import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../application/session_preview_model.dart';
import '../application/session_preview_provider.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final String programId;
  final String week;
  final String session;

  const SessionDetailScreen({
    super.key,
    required this.programId,
    required this.week,
    required this.session,
  });

  @override
  ConsumerState<SessionDetailScreen> createState() =>
      _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  bool _isStarting = false;

  @override
  Widget build(BuildContext context) {
    final weekIndex = int.parse(widget.week);
    final sessionIndex = int.parse(widget.session);
    final sessionAsync = ref.watch(
        resolvedSessionProvider((widget.programId, weekIndex, sessionIndex)));
    final resolvedSession = sessionAsync.valueOrNull;
    final sessionTitle = resolvedSession?.session.title ??
        'Week ${weekIndex + 1}, Session ${sessionIndex + 1}';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: sessionAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading session...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: AppSpacing.card,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg - 4),
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
                  child: Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.error,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'Failed to load session',
                  style: AppTextStyles.titleL,
                ),
                SizedBox(height: AppSpacing.sm + 4),
                Text(
                  error.toString(),
                  style: AppTextStyles.small.copyWith(
                    color: AppTheme.secondaryTextColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (session) => session == null
            ? Center(
                child: Padding(
                  padding: AppSpacing.card,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.lg - 4),
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
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.grey600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Text(
                        'Session not found',
                        style: AppTextStyles.titleL,
                      ),
                      SizedBox(height: AppSpacing.sm + 4),
                      Text(
                        'The requested session could not be found.',
                        style: AppTextStyles.small.copyWith(
                          color: AppTheme.secondaryTextColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : _buildSessionContent(context, session),
      ),
    );
  }

  Widget _buildSessionContent(
      BuildContext context, ResolvedSession session) {
    final sessionData = session.session;
    final exercises = session.exercises;

    return Column(
      children: [
        // Header with session overview - Glassmorphism + Hockey lines
        SafeArea(
          child: Container(
            margin: EdgeInsets.fromLTRB(AppSpacing.lg - 4, AppSpacing.sm, AppSpacing.lg - 4, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session title with thin accent line + info icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Very thin vertical accent line
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
                    SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: Text(
                        sessionData.title.toUpperCase(),
                        style: AppTextStyles.titleL.copyWith(
                          letterSpacing: 0.3,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: AppTheme.shadowColor,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm + 4),
                    // Info button
                    IconButton(
                      onPressed: () => _showSessionInfo(context, sessionData),
                      icon: const Icon(Icons.info_outline),
                      iconSize: 24,
                      color: AppTheme.primaryColor,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Session Info',
                    ),
                  ],
                ),
              
              SizedBox(height: AppSpacing.lg - 4),
              
              // Placeholder warning - glassmorphism
              if (session.hasPlaceholders) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.sm + 2),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
                        border: Border.all(
                          color: AppTheme.warning.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.warning,
                            size: 16,
                          ),
                          SizedBox(width: AppSpacing.sm + 2),
                          Expanded(
                            child: Text(
                              'Some exercises are placeholders and will be updated soon.',
                              style: AppTextStyles.small.copyWith(
                                color: AppTheme.warning,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg - 4),
              ],
              
              // Stats row - clean with thin divider
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md + 2, horizontal: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Exercises count
                        Expanded(
                          child: _buildStatItem(
                            context,
                            icon: Icons.fitness_center,
                            value: '${exercises.length}',
                            label: 'EXERCISES',
                          ),
                        ),
                        
                        // Very thin vertical divider
                        Container(
                          width: 1,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppTheme.primaryColor.withOpacity(0.3),
                                AppTheme.primaryColor.withOpacity(0.5),
                                AppTheme.primaryColor.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        
                        // Duration estimate
                        Expanded(
                          child: _buildStatItem(
                            context,
                            icon: Icons.schedule,
                            value: '~${_estimateDuration(exercises)}',
                            label: 'MINUTES',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
        // Exercise preview list
        Expanded(
          child: exercises.isEmpty
              ? Center(
                  child: Padding(
                    padding: AppSpacing.card,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSpacing.lg - 4),
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
                            Icons.fitness_center,
                            size: 64,
                            color: AppTheme.grey700,
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        Text(
                          'Session preview',
                          style: AppTextStyles.subtitleLarge,
                        ),
                        SizedBox(height: AppSpacing.sm + 4),
                        Text(
                          'Start the session to see exercises',
                          style: AppTextStyles.small.copyWith(
                            color: AppTheme.secondaryTextColor,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(AppSpacing.lg - 4, 1, AppSpacing.lg - 4, AppSpacing.sm),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    final isBonus = index == exercises.length - 1 && 
                                    sessionData.bonusChallenge.isNotEmpty;
                    return _ExercisePreviewCard(
                      exercise: exercise,
                      index: index,
                      isPlaceholder: session.isPlaceholder(exercise),
                      isBonus: isBonus,
                    );
                  },
                ),
        ),
        // Drop the puck button - Powerful hockey style
        Container(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg - 4, AppSpacing.sm + 4, AppSpacing.lg - 4, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            border: Border(
              top: BorderSide(
                color: AppTheme.grey850,
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Powerful accent line
              Container(
                height: 2,
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primaryColor.withOpacity(0.6),
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              
              // Button - full width
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isStarting ? null : _startSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.onPrimaryColor,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
                    elevation: 0,
                    disabledBackgroundColor: AppTheme.grey800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
                    ),
                  ),
                  icon: _isStarting
                      ? const SizedBox.shrink()
                      : const Icon(
                          Icons.sports_hockey,
                          size: 24,
                        ),
                  label: _isStarting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppTheme.onPrimaryColor),
                          ),
                        )
                      : Text(
                          'LET\'S GO',
                          style: AppTextStyles.buttonLarge.copyWith(
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _startSession() async {
    if (_isStarting) return;

    setState(() {
      _isStarting = true;
    });

    try {
      if (mounted) {
        context.push(
            '/session/${widget.programId}/${widget.week}/${widget.session}/play');
      }
    } catch (error) {
      debugPrint('Failed to start session: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start session: $error'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }

  int _estimateDuration(List<Exercise> exercises) {
    int totalSeconds = 0;
    for (final exercise in exercises) {
      // Calculate time per set
      final timePerSet = (exercise.duration ?? 0) + (exercise.rest ?? 0);
      totalSeconds += exercise.sets * timePerSet;
    }
    return (totalSeconds / 60).ceil();
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        children: [
          // Icon with subtle glow - same as player screen
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
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
              icon,
              size: 26,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: AppSpacing.sm + 2),
          // Value with emphasis
          Text(
            value,
            style: AppTextStyles.displayXL.copyWith(
              height: 1,
            ),
          ),
          SizedBox(height: AppSpacing.xs + 2),
          // Underline accent - hockey style
          Container(
            width: 30,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.primaryColor.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          SizedBox(height: AppSpacing.xs + 2),
          // Label
          Text(
            label,
            style: AppTextStyles.labelMicro.copyWith(
              color: AppTheme.grey500,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionInfo(BuildContext context, Session? session) {
    if (session == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exercises: ${session.blocks.length}'),
            Text('Session ID: ${session.id}'),
            if (session.bonusChallenge.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Bonus: ${session.bonusChallenge}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ExercisePreviewCard extends StatelessWidget {
  const _ExercisePreviewCard({
    required this.exercise,
    required this.index,
    this.isPlaceholder = false,
    this.isBonus = false,
  });

  final Exercise exercise;
  final int index;
  final bool isPlaceholder;
  final bool isBonus;

  @override
  Widget build(BuildContext context) {
    // Colors based on bonus status
    final accentColor = isBonus ? AppTheme.bonus : AppTheme.primaryColor;
    
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm + 2),
      child: Stack(
        children: [
          // Very thin left accent line - hockey rink inspired (amber for bonus)
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
                    accentColor,
                    accentColor.withOpacity(0.7),
                    accentColor.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          
          // Content with glassmorphism
          Padding(
            padding: EdgeInsets.only(left: AppSpacing.sm + 2),
            child: Column(
              children: [
                // Top thin line
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        accentColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: AppSpacing.sm + 2),
                
                // Main content row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Exercise number badge - hockey puck style (amber for bonus)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withOpacity(0.2),
                            accentColor.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: accentColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isBonus
                            ? Icon(
                                Icons.star,
                                size: 16,
                                color: AppTheme.bonus,
                              )
                              : Text(
                                '${index + 1}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    
                    // Exercise details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bonus badge
                          if (isBonus) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  size: 11,
                                  color: AppTheme.accentColor,
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  'BONUS CHALLENGE',
                                  style: AppTextStyles.labelMicro.copyWith(
                                    color: AppTheme.accentColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.xs + 2),
                          ],
                          
                          // Exercise name
                          Text(
                            exercise.name.toUpperCase(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              letterSpacing: 0.3,
                              height: 1.2,
                            ),
                            softWrap: true,
                          ),
                          
                          // Placeholder warning
                          if (isPlaceholder) ...[
                            SizedBox(height: AppSpacing.xs + 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 10,
                                  color: AppTheme.warning,
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Placeholder',
                                  style: AppTextStyles.labelMicro.copyWith(
                                    color: AppTheme.warning,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          
                          SizedBox(height: AppSpacing.sm + 2),
                          
                          // Stats row with thin dot separators
                          Row(
                            children: [
                              if (exercise.sets > 0) ...[
                                _buildStatBadge(
                                  icon: Icons.repeat_rounded,
                                  value: '${exercise.sets}',
                                  label: 'sets',
                                ),
                              ],
                              if (exercise.sets > 0 && exercise.reps > 0) ...[
                                Container(
                                  width: 2,
                                  height: 2,
                                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryColor.withOpacity(0.5),
                                  ),
                                ),
                              ],
                              if (exercise.reps > 0) ...[
                                _buildStatBadge(
                                  icon: Icons.fitness_center,
                                  value: '${exercise.reps}',
                                  label: 'reps',
                                ),
                              ],
                              if (exercise.duration != null && exercise.duration! > 0) ...[
                                Container(
                                  width: 2,
                                  height: 2,
                                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryColor.withOpacity(0.5),
                                  ),
                                ),
                                _buildStatBadge(
                                  icon: Icons.timer_outlined,
                                  value: '${exercise.duration}s',
                                  label: '',
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.sm + 2),
                
                // Bottom thin line
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        accentColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.primaryColor.withOpacity(0.7),
        ),
        SizedBox(width: AppSpacing.xs + 2),
        Text(
          '$value${label.isNotEmpty ? ' $label' : ''}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.secondaryTextColor,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
