// File: lib/widgets/history_summary_widget.dart

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';
import 'body_heatmap.dart';

class InfoCard extends StatelessWidget {
  final String value;
  final String label;

  const InfoCard({super.key, required this.value, required this.label});

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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.infoCardValueText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: colors.infoCardLabelText),
          ),
        ],
      ),
    );
  }
}

/// Compact workout-history summary used on the train/history surfaces.
///
/// Each time-range tab is loaded lazily and cached until [refreshToken]
/// changes. This keeps the initial screen quick while still letting users jump
/// between 1W/1M/3M/etc. without repeatedly hitting the database.
class HistorySummaryWidget extends StatefulWidget {
  final int refreshToken;

  const HistorySummaryWidget({super.key, this.refreshToken = 0});

  @override
  HistorySummaryWidgetState createState() => HistorySummaryWidgetState();
}

/// Pre-aggregated data for one selected time range.
class _HistoryTabData {
  final int workoutCount;
  final int totalDurationSeconds;
  final Map<BodyPart, double> heatmap;
  final double totalVolume;

  const _HistoryTabData({
    required this.workoutCount,
    required this.totalDurationSeconds,
    required this.heatmap,
    required this.totalVolume,
  });
}

class HistorySummaryWidgetState extends State<HistorySummaryWidget>
    with AutomaticKeepAliveClientMixin<HistorySummaryWidget> {
  static const _tabLabels = ['1W', '1M', '3M', '6M', '1Y', 'All'];
  static const _durations = [7, 30, 90, 180, 365];

  late Future<void> _loadFuture;
  late List<Future<_HistoryTabData>?> _tabFutures;
  late List<_HistoryTabData?> _tabData;
  int _selectedIndex = 0;
  int _loadGeneration = 0;

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
    _loadGeneration++;
    _tabFutures = List<Future<_HistoryTabData>?>.filled(
      _tabLabels.length,
      null,
    );
    _tabData = List<_HistoryTabData?>.filled(_tabLabels.length, null);
    _loadFuture = _ensureTabLoaded(_selectedIndex);
  }

  Future<void> _ensureTabLoaded(int index) {
    final existing = _tabFutures[index];
    if (existing != null) {
      _loadFuture = existing.then((_) {});
      return _loadFuture;
    }

    final loadGeneration = _loadGeneration;
    final future = _loadTab(index).then((data) {
      if (loadGeneration == _loadGeneration) {
        _tabData[index] = data;
      }
      return data;
    });
    _tabFutures[index] = future;
    _loadFuture = future.then((_) {});
    return _loadFuture;
  }

  Future<_HistoryTabData> _loadTab(int index) async {
    final repo = AppRepository();
    final now = DateTime.now();
    final start = _startForTab(index, now);
    final results = await Future.wait([
      repo.fetchWorkoutReportSessions(start: start, end: now),
      repo.fetchAllBodyPartSetsOverTimeRange(start: start, end: now),
    ]);
    final sessions = results[0] as List<WorkoutReportSession>;
    final heatmap = results[1] as Map<BodyPart, double>;
    return _HistoryTabData(
      workoutCount: sessions.length,
      totalDurationSeconds: sessions.fold<int>(
        0,
        (sum, session) => sum + session.durationSeconds,
      ),
      heatmap: heatmap,
      totalVolume: sessions.fold<double>(
        0.0,
        (sum, session) => sum + session.totalVolume,
      ),
    );
  }

  DateTime _startForTab(int index, DateTime now) {
    return index < _durations.length
        ? now.subtract(Duration(days: _durations[index]))
        : DateTime.fromMillisecondsSinceEpoch(0);
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
        if (snap.connectionState != ConnectionState.done &&
            _tabData[_selectedIndex] == null) {
          return SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(
                color: colors.historySummaryProgress!,
              ),
            ),
          );
        }
        if (snap.hasError && _tabData[_selectedIndex] == null) {
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
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = i;
                              _ensureTabLoaded(i);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                              borderRadius: _tabSegmentRadius(i),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _tabLabels[i],
                              style: TextStyle(
                                color:
                                    isSelected
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final summaryHeight =
                        (constraints.maxWidth * 0.62)
                            .clamp(210.0, 250.0)
                            .toDouble();
                    return SizedBox(
                      height: summaryHeight,
                      child: _buildLoadedTab(_selectedIndex),
                    );
                  },
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
    final data = _tabData[index];
    if (data == null) {
      return Center(
        child: CircularProgressIndicator(color: colors.historySummaryProgress!),
      );
    }
    final freqMap = bodyPartFrequencyMapFromNames({
      for (final entry in data.heatmap.entries) entry.key.name: entry.value,
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final gap = maxWidth < 330 ? 10.0 : 16.0;
        final heatmapBox = (maxWidth * 0.57).clamp(138.0, 250.0).toDouble();
        final heatmapSize = heatmapBox.clamp(128.0, 200.0).toDouble();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: heatmapBox,
              height: heatmapBox,
              child: Center(
                child: BodyHeatmap(
                  frequencyMap: freqMap,
                  lowColor: colors.historySummaryHeatmapLow!,
                  highColor: colors.historySummaryHeatmapHigh!,
                  width: heatmapSize,
                  height: heatmapSize,
                ),
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InfoCard(
                      value: data.workoutCount.toString(),
                      label: 'Workouts',
                    ),
                    InfoCard(
                      value: _durationLabel(data.totalDurationSeconds),
                      label: 'Total Time',
                    ),
                    InfoCard(
                      value:
                          '${(data.totalVolume / 1000).toStringAsFixed(1)}k lbs',
                      label: 'Total Volume',
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  BorderRadius _tabSegmentRadius(int index) {
    if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      );
    }
    if (index == _tabLabels.length - 1) {
      return const BorderRadius.only(
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(8),
      );
    }
    return BorderRadius.zero;
  }

  String _durationLabel(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;
    return '${hours}h ${mins}m';
  }
}
