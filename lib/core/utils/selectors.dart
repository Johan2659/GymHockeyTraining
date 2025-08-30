import '../models/models.dart';

/// Utility functions for calculating derived values from app state
/// These selectors compute XP, progress percentages, streaks, and other derived data

class Selectors {
  // =============================================================================
  // Constants for game mechanics
  // =============================================================================
  
  /// XP required per level
  static const int xpPerLevel = 100;
  
  /// Streak thresholds for different motivational messages
  static const int streakWeekThreshold = 7;
  static const int streakMomentumThreshold = 3;
  
  /// Progress percentage thresholds for motivational messages
  static const double progressNearCompleteThreshold = 0.8;
  static const double progressHalfwayThreshold = 0.5;
  /// Calculate XP gained from progress events
  /// Note: XP calculation logic to be implemented based on event types
  static int calculateTotalXP(List<ProgressEvent> events) {
    return events.fold(0, (total, event) {
      // Base XP per event type
      switch (event.type) {
        case ProgressEventType.exerciseDone:
          return total + 10;
        case ProgressEventType.sessionCompleted:
          return total + 50;
        case ProgressEventType.bonusDone:
          return total + 25;
        case ProgressEventType.sessionStarted:
          return total + 5;
      }
    });
  }

  /// Calculate XP gained today
  static int calculateTodayXP(List<ProgressEvent> events) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return events
        .where((event) => 
            event.ts.isAfter(todayStart) && 
            event.ts.isBefore(todayEnd))
        .fold(0, (total, event) {
          switch (event.type) {
            case ProgressEventType.exerciseDone:
              return total + 10;
            case ProgressEventType.sessionCompleted:
              return total + 50;
            case ProgressEventType.bonusDone:
              return total + 25;
            case ProgressEventType.sessionStarted:
              return total + 5;
          }
        });
  }

  /// Calculate current streak (consecutive days with progress)
  static int calculateCurrentStreak(List<ProgressEvent> events) {
    if (events.isEmpty) return 0;

    // Sort events by date descending
    final sortedEvents = events.toList()
      ..sort((a, b) => b.ts.compareTo(a.ts));

    // Group events by day
    final eventsByDay = <String, List<ProgressEvent>>{};
    for (final event in sortedEvents) {
      final dayKey = _getDayKey(event.ts);
      eventsByDay.putIfAbsent(dayKey, () => []).add(event);
    }

    final today = DateTime.now();
    var currentDate = DateTime(today.year, today.month, today.day);
    var streak = 0;

    // Check if there's activity today
    var dayKey = _getDayKey(currentDate);
    if (!eventsByDay.containsKey(dayKey)) {
      // No activity today, check yesterday
      currentDate = currentDate.subtract(const Duration(days: 1));
      dayKey = _getDayKey(currentDate);
    }

    // Count consecutive days with activity
    while (eventsByDay.containsKey(dayKey)) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
      dayKey = _getDayKey(currentDate);
    }

    return streak;
  }

  /// Calculate session completion percentage
  static double calculateSessionProgress(
    Session session,
    List<ProgressEvent> events,
  ) {
    if (session.blocks.isEmpty) return 0.0;

    final completedExercises = events
        .where((event) => 
            event.type == ProgressEventType.exerciseDone &&
            session.blocks.any((block) => block.exerciseId == event.exerciseId))
        .map((event) => event.exerciseId)
        .where((id) => id != null)
        .cast<String>()
        .toSet();

    return completedExercises.length / session.blocks.length;
  }

  /// Calculate week completion percentage
  static double calculateWeekProgress(
    Week week,
    List<Session> sessions,
    List<ProgressEvent> events,
  ) {
    if (week.sessions.isEmpty) return 0.0;

    var totalProgress = 0.0;
    
    for (final sessionId in week.sessions) {
      final session = sessions.firstWhere(
        (s) => s.id == sessionId,
        orElse: () => const Session(
          id: 'unknown',
          title: 'Unknown',
          blocks: [],
          bonusChallenge: '',
        ),
      );
      
      totalProgress += calculateSessionProgress(session, events);
    }

    return totalProgress / week.sessions.length;
  }

  /// Calculate program completion percentage
  static double calculateProgramProgress(
    Program program,
    List<Session> sessions,
    List<ProgressEvent> events,
  ) {
    if (program.weeks.isEmpty) return 0.0;

    var totalProgress = 0.0;
    
    for (final week in program.weeks) {
      totalProgress += calculateWeekProgress(week, sessions, events);
    }

    return totalProgress / program.weeks.length;
  }

  /// Check if a session is completed
  static bool isSessionCompleted(
    Session session,
    List<ProgressEvent> events,
  ) {
    return events.any((event) =>
        event.type == ProgressEventType.sessionCompleted &&
        event.session.toString() == session.id);
  }

  /// Check if a week is completed
  static bool isWeekCompleted(
    Week week,
    List<Session> sessions,
    List<ProgressEvent> events,
  ) {
    return calculateWeekProgress(week, sessions, events) >= 1.0;
  }

  /// Check if a program is completed
  static bool isProgramCompleted(
    Program program,
    List<Session> sessions,
    List<ProgressEvent> events,
  ) {
    return calculateProgramProgress(program, sessions, events) >= 1.0;
  }

  /// Get the current active session for a user
  static Session? getCurrentSession(
    Program? program,
    List<Session> sessions,
    ProgramState? state,
  ) {
    if (program == null || state == null || state.activeProgramId == null) {
      return null;
    }

    final currentWeek = program.weeks.firstWhere(
      (w) => w.index == state.currentWeek,
      orElse: () => program.weeks.first,
    );

    if (state.currentSession >= currentWeek.sessions.length) return null;

    final sessionId = currentWeek.sessions[state.currentSession];
    return sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => sessions.first,
    );
  }

  /// Get next session to complete
  static Session? getNextSession(
    Program program,
    List<Session> sessions,
    ProgramState state,
    List<ProgressEvent> events,
  ) {
    for (final week in program.weeks) {
      if (week.index < state.currentWeek) continue;
      
      for (int i = 0; i < week.sessions.length; i++) {
        if (week.index == state.currentWeek && i < state.currentSession) {
          continue;
        }
        
        final sessionId = week.sessions[i];
        final session = sessions.firstWhere(
          (s) => s.id == sessionId,
          orElse: () => const Session(
            id: 'unknown',
            title: 'Unknown',
            blocks: [],
            bonusChallenge: '',
          ),
        );
        
        if (!isSessionCompleted(session, events)) {
          return session;
        }
      }
    }
    
    return null; // Program completed
  }

  /// Calculate XP multiplier based on streak
  static double getXPMultiplier(int streak) {
    if (streak <= 1) return 1.0;
    if (streak <= 7) return 1.1;   // 10% bonus for week streak
    if (streak <= 30) return 1.25; // 25% bonus for month streak
    return 1.5; // 50% bonus for 30+ day streak
  }

  /// Calculate user level from total XP
  static int calculateLevel(int totalXP) {
    return (totalXP / xpPerLevel).floor() + 1;
  }

  /// Helper to get day key for grouping events
  static String _getDayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
