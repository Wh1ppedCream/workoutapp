// File: lib/widgets/exercise_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // for date formatting
import '../models/models.dart';
import '../repositories/app_repository.dart';

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

  const ExerciseDetailSheet({super.key, required this.definition, required this.defId});

  @override
  State<ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<ExerciseDetailSheet> {
  late final AppRepository _repo;
  late final Future<List<HistoryRecord>> _historyFuture;

  // Timeframe toggles
  final List<String> _timeframes = ['week', 'month', 'all'];
  late List<bool> _tfSelected;

  @override
  void initState() {
    super.initState();
    _repo = AppRepository();
    _tfSelected = [false, false, true]; // default to "all"
    _historyFuture = _loadHistory();
  }

  /// Load up to 10 recent weight-exercise records for this definition
  Future<List<HistoryRecord>> _loadHistory() async {
    final sessions = await _repo.fetchWorkoutSessions(); // newest first
    final records = <HistoryRecord>[];

    for (var session in sessions) {
      final exRows = await _repo.fetchExercises(session.id);
      for (var exRow in exRows) {
        if (exRow['type'] == 'weight' && exRow['exercise_def_id'] == widget.defId) {
          final we = await _repo.fetchDetailedExercise(exRow['id'] as int);
          if (we is WeightExercise) {
            records.add(HistoryRecord(
              date: session.date,
              sessionId: session.id,
              sets: we.sets,
            ));
          }
        }
      }
      if (records.length >= 10) break;
    }

    return records;
  }

  Widget _buildDetailsTab(ScrollController scrollCtrl) {
    final def = widget.definition;
    return SingleChildScrollView(
      controller: scrollCtrl,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(def.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text('EQUIPMENT: ${def.equipmentList.map((e) => e.name).join(', ')}'),
          const SizedBox(height: 8),
          Text('FOCUS AREA: ${def.bodyParts.map((b) => b.name).join(', ')}'),
          const SizedBox(height: 8),
          Text('FOCUS MUSCLES: ${def.muscles.map((m) => m.muscle.name).join(', ')}'),
          const SizedBox(height: 16),
          const Text('EXAMPLE: to be added', style: TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          const Text('SET‑UP: to be added', style: TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          const Text('EXECUTION: to be added', style: TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          const Text('TIPS: to be added', style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildMetricsTab(ScrollController scrollCtrl) {
    final idx = _tfSelected.indexWhere((sel) => sel);
    final timeframe = _timeframes[idx];

    return Column(
      children: [
        const SizedBox(height: 12),
        ToggleButtons(
          isSelected: _tfSelected,
          onPressed: (i) => setState(() {
            _tfSelected = List.generate(_timeframes.length, (j) => j == i);
          }),
          children: const [Text('Week'), Text('Month'), Text('All‑time')],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: FutureBuilder<List<RepMaxRow>>(
            future: _repo.fetchRepMaxes(widget.defId, timeframe),
            builder: (ctx, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
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
                      future: _repo.fetchVolumeMax(widget.defId, timeframe),
                      builder: (ctx2, snap2) {
                        final vm = snap2.data;
                        return Text('Volume Max: ${vm?.toStringAsFixed(1) ?? '--'} lbs');
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Expanded(child: Text('Reps')),
                        Expanded(child: Text('1RM')),
                        Expanded(child: Text('Volume'))
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
                              Expanded(child: Text(r.repCount.toString())),
                              Expanded(
                                  child: Text(r.isErm
                                      ? '${r.oneErm.toStringAsFixed(1)} (ERM)'
                                      : r.rmValue.toStringAsFixed(1))),
                              Expanded(child: Text((r.rmValue * r.repCount).toStringAsFixed(1))),
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
    return FutureBuilder<List<HistoryRecord>>(
      future: _historyFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final history = snap.data!;
        if (history.isEmpty) {
          return const Center(child: Text('No history for this exercise.'));
        }

        final dateFmt = DateFormat('MM/dd');
        final barGroups = <BarChartGroupData>[];
        for (var i = 0; i < history.length; i++) {
          final rec = history[i];
          final bestErm = rec.sets
              .map((s) => s.weight * (1 + 0.0333 * s.reps))
              .fold<double>(0, (a, b) => b > a ? b : a);
          final totalVm = rec.sets
              .map((s) => s.weight * s.reps)
              .fold<double>(0, (a, b) => a + b);

          barGroups.add(
            BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: bestErm,
                  width: 8,
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.blueAccent,
                ),
                BarChartRodData(
                  toY: totalVm,
                  width: 8,
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.green,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: history
                      .map((rec) => rec.sets
                          .map((s) => s.weight * (1 + 0.0333 * s.reps))
                          .fold<double>(0, (a, b) => b > a ? b : a))
                      .fold<double>(0, (a, b) => b > a ? b : a)
                      .ceilToDouble() *
                      1.2,
                  barGroups: barGroups,
                  groupsSpace: 16,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= history.length) {
                            return const SizedBox();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              dateFmt.format(history[idx].date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
                duration: const Duration(milliseconds: 150),
                curve: Curves.linear,
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
                  final dateStr = DateFormat('MMM dd, yyyy').format(rec.date);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...rec.sets.asMap().entries.map((entry) {
                        final j = entry.key;
                        final s = entry.value;
                        final oneErm = s.weight * (1 + 0.0333 * s.reps);
                        return Row(
                          children: [
                            Text('${j + 1}. ${s.weight.toInt()} lbs × ${s.reps}'),
                            const Spacer(),
                            Text(
                              'ERM=${oneErm.toStringAsFixed(1)}',
                              style: const TextStyle(fontStyle: FontStyle.italic),
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
      builder: (_, scrollCtrl) => DefaultTabController(
        length: 3,
        child: Material(
          elevation: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                    Text('Exercise Detail', style: Theme.of(context).textTheme.titleLarge),
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
