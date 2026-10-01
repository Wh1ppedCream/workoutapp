import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/physics.dart';

const double _indicatorSlotHeightFraction = 0.82;
const double _indicatorTravelWidthFraction = 0.78;
const double _indicatorSelectedWidthFraction = 0.94;
const double _maximumIndicatorOvershootInSlots = 0.06;
const double _maximumPressShapeOvershoot = 0.08;

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
/// events and clips its visual child to a changing shape. The child keeps its
/// layout, pointer hit testing, and semantic bounds. Pass both border radii to
/// add bounded shape compression/recovery without animating the label itself.
class TonosExpressivePressResponse extends StatefulWidget {
  const TonosExpressivePressResponse({
    super.key,
    required this.enabled,
    required this.child,
    this.borderRadius,
    this.pressedBorderRadius,
  }) : assert((borderRadius == null) == (pressedBorderRadius == null));

  final bool enabled;
  final Widget child;
  final BorderRadius? borderRadius;
  final BorderRadius? pressedBorderRadius;

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
        child: widget.child,
        builder: (context, child) {
          final progress = _controller.value;
          final borderRadius = _currentBorderRadius(progress);

          Widget visual = child!;
          if (borderRadius != null) {
            visual = ClipRRect(
              borderRadius: borderRadius,
              clipBehavior: Clip.antiAlias,
              child: visual,
            );
          }
          return visual;
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
