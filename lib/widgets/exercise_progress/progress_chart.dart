part of '../exercise_progress_section.dart';

class _ExerciseProgressLegend extends StatelessWidget {
  final Color? estimatedColor;

  const _ExerciseProgressLegend({this.estimatedColor});

  @override
  Widget build(BuildContext context) {
    final progressColors = context.progressColors;
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _LegendItem(
          color: progressColors.accent,
          label: AppLocalizations.of(context).exerciseProgressActual,
        ),
        _LegendItem(
          color: estimatedColor ?? progressColors.estimated,
          label: AppLocalizations.of(context).exerciseProgressEstimated,
          dashed: true,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;

  const _LegendItem({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(28, 10),
          painter: _LegendLinePainter(color: color, dashed: dashed),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _ExerciseProgressRecordingRow extends StatelessWidget {
  final ExerciseOneRmPoint point;
  final VoidCallback onTap;
  final bool expressive;

  const _ExerciseProgressRecordingRow({
    required this.point,
    required this.onTap,
    this.expressive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final locale = Localizations.localeOf(context);
    final strings = AppLocalizations.of(context);
    final date = LocalizedFormatters.dateTime(point.displayDateTime, locale);
    final estimatedValue = strings.exerciseProgressEstimatedValue(
      _formatWeight(point.estimatedOneRm, weightUnit, locale: locale),
    );
    final actualValue = point.actualOneRm == null
        ? strings.exerciseProgressNoActual
        : strings.exerciseProgressActualValue(
            _formatWeight(point.actualOneRm!, weightUnit, locale: locale),
          );

    if (expressive) {
      final shapes = context.shapeTokens;
      return TonosExpressivePressResponse(
        enabled: true,
        borderRadius: shapes.exerciseProgressSelector,
        pressedBorderRadius: ExpressiveTrainShapes.compactControlPressed,
        pressedScale: TonosExpressiveMotionTiers.supportingScale,
        pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
        allowReleaseOvershoot: false,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey(
              'exercise-progress-expressive-recording-${point.sessionId}',
            ),
            onTap: onTap,
            borderRadius: shapes.exerciseProgressSelector,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          date,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 3,
                    children: [
                      Text(
                        estimatedValue,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        actualValue,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  date,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(estimatedValue, style: theme.textTheme.bodyMedium),
                  Text(
                    actualValue,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseProgressChart extends StatefulWidget {
  final List<ExerciseOneRmPoint> points;
  final bool showEmptyLabel;
  final bool showAxes;
  final bool interactive;
  final String? exerciseName;
  final WeightUnit weightUnit;
  final Color? tooltipTextColor;
  final Color? actualColor;
  final Color? estimatedColor;
  final Color? plotSurface;

  const _ExerciseProgressChart({
    required this.points,
    this.showEmptyLabel = false,
    this.showAxes = false,
    this.interactive = false,
    this.exerciseName,
    this.weightUnit = WeightUnit.pounds,
    this.tooltipTextColor,
    this.actualColor,
    this.estimatedColor,
    this.plotSurface,
  });

  @override
  State<_ExerciseProgressChart> createState() => _ExerciseProgressChartState();
}

class _ExerciseProgressChartState extends State<_ExerciseProgressChart> {
  int? _selectedIndex;
  final FocusNode _chartFocusNode = FocusNode(
    debugLabel: 'exercise-progress-chart',
  );

  @override
  void initState() {
    super.initState();
    _selectedIndex = _initialSelectedIndex;
  }

  @override
  void dispose() {
    _chartFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ExerciseProgressChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.interactive || widget.points.isEmpty) {
      _selectedIndex = null;
    } else if ((_selectedIndex ?? -1) >= widget.points.length) {
      _selectedIndex = widget.points.length - 1;
    } else if (_selectedIndex == null && oldWidget.points != widget.points) {
      _selectedIndex = _initialSelectedIndex;
    }
  }

  int? get _initialSelectedIndex {
    if (!widget.interactive || widget.points.isEmpty) return null;
    return widget.points.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty && widget.showEmptyLabel) {
      final strings = AppLocalizations.of(context);
      return Center(
        child: Semantics(
          key: const ValueKey('exercise-progress-chart-empty-semantics'),
          container: true,
          label: _chartSemanticLabel(context),
          value: strings.exerciseProgressNoRecordings,
          child: ExcludeSemantics(
            child: Text(
              strings.exerciseProgressNoRecordings,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final progressColors = context.progressColors;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final scale = _ExerciseProgressChartScale(
          points: widget.points,
          size: size,
          showAxes: widget.showAxes,
          textScaler: textScaler,
          textDirection: textDirection,
          weightUnit: widget.weightUnit,
          locale: locale,
        );
        final chart = CustomPaint(
          size: size,
          painter: _ExerciseProgressChartPainter(
            points: widget.points,
            actualColor:
                widget.actualColor ??
                tonosPrimarySeriesForSurface(
                  context,
                  surfaces.exerciseProgressStat,
                ),
            estimatedColor:
                widget.estimatedColor ??
                tonosSecondarySeriesForSurface(
                  context,
                  surfaces.exerciseProgressStat,
                ),
            gridColor: progressColors.grid,
            axisLabelColor: progressColors.label,
            tooltipBackgroundColor: surfaces.exerciseProgressTooltip,
            tooltipTextColor: widget.tooltipTextColor ?? cs.onSurface,
            tooltipBorderRadius: shapes.exerciseProgressTooltip,
            showAxes: widget.showAxes,
            selectedIndex: _selectedIndex,
            weightUnit: widget.weightUnit,
            locale: locale,
            estimatedValueLabel: strings.exerciseProgressEstimatedValue,
            actualValueLabel: strings.exerciseProgressActualValue,
            noActualLabel: strings.exerciseProgressNoActual,
            textScaler: textScaler,
            textDirection: textDirection,
          ),
        );
        final chartPresentation = context.usesExpressivePresentation
            ? RepaintBoundary(
                key: ValueKey(
                  widget.interactive
                      ? 'exercise-progress-detail-plot'
                      : widget.showAxes
                      ? 'exercise-progress-hero-plot'
                      : 'exercise-progress-selector-plot',
                ),
                child: DecoratedBox(
                  // Keep the plot opaque when it sits inside the plum Progress
                  // module; axes, grid, data series, and tooltip contrast are
                  // resolved for this chart surface.
                  decoration: BoxDecoration(
                    color: widget.plotSurface ?? cs.surface,
                    borderRadius: shapes.exerciseProgressStat,
                  ),
                  child: chart,
                ),
              )
            : chart;

        if (!widget.interactive || widget.points.isEmpty) {
          return chartPresentation;
        }

        final currentIndex = _selectedIndex ?? _initialSelectedIndex!;
        final previousIndex = currentIndex - 1;
        final nextIndex = currentIndex + 1;
        final selectedValue = _pointSemanticValue(
          context,
          widget.points[currentIndex],
        );
        return Semantics(
          key: const ValueKey('exercise-progress-chart-semantics'),
          container: true,
          focusable: true,
          label: _chartSemanticLabel(context),
          value: selectedValue,
          increasedValue: nextIndex < widget.points.length
              ? _pointSemanticValue(context, widget.points[nextIndex])
              : null,
          decreasedValue: previousIndex >= 0
              ? _pointSemanticValue(context, widget.points[previousIndex])
              : null,
          hint: AppLocalizations.of(context).exerciseProgressTrendBody,
          onTap: () => _selectPoint(_selectedIndex ?? _initialSelectedIndex!),
          onIncrease: nextIndex < widget.points.length
              ? () => _selectPoint(nextIndex)
              : null,
          onDecrease: previousIndex >= 0
              ? () => _selectPoint(previousIndex)
              : null,
          child: Focus(
            focusNode: _chartFocusNode,
            canRequestFocus: true,
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return KeyEventResult.ignored;
              if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                  event.logicalKey == LogicalKeyboardKey.arrowDown) {
                if (nextIndex < widget.points.length) _selectPoint(nextIndex);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                  event.logicalKey == LogicalKeyboardKey.arrowUp) {
                if (previousIndex >= 0) _selectPoint(previousIndex);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final selected = _nearestPointIndex(
                  details.localPosition,
                  size,
                  scale,
                );
                if (selected == null) return;
                _chartFocusNode.requestFocus();
                _selectPoint(selected);
              },
              child: chartPresentation,
            ),
          ),
        );
      },
    );
  }

  void _selectPoint(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  String _chartSemanticLabel(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final exerciseName = widget.exerciseName;
    return [
      if (exerciseName != null && exerciseName.isNotEmpty) exerciseName,
      strings.exerciseProgressTitle,
      strings.exerciseProgressEstimated,
      strings.exerciseProgressActual,
      widget.weightUnit.shortLabel,
    ].join(', ');
  }

  String _pointSemanticValue(BuildContext context, ExerciseOneRmPoint point) {
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final actual = point.actualOneRm == null
        ? strings.exerciseProgressNoActual
        : strings.exerciseProgressActualValue(
            _formatWeight(
              point.actualOneRm!,
              widget.weightUnit,
              locale: locale,
            ),
          );
    return [
      LocalizedFormatters.dateTime(point.displayDateTime, locale),
      strings.exerciseProgressEstimatedValue(
        _formatWeight(point.estimatedOneRm, widget.weightUnit, locale: locale),
      ),
      actual,
    ].join(', ');
  }

  int? _nearestPointIndex(
    Offset tapPosition,
    Size size,
    _ExerciseProgressChartScale scale,
  ) {
    if (widget.points.isEmpty) return null;
    if (!scale.plotRect.inflate(28).contains(tapPosition)) return null;

    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < widget.points.length; i++) {
      final distance = (tapPosition.dx - scale.xFor(i)).abs();
      if (distance < bestDistance) {
        bestIndex = i;
        bestDistance = distance;
      }
    }

    return bestIndex;
  }
}

class _ExerciseProgressChartPainter extends CustomPainter {
  final List<ExerciseOneRmPoint> points;
  final Color actualColor;
  final Color estimatedColor;
  final Color gridColor;
  final Color axisLabelColor;
  final Color tooltipBackgroundColor;
  final Color tooltipTextColor;
  final BorderRadius tooltipBorderRadius;
  final bool showAxes;
  final int? selectedIndex;
  final WeightUnit weightUnit;
  final Locale locale;
  final String Function(String value) estimatedValueLabel;
  final String Function(String value) actualValueLabel;
  final String noActualLabel;
  final TextScaler textScaler;
  final ui.TextDirection textDirection;

  const _ExerciseProgressChartPainter({
    required this.points,
    required this.actualColor,
    required this.estimatedColor,
    required this.gridColor,
    required this.axisLabelColor,
    required this.tooltipBackgroundColor,
    required this.tooltipTextColor,
    required this.tooltipBorderRadius,
    required this.showAxes,
    required this.selectedIndex,
    required this.weightUnit,
    required this.locale,
    required this.estimatedValueLabel,
    required this.actualValueLabel,
    required this.noActualLabel,
    required this.textScaler,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = _ExerciseProgressChartScale(
      points: points,
      size: size,
      showAxes: showAxes,
      textScaler: textScaler,
      textDirection: textDirection,
      weightUnit: weightUnit,
      locale: locale,
    );
    if (!scale.hasUsableValues) return;

    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    for (final tick in scale.yTicks) {
      final y = scale.yFor(tick);
      canvas.drawLine(
        Offset(scale.plotRect.left, y),
        Offset(scale.plotRect.right, y),
        gridPaint,
      );
      if (showAxes) {
        _drawText(
          canvas,
          _formatAxisWeight(tick, weightUnit, locale),
          Offset(0, y - 7),
          TextStyle(
            color: axisLabelColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
          maxWidth: scale.axisLabelMaxWidth,
        );
      }
    }

    if (showAxes) {
      _drawDateLabels(canvas, scale);
    }

    final estimatedOffsets = <Offset>[
      for (var i = 0; i < points.length; i++)
        if (points[i].estimatedOneRm > 0)
          scale.pointFor(i, points[i].estimatedOneRm),
    ];
    final actualOffsets = <Offset>[
      for (var i = 0; i < points.length; i++)
        if ((points[i].actualOneRm ?? 0) > 0)
          scale.pointFor(i, points[i].actualOneRm!),
    ];

    _drawPolyline(
      canvas,
      estimatedOffsets,
      Paint()
        ..color = estimatedColor.withValues(alpha: 0.85)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
      dashed: true,
    );
    _drawPolyline(
      canvas,
      actualOffsets,
      Paint()
        ..color = actualColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    if (showAxes && selectedIndex != null) {
      _drawSelectedPoint(canvas, size, scale, selectedIndex!);
    }
  }

  void _drawDateLabels(Canvas canvas, _ExerciseProgressChartScale scale) {
    final dateStyle = TextStyle(
      color: axisLabelColor,
      fontSize: 10,
      fontWeight: FontWeight.w700,
    );
    for (final index in scale.dateTickIndexes) {
      final label = LocalizedFormatters.shortDate(
        points[index].calendarDay.toLocalDateTime(),
        locale,
      );
      final painter = TextPainter(
        text: TextSpan(text: label, style: dateStyle),
        textDirection: textDirection,
        textScaler: textScaler,
      )..layout();
      final x = math.max(
        scale.plotRect.left,
        math.min(
          scale.plotRect.right - painter.width,
          scale.xFor(index) - painter.width / 2,
        ),
      );
      painter.paint(canvas, Offset(x, scale.plotRect.bottom + 9));
    }
  }

  void _drawSelectedPoint(
    Canvas canvas,
    Size size,
    _ExerciseProgressChartScale scale,
    int index,
  ) {
    if (index < 0 || index >= points.length) return;

    final point = points[index];
    final x = scale.xFor(index);
    final guidePaint = Paint()
      ..color = actualColor.withValues(alpha: 0.28)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(x, scale.plotRect.top),
      Offset(x, scale.plotRect.bottom),
      guidePaint,
    );

    final highlightPaint = Paint()
      ..color = tooltipBackgroundColor
      ..style = PaintingStyle.fill;
    final estimatedPaint = Paint()
      ..color = estimatedColor
      ..style = PaintingStyle.fill;
    if (point.estimatedOneRm > 0) {
      final offset = scale.pointFor(index, point.estimatedOneRm);
      canvas.drawCircle(offset, 6.5, highlightPaint);
      canvas.drawCircle(offset, 4.4, estimatedPaint);
    }

    if ((point.actualOneRm ?? 0) > 0) {
      final offset = scale.pointFor(index, point.actualOneRm!);
      canvas.drawCircle(offset, 7, highlightPaint);
      canvas.drawCircle(offset, 4.8, Paint()..color = actualColor);
    }

    _drawTooltip(canvas, size, scale, point);
  }

  void _drawTooltip(
    Canvas canvas,
    Size size,
    _ExerciseProgressChartScale scale,
    ExerciseOneRmPoint point,
  ) {
    final titleStyle = TextStyle(
      color: tooltipTextColor,
      fontSize: 11,
      fontWeight: FontWeight.w900,
    );
    final bodyStyle = TextStyle(
      color: tooltipTextColor.withValues(alpha: 0.86),
      fontSize: 10,
      fontWeight: FontWeight.w700,
    );
    final lines = [
      (LocalizedFormatters.dateTime(point.displayDateTime, locale), titleStyle),
      (
        estimatedValueLabel(
          _formatWeight(point.estimatedOneRm, weightUnit, locale: locale),
        ),
        bodyStyle,
      ),
      (
        point.actualOneRm == null
            ? noActualLabel
            : actualValueLabel(
                _formatWeight(point.actualOneRm!, weightUnit, locale: locale),
              ),
        bodyStyle,
      ),
    ];

    final painters = lines
        .map(
          (line) =>
              TextPainter(
                text: TextSpan(text: line.$1, style: line.$2),
                textDirection: textDirection,
                textScaler: textScaler,
              )..layout(
                maxWidth: math.min(150 * textScaler.scale(1), size.width - 20),
              ),
        )
        .toList();
    final width =
        painters.fold<double>(0, (maxWidth, painter) {
          return math.max(maxWidth, painter.width);
        }) +
        20;
    final height =
        painters.fold<double>(0, (sum, painter) => sum + painter.height) + 16;
    final selectedX = scale.xFor(points.indexOf(point));
    final maxLeft = math.max(2.0, size.width - width - 2);
    final left = math.max(2.0, math.min(maxLeft, selectedX - width / 2));
    final rect = Rect.fromLTWH(left, 2, width, height);
    final background = Paint()
      ..color = tooltipBackgroundColor.withValues(alpha: 0.96)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(tooltipBorderRadius.toRRect(rect), background);

    var y = rect.top + 8;
    for (final painter in painters) {
      painter.paint(canvas, Offset(rect.left + 10, y));
      y += painter.height;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    required double maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 2,
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, offset);
  }

  void _drawPolyline(
    Canvas canvas,
    List<Offset> offsets,
    Paint paint, {
    bool dashed = false,
  }) {
    if (offsets.isEmpty) return;
    if (offsets.length == 1) {
      canvas.drawCircle(offsets.single, 3.5, paint);
      return;
    }

    for (var i = 1; i < offsets.length; i++) {
      if (dashed) {
        _drawDashedLine(canvas, offsets[i - 1], offsets[i], paint);
      } else {
        canvas.drawLine(offsets[i - 1], offsets[i], paint);
      }
    }
    for (final offset in offsets) {
      canvas.drawCircle(offset, 3.2, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 6.0;
    const gapLength = 4.0;
    final distance = (end - start).distance;
    if (distance <= 0) return;

    final direction = (end - start) / distance;
    var traveled = 0.0;
    while (traveled < distance) {
      final dashEnd = math.min(traveled + dashLength, distance);
      canvas.drawLine(
        start + direction * traveled,
        start + direction * dashEnd,
        paint,
      );
      traveled += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _ExerciseProgressChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.actualColor != actualColor ||
        oldDelegate.estimatedColor != estimatedColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.axisLabelColor != axisLabelColor ||
        oldDelegate.tooltipBackgroundColor != tooltipBackgroundColor ||
        oldDelegate.tooltipTextColor != tooltipTextColor ||
        oldDelegate.tooltipBorderRadius != tooltipBorderRadius ||
        oldDelegate.showAxes != showAxes ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.weightUnit != weightUnit ||
        oldDelegate.locale != locale ||
        oldDelegate.noActualLabel != noActualLabel ||
        oldDelegate.textScaler != textScaler ||
        oldDelegate.textDirection != textDirection;
  }
}

class _ExerciseProgressChartScale {
  final List<ExerciseOneRmPoint> points;
  final Size size;
  final bool showAxes;
  final TextScaler textScaler;
  final ui.TextDirection textDirection;
  final WeightUnit weightUnit;
  final Locale locale;

  _ExerciseProgressChartScale({
    required this.points,
    required this.size,
    required this.showAxes,
    required this.textScaler,
    required this.textDirection,
    required this.weightUnit,
    required this.locale,
  });

  late final List<double> _values = <double>[
    for (final point in points)
      if (point.estimatedOneRm > 0) point.estimatedOneRm,
    for (final point in points)
      if ((point.actualOneRm ?? 0) > 0) point.actualOneRm!,
  ];

  late final Rect plotRect = showAxes
      ? Rect.fromLTWH(
          axisGutter,
          topGutter,
          math.max(1.0, size.width - axisGutter - 4),
          math.max(1.0, size.height - topGutter - bottomGutter),
        )
      : Rect.fromLTWH(
          0,
          6,
          math.max(1.0, size.width),
          math.max(1.0, size.height - 12),
        );

  late final double axisLabelMaxWidth = math.max(1.0, axisGutter - 6);
  late final double axisGutter = math.max(26, _axisLabelWidth + 8);
  late final double topGutter = math.max(18, _axisLabelHeight / 2 + 7);
  late final double bottomGutter = math.max(42, _dateLabelHeight + 12);
  late final double _axisLabelWidth = _measureLabels([
    for (final tick in yTicks) _formatAxisWeight(tick, weightUnit, locale),
  ], const TextStyle(fontSize: 10, fontWeight: FontWeight.w700));
  late final double _axisLabelHeight = _measureLabelHeight(
    const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
  );
  late final double _dateLabelHeight = _measureLabelHeight(
    const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
  );

  double _measureLabels(List<String> labels, TextStyle style) {
    var width = 0.0;
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: textDirection,
        textScaler: textScaler,
      )..layout();
      width = math.max(width, painter.width);
    }
    return width;
  }

  double _measureLabelHeight(TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout();
    return painter.height;
  }

  late final double _rawMinY = _values.isEmpty ? 0 : _values.reduce(math.min);
  late final double _rawMaxY = _values.isEmpty ? 1 : _values.reduce(math.max);
  late final double _rangeY = math.max(1.0, _rawMaxY - _rawMinY);
  late final double _paddingY = math.max(2.0, _rangeY * 0.08);
  late final double _paddedMinY = math.max(0, _rawMinY - _paddingY);
  late final double _paddedMaxY = _rawMaxY + _paddingY;
  late final double _tickStep = _niceTickStep(
    math.max(1.0, (_paddedMaxY - _paddedMinY) / 2),
  );
  late final double minY = (_paddedMinY / _tickStep).floor() * _tickStep;
  late final double maxY = math.max(
    minY + 1,
    (_paddedMaxY / _tickStep).ceil() * _tickStep,
  );

  bool get hasUsableValues => _values.isNotEmpty;

  List<double> get yTicks => [minY, (minY + maxY) / 2, maxY];

  List<int> get dateTickIndexes {
    if (points.isEmpty) return const [];
    if (points.length <= 4) {
      return [for (var i = 0; i < points.length; i++) i];
    }
    return [0, points.length ~/ 2, points.length - 1];
  }

  double xFor(int index) {
    if (points.length <= 1) return plotRect.center.dx;
    final normalized = index / (points.length - 1);
    return plotRect.left + plotRect.width * normalized;
  }

  double yFor(double value) {
    final normalized = ((value - minY) / (maxY - minY))
        .clamp(0.0, 1.0)
        .toDouble();
    return plotRect.bottom - plotRect.height * normalized;
  }

  Offset pointFor(int index, double value) {
    return Offset(xFor(index), yFor(value));
  }

  static double _niceTickStep(double value) {
    if (value <= 0) return 1;
    final scale = math
        .pow(10, (math.log(value) / math.ln10).floor())
        .toDouble();
    final normalized = value / scale;
    final multiplier = normalized <= 1
        ? 1.0
        : normalized <= 1.5
        ? 1.5
        : normalized <= 2
        ? 2.0
        : normalized <= 2.5
        ? 2.5
        : normalized <= 3
        ? 3.0
        : normalized <= 4
        ? 4.0
        : normalized <= 5
        ? 5.0
        : normalized <= 7.5
        ? 7.5
        : 10.0;
    return multiplier * scale;
  }
}

class _LegendLinePainter extends CustomPainter {
  final Color color;
  final bool dashed;

  const _LegendLinePainter({required this.color, required this.dashed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }

    var x = 0.0;
    while (x < size.width) {
      final end = math.min(x + 5, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += 9;
    }
  }

  @override
  bool shouldRepaint(covariant _LegendLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.dashed != dashed;
  }
}

String _formatWeight(double value, WeightUnit unit, {Locale? locale}) {
  return WeightUnitFormatter.formatWeight(value, unit, locale: locale);
}

String _formatAxisWeight(double value, WeightUnit unit, [Locale? locale]) {
  final displayValue = WeightUnitFormatter.fromPounds(value, unit);
  final rounded = displayValue.round();
  if (rounded >= 1000) {
    final compact = rounded / 1000;
    final digits = compact >= 10 ? 0 : 1;
    final text = locale == null
        ? compact.toStringAsFixed(digits)
        : LocalizedFormatters.number(
            compact,
            locale,
            minimumFractionDigits: digits,
            maximumFractionDigits: digits,
          );
    return '${text}k';
  }
  return locale == null
      ? '$rounded'
      : LocalizedFormatters.number(rounded, locale, maximumFractionDigits: 0);
}
