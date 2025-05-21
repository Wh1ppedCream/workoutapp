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
  String _timeFilter = 'All'; // All, Week, Month, Year
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

    /// Compute chart X/Y points based on current timeFilter
  List<FlSpot> _computeSpots(List<Measurement> filtered) {
    if (filtered.isEmpty) return [];
    switch (_timeFilter) {
      case 'Weekly':
        final last = filtered.last.timestamp;
        final start = last.subtract(const Duration(days: 6));
        return filtered.map((m) {
          final dx = m.timestamp.difference(start).inDays.toDouble();
          return FlSpot(dx, m.value);
        }).toList();

      case 'Monthly':
        return filtered.map((m) {
          // map day 1→0, day 20→19, etc.
          final dx = (m.timestamp.day - 1).toDouble();
          return FlSpot(dx, m.value);
        }).toList();

      case 'Yearly':
        return filtered.map((m) {
          // month 1→1.0, ... 12→12.0
          return FlSpot(m.timestamp.month.toDouble(), m.value);
        }).toList();

      default:
        return List.generate(
          filtered.length,
          (i) => FlSpot(i.toDouble(), filtered[i].value),
        );
    }
  }

    /// Build bottom-axis labels exactly as “Weekly/Monthly/Yearly” spec’d
  AxisTitles bottomTitles() {
    switch (_timeFilter) {
      case 'Weekly':
        const labels = ['S','M','T','W','Th','F','S'];
        return AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, _) {
              final i = value.toInt().clamp(0,6);
              return Text(labels[i], style: const TextStyle(fontSize: 10));
            },
          ),
        );
      case 'Monthly':
        return AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            getTitlesWidget: (value, _) {
              final v = value.toInt();
              if (v % 5 != 0 || v < 0 || v > 30) return const SizedBox();
              return Text(v.toString(), style: const TextStyle(fontSize: 10));
            },
            reservedSize: 28,
          ),
        );
      case 'Yearly':
        return AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, _) {
              final m = value.toInt();
              if (m < 1 || m > 12) return const SizedBox();
              return Text(m.toString(), style: const TextStyle(fontSize: 10));
            },
            reservedSize: 28,
          ),
        );
      default:
        return AxisTitles(sideTitles: SideTitles(showTitles: false));
    }
  }



  // Determine earliest allowed date for time filtering
  DateTime get _earliestDate {
    final now = DateTime.now();
    switch (_timeFilter) {
      case 'Week':
        return now.subtract(const Duration(days: 7));
      case 'Month':
        return DateTime(now.year, now.month - 1, now.day);
      case 'Year':
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
          final byTime = (_timeFilter == 'All')
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
    case 'Week':
      // 7 ticks: days of week ending on last record’s weekday.
      final lastWeekday = filtered.last.timestamp.weekday; // 1=Mon…7=Sun
      const labels = ['S','M','T','W','Th','F','S'];
      return AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) {
            // value runs from 0..6; map to weekday index relative to last
            final idx = ((lastWeekday % 7) + value.toInt()) % 7;
            return Text(labels[idx], style: const TextStyle(fontSize: 10));
          },
        ),
      );

    case 'Month':
      // 5 ticks: days 5,10,15,20,25 of that month
      return AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: (filtered.length - 1) / 4,
          getTitlesWidget: (value, meta) {
            // Map positions 0..4 to the day labels
            const days = [5, 10, 15, 20, 25];
            final idx = value.toInt().clamp(0, 4);
            return Text(days[idx].toString(), style: const TextStyle(fontSize: 10));
          },
        ),
      );

    case 'Year':
      // 12 ticks: months J F M A M J J A S O N D
      const mLabels = ['J','F','M','A','M','J','J','A','S','O','N','D'];
      return AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: (filtered.length - 1) / 11,
          getTitlesWidget: (value, meta) {
            final idx = value.toInt().clamp(0, 11);
            return Text(mLabels[idx], style: const TextStyle(fontSize: 10));
          },
        ),
      );

    default:
      // All Records: no tick labels
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
    for (var f in ['All', 'Week', 'Month', 'Year'])
      Expanded(
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
      ),
  ],
),
const SizedBox(height: 16),


                // Chart
                SizedBox(
  height: 200,
  child: LineChart(
    LineChartData(
      minX: _timeFilter == 'Weekly'
          ? 0
          : _timeFilter == 'Monthly'
              ? 0
              : _timeFilter == 'Yearly'
                  ? 1
                  : 0,
      maxX: _timeFilter == 'Weekly'
          ? 6
          : _timeFilter == 'Monthly'
              ? 30
              : _timeFilter == 'Yearly'
                  ? 12
                  : (_computeSpots(filtered).length - 1).toDouble(),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: bottomTitles(),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: _computeSpots(filtered),
          isCurved: false,
          dotData: FlDotData(show: true),
        ),
      ],
    ),
  ),
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
