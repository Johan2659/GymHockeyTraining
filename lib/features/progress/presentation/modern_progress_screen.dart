import 'dart:math';

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
        title: const Text('Progress'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
      ),
      body: appStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading progress data',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
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
          // Performance Profile - consistent width
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
            child: _buildTrainingBalanceSection(context, ref),
          ),

          const SizedBox(height: 24),

          // Performance Evolution Graph - consistent width
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildPerformanceEvolutionSection(context, ref),
          ),

          const SizedBox(height: 24),

          // Activity Calendar - consistent width
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ActivityCalendarWidget(events: appState.events),
          ),

          // Extra bottom padding to clear the bottom navigation bar
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildXPCard(BuildContext context, AppStateData appState) {
    final level = Selectors.calculateLevel(appState.currentXP);
    final xpInCurrentLevel = appState.currentXP % Selectors.xpPerLevel;
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
              '${appState.currentXP} XP',
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
            if (appState.todayXP > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${appState.todayXP} today',
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

  Widget _buildStreakCard(BuildContext context, AppStateData appState) {
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
                  color:
                      appState.currentStreak > 0 ? Colors.orange : Colors.grey,
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
              '${appState.currentStreak} days',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: appState.currentStreak > 0
                        ? Colors.orange
                        : Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _getStreakMessage(appState.currentStreak),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
            if (appState.xpMultiplier > 1.0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${((appState.xpMultiplier - 1) * 100).toInt()}% XP Bonus',
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

  Widget _buildCycleProgressCard(BuildContext context, AppStateData appState) {
    final percentComplete = (appState.percentCycle * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.track_changes,
                    color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Current Program',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '$percentComplete%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (appState.activeProgram != null) ...[
              Text(
                appState.activeProgram!.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: appState.percentCycle,
                backgroundColor: Colors.grey[700],
                valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                _getCycleProgressMessage(appState.percentCycle),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
            ] else ...[
              Text(
                'No active program',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start a program to track your progress',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStreakSection(
      BuildContext context, AppStateData appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Activity',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildWeeklyActivityChart(context, appState),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyActivityChart(
      BuildContext context, AppStateData appState) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final days =
        List.generate(7, (index) => weekStart.add(Duration(days: index)));

    // Group events by day
    final eventsByDay = <String, int>{};
    for (final event in appState.events) {
      final dayKey = _formatDateKey(event.ts);
      eventsByDay[dayKey] = (eventsByDay[dayKey] ?? 0) + 1;
    }

    return Column(
      children: [
        Row(
          children: days.map((day) {
            final dayKey = _formatDateKey(day);
            final hasActivity = eventsByDay.containsKey(dayKey);
            final isToday = _formatDateKey(day) == _formatDateKey(now);

            return Expanded(
              child: Column(
                children: [
                  Text(
                    _formatWeekday(day),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                          fontSize: 10,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          hasActivity ? AppTheme.accentColor : Colors.grey[700],
                      border: isToday
                          ? Border.all(color: AppTheme.primaryColor, width: 2)
                          : null,
                    ),
                    child: hasActivity
                        ? Icon(
                            Icons.check,
                            color: AppTheme.backgroundColor,
                            size: 14,
                          )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isToday
                              ? AppTheme.primaryColor
                              : Colors.grey[400],
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPersonalRecordsSection(
      BuildContext context, AppStateData appState) {
    return Consumer(
      builder: (context, ref, child) {
        final personalBestsAsync = ref.watch(personalBestsProvider);

        return personalBestsAsync.when(
          data: (personalBests) =>
              _buildPersonalRecordsContent(context, personalBests),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              _buildPersonalRecordsContent(context, <String, PersonalBest>{}),
        );
      },
    );
  }

  Widget _buildPersonalRecordsContent(
      BuildContext context, Map<String, PersonalBest> personalBests) {
    // Priority exercises for display (motivational strength exercises)
    final priorityExercises = [
      'ex_squat',
      'ex_bench_press',
      'ex_deadlift',
      'ex_overhead_press',
      'ex_pull_ups',
      'ex_barbell_row',
      'ex_dumbbell_press',
      'ex_weighted_chin_ups',
    ];

    // Filter and sort personal bests by priority - focus on weight/performance metrics
    final displayBests = <String, PersonalBest>{};

    // First add priority exercises if they exist
    for (final exerciseId in priorityExercises) {
      if (personalBests.containsKey(exerciseId)) {
        final best = personalBests[exerciseId]!;
        // Only show exercises with meaningful performance metrics
        if (best.unit == 'kg' || best.unit == 'lbs' || best.unit == 'reps') {
          displayBests[exerciseId] = best;
        }
      }
    }

    // Then add other exercises with weight/performance metrics (excluding warmup/mobility)
    for (final entry in personalBests.entries) {
      if (!priorityExercises.contains(entry.key) &&
          (entry.value.unit == 'kg' ||
              entry.value.unit == 'lbs' ||
              entry.value.unit == 'reps')) {
        // Filter out non-performance oriented exercises
        final exerciseName = entry.value.exerciseName.toLowerCase();
        if (!exerciseName.contains('stretch') &&
            !exerciseName.contains('mobility') &&
            !exerciseName.contains('foam') &&
            !exerciseName.contains('warm')) {
          displayBests[entry.key] = entry.value;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Records',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (displayBests.isEmpty) ...[
          Card(
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
                      'No performance records yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[400],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete strength exercises to track your max lifts!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          ...displayBests.entries.take(5).map((entry) => _buildPersonalBestCard(
                context,
                entry.value,
              )),
        ],
      ],
    );
  }

  Widget _buildProgressTimelineSection(
      BuildContext context, AppStateData appState) {
    // Process events to combine session completions with their bonus challenges
    final combinedEvents = _processCombinedMilestones(appState.events);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with icon (same style as other sections)
            Row(
              children: [
                Icon(Icons.history, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (combinedEvents.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.timeline,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No milestones yet',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[400],
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete sessions and challenges to see your achievements here',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ...combinedEvents.asMap().entries.map((entry) {
                final index = entry.key;
                final eventInfo = entry.value;
                final isLast = index == combinedEvents.length - 1;

                return _buildCombinedTimelineItem(context, eventInfo, isLast);
              }),
            ],
          ],
        ),
      ),
    );
  }

  // Combined timeline processing methods
  List<Map<String, dynamic>> _processCombinedMilestones(
      List<ProgressEvent> events) {
    final milestoneEvents = events
        .where((event) =>
            event.type == ProgressEventType.sessionCompleted ||
            event.type == ProgressEventType.bonusDone ||
            event.type == ProgressEventType.extraCompleted)
        .toList();

    final combinedEvents = <Map<String, dynamic>>[];
    final processedBonuses = <ProgressEvent>{};

    for (final event in milestoneEvents) {
      if (event.type == ProgressEventType.sessionCompleted) {
        // Look for bonus challenge completed in the same session
        final matchingBonus = milestoneEvents
            .where((e) =>
                e.type == ProgressEventType.bonusDone &&
                e.programId == event.programId &&
                e.week == event.week &&
                e.session == event.session &&
                !processedBonuses.contains(e))
            .cast<ProgressEvent?>()
            .firstWhere((e) => e != null, orElse: () => null);

        combinedEvents.add({
          'type': 'session_with_bonus',
          'sessionEvent': event,
          'bonusEvent': matchingBonus,
          'timestamp': event.ts,
        });

        if (matchingBonus != null) {
          processedBonuses.add(matchingBonus);
        }
      } else if (event.type == ProgressEventType.extraCompleted) {
        // Extra challenges are always shown separately
        combinedEvents.add({
          'type': 'extra',
          'event': event,
          'timestamp': event.ts,
        });
      }
      // Skip standalone bonus events as they're combined with sessions
    }

    // Sort by timestamp (newest first)
    combinedEvents.sort((a, b) =>
        (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    return combinedEvents.take(10).toList();
  }

  Widget _buildCombinedTimelineItem(
      BuildContext context, Map<String, dynamic> eventInfo, bool isLast) {
    if (eventInfo['type'] == 'session_with_bonus') {
      return _buildSessionWithBonusItem(context, eventInfo, isLast);
    } else {
      return _buildExtraItem(context, eventInfo, isLast);
    }
  }

  Widget _buildSessionWithBonusItem(
      BuildContext context, Map<String, dynamic> eventInfo, bool isLast) {
    final sessionEvent = eventInfo['sessionEvent'] as ProgressEvent;
    final bonusEvent = eventInfo['bonusEvent'] as ProgressEvent?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
              ),
      ),
      child: Row(
        children: [
          // Main session icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentColor.withValues(alpha: 0.2),
            ),
            child:
                Icon(Icons.check_circle, color: AppTheme.accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Training Session Completed!',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (bonusEvent != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              'BONUS',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _getSessionSubtitle(sessionEvent, bonusEvent),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                      ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(sessionEvent.ts),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraItem(
      BuildContext context, Map<String, dynamic> eventInfo, bool isLast) {
    final event = eventInfo['event'] as ProgressEvent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple.withValues(alpha: 0.2),
            ),
            child: Icon(Icons.bolt, color: Colors.purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Extra Challenge Completed!',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  _getEventSubtitle(event),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                      ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(event.ts),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  String _getSessionSubtitle(
      ProgressEvent sessionEvent, ProgressEvent? bonusEvent) {
    final parts = <String>[];

    if (sessionEvent.week > 0 || sessionEvent.session > 0) {
      parts.add(
          'Week ${sessionEvent.week + 1}, Session ${sessionEvent.session + 1}');
    }

    if (bonusEvent != null) {
      parts.add('Bonus Challenge Completed');
    }

    return parts.join(' • ');
  }

  // Helper methods
  String _getStreakMessage(int streak) {
    if (streak == 0) return 'Start your streak today!';
    if (streak == 1) return 'Great start! Keep it going';
    if (streak < 7) return 'Building momentum';
    if (streak < 30) return 'Week streak achieved!';
    return 'Amazing dedication!';
  }

  String _getCycleProgressMessage(double progress) {
    if (progress < 0.25) return 'Just getting started';
    if (progress < 0.5) return 'Making good progress';
    if (progress < 0.75) return 'More than halfway there!';
    if (progress < 1.0) return 'Almost complete!';
    return 'Program completed!';
  }

  String _getEventSubtitle(ProgressEvent event) {
    final parts = <String>[];

    if (event.exerciseId != null) {
      parts.add(event.exerciseId!.replaceAll('_', ' ').toUpperCase());
    }

    if (event.week > 0 || event.session > 0) {
      parts.add('Week ${event.week + 1}, Session ${event.session + 1}');
    }

    if (event.type == ProgressEventType.extraCompleted &&
        event.payload?['xp_reward'] != null) {
      parts.add('+${event.payload!['xp_reward']} XP');
    }

    return parts.join(' • ');
  }

  // Date formatting helper methods
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatWeekday(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // =============================================================================
  // Performance Analytics Sections
  // =============================================================================

  Widget _buildPerformanceEvolutionSection(
      BuildContext context, WidgetRef ref) {
    final progressEventsAsync = ref.watch(progressEventsProvider);
    final analyticsAsync = ref.watch(performanceAnalyticsProvider);

    return progressEventsAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (events) {
        return analyticsAsync.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => const SizedBox.shrink(),
          data: (analytics) {
            final personalBests = analytics?.personalBests ?? {};

            // Calculate real-time stats from events
            final sessionEvents = events.where((e) => 
              e.type == ProgressEventType.sessionCompleted || 
              e.type == ProgressEventType.extraCompleted
            ).toList();

            final exerciseEvents = events.where((e) => 
              e.type == ProgressEventType.exerciseDone
            ).toList();

            // Always show the card, even with empty data
            return _PerformanceEvolutionWidget(
              sessionEvents: sessionEvents,
              exerciseEvents: exerciseEvents,
              personalBests: personalBests,
            );
          },
        );
      },
    );
  }

  Widget _buildTrainingBalanceSection(BuildContext context, WidgetRef ref) {
    final categoryProgressAsync = ref.watch(categoryProgressProvider);

    // Optimal training distribution for hockey players (based on sport science)
    // Source: Hockey training periodization research
    final hockeyOptimalDistribution = {
      ExerciseCategory.strength:
          25.0, // Foundation for power and injury prevention
      ExerciseCategory.power:
          30.0, // Most critical for explosive skating and shooting
      ExerciseCategory.speed:
          20.0, // Essential for acceleration and transitions
      ExerciseCategory.conditioning:
          15.0, // Aerobic/anaerobic endurance for game stamina
      ExerciseCategory.agility: 10.0, // Quick direction changes and edge work
    };

    final mainCategories = [
      ExerciseCategory.power,
      ExerciseCategory.strength,
      ExerciseCategory.speed,
      ExerciseCategory.conditioning,
      ExerciseCategory.agility,
    ];

    return categoryProgressAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (categoryProgress) {
        // Calculate the total progress across main categories
        double totalProgress = 0.0;
        final categoryValues = <ExerciseCategory, double>{};

        for (final category in mainCategories) {
          final progress = categoryProgress[category] ?? 0.0;
          categoryValues[category] = progress;
          totalProgress += progress;
        }

        // Calculate actual percentages
        final categoryPercentages = <ExerciseCategory, double>{};
        if (totalProgress > 0) {
          for (final category in mainCategories) {
            categoryPercentages[category] =
                (categoryValues[category]! / totalProgress) * 100;
          }
        } else {
          // If no progress, show 0%
          for (final category in mainCategories) {
            categoryPercentages[category] = 0.0;
          }
        }

        // Calculate hockey-specific balance score (how close to optimal distribution)
        double balanceScore = 0.0;
        double totalDeviation = 0.0;

        for (final category in mainCategories) {
          final actual = categoryPercentages[category]!;
          final optimal = hockeyOptimalDistribution[category]!;
          final deviation = (actual - optimal).abs();
          totalDeviation += deviation;
        }

        // Convert to a 0-100 score (lower deviation = higher score)
        // Max possible deviation is 200 (if all in one category)
        balanceScore = ((200 - totalDeviation) / 200) * 100;
        balanceScore = balanceScore.clamp(0, 100);

        // Determine balance quality for hockey performance
        String balanceQuality;

        if (balanceScore >= 85) {
          balanceQuality = 'Elite Hockey Balance';
        } else if (balanceScore >= 70) {
          balanceQuality = 'Good Hockey Balance';
        } else if (balanceScore >= 50) {
          balanceQuality = 'Building Your Foundation';
        } else if (totalProgress > 0) {
          balanceQuality = 'Early Progress';
        } else {
          balanceQuality = 'Ready to Start';
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.sports_hockey,
                        color: Colors.blue, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Performance Profile',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showPerformanceProfileInfo(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Simple, clean category breakdown (like Strava/WHOOP)
                _CategoryBreakdownWidget(
                  categories: mainCategories,
                  actualValues: categoryPercentages,
                  optimalValues: hockeyOptimalDistribution,
                  getCategoryColor: _getCategoryColor,
                  getCategoryName: _getExerciseCategoryDisplayName,
                  balanceScore: balanceScore,
                  balanceQuality: balanceQuality,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyStatsSection(BuildContext context, WidgetRef ref) {
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);

    return weeklyStatsAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (weeklyStats) {
        // Always show the section, even with empty data
        final stats = weeklyStats ?? const WeeklyStats(
          totalSessions: 0,
          totalExercises: 0,
          totalTrainingTime: 0,
          avgSessionDuration: 0.0,
          completionRate: 0.0,
          xpEarned: 0,
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'This Week',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        context,
                        'Sessions',
                        stats.totalSessions.toString(),
                        Icons.fitness_center,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatTile(
                        context,
                        'Exercises',
                        stats.totalExercises.toString(),
                        Icons.list_alt,
                        AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        context,
                        'Training Time',
                        '${stats.totalTrainingTime}min',
                        Icons.timer,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatTile(
                        context,
                        'XP Earned',
                        '+${stats.xpEarned}',
                        Icons.star,
                        Colors.amber,
                      ),
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

  Widget _buildStatTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  // =============================================================================
  // Helper Methods for Categories
  // =============================================================================

  void _showPerformanceProfileInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sports_hockey,
                      color: AppTheme.accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Performance Profile',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Explanation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What is this?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Performance Profile shows how balanced your training is across 5 key hockey areas:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[300],
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileCategory(context, '⚡ Power', '30%',
                        'Explosive skating & shots', Colors.orange),
                    _buildProfileCategory(context, '💪 Strength', '25%',
                        'Foundation & injury prevention', Colors.red),
                    _buildProfileCategory(context, '🏃 Speed', '20%',
                        'Acceleration & transitions', Colors.blue),
                    _buildProfileCategory(context, '❤️ Conditioning', '15%',
                        'Stamina & endurance', Colors.pink),
                    _buildProfileCategory(context, '🔀 Agility', '10%',
                        'Edge work & quickness', Colors.purple),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // How it works
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.15),
                      Colors.blue.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'How It Works',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your training programs are already designed with optimal hockey balance. Follow your program and use Extras to target specific areas when needed!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[300],
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Close button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Got it!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCategory(BuildContext context, String title,
      String percentage, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              percentage,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingTip(
      BuildContext context, String label, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.arrow_right, size: 16, color: Colors.amber[300]),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[300],
                    ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildPersonalBestCard(
      BuildContext context, PersonalBest personalBest) {
    IconData icon;
    Color iconColor;
    String subtitle;

    // Set icon, color and subtitle based on exercise type
    if (personalBest.unit == 'kg' || personalBest.unit == 'lbs') {
      icon = Icons.fitness_center;
      iconColor = Colors.orange;
      subtitle = 'Max Weight • ${_formatShortDate(personalBest.achievedAt)}';
    } else if (personalBest.unit == 'reps') {
      icon = Icons.repeat;
      iconColor = Colors.blue;
      subtitle = 'Max Reps • ${_formatShortDate(personalBest.achievedAt)}';
    } else {
      icon = Icons.timer;
      iconColor = Colors.green;
      subtitle = 'Best Time • ${_formatShortDate(personalBest.achievedAt)}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
        ),
        title: Text(
          personalBest.exerciseName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  personalBest.bestValue.toStringAsFixed(
                      personalBest.unit == 'kg' || personalBest.unit == 'lbs'
                          ? 1
                          : 0),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                ),
                const SizedBox(width: 4),
                Text(
                  personalBest.unit,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            if (personalBest.unit == 'kg' || personalBest.unit == 'lbs') ...[
              const SizedBox(height: 2),
              Text(
                'PR',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Category Breakdown Widget (Inspired by Strava, WHOOP, Strong)
// =============================================================================

class _CategoryBreakdownWidget extends StatefulWidget {
  final List<ExerciseCategory> categories;
  final Map<ExerciseCategory, double> actualValues;
  final Map<ExerciseCategory, double> optimalValues;
  final Color Function(ExerciseCategory) getCategoryColor;
  final String Function(ExerciseCategory) getCategoryName;
  final double balanceScore;
  final String balanceQuality;

  const _CategoryBreakdownWidget({
    required this.categories,
    required this.actualValues,
    required this.optimalValues,
    required this.getCategoryColor,
    required this.getCategoryName,
    required this.balanceScore,
    required this.balanceQuality,
  });

  @override
  State<_CategoryBreakdownWidget> createState() =>
      _CategoryBreakdownWidgetState();
}

class _CategoryBreakdownWidgetState extends State<_CategoryBreakdownWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get category icons
    String getCategoryIcon(ExerciseCategory category) {
      switch (category) {
        case ExerciseCategory.power:
          return '⚡';
        case ExerciseCategory.strength:
          return '💪';
        case ExerciseCategory.speed:
          return '⚡';
        case ExerciseCategory.conditioning:
          return '❤️';
        case ExerciseCategory.agility:
          return '✖️';
        case ExerciseCategory.technique:
          return '🎯';
        case ExerciseCategory.balance:
          return '⚖️';
        case ExerciseCategory.flexibility:
          return '🤸';
        case ExerciseCategory.warmup:
          return '🔥';
        case ExerciseCategory.recovery:
          return '🛀';
        default:
          return '🏒';
      }
    }

    // Get category descriptions
    String getCategoryDescription(ExerciseCategory category) {
      switch (category) {
        case ExerciseCategory.power:
          return 'Explosive skating & shots';
        case ExerciseCategory.strength:
          return 'Foundation & injury prevention';
        case ExerciseCategory.speed:
          return 'Acceleration & transitions';
        case ExerciseCategory.conditioning:
          return 'Stamina & endurance';
        case ExerciseCategory.agility:
          return 'Edge work & quickness';
        case ExerciseCategory.technique:
          return 'Skill & precision';
        case ExerciseCategory.balance:
          return 'Stability & control';
        case ExerciseCategory.flexibility:
          return 'Mobility & range';
        case ExerciseCategory.warmup:
          return 'Preparation & activation';
        case ExerciseCategory.recovery:
          return 'Rest & regeneration';
        default:
          return 'Training focus';
      }
    }

    // Calculate balance score color (yellow)
    final balanceColor = widget.balanceScore >= 70
        ? Colors.amber[400]!
        : widget.balanceScore >= 50
            ? Colors.amber[600]!
            : Colors.orange[600]!;

    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[900]!,
              Colors.grey[850]!,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[700]!,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance score header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BALANCE SCORE',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.balanceQuality,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: balanceColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: balanceColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.balanceScore.toInt()}',
                        style: TextStyle(
                          color: balanceColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Divider
              Container(
                height: 1,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 12),
              // Category stats - compact rows
              ...widget.categories.map((category) {
                final color = widget.getCategoryColor(category);
                final name = widget.getCategoryName(category);
                final optimal = widget.optimalValues[category] ?? 0.0;
                final actual = widget.actualValues[category] ?? 0.0;
                final icon = getCategoryIcon(category);
                final description = getCategoryDescription(category);
                final progress =
                    optimal > 0 ? (actual / optimal).clamp(0.0, 1.0) : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Icon - smaller
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                icon,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Category name and description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  description,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 10,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Stats - compact
                          Text(
                            '${actual.toInt()}%',
                            style: TextStyle(
                              color: color,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            ' / ${optimal.toInt()}%',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Progress bar - thinner
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.grey[850],
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
    );
  }
}

// =============================================================================
// Simple animated bar widget
// =============================================================================

class FractionallySizedBar extends StatelessWidget {
  final double fraction;
  final double animation;
  final double height;
  final Color color;
  final Color? borderColor;
  final double borderRadius;

  const FractionallySizedBar({
    super.key,
    required this.fraction,
    required this.animation,
    required this.height,
    required this.color,
    this.borderColor,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: (fraction * animation).clamp(0.0, 1.0),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.5)
              : null,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// =============================================================================
// Performance Evolution Graph
// =============================================================================

class PerformanceDataPoint {
  final DateTime date;
  final double value;

  PerformanceDataPoint({
    required this.date,
    required this.value,
  });
}

class PerformanceGraphPainter extends CustomPainter {
  final List<PerformanceDataPoint> dataPoints;
  final Color color;
  final int? bestLiftIndex; // Index of the best lift point
  final Color bestLiftColor;
  final String
      period; // 'Week', 'Month', or 'Year' to format labels accordingly

  PerformanceGraphPainter({
    required this.dataPoints,
    required this.color,
    this.bestLiftIndex,
    this.bestLiftColor = Colors.amber,
    this.period = 'Month',
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    // Find min and max values for scaling
    double minValue =
        dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    double maxValue =
        dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);

    // Add some padding to the range
    final valueRange = maxValue - minValue;
    minValue -= valueRange * 0.1;
    maxValue += valueRange * 0.1;

    // Draw grid lines
    _drawGrid(canvas, size, minValue, maxValue);

    // Draw the line graph
    _drawGraph(canvas, size, minValue, maxValue);

    // Draw data points
    _drawDataPoints(canvas, size, minValue, maxValue);

    // Draw labels
    _drawLabels(canvas, size, minValue, maxValue);
  }

  void _drawGrid(Canvas canvas, Size size, double minValue, double maxValue) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;

    // Draw horizontal grid lines (3 lines to match the labels)
    for (int i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  void _drawGraph(Canvas canvas, Size size, double minValue, double maxValue) {
    if (dataPoints.length < 2) return;

    final path = Path();
    final gradientPath = Path();

    // Calculate first point
    final firstX = 0.0;
    final firstY =
        _valueToY(dataPoints[0].value, size.height, minValue, maxValue);

    path.moveTo(firstX, firstY);
    gradientPath.moveTo(firstX, size.height);
    gradientPath.lineTo(firstX, firstY);

    // Draw smooth curve through points
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (size.width / (dataPoints.length - 1)) * i;
      final y = _valueToY(dataPoints[i].value, size.height, minValue, maxValue);

      if (i == 0) {
        path.moveTo(x, y);
        gradientPath.lineTo(x, y);
      } else {
        // Smooth curve using quadratic bezier
        final prevX = (size.width / (dataPoints.length - 1)) * (i - 1);
        final prevY =
            _valueToY(dataPoints[i - 1].value, size.height, minValue, maxValue);
        final cpX = (prevX + x) / 2;

        path.quadraticBezierTo(cpX, prevY, x, y);
        gradientPath.quadraticBezierTo(cpX, prevY, x, y);
      }
    }

    // Complete gradient path
    gradientPath.lineTo(size.width, size.height);
    gradientPath.close();

    // Draw gradient fill
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(gradientPath, gradientPaint);

    // Draw line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  void _drawDataPoints(
      Canvas canvas, Size size, double minValue, double maxValue) {
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (size.width / (dataPoints.length - 1)) * i;
      final y = _valueToY(dataPoints[i].value, size.height, minValue, maxValue);

      final isBestLift = bestLiftIndex != null && i == bestLiftIndex;

      if (isBestLift) {
        // Special marker for best lift - larger and gold colored

        // Outer glow
        final glowPaint = Paint()
          ..color = bestLiftColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 10, glowPaint);

        // Trophy/star background
        final bgPaint = Paint()
          ..color = bestLiftColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 7, bgPaint);

        // White border
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(Offset(x, y), 7, borderPaint);

        // Star icon in the center (simplified)
        final starPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        _drawStar(canvas, Offset(x, y), 4, starPaint);
      } else {
        // Regular data points
        // Outer circle (white)
        final outerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 5, outerPaint);

        // Inner circle (colored)
        final innerPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 3, innerPaint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    // Simple star shape
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * pi / 5) - pi / 2;
      final x = center.dx + size * cos(angle);
      final y = center.dy + size * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLabels(Canvas canvas, Size size, double minValue, double maxValue) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    // Draw date labels at the bottom (show first, middle, last)
    for (int i = 0; i < dataPoints.length; i++) {
      // Only show first, middle, and last labels to avoid clutter
      if (i == 0 || i == dataPoints.length ~/ 2 || i == dataPoints.length - 1) {
        final x = (size.width / (dataPoints.length - 1)) * i;
        final date = dataPoints[i].date;

        // Format label based on selected period
        String dateLabel;
        switch (period) {
          case 'Week':
            // Show "Nov 1" format for days
            dateLabel = '${monthNames[date.month - 1]} ${date.day}';
            break;
          case 'Month':
            // Show only month name for weeks/months
            dateLabel = monthNames[date.month - 1];
            break;
          case 'Year':
            // Show only year for yearly view
            dateLabel = '${date.year}';
            break;
          default:
            dateLabel = '${monthNames[date.month - 1]} ${date.day}';
        }

        final textSpan = TextSpan(
          text: dateLabel,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height + 8),
        );
      }
    }

    // Draw value labels on the left (show only 3 values: min, mid, max)
    for (int i = 0; i <= 2; i++) {
      final value = minValue + (maxValue - minValue) * (2 - i) / 2;
      final y = size.height * i / 2;

      // Format value in a friendly way
      String valueText;
      if (value >= 1000) {
        valueText = '${(value / 1000).toStringAsFixed(0)}K';
      } else {
        valueText = '${value.toInt()}';
      }

      final textSpan = TextSpan(
        text: valueText,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width - 8, y - textPainter.height / 2),
      );
    }
  }

  double _valueToY(
      double value, double height, double minValue, double maxValue) {
    final normalized = (value - minValue) / (maxValue - minValue);
    return height - (normalized * height);
  }

  @override
  bool shouldRepaint(PerformanceGraphPainter oldDelegate) {
    return dataPoints != oldDelegate.dataPoints;
  }
}

// =============================================================================
// Stateful Performance Evolution Widget
// =============================================================================

class _PerformanceEvolutionWidget extends StatefulWidget {
  const _PerformanceEvolutionWidget({
    required this.sessionEvents,
    required this.exerciseEvents,
    required this.personalBests,
  });

  final List<ProgressEvent> sessionEvents;
  final List<ProgressEvent> exerciseEvents;
  final Map<String, PersonalBest> personalBests;

  @override
  State<_PerformanceEvolutionWidget> createState() =>
      _PerformanceEvolutionWidgetState();
}

class _PerformanceEvolutionWidgetState
    extends State<_PerformanceEvolutionWidget> {
  String _selectedPeriod = 'Month'; // 'Week', 'Month', or 'Year'

  @override
  Widget build(BuildContext context) {
    // Get all available data
    final allSessions = widget.sessionEvents;
    final allBests = widget.personalBests;
    
    // Calculate period-specific stats
    final filteredSessions = _filterEventsByPeriod(allSessions, _selectedPeriod);
    
    // Separate program sessions from extras
    final programSessions = filteredSessions.where((e) => 
      e.type == ProgressEventType.sessionCompleted
    ).length;
    
    final extraSessions = filteredSessions.where((e) => 
      e.type == ProgressEventType.extraCompleted
    ).length;
    
    final totalSessions = filteredSessions.length;
    
    // Count completed programs (sessions at week 4, session 4 of a program)
    final completedPrograms = filteredSessions.where((e) => 
      e.type == ProgressEventType.sessionCompleted && 
      e.week == 4 && 
      e.session == 4
    ).length;
    
    // Calculate training time from event payloads
    // For events without duration, estimate based on typical session lengths
    int totalTrainingSeconds = 0;
    int programTrainingSeconds = 0;
    int extraTrainingSeconds = 0;
    int estimatedSessionCount = 0; // Track how many are estimated
    
    for (final event in filteredSessions) {
      int? durationFromPayload = event.payload?['duration'] as int?;
      
      // If no duration recorded, estimate based on session type
      int duration;
      if (durationFromPayload == null) {
        estimatedSessionCount++;
        if (event.type == ProgressEventType.sessionCompleted) {
          duration = 2400; // Estimate 40 minutes for program sessions
        } else {
          duration = 1800; // Estimate 30 minutes for extra sessions
        }
      } else {
        duration = durationFromPayload;
      }
      
      totalTrainingSeconds += duration;
      if (event.type == ProgressEventType.sessionCompleted) {
        programTrainingSeconds += duration;
      } else if (event.type == ProgressEventType.extraCompleted) {
        extraTrainingSeconds += duration;
      }
    }
    
    // Filter personal records by selected period
    final filteredBests = _filterPersonalBestsByPeriod(allBests.values.toList(), _selectedPeriod);
    
    // Get top 3 personal records (most recent)
    final sortedBests = filteredBests
      ..sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
    final top3Bests = sortedBests.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Training Stats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // Period Selector (Professional chip style)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildPeriodTab('Week', _selectedPeriod == 'Week'),
                  _buildPeriodTab('Month', _selectedPeriod == 'Month'),
                  _buildPeriodTab('Year', _selectedPeriod == 'Year'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Key Metrics Grid - Always show, even with zeros
            // First Row: Total Sessions & Programs
            Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Total Sessions',
                      totalSessions.toString(),
                      Icons.calendar_today,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Programs Done',
                      completedPrograms.toString(),
                      Icons.emoji_events,
                      Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Second Row: Program Sessions & Extras
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Program Training',
                      programSessions.toString(),
                      Icons.fitness_center,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Extra Training',
                      extraSessions.toString(),
                      Icons.add_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              
              // Training Time Section - Always show, even with zeros
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Training Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                    ),
                  ),
                  if (estimatedSessionCount > 0) ...[
                    const SizedBox(width: 6),
                    Tooltip(
                      message: '$estimatedSessionCount ${estimatedSessionCount == 1 ? 'session' : 'sessions'} estimated at typical duration',
                      child: Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              // Third Row: Training Time Stats
              Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Total Time',
                        _formatTrainingTime(totalTrainingSeconds),
                        Icons.timer,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Program Time',
                        _formatTrainingTime(programTrainingSeconds),
                        Icons.schedule,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Extra Time',
                        _formatTrainingTime(extraTrainingSeconds),
                        Icons.access_time,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Average time per session
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Avg/Session',
                        totalSessions > 0 
                          ? _formatTrainingTime(totalTrainingSeconds ~/ totalSessions)
                          : '0min',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
            const SizedBox(height: 16),

            // Personal Records Section - Always show
            Text(
              'Personal Records',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 12),
            
            // Show personal records or empty state
            if (top3Bests.isNotEmpty) ...[
              ...top3Bests.map((best) => _buildPersonalBestItem(best)),
            ] else
              // Empty state for personal records
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.grey[600],
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No personal records yet\nComplete exercises to set your first record!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalBestItem(PersonalBest best) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emoji_events, color: Colors.amber, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  best.exerciseName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(best.achievedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${best.bestValue.toStringAsFixed(best.unit == 'kg' ? 1 : 0)} ${best.unit}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  List<ProgressEvent> _filterEventsByPeriod(
    List<ProgressEvent> events,
    String period,
  ) {
    if (events.isEmpty) return [];
    
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (period) {
      case 'Week':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case 'Year':
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
      default:
        cutoffDate = now.subtract(const Duration(days: 30));
    }

    return events.where((event) => event.ts.isAfter(cutoffDate)).toList()
      ..sort((a, b) => a.ts.compareTo(b.ts));
  }

  List<PersonalBest> _filterPersonalBestsByPeriod(
    List<PersonalBest> bests,
    String period,
  ) {
    if (bests.isEmpty) return [];
    
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (period) {
      case 'Week':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case 'Year':
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
      default:
        cutoffDate = now.subtract(const Duration(days: 30));
    }

    return bests.where((best) => best.achievedAt.isAfter(cutoffDate)).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  String _formatTrainingTime(int seconds) {
    if (seconds == 0) return '0m';
    
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
