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
                  style: AppTextStyles.small.copyWith(color: AppTheme.secondaryTextColor),
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

          _buildSectionSeparator(),

          // 2) TRAINING VOLUME
          _buildProgressOverTimeSection(context, appState),

          _buildSectionSeparator(),

          // 3) PERFORMANCE PROFILE
          _buildPerformanceProfileSection(context, ref),

          _buildSectionSeparator(),

          // 4) ACTIVITY CALENDAR
          Padding(
            padding: AppSpacing.horizontalPage,
            child: ActivityCalendarWidget(events: appState.events),
          ),

          _buildSectionSeparator(),

          // 5) ACHIEVEMENTS
          _buildAchievementsStrip(context, ref, appState),

          // Extra bottom padding to clear the bottom navigation bar
          SizedBox(height: MediaQuery.of(context).padding.bottom + 120),
        ],
      ),
    );
  }

  // Modern section separator - subtle gradient fade
  Widget _buildSectionSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Container(
        height: 1,
        margin: AppSpacing.horizontalPage,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppTheme.primaryColor.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header - consistent style
        Row(
          children: [
            Icon(
              Icons.trending_up,
              color: AppTheme.primaryColor,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'SEASON OVERVIEW',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppTheme.primaryColor,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Stats Grid - 2025 minimalist style: pure spacing, no backgrounds
        Row(
          children: [
            _buildMinimalStatItem(
              context,
              'LEVEL',
              '$level',
              Icons.military_tech,
              AppTheme.accentGold,
            ),
            const SizedBox(width: AppSpacing.lg),
            _buildMinimalStatItem(
              context,
              'SESSIONS',
              '$totalSessions',
              Icons.fitness_center,
              AppTheme.primaryColor,
            ),
            const SizedBox(width: AppSpacing.lg),
            _buildMinimalStatItem(
              context,
              'WEEK',
              '$currentWeek',
              Icons.calendar_today,
              AppTheme.success,
            ),
            const SizedBox(width: AppSpacing.lg),
            _buildMinimalStatItem(
              context,
              'XP',
              '${appState.currentXP}',
              Icons.stars,
              AppTheme.extras,
            ),
          ],
        ),
      ],
    );
  }

  // 2025 Ultra-minimal stat item - no backgrounds, pure spacing + subtle glow
  Widget _buildMinimalStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          // Icon with subtle glow
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Value
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(
              fontSize: 36,
              color: color,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Label
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppTheme.tertiaryTextColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // =============================================================================
  // 2) TRAINING VOLUME SECTION
  // =============================================================================

  Widget _buildProgressOverTimeSection(BuildContext context, AppStateData appState) {
    // Get last 4 weeks of data
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    
    final recentEvents = appState.events
        .where((e) => 
            (e.type == ProgressEventType.sessionCompleted ||
             e.type == ProgressEventType.extraCompleted) &&
            e.ts.isAfter(fourWeeksAgo))
        .toList()
      ..sort((a, b) => a.ts.compareTo(b.ts));

    // Calculate metrics per week using ACTUAL session duration
    final weeklyData = <int, Map<String, int>>{};
    for (final event in recentEvents) {
      final weekNumber = ((now.difference(event.ts).inDays) / 7).floor();
      if (weekNumber >= 0 && weekNumber < 4) {
        final weekIndex = 3 - weekNumber;
        weeklyData[weekIndex] ??= {'total': 0, 'weight': 0, 'bodyweight': 0};
        
        // Get actual duration from event payload (in seconds), convert to minutes
        int durationMinutes;
        if (event.payload != null && event.payload!['duration'] != null) {
          final durationSeconds = event.payload!['duration'] as int;
          durationMinutes = (durationSeconds / 60).round();
        } else {
          // Fallback to estimates if no duration saved (old sessions)
          durationMinutes = event.type == ProgressEventType.sessionCompleted ? 45 : 20;
        }
        
        weeklyData[weekIndex]!['total'] = weeklyData[weekIndex]!['total']! + durationMinutes;
        
        // Split weight/bodyweight: ~55% weight training, 45% bodyweight/conditioning
        if (event.type == ProgressEventType.sessionCompleted) {
          weeklyData[weekIndex]!['weight'] = weeklyData[weekIndex]!['weight']! + (durationMinutes * 0.55).round();
          weeklyData[weekIndex]!['bodyweight'] = weeklyData[weekIndex]!['bodyweight']! + (durationMinutes * 0.45).round();
        } else {
          // Extras are typically bodyweight/conditioning
          weeklyData[weekIndex]!['bodyweight'] = weeklyData[weekIndex]!['bodyweight']! + durationMinutes;
        }
      }
    }

    final maxMinutes = weeklyData.values.isEmpty 
        ? 1 
        : weeklyData.values.map((d) => d['total']!).reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: AppSpacing.horizontalPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header - consistent style
          Row(
            children: [
              Icon(
                Icons.show_chart,
                color: AppTheme.primaryColor,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'TRAINING VOLUME',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppTheme.primaryColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Weekly bars - NO CONTAINER, just floating bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(4, (index) {
              final data = weeklyData[index];
              final totalMinutes = data?['total'] ?? 0;
              final weightMinutes = data?['weight'] ?? 0;
              final bodyweightMinutes = data?['bodyweight'] ?? 0;
              
              final fraction = maxMinutes > 0 ? totalMinutes / maxMinutes : 0.0;
              
              // Better week labels: "Week 1", "Week 2", "Week 3", "Now"
              final weekLabel = index == 3 ? 'Now' : 'Week ${4 - index}';

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      // Week label at TOP - consistent position
                      SizedBox(
                        height: 32, // Fixed height for alignment
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            weekLabel,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: index == 3 ? AppTheme.primaryColor : AppTheme.tertiaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      
                      // Total minutes
                      Text(
                        '$totalMinutes',
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: totalMinutes > 0 ? AppTheme.primaryColor : AppTheme.tertiaryTextColor,
                          fontSize: 20,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'MIN',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: totalMinutes > 0 ? AppTheme.primaryColor.withOpacity(0.7) : AppTheme.tertiaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      
                      // Floating bar with glow - NO BACKGROUND CONTAINER
                      Container(
                        height: 120,
                        alignment: Alignment.bottomCenter,
                        child: totalMinutes > 0 
                            ? FractionallySizedBox(
                                heightFactor: fraction.clamp(0.15, 1.0),
                                widthFactor: 1.0,
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppTheme.primaryColor.withOpacity(0.4),
                                        AppTheme.primaryColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                        blurRadius: 12,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      
                      // Split indicator at BOTTOM - consistent position
                      SizedBox(
                        height: 24, // Fixed height for alignment
                        child: totalMinutes > 0
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: AppTheme.inProgress,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '$weightMinutes',
                                    style: AppTextStyles.labelMicro.copyWith(
                                      color: AppTheme.inProgress,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: AppTheme.completed,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '$bodyweightMinutes',
                                    style: AppTextStyles.labelMicro.copyWith(
                                      color: AppTheme.completed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          
          // Legend - clean, no container
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.inProgress,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Weight Training',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.completed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Bodyweight/Conditioning',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),

          if (recentEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: Center(
                child: Text(
                  'Complete sessions to see your training volume',
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
              // Section Header - consistent style
              Row(
                children: [
                  Icon(
                    Icons.radar,
                    color: AppTheme.primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'PERFORMANCE PROFILE',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppTheme.primaryColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppTheme.tertiaryTextColor,
                    ),
                    onPressed: () => _showPerformanceProfileInfo(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
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
                // NO CONTAINER - just clean floating bars
                Column(
                  children: [
                    ...mainCategories.map((category) {
                        final progress = categoryProgress[category] ?? 0.0;
                        final color = _getCategoryColor(category);
                        final name = _getExerciseCategoryDisplayName(category);
                        final description = _getCategoryDescription(category);
                        
                        // Calculate total training volume
                        final totalProgress = mainCategories
                            .map((cat) => categoryProgress[cat] ?? 0.0)
                            .reduce((a, b) => a + b);
                        
                        // Calculate actual percentage of this category
                        final actualPercentage = totalProgress > 0 
                            ? (progress / totalProgress) * 100 
                            : 0.0;
                        
                        // Ideal hockey training distribution
                        final idealPercentage = _getIdealCategoryPercentage(category);
                        
                        // Show FOCUS if category is below 50% of its ideal target
                        // This scales properly for all categories (30% power needs 15%+, 10% agility needs 5%+)
                        final isFocusArea = totalProgress > 0 && 
                                           idealPercentage > 0 && 
                                           actualPercentage < (idealPercentage * 0.5);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              name.toUpperCase(),
                                              style: AppTextStyles.labelMedium.copyWith(
                                                color: AppTheme.secondaryTextColor,
                                              ),
                                            ),
                                            const SizedBox(width: AppSpacing.xs),
                                            if (isFocusArea)
                                              TweenAnimationBuilder<double>(
                                                duration: const Duration(milliseconds: 600),
                                                tween: Tween(begin: 0.0, end: 1.0),
                                                builder: (context, value, child) {
                                                  return Transform.scale(
                                                    scale: 0.8 + (0.2 * value),
                                                    child: Opacity(
                                                      opacity: value,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              AppTheme.accentGold.withOpacity(0.3),
                                                              AppTheme.accentGold.withOpacity(0.15),
                                                            ],
                                                          ),
                                                          borderRadius: BorderRadius.circular(6),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: AppTheme.accentGold.withOpacity(0.3 * value),
                                                              blurRadius: 12,
                                                              spreadRadius: -1,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Text(
                                                          'FOCUS',
                                                          style: AppTextStyles.labelMicro.copyWith(
                                                            color: AppTheme.accentGold,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          description,
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: AppTheme.tertiaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${actualPercentage.toStringAsFixed(0)}%',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                      Text(
                                        'of training',
                                        style: AppTextStyles.labelMicro.copyWith(
                                          color: AppTheme.tertiaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Stack(
                                children: [
                                  // Background bar with subtle glow
                                  Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  // Progress bar with glow effect - shows relative proportion
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeOutCubic,
                                    tween: Tween(begin: 0.0, end: actualPercentage / 100),
                                    builder: (context, value, child) {
                                      return FractionallySizedBox(
                                        widthFactor: value.clamp(0.02, 1.0),
                                        child: Container(
                                          height: 6,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.7),
                                                color,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(3),
                                            boxShadow: [
                                              BoxShadow(
                                                color: color.withOpacity(0.5),
                                                blurRadius: 8,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppTheme.primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'ACHIEVEMENTS',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppTheme.primaryColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                    _buildAchievementChip(
                      context,
                      '${appState.currentStreak}',
                      'Day Streak',
                      Icons.local_fire_department,
                      AppTheme.inProgress,
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
                      AppTheme.extras,
                    ),
                  ],
                ),
              ],
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
          style: AppTextStyles.labelSmall.copyWith(
            color: AppTheme.tertiaryTextColor,
            fontWeight: FontWeight.w600,
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
                'Each session is distributed proportionally across categories based on exercises completed. For example, a session with 6 Strength + 2 Power + 2 Conditioning = 60% Strength + 20% Power + 20% Conditioning.',
                style: AppTextStyles.small.copyWith(
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Compare your actual distribution to the ideal:',
                style: AppTextStyles.small.copyWith(
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Ideal hockey distribution:',
                style: AppTextStyles.small.copyWith(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '• Power: 30%\n'
                '• Strength: 25%\n'
                '• Speed: 20%\n'
                '• Conditioning: 15%\n'
                '• Agility: 10%',
                style: AppTextStyles.small.copyWith(
                  color: Colors.grey[300],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Categories marked as FOCUS are below 50% of their ideal target. Adjust your training to balance your profile over time.',
                style: AppTextStyles.small.copyWith(
                  color: AppTheme.secondaryTextColor,
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
        return AppTheme.inProgress;
      case ExerciseCategory.speed:
        return Colors.blue;
      case ExerciseCategory.agility:
        return AppTheme.completed;
      case ExerciseCategory.conditioning:
        return AppTheme.extras;
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

  String _getCategoryDescription(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.power:
        return 'Explosive skating & shooting';
      case ExerciseCategory.strength:
        return 'Foundation for injury prevention';
      case ExerciseCategory.speed:
        return 'Acceleration & transitions';
      case ExerciseCategory.conditioning:
        return 'Game stamina & endurance';
      case ExerciseCategory.agility:
        return 'Quick direction changes';
      case ExerciseCategory.technique:
        return 'Skill refinement';
      case ExerciseCategory.balance:
        return 'Stability & control';
      case ExerciseCategory.flexibility:
        return 'Mobility & recovery';
      case ExerciseCategory.warmup:
        return 'Preparation';
      case ExerciseCategory.recovery:
        return 'Rest & regeneration';
      case ExerciseCategory.stickSkills:
        return 'Puck handling';
      case ExerciseCategory.gameSituation:
        return 'Match simulation';
    }
  }

  /// Returns the ideal percentage for each category based on optimal hockey training distribution
  /// Total: Power 30%, Strength 25%, Speed 20%, Conditioning 15%, Agility 10%
  double _getIdealCategoryPercentage(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.power:
        return 30.0;
      case ExerciseCategory.strength:
        return 25.0;
      case ExerciseCategory.speed:
        return 20.0;
      case ExerciseCategory.conditioning:
        return 15.0;
      case ExerciseCategory.agility:
        return 10.0;
      default:
        return 0.0;
    }
  }
}
