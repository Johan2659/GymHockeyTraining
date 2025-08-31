import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'package:gymhockeytraining/core/repositories/progress_repository.dart';
import 'package:gymhockeytraining/core/repositories/program_state_repository.dart';
import 'package:gymhockeytraining/features/application/app_state_provider.dart';
import 'package:gymhockeytraining/app/di.dart';
import '../helpers/test_helpers.dart';

// Mock classes
class MockProgressRepository extends Mock implements ProgressRepository {}
class MockProgramStateRepository extends Mock implements ProgramStateRepository {}

// Fake classes for mocktail fallback values
class FakeProgramState extends Fake implements ProgramState {}
class FakeProgressEvent extends Fake implements ProgressEvent {}

void main() {
  group('AppState Transitions Tests', () {
    late MockProgressRepository mockProgressRepository;
    late MockProgramStateRepository mockProgramStateRepository;
    late ProviderContainer container;

    setUpAll(() async {
      // Initialize test environment
      await TestHelpers.initializeTestEnvironment();
      
      // Register fallback values for mocktail
      registerFallbackValue(FakeProgramState());
      registerFallbackValue(FakeProgressEvent());
    });

    setUp(() {
      mockProgressRepository = MockProgressRepository();
      mockProgramStateRepository = MockProgramStateRepository();
      
      container = ProviderContainer(
        overrides: [
          progressRepositoryProvider.overrideWithValue(mockProgressRepository),
          programStateRepositoryProvider.overrideWithValue(mockProgramStateRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    tearDownAll(() async {
      await TestHelpers.cleanup();
    });

    group('startProgramAction', () {
      test('should create new program state and log event', () async {
        // Arrange
        const programId = 'hockey_attacker_v1';
        when(() => mockProgramStateRepository.save(any())).thenAnswer((_) async => true);
        when(() => mockProgressRepository.appendEvent(any())).thenAnswer((_) async => true);

        // Act
        await container.read(startProgramActionProvider(programId).future);

        // Assert
        verify(() => mockProgramStateRepository.save(any(that: isA<ProgramState>().having(
          (state) => state.activeProgramId,
          'activeProgramId',
          equals(programId),
        ).having(
          (state) => state.currentWeek,
          'currentWeek',
          equals(0),
        ).having(
          (state) => state.currentSession,
          'currentSession',
          equals(0),
        ).having(
          (state) => state.completedExerciseIds,
          'completedExerciseIds',
          isEmpty,
        )))).called(1);

        verify(() => mockProgressRepository.appendEvent(any(that: isA<ProgressEvent>().having(
          (event) => event.type,
          'type',
          equals(ProgressEventType.sessionStarted),
        ).having(
          (event) => event.programId,
          'programId',
          equals(programId),
        ).having(
          (event) => event.week,
          'week',
          equals(0),
        ).having(
          (event) => event.session,
          'session',
          equals(0),
        )))).called(1);
      });

      test('should handle repository failures gracefully', () async {
        // Arrange
        const programId = 'hockey_attacker_v1';
        when(() => mockProgramStateRepository.save(any())).thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => container.read(startProgramActionProvider(programId).future),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('markExerciseDoneAction', () {
      test('should update program state and log exercise completion', () async {
        // Arrange
        const exerciseId = 'sprint_30m';
        const initialState = ProgramState(
          activeProgramId: 'hockey_attacker_v1',
          currentWeek: 1,
          currentSession: 2,
          completedExerciseIds: ['previous_exercise'],
        );

        when(() => mockProgramStateRepository.get()).thenAnswer((_) async => initialState);
        when(() => mockProgramStateRepository.addCompletedExercise(any())).thenAnswer((_) async => true);
        when(() => mockProgressRepository.appendEvent(any())).thenAnswer((_) async => true);

        // Act
        await container.read(markExerciseDoneActionProvider(exerciseId).future);

        // Assert
        verify(() => mockProgramStateRepository.addCompletedExercise(exerciseId)).called(1);

        verify(() => mockProgressRepository.appendEvent(any(that: isA<ProgressEvent>().having(
          (event) => event.type,
          'type',
          equals(ProgressEventType.exerciseDone),
        ).having(
          (event) => event.exerciseId,
          'exerciseId',
          equals(exerciseId),
        ).having(
          (event) => event.week,
          'week',
          equals(1),
        ).having(
          (event) => event.session,
          'session',
          equals(2),
        )))).called(1);
      });

      test('should handle null program state gracefully', () async {
        // Arrange
        const exerciseId = 'sprint_30m';
        when(() => mockProgramStateRepository.get()).thenAnswer((_) async => null);

        // Act
        await container.read(markExerciseDoneActionProvider(exerciseId).future);

        // Assert - Should exit early when no active program
        verifyNever(() => mockProgramStateRepository.addCompletedExercise(any()));
        verifyNever(() => mockProgressRepository.appendEvent(any()));
      });
    });

    group('completeSessionAction', () {
      test('should advance to next session and log completion', () async {
        // Arrange
        const initialState = ProgramState(
          activeProgramId: 'hockey_attacker_v1',
          currentWeek: 1,
          currentSession: 2,
          completedExerciseIds: ['exercise1', 'exercise2', 'exercise3'],
        );

        when(() => mockProgramStateRepository.get()).thenAnswer((_) async => initialState);
        when(() => mockProgramStateRepository.updateCurrentSession(any())).thenAnswer((_) async => true);
        when(() => mockProgressRepository.appendEvent(any())).thenAnswer((_) async => true);

        // Act
        await container.read(completeSessionActionProvider.future);

        // Assert
        verify(() => mockProgramStateRepository.updateCurrentSession(3)).called(1); // Advanced from 2 to 3

        verify(() => mockProgressRepository.appendEvent(any(that: isA<ProgressEvent>().having(
          (event) => event.type,
          'type',
          equals(ProgressEventType.sessionCompleted),
        ).having(
          (event) => event.week,
          'week',
          equals(1),
        ).having(
          (event) => event.session,
          'session',
          equals(2), // The session that was completed
        )))).called(1);
      });

      test('should handle null program state', () async {
        // Arrange
        when(() => mockProgramStateRepository.get()).thenAnswer((_) async => null);

        // Act
        await container.read(completeSessionActionProvider.future);

        // Assert - Should exit early when no active program
        verifyNever(() => mockProgramStateRepository.updateCurrentSession(any()));
        verifyNever(() => mockProgressRepository.appendEvent(any()));
      });
    });

    group('pauseProgramAction', () {
      test('should set pausedAt timestamp', () async {
        // Arrange
        when(() => mockProgramStateRepository.pauseProgram()).thenAnswer((_) async => true);

        // Act
        await container.read(pauseProgramActionProvider.future);

        // Assert
        verify(() => mockProgramStateRepository.pauseProgram()).called(1);
      });
    });

    group('resumeProgramAction', () {
      test('should clear pausedAt timestamp', () async {
        // Arrange
        when(() => mockProgramStateRepository.resumeProgram()).thenAnswer((_) async => true);

        // Act
        await container.read(resumeProgramActionProvider.future);

        // Assert
        verify(() => mockProgramStateRepository.resumeProgram()).called(1);
      });
    });

    group('completeBonusChallengeAction', () {
      test('should log bonus completion event', () async {
        // Arrange
        const initialState = ProgramState(
          activeProgramId: 'hockey_attacker_v1',
          currentWeek: 1,
          currentSession: 2,
          completedExerciseIds: ['exercise1'],
        );

        when(() => mockProgramStateRepository.get()).thenAnswer((_) async => initialState);
        when(() => mockProgressRepository.appendEvent(any())).thenAnswer((_) async => true);

        // Act
        await container.read(completeBonusChallengeActionProvider.future);

        // Assert
        verify(() => mockProgressRepository.appendEvent(any(that: isA<ProgressEvent>().having(
          (event) => event.type,
          'type',
          equals(ProgressEventType.bonusDone),
        ).having(
          (event) => event.week,
          'week',
          equals(1),
        ).having(
          (event) => event.session,
          'session',
          equals(2),
        )))).called(1);
      });
    });

    group('startSessionAction', () {
      test('should update program state to specific session', () async {
        // Arrange
        const programId = 'hockey_attacker_v1';
        const week = 2;
        const session = 1;

        when(() => mockProgressRepository.appendEvent(any())).thenAnswer((_) async => true);

        // Act
        await container.read(startSessionActionProvider(programId, week, session).future);

        // Assert
        verify(() => mockProgressRepository.appendEvent(any(that: isA<ProgressEvent>().having(
          (event) => event.type,
          'type',
          equals(ProgressEventType.sessionStarted),
        ).having(
          (event) => event.week,
          'week',
          equals(week),
        ).having(
          (event) => event.session,
          'session',
          equals(session),
        )))).called(1);
      });
    });

    group('completeExtraAction', () {
      test('should log extra completion with XP reward', () async {
        // Arrange
        const extraId = 'express_workout_1';
        const xpReward = 50;

        when(() => mockProgressRepository.appendEvent(any())).thenAnswer((_) async => true);

        // Act
        await container.read(completeExtraActionProvider(extraId, xpReward).future);

        // Assert
        verify(() => mockProgressRepository.appendEvent(any(that: isA<ProgressEvent>().having(
          (event) => event.type,
          'type',
          equals(ProgressEventType.extraCompleted),
        ).having(
          (event) => event.exerciseId,
          'exerciseId',
          equals(extraId),
        ).having(
          (event) => event.payload,
          'payload',
          isNotNull,
        )))).called(1);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle repository save failures', () async {
        // Arrange
        const programId = 'hockey_attacker_v1';
        when(() => mockProgramStateRepository.save(any())).thenThrow(Exception('Save failed'));

        // Act & Assert
        expect(
          () => container.read(startProgramActionProvider(programId).future),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle progress event logging failures', () async {
        // Arrange
        const exerciseId = 'sprint_30m';
        const initialState = ProgramState(
          activeProgramId: 'hockey_attacker_v1',
          currentWeek: 1,
          currentSession: 2,
          completedExerciseIds: [],
        );

        when(() => mockProgramStateRepository.get()).thenAnswer((_) async => initialState);
        when(() => mockProgramStateRepository.addCompletedExercise(any())).thenAnswer((_) async => true);
        when(() => mockProgressRepository.appendEvent(any())).thenThrow(Exception('Event log failed'));

        // Act & Assert
        expect(
          () => container.read(markExerciseDoneActionProvider(exerciseId).future),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
