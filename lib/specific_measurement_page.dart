// File: lib/specific_measurement_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'db/database_helper.dart';
import 'models.dart';

class SpecificMeasurementPage extends StatefulWidget {
  final MeasurementDefinition definition;
  const SpecificMeasurementPage({Key? key, required this.definition}) : super(key: key);

  @override
  _SpecificMeasurementPageState createState() => _SpecificMeasurementPageState();
}

class _SpecificMeasurementPageState extends State<SpecificMeasurementPage> {
  // Top filters
  String _timeFilter = 'All'; // All, Weekly, Monthly, Yearly
  String _subFilter = 'Overall'; // Subtype filter

  late Future<List<Measurement>> _measurementsFuture;

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

  @override
  Widget build(BuildContext context) {
    final type = widget.definition.type;
    return Scaffold(
      appBar: AppBar(title: Text(widget.definition.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time filter
            ToggleButtons(
              isSelected: ['All', 'Weekly', 'Monthly', 'Yearly']
                  .map((f) => f == _timeFilter)
                  .toList(),
              onPressed: (i) => setState(() => _timeFilter = ['All', 'Weekly', 'Monthly', 'Yearly'][i]),
              children: const [Text('All Records'), Text('Weekly'), Text('Monthly'), Text('Yearly')],
            ),
            const SizedBox(height: 16),
            // Sub filter
            // Use name to distinguish Bodyweight vs Height vs body parts
            if (widget.definition.name == 'Bodyweight')
              ToggleButtons(
                isSelected: ['WakeUp', 'BedTime', 'Overall']
                    .map((f) => f == _subFilter)
                    .toList(),
                onPressed: (i) => setState(() => _subFilter = ['WakeUp', 'BedTime', 'Overall'][i]),
                children: const [Text('WakeUp'), Text('BedTime'), Text('Overall')],
              )
            else if (widget.definition.name == 'Height')
              ToggleButtons(
                isSelected: ['ft/in', 'cm']
                    .map((f) => f == _subFilter)
                    .toList(),
                onPressed: (i) => setState(() => _subFilter = ['ft/in', 'cm'][i]),
                children: const [Text('ft/in'), Text('cm')],
              )
            else
              ToggleButtons(
                isSelected: ['Overall', 'With pump', 'Without pump']
                    .map((f) => f == _subFilter)
                    .toList(),
                onPressed: (i) => setState(() => _subFilter = ['Overall', 'With pump', 'Without pump'][i]),
                children: const [Text('Overall'), Text('With pump'), Text('Without pump')],
              ),
            const SizedBox(height: 16),
            // Graph placeholder
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(spots: const [], isCurved: false),
                  ],
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // History list
            Expanded(
              child: FutureBuilder<List<Measurement>>(
                future: _measurementsFuture,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snap.data ?? [];
                  // filter by subtype
                  final filtered = _subFilter == 'All' || _subFilter == 'All Records'
                      ? all
                      : all.where((m) => (m.note ?? 'Overall') == _subFilter).toList();
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final m = filtered[i];
                      return ListTile(
                        title: Text('${m.value} ${m.unit}'),
                        subtitle: Text(
                          '${m.timestamp.toLocal().toIso8601String().split("T").first} - ${m.note ?? ''}',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Add new record button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: navigate to add screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Record'),
            ),
          ],
        ),
      ),
    );
  }
}
