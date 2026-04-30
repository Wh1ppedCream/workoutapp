// File: lib/widgets/history_summary_widget.dart

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';
import 'body_heatmap.dart';

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
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.infoCardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.infoCardShadow!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.infoCardValueText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: colors.infoCardLabelText,
            ),
          ),
        ],
      ),
    );
  }
}

class HistorySummaryWidget extends StatefulWidget {
  final int refreshToken;

  const HistorySummaryWidget({
    super.key,
    this.refreshToken = 0,
  });

  @override
  HistorySummaryWidgetState createState() => HistorySummaryWidgetState();
}

class HistorySummaryWidgetState extends State<HistorySummaryWidget>
    with AutomaticKeepAliveClientMixin<HistorySummaryWidget> {
  static const _tabLabels = ['1W', '1M', '3M', '6M', '1Y', 'All'];
  static const _durations = [7, 30, 90, 180, 365];

  late Future<void> _loadFuture;
  late List<List<WorkoutSession>> _sessionsList;
  late List<Map<BodyPart, double>> _heatmapList;
  late List<double> _volumeList;
  int _selectedIndex = 0;
  int _loadGeneration = 0;
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  @override
  void didUpdateWidget(covariant HistorySummaryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      setState(_reloadData);
    }
  }

  void _reloadData() {
    final loadGeneration = ++_loadGeneration;
    final repo = AppRepository();
    final now = DateTime.now();

    final sessionFutures = List.generate(_tabLabels.length, (i) {
      if (i < _durations.length) {
        final start = now.subtract(Duration(days: _durations[i]));
        return repo.fetchSessionsInRange(start, now);
      }
      return repo.fetchSessionsInRange(
        DateTime.fromMillisecondsSinceEpoch(0),
        now,
      );
    });

    final heatmapFutures = List.generate(_tabLabels.length, (i) {
      if (i < _durations.length) {
        final start = now.subtract(Duration(days: _durations[i]));
        return repo.fetchAllBodyPartSetsOverTimeRange(start: start, end: now);
      }
      return repo.fetchAllBodyPartSetsOverTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(0),
        end: now,
      );
    });

    _loadFuture = () async {
      final results = await Future.wait([...sessionFutures, ...heatmapFutures]);
      final sessionsList = List<List<WorkoutSession>>.from(
        results
            .sublist(0, _tabLabels.length)
            .map((e) => e as List<WorkoutSession>),
      );
      final heatmapList = List<Map<BodyPart, double>>.from(
        results
            .sublist(_tabLabels.length)
            .map((e) => e as Map<BodyPart, double>),
      );
      final volumeList = await Future.wait(
        sessionsList.map(
          (sessions) => repo.calculateTotalVolumeForSessions(
            sessions.map((s) => s.id).toList(),
          ),
        ),
      );

      if (loadGeneration != _loadGeneration) return;
      _sessionsList = sessionsList;
      _heatmapList = heatmapList;
      _volumeList = volumeList;
      _hasLoadedData = true;
    }();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colors = context.colors;
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done && !_hasLoadedData) {
          return SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(
                color: colors.historySummaryProgress!,
              ),
            ),
          );
        }
        if (snap.hasError && !_hasLoadedData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('Error loading history')),
          );
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                        segmentRadius = const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        );
                      } else if (i == _tabLabels.length - 1) {
                        segmentRadius = const BorderRadius.only(
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
    final colors = context.colors;
    final sessions = _sessionsList[index];
    final rawHeatmap = _heatmapList[index];

    final workoutCount = sessions.length;
    final totalSeconds = sessions.fold<int>(0, (sum, s) => sum + s.duration);
    final hours = totalSeconds ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;
    final timeStr = '${hours}h ${mins}m';
    final totalVolume = _volumeList[index];

    final maxCount =
        rawHeatmap.values.fold<double>(0.0, (prev, v) => v > prev ? v : prev);
    final freqMap = <String, double>{};
    rawHeatmap.forEach((bp, count) {
      final ids = bodyPartNameToSvgIds[bp.name] ?? [];
      final norm = maxCount == 0.0 ? 0.0 : count / maxCount;
      for (final id in ids) {
        freqMap[id] = norm;
      }
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: BodyHeatmap(
            frequencyMap: freqMap,
            lowColor: colors.historySummaryHeatmapLow!,
            highColor: colors.historySummaryHeatmapHigh!,
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
                InfoCard(
                  value: '${(totalVolume / 1000).toStringAsFixed(1)}k lbs',
                  label: 'Total Volume',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
