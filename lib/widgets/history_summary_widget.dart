// File: lib/widgets/history_summary_widget.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';

/// Widget that displays summary metrics (count, time, volume, goal%)
/// for the given list of sessions (e.g. the last 7 days).
class HistorySummaryWidget extends StatelessWidget {
  final List<WorkoutSession> recentSessions;

  const HistorySummaryWidget({
    super.key,
    required this.recentSessions,
  });

  @override
  Widget build(BuildContext context) {
    // 1) Number of workouts
    final workoutCount = recentSessions.length;

    // 2) Total time (seconds → hours/minutes)
    final totalSeconds = recentSessions.fold<int>(
      0,
      (sum, session) => sum + session.duration,
    );
    final hours = totalSeconds ~/ 3600;
    final mins  = (totalSeconds % 3600) ~/ 60;
    final timeStr = '${hours}h ${mins}m';

    // Prepare session IDs for volume calculation
    final sessionIds = recentSessions.map((s) => s.id).toList();

    // Weekly goal % (assuming 5-target)
    const targetWorkouts = 5;
    final goalPercent = ((workoutCount / targetWorkouts) * 100)
        .clamp(0, 100)
        .toInt();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Last 7 Days', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _buildMetric('Workouts', workoutCount.toString()),
                _buildMetric('Total Time', timeStr),

                // ← Accurate volume via FutureBuilder
                FutureBuilder<double>(
                  future: AppRepository().calculateTotalVolumeForSessions(sessionIds),
                  builder: (ctx, snap) {
                    String volText;
                    if (snap.connectionState == ConnectionState.waiting) {
                      volText = '…';
                    } else if (snap.hasError) {
                      volText = 'Err';
                    } else {
                      final k = (snap.data! / 1000).toStringAsFixed(1);
                      volText = '${k}k lbs';
                    }
                    return _buildMetric('Total Volume', volText);
                  },
                ),

                _buildMetric('Goal %', '$goalPercent%'),
              ],
            ),

            const SizedBox(height: 12),
            // TODO: Body heatmap visualization
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}