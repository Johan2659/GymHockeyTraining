import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'package:gymhockeytraining/features/application/app_state_provider.dart';
import 'package:gymhockeytraining/features/hub/presentation/forge_home_screen.dart';

AppStateData dashboard({bool active = false}) => AppStateData(
  programs: const [],
  events: const [],
  profile: null,
  state: active
      ? const ProgramState(
          userId: 'test',
          activeProgramId: 'strength',
          currentWeek: 1,
          currentSession: 2,
          completedExerciseIds: [],
        )
      : null,
  activeProgram: null,
  currentXP: 0,
  todayXP: 0,
  currentStreak: 0,
  xpMultiplier: 1,
  percentCycle: 0,
  nextSession: active
      ? const Session(
          id: 'next',
          title: 'Strength',
          blocks: [],
          bonusChallenge: '',
        )
      : null,
);

void main() {
  Future<GoRouter> load(
    WidgetTester tester, {
    bool active = false,
    SessionInProgress? resume,
  }) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const ForgeHomeScreen()),
        GoRoute(
          path: '/programs',
          builder: (_, __) =>
              const Scaffold(body: Text('Programs destination')),
        ),
        GoRoute(
          path: '/session/:id/:week/:session/play',
          builder: (_, state) => Scaffold(body: Text(state.uri.path)),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appStateProvider.overrideWith(
            (ref) async => dashboard(active: active),
          ),
          sessionInProgressProvider.overrideWith((ref) async => resume),
          expressWorkoutsProvider.overrideWith((ref) async => <ExtraItem>[]),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('No program sends the player to program selection', (
    tester,
  ) async {
    await load(tester);
    await tester.tap(find.text('Choose a program'));
    await tester.pumpAndSettle();
    expect(find.text('Programs destination'), findsOneWidget);
  });

  testWidgets('Quick start uses the actual program cursor', (tester) async {
    await load(tester, active: true);
    await tester.tap(find.text('Start workout'));
    await tester.pumpAndSettle();
    expect(find.text('/session/strength/1/2/play'), findsOneWidget);
  });

  testWidgets('Saved session takes priority over the next workout', (
    tester,
  ) async {
    await load(
      tester,
      active: true,
      resume: SessionInProgress(
        programId: 'saved',
        week: 0,
        session: 1,
        currentPage: 2,
        completedExercises: const [],
        exercisePerformances: const {},
        pausedAt: DateTime(2026, 10, 5),
      ),
    );
    await tester.tap(find.text('Resume workout'));
    await tester.pumpAndSettle();
    expect(find.text('/session/saved/0/1/play'), findsOneWidget);
  });
}
