import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymhockeytraining/app/di.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'package:gymhockeytraining/features/application/app_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();
  
  print('\n=== Testing Category Progress Calculation ===\n');
  
  try {
    // Get all exercise performances
    final performanceRepo = container.read(exercisePerformanceRepositoryProvider);
    final allPerformances = await performanceRepo.getAll();
    
    print('Total exercise performances: ${allPerformances.length}');
    
    if (allPerformances.isEmpty) {
      print('❌ No exercise performances found in database');
      print('   User needs to complete some exercises first');
      return;
    }
    
    // Get exercise repository
    final exerciseRepo = container.read(exerciseRepositoryProvider);
    
    // Count by category
    final categoryCounts = <ExerciseCategory, int>{};
    final categoryVolumes = <ExerciseCategory, double>{};
    
    for (final perf in allPerformances) {
      final exercise = await exerciseRepo.getById(perf.exerciseId);
      if (exercise == null) {
        print('⚠️  Exercise not found: ${perf.exerciseId}');
        continue;
      }
      
      categoryCounts[exercise.category] = (categoryCounts[exercise.category] ?? 0) + 1;
      
      double volume = 0.0;
      for (final set in perf.sets) {
        final weight = set.weight ?? 1.0;
        volume += set.reps * weight;
      }
      
      categoryVolumes[exercise.category] = (categoryVolumes[exercise.category] ?? 0.0) + volume;
    }
    
    print('\n--- Category Breakdown ---');
    for (final category in ExerciseCategory.values) {
      final count = categoryCounts[category] ?? 0;
      final volume = categoryVolumes[category] ?? 0.0;
      if (count > 0) {
        print('${category.name}: $count exercises, ${volume.toStringAsFixed(1)} total volume');
      }
    }
    
    print('\n--- Main Categories (for radar) ---');
    const mainCategories = [
      ExerciseCategory.power,
      ExerciseCategory.strength,
      ExerciseCategory.speed,
      ExerciseCategory.conditioning,
      ExerciseCategory.agility,
    ];
    
    double totalVolume = 0.0;
    for (final category in mainCategories) {
      totalVolume += categoryVolumes[category] ?? 0.0;
    }
    
    for (final category in mainCategories) {
      final volume = categoryVolumes[category] ?? 0.0;
      final percentage = totalVolume > 0 ? (volume / totalVolume * 100) : 0.0;
      print('${category.name}: ${percentage.toStringAsFixed(1)}%');
    }
    
    // Test the actual provider
    print('\n--- Testing categoryProgressProvider ---');
    final categoryProgress = await container.read(categoryProgressProvider.future);
    
    double providerTotal = 0.0;
    for (final category in mainCategories) {
      providerTotal += categoryProgress[category] ?? 0.0;
    }
    
    for (final category in mainCategories) {
      final volume = categoryProgress[category] ?? 0.0;
      final percentage = providerTotal > 0 ? (volume / providerTotal * 100) : 0.0;
      print('${category.name}: ${percentage.toStringAsFixed(1)}% (from provider)');
    }
    
    print('\n✅ Test complete!');
  } catch (e, stack) {
    print('❌ Error: $e');
    print(stack);
  }
  
  container.dispose();
}
