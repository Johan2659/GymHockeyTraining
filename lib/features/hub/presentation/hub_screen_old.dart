import 'dart:ui';
import 'dart:math' as math;
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
/// Completely rewritten for 2025 pro gym/gaming aesthetic

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
          // Hero Header with BEAST LEAGUE title
          _buildBeastLeagueHeroHeader(context, ref, data, userProfileAsync),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Level + XP Ring (glassmorphism hero section)
          Padding(
            padding: AppSpacing.horizontalPage,
            child: _buildLevelRingSection(context, data),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Current Program Section
          Padding(
            padding: AppSpacing.horizontalPage,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.hasActiveProgram) ...[
                  sessionInProgressAsync.when(
                    data: (sessionInProgress) => _buildCurrentProgramSection(
                      context,
                      ref,
                      data,
                      sessionInProgress,
                    ),
                    loading: () => _buildCurrentProgramSection(context, ref, data, null),
                    error: (_, __) =>
                        _buildCurrentProgramSection(context, ref, data, null),
                  ),
                ] else ...[
                  _buildNoProgramState(context),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Thin gradient divider
          Padding(
            padding: AppSpacing.horizontalPage,
            child: const GradientDivider(margin: EdgeInsets.zero),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Quick Stats Strip
          Padding(
            padding: AppSpacing.horizontalPage,
            child: _buildQuickStatsStrip(context, data, weeklyStatsAsync),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          Padding(
            padding: AppSpacing.horizontalPage,
            child: const GradientDivider(margin: EdgeInsets.zero),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Quick Actions
          Padding(
            padding: AppSpacing.horizontalPage,
            child: _buildQuickActions(context),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          Padding(
            padding: AppSpacing.horizontalPage,
            child: const GradientDivider(margin: EdgeInsets.zero),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Motivational Section
          Padding(
            padding: AppSpacing.horizontalPage,
            child: _buildMotivationalSection(context, data),
          ),

          const SizedBox(height: 100), // Bottom padding for nav bar
        ],
      ),
    );
  }

  /// HERO HEADER - BEAST LEAGUE
  /// Full width hero section with title, welcome, and background effects
  Widget _buildBeastLeagueHeroHeader(
    BuildContext context,
    WidgetRef ref,
    AppStateData data,
    AsyncValue<UserProfile?> userProfileAsync,
  ) {
    final userProfile = userProfileAsync.valueOrNull;
    final userName = userProfile?.username.toUpperCase() ?? 'ATHLETE';

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          // Subtle background gradient blobs (ice dust effect)
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.08),
                    AppTheme.primaryColor.withOpacity(0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentGold.withOpacity(0.05),
                    AppTheme.accentGold.withOpacity(0.01),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with accent line
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vertical accent line (2px gradient)
                    Container(
                      width: 2,
                      height: 40,
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
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // BEAST LEAGUE title
                          Text(
                            'BEAST LEAGUE',
                            style: AppTextStyles.titleXL,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          // Welcome back subtitle
                          Row(
                            children: [
                              Text(
                                'Welcome back, ',
                                style: AppTextStyles.buttonSmall.copyWith(
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  userName,
                                  style: AppTextStyles.buttonSmall.copyWith(
                                    fontWeight: FontWeight.bold,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// LEVEL RING WIDGET + STREAK BADGE
  /// Single glassmorphism hero block with animated XP ring
  Widget _buildLevelRingSection(BuildContext context, AppStateData data) {
    final level = Selectors.calculateLevel(data.currentXP);
    final xpInCurrentLevel = data.currentXP % Selectors.xpPerLevel;
    final totalXPForNextLevel = Selectors.xpPerLevel;
    final xpNeeded = totalXPForNextLevel - xpInCurrentLevel;
    final progressToNextLevel = xpInCurrentLevel / totalXPForNextLevel;
    final rankName = _mapLevelToRank(level);

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // Animated XP Ring
          _LevelRingWidget(
            level: level,
            progress: progressToNextLevel,
            size: 100,
          ),
          
          const SizedBox(width: AppSpacing.lg),
          
          // Text info + Streak badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level and XP line
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'LEVEL $level',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      '  –  ${data.currentXP} XP',
                      style: AppTextStyles.buttonSmall.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xs),
                
                // XP to next rank
                Text(
                  '$xpNeeded XP TO NEXT RANK: $rankName',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.grey500,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Streak Badge (inline)
                _StreakBadgeWidget(streak: data.currentStreak),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Map level to cool hockey/gym rank names
  String _mapLevelToRank(int level) {
    if (level < 5) return 'ICE ROOKIE';
    if (level < 10) return 'ICE WARRIOR';
    if (level < 20) return 'STORM BREAKER';
    if (level < 30) return 'GLACIER TITAN';
    if (level < 50) return 'FROST LEGEND';
    return 'APEX BEAST';
  }

  /// CURRENT PROGRAM SECTION
  /// Full width, fluid layout with left accent line
  Widget _buildCurrentProgramSection(
    BuildContext context,
    WidgetRef ref,
    AppStateData data,
    SessionInProgress? sessionInProgress,
  ) {
    final currentWeek = (data.state?.currentWeek ?? 0) + 1;
    final currentSession = (data.state?.currentSession ?? 0) + 1;
    final hasSessionInProgress = sessionInProgress != null;
    final programName = (data.activeProgram?.title ?? 'Unknown Program').toUpperCase();
    
    // Infer role from program name (simple heuristic)
    String role = 'HOCKEY';
    if (programName.contains('ATTACKER') || programName.contains('FORWARD')) {
      role = 'ATTACKER';
    } else if (programName.contains('DEFENSE')) {
      role = 'DEFENSE';
    } else if (programName.contains('GOALIE')) {
      role = 'GOALIE';
    }

    return Stack(
      children: [
        // Left accent line (2px gradient)
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
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
        
        // Content
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Row(
                children: [
                  Icon(
                    Icons.sports_hockey,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'CURRENT PROGRAM',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppTheme.secondaryTextColor,
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
              
              const SizedBox(height: AppSpacing.sm),
              
              // Thin horizontal divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primaryColor.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Program name + role chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      programName,
                      style: AppTextStyles.headlineSmall,
                    ),
                  ),
                  // Role chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 2,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      role,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Progress info row
              Row(
                children: [
                  Text(
                    'WEEK $currentWeek',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondaryTextColor,
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
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(data.percentCycle * 100).toInt()}%',
                    style: AppTextStyles.titleL.copyWith(
                      
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Progress bar
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
              
              const SizedBox(height: AppSpacing.lg),
              
              // Session in progress banner (if exists)
              if (hasSessionInProgress)
                _buildSessionInProgressBanner(context, ref, sessionInProgress, data),
              
              if (hasSessionInProgress)
                const SizedBox(height: AppSpacing.md),
              
              // Main CTA button
              _buildProgramActionButton(context, data, hasSessionInProgress, sessionInProgress),
            ],
          ),
        ),
      ],
    );
  }

  /// Session in progress banner
  Widget _buildSessionInProgressBanner(
    BuildContext context,
    WidgetRef ref,
    SessionInProgress sessionInProgress,
    AppStateData data,
  ) {
    final timeSincePause = DateTime.now().difference(sessionInProgress.pausedAt);
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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.08),
            Colors.orange.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.orange.withOpacity(0.25),
                  Colors.orange.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(
              Icons.play_circle_filled,
              color: AppTheme.bonus.withOpacity(0.3),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'IN PROGRESS',
                      style: AppTextStyles.labelMicro.copyWith(
                        color: AppTheme.bonus.withOpacity(0.3),
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
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (completedCount > 0)
                  Text(
                    '$completedCount exercises completed',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.success,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => _showDiscardSessionDialog(context, ref),
            color: AppTheme.secondaryTextColor,
            tooltip: 'Discard session',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Program action button (resume or start next)
  Widget _buildProgramActionButton(
    BuildContext context,
    AppStateData data,
    bool hasSessionInProgress,
    SessionInProgress? sessionInProgress,
  ) {
    if (hasSessionInProgress && sessionInProgress != null) {
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
            style: AppTextStyles.button,
          ),
        ),
      );
    }

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
          backgroundColor: isSessionAvailable ? AppTheme.primaryColor : AppTheme.grey800,
          foregroundColor: AppTheme.onPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: AppTheme.grey800,
          disabledForegroundColor: AppTheme.grey600,
        ),
        icon: Icon(
          isSessionAvailable ? Icons.sports_hockey : Icons.emoji_events,
          size: 22,
        ),
        label: Text(
          isSessionAvailable ? 'START NEXT SESSION' : 'PROGRAM COMPLETE',
          style: AppTextStyles.button,
        ),
      ),
    );
  }

  /// No program state
  Widget _buildNoProgramState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),
        
        // Icon with glow
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.2),
                AppTheme.primaryColor.withOpacity(0.08),
                Colors.transparent,
              ],
            ),
          ),
          child: Icon(
            Icons.sports_hockey,
            size: 64,
            color: AppTheme.primaryColor,
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        Text(
          'READY TO START TRAINING?',
          style: AppTextStyles.subtitle.copyWith(
            
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        Text(
          'Choose a training program that matches your hockey position and goals.',
          style: AppTextStyles.body.copyWith(
            
            color: AppTheme.secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Accent line
        Container(
          height: 1,
          width: 80,
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
        
        const SizedBox(height: AppSpacing.lg),
        
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go('/programs'),
            child: Text(
              'CHOOSE YOUR PROGRAM',
              style: AppTextStyles.button,
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  /// QUICK STATS STRIP
  /// Single row with stats, separated by thin vertical dividers
  Widget _buildQuickStatsStrip(
    BuildContext context,
    AppStateData data,
    AsyncValue<WeeklyStats?> weeklyStatsAsync,
  ) {
    final weeklyStats = weeklyStatsAsync.valueOrNull;
    final sessionsThisWeek = weeklyStats?.totalSessions ?? 0;
    final totalMinutes = weeklyStats?.totalTrainingTime ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.insights,
              color: AppTheme.primaryColor,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'THIS WEEK',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Stats row
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Sessions stat
              Expanded(
                child: _StatItem(
                  icon: Icons.fitness_center,
                  value: '$sessionsThisWeek',
                  label: 'SESSIONS',
                ),
              ),
              
              // Vertical divider
              Container(
                width: 1,
                height: 40,
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
              ),
              
              // Time stat
              Expanded(
                child: _StatItem(
                  icon: Icons.timer,
                  value: '${totalMinutes}m',
                  label: 'TIME',
                ),
              ),
              
              // Vertical divider
              Container(
                width: 1,
                height: 40,
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
              ),
              
              // Streak stat
              Expanded(
                child: _StatItem(
                  icon: Icons.local_fire_department,
                  value: '${data.currentStreak}',
                  label: 'STREAK',
                  valueColor: data.currentStreak > 0 ? Colors.orange : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// QUICK ACTIONS
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.flash_on,
              color: AppTheme.primaryColor,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'QUICK ACTIONS',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'EXPRESS\nWORKOUT',
                icon: Icons.flash_on,
                color: Colors.orange,
                onTap: () => context.go('/extras'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                title: 'TRAINING\nFOCUS',
                icon: Icons.gps_fixed,
                color: AppTheme.primaryColor,
                onTap: () => context.go('/extras'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// MOTIVATIONAL SECTION
  Widget _buildMotivationalSection(BuildContext context, AppStateData data) {
    final message = _getMotivationalMessage(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.psychology,
              color: AppTheme.primaryColor,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'DAILY MOTIVATION',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.06),
                AppTheme.primaryColor.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.2),
                      AppTheme.primaryColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.format_quote,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.grey300,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
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

  void _showStopProgramDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProgramManagementDialog(),
    );
  }
}

// ============================================================================
// EXTRACTED WIDGETS
// ============================================================================

/// LEVEL RING WIDGET
/// Animated circular progress ring with level in center
class _LevelRingWidget extends StatelessWidget {
  final int level;
  final double progress;
  final double size;

  const _LevelRingWidget({
    required this.level,
    required this.progress,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[850],
                  valueColor: AlwaysStoppedAnimation(AppTheme.grey850),
                ),
              ),
              
              // Progress ring with gradient
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _GradientRingPainter(
                    progress: animatedProgress,
                    strokeWidth: 6,
                  ),
                ),
              ),
              
              // Level number
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$level',
                    style: AppTextStyles.statValue.copyWith(
                      
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    'LEVEL',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.grey500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for gradient ring
class _GradientRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _GradientRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + (2 * math.pi * progress),
      colors: [
        AppTheme.primaryColor,
        AppTheme.accentGold,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// STREAK BADGE WIDGET
/// Pill-shaped badge with pulsing animation
class _StreakBadgeWidget extends StatefulWidget {
  final int streak;

  const _StreakBadgeWidget({required this.streak});

  @override
  State<_StreakBadgeWidget> createState() => _StreakBadgeWidgetState();
}

class _StreakBadgeWidgetState extends State<_StreakBadgeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasStreak = widget.streak > 0;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () => _showStreakBottomSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasStreak
                  ? [
                      Colors.orange.withOpacity(0.2),
                      Colors.orange.withOpacity(0.1),
                    ]
                  : [
                      Colors.grey.withOpacity(0.15),
                      Colors.grey.withOpacity(0.08),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasStreak
                  ? Colors.orange.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.25),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                color: hasStreak ? Colors.orange : AppTheme.grey600,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                hasStreak ? '${widget.streak} WEEKS BEAST MODE' : 'START YOUR STREAK',
                style: AppTextStyles.caption.copyWith(
                  color: hasStreak ? Colors.orange : AppTheme.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStreakBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'STREAK CALENDAR',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your current streak: ${widget.streak} weeks',
              style: AppTextStyles.body.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Keep training weekly to maintain your streak and earn XP bonuses!',
              style: AppTextStyles.small.copyWith(
                color: AppTheme.grey500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('GOT IT', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// STAT ITEM
/// Individual stat display for quick stats strip
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 18,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.statValue.copyWith(
            
            color: valueColor ?? AppTheme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.grey500,
          ),
        ),
      ],
    );
  }
}

/// QUICK ACTION CARD
/// Card for quick action buttons
class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.08),
            color.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
            child: Column(
              children: [
                // Icon with glow
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(0.25),
                        color.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  style: AppTextStyles.small.copyWith(
                    fontWeight: FontWeight.w800,
                    
                    color: AppTheme.onPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

