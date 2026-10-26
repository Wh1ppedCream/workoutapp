import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

import '../theme_extensions.dart';

/// Motion roles for Expressive state changes. Resting layout and hit targets
/// remain owned by the existing components.
abstract final class TonosExpressiveStateMotion {
  static const fast = Duration(milliseconds: 220);
  static const standard = Duration(milliseconds: 360);
  static const data = Duration(milliseconds: 480);
  static const effects = Cubic(0.2, 0, 0, 1);
  static const spatial = _ExpressiveSettlingCurve();
  // ExpansionTile reverses its controller. Flip the curve once so closing
  // decelerates too, and keep its identity stable across header rebuilds.
  static final _collapseSpatial = spatial.flipped;

  static bool enabled(BuildContext context) =>
      context.usesExpressivePresentation &&
      context.motionTokens.standard > Duration.zero &&
      TickerMode.valuesOf(context).enabled &&
      !MediaQuery.disableAnimationsOf(context);

  static Duration duration(BuildContext context, Duration duration) =>
      enabled(context) ? duration : Duration.zero;

  static AnimationStyle? expansionStyle(
    BuildContext context, {
    bool settleOnCollapse = false,
  }) => context.usesExpressivePresentation
      ? AnimationStyle(
          duration: duration(context, standard),
          reverseDuration: duration(context, standard),
          curve: spatial,
          reverseCurve: settleOnCollapse ? _collapseSpatial : spatial,
        )
      : null;
}

// Critically damped for layout: the same physical settling feel as a press,
// without overshooting height, opacity, or the approved inset endpoints.
class _ExpressiveSettlingCurve extends Curve {
  const _ExpressiveSettlingCurve();

  static final _spring = SpringSimulation(
    SpringDescription.withDampingRatio(mass: 1, stiffness: 400, ratio: 1),
    0,
    1,
    0,
  );
  static final _end = _spring.x(0.36);

  @override
  double transformInternal(double t) =>
      (_spring.x(t * 0.36) / _end).clamp(0.0, 1.0);
}

/// A small paint-only spring after a real state change, or an explicitly
/// requested first arrival. It never remounts fields or repeats on rebuild.
class TonosExpressiveChangePulse extends StatefulWidget {
  const TonosExpressiveChangePulse({
    super.key,
    required this.value,
    required this.child,
    this.enabled = true,
    this.animateOnMount = false,
    this.duration = const Duration(milliseconds: 280),
    this.scale = 1.045,
    this.offset = Offset.zero,
    this.alignment = Alignment.center,
  });

  final Object? value;
  final Widget child;
  final bool enabled;
  final bool animateOnMount;
  final Duration duration;
  final double scale;
  final Offset offset;
  final AlignmentGeometry alignment;

  @override
  State<TonosExpressiveChangePulse> createState() =>
      _TonosExpressiveChangePulseState();
}

class _TonosExpressiveChangePulseState extends State<TonosExpressiveChangePulse>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );
  bool _initialized = false;
  bool _isArrival = false;
  double _from = 0;

  static final _spring = SpringSimulation(
    SpringDescription.withDampingRatio(mass: 1, stiffness: 700, ratio: 0.82),
    1,
    0,
    0,
  );
  static final _springEnd = _spring.x(0.24);

  double get _progress {
    final t = _controller.value;
    if (!_isArrival && t < 1 / 7) {
      return _from + (1 - _from) * Curves.easeOutCubic.transform(t * 7);
    }
    final settle = _isArrival ? t : (t - 1 / 7) / (6 / 7);
    return ((_spring.x(0.24 * settle) - _springEnd) / (1 - _springEnd)).clamp(
      -0.02,
      1.0,
    );
  }

  bool get _enabled =>
      widget.enabled && TonosExpressiveStateMotion.enabled(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_enabled) {
      _controller.value = 1;
    } else if (!_initialized && widget.animateOnMount) {
      _pulse(arrival: true);
    }
    _initialized = true;
  }

  @override
  void didUpdateWidget(covariant TonosExpressiveChangePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (!_enabled) {
      _controller.value = 1;
    } else if (oldWidget.value != widget.value) {
      _pulse();
    }
  }

  void _pulse({bool arrival = false}) {
    // A state change grows from the currently painted value during the first
    // seventh of its timeline. New arrivals start at their inset.
    _from = _progress;
    _isArrival = arrival;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) {
      final progress = _progress;
      return Transform.translate(
        offset: widget.offset * progress,
        transformHitTests: false,
        child: Transform.scale(
          scale: 1 + (widget.scale - 1) * progress,
          alignment: widget.alignment.resolve(Directionality.of(context)),
          transformHitTests: false,
          child: child,
        ),
      );
    },
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Slides only the incoming content. Keeping one live card avoids doubled text,
/// duplicate SVG paints and old/new height competition during rapid browsing.
class TonosExpressiveContentTransition extends StatefulWidget {
  const TonosExpressiveContentTransition({
    super.key,
    required this.value,
    required this.child,
    this.direction = 1,
  });
  final Object value;
  final Widget child;
  final double direction;

  @override
  State<TonosExpressiveContentTransition> createState() =>
      _TonosExpressiveContentTransitionState();
}

class _TonosExpressiveContentTransitionState
    extends State<TonosExpressiveContentTransition>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 1,
  );
  Offset _fromOffset = Offset.zero;
  Offset get _offset => Offset.lerp(
    _fromOffset,
    Offset.zero,
    Curves.easeOutCubic.transform(_controller.value),
  )!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!TonosExpressiveStateMotion.enabled(context)) _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant TonosExpressiveContentTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!TonosExpressiveStateMotion.enabled(context)) {
      _controller.value = 1;
    } else if (oldWidget.value != widget.value) {
      final direction = Directionality.of(context) == TextDirection.rtl
          ? -widget.direction
          : widget.direction;
      // Retarget from the painted offset when arrows are tapped rapidly.
      _fromOffset = _controller.isAnimating
          ? _offset
          : Offset(12 * direction, 0);
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: RepaintBoundary(child: widget.child),
    builder: (context, child) => ClipRect(
      clipBehavior: _controller.isCompleted ? Clip.none : Clip.hardEdge,
      child: Transform.translate(
        offset: _offset,
        transformHitTests: false,
        child: child,
      ),
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
