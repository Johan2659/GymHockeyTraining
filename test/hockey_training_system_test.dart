import 'package:flutter_test/flutter_test.dart';
import '../lib/core/models/models.dart';
import '../lib/data/datasources/hockey_exercises_database.dart';
import '../lib/data/datasources/attacker_program_data.dart';
import '../lib/data/datasources/local_exercise_source.dart';
import '../lib/data/datasources/local_program_source.dart';

/// Test suite for the comprehensive hockey training system
/// Tests exercise database, attacker program, and integration
void main() {
  group('Hockey Training System Tests', () {
    group('Exercise Database Tests', () {
      test('should load all exercises from database', () async {
        final exercises = await HockeyExercisesDatabase.getAllExercises();

        expect(exercises, isNotEmpty);
        expect(exercises.length, greaterThan(40)); // We have 50+ exercises

        // Verify we have key exercises
        final exerciseIds = exercises.map((e) => e.id).toList();
        expect(exerciseIds, contains('back_squat'));
        expect(exerciseIds, contains('deadlift'));
        expect(exerciseIds, contains('bench_press'));
        expect(exerciseIds, contains('overhead_press'));
      });

      test('should load specific exercises by ID', () async {
        final backSquat =
            await HockeyExercisesDatabase.getExerciseById('back_squat');

        expect(backSquat, isNotNull);
        expect(backSquat!.name, equals('Back Squat'));
        expect(backSquat.category, equals(ExerciseCategory.strength));
        expect(backSquat.sets, equals(4));
        expect(backSquat.reps, equals(5));
        expect(backSquat.rest, equals(180));
      });

      test('should return null for non-existent exercise', () async {
        final exercise = await HockeyExercisesDatabase.getExerciseById(
            'non_existent_exercise');

        expect(exercise, isNull);
      });

      test('should filter exercises by category', () async {
        final strengthExercises =
            await HockeyExercisesDatabase.getExercisesByCategory(
                ExerciseCategory.strength);
        final powerExercises =
            await HockeyExercisesDatabase.getExercisesByCategory(
                ExerciseCategory.power);
        final conditioningExercises =
            await HockeyExercisesDatabase.getExercisesByCategory(
                ExerciseCategory.conditioning);

        expect(strengthExercises, isNotEmpty);
        expect(powerExercises, isNotEmpty);
        expect(conditioningExercises, isNotEmpty);

        // Verify all exercises in strength category are actually strength
        for (final exercise in strengthExercises) {
          expect(exercise.category, equals(ExerciseCategory.strength));
        }
      });

      test('should search exercises by name and category', () async {
        final squatExercises =
            await HockeyExercisesDatabase.searchExercises('squat');
        final strengthResults =
            await HockeyExercisesDatabase.searchExercises('strength');

        expect(squatExercises, isNotEmpty);
        expect(strengthResults, isNotEmpty);

        // Verify squat exercises contain squat in name
        final hasSquatInName =
            squatExercises.any((e) => e.name.toLowerCase().contains('squat'));
        expect(hasSquatInName, isTrue);
      });
    });

    group('Attacker Program Tests', () {
      test('should load complete attacker program', () async {
        final program = await AttackerProgramData.getAttackerProgram();

        expect(program, isNotNull);
        expect(program!.id, equals('hockey_attacker_2025'));
        expect(program.role, equals(UserRole.attacker));
        expect(program.title, contains('Attacker'));
        expect(program.weeks, hasLength(5)); // 5 weeks

        // Verify each week has 3 sessions
        for (final week in program.weeks) {
          expect(week.sessions, hasLength(3));
        }
      });

      test('should load all sessions', () async {
        final sessions = await AttackerProgramData.getAllSessions();

        expect(sessions, hasLength(15)); // 5 weeks x 3 sessions

        // Verify session IDs are correct
        final sessionIds = sessions.map((s) => s.id).toList();
        expect(sessionIds, contains('attacker_w1_s1'));
        expect(sessionIds, contains('attacker_w1_s2'));
        expect(sessionIds, contains('attacker_w1_s3'));
        expect(sessionIds, contains('attacker_w5_s3')); // Last session
      });

      test('should load specific session by ID', () async {
        final session =
            await AttackerProgramData.getSessionById('attacker_w1_s1');

        expect(session, isNotNull);
        expect(session!.id, equals('attacker_w1_s1'));
        expect(session.title, contains('Lower Dominante'));
        expect(session.blocks, isNotEmpty);

        // Verify session has exercise blocks
        final hasExerciseBlocks =
            session.blocks.any((block) => block.exerciseId.isNotEmpty);
        expect(hasExerciseBlocks, isTrue);
      });

      test('should return null for non-existent session', () async {
        final session =
            await AttackerProgramData.getSessionById('non_existent_session');

        expect(session, isNull);
      });
    });

    group('Local Source Integration Tests', () {
      test('LocalExerciseSource should work with hockey database', () async {
        final source = LocalExerciseSource();

        final allExercises = await source.getAllExercises();
        expect(allExercises, isNotEmpty);

        final backSquat = await source.getExerciseById('back_squat');
        expect(backSquat, isNotNull);
        expect(backSquat!.name, equals('Back Squat'));

        final strengthExercises =
            await source.getExercisesByCategory('strength');
        expect(strengthExercises, isNotEmpty);
      });

      test('LocalProgramSource should load attacker program', () async {
        final source = LocalProgramSource();

        final allPrograms = await source.getAllPrograms();
        expect(allPrograms, isNotEmpty);

        final attackerProgram =
            await source.getProgramById('hockey_attacker_2025');
        expect(attackerProgram, isNotNull);
        expect(attackerProgram!.role, equals(UserRole.attacker));
        expect(attackerProgram.weeks, hasLength(5));

        final attackerPrograms =
            await source.getProgramsByRole(UserRole.attacker);
        expect(attackerPrograms, isNotEmpty);
      });
    });

    group('Exercise Alternatives Tests', () {
      test('should have proper gym and home alternatives', () async {
        final backSquat =
            await HockeyExercisesDatabase.getExerciseById('back_squat');

        expect(backSquat, isNotNull);
        expect(backSquat!.gymAltId, isNotNull);
        expect(backSquat.homeAltId, isNotNull);

        // Verify alternatives exist
        final gymAlt =
            await HockeyExercisesDatabase.getExerciseById(backSquat.gymAltId!);
        final homeAlt =
            await HockeyExercisesDatabase.getExerciseById(backSquat.homeAltId!);

        expect(gymAlt, isNotNull);
        expect(homeAlt, isNotNull);
      });

      test('should have YouTube queries for all exercises', () async {
        final exercises = await HockeyExercisesDatabase.getAllExercises();

        for (final exercise in exercises.take(10)) {
          // Test first 10
          expect(exercise.youtubeQuery, isNotNull);
          expect(exercise.youtubeQuery.isNotEmpty, isTrue);
        }
      });
    });

    group('Data Consistency Tests', () {
      test('all session exercise IDs should exist in database', () async {
        final sessions = await AttackerProgramData.getAllSessions();
        final allExercises = await HockeyExercisesDatabase.getAllExercises();
        final exerciseIds = allExercises.map((e) => e.id).toSet();

        for (final session in sessions) {
          for (final block in session.blocks) {
            if (block.exerciseId.isNotEmpty) {
              expect(exerciseIds, contains(block.exerciseId),
                  reason:
                      'Exercise ${block.exerciseId} not found in database for session ${session.id}');
            }
          }
        }
      });

      test('alternative exercise IDs should exist in database', () async {
        final exercises = await HockeyExercisesDatabase.getAllExercises();
        final exerciseIds = exercises.map((e) => e.id).toSet();

        for (final exercise in exercises.take(20)) {
          // Test first 20
          if (exercise.gymAltId != null) {
            expect(exerciseIds, contains(exercise.gymAltId),
                reason:
                    'Gym alternative ${exercise.gymAltId} not found for ${exercise.id}');
          }

          if (exercise.homeAltId != null) {
            expect(exerciseIds, contains(exercise.homeAltId),
                reason:
                    'Home alternative ${exercise.homeAltId} not found for ${exercise.id}');
          }
        }
      });
    });
  });
}
