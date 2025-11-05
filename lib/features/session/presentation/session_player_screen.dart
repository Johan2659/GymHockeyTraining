import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di.dart';
import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../../core/services/youtube_service.dart';
import '../../application/app_state_provider.dart';
import 'widgets/bonus_exercise_badge.dart';

part 'session_player_screen.g.dart';

// Number picker widget for reps and weight
class NumberPickerDialog extends StatefulWidget {
  final String title;
  final int minValue;
  final int maxValue;
  final double initialValue;
  final bool isDecimal;

  const NumberPickerDialog({
    super.key,
    required this.title,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    this.isDecimal = false,
  });

  @override
  State<NumberPickerDialog> createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<NumberPickerDialog> {
  late FixedExtentScrollController _scrollController;
  late double _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    final int initialIndex = widget.isDecimal
        ? ((widget.initialValue - widget.minValue) * 2).round()
        : (widget.initialValue - widget.minValue).toInt();
    _scrollController = FixedExtentScrollController(
      initialItem: initialIndex.clamp(0, _getItemCount() - 1),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _getItemCount() {
    if (widget.isDecimal) {
      return ((widget.maxValue - widget.minValue) * 2 + 1).toInt();
    }
    return widget.maxValue - widget.minValue + 1;
  }

  double _getValueAtIndex(int index) {
    if (widget.isDecimal) {
      return widget.minValue + (index * 0.5);
    }
    return (widget.minValue + index).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Selection highlight
                  Center(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  // Scrollable picker
                  ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedValue = _getValueAtIndex(index);
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: _getItemCount(),
                      builder: (context, index) {
                        final value = _getValueAtIndex(index);
                        final isSelected = value == _selectedValue;
                        return Center(
                          child: Text(
                            widget.isDecimal
                                ? value.toStringAsFixed(1)
                                : value.toInt().toString(),
                            style: TextStyle(
                              fontSize: isSelected ? 28 : 20,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey[400],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[700]!),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selectedValue),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen> 
    with TickerProviderStateMixin {
  final Set<String> _completedExercises = <String>{};
  bool _isFinishing = false;
  bool _bonusChallengeCompleted = false;
  bool _sessionStarted = false;

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int _restTimerDuration = 0; // Store original duration for restart
  bool _isRestTimerRunning = false;
  bool _isRestTimerPaused = false;
  String? _currentRestExerciseId; // Track which exercise is on rest

  // Performance tracking state
  // Map<exerciseId, List<Map<String, dynamic>>> to store reps, weight, and completion per set
  final Map<String, List<Map<String, dynamic>>> _exercisePerformances = {};

  // Track last used weight for each exercise (to auto-fill next sets)
  final Map<String, double> _lastWeightUsed = {};

  // Session duration tracking
  Timer? _durationTimer;
  int _elapsedSeconds = 0;

  // Track expanded instructions per exercise
  final Set<String> _expandedInstructions = <String>{};
  
  // Animation controllers for page entrance
  late AnimationController _titleAnimationController;
  late AnimationController _statsAnimationController;
  late Animation<double> _titleSlideAnimation;
  late Animation<double> _titleScaleAnimation;
  late Animation<double> _statsAnimation;
  
  // Track if ice flash has already been shown (only once ever)
  bool _hasShownIceFlash = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startDurationTimer();
    
    // Initialize animation controllers
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Puck drop: slide from above + scale
    _titleSlideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _titleScaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    // Stats shimmer animation
    _statsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.easeOut,
    ));
    
    // Log session start event on next frame to ensure ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logSessionStart();
      _restoreSessionState();
      // Trigger initial animation
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _triggerPageAnimations();
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _restTimer?.cancel();
    _durationTimer?.cancel();
    _titleAnimationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }
  
  void _triggerPageAnimations() {
    // Always play puck drop on title
    _titleAnimationController.forward(from: 0.0);
    
    // Ice flash on stats ONLY the very first time
    if (!_hasShownIceFlash) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _statsAnimationController.forward(from: 0.0);
          _hasShownIceFlash = true; // Mark as shown forever
        }
      });
    } else {
      // If already shown, set stats to fully visible immediately
      _statsAnimationController.value = 1.0;
    }
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

  Future<void> _restoreSessionState() async {
    try {
      final sessionInProgress =
          await ref.read(sessionInProgressProvider.future);

      if (sessionInProgress != null &&
          sessionInProgress.programId == widget.programId &&
          sessionInProgress.week == int.parse(widget.week) &&
          sessionInProgress.session == int.parse(widget.session)) {
        // Restore state
        setState(() {
          _currentPage = sessionInProgress.currentPage;
          _completedExercises.addAll(sessionInProgress.completedExercises);

          // Restore exercise performances
          sessionInProgress.exercisePerformances.forEach((key, value) {
            if (value is List) {
              _exercisePerformances[key] = List<Map<String, dynamic>>.from(
                  value.map((item) => Map<String, dynamic>.from(item as Map)));
            }
          });

          // Restore last weight used
          if (sessionInProgress.lastWeightUsed != null) {
            _lastWeightUsed.addAll(sessionInProgress.lastWeightUsed!);
          }
        });

        // Jump to the saved page
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(_currentPage);
          }
        });

        debugPrint('Session state restored from saved progress');
      }
    } catch (error) {
      debugPrint('Failed to restore session state: $error');
    }
  }

  Future<void> _saveSessionStateAndExit() async {
    try {
      // Convert exercise performances to JSON-serializable format
      final Map<String, dynamic> performancesJson = {};
      _exercisePerformances.forEach((key, value) {
        performancesJson[key] = value;
      });

      final sessionInProgress = SessionInProgress(
        programId: widget.programId,
        week: int.parse(widget.week),
        session: int.parse(widget.session),
        currentPage: _currentPage,
        completedExercises: _completedExercises.toList(),
        exercisePerformances: performancesJson,
        lastWeightUsed: Map<String, double>.from(_lastWeightUsed),
        pausedAt: DateTime.now(),
      );

      final success = await ref
          .read(saveSessionInProgressActionProvider(sessionInProgress).future);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.save, color: Colors.white),
                SizedBox(width: 8),
                Text('Session saved! You can resume later.'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back to hub
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/');
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save session: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref
        .watch(_sessionProvider(widget.programId, widget.week, widget.session));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.2),
                AppTheme.primaryColor.withOpacity(0.12),
                AppTheme.primaryColor.withOpacity(0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 0.7, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(_elapsedSeconds),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 24),
            onPressed: () => _showSessionInfo(context, sessionAsync.value),
            tooltip: 'Session Info',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 24),
            tooltip: 'More options',
            onSelected: (value) {
              if (value == 'save_exit') {
                _saveSessionStateAndExit();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save_exit',
                child: Row(
                  children: [
                    Icon(Icons.save_outlined, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text('Pause & Save'),
                  ],
                ),
              ),
            ],
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

    return Stack(
      children: [
        // Main content
        Column(
          children: [
            // Session header breadcrumb
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[850]!, width: 1),
                ),
              ),
              child: Text(
                'Exercise ${_currentPage + 1} of $totalCount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[400],
                  letterSpacing: 0.8,
                ),
              ),
            ),

            // Horizontal swipeable exercise pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const PageScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ).applyTo(const BouncingScrollPhysics()),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _triggerPageAnimations();
                },
                itemCount: totalCount,
                itemBuilder: (context, index) {
                  return _buildExercisePage(
                      context, session.blocks[index], index + 1);
                },
              ),
            ),

            // Bottom action bar (only for last page - finish session)
            if (isLastPage)
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    border: Border(
                      top: BorderSide(color: Colors.grey[800]!, width: 1),
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: isAllCompleted && !_isFinishing
                        ? _finishSession
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isAllCompleted ? const Color(0xFF4CAF50) : Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: _isFinishing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            isAllCompleted
                                ? 'FINISH SESSION'
                                : 'COMPLETE ALL EXERCISES',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),

        // Sticky Rest Timer at bottom (independent overlay)
        if (_isRestTimerRunning)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStickyRestTimer(context),
          ),
      ],
    );
  }

  Widget _buildPageIndicator(int count) {
    final sessionAsync = ref
        .watch(_sessionProvider(widget.programId, widget.week, widget.session));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          Color dotColor;

          if (sessionAsync.hasValue) {
            final exerciseId = sessionAsync.value!.blocks[index].exerciseId;
            final isBonus = sessionAsync.value!.blocks.isNotEmpty &&
                sessionAsync.value!.blocks.last.exerciseId == exerciseId;

            if (isBonus) {
              dotColor = Colors.amber;
            } else {
              final isCompleted = _completedExercises.contains(exerciseId);
              final hasPerformance =
                  _exercisePerformances.containsKey(exerciseId);
              final allSetsCompleted = _areAllSetsCompleted(exerciseId);

              if (isCompleted || allSetsCompleted) {
                dotColor = const Color(0xFF4CAF50);
              } else if (hasPerformance) {
                final sets = _exercisePerformances[exerciseId] ?? [];
                final hasCompletedSets =
                    sets.any((set) => set['completed'] as bool);

                if (hasCompletedSets) {
                  dotColor = Colors.orange;
                } else if (index == _currentPage) {
                  dotColor = AppTheme.primaryColor;
                } else {
                  dotColor = Colors.grey[800]!;
                }
              } else if (index == _currentPage) {
                dotColor = AppTheme.primaryColor;
              } else {
                dotColor = Colors.grey[800]!;
              }
            }
          } else {
            dotColor = index == _currentPage
                ? AppTheme.primaryColor
                : Colors.grey[800]!;
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: index == _currentPage ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              borderRadius: BorderRadius.circular(4),
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

  // Helper method to check if all sets are completed for an exercise
  bool _areAllSetsCompleted(String exerciseId) {
    final sets = _exercisePerformances[exerciseId];
    if (sets == null || sets.isEmpty) return false;
    return sets.every((set) => set['completed'] as bool);
  }

  Widget _buildExercisePage(
      BuildContext context, ExerciseBlock block, int exerciseNumber) {
    final exerciseAsync = ref.watch(_exerciseProvider(block.exerciseId));
    final sessionAsync = ref
        .watch(_sessionProvider(widget.programId, widget.week, widget.session));

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

        // Check if this is the bonus exercise (last exercise in the session)
        // treating last exercise as bonus
        final isBonus = sessionAsync.value != null &&
            sessionAsync.value!.blocks.isNotEmpty &&
            sessionAsync.value!.blocks.last.exerciseId == exercise.id;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bonus badge (if applicable)
              if (isBonus) ...[
                const BonusExerciseBadge(),
                const SizedBox(height: 10),
              ],

              // Exercise header with integrated actions + Puck Drop animation
              AnimatedBuilder(
                animation: _titleAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _titleSlideAnimation.value),
                    child: Transform.scale(
                      scale: _titleScaleAnimation.value,
                      child: Opacity(
                        opacity: _titleAnimationController.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: _buildExerciseHeader(context, exercise),
              ),

              const SizedBox(height: 20),

              // Prescribed details (no border, just spacing) + Ice Flash animation
              AnimatedBuilder(
                animation: _statsAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _statsAnimation.value,
                    child: Transform.scale(
                      scale: 0.95 + (_statsAnimation.value * 0.05),
                      child: child,
                    ),
                  );
                },
                child: _buildPrescribedDetails(context, exercise),
              ),

              // Last performance history
              lastPerfAsync.when(
                data: (lastPerf) => lastPerf != null
                    ? _buildLastPerformance(context, lastPerf)
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Performance input section
              _buildPerformanceInput(context, exercise),

              const SizedBox(height: 20),

              // Mark as done and go to next button
              SizedBox(
                width: double.infinity,
                child: Builder(
                  builder: (context) {
                    final allSetsCompleted =
                        _areAllSetsCompleted(exercise.id);
                    final isCompleted =
                        _completedExercises.contains(exercise.id);

                    return ElevatedButton.icon(
                      onPressed: isCompleted
                          ? null
                          : () =>
                              _saveExercisePerformanceAndNext(exercise),
                      icon: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : (allSetsCompleted
                                ? Icons.check_circle
                                : Icons.arrow_forward),
                        size: 22,
                      ),
                      label: Text(
                        isCompleted
                            ? 'COMPLETED'
                            : (allSetsCompleted
                                ? 'NEXT EXERCISE ✓'
                                : 'NEXT EXERCISE'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (isCompleted || allSetsCompleted)
                            ? Colors.green
                            : AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                    );
                  },
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

  void _startRestTimer(int duration, String exerciseId) {
    _stopRestTimer();

    setState(() {
      _isRestTimerRunning = true;
      _isRestTimerPaused = false;
      _restSecondsRemaining = duration;
      _restTimerDuration = duration;
      _currentRestExerciseId = exerciseId;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRestTimerPaused) {
        setState(() {
          if (_restSecondsRemaining > 0) {
            _restSecondsRemaining--;
          } else {
            _stopRestTimer();
          }
        });
      }
    });
  }

  void _pauseRestTimer() {
    setState(() {
      _isRestTimerPaused = true;
    });
  }

  void _resumeRestTimer() {
    setState(() {
      _isRestTimerPaused = false;
    });
  }

  void _restartRestTimer() {
    setState(() {
      _restSecondsRemaining = _restTimerDuration;
      _isRestTimerPaused = false;
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _isRestTimerRunning = false;
      _isRestTimerPaused = false;
      _restSecondsRemaining = 0;
      _restTimerDuration = 0;
      _currentRestExerciseId = null;
    });
  }

  void _skipRestTimer() {
    _stopRestTimer();
  }

  void _initializeExercisePerformance(Exercise exercise) {
    if (!_exercisePerformances.containsKey(exercise.id)) {
      final sets = <Map<String, dynamic>>[];

      for (int i = 0; i < exercise.sets; i++) {
        sets.add({
          'setNumber': i + 1,
          'reps': exercise.reps,
          'weight': 0.0,
          'completed': false,
        });
      }

      _exercisePerformances[exercise.id] = sets;
    }
  }

  Widget _buildPrescribedDetails(BuildContext context, Exercise exercise) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
      child: Row(
        children: [
          if (exercise.sets > 0)
            Expanded(child: _buildDetailItem(context, 'SETS', '${exercise.sets}', Icons.repeat_rounded)),
          if (exercise.sets > 0 && (exercise.reps > 0 || exercise.rest != null))
            _buildVerticalDivider(),
          if (exercise.reps > 0)
            Expanded(child: _buildDetailItem(context, 'REPS', '${exercise.reps}', Icons.fitness_center)),
          if (exercise.reps > 0 && exercise.rest != null && exercise.rest! > 0)
            _buildVerticalDivider(),
          if (exercise.rest != null && exercise.rest! > 0)
            Expanded(child: _buildDetailItem(context, 'REST', '${exercise.rest}s', Icons.timer_outlined)),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 20,
      height: 65,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main divider line
          Container(
            width: 1.5,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.primaryColor.withOpacity(0.3),
                  AppTheme.primaryColor.withOpacity(0.5),
                  AppTheme.primaryColor.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Accent dot in the middle (like faceoff circle)
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withOpacity(0.6),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          // Icon with subtle glow
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.15),
                  AppTheme.primaryColor.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(
              icon, 
              size: 26, 
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          // Value with emphasis
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          // Underline accent
          Container(
            width: 30,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.primaryColor.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 6),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader(BuildContext context, Exercise exercise) {
    final instructions = _getInstructionsForExercise(exercise);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise title with chevron button - entire row clickable
        InkWell(
          onTap: () {
            _showInstructionsDrawer(context, exercise, instructions);
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // Exercise name
                Expanded(
                  child: Text(
                    exercise.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Info icon - elegant and intuitive
                Icon(
                  Icons.info_outline,
                  size: 26,
                  color: AppTheme.primaryColor,
                ),
                
                const SizedBox(width: 16),
                
                // Thin classy line
                Container(
                  width: 1,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.primaryColor.withOpacity(0.4),
                        AppTheme.primaryColor.withOpacity(0.6),
                        AppTheme.primaryColor.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Watch demo link (under title)
        if (exercise.youtubeQuery.isNotEmpty) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
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
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.red.withOpacity(0.18),
                    Colors.red.withOpacity(0.12),
                    Colors.red.withOpacity(0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 20,
                    color: Colors.red[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Watch demo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[300],
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showInstructionsDrawer(BuildContext context, Exercise exercise, List<String> instructions) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Instructions',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 120, // Position below title
                left: 20,
                right: 20,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryColor.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HOW TO PERFORM',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exercise.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 22),
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                  
                  // Divider line
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.4),
                          AppTheme.primaryColor.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  
                  // Watch demo button (if available)
                  if (exercise.youtubeQuery.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: InkWell(
                        onTap: () async {
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
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.red.withOpacity(0.18),
                                Colors.red.withOpacity(0.12),
                                Colors.red.withOpacity(0.06),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.35, 0.65, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                size: 20,
                                color: Colors.red[400],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Watch demo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[300],
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  // Instructions list
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(20),
                      itemCount: instructions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Numbered badge - hockey puck style
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor.withOpacity(0.3),
                                      AppTheme.primaryColor.withOpacity(0.1),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    instructions[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[300],
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1), // Start from above
            end: Offset.zero, // End at position
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  List<String> _getInstructionsForExercise(Exercise exercise) {
    // Basic instructions based on exercise name/category
    final name = exercise.name.toLowerCase();
    
    if (name.contains('squat')) {
      return [
        'Stand with feet shoulder-width apart',
        'Keep your chest up and core engaged',
        'Lower down by bending knees and hips',
        'Go as low as comfortable, ideally thighs parallel to ground',
        'Push through heels to return to start',
      ];
    } else if (name.contains('bench press')) {
      return [
        'Lie flat on bench with feet on floor',
        'Grip bar slightly wider than shoulder width',
        'Lower bar to mid-chest with control',
        'Press bar up until arms fully extended',
        'Keep shoulder blades retracted throughout',
      ];
    } else if (name.contains('deadlift')) {
      return [
        'Stand with feet hip-width apart, bar over midfoot',
        'Bend down and grip bar with hands outside legs',
        'Keep back straight, chest up',
        'Drive through heels, extending hips and knees',
        'Stand fully upright, then lower with control',
      ];
    } else if (name.contains('push')) {
      return [
        'Position hands shoulder-width apart',
        'Keep body in straight line from head to heels',
        'Lower body until chest nearly touches ground',
        'Push back up to starting position',
        'Keep core tight throughout movement',
      ];
    } else if (name.contains('pull') || name.contains('row')) {
      return [
        'Grip bar or handles firmly',
        'Keep back straight and core engaged',
        'Pull weight towards your body',
        'Squeeze shoulder blades together at top',
        'Lower with control to starting position',
      ];
    } else if (name.contains('lunge')) {
      return [
        'Stand tall with feet hip-width apart',
        'Step forward with one leg',
        'Lower hips until both knees bent at 90°',
        'Push through front heel to return to start',
        'Alternate legs and maintain balance',
      ];
    } else if (name.contains('curl')) {
      return [
        'Stand with feet shoulder-width apart',
        'Hold weight with underhand grip',
        'Keep elbows close to torso',
        'Curl weight up towards shoulders',
        'Lower slowly back to starting position',
      ];
    } else if (name.contains('plank')) {
      return [
        'Position forearms on ground, elbows under shoulders',
        'Extend legs behind you, toes on ground',
        'Keep body in straight line',
        'Engage core and glutes',
        'Hold position without sagging or arching',
      ];
    }
    
    // Generic instructions
    return [
      'Set up in proper starting position',
      'Maintain good form throughout the movement',
      'Breathe steadily - exhale on effort',
      'Control the weight both up and down',
      'Rest as prescribed between sets',
    ];
  }

  Widget _buildLastPerformance(
      BuildContext context, ExercisePerformance lastPerf) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blueGrey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueGrey.withOpacity(0.15),
                ),
                child: const Icon(Icons.history, size: 14, color: Colors.blueGrey),
              ),
              const SizedBox(width: 10),
              Text(
                'Last Performance',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[300],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: lastPerf.sets.map((set) {
              final weightStr = set.weight != null ? '${set.weight}kg' : '-';
              return Text(
                'Set ${set.setNumber}: ${set.reps} reps @ $weightStr',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceInput(BuildContext context, Exercise exercise) {
    final sets = _exercisePerformances[exercise.id] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Set cards
        ...List.generate(sets.length, (index) {
          return _buildSetCard(
            context,
            exercise,
            sets[index],
            index,
          );
        }),

        const SizedBox(height: 12),

        // Add/Remove set buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (sets.length > 1)
              TextButton.icon(
                onPressed: () => _removeSet(exercise),
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                label: const Text('Remove set', style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.3,
                )),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[400],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            if (sets.length > 1) const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () => _addSet(exercise),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Add set', style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.3,
              )),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStickyRestTimer(BuildContext context) {
    final progress = _restTimerDuration > 0
        ? (_restTimerDuration - _restSecondsRemaining) / _restTimerDuration
        : 0.0;

    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 3,
              ),

              // Timer content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Timer display
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REST TIME',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatTime(_restSecondsRemaining),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1,
                              fontFeatures: [FontFeature.tabularFigures()],
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Control buttons
                    Row(
                      children: [
                        // Restart button
                        IconButton(
                          onPressed: _restartRestTimer,
                          icon: const Icon(Icons.restart_alt, size: 24),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.15),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(12),
                          ),
                          tooltip: 'Restart',
                        ),
                        const SizedBox(width: 8),

                        // Play/Pause button
                        IconButton(
                          onPressed: _isRestTimerPaused
                              ? _resumeRestTimer
                              : _pauseRestTimer,
                          icon: Icon(
                            _isRestTimerPaused ? Icons.play_arrow : Icons.pause,
                            size: 24,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.15),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(12),
                          ),
                          tooltip: _isRestTimerPaused ? 'Resume' : 'Pause',
                        ),
                        const SizedBox(width: 8),

                        // End rest button
                        IconButton(
                          onPressed: _skipRestTimer,
                          icon: const Icon(Icons.close, size: 24),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.15),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(12),
                          ),
                          tooltip: 'End Rest',
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

  Widget _buildSetCard(
    BuildContext context,
    Exercise exercise,
    Map<String, dynamic> setData,
    int index,
  ) {
    final setNumber = setData['setNumber'] as int;
    final reps = setData['reps'] as int;
    final weight = setData['weight'] as double;
    final completed = setData['completed'] as bool;

    // Calculate progressive line widths based on set number - VERY pronounced
    final totalSets = _exercisePerformances[exercise.id]?.length ?? 1;
    final progress = (setNumber - 1) / (totalSets > 1 ? totalSets - 1 : 1);
    
    // Progressive width: starts thin (2.5px), ends VERY thin (0.5px) - très prononcé!
    final mainLineWidth = 2.5 - (progress * 2.0); // 2.5 → 0.5
    final accentLineWidth = 1.0 - (progress * 0.75); // 1.0 → 0.25
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          // Multi-layered hockey rink-inspired lines (left side accent) - very thin
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 6,
              child: Stack(
                children: [
                  // Main thin line (progressive width)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: mainLineWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: completed
                              ? [
                                  const Color(0xFF4CAF50),
                                  const Color(0xFF4CAF50).withOpacity(0.8),
                                  const Color(0xFF4CAF50).withOpacity(0.3),
                                ]
                              : [
                                  AppTheme.primaryColor,
                                  AppTheme.primaryColor.withOpacity(0.7),
                                  AppTheme.primaryColor.withOpacity(0.2),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(0.5),
                      ),
                    ),
                  ),
                  // Very thin accent line (progressive width)
                  Positioned(
                    left: 4,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: accentLineWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: completed
                              ? [
                                  const Color(0xFF4CAF50).withOpacity(0.6),
                                  const Color(0xFF4CAF50).withOpacity(0.2),
                                  Colors.transparent,
                                ]
                              : [
                                  AppTheme.primaryColor.withOpacity(0.5),
                                  AppTheme.primaryColor.withOpacity(0.15),
                                  Colors.transparent,
                                ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Main content
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              children: [
                // Top line (center ice line inspired)
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        completed ? const Color(0xFF4CAF50).withOpacity(0.3) : AppTheme.primaryColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Set content
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Set number badge
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: completed
                            ? const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                              )
                            : LinearGradient(
                                colors: [Colors.grey[850]!, Colors.grey[800]!],
                              ),
                        boxShadow: completed
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: completed
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : Text(
                                '$setNumber',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Performance inputs with hockey-style lines
                    Expanded(
                      child: Row(
                        children: [
                          // Reps
                          Expanded(
                            child: _buildHockeyStyleInput(
                              context,
                              label: 'REPS',
                              value: reps.toString(),
                              icon: Icons.repeat,
                              isActive: !completed,
                              onTap: completed ? null : () => _showRepsPicker(exercise, index),
                            ),
                          ),
                          
                          // Vertical divider
                          if (exercise.tracksWeight ?? true) ...[
                            Container(
                              width: 1,
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    AppTheme.primaryColor.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            
                            // Weight
                            Expanded(
                              child: _buildHockeyStyleInput(
                                context,
                                label: 'WEIGHT',
                                value: weight > 0 ? weight.toStringAsFixed(1) : '-',
                                unit: 'kg',
                                icon: Icons.fitness_center,
                                isActive: !completed,
                                onTap: completed ? null : () => _showWeightPicker(exercise, index),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Complete/Edit button
                    InkWell(
                      onTap: completed 
                          ? () => _showEditSetDialog(exercise, index)
                          : () => _completeSet(exercise, index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: completed 
                                ? const Color(0xFF4CAF50) 
                                : AppTheme.primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                          color: completed 
                              ? const Color(0xFF4CAF50).withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          completed ? Icons.check_circle : Icons.check_circle_outline,
                          color: completed ? const Color(0xFF4CAF50) : AppTheme.primaryColor,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Bottom line
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        completed ? const Color(0xFF4CAF50).withOpacity(0.3) : AppTheme.primaryColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHockeyStyleInput(
    BuildContext context, {
    required String label,
    required String value,
    String? unit,
    required IconData icon,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Label with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 12,
                  color: isActive 
                      ? AppTheme.primaryColor.withOpacity(0.7) 
                      : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isActive 
                        ? AppTheme.primaryColor.withOpacity(0.7) 
                        : Colors.grey[600],
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 6),
            
            // Value display with underline
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isActive ? Colors.white : Colors.grey[600],
                        height: 1,
                      ),
                    ),
                    if (unit != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive 
                              ? AppTheme.primaryColor.withOpacity(0.6) 
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Hockey-style underline
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.3),
                            ]
                          : [
                              Colors.grey[800]!,
                              Colors.grey[850]!,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addSet(Exercise exercise) {
    setState(() {
      final sets = _exercisePerformances[exercise.id]!;
      final lastWeight = _lastWeightUsed[exercise.id] ?? 0.0;

      sets.add({
        'setNumber': sets.length + 1,
        'reps': exercise.reps,
        'weight': lastWeight,
        'completed': false,
      });
    });
  }

  void _removeSet(Exercise exercise) {
    setState(() {
      final sets = _exercisePerformances[exercise.id]!;
      if (sets.isNotEmpty) {
        sets.removeLast();
      }
    });
  }

  Future<void> _showRepsPicker(Exercise exercise, int setIndex) async {
    final currentReps =
        _exercisePerformances[exercise.id]![setIndex]['reps'] as int;

    final result = await showDialog<double>(
      context: context,
      builder: (context) => NumberPickerDialog(
        title: 'Select Reps',
        minValue: 1,
        maxValue: 50,
        initialValue: currentReps.toDouble(),
        isDecimal: false,
      ),
    );

    if (result != null) {
      setState(() {
        _exercisePerformances[exercise.id]![setIndex]['reps'] = result.toInt();

        // Auto-complete set if reps are filled (and weight if exercise tracks it)
        final setData = _exercisePerformances[exercise.id]![setIndex];
        final weight = setData['weight'] as double;
        final isCompleted = setData['completed'] as bool;
        final tracksWeight = exercise.tracksWeight ?? true;

        // For bodyweight exercises, auto-complete when reps > 0
        // For weighted exercises, auto-complete when both reps and weight > 0
        if (!isCompleted && result > 0) {
          if (!tracksWeight || weight > 0) {
            _autoCompleteSet(exercise, setIndex);
          }
        }
      });
    }
  }

  Future<void> _showWeightPicker(Exercise exercise, int setIndex) async {
    final currentWeight =
        _exercisePerformances[exercise.id]![setIndex]['weight'] as double;
    final initialWeight = currentWeight > 0
        ? currentWeight
        : (_lastWeightUsed[exercise.id] ?? 20.0);

    final result = await showDialog<double>(
      context: context,
      builder: (context) => NumberPickerDialog(
        title: 'Select Weight (kg)',
        minValue: 0,
        maxValue: 300,
        initialValue: initialWeight,
        isDecimal: true,
      ),
    );

    if (result != null) {
      setState(() {
        _exercisePerformances[exercise.id]![setIndex]['weight'] = result;
        _lastWeightUsed[exercise.id] = result;

        // Auto-complete set if both reps and weight are filled
        final setData = _exercisePerformances[exercise.id]![setIndex];
        final reps = setData['reps'] as int;
        final isCompleted = setData['completed'] as bool;

        // Only auto-complete if reps are also filled
        if (!isCompleted && result > 0 && reps > 0) {
          _autoCompleteSet(exercise, setIndex);
        }
      });
    }
  }

  void _autoCompleteSet(Exercise exercise, int setIndex) {
    setState(() {
      _exercisePerformances[exercise.id]![setIndex]['completed'] = true;
    });

    // Check if this is not the last set, then start rest timer
    final sets = _exercisePerformances[exercise.id]!;
    final isLastSet = setIndex == sets.length - 1;

    if (!isLastSet && exercise.rest != null && exercise.rest! > 0) {
      _startRestTimer(exercise.rest!, exercise.id);
    }
  }

  void _completeSet(Exercise exercise, int setIndex) {
    setState(() {
      _exercisePerformances[exercise.id]![setIndex]['completed'] = true;
    });

    // Check if this is not the last set, then start rest timer
    final sets = _exercisePerformances[exercise.id]!;
    final isLastSet = setIndex == sets.length - 1;

    if (!isLastSet && exercise.rest != null && exercise.rest! > 0) {
      _startRestTimer(exercise.rest!, exercise.id);
    }
  }

  Future<void> _showEditSetDialog(Exercise exercise, int setIndex) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Edit Set ${setIndex + 1}?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          'Do you want to modify this completed set?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      setState(() {
        // Uncomplete the set so it can be edited
        _exercisePerformances[exercise.id]![setIndex]['completed'] = false;
      });
    }
  }

  Future<void> _saveExercisePerformance(Exercise exercise) async {
    try {
      // Collect performance data from the state
      final setsData = _exercisePerformances[exercise.id]!;

      // Check if all sets are completed
      final allCompleted = setsData.every((set) => set['completed'] as bool);
      if (!allCompleted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete all sets first'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final sets = <ExerciseSetPerformance>[];
      for (final setData in setsData) {
        final reps = setData['reps'] as int;
        final weight = setData['weight'] as double;

        sets.add(ExerciseSetPerformance(
          setNumber: setData['setNumber'] as int,
          reps: reps,
          weight: weight > 0 ? weight : null,
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
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('${exercise.name} completed!'),
              ],
            ),
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

  Future<void> _saveExercisePerformanceAndNext(Exercise exercise) async {
    // First save the exercise performance
    await _saveExercisePerformance(exercise);

    // If save was successful (exercise is now in completed list), move to next
    if (_completedExercises.contains(exercise.id)) {
      // Small delay to show the completion feedback
      await Future.delayed(const Duration(milliseconds: 300));

      // Get session data to determine total exercises
      final sessionAsync = ref.read(
          _sessionProvider(widget.programId, widget.week, widget.session));
      if (mounted && sessionAsync.hasValue) {
        final totalExercises = sessionAsync.value!.blocks.length;
        // Navigate to next exercise if not on the last page
        if (_currentPage < totalExercises - 1) {
          _nextExercise();
        }
      }
    }
  }

  Future<void> _finishSession() async {
    setState(() {
      _isFinishing = true;
    });

    try {
      // Stop the duration timer
      _durationTimer?.cancel();
      
      // Complete the session through app state with duration
      await ref.read(completeSessionWithDurationActionProvider(_elapsedSeconds).future);

      // Clear the session-in-progress since it's completed
      await ref.read(clearSessionInProgressActionProvider.future);

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
}

// Provider to get session data
@riverpod
Future<Session> _session(
    Ref ref, String programId, String week, String session) async {
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final programRepository = ref.watch(programRepositoryProvider);

  // Convert route parameters to integers
  final weekIndex = int.parse(week);
  final sessionIndex = int.parse(session);

  // Load the program to get the actual session ID
  final program = await programRepository.getById(programId);
  if (program == null) {
    throw Exception('Program not found: $programId');
  }

  if (weekIndex >= program.weeks.length) {
    throw Exception(
        'Week index $weekIndex is out of bounds for program $programId (has ${program.weeks.length} weeks)');
  }

  final weekData = program.weeks[weekIndex];
  if (sessionIndex >= weekData.sessions.length) {
    throw Exception(
        'Session index $sessionIndex is out of bounds for week $weekIndex (has ${weekData.sessions.length} sessions)');
  }

  final sessionId = weekData.sessions[sessionIndex];

  final sessionResult = await sessionRepository.getById(sessionId);
  if (sessionResult == null) {
    throw Exception(
        'Session not found: $sessionId (program: $programId, week: $week, session: $session)');
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