import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/tutorial_state_store.dart';

class GuidedTutorialStep {
  final GlobalKey targetKey;
  final String title;
  final String body;
  final IconData icon;

  const GuidedTutorialStep({
    required this.targetKey,
    required this.title,
    required this.body,
    this.icon = Icons.tips_and_updates_outlined,
  });
}

class GuidedTutorialOverlay extends StatefulWidget {
  final List<GuidedTutorialStep> steps;
  final ValueChanged<bool> onFinished;

  const GuidedTutorialOverlay({
    super.key,
    required this.steps,
    required this.onFinished,
  });

  static Future<bool> show(
    BuildContext context, {
    required List<GuidedTutorialStep> steps,
  }) async {
    if (steps.isEmpty) return false;

    final overlay = Overlay.of(context, rootOverlay: true);
    final completer = Completer<bool>();
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (_) => GuidedTutorialOverlay(
            steps: steps,
            onFinished: (completed) {
              entry.remove();
              if (!completer.isCompleted) {
                completer.complete(completed);
              }
            },
          ),
    );

    overlay.insert(entry);
    return completer.future;
  }

  @override
  State<GuidedTutorialOverlay> createState() => _GuidedTutorialOverlayState();
}

class _GuidedTutorialOverlayState extends State<GuidedTutorialOverlay>
    with WidgetsBindingObserver {
  static const _targetPadding = 8.0;
  static const _cardEstimateHeight = 214.0;
  static const _maxMeasureAttempts = 10;
  static const _measureRetryDelay = Duration(milliseconds: 70);

  final _overlayKey = GlobalKey(debugLabel: 'guided_tutorial_overlay_bounds');
  int _index = 0;
  int _measureRequest = 0;
  Rect? _targetRect;
  bool _isMeasuring = true;
  bool _showSkipAllConfirmation = false;

  GuidedTutorialStep get _step => widget.steps[_index];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_measureTarget());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_measureTarget());
    });
  }

  Future<void> _measureTarget() async {
    if (!mounted) return;
    final request = ++_measureRequest;
    setState(() => _isMeasuring = true);

    final targetContext = _step.targetKey.currentContext;
    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 260),
        alignment: 0.36,
      );
      await Future<void>.delayed(const Duration(milliseconds: 280));
    }

    if (!mounted || request != _measureRequest) return;

    Rect? nextRect;
    for (var attempt = 0; attempt < _maxMeasureAttempts; attempt++) {
      nextRect = _resolveTargetRect();
      if (nextRect != null) break;
      await Future<void>.delayed(_measureRetryDelay);
      if (!mounted || request != _measureRequest) return;
    }

    setState(() {
      _targetRect = nextRect;
      _isMeasuring = false;
    });
  }

  Rect? _resolveTargetRect() {
    final renderObject = _step.targetKey.currentContext?.findRenderObject();
    final overlayObject = _overlayKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox ||
        overlayObject is! RenderBox ||
        !renderObject.attached ||
        !overlayObject.attached ||
        !renderObject.hasSize ||
        !overlayObject.hasSize ||
        renderObject.size.isEmpty ||
        overlayObject.size.isEmpty) {
      return null;
    }

    final overlayBounds = Offset.zero & overlayObject.size;
    final overlayTopLeft = overlayObject.localToGlobal(Offset.zero);
    final topLeft = renderObject.localToGlobal(Offset.zero) - overlayTopLeft;
    final bottomRight =
        renderObject.localToGlobal(renderObject.size.bottomRight(Offset.zero)) -
        overlayTopLeft;
    final rect = Rect.fromPoints(topLeft, bottomRight);
    if (rect.width < 4 || rect.height < 4 || !rect.overlaps(overlayBounds)) {
      return null;
    }

    return rect.intersect(overlayBounds);
  }

  void _goTo(int index) {
    setState(() {
      _index = math.max(0, math.min(index, widget.steps.length - 1));
      _targetRect = null;
      _isMeasuring = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_measureTarget());
    });
  }

  void _finish(bool completed) {
    widget.onFinished(completed);
  }

  void _skipAllTutorials() {
    if (_showSkipAllConfirmation) return;
    setState(() => _showSkipAllConfirmation = true);
  }

  void _keepTutorials() {
    setState(() => _showSkipAllConfirmation = false);
  }

  Future<void> _confirmSkipAllTutorials() async {
    setState(() => _showSkipAllConfirmation = false);
    await const TutorialStateStore().skipAll();
    if (!mounted) return;
    _finish(false);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scheme = Theme.of(context).colorScheme;

    return SizedBox.expand(
      key: _overlayKey,
      child: Material(
        color: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final measuredTarget = _targetRect;
            if (_isMeasuring) {
              return const _MeasuringTutorialScrim();
            }
            if (measuredTarget == null) {
              return Stack(
                children: [
                  const ModalBarrier(
                    color: Color(0xAD000000),
                    dismissible: false,
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: media.padding.top + 24,
                    child: _TutorialCard(
                      step: _step,
                      stepNumber: _index + 1,
                      totalSteps: widget.steps.length,
                      canGoBack: _index > 0,
                      isLast: _index == widget.steps.length - 1,
                      onBack: () => _goTo(_index - 1),
                      onNext:
                          _index == widget.steps.length - 1
                              ? () => _finish(true)
                              : () => _goTo(_index + 1),
                      onSkip: () => _finish(false),
                      onSkipAll: _skipAllTutorials,
                    ),
                  ),
                  if (_showSkipAllConfirmation)
                    _SkipAllTutorialConfirmation(
                      onKeepTutorials: _keepTutorials,
                      onSkipAll: _confirmSkipAllTutorials,
                    ),
                ],
              );
            }

            final target = measuredTarget
                .inflate(_targetPadding)
                .intersect(Offset.zero & size);
            final cardTop = _cardTopFor(size, media.padding, target);

            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: CustomPaint(painter: _TutorialScrimPainter(target)),
                  ),
                ),
                Positioned.fromRect(
                  rect: target,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: scheme.primary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.36),
                            blurRadius: 22,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: cardTop,
                  child: _TutorialCard(
                    step: _step,
                    stepNumber: _index + 1,
                    totalSteps: widget.steps.length,
                    canGoBack: _index > 0,
                    isLast: _index == widget.steps.length - 1,
                    onBack: () => _goTo(_index - 1),
                    onNext:
                        _index == widget.steps.length - 1
                            ? () => _finish(true)
                            : () => _goTo(_index + 1),
                    onSkip: () => _finish(false),
                    onSkipAll: _skipAllTutorials,
                  ),
                ),
                if (_showSkipAllConfirmation)
                  _SkipAllTutorialConfirmation(
                    onKeepTutorials: _keepTutorials,
                    onSkipAll: _confirmSkipAllTutorials,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _cardTopFor(Size size, EdgeInsets padding, Rect target) {
    final minTop = padding.top + 12;
    final maxTop = size.height - padding.bottom - _cardEstimateHeight - 12;
    final below = target.bottom + 14;
    final above = target.top - _cardEstimateHeight - 14;

    final preferredTop =
        below + _cardEstimateHeight <= size.height - padding.bottom
            ? below
            : above;

    return preferredTop.clamp(minTop, math.max(minTop, maxTop)).toDouble();
  }
}

class _TutorialCard extends StatelessWidget {
  final GuidedTutorialStep step;
  final int stepNumber;
  final int totalSteps;
  final bool canGoBack;
  final bool isLast;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onSkipAll;

  const _TutorialCard({
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
    required this.canGoBack,
    required this.isLast,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
    required this.onSkipAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.42)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(step.icon, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$stepNumber/$totalSteps',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            step.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(onPressed: onSkip, child: const Text('Skip')),
              TextButton(onPressed: onSkipAll, child: const Text('Skip All')),
              const Spacer(),
              if (canGoBack) ...[
                TextButton(onPressed: onBack, child: const Text('Back')),
                const SizedBox(width: 6),
              ],
              FilledButton(
                onPressed: onNext,
                child: Text(isLast ? 'Done' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkipAllTutorialConfirmation extends StatelessWidget {
  const _SkipAllTutorialConfirmation({
    required this.onKeepTutorials,
    required this.onSkipAll,
  });

  final VoidCallback onKeepTutorials;
  final VoidCallback onSkipAll;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          const ModalBarrier(color: Color(0xB3000000), dismissible: false),
          Center(
            child: SafeArea(
              minimum: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: AlertDialog(
                  title: const Text('Skip all tutorials?'),
                  content: const Text(
                    'This hides every guided tutorial. You can turn them back on anytime in Settings > Guided Tutorials by using Reset All Tutorials.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: onKeepTutorials,
                      child: const Text('Keep tutorials'),
                    ),
                    FilledButton(
                      onPressed: onSkipAll,
                      child: const Text('Skip all'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialScrimPainter extends CustomPainter {
  final Rect targetRect;

  const _TutorialScrimPainter(this.targetRect);

  @override
  void paint(Canvas canvas, Size size) {
    final path =
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(Offset.zero & size)
          ..addRRect(
            RRect.fromRectAndRadius(targetRect, const Radius.circular(22)),
          );
    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.68),
    );
  }

  @override
  bool shouldRepaint(covariant _TutorialScrimPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect;
  }
}

class _MeasuringTutorialScrim extends StatelessWidget {
  const _MeasuringTutorialScrim();

  @override
  Widget build(BuildContext context) {
    return const ModalBarrier(color: Color(0x66000000), dismissible: false);
  }
}
