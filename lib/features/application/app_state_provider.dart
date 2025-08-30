import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/di.dart';
import '../../core/models/models.dart';
import '../../core/utils/selectors.dart';

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

/// Current active program provider
@riverpod
Future<Program?> activeProgram(Ref ref) async {
  final state = await ref.watch(programStateProvider.future);
  if (state?.activeProgramId == null) return null;

  final repository = ref.watch(programRepositoryProvider);
  return repository.getById(state!.activeProgramId!);
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

  if (activeProgram.weeks.isEmpty || state!.currentWeek >= activeProgram.weeks.length) {
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
  final stateRepo = ref.read(programStateRepositoryProvider);
  final progressRepo = ref.read(progressRepositoryProvider);

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
}

/// Mark exercise done action provider
@riverpod
Future<void> markExerciseDoneAction(Ref ref, String exerciseId) async {
  final stateRepo = ref.read(programStateRepositoryProvider);
  final progressRepo = ref.read(progressRepositoryProvider);

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
}

/// Complete session action provider
@riverpod
Future<void> completeSessionAction(Ref ref) async {
  final stateRepo = ref.read(programStateRepositoryProvider);
  final progressRepo = ref.read(progressRepositoryProvider);

  final currentState = await stateRepo.get();
  if (currentState?.activeProgramId == null) return;

  final event = ProgressEvent(
    ts: DateTime.now(),
    type: ProgressEventType.sessionCompleted,
    programId: currentState!.activeProgramId!,
    week: currentState.currentWeek,
    session: currentState.currentSession,
  );

  await progressRepo.appendEvent(event);
  await stateRepo.updateCurrentSession(currentState.currentSession + 1);
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
  static double calculatePercentCycle(ProgramState? state, List<Program> programs) {
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
      0, (sum, week) => sum + week.sessions.length,
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
