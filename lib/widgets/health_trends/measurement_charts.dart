part of '../health_trends_section.dart';

class _MeasurementSparkline extends StatelessWidget {
  final MeasurementDefinition definition;
  final List<Measurement> entries;
  final Color lineColor;
  final Color? emptyColor;
  final bool useExpressiveEmptyState;
  final bool hideEmptyPrompt;

  const _MeasurementSparkline({
    required this.definition,
    required this.entries,
    required this.lineColor,
    this.emptyColor,
    this.useExpressiveEmptyState = false,
    this.hideEmptyPrompt = false,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final entries = MeasurementComparison.chartEntries(
      definition.type,
      this.entries,
    );
    if (entries.length < 2) {
      return Semantics(
        key: ValueKey('measurement-sparkline-${definition.id}-semantics'),
        container: true,
        label: _measurementTrendSemanticsLabel(
          definition,
          entries,
          strings,
          locale,
        ),
        child: ExcludeSemantics(
          child: Center(
            child: hideEmptyPrompt && entries.isEmpty
                ? Icon(
                    Icons.show_chart,
                    size: 19,
                    color:
                        emptyColor ??
                        Theme.of(context).iconTheme.color
                            ?.withValues(alpha: 0.55),
                  )
                : useExpressiveEmptyState
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final prompt = entries.isEmpty
                          ? strings.healthTrendNeedEntries
                          : strings.healthTrendNeedOneMore;
                      final promptStyle = Theme.of(context).textTheme.bodySmall
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          );
                      final promptPainter = TextPainter(
                        text: TextSpan(text: prompt, style: promptStyle),
                        textAlign: TextAlign.center,
                        textDirection: Directionality.of(context),
                        textScaler: MediaQuery.textScalerOf(context),
                        maxLines: 2,
                        ellipsis: '\u2026',
                      )..layout(maxWidth: constraints.maxWidth);
                      final icon = Icon(
                        Icons.show_chart,
                        size: 19,
                        color:
                            emptyColor ??
                            Theme.of(context).iconTheme.color
                                ?.withValues(alpha: 0.55),
                      );
                      if (constraints.maxHeight < promptPainter.height + 23) {
                        return icon;
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          icon,
                          const SizedBox(height: 4),
                          Text(
                            prompt,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: promptStyle,
                          ),
                        ],
                      );
                    },
                  )
                : Icon(
                    Icons.show_chart,
                    color:
                        emptyColor ??
                        Theme.of(context).iconTheme.color
                            ?.withValues(alpha: 0.25),
                  ),
          ),
        ),
      );
    }

    final spots = _spotsFor(definition, entries);
    final bounds = _chartBounds(spots.map((spot) => spot.y).toList());
    return Semantics(
      key: ValueKey('measurement-sparkline-${definition.id}-semantics'),
      container: true,
      label: _measurementTrendSemanticsLabel(
        definition,
        entries,
        strings,
        locale,
      ),
      child: ExcludeSemantics(
        child: LineChart(
          LineChartData(
            minX: spots.first.x,
            maxX: spots.last.x,
            minY: bounds.minY,
            maxY: bounds.maxY,
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 2,
                color: lineColor,
                dotData: FlDotData(show: entries.length <= 4),
                belowBarData: BarAreaData(
                  show: true,
                  color: lineColor.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
          duration: context.usesExpressivePresentation
              ? TonosExpressiveStateMotion.duration(
                  context,
                  TonosExpressiveStateMotion.data,
                )
              : appMotionDuration(context, const Duration(milliseconds: 150)),
          curve: context.usesExpressivePresentation
              ? TonosExpressiveStateMotion.effects
              : Curves.linear,
        ),
      ),
    );
  }
}

class _MeasurementSummaryCard extends StatelessWidget {
  final MeasurementDefinition definition;
  final List<Measurement> entries;

  const _MeasurementSummaryCard({
    required this.definition,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final shapes = context.shapeTokens;
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final latest = entries.isEmpty ? null : entries.last;
    final previous = entries.length < 2 ? null : entries[entries.length - 2];
    final delta = _measurementDelta(definition, latest, previous);
    final incompatibleUnits =
        latest != null && previous != null && delta == null;
    final surface = _measurementDetailSurface(
      context,
      role: _MeasurementDetailRole.focal,
    );
    final records = _SummaryStat(
      valueKey: const ValueKey('measurement-trend-summary-records'),
      label: strings.healthRecords,
      value: LocalizedFormatters.number(
        entries.length,
        locale,
        maximumFractionDigits: 0,
      ),
      detail: latest != null
          ? latest.unit
          : _defaultUnitFor(definition, weightUnit),
    );
    final summaryStats = [
      _SummaryStat(
        valueKey: const ValueKey('measurement-trend-summary-latest'),
        label: strings.healthLatest,
        value: latest == null
            ? strings.healthNoEntry
            : _formatMeasurement(latest, locale),
        detail: latest == null
            ? strings.healthNotTrackedYet
            : LocalizedFormatters.date(
                latest.calendarDay.toLocalDateTime(),
                locale,
              ),
      ),
      _SummaryStat(
        valueKey: const ValueKey('measurement-trend-summary-change'),
        label: strings.healthChange,
        value: incompatibleUnits
            ? strings.healthUnitsNotComparable
            : delta == null
            ? strings.healthNoChange
            : _formatDelta(delta, strings, locale, unit: latest?.unit),
        detail: entries.length < 2
            ? strings.healthNeedTwoEntries
            : strings.healthVersusPrevious,
        valueColor: _deltaColor(context, delta),
      ),
      records,
    ];

    final legacySummary = _withHealthCardForeground(
      context,
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _healthTrendCardSurface(context),
          borderRadius: shapes.healthTrendCard,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final useStackedLayout =
                constraints.maxWidth < 420 || textScale > 1.15;
            if (useStackedLayout) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < summaryStats.length; index++) ...[
                    if (index > 0) const SizedBox(height: 12),
                    summaryStats[index],
                  ],
                ],
              );
            }
            return Row(
              children: [
                for (var index = 0; index < summaryStats.length; index++) ...[
                  if (index > 0) const SizedBox(width: 10),
                  Expanded(child: summaryStats[index]),
                ],
              ],
            );
          },
        ),
      ),
    );

    final expressiveForeground = _measurementDetailForeground(
      context,
      role: _MeasurementDetailRole.focal,
    );
    final expressiveSupportingForeground =
        _measurementDetailSupportingForeground(
          context,
          role: _MeasurementDetailRole.focal,
        );
    final expressiveRecords = _SummaryStat(
      valueKey: const ValueKey('measurement-trend-summary-records'),
      label: strings.healthRecords,
      value: strings.healthRecordCount(entries.length),
      detail: null,
      foreground: expressiveForeground,
      supportingForeground: expressiveSupportingForeground,
      wrapValues: true,
      compact: true,
    );
    final expressiveChange = _SummaryStat(
      valueKey: const ValueKey('measurement-trend-summary-change'),
      label: strings.healthChange,
      value: incompatibleUnits
          ? strings.healthUnitsNotComparable
          : delta == null
          ? (entries.isEmpty ? '—' : strings.healthNoChange)
          : definition.type == MeasurementType.BodyWeight
          ? _formatSignedMeasurementDelta(delta, latest!.unit, locale)
          : _formatDelta(delta, strings, locale, unit: latest?.unit),
      detail: entries.length < 2
          ? strings.healthNeedTwoEntries
          : strings.healthVersusPrevious,
      valueColor: delta == null || definition.type == MeasurementType.BodyWeight
          ? expressiveForeground
          : _deltaColor(context, delta),
      foreground: expressiveForeground,
      supportingForeground: expressiveSupportingForeground,
      wrapValues: true,
      compact: true,
    );
    final expressiveSummary = _withMeasurementDetailSurfaceTheme(
      context,
      role: _MeasurementDetailRole.focal,
      child: _withHealthCardForeground(
        context,
        Material(
          color: surface,
          borderRadius: shapes.healthTrendCard,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (latest == null)
                  _EmptyMeasurementSummary(
                    title: strings.healthNoEntry,
                    detail: strings.healthNotTrackedYet,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.healthLatest,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: expressiveSupportingForeground,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _formatMeasurement(latest, locale),
                              key: const ValueKey(
                                'measurement-trend-summary-latest',
                              ),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: expressiveForeground,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              LocalizedFormatters.date(
                                latest.calendarDay.toLocalDateTime(),
                                locale,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: expressiveSupportingForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: expressiveForeground.withValues(alpha: 0.12),
                          borderRadius: shapes.healthTrendEntry,
                        ),
                        child: Icon(
                          Icons.monitor_heart_outlined,
                          color: expressiveForeground,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: expressiveForeground.withValues(alpha: 0.18),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stackStats =
                        constraints.maxWidth < 300 ||
                        MediaQuery.textScalerOf(context).scale(1) > 1.15;
                    if (stackStats) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          expressiveChange,
                          const SizedBox(height: 8),
                          expressiveRecords,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: expressiveChange),
                        const SizedBox(width: 20),
                        Expanded(child: expressiveRecords),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        surface: surface,
      ),
    );
    if (_measurementDetailTokens(context) != null) return expressiveSummary;
    return legacySummary;
  }
}

class _EmptyMeasurementSummary extends StatelessWidget {
  const _EmptyMeasurementSummary({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final destination = _measurementDetailTokens(context);
    final iconSurface =
        destination?.surfaceSecondary ??
        theme.colorScheme.surfaceContainerHighest;
    final iconForeground =
        destination?.onSurfaceSecondary ?? theme.colorScheme.onSurfaceVariant;
    final foreground = _measurementDetailForeground(
      context,
      role: _MeasurementDetailRole.focal,
    );
    final supportingForeground = _measurementDetailSupportingForeground(
      context,
      role: _MeasurementDetailRole.focal,
    );
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconSurface,
            borderRadius: context.shapeTokens.healthTrendEntry,
          ),
          child: Icon(Icons.show_chart, color: iconForeground),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                key: const ValueKey('measurement-trend-summary-latest'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: supportingForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final Key? valueKey;
  final String label;
  final String value;
  final String? detail;
  final Color? valueColor;
  final Color? foreground;
  final Color? supportingForeground;
  final bool wrapValues;
  final bool compact;

  const _SummaryStat({
    this.valueKey,
    required this.label,
    required this.value,
    required this.detail,
    this.valueColor,
    this.foreground,
    this.supportingForeground,
    this.wrapValues = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = this.detail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: supportingForeground ?? theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: compact ? 4 : 6),
        Text(
          value,
          key: valueKey,
          maxLines: wrapValues ? null : 1,
          overflow: wrapValues ? null : TextOverflow.ellipsis,
          style:
              (compact
                      ? theme.textTheme.titleSmall
                      : theme.textTheme.titleMedium)
                  ?.copyWith(
                    color:
                        valueColor ?? foreground ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
        ),
        if (detail != null) ...[
          SizedBox(height: compact ? 1 : 2),
          Text(
            detail,
            maxLines: wrapValues ? null : 1,
            overflow: wrapValues ? null : TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: supportingForeground ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _MeasurementChartCard extends StatefulWidget {
  final MeasurementDefinition definition;
  final List<Measurement> entries;
  final double height;

  const _MeasurementChartCard({
    required this.definition,
    required this.entries,
    required this.height,
  });

  @override
  State<_MeasurementChartCard> createState() => _MeasurementChartCardState();
}

class _MeasurementChartCardState extends State<_MeasurementChartCard> {
  int? _selectedIndex;
  List<Measurement> get _entries => MeasurementComparison.chartEntries(
    widget.definition.type,
    widget.entries,
  );

  @override
  void didUpdateWidget(covariant _MeasurementChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _selectedIndex = null;
    }
  }

  void _selectIndex(int index) {
    if (index < 0 || index >= _entries.length || _selectedIndex == index) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _selectNext() {
    if (_entries.isEmpty) return;
    final currentIndex = _selectedIndex ?? _entries.length - 1;
    if (currentIndex + 1 >= _entries.length) return;
    _selectIndex(currentIndex + 1);
  }

  void _selectPrevious() {
    if (_entries.isEmpty) return;
    final currentIndex = _selectedIndex ?? _entries.length - 1;
    if (currentIndex <= 0) return;
    _selectIndex(currentIndex - 1);
  }

  @override
  Widget build(BuildContext context) {
    final shapes = context.shapeTokens;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final dataVisualization = context.dataVisualizationTokens;
    final entries = _entries;
    final spots = _spotsFor(widget.definition, entries);
    final bounds = _chartBounds(spots.map((spot) => spot.y).toList());
    final chartSemantics = _measurementTrendSemanticsLabel(
      widget.definition,
      entries,
      strings,
      locale,
    );
    final selectedIndex = _selectedIndex;
    final currentIndex = entries.isEmpty
        ? null
        : (selectedIndex ?? entries.length - 1)
              .clamp(0, entries.length - 1)
              .toInt();
    final currentPoint = currentIndex == null ? null : entries[currentIndex];
    final nextPoint = currentIndex != null && currentIndex + 1 < entries.length
        ? entries[currentIndex + 1]
        : null;
    final previousPoint = currentIndex != null && currentIndex > 0
        ? entries[currentIndex - 1]
        : null;
    final canIncrease = nextPoint != null;
    final canDecrease = previousPoint != null;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final isSparse = entries.length < 2;
    final expressiveDetail = _usesExpressiveHealthTrendChart(context);
    final compactExpressiveEmpty = isSparse && expressiveDetail;
    final responsiveHeight = compactExpressiveEmpty
        ? math
              .min(widget.height, 128 + math.max(0.0, (textScale - 1) * 64))
              .toDouble()
        : (widget.height + math.max(0.0, (textScale - 1) * 80)).toDouble();
    final chart = _buildChart(
      context: context,
      strings: strings,
      locale: locale,
      dataVisualization: dataVisualization,
      entries: entries,
      spots: spots,
      bounds: bounds,
      selectedIndex: selectedIndex,
    );
    final hasOtherUnits = entries.length != widget.entries.length;

    return Semantics(
      key: const ValueKey('measurement-trend-chart-semantics'),
      container: true,
      label: chartSemantics,
      value: currentPoint == null
          ? null
          : _measurementPointSemanticsValue(currentPoint, locale),
      increasedValue: nextPoint == null
          ? null
          : _measurementPointSemanticsValue(nextPoint, locale),
      decreasedValue: previousPoint == null
          ? null
          : _measurementPointSemanticsValue(previousPoint, locale),
      focusable: canIncrease || canDecrease,
      onIncrease: canIncrease ? _selectNext : null,
      onDecrease: canDecrease ? _selectPrevious : null,
      child: ExcludeSemantics(
        child: _withMeasurementTrendChartTheme(
          context,
          child: Container(
            height: hasOtherUnits ? null : responsiveHeight,
            padding: expressiveDetail
                ? const EdgeInsets.fromLTRB(18, 13, 18, 16)
                : const EdgeInsets.fromLTRB(14, 16, 14, 12),
            decoration: BoxDecoration(
              color: _measurementTrendChartSurface(context),
              borderRadius: shapes.healthTrendCard,
            ),
            child: !hasOtherUnits
                ? chart
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: responsiveHeight, child: chart),
                      const SizedBox(height: 8),
                      Text(
                        strings.healthChartUnitNote(entries.last.unit),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart({
    required BuildContext context,
    required AppLocalizations strings,
    required Locale locale,
    required AppDataVisualizationTokens dataVisualization,
    required List<Measurement> entries,
    required List<FlSpot> spots,
    required _ChartBounds bounds,
    required int? selectedIndex,
  }) {
    final theme = Theme.of(context);
    if (entries.length < 2) {
      final message = entries.isEmpty
          ? strings.healthTrendNeedEntries
          : strings.healthTrendNeedOneMore;
      if (_usesExpressiveHealthTrendChart(context)) {
        return Container(
          key: const ValueKey('measurement-trend-chart-empty'),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _measurementTrendChartSurface(context),
            borderRadius: context.shapeTokens.healthTrendEntry,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _measurementDetailSupportingForeground(
                      context,
                      role: _MeasurementDetailRole.analytical,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final expressiveDetail = _usesExpressiveHealthTrendChart(context);
    final xInset = expressiveDetail ? 0.12 : 0.0;
    final chartLine = LineChartBarData(
      spots: spots,
      isCurved: !expressiveDetail,
      color: dataVisualization.tertiarySeries,
      barWidth: 3,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: dataVisualization.tertiarySeries.withValues(alpha: 0.12),
      ),
    );
    final dateTickIndexes = _measurementDateTickIndexes(entries);
    final yAxisTickValues = _chartYAxisTickValues(bounds);
    final yAxisLabels = _formatChartYAxisLabels(
      yAxisTickValues,
      bounds.interval,
      locale,
    );
    final yAxisLabelStyle = theme.textTheme.labelSmall?.copyWith(
      color: _measurementDetailForeground(
        context,
        role: _MeasurementDetailRole.analytical,
      ),
    );
    final yAxisReservedSize = _chartYAxisReservedSize(
      context,
      yAxisLabels,
      yAxisLabelStyle,
      locale,
    );
    final showingTooltipIndicators = selectedIndex == null
        ? const <ShowingTooltipIndicators>[]
        : <ShowingTooltipIndicators>[
            ShowingTooltipIndicators([
              LineBarSpot(chartLine, 0, spots[selectedIndex]),
            ]),
          ];

    return LineChart(
      LineChartData(
        minX: spots.first.x - xInset,
        maxX: spots.last.x + xInset,
        minY: bounds.minY,
        maxY: bounds.maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: context.progressColors.healthGrid.withValues(
              alpha: expressiveDetail ? 0.16 : 0.35,
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
          leftTitles: expressiveDetail
              ? const AxisTitles(
                  sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                )
              : AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: yAxisReservedSize,
                    interval: bounds.interval,
                    getTitlesWidget: (value, _) {
                      final tickIndex =
                          ((value - bounds.minY) / bounds.interval).round();
                      if (tickIndex < 0 || tickIndex >= yAxisLabels.length) {
                        return const SizedBox.shrink();
                      }
                      return SizedBox(
                        width: yAxisReservedSize - 6,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              yAxisLabels[tickIndex],
                              key: ValueKey(
                                'measurement-trend-chart-y-tick-$tickIndex',
                              ),
                              maxLines: 1,
                              softWrap: false,
                              style: yAxisLabelStyle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: expressiveDetail ? 34 : 28,
              interval: 1,
              getTitlesWidget: (value, _) {
                final index = value.round();
                if ((value - index).abs() > 0.05 ||
                    index < 0 ||
                    index >= entries.length ||
                    !dateTickIndexes.contains(index)) {
                  return const SizedBox.shrink();
                }
                return Text(
                  _shortDate(
                    entries[index].calendarDay.toLocalDateTime(),
                    locale,
                  ),
                  key: ValueKey('measurement-trend-chart-tick-$index'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _measurementDetailForeground(
                      context,
                      role: _MeasurementDetailRole.analytical,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchCallback: (event, response) {
            final touchedSpots = response?.lineBarSpots;
            if (touchedSpots == null || touchedSpots.isEmpty) return;
            _selectIndex(touchedSpots.first.spotIndex);
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.surface,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final index = spot.spotIndex.clamp(0, entries.length - 1).toInt();
              final entry = entries[index];
              return LineTooltipItem(
                '${_formatDateTime(entry.displayDateTime, locale)}\n${_formatMeasurement(entry, locale)}',
                theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ) ??
                    TextStyle(color: theme.colorScheme.onSurface),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [chartLine],
        showingTooltipIndicators: showingTooltipIndicators,
      ),
      duration: context.usesExpressivePresentation
          ? TonosExpressiveStateMotion.duration(
              context,
              TonosExpressiveStateMotion.data,
            )
          : appMotionDuration(context, const Duration(milliseconds: 150)),
      curve: context.usesExpressivePresentation
          ? TonosExpressiveStateMotion.effects
          : Curves.linear,
    );
  }
}
