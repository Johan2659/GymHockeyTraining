import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../application/extra_session_model.dart';
import '../application/extra_session_provider.dart';

class ExtraDetailScreen extends ConsumerStatefulWidget {
  final String extraId;

  const ExtraDetailScreen({
    super.key,
    required this.extraId,
  });

  @override
  ConsumerState<ExtraDetailScreen> createState() => _ExtraDetailScreenState();
}

class _ExtraDetailScreenState extends ConsumerState<ExtraDetailScreen> {
  bool _isCompleting = false;
  bool _extraStarted = false;

  @override
  void initState() {
    super.initState();
    // Log extra start on next frame to ensure ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logExtraStart();
    });
  }

  Future<void> _logExtraStart() async {
    if (_extraStarted) return;
    _extraStarted = true;

    try {
      debugPrint('Extra started: ${widget.extraId}');
    } catch (error) {
      // Log error but don't prevent extra from loading
      debugPrint('Failed to log extra start: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync =
        ref.watch(resolvedExtraSessionProvider(widget.extraId));
    final resolvedSession = sessionAsync.valueOrNull;
    final extraTitle = resolvedSession?.extra.title ?? 'Loading...';
    final typeLabel = _getTypeDisplayName(resolvedSession?.extra.type);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              extraTitle,
              style: AppTextStyles.body,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              typeLabel,
              style: AppTextStyles.small,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showExtraInfo(context, resolvedSession?.extra),
          ),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading extra...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load extra',
                style: AppTextStyles.titleL,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error.toString(),
                style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (session) => session == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppTheme.grey600,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Extra not found',
                      style: AppTextStyles.titleL,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'The requested extra could not be found.',
                      style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : _buildExtraContent(context, session),
      ),
    );
  }

  Widget _buildExtraContent(
      BuildContext context, ResolvedExtraSession session) {
    final extra = session.extra;
    final exercises = session.exercises;

    return Column(
      children: [
        // Header with session overview
        Container(
          padding: AppSpacing.card,
          child: Card(
            child: Padding(
              padding: AppSpacing.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Overview',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.sm + 4),
                  Text(
                    extra.description,
                    style: AppTextStyles.bodyMedium,
                  ),
                  if (session.hasPlaceholders) ...[
                    const SizedBox(height: AppSpacing.sm + 4),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm + 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
                        border: Border.all(color: AppTheme.warning),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              color: AppTheme.warning, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Some exercises are placeholders and will be updated soon.',
                              style: AppTextStyles.small.copyWith(
                                  color: AppTheme.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm + 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${extra.duration} min',
                        style: AppTextStyles.small,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      if (extra.difficulty != null) ...[
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: _getDifficultyColor(extra.difficulty!),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          extra.difficulty!.toUpperCase(),
                          style: AppTextStyles.small.copyWith(
                                color: _getDifficultyColor(extra.difficulty!),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '+${extra.xpReward} XP',
                        style: AppTextStyles.small.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
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
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: AppTheme.grey700,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Session preview',
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Start the session to see exercises',
                          style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppTheme.secondaryTextColor,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return _ExercisePreviewCard(
                      exercise: exercise,
                      index: index,
                      isPlaceholder: session.isPlaceholder(exercise),
                    );
                  },
                ),
        ),
        // Start Session button - always visible
        SafeArea(
          child: Container(
            padding: AppSpacing.card,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor.withOpacity(0.33),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isCompleting ? null : () => _startSession(session.extra),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.onPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  disabledBackgroundColor: AppTheme.grey800,
                ),
                child: _isCompleting
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
                        'Start this session',
                        style: AppTextStyles.button,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startSession(ExtraItem extra) async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      if (mounted) {
        context.push('/extras/${extra.id}/play');
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
          _isCompleting = false;
        });
      }
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppTheme.completed;
      case 'medium':
        return AppTheme.inProgress;
      case 'hard':
        return AppTheme.error;
      default:
        return AppTheme.notStarted;
    }
  }

  void _showExtraInfo(BuildContext context, ExtraItem? extra) {
    if (extra == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(extra.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(extra.description),
            const SizedBox(height: 16),
            Text('Type: ${_getTypeDisplayName(extra.type)}'),
            Text('Duration: ${extra.duration} minutes'),
            Text('XP Reward: ${extra.xpReward}'),
            if (extra.difficulty != null)
              Text('Difficulty: ${extra.difficulty}'),
            Text('Exercises: ${extra.blocks.length}'),
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

  String _getTypeDisplayName(ExtraType? type) {
    switch (type) {
      case ExtraType.expressWorkout:
        return 'Express Workout';
      case ExtraType.bonusChallenge:
        return 'Bonus Challenge';
      case ExtraType.mobilityRecovery:
        return 'Mobility & Recovery';
      case null:
        return 'Extra';
    }
  }
}

class _ExercisePreviewCard extends StatelessWidget {
  const _ExercisePreviewCard({
    required this.exercise,
    required this.index,
    this.isPlaceholder = false,
  });

  final Exercise exercise;
  final int index;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
      child: Padding(
        padding: AppSpacing.card,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.2),
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    softWrap: true,
                  ),
                  if (isPlaceholder) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: AppTheme.warning),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Placeholder exercise',
                          style: AppTextStyles.small.copyWith(
                              color: AppTheme.warning),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      if (exercise.sets > 0)
                        Text(
                          '${exercise.sets} sets',
                          style: AppTextStyles.small,
                        ),
                      if (exercise.reps > 0)
                        Text(
                          '${exercise.reps} reps',
                          style: AppTextStyles.small,
                        ),
                      if (exercise.duration != null)
                        Text(
                          '${exercise.duration}s',
                          style: AppTextStyles.small,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
