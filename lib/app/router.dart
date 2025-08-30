import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/hub/presentation/hub_screen.dart';
import '../features/programs/presentation/programs_screen.dart';
import '../features/extras/presentation/extras_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/session/presentation/session_player_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Shell route with bottom navigation for main sections
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'hub',
            builder: (context, state) => const HubScreen(),
          ),
          GoRoute(
            path: '/programs',
            name: 'programs',
            builder: (context, state) => const ProgramsScreen(),
          ),
          GoRoute(
            path: '/extras',
            name: 'extras',
            builder: (context, state) => const ExtrasScreen(),
          ),
          GoRoute(
            path: '/progress',
            name: 'progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Session player route (fullscreen, no bottom nav)
      GoRoute(
        path: '/session/:programId/:week/:session',
        name: 'session-player',
        builder: (context, state) {
          final programId = state.pathParameters['programId']!;
          final week = state.pathParameters['week']!;
          final session = state.pathParameters['session']!;
          return SessionPlayerScreen(
            programId: programId,
            week: week,
            session: session,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Navigation shell with bottom navigation bar
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(currentLocation),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Programs',
          ),
          NavigationDestination(
            icon: Icon(Icons.extension_outlined),
            selectedIcon: Icon(Icons.extension),
            label: 'Extras',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Hub',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/programs')) return 0;
    if (location.startsWith('/extras')) return 1;
    if (location == '/') return 2; // Hub is center
    if (location.startsWith('/progress')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 2; // Default to Hub
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/programs');
        break;
      case 1:
        context.go('/extras');
        break;
      case 2:
        context.go('/');
        break;
      case 3:
        context.go('/progress');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }}