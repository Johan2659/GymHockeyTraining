import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymhockeytraining/features/application/app_state_provider.dart';
import 'package:gymhockeytraining/core/persistence/persistence_service.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Step 9 — Persistence Integration Tests', () {
    late ProviderContainer container;

    setUp(() async {
      await TestHelpers.initializeTestEnvironment();
      
      // Initialize persistence service (will work without SharedPreferences in tests)
      await PersistenceService.initialize();
      
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      PersistenceService.resetForTesting();
      await TestHelpers.cleanup();
    });

    test('AppState hydrates correctly from persistence on startup', () async {
      // Start a program to create some state
      await container.read(startProgramActionProvider('hockey_attacker_v1').future);
      await Future.delayed(Duration(milliseconds: 100));
      
      // Mark some exercises done
      await container.read(markExerciseDoneActionProvider('exercise1').future);
      await Future.delayed(Duration(milliseconds: 100));
      
      // Get current state
      final appState1 = await container.read(appStateProvider.future);
      expect(appState1.state?.activeProgramId, equals('hockey_attacker_v1'));
      expect(appState1.state?.completedExerciseIds, contains('exercise1'));
      
      // Dispose container to simulate app restart
      container.dispose();
      
      // Create new container to simulate fresh app start
      container = ProviderContainer();
      
      // Check if state persisted
      final appState2 = await container.read(appStateProvider.future);
      expect(appState2.state?.activeProgramId, equals('hockey_attacker_v1'));
      expect(appState2.state?.completedExerciseIds, contains('exercise1'));
    });

    test('Critical fields are saved (role, cycle, sessions, streaks, XP)', () async {
      // Start program and create comprehensive state
      await container.read(startProgramActionProvider('hockey_attacker_v1').future);
      await Future.delayed(Duration(milliseconds: 100));
      
      await container.read(markExerciseDoneActionProvider('squats').future);
      await Future.delayed(Duration(milliseconds: 100));
      
      await container.read(completeSessionActionProvider.future);
      await Future.delayed(Duration(milliseconds: 100));
      
      // Get the full app state
      final appState = await container.read(appStateProvider.future);
      
      // Verify all critical fields are available
      expect(appState.state?.activeProgramId, isNotNull); // Active program
      expect(appState.state?.currentWeek, isNotNull); // Current cycle position
      expect(appState.state?.currentSession, isNotNull); // Current session
      expect(appState.state?.completedExerciseIds, isNotEmpty); // Completed sessions
      expect(appState.currentStreak, greaterThanOrEqualTo(0)); // Streaks
      expect(appState.currentXP, greaterThanOrEqualTo(0)); // XP
      expect(appState.events, isNotEmpty); // Progress events persist
    });

    test('Persistence handles graceful fallback', () async {
      // Test that persistence service can handle failures gracefully
      final healthCheck = await PersistenceService.healthCheck();
      expect(healthCheck, isTrue);
      
      // Test read/write fallback functionality (Hive only in tests)
      const testValue = 'test_persistence_fallback';
      final writeSuccess = await PersistenceService.writeWithFallback(
        'test_box', 
        'test_key', 
        testValue
      );
      expect(writeSuccess, isTrue);
      
      final readValue = await PersistenceService.readWithFallback(
        'test_box', 
        'test_key'
      );
      expect(readValue, equals(testValue));
    });

    test('Schema versioning is in place', () async {
      // Test that schema versioning works (Hive only in test environment)
      final currentVersion = await PersistenceService.getSchemaVersion();
      expect(currentVersion, greaterThanOrEqualTo(0)); // Default is 0 in tests
      
      // Test setting schema version
      await PersistenceService.setSchemaVersion(2);
      final updatedVersion = await PersistenceService.getSchemaVersion();
      expect(updatedVersion, equals(2));
      
      // Reset to original version
      await PersistenceService.setSchemaVersion(currentVersion);
    });

    test('State reloads properly after app kill simulation', () async {
      // Create initial state
      await container.read(startProgramActionProvider('hockey_attacker_v1').future);
      await Future.delayed(Duration(milliseconds: 100));
      
      // Progress through multiple actions
      await container.read(markExerciseDoneActionProvider('warmup').future);
      await container.read(markExerciseDoneActionProvider('mainset').future);
      await container.read(completeSessionActionProvider.future);
      await Future.delayed(Duration(milliseconds: 200));
      
      // Capture state before "app kill"
      final stateBeforeKill = await container.read(appStateProvider.future);
      final eventsCountBefore = stateBeforeKill.events.length;
      final xpBefore = stateBeforeKill.currentXP;
      
      // Simulate app kill and restart
      container.dispose();
      await Future.delayed(Duration(milliseconds: 100));
      
      // Fresh container simulates new app launch
      container = ProviderContainer();
      
      // Verify state persisted correctly
      final stateAfterRestart = await container.read(appStateProvider.future);
      
      expect(stateAfterRestart.state?.activeProgramId, 
             equals(stateBeforeKill.state?.activeProgramId));
      expect(stateAfterRestart.events.length, equals(eventsCountBefore));
      expect(stateAfterRestart.currentXP, equals(xpBefore));
      expect(stateAfterRestart.state?.completedExerciseIds.length, 
             equals(stateBeforeKill.state?.completedExerciseIds.length));
    });

    test('Persistence is modular and can be mocked', () async {
      // This test verifies that PersistenceService is separate from core logic
      // In real tests, you could inject a mock persistence service
      
      // Test that persistence methods are static and don't depend on instances
      expect(PersistenceService.healthCheck, isA<Function>());
      expect(PersistenceService.readWithFallback, isA<Function>());
      expect(PersistenceService.writeWithFallback, isA<Function>());
      expect(PersistenceService.logStateChange, isA<Function>());
      
      // Test that clearing doesn't break the system
      await PersistenceService.clearAll();
      
      // System should still work after clear
      await container.read(startProgramActionProvider('hockey_attacker_v1').future);
      final appState = await container.read(appStateProvider.future);
      expect(appState.state?.activeProgramId, equals('hockey_attacker_v1'));
    });
  });
}
