import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'package:gymhockeytraining/data/repositories_impl/repositories_impl.dart';

/// Simple verification script to test repository functionality
/// Run this to verify the three main requirements
Future<void> main() async {
  print('🏒 Hockey Gym Repository Verification Starting...\n');

  try {
    await verifyProgramRepository();
    await verifyProgressRepository();
    await verifyProgramStateRepository();

    print('\n✅ All repository verifications PASSED! 🎯');
  } catch (e, stackTrace) {
    print('\n❌ Repository verification FAILED: $e');
    if (kDebugMode) {
      print('Stack trace: $stackTrace');
    }
    exit(1);
  }
}

/// Verify ProgramRepository returns valid programs (Attacker not empty)
Future<void> verifyProgramRepository() async {
  print('📋 Testing ProgramRepository...');

  final repository = ProgramRepositoryImpl();

  // Test 1: Get all programs
  final allPrograms = await repository.getAll();
  if (allPrograms.isEmpty) {
    throw Exception('❌ ProgramRepository.getAll() returned empty list');
  }
  print('  ✅ getAll() returned ${allPrograms.length} programs');

  // Test 2: Get attacker programs
  final attackerPrograms = await repository.listByRole(UserRole.attacker);
  if (attackerPrograms.isEmpty) {
    throw Exception(
        '❌ ProgramRepository.listByRole(attacker) returned empty list');
  }
  print(
      '  ✅ listByRole(attacker) returned ${attackerPrograms.length} programs');

  // Test 3: Verify program structure
  final program = attackerPrograms.first;
  if (program.id != 'hockey_attacker_v1') {
    throw Exception('❌ Program ID mismatch: ${program.id}');
  }
  if (program.weeks.isEmpty) {
    throw Exception('❌ Program has no weeks');
  }
  if (program.weeks.first.sessions.isEmpty) {
    throw Exception('❌ Program week has no sessions');
  }

  print('  ✅ Program structure validation passed');
  print('  📊 Program: ${program.title}');
  print('  📊 Weeks: ${program.weeks.length}');
  print('  📊 Sessions in week 1: ${program.weeks.first.sessions.length}');
}

/// Verify ProgressRepository appendEvent works, watchAll emits updates
Future<void> verifyProgressRepository() async {
  print('\n📈 Testing ProgressRepository...');

  final repository = ProgressRepositoryImpl();

  // Test 1: Create test event
  final testEvent = ProgressEvent(
    ts: DateTime.now(),
    type: ProgressEventType.sessionStarted,
    programId: 'hockey_attacker_v1',
    week: 1,
    session: 1,
    exerciseId: 'test_exercise',
    payload: {'verification': true},
  );

  // Test 2: Append event
  final appendSuccess = await repository.appendEvent(testEvent);
  if (!appendSuccess) {
    throw Exception('❌ ProgressRepository.appendEvent() failed');
  }
  print('  ✅ appendEvent() succeeded');

  // Test 3: Verify event was stored
  final recentEvents = await repository.getRecent(limit: 5);
  final foundEvent = recentEvents.any((event) =>
      event.programId == testEvent.programId &&
      event.type == testEvent.type &&
      event.exerciseId == testEvent.exerciseId);

  if (!foundEvent) {
    throw Exception('❌ Appended event not found in recent events');
  }
  print('  ✅ Event successfully stored and retrieved');

  // Test 4: Test watchAll stream (basic verification)
  var streamEmitted = false;
  final subscription = repository.watchAll().listen((events) {
    streamEmitted = true;
  });

  // Give stream time to emit
  await Future.delayed(const Duration(milliseconds: 200));

  if (!streamEmitted) {
    throw Exception('❌ watchAll() stream did not emit');
  }
  print('  ✅ watchAll() stream emitted events');

  await subscription.cancel();

  print('  📊 Recent events count: ${recentEvents.length}');
}

/// Verify ProgramStateRepository reads/writes correctly
Future<void> verifyProgramStateRepository() async {
  print('\n💾 Testing ProgramStateRepository...');

  final repository = ProgramStateRepositoryImpl();

  // Test 1: Initial state should be null
  final initialState = await repository.get();
  if (initialState != null) {
    // Clear any existing state for clean test
    await repository.clear();
  }

  final clearedState = await repository.get();
  if (clearedState != null) {
    throw Exception('❌ State not properly cleared');
  }
  print('  ✅ Initial state is null (as expected)');

  // Test 2: Create and save state
  final testState = ProgramState(
    activeProgramId: 'hockey_attacker_v1',
    currentWeek: 2,
    currentSession: 3,
    completedExerciseIds: ['ex1', 'ex2', 'ex3'],
    pausedAt: null,
  );

  final saveSuccess = await repository.save(testState);
  if (!saveSuccess) {
    throw Exception('❌ ProgramStateRepository.save() failed');
  }
  print('  ✅ save() succeeded');

  // Test 3: Read saved state
  final savedState = await repository.get();
  if (savedState == null) {
    throw Exception('❌ Failed to retrieve saved state');
  }

  if (savedState.activeProgramId != testState.activeProgramId ||
      savedState.currentWeek != testState.currentWeek ||
      savedState.currentSession != testState.currentSession ||
      savedState.completedExerciseIds.length !=
          testState.completedExerciseIds.length) {
    throw Exception('❌ Retrieved state does not match saved state');
  }
  print('  ✅ State read/write verification passed');

  // Test 4: Test state updates
  final weekUpdateSuccess = await repository.updateCurrentWeek(5);
  if (!weekUpdateSuccess) {
    throw Exception('❌ updateCurrentWeek() failed');
  }

  final updatedState = await repository.get();
  if (updatedState?.currentWeek != 5) {
    throw Exception('❌ Week update not persisted');
  }
  print('  ✅ State updates work correctly');

  print('  📊 Active program: ${savedState.activeProgramId}');
  print('  📊 Current week: ${updatedState?.currentWeek}');
  print('  📊 Current session: ${savedState.currentSession}');
  print('  📊 Completed exercises: ${savedState.completedExerciseIds.length}');
}
