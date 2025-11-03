import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/models.dart';
import 'interval_timer_widget.dart';
import 'sets_tracker_widget.dart';

/// Exercise card widget displaying exercise details, timer, and sets tracker
class ExerciseCardWidget extends StatelessWidget {
  const ExerciseCardWidget({
    super.key,
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

  /// ===========================================================================
  /// MAIN BUILD METHOD
  /// ===========================================================================
  /// This widget displays exercise content inside the PageView.
  /// 
  /// LAYOUT STRUCTURE:
  /// 
  /// ┌─────────────────────────────────┐
  /// │ 1. Header (name + demo button)  │ ← Fixed height
  /// │ 2. Placeholder chip (optional)  │ ← Fixed height
  /// │ 3. Details (sets/hold/rest)     │ ← Fixed height
  /// │                                 │
  /// │        ↕ Flexible Space         │ ← Spacer (flex: 1)
  /// │                                 │
  /// │ 4. Timer (big circle)           │ ← Fixed height (timer size)
  /// │ 5. Sets Tracker (pills)         │ ← Fixed height
  /// │                                 │
  /// │        ↕ Flexible Space         │ ← Spacer (flex: 1)
  /// │                                 │
  /// └─────────────────────────────────┘
  ///   ↓ (Followed by Bottom Controls in main screen)
  /// 
  /// ===========================================================================
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompactHeight = constraints.maxHeight < 660;

        if (isCompactHeight) {
          return _buildCompactLayout(context);
        }

        return _buildExpandedLayout(context);
      },
    );
  }

  /// Compact layout for smaller screens - scrollable
  Widget _buildCompactLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          if (isPlaceholder) ...[
            const SizedBox(height: 8),
            _buildPlaceholderChip(context),
          ],
          const SizedBox(height: 12),
          _buildDetailsRow(context),
          const SizedBox(height: 24),
          Center(child: _buildTimer(context)),
          const SizedBox(height: 24),
          _buildSetsTracker(context),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  /// ===========================================================================
  /// EXPANDED LAYOUT - Main layout for taller screens
  /// ===========================================================================
  /// 
  /// HOW TO MODIFY THE VERTICAL POSITION:
  /// 
  /// To move Timer + Sets UP:     Increase bottom Spacer flex (e.g., flex: 2)
  /// To move Timer + Sets DOWN:   Increase top Spacer flex (e.g., flex: 2)
  /// To center exactly:           Keep both Spacer flex equal (flex: 1)
  /// 
  /// To adjust spacing between elements:
  /// - Change SizedBox(height: X) values
  /// - Horizontal padding: EdgeInsets.symmetric(horizontal: X)
  /// 
  /// ===========================================================================
  Widget _buildExpandedLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // SECTION 1: EXERCISE HEADER
          // ═══════════════════════════════════════════════════════════════
          const SizedBox(height: 4),
          _buildHeader(context),
          
          // ═══════════════════════════════════════════════════════════════
          // SECTION 2: PLACEHOLDER CHIP (only if exercise is placeholder)
          // ═══════════════════════════════════════════════════════════════
          if (isPlaceholder) ...[
            const SizedBox(height: 8),
            _buildPlaceholderChip(context),
          ],
          
          // ═══════════════════════════════════════════════════════════════
          // SECTION 3: DETAILS ROW (6 sets, 20s hold, 40s rest)
          // ═══════════════════════════════════════════════════════════════
          const SizedBox(height: 12),
          _buildDetailsRow(context),
          
          // ═══════════════════════════════════════════════════════════════
          // FLEXIBLE SPACE ABOVE TIMER (adjust flex to move content)
          // ═══════════════════════════════════════════════════════════════
          const Spacer(flex: 3),
          
          // ═══════════════════════════════════════════════════════════════
          // SECTION 4: INTERVAL TIMER (big circular timer)
          // ═══════════════════════════════════════════════════════════════
          Center(child: _buildTimer(context)),
          
          // ═══════════════════════════════════════════════════════════════
          // SPACING BETWEEN TIMER AND SETS
          // ═══════════════════════════════════════════════════════════════
          const SizedBox(height: 20),
          
          // ═══════════════════════════════════════════════════════════════
          // SECTION 5: SETS TRACKER (1 2 3 4 5 6 pills)
          // ═══════════════════════════════════════════════════════════════
          _buildSetsTracker(context),
          
          // ═══════════════════════════════════════════════════════════════
          // FLEXIBLE SPACE BELOW SETS (adjust flex to move content)
          // ═══════════════════════════════════════════════════════════════
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  /// Exercise header with number, name, and demo button
  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final badgeSize = (screenWidth * 0.11).clamp(40.0, 48.0);
    final titleSize = (screenWidth * 0.056).clamp(20.0, 24.0);
    
    return Row(
      children: [
        Container(
          width: badgeSize,
          height: badgeSize,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFF4CAF50) : AppTheme.primaryColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isCompleted ? const Color(0xFF4CAF50) : AppTheme.primaryColor)
                    .withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: badgeSize * 0.5,
                  )
                : Text(
                    '${index + 1}',
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
        IconButton(
          icon: Icon(
            Icons.play_circle_outline,
            color: const Color(0xFF42A5F5),
            size: (screenWidth * 0.08).clamp(28.0, 34.0),
          ),
          onPressed: () {},
          tooltip: 'Watch demo',
          padding: EdgeInsets.all((screenWidth * 0.018).clamp(6.0, 8.0)),
          constraints: BoxConstraints(
            minWidth: (screenWidth * 0.11).clamp(40.0, 46.0),
            minHeight: (screenWidth * 0.11).clamp(40.0, 46.0),
          ),
        ),
      ],
    );
  }

  /// Placeholder chip indicator
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
          color: const Color(0xFFFFA726).withOpacity(0.45),
          width: 1.5,
        ),
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

  /// Exercise details row (sets, reps/duration, rest)
  Widget _buildDetailsRow(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.038).clamp(14.0, 16.0),
        vertical: (screenWidth * 0.026).clamp(10.0, 12.0),
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _InfoChip(
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
          _InfoChip(
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
            _InfoChip(
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

  /// Timer widget
  Widget _buildTimer(BuildContext context) {
    return IntervalTimerWidget(
      exercise: exercise,
      onStart: onStartIntervalTimer,
      isActive: isTimerActive,
      isPaused: isTimerPaused,
      isWorkPhase: isWorkPhase,
      currentPhaseSeconds: currentPhaseSeconds,
      workDuration: workDuration,
      restDuration: restDuration,
      onPause: onPauseTimer,
      onResume: onResumeTimer,
      onStop: onStopTimer,
    );
  }

  /// Sets tracker widget
  Widget _buildSetsTracker(BuildContext context) {
    return SetsTrackerWidget(
      totalSets: exercise.sets,
      completedSets: completedSets,
      currentActiveSet: currentActiveSet,
      isTimerActive: isTimerActive,
      isWorkPhase: isWorkPhase,
      onToggleSet: onToggleSet,
    );
  }
}

/// Info chip component for displaying exercise parameters
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.screenWidth,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
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
}

