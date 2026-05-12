import 'package:flutter/material.dart';
import '../models/models.dart';
import '../screens/exercise/exercise_catalog_page.dart';
import '../screens/exercise/muscle_filter_page.dart';
import '../screens/exercise/session_detail_screen.dart';
import '../widgets/history_summary_widget.dart';
import '../screens/exercise/analytics_dashboard_screen.dart';
import '../widgets/past_sessions_list.dart';
import '../widgets/workout_history_calendar.dart';
import '../widgets/workout_metric_chart_card.dart';

/// Shared history content used by both TrainPage and HistoryScreen.
class HistoryContent extends StatefulWidget {
  /// Callback to reload the past sessions list.
  final VoidCallback onReload;
  final int refreshToken;

  const HistoryContent({
    super.key,
    required this.onReload,
    this.refreshToken = 0,
  });

  @override
  State<HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends State<HistoryContent> {
  int _localRefreshToken = 0;

  void _handleReload() {
    if (!mounted) return;
    setState(() => _localRefreshToken++);
    widget.onReload();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRefreshToken = widget.refreshToken + _localRefreshToken;

    void openReportSession(WorkoutReportSession reportSession) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder:
                  (_) => SessionDetailScreen(
                    WorkoutSession(
                      id: reportSession.id,
                      date: reportSession.date,
                      duration: reportSession.durationSeconds,
                    ),
                  ),
            ),
          )
          .then((_) => _handleReload());
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Filter navigation buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ExerciseCatalogPage(),
                      ),
                    ),
                child: const Text('Exercises'),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MuscleFilterPage(),
                      ),
                    ),
                child: const Text('Muscle'),
              ),
            ],
          ),
        ),

        WorkoutMetricChartCard(refreshToken: effectiveRefreshToken),

        WorkoutHistoryCalendar(
          refreshToken: effectiveRefreshToken,
          onSessionTap: openReportSession,
        ),

        // 7-day summary panel
        HistorySummaryWidget(refreshToken: effectiveRefreshToken),

        // Analytics dashboard button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.analytics),
            label: const Text('View 7-Day Analytics'),
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AnalyticsDashboardScreen(),
                  ),
                ),
          ),
        ),

        // Past sessions list
        PastSessionsList(
          onReload: _handleReload,
          refreshToken: effectiveRefreshToken,
        ),
      ],
    );
  }
}
