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
import '../services/measurement_validation.dart';
import '../services/safe_failure.dart';
import '../theme/theme_extensions.dart';
import '../utils/tutorial_launcher.dart';
import '../utils/app_test_keys.dart';
import '../utils/localized_formatters.dart';
import 'guided_tutorial_overlay.dart';
import 'safe_error_view.dart';

class HealthTrendsSection extends StatefulWidget {
  final int refreshToken;
  final VoidCallback? onChanged;
  final bool fullPage;

  const HealthTrendsSection({
    super.key,
    this.refreshToken = 0,
    this.onChanged,
    this.fullPage = false,
  });

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

  void _notifyChanged() => widget.onChanged?.call();

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
      return _measurementSortName(
        a.definition,
      ).compareTo(_measurementSortName(b.definition));
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
      _notifyChanged();
    }
  }

  Future<void> _logEntry(_MeasurementTrend trend) async {
    final weightUnit = context.read<UnitPreferenceProvider>().weightUnit;
    final input = await showDialog<_MeasurementEntryInput>(
      context: context,
      builder:
          (_) => _MeasurementEntryDialog(
            title: _strings.healthLogMeasurement(
              _measurementTitle(trend.definition, _strings),
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
      input.context,
    );
    if (mounted) {
      _reload();
      _notifyChanged();
    }
  }

  Future<void> _createCustomMetric() async {
    final input = await showDialog<_MeasurementDefinitionInput>(
      context: context,
      builder: (_) => const _MeasurementDefinitionDialog(),
    );
    if (input == null) return;

    try {
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
          null,
        );
      }
    } on MeasurementValidationException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_measurementValidationMessage(_strings, error)),
          ),
        );
      }
      return;
    }
    if (mounted) {
      _reload();
      _notifyChanged();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);

    final header = Padding(
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
    );

    if (widget.fullPage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [header, Expanded(child: _buildTrends(strings))],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [header, _buildTrends(strings)],
    );
  }

  Widget _buildTrends(AppLocalizations strings) {
    return FutureBuilder<List<_MeasurementTrend>>(
      future: _trendsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          if (widget.fullPage) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox(
            height: 162,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SafeErrorView(
            title: strings.safeFailureLoadTitle,
            failure: SafeFailure.classify(snapshot.error!),
            onRetry: _reload,
            compact: !widget.fullPage,
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

        if (widget.fullPage) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              if (index == trends.length) {
                return _AddTrendTile(
                  onTap: _createCustomMetric,
                  fillCell: true,
                );
              }
              final trend = trends[index];
              return _TrendTile(
                trend: trend,
                onTap: () => _openTrend(trend),
                onAdd: () => _logEntry(trend),
                fillCell: true,
              );
            },
            itemCount: trends.length + 1,
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
              _measurementTitle(widget.definition, _strings),
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
      input.context,
    );
    if (mounted) _reload();
  }

  Future<void> _editEntry(Measurement entry) async {
    final input = await showDialog<_MeasurementEntryInput>(
      context: context,
      builder:
          (_) => _MeasurementEntryDialog(
            title: _strings.healthEditMeasurement(
              _measurementTitle(widget.definition, _strings),
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
      context: input.context,
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
                _formatMeasurement(entry, Localizations.localeOf(context)),
                _formatDateTime(
                  entry.displayDateTime,
                  Localizations.localeOf(context),
                ),
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
    final strings = AppLocalizations.of(context);
    final title = _measurementTitle(widget.definition, strings);

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
              return SafeErrorView(
                title: strings.safeFailureLoadTitle,
                failure: SafeFailure.classify(snapshot.error!),
                onRetry: _reload,
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
  final bool fillCell;

  const _TrendTile({
    required this.trend,
    required this.onTap,
    required this.onAdd,
    this.fillCell = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final title = _measurementTitle(trend.definition, strings);
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
          key: AppTestKeys.measurementTrend(trend.definition.id),
          width: fillCell ? double.infinity : 154,
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
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: strings.healthLogMeasurement(title),
                    onTap: onAdd,
                    child: ExcludeSemantics(
                      child: InkResponse(
                        key: AppTestKeys.measurementTrendAdd(
                          trend.definition.id,
                        ),
                        onTap: onAdd,
                        radius: 18,
                        child: Icon(
                          Icons.add_circle_outline,
                          size: 18,
                          color:
                              colors.healthTrendIcon ??
                              theme.colorScheme.primary,
                        ),
                      ),
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
                latest == null
                    ? strings.healthNoEntries
                    : _formatMeasurement(latest, locale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                latest == null
                    ? strings.healthTapToLog
                    : _formatDelta(delta, strings, locale),
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
  final bool fillCell;

  const _AddTrendTile({required this.onTap, this.fillCell = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final colors = context.colors;
    return Semantics(
      button: true,
      label: strings.healthCreateMetric,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: fillCell ? double.infinity : 132,
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
                    strings.healthCustomMetric,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ),
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
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
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
              label: strings.healthLatest,
              value:
                  latest == null
                      ? strings.healthNoEntry
                      : _formatMeasurement(latest, locale),
              detail:
                  latest == null
                      ? strings.healthNotTrackedYet
                      : LocalizedFormatters.date(
                        latest.calendarDay.toLocalDateTime(),
                        locale,
                      ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryStat(
              label: strings.healthChange,
              value:
                  delta == null
                      ? strings.healthNoChange
                      : _formatDelta(delta, strings, locale),
              detail:
                  entries.length < 2
                      ? strings.healthNeedTwoEntries
                      : strings.healthVersusPrevious,
              valueColor: _deltaColor(context, delta),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryStat(
              label: strings.healthRecords,
              value: LocalizedFormatters.number(
                entries.length,
                locale,
                maximumFractionDigits: 0,
              ),
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
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final colors = context.colors;
    final spots = _spotsFor(entries);
    final bounds = _chartBounds(entries.map((m) => m.value).toList());
    final title = _measurementTitle(definition, strings);
    final latest =
        entries.isEmpty
            ? strings.healthNoEntry
            : _formatMeasurement(entries.last, locale);
    final chartSemantics = strings.healthTrendChartSemantics(
      title,
      entries.length,
      latest,
    );

    return Semantics(
      container: true,
      label: chartSemantics,
      child: ExcludeSemantics(
        child: Container(
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
                          ? strings.healthTrendNeedEntries
                          : strings.healthTrendNeedOneMore,
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
                                  _compactNumber(value, locale),
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
                                _shortDate(
                                  entries[index].calendarDay.toLocalDateTime(),
                                  locale,
                                ),
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
                                      '${_formatDateTime(entry.displayDateTime, locale)}\n${_formatMeasurement(entry, locale)}',
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
                              colors.healthTrendLine ??
                              theme.colorScheme.primary,
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
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final contextLabel = _measurementContextLabel(entry, strings);
    final note = _measurementNote(entry);
    final details = <String>[
      _formatDateTime(entry.displayDateTime, locale),
      if (contextLabel != null) contextLabel,
      if (note != null) note,
    ].join(' - ');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        onTap: onTap,
        title: Text(_formatMeasurement(entry, locale)),
        subtitle: Text(details),
        trailing: PopupMenuButton<String>(
          tooltip: strings.healthEntryActions,
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
  late final TextEditingController _heightInchesController;
  late final TextEditingController _unitController;
  late final TextEditingController _noteController;
  bool _heightUsesFeetAndInches = false;
  String? _bodyWeightVariation;
  bool _withPump = false;

  bool get _isHeight => widget.definition.type == MeasurementType.Height;
  bool get _isBodyWeight =>
      widget.definition.type == MeasurementType.BodyWeight;
  bool get _isBodyPart =>
      !_isHeight &&
      !_isBodyWeight &&
      widget.definition.type != MeasurementType.Custom;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    final unit = entry?.unit ?? widget.defaultUnit;
    final note = entry?.note ?? '';
    final measurementContext =
        entry?.context ??
        MeasurementValidation.legacyContextFor(
          type: widget.definition.type,
          note: entry?.note,
        );
    _timestamp = entry?.timestamp ?? DateTime.now();
    _heightUsesFeetAndInches = _isHeight && unit == 'in';
    if (_heightUsesFeetAndInches && entry != null) {
      final totalInches = entry.value.round();
      _valueController = TextEditingController(
        text: (totalInches ~/ 12).toString(),
      );
      _heightInchesController = TextEditingController(
        text: (totalInches % 12).toString(),
      );
    } else {
      _valueController = TextEditingController(
        text: entry == null ? '' : _cleanNumber(entry.value),
      );
      _heightInchesController = TextEditingController();
    }
    _unitController = TextEditingController(text: unit);
    _bodyWeightVariation = switch (measurementContext) {
      MeasurementContext.wakeUp => 'WakeUp',
      MeasurementContext.bedtime => 'BedTime',
      MeasurementContext.overall => 'Overall',
      _ => _isBodyWeight && _isKnownBodyWeightVariation(note) ? note : null,
    };
    _withPump =
        measurementContext == MeasurementContext.withPump ||
        (_isBodyPart && note == 'With pump');
    _noteController = TextEditingController(
      text: _usesPresetNote(note) ? '' : note,
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _heightInchesController.dispose();
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
    final value =
        _heightUsesFeetAndInches
            ? _heightInchesValue()
            : double.tryParse(_valueController.text.trim());
    final unit = _heightUsesFeetAndInches ? 'in' : _unitController.text.trim();
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
    try {
      MeasurementValidation.validateEntry(
        type: widget.definition.type,
        value: value,
        unit: unit,
        context: _resolvedContext(),
      );
    } on MeasurementValidationException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _measurementValidationMessage(AppLocalizations.of(context), error),
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
        note: _resolvedNote(),
        context: _resolvedContext(),
      ),
    );
  }

  double? _heightInchesValue() {
    final feet = int.tryParse(_valueController.text.trim());
    final inches = int.tryParse(_heightInchesController.text.trim());
    if (feet == null || inches == null || inches < 0 || inches >= 12) {
      return null;
    }
    return (feet * 12 + inches).toDouble();
  }

  String? _resolvedNote() {
    final typedNote = _noteController.text.trim();
    if (typedNote.isNotEmpty) return typedNote;
    return null;
  }

  MeasurementContext? _resolvedContext() {
    if (_isBodyWeight) {
      return switch (_bodyWeightVariation) {
        'WakeUp' => MeasurementContext.wakeUp,
        'BedTime' => MeasurementContext.bedtime,
        'Overall' => MeasurementContext.overall,
        _ => null,
      };
    }
    if (_isBodyPart) {
      return _withPump
          ? MeasurementContext.withPump
          : MeasurementContext.withoutPump;
    }
    return null;
  }

  bool _usesPresetNote(String note) {
    return _isKnownBodyWeightVariation(note) ||
        (_isBodyPart && (note == 'With pump' || note == 'Without pump'));
  }

  bool _isKnownBodyWeightVariation(String note) {
    return note == 'WakeUp' || note == 'BedTime' || note == 'Overall';
  }

  void _setHeightUnit(bool useFeetAndInches) {
    if (_heightUsesFeetAndInches == useFeetAndInches) return;

    if (useFeetAndInches) {
      final centimeters = double.tryParse(_valueController.text.trim());
      if (centimeters == null) {
        _valueController.clear();
        _heightInchesController.clear();
      } else {
        final totalInches = (centimeters / 2.54).round();
        _valueController.text = (totalInches ~/ 12).toString();
        _heightInchesController.text = (totalInches % 12).toString();
      }
    } else {
      final totalInches = _heightInchesValue();
      _valueController.text =
          totalInches == null ? '' : _cleanNumber(totalInches * 2.54);
    }
    setState(() {
      _heightUsesFeetAndInches = useFeetAndInches;
      _unitController.text = useFeetAndInches ? 'in' : 'cm';
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isHeight) ...[
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(
                      '${strings.measurementFeet}/${strings.measurementInches}',
                    ),
                    selected: _heightUsesFeetAndInches,
                    onSelected: (_) => _setHeightUnit(true),
                  ),
                  ChoiceChip(
                    label: Text(strings.measurementCentimeters),
                    selected: !_heightUsesFeetAndInches,
                    onSelected: (_) => _setHeightUnit(false),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (_heightUsesFeetAndInches)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _valueController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: strings.measurementFeet,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _heightInchesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: strings.measurementInches,
                      ),
                    ),
                  ),
                ],
              )
            else
              TextField(
                key: AppTestKeys.measurementEntryValue,
                controller: _valueController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: _measurementTitle(widget.definition, strings),
                ),
              ),
            const SizedBox(height: 10),
            if (!_heightUsesFeetAndInches)
              TextField(
                key: AppTestKeys.measurementEntryUnit,
                controller: _unitController,
                decoration: InputDecoration(labelText: strings.healthUnit),
              ),
            if (!_heightUsesFeetAndInches) const SizedBox(height: 10),
            if (_isBodyWeight) ...[
              DropdownButtonFormField<String>(
                value: _bodyWeightVariation,
                decoration: InputDecoration(
                  labelText: strings.measurementVariation,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'WakeUp',
                    child: Text(strings.measurementWakeUp),
                  ),
                  DropdownMenuItem(
                    value: 'BedTime',
                    child: Text(strings.measurementBedtime),
                  ),
                  DropdownMenuItem(
                    value: 'Overall',
                    child: Text(strings.measurementOverall),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _bodyWeightVariation = value);
                },
              ),
              const SizedBox(height: 10),
            ],
            if (_isBodyPart)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _withPump,
                onChanged:
                    (value) => setState(() => _withPump = value ?? false),
                title: Text(strings.measurementWithPump),
              ),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: strings.healthNote,
                hintText: strings.healthOptional,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _formatDateTime(_timestamp, Localizations.localeOf(context)),
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
          key: AppTestKeys.measurementEntrySave,
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
    try {
      MeasurementValidation.validateDefinition(name: name, unit: unit);
      if (initialValue != null) {
        MeasurementValidation.validateEntry(
          type: MeasurementType.Custom,
          value: initialValue,
          unit: unit,
        );
      }
    } on MeasurementValidationException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _measurementValidationMessage(AppLocalizations.of(context), error),
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
  final MeasurementContext? context;

  const _MeasurementEntryInput({
    required this.timestamp,
    required this.value,
    required this.unit,
    this.note,
    this.context,
  });
}

String _measurementValidationMessage(
  AppLocalizations strings,
  MeasurementValidationException error,
) {
  return switch (error.error) {
    MeasurementValidationError.missingName ||
    MeasurementValidationError.invalidName ||
    MeasurementValidationError.duplicateName ||
    MeasurementValidationError.invalidUnit => strings.healthMetricInvalid,
    MeasurementValidationError.unsupportedUnit ||
    MeasurementValidationError.invalidValue ||
    MeasurementValidationError.implausibleValue ||
    MeasurementValidationError
        .invalidContext => strings.healthMeasurementEntryInvalid,
  };
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

String _measurementTitle(
  MeasurementDefinition definition,
  AppLocalizations strings,
) {
  if (definition.type == MeasurementType.Custom) return definition.name;
  return switch (definition.type) {
    MeasurementType.BodyWeight => strings.measurementWeight,
    MeasurementType.Height => strings.measurementHeight,
    MeasurementType.Forearm => strings.measurementForearm,
    MeasurementType.Arm => strings.measurementArm,
    MeasurementType.Neck => strings.measurementNeck,
    MeasurementType.Shoulder => strings.measurementShoulders,
    MeasurementType.Chest => strings.measurementChest,
    MeasurementType.Waist => strings.measurementWaist,
    MeasurementType.Hip => strings.measurementHips,
    MeasurementType.Thigh => strings.measurementThigh,
    MeasurementType.Calf => strings.measurementCalves,
    MeasurementType.Custom => definition.name,
  };
}

String _measurementSortName(MeasurementDefinition definition) {
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

String _formatMeasurement(Measurement entry, Locale locale) {
  return '${_localizedNumber(entry.value, locale)} ${entry.unit}'.trim();
}

String _formatDelta(double? delta, AppLocalizations strings, Locale locale) {
  if (delta == null || delta.abs() < 0.001) return strings.healthNoChange;
  final prefix = delta > 0 ? '+' : '';
  return strings.healthChangeSinceLast(
    '$prefix${_localizedNumber(delta, locale)}',
  );
}

String _localizedNumber(double value, Locale locale) {
  final maximumFractionDigits =
      value.abs() >= 1000 || value == value.roundToDouble() ? 0 : 1;
  return LocalizedFormatters.number(
    value,
    locale,
    maximumFractionDigits: maximumFractionDigits,
  );
}

String? _measurementContextLabel(Measurement entry, AppLocalizations strings) {
  final context = entry.context ?? _legacyMeasurementContext(entry.note);
  return switch (context) {
    MeasurementContext.wakeUp => strings.measurementWakeUp,
    MeasurementContext.bedtime => strings.measurementBedtime,
    MeasurementContext.overall => strings.measurementOverall,
    MeasurementContext.withPump => strings.measurementWithPump,
    MeasurementContext.withoutPump => strings.measurementWithoutPump,
    null => null,
  };
}

MeasurementContext? _legacyMeasurementContext(String? note) {
  return switch (note?.trim()) {
    'WakeUp' => MeasurementContext.wakeUp,
    'BedTime' => MeasurementContext.bedtime,
    'Overall' => MeasurementContext.overall,
    'With pump' => MeasurementContext.withPump,
    'Without pump' => MeasurementContext.withoutPump,
    _ => null,
  };
}

String? _measurementNote(Measurement entry) {
  final note = entry.note?.trim();
  if (note == null || note.isEmpty) return null;
  return _legacyMeasurementContext(note) == null ? note : null;
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

String _compactNumber(double value, Locale locale) {
  return LocalizedFormatters.compactNumber(value, locale);
}

String _shortDate(DateTime value, Locale locale) {
  return LocalizedFormatters.shortDate(value, locale);
}

String _formatDateTime(DateTime value, Locale locale) {
  return LocalizedFormatters.dateTime(value, locale);
}
