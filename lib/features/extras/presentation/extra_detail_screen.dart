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

    return Column(
      children: [
        // Header with session overview
        Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
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
                      if (extra.difficulty != null) ...[
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: _getDifficultyColor(extra.difficulty!),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          extra.difficulty!.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _getDifficultyColor(extra.difficulty!),
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(width: 16),
                      ],
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
                ],
              ),
            ),
          ),
        ),
        // Exercise preview list
        Expanded(
          child: extraExercises.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Session preview',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the session to see exercises',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[400],
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: extraExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = extraExercises[index];
                    return _ExercisePreviewCard(
                      exercise: exercise,
                      index: index,
                    );
                  },
                ),
        ),
        // Start Session button - always visible
        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCompleting ? null : () => _startSession(extra),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey[800],
                ),
                child: _isCompleting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Start this session',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
      // Log the session start
      debugPrint('Starting extra session: ${extra.id}');

      // TODO: Replace with actual workout session navigation
      // For now, navigate to a placeholder or existing workout screen
      // Example: context.push('/workout-session/${extra.id}');
      
      if (mounted) {
        // Show a snackbar indicating session is starting
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Starting ${extra.title}...'),
            backgroundColor: AppTheme.primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );

        // Simulate navigation delay
        await Future.delayed(const Duration(milliseconds: 500));

        // TODO: Navigate to actual workout session screen when implemented
        // For now, just pop back
        if (mounted) {
          context.pop();
        }
      }
    } catch (error) {
      debugPrint('Failed to start session: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start session: $error'),
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
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
  });

  final Exercise exercise;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
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
