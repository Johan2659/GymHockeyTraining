import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/models/models.dart';
import '../features/hub/presentation/hub_screen.dart';
import '../features/programs/presentation/programs_screen.dart';
import '../features/programs/presentation/program_detail_screen.dart';
import '../features/extras/presentation/extras_screen.dart';
import '../features/extras/presentation/extra_detail_screen.dart';
import '../features/extras/presentation/extra_session_player_screen.dart';
import '../features/progress/presentation/modern_progress_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/session/presentation/session_detail_screen.dart';
import '../features/session/presentation/session_player_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/onboarding/presentation/role_selection_screen.dart';
import '../features/onboarding/presentation/goal_selection_screen.dart';
import '../features/onboarding/presentation/plan_preview_screen.dart';
import '../features/auth/presentation/auth_welcome_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/application/auth_controller.dart';
import 'di.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  // Watch auth state so router rebuilds when user logs in/out
  ref.watch(currentAuthUserProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // Use fresh read to get current auth state (not cached)
      final authRepo = ref.read(authRepositoryProvider);
      final isLoggedIn = await authRepo.isLoggedIn();
      final currentUser = await authRepo.getCurrentUser();
      
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isOnboardingRoute = state.matchedLocation.startsWith('/onboarding');
      
      // Not logged in - redirect to auth
      if (!isLoggedIn && !isAuthRoute) {
        return '/auth/welcome';
      }
      
      // Logged in but onboarding not completed - redirect to onboarding
      if (isLoggedIn && currentUser != null && !currentUser.onboardingCompleted && !isOnboardingRoute) {
        return '/onboarding/welcome';
      }
      
      // Logged in, onboarding completed, trying to access auth/onboarding - redirect to main app
      if (isLoggedIn && currentUser != null && currentUser.onboardingCompleted && (isAuthRoute || isOnboardingRoute)) {
        return '/';
      }
      
      return null; // No redirect needed
    },
    routes: [
      // Authentication routes
      GoRoute(
        path: '/auth/welcome',
        builder: (context, state) => const AuthWelcomeScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
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
            builder: (context, state) => const ModernProgressScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Program detail route (fullscreen, no bottom nav)
      GoRoute(
        path: '/programs/:programId',
        name: 'program-detail',
        builder: (context, state) {
          final programId = state.pathParameters['programId']!;
          return ProgramDetailScreen(programId: programId);
        },
      ),
      // Session detail route (fullscreen, no bottom nav)
      GoRoute(
        path: '/session/:programId/:week/:session',
        name: 'session-detail',
        builder: (context, state) {
          final programId = state.pathParameters['programId']!;
          final week = state.pathParameters['week']!;
          final session = state.pathParameters['session']!;
          return SessionDetailScreen(
            programId: programId,
            week: week,
            session: session,
          );
        },
      ),
      // Session player route (fullscreen, no bottom nav)
      GoRoute(
        path: '/session/:programId/:week/:session/play',
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
      // Extra detail route (fullscreen, no bottom nav)
      GoRoute(
        path: '/extras/:extraId',
        name: 'extra-detail',
        builder: (context, state) {
          final extraId = state.pathParameters['extraId']!;
          return ExtraDetailScreen(extraId: extraId);
        },
      ),
      // Extra session player route (fullscreen, no bottom nav)
      GoRoute(
        path: '/extras/:extraId/play',
        name: 'extra-session-player',
        builder: (context, state) {
          final extraId = state.pathParameters['extraId']!;
          return ExtraSessionPlayerScreen(extraId: extraId);
        },
      ),
      // Onboarding routes (fullscreen, no bottom nav)
      GoRoute(
        path: '/onboarding/welcome',
        name: 'onboarding-welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/role',
        name: 'onboarding-role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/goal',
        name: 'onboarding-goal',
        builder: (context, state) {
          final role = state.extra as PlayerRole;
          return GoalSelectionScreen(role: role);
        },
      ),
      GoRoute(
        path: '/onboarding/plan_preview',
        name: 'onboarding-plan-preview',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          final role = data['role'] as PlayerRole;
          final goal = data['goal'] as TrainingGoal;
          return PlanPreviewScreen(role: role, goal: goal);
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

// Custom painter for hockey rink center line that contours around the puck
class HockeyRinkLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Create gradient for the red line
    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        const Color.fromARGB(255, 112, 21, 21),
        const Color.fromARGB(255, 19, 4, 4),
        const Color.fromARGB(255, 112, 21, 21),
        Colors.transparent,
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, 4);
    paint.shader = gradient.createShader(rect);

    final path = Path();
    final centerX = size.width / 2;
    final lineY = 0.0;
    final puckRadius = 30.0; // Adjusted for standard sizing

    // Left part of the line
    path.moveTo(0, lineY);
    path.lineTo(centerX - puckRadius - 8, lineY);

    // // Curve around the puck (top half of circle)
    // path.arcToPoint(
    //   Offset(centerX + puckRadius + 8, lineY),
    //   radius: Radius.circular(puckRadius + 8),
    //   clockwise: false,
    // );

    // Right part of the line
    path.lineTo(size.width, lineY);

    canvas.drawPath(path, paint);

    // Add glow effect
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = const Color(0xFFE53E3E).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for dark grey border that follows the red line contour
class HockeyRinkBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final puckRadius = 30.0;
    final borderRadius = 20.0;
    final spacing = 7.0;

    // Créer un gradient plus fluide pour la bordure complète
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFF0F0F0F), // Très foncé aux extrémités (radius)
        const Color(0xFF1A1A1A), // Plus foncé
        const Color(0xFF2A2A2A), // Gris foncé
        const Color(0xFF1A1A1A), // Plus foncé vers le centre
        const Color(0xFF0F0F0F), // Très foncé au centre (interruption gauche)
        const Color(0xFF0F0F0F), // Très foncé au centre (interruption droite)
        const Color(0xFF1A1A1A), // Plus foncé sortie du centre
        const Color(0xFF2A2A2A), // Gris foncé
        const Color(0xFF1A1A1A), // Plus foncé
        const Color(0xFF0F0F0F), // Très foncé aux extrémités (radius)
      ],
      stops: const [0.0, 0.1, 0.2, 0.35, 0.45, 0.55, 0.65, 0.8, 0.9, 1.0],
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Dessiner la partie gauche complète (avec radius)
    final leftPath = Path();
    leftPath.moveTo(0, size.height);
    leftPath.lineTo(0, borderRadius + spacing);
    leftPath.arcToPoint(
      Offset(borderRadius, spacing),
      radius: Radius.circular(borderRadius),
    );
    leftPath.lineTo(centerX - puckRadius - 2, spacing);

    // Dessiner la partie droite complète (avec radius)
    final rightPath = Path();
    rightPath.moveTo(centerX + puckRadius + 2, spacing);
    rightPath.lineTo(size.width - borderRadius, spacing);
    rightPath.arcToPoint(
      Offset(size.width, borderRadius + spacing),
      radius: Radius.circular(borderRadius),
    );
    rightPath.lineTo(size.width, size.height);

    // Dessiner les deux parties avec des connexions douces
    canvas.drawPath(leftPath, paint);
    canvas.drawPath(rightPath, paint);

    // Ajouter des points de connexion doux aux extrémités du centre
    final centerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF0F0F0F);

    // Petites connexions aux interruptions pour plus de fluidité
    canvas.drawCircle(
      Offset(centerX - puckRadius - 2, spacing),
      1.0,
      centerPaint,
    );
    canvas.drawCircle(
      Offset(centerX + puckRadius + 2, spacing),
      1.0,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Navigation shell with modern hockey-themed bottom navigation bar
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final selectedIndex = _calculateSelectedIndex(currentLocation);

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: _buildHockeyRinkBottomNav(context, selectedIndex),
    );
  }

  Widget _buildHockeyRinkBottomNav(BuildContext context, int currentIndex) {
    return SizedBox(
      height: 110, // Augmentation pour accueillir le texte "Hub"
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Solid black background
          Container(
            decoration: const BoxDecoration(
              color: Colors.black, // Solid black background
            ),
          ),

          // Dark grey border that follows the red line contour around the hub
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 110),
            painter: HockeyRinkBorderPainter(),
          ),

          // Red line that contours around the Hub button
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 110),
            painter: HockeyRinkLinePainter(),
          ),

          // Navigation items positioned around the puck
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  isSelected: currentIndex == 0,
                  icon: Icons.sports_hockey_rounded,
                  label: 'Programs',
                  onTap: () => context.go('/programs'),
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  isSelected: currentIndex == 1,
                  icon: Icons.calendar_today_rounded,
                  label: 'Extras',
                  onTap: () => context.go('/extras'),
                ),

                // Center puck (Hub) - ajusté pour éviter l'overflow
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 30), // Réduit pour laisser place au texte
                  child: _buildCenterHub(
                    context,
                    isSelected: currentIndex == 2,
                    onTap: () => context.go('/'),
                  ), // Home (Hub) - Main dashboard
                ),

                _buildNavItem(
                  context,
                  index: 3,
                  isSelected: currentIndex == 3,
                  icon: Icons.trending_up_rounded,
                  label: 'Progress',
                  onTap: () => context.go('/progress'),
                ),
                _buildNavItem(
                  context,
                  index: 4,
                  isSelected: currentIndex == 4,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required bool isSelected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final color = isSelected
        ? const Color.fromARGB(255, 132, 239, 251)
        : Colors.white.withOpacity(0.7);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: isSelected
                  ? BoxDecoration(
                      color:
                          const Color.fromARGB(255, 12, 2, 60).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterHub(
    BuildContext context, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color =
        isSelected ? const Color(0xFF00CFFF) : Colors.white.withOpacity(0.7);

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      splashColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black, // Black background
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromARGB(255, 201, 26, 23), // Red border
                width: 1.5,
              ),
              boxShadow: [
                // Very subtle dark shadow at the top only
                BoxShadow(
                  color: const Color.fromARGB(255, 22, 22, 22).withOpacity(0.8),
                  blurRadius: 1,
                  spreadRadius: 0.5,
                  offset: const Offset(0, -5),
                  // Top shadow, less than 1px
                ),
              ],
            ),
            child: Icon(
              Icons.sports_hockey, // Single hockey icon
              size: 36, // Augmentation de 30 à 36
              color: isSelected
                  ? const Color(0xFF00CFFF) // Bleu électrique quand sélectionné
                  : const Color.fromARGB(
                      255, 174, 166, 166), // Gris quand non sélectionné
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hub',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
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
}
