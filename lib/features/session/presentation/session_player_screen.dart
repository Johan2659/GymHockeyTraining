import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di.dart';
import '../../../core/models/models.dart';
import '../../application/app_state_provider.dart';

part 'session_player_screen.g.dart';

class SessionPlayerScreen extends ConsumerStatefulWidget {
  final String programId;
  final String week;
  final String session;

  const SessionPlayerScreen({
    super.key,
    required this.programId,
    required this.week,
    required this.session,
  });

  @override
  ConsumerState<SessionPlayerScreen> createState() => _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen> {
  final Set<String> _completedExercises = <String>{};
  bool _isFinishing = false;
  bool _bonusChallengeCompleted = false;
  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();
    // Log session start event on next frame to ensure ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logSessionStart();
    });
  }

  Future<void> _logSessionStart() async {
    if (_sessionStarted) return;
    _sessionStarted = true;
    
    try {
      final week = int.tryParse(widget.week) ?? 1;
      final session = int.tryParse(widget.session.replaceAll('week${week}_session', '')) ?? 1;
      
      await ref.read(startSessionActionProvider(widget.programId, week, session).future);
      debugPrint('Session started: ${widget.programId}, week: $week, session: $session');
    } catch (error) {
      // Log error but don't prevent session from loading
      debugPrint('Failed to log session start: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(_sessionProvider(widget.week, widget.session));
    final programAsync = ref.watch(_programProvider(widget.programId));

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
              programAsync.value?.title ?? 'Loading...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Week ${widget.week} • Session ${widget.session}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showSessionInfo(context, sessionAsync.value),
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
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load session'),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
        data: (session) => _buildSessionContent(context, session),
      ),
    );
  }

  Widget _buildSessionContent(BuildContext context, Session session) {
    final theme = Theme.of(context);
    final completedCount = _completedExercises.length;
    final totalCount = session.blocks.length;
    final isAllCompleted = completedCount == totalCount && totalCount > 0;

    return Column(
      children: [
        // Progress header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B365D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete all ${session.blocks.length} exercises in this training session',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: totalCount > 0 ? completedCount / totalCount : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        isAllCompleted ? Colors.green : const Color(0xFF2196F3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$completedCount/$totalCount',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isAllCompleted ? Colors.green : const Color(0xFF1B365D),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Exercise blocks list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: session.blocks.length + (session.bonusChallenge.isNotEmpty ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < session.blocks.length) {
                return _buildExerciseBlock(context, session.blocks[index], index + 1);
              } else {
                // Bonus challenge
                return _buildBonusChallengeBlock(context, session.bonusChallenge);
              }
            },
          ),
        ),

        // Finish session button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isAllCompleted && !_isFinishing ? _finishSession : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAllCompleted ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isFinishing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      isAllCompleted ? 'Complete Session 🎉' : 'Complete all exercises to finish',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseBlock(BuildContext context, ExerciseBlock block, int exerciseNumber) {
    final exerciseAsync = ref.watch(_exerciseProvider(block.exerciseId));
    
    return exerciseAsync.when(
      loading: () => const Card(
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading exercise: $error'),
        ),
      ),
      data: (exercise) => _buildExerciseCard(context, exercise, exerciseNumber),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise, int exerciseNumber) {
    final isCompleted = _completedExercises.contains(exercise.id);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCompleted ? Colors.green[50] : Colors.white,
          border: Border.all(
            color: isCompleted ? Colors.green : Colors.grey[300]!,
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? Colors.green : const Color(0xFF1B365D),
                  ),
                  child: Center(
                    child: Text(
                      '$exerciseNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercise.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey[600] : null,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleExercise(exercise.id),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? Colors.green : Colors.white,
                      border: Border.all(
                        color: isCompleted ? Colors.green : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 20,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildExerciseDetails(exercise),
            if (exercise.youtubeQuery.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showVideoDialog(context, exercise),
                  icon: const Icon(Icons.play_circle_outline, color: Colors.red),
                  label: const Text('Watch Video'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseDetails(Exercise exercise) {
    final details = <String>[];
    
    if (exercise.sets > 0) details.add('${exercise.sets} sets');
    if (exercise.reps > 0) details.add('${exercise.reps} reps');
    if (exercise.duration != null && exercise.duration! > 0) details.add('${exercise.duration}s');
    if (exercise.rest != null && exercise.rest! > 0) details.add('${exercise.rest}s rest');

    return Wrap(
      spacing: 8,
      children: details
          .map((detail) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B365D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B365D),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildBonusChallengeBlock(BuildContext context, String bonusChallenge) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.orange[400]!, Colors.orange[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'BONUS CHALLENGE',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              bonusChallenge,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _bonusChallengeCompleted ? null : () => _completeBonusChallenge(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _bonusChallengeCompleted ? Colors.grey : Colors.white,
                  foregroundColor: _bonusChallengeCompleted ? Colors.white : Colors.orange[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _bonusChallengeCompleted ? 'Completed! ✅' : 'Complete Bonus Challenge',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleExercise(String exerciseId) {
    setState(() {
      if (_completedExercises.contains(exerciseId)) {
        _completedExercises.remove(exerciseId);
      } else {
        _completedExercises.add(exerciseId);
        // Mark exercise as done in app state
        ref.read(markExerciseDoneActionProvider(exerciseId));
      }
    });
  }

  Future<void> _finishSession() async {
    setState(() {
      _isFinishing = true;
    });

    try {
      // Complete the session through app state
      await ref.read(completeSessionActionProvider.future);
      
      if (mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('🎉 Session Complete!'),
            content: const Text(
              'Great job! You\'ve completed this training session. Keep up the excellent work!',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  context.go('/'); // Navigate to hub screen
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete session: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFinishing = false;
        });
      }
    }
  }

  Future<void> _completeBonusChallenge() async {
    try {
      await ref.read(completeBonusChallengeActionProvider.future);
      
      setState(() {
        _bonusChallengeCompleted = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🏆 Bonus challenge completed! Extra XP earned!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete bonus challenge: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSessionInfo(BuildContext context, Session? session) {
    if (session == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This session contains:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• ${session.blocks.length} exercises'),
              if (session.bonusChallenge.isNotEmpty) ...[
                const SizedBox(height: 4),
                const Text(
                  '• Bonus Challenge Available! 🏆',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Complete all exercises to finish the session and earn XP!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showVideoDialog(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_circle_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Search YouTube for: "${exercise.youtubeQuery}"',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'This would open a video player in a real app.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Provider to get session data
@riverpod
Future<Session> _session(Ref ref, String week, String session) async {
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  
  // Convert route parameters to session ID format (week1_session1, week2_session2, etc.)
  final weekNum = int.parse(week) + 1; // Route uses 0-based, data uses 1-based
  final sessionNum = int.parse(session) + 1; // Route uses 0-based, data uses 1-based
  final sessionId = 'week${weekNum}_session$sessionNum';
  
  final sessionResult = await sessionRepository.getById(sessionId);
  if (sessionResult == null) {
    throw Exception('Session not found: $sessionId (week: $week, session: $session)');
  }
  return sessionResult;
}

// Provider to get program data
@riverpod
Future<Program> _program(Ref ref, String programId) async {
  final programRepository = ref.watch(programRepositoryProvider);
  final program = await programRepository.getById(programId);
  if (program == null) {
    throw Exception('Program not found: $programId');
  }
  return program;
}

// Provider to get exercise data
@riverpod
Future<Exercise> _exercise(Ref ref, String exerciseId) async {
  final exerciseRepository = ref.watch(exerciseRepositoryProvider);
  final exercise = await exerciseRepository.getById(exerciseId);
  if (exercise == null) {
    throw Exception('Exercise not found: $exerciseId');
  }
  return exercise;
}
