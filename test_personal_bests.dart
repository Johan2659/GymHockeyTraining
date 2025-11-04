import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymhockeytraining/app/di.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'package:gymhockeytraining/features/application/app_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  print('\n=== Testing Personal Best Tracking ===\n');

  try {
    // Create a test performance with a good weight
    final testPerformance = ExercisePerformance(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      exerciseId: 'back_squat',
      exerciseName: 'Back Squat',
      programId: 'test_program',
      week: 0,
      session: 0,
      timestamp: DateTime.now(),
      sets: [
        ExerciseSetPerformance(
          setNumber: 1,
          reps: 5,
          weight: 100.0,
          completed: true,
        ),
        ExerciseSetPerformance(
          setNumber: 2,
          reps: 5,
          weight: 110.0,
          completed: true,
        ),
        ExerciseSetPerformance(
          setNumber: 3,
          reps: 5,
          weight: 120.0,
          completed: true,
        ),
      ],
    );

    print('Saving test performance with max weight: 120kg');
    final success = await container.read(
        saveExercisePerformanceActionProvider(testPerformance).future);

    if (success) {
      print('✓ Performance saved successfully\n');

      // Wait a moment for async operations to complete
      await Future.delayed(Duration(milliseconds: 500));

      // Check if personal best was recorded
      final analyticsRepo =
          container.read(performanceAnalyticsRepositoryProvider);
      final analytics = await analyticsRepo.get();

      print('Current personal bests:');
      if (analytics != null && analytics.personalBests.isNotEmpty) {
        for (final entry in analytics.personalBests.entries) {
          final best = entry.value;
          print('  - ${best.exerciseName}: ${best.bestValue} ${best.unit}');
          print('    Achieved at: ${best.achievedAt}');
          print('    Program: ${best.programId}');
        }
      } else {
        print('  ❌ No personal bests found!');
      }

      // Get all performances to verify
      final perfRepo = container.read(exercisePerformanceRepositoryProvider);
      final allPerfs = await perfRepo.getByExerciseId('back_squat');
      print('\nTotal performances for back_squat: ${allPerfs.length}');
    } else {
      print('❌ Failed to save performance');
    }
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print(stackTrace);
  } finally {
    container.dispose();
  }
}
