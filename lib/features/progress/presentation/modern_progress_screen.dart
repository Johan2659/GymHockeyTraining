import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/selectors.dart';
import '../../application/app_state_provider.dart';
import 'widgets/activity_calendar_widget.dart';

class ModernProgressScreen extends ConsumerWidget {
  const ModernProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStateAsync = ref.watch(appStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROGRESS'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: appStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: AppSpacing.card,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: AppTheme.error),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Error loading progress data',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  error.toString(),
                  style: AppTextStyles.small.copyWith(color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (appState) => _buildProgressContent(context, ref, appState),
      ),
    );
  }

  Widget _buildProgressContent(
      BuildContext context, WidgetRef ref, AppStateData appState) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),

          // 1) HERO SUMMARY SECTION
          Padding(
            padding: AppSpacing.horizontalPage,
            child: _buildHeroSummarySection(context, appState),
          ),

          const SizedBox(height: AppSpacing.xl),

          // 2) PROGRESS OVER TIME
          _buildProgressOverTimeSection(context, appState),

          const SizedBox(height: AppSpacing.xl),

          // 3) PERFORMANCE PROFILE
          _buildPerformanceProfileSection(context, ref),

          const SizedBox(height: AppSpacing.xl),

          // 4) ACTIVITY CALENDAR
          Padding(
            padding: AppSpacing.horizontalPage,
            child: ActivityCalendarWidget(events: appState.events),
          ),

          const SizedBox(height: AppSpacing.xl),

          // 5) ACHIEVEMENTS / STREAK STRIP
          _buildAchievementsStrip(context, ref, appState),

          // Extra bottom padding to clear the bottom navigation bar
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // =============================================================================
  // 1) HERO SUMMARY SECTION
  // =============================================================================

  Widget _buildHeroSummarySection(BuildContext context, AppStateData appState) {
    final level = Selectors.calculateLevel(appState.currentXP);
    final totalSessions = appState.events
        .where((e) => e.type == ProgressEventType.sessionCompleted)
        .length;
    final currentWeek = (appState.state?.currentWeek ?? 0) + 1;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'SEASON OVERVIEW',
                style: AppTextStyles.labelXS.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'LEVEL',
                '$level',
                Icons.military_tech,
                AppTheme.accentGold,
              ),
              _buildVerticalDivider(),
              _buildStatItem(
                context,
                'SESSIONS',
                '$totalSessions',
                Icons.fitness_center,
                AppTheme.primaryColor,
              ),
              _buildVerticalDivider(),
              _buildStatItem(
                context,
                'WEEK',
                '$currentWeek',
                Icons.calendar_today,
                AppTheme.success,
              ),
              _buildVerticalDivider(),
              _buildStatItem(
                context,
                'XP',
                '${appState.currentXP}',
                Icons.stars,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(
              fontSize: 28,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.statLabel,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.primaryColor.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // =============================================================================
  // 2) PROGRESS OVER TIME SECTION
  // =============================================================================

  Widget _buildProgressOverTimeSection(BuildContext context, AppStateData appState) {
    // Get last 4 weeks of data
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    
    final recentSessions = appState.events
        .where((e) => 
            e.type == ProgressEventType.sessionCompleted &&
            e.ts.isAfter(fourWeeksAgo))
        .toList()
      ..sort((a, b) => a.ts.compareTo(b.ts));

    // Group by week
    final weeklySessionCounts = <int, int>{};
    for (final session in recentSessions) {
      final weekNumber = ((now.difference(session.ts).inDays) / 7).floor();
      if (weekNumber >= 0 && weekNumber < 4) {
        weeklySessionCounts[3 - weekNumber] = (weeklySessionCounts[3 - weekNumber] ?? 0) + 1;
      }
    }

    final maxSessions = weeklySessionCounts.values.isEmpty 
        ? 1 
        : weeklySessionCounts.values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: AppSpacing.horizontalPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(Icons.show_chart, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'PROGRESS OVER TIME',
                style: AppTextStyles.labelXS.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const GradientDivider(height: 1, margin: EdgeInsets.zero),
          const SizedBox(height: AppSpacing.lg),

          // Weekly bars
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(4, (index) {
                final count = weeklySessionCounts[index] ?? 0;
                final fraction = maxSessions > 0 ? count / maxSessions : 0.0;
                final weekLabel = index == 3 ? 'This\nWeek' : '${4 - index}w\nago';

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Text(
                          '$count',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: count > 0 ? AppTheme.primaryColor : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: fraction.clamp(0.1, 1.0),
                            widthFactor: 1.0,
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: count > 0
                                      ? [
                                          AppTheme.primaryColor.withOpacity(0.6),
                                          AppTheme.primaryColor,
                                        ]
                                      : [
                                          Colors.grey[800]!,
                                          Colors.grey[700]!,
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          weekLabel,
                          style: AppTextStyles.labelXS.copyWith(
                            color: Colors.grey[600],
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          if (recentSessions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Center(
                child: Text(
                  'Complete sessions to see your progress here',
                  style: AppTextStyles.small.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =============================================================================
  // 3) PERFORMANCE PROFILE SECTION
  // =============================================================================

  Widget _buildPerformanceProfileSection(BuildContext context, WidgetRef ref) {
    final categoryProgressAsync = ref.watch(categoryProgressProvider);

    return categoryProgressAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (categoryProgress) {
        // Filter main training categories
        final mainCategories = [
          ExerciseCategory.power,
          ExerciseCategory.strength,
          ExerciseCategory.speed,
          ExerciseCategory.conditioning,
          ExerciseCategory.agility,
        ];

        final hasData = mainCategories.any((cat) => 
          (categoryProgress[cat] ?? 0.0) > 0
        );

        return Padding(
          padding: AppSpacing.horizontalPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                children: [
                  Icon(Icons.radar, color: AppTheme.accentGold, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'PERFORMANCE PROFILE',
                    style: AppTextStyles.labelXS.copyWith(
                      color: AppTheme.accentGold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    onPressed: () => _showPerformanceProfileInfo(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              const GradientDivider(height: 1, margin: EdgeInsets.zero),
              const SizedBox(height: AppSpacing.lg),

              if (!hasData)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(
                    child: Text(
                      'Complete training sessions to build your profile',
                      style: AppTextStyles.small.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.accentGold.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: mainCategories.map((category) {
                      final progress = categoryProgress[category] ?? 0.0;
                      final color = _getCategoryColor(category);
                      final name = _getExerciseCategoryDisplayName(category);
                      
                      // Determine if this is a focus area (below threshold)
                      final isFocusArea = progress > 0 && progress < 15.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  name.toUpperCase(),
                                  style: AppTextStyles.labelXS.copyWith(
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const Spacer(),
                                if (isFocusArea)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGold.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: AppTheme.accentGold.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'FOCUS AREA',
                                      style: AppTextStyles.labelXS.copyWith(
                                        color: AppTheme.accentGold,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '${progress.toInt()}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Stack(
                              children: [
                                // Background bar
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                // Progress bar
                                FractionallySizedBox(
                                  widthFactor: (progress / 100).clamp(0.0, 1.0),
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          color.withOpacity(0.6),
                                          color,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // =============================================================================
  // 4) ACHIEVEMENTS / STREAK STRIP
  // =============================================================================

  Widget _buildAchievementsStrip(
    BuildContext context,
    WidgetRef ref,
    AppStateData appState,
  ) {
    final personalBestsAsync = ref.watch(personalBestsProvider);

    return personalBestsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (personalBests) {
        final completedPrograms = appState.events
            .where((e) =>
                e.type == ProgressEventType.sessionCompleted &&
                e.week == 4 &&
                e.session == 4)
            .length;

        final totalBonuses = appState.events
            .where((e) => e.type == ProgressEventType.extraCompleted)
            .length;

        return Padding(
          padding: AppSpacing.horizontalPage,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.05),
                  AppTheme.accentGold.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: AppTheme.accentGold,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'ACHIEVEMENTS',
                      style: AppTextStyles.labelXS.copyWith(
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAchievementChip(
                      context,
                      '${appState.currentStreak}',
                      'Day Streak',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    _buildAchievementChip(
                      context,
                      '$completedPrograms',
                      'Cycles',
                      Icons.check_circle,
                      AppTheme.success,
                    ),
                    _buildAchievementChip(
                      context,
                      '${personalBests.length}',
                      'PRs',
                      Icons.stars,
                      AppTheme.accentGold,
                    ),
                    _buildAchievementChip(
                      context,
                      '$totalBonuses',
                      'Bonuses',
                      Icons.add_circle,
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementChip(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.statValue.copyWith(
            fontSize: 24,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelXS.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // =============================================================================
  // HELPER METHODS
  // =============================================================================

  void _showPerformanceProfileInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: AppTheme.accentGold, size: 24),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Performance Profile',
                    style: AppTextStyles.titleL,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Your training distribution across key hockey performance categories.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Focus Areas are categories where you have less than 15 completed exercises. Building balance across all categories creates a well-rounded athlete.',
                style: AppTextStyles.small.copyWith(
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'GOT IT',
                    style: AppTextStyles.button.copyWith(
                      color: AppTheme.primaryColor,
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

  String _getExerciseCategoryDisplayName(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.strength:
        return 'Strength';
      case ExerciseCategory.power:
        return 'Power';
      case ExerciseCategory.speed:
        return 'Speed';
      case ExerciseCategory.agility:
        return 'Agility';
      case ExerciseCategory.conditioning:
        return 'Conditioning';
      case ExerciseCategory.technique:
        return 'Technique';
      case ExerciseCategory.balance:
        return 'Balance';
      case ExerciseCategory.flexibility:
        return 'Flexibility';
      case ExerciseCategory.warmup:
        return 'Warmup';
      case ExerciseCategory.recovery:
        return 'Recovery';
      case ExerciseCategory.stickSkills:
        return 'Stick Skills';
      case ExerciseCategory.gameSituation:
        return 'Game Situation';
    }
  }

  Color _getCategoryColor(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.strength:
        return Colors.red;
      case ExerciseCategory.power:
        return Colors.orange;
      case ExerciseCategory.speed:
        return Colors.blue;
      case ExerciseCategory.agility:
        return Colors.green;
      case ExerciseCategory.conditioning:
        return Colors.purple;
      case ExerciseCategory.technique:
        return Colors.indigo;
      case ExerciseCategory.balance:
        return Colors.teal;
      case ExerciseCategory.flexibility:
        return Colors.pink;
      case ExerciseCategory.warmup:
        return Colors.amber;
      case ExerciseCategory.recovery:
        return Colors.lightGreen;
      case ExerciseCategory.stickSkills:
        return Colors.deepOrange;
      case ExerciseCategory.gameSituation:
        return Colors.cyan;
    }
  }
}
