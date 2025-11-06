import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../application/app_state_provider.dart';
import '../../../core/utils/selectors.dart';
import '../../programs/presentation/program_management_dialog.dart';
import '../../auth/application/auth_controller.dart';

/// BEAST LEAGUE Dashboard - Hockey Gym V2
/// Modern, fluid design inspired by Fitbod × EA Sports × Apple Fitness

class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: appState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: AppSpacing.page,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.error.withOpacity(0.2),
                        AppTheme.error.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Error loading app state',
                  style: AppTextStyles.titleL,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () => ref.invalidate(appStateProvider),
                  child: Text(
                    'RETRY',
                    style: AppTextStyles.button,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (data) => _buildDashboard(context, ref, data),
      ),
    );
  }

  Widget _buildDashboard(
      BuildContext context, WidgetRef ref, AppStateData data) {
    final sessionInProgressAsync = ref.watch(sessionInProgressProvider);
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Powerful Beast League Header
          _buildBeastLeagueHeader(context, ref, data, userProfileAsync, weeklyStatsAsync),
          
          // Content with padding
          Padding(
            padding: AppSpacing.horizontalPage,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                
                // Unified Program Card (includes session in progress if exists)
          if (data.hasActiveProgram) ...[
            sessionInProgressAsync.when(
              data: (sessionInProgress) => _buildUnifiedProgramCard(
                context,
                ref,
                data,
                sessionInProgress,
              ),
              loading: () => _buildUnifiedProgramCard(context, ref, data, null),
              error: (_, __) =>
                  _buildUnifiedProgramCard(context, ref, data, null),
            ),
            const SizedBox(height: AppSpacing.xl),
          ] else ...[
            _buildNoProgramCard(context),
            const SizedBox(height: AppSpacing.xl),
          ],

          // XP Card (with integrated streak)
          _buildXPCard(context, data),
          
          // Thin separator line
          const SizedBox(height: AppSpacing.xl),
          const GradientDivider(),
          const SizedBox(height: AppSpacing.xl),

          // Tip of the Day
          _buildTipOfTheDay(context),
          
          const SizedBox(height: AppSpacing.xl),
          const GradientDivider(),
          const SizedBox(height: AppSpacing.xl),

          // Shortcut Cards
          _buildShortcutCards(context),
          
          const SizedBox(height: AppSpacing.xl),
          const GradientDivider(),
          const SizedBox(height: AppSpacing.xl),

          // Motivational Section
          _buildMotivationalSection(context, data),

          const SizedBox(height: 100), // Bottom padding for nav bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Powerful Beast League Header with XP bar and weekly stats
  Widget _buildBeastLeagueHeader(
    BuildContext context,
    WidgetRef ref,
    AppStateData data,
    AsyncValue<UserProfile?> userProfileAsync,
    AsyncValue<WeeklyStats?> weeklyStatsAsync,
  ) {
    final userProfile = userProfileAsync.valueOrNull;
    final weeklyStats = weeklyStatsAsync.valueOrNull;
    final userName = userProfile?.username.toUpperCase() ?? 'ATHLETE';
    
    final level = Selectors.calculateLevel(data.currentXP);
    final xpInCurrentLevel = data.currentXP % Selectors.xpPerLevel;
    final progressToNextLevel = xpInCurrentLevel / Selectors.xpPerLevel;
    final xpNeeded = Selectors.xpPerLevel - xpInCurrentLevel;
    
    final sessionsThisWeek = weeklyStats?.totalSessions ?? 0;
    
    // Motivational message based on weekly performance
    String weeklyMessage = _getWeeklyMotivationMessage(sessionsThisWeek);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Beast League Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vertical accent line - 2px like session_detail
                Container(
                  width: 2,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title - using theme text style
                      Text(
                        'BEAST LEAGUE',
                        style: AppTextStyles.titleL.copyWith(
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Welcome message - integrated
                      Row(
                        children: [
                          Text(
                            'Welcome back, ',
                            style: AppTextStyles.small.copyWith(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              userName,
                              style: AppTextStyles.small.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 14),
            
            // XP/Level and Streak - Integrated directly in header
            // Top row - Level, XP info and Streak
            Row(
              children: [
                // Level badge - Hockey puck style with primary color
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.2),
                        AppTheme.primaryColor.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$level',
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                // XP Progress Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${data.currentXP}',
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 20,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            ' / ${Selectors.xpPerLevel * (level + 1)}',
                            style: AppTextStyles.small.copyWith(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'XP',
                            style: AppTextStyles.labelXS.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Next level info - clean and simple
                      Row(
                        children: [
                          Text(
                            'NEXT LEVEL:',
                            style: AppTextStyles.labelXS.copyWith(
                              fontSize: 9,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$xpNeeded XP',
                            style: AppTextStyles.small.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFB89ECA),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Streak badge - Consecutive training weeks
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: data.currentStreak > 0 
                        ? Colors.orange.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    border: Border.all(
                      color: data.currentStreak > 0 
                          ? Colors.orange.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: data.currentStreak > 0 
                                ? Colors.orange 
                                : Colors.grey[600],
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${data.currentStreak}',
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 16,
                              color: data.currentStreak > 0 
                                  ? Colors.orange 
                                  : Colors.grey[600],
                              letterSpacing: -0.5,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'WEEK${data.currentStreak != 1 ? 'S' : ''}',
                        style: AppTextStyles.labelXS.copyWith(
                          fontSize: 8,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress bar - Modern slim design
            Stack(
              children: [
                // Background track
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Progress fill with gradient
                FractionallySizedBox(
                  widthFactor: progressToNextLevel,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8B5BBF),
                          const Color(0xFFB89ECA),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5BBF).withOpacity(0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Percentage indicator at the end
                if (progressToNextLevel > 0)
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.85 * progressToNextLevel - 16,
                    top: -18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5BBF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${(progressToNextLevel * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Milestone dots - Hockey themed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final milestone = (index + 1) * 0.2;
                final isPassed = progressToNextLevel >= milestone;
                return Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPassed 
                        ? const Color(0xFF8B5BBF) 
                        : Colors.grey[800],
                  ),
                );
              }),
            ),
            
            // Weekly Performance badge - only if sessions > 0
            if (sessionsThisWeek > 0) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  // Small dot indicator
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.success,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.success.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: Text(
                      weeklyMessage,
                      style: AppTextStyles.small.copyWith(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Minimal badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppTheme.success.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$sessionsThisWeek/7',
                      style: AppTextStyles.small.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            // Thin separator line at bottom
            const SizedBox(height: 20),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.primaryColor.withOpacity(0.15),
                    AppTheme.primaryColor.withOpacity(0.3),
                    AppTheme.primaryColor.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeeklyMotivationMessage(int sessionsThisWeek) {
    if (sessionsThisWeek == 0) {
      return 'Ready to dominate this week? Let\'s get started!';
    } else if (sessionsThisWeek == 1) {
      return 'Great start! 1 session down, keep the momentum going!';
    } else if (sessionsThisWeek == 2) {
      return 'Crushing it! 2 sessions this week. You\'re on fire! 🔥';
    } else if (sessionsThisWeek == 3) {
      return 'Impressive! 3 sessions completed. Beast mode activated!';
    } else if (sessionsThisWeek >= 4 && sessionsThisWeek < 7) {
      return 'Unstoppable! $sessionsThisWeek sessions this week. Champion mindset! 💪';
    } else {
      return 'LEGENDARY! $sessionsThisWeek sessions! You\'re a training machine! 🏆';
    }
  }


  void _showDiscardSessionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Session?'),
        content: const Text(
          'Are you sure you want to discard this session in progress? All unsaved progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(clearSessionInProgressActionProvider.future);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Session discarded'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text(
              'Discard',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Unified widget that shows current program with embedded session in progress
  Widget _buildUnifiedProgramCard(
    BuildContext context,
    WidgetRef ref,
    AppStateData data,
    SessionInProgress? sessionInProgress,
  ) {
    final currentWeek = (data.state?.currentWeek ?? 0) + 1;
    final currentSession = (data.state?.currentSession ?? 0) + 1;
    final hasSessionInProgress = sessionInProgress != null;

    return Container(
      child: Stack(
        children: [
          // Subtle left accent line - no container
          Positioned(
            left: 0,
            top: 8,
            bottom: 8,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.primaryColor.withOpacity(0.6),
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          
          // Content - no background box
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Program Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sports_hockey,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'CURRENT PROGRAM',
                                style: AppTextStyles.labelXS.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                              const Spacer(),
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Colors.grey[400],
                                  size: 20,
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
                                        Icon(Icons.stop_circle_outlined,
                                            color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text('Stop Program'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm + 4),
                          Text(
                            (data.activeProgram?.title ?? 'Unknown Program').toUpperCase(),
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          
                          // Progress bar with hockey style
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[850],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: data.percentCycle,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primaryColor,
                                          AppTheme.primaryColor.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm + 4),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'WEEK $currentWeek',
                                    style: AppTextStyles.small.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  Container(
                                    width: 3,
                                    height: 3,
                                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.primaryColor.withOpacity(0.5),
                                    ),
                                  ),
                                  Text(
                                    'SESSION $currentSession',
                                    style: AppTextStyles.small.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${(data.percentCycle * 100).toInt()}%',
                                style: AppTextStyles.titleL.copyWith(
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Session In Progress Banner (embedded)
                    if (hasSessionInProgress)
                      _buildSessionInProgressBanner(
                          context, ref, sessionInProgress, data),

                // Main CTA Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 16, 4),
                  child: hasSessionInProgress
                      ? _buildResumeSessionButton(context, sessionInProgress)
                      : _buildStartNextSessionButton(context, data),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Compact banner showing session in progress
  Widget _buildSessionInProgressBanner(
    BuildContext context,
    WidgetRef ref,
    SessionInProgress sessionInProgress,
    AppStateData data,
  ) {
    final timeSincePause =
        DateTime.now().difference(sessionInProgress.pausedAt);
    final hoursSincePause = timeSincePause.inHours;
    final minutesSincePause = timeSincePause.inMinutes;

    String timeAgoText;
    if (hoursSincePause > 24) {
      timeAgoText = '${(hoursSincePause / 24).floor()} days ago';
    } else if (hoursSincePause > 0) {
      timeAgoText = '$hoursSincePause hours ago';
    } else if (minutesSincePause > 0) {
      timeAgoText = '$minutesSincePause minutes ago';
    } else {
      timeAgoText = 'Just now';
    }

    final completedCount = sessionInProgress.completedExercises.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.md, AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.withOpacity(0.06),
              Colors.orange.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
          border: Border.all(
            color: Colors.orange.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon with subtle glow
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.orange.withOpacity(0.2),
                    Colors.orange.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.amber.shade200,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'IN PROGRESS',
                        style: AppTextStyles.labelXS.copyWith(
                          color: Colors.amber.shade200,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.withOpacity(0.5),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          'Paused $timeAgoText',
                          style: AppTextStyles.small.copyWith(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'WEEK ${sessionInProgress.week + 1}',
                        style: AppTextStyles.small.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[300],
                        ),
                      ),
                      Container(
                        width: 3,
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        'SESSION ${sessionInProgress.session + 1}',
                        style: AppTextStyles.small.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (completedCount > 0) ...[
              // Hockey puck badge style
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.success.withOpacity(0.2),
                      AppTheme.success.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: AppTheme.success,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$completedCount',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.success,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => _showDiscardSessionDialog(context, ref),
              color: Colors.grey[400],
              tooltip: 'Discard session',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  /// Resume session button
  Widget _buildResumeSessionButton(
    BuildContext context,
    SessionInProgress sessionInProgress,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          context.go(
              '/session/${sessionInProgress.programId}/${sessionInProgress.week}/${sessionInProgress.session}/play');
        },
        icon: const Icon(Icons.play_arrow, size: 22),
        label: Text(
          'RESUME SESSION',
          style: AppTextStyles.button.copyWith(
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  /// Start next session button
  Widget _buildStartNextSessionButton(BuildContext context, AppStateData data) {
    final isSessionAvailable = data.nextSession != null;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isSessionAvailable
            ? () {
                final programId = data.state?.activeProgramId ?? '';
                final week = data.state?.currentWeek ?? 0;
                final session = data.state?.currentSession ?? 0;
                context.go('/session/$programId/$week/$session');
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSessionAvailable ? AppTheme.primaryColor : Colors.grey[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey[800],
          disabledForegroundColor: Colors.grey[600],
        ),
        icon: Icon(
          isSessionAvailable ? Icons.sports_hockey : Icons.emoji_events,
          size: 22,
        ),
        label: Text(
          isSessionAvailable ? 'START NEXT SESSION' : 'PROGRAM COMPLETE',
          style: AppTextStyles.button.copyWith(
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget _buildNoProgramCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
      child: Center(
        child: Column(
          children: [
            // Icon with subtle glow - no box
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.15),
                    AppTheme.primaryColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.sports_hockey,
                size: 56,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'READY TO START TRAINING?',
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            Text(
              'Choose a training program that matches your hockey position and goals.',
              style: AppTextStyles.body.copyWith(
                fontSize: 15,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            
            // Accent line
            Container(
              height: 1,
              width: 80,
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.primaryColor.withOpacity(0.5),
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/programs'),
                child: Text(
                  'CHOOSE YOUR PROGRAM',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
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

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.04),
            AppTheme.primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.star, color: AppTheme.accentColor, size: 18),
              const SizedBox(width: 6),
              Text(
                'LEVEL $level',
                style: AppTextStyles.labelXS.copyWith(
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          
          // XP Value
          Text(
            '${data.currentXP}',
            style: AppTextStyles.statValue.copyWith(
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'EXPERIENCE POINTS',
            style: AppTextStyles.labelXS,
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progressToNextLevel,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentColor,
                          AppTheme.accentColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${Selectors.xpPerLevel - xpInCurrentLevel} XP to Level ${level + 1}',
            style: AppTextStyles.small.copyWith(
              color: Colors.grey[400],
            ),
          ),
          if (data.todayXP > 0) ...[
            const SizedBox(height: AppSpacing.sm + 2),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '+${data.todayXP} TODAY',
                  style: AppTextStyles.small.copyWith(
                    color: AppTheme.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, AppStateData data) {
    final hasStreak = data.currentStreak > 0;
    final streakColor = hasStreak ? Colors.orange : Colors.grey[600]!;
    
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.04),
            AppTheme.primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: streakColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'STREAK',
                style: AppTextStyles.labelXS.copyWith(
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          
          // Streak Value
          Text(
            '${data.currentStreak}',
            style: AppTextStyles.statValue.copyWith(
              fontSize: 32,
              color: hasStreak ? Colors.orange : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'DAYS',
            style: AppTextStyles.labelXS,
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          
          Text(
            _getStreakMessage(data.currentStreak),
            style: AppTextStyles.small.copyWith(
              color: Colors.grey[400],
            ),
          ),
          if (data.xpMultiplier > 1.0) ...[
            const SizedBox(height: AppSpacing.sm + 2),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '+${((data.xpMultiplier - 1) * 100).toInt()}% XP BONUS',
                  style: AppTextStyles.small.copyWith(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ],
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
        Row(
          children: [
            Container(
              width: 2,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Text(
              'QUICK ACTIONS',
              style: AppTextStyles.subtitle,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildShortcutCard(
                context,
                'EXPRESS WORKOUT',
                Icons.flash_on,
                Colors.orange,
                () => context.go('/extras'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildShortcutCard(
                context,
                'TRAINING FOCUS',
                Icons.gps_fixed,
                AppTheme.primaryColor,
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.06),
            color.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
            child: Column(
              children: [
                // Icon with subtle glow
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: AppSpacing.sm + 4),
                Text(
                  title,
                  style: AppTextStyles.small.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
        Row(
          children: [
            Container(
              width: 2,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Text(
              'MOTIVATION',
              style: AppTextStyles.subtitle,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.04),
                AppTheme.primaryColor.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.15),
                      AppTheme.primaryColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.psychology,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[300],
                    fontStyle: FontStyle.italic,
                  ),
                  softWrap: true,
                ),
              ),
            ],
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

  Widget _buildTipOfTheDay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.06),
            Colors.blue.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
        border: Border.all(
          color: Colors.blue.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.blue.withOpacity(0.2),
                  Colors.blue.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(
              Icons.tips_and_updates,
              color: Colors.blue.shade300,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIP OF THE DAY',
                  style: AppTextStyles.labelXS.copyWith(
                    color: Colors.blue.shade300,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getTipOfTheDay(),
                  style: AppTextStyles.small.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTipOfTheDay() {
    final tips = [
      'Add Power Extras for explosive first strides. Plyometrics and jump training translate directly to faster acceleration on ice!',
      'Boost your Strength with compound lift Extras. A strong foundation reduces injury risk and improves overall performance.',
      'Include Speed Extras for better acceleration. Sprint intervals improve your ability to win races to loose pucks.',
      'Use Conditioning Extras to dominate the 3rd period. Better endurance means maintaining your speed when opponents are tired.',
      'Try Agility Extras to sharpen your edge work. Quick direction changes are crucial for tight turns and defensive maneuvers.',
      'Power training builds the explosive strength needed for powerful slap shots and quick one-timers.',
      'Consistent Strength work protects your joints during physical play and board battles.',
      'Speed training improves your straight-line skating, perfect for breakaways and backchecking.',
      'Conditioning work helps you maintain high performance across all three periods of intense play.',
      'Agility training enhances your ability to evade checks and create space in tight situations.',
      'Use Extras strategically to target areas where you want to excel on the ice.',
      'Balance your training for well-rounded development, but don\'t be afraid to specialize in your strengths!',
      'Recovery is training too. Listen to your body and use rest days wisely.',
      'Consistency beats intensity. Regular training sessions yield better results than sporadic intense workouts.',
      'Pre-game nutrition matters. Fuel your body 2-3 hours before training for optimal performance.',
      'Hydration is key. Drink water throughout the day, not just during training.',
      'Quality sleep enhances recovery. Aim for 8+ hours to maximize your training gains.',
      'Mental preparation is as important as physical training. Visualize your success on the ice.',
      'Progressive overload drives improvement. Gradually increase intensity over time.',
      'Mix up your training to avoid plateaus. Your body adapts when you challenge it in new ways.',
    ];

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % tips.length;
    return tips[index];
  }

  /// Shows the stop program dialog
  void _showStopProgramDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProgramManagementDialog(),
    );
  }
}
