import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di.dart';
import '../../../app/theme.dart';
import '../../../core/models/models.dart';
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

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen> {
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Log session start event on next frame to ensure ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logSessionStart();
      _restoreSessionState();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _restTimer?.cancel();
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

  Future<void> _restoreSessionState() async {
    try {
      final sessionInProgress = await ref.read(sessionInProgressProvider.future);
      
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
                value.map((item) => Map<String, dynamic>.from(item as Map))
              );
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
      
      final success = await ref.read(saveSessionInProgressActionProvider(sessionInProgress).future);
      
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
    final sessionAsync =
        ref.watch(_sessionProvider(widget.programId, widget.week, widget.session));
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
            tooltip: 'Session Info',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
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
                    Text('Save & Exit'),
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
    final sessionAsync = ref.watch(_sessionProvider(widget.programId, widget.week, widget.session));
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          // Determine the color based on completion status
          Color dotColor;
          
          if (sessionAsync.hasValue) {
            final exerciseId = sessionAsync.value!.blocks[index].exerciseId;
            
            // Check if this is the bonus exercise (last exercise in session)
            final isBonus = sessionAsync.value!.blocks.isNotEmpty &&
                sessionAsync.value!.blocks.last.exerciseId == exerciseId;
            
            if (isBonus) {
              // Bonus exercise - always use bonus color (amber)
              dotColor = Colors.yellow;
            } else {
              // Normal exercises - apply status-based coloring
              final isCompleted = _completedExercises.contains(exerciseId);
              final hasPerformance = _exercisePerformances.containsKey(exerciseId);
              final allSetsCompleted = _areAllSetsCompleted(exerciseId);
              
              if (isCompleted || allSetsCompleted) {
                // Fully completed (marked or all sets done) - green
                dotColor = Colors.green;
              } else if (hasPerformance) {
                // Check if partially completed (some sets done)
                final sets = _exercisePerformances[exerciseId] ?? [];
                final hasCompletedSets = sets.any((set) => set['completed'] as bool);
                
                if (hasCompletedSets) {
                  // Partially completed - orange
                  dotColor = Colors.orange;
                } else if (index == _currentPage) {
                  // Current page - primary color
                  dotColor = AppTheme.primaryColor;
                } else {
                  // Not started - gray
                  dotColor = Colors.grey[700]!;
                }
              } else if (index == _currentPage) {
                // Current page - primary color
                dotColor = AppTheme.primaryColor;
              } else {
                // Not started - gray
                dotColor = Colors.grey[700]!;
              }
            }
          } else {
            // Loading state
            dotColor = index == _currentPage ? AppTheme.primaryColor : Colors.grey[700]!;
          }
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: index == _currentPage ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              borderRadius: BorderRadius.circular(4),
              border: index == _currentPage 
                  ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                  : null,
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
    final sessionAsync = ref.watch(_sessionProvider(widget.programId, widget.week, widget.session));

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isBonus 
                      ? AppTheme.primaryColor.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isBonus
                      ? Border.all(
                          color: Colors.amber.withOpacity(0.4),
                          width: 1.5,
                        )
                      : null,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add some top padding if bonus to make room for the badge
                    if (isBonus) const SizedBox(height: 24),
                    
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

                    // Mark as done and go to next button
                    SizedBox(
                      width: double.infinity,
                      child: Builder(
                        builder: (context) {
                          final allSetsCompleted = _areAllSetsCompleted(exercise.id);
                          final isCompleted = _completedExercises.contains(exercise.id);
                          
                          return ElevatedButton.icon(
                            onPressed: isCompleted
                                ? null
                                : () => _saveExercisePerformanceAndNext(exercise),
                            icon: Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : (allSetsCompleted ? Icons.check_circle : Icons.arrow_forward),
                              size: 20,
                            ),
                            label: Text(
                              isCompleted
                                  ? 'Completed'
                                  : (allSetsCompleted ? 'Next Exercise ✓' : 'Next Exercise'),
                              style: const TextStyle(fontSize: 15),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (isCompleted || allSetsCompleted)
                                  ? Colors.green
                                  : AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bonus badge overlay
              if (isBonus)
                const Positioned(
                  top: 12,
                  left: 12,
                  child: BonusExerciseBadge(),
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
          const SizedBox(height: 16),
          
          // Set cards
          ...List.generate(sets.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSetCard(
                context,
                exercise,
                sets[index],
                index,
              ),
            );
          }),

          const SizedBox(height: 12),

          // Add/Remove set buttons (simple icons)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (sets.length > 1)
                IconButton.filled(
                  onPressed: () => _removeSet(exercise),
                  icon: const Icon(Icons.remove, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.red,
                  ),
                  tooltip: 'Remove Set',
                ),
              const SizedBox(width: 16),
              IconButton.filled(
                onPressed: () => _addSet(exercise),
                icon: const Icon(Icons.add, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  foregroundColor: AppTheme.primaryColor,
                ),
                tooltip: 'Add Set',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyRestTimer(BuildContext context) {
    final progress = _restTimerDuration > 0 
        ? (_restTimerDuration - _restSecondsRemaining) / _restTimerDuration 
        : 0.0;
    
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.withOpacity(0.95),
              Colors.deepOrange.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar at top of timer
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 4,
              ),
              
              // Timer content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Timer icon and label
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isRestTimerPaused ? Icons.pause : Icons.timer,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    
                    // Timer display
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rest Time',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(_restSecondsRemaining),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
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
                          icon: const Icon(Icons.restart_alt, size: 22),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(10),
                          ),
                          tooltip: 'Restart',
                        ),
                        const SizedBox(width: 6),
                        
                        // Play/Pause button
                        IconButton(
                          onPressed: _isRestTimerPaused ? _resumeRestTimer : _pauseRestTimer,
                          icon: Icon(
                            _isRestTimerPaused ? Icons.play_arrow : Icons.pause,
                            size: 22,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(10),
                          ),
                          tooltip: _isRestTimerPaused ? 'Resume' : 'Pause',
                        ),
                        const SizedBox(width: 6),
                        
                        // Skip button
                        IconButton(
                          onPressed: _skipRestTimer,
                          icon: const Icon(Icons.skip_next, size: 22),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(10),
                          ),
                          tooltip: 'Skip',
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: completed 
            ? Colors.green.withOpacity(0.1) 
            : AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: completed 
              ? Colors.green.withOpacity(0.4) 
              : Colors.grey[800]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Set number badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? Colors.green.withOpacity(0.3)
                  : AppTheme.primaryColor.withOpacity(0.2),
            ),
            child: Center(
              child: completed
                  ? const Icon(Icons.check, color: Colors.green, size: 20)
                  : Text(
                      '$setNumber',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Reps input
          Expanded(
            child: _buildValueButton(
              context,
              label: 'Reps',
              value: reps.toString(),
              icon: Icons.repeat,
              onTap: completed ? null : () => _showRepsPicker(exercise, index),
            ),
          ),
          const SizedBox(width: 10),

          // Weight input
          Expanded(
            child: _buildValueButton(
              context,
              label: 'Weight',
              value: weight > 0 ? '${weight.toStringAsFixed(1)} kg' : '-',
              icon: Icons.fitness_center,
              onTap: completed ? null : () => _showWeightPicker(exercise, index),
            ),
          ),
          const SizedBox(width: 10),

          // Complete set button
          IconButton(
            onPressed: completed ? null : () => _completeSet(exercise, index),
            icon: Icon(
              completed ? Icons.check_circle : Icons.check_circle_outline,
              color: completed ? Colors.green : AppTheme.primaryColor,
              size: 28,
            ),
            tooltip: completed ? 'Completed' : 'Complete Set',
          ),
        ],
      ),
    );
  }

  Widget _buildValueButton(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap == null ? Colors.grey[700]! : AppTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: onTap == null ? Colors.grey[600] : AppTheme.onSurfaceColor,
              ),
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
    final currentReps = _exercisePerformances[exercise.id]![setIndex]['reps'] as int;
    
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
        
        // Auto-complete set if both reps and weight are filled
        final setData = _exercisePerformances[exercise.id]![setIndex];
        final weight = setData['weight'] as double;
        final isCompleted = setData['completed'] as bool;
        
        if (!isCompleted && result > 0 && weight > 0) {
          _autoCompleteSet(exercise, setIndex);
        }
      });
    }
  }

  Future<void> _showWeightPicker(Exercise exercise, int setIndex) async {
    final currentWeight = _exercisePerformances[exercise.id]![setIndex]['weight'] as double;
    final initialWeight = currentWeight > 0 ? currentWeight : (_lastWeightUsed[exercise.id] ?? 20.0);
    
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
        
        if (!isCompleted && result > 0 && reps > 0) {
          _autoCompleteSet(exercise, setIndex);
        }
      });
    }
  }

  void _autoCompleteSet(Exercise exercise, int setIndex) {
    _exercisePerformances[exercise.id]![setIndex]['completed'] = true;
    
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
      
      // Check if this is not the last set, then start rest timer
      final sets = _exercisePerformances[exercise.id]!;
      final isLastSet = setIndex == sets.length - 1;
      
      if (!isLastSet && exercise.rest != null && exercise.rest! > 0) {
        _startRestTimer(exercise.rest!, exercise.id);
      }
    });
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
      final sessionAsync = ref.read(_sessionProvider(widget.programId, widget.week, widget.session));
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
      // Complete the session through app state
      await ref.read(completeSessionActionProvider.future);
      
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
Future<Session> _session(Ref ref, String programId, String week, String session) async {
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
