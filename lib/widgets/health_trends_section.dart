// File: lib/widgets/health_trends_section.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../screens/nutrition/default_trend_page.dart';

/// A tappable box showing a mini trend line + value + chevron.
class HealthTrendTile extends StatelessWidget {
  final String title;
  final List<FlSpot> spots;
  final String value;
  final VoidCallback onTap;

  const HealthTrendTile({
    super.key,
    required this.title,
    required this.spots,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 40,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                  minX: spots.first.x,
                  maxX: spots.last.x,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps a horizontal scroll of multiple HealthTrendTile widgets.
class HealthTrendsSection extends StatelessWidget {
  final int caloriesConsumed;
  final int calorieGoal;
  final List<FlSpot> expenditureSpots;
  final String weightValue;
  final List<FlSpot> weightSpots;

  const HealthTrendsSection({
    super.key,
    required this.caloriesConsumed,
    required this.calorieGoal,
    required this.expenditureSpots,
    required this.weightValue,
    required this.weightSpots,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text('Health Trends', style: Theme.of(context).textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                HealthTrendTile(
                  title: 'Expenditure',
                  spots: expenditureSpots,
                  value: '${calorieGoal - caloriesConsumed} kcal',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DefaultTrendPage(title: 'Calorie Expenditure')),
                  ),
                ),
                HealthTrendTile(
                  title: 'Weight',
                  spots: weightSpots,
                  value: weightValue,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DefaultTrendPage(title: 'Bodyweight')),
                  ),
                ),
                // …add any others here…
              ],
            ),
          ),
        ),
        const Divider(height: 32),
      ],
    );
  }
}
