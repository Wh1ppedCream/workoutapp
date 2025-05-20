import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';  // add to pubspec
import 'db/database_helper.dart';
import 'models.dart';

class SpecificMeasurementPage extends StatelessWidget {
  final MeasurementDefinition definition;
  const SpecificMeasurementPage({Key? key, required this.definition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(definition.name)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getMeasurementsForDefinition(definition.id),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snap.data!;
          final measurements = rows.map((r) {
              // Safely cast note to nullable String
            final noteValue = r['note'] as String?;
            return Measurement(
              id: r['id'] as int,
              defId: r['def_id'] as int,
              timestamp: DateTime.parse(r['timestamp'] as String),
              value: (r['value'] as num).toDouble(),
              unit: r['unit'] as String,
              note: noteValue,                  
            );
}).toList().reversed.toList();
;

          // Chart data
          final spots = measurements.asMap().entries.map((e) =>
            FlSpot(e.key.toDouble(), e.value.value)
          ).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Graph (line chart)
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(spots: spots, isCurved: false),
                      ],
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Past measurements list
                Expanded(
                  child: ListView(
                    children: measurements.map((m) => ListTile(
                      title: Text('${m.value} ${m.unit}'),
                      subtitle: Text(
                        '${m.timestamp.toLocal().toIso8601String().split("T").first}'
                        '${m.note!=null ? " - ${m.note}" : ""}'
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
