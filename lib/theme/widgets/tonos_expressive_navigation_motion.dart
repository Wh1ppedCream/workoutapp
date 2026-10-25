import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

import '../theme_extensions.dart';
import 'tonos_expressive_state_motion.dart';

/// A 40ms exit and 120ms spring entrance overlap for 10ms. Keyed tabs stay
/// mounted; the incoming page paints above the outgoing page during the overlap.
class TonosExpressiveTabStack extends StatefulWidget {
  const TonosExpressiveTabStack({
    super.key,
    required this.index,
    required this.identities,
    required this.children,
  }) : assert(identities.length == children.length);

  final int index;
  final List<Object> identities;
  final List<Widget> children;

  @override
  State<TonosExpressiveTabStack> createState() =>
      _TonosExpressiveTabStackState();
}

class _TonosExpressiveTabStackState extends State<TonosExpressiveTabStack>
    with SingleTickerProviderStateMixin {
  static const _exitEnd = 40 / 150;
  static const _entranceStart = 30 / 150;
  static const _entranceFadeEnd = 80 / 150;
  static const _exitScaleCurve = _TabExitScaleCurve();
  static const _entranceScaleCurve = _TabEntranceScaleCurve();

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
    value: 1,
  );
  int? _outgoingIndex;
  double _exitStartOpacity = 1;
  double _exitStartScale = 1;

  double _entranceProgress(double progress) =>
      ((progress - _entranceStart) / (1 - _entranceStart)).clamp(0.0, 1.0);

  double _entranceOpacity(double progress) => Curves.easeOutCubic.transform(
    ((progress - _entranceStart) / (_entranceFadeEnd - _entranceStart)).clamp(
      0.0,
      1.0,
    ),
  );

  double _entranceScale(double progress) =>
      0.95 + 0.05 * _entranceScaleCurve.transform(_entranceProgress(progress));

  void _snap() {
    _outgoingIndex = null;
    _controller.value = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!TonosExpressiveStateMotion.enabled(context)) _snap();
  }

  @override
  void didUpdateWidget(covariant TonosExpressiveTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    final sameTabs =
        oldWidget.identities.length == widget.identities.length &&
        List.generate(
          widget.identities.length,
          (i) => i,
        ).every((i) => oldWidget.identities[i] == widget.identities[i]);
    if (!sameTabs || !TonosExpressiveStateMotion.enabled(context)) {
      _snap();
    } else if (oldWidget.index != widget.index) {
      if (_controller.isAnimating && _controller.value < _entranceStart) {
        // The outgoing page is still visible. Keep its timeline and
        // substitute only the latest requested destination for the entrance.
        if (widget.index == _outgoingIndex) _snap();
        return;
      }
      _outgoingIndex = oldWidget.index;
      _exitStartOpacity = _entranceOpacity(_controller.value);
      _exitStartScale = _entranceScale(_controller.value);
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      final progress = _controller.value;
      final outgoingIndex = _outgoingIndex;
      final exiting = outgoingIndex != null && progress < _exitEnd;
      final entering = progress >= _entranceStart;
      final exitProgress = (progress / _exitEnd).clamp(0.0, 1.0);
      final outgoingOpacity = _exitStartOpacity * (1 - exitProgress);
      final outgoingScale =
          _exitStartScale *
          (1 - 0.03 * _exitScaleCurve.transform(exitProgress));
      final incomingOpacity = _entranceOpacity(progress);
      final incomingScale = _entranceScale(progress);
      final incomingInteractive = entering && incomingOpacity > 0;
      // Stable identity keys let Stack reorder the existing tab elements without
      // remounting them. Incoming content is always on top, in either direction.
      final paintOrder = [
        for (var i = 0; i < widget.children.length; i++)
          if (i != widget.index && i != outgoingIndex) i,
        if (outgoingIndex != null && outgoingIndex != widget.index)
          outgoingIndex,
        widget.index,
      ];

      return Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          for (final i in paintOrder)
            Positioned.fill(
              key: ValueKey(widget.identities[i]),
              child: Offstage(
                offstage: i == widget.index
                    ? !entering
                    : i != outgoingIndex || !exiting,
                child: TickerMode(
                  enabled: i == widget.index && incomingInteractive,
                  child: ExcludeSemantics(
                    excluding: i != widget.index || !incomingInteractive,
                    child: ExcludeFocus(
                      excluding: i != widget.index || !incomingInteractive,
                      child: IgnorePointer(
                        ignoring: i != widget.index || !incomingInteractive,
                        child: Opacity(
                          alwaysIncludeSemantics:
                              i == widget.index && incomingInteractive,
                          opacity: i == widget.index
                              ? incomingOpacity
                              : i == outgoingIndex
                              ? outgoingOpacity
                              : 1,
                          child: Transform.scale(
                            scale: i == widget.index
                                ? incomingScale
                                : i == outgoingIndex
                                ? outgoingScale
                                : 1,
                            child: RepaintBoundary(child: widget.children[i]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _TabExitScaleCurve extends Curve {
  const _TabExitScaleCurve();

  static final _spring = SpringSimulation(
    SpringDescription.withDampingRatio(mass: 1, stiffness: 6000, ratio: 0.65),
    0,
    1,
    0,
  );
  static final _end = _spring.x(0.04);

  @override
  double transformInternal(double t) =>
      (_spring.x(t * 0.04) / _end).clamp(0.0, 1.0);
}

class _TabEntranceScaleCurve extends Curve {
  const _TabEntranceScaleCurve();

  // A 5% entrance distance and 30% relative spring overshoot give 101.5%
  // absolute scale. Its first peak is 50ms into the 120ms entrance (80ms).
  static const _overshoot = 0.3;
  static final _logOvershoot = math.log(_overshoot);
  static final _ratio =
      -_logOvershoot /
      math.sqrt(math.pi * math.pi + _logOvershoot * _logOvershoot);
  static final _frequency = math.pi / (0.05 * math.sqrt(1 - _ratio * _ratio));
  static final _spring = SpringSimulation(
    SpringDescription.withDampingRatio(
      mass: 1,
      stiffness: _frequency * _frequency,
      ratio: _ratio,
    ),
    0,
    1,
    0,
  );

  @override
  double transformInternal(double t) {
    final seconds = 0.12 * t;
    if (seconds <= 0.05) return _spring.x(seconds);
    // Finish the first bounce with zero velocity at both the peak and rest,
    // rather than truncating an oscillating spring at the 150ms deadline.
    final settle = ((seconds - 0.05) / 0.07).clamp(0.0, 1.0);
    final settled = settle * settle * (3 - 2 * settle);
    return 1 + _overshoot * (1 - settled);
  }
}

/// Conditional actions retain their outgoing visual until it settles, while
/// becoming non-interactive immediately when hidden. No space remains at rest.
class TonosExpressiveActionVisibility extends StatefulWidget {
  const TonosExpressiveActionVisibility({
    super.key,
    required this.visible,
    required this.child,
    this.animateSize = true,
  });

  final bool visible;
  final Widget child;

  /// Floating menus occupy their full paint bounds while fading, so actions
  /// and their shadows are never revealed through a clipping rectangle.
  final bool animateSize;

  @override
  State<TonosExpressiveActionVisibility> createState() =>
      _TonosExpressiveActionVisibilityState();
}

class _TonosExpressiveActionVisibilityState
    extends State<TonosExpressiveActionVisibility>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: TonosExpressiveStateMotion.fast,
    reverseDuration: widget.animateSize
        ? const Duration(milliseconds: 160)
        : TonosExpressiveStateMotion.fast,
    value: widget.visible ? 1 : 0,
  );

  void _sync() {
    if (!TonosExpressiveStateMotion.enabled(context)) {
      _controller.value = widget.visible ? 1 : 0;
    } else if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant TonosExpressiveActionVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.usesExpressivePresentation) {
      return widget.visible ? widget.child : const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = TonosExpressiveStateMotion.spatial.transform(
          _controller.value,
        );
        if (t == 0 && !widget.visible) return const SizedBox.shrink();
        return ExcludeSemantics(
          excluding: !widget.visible,
          child: ExcludeFocus(
            excluding: !widget.visible,
            child: IgnorePointer(
              ignoring: !widget.visible,
              child: ClipRect(
                clipBehavior: Clip.none,
                child: Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  heightFactor: widget.animateSize ? t : 1,
                  widthFactor: 1,
                  child: Opacity(
                    opacity: widget.animateSize
                        // Establish space before revealing a stacked action;
                        // reversing follows the same curve without an alpha jump.
                        ? const Interval(
                            0.2,
                            0.85,
                            curve: Curves.easeInOutCubic,
                          ).transform(_controller.value)
                        : _controller.value,
                    child: Transform.scale(
                      scale: widget.animateSize
                          ? 0.96 + 0.04 * t
                          : 0.98 + 0.02 * t,
                      alignment: AlignmentDirectional.bottomEnd,
                      transformHitTests: false,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Bounded interpolation for data or selection positions; initial values are
/// already settled and updates retarget from the currently painted value.
class TonosExpressiveAnimatedValue extends StatelessWidget {
  const TonosExpressiveAnimatedValue({
    super.key,
    required this.value,
    required this.builder,
    this.duration = TonosExpressiveStateMotion.fast,
  });

  final double value;
  final Widget Function(BuildContext, double) builder;
  final Duration duration;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: value, end: value),
    duration: TonosExpressiveStateMotion.duration(context, duration),
    curve: TonosExpressiveStateMotion.effects,
    builder: (context, value, _) => builder(context, value),
  );
}

/// Retains the child's state while its content changes size. Offstage and
/// reduced-motion regions use the direct layout, with no stale resize ticker.
class TonosExpressiveResize extends StatefulWidget {
  const TonosExpressiveResize({super.key, required this.child});
  final Widget child;

  @override
  State<TonosExpressiveResize> createState() => _TonosExpressiveResizeState();
}

class _TonosExpressiveResizeState extends State<TonosExpressiveResize> {
  final _contentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final content = KeyedSubtree(key: _contentKey, child: widget.child);
    if (!TonosExpressiveStateMotion.enabled(context)) return content;
    return AnimatedSize(
      duration: TonosExpressiveStateMotion.fast,
      curve: TonosExpressiveStateMotion.effects,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      child: content,
    );
  }
}

Widget tonosExpressiveDragProxy(
  Widget child,
  int index,
  Animation<double> animation,
) => AnimatedBuilder(
  animation: animation,
  child: child,
  builder: (context, child) {
    final t = TonosExpressiveStateMotion.enabled(context)
        ? TonosExpressiveStateMotion.spatial.transform(animation.value)
        : 1.0;
    return Transform.scale(
      scale: 1 + 0.012 * t,
      child: Material(
        color: Colors.transparent,
        elevation: 3 * t,
        shadowColor: Theme.of(context).colorScheme.shadow
            .withValues(alpha: 0.35),
        child: child,
      ),
    );
  },
);
