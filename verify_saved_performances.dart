import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymhockeytraining/app/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  print('\n=== Check Exercise Performances ===\n');

  try {
    final performanceRepo =
        container.read(exercisePerformanceRepositoryProvider);
    final allPerformances = await performanceRepo.getAll();

    print('Total performances found: ${allPerformances.length}');

    if (allPerformances.isEmpty) {
      print('❌ NO PERFORMANCES - Challenge not saved properly');
      return;
    }

    print('\nAll performances:');
    for (final perf in allPerformances) {
      print('\n- ${perf.exerciseName} (${perf.exerciseId})');
      print(
          '  Program: ${perf.programId}, Week: ${perf.week}, Session: ${perf.session}');
      print('  Timestamp: ${perf.timestamp}');
      print('  Sets: ${perf.sets.length}');

      for (int i = 0; i < perf.sets.length; i++) {
        final set = perf.sets[i];
        print(
            '    Set ${i + 1}: ${set.reps} reps × ${set.weight ?? "bodyweight"}');
      }

      // Calculate volume
      double volume = 0.0;
      for (final set in perf.sets) {
        final weight = set.weight ?? 1.0;
        volume += set.reps * weight;
      }
      print('  Total volume: ${volume.toStringAsFixed(1)}');
    }

    // Now get exercise details
    print('\n\nChecking exercise categories:');
    final exerciseRepo = container.read(exerciseRepositoryProvider);

    for (final perf in allPerformances) {
      final exercise = await exerciseRepo.getById(perf.exerciseId);
      if (exercise != null) {
        print('- ${perf.exerciseName}: ${exercise.category.name}');
      } else {
        print('- ${perf.exerciseName}: ❌ EXERCISE NOT FOUND IN DATABASE');
      }
    }

    print('\n✅ Done!');
  } catch (e, stack) {
    print('❌ Error: $e');
    print(stack);
  }

  container.dispose();
}
