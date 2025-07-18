// File: lib/screens/nutrition/specific_measurement_page.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../repositories/app_repository.dart';
import '../../models/models.dart';

/// Shows a historical chart and list for a single measurement definition.
class SpecificMeasurementPage extends StatefulWidget {
  final MeasurementDefinition definition;
  const SpecificMeasurementPage({super.key, required this.definition});

  @override
  State<SpecificMeasurementPage> createState() => _SpecificMeasurementPageState();
}

class _SpecificMeasurementPageState extends State<SpecificMeasurementPage> {
  // Changed these to match the internal switch/case logic exactly:
  static const timeOptions = ['All Records', 'Weekly', 'Monthly', 'Yearly'];
  String _timeFilter = timeOptions[0];

  // For Bodyweight, Height, or Body-Part sub-filter
  String _subFilter = 'Overall';
  late final Future<List<Measurement>> _measurementsFuture;
  final _repo = AppRepository();

  @override
  void initState() {
    super.initState();
    _measurementsFuture = _repo.fetchClassMeasurementsForDefinition(widget.definition.id);
  }


  /// If this is Height + "ft/in" view, convert inches→feet for y-axis.
  double _yValue(Measurement m) {
    if (widget.definition.name == 'Height' && _subFilter == 'ft/in') {
      return m.value / 12;
    }
    return m.value;
  }

  /// Turn the filtered list of measurements into a list of FlSpot(x,y).
  List<FlSpot> _computeSpots(List<Measurement> data) {
    if (data.isEmpty) return [];
    final last = data.last.timestamp;

    switch (_timeFilter) {
      case 'Weekly':
        // Show last 7 days; x = days since (today−6)
        final start = last.subtract(const Duration(days: 6));
        return data.map((m) {
          final dx = m.timestamp.difference(start).inDays.toDouble();
          return FlSpot(dx, _yValue(m));
        }).toList();

      case 'Monthly':
        // x = (day of month) − 1, so [0..30]
        return data.map((m) {
          final dx = (m.timestamp.day - 1).toDouble();
          return FlSpot(dx, _yValue(m));
        }).toList();

      case 'Yearly':
        // x = month index [1..12]
        return data.map((m) {
          return FlSpot(m.timestamp.month.toDouble(), _yValue(m));
        }).toList();

      default:
        // 'All Records': plot them in order 0..(n−1)
        return List.generate(
          data.length,
          (i) => FlSpot(i.toDouble(), _yValue(data[i])),
        );
    }
  }

  /// Build X-axis titles depending on timeFilter.
  AxisTitles _buildBottomTitles(
      List<Measurement> data, List<FlSpot> spots) {
    // If no data or "All Records", hide titles
    if (_timeFilter == 'All Records' || data.isEmpty || spots.isEmpty) {
      return AxisTitles(sideTitles: SideTitles(showTitles: false));
    }

    switch (_timeFilter) {
      case 'Weekly':
        // Show S M T W Th F S (last week’s weekdays)
        const labels = ['S', 'M', 'T', 'W', 'Th', 'F', 'S'];
        final lastWeekday = data.last.timestamp.weekday % 7;
        return AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, _) {
              // value = 0..6 position relative to start
              final idx = ((lastWeekday + value.toInt()) % 7).clamp(0, 6);
              return Text(labels[idx], style: const TextStyle(fontSize: 10));
            },
          ),
        );

      case 'Monthly':
        // Show roughly 5,10,15,20,25 on X
        return AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (data.length - 1) / 4,
            getTitlesWidget: (value, _) {
              const days = [5, 10, 15, 20, 25];
              final idx = value.toInt().clamp(0, 4);
              return Text(days[idx].toString(),
                  style: const TextStyle(fontSize: 10));
            },
            reservedSize: 28,
          ),
        );

      case 'Yearly':
        // Show first letter of each month
        const mLabels = [
          'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'
        ];
        return AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, _) {
              final month = value.toInt().clamp(1, 12);
              return Text(mLabels[month - 1],
                  style: const TextStyle(fontSize: 10));
            },
            reservedSize: 28,
          ),
        );

      default:
        return AxisTitles(sideTitles: SideTitles(showTitles: false));
    }
  }

  /// Return a filtered subset of 'all' based on time & subFilter.
  List<Measurement> _applyFilters(List<Measurement> all) {
    final base = (_timeFilter == 'All Records')
        ? all
        : all.where((m) {
            final last = all.last.timestamp;
            final earliest = (_timeFilter == 'Weekly')
                ? last.subtract(const Duration(days: 6))
                : (_timeFilter == 'Monthly')
                    ? DateTime(last.year, last.month, 1)
                    : DateTime(last.year - 1, last.month, last.day);
            return m.timestamp.isAfter(earliest);
          }).toList();

    // If Height, do not filter by note
    if (widget.definition.name == 'Height') return base;

    // Otherwise, either show all "Overall" or filter by note
    if (_subFilter == 'Overall') return base;
    return base.where((m) => m.note == _subFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.definition.name;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: FutureBuilder<List<Measurement>>(
        future: _measurementsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final all = snap.data!;
          var filtered = _applyFilters(all);
          filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          final spots = _computeSpots(filtered);
          final bottomTitles = _buildBottomTitles(filtered, spots);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ───── Time Filter Buttons ──────────────────────────────────────────
                Row(
                  children: timeOptions.map((f) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                _timeFilter == f ? Colors.deepPurple : null,
                            foregroundColor:
                                _timeFilter == f ? Colors.white : null,
                          ),
                          onPressed: () =>
                              setState(() => _timeFilter = f),
                          child: Text(f),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // ───── Sub-Filter Buttons ───────────────────────────────────────────
                Row(
                  children: (name == 'BodyWeight'
                          ? ['WakeUp', 'BedTime', 'Overall']
                          : name == 'Height'
                              ? ['ft/in', 'cm']
                              : ['Overall', 'With pump', 'Without pump'])
                      .map((s) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                _subFilter == s ? Colors.deepPurple : null,
                            foregroundColor:
                                _subFilter == s ? Colors.white : null,
                          ),
                          onPressed: () => setState(() => _subFilter = s),
                          child: Text(s),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // ───── Line Chart ───────────────────────────────────────────────────
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minX: spots.isEmpty ? 0 : spots.first.x,
                      maxX: spots.isEmpty ? 0 : spots.last.x,
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: bottomTitles,
                        leftTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => Colors.deepPurple,
                          getTooltipItems: (touchedSpots) => touchedSpots.map((ts) {
                            final m = filtered[ts.spotIndex];
                            final date =
                                m.timestamp.toLocal().toIso8601String().split('T').first;
                            final displayValue =
                                (name == 'Height' && _subFilter == 'ft/in')
                                    ? '${(m.value ~/ 12)}ft ${(m.value % 12).toInt()}in'
                                    : '${m.value.toStringAsFixed(1)} ${m.unit}';
                            return LineTooltipItem(
                              '$displayValue\n$date',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList(),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: false,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ───── Historical List ───────────────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final m = filtered[i];
                      final date =
                          m.timestamp.toLocal().toIso8601String().split('T').first;
                      final displayValue =
                          (name == 'Height' && _subFilter == 'ft/in')
                              ? '${(m.value ~/ 12)}ft ${(m.value % 12).toInt()}in'
                              : '${m.value.toStringAsFixed(1)} ${m.unit}';
                      return ListTile(
                        title: Text(displayValue),
                        subtitle:
                            Text('$date${m.note != null ? ' • ${m.note}' : ''}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // ───── “Add New Record” Button ─────────────────────────────────────────
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: open add new record dialog
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New Record'),
        ),
      ),
    );
  }
}
