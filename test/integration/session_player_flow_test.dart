import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'package:gymhockeytraining/features/application/app_state_provider.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Integration Tests - SessionPlayer Flow', () {
    late ProviderContainer container;

    setUpAll(() async {
      await TestHelpers.initializeTestEnvironment();
    });

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    tearDownAll(() async {
      await TestHelpers.cleanup();
    });

    group('Complete SessionPlayer Flow', () {
      test('should complete full session flow from start to finish', () async {
        const programId = 'hockey_attacker_v1';
        
        // 1. Start a program
        await container.read(startProgramActionProvider(programId).future);
        
        // Verify program state was created
        final initialState = await container.read(programStateProvider.future);
        expect(initialState?.activeProgramId, equals(programId));
        expect(initialState?.currentWeek, equals(0));
        expect(initialState?.currentSession, equals(0));
        expect(initialState?.completedExerciseIds, isEmpty);

        // 2. Mark some exercises as done
        await container.read(markExerciseDoneActionProvider('sprint_30m').future);
        await container.read(markExerciseDoneActionProvider('agility_ladder').future);
        
        // Verify exercises were added
        final stateAfterExercises = await container.read(programStateProvider.future);
        expect(stateAfterExercises?.completedExerciseIds, contains('sprint_30m'));
        expect(stateAfterExercises?.completedExerciseIds, contains('agility_ladder'));
        expect(stateAfterExercises?.completedExerciseIds.length, equals(2));

        // 3. Complete bonus challenge
        await container.read(completeBonusChallengeActionProvider.future);

        // 4. Complete the session
        await container.read(completeSessionActionProvider.future);
        
        // Verify session advancement
        final finalState = await container.read(programStateProvider.future);
        expect(finalState?.currentSession, equals(1)); // Advanced from 0 to 1
        
        // 5. Verify progress events were logged
        final events = await container.read(progressEventsProvider.future);
        expect(events, isNotEmpty);
        
        // Should have: sessionStarted, exerciseDone (x2), bonusDone, sessionCompleted
        final sessionStarted = events.where((e) => e.type == ProgressEventType.sessionStarted);
        final exercisesDone = events.where((e) => e.type == ProgressEventType.exerciseDone);
        final bonusDone = events.where((e) => e.type == ProgressEventType.bonusDone);
        final sessionCompleted = events.where((e) => e.type == ProgressEventType.sessionCompleted);
        
        expect(sessionStarted.length, greaterThanOrEqualTo(1));
        expect(exercisesDone.length, greaterThanOrEqualTo(2));
        expect(bonusDone.length, greaterThanOrEqualTo(1));
        expect(sessionCompleted.length, greaterThanOrEqualTo(1));
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('should handle program pause and resume correctly', () async {
        const programId = 'hockey_attacker_v1';
        
        // Start program
        await container.read(startProgramActionProvider(programId).future);
        
        // Do some exercises
        await container.read(markExerciseDoneActionProvider('exercise1').future);
        
        // Pause program
        await container.read(pauseProgramActionProvider.future);
        
        // Verify pause state
        final pausedState = await container.read(programStateProvider.future);
        expect(pausedState?.pausedAt, isNotNull);
        expect(pausedState?.completedExerciseIds, contains('exercise1'));
        
        // Resume program
        await container.read(resumeProgramActionProvider.future);
        
        // Verify resume state
        final resumedState = await container.read(programStateProvider.future);
        expect(resumedState?.pausedAt, isNull);
        expect(resumedState?.completedExerciseIds, contains('exercise1')); // Should retain progress
      });

      test('should handle multiple sessions progression', () async {
        const programId = 'hockey_attacker_v1';
        
        // Start program
        await container.read(startProgramActionProvider(programId).future);
        
        // Complete first session
        await container.read(markExerciseDoneActionProvider('exercise1').future);
        await container.read(completeSessionActionProvider.future);
        
        // Complete second session  
        await container.read(markExerciseDoneActionProvider('exercise2').future);
        await container.read(completeSessionActionProvider.future);
        
        // Verify progression
        final finalState = await container.read(programStateProvider.future);
        expect(finalState?.currentSession, equals(2)); // Should be at session 2
        
        // Verify all events logged
        final events = await container.read(progressEventsProvider.future);
        final sessionCompletions = events.where((e) => e.type == ProgressEventType.sessionCompleted);
        expect(sessionCompletions.length, greaterThanOrEqualTo(2));
      });

      test('should handle extra completion with XP rewards', () async {
        const extraId = 'express_workout_1';
        const xpReward = 50;
        
        // Complete extra
        await container.read(completeExtraActionProvider(extraId, xpReward).future);
        
        // Verify extra completion event
        final events = await container.read(progressEventsProvider.future);
        final extraEvents = events.where((e) => 
          e.type == ProgressEventType.extraCompleted && 
          e.exerciseId == extraId
        );
        
        expect(extraEvents.length, equals(1));
        expect(extraEvents.first.payload, isNotNull);
        expect(extraEvents.first.payload!['xp_reward'], equals(xpReward));
      });

      test('should calculate XP and streaks correctly', () async {
        const programId = 'hockey_attacker_v1';
        
        // Start program and complete some activities
        await container.read(startProgramActionProvider(programId).future);
        await container.read(markExerciseDoneActionProvider('exercise1').future);
        await container.read(completeSessionActionProvider.future);
        
        // Complete an extra
        await container.read(completeExtraActionProvider('extra1', 25).future);
        
        // Check XP calculation
        final currentXP = await container.read(currentXPProvider.future);
        expect(currentXP, greaterThan(0));
        
        // Check today's XP
        final todayXP = await container.read(todayXPProvider.future);
        expect(todayXP, greaterThan(0));
        
        // Check streak
        final streak = await container.read(currentStreakProvider.future);
        expect(streak, greaterThanOrEqualTo(0));
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle completing exercises without active program', () async {
        // Try to complete exercise without starting program
        await container.read(markExerciseDoneActionProvider('exercise1').future);
        
        // Should not crash, just do nothing
        final state = await container.read(programStateProvider.future);
        expect(state, isNull);
      });

      test('should handle completing session without active program', () async {
        // Try to complete session without starting program
        await container.read(completeSessionActionProvider.future);
        
        // Should not crash, just do nothing
        final state = await container.read(programStateProvider.future);
        expect(state, isNull);
      });

      test('should handle bonus completion without active program', () async {
        // Try to complete bonus without starting program
        await container.read(completeBonusChallengeActionProvider.future);
        
        // Should not crash, just do nothing
        final state = await container.read(programStateProvider.future);
        expect(state, isNull);
      });
    });
  });
}
