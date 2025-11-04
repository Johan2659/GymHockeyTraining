import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../../core/services/youtube_service.dart';
import '../../application/app_state_provider.dart';
import '../application/extra_session_model.dart';
import '../application/extra_session_provider.dart';
import 'widgets/interval_timer_widget.dart';
import 'widgets/sets_tracker_widget.dart';

/// Extra session player screen - manages workout execution for extra sessions
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
    extends ConsumerState<ExtraSessionPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  final Map<String, List<bool>> _completedSets = {};
  bool _startLogged = false;
  bool _isFinishing = false;
  int _currentPage = 0;

  // Interval timer state
  Timer? _intervalTimer;
  bool _isIntervalTimerActive = false;
  bool _isIntervalTimerPaused = false;
  bool _isWorkPhase = true;
  int _currentPhaseSeconds = 0;
  int _workDuration = 0;
  int _restDuration = 0;
  int _currentSet = 0;
  String? _currentIntervalExerciseId;

  // Page transition animation
  late AnimationController _pageTransitionController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Session duration tracking
  Timer? _durationTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startDurationTimer();

    // Initialize page transition animation (fast and snappy)
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 200), // Reduced from 300ms
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logExtraStart();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _intervalTimer?.cancel();
    _durationTimer?.cancel();
    _pageTransitionController.dispose();
    super.dispose();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _navigateToPage(int newPage) async {
    if (newPage == _currentPage) return;

    final direction = newPage > _currentPage
        ? -1.0
        : 1.0; // -1 = slide left (next), 1 = slide right (prev)

    // Set up slide out animation
    setState(() {
      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(direction, 0),
      ).animate(CurvedAnimation(
        parent: _pageTransitionController,
        curve: Curves.easeInQuart, // Snappier curve
      ));
      _fadeAnimation = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _pageTransitionController,
        curve: Curves.easeIn,
      ));
    });

    // Slide out old content
    await _pageTransitionController.forward(from: 0);

    // Update page content
    setState(() {
      _currentPage = newPage;

      // Set up slide in animation (from opposite direction)
      _slideAnimation = Tween<Offset>(
        begin: Offset(-direction, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _pageTransitionController,
        curve: Curves.easeOutQuart, // Snappier curve
      ));
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _pageTransitionController,
        curve: Curves.easeOut,
      ));
    });

    // Slide in new content
    await _pageTransitionController.forward(from: 0);
  }

  // =========================================================================
  // State Management Methods
  // =========================================================================

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
    final wasCompleted = _completedSets[exercise.id]![setIndex];

    // Always allow toggling - user can check/uncheck freely
    setState(() {
      _completedSets[exercise.id]![setIndex] = !wasCompleted;
    });

    // Smart timer logic: Only start/reset timer when MARKING as complete (not unmarking)
    if (!wasCompleted) {
      // User just completed this set -> Start/restart rest timer
      _startRestTimer(exercise, setIndex);
    }
    // If they're UNmarking a set, the timer keeps running
    // They can freely uncheck if they realize they didn't finish the set properly
  }

  void _startRestTimer(Exercise exercise, int setNumber) {
    _stopIntervalTimer();

    final restDuration = exercise.rest ?? 40;

    setState(() {
      _isIntervalTimerActive = true;
      _isIntervalTimerPaused = false;
      _isWorkPhase = false; // Start directly in REST phase
      _currentPhaseSeconds = 0;
      _workDuration = 0;
      _restDuration = restDuration;
      _currentSet = setNumber;
      _currentIntervalExerciseId = exercise.id;
    });

    _intervalTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isIntervalTimerPaused) {
        _currentPhaseSeconds++;

        // Check if rest is complete
        if (_currentPhaseSeconds >= _restDuration * 10) {
          _stopIntervalTimer();
          setState(() {});
        } else {
          setState(() {});
        }
      }
    });
  }

  // =========================================================================
  // Interval Timer Methods
  // =========================================================================

  void _startIntervalTimer(Exercise exercise, int setNumber) {
    _stopIntervalTimer();

    final workDuration = exercise.duration ?? 20;
    final restDuration = exercise.rest ?? 40;

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

        // Check phase transitions
        if (_isWorkPhase && _currentPhaseSeconds >= _workDuration * 10) {
          // Switch to rest phase
          _isWorkPhase = false;
          _currentPhaseSeconds = 0;
        } else if (!_isWorkPhase &&
            _currentPhaseSeconds >= _restDuration * 10) {
          // Rest complete - mark set as done and move to next
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
              } else {
                // All sets complete
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

  // =========================================================================
  // Session Management Methods
  // =========================================================================

  Future<void> _logExtraStart() async {
    if (_startLogged) return;
    _startLogged = true;

    try {
      await ref.read(startExtraActionProvider(widget.extraId).future);
    } catch (error) {
      debugPrint('Failed to log extra start: $error');
    }
  }

  Future<void> _finishSession(ResolvedExtraSession session) async {
    if (_isFinishing) return;

    setState(() {
      _isFinishing = true;
    });

    // Stop the timer
    _durationTimer?.cancel();

    try {
      // Save exercise performances for all exercises in the extra session
      // This ensures category progress updates correctly
      for (final exercise in session.exercises) {
        try {
          // Create performance sets - for extras, create one record per set
          final performanceSets = <ExerciseSetPerformance>[];
          for (int i = 0; i < exercise.sets; i++) {
            performanceSets.add(ExerciseSetPerformance(
              setNumber: i + 1,
              reps: exercise.reps,
              weight: null, // Extras don't track weight
              completed: true,
            ));
          }
          
          final performance = ExercisePerformance(
            id: '${exercise.id}_${DateTime.now().millisecondsSinceEpoch}',
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            programId: session.extra.id,
            week: 0, // Extras don't have weeks
            session: 0, // Extras don't have sessions
            timestamp: DateTime.now(),
            sets: performanceSets,
          );
          
          await ref.read(saveExercisePerformanceActionProvider(performance).future);
        } catch (e) {
          // Log but don't fail the entire session if one exercise fails to save
          print('Warning: Failed to save performance for ${exercise.name}: $e');
        }
      }
      
      await ref.read(completeExtraActionProvider(
        session.extra.id,
        session.extra.xpReward,
        durationSeconds: _elapsedSeconds,
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
              onPressed: () => Navigator.of(context).pop(),
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

  // =========================================================================
  // Build Methods
  // =========================================================================

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    extraTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(_elapsedSeconds),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Extras Session',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 26),
            onPressed: () => context.pop(),
            tooltip: 'Exit session',
          ),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error),
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

    // Get current exercise data
    final exercise = exercises[_currentPage];
    final isPlaceholder = session.isPlaceholder(exercise);
    _initializeExerciseSets(exercise);
    final completedSets = _completedSets[exercise.id] ?? [];

    return Column(
      children: [
        // ============================================================
        // SECTION 1: PLACEHOLDER WARNING (if needed)
        // ============================================================
        if (session.hasPlaceholders) _buildPlaceholderWarning(context),

        // ============================================================
        // SECTION 2: MAIN CONTENT AREA - Direct rendering, no PageView!
        // ============================================================
        Expanded(
          child: Stack(
            children: [
              // Main content with swipe gesture
              GestureDetector(
                // Swipe to change exercises (right = previous, left = next)
                // Very low threshold (200) for easy swiping, always allow navigation
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity > 200 && _currentPage > 0) {
                    // Swipe right - go to previous
                    _navigateToPage(_currentPage - 1);
                  } else if (velocity < -200 &&
                      _currentPage < exercises.length - 1) {
                    // Swipe left - go to next
                    _navigateToPage(_currentPage + 1);
                  }
                },
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ════════════════════════════════════════════════════════
                          // 2.1: EXERCISE HEADER (name + demo button)
                          // ════════════════════════════════════════════════════════
                          const SizedBox(height: 8),
                          _buildExerciseHeader(
                              context, exercise, isPlaceholder),

                          // ════════════════════════════════════════════════════════
                          // 2.2: PLACEHOLDER CHIP (if needed)
                          // ════════════════════════════════════════════════════════
                          if (isPlaceholder) ...[
                            const SizedBox(height: 8),
                            _buildPlaceholderChip(context),
                          ],

                          // ════════════════════════════════════════════════════════
                          // 2.3: DETAILS ROW (6 sets, 20s hold, 40s rest)
                          // ════════════════════════════════════════════════════════
                          const SizedBox(height: 16),
                          _buildExerciseDetails(context, exercise),

                          // ════════════════════════════════════════════════════════
                          // FLEXIBLE SPACE - Timer centered between details and sets
                          // ════════════════════════════════════════════════════════
                          const Spacer(flex: 2),

                          // ════════════════════════════════════════════════════════
                          // 2.4: INTERVAL TIMER (big circle) - THE FOCAL POINT
                          // ════════════════════════════════════════════════════════
                          _buildIntervalTimer(context, exercise),

                          // ════════════════════════════════════════════════════════
                          // FLEXIBLE SPACE - Timer centered between details and sets
                          // ════════════════════════════════════════════════════════
                          const Spacer(flex: 2),

                          // ════════════════════════════════════════════════════════
                          // 2.5: SETS TRACKER - Moved to bottom sticky section
                          // (Now grouped with controls for better UX)
                          // ════════════════════════════════════════════════════════
                          _buildSetsTracker(context, exercise, completedSets),

                          // ════════════════════════════════════════════════════════
                          // SWIPE INDICATORS - Simple grey dots
                          // ════════════════════════════════════════════════════════
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              exercises.length,
                              (index) {
                                final isActive = index == _currentPage;
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: isActive ? 10 : 8,
                                  height: isActive ? 10 : 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey
                                        .withOpacity(isActive ? 0.6 : 0.3),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ============================================================
        // SECTION 3: BOTTOM CONTROLS (Fixed at bottom)
        // - Exercises Progress Bar
        // - Mark Complete / Next Exercise Button
        // ============================================================
        _buildControls(context, session),
      ],
    );
  }

  Widget _buildPlaceholderWarning(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildControls(BuildContext context, ResolvedExtraSession session) {
    final exercises = session.exercises;
    final currentExercise = exercises[_currentPage];
    final isCompleted = _isExerciseCompleted(currentExercise);
    final isLastPage = _currentPage == exercises.length - 1;
    final completedCount = _getCompletedExerciseCount(exercises);
    final allCompleted = completedCount == exercises.length;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          (screenWidth * 0.045).clamp(16.0, 20.0),
          (screenWidth * 0.012).clamp(4.0, 6.0),
          (screenWidth * 0.045).clamp(16.0, 20.0),
          (screenWidth * 0.022).clamp(8.0, 10.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: (screenWidth * 0.038).clamp(14.0, 16.0),
          vertical: (screenWidth * 0.028).clamp(10.0, 12.0),
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar row
            _buildProgressBar(exercises, completedCount, allCompleted),
            SizedBox(height: (screenWidth * 0.025).clamp(9.0, 11.0)),
            // Navigation buttons
            _buildNavigationButtons(
                isCompleted, isLastPage, allCompleted, session),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
      List<Exercise> exercises, int completedCount, bool allCompleted) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        // Exercise counter badge with icon
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: (screenWidth * 0.032).clamp(12.0, 14.0),
            vertical: (screenWidth * 0.018).clamp(6.5, 8.0),
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.45),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center,
                color: AppTheme.primaryColor,
                size: (screenWidth * 0.042).clamp(15.0, 17.0),
              ),
              SizedBox(width: (screenWidth * 0.016).clamp(6.0, 7.0)),
              Text(
                '${_currentPage + 1}/${exercises.length}',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: (screenWidth * 0.038).clamp(14.0, 15.5),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: (screenWidth * 0.028).clamp(10.0, 12.0)),
        // Progress bar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Exercises Progress',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: (screenWidth * 0.029).clamp(10.5, 12.0),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  height: 1,
                ),
              ),
              SizedBox(height: (screenWidth * 0.012).clamp(4.5, 5.5)),
              // Custom progress bar with segments
              SizedBox(
                height: (screenWidth * 0.012).clamp(4.5, 5.5),
                child: Row(
                  children: List.generate(exercises.length, (index) {
                    final exercise = exercises[index];
                    final isFullyCompleted = _isExerciseCompleted(exercise);
                    final isCurrent = index == _currentPage;
                    final isPast = index < _currentPage;
                    final isPartiallyDone = isPast && !isFullyCompleted;

                    Color segmentColor;
                    if (isCurrent) {
                      // Current exercise - solid blue
                      segmentColor = const Color(0xFF42A5F5);
                    } else if (isFullyCompleted) {
                      // Fully completed - green
                      segmentColor = const Color(0xFF4CAF50);
                    } else if (isPartiallyDone) {
                      // Skipped/partially done - orange (attention but not negative)
                      segmentColor = Colors.orange;
                    } else {
                      // Future exercise - low opacity blue
                      segmentColor = const Color(0xFF42A5F5).withOpacity(0.25);
                    }

                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: index < exercises.length - 1 ? 2 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: segmentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(bool isCompleted, bool isLastPage,
      bool allCompleted, ResolvedExtraSession session) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        if (_currentPage > 0)
          Expanded(
            flex: 2,
            child: _buildNavigationButton(
              label: 'Previous',
              icon: Icons.arrow_back_ios_new_rounded,
              isPrimary: false,
              onTap: () => _navigateToPage(_currentPage - 1),
            ),
          ),
        if (_currentPage > 0)
          SizedBox(width: (screenWidth * 0.028).clamp(10.0, 12.0)),
        Expanded(
          flex: 3,
          child: _buildNavigationButton(
            label: _getControlLabel(isCompleted, isLastPage, allCompleted),
            icon: !isLastPage
                ? Icons.arrow_forward_ios_rounded
                : (allCompleted ? Icons.check_circle_outline_rounded : null),
            isPrimary: true, // Always enabled
            isLoading: _isFinishing,
            onTap: isLastPage
                ? (!_isFinishing ? () => _finishSession(session) : null)
                : () => _navigateToPage(_currentPage + 1),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required String label,
    IconData? icon,
    required bool isPrimary,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.primaryColor : Colors.grey[800],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPrimary
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: (screenWidth * 0.035).clamp(13.0, 15.0),
              horizontal: (screenWidth * 0.045).clamp(16.0, 18.0),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: (screenWidth * 0.052).clamp(19.0, 22.0),
                      width: (screenWidth * 0.052).clamp(19.0, 22.0),
                      child: const CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon == Icons.arrow_back_ios_new_rounded) ...[
                          Icon(icon,
                              size: (screenWidth * 0.045).clamp(16.0, 18.0),
                              color: Colors.white),
                          SizedBox(
                              width: (screenWidth * 0.018).clamp(6.5, 8.0)),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: (screenWidth * 0.04).clamp(14.5, 16.0),
                            fontWeight: FontWeight.w700,
                            height: 1,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (icon == Icons.arrow_forward_ios_rounded) ...[
                          SizedBox(
                              width: (screenWidth * 0.018).clamp(6.5, 8.0)),
                          Icon(icon,
                              size: (screenWidth * 0.045).clamp(16.0, 18.0),
                              color: Colors.white),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _getControlLabel(
      bool isCompleted, bool isLastPage, bool allCompleted) {
    if (isLastPage) return 'Finish Session';
    return 'Next Exercise';
  }

  // =========================================================================
  // Error and Empty State Widgets
  // =========================================================================

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
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
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade600),
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
            Icon(Icons.fitness_center, size: 64, color: Colors.grey.shade600),
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

  // =========================================================================
  // Helper Widget Builders - All in one place for easy maintenance
  // =========================================================================

  Widget _buildExerciseHeader(
      BuildContext context, Exercise exercise, bool isPlaceholder) {
    final screenWidth = MediaQuery.of(context).size.width;
    final badgeSize = (screenWidth * 0.11).clamp(40.0, 48.0);
    final titleSize = (screenWidth * 0.056).clamp(20.0, 24.0);
    final isCompleted = _isExerciseCompleted(exercise);

    return Row(
      children: [
        Container(
          width: badgeSize,
          height: badgeSize,
          decoration: BoxDecoration(
            color:
                isCompleted ? const Color(0xFF4CAF50) : AppTheme.primaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: (isCompleted
                        ? const Color(0xFF4CAF50)
                        : AppTheme.primaryColor)
                    .withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check_rounded,
                    color: Colors.white, size: badgeSize * 0.5)
                : Text(
                    '${_currentPage + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: badgeSize * 0.44,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
          ),
        ),
        SizedBox(width: (screenWidth * 0.032).clamp(12.0, 14.0)),
        Expanded(
          child: Text(
            exercise.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: titleSize,
              height: 1.15,
              letterSpacing: -0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.play_circle_outline,
                color: const Color(0xFF42A5F5),
                size: (screenWidth * 0.08).clamp(28.0, 34.0),
              ),
              onPressed: exercise.youtubeQuery.isNotEmpty
                  ? () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening YouTube...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      final success = await YouTubeService.searchYouTube(
                          exercise.youtubeQuery);
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Unable to open YouTube. Please check your internet connection.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  : null,
              padding: EdgeInsets.all((screenWidth * 0.018).clamp(6.0, 8.0)),
              constraints: BoxConstraints(
                minWidth: (screenWidth * 0.11).clamp(40.0, 46.0),
                minHeight: (screenWidth * 0.11).clamp(40.0, 46.0),
              ),
            ),
            Text(
              'Watch demo',
              style: TextStyle(
                color: const Color(0xFF42A5F5),
                fontSize: (screenWidth * 0.028).clamp(10.0, 11.0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholderChip(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.032).clamp(12.0, 14.0),
        vertical: (screenWidth * 0.022).clamp(8.0, 10.0),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFFFA726).withOpacity(0.45), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: const Color(0xFFFFB74D),
            size: (screenWidth * 0.042).clamp(15.0, 17.0),
          ),
          SizedBox(width: (screenWidth * 0.018).clamp(7.0, 8.0)),
          Text(
            'Placeholder exercise',
            style: TextStyle(
              color: const Color(0xFFFFCC80),
              fontSize: (screenWidth * 0.032).clamp(11.5, 13.0),
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseDetails(BuildContext context, Exercise exercise) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.038).clamp(14.0, 16.0),
        vertical: (screenWidth * 0.026).clamp(10.0, 12.0),
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoChip(
            icon: Icons.repeat_rounded,
            value: '${exercise.sets}',
            label: 'sets',
            color: AppTheme.primaryColor,
            screenWidth: screenWidth,
          ),
          Container(
            width: 1.5,
            height: (screenWidth * 0.08).clamp(30.0, 34.0),
            color: Colors.grey[800],
          ),
          _buildInfoChip(
            icon: Icons.fitness_center,
            value: exercise.duration != null
                ? '${exercise.duration}s'
                : '${exercise.reps}',
            label: exercise.duration != null ? 'hold' : 'reps',
            color: const Color(0xFF4CAF50),
            screenWidth: screenWidth,
          ),
          if (exercise.rest != null) ...[
            Container(
              width: 1.5,
              height: (screenWidth * 0.08).clamp(30.0, 34.0),
              color: Colors.grey[800],
            ),
            _buildInfoChip(
              icon: Icons.hourglass_bottom_rounded,
              value: '${exercise.rest}s',
              label: 'rest',
              color: const Color(0xFFFF9800),
              screenWidth: screenWidth,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required double screenWidth,
  }) {
    final iconSize = (screenWidth * 0.052).clamp(18.0, 22.0);
    final valueSize = (screenWidth * 0.042).clamp(15.0, 18.0);
    final labelSize = (screenWidth * 0.026).clamp(9.5, 11.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: color),
        SizedBox(width: (screenWidth * 0.016).clamp(6.0, 7.0)),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: valueSize,
                fontWeight: FontWeight.w800,
                height: 1,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: (screenWidth * 0.006).clamp(2.0, 3.0)),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.75),
                fontSize: labelSize,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntervalTimer(BuildContext context, Exercise exercise) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseTimerSize = (screenWidth * 0.65).clamp(220.0, 320.0);
    final timerSize = screenHeight < 700
        ? (baseTimerSize * 0.85).clamp(200.0, 260.0)
        : baseTimerSize;

    return Center(
      child: SizedBox(
        height: timerSize,
        width: timerSize,
        child: IntervalTimerWidget(
          exercise: exercise,
          onStart: () {
            final completedSets = _completedSets[exercise.id] ?? [];
            final nextSet = completedSets.indexWhere((s) => !s);
            if (nextSet >= 0) {
              _startIntervalTimer(exercise, nextSet);
            }
          },
          isActive: _isIntervalTimerActive &&
              _currentIntervalExerciseId == exercise.id,
          isPaused: _isIntervalTimerPaused,
          isWorkPhase: _isWorkPhase,
          currentPhaseSeconds: _currentPhaseSeconds,
          workDuration: _workDuration,
          restDuration: _restDuration,
          onPause: _pauseIntervalTimer,
          onResume: _resumeIntervalTimer,
          onStop: _stopIntervalTimer,
        ),
      ),
    );
  }

  Widget _buildSetsTracker(
      BuildContext context, Exercise exercise, List<bool> completedSets) {
    return SetsTrackerWidget(
      totalSets: exercise.sets,
      completedSets: completedSets,
      currentActiveSet:
          _isIntervalTimerActive && _currentIntervalExerciseId == exercise.id
              ? _currentSet
              : -1,
      isTimerActive:
          _isIntervalTimerActive && _currentIntervalExerciseId == exercise.id,
      isWorkPhase: _isWorkPhase,
      onToggleSet: (setIndex) => _toggleSet(exercise, setIndex),
    );
  }
}
