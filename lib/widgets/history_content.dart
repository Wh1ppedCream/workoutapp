import 'package:flutter/material.dart';
import '../screens/exercise/exercise_catalog_page.dart';
import '../screens/exercise/muscle_filter_page.dart';
import '../widgets/history_summary_widget.dart';
import '../screens/exercise/analytics_dashboard_screen.dart';
import '../widgets/past_sessions_list.dart';

/// Shared history content used by both TrainPage and HistoryScreen.
class HistoryContent extends StatelessWidget {
  /// Callback to reload the past sessions list.
  final VoidCallback onReload;

  const HistoryContent({super.key, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter navigation buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExerciseCatalogPage()),
                ),
                child: const Text('Exercises'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MuscleFilterPage()),
                ),
                child: const Text('Muscle'),
              ),
            ],
          ),
        ),

        // 7-day summary panel
        const HistorySummaryWidget(),

        // Analytics dashboard button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.analytics),
            label: const Text('View 7-Day Analytics'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()),
            ),
          ),
        ),

        // Past sessions list
        Expanded(
          child: PastSessionsList(onReload: onReload),
        ),
      ],
    );
  }
}
