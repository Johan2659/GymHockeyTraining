import 'package:flutter_test/flutter_test.dart';
import 'package:gymhockeytraining/data/repositories_impl/progress_repository_impl.dart';
import 'package:gymhockeytraining/data/repositories_impl/program_state_repository_impl.dart';
import 'package:gymhockeytraining/data/repositories_impl/profile_repository_impl.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Repository Tests', () {
    late ProgressRepositoryImpl progressRepo;
    late ProgramStateRepositoryImpl stateRepo;
    late ProfileRepositoryImpl profileRepo;

    setUpAll(() async {
      await TestHelpers.initializeTestEnvironment();
    });

    setUp(() async {
      progressRepo = ProgressRepositoryImpl();
      stateRepo = ProgramStateRepositoryImpl();
      profileRepo = ProfileRepositoryImpl();
    });

    tearDown(() async {
      await TestHelpers.cleanup();
    });

    test('should store and retrieve progress events', () async {
      // Create a test event
      final event = ProgressEvent(
        ts: DateTime.now(),
        type: ProgressEventType.sessionStarted,
        programId: 'test-program',
        week: 1,
        session: 1,
      );

      // Store the event
      final success = await progressRepo.appendEvent(event);
      expect(success, true);

      // Retrieve recent events
      final events = await progressRepo.getRecent();

      expect(events.length, greaterThan(0));
      expect(events.first.type, ProgressEventType.sessionStarted);
      expect(events.first.programId, 'test-program');
    });

    test('should store and retrieve program state', () async {
      // Create test state
      final state = ProgramState(
        activeProgramId: 'test-program',
        currentWeek: 2,
        currentSession: 3,
        completedExerciseIds: ['ex1', 'ex2'],
      );

      // Store the state
      final success = await stateRepo.save(state);
      expect(success, true);

      // Retrieve the state
      final retrieved = await stateRepo.get();

      expect(retrieved, isNotNull);
      expect(retrieved!.activeProgramId, 'test-program');
      expect(retrieved.currentWeek, 2);
      expect(retrieved.currentSession, 3);
      expect(retrieved.completedExerciseIds, ['ex1', 'ex2']);
    });

    test('should store and retrieve profile', () async {
      // Create test profile
      final profile = Profile(
        role: UserRole.attacker,
        language: 'en',
        units: 'metric',
        theme: 'dark',
      );

      // Store the profile
      final success = await profileRepo.save(profile);
      expect(success, true);

      // Retrieve the profile
      final retrieved = await profileRepo.get();

      expect(retrieved, isNotNull);
      expect(retrieved!.role, UserRole.attacker);
      expect(retrieved.language, 'en');
    });
  });
}
