part of '../workout_metric_chart_card.dart';

class _ExpressiveWorkoutReportComposition extends StatelessWidget {
  const _ExpressiveWorkoutReportComposition({
    required this.title,
    required this.stats,
    required this.selectedMetricIndex,
    required this.chartViewport,
    required this.rangeSelector,
    required this.additionalDetails,
  });

  final String title;
  final List<Widget> stats;
  final int selectedMetricIndex;
  final Widget chartViewport;
  final Widget rangeSelector;
  final Widget additionalDetails;

  @override
  Widget build(BuildContext context) {
    final expressive = Theme.of(context).extension<AppExpressiveTrainTokens>()!;
    final destination = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    final isProgressDestination = _usesProgressExpressiveReport(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Padding(
      key: const ValueKey('workout-report-expressive-composition'),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            key: const ValueKey('workout-report-expressive-title'),
            textAlign: TextAlign.start,
            maxLines: 2,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isProgressDestination
                  ? destination!.onSurfacePrimary
                  : expressive.actionPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          if (isProgressDestination)
            Align(
              key: const ValueKey('workout-report-expressive-title-rule'),
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: destination!.outlineAccent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            )
          else
            Stack(
              key: const ValueKey('workout-report-expressive-title-rule'),
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: expressive.selectorTrack,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    width: 48,
                    height: 3,
                    decoration: BoxDecoration(
                      color: expressive.selectorActive,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),
          Container(
            key: const ValueKey('workout-report-expressive-metric-cluster'),
            padding: EdgeInsets.all(isProgressDestination ? 0 : 5),
            decoration: BoxDecoration(
              color: isProgressDestination
                  ? Colors.transparent
                  : expressive.selectorTrack,
              borderRadius: context.shapeTokens.workoutMetricRange,
            ),
            child: LayoutBuilder(
              builder: (context, _) {
                if (textScale <= 1.15) {
                  return Row(
                    children: [
                      for (var index = 0; index < stats.length; index++)
                        Expanded(
                          flex: index == selectedMetricIndex ? 6 : 5,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isProgressDestination ? 3 : 0,
                            ),
                            child: stats[index],
                          ),
                        ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final stat in stats)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: stat,
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          chartViewport,
          const SizedBox(height: 12),
          rangeSelector,
          const SizedBox(height: 10),
          additionalDetails,
        ],
      ),
    );
  }
}

class _ReportStat extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final _MetricTrend trend;
  final bool selected;
  final VoidCallback onTap;

  const _ReportStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.trend,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final progressColors = context.progressColors;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressiveRecipe = context.usesExpressivePresentation;
    final expressiveTokens = usesExpressiveRecipe
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()
        : null;
    final destinationTokens = usesExpressiveRecipe
        ? Theme.of(context).extension<AppExpressiveDestinationTokens>()
        : null;
    final isProgressDestination = _usesProgressExpressiveReport(context);
    final unselectedFill = usesInkRecipe
        ? surfaces.workoutMetricRange
        : usesExpressiveRecipe
        ? isProgressDestination
              ? Color.lerp(
                  surfaces.workoutMetricStat,
                  destinationTokens!.surfaceSelected,
                  0.12,
                )!
              : Colors.transparent
        : surfaces.workoutMetricStat;
    final selectedFill = usesInkRecipe
        ? surfaces.exerciseProgressSelector
        : usesExpressiveRecipe
        ? isProgressDestination
              ? destinationTokens!.surfaceSelected
              : Color.lerp(expressiveTokens!.focusSurface, Colors.black, 0.36)!
        : progressColors.accent.withValues(alpha: 0.14);
    final unselectedForeground = usesInkRecipe
        ? tonosForegroundForSurface(context, unselectedFill)
        : usesExpressiveRecipe
        ? isProgressDestination
              ? destinationTokens!.supportingForeground
              : Theme.of(context).brightness == Brightness.light
              ? expressiveTokens!.focusSurface
              : expressiveTokens!.focusForeground
        : cs.onSurface;
    final selectedForeground = usesInkRecipe
        ? tonosForegroundForSurface(
            context,
            selectedFill,
            parentSurface: unselectedFill,
          )
        : usesExpressiveRecipe
        ? isProgressDestination
              ? destinationTokens!.onSurfaceSelected
              : expressiveTokens!.focusForeground
        : progressColors.accent;
    final selectedExpressiveForeground = isProgressDestination
        ? destinationTokens!.onSurfaceSelected
        : selectedForeground;
    final unitForeground = usesInkRecipe
        ? (selected ? selectedForeground : unselectedForeground).withValues(
            alpha: 0.78,
          )
        : usesExpressiveRecipe
        ? isProgressDestination
              ? selectedExpressiveForeground
              : (selected ? selectedForeground : unselectedForeground)
                    .withValues(alpha: 0.78)
        : cs.onSurfaceVariant;
    final unselectedBorder = usesInkRecipe
        ? tonosOutlineForSurface(context, unselectedFill)
        : usesExpressiveRecipe
        ? Colors.transparent
        : cs.outlineVariant.withValues(alpha: 0.7);
    final selectedBorder = usesInkRecipe
        ? tonosOutlineForSurface(context, selectedFill)
        : usesExpressiveRecipe
        ? Colors.transparent
        : progressColors.accent.withValues(alpha: 0.75);
    final strings = AppLocalizations.of(context);
    final trendSurface = usesExpressiveRecipe
        ? selected
              ? selectedFill
              : unselectedFill
        : selected
        ? selectedFill
        : unselectedFill;
    final trendColor =
        usesExpressiveRecipe &&
            selected &&
            trend.direction == _MetricTrendDirection.flat
        ? isProgressDestination
              ? destinationTokens!.onSurfaceSelected
              : expressiveTokens!.focusForeground
        : _trendColor(context, trendSurface);
    final compactLayout = MediaQuery.textScalerOf(context).scale(1) <= 1.15;
    return Semantics(
      button: true,
      selected: selected,
      label: strings.workoutReportMetricSemantics(label),
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? selectedFill : unselectedFill,
            borderRadius: shapes.workoutMetricStat,
            border: usesExpressiveRecipe
                ? selected
                      ? BorderDirectional(
                          start: BorderSide(
                            color: isProgressDestination
                                ? destinationTokens!.outlineAccent
                                : expressiveTokens!.selectorActive,
                            width: 4,
                          ),
                        )
                      : null
                : Border.all(
                    color: selected ? selectedBorder : unselectedBorder,
                    width: 1,
                  ),
          ),
          child: InkWell(
            borderRadius: shapes.workoutMetricStat,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: compactLayout
                  ? _classicContent(
                      context,
                      selected
                          ? selectedExpressiveForeground
                          : unselectedForeground,
                      unitForeground,
                      trendColor,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: selected
                                    ? selectedExpressiveForeground
                                    : unselectedForeground,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.end,
                          spacing: 4,
                          children: [
                            Text(
                              value,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: selected
                                        ? selectedExpressiveForeground
                                        : unselectedForeground,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            if (unit != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text(
                                  unit!,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color:
                                            usesInkRecipe ||
                                                usesExpressiveRecipe
                                            ? unitForeground
                                            : cs.onSurfaceVariant,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          trend.label,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: trendColor,
                                height: 1.05,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _classicContent(
    BuildContext context,
    Color foreground,
    Color unitColor,
    Color trendColor,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.bodyMedium!.copyWith(
      color: foreground,
      fontWeight: FontWeight.w700,
    );
    final valueStyle = textTheme.headlineSmall!.copyWith(
      color: foreground,
      fontWeight: FontWeight.w900,
    );
    final trendStyle = textTheme.labelSmall!.copyWith(
      color: trendColor,
      height: 1.05,
      fontWeight: FontWeight.w800,
    );

    // Equal line slots preserve Classic tile geometry while long values shrink.
    Widget fittedLine(TextStyle style, String measurementText, Widget child) {
      final painter = TextPainter(
        text: TextSpan(text: measurementText, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        locale: Localizations.localeOf(context),
      )..layout();
      final height = painter.height;
      painter.dispose();
      return SizedBox(
        width: double.infinity,
        height: height,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: child,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fittedLine(
          labelStyle,
          label,
          Text(label, maxLines: 1, style: labelStyle),
        ),
        const SizedBox(height: 4),
        fittedLine(
          valueStyle,
          value,
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, maxLines: 1, style: valueStyle),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit!,
                    maxLines: 1,
                    style: textTheme.labelSmall?.copyWith(color: unitColor),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 5),
        fittedLine(
          trendStyle,
          trend.label,
          Text(trend.label, maxLines: 1, style: trendStyle),
        ),
      ],
    );
  }

  Color _trendColor(BuildContext context, Color surface) {
    switch (trend.direction) {
      case _MetricTrendDirection.up:
        return tonosWorkoutIncreaseForSurface(context, surface);
      case _MetricTrendDirection.down:
        return tonosWorkoutDecreaseForSurface(context, surface);
      case _MetricTrendDirection.flat:
        return tonosWorkoutNeutralForSurface(context, surface);
    }
  }
}

class _MetricChartPage extends StatelessWidget {
  final List<WorkoutReportBucket> buckets;
  final WorkoutReportMetric metric;
  final _ReportBucketInterval interval;
  final WorkoutReportRange range;
  final bool rangeDataReady;
  final WeightUnit weightUnit;

  const _MetricChartPage({
    required this.buckets,
    required this.metric,
    required this.interval,
    required this.range,
    required this.rangeDataReady,
    required this.weightUnit,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final chartSurface = _workoutReportChartSurface(context);
    final shapes = context.shapeTokens;
    final hasValue = buckets.any((bucket) => bucket.valueFor(metric) > 0);
    return Container(
      key: _usesProgressExpressiveReport(context)
          ? const ValueKey('workout-report-expressive-chart-surface')
          : null,
      decoration: BoxDecoration(
        color: chartSurface,
        borderRadius: shapes.workoutMetricChart,
      ),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _chartTitle(metric, range, strings),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: hasValue
                ? _InteractiveWorkoutLineChart(
                    buckets: buckets,
                    metric: metric,
                    interval: interval,
                    range: range,
                    rangeDataReady: rangeDataReady,
                    showValueLabels: buckets.length <= 6,
                    weightUnit: weightUnit,
                  )
                : Semantics(
                    key: const ValueKey('workout-report-chart-semantics'),
                    container: true,
                    label: _chartSemanticsLabel(
                      metric: metric,
                      range: range,
                      strings: strings,
                    ),
                    value: _emptyChartSemanticsValue(
                      metric: metric,
                      strings: strings,
                    ),
                    child: ExcludeSemantics(
                      child: _EmptyMetricChartMessage(metric: metric),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
