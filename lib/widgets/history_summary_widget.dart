// File: lib/widgets/history_summary_widget.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import 'body_heatmap.dart';

/// Map from your DB BodyPart.name → all matching SVG path id="…"
const Map<String, List<String>> _bodyPartNameToSvgIds = {
  'Neck':          ['Neck_frontal', 'neck_rear'],
  'Shoulders':     [
                     'Shoulder_frontal_left',
                     'Shoulder_frontal_right',
                     'shoulder_left_back',
                     'shoulder_right_rear',
                   ],
  'Chest':         ['Chest_left', 'Chest_right'],
  'Core':          ['Core_front'],
  'Upper Back':    ['Upper_Back'],
  'Lower Back':    ['lower_back'],
  'Biceps':        ['bicep_left', 'Bicep_right'],
  'Triceps':       ['tricep_left_back', 'tricep_right_rear'],
  'Forearms':      [
                     'Forearm_Right_front',
                     'forearm_frontal_left',
                     'forearm_left_back',
                     'forearm_right_rear',
                   ],
  'Hips':          ['Hip_back_left', 'hip_right_rear'],
  'Hamstrings':    ['hamstring_left_back', 'Hamstring_right_back'],
  'Quads':         ['Quad_Front_Right', 'Quad_Left_front'],
  'Calves':        [
                     'Calf_Front_Right',
                     'Calf_front_left',
                     'Calf_left_back',
                     'Calf_right_back',
                   ],
};


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

     // Fetch body-part sets for the last 7 days
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final futureBodyPartMap = AppRepository()
        .fetchSetsPerBodyPart(start: weekAgo, end: now);

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
            // Heatmap showing sets per bodypart
            FutureBuilder<Map<BodyPart, double>>(
              future: futureBodyPartMap,
              builder: (ctx, snap) {
                const heatmapHeight = 180.0;
                if (snap.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: heatmapHeight,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError || snap.data == null) {
                  return SizedBox(
                    height: heatmapHeight,
                    child: const Center(child: Text('Failed to load heatmap')),
                  );
                }
                final rawCounts = snap.data!;
                final maxCount = rawCounts.values.fold<double>(
                  0.0, (prev, v) => v > prev ? v : prev);

                // Build svgId→normalized frequency map
                final freqMap = <String, double>{};
                rawCounts.forEach((bodyPart, count) {
                  final ids = _bodyPartNameToSvgIds[bodyPart.name];
                  if (ids != null) {
                    final norm = maxCount == 0.0 ? 0.0 : count / maxCount;
                    for (var svgId in ids) {
                      freqMap[svgId] = norm;
                    }
                  }
                });

                return SizedBox(
                  height: heatmapHeight,
                  child: BodyHeatmap(
                    frequencyMap: freqMap,
                    lowColor: Colors.grey.shade400,
                    highColor: const Color.fromARGB(255, 16, 2, 216),
                    width: double.infinity,
                    height: heatmapHeight,
                  ),
                );
              },
            ),
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