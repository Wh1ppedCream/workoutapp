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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.infoCardValueText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: colors.infoCardLabelText),
          ),
        ],
      ),
    );
  }
}

class HistorySummaryWidget extends StatefulWidget {
  final int refreshToken;

  const HistorySummaryWidget({super.key, this.refreshToken = 0});

  @override
  HistorySummaryWidgetState createState() => HistorySummaryWidgetState();
}

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
    final start =
        index < _durations.length
            ? now.subtract(Duration(days: _durations[index]))
            : DateTime.fromMillisecondsSinceEpoch(0);
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
                              borderRadius: segmentRadius,
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
                SizedBox(height: 250, child: _buildLoadedTab(_selectedIndex)),
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
    final rawHeatmap = data.heatmap;

    final workoutCount = data.workoutCount;
    final totalSeconds = data.totalDurationSeconds;
    final hours = totalSeconds ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;
    final timeStr = '${hours}h ${mins}m';
    final totalVolume = data.totalVolume;

    final maxCount = rawHeatmap.values.fold<double>(
      0.0,
      (prev, v) => v > prev ? v : prev,
    );
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
