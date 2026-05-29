import 'package:flutter/material.dart';
import '../models/models.dart';
import '../screens/exercise/full_history_screen.dart';
import '../screens/exercise/session_detail_screen.dart';
import '../widgets/history_summary_widget.dart';
import '../widgets/past_sessions_list.dart';
import '../widgets/workout_history_calendar.dart';

/// Shared history content used by both Train2Page and HistoryScreen.
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

    void openFullHistory() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const FullHistoryScreen()))
          .then((_) => _handleReload());
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        WorkoutHistoryCalendar(
          refreshToken: effectiveRefreshToken,
          onSessionTap: openReportSession,
          onOpenFullHistory: openFullHistory,
        ),

        // 7-day summary panel
        HistorySummaryWidget(refreshToken: effectiveRefreshToken),

        // Past sessions list
        PastSessionsList(
          onReload: _handleReload,
          refreshToken: effectiveRefreshToken,
        ),
      ],
    );
  }
}
