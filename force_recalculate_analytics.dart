import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymhockeytraining/app/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();
  
  print('\n=== Force Recalculate Analytics ===\n');
  
  try {
    // Get repositories
    final analyticsRepo = container.read(performanceAnalyticsRepositoryProvider);
    final progressRepo = container.read(progressRepositoryProvider);
    final programRepo = container.read(programRepositoryProvider);
    final stateRepo = container.read(programStateRepositoryProvider);
    
    print('1. Fetching current data...');
    final events = await progressRepo.getRecent(limit: 10000);
    final programs = await programRepo.getAll();
    final currentState = await stateRepo.get();
    
    print('   - Events: ${events.length}');
    print('   - Programs: ${programs.length}');
    print('   - Current state: ${currentState?.activeProgramId ?? "None"}');
    
    print('\n2. Recalculating analytics with NEW logic...');
    final newAnalytics = await analyticsRepo.calculateAnalytics(
      events,
      programs,
      currentState,
    );
    
    print('\n3. Category Progress Results:');
    final categories = [
      'power',
      'strength', 
      'speed',
      'conditioning',
      'agility',
    ];
    
    double total = 0.0;
    for (final catName in categories) {
      final cat = newAnalytics.categoryProgress.keys.firstWhere(
        (k) => k.name == catName,
        orElse: () => throw Exception('Category $catName not found'),
      );
      total += newAnalytics.categoryProgress[cat] ?? 0.0;
    }
    
    for (final catName in categories) {
      final cat = newAnalytics.categoryProgress.keys.firstWhere(
        (k) => k.name == catName,
      );
      final value = newAnalytics.categoryProgress[cat] ?? 0.0;
      final percentage = total > 0 ? (value / total * 100) : 0.0;
      print('   ${catName.padRight(15)}: ${value.toStringAsFixed(1)} → ${percentage.toStringAsFixed(1)}%');
    }
    
    print('\n4. Saving new analytics to database...');
    await analyticsRepo.save(newAnalytics);
    
    print('\n✅ Analytics recalculated and saved!');
    print('   Please Hot Restart your app to see the changes.');
    
  } catch (e, stack) {
    print('❌ Error: $e');
    print(stack);
  }
  
  container.dispose();
}
