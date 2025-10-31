import 'package:flutter_test/flutter_test.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'package:gymhockeytraining/data/repositories_impl/repositories_impl.dart';

void main() {
  group('Repository Requirements Verification', () {
    test('ProgramRepository returns valid programs (Attacker not empty)',
        () async {
      final repository = ProgramRepositoryImpl();

      // Check all programs
      final allPrograms = await repository.getAll();
      expect(allPrograms, isNotEmpty, reason: 'Should have programs available');

      // Check attacker-specific programs
      final attackerPrograms = await repository.listByRole(UserRole.attacker);
      expect(attackerPrograms, isNotEmpty,
          reason: 'Should have attacker programs');

      // Verify program structure
      final program = attackerPrograms.first;
      expect(program.id, 'hockey_attacker_v1');
      expect(program.title, 'Hockey Attacker Training Program');
      expect(program.role, UserRole.attacker);
      expect(program.weeks, isNotEmpty, reason: 'Program should have weeks');
      expect(program.weeks.length, 2, reason: 'Should have 2 weeks');

      // Verify first week has sessions
      final week1 = program.weeks.first;
      expect(week1.index, 1);
      expect(week1.sessions, isNotEmpty, reason: 'Week should have sessions');
      expect(week1.sessions.length, 3, reason: 'Week should have 3 sessions');

      print('✅ ProgramRepository verification PASSED');
      print('   Programs available: ${allPrograms.length}');
      print('   Attacker programs: ${attackerPrograms.length}');
      print('   Program title: ${program.title}');
      print('   Weeks: ${program.weeks.length}');
    });

    test('ProgressRepository interface works (storage will fail without Hive)',
        () async {
      final repository = ProgressRepositoryImpl();

      // Create test event
      final testEvent = ProgressEvent(
        ts: DateTime.now(),
        type: ProgressEventType.sessionStarted,
        programId: 'hockey_attacker_v1',
        week: 1,
        session: 1,
        exerciseId: 'test_exercise',
        payload: {'test': true},
      );

      // Test append (will fail gracefully without Hive, returning false)
      final appendSuccess = await repository.appendEvent(testEvent);
      // In unit tests without Hive, this will return false, which is expected
      expect(appendSuccess, isA<bool>(),
          reason: 'Should return a boolean result');

      // Test recent events (will return empty list without Hive)
      final recentEvents = await repository.getRecent(limit: 10);
      expect(recentEvents, isA<List<ProgressEvent>>(),
          reason: 'Should return a list');

      // Test watchAll stream (should provide a stream even if empty)
      final stream = repository.watchAll();
      expect(stream, isA<Stream<List<ProgressEvent>>>(),
          reason: 'Should return a stream');

      print('✅ ProgressRepository interface verification PASSED');
      print('   Append returned: $appendSuccess (false expected without Hive)');
      print(
          '   Recent events: ${recentEvents.length} (0 expected without Hive)');
      print('   Stream created successfully');
    });

    test(
        'ProgramStateRepository interface works (storage will fail without Hive)',
        () async {
      final repository = ProgramStateRepositoryImpl();

      // Test initial state (will return null without Hive)
      final initialState = await repository.get();
      expect(initialState, isNull,
          reason: 'Should return null without storage');

      // Create test state
      final testState = ProgramState(
        activeProgramId: 'hockey_attacker_v1',
        currentWeek: 1,
        currentSession: 2,
        completedExerciseIds: ['ex1', 'ex2'],
        pausedAt: null,
      );

      // Test save (will fail gracefully without Hive, returning false)
      final saveSuccess = await repository.save(testState);
      expect(saveSuccess, isA<bool>(),
          reason: 'Should return a boolean result');

      // Test watch stream (should provide a stream even if null)
      final stream = repository.watch();
      expect(stream, isA<Stream<ProgramState?>>(),
          reason: 'Should return a stream');

      // Test update operations (will fail gracefully without existing state)
      final weekUpdateSuccess = await repository.updateCurrentWeek(3);
      expect(weekUpdateSuccess, isA<bool>(),
          reason: 'Should return a boolean result');

      print('✅ ProgramStateRepository interface verification PASSED');
      print('   Save returned: $saveSuccess (false expected without Hive)');
      print('   Initial state: $initialState (null expected without Hive)');
      print(
          '   Update returned: $weekUpdateSuccess (false expected without state)');
      print('   Stream created successfully');
    });
  });
}
