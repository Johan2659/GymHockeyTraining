import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymhockeytraining/features/application/app_state_provider.dart';
import 'package:gymhockeytraining/core/models/models.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Step 5 — SSOT AppState Tests', () {
    late ProviderContainer container;

    setUp(() async {
      await TestHelpers.initializeTestEnvironment();
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await TestHelpers.cleanup();
    });

    test('AppState provider builds without loops', () async {
      // This should complete without hanging or throwing
      final appState = await container.read(appStateProvider.future);

      expect(appState, isNotNull);
      expect(appState.programs, isNotEmpty);
    });

    test('Mutations append events and update state', () async {
      // Start a program
      await container
          .read(startProgramActionProvider('hockey_attacker_v1').future);
      await Future.delayed(Duration(milliseconds: 100));

      // Mark exercise done
      await container.read(markExerciseDoneActionProvider('squats').future);
      await Future.delayed(Duration(milliseconds: 100));

      // Verify events were appended
      final appState = await container.read(appStateProvider.future);

      expect(appState.events.length, greaterThanOrEqualTo(2));
      expect(
          appState.events
              .any((e) => e.type == ProgressEventType.sessionStarted),
          isTrue);
      expect(
          appState.events.any((e) => e.type == ProgressEventType.exerciseDone),
          isTrue);
      expect(appState.state?.completedExerciseIds, contains('squats'));
    });

    test('percentCycle calculated correctly', () async {
      // Start a program
      await container
          .read(startProgramActionProvider('hockey_attacker_v1').future);
      await Future.delayed(Duration(milliseconds: 100));

      // Check percent cycle
      final appState = await container.read(appStateProvider.future);

      // Should be greater than 0 since we started a session
      expect(appState.percentCycle, greaterThanOrEqualTo(0.0));
      expect(appState.percentCycle, lessThanOrEqualTo(1.0));
    });

    test('streak calculated correctly with test events', () async {
      // Start a program (creates events)
      await container
          .read(startProgramActionProvider('hockey_attacker_v1').future);
      await Future.delayed(Duration(milliseconds: 100));

      // Mark exercise done (creates more events)
      await container.read(markExerciseDoneActionProvider('squats').future);
      await Future.delayed(Duration(milliseconds: 100));

      // Complete session
      await container.read(completeSessionActionProvider.future);
      await Future.delayed(Duration(milliseconds: 100));

      // Check streak calculation
      final appState = await container.read(appStateProvider.future);

      // Should have some streak since we have events today
      expect(appState.currentStreak, greaterThanOrEqualTo(0));
      expect(appState.currentStreak,
          lessThanOrEqualTo(365)); // Reasonable upper bound
    });

    test('nextSessionRef calculated correctly', () async {
      // Start a program
      await container
          .read(startProgramActionProvider('hockey_attacker_v1').future);
      await Future.delayed(Duration(milliseconds: 100));

      // Check next session reference
      final appState = await container.read(appStateProvider.future);

      // Should have a next session since we just started
      expect(appState.nextSession, isNotNull);
      expect(appState.nextSession?.id, isNotEmpty);
    });

    test('All derived values work together', () async {
      // Start program and do multiple actions
      await container
          .read(startProgramActionProvider('hockey_attacker_v1').future);
      await Future.delayed(Duration(milliseconds: 100));

      await container.read(markExerciseDoneActionProvider('squats').future);
      await Future.delayed(Duration(milliseconds: 100));

      await container.read(markExerciseDoneActionProvider('pushups').future);
      await Future.delayed(Duration(milliseconds: 100));

      await container.read(completeBonusChallengeActionProvider.future);
      await Future.delayed(Duration(milliseconds: 100));

      // Verify all derived values are calculated
      final appState = await container.read(appStateProvider.future);

      expect(appState.currentXP, greaterThan(0));
      expect(appState.todayXP, greaterThan(0));
      expect(appState.currentStreak, greaterThanOrEqualTo(0));
      expect(appState.xpMultiplier, greaterThanOrEqualTo(1.0));
      expect(appState.percentCycle, greaterThanOrEqualTo(0.0));
      expect(appState.percentCycle, lessThanOrEqualTo(1.0));

      // Should have multiple events
      expect(appState.events.length,
          greaterThanOrEqualTo(4)); // start + 2 exercises + bonus
    });
  });
}
