import 'dart:async';
import 'dart:math' as math;
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
    extends ConsumerState<ExtraSessionPlayerScreen> with TickerProviderStateMixin {
  late final PageController _pageController;
  final Map<String, List<bool>> _completedSets = {}; // exerciseId -> set completion list
  bool _startLogged = false;
  bool _isFinishing = false;
  int _currentPage = 0;
  
  // Interval timer state
  Timer? _intervalTimer;
  bool _isIntervalTimerActive = false;
  bool _isIntervalTimerPaused = false;
  bool _isWorkPhase = true; // true = work/hold, false = rest
  int _currentPhaseSeconds = 0; // Seconds elapsed in current phase
  int _workDuration = 0; // Total work duration
  int _restDuration = 0; // Total rest duration
  int _currentSet = 0; // Current set number for interval timer
  String? _currentIntervalExerciseId;

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
    _intervalTimer?.cancel();
    super.dispose();
  }
  
  // Helper methods
  bool _isExerciseCompleted(Exercise exercise) {
    final sets = _completedSets[exercise.id];
    if (sets == null || sets.isEmpty) return false;
    return sets.every((completed) => completed);
  }
  
  int _getCompletedExerciseCount(List<Exercise> exercises) {
    return exercises.where((ex) => _isExerciseCompleted(ex)).length;
  }
  
  void _initializeExerciseSets(Exercise exercise) {
    if (!_completedSets.containsKey(exercise.id)) {
      _completedSets[exercise.id] = List.filled(exercise.sets, false);
    }
  }
  
  void _toggleSet(Exercise exercise, int setIndex) {
    setState(() {
      _completedSets[exercise.id]![setIndex] = !_completedSets[exercise.id]![setIndex];
    });
  }
  
  void _startIntervalTimer(Exercise exercise, int setNumber) {
    _stopIntervalTimer();
    
    final workDuration = exercise.duration ?? 20; // Default 20s if not specified
    final restDuration = exercise.rest ?? 40; // Default 40s if not specified
    
    setState(() {
      _isIntervalTimerActive = true;
      _isIntervalTimerPaused = false;
      _isWorkPhase = true;
      _currentPhaseSeconds = 0;
      _workDuration = workDuration;
      _restDuration = restDuration;
      _currentSet = setNumber;
      _currentIntervalExerciseId = exercise.id;
    });
    
    _intervalTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isIntervalTimerPaused) {
        _currentPhaseSeconds++;
        
        // Check if we need to switch phases
        if (_isWorkPhase && _currentPhaseSeconds >= _workDuration * 10) {
          // Switch to rest phase
          _isWorkPhase = false;
          _currentPhaseSeconds = 0;
        } else if (!_isWorkPhase && _currentPhaseSeconds >= _restDuration * 10) {
          // Rest phase complete - mark current set as done
          if (_currentIntervalExerciseId != null) {
            final sets = _completedSets[_currentIntervalExerciseId!];
            if (sets != null && _currentSet < sets.length) {
              sets[_currentSet] = true;
              
              // Find next incomplete set
              final nextSetIndex = sets.indexWhere((completed) => !completed);
              
              if (nextSetIndex != -1) {
                // Start next set automatically
                _currentSet = nextSetIndex;
                _isWorkPhase = true;
                _currentPhaseSeconds = 0;
                // Continue timer - don't stop
              } else {
                // All sets complete - stop timer
                _stopIntervalTimer();
                return;
              }
            } else {
              _stopIntervalTimer();
              return;
            }
          } else {
            _stopIntervalTimer();
            return;
          }
        }
        
        // Only update UI after all state changes
        if (mounted) {
          setState(() {});
        }
      }
    });
  }
  
  void _pauseIntervalTimer() {
    setState(() {
      _isIntervalTimerPaused = true;
    });
  }
  
  void _resumeIntervalTimer() {
    setState(() {
      _isIntervalTimerPaused = false;
    });
  }
  
  void _stopIntervalTimer() {
    _intervalTimer?.cancel();
    setState(() {
      _isIntervalTimerActive = false;
      _isIntervalTimerPaused = false;
      _isWorkPhase = true;
      _currentPhaseSeconds = 0;
      _currentSet = 0;
      _currentIntervalExerciseId = null;
    });
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
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
    
    return Column(
      children: [
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
            physics: const BouncingScrollPhysics(),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              final isPlaceholder = session.isPlaceholder(exercise);
              
              // Initialize sets if needed
              _initializeExerciseSets(exercise);
              
              final completedSets = _completedSets[exercise.id] ?? [];
              final isCompleted = _isExerciseCompleted(exercise);

              return _ExerciseCard(
                exercise: exercise,
                index: index,
                total: exercises.length,
                isPlaceholder: isPlaceholder,
                isCompleted: isCompleted,
                completedSets: completedSets,
                onToggleSet: (setIndex) => _toggleSet(exercise, setIndex),
                onStartIntervalTimer: () {
                  final nextSet = completedSets.indexWhere((s) => !s);
                  if (nextSet >= 0) {
                    _startIntervalTimer(exercise, nextSet);
                  }
                },
                isTimerActive: _isIntervalTimerActive && _currentIntervalExerciseId == exercise.id,
                isTimerPaused: _isIntervalTimerPaused,
                isWorkPhase: _isWorkPhase,
                currentPhaseSeconds: _currentPhaseSeconds,
                workDuration: _workDuration,
                restDuration: _restDuration,
                currentActiveSet: _isIntervalTimerActive && _currentIntervalExerciseId == exercise.id ? _currentSet : -1,
                onPauseTimer: _pauseIntervalTimer,
                onResumeTimer: _resumeIntervalTimer,
                onStopTimer: _stopIntervalTimer,
              );
            },
          ),
        ),
        _buildControls(context, session),
      ],
    );
  }
  


  Widget _buildControls(
      BuildContext context, ResolvedExtraSession session) {
    final exercises = session.exercises;
    final currentExercise = exercises[_currentPage];
    final isCompleted = _isExerciseCompleted(currentExercise);
    final isLastPage = _currentPage == exercises.length - 1;
    final completedCount = _getCompletedExerciseCount(exercises);
    final allCompleted = completedCount == exercises.length;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Enhanced breadcrumb navigation
            Row(
              children: [
                // Exercise counter badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_currentPage + 1}/${exercises.length}',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Progress bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Workout Progress',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: exercises.length > 0 ? (_currentPage + 1) / exercises.length : 0,
                          backgroundColor: Colors.grey[850],
                          valueColor: AlwaysStoppedAnimation(
                            allCompleted ? const Color(0xFF4CAF50) : AppTheme.accentColor,
                          ),
                          minHeight: 3.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Completion counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (allCompleted ? const Color(0xFF4CAF50) : AppTheme.accentColor).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (allCompleted ? const Color(0xFF4CAF50) : AppTheme.accentColor).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        allCompleted ? Icons.check_circle : Icons.fitness_center,
                        color: allCompleted ? const Color(0xFF4CAF50) : AppTheme.accentColor,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$completedCount',
                        style: TextStyle(
                          color: allCompleted ? const Color(0xFF4CAF50) : AppTheme.accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (_currentPage > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back_ios_new_rounded,
                                  size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'Previous',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? (isLastPage
                              ? AppTheme.accentColor
                              : AppTheme.primaryColor)
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isCompleted
                                  ? (isLastPage
                                      ? AppTheme.accentColor
                                      : AppTheme.primaryColor)
                                  : Colors.black)
                              .withOpacity(isCompleted ? 0.4 : 0.3),
                          blurRadius: isCompleted ? 12 : 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isCompleted
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
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: _buildControlLabel(
                                isCompleted, isLastPage, allCompleted),
                          ),
                        ),
                      ),
                    ),
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

// Responsive circular timer with 2025 UX best practices
class _ResponsiveCircularTimer extends StatelessWidget {
  const _ResponsiveCircularTimer({
    required this.exercise,
    required this.onStartIntervalTimer,
    required this.isActive,
    required this.isPaused,
    required this.isWorkPhase,
    required this.currentPhaseSeconds,
    required this.workDuration,
    required this.restDuration,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final Exercise exercise;
  final VoidCallback onStartIntervalTimer;
  final bool isActive;
  final bool isPaused;
  final bool isWorkPhase;
  final int currentPhaseSeconds;
  final int workDuration;
  final int restDuration;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final displayWorkDuration = workDuration > 0 ? workDuration : (exercise.duration ?? 20);
    final displayRestDuration = restDuration > 0 ? restDuration : (exercise.rest ?? 40);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing - Optimized for 2025 UX
    final double timerSize = screenWidth < 380 ? 170 : (screenWidth < 400 ? 185 : 200);
    final double strokeWidth = screenWidth < 380 ? 8 : 9;
    
    return Center(
      child: GestureDetector(
        onTap: isActive ? null : onStartIntervalTimer,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring - Hockey rink board style
            if (isActive)
              Container(
                width: timerSize + 16,
                height: timerSize + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isWorkPhase 
                        ? const Color(0xFF4CAF50) 
                        : const Color(0xFFFF9800))
                        .withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
            // Main timer container
            Container(
              width: timerSize,
              height: timerSize,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceColor.withOpacity(0.7),
                border: Border.all(
                  color: isActive
                      ? (isWorkPhase 
                          ? const Color(0xFF4CAF50) 
                          : const Color(0xFFFF9800))
                          .withOpacity(0.5)
                      : Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _ModernTimerPainter(
                  workProgress: isActive && isWorkPhase
                      ? (currentPhaseSeconds / 10) / displayWorkDuration
                      : (isActive && !isWorkPhase ? 1.0 : 0.0),
                  restProgress: isActive && !isWorkPhase
                      ? (currentPhaseSeconds / 10) / displayRestDuration
                      : 0.0,
                  strokeWidth: strokeWidth,
                  isActive: isActive,
                  isWorkPhase: isWorkPhase,
                ),
                child: Center(
                  child: isActive
                      ? _buildActiveTimerContent(
                          context, 
                          displayWorkDuration, 
                          displayRestDuration,
                          screenWidth,
                        )
                      : _buildIdleTimerContent(context, screenWidth),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTimerContent(
    BuildContext context,
    int displayWorkDuration,
    int displayRestDuration,
    double screenWidth,
  ) {
    final fontSize = screenWidth < 380 ? 36.0 : (screenWidth < 400 ? 40.0 : 48.0);
    final labelSize = screenWidth < 380 ? 11.0 : 12.0;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Phase indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: (isWorkPhase 
                ? const Color(0xFF4CAF50) 
                : const Color(0xFFFF9800))
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isWorkPhase 
                  ? const Color(0xFF4CAF50) 
                  : const Color(0xFFFF9800),
              width: 1.5,
            ),
          ),
          child: Text(
            isWorkPhase ? 'HOLD' : 'REST',
            style: TextStyle(
              color: isWorkPhase 
                  ? const Color(0xFF4CAF50) 
                  : const Color(0xFFFF9800),
              fontSize: labelSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Timer display
        Text(
          _formatTime(
            (isWorkPhase ? displayWorkDuration : displayRestDuration) -
                (currentPhaseSeconds ~/ 10)
          ),
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: (isWorkPhase 
                    ? const Color(0xFF4CAF50) 
                    : const Color(0xFFFF9800))
                    .withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TimerControlButton(
              icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              onTap: isPaused ? onResume : onPause,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            _TimerControlButton(
              icon: Icons.stop_rounded,
              onTap: onStop,
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIdleTimerContent(BuildContext context, double screenWidth) {
    final iconSize = screenWidth < 380 ? 48.0 : (screenWidth < 400 ? 56.0 : 64.0);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor.withOpacity(0.15),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.play_circle_filled,
            color: AppTheme.primaryColor,
            size: iconSize,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'TAP TO START',
          style: TextStyle(
            color: AppTheme.primaryColor.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Interval Timer',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Timer control button component
class _TimerControlButton extends StatelessWidget {
  const _TimerControlButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 24,
          color: color,
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
    required this.completedSets,
    required this.onToggleSet,
    required this.onStartIntervalTimer,
    required this.isTimerActive,
    required this.isTimerPaused,
    required this.isWorkPhase,
    required this.currentPhaseSeconds,
    required this.workDuration,
    required this.restDuration,
    required this.currentActiveSet,
    required this.onPauseTimer,
    required this.onResumeTimer,
    required this.onStopTimer,
  });

  final Exercise exercise;
  final int index;
  final int total;
  final bool isPlaceholder;
  final bool isCompleted;
  final List<bool> completedSets;
  final Function(int) onToggleSet;
  final VoidCallback onStartIntervalTimer;
  final bool isTimerActive;
  final bool isTimerPaused;
  final bool isWorkPhase;
  final int currentPhaseSeconds;
  final int workDuration;
  final int restDuration;
  final int currentActiveSet;
  final VoidCallback onPauseTimer;
  final VoidCallback onResumeTimer;
  final VoidCallback onStopTimer;

  @override
  Widget build(BuildContext context) {
    final completedSetsCount = completedSets.where((s) => s).length;
    
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with progress
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF4CAF50)
                      : AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isCompleted 
                          ? const Color(0xFF4CAF50) 
                          : AppTheme.primaryColor)
                          .withOpacity(0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check_rounded, 
                          color: Colors.white, 
                          size: 22,
                        )
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        height: 1.2,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // YouTube video button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF1976D2).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.play_circle_outline,
                    color: Color(0xFF42A5F5),
                    size: 26,
                  ),
                  onPressed: () {
                    // You can add YouTube search functionality here if needed
                  },
                  tooltip: 'Watch demo on YouTube',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
              ),
            ],
          ),
          
          if (isPlaceholder) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA726).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFA726).withOpacity(0.45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFA726).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA726).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded, 
                      color: Color(0xFFFFB74D), 
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Placeholder - substitute with similar exercise',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFFFCC80),
                            fontSize: 12,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 10),
          
          // Exercise details with horizontal info chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[800]!, width: 1),
            ),
            child: Row(
              children: [
                _ResponsiveInfoChip(
                  icon: Icons.repeat_rounded,
                  value: '${exercise.sets}',
                  label: 'sets',
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                _ResponsiveInfoChip(
                  icon: Icons.fitness_center,
                  value: exercise.duration != null
                      ? '${exercise.duration}s'
                      : '${exercise.reps}',
                  label: exercise.duration != null ? 'hold' : 'reps',
                  color: const Color(0xFF4CAF50),
                ),
                if (exercise.rest != null) ...[
                  const SizedBox(width: 12),
                  _ResponsiveInfoChip(
                    icon: Icons.hourglass_bottom_rounded,
                    value: '${exercise.rest}s',
                    label: 'rest',
                    color: const Color(0xFFFF9800),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Circular Timer - Standalone, responsive
          _ResponsiveCircularTimer(
            exercise: exercise,
            onStartIntervalTimer: onStartIntervalTimer,
            isActive: isTimerActive,
            isPaused: isTimerPaused,
            isWorkPhase: isWorkPhase,
            currentPhaseSeconds: currentPhaseSeconds,
            workDuration: workDuration,
            restDuration: restDuration,
            onPause: onPauseTimer,
            onResume: onResumeTimer,
            onStop: onStopTimer,
          ),
          
          const SizedBox(height: 10),
          
          // Sets tracker - Modern 2025 minimal design
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Compact header with inline progress
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.grid_view_rounded,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Sets',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$completedSetsCount',
                      style: TextStyle(
                        color: isCompleted 
                            ? const Color(0xFF4CAF50) 
                            : AppTheme.accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/${exercise.sets}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Single-line set indicators - Always displays all sets in one row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    
                    // Calculate spacing to fit all sets in one line
                    // Responsive spacing based on screen width
                    final spacing = availableWidth > 380 ? 8.0 : 6.0;
                    
                    return Row(
                      children: List.generate(exercise.sets, (setIndex) {
                        final isSetCompleted = completedSets.length > setIndex &&
                            completedSets[setIndex];
                        final isCurrentlyActive = isTimerActive && currentActiveSet == setIndex;
                        
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              right: setIndex < exercise.sets - 1 ? spacing : 0,
                            ),
                            child: _ModernSetPill(
                              setNumber: setIndex + 1,
                              isCompleted: isSetCompleted,
                              isActive: isCurrentlyActive,
                              isWorkPhase: isWorkPhase,
                              onTap: () => onToggleSet(setIndex),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Modern 2025 pill-style set indicator
class _ModernSetPill extends StatefulWidget {
  const _ModernSetPill({
    required this.setNumber,
    required this.isCompleted,
    required this.isActive,
    required this.isWorkPhase,
    required this.onTap,
  });

  final int setNumber;
  final bool isCompleted;
  final bool isActive;
  final bool isWorkPhase;
  final VoidCallback onTap;

  @override
  State<_ModernSetPill> createState() => _ModernSetPillState();
}

class _ModernSetPillState extends State<_ModernSetPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    // Determine state colors
    Color backgroundColor;
    Color textColor;
    IconData? icon;
    
    if (widget.isCompleted) {
      backgroundColor = const Color(0xFF4CAF50).withOpacity(0.2);
      textColor = const Color(0xFF4CAF50);
      icon = Icons.check_circle_rounded;
    } else if (widget.isActive) {
      if (widget.isWorkPhase) {
        backgroundColor = const Color(0xFFFF9800).withOpacity(0.2);
        textColor = const Color(0xFFFF9800);
        icon = Icons.play_circle_filled_rounded;
      } else {
        backgroundColor = const Color(0xFFFFB74D).withOpacity(0.2);
        textColor = const Color(0xFFFFB74D);
        icon = Icons.pause_circle_filled_rounded;
      }
    } else {
      backgroundColor = Colors.grey[800]!.withOpacity(0.3);
      textColor = Colors.grey[500]!;
      icon = null;
    }
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isActive || widget.isCompleted
                  ? textColor.withOpacity(0.5)
                  : Colors.white.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: textColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    size: 18,
                    color: textColor,
                  )
                : Text(
                    '${widget.setNumber}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SetButton extends StatefulWidget {
  const _SetButton({
    required this.setNumber,
    required this.isCompleted,
    required this.isActive,
    required this.isWorkPhase,
    required this.onTap,
  });

  final int setNumber;
  final bool isCompleted;
  final bool isActive;
  final bool isWorkPhase;
  final VoidCallback onTap;

  @override
  State<_SetButton> createState() => _SetButtonState();
}

class _SetButtonState extends State<_SetButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    // Determine state colors
    Color backgroundColor;
    Color borderColor;
    Color? glowColor;
    
    if (widget.isCompleted) {
      // Completed = Green
      backgroundColor = const Color(0xFF4CAF50);
      borderColor = const Color(0xFF4CAF50);
      glowColor = const Color(0xFF4CAF50);
    } else if (widget.isActive) {
      if (widget.isWorkPhase) {
        // Active during hold = Orange/Yellow
        backgroundColor = const Color(0xFFFF9800);
        borderColor = const Color(0xFFFF9800);
        glowColor = const Color(0xFFFF9800);
      } else {
        // Active during rest = Light orange (transitioning)
        backgroundColor = const Color(0xFFFFB74D);
        borderColor = const Color(0xFFFFB74D);
        glowColor = const Color(0xFFFFB74D);
      }
    } else {
      // Normal = Grey
      backgroundColor = Colors.grey[850]!;
      borderColor = Colors.grey[700]!;
      glowColor = null;
    }
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: widget.isActive || widget.isCompleted ? 2 : 1.5,
            ),
            boxShadow: [
              if (glowColor != null)
                BoxShadow(
                  color: glowColor.withOpacity(0.4),
                  blurRadius: widget.isActive ? 12 : 8,
                  spreadRadius: widget.isActive ? 2 : 0,
                  offset: const Offset(0, 3),
                ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: widget.isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 24,
                  )
                : widget.isActive
                    ? Icon(
                        widget.isWorkPhase 
                            ? Icons.fitness_center 
                            : Icons.hourglass_bottom_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
                        '${widget.setNumber}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}

// Modern 2025 timer painter with clean circular progress
class _ModernTimerPainter extends CustomPainter {
  final double workProgress;
  final double restProgress;
  final double strokeWidth;
  final bool isActive;
  final bool isWorkPhase;

  _ModernTimerPainter({
    required this.workProgress,
    required this.restProgress,
    required this.strokeWidth,
    required this.isActive,
    required this.isWorkPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2) - 4;
    const startAngle = -math.pi / 2;
    const fullCircle = 2 * math.pi;

    if (!isActive) {
      // Idle state - subtle ring
      final idlePaint = Paint()
        ..color = AppTheme.primaryColor.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, idlePaint);
      return;
    }

    // Background track (inactive portion)
    final trackPaint = Paint()
      ..color = Colors.grey[850]!.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc - solid color with glow (2025 best practice)
    if (workProgress > 0 || restProgress > 0) {
      final activeProgress = isWorkPhase ? workProgress : restProgress;
      final activeColor = isWorkPhase 
          ? const Color(0xFF4CAF50) 
          : const Color(0xFFFF9800);

      // Draw subtle glow layer behind (depth effect)
      final glowPaint = Paint()
        ..color = activeColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fullCircle * activeProgress,
        false,
        glowPaint,
      );

      // Main solid color progress arc
      final progressPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fullCircle * activeProgress,
        false,
        progressPaint,
      );

      // Bright dot at progress end
      final dotAngle = startAngle + (fullCircle * activeProgress);
      final dotX = center.dx + radius * math.cos(dotAngle);
      final dotY = center.dy + radius * math.sin(dotAngle);
      
      // Outer glow
      final dotGlowPaint = Paint()
        ..color = activeColor.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(
        Offset(dotX, dotY),
        strokeWidth * 0.8,
        dotGlowPaint,
      );
      
      // Inner bright dot
      final dotPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(dotX, dotY),
        strokeWidth * 0.4,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ModernTimerPainter oldDelegate) {
    return oldDelegate.workProgress != workProgress ||
        oldDelegate.restProgress != restProgress ||
        oldDelegate.isWorkPhase != isWorkPhase ||
        oldDelegate.isActive != isActive;
  }
}

// Responsive horizontal info chip
class _ResponsiveInfoChip extends StatelessWidget {
  const _ResponsiveInfoChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 10,
          vertical: isSmallScreen ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 16 : 18,
              color: color,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      color: color.withOpacity(0.7),
                      fontSize: isSmallScreen ? 10 : 11,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
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

