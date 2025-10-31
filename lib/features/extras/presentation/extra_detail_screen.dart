import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di.dart';
import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../application/app_state_provider.dart';

part 'extra_detail_screen.g.dart';

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
  final Set<String> _completedExercises = <String>{};
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
    final extraAsync = ref.watch(_extraProvider(widget.extraId));
    final exercisesAsync = ref.watch(_exercisesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              extraAsync.value?.title ?? 'Loading...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _getTypeDisplayName(extraAsync.value?.type),
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showExtraInfo(context, extraAsync.value),
          ),
        ],
      ),
      body: extraAsync.when(
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
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load extra',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (extra) => extra == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Extra not found',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The requested extra could not be found.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : exercisesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Failed to load exercises: $error'),
                ),
                data: (exercises) =>
                    _buildExtraContent(context, extra, exercises),
              ),
      ),
    );
  }

  Widget _buildExtraContent(
      BuildContext context, ExtraItem extra, List<Exercise> exercises) {
    // Create a map for quick exercise lookups
    final exerciseMap = {for (var ex in exercises) ex.id: ex};

    // Get the exercises for this extra
    final extraExercises = extra.blocks
        .map((block) => exerciseMap[block.exerciseId])
        .where((exercise) => exercise != null)
        .cast<Exercise>()
        .toList();

    final completedCount = _completedExercises.length;
    final totalCount = extraExercises.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final isCompleted = completedCount == totalCount;

    return Column(
      children: [
        // Header with progress
        Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    extra.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${extra.duration} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[400],
                            ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${extra.xpReward} XP',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[700],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? Colors.green : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$completedCount/$totalCount',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
        // Exercise list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: extraExercises.length,
            itemBuilder: (context, index) {
              final exercise = extraExercises[index];
              final isCompleted = _completedExercises.contains(exercise.id);

              return _ExerciseCard(
                exercise: exercise,
                isCompleted: isCompleted,
                onCompleted: () => _markExerciseCompleted(exercise.id),
              );
            },
          ),
        ),
        // Complete button
        if (isCompleted && !_isCompleting)
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completeExtra,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Complete Extra (+${extra.xpReward} XP)',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        if (_isCompleting)
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  void _markExerciseCompleted(String exerciseId) {
    setState(() {
      if (_completedExercises.contains(exerciseId)) {
        _completedExercises.remove(exerciseId);
      } else {
        _completedExercises.add(exerciseId);
      }
    });
  }

  Future<void> _completeExtra() async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      final extra = await ref.read(_extraProvider(widget.extraId).future);
      if (extra != null) {
        await ref.read(
            completeExtraActionProvider(widget.extraId, extra.xpReward).future);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Extra completed! +${extra.xpReward} XP earned'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      }
    } catch (error) {
      debugPrint('Failed to complete extra: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete extra: $error'),
            backgroundColor: Colors.red,
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

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.isCompleted,
    required this.onCompleted,
  });

  final Exercise exercise;
  final bool isCompleted;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onCompleted,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppTheme.accentColor
                      : AppTheme.backgroundColor,
                  border: Border.all(
                    color:
                        isCompleted ? AppTheme.accentColor : Colors.grey[700]!,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        color: AppTheme.backgroundColor,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (exercise.sets > 0)
                          Text(
                            '${exercise.sets} sets',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[400],
                                    ),
                          ),
                        if (exercise.reps > 0)
                          Text(
                            '${exercise.reps} reps',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[400],
                                    ),
                          ),
                        if (exercise.duration != null)
                          Text(
                            '${exercise.duration}s',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[400],
                                    ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Provider for getting a specific extra by ID
@riverpod
Future<ExtraItem?> _extra(Ref ref, String extraId) async {
  final repository = ref.watch(extrasRepositoryProvider);
  return repository.getById(extraId);
}

// Provider for getting all exercises (reused from existing logic)
@riverpod
Future<List<Exercise>> _exercises(Ref ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getAll();
}
