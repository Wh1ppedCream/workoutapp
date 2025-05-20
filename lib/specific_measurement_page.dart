// File: lib/specific_measurement_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'db/database_helper.dart';
import 'models.dart';

class SpecificMeasurementPage extends StatefulWidget {
  final MeasurementDefinition definition;
  const SpecificMeasurementPage({Key? key, required this.definition})
      : super(key: key);

  @override
  _SpecificMeasurementPageState createState() =>
      _SpecificMeasurementPageState();
}

class _SpecificMeasurementPageState extends State<SpecificMeasurementPage> {
  // --- Filters ---
  String _timeFilter = 'All Records'; // All Records, Weekly, Monthly, Yearly
  String _subFilter = 'Overall'; // WakeUp/BedTime/Overall or ft/in/cm or Overall/With pump/Without pump

  late Future<List<Measurement>> _measurementsFuture;

  @override
  void initState() {
    super.initState();
    _measurementsFuture = _loadMeasurements();
  }

  Future<List<Measurement>> _loadMeasurements() async {
    final rows = await DatabaseHelper()
        .getMeasurementsForDefinition(widget.definition.id);
    return rows
        .map((r) => Measurement(
              id: r['id'] as int,
              defId: r['def_id'] as int,
              timestamp: DateTime.parse(r['timestamp'] as String),
              value: (r['value'] as num).toDouble(),
              unit: r['unit'] as String,
              note: r['note'] as String?,
            ))
        .toList();
  }

  // Determine earliest allowed date for time filtering
  DateTime get _earliestDate {
    final now = DateTime.now();
    switch (_timeFilter) {
      case 'Weekly':
        return now.subtract(const Duration(days: 7));
      case 'Monthly':
        return DateTime(now.year, now.month - 1, now.day);
      case 'Yearly':
        return DateTime(now.year - 1, now.month, now.day);
      default:
        return DateTime(1970);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.definition.name;
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: FutureBuilder<List<Measurement>>(
        future: _measurementsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());

          // 1) initial full list
          final all = snap.data ?? [];

          // 2) apply time filter
          final byTime = (_timeFilter == 'All Records')
              ? all
              : all.where((m) => m.timestamp.isAfter(_earliestDate)).toList();

          // 3) apply subtype filter
          final filtered = (name == 'Height')
              ? byTime
              : byTime.where((m) {
                  if (_subFilter == 'Overall') return true;
                  return m.note == _subFilter;
                }).toList();

          // 4) build chart spots
          filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          final spots = <FlSpot>[];
          for (var i = 0; i < filtered.length; i++) {
            spots.add(FlSpot(i.toDouble(), filtered[i].value));
          }

          // 5) axis titles builder
          AxisTitles bottomTitles() {
            switch (_timeFilter) {
              case 'Weekly':
                // 7 ticks: days of week ending at last record
                final labels = ['S','M','T','W','Th','F','S'];
                return AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt().clamp(0,6);
                      return Text(labels[idx]);
                    },
                  ),
                );
              case 'Monthly':
                // 5 ticks: 5,10,15,20,25
                return AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (filtered.length/5).clamp(1, double.infinity),
                    getTitlesWidget: (v, _) {
                      final d = ((filtered.first.timestamp.day) + 5*v)
                          .toInt().toString();
                      return Text(d);
                    },
                  ),
                );
              case 'Yearly':
                // 12 ticks: J F M A M J J A S O N D
                final labels = ['J','F','M','A','M','J','J','A','S','O','N','D'];
                return AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (filtered.length/12).clamp(1, double.infinity),
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt().clamp(0,11);
                      return Text(labels[idx]);
                    },
                  ),
                );
              default:
                // All Records: no bottom titles
                return AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                );
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Time filter buttons (equally sized)
Row(
  children: [
    for (var f in ['All Records', 'Weekly', 'Monthly', 'Yearly'])
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: _timeFilter == f ? Colors.deepPurple : null,
              foregroundColor: _timeFilter == f ? Colors.white : null,
            ),
            onPressed: () => setState(() => _timeFilter = f),
            child: Text(f),
          ),
        ),
      ),
  ],
),
const SizedBox(height: 16),

                // Subtype filter buttons (equally sized)
Row(
  children: [
    for (var s in (name == 'Bodyweight'
        ? ['WakeUp', 'BedTime', 'Overall']
        : name == 'Height'
            ? ['ft/in', 'cm']
            : ['Overall', 'With pump', 'Without pump']))
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: _subFilter == s ? Colors.deepPurple : null,
              foregroundColor: _subFilter == s ? Colors.white : null,
            ),
            onPressed: () => setState(() => _subFilter = s),
            child: Text(s),
          ),
        ),
      ),
  ],
),
const SizedBox(height: 16),


                // Chart
                SizedBox(
                  height: 200,
                  child: LineChart(LineChartData(
                    gridData: FlGridData(show: true),
                    lineBarsData: [
                      LineChartBarData(spots: spots, isCurved: false, dotData: FlDotData(show: true))
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: bottomTitles(),
                    ),
                  )),
                ),
                const SizedBox(height: 16),

                // History list
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final m = filtered[i];
                      return ListTile(
                        title: Text('${m.value.toStringAsFixed(1)} ${m.unit}'),
                        subtitle: Text(
                          '${m.timestamp.toLocal().toIso8601String().split('T').first}'
                          ' • ${m.note ?? ''}',
                        ),
                      );
                    },
                  ),
                ),

                // Add new record placeholder (we'll wire this next)
                ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Record'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
