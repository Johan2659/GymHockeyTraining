import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../application/app_state_provider.dart';
import '../../../core/utils/selectors.dart';
import '../../programs/presentation/program_management_dialog.dart';

class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hockey Gym'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
      ),
      body: appState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading app state',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              FilledButton(
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

  Widget _buildDashboard(
      BuildContext context, WidgetRef ref, AppStateData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _buildStatsRow(context, data),
          const SizedBox(height: 24),

          // Shortcut Cards
          _buildShortcutCards(context),
          const SizedBox(height: 24),

          // Motivational Section
          _buildMotivationalSection(context, data),

          const SizedBox(height: 100), // Bottom padding for nav bar
        ],
      ),
    );
  }

  Widget _buildActiveCycleCard(
      BuildContext context, WidgetRef ref, AppStateData data) {
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
                  Icons.track_changes,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Current Program',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[400],
                  ),
                  onSelected: (value) {
                    if (value == 'stop') {
                      _showStopProgramDialog(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'stop',
                      child: Row(
                        children: [
                          Icon(Icons.stop_circle_outlined, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Stop Program'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data.activeProgram?.title ?? 'Unknown Program',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: data.percentCycle,
              backgroundColor: Colors.grey[700],
              valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Week $currentWeek • Session $currentSession',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                      ),
                ),
                Text(
                  '${(data.percentCycle * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCTA(BuildContext context, WidgetRef ref, AppStateData data) {
    final isSessionAvailable = data.nextSession != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: isSessionAvailable
            ? () {
                final programId = data.state?.activeProgramId ?? '';
                final week = data.state?.currentWeek ?? 0;
                final session = data.state?.currentSession ?? 0;
                context.go('/session/$programId/$week/$session');
              }
            : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.onPrimaryColor,
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
            Flexible(
              child: Text(
                isSessionAvailable ? 'Start Next Session' : 'Program Complete!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProgramCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.fitness_center,
                size: 48,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 12),
              Text(
                'Ready to Start Training?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a training program that matches your hockey position and goals.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/programs'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.onPrimaryColor,
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
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AppStateData data) {
    return Row(
      children: [
        Expanded(child: _buildXPCard(context, data)),
        const SizedBox(width: 12),
        Expanded(child: _buildStreakCard(context, data)),
      ],
    );
  }

  Widget _buildXPCard(BuildContext context, AppStateData data) {
    final level = Selectors.calculateLevel(data.currentXP);
    final xpInCurrentLevel = data.currentXP % Selectors.xpPerLevel;
    final progressToNextLevel = xpInCurrentLevel / Selectors.xpPerLevel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: AppTheme.accentColor, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Level $level',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${data.currentXP} XP',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressToNextLevel,
              backgroundColor: Colors.grey[700],
              valueColor: AlwaysStoppedAnimation(AppTheme.accentColor),
            ),
            const SizedBox(height: 4),
            Text(
              '${Selectors.xpPerLevel - xpInCurrentLevel} XP to Level ${level + 1}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
            if (data.todayXP > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${data.todayXP} today',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, AppStateData data) {
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
                  color: data.currentStreak > 0 ? Colors.orange : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Streak',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${data.currentStreak} days',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: data.currentStreak > 0 ? Colors.orange : Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _getStreakMessage(data.currentStreak),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
            if (data.xpMultiplier > 1.0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${((data.xpMultiplier - 1) * 100).toInt()}% XP Bonus',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStreakMessage(int streak) {
    if (streak == 0) return 'Start your streak today!';
    if (streak == 1) return 'Great start! Keep it going';
    if (streak < 7) return 'Building momentum';
    if (streak < 30) return 'Week streak achieved!';
    return 'Amazing dedication!';
  }

  Widget _buildShortcutCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

  Widget _buildShortcutCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationalSection(BuildContext context, AppStateData data) {
    final message = _getMotivationalMessage(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motivation',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
  }

  /// Shows the stop program dialog
  void _showStopProgramDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProgramManagementDialog(),
    );
  }
}
