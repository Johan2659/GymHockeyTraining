import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/selectors.dart';
import '../../application/app_state_provider.dart';

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

  Widget _buildProgressContent(BuildContext context, WidgetRef ref, AppStateData appState) {
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
          
          // Weekly Stats section - consistent width
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildWeeklyStatsSection(context, ref),
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity - consistent width
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildProgressTimelineSection(context, appState),
          ),
          
          const SizedBox(height: 16),
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
              color: AppTheme.accentColor.withValues(alpha: 0.2),
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
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
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

  Widget _buildPerformanceEvolutionSection(BuildContext context, WidgetRef ref) {
    return _PerformanceEvolutionWidget();
  }

  Widget _buildTrainingBalanceSection(BuildContext context, WidgetRef ref) {
    final categoryProgressAsync = ref.watch(categoryProgressProvider);
    
    // Optimal training distribution for hockey players (based on sport science)
    // Source: Hockey training periodization research
    final hockeyOptimalDistribution = {
      ExerciseCategory.strength: 25.0,      // Foundation for power and injury prevention
      ExerciseCategory.power: 30.0,         // Most critical for explosive skating and shooting
      ExerciseCategory.speed: 20.0,         // Essential for acceleration and transitions
      ExerciseCategory.conditioning: 15.0,  // Aerobic/anaerobic endurance for game stamina
      ExerciseCategory.agility: 10.0,       // Quick direction changes and edge work
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
            categoryPercentages[category] = (categoryValues[category]! / totalProgress) * 100;
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
        Color balanceColor;
        IconData balanceIcon;
        String balanceMessage;
        
        if (balanceScore >= 85) {
          balanceQuality = 'Elite Hockey Balance';
          balanceColor = Colors.green;
          balanceIcon = Icons.emoji_events;
          balanceMessage = 'Your training distribution is ideal for hockey performance!';
        } else if (balanceScore >= 70) {
          balanceQuality = 'Good Hockey Balance';
          balanceColor = Colors.lightGreen;
          balanceIcon = Icons.trending_up;
          balanceMessage = 'Solid distribution. Keep following your program!';
        } else if (balanceScore >= 50) {
          balanceQuality = 'Building Your Foundation';
          balanceColor = Colors.blue;
          balanceIcon = Icons.trending_up;
          balanceMessage = 'Your program is on track. Add extras to fine-tune specific areas.';
        } else if (totalProgress > 0) {
          balanceQuality = 'Early Progress';
          balanceColor = Colors.blue;
          balanceIcon = Icons.fitness_center;
          balanceMessage = 'Keep following your program. Balance will improve naturally!';
        } else {
          balanceQuality = 'Ready to Start';
          balanceColor = Colors.grey;
          balanceIcon = Icons.play_arrow;
          balanceMessage = 'Start your training program for optimal hockey development.';
        }
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.sports_hockey, color: AppTheme.accentColor, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Performance Profile',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showPerformanceProfileInfo(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Balance Score
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: balanceColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: balanceColor.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(balanceIcon, color: balanceColor, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  balanceQuality,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: balanceColor,
                                  ),
                                ),
                                Text(
                                  'Score: ${balanceScore.toInt()}/100',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: balanceColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: balanceScore / 100,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation(balanceColor),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        balanceMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: balanceColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Category Distribution with target comparison
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Training Mix',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showPerformanceProfileInfo(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Spider/Radar Chart with interactive labels
                Center(
                  child: CustomPaint(
                    size: const Size(280, 280),
                    painter: RadarChartPainter(
                      categories: mainCategories,
                      actualValues: categoryPercentages,
                      targetValues: hockeyOptimalDistribution,
                      getCategoryColor: _getCategoryColor,
                      getCategoryName: _getExerciseCategoryDisplayName,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Chart guide
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.amber, width: 2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Optimal Zone',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.amber[300],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 20,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.accentColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Your Profile',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                if (totalProgress == 0) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How It Works',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your training programs are already designed with optimal hockey balance. Follow your program and use Extras to target specific areas when needed!',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.blue,
                                ),
                              ),
                            ],
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

  Widget _buildMotivationalGuidance(
    BuildContext context,
    Map<ExerciseCategory, double> actual,
    Map<ExerciseCategory, double> optimal,
    List<ExerciseCategory> categories,
    double balanceScore,
  ) {
    // Find the category that needs the most focus
    ExerciseCategory? focusArea;
    double maxDeficit = 0;
    
    for (final category in categories) {
      final deficit = optimal[category]! - actual[category]!;
      if (deficit > maxDeficit && deficit > 5) {
        maxDeficit = deficit;
        focusArea = category;
      }
    }
    
    // Build the message
    String message;
    IconData icon;
    Color color;
    
    if (balanceScore >= 85) {
      // Excellent balance
      message = "Outstanding! Your training profile is dialed in. Keep crushing your program! 💪";
      icon = Icons.emoji_events;
      color = Colors.green;
    } else if (focusArea == null) {
      // Good balance, minor tweaks
      message = "Solid work! Your program is keeping you balanced. Stay consistent! 🔥";
      icon = Icons.trending_up;
      color = Colors.blue;
    } else {
      // Specific area to focus
      final categoryName = _getExerciseCategoryDisplayName(focusArea);
      final actionTip = _getFocusActionTip(focusArea);
      message = "You're doing great! To level up, try adding $categoryName Extras or choose bonus exercises when available. $actionTip 🚀";
      icon = Icons.lightbulb_outline;
      color = Colors.amber;
    }
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFocusActionTip(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.power:
        return 'Plyometrics and explosive lifts will boost your first stride!';
      case ExerciseCategory.strength:
        return 'Building your foundation protects you on the ice!';
      case ExerciseCategory.speed:
        return 'Sprint work translates directly to faster skating!';
      case ExerciseCategory.conditioning:
        return 'Your 3rd period performance will thank you!';
      case ExerciseCategory.agility:
        return 'Sharp edges win battles in the corners!';
      default:
        return 'Every session makes you better!';
    }
  }

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
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                    _buildProfileCategory(context, '⚡ Power', '30%', 'Explosive skating & shots', Colors.orange),
                    _buildProfileCategory(context, '💪 Strength', '25%', 'Foundation & injury prevention', Colors.red),
                    _buildProfileCategory(context, '🏃 Speed', '20%', 'Acceleration & transitions', Colors.blue),
                    _buildProfileCategory(context, '❤️ Conditioning', '15%', 'Stamina & endurance', Colors.pink),
                    _buildProfileCategory(context, '🔀 Agility', '10%', 'Edge work & quickness', Colors.purple),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // How to read it
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withOpacity(0.15),
                      Colors.amber.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.insights, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'How to read it',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildReadingTip(context, 'Dashed amber line', 'Optimal hockey profile'),
                    _buildReadingTip(context, 'Filled colored area', 'Your current training'),
                    _buildReadingTip(context, '✓ Checkmarks', 'You\'re on target!'),
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

  Widget _buildProfileCategory(BuildContext context, String title, String percentage, String description, Color color) {
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

  Widget _buildReadingTip(BuildContext context, String label, String description) {
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

  String _getCategoryDescription(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.power:
        return 'Explosive skating & powerful shots';
      case ExerciseCategory.strength:
        return 'Foundation for power & injury prevention';
      case ExerciseCategory.speed:
        return 'Acceleration & quick transitions';
      case ExerciseCategory.conditioning:
        return 'Game stamina & 3rd period endurance';
      case ExerciseCategory.agility:
        return 'Edge work & direction changes';
      default:
        return '';
    }
  }

  String _getRadarChartGuidance(
    Map<ExerciseCategory, double> actual,
    Map<ExerciseCategory, double> optimal,
    List<ExerciseCategory> categories,
  ) {
    // Find categories that need improvement (below target by >5%)
    final needsWork = <ExerciseCategory>[];
    
    for (final category in categories) {
      final deficit = optimal[category]! - actual[category]!;
      if (deficit > 5) {
        needsWork.add(category);
      }
    }
    
    if (needsWork.isEmpty) {
      return 'Great balance! Your profile is close to the optimal hockey zone.';
    } else if (needsWork.length == 1) {
      final category = needsWork.first;
      return 'Expand your ${_getExerciseCategoryDisplayName(category)} area to reach the optimal zone. Use Extras to target this!';
    } else {
      final names = needsWork.take(2).map((c) => _getExerciseCategoryDisplayName(c)).join(' and ');
      return 'Focus on expanding $names to match the optimal zone. Add Extras in these areas!';
    }
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

// Radar Chart Painter for Performance Profile
class RadarChartPainter extends CustomPainter {
  final List<ExerciseCategory> categories;
  final Map<ExerciseCategory, double> actualValues;
  final Map<ExerciseCategory, double> targetValues;
  final Color Function(ExerciseCategory) getCategoryColor;
  final String Function(ExerciseCategory) getCategoryName;

  RadarChartPainter({
    required this.categories,
    required this.actualValues,
    required this.targetValues,
    required this.getCategoryColor,
    required this.getCategoryName,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35; // Chart radius
    final maxValue = 35.0; // Max percentage for scaling (slightly above 30% max)
    
    // Draw grid circles (background levels)
    _drawGridCircles(canvas, center, radius);
    
    // Draw axes lines from center
    _drawAxes(canvas, center, radius);
    
    // Draw target polygon (outlined)
    _drawTargetPolygon(canvas, center, radius, maxValue);
    
    // Draw actual polygon (filled)
    _drawActualPolygon(canvas, center, radius, maxValue);
    
    // Draw labels
    _drawLabels(canvas, center, radius, size);
  }

  void _drawGridCircles(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw 3 concentric circles at 33%, 66%, 100%
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * (i / 3), paint);
    }
  }

  void _drawAxes(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 1;

    for (int i = 0; i < categories.length; i++) {
      final angle = _getAngleForIndex(i);
      final endPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, endPoint, paint);
    }
  }

  void _drawTargetPolygon(Canvas canvas, Offset center, double radius, double maxValue) {
    final path = Path();
    
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final value = targetValues[category] ?? 0.0;
      final angle = _getAngleForIndex(i);
      final distance = (value / maxValue) * radius;
      
      final point = Offset(
        center.dx + distance * cos(angle),
        center.dy + distance * sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    
    // Fill target zone with subtle color
    final fillPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
    
    // Draw dashed outline for target
    final dashedPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    _drawDashedPath(canvas, path, dashedPaint, dashWidth: 8, dashSpace: 5);
  }
  
  void _drawDashedPath(Canvas canvas, Path path, Paint paint, {required double dashWidth, required double dashSpace}) {
    final metric = path.computeMetrics().first;
    double distance = 0.0;
    
    while (distance < metric.length) {
      final start = metric.getTangentForOffset(distance)!.position;
      distance += dashWidth;
      final end = metric.getTangentForOffset(distance)!.position;
      canvas.drawLine(start, end, paint);
      distance += dashSpace;
    }
  }

  void _drawActualPolygon(Canvas canvas, Offset center, double radius, double maxValue) {
    final path = Path();
    
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final value = actualValues[category] ?? 0.0;
      final angle = _getAngleForIndex(i);
      final distance = (value / maxValue) * radius;
      
      final point = Offset(
        center.dx + distance * cos(angle),
        center.dy + distance * sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // Fill with gradient
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.primaryColor.withValues(alpha: 0.4),
          AppTheme.accentColor.withValues(alpha: 0.2),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Draw colored outline
    final outlinePaint = Paint()
      ..color = AppTheme.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(path, outlinePaint);

    // Draw points on vertices
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final value = actualValues[category] ?? 0.0;
      final angle = _getAngleForIndex(i);
      final distance = (value / maxValue) * radius;
      
      final point = Offset(
        center.dx + distance * cos(angle),
        center.dy + distance * sin(angle),
      );

      final pointPaint = Paint()
        ..color = getCategoryColor(category)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, 5, pointPaint);
      
      // White border around point
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(point, 5, borderPaint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius, Size size) {
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final angle = _getAngleForIndex(i);
      final labelDistance = radius + 35;
      final actualValue = actualValues[category] ?? 0.0;
      final targetValue = targetValues[category] ?? 0.0;
      final isOnTarget = (actualValue - targetValue).abs() < 5.0;
      
      final point = Offset(
        center.dx + labelDistance * cos(angle),
        center.dy + labelDistance * sin(angle),
      );

      // Draw category name
      final nameSpan = TextSpan(
        text: getCategoryName(category),
        style: TextStyle(
          color: getCategoryColor(category),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      );

      final namePainter = TextPainter(
        text: nameSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      namePainter.layout();

      // Position name
      final nameOffset = Offset(
        point.dx - namePainter.width / 2,
        point.dy - namePainter.height / 2 - 8,
      );

      namePainter.paint(canvas, nameOffset);
      
      // Draw percentage below name
      final percentSpan = TextSpan(
        text: '${actualValue.toInt()}%',
        style: TextStyle(
          color: getCategoryColor(category),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );

      final percentPainter = TextPainter(
        text: percentSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      percentPainter.layout();

      final percentOffset = Offset(
        point.dx - percentPainter.width / 2,
        point.dy - percentPainter.height / 2 + 8,
      );

      percentPainter.paint(canvas, percentOffset);
      
      // Draw status indicator (checkmark or arrow)
      final iconPaint = Paint()
        ..color = isOnTarget ? Colors.blue[300]! : 
          (actualValue > targetValue ? Colors.orange : Colors.red[300]!)
        ..style = PaintingStyle.fill;
      
      final iconCenter = Offset(
        point.dx + namePainter.width / 2 + 10,
        point.dy - 8,
      );
      
      if (isOnTarget) {
        // Draw checkmark circle
        canvas.drawCircle(iconCenter, 6, iconPaint);
        // Draw checkmark
        final checkPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        final checkPath = Path()
          ..moveTo(iconCenter.dx - 2, iconCenter.dy)
          ..lineTo(iconCenter.dx - 1, iconCenter.dy + 2)
          ..lineTo(iconCenter.dx + 2, iconCenter.dy - 2);
        canvas.drawPath(checkPath, checkPaint);
      }
    }
  }

  double _getAngleForIndex(int index) {
    // Start from top (-π/2) and go clockwise
    final angleStep = (2 * pi) / categories.length;
    return -pi / 2 + (index * angleStep);
  }

  @override
  bool shouldRepaint(RadarChartPainter oldDelegate) => true;
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
  final String period; // 'Week', 'Month', or 'Year' to format labels accordingly

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
    double minValue = dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    double maxValue = dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    
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
    final firstY = _valueToY(dataPoints[0].value, size.height, minValue, maxValue);
    
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
        final prevY = _valueToY(dataPoints[i - 1].value, size.height, minValue, maxValue);
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

  void _drawDataPoints(Canvas canvas, Size size, double minValue, double maxValue) {
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
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
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

  double _valueToY(double value, double height, double minValue, double maxValue) {
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
  @override
  State<_PerformanceEvolutionWidget> createState() => _PerformanceEvolutionWidgetState();
}

class _PerformanceEvolutionWidgetState extends State<_PerformanceEvolutionWidget> {
  String _selectedPeriod = 'Month'; // 'Week', 'Month', or 'Year'

  List<PerformanceDataPoint> _generatePerformanceData(String period) {
    final now = DateTime.now();
    
    switch (period) {
      case 'Week':
        // Last 7 days
        return List.generate(7, (index) {
          return PerformanceDataPoint(
            date: now.subtract(Duration(days: 6 - index)),
            value: 1500 + (index * 100) + (index * index * 10),
          );
        });
      
      case 'Month':
        // Last 8 weeks
        return List.generate(8, (index) {
          return PerformanceDataPoint(
            date: now.subtract(Duration(days: (7 - index) * 7)),
            value: 8000 + (index * 600) + (index * index * 50),
          );
        });
      
      case 'Year':
        // Last 12 months
        return List.generate(12, (index) {
          return PerformanceDataPoint(
            date: DateTime(now.year, now.month - (11 - index), 1),
            value: 30000 + (index * 2500) + (index * index * 200),
          );
        });
      
      default:
        return [];
    }
  }

  Widget _buildTimePeriodChip(String label, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[700]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceStatTile(
    BuildContext context,
    String label,
    String value,
    String change,
    IconData icon,
    Color color, {
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: isPositive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 11,
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBestLiftTile(
    BuildContext context,
    String exerciseName,
    String weight,
    String date,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                'Best Lift',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            weight,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            exerciseName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[300],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 10, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<PerformanceDataPoint> performanceData = _generatePerformanceData(_selectedPeriod);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: AppTheme.primaryColor, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Performance Evolution',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Track your strength gains over time',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stats summary
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceStatTile(
                    context,
                    'Total Volume',
                    '12.5K kg',
                    '+15%',
                    Icons.fitness_center,
                    Colors.blue,
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBestLiftTile(
                    context,
                    'Squat',
                    '125 kg',
                    'Nov 1, 2025',
                    Icons.military_tech,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Time period selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimePeriodChip('Week', isSelected: _selectedPeriod == 'Week'),
                const SizedBox(width: 8),
                _buildTimePeriodChip('Month', isSelected: _selectedPeriod == 'Month'),
                const SizedBox(width: 8),
                _buildTimePeriodChip('Year', isSelected: _selectedPeriod == 'Year'),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Performance graph
            SizedBox(
              height: 200,
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: PerformanceGraphPainter(
                  dataPoints: performanceData,
                  color: AppTheme.primaryColor,
                  bestLiftIndex: 5, // Index of the best lift in the data
                  bestLiftColor: Colors.amber,
                  period: _selectedPeriod, // Pass the selected period for label formatting
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}