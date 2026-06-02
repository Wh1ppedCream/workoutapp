// lib/screens/measurements_trends_page.dart
import 'package:flutter/material.dart';

import '../widgets/exercise_progress_section.dart';
import '../widgets/health_trends_section.dart';
import '../widgets/workout_metric_chart_card.dart';

class MeasurementsTrendsPage extends StatefulWidget {
  const MeasurementsTrendsPage({super.key});

  @override
  State<MeasurementsTrendsPage> createState() => _MeasurementsTrendsPageState();
}

class _MeasurementsTrendsPageState extends State<MeasurementsTrendsPage> {
  int _refreshToken = 0;

  Future<void> _refresh() async {
    setState(() => _refreshToken++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 24),
            children: [
              WorkoutMetricChartCard(refreshToken: _refreshToken),
              const HealthTrendsSection(),
              ExerciseProgressSection(refreshToken: _refreshToken),
            ],
          ),
        ),
      ),
    );
  }
}
