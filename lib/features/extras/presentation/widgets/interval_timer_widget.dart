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
    final displayWorkDuration = workDuration > 0 ? workDuration : (exercise.duration ?? 20);
    final displayRestDuration = restDuration > 0 ? restDuration : (exercise.rest ?? 40);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing
    final double timerSize = screenWidth < 380 ? 160 : (screenWidth < 400 ? 170 : 180);
    final double strokeWidth = screenWidth < 380 ? 8 : 9;

    return GestureDetector(
      onTap: isActive ? null : onStart,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring when active
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
    final fontSize = screenWidth < 380 ? 34.0 : (screenWidth < 400 ? 38.0 : 44.0);
    final labelSize = screenWidth < 380 ? 10.0 : 11.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Phase indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: (isWorkPhase ? const Color(0xFF4CAF50) : const Color(0xFFFF9800))
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isWorkPhase ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
              width: 1.5,
            ),
          ),
          child: Text(
            isWorkPhase ? 'HOLD' : 'REST',
            style: TextStyle(
              color: isWorkPhase ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
              fontSize: labelSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Timer display
        Text(
          _formatTime((isWorkPhase ? displayWorkDuration : displayRestDuration) -
              (currentPhaseSeconds ~/ 10)),
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: (isWorkPhase ? const Color(0xFF4CAF50) : const Color(0xFFFF9800))
                    .withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
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

  Widget _buildIdleContent(BuildContext context, double screenWidth) {
    final iconSize = screenWidth < 380 ? 44.0 : (screenWidth < 400 ? 50.0 : 56.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
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
        const SizedBox(height: 6),
        Text(
          'TAP TO START',
          style: TextStyle(
            color: AppTheme.primaryColor.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Interval Timer',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 9,
            fontWeight: FontWeight.w500,
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
      ..color = Colors.grey[850]!.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    if (workProgress > 0 || restProgress > 0) {
      final activeProgress = isWorkPhase ? workProgress : restProgress;
      final activeColor =
          isWorkPhase ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);

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

