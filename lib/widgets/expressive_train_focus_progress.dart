import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:material_ui/material_ui.dart';

/// A Train-only decorative wave for an existing determinate focus metric.
///
/// The supplied phase is shared with the containing focus card. The terminal
/// edge's mean horizontal position remains [value] for every phase; only its
/// contour moves. A native, visually hidden [LinearProgressIndicator] remains
/// the semantics owner and receives the exact current value.
class ExpressiveTrainFocusProgress extends StatelessWidget {
  const ExpressiveTrainFocusProgress({
    super.key,
    required this.value,
    required this.phase,
    required this.borderRadius,
  });

  final double value;
  final ValueListenable<double> phase;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressTheme = theme.progressIndicatorTheme;
    final fillColor = progressTheme.color ?? theme.colorScheme.primary;
    final trackColor =
        progressTheme.linearTrackColor ?? fillColor.withValues(alpha: 0.24);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: phase,
        child: Opacity(
          opacity: 0,
          alwaysIncludeSemantics: true,
          child: LinearProgressIndicator(
            minHeight: 6,
            value: value.clamp(0.0, 1.0).toDouble(),
            color: Colors.transparent,
            backgroundColor: Colors.transparent,
          ),
        ),
        builder: (context, semanticProgress) {
          final canAnimate =
              TickerMode.valuesOf(context).enabled &&
              !MediaQuery.disableAnimationsOf(context);
          final resolvedPhase = canAnimate
              ? phase.value.clamp(0.0, 1.0).toDouble()
              : 0.0;

          return SizedBox(
            height: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ExcludeSemantics(
                  child: CustomPaint(
                    painter: ExpressiveTrainFocusProgressPainter(
                      value: value.clamp(0.0, 1.0).toDouble(),
                      phase: resolvedPhase,
                      fillColor: fillColor,
                      trackColor: trackColor,
                      borderRadius: borderRadius.resolve(
                        Directionality.of(context),
                      ),
                      textDirection: Directionality.of(context),
                    ),
                  ),
                ),
                // Keep Flutter's native progress semantics and latest exact
                // value while the custom paint supplies the decorative contour.
                semanticProgress!,
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Public for focused widget tests; callers should use the widget above.
class ExpressiveTrainFocusProgressPainter extends CustomPainter {
  const ExpressiveTrainFocusProgressPainter({
    required this.value,
    required this.phase,
    required this.fillColor,
    required this.trackColor,
    required this.borderRadius,
    required this.textDirection,
  });

  final double value;
  final double phase;
  final Color fillColor;
  final Color trackColor;
  final BorderRadius borderRadius;
  final TextDirection textDirection;

  static const int _waveSamples = 24;
  static const double _maximumWaveAmplitude = 1.25;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = Offset.zero & size;
    final track = RRect.fromRectAndCorners(
      rect,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );
    canvas.drawRRect(track, Paint()..color = trackColor);

    final progress = value.clamp(0.0, 1.0).toDouble();
    if (progress <= 0) return;

    final isRtl = textDirection == TextDirection.rtl;
    final frontX = isRtl ? size.width * (1 - progress) : size.width * progress;
    final unfilledWidth = size.width * (1 - progress);
    final amplitude = math.min(
      _maximumWaveAmplitude,
      math.min(frontX, unfilledWidth) * 0.24,
    );
    final waveStrength = math.sin(phase * math.pi * 2);
    final path = Path();

    if (amplitude <= 0 || waveStrength.abs() < 0.0001) {
      if (isRtl) {
        path
          ..moveTo(frontX, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(frontX, size.height)
          ..close();
      } else {
        path
          ..moveTo(0, 0)
          ..lineTo(frontX, 0)
          ..lineTo(frontX, size.height)
          ..lineTo(0, size.height)
          ..close();
      }
    } else if (isRtl) {
      path
        ..moveTo(frontX, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(frontX, size.height);
      for (var sample = _waveSamples - 1; sample >= 0; sample--) {
        final y = size.height * sample / _waveSamples;
        final offset =
            amplitude * math.sin(math.pi * 2 * y / size.height) * waveStrength;
        path.lineTo(frontX + offset, y);
      }
      path.close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(frontX, 0);
      for (var sample = 1; sample <= _waveSamples; sample++) {
        final y = size.height * sample / _waveSamples;
        final offset =
            amplitude * math.sin(math.pi * 2 * y / size.height) * waveStrength;
        path.lineTo(frontX + offset, y);
      }
      path
        ..lineTo(0, size.height)
        ..close();
    }

    canvas.save();
    canvas.clipRRect(track);
    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.restore();
  }

  @override
  bool shouldRepaint(
    covariant ExpressiveTrainFocusProgressPainter oldDelegate,
  ) {
    return oldDelegate.value != value ||
        oldDelegate.phase != phase ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.textDirection != textDirection;
  }
}
