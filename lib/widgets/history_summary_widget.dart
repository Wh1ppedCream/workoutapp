// File: lib/widgets/history_summary_widget.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import 'body_heatmap.dart';


// Mapping DB BodyPart.name → all SVG <path id="…"> strings 
const Map<String, List<String>> _bodyPartNameToSvgIds = {
  'Neck': [
    'Neck_frontal',
    'neck_rear',
  ],
  'Shoulders': [
    'Shoulder_frontal_left',
    'Shoulder_frontal_right',
    'shoulder_left_back',
    'shoulder_right_rear',
  ],
  'Chest': [
    'Chest_left',
    'Chest_right',
  ],
  'Core': [
    'Core_front',
  ],
  'Upper Back': [
    'Upper_Back',
  ],
  'Lower Back': [
    'lower_back',
  ],
  'Biceps': [
    'bicep_left',
    'Bicep_right',
  ],
  'Triceps': [
    'tricep_left_back',
    'tricep_right_rear',
  ],
  'Forearms': [
    'Forearm_Right_front',
    'forearm_frontal_left',
    'forearm_left_back',
    'forearm_right_rear',
  ],
  'Hips': [
    'Hip_back_left',
    'hip_right_rear',
  ],
  'Hamstrings': [
    'hamstring_left_back',
    'Hamstring_right_back',
  ],
  'Quads': [
    'Quad_Front_Right',
    'Quad_Left_front',
  ],
  'Calves': [
    'Calf_Front_Right',
    'Calf_front_left',
    'Calf_left_back',
    'Calf_right_back',
  ],
};


/// A little card for showing one piece of info (value + label).
class InfoCard extends StatelessWidget {
  final String value;
  final String label;

  const InfoCard({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // subtle shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loads the last-7-day sessions internally, then renders the summary.
class HistorySummaryWidget extends StatefulWidget {
  const HistorySummaryWidget({super.key});

  @override
  _HistorySummaryWidgetState createState() => _HistorySummaryWidgetState();
}

class _HistorySummaryWidgetState extends State<HistorySummaryWidget> {
  late final Future<List<WorkoutSession>> _sessionsFuture;
  late final Future<Map<BodyPart,double>> _heatmapFuture;
  late final DateTime _now;
  late final DateTime _weekAgo;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _weekAgo = _now.subtract(const Duration(days: 7));
    _sessionsFuture = AppRepository().fetchSessionsInRange(_weekAgo, _now);
    _heatmapFuture  = AppRepository().fetchSetsPerBodyPart(
      start: _weekAgo, end: _now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WorkoutSession>>(
      future: _sessionsFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError || snap.data == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('Error loading history')),
          );
        }
        return _buildSummary(context, snap.data!);
      },
    );
  }


Widget _buildSummary(BuildContext context, List<WorkoutSession> recentSessions) {
    // 1) Number of workouts
    final workoutCount = recentSessions.length;

    // 2) Total time (seconds → hours/minutes)
    final totalSeconds = recentSessions.fold<int>(
      0,
      (sum, session) => sum + session.duration,
    );
    final hours = totalSeconds ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;
    final timeStr = '${hours}h ${mins}m';

    // Prepare session IDs for volume calculation
    final sessionIds = recentSessions.map((s) => s.id).toList();

    // Heatmap Future
    final heatmapFuture = _heatmapFuture;

final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTabController(
          length: 6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              // ─── Tab Bar ────────────────────────────────
              Container(
                height: 35,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  // full-tab indicator
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  tabs: const [
                    Tab(text: '1W'),
                    Tab(text: '1M'),
                    Tab(text: '3M'),
                    Tab(text: '6M'),
                    Tab(text: '1Y'),
                    Tab(text: 'All'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

            // ── NEW ROW: Heatmap on left, 3 info cards on right ──
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1) The heatmap
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: FutureBuilder<Map<BodyPart, double>>(
                      future: heatmapFuture,
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snap.hasError || snap.data == null) {
                          return const Center(child: Text('Heatmap error'));
                        }

                        // Normalize & map to SVG IDs
                        final raw = snap.data!;
                        final maxCount = raw.values.fold<double>(
                          0.0,
                          (prev, v) => v > prev ? v : prev,
                        );

                        // Map DB BodyPart.name → List<svgId> is assumed
                        // to be defined elsewhere (as _bodyPartNameToSvgIds)
                        final freqMap = <String, double>{};
                        raw.forEach((bp, count) {
                          final ids = _bodyPartNameToSvgIds[bp.name];
                          if (ids != null) {
                            final norm = maxCount == 0.0 ? 0.0 : count / maxCount;
                            for (var id in ids) {
                              freqMap[id] = norm;
                            }
                          }
                        });

                        return BodyHeatmap(
                          frequencyMap: freqMap,
                          lowColor: Colors.grey.shade300,
                          highColor: Colors.blue.shade800,
                          width: 200,
                          height: 200,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 2) The three info cards
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InfoCard(
                          value: workoutCount.toString(),
                          label: 'Workouts',
                        ),

                        InfoCard(
                          value: timeStr,
                          label: 'Total Time',
                        ),

                        // FutureBuilder for volume → InfoCard
                        FutureBuilder<double>(
                          future: AppRepository()
                              .calculateTotalVolumeForSessions(sessionIds),
                          builder: (ctx, snap) {
                            String volText;
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              volText = '…';
                            } else if (snap.hasError) {
                              volText = 'Err';
                            } else {
                              final k = (snap.data! / 1000).toStringAsFixed(1);
                              volText = '${k}k lbs';
                            }
                            return InfoCard(
                              value: volText,
                              label: 'Total Volume',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          

            // remove the old placeholder / TODO
          ],
        ),
        ),
      ),
    );


  }
 }



