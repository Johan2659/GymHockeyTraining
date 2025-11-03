import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/di.dart';
import '../../core/models/models.dart';
import '../../core/utils/selectors.dart';
import '../../core/persistence/persistence_service.dart';
import '../../core/services/logger_service.dart';
import '../profile/application/profile_controller.dart';

part 'app_state_provider.g.dart';

/// Comprehensive app state provider that serves as the Single Source of Truth (SSOT)
/// Aggregates all repositories and computes derived values

// =============================================================================
// Stream Providers for Real-time Data
// =============================================================================

/// Stream of all progress events
@riverpod
Stream<List<ProgressEvent>> progressEvents(Ref ref) {
  final repository = ref.watch(progressRepositoryProvider);
  return repository.watchAll();
}

/// Stream of current program state
@riverpod
Stream<ProgramState?> programState(Ref ref) {
  final repository = ref.watch(programStateRepositoryProvider);
  return repository.watch();
}

/// Stream of user profile
@riverpod
Stream<Profile?> userProfile(Ref ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.watch();
}

// =============================================================================
// Data Providers
// =============================================================================

/// Available programs provider
@riverpod
Future<List<Program>> availablePrograms(Ref ref) {
  final repository = ref.watch(programRepositoryProvider);
  return repository.getAll();
}

/// Available extras provider
@riverpod
Future<List<ExtraItem>> availableExtras(Ref ref) {
  final repository = ref.watch(extrasRepositoryProvider);
  return repository.getAll();
}

/// Express workouts provider
@riverpod
Future<List<ExtraItem>> expressWorkouts(Ref ref) {
  final repository = ref.watch(extrasRepositoryProvider);
  return repository.getByType(ExtraType.expressWorkout);
}

/// Bonus challenges provider
@riverpod
Future<List<ExtraItem>> bonusChallenges(Ref ref) {
  final repository = ref.watch(extrasRepositoryProvider);
  return repository.getByType(ExtraType.bonusChallenge);
}

/// Mobility & recovery provider
@riverpod
Future<List<ExtraItem>> mobilityRecovery(Ref ref) {
  final repository = ref.watch(extrasRepositoryProvider);
  return repository.getByType(ExtraType.mobilityRecovery);
}

/// Performance analytics provider
@riverpod
Future<PerformanceAnalytics?> performanceAnalytics(Ref ref) async {
  final repository = ref.watch(performanceAnalyticsRepositoryProvider);
  try {
    final existing = await repository.get();
    if (existing != null) {
      return existing;
    }

    // Create default analytics if none exist
    final defaultAnalytics = PerformanceAnalytics(
      weeklyStats: WeeklyStats(
        totalSessions: 0,
        totalExercises: 0,
        totalTrainingTime: 0,
        avgSessionDuration: 0.0,
        completionRate: 0.0,
        xpEarned: 0,
      ),
      categoryProgress: <ExerciseCategory, double>{
        for (final category in ExerciseCategory.values) category: 0.0,
      },
      streakData: StreakData(
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

    await repository.save(defaultAnalytics);
    return defaultAnalytics;
  } catch (e) {
    LoggerService.instance.error('Failed to get performance analytics',
        error: e, source: 'AppStateProvider');
    return null;
  }
}

/// Current category progress provider
@riverpod
Future<Map<ExerciseCategory, double>> categoryProgress(Ref ref) async {
  final analytics = await ref.watch(performanceAnalyticsProvider.future);
  return analytics?.categoryProgress ??
      <ExerciseCategory, double>{
        for (final category in ExerciseCategory.values) category: 0.0,
      };
}

/// Weekly training stats provider
@riverpod
Future<WeeklyStats?> weeklyStats(Ref ref) async {
  final analytics = await ref.watch(performanceAnalyticsProvider.future);
  return analytics?.weeklyStats ??
      WeeklyStats(
        totalSessions: 0,
        totalExercises: 0,
        totalTrainingTime: 0,
        avgSessionDuration: 0.0,
        completionRate: 0.0,
        xpEarned: 0,
      );
}

/// Streak data provider
@riverpod
Future<StreakData?> streakData(Ref ref) async {
  final analytics = await ref.watch(performanceAnalyticsProvider.future);
  return analytics?.streakData;
}

/// Personal bests provider
@riverpod
Future<Map<String, PersonalBest>> personalBests(Ref ref) async {
  final analytics = await ref.watch(performanceAnalyticsProvider.future);
  return analytics?.personalBests ?? <String, PersonalBest>{};
}

/// Training intensity trends provider
@riverpod
Future<List<IntensityDataPoint>> intensityTrends(Ref ref) async {
  final analytics = await ref.watch(performanceAnalyticsProvider.future);
  return analytics?.intensityTrends ?? <IntensityDataPoint>[];
}

/// Current active program provider
@riverpod
Future<Program?> activeProgram(Ref ref) async {
  try {
    final state = await ref.watch(programStateProvider.future);
    if (state?.activeProgramId == null) return null;

    final repository = ref.watch(programRepositoryProvider);
    final program = await repository.getById(state!.activeProgramId!);
    
    // Additional safety check
    if (program == null) {
      LoggerService.instance.warning('Active program not found', 
          source: 'activeProgramProvider', 
          metadata: {'programId': state.activeProgramId});
      return null;
    }
    
    return program;
  } catch (e, stackTrace) {
    LoggerService.instance.error('Failed to get active program',
        source: 'activeProgramProvider',
        error: e,
        stackTrace: stackTrace);
    return null;
  }
}

// =============================================================================
// Derived Value Providers (Computed State)
// =============================================================================

/// Current user XP
@riverpod
Future<int> currentXP(Ref ref) async {
  final events = await ref.watch(progressEventsProvider.future);
  return Selectors.calculateTotalXP(events);
}

/// XP gained today
@riverpod
Future<int> todayXP(Ref ref) async {
  final events = await ref.watch(progressEventsProvider.future);
  return Selectors.calculateTodayXP(events);
}

/// Current streak
@riverpod
Future<int> currentStreak(Ref ref) async {
  final events = await ref.watch(progressEventsProvider.future);
  return Selectors.calculateCurrentStreak(events);
}

/// XP multiplier based on streak
@riverpod
double xpMultiplier(Ref ref) {
  final streak = ref.watch(currentStreakProvider).value ?? 0;
  return Selectors.getXPMultiplier(streak);
}

/// Current program completion percentage (pure async)
@riverpod
Future<double> percentCycle(Ref ref) async {
  final state = await ref.watch(programStateProvider.future);
  final programs = await ref.watch(availableProgramsProvider.future);
  return SelectorsExt.calculatePercentCycle(state, programs);
}

/// Next session reference
@riverpod
Future<Session?> nextSessionRef(Ref ref) async {
  final state = await ref.watch(programStateProvider.future);
  if (state?.activeProgramId == null) return null;

  final programs = await ref.watch(availableProgramsProvider.future);
  final activeProgram = programs.firstWhere(
    (p) => p.id == state!.activeProgramId,
    orElse: () => const Program(
      id: 'unknown',
      title: 'Unknown',
      role: UserRole.attacker,
      weeks: [],
    ),
  );

  if (activeProgram.weeks.isEmpty ||
      state!.currentWeek >= activeProgram.weeks.length) {
    return null;
  }

  final currentWeek = activeProgram.weeks[state.currentWeek];
  if (state.currentSession >= currentWeek.sessions.length) {
    return null;
  }

  final sessionId = currentWeek.sessions[state.currentSession];
  return Session(
    id: sessionId,
    title: 'Session ${state.currentSession + 1}',
    blocks: [],
    bonusChallenge: 'Complete the session',
  );
}

// =============================================================================
// Action Providers (Separate from main state to avoid dependency issues)
// =============================================================================

/// Start program action provider
@riverpod
Future<void> startProgramAction(Ref ref, String programId) async {
  try {
    LoggerService.instance.info('Starting program action',
        source: 'startProgramAction', metadata: {'programId': programId});

    final stateRepo = ref.read(programStateRepositoryProvider);
    final progressRepo = ref.read(progressRepositoryProvider);

    PersistenceService.logStateChange('Starting program: $programId');

    final newState = ProgramState(
      activeProgramId: programId,
      currentWeek: 0,
      currentSession: 0,
      completedExerciseIds: [],
    );

    await stateRepo.save(newState);

    final event = ProgressEvent(
      ts: DateTime.now(),
      type: ProgressEventType.sessionStarted,
      programId: programId,
      week: 0,
      session: 0,
    );

    await progressRepo.appendEvent(event);

    LoggerService.instance.info('Program started successfully',
        source: 'startProgramAction', metadata: {'programId': programId});
  } catch (e, stackTrace) {
    LoggerService.instance.error('Failed to start program',
        source: 'startProgramAction',
        error: e,
        stackTrace: stackTrace,
        metadata: {'programId': programId});
    rethrow;
  }
}

/// Mark exercise done action provider
@riverpod
Future<void> markExerciseDoneAction(Ref ref, String exerciseId) async {
  final stateRepo = ref.read(programStateRepositoryProvider);
  final progressRepo = ref.read(progressRepositoryProvider);
  final analyticsRepo = ref.read(performanceAnalyticsRepositoryProvider);

  final currentState = await stateRepo.get();
  if (currentState?.activeProgramId == null) return;

  await stateRepo.addCompletedExercise(exerciseId);

  final event = ProgressEvent(
    ts: DateTime.now(),
    type: ProgressEventType.exerciseDone,
    programId: currentState!.activeProgramId!,
    week: currentState.currentWeek,
    session: currentState.currentSession,
    exerciseId: exerciseId,
  );

  await progressRepo.appendEvent(event);

  // Update performance analytics
  try {
    // For now, we'll assume a default category - in a real app, you'd look up the exercise
    await analyticsRepo.updateCategoryProgress(
      exerciseId,
      ExerciseCategory.strength, // Default category
      currentState.activeProgramId!,
    );
  } catch (e) {
    LoggerService.instance.warning('Failed to update performance analytics',
        source: 'markExerciseDoneAction', error: e);
  }
}

/// Complete session action provider
@riverpod
Future<void> completeSessionAction(Ref ref) async {
  final stateRepo = ref.read(programStateRepositoryProvider);
  final progressRepo = ref.read(progressRepositoryProvider);
  final analyticsRepo = ref.read(performanceAnalyticsRepositoryProvider);

  final currentState = await stateRepo.get();
  if (currentState?.activeProgramId == null) return;

  PersistenceService.logStateChange(
      'Completing session - Week: ${currentState!.currentWeek}, Session: ${currentState.currentSession}');

  final event = ProgressEvent(
    ts: DateTime.now(),
    type: ProgressEventType.sessionCompleted,
    programId: currentState.activeProgramId!,
    week: currentState.currentWeek,
    session: currentState.currentSession,
  );

  await progressRepo.appendEvent(event);
  await stateRepo.updateCurrentSession(currentState.currentSession + 1);

  // Update performance analytics with session completion
  try {
    final events =
        await progressRepo.getRecent(limit: 1000); // Get all recent events
    final programs = await ref.read(programRepositoryProvider).getAll();
    final updatedAnalytics = await analyticsRepo.calculateAnalytics(
      events,
      programs,
      currentState,
    );
    await analyticsRepo.save(updatedAnalytics);
    
    // Invalidate the cache so the UI updates immediately
    ref.invalidate(performanceAnalyticsProvider);
    ref.invalidate(categoryProgressProvider);
  } catch (e) {
    LoggerService.instance.warning(
        'Failed to update performance analytics after session completion',
        source: 'completeSessionAction',
        error: e);
  }
}

/// Pause program action provider
@riverpod
Future<void> pauseProgramAction(Ref ref) async {
  final stateRepo = ref.read(programStateRepositoryProvider);
  await stateRepo.pauseProgram();
}

/// Resume program action provider
@riverpod
Future<void> resumeProgramAction(Ref ref) async {
  final stateRepo = ref.read(programStateRepositoryProvider);
  await stateRepo.resumeProgram();
}

/// Reset current session to 0 (DEBUG - for testing)
@riverpod
Future<void> resetSessionAction(Ref ref) async {
  final stateRepo = ref.read(programStateRepositoryProvider);
  await stateRepo.updateCurrentSession(0);
  LoggerService.instance.info('Session reset to 0', source: 'resetSessionAction');
}

/// Complete bonus challenge action provider
@riverpod
Future<void> completeBonusChallengeAction(Ref ref) async {
  final stateRepo = ref.read(programStateRepositoryProvider);
  final progressRepo = ref.read(progressRepositoryProvider);

  final currentState = await stateRepo.get();
  if (currentState?.activeProgramId == null) return;

  final event = ProgressEvent(
    ts: DateTime.now(),
    type: ProgressEventType.bonusDone,
    programId: currentState!.activeProgramId!,
    week: currentState.currentWeek,
    session: currentState.currentSession,
  );

  await progressRepo.appendEvent(event);
}

/// Start session action provider
@riverpod
Future<void> startSessionAction(
    Ref ref, String programId, int week, int session) async {
  final progressRepo = ref.read(progressRepositoryProvider);

  final event = ProgressEvent(
    ts: DateTime.now(),
    type: ProgressEventType.sessionStarted,
    programId: programId,
    week: week,
    session: session,
  );

  await progressRepo.appendEvent(event);
}

/// Start extra action provider
@riverpod
Future<void> startExtraAction(Ref ref, String extraId) async {
  try {
    LoggerService.instance.info('Starting extra action',
        source: 'startExtraAction', metadata: {'extraId': extraId});

    PersistenceService.logStateChange('Starting extra session: $extraId');

    final progressRepo = ref.read(progressRepositoryProvider);
    final event = ProgressEvent(
      ts: DateTime.now(),
      type: ProgressEventType.sessionStarted,
      programId: extraId,
      week: 0,
      session: 0,
      payload: {
        'context': 'extra_session',
      },
    );

    await progressRepo.appendEvent(event);
  } catch (e, stackTrace) {
    LoggerService.instance.error('Failed to start extra',
        source: 'startExtraAction',
        error: e,
        stackTrace: stackTrace,
        metadata: {'extraId': extraId});
  }
}

/// Complete extra action provider
@riverpod
Future<void> completeExtraAction(Ref ref, String extraId, int xpReward) async {
  final progressRepo = ref.read(progressRepositoryProvider);

  PersistenceService.logStateChange(
      'Completing extra: $extraId with XP reward: $xpReward');

  final event = ProgressEvent(
    ts: DateTime.now(),
    type: ProgressEventType.extraCompleted,
    programId: extraId, // Using extraId as programId for extras
    week: 0, // Extras don't have weeks
    session: 0, // Extras don't have sessions
    exerciseId: extraId,
    payload: {
      'xp_reward': xpReward,
      'extra_type': 'extra_completion',
    },
  );

  await progressRepo.appendEvent(event);
}

/// Save exercise performance action provider
@riverpod
Future<bool> saveExercisePerformanceAction(
    Ref ref, ExercisePerformance performance) async {
  try {
    final performanceRepo = ref.read(exercisePerformanceRepositoryProvider);
    final success = await performanceRepo.save(performance);

    if (success) {
      LoggerService.instance.info('Exercise performance saved',
          source: 'saveExercisePerformanceAction',
          metadata: {
            'exerciseId': performance.exerciseId,
            'sets': performance.sets.length
          });
    }

    return success;
  } catch (e) {
    LoggerService.instance.error('Failed to save exercise performance',
        source: 'saveExercisePerformanceAction', error: e);
    return false;
  }
}

/// Get last performance for exercise provider
@riverpod
Future<ExercisePerformance?> lastPerformance(Ref ref, String exerciseId) async {
  try {
    final performanceRepo = ref.read(exercisePerformanceRepositoryProvider);
    return await performanceRepo.getLastPerformance(exerciseId);
  } catch (e) {
    LoggerService.instance.error('Failed to get last performance',
        source: 'lastPerformanceProvider', error: e);
    return null;
  }
}

/// Save session in progress action provider
@riverpod
Future<bool> saveSessionInProgressAction(Ref ref, SessionInProgress session) async {
  try {
    final stateRepo = ref.read(programStateRepositoryProvider);
    final success = await stateRepo.saveSessionInProgress(session);

    if (success) {
      LoggerService.instance.info('Session in progress saved',
          source: 'saveSessionInProgressAction',
          metadata: {
            'programId': session.programId,
            'week': session.week,
            'session': session.session
          });
      
      // Invalidate program state to trigger UI updates
      ref.invalidate(programStateProvider);
    }

    return success;
  } catch (e) {
    LoggerService.instance.error('Failed to save session in progress',
        source: 'saveSessionInProgressAction', error: e);
    return false;
  }
}

/// Clear session in progress action provider
@riverpod
Future<bool> clearSessionInProgressAction(Ref ref) async {
  try {
    final stateRepo = ref.read(programStateRepositoryProvider);
    final success = await stateRepo.clearSessionInProgress();

    if (success) {
      LoggerService.instance.info('Session in progress cleared',
          source: 'clearSessionInProgressAction');
      
      // Invalidate program state to trigger UI updates
      ref.invalidate(programStateProvider);
    }

    return success;
  } catch (e) {
    LoggerService.instance.error('Failed to clear session in progress',
        source: 'clearSessionInProgressAction', error: e);
    return false;
  }
}

/// Get session in progress provider
@riverpod
Future<SessionInProgress?> sessionInProgress(Ref ref) async {
  try {
    final state = await ref.watch(programStateProvider.future);
    return state?.sessionInProgress;
  } catch (e) {
    LoggerService.instance.error('Failed to get session in progress',
        source: 'sessionInProgressProvider', error: e);
    return null;
  }
}

// =============================================================================
// Profile Action Providers
// =============================================================================

/// Update role action provider
@riverpod
Future<bool> updateRoleAction(Ref ref, UserRole role) async {
  final profileController = ref.read(profileControllerProvider.notifier);
  final success = await profileController.updateRole(role);

  if (success) {
    // Invalidate providers that depend on profile data
    ref.invalidate(userProfileProvider);
    ref.invalidate(availableProgramsProvider);
  }

  return success;
}

/// Update units action provider
@riverpod
Future<bool> updateUnitsAction(Ref ref, String units) async {
  final profileController = ref.read(profileControllerProvider.notifier);
  final success = await profileController.updateUnits(units);

  if (success) {
    ref.invalidate(userProfileProvider);
  }

  return success;
}

/// Update language action provider
@riverpod
Future<bool> updateLanguageAction(Ref ref, String language) async {
  final profileController = ref.read(profileControllerProvider.notifier);
  final success = await profileController.updateLanguage(language);

  if (success) {
    ref.invalidate(userProfileProvider);
  }

  return success;
}

/// Update theme action provider
@riverpod
Future<bool> updateThemeAction(Ref ref, String theme) async {
  final profileController = ref.read(profileControllerProvider.notifier);
  final success = await profileController.updateTheme(theme);

  if (success) {
    ref.invalidate(userProfileProvider);
  }

  return success;
}

/// Export logs action provider
@riverpod
Future<String?> exportLogsAction(Ref ref) async {
  final profileController = ref.read(profileControllerProvider.notifier);
  return await profileController.exportLogs();
}

/// Delete account action provider
@riverpod
Future<bool> deleteAccountAction(Ref ref) async {
  final profileController = ref.read(profileControllerProvider.notifier);
  final success = await profileController.deleteAccount();

  if (success) {
    // Invalidate all major providers after account deletion
    ref.invalidate(progressEventsProvider);
    ref.invalidate(programStateProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(currentXPProvider);
    ref.invalidate(todayXPProvider);
    ref.invalidate(currentStreakProvider);
    ref.invalidate(percentCycleProvider);
  }

  return success;
}

/// Initialize performance analytics action provider
@riverpod
Future<void> initializePerformanceAnalyticsAction(Ref ref) async {
  try {
    final analyticsRepo = ref.read(performanceAnalyticsRepositoryProvider);
    final existing = await analyticsRepo.get();

    // Only initialize if analytics don't exist
    if (existing == null) {
      final initialAnalytics = PerformanceAnalytics(
        categoryProgress: <ExerciseCategory, double>{
          for (ExerciseCategory category in ExerciseCategory.values)
            category: 0.0,
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

      await analyticsRepo.save(initialAnalytics);
      LoggerService.instance.info('Performance analytics initialized',
          source: 'initializePerformanceAnalyticsAction');
    }
  } catch (e) {
    LoggerService.instance.error('Failed to initialize performance analytics',
        source: 'initializePerformanceAnalyticsAction', error: e);
  }
}

// =============================================================================
// App State Provider (Main SSOT)
// =============================================================================

/// Main app state provider that aggregates all state and provides action methods
@riverpod
class AppState extends _$AppState {
  @override
  Future<AppStateData> build() async {
    // Fully async style — no `.value` mixing
    final events = await ref.watch(progressEventsProvider.future);
    final state = await ref.watch(programStateProvider.future);
    final profile = await ref.watch(userProfileProvider.future);
    final programs = await ref.watch(availableProgramsProvider.future);
    final activeProgram = await ref.watch(activeProgramProvider.future);
    final nextSession = await ref.watch(nextSessionRefProvider.future);

    final currentXP = Selectors.calculateTotalXP(events);
    final todayXP = Selectors.calculateTodayXP(events);
    final streak = Selectors.calculateCurrentStreak(events);
    final xpMultiplier = Selectors.getXPMultiplier(streak);
    final percentCycle = SelectorsExt.calculatePercentCycle(state, programs);

    return AppStateData(
      // Core data
      programs: programs,
      events: events,
      state: state,
      profile: profile,
      activeProgram: activeProgram,

      // Derived values
      currentXP: currentXP,
      todayXP: todayXP,
      currentStreak: streak,
      xpMultiplier: xpMultiplier,
      percentCycle: percentCycle,
      nextSession: nextSession,
    );
  }
}

/// Data class representing the complete app state
class AppStateData {
  const AppStateData({
    required this.programs,
    required this.events,
    required this.state,
    required this.profile,
    required this.activeProgram,
    required this.currentXP,
    required this.todayXP,
    required this.currentStreak,
    required this.xpMultiplier,
    required this.percentCycle,
    required this.nextSession,
  });

  // Core data
  final List<Program> programs;
  final List<ProgressEvent> events;
  final ProgramState? state;
  final Profile? profile;
  final Program? activeProgram;

  // Derived values
  final int currentXP;
  final int todayXP;
  final int currentStreak;
  final double xpMultiplier;
  final double percentCycle;
  final Session? nextSession;

  /// Check if a program is currently active
  bool get hasActiveProgram => state?.activeProgramId != null;

  /// Check if the program is paused
  bool get isProgramPaused => state?.pausedAt != null;

  /// Get current user role
  UserRole? get userRole => profile?.role;
}

// =============================================================================
// Helpers
// =============================================================================

extension SelectorsExt on Selectors {
  static double calculatePercentCycle(
      ProgramState? state, List<Program> programs) {
    if (state?.activeProgramId == null) return 0.0;

    final activeProgram = programs.firstWhere(
      (p) => p.id == state!.activeProgramId,
      orElse: () => const Program(
        id: 'unknown',
        title: 'Unknown',
        role: UserRole.attacker,
        weeks: [],
      ),
    );

    if (activeProgram.weeks.isEmpty) return 0.0;

    final totalSessions = activeProgram.weeks.fold<int>(
      0,
      (sum, week) => sum + week.sessions.length,
    );
    if (totalSessions == 0) return 0.0;

    var completedSessions = 0;
    for (int i = 0; i < state!.currentWeek; i++) {
      if (i < activeProgram.weeks.length) {
        completedSessions += activeProgram.weeks[i].sessions.length;
      }
    }
    completedSessions += state.currentSession;

    return completedSessions / totalSessions;
  }
}
