// File: lib/widgets/health_trends_section.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../screens/nutrition/default_trend_page.dart';

import '../theme/theme_extensions.dart';

/// Minimal data-holder for one trend tile.
class TrendData {
  String title;
  List<FlSpot> spots;
  String value;

  TrendData({required this.title, required this.spots, required this.value});
}

/// A horizontal scroll of mini‐trend cards, plus an “+” to add more.
class HealthTrendsSection extends StatefulWidget {
  const HealthTrendsSection({super.key});

  @override
  HealthTrendsSectionState createState() => HealthTrendsSectionState();
}

class HealthTrendsSectionState extends State<HealthTrendsSection>
    with AutomaticKeepAliveClientMixin<HealthTrendsSection> {
  // start with your two demo tiles
  final List<TrendData> _tiles = [
    TrendData(
      title: 'Expenditure',
      spots: const [
        FlSpot(0, 50),
        FlSpot(1, 60),
        FlSpot(2, 55),
        FlSpot(3, 70),
        FlSpot(4, 65),
        FlSpot(5, 80),
        FlSpot(6, 75),
      ],
      value: '${2000 - 1200} kcal', // demo remaining
    ),
    TrendData(
      title: 'Weight',
      spots: const [
        FlSpot(0, 210),
        FlSpot(1, 211),
        FlSpot(2, 211.5),
        FlSpot(3, 212),
        FlSpot(4, 211.8),
        FlSpot(5, 212.2),
        FlSpot(6, 211.9),
      ],
      value: '211.9 lbs',
    ),
  ];

  void _addBlankTile() {
    setState(() {
      _tiles.insert(
        _tiles.length,
        TrendData(
          title: 'New',
          spots: const [
            FlSpot(0, 50),
            FlSpot(1, 70),
            FlSpot(2, 30),
            FlSpot(3, 40),
            FlSpot(4, 35),
            FlSpot(5, 90),
            FlSpot(6, 75),
          ], // blank data
          value: '420 cm',
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Health Trends',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        // scrollable row of tiles + add-button
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _tiles.length + 1, // +1 for the "+" tile
            itemBuilder: (ctx, i) {
              if (i < _tiles.length) {
                final t = _tiles[i];
                return _TrendTile(
                  title: t.title,
                  spots: t.spots,
                  value: t.value,
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DefaultTrendPage(title: t.title),
                        ),
                      ),
                );
              } else {
                // the "+" button
                return GestureDetector(
                  onTap: _addBlankTile,
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.healthTrendBorder!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 32,
                        color: colors.healthTrendIcon!,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _TrendTile extends StatelessWidget {
  final String title;
  final List<FlSpot> spots;
  final String value;
  final VoidCallback onTap;

  const _TrendTile({
    required this.title,
    required this.spots,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: colors.healthTrendBorder!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 50,
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
                      color: colors.healthTrendLine!,
                    ),
                  ],
                  minX: spots.first.x,
                  maxX: spots.last.x,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: colors.healthTrendIcon!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
