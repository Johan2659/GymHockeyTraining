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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
          const SizedBox(height: 16),
          _buildTimer(context),
          const SizedBox(height: 16),
          _buildSetsTracker(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Expanded layout for larger screens - optimized space usage
  Widget _buildExpandedLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildHeader(context),
          if (isPlaceholder) ...[
            const SizedBox(height: 8),
            _buildPlaceholderChip(context),
          ],
          const SizedBox(height: 12),
          _buildDetailsRow(context),
          const SizedBox(height: 12),
          // Timer takes available space
          Expanded(
            child: Center(
              child: _buildTimer(context),
            ),
          ),
          const SizedBox(height: 12),
          // Sets tracker at bottom
          _buildSetsTracker(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Exercise header with number, name, and demo button
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFF4CAF50) : AppTheme.primaryColor,
            shape: BoxShape.circle,
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
                    size: 20,
                  )
                : Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            exercise.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  height: 1.1,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.play_circle_outline,
            color: Color(0xFF42A5F5),
            size: 28,
          ),
          onPressed: () {},
          tooltip: 'Watch demo',
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ],
    );
  }

  /// Placeholder chip indicator
  Widget _buildPlaceholderChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726).withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFFA726).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFFFB74D),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            'Placeholder exercise',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFFFCC80),
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  /// Exercise details row (sets, reps/duration, rest)
  Widget _buildDetailsRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _InfoChip(
            icon: Icons.repeat_rounded,
            value: '${exercise.sets}',
            label: 'sets',
            color: AppTheme.primaryColor,
          ),
          Container(width: 1, height: 26, color: Colors.grey[800]),
          _InfoChip(
            icon: Icons.fitness_center,
            value: exercise.duration != null
                ? '${exercise.duration}s'
                : '${exercise.reps}',
            label: exercise.duration != null ? 'hold' : 'reps',
            color: const Color(0xFF4CAF50),
          ),
          if (exercise.rest != null) ...[
            Container(width: 1, height: 26, color: Colors.grey[800]),
            _InfoChip(
              icon: Icons.hourglass_bottom_rounded,
              value: '${exercise.rest}s',
              label: 'rest',
              color: const Color(0xFFFF9800),
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
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 5),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

