// File: lib/screens/nutrition_page.dart

// ignore_for_file: unused_local_variable, unused_element_parameter

import 'package:flutter/material.dart';
import 'default_trend_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'log_entry_page.dart';
import '../../widgets/speed_dial_fab.dart';
import '../../widgets/nutrition_dash.dart';



class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: replace with repo call or provider for today's date & stats
    final today = DateTime.now();
    final caloriesConsumed = 1200; // TODO
    final calorieGoal = 2000;      // TODO

    // TODO: wire in your real daily goals later
final proteinTarget = 100; // grams
final carbTarget    = 200; // grams
final fatTarget     =  70; // grams


    // TODO: replace with real macro values
    final proteinGrams = 80;
    final carbGrams = 150;
    final fatGrams = 60;

    // TODO: fetch actual meal entries for today
    final meals = [
      {'name': 'Breakfast', 'cal': 400, 'time': '8:00 AM'},
      {'name': 'Lunch',     'cal': 500, 'time': '12:30 PM'},
      {'name': 'Snack',     'cal': 300, 'time': '3:30 PM'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Dashboard')),
      body: SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
          // 1️⃣ Daily summary: date + two-line numeric tally
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),

// ─── Daily summary: date + two-line numeric tally ─────────────────
NutritionDash(
  caloriesConsumed: caloriesConsumed,
  calorieGoal: calorieGoal,
  proteinConsumed: proteinGrams,
  proteinTarget: proteinTarget,
  carbConsumed: carbGrams,
  carbTarget: carbTarget,
  fatConsumed: fatGrams,
  fatTarget: fatTarget,
),




    ],
  ),
),






const Divider(height: 25),

// ─── Health Trends ───────────────────────────────────
Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  'Health Trends',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _HealthTrendTile(
  title: 'Expenditure',
  spots: const [
    FlSpot(0, 50), FlSpot(1, 60), FlSpot(2, 55),
    FlSpot(3, 70), FlSpot(4, 65), FlSpot(5, 80),
    FlSpot(6, 75),
  ], // TODO: replace with real 7-day spots
  value: '${calorieGoal - caloriesConsumed} kcal', // TODO: wire actual remaining or total
  onTap: () => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DefaultTrendPage(title: 'Calorie Expenditure'),
    ),
  ),
),

        const SizedBox(width: 8),
        _HealthTrendTile(
  title: 'Weight',
  spots: const [
    FlSpot(0, 210), FlSpot(1, 211), FlSpot(2, 211.5),
    FlSpot(3, 212), FlSpot(4, 211.8), FlSpot(5, 212.2),
    FlSpot(6, 211.9),
  ], // TODO: replace with real 7-day weight spots
  value: '211.9 lbs', // TODO: wire actual current weight
  onTap: () => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DefaultTrendPage(title: 'Bodyweight'),
    ),
  ),
),

        // TODO: add more _HealthTrendTile(...) entries for other metrics
      ],
    ),
  ),
),

// keep the meal‐list divider
const Divider(height: 32),


// ─── Data & Records ───────────────────────────────────
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section title
      Text(
        'Data & Records',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),

      // 28-day calendar (4 rows × 7 cols)
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 7,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 1,
    children: List.generate(28, (i) {
      final date = DateTime.now().subtract(Duration(days: 27 - i));
      return GestureDetector(
        onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LogEntryPage(date: date),
      ),
    );
  },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[400]!),
            // TODO: highlight today or selected date
          ),
          child: Text(
            '${date.day}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }),
  ),
),

      const SizedBox(height: 8),

      // Summary row (e.g. “1/7 this week”, “1 all time”)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '1/7 this week',               // TODO: wire real counts
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '1 all time',                  // TODO: wire real counts
            style: Theme.of(context).textTheme.bodySmall,
          ),
          GestureDetector(
            onTap: () {
              // TODO: open full calendar or records page
            },
            child: const Icon(Icons.chevron_right, size: 16),
          ),
        ],
      ),

      const Divider(height: 32),
    ],
  ),
),



          // ─── Current Metrics ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title & date
                Text(
                  'Current Metrics',  // TODO: make dynamic section name
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${today.month}/${today.day}', // TODO: wire in last-measured date
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),

                // Metric items row
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _MetricItem(
                      color: Colors.green,        // TODO: pick your palette
                      label: 'Visual Body Fat',
                      value: '26.0 %',
                    ),
                    const SizedBox(width: 16),
                    _MetricItem(
                      color: Colors.blue,
                      label: 'Waist',
                      value: '27 in',
                    ),
                    const SizedBox(width: 16),
                    _MetricItem(
                      color: Colors.purple,
                      label: 'Hips',
                      value: '36 in',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Footer row: “X days ago” + chevron
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0 days ago',  // TODO: compute days since last measurement
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: navigate to detailed metrics page
                      },
                      child: const Icon(Icons.chevron_right, size: 16),
                    ),
                  ],
                ),
                const Divider(height: 32),
              ],
            ),
          ),
       
        ],
      ),
      ),
      // 4️⃣ Add new meal
       floatingActionButton: const SpeedDialFab(),

    );
  }
}



/// A tappable box showing a mini trend line + value + chevron.
class _HealthTrendTile extends StatelessWidget {
  final String title;
  final List<FlSpot> spots;   // mini-chart data
  final String value;         // e.g. '3375 kcal'
  final VoidCallback onTap;

  const _HealthTrendTile({
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
            // ─── Mini Line Chart ───────────────
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
                  // TODO: set minY/maxY dynamically if you like
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ─── Title ──────────────────────────
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // ─── Value & Chevron ────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
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


/// A little tile showing one metric with a colored dot.
class _MetricItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _MetricItem({
    super.key,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // colored dot
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        // value
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 2),
        // label
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
