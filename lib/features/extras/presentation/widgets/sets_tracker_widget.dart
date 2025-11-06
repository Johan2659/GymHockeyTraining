import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Sets tracker widget showing completion status of exercise sets
class SetsTrackerWidget extends StatelessWidget {
  const SetsTrackerWidget({
    super.key,
    required this.totalSets,
    required this.completedSets,
    required this.currentActiveSet,
    required this.isTimerActive,
    required this.isWorkPhase,
    required this.onToggleSet,
  });

  final int totalSets;
  final List<bool> completedSets;
  final int currentActiveSet;
  final bool isTimerActive;
  final bool isWorkPhase;
  final Function(int) onToggleSet;

  @override
  Widget build(BuildContext context) {
    final completedCount = completedSets.where((s) => s).length;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.032).clamp(12.0, 14.0),
        vertical: (screenWidth * 0.028).clamp(10.0, 12.0),
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                color: AppTheme.primaryColor,
                size: (screenWidth * 0.045).clamp(16.0, 19.0),
              ),
              SizedBox(width: (screenWidth * 0.022).clamp(8.0, 9.0)),
              Text(
                'Sets',
                style: TextStyle(
                  color: AppTheme.grey400,
                  fontSize: (screenWidth * 0.035).clamp(13.0, 14.5),
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const Spacer(),
              Text(
                '$completedCount',
                style: TextStyle(
                  color: completedCount == totalSets
                      ? AppTheme.completed
                      : AppTheme.accentColor,
                  fontSize: (screenWidth * 0.042).clamp(15.0, 17.0),
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Text(
                '/$totalSets',
                style: TextStyle(
                  color: AppTheme.grey600,
                  fontSize: (screenWidth * 0.035).clamp(13.0, 14.0),
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: (screenWidth * 0.025).clamp(9.0, 11.0)),
          // Set pills
          Row(
            children: List.generate(totalSets, (setIndex) {
              final isSetCompleted =
                  completedSets.length > setIndex && completedSets[setIndex];
              final isCurrentlyActive =
                  isTimerActive && currentActiveSet == setIndex;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: setIndex < totalSets - 1
                        ? (screenWidth * 0.018).clamp(6.5, 8.0)
                        : 0,
                  ),
                  child: _SetPill(
                    setNumber: setIndex + 1,
                    isCompleted: isSetCompleted,
                    isActive: isCurrentlyActive,
                    isWorkPhase: isWorkPhase,
                    onTap: () => onToggleSet(setIndex),
                    screenWidth: screenWidth,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Individual set pill indicator
class _SetPill extends StatefulWidget {
  const _SetPill({
    required this.setNumber,
    required this.isCompleted,
    required this.isActive,
    required this.isWorkPhase,
    required this.onTap,
    required this.screenWidth,
  });

  final int setNumber;
  final bool isCompleted;
  final bool isActive;
  final bool isWorkPhase;
  final VoidCallback onTap;
  final double screenWidth;

  @override
  State<_SetPill> createState() => _SetPillState();
}

class _SetPillState extends State<_SetPill>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
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
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    if (widget.isCompleted) {
      backgroundColor = AppTheme.completed.withOpacity(0.2);
      textColor = AppTheme.completed;
      icon = Icons.check_circle;
    } else if (widget.isActive) {
      if (widget.isWorkPhase) {
        backgroundColor = AppTheme.completed.withOpacity(0.2);
        textColor = AppTheme.completed;
        icon = Icons.play_circle_filled;
      } else {
        backgroundColor = AppTheme.inProgress.withOpacity(0.2);
        textColor = AppTheme.inProgress;
        icon = Icons.pause_circle_filled;
      }
    } else {
      backgroundColor = AppTheme.grey800.withOpacity(0.3);
      textColor = AppTheme.grey500;
      icon = null;
    }

    final pillHeight = (widget.screenWidth * 0.11).clamp(40.0, 48.0);
    final iconSize = (widget.screenWidth * 0.05).clamp(18.0, 22.0);
    final textSize = (widget.screenWidth * 0.04).clamp(14.5, 16.5);

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
          height: pillHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isActive || widget.isCompleted
                  ? textColor.withOpacity(0.5)
                  : Colors.white.withOpacity(0.06),
              width: 1.5,
            ),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, size: iconSize, color: textColor)
                : Text(
                    '${widget.setNumber}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: textSize,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
