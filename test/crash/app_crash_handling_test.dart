import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'package:gymhockeytraining/features/application/app_state_provider.dart';
import 'package:gymhockeytraining/data/datasources/local_prefs_source.dart';
import 'package:gymhockeytraining/data/datasources/local_progress_source.dart';

void main() {
  group('Crash Handling Tests - Simulated App Crashes', () {
    late ProviderContainer container;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Mock all required platform channels
      const MethodChannel('plugins.flutter.io/path_provider')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getApplicationDocumentsDirectory':
            return './test/documents';
          case 'getTemporaryDirectory':
            return './test/temp';
          default:
            return './test/';
        }
      });

      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'read':
            return null;
          case 'write':
            return null;
          case 'delete':
            return null;
          default:
            return null;
        }
      });

      const MethodChannel('plugins.flutter.io/shared_preferences')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getAll':
            return <String, Object>{};
          case 'setString':
            return true;
          default:
            return null;
        }
      });

      // Initialize Hive for testing
      await Hive.initFlutter();

      // Open test boxes
      try {
        await Hive.openBox('user_profile');
        await Hive.openBox('app_settings');
        await Hive.openBox('progress_journal');
      } catch (e) {
        // Boxes might already be open
        print('Boxes setup: $e');
      }
    });

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    tearDownAll(() async {
      // Clean up test boxes
      try {
        if (Hive.isBoxOpen('user_profile'))
          await Hive.box('user_profile').clear();
        if (Hive.isBoxOpen('app_settings'))
          await Hive.box('app_settings').clear();
        if (Hive.isBoxOpen('progress_journal'))
          await Hive.box('progress_journal').clear();
      } catch (e) {
        print('Cleanup: $e');
      }
    });

    group('Hive Box Crash Simulation', () {
      test('should handle user profile box crash gracefully', () async {
        // Start with working profile
        const profile = Profile(
          role: UserRole.attacker,
          language: 'en',
          units: 'metric',
          theme: 'dark',
        );

        final prefsSource = LocalPrefsSource();
        await prefsSource.saveProfile(profile);

        // Verify it works initially
        final initialProfile = await prefsSource.getProfile();
        expect(initialProfile?.role, equals(UserRole.attacker));

        // SIMULATE CRASH: Force close the user_profile box
        if (Hive.isBoxOpen('user_profile')) {
          await Hive.box('user_profile').close();
        }

        // App should handle closed box gracefully - no crashes
        final profileAfterCrash = await prefsSource.getProfile();
        expect(profileAfterCrash, isNull,
            reason: 'Should return null when box is closed, not crash');

        // App should be able to save new profile after crash (graceful recovery)
        const newProfile = Profile(
          role: UserRole.defender,
          language: 'fr',
          units: 'imperial',
          theme: 'light',
        );

        // This should not crash the app
        expect(() => prefsSource.saveProfile(newProfile), returnsNormally);

        print('✅ User profile box crash handled gracefully');
      });

      test('should handle progress journal box crash gracefully', () async {
        final progressSource = LocalProgressSource();

        // Create initial progress event
        final event = ProgressEvent(
          ts: DateTime.now(),
          type: ProgressEventType.sessionStarted,
          programId: 'test_program',
          week: 1,
          session: 1,
        );

        await progressSource.appendEvent(event);
        final initialEvents = await progressSource.getAllEvents();
        expect(initialEvents, isNotEmpty);

        // SIMULATE CRASH: Force close the progress_journal box
        if (Hive.isBoxOpen('progress_journal')) {
          await Hive.box('progress_journal').close();
        }

        // App should handle closed box gracefully
        final eventsAfterCrash = await progressSource.getAllEvents();
        expect(eventsAfterCrash, isEmpty,
            reason: 'Should return empty list when box is closed, not crash');

        // App should handle new event writes gracefully after crash
        final newEvent = ProgressEvent(
          ts: DateTime.now(),
          type: ProgressEventType.exerciseDone,
          programId: 'test_program',
          week: 1,
          session: 1,
          exerciseId: 'exercise_1',
        );

        expect(() => progressSource.appendEvent(newEvent), returnsNormally);

        print('✅ Progress journal box crash handled gracefully');
      });

      test('should handle app settings box crash gracefully', () async {
        const programState = ProgramState(
          activeProgramId: 'test_program',
          currentWeek: 1,
          currentSession: 2,
          completedExerciseIds: ['exercise1', 'exercise2'],
        );

        final prefsSource = LocalPrefsSource();
        await prefsSource.saveProgramState(programState);

        // Verify it works initially
        final initialState = await prefsSource.getProgramState();
        expect(initialState?.activeProgramId, equals('test_program'));

        // SIMULATE CRASH: Force close the app_settings box
        if (Hive.isBoxOpen('app_settings')) {
          await Hive.box('app_settings').close();
        }

        // App should handle closed box gracefully
        final stateAfterCrash = await prefsSource.getProgramState();
        expect(stateAfterCrash, isNull,
            reason: 'Should return null when box is closed, not crash');

        // App should handle state saves gracefully after crash
        const newState = ProgramState(
          activeProgramId: 'recovery_program',
          currentWeek: 0,
          currentSession: 0,
          completedExerciseIds: [],
        );

        expect(() => prefsSource.saveProgramState(newState), returnsNormally);

        print('✅ App settings box crash handled gracefully');
      });
    });

    group('Provider-Level Crash Simulation', () {
      test('should handle app state provider crashes gracefully', () async {
        // Start with working app state
        await container
            .read(startProgramActionProvider('crash_test_program').future);

        final initialState = await container.read(programStateProvider.future);
        expect(initialState?.activeProgramId, equals('crash_test_program'));

        // SIMULATE CRASH: Close all Hive boxes
        final boxNames = ['user_profile', 'app_settings', 'progress_journal'];
        for (final boxName in boxNames) {
          if (Hive.isBoxOpen(boxName)) {
            await Hive.box(boxName).close();
          }
        }

        // Create new container to simulate app restart after crash
        container.dispose();
        container = ProviderContainer();

        // App state providers should handle storage failures gracefully
        final stateAfterCrash =
            await container.read(programStateProvider.future);
        expect(stateAfterCrash, isNull,
            reason: 'Should return null when storage is unavailable');

        final profileAfterCrash =
            await container.read(userProfileProvider.future);
        expect(profileAfterCrash, isNull,
            reason: 'Should return null when storage is unavailable');

        final eventsAfterCrash =
            await container.read(progressEventsProvider.future);
        expect(eventsAfterCrash, isEmpty,
            reason: 'Should return empty list when storage is unavailable');

        // Derived providers should handle null/empty data gracefully
        final xpAfterCrash = await container.read(currentXPProvider.future);
        expect(xpAfterCrash, equals(0),
            reason: 'Should return 0 XP when no data available');

        final streakAfterCrash =
            await container.read(currentStreakProvider.future);
        expect(streakAfterCrash, equals(0),
            reason: 'Should return 0 streak when no data available');

        print('✅ App state provider crash handled gracefully');
      });

      test('should recover gracefully after box reopening', () async {
        // Start with closed boxes (simulating post-crash state)
        final boxNames = ['user_profile', 'app_settings', 'progress_journal'];
        for (final boxName in boxNames) {
          if (Hive.isBoxOpen(boxName)) {
            await Hive.box(boxName).close();
          }
        }

        // App should handle closed boxes gracefully
        final stateWithClosedBoxes =
            await container.read(programStateProvider.future);
        expect(stateWithClosedBoxes, isNull);

        // SIMULATE RECOVERY: Reopen boxes
        for (final boxName in boxNames) {
          await Hive.openBox(boxName);
        }

        // Create new container to simulate fresh app state
        container.dispose();
        container = ProviderContainer();

        // App should work normally after recovery
        await container
            .read(startProgramActionProvider('recovery_test').future);
        final recoveredState =
            await container.read(programStateProvider.future);
        expect(recoveredState?.activeProgramId, equals('recovery_test'));

        print('✅ App recovery after crash handled gracefully');
      });
    });

    group('Data Corruption Crash Simulation', () {
      test('should handle corrupted Hive data gracefully', () async {
        final prefsSource = LocalPrefsSource();

        // Put corrupted data in Hive box
        if (Hive.isBoxOpen('user_profile')) {
          final box = Hive.box('user_profile');
          await box.put('profile_data', 'corrupted_json_string');
        }

        // App should handle corrupted data gracefully
        final corruptedProfile = await prefsSource.getProfile();
        expect(corruptedProfile, isNull,
            reason: 'Should return null for corrupted data, not crash');

        // App should be able to save valid data over corrupted data
        const validProfile = Profile(
          role: UserRole.attacker,
          language: 'en',
          units: 'metric',
          theme: 'dark',
        );

        await prefsSource.saveProfile(validProfile);
        final recoveredProfile = await prefsSource.getProfile();
        expect(recoveredProfile?.role, equals(UserRole.attacker));

        print('✅ Data corruption handled gracefully');
      });

      test('should handle unexpected data types gracefully', () async {
        final prefsSource = LocalPrefsSource();

        // Put wrong data types in boxes
        if (Hive.isBoxOpen('app_settings')) {
          final box = Hive.box('app_settings');
          await box.put('program_state', 12345); // Int instead of Map
          await box
              .put('random_key', [1, 2, 3]); // Array instead of expected type
        }

        // App should handle type mismatches gracefully
        final wrongTypeState = await prefsSource.getProgramState();
        expect(wrongTypeState, isNull,
            reason: 'Should return null for wrong data type, not crash');

        // App should be able to save correct data
        const validState = ProgramState(
          activeProgramId: 'type_recovery_test',
          currentWeek: 0,
          currentSession: 0,
          completedExerciseIds: [],
        );

        await prefsSource.saveProgramState(validState);
        final recoveredState = await prefsSource.getProgramState();
        expect(recoveredState?.activeProgramId, equals('type_recovery_test'));

        print('✅ Data type corruption handled gracefully');
      });
    });
  });
}
