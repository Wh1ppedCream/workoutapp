import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show ValueListenable, visibleForTesting;
import 'package:material_ui/material_ui.dart';

/// A Train-only decorative wave for an existing determinate focus metric.
///
/// The supplied phase is shared with the containing focus card. The terminal
/// active extent remains [value] for every phase; only a thin sinusoidal stroke
/// travels inside that extent. A native, visually hidden
/// [LinearProgressIndicator] remains the semantics owner and receives the exact
/// current value.
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

  static const double _waveAmplitude = 1.5;
  static const double _waveLength = 20;
  static const double _waveStrokeWidth = 2.5;
  static const double _waveColorLift = 0.08;
  static const double _trackStrokeWidth = 1.5;
  static const double _terminalRadius = 1.5;

  @visibleForTesting
  Color get activeWaveColor =>
      Color.lerp(fillColor, Colors.white, _waveColorLift)!;

  @visibleForTesting
  double get activeWaveStrokeWidth => _waveStrokeWidth;

  @visibleForTesting
  double activeExtentFor(Size size) =>
      size.width * value.clamp(0.0, 1.0).toDouble();

  @visibleForTesting
  Rect activeRectFor(Size size) {
    final activeExtent = activeExtentFor(size);
    return textDirection == TextDirection.rtl
        ? Rect.fromLTRB(size.width - activeExtent, 0, size.width, size.height)
        : Rect.fromLTRB(0, 0, activeExtent, size.height);
  }

  @visibleForTesting
  Rect inactiveTrackRectFor(Size size) {
    final activeExtent = activeExtentFor(size);
    return textDirection == TextDirection.rtl
        ? Rect.fromLTRB(0, 0, size.width - activeExtent, size.height)
        : Rect.fromLTRB(activeExtent, 0, size.width, size.height);
  }

  @visibleForTesting
  Path? inactiveTrackPathFor(Size size) {
    if (size.width <= 0) return null;

    final activeExtent = activeExtentFor(size);
    if (activeExtent >= size.width) return null;

    final isRtl = textDirection == TextDirection.rtl;
    final startX = isRtl ? 0.0 : activeExtent;
    final endX = isRtl ? size.width - activeExtent : size.width;
    return Path()
      ..moveTo(startX, size.height / 2)
      ..lineTo(endX, size.height / 2);
  }

  @visibleForTesting
  Offset terminalMarkerCenterFor(Size size) => Offset(
    textDirection == TextDirection.rtl
        ? _terminalRadius
        : size.width - _terminalRadius,
    size.height / 2,
  );

  @visibleForTesting
  Path? activeStrokePathFor(Size size) {
    final activeExtent = activeExtentFor(size);
    if (activeExtent <= 0 || size.width <= 0) return null;

    final isRtl = textDirection == TextDirection.rtl;
    final direction = isRtl ? -1.0 : 1.0;
    final startX = isRtl ? size.width : 0.0;
    final phaseOffset = phase.clamp(0.0, 1.0).toDouble() * math.pi * 2;
    final sampleCount = math.max(8, (activeExtent / 1.5).ceil());
    final path = Path();
    for (var sample = 0; sample <= sampleCount; sample++) {
      final distance = activeExtent * sample / sampleCount;
      final x = startX + direction * distance;
      final y =
          size.height / 2 +
          _waveAmplitude *
              math.sin((math.pi * 2 * distance / _waveLength) - phaseOffset);
      if (sample == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path;
  }

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
    final path = activeStrokePathFor(size);
    if (path != null) {
      canvas.save();
      canvas.clipRRect(track);
      canvas.clipRect(activeRectFor(size));
      canvas.drawPath(
        path,
        Paint()
          ..color = activeWaveColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = _waveStrokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.restore();
    }

    final remainder = inactiveTrackPathFor(size);
    if (remainder != null) {
      canvas.save();
      canvas.clipRRect(track);
      // The track begins at the exact value boundary and is clipped to the
      // inactive side, so no straight line is visible under the active wave.
      canvas.clipRect(inactiveTrackRectFor(size));
      canvas.drawPath(
        remainder,
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = _trackStrokeWidth
          ..strokeCap = StrokeCap.round,
      );
      canvas.restore();
    }

    // This fixed, quiet marker closes the track. It does not encode progress;
    // the sinusoid's horizontal extent remains the sole value representation.
    canvas.drawCircle(
      terminalMarkerCenterFor(size),
      _terminalRadius,
      Paint()..color = trackColor,
    );
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
