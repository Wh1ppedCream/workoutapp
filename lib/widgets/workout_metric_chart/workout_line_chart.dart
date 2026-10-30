part of '../workout_metric_chart_card.dart';

class _InteractiveWorkoutLineChart extends StatefulWidget {
  final List<WorkoutReportBucket> buckets;
  final WorkoutReportMetric metric;
  final _ReportBucketInterval interval;
  final WorkoutReportRange range;
  final bool rangeDataReady;
  final bool showValueLabels;
  final WeightUnit weightUnit;

  const _InteractiveWorkoutLineChart({
    required this.buckets,
    required this.metric,
    required this.interval,
    required this.range,
    required this.rangeDataReady,
    required this.showValueLabels,
    required this.weightUnit,
  });

  @override
  State<_InteractiveWorkoutLineChart> createState() =>
      _InteractiveWorkoutLineChartState();
}

class _InteractiveWorkoutLineChartState
    extends State<_InteractiveWorkoutLineChart>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  late final _dataMotion = AnimationController(
    vsync: this,
    duration: TonosExpressiveStateMotion.data,
    value: 1,
  );
  late List<double> _fromValues;
  late List<double> _targetValues;
  late List<DateTime> _valueDates;
  bool _pendingRangeReveal = false;
  bool _entryMotionStarted = false;

  List<double> get _paintedValues {
    if (_dataMotion.isCompleted) return _targetValues;
    final t = TonosExpressiveStateMotion.effects.transform(_dataMotion.value);
    return [
      for (var i = 0; i < _targetValues.length; i++)
        _fromValues[i] + (_targetValues[i] - _fromValues[i]) * t,
    ];
  }

  @override
  void initState() {
    super.initState();
    _fromValues = _targetValues = [
      for (final bucket in widget.buckets) bucket.valueFor(widget.metric),
    ];
    _valueDates = [for (final bucket in widget.buckets) bucket.start];
    _pendingRangeReveal = !widget.rangeDataReady;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!TonosExpressiveStateMotion.enabled(context)) {
      _dataMotion.value = 1;
    } else if (!_entryMotionStarted && widget.rangeDataReady) {
      _fromValues = List.filled(_targetValues.length, 0);
      _dataMotion.forward(from: 0);
    }
    _entryMotionStarted = true;
  }

  final FocusNode _focusNode = FocusNode(debugLabel: 'workout-report-chart');

  @override
  void dispose() {
    _dataMotion.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _InteractiveWorkoutLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = [
      for (final bucket in widget.buckets) bucket.valueFor(widget.metric),
    ];
    final dates = [for (final bucket in widget.buckets) bucket.start];
    final datesChanged =
        dates.length != _valueDates.length ||
        List.generate(
          dates.length,
          (i) => i,
        ).any((i) => dates[i] != _valueDates[i]);
    final rangeChanged = oldWidget.range != widget.range;
    final rangeTransition = rangeChanged || _pendingRangeReveal;
    if (rangeTransition) {
      _pendingRangeReveal = !widget.rangeDataReady;
    }
    // Regrouped dates start at the baseline rather than borrowing values from
    // unrelated buckets. Wait for the actual query result before moving them.
    final revealRange = rangeTransition && widget.rangeDataReady;
    final regrouped =
        !rangeTransition &&
        oldWidget.metric == widget.metric &&
        (datesChanged || oldWidget.interval != widget.interval);
    final changed =
        next.length != _targetValues.length ||
        List.generate(
          next.length,
          (i) => i,
        ).any((i) => next[i] != _targetValues[i] || dates[i] != _valueDates[i]);
    if (changed || revealRange) {
      final painted = _paintedValues;
      final byDate = {
        for (var i = 0; i < _valueDates.length; i++) _valueDates[i]: painted[i],
      };
      _fromValues = [
        for (var i = 0; i < next.length; i++)
          revealRange || regrouped
              ? 0.0
              : rangeTransition ||
                    oldWidget.metric != widget.metric ||
                    oldWidget.interval != widget.interval
              ? next[i]
              : byDate[dates[i]] ?? next[i],
      ];
      _targetValues = next;
      _valueDates = dates;
      final hasTransition = List.generate(
        next.length,
        (i) => i,
      ).any((i) => _fromValues[i] != next[i]);
      if (hasTransition &&
          !_pendingRangeReveal &&
          TonosExpressiveStateMotion.enabled(context)) {
        _dataMotion.forward(from: 0);
      } else {
        _dataMotion.value = 1;
      }
    }
    if (rangeChanged ||
        oldWidget.buckets != widget.buckets ||
        oldWidget.metric != widget.metric ||
        oldWidget.interval != widget.interval) {
      _selectedIndex = null;
    } else if ((_selectedIndex ?? -1) >= widget.buckets.length) {
      _selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressColors = context.progressColors;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final expressive = context.usesExpressivePresentation;
    final destination = expressive
        ? Theme.of(context).extension<AppExpressiveDestinationTokens>()
        : null;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final textScaler = MediaQuery.textScalerOf(context);
        final textDirection = Directionality.of(context);
        final locale = Localizations.localeOf(context);
        final strings = AppLocalizations.of(context);
        final latestIndex = widget.buckets.isEmpty
            ? null
            : widget.buckets.length - 1;
        final semanticIndex = _selectedIndex ?? latestIndex;
        final semanticsValue = semanticIndex == null
            ? _emptyChartSemanticsValue(metric: widget.metric, strings: strings)
            : _chartPointSemanticsValue(
                bucket: widget.buckets[semanticIndex],
                metric: widget.metric,
                interval: widget.interval,
                weightUnit: widget.weightUnit,
                strings: strings,
                locale: locale,
                isLatest: _selectedIndex == null,
              );
        String? adjacentPointValue(int delta) {
          final current = semanticIndex;
          if (current == null) return null;
          final index = current + delta;
          if (index < 0 || index >= widget.buckets.length) return null;
          return _chartPointSemanticsValue(
            bucket: widget.buckets[index],
            metric: widget.metric,
            interval: widget.interval,
            weightUnit: widget.weightUnit,
            strings: strings,
            locale: locale,
            isLatest: _selectedIndex == null && index == latestIndex,
          );
        }

        final chart = TonosExpressiveAnimatedValue(
          value: (_selectedIndex ?? latestIndex ?? 0).toDouble(),
          builder: (context, selectionPosition) => AnimatedBuilder(
            animation: _dataMotion,
            builder: (context, _) => CustomPaint(
              key: const ValueKey('workout-report-chart-canvas'),
              size: size,
              painter: _WorkoutLineChartPainter(
                buckets: widget.buckets,
                metric: widget.metric,
                interval: widget.interval,
                strings: strings,
                accent: tonosPrimarySeriesForSurface(
                  context,
                  _workoutReportChartSurface(context),
                ),
                grid: progressColors.grid,
                labelColor: progressColors.label,
                tooltipBackground: expressive
                    ? destination?.surfaceSelected ??
                          context.cs.primaryContainer
                    : surfaces.workoutMetricTooltip,
                tooltipTextColor: expressive
                    ? destination?.onSurfaceSelected ??
                          context.cs.onPrimaryContainer
                    : context.cs.onSurface,
                tooltipOutline: expressive
                    ? destination?.outlineAccent ?? context.cs.primary
                    : null,
                tooltipBorderRadius: shapes.workoutMetricTooltip,
                showValueLabels: widget.showValueLabels,
                selectedIndex: _selectedIndex,
                selectionPosition: _selectedIndex == null
                    ? null
                    : selectionPosition,
                seriesValues: context.usesExpressivePresentation
                    ? _paintedValues
                    : null,
                seriesOpacity: expressive && _pendingRangeReveal ? 0 : 1,
                weightUnit: widget.weightUnit,
                locale: locale,
                textScaler: textScaler,
                textDirection: textDirection,
              ),
            ),
          ),
        );

        return Semantics(
          key: const ValueKey('workout-report-chart-semantics'),
          container: true,
          focusable: widget.buckets.isNotEmpty,
          selected: _selectedIndex != null,
          label: _chartSemanticsLabel(
            metric: widget.metric,
            range: widget.range,
            strings: strings,
          ),
          value: semanticsValue,
          increasedValue: adjacentPointValue(1),
          decreasedValue: adjacentPointValue(-1),
          liveRegion: _selectedIndex != null,
          onTap: widget.buckets.isEmpty ? null : _selectLatestBucket,
          onIncrease: adjacentPointValue(1) == null
              ? null
              : () => _moveSelection(1),
          onDecrease: adjacentPointValue(-1) == null
              ? null
              : () => _moveSelection(-1),
          child: Focus(
            focusNode: _focusNode,
            canRequestFocus: widget.buckets.isNotEmpty,
            onKeyEvent: _handleKeyEvent,
            child: ExcludeSemantics(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  final selected = _nearestBucketIndex(
                    details.localPosition,
                    size,
                    textScale: textScaler.scale(1),
                    textDirection: textDirection,
                  );
                  if (selected == null) return;
                  _focusNode.requestFocus();
                  setState(() => _selectedIndex = selected);
                },
                child: chart,
              ),
            ),
          ),
        );
      },
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || widget.buckets.isEmpty) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _moveSelection(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveSelection(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _selectLatestBucket() {
    if (widget.buckets.isEmpty) return;
    setState(() => _selectedIndex = widget.buckets.length - 1);
  }

  void _moveSelection(int delta) {
    if (widget.buckets.isEmpty) return;
    final current = _selectedIndex ?? widget.buckets.length - 1;
    final next = (current + delta).clamp(0, widget.buckets.length - 1).toInt();
    if (next == current) return;
    setState(() => _selectedIndex = next);
  }

  int? _nearestBucketIndex(
    Offset tapPosition,
    Size size, {
    required double textScale,
    required TextDirection textDirection,
  }) {
    if (widget.buckets.isEmpty) return null;
    final geometry = _WorkoutLineChartGeometry(
      buckets: widget.buckets,
      metric: widget.metric,
      size: size,
      textScale: textScale,
      textDirection: textDirection,
    );
    if (!geometry.plotRect.inflate(28).contains(tapPosition)) return null;

    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var index = 0; index < widget.buckets.length; index++) {
      final distance = (tapPosition.dx - geometry.xFor(index)).abs();
      if (distance < bestDistance) {
        bestIndex = index;
        bestDistance = distance;
      }
    }
    return bestIndex;
  }
}

String _emptyChartSemanticsValue({
  required WorkoutReportMetric metric,
  required AppLocalizations strings,
}) {
  return '${_emptyMetricTitle(metric, strings)}. '
      '${_emptyMetricSubtitle(metric, strings)}';
}

String _chartSemanticsLabel({
  required WorkoutReportMetric metric,
  required WorkoutReportRange range,
  required AppLocalizations strings,
}) {
  return '${strings.workoutReportTitle}, ${_chartTitle(metric, range, strings)}';
}

String _chartPointSemanticsValue({
  required WorkoutReportBucket bucket,
  required WorkoutReportMetric metric,
  required _ReportBucketInterval interval,
  required WeightUnit weightUnit,
  required AppLocalizations strings,
  required Locale locale,
  required bool isLatest,
}) {
  final unit = _metricTooltipValue(
    bucket.valueFor(metric),
    metric,
    weightUnit,
    strings,
    locale,
  );
  final date = _bucketTooltipLabel(bucket, interval, locale);
  final point = strings.workoutReportUnitOnDate(unit, date);
  return isLatest ? '${strings.healthLatest}: $point' : point;
}

class _WorkoutLineChartGeometry {
  static const _axisWidth = 42.0;
  static const _outerMargin = 14.0;
  static const _topMargin = 18.0;
  static const _bottomMargin = 32.0;

  final List<WorkoutReportBucket> buckets;
  final WorkoutReportMetric metric;
  final Size size;
  final double textScale;
  final TextDirection textDirection;

  _WorkoutLineChartGeometry({
    required this.buckets,
    required this.metric,
    required this.size,
    required this.textScale,
    required this.textDirection,
  });

  double get _scaledText => textScale.clamp(1.0, 2.0).toDouble();
  double get axisWidth => math.min(size.width * 0.32, _axisWidth * _scaledText);
  double get outerMargin => _outerMargin * _scaledText;
  double get topMargin => _topMargin * _scaledText;
  double get bottomMargin => _bottomMargin * _scaledText;
  double get leftInset =>
      textDirection == TextDirection.ltr ? axisWidth : outerMargin;
  double get rightInset =>
      textDirection == TextDirection.ltr ? outerMargin : axisWidth;

  late final Rect plotRect = Rect.fromLTWH(
    leftInset,
    topMargin,
    math.max(1.0, size.width - leftInset - rightInset),
    math.max(1.0, size.height - topMargin - bottomMargin),
  );

  late final List<double> values = buckets
      .map((bucket) => bucket.valueFor(metric))
      .toList();

  late final double yMax = _WorkoutLineChartPainter._niceMax(
    metric,
    values.fold<double>(0, math.max),
  );

  late final List<Offset> points = [
    for (var index = 0; index < buckets.length; index++)
      Offset(xFor(index), yFor(values[index])),
  ];

  double xFor(int index) {
    if (buckets.length <= 1) return plotRect.center.dx;
    return plotRect.left + plotRect.width * (index / (buckets.length - 1));
  }

  double yFor(double value) {
    if (yMax <= 0) return plotRect.bottom;
    final normalized = (value / yMax).clamp(0.0, 1.0).toDouble();
    return plotRect.bottom - plotRect.height * normalized;
  }
}

class _WorkoutLineChartPainter extends CustomPainter {
  final List<WorkoutReportBucket> buckets;
  final WorkoutReportMetric metric;
  final _ReportBucketInterval interval;
  final AppLocalizations strings;
  final Color accent;
  final Color grid;
  final Color labelColor;
  final Color tooltipBackground;
  final Color tooltipTextColor;
  final Color? tooltipOutline;
  final BorderRadius tooltipBorderRadius;
  final double seriesOpacity;
  final bool showValueLabels;
  final int? selectedIndex;
  final double? selectionPosition;
  final List<double>? seriesValues;
  final WeightUnit weightUnit;
  final Locale locale;
  final TextScaler textScaler;
  final TextDirection textDirection;

  const _WorkoutLineChartPainter({
    required this.buckets,
    required this.metric,
    required this.interval,
    required this.strings,
    required this.accent,
    required this.grid,
    required this.labelColor,
    required this.tooltipBackground,
    required this.tooltipTextColor,
    required this.tooltipBorderRadius,
    this.tooltipOutline,
    this.seriesOpacity = 1,
    this.showValueLabels = false,
    this.selectedIndex,
    this.selectionPosition,
    this.seriesValues,
    required this.weightUnit,
    required this.locale,
    required this.textScaler,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = _WorkoutLineChartGeometry(
      buckets: buckets,
      metric: metric,
      size: size,
      textScale: textScaler.scale(1),
      textDirection: textDirection,
    );
    final values = geometry.values;
    final yMax = geometry.yMax;
    final plotRect = geometry.plotRect;

    final gridPaint = Paint()
      ..color = grid.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    final labelStyle = TextStyle(
      color: labelColor.withValues(alpha: 0.82),
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    final tickValues = workoutReportAxisTickValues(
      metric: metric,
      maximum: yMax,
    );
    final gridLineCount = tickValues.length - 1;
    final tickLabelEvery = textScaler.scale(1) >= 1.5 ? 2 : 1;
    for (var i = 0; i < tickValues.length; i++) {
      final value = tickValues[i];
      final y = geometry.yFor(value);
      _drawDashedLine(
        canvas,
        Offset(plotRect.left, y),
        Offset(plotRect.right, y),
        gridPaint,
      );
      if (i == 0 || i == gridLineCount || i % tickLabelEvery == 0) {
        _drawText(
          canvas,
          _formatAxis(value, metric, weightUnit, locale),
          Offset(
            textDirection == TextDirection.ltr
                ? 0
                : size.width - geometry.axisWidth,
            y - textScaler.scale(8),
          ),
          labelStyle,
          maxWidth: geometry.axisWidth - textScaler.scale(8),
          align: textDirection == TextDirection.ltr
              ? TextAlign.right
              : TextAlign.left,
        );
      }
    }

    if (buckets.isEmpty) return;

    final pointCount = buckets.length;
    final maxDateLabels = math.max(
      2,
      (plotRect.width / textScaler.scale(56)).floor(),
    );
    final labelEvery = math.max(1, (pointCount / maxDateLabels).ceil());
    // Axes, labels, hit testing and semantics use the actual target dataset.
    // Only the painted series interpolates, keeping the scale stable.
    final points = seriesValues == null
        ? geometry.points
        : [
            for (var i = 0; i < buckets.length; i++)
              Offset(geometry.xFor(i), geometry.yFor(seriesValues![i])),
          ];
    final dateStyle = labelStyle.copyWith(fontSize: 10);
    final dateLabelWidths = List<double>.filled(buckets.length, 0);
    for (var index = 0; index < buckets.length; index++) {
      if (index % labelEvery != 0 && index != buckets.length - 1) continue;
      final dateLabel = _chartDateLabel(buckets[index], interval, locale);
      final measure = TextPainter(
        text: TextSpan(text: dateLabel, style: dateStyle),
        textDirection: textDirection,
        textScaler: textScaler,
        maxLines: 1,
        ellipsis: '\u2026',
      )..layout();
      dateLabelWidths[index] = math.min(
        geometry.plotRect.width,
        math.max(textScaler.scale(56), measure.width),
      );
    }
    final dateLabelPlacements = {
      for (final placement in layoutWorkoutReportDateLabelPlacements(
        pointCenters: points,
        labelWidths: dateLabelWidths,
        labelEvery: labelEvery,
        plotRect: geometry.plotRect,
        minimumGap: textScaler.scale(6),
      ))
        placement.index: placement,
    };

    final fillPath = Path()
      ..moveTo(points.first.dx, plotRect.bottom)
      ..lineTo(points.first.dx, points.first.dy);
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final current = points[index];
      linePath.lineTo(current.dx, current.dy);
      fillPath.lineTo(current.dx, current.dy);
    }
    fillPath
      ..lineTo(points.last.dx, plotRect.bottom)
      ..close();

    // Hide retained previous-query data while a new range loads. Once ready,
    // its points move from the baseline at full opacity; axes stay steady.
    if (seriesOpacity < 1) {
      canvas.saveLayer(
        Offset.zero & size,
        Paint()..color = Colors.white.withValues(alpha: seriesOpacity),
      );
    }
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, plotRect.top),
          Offset(0, plotRect.bottom),
          [accent.withValues(alpha: 0.24), accent.withValues(alpha: 0.02)],
        ),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = accent
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    for (var i = 0; i < buckets.length; i++) {
      final value = values[i];
      final point = points[i];
      final pointRadius = value > 0 ? 4.5 : 2.8;
      canvas.drawCircle(point, pointRadius, Paint()..color = accent);
      canvas.drawCircle(
        point,
        value > 0 ? 2.4 : 1.4,
        Paint()..color = labelColor.withValues(alpha: 0.9),
      );

      if (showValueLabels && value > 0) {
        final valueLabelWidth = textScaler.scale(36);
        _drawText(
          canvas,
          _formatAxis(value, metric, weightUnit, locale),
          Offset(
            (point.dx - valueLabelWidth / 2).clamp(
              geometry.plotRect.left,
              geometry.plotRect.right - valueLabelWidth,
            ),
            math.max(0, point.dy - textScaler.scale(20)),
          ),
          labelStyle.copyWith(
            color: labelColor.withValues(alpha: 0.95),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
          maxWidth: valueLabelWidth,
          align: TextAlign.center,
        );
      }
    }
    if (seriesOpacity < 1) canvas.restore();

    for (var i = 0; i < buckets.length; i++) {
      final datePlacement = dateLabelPlacements[i];
      if (datePlacement != null) {
        _drawText(
          canvas,
          _chartDateLabel(buckets[i], interval, locale),
          Offset(datePlacement.left, plotRect.bottom + textScaler.scale(8)),
          dateStyle,
          maxWidth: datePlacement.width,
          align: TextAlign.center,
        );
      }
    }

    if (selectedIndex != null) {
      _drawSelectedBucket(
        canvas,
        size,
        geometry,
        selectedIndex!,
        labelStyle,
        points,
      );
    }
  }

  void _drawSelectedBucket(
    Canvas canvas,
    Size size,
    _WorkoutLineChartGeometry geometry,
    int index,
    TextStyle labelStyle,
    List<Offset> points,
  ) {
    if (index < 0 || index >= buckets.length) return;

    final position = (selectionPosition ?? index.toDouble()).clamp(
      0.0,
      points.length - 1.0,
    );
    final point = Offset.lerp(
      points[position.floor()],
      points[position.ceil()],
      position - position.floor(),
    )!;
    final bucket = buckets[index];
    final value = bucket.valueFor(metric);
    final guidePaint = Paint()
      ..color = accent.withValues(alpha: 0.28)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(point.dx, geometry.plotRect.top),
      Offset(point.dx, geometry.plotRect.bottom),
      guidePaint,
    );
    canvas.drawCircle(
      point,
      7,
      Paint()..color = tooltipBackground.withValues(alpha: 0.98),
    );
    canvas.drawCircle(point, 4.8, Paint()..color = accent);

    final titleStyle = labelStyle.copyWith(
      color: tooltipTextColor,
      fontSize: 11,
      fontWeight: FontWeight.w900,
    );
    final bodyStyle = labelStyle.copyWith(
      color: tooltipTextColor.withValues(alpha: 0.86),
      fontSize: 10,
      fontWeight: FontWeight.w800,
    );
    final tooltipLines = [
      (_bucketTooltipLabel(bucket, interval, locale), titleStyle),
      (
        _metricTooltipValue(value, metric, weightUnit, strings, locale),
        bodyStyle,
      ),
    ];
    final maxTooltipTextWidth = math.max(
      1.0,
      math.min(size.width - textScaler.scale(20), textScaler.scale(150)),
    );
    final painters = tooltipLines
        .map(
          (line) => TextPainter(
            text: TextSpan(text: line.$1, style: line.$2),
            textDirection: textDirection,
            textScaler: textScaler,
            textAlign: textDirection == TextDirection.ltr
                ? TextAlign.left
                : TextAlign.right,
          )..layout(maxWidth: maxTooltipTextWidth),
        )
        .toList();
    final width =
        painters.fold<double>(
          0,
          (maxWidth, painter) => math.max(maxWidth, painter.width),
        ) +
        textScaler.scale(20);
    final height =
        painters.fold<double>(0, (sum, painter) => sum + painter.height) +
        textScaler.scale(16);
    final left = math.max(
      2.0,
      math.min(size.width - width - 2, point.dx - width / 2),
    );
    final top = math.max(
      2.0,
      geometry.plotRect.top - height + textScaler.scale(16),
    );
    final rect = Rect.fromLTWH(left, top, width, height);
    canvas.drawRRect(
      tooltipBorderRadius.toRRect(rect),
      Paint()
        ..color = tooltipBackground.withValues(alpha: 0.97)
        ..style = PaintingStyle.fill,
    );
    if (tooltipOutline != null) {
      canvas.drawRRect(
        tooltipBorderRadius.toRRect(rect),
        Paint()
          ..color = tooltipOutline!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    var y = rect.top + textScaler.scale(8);
    for (final painter in painters) {
      painter.paint(
        canvas,
        Offset(
          textDirection == TextDirection.ltr
              ? rect.left + textScaler.scale(10)
              : rect.right - textScaler.scale(10) - painter.width,
          y,
        ),
      );
      y += painter.height;
    }
  }

  @override
  bool shouldRepaint(covariant _WorkoutLineChartPainter oldDelegate) {
    return oldDelegate.buckets != buckets ||
        oldDelegate.metric != metric ||
        oldDelegate.interval != interval ||
        oldDelegate.strings.localeName != strings.localeName ||
        oldDelegate.accent != accent ||
        oldDelegate.grid != grid ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.tooltipBackground != tooltipBackground ||
        oldDelegate.tooltipTextColor != tooltipTextColor ||
        oldDelegate.tooltipOutline != tooltipOutline ||
        oldDelegate.tooltipBorderRadius != tooltipBorderRadius ||
        oldDelegate.seriesOpacity != seriesOpacity ||
        oldDelegate.showValueLabels != showValueLabels ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.selectionPosition != selectionPosition ||
        oldDelegate.seriesValues != seriesValues ||
        oldDelegate.weightUnit != weightUnit ||
        oldDelegate.locale != locale ||
        oldDelegate.textScaler != textScaler ||
        oldDelegate.textDirection != textDirection;
  }

  static double _niceMax(WorkoutReportMetric metric, double value) {
    if (metric == WorkoutReportMetric.workouts) {
      final minimum = math.max(6, value.ceil()).toDouble();
      final step = _niceIntegerStep(minimum / 6);
      return (minimum / step).ceil() * step;
    }
    if (value <= 0) return 1;
    final magnitude = math.pow(
      10,
      math.max(0, value.floor().toString().length - 1),
    );
    final normalized = value / magnitude;
    final nice = normalized <= 2
        ? 2
        : normalized <= 5
        ? 5
        : 10;
    return nice * magnitude.toDouble();
  }

  static double _niceIntegerStep(double roughStep) {
    final magnitude = math.pow(
      10,
      math.max(0, roughStep.floor().toString().length - 1),
    );
    final normalized = roughStep / magnitude;
    final niceStep = normalized <= 1
        ? 1
        : normalized <= 2
        ? 2
        : normalized <= 5
        ? 5
        : 10;
    return niceStep * magnitude.toDouble();
  }

  static String _chartDateLabel(
    WorkoutReportBucket bucket,
    _ReportBucketInterval interval,
    Locale locale,
  ) {
    final label =
        (interval == _ReportBucketInterval.month
                ? LocalizedFormatters.monthShort(bucket.start, locale)
                : LocalizedFormatters.dayMonth(bucket.start, locale))
            .toUpperCase();
    if (interval == _ReportBucketInterval.month) return label;
    return label.replaceAll(' ', '\n');
  }

  static void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const dashWidth = 5.0;
    const dashGap = 6.0;
    var x = start.dx;
    while (x < end.dx) {
      canvas.drawLine(
        Offset(x, start.dy),
        Offset(math.min(x + dashWidth, end.dx), end.dy),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    required double maxWidth,
    TextAlign align = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textAlign: align,
      textScaler: textScaler,
      maxLines: 2,
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, offset);
  }
}
