/// Performance analytics repository implementation
import '../../core/models/models.dart';
import '../../core/repositories/performance_analytics_repository.dart';
import '../../core/services/logger_service.dart';
import '../datasources/local_performance_source.dart';

class PerformanceAnalyticsRepositoryImpl implements PerformanceAnalyticsRepository {
  PerformanceAnalyticsRepositoryImpl({
    required LocalPerformanceSource dataSource,
  }) : _dataSource = dataSource;

  final LocalPerformanceSource _dataSource;

  @override
  Future<PerformanceAnalytics?> get() async {
    try {
      return await _dataSource.getPerformanceAnalytics();
    } catch (e) {
      LoggerService.instance.error('Failed to get performance analytics', error: e, source: 'PerformanceAnalyticsRepository');
      return null;
    }
  }

  @override
  Stream<PerformanceAnalytics?> watch() {
    return _dataSource.watchPerformanceAnalytics();
  }

  @override
  Future<void> save(PerformanceAnalytics analytics) async {
    try {
      await _dataSource.savePerformanceAnalytics(analytics);
    } catch (e) {
      LoggerService.instance.error('Failed to save performance analytics', error: e, source: 'PerformanceAnalyticsRepository');
      rethrow;
    }
  }

  @override
  Future<PerformanceAnalytics> calculateAnalytics(
    List<ProgressEvent> events,
    List<Program> programs,
    ProgramState? currentState,
  ) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final weeklyEvents = events.where((e) => e.ts.isAfter(startOfWeek)).toList();

      // Calculate category progress
      final categoryProgress = await _calculateCategoryProgress(events, programs, currentState);

      // Calculate weekly stats
      final weeklyStats = _calculateWeeklyStats(weeklyEvents);

      // Calculate streak data
      final streakData = _calculateStreakData(events);

      // Get existing data for personal bests and intensity trends
      final existing = await get();
      final personalBests = existing?.personalBests ?? <String, PersonalBest>{};
      final intensityTrends = existing?.intensityTrends ?? <IntensityDataPoint>[];

      // Add new intensity data point if we have session data today
      final todayEvents = events.where((e) => 
        e.ts.year == now.year && 
        e.ts.month == now.month && 
        e.ts.day == now.day
      ).toList();

      List<IntensityDataPoint> updatedTrends = List.from(intensityTrends);
      if (todayEvents.isNotEmpty) {
        final sessionEvents = todayEvents.where((e) => 
          e.type == ProgressEventType.sessionCompleted
        ).toList();
        
        if (sessionEvents.isNotEmpty) {
          final intensity = _calculateSessionIntensity(todayEvents);
          final volume = todayEvents.where((e) => 
            e.type == ProgressEventType.exerciseDone
          ).length;
          final duration = _estimateSessionDuration(todayEvents);

          updatedTrends.add(IntensityDataPoint(
            date: now,
            intensity: intensity,
            volume: volume,
            duration: duration,
          ));

          // Keep only last 30 days
          updatedTrends = updatedTrends.where((dp) => 
            dp.date.isAfter(now.subtract(const Duration(days: 30)))
          ).toList();
        }
      }

      return PerformanceAnalytics(
        categoryProgress: categoryProgress,
        weeklyStats: weeklyStats,
        streakData: streakData,
        personalBests: personalBests,
        intensityTrends: updatedTrends,
        lastUpdated: now,
      );
    } catch (e) {
      LoggerService.instance.error('Failed to calculate performance analytics', error: e, source: 'PerformanceAnalyticsRepository');
      rethrow;
    }
  }

  @override
  Future<void> updateCategoryProgress(
    String exerciseId,
    ExerciseCategory category,
    String programId,
  ) async {
    try {
      final current = await get();
      if (current == null) return;

      final updatedProgress = Map<ExerciseCategory, double>.from(current.categoryProgress);
      final currentProgress = updatedProgress[category] ?? 0.0;
      
      // Increment by small amount per exercise completion
      updatedProgress[category] = (currentProgress + 0.01).clamp(0.0, 1.0);

      final updated = current.copyWith(
        categoryProgress: updatedProgress,
        lastUpdated: DateTime.now(),
      );

      await save(updated);
    } catch (e) {
      LoggerService.instance.error('Failed to update category progress', error: e, source: 'PerformanceAnalyticsRepository');
    }
  }

  @override
  Future<void> recordPersonalBest(PersonalBest personalBest) async {
    try {
      final current = await get();
      if (current == null) return;

      final updatedBests = Map<String, PersonalBest>.from(current.personalBests);
      updatedBests[personalBest.exerciseId] = personalBest;

      final updated = current.copyWith(
        personalBests: updatedBests,
        lastUpdated: DateTime.now(),
      );

      await save(updated);
    } catch (e) {
      LoggerService.instance.error('Failed to record personal best', error: e, source: 'PerformanceAnalyticsRepository');
    }
  }

  @override
  Future<void> updateIntensityData(IntensityDataPoint dataPoint) async {
    try {
      final current = await get();
      if (current == null) return;

      final updatedTrends = List<IntensityDataPoint>.from(current.intensityTrends);
      updatedTrends.add(dataPoint);

      // Keep only last 30 days
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      updatedTrends.removeWhere((dp) => dp.date.isBefore(cutoffDate));

      final updated = current.copyWith(
        intensityTrends: updatedTrends,
        lastUpdated: DateTime.now(),
      );

      await save(updated);
    } catch (e) {
      LoggerService.instance.error('Failed to update intensity data', error: e, source: 'PerformanceAnalyticsRepository');
    }
  }

  // Private helper methods
  Future<Map<ExerciseCategory, double>> _calculateCategoryProgress(
    List<ProgressEvent> events,
    List<Program> programs,
    ProgramState? currentState,
  ) async {
    if (currentState?.activeProgramId == null) {
      return <ExerciseCategory, double>{};
    }

    try {
      final program = programs.firstWhere((p) => p.id == currentState!.activeProgramId);
      final completedEvents = events.where((e) => 
        e.type == ProgressEventType.exerciseDone && e.programId == program.id
      ).toList();

      // Initialize all categories with 0.0
      final categoryProgress = <ExerciseCategory, double>{
        for (ExerciseCategory category in ExerciseCategory.values) category: 0.0,
      };

      // This is a simplified calculation - in a real app, you'd need access to exercise data
      // to map completed exercises to their categories
      final totalCompleted = completedEvents.length;
      if (totalCompleted > 0) {
        // Distribute progress across categories based on typical hockey training patterns
        categoryProgress[ExerciseCategory.strength] = (totalCompleted * 0.25).clamp(0.0, 1.0);
        categoryProgress[ExerciseCategory.power] = (totalCompleted * 0.20).clamp(0.0, 1.0);
        categoryProgress[ExerciseCategory.speed] = (totalCompleted * 0.15).clamp(0.0, 1.0);
        categoryProgress[ExerciseCategory.agility] = (totalCompleted * 0.15).clamp(0.0, 1.0);
        categoryProgress[ExerciseCategory.conditioning] = (totalCompleted * 0.25).clamp(0.0, 1.0);
      }

      return categoryProgress;
    } catch (e) {
      LoggerService.instance.error('Failed to calculate category progress', error: e, source: 'PerformanceAnalyticsRepository');
      return <ExerciseCategory, double>{};
    }
  }

  WeeklyStats _calculateWeeklyStats(List<ProgressEvent> weeklyEvents) {
    final sessionEvents = weeklyEvents.where((e) => 
      e.type == ProgressEventType.sessionCompleted
    ).toList();
    
    final exerciseEvents = weeklyEvents.where((e) => 
      e.type == ProgressEventType.exerciseDone
    ).toList();

    final bonusEvents = weeklyEvents.where((e) => 
      e.type == ProgressEventType.bonusDone
    ).toList();

    final totalSessions = sessionEvents.length;
    final totalExercises = exerciseEvents.length;
    final totalTrainingTime = totalSessions * 45; // Estimate 45 min per session
    final avgSessionDuration = totalSessions > 0 ? totalTrainingTime / totalSessions : 0.0;
    final completionRate = totalSessions > 0 ? 1.0 : 0.8; // Simplified calculation
    final xpEarned = (totalExercises * 10) + (totalSessions * 50) + (bonusEvents.length * 25);

    return WeeklyStats(
      totalSessions: totalSessions,
      totalExercises: totalExercises,
      totalTrainingTime: totalTrainingTime,
      avgSessionDuration: avgSessionDuration,
      completionRate: completionRate,
      xpEarned: xpEarned,
    );
  }

  StreakData _calculateStreakData(List<ProgressEvent> events) {
    final sessionEvents = events.where((e) => 
      e.type == ProgressEventType.sessionCompleted
    ).toList()..sort((a, b) => b.ts.compareTo(a.ts));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastDate;

    for (final event in sessionEvents.reversed) {
      final eventDate = DateTime(event.ts.year, event.ts.month, event.ts.day);
      
      if (lastDate == null) {
        tempStreak = 1;
        lastDate = eventDate;
      } else {
        final daysDiff = eventDate.difference(lastDate).inDays;
        if (daysDiff == 1) {
          tempStreak++;
        } else if (daysDiff > 1) {
          longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
          tempStreak = 1;
        }
        lastDate = eventDate;
      }
    }

    longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
    
    // Calculate current streak (consecutive days from today)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (lastDate != null) {
      final daysSinceLastSession = today.difference(lastDate).inDays;
      if (daysSinceLastSession <= 1) {
        currentStreak = tempStreak;
      }
    }

    // Calculate weekly progress
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weeklySessionCount = sessionEvents.where((e) => 
      e.ts.isAfter(startOfWeek)
    ).length;

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      weeklyGoal: 3, // Default weekly goal
      weeklyProgress: weeklySessionCount,
      lastTrainingDate: sessionEvents.isNotEmpty ? sessionEvents.first.ts : null,
    );
  }

  double _calculateSessionIntensity(List<ProgressEvent> sessionEvents) {
    final exerciseCount = sessionEvents.where((e) => 
      e.type == ProgressEventType.exerciseDone
    ).length;
    
    final bonusCount = sessionEvents.where((e) => 
      e.type == ProgressEventType.bonusDone
    ).length;

    // Base intensity on exercise count and bonus completions
    double intensity = 5.0; // Base intensity
    intensity += (exerciseCount * 0.1).clamp(0.0, 3.0);
    intensity += (bonusCount * 0.5).clamp(0.0, 2.0);
    
    return intensity.clamp(1.0, 10.0);
  }

  int _estimateSessionDuration(List<ProgressEvent> sessionEvents) {
    if (sessionEvents.length < 2) return 30; // Default 30 minutes

    final sortedEvents = sessionEvents..sort((a, b) => a.ts.compareTo(b.ts));
    final duration = sortedEvents.last.ts.difference(sortedEvents.first.ts).inMinutes;
    
    return duration.clamp(15, 120); // Between 15 and 120 minutes
  }

  @override
  Future<bool> clear() async {
    try {
      LoggerService.instance.warning('Clearing performance analytics data', source: 'PerformanceAnalyticsRepository');
      
      // We'll clear by saving a reset analytics object
      final resetAnalytics = PerformanceAnalytics(
        categoryProgress: <ExerciseCategory, double>{
          for (final category in ExerciseCategory.values) category: 0.0,
        },
        weeklyStats: const WeeklyStats(
          totalSessions: 0,
          totalExercises: 0,
          totalTrainingTime: 0,
          avgSessionDuration: 0.0,
          completionRate: 0.0,
          xpEarned: 0,
        ),
        streakData: const StreakData(
          currentStreak: 0,
          longestStreak: 0,
          weeklyGoal: 3,
          weeklyProgress: 0,
          lastTrainingDate: null,
        ),
        personalBests: <String, PersonalBest>{},
        intensityTrends: <IntensityDataPoint>[],
        lastUpdated: DateTime.now(),
      );
      
      await save(resetAnalytics);
      LoggerService.instance.info('Performance analytics cleared successfully', source: 'PerformanceAnalyticsRepository');
      return true;
      
    } catch (e) {
      LoggerService.instance.error('Failed to clear performance analytics', error: e, source: 'PerformanceAnalyticsRepository');
      return false;
    }
  }
}
