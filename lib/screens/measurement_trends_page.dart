// lib/screens/measurements_trends_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/active_session.dart';
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
  int? _seenCompletedSessionVersion;

  Future<void> _refresh() async {
    setState(() => _refreshToken++);
  }

  @override
  Widget build(BuildContext context) {
    final completedSessionVersion = context.select<ActiveSession, int>(
      (session) => session.completedSessionVersion,
    );
    if (_seenCompletedSessionVersion == null) {
      _seenCompletedSessionVersion = completedSessionVersion;
    } else if (_seenCompletedSessionVersion != completedSessionVersion) {
      _seenCompletedSessionVersion = completedSessionVersion;
      _refreshToken++;
    }

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
              ExerciseProgressSection(refreshToken: _refreshToken),
              const HealthTrendsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
