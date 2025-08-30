import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/app_state_provider.dart';
import '../../../core/utils/selectors.dart';

class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      body: appState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading app state'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(appStateProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => _buildDashboard(context, ref, data),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, AppStateData data) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, data),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Active Program Section
              if (data.hasActiveProgram) ...[
                _buildActiveCycleCard(context, ref, data),
                const SizedBox(height: 16),
                _buildMainCTA(context, ref, data),
                const SizedBox(height: 24),
              ] else ...[
                _buildNoProgramCard(context),
                const SizedBox(height: 24),
              ],

              // Stats Row
              _buildStatsRow(data),
              const SizedBox(height: 24),

              // Shortcut Cards
              _buildShortcutCards(context),
              const SizedBox(height: 24),

              // Motivational Section
              _buildMotivationalSection(context, data),
              
              const SizedBox(height: 100), // Bottom padding for nav bar
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, AppStateData data) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Hockey Gym'),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.sports_hockey,
              size: 48,
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCycleCard(BuildContext context, WidgetRef ref, AppStateData data) {
    final theme = Theme.of(context);
    final currentWeek = (data.state?.currentWeek ?? 0) + 1;
    final currentSession = (data.state?.currentSession ?? 0) + 1;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Active Program',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              data.activeProgram?.title ?? 'Unknown Program',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            
            Text(
              'Week $currentWeek • Session $currentSession',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress Bar
            LinearProgressIndicator(
              value: data.percentCycle,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            
            Text(
              '${(data.percentCycle * 100).toInt()}% Complete',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCTA(BuildContext context, WidgetRef ref, AppStateData data) {
    final theme = Theme.of(context);
    final isSessionAvailable = data.nextSession != null;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isSessionAvailable ? () {
          final programId = data.state?.activeProgramId ?? '';
          final week = data.state?.currentWeek ?? 0;
          final session = data.state?.currentSession ?? 0;
          context.go('/session/$programId/$week/$session');
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSessionAvailable ? Icons.play_arrow : Icons.check_circle,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isSessionAvailable ? 'Start Next Session' : 'Program Complete!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProgramCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Ready to Start Training?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a training program that matches your hockey position and goals.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/programs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Choose Your Program',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(AppStateData data) {
    return Row(
      children: [
        Expanded(child: _buildXPCard(data)),
        const SizedBox(width: 12),
        Expanded(child: _buildStreakCard(data)),
      ],
    );
  }

  Widget _buildXPCard(AppStateData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.stars,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'XP Level',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${Selectors.calculateLevel(data.currentXP)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${data.currentXP} XP',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (data.todayXP > 0) ...[
              const SizedBox(height: 4),
              Text(
                '+${data.todayXP} today',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(AppStateData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'Streak',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${data.currentStreak}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.currentStreak == 1 ? 'day' : 'days',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (data.xpMultiplier > 1.0) ...[
              const SizedBox(height: 4),
              Text(
                '${data.xpMultiplier.toStringAsFixed(1)}x XP',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildShortcutCard(
                context,
                'Express Workout',
                Icons.flash_on,
                Colors.orange,
                () => context.go('/extras'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildShortcutCard(
                context,
                'Training Focus',
                Icons.gps_fixed,
                Colors.blue,
                () => context.go('/extras'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShortcutCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationalSection(BuildContext context, AppStateData data) {
    final message = _getMotivationalMessage(data);
    
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.psychology,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getMotivationalMessage(AppStateData data) {
    if (!data.hasActiveProgram) {
      return "Every champion started with a single decision. Choose your program and begin your journey!";
    }

    if (data.currentStreak >= Selectors.streakWeekThreshold) {
      return "Incredible! You're on fire with a ${data.currentStreak}-day streak. Champions are made of this dedication!";
    }

    if (data.currentStreak >= Selectors.streakMomentumThreshold) {
      return "Building momentum! Your ${data.currentStreak}-day streak shows real commitment. Keep pushing forward!";
    }

    if (data.todayXP > 0) {
      return "Great work today! You've earned ${data.todayXP} XP. Consistency builds champions.";
    }

    if (data.percentCycle > Selectors.progressNearCompleteThreshold) {
      return "You're so close to completing your program! Finish strong - champions never quit!";
    }

    if (data.percentCycle > Selectors.progressHalfwayThreshold) {
      return "Halfway there! Your progress shows dedication. Every session makes you stronger!";
    }

    final messages = [
      "Hockey is a game of speed, skill, and heart. Train all three today!",
      "Champions aren't made in comfort zones. Push your limits today!",
      "Every pro started as a beginner. Every expert was once a rookie. Keep training!",
      "The ice doesn't care about excuses. Show up and give your best!",
      "Skill is built through repetition. Greatness through persistence.",
    ];

    return messages[data.currentXP % messages.length];
  }}