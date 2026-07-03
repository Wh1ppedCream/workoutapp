// lib/screens/measurements_trends_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/active_session.dart';
import '../services/tutorial_state_store.dart';
import '../widgets/exercise_progress_section.dart';
import '../widgets/guided_tutorial_overlay.dart';
import '../widgets/health_trends_section.dart';
import '../widgets/workout_metric_chart_card.dart';

class MeasurementsTrendsPage extends StatefulWidget {
  const MeasurementsTrendsPage({super.key});

  @override
  State<MeasurementsTrendsPage> createState() => _MeasurementsTrendsPageState();
}

class _MeasurementsTrendsPageState extends State<MeasurementsTrendsPage> {
  final _workoutReportTutorialKey = GlobalKey(
    debugLabel: 'progress_workout_report_tutorial',
  );
  final _exerciseProgressTutorialKey = GlobalKey(
    debugLabel: 'progress_exercise_progress_tutorial',
  );
  final _healthTrendsTutorialKey = GlobalKey(
    debugLabel: 'progress_health_trends_tutorial',
  );
  final _tutorialStore = const TutorialStateStore();

  int _refreshToken = 0;
  int? _seenCompletedSessionVersion;
  bool _progressTutorialQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueProgressTutorial();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TickerMode.of(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queueProgressTutorial();
      });
    }
  }

  Future<void> _refresh() async {
    setState(() => _refreshToken++);
  }

  void _queueProgressTutorial() {
    if (!mounted || _progressTutorialQueued || !TickerMode.of(context)) return;
    _progressTutorialQueued = true;
    unawaited(_showProgressTutorialIfNeeded());
  }

  Future<void> _showProgressTutorialIfNeeded() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 550));
      if (!mounted || !TickerMode.of(context)) return;

      final completed = await _tutorialStore.isCompleted(
        TutorialIds.progressHome,
      );
      if (completed || !mounted) return;

      await GuidedTutorialOverlay.show(
        context,
        steps: [
          GuidedTutorialStep(
            targetKey: _workoutReportTutorialKey,
            icon: Icons.show_chart_outlined,
            title: 'Workout report',
            body:
                'This tracks workout count, training time, and volume over different time ranges. Tap a metric to change what the graph shows.',
          ),
          GuidedTutorialStep(
            targetKey: _exerciseProgressTutorialKey,
            icon: Icons.trending_up,
            title: 'Exercise progress',
            body:
                'Track strength trends for selected exercises. Use the edit tile to add or remove exercises from this dashboard.',
          ),
          GuidedTutorialStep(
            targetKey: _healthTrendsTutorialKey,
            icon: Icons.monitor_heart_outlined,
            title: 'Health trends',
            body:
                'Log bodyweight and custom measurements here, then watch those measurements change over time.',
          ),
        ],
      );
      await _tutorialStore.markCompleted(TutorialIds.progressHome);
    } finally {
      _progressTutorialQueued = false;
    }
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
              KeyedSubtree(
                key: _workoutReportTutorialKey,
                child: WorkoutMetricChartCard(refreshToken: _refreshToken),
              ),
              KeyedSubtree(
                key: _exerciseProgressTutorialKey,
                child: ExerciseProgressSection(refreshToken: _refreshToken),
              ),
              KeyedSubtree(
                key: _healthTrendsTutorialKey,
                child: HealthTrendsSection(refreshToken: _refreshToken),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
