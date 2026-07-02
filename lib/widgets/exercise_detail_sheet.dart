// File: lib/widgets/exercise_detail_sheet.dart

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';
import '../utils/weight_unit_formatter.dart';
import 'body_heatmap.dart';

/// Simple record model for history tab
class HistoryRecord {
  final DateTime date;
  final int sessionId;
  final List<ExerciseSet> sets;

  HistoryRecord({
    required this.date,
    required this.sessionId,
    required this.sets,
  });
}

/// Exercise Detail Bottom Sheet with tabs: Details, Metrics, Records
class ExerciseDetailSheet extends StatefulWidget {
  final ExerciseDefinition definition;
  final int defId;

  const ExerciseDetailSheet({
    super.key,
    required this.definition,
    required this.defId,
  });

  @override
  State<ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<ExerciseDetailSheet> {
  late final AppRepository _repo;
  late Future<List<HistoryRecord>> _historyFuture;
  final Map<String, Future<List<RepMaxRow>>> _repMaxFutures = {};
  final Map<String, Future<double?>> _volumeMaxFutures = {};

  // Timeframe toggles
  final List<String> _timeframes = ['week', 'month', 'all'];
  late List<bool> _tfSelected;

  @override
  void initState() {
    super.initState();
    _repo = AppRepository();
    _tfSelected = [false, false, true]; // default to "all"
    unawaited(BodyHeatmap.preload());
    _historyFuture = _loadHistory();
  }

  @override
  void didUpdateWidget(covariant ExerciseDetailSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defId != widget.defId) {
      _repMaxFutures.clear();
      _volumeMaxFutures.clear();
      _historyFuture = _loadHistory();
    }
  }

  Future<List<RepMaxRow>> _repMaxFuture(String timeframe) {
    return _repMaxFutures.putIfAbsent(
      timeframe,
      () => _repo.fetchRepMaxes(widget.defId, timeframe),
    );
  }

  Future<double?> _volumeMaxFuture(String timeframe) {
    return _volumeMaxFutures.putIfAbsent(
      timeframe,
      () => _repo.fetchVolumeMax(widget.defId, timeframe),
    );
  }

  /// Load up to 10 recent weight-exercise records for this definition
  Future<List<HistoryRecord>> _loadHistory() async {
    final historyRows = await _repo.fetchRecentWeightExerciseHistoryRows(
      definitionId: widget.defId,
      limit: 10,
    );
    final exercises = await Future.wait(
      historyRows.map(
        (row) => _repo.fetchDetailedExercise(row['exercise_id'] as int),
      ),
    );

    final records = <HistoryRecord>[];
    for (var i = 0; i < historyRows.length; i++) {
      final exercise = exercises[i];
      if (exercise is! WeightExercise) continue;
      final row = historyRows[i];
      records.add(
        HistoryRecord(
          date: DateTime.parse(row['session_date'] as String),
          sessionId: row['session_id'] as int,
          sets: exercise.sets,
        ),
      );
    }
    return records;
  }

  Widget _buildDetailsTab(ScrollController scrollCtrl) {
    final def = widget.definition;
    final theme = Theme.of(context);
    final colors = context.colors;
    final heatmapFrequencyMap = bodyPartFrequencyMapFromNames({
      for (final bodyPart in def.bodyParts) bodyPart.name: 1.0,
    });

    return SingleChildScrollView(
      controller: scrollCtrl,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EQUIPMENT: ${def.equipmentList.map((e) => e.name).join(', ')}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 220,
              constraints: const BoxConstraints(maxWidth: 260),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child:
                  heatmapFrequencyMap.isEmpty
                      ? Icon(
                        Icons.accessibility_new,
                        size: 88,
                        color: theme.colorScheme.primary,
                      )
                      : BodyHeatmap(
                        frequencyMap: heatmapFrequencyMap,
                        lowColor: colors.historySummaryHeatmapLow!,
                        highColor: colors.historySummaryHeatmapHigh!,
                        width: 196,
                        height: 196,
                      ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'FOCUS AREA: ${def.bodyParts.map((b) => b.name).join(', ')}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'FOCUS MUSCLES: ${def.muscles.map((m) => m.muscle.name).join(', ')}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // --- Notes from the database ---
          const Text('SET-UP:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            def.setupNotes.isNotEmpty == true
                ? def.setupNotes
                : 'No setup instructions provided.',
          ),
          const SizedBox(height: 12),
          const Text(
            'EXECUTION:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            def.executionNotes.isNotEmpty == true
                ? def.executionNotes
                : 'No execution notes provided.',
          ),
          const SizedBox(height: 12),
          const Text('TIPS:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            def.tipsNotes.isNotEmpty == true
                ? def.tipsNotes
                : 'No additional tips.',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsTab(ScrollController scrollCtrl) {
    final idx = _tfSelected.indexWhere((sel) => sel);
    final timeframe = _timeframes[idx];
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;

    return Column(
      children: [
        const SizedBox(height: 12),
        ToggleButtons(
          isSelected: _tfSelected,
          onPressed:
              (i) => setState(() {
                _tfSelected = List.generate(_timeframes.length, (j) => j == i);
              }),
          children: const [Text('Week'), Text('Month'), Text('All‑time')],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: FutureBuilder<List<RepMaxRow>>(
            future: _repMaxFuture(timeframe),
            builder: (ctx, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return const Center(child: Text('Unable to load metrics.'));
              }
              final rows = snap.data ?? <RepMaxRow>[];
              if (rows.isEmpty) {
                return const Center(child: Text('No metrics available.'));
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    FutureBuilder<double?>(
                      future: _volumeMaxFuture(timeframe),
                      builder: (ctx2, snap2) {
                        final vm = snap2.data;
                        if (snap2.hasError) {
                          return const Text('Volume Max: --');
                        }
                        return Text(
                          'Volume Max: ${vm == null ? '--' : WeightUnitFormatter.formatVolume(vm, weightUnit)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Expanded(child: Text('Reps', maxLines: 1)),
                        Expanded(child: Text('1RM', maxLines: 1)),
                        Expanded(child: Text('Volume', maxLines: 1)),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: rows.length,
                        itemBuilder: (_, i) {
                          final r = rows[i];
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  r.repCount.toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  r.isErm
                                      ? '${WeightUnitFormatter.formatWeight(r.oneErm, weightUnit)} (ERM)'
                                      : WeightUnitFormatter.formatWeight(
                                        r.oneErm,
                                        weightUnit,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  WeightUnitFormatter.formatVolume(
                                    r.rmValue * r.repCount,
                                    weightUnit,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsTab(ScrollController scrollCtrl) {
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    return FutureBuilder<List<HistoryRecord>>(
      future: _historyFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return const Center(child: Text('Unable to load exercise history.'));
        }
        final history = snap.data ?? const <HistoryRecord>[];
        if (history.isEmpty) {
          return const Center(child: Text('No history for this exercise.'));
        }

        final records = _buildRecordTrendPoints(history);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: _ExerciseRecordTrendChart(
                points: records,
                weightUnit: weightUnit,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _RecordLegendDot(
                    color: Theme.of(context).colorScheme.primary,
                    label: 'Best weight',
                  ),
                  const SizedBox(width: 16),
                  _RecordLegendDot(
                    color: Colors.green.shade400,
                    label: 'Estimated 1RM',
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final rec = history[i];
                  final dateStr = DateFormat.yMMMd().add_jm().format(rec.date);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ...rec.sets.asMap().entries.map((entry) {
                        final j = entry.key;
                        final s = entry.value;
                        final oneErm = _estimatedOneRm(s);
                        return Row(
                          children: [
                            Text('${j + 1}. ${_formatSet(s, weightUnit)}'),
                            const Spacer(),
                            Text(
                              'ERM=${WeightUnitFormatter.formatWeight(oneErm, weightUnit)}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder:
          (_, scrollCtrl) => DefaultTabController(
            length: 3,
            child: Material(
              elevation: 12,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  // Header with Close Icon
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.definition.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  const TabBar(
                    tabs: [
                      Tab(text: 'Details'),
                      Tab(text: 'Metrics'),
                      Tab(text: 'Records'),
                    ],
                  ),
                  const Divider(height: 1),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildDetailsTab(scrollCtrl),
                        _buildMetricsTab(scrollCtrl),
                        _buildRecordsTab(scrollCtrl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

List<_ExerciseRecordPoint> _buildRecordTrendPoints(
  List<HistoryRecord> history,
) {
  final ordered = [...history]..sort((a, b) => a.date.compareTo(b.date));
  final points = <_ExerciseRecordPoint>[];
  for (final record in ordered) {
    if (record.sets.isEmpty) continue;
    final point = _ExerciseRecordPoint.from(record);
    if (point.bestWeight <= 0 && point.bestEstimatedOneRm <= 0) continue;
    points.add(point);
  }
  return points;
}

class _ExerciseRecordPoint {
  final DateTime date;
  final double bestWeight;
  final double bestEstimatedOneRm;
  final ExerciseSet bestSet;

  const _ExerciseRecordPoint({
    required this.date,
    required this.bestWeight,
    required this.bestEstimatedOneRm,
    required this.bestSet,
  });

  factory _ExerciseRecordPoint.from(HistoryRecord record) {
    var bestSet = record.sets.first;
    var bestEstimatedOneRm = _estimatedOneRm(bestSet);

    for (final set in record.sets.skip(1)) {
      final estimatedOneRm = _estimatedOneRm(set);
      if (estimatedOneRm > bestEstimatedOneRm) {
        bestSet = set;
        bestEstimatedOneRm = estimatedOneRm;
      }
    }

    final bestWeight = record.sets.fold<double>(
      0,
      (best, set) => set.weight > best ? set.weight : best,
    );

    return _ExerciseRecordPoint(
      date: record.date,
      bestWeight: bestWeight,
      bestEstimatedOneRm: bestEstimatedOneRm,
      bestSet: bestSet,
    );
  }
}

class _ExerciseRecordTrendChart extends StatelessWidget {
  final List<_ExerciseRecordPoint> points;
  final WeightUnit weightUnit;

  const _ExerciseRecordTrendChart({
    required this.points,
    required this.weightUnit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (points.isEmpty) {
      return Container(
        height: 188,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'No completed set records to chart yet.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final bounds = _recordChartBounds(points);
    final labelIndexes = _recordDateLabelIndexes(points.length);
    final showTimes = _shouldUseTimeLabels(points);
    final actualColor = scheme.primary;
    final estimatedColor = Colors.green.shade400;
    final hasBestWeight = points.any((point) => point.bestWeight > 0);
    final hasEstimatedOneRm = points.any(
      (point) => point.bestEstimatedOneRm > 0,
    );

    return Container(
      height: 214,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(1, points.length - 1).toDouble(),
          minY: bounds.minY,
          maxY: bounds.maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBorderRadius: BorderRadius.circular(10),
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              tooltipMargin: 8,
              maxContentWidth: 164,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor:
                  (_) => scheme.surfaceContainerHighest.withValues(alpha: 0.96),
              getTooltipItems: (touchedSpots) {
                if (touchedSpots.isEmpty) return const <LineTooltipItem?>[];
                final spot = touchedSpots.first;
                final index =
                    spot.x.round().clamp(0, points.length - 1).toInt();
                final point = points[index];
                final textStyle =
                    theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface,
                      fontSize: 9,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    ) ??
                    TextStyle(
                      color: scheme.onSurface,
                      fontSize: 9,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    );
                return [
                  LineTooltipItem(
                    '${DateFormat('MMM d, h:mm a').format(point.date)}\n'
                    'Wt ${WeightUnitFormatter.formatWeight(point.bestWeight, weightUnit)} | '
                    'Est ${WeightUnitFormatter.formatWeight(point.bestEstimatedOneRm, weightUnit)} | '
                    'Top ${_formatSet(point.bestSet, weightUnit)}',
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
            getDrawingHorizontalLine:
                (_) => FlLine(
                  color: scheme.outlineVariant.withValues(alpha: 0.42),
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
                interval: bounds.interval,
                reservedSize: 46,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    fitInside: SideTitleFitInsideData.fromTitleMeta(
                      meta,
                      distanceFromEdge: 2,
                    ),
                    child: Text(
                      _compactWeight(value, weightUnit),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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
                    child: Text(
                      _recordAxisLabel(points[index].date, showTimes),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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
                color: actualColor.withValues(alpha: 0.08),
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
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
      ),
    );
  }
}

class _RecordLegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _RecordLegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
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
  final values =
      [
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
  final days = {
    for (final point in points)
      DateUtils.dateOnly(point.date).toIso8601String(),
  };
  return days.length == 1;
}

String _recordAxisLabel(DateTime date, bool showTime) {
  return showTime
      ? DateFormat('h:mm a').format(date)
      : DateFormat.MMMd().format(date);
}

double _estimatedOneRm(ExerciseSet set) {
  if (set.reps <= 1) return set.weight;
  return set.weight * (1 + 0.0333 * set.reps);
}

String _formatSet(ExerciseSet set, WeightUnit weightUnit) {
  return '${WeightUnitFormatter.formatWeight(set.weight, weightUnit)} x ${set.reps}';
}

String _compactWeight(double value, WeightUnit weightUnit) {
  final displayValue = WeightUnitFormatter.fromPounds(value, weightUnit);
  if (displayValue.abs() >= 1000) {
    return '${(displayValue / 1000).toStringAsFixed(displayValue.abs() >= 10000 ? 0 : 1)}k';
  }
  return _cleanNumber(displayValue);
}

String _cleanNumber(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}
