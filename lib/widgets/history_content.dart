import 'package:material_ui/material_ui.dart';

import '../models/models.dart';
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../theme/widgets/app_expressive_destination_theme.dart';
import '../screens/exercise/full_history_screen.dart';
import '../screens/exercise/session_detail_screen.dart';
import '../widgets/workout_history_calendar.dart';

/// Shared history content used by both Train2Page and HistoryScreen.
class HistoryContent extends StatefulWidget {
  /// Callback to reload history data after viewing or editing a session.
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
    final destinationFamily = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>()
        ?.family;

    Widget scopeDestination(Widget child) {
      final family = destinationFamily;
      if (family == null) return child;
      return AppExpressiveDestinationTheme(family: family, child: child);
    }

    void openReportSession(WorkoutReportSession reportSession) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => scopeDestination(
                SessionDetailScreen(
                  WorkoutSession(
                    id: reportSession.id,
                    date: reportSession.date,
                    calendarDayKey: reportSession.calendarDayKey,
                    duration: reportSession.durationSeconds,
                  ),
                ),
              ),
            ),
          )
          .then((_) => _handleReload());
    }

    void openFullHistory() {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => scopeDestination(const FullHistoryScreen()),
            ),
          )
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
      ],
    );
  }
}
