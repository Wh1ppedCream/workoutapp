import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'db/database_helper.dart';
import 'models.dart';

/// Shows a historical chart and list for a single measurement definition.
class SpecificMeasurementPage extends StatefulWidget {
  final MeasurementDefinition definition;
  const SpecificMeasurementPage({super.key, required this.definition});

  @override
  State<SpecificMeasurementPage> createState() => _SpecificMeasurementPageState();
}

class _SpecificMeasurementPageState extends State<SpecificMeasurementPage> {
  static const timeOptions = ['All', 'Week', 'Month', 'Year'];
  String _timeFilter = timeOptions[0];
  String _subFilter = 'Overall';
  late final Future<List<Measurement>> _measurementsFuture;

  @override
  void initState() {
    super.initState();
    _measurementsFuture = _loadMeasurements();
  }

  Future<List<Measurement>> _loadMeasurements() async {
    final rows = await DatabaseHelper().getMeasurementsForDefinition(widget.definition.id);
    return rows.map((r) => Measurement(
          id: r['id'] as int,
          defId: r['def_id'] as int,
          timestamp: DateTime.parse(r['timestamp'] as String),
          value: (r['value'] as num).toDouble(),
          unit: r['unit'] as String,
          note: r['note'] as String?,
        )).toList();
  }

  double _yValue(Measurement m) {
    if (widget.definition.name == 'Height' && _subFilter == 'ft/in') {
      return m.value / 12;
    }
    return m.value;
  }

  List<FlSpot> _computeSpots(List<Measurement> data) {
    if (data.isEmpty) return [];
    final last = data.last.timestamp;
    switch (_timeFilter) {
      case 'Weekly':
        final start = last.subtract(const Duration(days: 6));
        return data.map((m) {
          final dx = m.timestamp.difference(start).inDays.toDouble();
          return FlSpot(dx, _yValue(m));
        }).toList();
      case 'Monthly':
        return data.map((m) {
          final dx = (m.timestamp.day - 1).toDouble();
          return FlSpot(dx, _yValue(m));
        }).toList();
      case 'Yearly':
        return data.map((m) {
          return FlSpot(m.timestamp.month.toDouble(), _yValue(m));
        }).toList();
      default:
        return List.generate(
          data.length,
          (i) => FlSpot(i.toDouble(), _yValue(data[i])),
        );
    }
  }

  AxisTitles _buildBottomTitles(List<Measurement> data, List<FlSpot> spots) {
    if (_timeFilter == 'All Records' || data.isEmpty || spots.isEmpty) {
      return AxisTitles(sideTitles: SideTitles(showTitles: false));
    }
    switch (_timeFilter) {
      case 'Weekly':
        const labels = ['S','M','T','W','Th','F','S'];
        final lastWeekday = data.last.timestamp.weekday % 7;
        return AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, _) {
              final idx = ((lastWeekday + value.toInt()) % 7).clamp(0,6);
              return Text(labels[idx], style: const TextStyle(fontSize: 10));
            },
          ),
        );
      case 'Monthly':
        return AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (data.length - 1) / 4,
            getTitlesWidget: (value, _) {
              const days = [5,10,15,20,25];
              final idx = value.toInt().clamp(0,4);
              return Text(days[idx].toString(), style: const TextStyle(fontSize: 10));
            },
            reservedSize: 28,
          ),
        );
      case 'Yearly':
        const mLabels = ['J','F','M','A','M','J','J','A','S','O','N','D'];
        return AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, _) {
              final idx = value.toInt().clamp(1,12) - 1;
              return Text(mLabels[idx], style: const TextStyle(fontSize: 10));
            },
            reservedSize: 28,
          ),
        );
      default:
        return AxisTitles(sideTitles: SideTitles(showTitles: false));
    }
  }

  List<Measurement> _applyFilters(List<Measurement> all) {
    final base = (_timeFilter == 'All Records')
        ? all
        : all.where((m) {
            final last = all.last.timestamp;
            final earliest =
                _timeFilter == 'Weekly'
                    ? last.subtract(const Duration(days: 6))
                    : _timeFilter == 'Monthly'
                        ? DateTime(last.year, last.month, 1)
                        : DateTime(last.year - 1, last.month, last.day);
            return m.timestamp.isAfter(earliest);
          }).toList();
    if (widget.definition.name == 'Height') return base;
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
            return Center(child: Text('Error: \${snap.error}'));
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
                Row(
                  children: timeOptions.map((f) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _timeFilter == f ? Colors.deepPurple : null,
                            foregroundColor: _timeFilter == f ? Colors.white : null,
                          ),
                          onPressed: () => setState(() => _timeFilter = f),
                          child: Text(f),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: (name == 'Bodyweight'
                          ? ['WakeUp','BedTime','Overall']
                          : name == 'Height'
                              ? ['ft/in','cm']
                              : ['Overall','With pump','Without pump'])
                      .map((s) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _subFilter == s ? Colors.deepPurple : null,
                            foregroundColor: _subFilter == s ? Colors.white : null,
                          ),
                          onPressed: () => setState(() => _subFilter = s),
                          child: Text(s),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
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
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineTouchData: LineTouchData(
  touchTooltipData: LineTouchTooltipData(
    getTooltipColor: (touchedSpot) => Colors.deepPurple, // Correct way to set the background color
    getTooltipItems: (touchedSpots) => touchedSpots.map((ts) {
      final m = filtered[ts.spotIndex];
      final date = m.timestamp.toLocal().toIso8601String().split('T').first;
      final displayValue = (name == 'Height' && _subFilter == 'ft/in')
          ? '${(m.value ~/ 12)}ft ${(m.value % 12).toInt()}in'
          : '${m.value.toStringAsFixed(1)} ${m.unit}';
      return LineTooltipItem('$displayValue\n$date', const TextStyle(color: Colors.white));
    }).toList(),
  ),
),

                      lineBarsData: [
                        LineChartBarData(spots: spots, isCurved: false, dotData: FlDotData(show: true)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final m = filtered[i];
                      final date = m.timestamp.toLocal().toIso8601String().split('T').first;
                      final displayValue = (name == 'Height' && _subFilter == 'ft/in')
                          ? '${(m.value~/12)}ft ${(m.value%12).toInt()}in'
                          : '${m.value.toStringAsFixed(1)} ${m.unit}';
                      return ListTile(
                        title: Text(displayValue),
                        subtitle: Text('$date${m.note != null ? ' • ${m.note}' : ''}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
