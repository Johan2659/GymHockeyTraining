import 'dart:async';r
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../application/app_state_provider.dart';
import '../application/extra_session_model.dart';
import '../application/extra_session_provider.dart';
import 'widgets/exercise_card_widget.dart';

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
    extends ConsumerState<ExtraSessionPlayerScreen> {
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
    setState(() {
      _completedSets[exercise.id]![setIndex] =
          !_completedSets[exercise.id]![setIndex];
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

    return Column(
      children: [
        // Placeholder warning banner
        if (session.hasPlaceholders) _buildPlaceholderWarning(context),
        // Exercise pages
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

              _initializeExerciseSets(exercise);

              final completedSets = _completedSets[exercise.id] ?? [];
              final isCompleted = _isExerciseCompleted(exercise);

              return ExerciseCardWidget(
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
                isTimerActive: _isIntervalTimerActive &&
                    _currentIntervalExerciseId == exercise.id,
                isTimerPaused: _isIntervalTimerPaused,
                isWorkPhase: _isWorkPhase,
                currentPhaseSeconds: _currentPhaseSeconds,
                workDuration: _workDuration,
                restDuration: _restDuration,
                currentActiveSet: _isIntervalTimerActive &&
                        _currentIntervalExerciseId == exercise.id
                    ? _currentSet
                    : -1,
                onPauseTimer: _pauseIntervalTimer,
                onResumeTimer: _resumeIntervalTimer,
                onStopTimer: _stopIntervalTimer,
              );
            },
          ),
        ),
        // Bottom controls
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

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar row
            _buildProgressBar(exercises, completedCount, allCompleted),
            const SizedBox(height: 8),
            // Navigation buttons
            _buildNavigationButtons(isCompleted, isLastPage, allCompleted, session),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
      List<Exercise> exercises, int completedCount, bool allCompleted) {
    return Row(
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
                  value: exercises.isNotEmpty
                      ? (_currentPage + 1) / exercises.length
                      : 0,
                  backgroundColor: Colors.grey[850],
                  valueColor: AlwaysStoppedAnimation(
                    allCompleted
                        ? const Color(0xFF4CAF50)
                        : AppTheme.accentColor,
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
            color: (allCompleted
                    ? const Color(0xFF4CAF50)
                    : AppTheme.accentColor)
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (allCompleted
                      ? const Color(0xFF4CAF50)
                      : AppTheme.accentColor)
                  .withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                allCompleted ? Icons.check_circle : Icons.fitness_center,
                color: allCompleted
                    ? const Color(0xFF4CAF50)
                    : AppTheme.accentColor,
                size: 14,
              ),
              const SizedBox(width: 5),
              Text(
                '$completedCount',
                style: TextStyle(
                  color: allCompleted
                      ? const Color(0xFF4CAF50)
                      : AppTheme.accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(
      bool isCompleted, bool isLastPage, bool allCompleted, ResolvedExtraSession session) {
    return Row(
      children: [
        if (_currentPage > 0)
          Expanded(
            flex: 2,
            child: _buildNavigationButton(
              label: 'Previous',
              icon: Icons.arrow_back_ios_new_rounded,
              isPrimary: false,
              onTap: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        if (_currentPage > 0) const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: _buildNavigationButton(
            label: _getControlLabel(isCompleted, isLastPage, allCompleted),
            icon: isCompleted && !isLastPage
                ? Icons.arrow_forward_ios_rounded
                : null,
            isPrimary: isCompleted,
            isLoading: _isFinishing,
            onTap: isCompleted
                ? isLastPage
                    ? (allCompleted && !_isFinishing
                        ? () => _finishSession(session)
                        : null)
                    : () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      }
                : null,
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
    return Container(
      decoration: BoxDecoration(
        color: isPrimary
            ? AppTheme.primaryColor
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon == Icons.arrow_back_ios_new_rounded) ...[
                          Icon(icon, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (icon == Icons.arrow_forward_ios_rounded) ...[
                          const SizedBox(width: 6),
                          Icon(icon, size: 16, color: Colors.white),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _getControlLabel(bool isCompleted, bool isLastPage, bool allCompleted) {
    if (!isCompleted) return 'Mark Complete';
    if (isLastPage && allCompleted) return 'Finish Session';
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
}
