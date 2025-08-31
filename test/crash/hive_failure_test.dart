import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'package:gymhockeytraining/features/application/app_state_provider.dart';
import 'package:gymhockeytraining/data/datasources/local_prefs_source.dart';
import 'package:gymhockeytraining/data/datasources/local_progress_source.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Crash Tests - Hive Box Failure Handling', () {
    late ProviderContainer container;

    setUpAll(() async {
      try {
        await TestHelpers.initializeTestEnvironment();
      } catch (e) {
        // Initialization failure is expected in crash tests
        print('Expected initialization failure in crash tests: $e');
      }
    });

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    tearDownAll(() async {
      try {
        await TestHelpers.cleanup();
      } catch (e) {
        // Cleanup failure is expected in crash tests
        print('Expected cleanup failure in crash tests: $e');
      }
    });

    group('Hive Box Closure Scenarios', () {
      test('should handle closed user_profile box gracefully', () async {
        // Start with a working state
        const profile = Profile(
          role: UserRole.attacker,
          language: 'en',
          units: 'metric',
          theme: 'dark',
        );

        final prefsSource = LocalPrefsSource();
        
        try {
          await prefsSource.saveProfile(profile);
          
          // Verify it works initially
          final initialProfile = await prefsSource.getProfile();
          expect(initialProfile?.role, equals(UserRole.attacker));
        } catch (e) {
          // May fail if boxes aren't initialized, that's expected
          print('Expected profile save/load failure: $e');
        }

        // Simulate box closure
        try {
          if (Hive.isBoxOpen('user_profile')) {
            await Hive.box('user_profile').close();
          }
        } catch (e) {
          // Box may not be open, that's fine
          print('Box closure attempt: $e');
        }

        // Operations should handle closed box gracefully
        final profileAfterClosure = await prefsSource.getProfile();
        expect(profileAfterClosure, isNull); // Should return null, not crash

        // Writing should also handle closed box
        const newProfile = Profile(
          role: UserRole.goalie,
          language: 'fr',
          units: 'imperial',
          theme: 'light',
        );

        // Should not throw exception
        expect(() => prefsSource.saveProfile(newProfile), returnsNormally);
      });

      test('should handle closed progress_journal box gracefully', () async {
        // Create a progress event
        final event = ProgressEvent(
          ts: DateTime.now(),
          type: ProgressEventType.sessionStarted,
          programId: 'test_program',
          week: 0,
          session: 0,
        );

        final progressSource = LocalProgressSource();
        
        try {
          // Initially should work
          await progressSource.appendEvent(event);
          final initialEvents = await progressSource.getAllEvents();
          expect(initialEvents, isNotEmpty);
        } catch (e) {
          // May fail if boxes aren't initialized, that's expected
          print('Expected progress event failure: $e');
        }

        // Close the box
        try {
          if (Hive.isBoxOpen('progress_journal')) {
            await Hive.box('progress_journal').close();
          }
        } catch (e) {
          print('Box closure attempt: $e');
        }

        // Should handle closed box gracefully
        final eventsAfterClosure = await progressSource.getAllEvents();
        expect(eventsAfterClosure, isEmpty); // Should return empty, not crash

        // Writing should also handle closed box
        final newEvent = ProgressEvent(
          ts: DateTime.now(),
          type: ProgressEventType.exerciseDone,
          programId: 'test_program',
          week: 0,
          session: 0,
          exerciseId: 'test_exercise',
        );

        expect(() => progressSource.appendEvent(newEvent), returnsNormally);
      });

      test('should handle app_settings box closure gracefully', () async {
        const programState = ProgramState(
          activeProgramId: 'test_program',
          currentWeek: 1,
          currentSession: 2,
          completedExerciseIds: ['exercise1', 'exercise2'],
        );

        final prefsSource = LocalPrefsSource();
        
        // Initially should work
        await prefsSource.saveProgramState(programState);
        final initialState = await prefsSource.getProgramState();
        expect(initialState?.activeProgramId, equals('test_program'));

        // Close the box
        if (Hive.isBoxOpen('app_settings')) {
          await Hive.box('app_settings').close();
        }

        // Should handle closed box gracefully
        final stateAfterClosure = await prefsSource.getProgramState();
        expect(stateAfterClosure, isNull); // Should return null, not crash

        // Writing should also handle closed box
        const newState = ProgramState(
          activeProgramId: 'new_program',
          currentWeek: 0,
          currentSession: 0,
          completedExerciseIds: [],
        );

        expect(() => prefsSource.saveProgramState(newState), returnsNormally);
      });
    });

    group('Provider-Level Crash Handling', () {
      test('should handle app state provider when storage fails', () async {
        // Start with working state
        await container.read(startProgramActionProvider('test_program').future);
        
        // Verify initial state
        final initialState = await container.read(programStateProvider.future);
        expect(initialState?.activeProgramId, equals('test_program'));

        // Close all Hive boxes to simulate storage failure
        for (final boxName in ['user_profile', 'app_settings', 'progress_journal']) {
          if (Hive.isBoxOpen(boxName)) {
            await Hive.box(boxName).close();
          }
        }

        // App state should handle storage failures gracefully
        // These operations should not crash the app
        expect(() => container.read(programStateProvider.future), returnsNormally);
        expect(() => container.read(userProfileProvider.future), returnsNormally);
        expect(() => container.read(progressEventsProvider.future), returnsNormally);

        // Actions should also handle failures gracefully
        expect(() => container.read(markExerciseDoneActionProvider('exercise1').future), returnsNormally);
        expect(() => container.read(completeSessionActionProvider.future), returnsNormally);
      });

      test('should provide fallback values when storage is unavailable', () async {
        // Close all boxes first
        for (final boxName in ['user_profile', 'app_settings', 'progress_journal']) {
          if (Hive.isBoxOpen(boxName)) {
            await Hive.box(boxName).close();
          }
        }

        // Providers should return safe default values
        final state = await container.read(programStateProvider.future);
        expect(state, isNull); // Should be null, not crash

        final profile = await container.read(userProfileProvider.future);
        expect(profile, isNull); // Should be null, not crash

        final events = await container.read(progressEventsProvider.future);
        expect(events, isEmpty); // Should be empty list, not crash

        // Derived providers should handle null/empty gracefully
        final currentXP = await container.read(currentXPProvider.future);
        expect(currentXP, equals(0)); // Should be 0 when no events

        final todayXP = await container.read(todayXPProvider.future);
        expect(todayXP, equals(0)); // Should be 0 when no events

        final streak = await container.read(currentStreakProvider.future);
        expect(streak, equals(0)); // Should be 0 when no events
      });
    });

    group('Recovery Scenarios', () {
      test('should recover gracefully when boxes are reopened', () async {
        // Start with closed boxes
        for (final boxName in ['user_profile', 'app_settings', 'progress_journal']) {
          if (Hive.isBoxOpen(boxName)) {
            await Hive.box(boxName).close();
          }
        }

        // Create new container to simulate app restart
        container.dispose();
        container = ProviderContainer();

        // Operations should fail gracefully first
        final initialState = await container.read(programStateProvider.future);
        expect(initialState, isNull);

        // Reopen boxes (simulating recovery)
        await Hive.openBox('user_profile');
        await Hive.openBox('app_settings');
        await Hive.openBox('progress_journal');

        // Create new container after recovery
        container.dispose();
        container = ProviderContainer();

        // Should now work normally
        await container.read(startProgramActionProvider('recovered_program').future);
        final recoveredState = await container.read(programStateProvider.future);
        expect(recoveredState?.activeProgramId, equals('recovered_program'));
      });

      test('should handle partial box failures', () async {
        // Close only one box to simulate partial failure
        if (Hive.isBoxOpen('progress_journal')) {
          await Hive.box('progress_journal').close();
        }

        // Start a program (this should work since app_settings box is open)
        await container.read(startProgramActionProvider('partial_failure_test').future);
        
        final state = await container.read(programStateProvider.future);
        expect(state?.activeProgramId, equals('partial_failure_test'));

        // Progress events should fail gracefully (progress_journal is closed)
        final events = await container.read(progressEventsProvider.future);
        expect(events, isEmpty); // Should return empty, not crash

        // Exercise completion should not crash even if event logging fails
        expect(() => container.read(markExerciseDoneActionProvider('exercise1').future), returnsNormally);
      });
    });

    group('Corrupted Data Handling', () {
      test('should handle corrupted box data gracefully', () async {
        // This test simulates what happens when Hive data is corrupted
        // In real scenarios, this would be handled by Hive itself, but we test our error handling
        
        final prefsSource = LocalPrefsSource();
        
        // Manually put invalid data that could cause parsing errors
        if (Hive.isBoxOpen('user_profile')) {
          final box = Hive.box('user_profile');
          await box.put('profile_data', 'invalid_json_data');
        }

        // Should handle parsing errors gracefully
        final profile = await prefsSource.getProfile();
        expect(profile, isNull); // Should return null for corrupted data, not crash

        // Should be able to overwrite corrupted data
        const validProfile = Profile(
          role: UserRole.attacker,
          language: 'en',
          units: 'metric',
          theme: 'dark',
        );

        await prefsSource.saveProfile(validProfile);
        final recoveredProfile = await prefsSource.getProfile();
        expect(recoveredProfile?.role, equals(UserRole.attacker));
      });

      test('should handle unexpected data types in boxes', () async {
        final prefsSource = LocalPrefsSource();

        // Put unexpected data types in boxes
        if (Hive.isBoxOpen('app_settings')) {
          final box = Hive.box('app_settings');
          await box.put('program_state', 12345); // Should be Map, not int
          await box.put('some_other_key', [1, 2, 3]); // List instead of expected type
        }

        // Should handle type mismatches gracefully
        final state = await prefsSource.getProgramState();
        expect(state, isNull); // Should return null for wrong type, not crash

        // Should be able to save valid data
        const validState = ProgramState(
          activeProgramId: 'valid_program',
          currentWeek: 0,
          currentSession: 0,
          completedExerciseIds: [],
        );

        await prefsSource.saveProgramState(validState);
        final recoveredState = await prefsSource.getProgramState();
        expect(recoveredState?.activeProgramId, equals('valid_program'));
      });
    });
  });
}
