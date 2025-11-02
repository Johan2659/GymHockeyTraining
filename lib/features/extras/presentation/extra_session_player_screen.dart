import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../application/app_state_provider.dart';
import '../application/extra_session_model.dart';
import '../application/extra_session_provider.dart';

class ExtraSessionPlayerScreen extends ConsumerStatefulWidget {
  const ExtraSessionPlayerScreen({
    super.key,
    required this.extraId,
  });

  final String extraId;

  @override
  ConsumerState<ExtraSessionPlayerScreen> createState() =>
      _ExtraSessionPlayerScreenState();
}

class _ExtraSessionPlayerScreenState
    extends ConsumerState<ExtraSessionPlayerScreen> {
  late final PageController _pageController;
  final Set<String> _completedExerciseIds = <String>{};
  bool _startLogged = false;
  bool _isFinishing = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logExtraStart();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _logExtraStart() async {
    if (_startLogged) return;
    _startLogged = true;

    try {
      await ref
          .read(startExtraActionProvider(widget.extraId).future);
    } catch (error) {
      debugPrint('Failed to log extra start: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync =
        ref.watch(resolvedExtraSessionProvider(widget.extraId));
    final resolvedSession = sessionAsync.valueOrNull;
    final extraTitle = resolvedSession?.extra.title ?? 'Extra Session';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              extraTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            const Text(
              'Extras Session',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 12),
                Text(
                  'Failed to load session',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ),
        data: (session) {
          if (session == null) {
            return _buildNotFound(context);
          }
          if (session.exercises.isEmpty) {
            return _buildEmptySession(context, session.extra);
          }
          return _buildSessionPlayer(context, session);
        },
      ),
    );
  }

  Widget _buildSessionPlayer(
      BuildContext context, ResolvedExtraSession session) {
    final exercises = session.exercises;
    final progress = _completedExerciseIds.length / exercises.length;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[800],
          color: AppTheme.accentColor,
          minHeight: 6,
        ),
        if (session.hasPlaceholders)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 18, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Placeholder exercises are included. Follow the instructions provided or substitute with a similar movement.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.amber.shade200),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              final isPlaceholder = session.isPlaceholder(exercise);
              final isCompleted =
                  _completedExerciseIds.contains(exercise.id);

              return _ExerciseCard(
                exercise: exercise,
                index: index,
                total: exercises.length,
                isPlaceholder: isPlaceholder,
                isCompleted: isCompleted,
                onComplete: () => _markExerciseCompleted(exercise),
              );
            },
          ),
        ),
        _buildControls(context, session),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildControls(
      BuildContext context, ResolvedExtraSession session) {
    final exercises = session.exercises;
    final currentExercise = exercises[_currentPage];
    final isCompleted = _completedExerciseIds.contains(currentExercise.id);
    final isLastPage = _currentPage == exercises.length - 1;
    final allCompleted =
        _completedExerciseIds.length == exercises.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercise ${_currentPage + 1} of ${exercises.length}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[400]),
                ),
                Text(
                  '${_completedExerciseIds.length}/${exercises.length} completed',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[400]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _currentPage == 0
                        ? null
                        : () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          },
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isCompleted
                        ? isLastPage
                            ? (allCompleted && !_isFinishing
                                ? () => _finishSession(session)
                                : null)
                            : () {
                                _pageController.nextPage(
                                  duration:
                                      const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );
                              }
                        : () => _markExerciseCompleted(currentExercise),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted
                          ? (isLastPage
                              ? AppTheme.accentColor
                              : AppTheme.primaryColor)
                          : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _buildControlLabel(
                        isCompleted, isLastPage, allCompleted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlLabel(bool isCompleted, bool isLastPage, bool allCompleted) {
    if (!isCompleted) {
      return const Text('Mark Complete');
    }
    if (isLastPage && allCompleted) {
      return _isFinishing
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Finish Session');
    }
    return const Text('Next Exercise');
  }

  void _markExerciseCompleted(Exercise exercise) {
    setState(() {
      _completedExerciseIds.add(exercise.id);
    });
  }

  Future<void> _finishSession(ResolvedExtraSession session) async {
    if (_isFinishing) return;

    setState(() {
      _isFinishing = true;
    });

    try {
      await ref.read(completeExtraActionProvider(
        session.extra.id,
        session.extra.xpReward,
      ).future);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Nice Work!'),
          content: Text(
            'You completed ${session.extra.title} and earned +${session.extra.xpReward} XP.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      context.go('/extras');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete session: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFinishing = false;
        });
      }
    }
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                size: 64, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(
              'Extra not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Please return to the extras list and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/extras'),
              child: const Text('Back to Extras'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySession(BuildContext context, ExtraItem extra) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center,
                size: 64, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(
              'Session coming soon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'We are still building the exercise list for ${extra.title}. Check back shortly!',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/extras'),
              child: const Text('Back to Extras'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.index,
    required this.total,
    required this.isPlaceholder,
    required this.isCompleted,
    required this.onComplete,
  });

  final Exercise exercise;
  final int index;
  final int total;
  final bool isPlaceholder;
  final bool isCompleted;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exercise ${index + 1} of $total',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[400]),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (isPlaceholder)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.info, size: 14,
                                  color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                'Placeholder',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: Colors.amber),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _InfoChip(
                        icon: Icons.repeat,
                        label: '${exercise.sets} sets',
                      ),
                      _InfoChip(
                        icon: Icons.timer,
                        label: exercise.duration != null
                            ? '${exercise.duration}s'
                            : '${exercise.reps} reps',
                      ),
                      if (exercise.rest != null)
                        _InfoChip(
                          icon: Icons.hourglass_bottom,
                          label: '${exercise.rest}s rest',
                        ),
                      _InfoChip(
                        icon: Icons.category,
                        label: exercise.category.name.replaceAll('_', ' '),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tip',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search YouTube for "${exercise.youtubeQuery}" for a demo of this movement.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: isCompleted ? null : onComplete,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(isCompleted
                        ? 'Completed'
                        : 'Mark Exercise Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted
                          ? Colors.green.withOpacity(0.3)
                          : AppTheme.primaryColor,
                      foregroundColor:
                          isCompleted ? Colors.greenAccent : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[300]),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Colors.grey[300]),
          ),
        ],
      ),
    );
  }
}

