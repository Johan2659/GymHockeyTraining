import 'package:flutter_test/flutter_test.dart';
import 'package:gymhockeytraining/core/models/models.dart';

void main() {
  group('Domain Models JSON Serialization', () {
    test('Exercise JSON serialization', () {
      const exercise = Exercise(
        id: 'ex1',
        name: 'Push-ups',
        category: ExerciseCategory.strength,
        sets: 3,
        reps: 10,
        duration: 30,
        rest: 60,
        youtubeQuery: 'hockey push ups',
        gymAltId: 'gym1',
        homeAltId: 'home1',
      );

      final json = exercise.toJson();
      final restored = Exercise.fromJson(json);

      expect(restored.id, equals(exercise.id));
      expect(restored.name, equals(exercise.name));
      expect(restored.category, equals(exercise.category));
      expect(restored.sets, equals(exercise.sets));
      expect(restored.reps, equals(exercise.reps));
      expect(restored.duration, equals(exercise.duration));
      expect(restored.rest, equals(exercise.rest));
      expect(restored.youtubeQuery, equals(exercise.youtubeQuery));
      expect(restored.gymAltId, equals(exercise.gymAltId));
      expect(restored.homeAltId, equals(exercise.homeAltId));
    });

    test('UserRole enum serialization', () {
      const role = UserRole.attacker;
      
      expect(role.name, equals('attacker'));
    });

    test('Program JSON serialization', () {
      const program = Program(
        id: 'prog1',
        role: UserRole.attacker,
        title: 'Attacker Training',
        weeks: [
          Week(index: 1, sessions: ['session1', 'session2']),
          Week(index: 2, sessions: ['session3', 'session4']),
        ],
      );

      final json = program.toJson();
      final restored = Program.fromJson(json);

      expect(restored.id, equals(program.id));
      expect(restored.role, equals(program.role));
      expect(restored.title, equals(program.title));
      expect(restored.weeks.length, equals(2));
      expect(restored.weeks[0].index, equals(1));
      expect(restored.weeks[0].sessions, equals(['session1', 'session2']));
    });

    test('ProgressEvent JSON serialization', () {
      final now = DateTime.now();
      final event = ProgressEvent(
        ts: now,
        type: ProgressEventType.sessionStarted,
        programId: 'prog1',
        week: 1,
        session: 1,
        exerciseId: 'ex1',
        payload: {'test': 'data'},
      );

      final json = event.toJson();
      final restored = ProgressEvent.fromJson(json);

      expect(restored.ts, equals(event.ts));
      expect(restored.type, equals(event.type));
      expect(restored.programId, equals(event.programId));
      expect(restored.week, equals(event.week));
      expect(restored.session, equals(event.session));
      expect(restored.exerciseId, equals(event.exerciseId));
      expect(restored.payload, equals(event.payload));
    });

    test('ProgramState copyWith method', () {
      const initialState = ProgramState(
        activeProgramId: 'prog1',
        currentWeek: 1,
        currentSession: 1,
        completedExerciseIds: ['ex1'],
      );

      final updatedState = initialState.copyWith(
        currentWeek: 2,
        completedExerciseIds: ['ex1', 'ex2'],
      );

      expect(updatedState.activeProgramId, equals('prog1'));
      expect(updatedState.currentWeek, equals(2));
      expect(updatedState.currentSession, equals(1));
      expect(updatedState.completedExerciseIds, equals(['ex1', 'ex2']));
    });

    test('Profile copyWith method', () {
      const initialProfile = Profile(
        role: UserRole.attacker,
        language: 'en',
        units: 'metric',
        theme: 'dark',
      );

      final updatedProfile = initialProfile.copyWith(
        role: UserRole.defender,
        theme: 'light',
      );

      expect(updatedProfile.role, equals(UserRole.defender));
      expect(updatedProfile.language, equals('en'));
      expect(updatedProfile.units, equals('metric'));
      expect(updatedProfile.theme, equals('light'));
    });

    test('XP copyWith method', () {
      const initialXP = XP(
        total: 100,
        level: 5,
        lastRewards: ['reward1'],
      );

      final updatedXP = initialXP.copyWith(
        total: 150,
        lastRewards: ['reward1', 'reward2'],
      );

      expect(updatedXP.total, equals(150));
      expect(updatedXP.level, equals(5));
      expect(updatedXP.lastRewards, equals(['reward1', 'reward2']));
    });
  });
}
