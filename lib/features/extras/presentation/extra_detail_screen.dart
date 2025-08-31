import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di.dart';
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              extraAsync.value?.title ?? 'Loading...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _getTypeDisplayName(extraAsync.value?.type),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              data: (exercises) => _buildExtraContent(context, extra, exercises),
            ),
      ),
    );
  }

  Widget _buildExtraContent(BuildContext context, ExtraItem extra, List<Exercise> exercises) {
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
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          extra.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${extra.duration} min',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.emoji_events,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${extra.xpReward} XP',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.amber[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
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
        // Exercise list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
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
          Container(
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        if (_isCompleting)
          Container(
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: CircularProgressIndicator(),
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
        await ref.read(completeExtraActionProvider(widget.extraId, extra.xpReward).future);
        
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: onCompleted,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Colors.green : Colors.grey[300],
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.circle_outlined,
                  color: isCompleted ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (exercise.sets > 0) ...[
                        Text(
                          '${exercise.sets} sets',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (exercise.reps > 0) ...[
                        Text(
                          '${exercise.reps} reps',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (exercise.duration != null) ...[
                        Text(
                          '${exercise.duration}s',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
