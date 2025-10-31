import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di.dart';
import '../../../app/theme.dart';
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
  ConsumerState<SessionPlayerScreen> createState() =>
      _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen> {
  final Set<String> _completedExercises = <String>{};
  bool _isFinishing = false;
  bool _bonusChallengeCompleted = false;
  bool _sessionStarted = false;
  
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isTimerRunning = false;

  // Performance tracking state
  // Map<exerciseId, List<ExerciseSetPerformance>>
  final Map<String, List<ExerciseSetPerformance>> _exercisePerformances = {};
  final Map<String, List<TextEditingController>> _repsControllers = {};
  final Map<String, List<TextEditingController>> _weightControllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Log session start event on next frame to ensure ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logSessionStart();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    
    // Dispose all text controllers
    for (final controllers in _repsControllers.values) {
      for (final controller in controllers) {
        controller.dispose();
      }
    }
    for (final controllers in _weightControllers.values) {
      for (final controller in controllers) {
        controller.dispose();
      }
    }
    
    super.dispose();
  }

  Future<void> _logSessionStart() async {
    if (_sessionStarted) return;
    _sessionStarted = true;

    try {
      final week = int.tryParse(widget.week) ?? 0;
      final session = int.tryParse(widget.session) ?? 0;

      await ref.read(
          startSessionActionProvider(widget.programId, week, session).future);
      debugPrint(
          'Session started: ${widget.programId}, week: $week, session: $session');
    } catch (error) {
      // Log error but don't prevent session from loading
      debugPrint('Failed to log session start: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync =
        ref.watch(_sessionProvider(widget.week, widget.session));
    final programAsync = ref.watch(_programProvider(widget.programId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              programAsync.value?.title ?? 'Loading...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Week ${int.parse(widget.week) + 1} • Session ${int.parse(widget.session) + 1}',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
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
    final completedCount = _completedExercises.length;
    final totalCount = session.blocks.length;
    final isAllCompleted = completedCount == totalCount && totalCount > 0;
    final isLastPage = _currentPage == totalCount - 1;

    return Column(
      children: [
        // Session header with progress
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exercise ${_currentPage + 1} of $totalCount',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: totalCount > 0 ? (_currentPage + 1) / totalCount : 0,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation(
                          isAllCompleted ? Colors.green : AppTheme.primaryColor,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$completedCount/$totalCount',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isAllCompleted ? Colors.green : AppTheme.primaryColor,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Page indicator dots
        _buildPageIndicator(totalCount),

        // Horizontal swipeable exercise pages
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _stopTimer();
              });
            },
            itemCount: totalCount,
            itemBuilder: (context, index) {
              return _buildExercisePage(context, session.blocks[index], index + 1);
            },
          ),
        ),

        // Bottom action bar
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
            child: Row(
              children: [
                if (!isLastPage)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _nextExercise,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppTheme.primaryColor),
                      ),
                      child: const Text(
                        'Next Exercise',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (isLastPage)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isAllCompleted && !_isFinishing ? _finishSession : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAllCompleted ? Colors.green : null,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                              isAllCompleted
                                  ? 'Complete Session'
                                  : 'Mark all exercises',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: index == _currentPage ? 24 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: index == _currentPage
                  ? AppTheme.primaryColor
                  : Colors.grey[700],
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  void _nextExercise() {
    if (_currentPage < _pageController.page!.toInt() + 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildExercisePage(
      BuildContext context, ExerciseBlock block, int exerciseNumber) {
    final exerciseAsync = ref.watch(_exerciseProvider(block.exerciseId));

    return exerciseAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error loading exercise: $error'),
      ),
      data: (exercise) {
        // Initialize performance data for this exercise if not exists
        _initializeExercisePerformance(exercise);
        
        // Watch last performance
        final lastPerfAsync = ref.watch(lastPerformanceProvider(exercise.id));

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Exercise info card
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise name and number
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Text(
                              '$exerciseNumber',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Prescribed details
                    _buildPrescribedDetails(context, exercise),

                    // Last performance history
                    lastPerfAsync.when(
                      data: (lastPerf) => lastPerf != null
                          ? _buildLastPerformance(context, lastPerf)
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    // Watch video button
                    if (exercise.youtubeQuery.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showVideoDialog(context, exercise),
                          icon: const Icon(Icons.play_circle_outline, size: 18),
                          label: const Text('Watch Video', style: TextStyle(fontSize: 14)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Performance input section
              _buildPerformanceInput(context, exercise),

              const SizedBox(height: 16),

              // Mark as done button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _saveExercisePerformance(exercise),
                  icon: Icon(
                    _completedExercises.contains(exercise.id)
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    size: 20,
                  ),
                  label: Text(
                    _completedExercises.contains(exercise.id)
                        ? 'Completed'
                        : 'Complete Exercise',
                    style: const TextStyle(fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _completedExercises.contains(exercise.id)
                        ? Colors.green
                        : AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _startTimer(int duration) {
    if (_isTimerRunning) {
      _stopTimer();
      return;
    }

    setState(() {
      _isTimerRunning = true;
      if (_secondsRemaining == 0) {
        _secondsRemaining = duration;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _stopTimer();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _secondsRemaining = 0;
    });
  }


  void _initializeExercisePerformance(Exercise exercise) {
    if (!_exercisePerformances.containsKey(exercise.id)) {
      final sets = <ExerciseSetPerformance>[];
      final repsControllers = <TextEditingController>[];
      final weightControllers = <TextEditingController>[];

      for (int i = 0; i < exercise.sets; i++) {
        sets.add(ExerciseSetPerformance(
          setNumber: i + 1,
          reps: exercise.reps,
          weight: null,
          completed: false,
        ));
        repsControllers.add(TextEditingController(text: exercise.reps.toString()));
        weightControllers.add(TextEditingController());
      }

      _exercisePerformances[exercise.id] = sets;
      _repsControllers[exercise.id] = repsControllers;
      _weightControllers[exercise.id] = weightControllers;
    }
  }

  Widget _buildPrescribedDetails(BuildContext context, Exercise exercise) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (exercise.sets > 0)
            _buildDetailItem(context, 'Sets', '${exercise.sets}'),
          if (exercise.reps > 0)
            _buildDetailItem(context, 'Reps', '${exercise.reps}'),
          if (exercise.rest != null && exercise.rest! > 0)
            _buildDetailItem(context, 'Rest', '${exercise.rest}s'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildLastPerformance(BuildContext context, ExercisePerformance lastPerf) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 16, color: Colors.blueGrey),
              const SizedBox(width: 6),
              Text(
                'Last Performance',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: lastPerf.sets.map((set) {
              final weightStr = set.weight != null ? '${set.weight}kg' : '-';
              return Text(
                'Set ${set.setNumber}: ${set.reps} reps @ $weightStr',
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceInput(BuildContext context, Exercise exercise) {
    final sets = _exercisePerformances[exercise.id] ?? [];
    final repsControllers = _repsControllers[exercise.id] ?? [];
    final weightControllers = _weightControllers[exercise.id] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Performance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
          ),
          const SizedBox(height: 12),
          
          // Set input rows
          ...List.generate(sets.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSetInputRow(
                context,
                index + 1,
                repsControllers[index],
                weightControllers[index],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Add/Remove set buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addSet(exercise),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Set'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (sets.length > 1) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _removeSet(exercise),
                    icon: const Icon(Icons.remove, size: 18),
                    label: const Text('Remove Set'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetInputRow(
    BuildContext context,
    int setNumber,
    TextEditingController repsController,
    TextEditingController weightController,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
          child: Center(
            child: Text(
              '$setNumber',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: repsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Reps',
              labelStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
              filled: true,
              fillColor: AppTheme.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Weight (kg)',
              labelStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
              filled: true,
              fillColor: AppTheme.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _addSet(Exercise exercise) {
    setState(() {
      final sets = _exercisePerformances[exercise.id]!;
      final repsControllers = _repsControllers[exercise.id]!;
      final weightControllers = _weightControllers[exercise.id]!;

      sets.add(ExerciseSetPerformance(
        setNumber: sets.length + 1,
        reps: exercise.reps,
        weight: null,
        completed: false,
      ));
      repsControllers.add(TextEditingController(text: exercise.reps.toString()));
      weightControllers.add(TextEditingController());
    });
  }

  void _removeSet(Exercise exercise) {
    setState(() {
      final sets = _exercisePerformances[exercise.id]!;
      final repsControllers = _repsControllers[exercise.id]!;
      final weightControllers = _weightControllers[exercise.id]!;

      if (sets.isNotEmpty) {
        sets.removeLast();
        repsControllers.last.dispose();
        repsControllers.removeLast();
        weightControllers.last.dispose();
        weightControllers.removeLast();
      }
    });
  }

  Future<void> _saveExercisePerformance(Exercise exercise) async {
    try {
      // Collect performance data from controllers
      final repsControllers = _repsControllers[exercise.id]!;
      final weightControllers = _weightControllers[exercise.id]!;
      
      final sets = <ExerciseSetPerformance>[];
      for (int i = 0; i < repsControllers.length; i++) {
        final reps = int.tryParse(repsControllers[i].text) ?? 0;
        final weightText = weightControllers[i].text;
        final weight = weightText.isNotEmpty ? double.tryParse(weightText) : null;
        
        sets.add(ExerciseSetPerformance(
          setNumber: i + 1,
          reps: reps,
          weight: weight,
          completed: true,
        ));
      }

      // Create performance record
      final performance = ExercisePerformance(
        id: '${exercise.id}_${DateTime.now().millisecondsSinceEpoch}',
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        programId: widget.programId,
        week: int.parse(widget.week),
        session: int.parse(widget.session),
        timestamp: DateTime.now(),
        sets: sets,
      );

      // Save performance
      await ref.read(saveExercisePerformanceActionProvider(performance).future);

      // Mark exercise as completed
      setState(() {
        if (!_completedExercises.contains(exercise.id)) {
          _completedExercises.add(exercise.id);
          ref.read(markExerciseDoneActionProvider(exercise.id));
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${exercise.name} completed!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save performance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  // Convert route parameters to session ID format
  final weekNum = int.parse(week) + 1; // Route uses 0-based, data uses 1-based
  final sessionNum =
      int.parse(session) + 1; // Route uses 0-based, data uses 1-based
  
  // Build session ID based on program format (attacker_w1_s1)
  final sessionId = 'attacker_w${weekNum}_s$sessionNum';

  final sessionResult = await sessionRepository.getById(sessionId);
  if (sessionResult == null) {
    throw Exception(
        'Session not found: $sessionId (week: $week, session: $session)');
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
