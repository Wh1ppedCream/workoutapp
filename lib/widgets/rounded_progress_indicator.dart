import 'dart:math';
import 'package:flutter/material.dart';

/// A donut-style progress indicator with rounded stroke caps.
class RoundedProgressIndicator extends StatelessWidget {
  /// Fractional progress from 0.0 to 1.0.
  final double progress;

  /// Width & height of the square widget.
  final double size;

  /// Color of the filled arc.
  final Color progressColor;

  /// Color of the unfilled track.
  final Color backgroundColor;

  /// Thickness of the ring.
  final double strokeWidth;

  const RoundedProgressIndicator({
    super.key,
    required this.progress,
    required this.size,
    required this.progressColor,
    required this.backgroundColor,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RoundedProgressPainter(
          progress: progress.clamp(0.0, 1.0),
          progressColor: progressColor,
          backgroundColor: backgroundColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _RoundedProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _RoundedProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    // Draw full‐circle background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw progress arc with rounded caps
    final fgPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final startAngle = -pi / 2; // top
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoundedProgressPainter old) {
    return old.progress != progress ||
        old.progressColor != progressColor ||
        old.backgroundColor != backgroundColor ||
        old.strokeWidth != strokeWidth;
  }
}
