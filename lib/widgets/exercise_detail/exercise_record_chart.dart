part of '../exercise_detail_sheet.dart';

List<_ExerciseRecordPoint> _buildRecordTrendPoints(
  List<HistoryRecord> history, {
  bool requireTrackableData = false,
}) {
  final ordered = [...history]..sort((a, b) => a.date.compareTo(b.date));
  final points = <_ExerciseRecordPoint>[];
  for (final record in ordered) {
    if (record.sets.isEmpty) continue;
    final point = _ExerciseRecordPoint.from(
      record,
      requireTrackableData: requireTrackableData,
    );
    if (point == null) continue;
    if (!requireTrackableData) {
      if (point.bestWeight <= 0 && point.bestEstimatedOneRm <= 0) continue;
      points.add(point);
      continue;
    }
    final hasBestWeight = point.bestWeight.isFinite && point.bestWeight > 0;
    final hasEstimatedOneRm =
        point.bestEstimatedOneRm.isFinite && point.bestEstimatedOneRm > 0;
    if (!hasBestWeight && !hasEstimatedOneRm) continue;
    points.add(point);
  }
  return points;
}

class _ExerciseRecordPoint {
  final DateTime completedAt;
  final LocalCalendarDay calendarDay;
  final double bestWeight;
  final double bestEstimatedOneRm;
  final ExerciseSet bestSet;

  const _ExerciseRecordPoint({
    required this.completedAt,
    required this.calendarDay,
    required this.bestWeight,
    required this.bestEstimatedOneRm,
    required this.bestSet,
  });

  DateTime get displayDateTime => calendarDay.atLocalTime(completedAt);

  static _ExerciseRecordPoint? from(
    HistoryRecord record, {
    bool requireTrackableData = false,
  }) {
    final sets = requireTrackableData
        ? record.sets
              .where(
                (set) => set.reps > 0 && set.weight.isFinite && set.weight > 0,
              )
              .toList(growable: false)
        : record.sets;
    if (sets.isEmpty) return null;

    var bestSet = sets.first;
    var bestEstimatedOneRm = _estimatedOneRm(bestSet);
    if (requireTrackableData && !bestEstimatedOneRm.isFinite) {
      bestEstimatedOneRm = 0;
    }

    for (final set in sets.skip(1)) {
      var estimatedOneRm = _estimatedOneRm(set);
      if (requireTrackableData && !estimatedOneRm.isFinite) {
        estimatedOneRm = 0;
      }
      if (estimatedOneRm > bestEstimatedOneRm) {
        bestSet = set;
        bestEstimatedOneRm = estimatedOneRm;
      }
    }

    final bestWeight = sets.fold<double>(
      0,
      (best, set) => set.weight > best ? set.weight : best,
    );

    return _ExerciseRecordPoint(
      completedAt: record.date,
      calendarDay: record.calendarDay,
      bestWeight: bestWeight,
      bestEstimatedOneRm: bestEstimatedOneRm,
      bestSet: bestSet,
    );
  }
}

Color _exerciseRecordActualSeriesColor(BuildContext context) {
  final theme = Theme.of(context);
  if (!context.usesNeoPresentation) {
    return theme.colorScheme.primary;
  }
  return tonosPrimarySeriesForSurface(
    context,
    theme.surfaceTokens.exerciseDetailChart,
  );
}

Color _exerciseRecordEstimatedSeriesColor(BuildContext context) {
  return tonosEstimatedOneRmForSurface(
    context,
    Theme.of(context).surfaceTokens.exerciseDetailChart,
  );
}

class _ExerciseRecordTrendChart extends StatelessWidget {
  final List<_ExerciseRecordPoint> points;
  final WeightUnit weightUnit;
  final bool catalogCompact;

  const _ExerciseRecordTrendChart({
    required this.points,
    required this.weightUnit,
    this.catalogCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = theme.surfaceTokens;
    final shapes = theme.shapeTokens;
    final motion = theme.motionTokens;
    final strings = AppLocalizations.of(context);
    final neo = context.usesNeoPresentation;
    final destination = theme.extension<AppExpressiveDestinationTokens>();
    final expressive =
        destination?.family == AppExpressiveDestinationFamily.catalog &&
        theme.appThemeFamilyIdentity ==
            AppThemeFamilyIdentity.expressivePreview;
    final chartForeground = expressive
        ? scheme.onSurfaceVariant
        : neo
        ? tonosForegroundForSurface(context, surfaces.exerciseDetailChart)
        : scheme.onSurfaceVariant;
    final chartEmptyForeground = expressive
        ? scheme.onSurfaceVariant
        : neo
        ? tonosForegroundForSurface(context, surfaces.exerciseDetailChartEmpty)
        : scheme.onSurfaceVariant;
    final tooltipForeground = expressive
        ? scheme.onSurface
        : neo
        ? tonosForegroundForSurface(context, surfaces.exerciseDetailTooltip)
        : scheme.onSurface;

    if (points.isEmpty) {
      return Container(
        height: catalogCompact ? 176 : 188,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: expressive
              ? scheme.surfaceContainerLowest
              : surfaces.exerciseDetailChartEmpty,
          borderRadius: expressive
              ? const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(18),
                )
              : shapes.exerciseDetailChart,
        ),
        child: Text(
          AppLocalizations.of(context).exerciseDetailNoChartData,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: chartEmptyForeground,
          ),
        ),
      );
    }

    final bounds = _recordChartBounds(points);
    final labelIndexes = _recordDateLabelIndexes(points.length);
    final showTimes = _shouldUseTimeLabels(points);
    final actualColor = _exerciseRecordActualSeriesColor(context);
    final estimatedColor = _exerciseRecordEstimatedSeriesColor(context);
    final hasBestWeight = points.any((point) => point.bestWeight > 0);
    final hasEstimatedOneRm = points.any(
      (point) => point.bestEstimatedOneRm > 0,
    );

    return Container(
      height: catalogCompact ? 198 : 214,
      padding: EdgeInsets.fromLTRB(8, catalogCompact ? 11 : 14, 10, 8),
      decoration: BoxDecoration(
        color: expressive
            ? scheme.surfaceContainerLowest
            : surfaces.exerciseDetailChart,
        borderRadius: expressive
            ? const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(18),
              )
            : shapes.exerciseDetailChart,
        border: expressive
            ? null
            : Border.all(
                color: scheme.outlineVariant.withValues(
                  alpha: surfaces.exerciseDetailChartBorderOpacity,
                ),
              ),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(1, points.length - 1).toDouble(),
          minY: bounds.minY,
          maxY: bounds.maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBorderRadius: shapes.exerciseDetailChartTooltip,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              tooltipMargin: 8,
              maxContentWidth: 164,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor: (_) => surfaces.exerciseDetailTooltip,
              getTooltipItems: (touchedSpots) {
                if (touchedSpots.isEmpty) return const <LineTooltipItem?>[];
                final spot = touchedSpots.first;
                final index = spot.x
                    .round()
                    .clamp(0, points.length - 1)
                    .toInt();
                final point = points[index];
                final textStyle =
                    theme.textTheme.labelSmall?.copyWith(
                      color: tooltipForeground,
                      fontSize: 9,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    ) ??
                    TextStyle(
                      color: tooltipForeground,
                      fontSize: 9,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    );
                return [
                  LineTooltipItem(
                    '${LocalizedFormatters.dateTime(point.displayDateTime, Localizations.localeOf(context))}\n'
                    '${strings.exerciseDetailWeightAbbreviation} ${WeightUnitFormatter.formatWeight(point.bestWeight, weightUnit, locale: Localizations.localeOf(context))} | '
                    '${strings.exerciseDetailEstimatedAbbreviation} ${WeightUnitFormatter.formatWeight(point.bestEstimatedOneRm, weightUnit, locale: Localizations.localeOf(context))} | '
                    '${strings.exerciseDetailTopAbbreviation} ${_formatSet(point.bestSet, weightUnit, locale: Localizations.localeOf(context))}',
                    textStyle,
                  ),
                  for (var i = 1; i < touchedSpots.length; i++) null,
                ];
              },
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: bounds.interval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: scheme.outlineVariant.withValues(
                alpha: surfaces.exerciseDetailChartGridOpacity,
              ),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: catalogCompact
                ? const AxisTitles(
                    sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                  )
                : AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: bounds.interval,
                      reservedSize: expressive ? 56 : 38,
                      getTitlesWidget: (value, meta) {
                        final weightLabel = _compactWeight(
                          value,
                          weightUnit,
                          Localizations.localeOf(context),
                        );
                        return SideTitleWidget(
                          meta: meta,
                          space: 2,
                          fitInside: SideTitleFitInsideData.fromTitleMeta(
                            meta,
                            distanceFromEdge: 2,
                          ),
                          child: Text(
                            expressive
                                ? '$weightLabel ${weightUnit.shortLabel}'
                                : weightLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: chartForeground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if ((value - index).abs() > 0.2 ||
                      !labelIndexes.contains(index) ||
                      index < 0 ||
                      index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    fitInside: SideTitleFitInsideData.fromTitleMeta(
                      meta,
                      distanceFromEdge: 4,
                    ),
                    child: Text(
                      _recordAxisLabel(
                        points[index],
                        showTimes,
                        Localizations.localeOf(context),
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: chartForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              show: hasBestWeight,
              spots: [
                for (var i = 0; i < points.length; i++)
                  _recordSpot(i, points[i].bestWeight),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: actualColor,
              barWidth: 2.6,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: actualColor.withValues(
                  alpha: surfaces.exerciseDetailChartAreaOpacity,
                ),
              ),
            ),
            LineChartBarData(
              show: hasEstimatedOneRm,
              spots: [
                for (var i = 0; i < points.length; i++)
                  _recordSpot(i, points[i].bestEstimatedOneRm),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: estimatedColor,
              barWidth: 2.4,
              dashArray: const [6, 4],
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
        duration: appMotionDuration(context, motion.exerciseDetailSelection),
        curve: Curves.easeOut,
      ),
    );
  }
}

class _RecordLegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool oneLine;

  const _RecordLegendDot({
    required this.color,
    required this.label,
    this.oneLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = theme.surfaceTokens;
    final outlined = context.surfaceDecorationTokens.panel.outlined;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: outlined
                ? Border.all(
                    color: tonosForegroundForSurface(context, surfaces.sheet),
                    width: theme.shapeTokens.outlineWidth,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: oneLine ? 1 : null,
            overflow: oneLine ? TextOverflow.ellipsis : null,
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}

class _RecordChartBounds {
  final double minY;
  final double maxY;
  final double interval;

  const _RecordChartBounds({
    required this.minY,
    required this.maxY,
    required this.interval,
  });
}

_RecordChartBounds _recordChartBounds(List<_ExerciseRecordPoint> points) {
  final values = [
    for (final point in points) point.bestWeight,
    for (final point in points) point.bestEstimatedOneRm,
  ].where((value) => value > 0).toList();

  if (values.isEmpty) {
    return const _RecordChartBounds(minY: 0, maxY: 10, interval: 5);
  }

  final minValue = values.reduce((a, b) => a < b ? a : b);
  final maxValue = values.reduce((a, b) => a > b ? a : b);
  final range = math.max(1.0, maxValue - minValue);
  final padding = math.max(2.5, range * 0.05);
  final rawMinY = math.max(0.0, minValue - padding);
  final rawMaxY = maxValue + padding;
  final interval = _niceRecordInterval((rawMaxY - rawMinY) / 3);
  final minY = math.max(0.0, (rawMinY / interval).floor() * interval);
  final maxY = math.max(
    minY + interval,
    (rawMaxY / interval).ceil() * interval,
  );

  return _RecordChartBounds(minY: minY, maxY: maxY, interval: interval);
}

FlSpot _recordSpot(int index, double value) {
  if (value <= 0) return FlSpot.nullSpot;
  return FlSpot(index.toDouble(), value);
}

double _niceRecordInterval(double target) {
  if (target <= 0) return 1;
  final exponent = (math.log(target) / math.ln10).floor();
  final magnitude = math.pow(10, exponent).toDouble();
  for (final multiplier in const [1, 2, 2.5, 5, 10]) {
    final interval = magnitude * multiplier;
    if (interval >= target) return interval.toDouble();
  }
  return magnitude * 10;
}

Set<int> _recordDateLabelIndexes(int length) {
  if (length <= 4) {
    return {for (var i = 0; i < length; i++) i};
  }
  return {0, length ~/ 2, length - 1};
}

bool _shouldUseTimeLabels(List<_ExerciseRecordPoint> points) {
  final days = {for (final point in points) point.calendarDay.storageKey};
  return days.length == 1;
}

String _recordAxisLabel(
  _ExerciseRecordPoint point,
  bool showTime,
  Locale locale,
) {
  return showTime
      ? LocalizedFormatters.time(point.completedAt, locale)
      : LocalizedFormatters.shortDate(
          point.calendarDay.toLocalDateTime(),
          locale,
        );
}
