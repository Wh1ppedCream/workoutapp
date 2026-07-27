import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

class InteractiveTutorialStep {
  final GlobalKey targetKey;
  final int stepNumber;
  final int totalSteps;
  final IconData icon;
  final String title;
  final String body;
  final String? continueLabel;
  final VoidCallback? onContinue;

  const InteractiveTutorialStep({
    required this.targetKey,
    required this.stepNumber,
    required this.totalSteps,
    required this.icon,
    required this.title,
    required this.body,
    this.continueLabel,
    this.onContinue,
  });
}

/// Highlights a live control while leaving the rest of the page usable.
class InteractiveTutorialOverlay extends StatefulWidget {
  final InteractiveTutorialStep step;
  final VoidCallback onSkip;

  const InteractiveTutorialOverlay({
    super.key,
    required this.step,
    required this.onSkip,
  });

  @override
  State<InteractiveTutorialOverlay> createState() =>
      _InteractiveTutorialOverlayState();
}

class _InteractiveTutorialOverlayState extends State<InteractiveTutorialOverlay>
    with WidgetsBindingObserver {
  static const _targetPadding = 8.0;
  static const _cardEstimateHeight = 150.0;
  static const _cardMaxWidth = 360.0;
  static const _measureRetryDelay = Duration(milliseconds: 70);
  static const _maxMeasureAttempts = 8;

  final _boundsKey = GlobalKey(debugLabel: 'interactive_tutorial_bounds');
  final _cardKey = GlobalKey(debugLabel: 'interactive_tutorial_card');
  Rect? _targetRect;
  double? _cardHeight;
  int _measureRequest = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMeasure();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(covariant InteractiveTutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.targetKey != widget.step.targetKey ||
        oldWidget.step.stepNumber != widget.step.stepNumber) {
      _targetRect = null;
      _cardHeight = null;
      _scheduleMeasure();
    }
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_measureTarget());
    });
  }

  Future<void> _measureTarget() async {
    if (!mounted) return;
    final request = ++_measureRequest;
    final targetContext = widget.step.targetKey.currentContext;
    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 220),
        alignment: 0.36,
      );
      await Future<void>.delayed(const Duration(milliseconds: 240));
    }

    if (!mounted || request != _measureRequest) return;
    for (var attempt = 0; attempt < _maxMeasureAttempts; attempt++) {
      final rect = _resolveTargetRect();
      if (rect != null) {
        setState(() => _targetRect = rect);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _measureCard();
        });
        return;
      }
      await Future<void>.delayed(_measureRetryDelay);
      if (!mounted || request != _measureRequest) return;
    }
  }

  void _measureCard() {
    if (!mounted) return;
    final renderObject = _cardKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      return;
    }
    final nextHeight = renderObject.size.height;
    if (_cardHeight != null && (_cardHeight! - nextHeight).abs() < 0.5) {
      return;
    }
    setState(() => _cardHeight = nextHeight);
  }

  Rect? _resolveTargetRect() {
    final targetObject =
        widget.step.targetKey.currentContext?.findRenderObject();
    final boundsObject = _boundsKey.currentContext?.findRenderObject();
    if (targetObject is! RenderBox ||
        boundsObject is! RenderBox ||
        !targetObject.attached ||
        !boundsObject.attached ||
        !targetObject.hasSize ||
        !boundsObject.hasSize ||
        targetObject.size.isEmpty ||
        boundsObject.size.isEmpty) {
      return null;
    }

    final boundsTopLeft = boundsObject.localToGlobal(Offset.zero);
    final rect = Rect.fromPoints(
      targetObject.localToGlobal(Offset.zero) - boundsTopLeft,
      targetObject.localToGlobal(targetObject.size.bottomRight(Offset.zero)) -
          boundsTopLeft,
    );
    final bounds = Offset.zero & boundsObject.size;
    return rect.overlaps(bounds) ? rect.intersect(bounds) : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final target = _targetRect;

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final highlightedTarget = target
              ?.inflate(_targetPadding)
              .intersect(Offset.zero & size);
          final cardHeight = _cardHeight ?? _cardEstimateHeight;
          final cardTop =
              highlightedTarget == null
                  ? media.padding.top + 20
                  : _cardTopFor(
                    size,
                    media.padding,
                    highlightedTarget,
                    cardHeight,
                  );
          final cardWidth = math.min(_cardMaxWidth, size.width - 32);
          final cardLeft =
              highlightedTarget == null
                  ? (size.width - cardWidth) / 2
                  : (highlightedTarget.center.dx - cardWidth / 2)
                      .clamp(16.0, size.width - cardWidth - 16.0)
                      .toDouble();

          return Stack(
            key: _boundsKey,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _InteractiveTutorialScrimPainter(
                      target: highlightedTarget,
                      borderColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: cardLeft,
                width: cardWidth,
                top: cardTop,
                child: _InteractiveTutorialCard(
                  key: _cardKey,
                  step: widget.step,
                  onSkip: widget.onSkip,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _cardTopFor(
    Size size,
    EdgeInsets padding,
    Rect target,
    double cardHeight,
  ) {
    final minTop = padding.top + 12;
    final maxTop = size.height - padding.bottom - cardHeight - 12;
    final below = target.bottom + 14;
    final above = target.top - cardHeight - 14;
    final preferred =
        below + cardHeight <= size.height - padding.bottom ? below : above;
    return preferred.clamp(minTop, math.max(minTop, maxTop)).toDouble();
  }
}

class _InteractiveTutorialScrimPainter extends CustomPainter {
  final Rect? target;
  final Color borderColor;

  const _InteractiveTutorialScrimPainter({
    required this.target,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final focus = target;
    if (focus == null) return;

    final roundedTarget = RRect.fromRectAndRadius(
      focus,
      const Radius.circular(20),
    );
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: 0.42),
    );
    canvas.drawRRect(roundedTarget, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
    canvas.drawRRect(
      roundedTarget,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _InteractiveTutorialScrimPainter oldDelegate) {
    return oldDelegate.target != target ||
        oldDelegate.borderColor != borderColor;
  }
}

class _InteractiveTutorialCard extends StatelessWidget {
  final InteractiveTutorialStep step;
  final VoidCallback onSkip;

  const _InteractiveTutorialCard({
    super.key,
    required this.step,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.65)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(step.icon, color: scheme.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.planCoachStepTitle(
                      step.stepNumber,
                      step.totalSteps,
                      step.title,
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(step.body, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      TextButton(
                        onPressed: onSkip,
                        child: Text(strings.planCoachSkipGuide),
                      ),
                      const Spacer(),
                      if (step.onContinue != null)
                        FilledButton.tonal(
                          onPressed: step.onContinue,
                          child: Text(
                            step.continueLabel ?? strings.planCoachContinue,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
