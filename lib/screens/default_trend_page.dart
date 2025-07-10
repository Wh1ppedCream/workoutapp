// File: lib/screens/default_trend_page.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


/// A reusable “trend” page layout for things like bodyweight, calories burned, etc.
/// Displays a header with stats, a graph placeholder, timespan selector, insights,
/// a list of past measurements, and a button to add a new measurement.
class DefaultTrendPage extends StatefulWidget {
  final String title; // e.g. "Bodyweight", "Calories Burned"
  const DefaultTrendPage({
    super.key,
    required this.title,
  });

  @override
  State<DefaultTrendPage> createState() => _DefaultTrendPageState();
}

class _DefaultTrendPageState extends State<DefaultTrendPage> {
  // TODO: wire these to real data
  double averageValue = 0;
  double goalValue = 0;
  double currentValue = 0;

  // timespan options
  final spans = ['1W', '1M', '3M', '6M', '1Y', 'All'];
  String selectedSpan = '1W';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} Trend'),
      ),
      body: Column(
        children: [
          // ─── Header stats ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatColumn(label: 'Average', value: averageValue.toString()),
                _StatColumn(label: 'Goal',    value: goalValue.toString()),
                _StatColumn(label: 'Current', value: currentValue.toString()),
              ],
            ),
          ),

          // ─── Trend graph ────────────────────────────────────
SizedBox(
  height: 200,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: LineChart(
      LineChartData(
        // TODO: wire minX/maxX based on selectedSpan
        minX: 0,
        maxX: 6,
        // TODO: wire minY/maxY based on your data range
        minY: 0,
        maxY: 100,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            // TODO: replace these sample spots with your real measurements
            spots: const [
              FlSpot(0, 20),
              FlSpot(1, 40),
              FlSpot(2, 35),
              FlSpot(3, 60),
              FlSpot(4, 50),
              FlSpot(5, 80),
              FlSpot(6, 70),
            ],
            isCurved: true,
            barWidth: 2,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              // TODO: replace with .withValues() once you configure exact color
              color: Theme.of(context).primaryColor,  
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          // TODO: customize tooltip style here once API is confirmed
          touchTooltipData: LineTouchTooltipData(),
        ),
      ),
      // swapAnimationDuration & swapAnimationCurve were removed in v1.0.0;
      // TODO: re-add animations when you confirm the new API
    ),
  ),
),

          // ─── Timespan selector ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: spans.map((span) {
                  final isSelected = span == selectedSpan;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(span),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => selectedSpan = span);
                        // TODO: reload graph data for this timespan
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── Insights ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Insights', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  '• TODO: Show dynamic insights for ${widget.title}\n'
                  '• e.g. highest value this period, trend up/down, notes...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const Divider(),

          // ─── Past measurements ──────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: 5, // TODO: use real measurement count
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                // TODO: replace with actual Measurement model
                final placeholderDate = DateTime.now().subtract(Duration(days: i * 3));
                final placeholderValue = (100 + i * 5).toString();
                return Card(
                  child: ListTile(
                    title: Text(placeholderValue),
                    subtitle:
                        Text('${placeholderDate.month}/${placeholderDate.day}/${placeholderDate.year}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: open edit-measurement form
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ─── Add new measurement ─────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: open add-measurement dialog/form
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Reusable column for the header stats (label above, value below).
class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
