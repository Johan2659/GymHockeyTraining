import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymhockeytraining/app/di.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'package:gymhockeytraining/features/application/app_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  print('\n=== DIAGNOSTIC: Category Progress ===\n');

  try {
    // 1. Check ExercisePerformance data
    print('1. Checking ExercisePerformance data...');
    final performanceRepo =
        container.read(exercisePerformanceRepositoryProvider);
    final allPerformances = await performanceRepo.getAll();
    print('   Total performances: ${allPerformances.length}');

    if (allPerformances.isEmpty) {
      print(
          '   ❌ NO PERFORMANCES FOUND - User needs to complete exercises first');
      container.dispose();
      return;
    }

    // Show first 3 performances
    print('\n   First 3 performances:');
    for (int i = 0; i < 3 && i < allPerformances.length; i++) {
      final perf = allPerformances[i];
      print('   - ${perf.exerciseName} (ID: ${perf.exerciseId})');
      print('     Sets: ${perf.sets.length}');
      if (perf.sets.isNotEmpty) {
        final firstSet = perf.sets.first;
        print(
            '     First set: ${firstSet.reps} reps × ${firstSet.weight ?? 0} kg');
      }
    }

    // 2. Check Exercise data
    print('\n2. Checking Exercise repository...');
    final exerciseRepo = container.read(exerciseRepositoryProvider);
    final allExercises = await exerciseRepo.getAll();
    print('   Total exercises: ${allExercises.length}');

    if (allExercises.isEmpty) {
      print('   ❌ NO EXERCISES FOUND');
      container.dispose();
      return;
    }

    // Show first 3 exercises with categories
    print('\n   First 3 exercises:');
    for (int i = 0; i < 3 && i < allExercises.length; i++) {
      final ex = allExercises[i];
      print('   - ${ex.name} (ID: ${ex.id}) → Category: ${ex.category.name}');
    }

    // 3. Match performances to exercises
    print('\n3. Matching performances to exercise categories...');
    final categoryCounts = <ExerciseCategory, int>{};
    final categoryVolumes = <ExerciseCategory, double>{};
    int matchCount = 0;
    int noMatchCount = 0;

    for (final perf in allPerformances) {
      final exercise = await exerciseRepo.getById(perf.exerciseId);

      if (exercise == null) {
        noMatchCount++;
        if (noMatchCount <= 3) {
          print(
              '   ⚠️  No match for exerciseId: ${perf.exerciseId} (${perf.exerciseName})');
        }
        continue;
      }

      matchCount++;
      categoryCounts[exercise.category] =
          (categoryCounts[exercise.category] ?? 0) + 1;

      double volume = 0.0;
      for (final set in perf.sets) {
        final weight = set.weight ?? 1.0;
        volume += set.reps * weight;
      }

      categoryVolumes[exercise.category] =
          (categoryVolumes[exercise.category] ?? 0.0) + volume;
    }

    print('   ✓ Matched: $matchCount');
    print('   ✗ No match: $noMatchCount');

    // 4. Show category breakdown
    print('\n4. Category breakdown (ALL categories):');
    for (final category in ExerciseCategory.values) {
      final count = categoryCounts[category] ?? 0;
      final volume = categoryVolumes[category] ?? 0.0;
      if (count > 0) {
        print(
            '   ${category.name.padRight(15)}: $count exercises, ${volume.toStringAsFixed(1)} volume');
      }
    }

    // 5. Check main 5 categories for radar
    print('\n5. Main 5 categories (for radar):');
    const mainCategories = [
      ExerciseCategory.power,
      ExerciseCategory.strength,
      ExerciseCategory.speed,
      ExerciseCategory.conditioning,
      ExerciseCategory.agility,
    ];

    double totalMainVolume = 0.0;
    for (final category in mainCategories) {
      totalMainVolume += categoryVolumes[category] ?? 0.0;
    }

    print('   Total volume in main 5: ${totalMainVolume.toStringAsFixed(1)}');

    for (final category in mainCategories) {
      final volume = categoryVolumes[category] ?? 0.0;
      final percentage =
          totalMainVolume > 0 ? (volume / totalMainVolume * 100) : 20.0;
      print(
          '   ${category.name.padRight(15)}: ${percentage.toStringAsFixed(1)}%');
    }

    // 6. Test the actual provider
    print('\n6. Testing categoryProgressProvider...');
    final categoryProgress =
        await container.read(categoryProgressProvider.future);

    print('   Raw values from provider:');
    for (final category in mainCategories) {
      final value = categoryProgress[category] ?? 0.0;
      print('   ${category.name.padRight(15)}: ${value.toStringAsFixed(2)}');
    }

    double providerTotal = 0.0;
    for (final category in mainCategories) {
      providerTotal += categoryProgress[category] ?? 0.0;
    }

    print('\n   Percentages from provider:');
    for (final category in mainCategories) {
      final volume = categoryProgress[category] ?? 0.0;
      final percentage =
          providerTotal > 0 ? (volume / providerTotal * 100) : 20.0;
      print(
          '   ${category.name.padRight(15)}: ${percentage.toStringAsFixed(1)}%');
    }

    print('\n✅ Diagnostic complete!');
  } catch (e, stack) {
    print('❌ Error: $e');
    print(stack);
  }

  container.dispose();
}
