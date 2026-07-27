import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../services/tutorial_state_store.dart';
import '../theme/theme_extensions.dart';
import '../utils/tutorial_launcher.dart';
import 'guided_tutorial_overlay.dart';

class HealthTrendsSection extends StatefulWidget {
  final int refreshToken;

  const HealthTrendsSection({super.key, this.refreshToken = 0});

  @override
  State<HealthTrendsSection> createState() => HealthTrendsSectionState();
}

class HealthTrendsSectionState extends State<HealthTrendsSection>
    with AutomaticKeepAliveClientMixin<HealthTrendsSection> {
  AppRepository get _repo => context.read<AppRepository>();
  late Future<List<_MeasurementTrend>> _trendsFuture;

  AppLocalizations get _strings => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _trendsFuture = _loadTrends();
  }

  @override
  void didUpdateWidget(covariant HealthTrendsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _reload();
    }
  }

  void _reload() {
    setState(() {
      _trendsFuture = _loadTrends();
    });
  }

  Future<List<_MeasurementTrend>> _loadTrends() async {
    await _repo.ensureDefaultMeasurementDefinitions();
    final definitions = await _repo.fetchClassMeasurementDefinitions();
    final trends = await Future.wait(
      definitions.map((definition) async {
        final entries = await _repo.fetchClassMeasurementsForDefinition(
          definition.id,
        );
        entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return _MeasurementTrend(definition: definition, entries: entries);
      }),
    );

    trends.sort((a, b) {
      final usedCompare = (b.entries.isNotEmpty ? 1 : 0).compareTo(
        a.entries.isNotEmpty ? 1 : 0,
      );
      if (usedCompare != 0) return usedCompare;
      final orderCompare = _definitionOrder(
        a.definition,
      ).compareTo(_definitionOrder(b.definition));
      if (orderCompare != 0) return orderCompare;
      return _measurementTitle(
        a.definition,
      ).compareTo(_measurementTitle(b.definition));
    });
    return trends;
  }

  Future<void> _openTrend(_MeasurementTrend trend) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => MeasurementTrendDetailPage(definition: trend.definition),
      ),
    );
    if (changed == true && mounted) {
      _reload();
    }
  }

  Future<void> _logEntry(_MeasurementTrend trend) async {
    final weightUnit = context.read<UnitPreferenceProvider>().weightUnit;
    final input = await showDialog<_MeasurementEntryInput>(
      context: context,
      builder:
          (_) => _MeasurementEntryDialog(
            title: _strings.healthLogMeasurement(
              _measurementTitle(trend.definition),
            ),
            definition: trend.definition,
            defaultUnit:
                trend.latest?.unit ??
                _defaultUnitFor(trend.definition, weightUnit),
          ),
    );
    if (input == null) return;

    await _repo.insertMeasurement(
      trend.definition.id,
      input.timestamp,
      input.value,
      input.unit,
      input.note,
    );
    if (mounted) _reload();
  }

  Future<void> _createCustomMetric() async {
    final input = await showDialog<_MeasurementDefinitionInput>(
      context: context,
      builder: (_) => const _MeasurementDefinitionDialog(),
    );
    if (input == null) return;

    final defId = await _repo.insertMeasurementDefinition(
      name: input.name,
      type: MeasurementType.Custom,
    );
    if (input.initialValue != null) {
      await _repo.insertMeasurement(
        defId,
        DateTime.now(),
        input.initialValue!,
        input.unit,
        input.note,
      );
    }
    if (mounted) _reload();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  strings.healthTrendsTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              TextButton.icon(
                onPressed: _createCustomMetric,
                icon: const Icon(Icons.add, size: 18),
                label: Text(strings.healthMetric),
              ),
            ],
          ),
        ),
        FutureBuilder<List<_MeasurementTrend>>(
          future: _trendsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 162,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return _HealthTrendMessageCard(
                icon: Icons.error_outline,
                title: strings.healthUnableToLoad,
                message: snapshot.error.toString(),
              );
            }

            final trends = snapshot.data ?? const <_MeasurementTrend>[];
            if (trends.isEmpty) {
              return _HealthTrendMessageCard(
                icon: Icons.straighten,
                title: strings.healthNoMeasurements,
                message: strings.healthNoMeasurementsBody,
                actionLabel: strings.healthCreateMetric,
                onAction: _createCustomMetric,
              );
            }

            return SizedBox(
              height: 162,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  if (index == trends.length) {
                    return _AddTrendTile(onTap: _createCustomMetric);
                  }
                  final trend = trends[index];
                  return _TrendTile(
                    trend: trend,
                    onTap: () => _openTrend(trend),
                    onAdd: () => _logEntry(trend),
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemCount: trends.length + 1,
              ),
            );
          },
        ),
      ],
    );
  }
}

class MeasurementTrendDetailPage extends StatefulWidget {
  final MeasurementDefinition definition;

  const MeasurementTrendDetailPage({super.key, required this.definition});

  @override
  State<MeasurementTrendDetailPage> createState() =>
      _MeasurementTrendDetailPageState();
}

class _MeasurementTrendDetailPageState
    extends State<MeasurementTrendDetailPage> {
  AppRepository get _repo => context.read<AppRepository>();
  final _addTutorialKey = GlobalKey(debugLabel: 'measurement_trend_add');
  final _summaryTutorialKey = GlobalKey(
    debugLabel: 'measurement_trend_summary',
  );
  final _chartTutorialKey = GlobalKey(debugLabel: 'measurement_trend_chart');
  final _entriesTutorialKey = GlobalKey(
    debugLabel: 'measurement_trend_entries',
  );
  late Future<List<Measurement>> _entriesFuture;
  bool _changed = false;

  AppLocalizations get _strings => AppLocalizations.of(context);
  bool _tutorialQueued = false;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _loadEntries();
  }

  Future<List<Measurement>> _loadEntries() async {
    final entries = await _repo.fetchClassMeasurementsForDefinition(
      widget.definition.id,
    );
    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return entries;
  }

  void _reload() {
    setState(() {
      _entriesFuture = _loadEntries();
      _changed = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
  }

  void _queueTutorial() {
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  Future<void> _showTutorial() async {
    try {
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.measurementTrendDetail,
        steps: [
          GuidedTutorialStep(
            targetKey: _summaryTutorialKey,
            icon: Icons.speed,
            title: _strings.healthTutorialSummaryTitle,
            body: _strings.healthTutorialSummaryBody,
          ),
          GuidedTutorialStep(
            targetKey: _chartTutorialKey,
            icon: Icons.show_chart,
            title: _strings.healthTutorialChartTitle,
            body: _strings.healthTutorialChartBody,
          ),
          GuidedTutorialStep(
            targetKey: _entriesTutorialKey,
            icon: Icons.list_alt,
            title: _strings.healthTutorialEntriesTitle,
            body: _strings.healthTutorialEntriesBody,
          ),
          GuidedTutorialStep(
            targetKey: _addTutorialKey,
            icon: Icons.add,
            title: _strings.healthTutorialLogTitle,
            body: _strings.healthTutorialLogBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  Future<void> _addEntry(List<Measurement> entries) async {
    final weightUnit = context.read<UnitPreferenceProvider>().weightUnit;
    final input = await showDialog<_MeasurementEntryInput>(
      context: context,
      builder:
          (_) => _MeasurementEntryDialog(
            title: _strings.healthLogMeasurement(
              _measurementTitle(widget.definition),
            ),
            definition: widget.definition,
            defaultUnit:
                entries.isNotEmpty
                    ? entries.last.unit
                    : _defaultUnitFor(widget.definition, weightUnit),
          ),
    );
    if (input == null) return;

    await _repo.insertMeasurement(
      widget.definition.id,
      input.timestamp,
      input.value,
      input.unit,
      input.note,
    );
    if (mounted) _reload();
  }

  Future<void> _editEntry(Measurement entry) async {
    final input = await showDialog<_MeasurementEntryInput>(
      context: context,
      builder:
          (_) => _MeasurementEntryDialog(
            title: _strings.healthEditMeasurement(
              _measurementTitle(widget.definition),
            ),
            definition: widget.definition,
            defaultUnit: entry.unit,
            entry: entry,
          ),
    );
    if (input == null) return;

    await _repo.updateMeasurement(
      measurementId: entry.id,
      timestamp: input.timestamp,
      value: input.value,
      unit: input.unit,
      note: input.note,
    );
    if (mounted) _reload();
  }

  Future<void> _deleteEntry(Measurement entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(_strings.healthDeleteEntryTitle),
            content: Text(
              _strings.healthDeleteEntryBody(
                _formatMeasurement(entry),
                _formatDateTime(entry.timestamp),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(_strings.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(_strings.commonDelete),
              ),
            ],
          ),
    );
    if (confirmed != true) return;

    await _repo.deleteMeasurement(entry.id);
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final title = _measurementTitle(widget.definition);
    final strings = AppLocalizations.of(context);

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(_changed),
          ),
          title: Text(title),
          actions: [
            IconButton(
              tooltip: strings.healthLogEntry,
              onPressed: () async {
                final entries = await _entriesFuture;
                if (!context.mounted) return;
                await _addEntry(entries);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: FutureBuilder<List<Measurement>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  strings.healthLoadFailed(snapshot.error.toString()),
                ),
              );
            }

            final entries = snapshot.data ?? const <Measurement>[];
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _queueTutorial();
            });
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                KeyedSubtree(
                  key: _summaryTutorialKey,
                  child: _MeasurementSummaryCard(
                    definition: widget.definition,
                    entries: entries,
                  ),
                ),
                const SizedBox(height: 12),
                KeyedSubtree(
                  key: _chartTutorialKey,
                  child: _MeasurementChartCard(
                    definition: widget.definition,
                    entries: entries,
                    height: 250,
                  ),
                ),
                const SizedBox(height: 20),
                KeyedSubtree(
                  key: _entriesTutorialKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        strings.healthEntries,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (entries.isEmpty)
                        _HealthTrendMessageCard(
                          icon: Icons.add_chart,
                          title: strings.healthNoEntries,
                          message: strings.healthFirstEntry(title),
                          actionLabel: strings.healthLogEntry,
                          onAction: () => _addEntry(entries),
                        )
                      else
                        for (final entry in entries.reversed)
                          _MeasurementEntryTile(
                            entry: entry,
                            onTap: () => _editEntry(entry),
                            onDelete: () => _deleteEntry(entry),
                          ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: KeyedSubtree(
              key: _addTutorialKey,
              child: FilledButton.icon(
                onPressed: () async {
                  final entries = await _entriesFuture;
                  if (!context.mounted) return;
                  await _addEntry(entries);
                },
                icon: const Icon(Icons.add),
                label: Text(strings.healthLogEntry),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendTile extends StatelessWidget {
  final _MeasurementTrend trend;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _TrendTile({
    required this.trend,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final latest = trend.latest;
    final delta = trend.delta;
    final deltaColor = _deltaColor(context, delta);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 154,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: (colors.healthTrendBorder ?? theme.dividerColor)
                  .withValues(alpha: 0.75),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _measurementTitle(trend.definition),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  InkResponse(
                    onTap: onAdd,
                    radius: 18,
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color:
                          colors.healthTrendIcon ?? theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _MeasurementSparkline(
                  entries: trend.entries,
                  lineColor:
                      colors.healthTrendLine ?? theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                latest == null ? 'No entries' : _formatMeasurement(latest),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                latest == null ? 'Tap + to log' : _formatDelta(delta),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: deltaColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTrendTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTrendTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 132,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.healthTrendBorder ?? theme.dividerColor,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: colors.healthTrendIcon ?? theme.colorScheme.primary,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                'Custom Metric',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasurementSparkline extends StatelessWidget {
  final List<Measurement> entries;
  final Color lineColor;

  const _MeasurementSparkline({required this.entries, required this.lineColor});

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) {
      return Center(
        child: Icon(
          Icons.show_chart,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.25),
        ),
      );
    }

    final spots = _spotsFor(entries);
    final bounds = _chartBounds(entries.map((m) => m.value).toList());
    return LineChart(
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
    final theme = Theme.of(context);
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final latest = entries.isEmpty ? null : entries.last;
    final previous = entries.length < 2 ? null : entries[entries.length - 2];
    final delta =
        latest == null || previous == null
            ? null
            : latest.value - previous.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryStat(
              label: 'Latest',
              value: latest == null ? 'No entry' : _formatMeasurement(latest),
              detail:
                  latest == null
                      ? 'Not tracked yet'
                      : _formatDate(latest.timestamp),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryStat(
              label: 'Change',
              value: delta == null ? '0' : _formatDelta(delta),
              detail: entries.length < 2 ? 'Need 2 entries' : 'Vs previous',
              valueColor: _deltaColor(context, delta),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryStat(
              label: 'Records',
              value: '${entries.length}',
              detail: _defaultUnitFor(definition, weightUnit),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final Color? valueColor;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.detail,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          detail,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MeasurementChartCard extends StatelessWidget {
  final MeasurementDefinition definition;
  final List<Measurement> entries;
  final double height;

  const _MeasurementChartCard({
    required this.definition,
    required this.entries,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final spots = _spotsFor(entries);
    final bounds = _chartBounds(entries.map((m) => m.value).toList());

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child:
          entries.length < 2
              ? Center(
                child: Text(
                  entries.isEmpty
                      ? 'Log entries to build a trend.'
                      : 'Log one more entry to draw a trend.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              )
              : LineChart(
                LineChartData(
                  minX: spots.first.x,
                  maxX: spots.last.x,
                  minY: bounds.minY,
                  maxY: bounds.maxY,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine:
                        (_) => FlLine(
                          color: theme.dividerColor.withValues(alpha: 0.35),
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
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: bounds.interval,
                        getTitlesWidget:
                            (value, _) => Text(
                              _compactNumber(value),
                              style: theme.textTheme.labelSmall,
                            ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: math.max(1.0, (spots.length - 1) / 2),
                        getTitlesWidget: (value, _) {
                          final index =
                              value
                                  .round()
                                  .clamp(0, entries.length - 1)
                                  .toInt();
                          if ((value - index).abs() > 0.2) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            _shortDate(entries[index].timestamp),
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => theme.colorScheme.surface,
                      getTooltipItems:
                          (touchedSpots) =>
                              touchedSpots.map((spot) {
                                final index =
                                    spot.spotIndex
                                        .clamp(0, entries.length - 1)
                                        .toInt();
                                final entry = entries[index];
                                return LineTooltipItem(
                                  '${_formatDateTime(entry.timestamp)}\n${_formatMeasurement(entry)}',
                                  theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                      ) ??
                                      TextStyle(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                );
                              }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color:
                          colors.healthTrendLine ?? theme.colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: (colors.healthTrendLine ??
                                theme.colorScheme.primary)
                            .withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class _MeasurementEntryTile extends StatelessWidget {
  final Measurement entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MeasurementEntryTile({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        onTap: onTap,
        title: Text(_formatMeasurement(entry)),
        subtitle: Text(
          '${_formatDateTime(entry.timestamp)}${entry.note == null || entry.note!.trim().isEmpty ? '' : ' - ${entry.note}'}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onTap();
            if (value == 'delete') onDelete();
          },
          itemBuilder:
              (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(AppLocalizations.of(context).commonEdit),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(AppLocalizations.of(context).commonDelete),
                ),
              ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: theme.cardColor,
      ),
    );
  }
}

class _HealthTrendMessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _HealthTrendMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(message, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 10),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _MeasurementEntryDialog extends StatefulWidget {
  final String title;
  final MeasurementDefinition definition;
  final String defaultUnit;
  final Measurement? entry;

  const _MeasurementEntryDialog({
    required this.title,
    required this.definition,
    required this.defaultUnit,
    this.entry,
  });

  @override
  State<_MeasurementEntryDialog> createState() =>
      _MeasurementEntryDialogState();
}

class _MeasurementEntryDialogState extends State<_MeasurementEntryDialog> {
  late DateTime _timestamp;
  late final TextEditingController _valueController;
  late final TextEditingController _unitController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _timestamp = entry?.timestamp ?? DateTime.now();
    _valueController = TextEditingController(
      text: entry == null ? '' : _cleanNumber(entry.value),
    );
    _unitController = TextEditingController(
      text: entry?.unit ?? widget.defaultUnit,
    );
    _noteController = TextEditingController(text: entry?.note ?? '');
  }

  @override
  void dispose() {
    _valueController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDate: _timestamp,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (!mounted) return;
    setState(() {
      _timestamp = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _timestamp.hour,
        time?.minute ?? _timestamp.minute,
      );
    });
  }

  void _save() {
    final value = double.tryParse(_valueController.text.trim());
    final unit = _unitController.text.trim();
    if (value == null || unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).healthEntryValueUnitRequired,
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      _MeasurementEntryInput(
        timestamp: _timestamp,
        value: value,
        unit: unit,
        note:
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _valueController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: _measurementTitle(widget.definition),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthUnit,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthNote,
                hintText: AppLocalizations.of(context).healthOptional,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(_formatDateTime(_timestamp)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).commonCancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(AppLocalizations.of(context).commonSave),
        ),
      ],
    );
  }
}

class _MeasurementDefinitionDialog extends StatefulWidget {
  const _MeasurementDefinitionDialog();

  @override
  State<_MeasurementDefinitionDialog> createState() =>
      _MeasurementDefinitionDialogState();
}

class _MeasurementDefinitionDialogState
    extends State<_MeasurementDefinitionDialog> {
  final _nameController = TextEditingController();
  final _unitController = TextEditingController(text: 'in');
  final _initialValueController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _initialValueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final unit = _unitController.text.trim();
    final initialText = _initialValueController.text.trim();
    final initialValue =
        initialText.isEmpty ? null : double.tryParse(initialText);

    if (name.isEmpty ||
        unit.isEmpty ||
        (initialText.isNotEmpty && initialValue == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).healthDefinitionFieldsRequired,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      _MeasurementDefinitionInput(
        name: name,
        unit: unit,
        initialValue: initialValue,
        note:
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    return AlertDialog(
      title: Text(AppLocalizations.of(context).healthCreateMetric),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthMetricName,
                hintText: AppLocalizations.of(context).healthMetricNameHint,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthUnit,
                hintText: AppLocalizations.of(
                  context,
                ).healthUnitHint(weightUnit.shortLabel),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _initialValueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthStartingValue,
                hintText: AppLocalizations.of(context).healthOptional,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthNote,
                hintText: AppLocalizations.of(context).healthOptional,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).commonCancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(AppLocalizations.of(context).healthCreate),
        ),
      ],
    );
  }
}

class _MeasurementTrend {
  final MeasurementDefinition definition;
  final List<Measurement> entries;

  const _MeasurementTrend({required this.definition, required this.entries});

  Measurement? get latest => entries.isEmpty ? null : entries.last;

  Measurement? get previous =>
      entries.length < 2 ? null : entries[entries.length - 2];

  double? get delta {
    final last = latest;
    final prior = previous;
    if (last == null || prior == null) return null;
    return last.value - prior.value;
  }
}

class _MeasurementEntryInput {
  final DateTime timestamp;
  final double value;
  final String unit;
  final String? note;

  const _MeasurementEntryInput({
    required this.timestamp,
    required this.value,
    required this.unit,
    this.note,
  });
}

class _MeasurementDefinitionInput {
  final String name;
  final String unit;
  final double? initialValue;
  final String? note;

  const _MeasurementDefinitionInput({
    required this.name,
    required this.unit,
    this.initialValue,
    this.note,
  });
}

class _ChartBounds {
  final double minY;
  final double maxY;
  final double interval;

  const _ChartBounds({
    required this.minY,
    required this.maxY,
    required this.interval,
  });
}

List<FlSpot> _spotsFor(List<Measurement> entries) {
  return List.generate(
    entries.length,
    (index) => FlSpot(index.toDouble(), entries[index].value),
  );
}

_ChartBounds _chartBounds(List<double> values) {
  if (values.isEmpty) {
    return const _ChartBounds(minY: 0, maxY: 1, interval: 1);
  }

  var minY = values.reduce(math.min);
  var maxY = values.reduce(math.max);
  final range = maxY - minY;
  final padding = range <= 0 ? math.max(1.0, maxY.abs() * 0.04) : range * 0.08;
  minY -= padding;
  maxY += padding;
  if (minY == maxY) maxY = minY + 1;
  final interval = math.max((maxY - minY) / 3, 0.1);
  return _ChartBounds(minY: minY, maxY: maxY, interval: interval);
}

int _definitionOrder(MeasurementDefinition definition) {
  const order = <MeasurementType, int>{
    MeasurementType.BodyWeight: 0,
    MeasurementType.Height: 1,
    MeasurementType.Chest: 2,
    MeasurementType.Waist: 3,
    MeasurementType.Hip: 4,
    MeasurementType.Shoulder: 5,
    MeasurementType.Arm: 6,
    MeasurementType.Forearm: 7,
    MeasurementType.Thigh: 8,
    MeasurementType.Calf: 9,
    MeasurementType.Neck: 10,
    MeasurementType.Custom: 100,
  };
  return order[definition.type] ?? 100;
}

String _measurementTitle(MeasurementDefinition definition) {
  if (definition.type == MeasurementType.Custom) return definition.name;
  return switch (definition.type) {
    MeasurementType.BodyWeight => 'Weight',
    MeasurementType.Height => 'Height',
    MeasurementType.Forearm => 'Forearm',
    MeasurementType.Arm => 'Arm',
    MeasurementType.Neck => 'Neck',
    MeasurementType.Shoulder => 'Shoulders',
    MeasurementType.Chest => 'Chest',
    MeasurementType.Waist => 'Waist',
    MeasurementType.Hip => 'Hips',
    MeasurementType.Thigh => 'Thigh',
    MeasurementType.Calf => 'Calves',
    MeasurementType.Custom => definition.name,
  };
}

String _defaultUnitFor(
  MeasurementDefinition definition, [
  WeightUnit weightUnit = WeightUnit.pounds,
]) {
  return switch (definition.type) {
    MeasurementType.BodyWeight => weightUnit.shortLabel,
    MeasurementType.Height => 'in',
    MeasurementType.Custom => '',
    _ => 'in',
  };
}

String _formatMeasurement(Measurement entry) {
  return '${_cleanNumber(entry.value)} ${entry.unit}'.trim();
}

String _formatDelta(double? delta) {
  if (delta == null || delta.abs() < 0.001) return 'No change yet';
  final prefix = delta > 0 ? '+' : '';
  return '$prefix${_cleanNumber(delta)} since last';
}

Color? _deltaColor(BuildContext context, double? delta) {
  if (delta == null || delta.abs() < 0.001) {
    return Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7);
  }
  return delta > 0 ? Colors.greenAccent.shade400 : Colors.redAccent.shade100;
}

String _cleanNumber(double value) {
  if (value.abs() >= 1000) {
    return value.toStringAsFixed(0);
  }
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}

String _compactNumber(double value) {
  if (value.abs() >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}k';
  }
  return _cleanNumber(value);
}

String _formatDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}

String _shortDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}';
}

String _formatDateTime(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '${_formatDate(value)} $hour:$minute $suffix';
}
