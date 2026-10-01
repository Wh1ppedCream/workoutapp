import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/physics.dart';

const double _indicatorSlotHeightFraction = 0.82;
const double _indicatorTravelWidthFraction = 0.78;
const double _indicatorSelectedWidthFraction = 0.94;
const double _maximumIndicatorOvershootInSlots = 0.06;
const double _maximumPressShapeOvershoot = 0.08;
const int _maximumRevealStaggerIndex = 6;

/// Shared press amplitudes for the Expressive Train preview.
///
/// Focal actions compress more than their supporting actions; compact controls
/// use a short, local response. Individual widgets may still vary shape and
/// offset to communicate their role.
abstract final class TonosExpressiveMotionTiers {
  static const double focalScale = 0.91;
  static const double supportingScale = 0.93;
  static const double compactScale = 0.88;
  static const Offset focalOffset = Offset(0, 2);
  static const Offset supportingOffset = Offset(0, 1.5);
  static const Offset compactOffset = Offset(0, 0.5);
  static const double compactRotation = 0.05;
}

final SpringDescription _selectedSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 650,
  ratio: 0.8,
);

final SpringDescription _primaryActionSpring =
    SpringDescription.withDampingRatio(mass: 1, stiffness: 800, ratio: 0.72);

/// A decorative springing selection fill for an existing control group.
///
/// [child] remains the only hit-test and semantics owner. The indicator is
/// clipped to this widget's fixed layout bounds and is excluded from both
/// pointer handling and semantics. [topologyKey] should identify the ordered
/// destinations when a group's contents can change without changing its
/// count, so a programmatic reorder snaps rather than animating from a stale
/// slot.
class TonosExpressiveSelectionIndicator extends StatefulWidget {
  const TonosExpressiveSelectionIndicator({
    super.key,
    required this.selectedIndex,
    required this.itemCount,
    required this.color,
    required this.borderRadius,
    required this.child,
    this.topologyKey,
    this.travelBorderRadius,
    this.travelWidthFraction = _indicatorTravelWidthFraction,
    this.selectedWidthFraction = _indicatorSelectedWidthFraction,
  }) : assert(travelWidthFraction >= 0 && travelWidthFraction < 1),
       assert(selectedWidthFraction >= 0 && selectedWidthFraction < 1);

  final int selectedIndex;
  final int itemCount;
  final Color color;
  final BorderRadius borderRadius;
  final Widget child;
  final Object? topologyKey;
  final BorderRadius? travelBorderRadius;
  final double travelWidthFraction;
  final double selectedWidthFraction;

  @override
  State<TonosExpressiveSelectionIndicator> createState() =>
      _TonosExpressiveSelectionIndicatorState();
}

class _TonosExpressiveSelectionIndicatorState
    extends State<TonosExpressiveSelectionIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late double _targetPosition;
  late double _springStartPosition;
  TextDirection? _textDirection;

  @override
  void initState() {
    super.initState();
    _targetPosition = _resolveIndex(widget.selectedIndex, widget.itemCount);
    _springStartPosition = _targetPosition;
    _controller = AnimationController.unbounded(
      vsync: this,
      value: _targetPosition,
    )..addStatusListener(_snapToExactTargetWhenSettled);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    if (_textDirection != null && _textDirection != direction) {
      _snapToTarget();
    }
    _textDirection = direction;
    if (!_canAnimate(context)) {
      _snapToTarget();
    }
  }

  @override
  void didUpdateWidget(covariant TonosExpressiveSelectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _resolveIndex(widget.selectedIndex, widget.itemCount);
    final topologyChanged =
        oldWidget.itemCount != widget.itemCount ||
        _topologyChanged(oldWidget.topologyKey, widget.topologyKey);
    final selectionChanged = target != _targetPosition;
    _targetPosition = target;

    if (topologyChanged || widget.itemCount <= 0) {
      _snapToTarget();
    } else if (selectionChanged) {
      if (_canAnimate(context)) {
        _animateToTarget();
      } else {
        _snapToTarget();
      }
    }
  }

  static double _resolveIndex(int selectedIndex, int itemCount) {
    if (itemCount <= 0) return 0;
    return selectedIndex.clamp(0, itemCount - 1).toDouble();
  }

  static bool _topologyChanged(Object? oldKey, Object? newKey) {
    if (identical(oldKey, newKey)) return false;
    return oldKey != newKey;
  }

  static bool _canAnimate(BuildContext context) {
    return TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
  }

  void _animateToTarget() {
    final start = _controller.value;
    final velocity = _controller.velocity;
    _springStartPosition = start;
    _controller.animateWith(
      SpringSimulation(_selectedSpring, start, _targetPosition, velocity),
    );
  }

  void _snapToTarget() {
    _controller.stop(canceled: true);
    _springStartPosition = _targetPosition;
    _controller.value = _targetPosition;
  }

  void _snapToExactTargetWhenSettled(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      if ((_controller.value - _targetPosition).abs() > 0) {
        _controller.value = _targetPosition;
      }
    }
  }

  double _boundedVisualIndex(int itemCount) {
    final value = _controller.value;
    final lowEndpoint = _springStartPosition < _targetPosition
        ? _springStartPosition
        : _targetPosition;
    final highEndpoint = _springStartPosition > _targetPosition
        ? _springStartPosition
        : _targetPosition;

    var bounded = value;
    if (value < lowEndpoint) {
      bounded = value.clamp(
        lowEndpoint - _maximumIndicatorOvershootInSlots,
        lowEndpoint,
      );
    } else if (value > highEndpoint) {
      bounded = value.clamp(
        highEndpoint,
        highEndpoint + _maximumIndicatorOvershootInSlots,
      );
    }

    return bounded
        .clamp(
          -_maximumIndicatorOvershootInSlots,
          itemCount - 1 + _maximumIndicatorOvershootInSlots,
        )
        .toDouble();
  }

  Alignment _indicatorAlignment(double logicalIndex, int itemCount) {
    final isRtl = _textDirection == TextDirection.rtl;
    final physicalIndex = isRtl ? itemCount - 1 - logicalIndex : logicalIndex;
    final widthFactor = _currentWidthFraction() / itemCount;
    final centerFraction = (physicalIndex + 0.5) / itemCount;
    final alignmentX =
        2 * (centerFraction - widthFactor / 2) / (1 - widthFactor) - 1;
    return Alignment(alignmentX, 0);
  }

  double _selectionMorphProgress() {
    final nearestSlot = _controller.value.roundToDouble();
    return (1 - (_controller.value - nearestSlot).abs().clamp(0.0, 1.0))
        .toDouble();
  }

  double _currentWidthFraction() {
    final morph = _selectionMorphProgress();
    return lerpDouble(
      widget.travelWidthFraction,
      widget.selectedWidthFraction,
      morph,
    )!.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.itemCount;
    if (itemCount <= 0) return widget.child;

    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final morph = _selectionMorphProgress();
                  final widthFactor = _currentWidthFraction();
                  final borderRadius = BorderRadius.lerp(
                    widget.travelBorderRadius ?? widget.borderRadius,
                    widget.borderRadius,
                    morph,
                  )!;
                  return Align(
                    alignment: _indicatorAlignment(
                      _boundedVisualIndex(itemCount),
                      itemCount,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: widthFactor / itemCount,
                      heightFactor: _indicatorSlotHeightFraction,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius: borderRadius,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// A pointer-only press/release response for an existing primary action.
///
/// The child continues to own the action callback, keyboard activation,
/// focus, and semantics. This wrapper only listens to raw pointer down/up/cancel
/// events and adds paint-only scale, offset, rotation, and shape compression.
/// The child keeps its layout and hit target. Pass both border radii to morph
/// the silhouette without animating the label itself.
class TonosExpressivePressResponse extends StatefulWidget {
  const TonosExpressivePressResponse({
    super.key,
    required this.enabled,
    required this.child,
    this.borderRadius,
    this.pressedBorderRadius,
    this.pressedScale = 1,
    this.pressedOffset = Offset.zero,
    this.pressedRotation = 0,
    this.allowReleaseOvershoot = true,
  }) : assert((borderRadius == null) == (pressedBorderRadius == null));

  final bool enabled;
  final Widget child;
  final BorderRadius? borderRadius;
  final BorderRadius? pressedBorderRadius;
  final double pressedScale;
  final Offset pressedOffset;
  final double pressedRotation;

  /// Whether the release spring may paint past the resting bounds.
  ///
  /// Keep this disabled for controls inside a hard rounded clip. The inward
  /// press response and spring return remain; only the clipped outward recoil
  /// is capped at its stable rest pose.
  final bool allowReleaseOvershoot;

  @override
  State<TonosExpressivePressResponse> createState() =>
      _TonosExpressivePressResponseState();
}

class _TonosExpressivePressResponseState
    extends State<TonosExpressivePressResponse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int? _activePointer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: 0)
      ..addStatusListener(_snapToExactRestWhenSettled);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_canAnimate(context)) {
      _activePointer = null;
      _snapToRest();
    }
  }

  @override
  void didUpdateWidget(covariant TonosExpressivePressResponse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) {
      _activePointer = null;
      _snapToRest();
    }
  }

  static bool _canAnimate(BuildContext context) {
    return TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enabled || !_canAnimate(context) || _activePointer != null) {
      return;
    }
    _controller.stop(canceled: true);
    _activePointer = event.pointer;
    _controller.value = 1;
  }

  void _handlePointerUp(PointerEvent event) {
    if (_activePointer != event.pointer) return;
    _activePointer = null;
    if (_canAnimate(context)) {
      _animateToRest();
    } else {
      _snapToRest();
    }
  }

  void _animateToRest() {
    final start = _controller.value;
    final velocity = _controller.velocity;
    _controller.animateWith(
      SpringSimulation(_primaryActionSpring, start, 0, velocity),
    );
  }

  void _snapToRest() {
    _controller.stop(canceled: true);
    _controller.value = 0;
  }

  void _snapToExactRestWhenSettled(AnimationStatus status) {
    if ((status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) &&
        _controller.value != 0) {
      _controller.value = 0;
    }
  }

  BorderRadius? _currentBorderRadius(double pressProgress) {
    final rest = widget.borderRadius;
    final pressed = widget.pressedBorderRadius;
    if (rest == null || pressed == null) return null;
    final canOverroundRest =
        _cornerIsTighter(pressed.topLeft, rest.topLeft) &&
        _cornerIsTighter(pressed.topRight, rest.topRight) &&
        _cornerIsTighter(pressed.bottomLeft, rest.bottomLeft) &&
        _cornerIsTighter(pressed.bottomRight, rest.bottomRight);
    final minimumProgress = canOverroundRest
        ? -_maximumPressShapeOvershoot
        : 0.0;
    final boundedProgress = pressProgress
        .clamp(minimumProgress, 1.0)
        .toDouble();
    return BorderRadius.lerp(rest, pressed, boundedProgress);
  }

  static bool _cornerIsTighter(Radius pressed, Radius resting) {
    return pressed.x <= resting.x && pressed.y <= resting.y;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerUp,
      child: AnimatedBuilder(
        animation: _controller,
        child: RepaintBoundary(child: widget.child),
        builder: (context, child) {
          final progress = _controller.value;
          final visualProgress = widget.allowReleaseOvershoot
              ? progress
              : progress.clamp(0.0, 1.0).toDouble();
          final borderRadius = _currentBorderRadius(visualProgress);
          final boundedProgress = widget.allowReleaseOvershoot
              ? visualProgress.clamp(-0.08, 1.06).toDouble()
              : visualProgress;
          final scale = (1 + (widget.pressedScale - 1) * boundedProgress)
              .clamp(0.78, widget.allowReleaseOvershoot ? 1.03 : 1.0)
              .toDouble();

          Widget visual = child!;
          if (borderRadius != null) {
            visual = ClipRRect(
              borderRadius: borderRadius,
              clipBehavior: Clip.antiAlias,
              child: visual,
            );
          }
          return Transform.translate(
            offset: widget.pressedOffset * boundedProgress,
            transformHitTests: false,
            child: Transform.rotate(
              angle: widget.pressedRotation * boundedProgress,
              transformHitTests: false,
              child: Transform.scale(
                scale: scale,
                transformHitTests: false,
                child: visual,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// A short, one-shot expressive arrival for a newly visible child.
///
/// The child remains mounted and interactive while it arrives; only paint is
/// transformed. [staggerIndex] offsets the start within a small bounded batch
/// without timers or delayed callbacks. Reduced motion and disabled ticker
/// regions resolve directly to the resting presentation.
class TonosExpressiveReveal extends StatefulWidget {
  const TonosExpressiveReveal({
    super.key,
    required this.child,
    this.enabled = true,
    this.staggerIndex = 0,
    this.duration = const Duration(milliseconds: 240),
    this.staggerStep = const Duration(milliseconds: 55),
  }) : assert(staggerIndex >= 0),
       assert(duration > Duration.zero),
       assert(staggerStep >= Duration.zero);

  final Widget child;
  final bool enabled;
  final int staggerIndex;
  final Duration duration;
  final Duration staggerStep;

  @override
  State<TonosExpressiveReveal> createState() => _TonosExpressiveRevealState();
}

class _TonosExpressiveRevealState extends State<TonosExpressiveReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _arrival;
  bool _started = false;

  int get _boundedStagger =>
      widget.staggerIndex.clamp(0, _maximumRevealStaggerIndex);

  Duration get _delay => widget.staggerStep * _boundedStagger;

  Duration get _totalDuration => widget.duration + _delay;

  @override
  void initState() {
    super.initState();
    final totalMicros = _totalDuration.inMicroseconds;
    final delayFraction = totalMicros == 0
        ? 0.0
        : _delay.inMicroseconds / totalMicros;
    _controller = AnimationController(vsync: this, duration: _totalDuration);
    _arrival = CurvedAnimation(
      parent: _controller,
      curve: Interval(delayFraction, 1, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant TonosExpressiveReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled && !widget.enabled) {
      _snapToRest();
    } else if (!oldWidget.enabled && widget.enabled) {
      _syncAnimation();
    }
  }

  bool _canAnimate() =>
      widget.enabled &&
      TickerMode.valuesOf(context).enabled &&
      !MediaQuery.disableAnimationsOf(context);

  void _syncAnimation() {
    if (!_canAnimate()) {
      _snapToRest();
      return;
    }
    if (!_started) {
      _started = true;
      _controller.forward(from: 0);
    }
  }

  void _snapToRest() {
    _controller.stop(canceled: true);
    _controller.value = 1;
    _started = true;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _arrival,
      child: RepaintBoundary(child: widget.child),
      builder: (context, child) {
        final progress = _arrival.value;
        return Opacity(
          opacity: progress,
          alwaysIncludeSemantics: true,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - progress)),
            transformHitTests: false,
            child: Transform.scale(
              scale: lerpDouble(0.965, 1, progress)!,
              transformHitTests: false,
              child: child,
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

/// A low-cost, paint-only ambient loop for a small expressive focal surface.
///
/// The caller keeps layout and semantics in [child] and uses [builder] only to
/// interpolate decorative color/paint. The loop is stopped and snapped to its
/// neutral pose whenever reduced motion, Effects Off, TickerMode, an inactive
/// tab, or a non-resumed app lifecycle state disables it.
class TonosExpressiveAmbientMotion extends StatefulWidget {
  const TonosExpressiveAmbientMotion({
    super.key,
    required this.child,
    required this.builder,
    this.enabled = true,
    this.halfCycle = const Duration(seconds: 8),
  }) : assert(halfCycle > Duration.zero);

  final Widget child;
  final Widget Function(BuildContext context, double phase, Widget child)
  builder;
  final bool enabled;
  final Duration halfCycle;

  @override
  State<TonosExpressiveAmbientMotion> createState() =>
      _TonosExpressiveAmbientMotionState();
}

/// Exposes the ambient owner's existing phase without making the whole child
/// subtree rebuild on every tick. Paint-only accents and progress decorations
/// can listen to the same animation through their own [AnimatedBuilder].
class TonosExpressiveAmbientPhaseScope extends InheritedWidget {
  const TonosExpressiveAmbientPhaseScope({
    super.key,
    required this.phase,
    required super.child,
  });

  final Animation<double> phase;

  static Animation<double>? maybePhaseOf(BuildContext context) => context
      .getInheritedWidgetOfExactType<TonosExpressiveAmbientPhaseScope>()
      ?.phase;

  @override
  bool updateShouldNotify(TonosExpressiveAmbientPhaseScope oldWidget) =>
      !identical(phase, oldWidget.phase);
}

class _TonosExpressiveAmbientMotionState
    extends State<TonosExpressiveAmbientMotion>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  late final CurvedAnimation _phase;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    _lifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(vsync: this, duration: widget.halfCycle);
    _phase = CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant TonosExpressiveAmbientMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.halfCycle != widget.halfCycle) {
      _controller.duration = widget.halfCycle;
    }
    _syncAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    _syncAnimation();
  }

  bool _canAnimate() =>
      widget.enabled &&
      TickerMode.valuesOf(context).enabled &&
      !MediaQuery.disableAnimationsOf(context) &&
      _lifecycleState == AppLifecycleState.resumed;

  void _syncAnimation() {
    if (_canAnimate()) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop(canceled: true);
      _controller.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _phase,
        child: RepaintBoundary(child: widget.child),
        builder: (context, child) {
          final phase = _phase.value;
          return widget.builder(
            context,
            phase,
            TonosExpressiveAmbientPhaseScope(phase: _phase, child: child!),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _phase.dispose();
    _controller.dispose();
    super.dispose();
  }
}
