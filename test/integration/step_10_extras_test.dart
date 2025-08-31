import 'package:flutter_test/flutter_test.dart';

import '../../lib/core/models/models.dart';
import '../../lib/data/datasources/local_extras_source.dart';
import '../../lib/data/repositories_impl/extras_repository_impl.dart';

void main() {
  group('Step 10 - Extras Implementation Tests', () {
    
    test('LocalExtrasSource loads all extras correctly', () async {
      final source = LocalExtrasSource();
      final extras = await source.getAllExtras();

      // Should have 9 total extras (3 express workouts + 3 bonus challenges + 3 mobility)
      expect(extras.length, 9);

      // Check express workouts
      final expressWorkouts = extras.where((e) => e.type == ExtraType.expressWorkout).toList();
      expect(expressWorkouts.length, 3);
      expect(expressWorkouts.any((e) => e.id == 'express_cardio_15'), true);
      expect(expressWorkouts.any((e) => e.id == 'express_strength_20'), true);
      expect(expressWorkouts.any((e) => e.id == 'express_agility_15'), true);

      // Check bonus challenges
      final bonusChallenges = extras.where((e) => e.type == ExtraType.bonusChallenge).toList();
      expect(bonusChallenges.length, 3);
      expect(bonusChallenges.any((e) => e.id == 'challenge_100_pushups'), true);
      expect(bonusChallenges.any((e) => e.id == 'challenge_plank_5min'), true);
      expect(bonusChallenges.any((e) => e.id == 'challenge_burpee_ladder'), true);

      // Check mobility & recovery
      final mobilityRecovery = extras.where((e) => e.type == ExtraType.mobilityRecovery).toList();
      expect(mobilityRecovery.length, 3);
      expect(mobilityRecovery.any((e) => e.id == 'mobility_hip_flow'), true);
      expect(mobilityRecovery.any((e) => e.id == 'mobility_ankle_prep'), true);
      expect(mobilityRecovery.any((e) => e.id == 'mobility_cool_down'), true);
    });

    test('ExtrasRepository filters by type correctly', () async {
      final source = LocalExtrasSource();
      final repository = ExtrasRepositoryImpl(localSource: source);

      // Test express workouts
      final expressWorkouts = await repository.getByType(ExtraType.expressWorkout);
      expect(expressWorkouts.length, 3);
      expect(expressWorkouts.every((e) => e.type == ExtraType.expressWorkout), true);

      // Test bonus challenges
      final bonusChallenges = await repository.getByType(ExtraType.bonusChallenge);
      expect(bonusChallenges.length, 3);
      expect(bonusChallenges.every((e) => e.type == ExtraType.bonusChallenge), true);

      // Test mobility & recovery
      final mobilityRecovery = await repository.getByType(ExtraType.mobilityRecovery);
      expect(mobilityRecovery.length, 3);
      expect(mobilityRecovery.every((e) => e.type == ExtraType.mobilityRecovery), true);
    });

    test('ExtrasRepository finds extras by ID', () async {
      final source = LocalExtrasSource();
      final repository = ExtrasRepositoryImpl(localSource: source);

      // Test finding a specific extra
      final cardioBlast = await repository.getById('express_cardio_15');
      expect(cardioBlast, isNotNull);
      expect(cardioBlast!.title, '15-Min Cardio Blast');
      expect(cardioBlast.type, ExtraType.expressWorkout);
      expect(cardioBlast.xpReward, 50);
      expect(cardioBlast.duration, 15);

      // Test finding non-existent extra
      final nonExistent = await repository.getById('non_existent_id');
      expect(nonExistent, isNull);
    });

    test('ExtraItem model has correct properties', () async {
      final source = LocalExtrasSource();
      final extras = await source.getAllExtras();
      
      final cardioBlast = extras.firstWhere((e) => e.id == 'express_cardio_15');
      
      expect(cardioBlast.id, 'express_cardio_15');
      expect(cardioBlast.title, '15-Min Cardio Blast');
      expect(cardioBlast.description, 'High-intensity cardio circuit to boost endurance and agility');
      expect(cardioBlast.type, ExtraType.expressWorkout);
      expect(cardioBlast.xpReward, 50);
      expect(cardioBlast.duration, 15);
      expect(cardioBlast.difficulty, 'medium');
      expect(cardioBlast.blocks.length, 4);
      
      // Check exercise blocks
      final exerciseIds = cardioBlast.blocks.map((b) => b.exerciseId).toList();
      expect(exerciseIds, contains('jumping_jacks'));
      expect(exerciseIds, contains('burpees'));
      expect(exerciseIds, contains('mountain_climbers'));
      expect(exerciseIds, contains('high_knees'));
    });

    test('Bonus challenges have higher XP rewards', () async {
      final source = LocalExtrasSource();
      final bonusChallenges = await source.getExtrasByType(ExtraType.bonusChallenge);
      
      // All bonus challenges should have XP rewards >= 80
      expect(bonusChallenges.every((e) => e.xpReward >= 80), true);
      
      // Check specific challenges
      final pushupChallenge = bonusChallenges.firstWhere((e) => e.id == 'challenge_100_pushups');
      expect(pushupChallenge.xpReward, 100);
      
      final plankChallenge = bonusChallenges.firstWhere((e) => e.id == 'challenge_plank_5min');
      expect(plankChallenge.xpReward, 80);
      
      final burpeeChallenge = bonusChallenges.firstWhere((e) => e.id == 'challenge_burpee_ladder');
      expect(burpeeChallenge.xpReward, 120);
    });

    test('Mobility & recovery extras have appropriate properties', () async {
      final source = LocalExtrasSource();
      final mobilityExtras = await source.getExtrasByType(ExtraType.mobilityRecovery);
      
      // All mobility extras should be 'easy' difficulty
      expect(mobilityExtras.every((e) => e.difficulty == 'easy'), true);
      
      // All mobility extras should have lower XP rewards (recovery focus)
      expect(mobilityExtras.every((e) => e.xpReward <= 30), true);
      
      // Check hip mobility flow
      final hipFlow = mobilityExtras.firstWhere((e) => e.id == 'mobility_hip_flow');
      expect(hipFlow.title, 'Hip Mobility Flow');
      expect(hipFlow.duration, 10);
      expect(hipFlow.xpReward, 25);
      expect(hipFlow.blocks.length, 4);
    });

    test('Express workouts have varied difficulty levels', () async {
      final source = LocalExtrasSource();
      final expressWorkouts = await source.getExtrasByType(ExtraType.expressWorkout);
      
      // Should have easy, medium, and hard workouts
      final difficulties = expressWorkouts.map((e) => e.difficulty).toSet();
      expect(difficulties, contains('easy'));
      expect(difficulties, contains('medium'));
      expect(difficulties, contains('hard'));
      
      // Hard workouts should have higher XP rewards
      final hardWorkouts = expressWorkouts.where((e) => e.difficulty == 'hard').toList();
      expect(hardWorkouts.isNotEmpty, true);
      expect(hardWorkouts.every((e) => e.xpReward >= 75), true);
    });

    test('All extras have valid exercise blocks', () async {
      final source = LocalExtrasSource();
      final extras = await source.getAllExtras();
      
      for (final extra in extras) {
        // All extras should have at least one exercise block
        expect(extra.blocks.length, greaterThan(0));
        
        // All blocks should have valid exercise IDs
        for (final block in extra.blocks) {
          expect(block.exerciseId.isNotEmpty, true);
        }
      }
    });

    test('Extras data is properly structured', () async {
      final source = LocalExtrasSource();
      final extras = await source.getAllExtras();
      
      for (final extra in extras) {
        // Required fields should not be null or empty
        expect(extra.id.isNotEmpty, true);
        expect(extra.title.isNotEmpty, true);
        expect(extra.description.isNotEmpty, true);
        expect(extra.xpReward, greaterThan(0));
        expect(extra.duration, greaterThan(0));
        
        // Type should be valid
        expect([ExtraType.expressWorkout, ExtraType.bonusChallenge, ExtraType.mobilityRecovery], 
               contains(extra.type));
      }
    });
  });
}
