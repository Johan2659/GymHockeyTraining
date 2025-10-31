import 'package:flutter_test/flutter_test.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'package:gymhockeytraining/data/repositories_impl/repositories_impl.dart';

void main() {
  group('Repository Functionality Verification', () {
    group('ProgramRepository', () {
      late ProgramRepositoryImpl repository;

      setUp(() {
        repository = ProgramRepositoryImpl();
      });

      test('should return valid attacker program (not empty)', () async {
        // Test: Get all programs
        final allPrograms = await repository.getAll();
        expect(allPrograms, isNotEmpty,
            reason: 'Should have at least one program');

        // Test: Get programs by attacker role
        final attackerPrograms = await repository.listByRole(UserRole.attacker);
        expect(attackerPrograms, isNotEmpty,
            reason: 'Should have attacker programs');

        // Test: Verify program structure
        final program = attackerPrograms.first;
        expect(program.id, equals('hockey_attacker_v1'));
        expect(program.title, equals('Hockey Attacker Training Program'));
        expect(program.role, equals(UserRole.attacker));
        expect(program.weeks, isNotEmpty, reason: 'Program should have weeks');

        // Test: Verify weeks structure
        expect(program.weeks.length, equals(2), reason: 'Should have 2 weeks');

        final week1 = program.weeks.first;
        expect(week1.index, equals(1));
        expect(week1.sessions, isNotEmpty, reason: 'Week should have sessions');
        expect(week1.sessions.length, equals(3),
            reason: 'Week should have 3 sessions');

        print('✅ Program verification passed:');
        print('  - Program ID: ${program.id}');
        print('  - Title: ${program.title}');
        print('  - Role: ${program.role}');
        print('  - Weeks: ${program.weeks.length}');
        print('  - Sessions in week 1: ${week1.sessions.length}');
      });

      test('should get specific program by ID', () async {
        final program = await repository.getById('hockey_attacker_v1');
        expect(program, isNotNull, reason: 'Should find attacker program');
        expect(program!.id, equals('hockey_attacker_v1'));
        expect(program.weeks, isNotEmpty);

        print('✅ GetById verification passed:');
        print('  - Found program: ${program.title}');
      });

      test('should handle non-existent program ID', () async {
        final program = await repository.getById('non_existent_program');
        expect(program, isNull,
            reason: 'Should return null for non-existent program');

        print('✅ Non-existent program handling verified');
      });
    });

    group('ProgressRepository', () {
      late ProgressRepositoryImpl repository;

      setUp(() {
        repository = ProgressRepositoryImpl();
      });

      test('should append event and emit updates via watchAll', () async {
        // Create test progress event
        final testEvent = ProgressEvent(
          ts: DateTime.now(),
          type: ProgressEventType.sessionStarted,
          programId: 'hockey_attacker_v1',
          week: 1,
          session: 1,
          exerciseId: null,
          payload: {'test': true},
        );

        // Test: Watch stream before adding event
        final streamEvents = <List<ProgressEvent>>[];
        final subscription = repository.watchAll().listen((events) {
          streamEvents.add(events);
        });

        // Wait for initial empty state
        await Future.delayed(const Duration(milliseconds: 100));

        // Test: Append event
        final appendSuccess = await repository.appendEvent(testEvent);
        expect(appendSuccess, isTrue,
            reason: 'Should successfully append event');

        // Wait for stream update
        await Future.delayed(const Duration(milliseconds: 200));

        // Test: Verify stream emitted updates
        expect(streamEvents, isNotEmpty, reason: 'Stream should emit events');

        // Get recent events to verify
        final recentEvents = await repository.getRecent(limit: 10);
        expect(recentEvents, isNotEmpty, reason: 'Should have recent events');

        final addedEvent = recentEvents.firstWhere(
          (event) =>
              event.programId == testEvent.programId &&
              event.type == testEvent.type,
          orElse: () => throw StateError('Event not found'),
        );

        expect(addedEvent.programId, equals(testEvent.programId));
        expect(addedEvent.type, equals(testEvent.type));
        expect(addedEvent.week, equals(testEvent.week));
        expect(addedEvent.session, equals(testEvent.session));

        await subscription.cancel();

        print('✅ Progress append and watch verification passed:');
        print('  - Append success: $appendSuccess');
        print('  - Stream emissions: ${streamEvents.length}');
        print('  - Recent events: ${recentEvents.length}');
        print('  - Event type: ${addedEvent.type}');
      });

      test('should get events by program', () async {
        // First add some test events
        final events = [
          ProgressEvent(
            ts: DateTime.now(),
            type: ProgressEventType.sessionStarted,
            programId: 'hockey_attacker_v1',
            week: 1,
            session: 1,
          ),
          ProgressEvent(
            ts: DateTime.now().add(const Duration(minutes: 30)),
            type: ProgressEventType.sessionCompleted,
            programId: 'hockey_attacker_v1',
            week: 1,
            session: 1,
          ),
        ];

        for (final event in events) {
          await repository.appendEvent(event);
        }

        // Test: Get events by program
        final programEvents =
            await repository.getByProgram('hockey_attacker_v1');
        expect(programEvents, isNotEmpty,
            reason: 'Should have events for program');

        print('✅ Get events by program verification passed:');
        print('  - Events for program: ${programEvents.length}');
      });
    });

    group('ProgramStateRepository', () {
      late ProgramStateRepositoryImpl repository;

      setUp(() {
        repository = ProgramStateRepositoryImpl();
      });

      test('should read and write program state correctly', () async {
        // Test: Initial state should be null
        final initialState = await repository.get();
        expect(initialState, isNull, reason: 'Initial state should be null');

        // Test: Create and save state
        final testState = ProgramState(
          activeProgramId: 'hockey_attacker_v1',
          currentWeek: 1,
          currentSession: 2,
          completedExerciseIds: ['exercise_1', 'exercise_2'],
          pausedAt: null,
        );

        final saveSuccess = await repository.save(testState);
        expect(saveSuccess, isTrue, reason: 'Should successfully save state');

        // Test: Read saved state
        final savedState = await repository.get();
        expect(savedState, isNotNull, reason: 'Should retrieve saved state');
        expect(savedState!.activeProgramId, equals(testState.activeProgramId));
        expect(savedState.currentWeek, equals(testState.currentWeek));
        expect(savedState.currentSession, equals(testState.currentSession));
        expect(savedState.completedExerciseIds,
            equals(testState.completedExerciseIds));
        expect(savedState.pausedAt, equals(testState.pausedAt));

        print('✅ Program state read/write verification passed:');
        print('  - Save success: $saveSuccess');
        print('  - Active program: ${savedState.activeProgramId}');
        print('  - Current week: ${savedState.currentWeek}');
        print('  - Current session: ${savedState.currentSession}');
        print(
            '  - Completed exercises: ${savedState.completedExerciseIds.length}');
      });

      test('should update specific state fields', () async {
        // Setup initial state
        final initialState = ProgramState(
          activeProgramId: 'hockey_attacker_v1',
          currentWeek: 1,
          currentSession: 1,
          completedExerciseIds: [],
          pausedAt: null,
        );
        await repository.save(initialState);

        // Test: Update current week
        final weekUpdateSuccess = await repository.updateCurrentWeek(2);
        expect(weekUpdateSuccess, isTrue,
            reason: 'Should update week successfully');

        final stateAfterWeekUpdate = await repository.get();
        expect(stateAfterWeekUpdate!.currentWeek, equals(2));

        // Test: Update current session
        final sessionUpdateSuccess = await repository.updateCurrentSession(3);
        expect(sessionUpdateSuccess, isTrue,
            reason: 'Should update session successfully');

        final stateAfterSessionUpdate = await repository.get();
        expect(stateAfterSessionUpdate!.currentSession, equals(3));

        // Test: Add completed exercise
        final addExerciseSuccess =
            await repository.addCompletedExercise('test_exercise_1');
        expect(addExerciseSuccess, isTrue,
            reason: 'Should add exercise successfully');

        final stateAfterAddExercise = await repository.get();
        expect(stateAfterAddExercise!.completedExerciseIds,
            contains('test_exercise_1'));

        // Test: Pause program
        final pauseSuccess = await repository.pauseProgram();
        expect(pauseSuccess, isTrue,
            reason: 'Should pause program successfully');

        final stateAfterPause = await repository.get();
        expect(stateAfterPause!.pausedAt, isNotNull);

        // Test: Resume program
        final resumeSuccess = await repository.resumeProgram();
        expect(resumeSuccess, isTrue,
            reason: 'Should resume program successfully');

        final stateAfterResume = await repository.get();
        expect(stateAfterResume!.pausedAt, isNull);

        print('✅ Program state updates verification passed:');
        print('  - Week update: $weekUpdateSuccess');
        print('  - Session update: $sessionUpdateSuccess');
        print('  - Add exercise: $addExerciseSuccess');
        print('  - Pause: $pauseSuccess');
        print('  - Resume: $resumeSuccess');
      });

      test('should provide watch stream for state changes', () async {
        final streamStates = <ProgramState?>[];
        final subscription = repository.watch().listen((state) {
          streamStates.add(state);
        });

        // Wait for initial emission
        await Future.delayed(const Duration(milliseconds: 100));

        // Create and save new state
        final newState = ProgramState(
          activeProgramId: 'hockey_attacker_v1',
          currentWeek: 1,
          currentSession: 1,
          completedExerciseIds: [],
        );

        await repository.save(newState);

        // Wait for stream update
        await Future.delayed(const Duration(milliseconds: 200));

        expect(streamStates, isNotEmpty, reason: 'Stream should emit states');

        await subscription.cancel();

        print('✅ Program state watch stream verification passed:');
        print('  - Stream emissions: ${streamStates.length}');
      });
    });
  });
}
