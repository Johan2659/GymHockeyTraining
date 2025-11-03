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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
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
                size: 15,
              ),
              const SizedBox(width: 7),
              Text(
                'Sets',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$completedCount',
                style: TextStyle(
                  color: completedCount == totalSets
                      ? const Color(0xFF4CAF50)
                      : AppTheme.accentColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '/$totalSets',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                    right: setIndex < totalSets - 1 ? 6.0 : 0,
                  ),
                  child: _SetPill(
                    setNumber: setIndex + 1,
                    isCompleted: isSetCompleted,
                    isActive: isCurrentlyActive,
                    isWorkPhase: isWorkPhase,
                    onTap: () => onToggleSet(setIndex),
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
  });

  final int setNumber;
  final bool isCompleted;
  final bool isActive;
  final bool isWorkPhase;
  final VoidCallback onTap;

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
      backgroundColor = const Color(0xFF4CAF50).withOpacity(0.2);
      textColor = const Color(0xFF4CAF50);
      icon = Icons.check_circle;
    } else if (widget.isActive) {
      if (widget.isWorkPhase) {
        backgroundColor = const Color(0xFF4CAF50).withOpacity(0.2);
        textColor = const Color(0xFF4CAF50);
        icon = Icons.play_circle_filled;
      } else {
        backgroundColor = const Color(0xFFFF9800).withOpacity(0.2);
        textColor = const Color(0xFFFF9800);
        icon = Icons.pause_circle_filled;
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
          height: 38,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isActive || widget.isCompleted
                  ? textColor.withOpacity(0.5)
                  : Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, size: 17, color: textColor)
                : Text(
                    '${widget.setNumber}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

