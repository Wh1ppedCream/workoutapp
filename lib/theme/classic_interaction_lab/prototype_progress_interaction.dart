import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/theme_extensions.dart';
import '../../widgets/workout_metric_chart_card.dart';

/// Local-only comparison for the six Workout Report ranges and chart points.
///
/// The controls share one selection and the chart swaps between fixed fixture
/// datasets. This prototype never reads workout repositories or persists data.
class ProgressInteractionPrototype extends StatefulWidget {
  const ProgressInteractionPrototype({super.key});

  @override
  State<ProgressInteractionPrototype> createState() =>
      _ProgressInteractionPrototypeState();
}

class _ProgressInteractionPrototypeState
    extends State<ProgressInteractionPrototype> {
  WorkoutReportRange _selectedRange = WorkoutReportRange.all;
  int? _selectedPoint;
  final FocusNode _chartFocusNode = FocusNode(debugLabel: 'progress-chart');

  @override
  void dispose() {
    _chartFocusNode.dispose();
    super.dispose();
  }

  void _selectRange(WorkoutReportRange range) {
    if (_selectedRange == range) return;
    setState(() {
      _selectedRange = range;
      // Changing the date question selects a separate fixture; there is no
      // animated interpolation between these unrelated sample datasets.
      _selectedPoint = null;
    });
  }

  void _selectPoint(int index) {
    setState(() => _selectedPoint = index.clamp(0, 6).toInt());
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final points = _samplePointsFor(_selectedRange);
    final point = _selectedPoint == null ? null : points[_selectedPoint!];
    final pointValue = point == null
        ? 'No point selected. Use a chart point, arrow key, or increase and decrease actions.'
        : _pointTooltip(context, point);
    final referencePointIndex = _selectedPoint ?? 0;
    final increasedPointIndex = (referencePointIndex + 1).clamp(
      0,
      points.length - 1,
    );
    final decreasedPointIndex = (referencePointIndex - 1).clamp(
      0,
      points.length - 1,
    );
    final rangeLabel = _longRangeLabel(_selectedRange, strings);

    return Card(
      key: const ValueKey('progress-interaction-prototype'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Progress · ranges and chart points',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Six current ranges · fixed local sample data · no workout records read or saved.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _VariantHeading(
              title: 'Current Tonos compact selector',
              note: 'Same six choices and selected meaning.',
            ),
            const SizedBox(height: 6),
            _CurrentRangeSelector(
              key: const ValueKey('progress-tonos-range-selector'),
              selectedRange: _selectedRange,
              onSelectRange: _selectRange,
            ),
            const SizedBox(height: 12),
            _VariantHeading(
              title: 'Standard Material',
              note: 'SegmentedButton with the same six choices.',
            ),
            const SizedBox(height: 6),
            _MaterialRangeSelector(
              key: const ValueKey('progress-material-range-selector'),
              selectedRange: _selectedRange,
              onSelectRange: _selectRange,
            ),
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              label: 'Selected range',
              value: rangeLabel,
              child: Text(
                'Selected range: $rangeLabel',
                key: const ValueKey('progress-selected-range'),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            _SampleWorkoutChart(
              range: _selectedRange,
              points: points,
              selectedPointIndex: _selectedPoint,
              focusNode: _chartFocusNode,
              onSelectPoint: _selectPoint,
              semanticValue: point == null ? '' : pointValue,
              increasedValue: point == null
                  ? null
                  : _pointTooltip(context, points[increasedPointIndex]),
              decreasedValue: point == null
                  ? null
                  : _pointTooltip(context, points[decreasedPointIndex]),
            ),
            const SizedBox(height: 6),
            Semantics(
              liveRegion: true,
              label: 'Selected sample workout bucket',
              value: pointValue,
              child: Text(
                point == null
                    ? 'Tap a chart point or focus the chart and use the arrow keys.'
                    : pointValue,
                key: const ValueKey('progress-selected-point-value'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Chart stroke and grid use Tonos data-visualization tokens.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantHeading extends StatelessWidget {
  const _VariantHeading({required this.title, required this.note});

  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          note,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CurrentRangeSelector extends StatelessWidget {
  const _CurrentRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onSelectRange,
  });

  final WorkoutReportRange selectedRange;
  final ValueChanged<WorkoutReportRange> onSelectRange;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Container(
      key: const ValueKey('progress-tonos-range'),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaces.workoutMetricRange,
        borderRadius: shapes.workoutMetricRange,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final compactLayout = textScale <= 1.15;
          final columns = compactLayout
              ? WorkoutReportRange.values.length
              : constraints.maxWidth < 360 || textScale > 1.15
              ? 3
              : WorkoutReportRange.values.length;
          const gap = 4.0;
          final itemWidth =
              (constraints.maxWidth - (columns - 1) * gap) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final range in WorkoutReportRange.values)
                SizedBox(
                  width: itemWidth,
                  child: _CurrentRangeOption(
                    key: ValueKey('progress-tonos-range-${range.name}'),
                    label: _shortRangeLabel(range, strings),
                    selected: selectedRange == range,
                    selectedFill: primary,
                    selectedForeground: onPrimary,
                    borderRadius: shapes.workoutMetricRangeOption,
                    compactLayout: compactLayout,
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 160),
                    onTap: () => onSelectRange(range),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CurrentRangeOption extends StatelessWidget {
  const _CurrentRangeOption({
    super.key,
    required this.label,
    required this.selected,
    required this.selectedFill,
    required this.selectedForeground,
    required this.borderRadius,
    required this.compactLayout,
    required this.duration,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedFill;
  final Color selectedForeground;
  final BorderRadiusGeometry borderRadius;
  final bool compactLayout;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? selectedForeground
        : theme.colorScheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: compactLayout
            ? InkWell(
                borderRadius: borderRadius.resolve(Directionality.of(context)),
                onTap: onTap,
                child: AnimatedContainer(
                  duration: duration,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? selectedFill : Colors.transparent,
                    borderRadius: borderRadius,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              )
            : Tooltip(
                message: label,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: selected ? selectedFill : Colors.transparent,
                      borderRadius: borderRadius,
                    ),
                    child: InkWell(
                      borderRadius: borderRadius.resolve(
                        Directionality.of(context),
                      ),
                      onTap: onTap,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          child: Text(
                            label,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _MaterialRangeSelector extends StatelessWidget {
  const _MaterialRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onSelectRange,
  });

  final WorkoutReportRange selectedRange;
  final ValueChanged<WorkoutReportRange> onSelectRange;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final selected = <WorkoutReportRange>{selectedRange};
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        if (constraints.maxWidth < 340 || textScale > 1.15) {
          final surfaces = context.surfaceTokens;
          final shapes = context.shapeTokens;
          const gap = 4.0;
          final columns = 3;
          final itemWidth =
              (constraints.maxWidth - (columns - 1) * gap - 8) / columns;
          return Container(
            key: const ValueKey('progress-standard-material-range'),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: surfaces.workoutMetricRange,
              borderRadius: shapes.workoutMetricRange,
            ),
            child: Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final range in WorkoutReportRange.values)
                  SizedBox(
                    width: itemWidth,
                    child: ChoiceChip(
                      label: Center(
                        child: Text(_shortRangeLabel(range, strings)),
                      ),
                      tooltip: _longRangeLabel(range, strings),
                      selected: range == selectedRange,
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      labelPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: shapes.workoutMetricRangeOption,
                      ),
                      onSelected: (_) => onSelectRange(range),
                    ),
                  ),
              ],
            ),
          );
        }

        return SizedBox(
          key: const ValueKey('progress-standard-material-range'),
          child: SegmentedButton<WorkoutReportRange>(
            showSelectedIcon: false,
            segments: [
              for (final range in WorkoutReportRange.values)
                ButtonSegment<WorkoutReportRange>(
                  value: range,
                  label: Text(_shortRangeLabel(range, strings)),
                  tooltip: _longRangeLabel(range, strings),
                ),
            ],
            selected: selected,
            onSelectionChanged: (next) {
              if (next.isNotEmpty) onSelectRange(next.first);
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 2),
              ),
              textStyle: WidgetStatePropertyAll(
                Theme.of(context).textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SampleWorkoutChart extends StatelessWidget {
  const _SampleWorkoutChart({
    required this.range,
    required this.points,
    required this.selectedPointIndex,
    required this.focusNode,
    required this.onSelectPoint,
    required this.semanticValue,
    required this.increasedValue,
    required this.decreasedValue,
  });

  final WorkoutReportRange range;
  final List<_SamplePoint> points;
  final int? selectedPointIndex;
  final FocusNode focusNode;
  final ValueChanged<int> onSelectPoint;
  final String semanticValue;
  final String? increasedValue;
  final String? decreasedValue;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final dataColors = context.dataVisualizationTokens;
    final gridColor = dataColors.grid;
    final labelColor = dataColors.label;
    final seriesColor = dataColors.primarySeries;
    final selectionColor = dataColors.selection;

    void moveSelection(int delta) {
      final current = selectedPointIndex ?? (delta > 0 ? -1 : points.length);
      onSelectPoint((current + delta).clamp(0, points.length - 1));
    }

    return Column(
      children: [
        Semantics(
          key: const ValueKey('progress-chart-semantics'),
          container: true,
          focusable: true,
          label: 'Workout trend chart',
          value: semanticValue,
          increasedValue: increasedValue,
          decreasedValue: decreasedValue,
          hint: 'Focus and use the left and right arrow keys, or increase and decrease actions, to inspect sample buckets.',
          onTap: () => onSelectPoint(selectedPointIndex ?? 0),
          onIncrease: selectedPointIndex == null
              ? null
              : () => moveSelection(1),
          onDecrease: selectedPointIndex == null
              ? null
              : () => moveSelection(-1),
          child: Focus(
            focusNode: focusNode,
            canRequestFocus: true,
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return KeyEventResult.ignored;
              if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                  event.logicalKey == LogicalKeyboardKey.arrowDown) {
                moveSelection(1);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                  event.logicalKey == LogicalKeyboardKey.arrowUp) {
                moveSelection(-1);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Container(
              key: const ValueKey('progress-chart-canvas'),
              height: 150,
              decoration: BoxDecoration(
                color: surfaces.workoutMetricChart,
                borderRadius: context.shapeTokens.workoutMetricChart,
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      focusNode.requestFocus();
                      final geometry = _SampleChartGeometry(
                        size: size,
                        points: points,
                      );
                      onSelectPoint(
                        geometry.nearestIndex(details.localPosition.dx),
                      );
                    },
                    child: CustomPaint(
                      size: size,
                      painter: _SampleWorkoutChartPainter(
                        points: points,
                        selectedPointIndex: selectedPointIndex,
                        gridColor: gridColor,
                        labelColor: labelColor,
                        seriesColor: seriesColor,
                        selectionColor: selectionColor,
                        textDirection: Directionality.of(context),
                        materialLocalizations: MaterialLocalizations.of(
                          context,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 2,
          children: [
            Text(
              _longRangeLabel(range, strings),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${points.length} sample buckets',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SampleChartGeometry {
  const _SampleChartGeometry({required this.size, required this.points});

  final Size size;
  final List<_SamplePoint> points;

  Rect get plotRect => Rect.fromLTRB(
    16,
    14,
    math.max(17, size.width - 12),
    math.max(15, size.height - 24),
  );

  int nearestIndex(double dx) {
    if (points.length <= 1) return 0;
    final normalized = ((dx - plotRect.left) / plotRect.width).clamp(0.0, 1.0);
    return (normalized * (points.length - 1)).round();
  }

  Offset pointFor(int index, double maxValue) {
    final value = points[index].count / maxValue;
    return Offset(
      plotRect.left + plotRect.width * index / (points.length - 1),
      plotRect.bottom - plotRect.height * value,
    );
  }
}

class _SampleWorkoutChartPainter extends CustomPainter {
  const _SampleWorkoutChartPainter({
    required this.points,
    required this.selectedPointIndex,
    required this.gridColor,
    required this.labelColor,
    required this.seriesColor,
    required this.selectionColor,
    required this.textDirection,
    required this.materialLocalizations,
  });

  final List<_SamplePoint> points;
  final int? selectedPointIndex;
  final Color gridColor;
  final Color labelColor;
  final Color seriesColor;
  final Color selectionColor;
  final TextDirection textDirection;
  final MaterialLocalizations materialLocalizations;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final maxValue = points
        .map((point) => point.count)
        .reduce(math.max)
        .toDouble();
    final geometry = _SampleChartGeometry(size: size, points: points);
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final fraction in [0.0, 0.5, 1.0]) {
      final y = geometry.plotRect.top + geometry.plotRect.height * fraction;
      canvas.drawLine(
        Offset(geometry.plotRect.left, y),
        Offset(geometry.plotRect.right, y),
        gridPaint,
      );
    }

    final line = Path();
    for (var index = 0; index < points.length; index++) {
      final point = geometry.pointFor(index, maxValue);
      if (index == 0) {
        line.moveTo(point.dx, point.dy);
      } else {
        line.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = seriesColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var index = 0; index < points.length; index++) {
      final point = geometry.pointFor(index, maxValue);
      canvas.drawCircle(
        point,
        index == selectedPointIndex ? 6 : 3.5,
        Paint()
          ..color = index == selectedPointIndex ? selectionColor : seriesColor,
      );
    }

    _paintEndpointLabel(
      canvas,
      points.first.date,
      geometry.plotRect.left,
      size,
    );
    _paintEndpointLabel(
      canvas,
      points.last.date,
      geometry.plotRect.right,
      size,
    );
  }

  void _paintEndpointLabel(Canvas canvas, DateTime date, double x, Size size) {
    final painter = TextPainter(
      text: TextSpan(
        text: materialLocalizations.formatCompactDate(date),
        style: TextStyle(color: labelColor, fontSize: 9),
      ),
      textDirection: textDirection,
      maxLines: 1,
    )..layout(maxWidth: 76);
    final position = x < size.width / 2
        ? Offset(x, size.height - painter.height - 2)
        : Offset(x - painter.width, size.height - painter.height - 2);
    painter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant _SampleWorkoutChartPainter oldDelegate) =>
      !identical(points, oldDelegate.points) ||
      selectedPointIndex != oldDelegate.selectedPointIndex ||
      gridColor != oldDelegate.gridColor ||
      labelColor != oldDelegate.labelColor ||
      seriesColor != oldDelegate.seriesColor ||
      selectionColor != oldDelegate.selectionColor ||
      textDirection != oldDelegate.textDirection;
}

class _SamplePoint {
  const _SamplePoint({required this.date, required this.count});

  final DateTime date;
  final int count;
}

List<_SamplePoint> _samplePointsFor(WorkoutReportRange range) {
  const countsByRange = <WorkoutReportRange, List<int>>{
    WorkoutReportRange.oneWeek: [1, 0, 2, 1, 3, 2, 4],
    WorkoutReportRange.oneMonth: [2, 1, 4, 3, 5, 2, 6],
    WorkoutReportRange.threeMonths: [4, 5, 3, 7, 4, 8, 6],
    WorkoutReportRange.sixMonths: [6, 5, 8, 7, 10, 9, 12],
    WorkoutReportRange.oneYear: [12, 10, 15, 13, 18, 16, 20],
    WorkoutReportRange.all: [8, 11, 9, 14, 12, 17, 15],
  };
  const dayOffsetsByRange = <WorkoutReportRange, List<int>>{
    WorkoutReportRange.oneWeek: [-6, -5, -4, -3, -2, -1, 0],
    WorkoutReportRange.oneMonth: [-27, -22, -18, -13, -9, -4, 0],
    WorkoutReportRange.threeMonths: [-84, -70, -56, -42, -28, -14, 0],
    WorkoutReportRange.sixMonths: [-168, -140, -112, -84, -56, -28, 0],
    WorkoutReportRange.oneYear: [-336, -280, -224, -168, -112, -56, 0],
    WorkoutReportRange.all: [-500, -400, -300, -200, -100, -50, 0],
  };
  final today = DateTime(2026, 9, 28);
  return [
    for (var index = 0; index < 7; index++)
      _SamplePoint(
        date: today.add(Duration(days: dayOffsetsByRange[range]![index])),
        count: countsByRange[range]![index],
      ),
  ];
}

String _shortRangeLabel(WorkoutReportRange range, AppLocalizations strings) =>
    switch (range) {
      WorkoutReportRange.oneWeek => strings.workoutReportRangeOneWeekShort,
      WorkoutReportRange.oneMonth => strings.workoutReportRangeOneMonthShort,
      WorkoutReportRange.threeMonths =>
        strings.workoutReportRangeThreeMonthsShort,
      WorkoutReportRange.sixMonths => strings.workoutReportRangeSixMonthsShort,
      WorkoutReportRange.oneYear => strings.workoutReportRangeOneYearShort,
      WorkoutReportRange.all => strings.workoutReportRangeAll,
    };

String _longRangeLabel(WorkoutReportRange range, AppLocalizations strings) =>
    switch (range) {
      WorkoutReportRange.oneWeek => strings.workoutReportRangeOneWeek,
      WorkoutReportRange.oneMonth => strings.workoutReportRangeOneMonth,
      WorkoutReportRange.threeMonths => strings.workoutReportRangeThreeMonths,
      WorkoutReportRange.sixMonths => strings.workoutReportRangeSixMonths,
      WorkoutReportRange.oneYear => strings.workoutReportRangeOneYear,
      WorkoutReportRange.all => strings.workoutReportRangeAll,
    };

String _pointTooltip(BuildContext context, _SamplePoint point) {
  final date = MaterialLocalizations.of(context).formatShortDate(point.date);
  final count = AppLocalizations.of(context)
      .workoutReportWorkoutCount(point.count);
  return '$date · $count';
}
