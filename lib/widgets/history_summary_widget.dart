// File: lib/widgets/history_summary_widget.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import 'body_heatmap.dart';

// Mapping DB BodyPart.name → all SVG <path id="…"> strings
const Map<String, List<String>> _bodyPartNameToSvgIds = {
  'Neck': ['Neck_frontal', 'neck_rear'],
  'Shoulders': ['Shoulder_frontal_left', 'Shoulder_frontal_right', 'shoulder_left_back', 'shoulder_right_rear'],
  'Chest': ['Chest_left', 'Chest_right'],
  'Core': ['Core_front'],
  'Upper Back': ['Upper_Back'],
  'Lower Back': ['lower_back'],
  'Biceps': ['bicep_left', 'Bicep_right'],
  'Triceps': ['tricep_left_back', 'tricep_right_rear'],
  'Forearms': ['Forearm_Right_front', 'forearm_frontal_left', 'forearm_left_back', 'forearm_right_rear'],
  'Hips': ['Hip_back_left', 'hip_right_rear'],
  'Hamstrings': ['hamstring_left_back', 'Hamstring_right_back'],
  'Quads': ['Quad_Front_Right', 'Quad_Left_front'],
  'Calves': ['Calf_Front_Right', 'Calf_front_left', 'Calf_left_back', 'Calf_right_back'],
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        ],
      ),
    );
  }
}

/// Widget showing history summary across selectable timeframes via segmented button bar.
class HistorySummaryWidget extends StatefulWidget {
  const HistorySummaryWidget({super.key});

  @override
  _HistorySummaryWidgetState createState() => _HistorySummaryWidgetState();
}

class _HistorySummaryWidgetState extends State<HistorySummaryWidget> {
  static const _tabLabels = ['1W', '1M', '3M', '6M', '1Y', 'All'];
  static const _durations = [7, 30, 90, 180, 365];

  late final Future<void> _initialLoadFuture;
  late final List<List<WorkoutSession>> _sessionsList;
  late final List<Map<BodyPart, double>> _heatmapList;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    // Prepare futures
    final sessionFutures = List.generate(_tabLabels.length, (i) {
      if (i < _durations.length) {
        final start = now.subtract(Duration(days: _durations[i]));
        return AppRepository().fetchSessionsInRange(start, now);
      }
      return AppRepository().fetchSessionsInRange(DateTime.fromMillisecondsSinceEpoch(0), now);
    });
    final heatmapFutures = List.generate(_tabLabels.length, (i) {
      if (i < _durations.length) {
        final start = now.subtract(Duration(days: _durations[i]));
        return AppRepository().fetchSetsPerBodyPart(start: start, end: now);
      }
      return AppRepository().fetchSetsPerBodyPart(start: DateTime.fromMillisecondsSinceEpoch(0), end: now);
    });

    // Load all data once
    _initialLoadFuture = Future.wait([...sessionFutures, ...heatmapFutures]).then((results) {
      _sessionsList = List<List<WorkoutSession>>.from(
        results.sublist(0, _tabLabels.length).map((e) => e as List<WorkoutSession>),
      );
      _heatmapList = List<Map<BodyPart, double>>.from(
        results.sublist(_tabLabels.length).map((e) => e as Map<BodyPart, double>),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<void>(
      future: _initialLoadFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('Error loading history')),
          );
        }

        // All data ready
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Segmented appbar-style button bar
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: List.generate(_tabLabels.length, (i) {
                      final isSelected = i == _selectedIndex;
                      BorderRadius segmentRadius;
                      if (i == 0) {
                        segmentRadius = BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        );
                      } else if (i == _tabLabels.length - 1) {
                        segmentRadius = BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        );
                      } else {
                        segmentRadius = BorderRadius.zero;
                      }
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedIndex = i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: segmentRadius,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _tabLabels[i],
                              style: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                // Content panel
                SizedBox(
                  height: 250,
                  child: _buildLoadedTab(_selectedIndex),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadedTab(int index) {
    final sessions = _sessionsList[index];
    final rawHeatmap = _heatmapList[index];

    final workoutCount = sessions.length;
    final totalSeconds = sessions.fold<int>(0, (sum, s) => sum + s.duration);
    final hours = totalSeconds ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;
    final timeStr = '${hours}h ${mins}m';
    final sessionIds = sessions.map((s) => s.id).toList();

    // Heatmap frequency map
    final maxCount = rawHeatmap.values.fold<double>(0.0, (prev, v) => v > prev ? v : prev);
    final freqMap = <String, double>{};
    rawHeatmap.forEach((bp, count) {
      final ids = _bodyPartNameToSvgIds[bp.name] ?? [];
      final norm = maxCount == 0.0 ? 0.0 : count / maxCount;
      for (var id in ids) freqMap[id] = norm;
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: BodyHeatmap(
            frequencyMap: freqMap,
            lowColor: Colors.grey.shade300,
            highColor: Colors.blue.shade800,
            width: 200,
            height: 200,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InfoCard(value: workoutCount.toString(), label: 'Workouts'),
                InfoCard(value: timeStr, label: 'Total Time'),
                FutureBuilder<double>(
                  future: AppRepository().calculateTotalVolumeForSessions(sessionIds),
                  builder: (ctx3, volSnap) {
                    String volText;
                    if (volSnap.connectionState != ConnectionState.done) {
                      volText = '…';
                    } else if (volSnap.hasError) {
                      volText = 'Err';
                    } else {
                      final k = (volSnap.data! / 1000).toStringAsFixed(1);
                      volText = '${k}k lbs';
                    }
                    return InfoCard(value: volText, label: 'Total Volume');
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
