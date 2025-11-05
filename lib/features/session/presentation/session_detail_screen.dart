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
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sessionTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Week ${weekIndex + 1}, Session ${sessionIndex + 1}',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () =>
                _showSessionInfo(context, resolvedSession?.session),
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
              Text('Loading session...'),
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
                'Failed to load session',
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
        data: (session) => session == null
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
                      'Session not found',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The requested session could not be found.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
                    sessionData.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (session.hasPlaceholders) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade400),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.amber, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Some exercises are placeholders and will be updated soon.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.amber.shade200),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${exercises.length} exercises',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[400],
                            ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '~${_estimateDuration(exercises)} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[400],
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
                onPressed: _isStarting ? null : _startSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey[800],
                ),
                child: _isStarting
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
            backgroundColor: Colors.red,
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
  });

  final Exercise exercise;
  final int index;
  final bool isPlaceholder;

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
                  if (isPlaceholder) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: Colors.amber.shade300),
                        const SizedBox(width: 4),
                        Text(
                          'Placeholder exercise',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.amber.shade200),
                        ),
                      ],
                    ),
                  ],
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
                      if (exercise.duration != null && exercise.duration! > 0)
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
