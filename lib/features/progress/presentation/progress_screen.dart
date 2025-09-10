import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/selectors.dart';
import '../../application/app_state_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

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

  Widget _buildProgressContent(BuildContext context, WidgetRef ref, AppStateData appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header stats row
          Row(
            children: [
              Expanded(child: _buildXPCard(context, appState)),
              const SizedBox(width: 12),
              Expanded(child: _buildStreakCard(context, appState)),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Cycle completion
          _buildCycleProgressCard(context, appState),
          
          const SizedBox(height: 24),
          
          // Training Balance Stats section
          _buildTrainingBalanceSection(context, ref),
          
          const SizedBox(height: 24),
          
          // Weekly Stats section
          _buildWeeklyStatsSection(context, ref),
          
          const SizedBox(height: 24),
          
          // Weekly streak visualization
          _buildWeeklyStreakSection(context, appState),
          
          const SizedBox(height: 24),
          
          // Personal Records section
          _buildPersonalRecordsSection(context, appState),
          
          const SizedBox(height: 24),
          
          // Progress Timeline
          _buildProgressTimelineSection(context, appState),
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
                  color: Colors.green.withOpacity(0.2),
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
                  color: appState.currentStreak > 0 ? Colors.orange : Colors.grey,
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
                color: appState.currentStreak > 0 ? Colors.orange : Colors.grey,
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
                  color: Colors.orange.withOpacity(0.2),
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
                Icon(Icons.track_changes, color: AppTheme.primaryColor, size: 20),
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

  Widget _buildWeeklyStreakSection(BuildContext context, AppStateData appState) {
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

  Widget _buildWeeklyActivityChart(BuildContext context, AppStateData appState) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (index) => weekStart.add(Duration(days: index)));
    
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
                      color: hasActivity 
                          ? AppTheme.accentColor
                          : Colors.grey[700],
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
                      color: isToday ? AppTheme.primaryColor : Colors.grey[400],
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildPersonalRecordsSection(BuildContext context, AppStateData appState) {
    return Consumer(
      builder: (context, ref, child) {
        final personalBestsAsync = ref.watch(personalBestsProvider);
        
        return personalBestsAsync.when(
          data: (personalBests) => _buildPersonalRecordsContent(context, personalBests),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildPersonalRecordsContent(context, <String, PersonalBest>{}),
        );
      },
    );
  }

  Widget _buildPersonalRecordsContent(BuildContext context, Map<String, PersonalBest> personalBests) {
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
          (entry.value.unit == 'kg' || entry.value.unit == 'lbs' || entry.value.unit == 'reps')) {
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

  Widget _buildProgressTimelineSection(BuildContext context, AppStateData appState) {
    // Process events to combine session completions with their bonus challenges
    final combinedEvents = _processCombinedMilestones(appState.events);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (combinedEvents.isEmpty) ...[
          Card(
            child: Padding(
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
          ),
        ] else ...[
          Card(
            child: Column(
              children: [
                ...combinedEvents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final eventInfo = entry.value;
                  final isLast = index == combinedEvents.length - 1;
                  
                  return _buildCombinedTimelineItem(context, eventInfo, isLast);
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Combined timeline processing methods
  List<Map<String, dynamic>> _processCombinedMilestones(List<ProgressEvent> events) {
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
    combinedEvents.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    
    return combinedEvents.take(10).toList();
  }

  Widget _buildCombinedTimelineItem(BuildContext context, Map<String, dynamic> eventInfo, bool isLast) {
    if (eventInfo['type'] == 'session_with_bonus') {
      return _buildSessionWithBonusItem(context, eventInfo, isLast);
    } else {
      return _buildExtraItem(context, eventInfo, isLast);
    }
  }

  Widget _buildSessionWithBonusItem(BuildContext context, Map<String, dynamic> eventInfo, bool isLast) {
    final sessionEvent = eventInfo['sessionEvent'] as ProgressEvent;
    final bonusEvent = eventInfo['bonusEvent'] as ProgressEvent?;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
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
              color: AppTheme.accentColor.withOpacity(0.2),
            ),
            child: Icon(Icons.check_circle, color: AppTheme.accentColor, size: 20),
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
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

  Widget _buildExtraItem(BuildContext context, Map<String, dynamic> eventInfo, bool isLast) {
    final event = eventInfo['event'] as ProgressEvent;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
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
              color: Colors.purple.withOpacity(0.2),
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

  String _getSessionSubtitle(ProgressEvent sessionEvent, ProgressEvent? bonusEvent) {
    final parts = <String>[];
    
    if (sessionEvent.week > 0 || sessionEvent.session > 0) {
      parts.add('Week ${sessionEvent.week + 1}, Session ${sessionEvent.session + 1}');
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
    
    if (event.type == ProgressEventType.extraCompleted && event.payload?['xp_reward'] != null) {
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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

  Widget _buildTrainingBalanceSection(BuildContext context, WidgetRef ref) {
    final categoryProgressAsync = ref.watch(categoryProgressProvider);
    
    // Define the main training categories for balance calculation
    final mainCategories = [
      ExerciseCategory.strength,
      ExerciseCategory.power,
      ExerciseCategory.speed,
      ExerciseCategory.agility,
      ExerciseCategory.conditioning,
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
        
        // Calculate percentages (normalize to 100%)
        final categoryPercentages = <ExerciseCategory, double>{};
        if (totalProgress > 0) {
          for (final category in mainCategories) {
            categoryPercentages[category] = (categoryValues[category]! / totalProgress) * 100;
          }
        } else {
          // If no progress, show equal distribution
          for (final category in mainCategories) {
            categoryPercentages[category] = 20.0; // 100% / 5 categories
          }
        }
        
        // Calculate balance score (how close to equal distribution)
        final idealPercentage = 20.0; // 100% / 5 categories
        double balanceScore = 0.0;
        for (final category in mainCategories) {
          final deviation = (categoryPercentages[category]! - idealPercentage).abs();
          balanceScore += (20.0 - deviation) / 20.0; // Normalize to 0-1
        }
        balanceScore = (balanceScore / mainCategories.length) * 100; // Convert to percentage
        
        // Determine balance quality
        String balanceQuality;
        Color balanceColor;
        IconData balanceIcon;
        
        if (balanceScore >= 80) {
          balanceQuality = 'Excellent';
          balanceColor = Colors.green;
          balanceIcon = Icons.check_circle;
        } else if (balanceScore >= 60) {
          balanceQuality = 'Good';
          balanceColor = Colors.orange;
          balanceIcon = Icons.warning;
        } else {
          balanceQuality = 'Needs Improvement';
          balanceColor = Colors.red;
          balanceIcon = Icons.error;
        }
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Training Balance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Balance Score
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: balanceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: balanceColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(balanceIcon, color: balanceColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance Score: ${balanceScore.toInt()}%',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: balanceColor,
                              ),
                            ),
                            Text(
                              balanceQuality,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: balanceColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Category Distribution
                Text(
                  'Training Distribution',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                ...mainCategories.map((category) {
                  final percentage = categoryPercentages[category] ?? 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(category),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getExerciseCategoryDisplayName(category),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Text(
                          '${percentage.toInt()}%',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(category),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
                if (balanceScore < 80) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tip: Try to balance your training across all categories for optimal development',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
        if (weeklyStats == null) return const SizedBox.shrink();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20),
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
                        weeklyStats.totalSessions.toString(),
                        Icons.fitness_center,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatTile(
                        context,
                        'Exercises',
                        weeklyStats.totalExercises.toString(),
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
                        '${weeklyStats.totalTrainingTime}min',
                        Icons.timer,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatTile(
                        context,
                        'XP Earned',
                        '+${weeklyStats.xpEarned}',
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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

  Widget _buildPersonalBestCard(BuildContext context, PersonalBest personalBest) {
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
            color: iconColor.withOpacity(0.1),
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
                    personalBest.unit == 'kg' || personalBest.unit == 'lbs' ? 1 : 0
                  ),
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
