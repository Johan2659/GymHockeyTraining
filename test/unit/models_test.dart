import 'package:flutter_test/flutter_test.dart';
import 'package:gymhockeytraining/core/models/models.dart';

void main() {
  group('Models Serialization/Deserialization Tests', () {
    group('Profile Model', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        const profile = Profile(
          role: UserRole.attacker,
          units: 'metric',
          language: 'en',
          theme: 'dark',
        );

        // Act
        final json = profile.toJson();
        final deserializedProfile = Profile.fromJson(json);

        // Assert
        expect(deserializedProfile.role, equals(profile.role));
        expect(deserializedProfile.units, equals(profile.units));
        expect(deserializedProfile.language, equals(profile.language));
        expect(deserializedProfile.theme, equals(profile.theme));
      });

      test('should handle null values correctly', () {
        // Arrange
        const profile = Profile();

        // Act & Assert
        expect(() => profile.toJson(), returnsNormally);
        expect(() => Profile.fromJson(profile.toJson()), returnsNormally);
      });

      test('should serialize all UserRole values', () {
        // Test all enum values
        for (final role in UserRole.values) {
          final profile = Profile(
            role: role,
            units: 'metric',
            language: 'en',
            theme: 'light',
          );

          final json = profile.toJson();
          final deserializedProfile = Profile.fromJson(json);
          expect(deserializedProfile.role, equals(role));
        }
      });
    });

    group('ProgramState Model', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        const programState = ProgramState(
          activeProgramId: 'hockey_attacker_v1',
          currentWeek: 2,
          currentSession: 1,
          completedExerciseIds: ['exercise_1', 'exercise_2', 'exercise_3'],
        );

        // Act
        final json = programState.toJson();
        final deserializedState = ProgramState.fromJson(json);

        // Assert
        expect(deserializedState.activeProgramId, equals(programState.activeProgramId));
        expect(deserializedState.currentWeek, equals(programState.currentWeek));
        expect(deserializedState.currentSession, equals(programState.currentSession));
        expect(deserializedState.completedExerciseIds, equals(programState.completedExerciseIds));
      });

      test('should handle empty completed exercises list', () {
        // Arrange
        const programState = ProgramState(
          activeProgramId: 'test_program',
          currentWeek: 0,
          currentSession: 0,
          completedExerciseIds: [],
        );

        // Act
        final json = programState.toJson();
        final deserializedState = ProgramState.fromJson(json);

        // Assert
        expect(deserializedState.completedExerciseIds, isEmpty);
      });

      test('should handle null activeProgramId', () {
        // Arrange
        const programState = ProgramState(
          activeProgramId: null,
          currentWeek: 0,
          currentSession: 0,
          completedExerciseIds: [],
        );

        // Act
        final json = programState.toJson();
        final deserializedState = ProgramState.fromJson(json);

        // Assert
        expect(deserializedState.activeProgramId, isNull);
      });

      test('should handle pausedAt field', () {
        // Arrange
        final pausedTime = DateTime(2025, 8, 31, 12, 0, 0);
        final programState = ProgramState(
          activeProgramId: 'test',
          currentWeek: 1,
          currentSession: 2,
          completedExerciseIds: [],
          pausedAt: pausedTime,
        );

        // Act
        final json = programState.toJson();
        final deserializedState = ProgramState.fromJson(json);

        // Assert
        expect(deserializedState.pausedAt, equals(pausedTime));
      });
    });

    group('ProgressEvent Model', () {
      test('should serialize and deserialize sessionStarted event', () {
        // Arrange
        final event = ProgressEvent(
          ts: DateTime(2025, 8, 31, 12, 0, 0),
          type: ProgressEventType.sessionStarted,
          programId: 'hockey_attacker_v1',
          week: 1,
          session: 2,
        );

        // Act
        final json = event.toJson();
        final deserializedEvent = ProgressEvent.fromJson(json);

        // Assert
        expect(deserializedEvent.ts, equals(event.ts));
        expect(deserializedEvent.type, equals(event.type));
        expect(deserializedEvent.programId, equals(event.programId));
        expect(deserializedEvent.week, equals(event.week));
        expect(deserializedEvent.session, equals(event.session));
      });

      test('should serialize and deserialize exerciseDone event with exerciseId', () {
        // Arrange
        final event = ProgressEvent(
          ts: DateTime(2025, 8, 31, 12, 30, 0),
          type: ProgressEventType.exerciseDone,
          programId: 'hockey_defender_v1',
          week: 0,
          session: 1,
          exerciseId: 'sprint_30m',
        );

        // Act
        final json = event.toJson();
        final deserializedEvent = ProgressEvent.fromJson(json);

        // Assert
        expect(deserializedEvent.exerciseId, equals(event.exerciseId));
        expect(deserializedEvent.type, equals(ProgressEventType.exerciseDone));
      });

      test('should serialize all ProgressEventType values', () {
        // Test all enum values
        for (final eventType in ProgressEventType.values) {
          final event = ProgressEvent(
            ts: DateTime.now(),
            type: eventType,
            programId: 'test_program',
            week: 0,
            session: 0,
          );

          final json = event.toJson();
          final deserializedEvent = ProgressEvent.fromJson(json);
          expect(deserializedEvent.type, equals(eventType));
        }
      });

      test('should handle optional payload field', () {
        // Arrange
        final event = ProgressEvent(
          ts: DateTime(2025, 8, 31),
          type: ProgressEventType.sessionCompleted,
          programId: 'test',
          week: 0,
          session: 0,
          payload: {'xp': 100, 'bonus': true},
        );

        // Act
        final json = event.toJson();
        final deserializedEvent = ProgressEvent.fromJson(json);

        // Assert
        expect(deserializedEvent.payload, isNotNull);
        expect(deserializedEvent.payload!['xp'], equals(100));
        expect(deserializedEvent.payload!['bonus'], equals(true));
      });
    });

    group('Program Model', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        const program = Program(
          id: 'hockey_attacker_v1',
          title: 'Hockey Attacker Program',
          role: UserRole.attacker,
          weeks: [
            Week(
              index: 0,
              sessions: ['session_1', 'session_2'],
            ),
          ],
        );

        // Act
        final json = program.toJson();
        final deserializedProgram = Program.fromJson(json);

        // Assert
        expect(deserializedProgram.id, equals(program.id));
        expect(deserializedProgram.title, equals(program.title));
        expect(deserializedProgram.role, equals(program.role));
        expect(deserializedProgram.weeks.length, equals(1));
        expect(deserializedProgram.weeks[0].sessions.length, equals(2));
        expect(deserializedProgram.weeks[0].sessions, equals(['session_1', 'session_2']));
      });

      test('should handle empty weeks list', () {
        // Arrange
        const program = Program(
          id: 'empty_program',
          title: 'Empty Program',
          role: UserRole.goalie,
          weeks: [],
        );

        // Act
        final json = program.toJson();
        final deserializedProgram = Program.fromJson(json);

        // Assert
        expect(deserializedProgram.weeks, isEmpty);
      });
    });

    group('Session Model', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        const session = Session(
          id: 'test_session',
          title: 'Test Session',
          blocks: [
            ExerciseBlock(exerciseId: 'exercise_1'),
            ExerciseBlock(exerciseId: 'exercise_2'),
          ],
          bonusChallenge: 'Complete all exercises with perfect form',
        );

        // Act
        final json = session.toJson();
        final deserializedSession = Session.fromJson(json);

        // Assert
        expect(deserializedSession.id, equals(session.id));
        expect(deserializedSession.title, equals(session.title));
        expect(deserializedSession.blocks.length, equals(2));
        expect(deserializedSession.blocks[0].exerciseId, equals('exercise_1'));
        expect(deserializedSession.bonusChallenge, equals(session.bonusChallenge));
      });

      test('should handle empty blocks list', () {
        // Arrange
        const session = Session(
          id: 'empty_session',
          title: 'Empty Session',
          blocks: [],
          bonusChallenge: 'No exercises',
        );

        // Act & Assert
        expect(() => session.toJson(), returnsNormally);
        expect(() => Session.fromJson(session.toJson()), returnsNormally);
      });
    });

    group('Exercise Model', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        const exercise = Exercise(
          id: 'sprint_30m',
          name: '30m Sprint',
          category: ExerciseCategory.speed,
          sets: 3,
          reps: 1,
          duration: 30,
          rest: 60,
          youtubeQuery: 'hockey sprint training',
        );

        // Act
        final json = exercise.toJson();
        final deserializedExercise = Exercise.fromJson(json);

        // Assert
        expect(deserializedExercise.id, equals(exercise.id));
        expect(deserializedExercise.name, equals(exercise.name));
        expect(deserializedExercise.category, equals(exercise.category));
        expect(deserializedExercise.sets, equals(exercise.sets));
        expect(deserializedExercise.reps, equals(exercise.reps));
        expect(deserializedExercise.duration, equals(exercise.duration));
        expect(deserializedExercise.rest, equals(exercise.rest));
        expect(deserializedExercise.youtubeQuery, equals(exercise.youtubeQuery));
      });

      test('should handle optional fields', () {
        // Arrange
        const exercise = Exercise(
          id: 'simple_exercise',
          name: 'Simple Exercise',
          category: ExerciseCategory.strength,
          sets: 1,
          reps: 10,
          youtubeQuery: 'basic exercise',
        );

        // Act
        final json = exercise.toJson();
        final deserializedExercise = Exercise.fromJson(json);

        // Assert
        expect(deserializedExercise.duration, isNull);
        expect(deserializedExercise.rest, isNull);
        expect(deserializedExercise.gymAltId, isNull);
        expect(deserializedExercise.homeAltId, isNull);
      });
    });

    group('ExerciseBlock Model', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        const exerciseBlock = ExerciseBlock(
          exerciseId: 'sprint_10m',
          swapGymId: 'gym_alternative',
          swapHomeId: 'home_alternative',
        );

        // Act
        final json = exerciseBlock.toJson();
        final deserializedBlock = ExerciseBlock.fromJson(json);

        // Assert
        expect(deserializedBlock.exerciseId, equals(exerciseBlock.exerciseId));
        expect(deserializedBlock.swapGymId, equals(exerciseBlock.swapGymId));
        expect(deserializedBlock.swapHomeId, equals(exerciseBlock.swapHomeId));
      });

      test('should handle null swap IDs', () {
        // Arrange
        const exerciseBlock = ExerciseBlock(exerciseId: 'basic_exercise');

        // Act
        final json = exerciseBlock.toJson();
        final deserializedBlock = ExerciseBlock.fromJson(json);

        // Assert
        expect(deserializedBlock.swapGymId, isNull);
        expect(deserializedBlock.swapHomeId, isNull);
      });
    });

    group('ExtraItem Model', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        const extraItem = ExtraItem(
          id: 'express_workout_1',
          title: 'Quick Cardio Blast',
          description: 'A 15-minute high-intensity workout',
          type: ExtraType.expressWorkout,
          xpReward: 50,
          duration: 15,
          blocks: [
            ExerciseBlock(exerciseId: 'burpees'),
            ExerciseBlock(exerciseId: 'mountain_climbers'),
          ],
          difficulty: 'medium',
        );

        // Act
        final json = extraItem.toJson();
        final deserializedItem = ExtraItem.fromJson(json);

        // Assert
        expect(deserializedItem.id, equals(extraItem.id));
        expect(deserializedItem.title, equals(extraItem.title));
        expect(deserializedItem.description, equals(extraItem.description));
        expect(deserializedItem.type, equals(extraItem.type));
        expect(deserializedItem.xpReward, equals(extraItem.xpReward));
        expect(deserializedItem.duration, equals(extraItem.duration));
        expect(deserializedItem.blocks.length, equals(2));
        expect(deserializedItem.difficulty, equals(extraItem.difficulty));
      });

      test('should serialize all ExtraType values', () {
        // Test all enum values
        for (final extraType in ExtraType.values) {
          final extraItem = ExtraItem(
            id: 'test_extra',
            title: 'Test Extra',
            description: 'Test description',
            type: extraType,
            xpReward: 25,
            duration: 10,
            blocks: [],
          );

          final json = extraItem.toJson();
          final deserializedItem = ExtraItem.fromJson(json);
          expect(deserializedItem.type, equals(extraType));
        }
      });
    });

    group('XP Model', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        const xp = XP(
          total: 1500,
          level: 5,
          lastRewards: ['session_completed', 'bonus_challenge'],
        );

        // Act
        final json = xp.toJson();
        final deserializedXP = XP.fromJson(json);

        // Assert
        expect(deserializedXP.total, equals(xp.total));
        expect(deserializedXP.level, equals(xp.level));
        expect(deserializedXP.lastRewards, equals(xp.lastRewards));
      });

      test('should handle empty rewards list', () {
        // Arrange
        const xp = XP(
          total: 0,
          level: 1,
          lastRewards: [],
        );

        // Act
        final json = xp.toJson();
        final deserializedXP = XP.fromJson(json);

        // Assert
        expect(deserializedXP.lastRewards, isEmpty);
      });
    });
  });
}
