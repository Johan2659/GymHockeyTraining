import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/models.dart';

/// Modern circular interval timer widget for exercises
class IntervalTimerWidget extends StatelessWidget {
  const IntervalTimerWidget({
    super.key,
    required this.exercise,
    required this.onStart,
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
  final VoidCallback onStart;
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
    final displayWorkDuration =
        workDuration > 0 ? workDuration : (exercise.duration ?? 20);
    final displayRestDuration =
        restDuration > 0 ? restDuration : (exercise.rest ?? 40);
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive sizing - much larger timer, optimized for space
    // Base size on available space, with min/max constraints
    final double baseTimerSize = (screenWidth * 0.65).clamp(220.0, 320.0);
    // Adjust for screen height
    final double timerSize = screenHeight < 700
        ? (baseTimerSize * 0.85).clamp(200.0, 260.0)
        : baseTimerSize;
    final double strokeWidth = (timerSize * 0.045).clamp(9.0, 14.0);

    return GestureDetector(
      onTap: isActive ? null : onStart,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring when active
          if (isActive)
            Container(
              width: timerSize + 24,
              height: timerSize + 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (isWorkPhase
                          ? AppTheme.completed
                          : AppTheme.inProgress)
                      .withOpacity(0.25),
                  width: 3,
                ),
              ),
            ),
          // Main timer container
          Container(
            width: timerSize,
            height: timerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceColor.withOpacity(0.7),
              border: Border.all(
                color: isActive
                    ? (isWorkPhase
                            ? AppTheme.completed
                            : AppTheme.inProgress)
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
              painter: _TimerPainter(
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
                    ? _buildActiveContent(
                        context,
                        displayWorkDuration,
                        displayRestDuration,
                        screenWidth,
                      )
                    : _buildIdleContent(context, screenWidth),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveContent(
    BuildContext context,
    int displayWorkDuration,
    int displayRestDuration,
    double screenWidth,
  ) {
    // Responsive typography - larger and more readable
    final fontSize = (screenWidth * 0.13).clamp(48.0, 68.0);
    final labelSize = (screenWidth * 0.032).clamp(11.0, 14.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Phase indicator
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: (screenWidth * 0.035).clamp(12.0, 16.0),
            vertical: (screenWidth * 0.012).clamp(4.0, 6.0),
          ),
          decoration: BoxDecoration(
            color: (isWorkPhase
                    ? AppTheme.completed
                    : AppTheme.inProgress)
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isWorkPhase
                  ? AppTheme.completed
                  : AppTheme.inProgress,
              width: 2,
            ),
          ),
          child: Text(
            isWorkPhase ? 'HOLD' : 'REST',
            style: TextStyle(
              color: isWorkPhase
                  ? AppTheme.completed
                  : AppTheme.inProgress,
              fontSize: labelSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              height: 1,
            ),
          ),
        ),
        SizedBox(height: (screenWidth * 0.028).clamp(10.0, 14.0)),
        // Timer display
        Text(
          _formatTime(
              (isWorkPhase ? displayWorkDuration : displayRestDuration) -
                  (currentPhaseSeconds ~/ 10)),
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            height: 1,
            shadows: [
              Shadow(
                color: (isWorkPhase
                        ? AppTheme.completed
                        : AppTheme.inProgress)
                    .withOpacity(0.6),
                blurRadius: 24,
              ),
            ],
          ),
        ),
        SizedBox(height: (screenWidth * 0.035).clamp(12.0, 16.0)),
        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TimerControlButton(
              icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              onTap: isPaused ? onResume : onPause,
              color: Colors.white,
              size: (screenWidth * 0.09).clamp(32.0, 42.0),
            ),
            SizedBox(width: (screenWidth * 0.05).clamp(18.0, 24.0)),
            _TimerControlButton(
              icon: Icons.stop_rounded,
              onTap: onStop,
              color: Colors.red,
              size: (screenWidth * 0.09).clamp(32.0, 42.0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIdleContent(BuildContext context, double screenWidth) {
    final iconSize = (screenWidth * 0.16).clamp(56.0, 72.0);
    final titleSize = (screenWidth * 0.032).clamp(12.0, 14.0);
    final subtitleSize = (screenWidth * 0.026).clamp(9.5, 11.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all((screenWidth * 0.045).clamp(16.0, 20.0)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor.withOpacity(0.15),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.25),
                blurRadius: 24,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(
            Icons.play_circle_filled,
            color: AppTheme.primaryColor,
            size: iconSize,
          ),
        ),
        SizedBox(height: (screenWidth * 0.022).clamp(8.0, 10.0)),
        Text(
          'TAP TO START',
          style: TextStyle(
            color: AppTheme.primaryColor.withOpacity(0.9),
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
            height: 1,
          ),
        ),
        SizedBox(height: (screenWidth * 0.008).clamp(3.0, 4.0)),
        Text(
          'Interval Timer',
          style: TextStyle(
            color: AppTheme.grey500,
            fontSize: subtitleSize,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ],
    );
  }
}

/// Timer control button component
class _TimerControlButton extends StatelessWidget {
  const _TimerControlButton({
    required this.icon,
    required this.onTap,
    required this.color,
    this.size = 32.0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all((size * 0.32).clamp(10.0, 14.0)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(0.35),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      ),
    );
  }
}

/// Custom painter for the circular progress indicator
class _TimerPainter extends CustomPainter {
  final double workProgress;
  final double restProgress;
  final double strokeWidth;
  final bool isActive;
  final bool isWorkPhase;

  _TimerPainter({
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

    // Background track
    final trackPaint = Paint()
      ..color = AppTheme.grey850.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    if (workProgress > 0 || restProgress > 0) {
      final activeProgress = isWorkPhase ? workProgress : restProgress;
      final activeColor =
          isWorkPhase ? AppTheme.completed : AppTheme.inProgress;

      // Glow layer
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

      // Main progress arc
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

      // Progress dot at end
      final dotAngle = startAngle + (fullCircle * activeProgress);
      final dotX = center.dx + radius * math.cos(dotAngle);
      final dotY = center.dy + radius * math.sin(dotAngle);

      final dotGlowPaint = Paint()
        ..color = activeColor.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(dotX, dotY), strokeWidth * 0.8, dotGlowPaint);

      final dotPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), strokeWidth * 0.4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_TimerPainter oldDelegate) {
    return oldDelegate.workProgress != workProgress ||
        oldDelegate.restProgress != restProgress ||
        oldDelegate.isWorkPhase != isWorkPhase ||
        oldDelegate.isActive != isActive;
  }
}
