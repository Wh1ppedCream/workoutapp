import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';
import '../utils/completed_workout_duration_formatter.dart';
import '../utils/localized_digit_formatter.dart';
import '../utils/weight_unit_formatter.dart';

enum WorkoutReportRange {
  oneWeek,
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
  all,
}

enum _ReportBucketInterval { day, week, month }

_ReportBucketInterval _bucketIntervalForRange(
  WorkoutReportRange range,
  int weekCount,
) {
  switch (range) {
    case WorkoutReportRange.oneWeek:
    case WorkoutReportRange.oneMonth:
      return _ReportBucketInterval.day;
    case WorkoutReportRange.threeMonths:
    case WorkoutReportRange.sixMonths:
      return _ReportBucketInterval.week;
    case WorkoutReportRange.oneYear:
      return _ReportBucketInterval.month;
    case WorkoutReportRange.all:
      return weekCount > 80
          ? _ReportBucketInterval.month
          : _ReportBucketInterval.week;
  }
}

String _bucketNoun(_ReportBucketInterval interval, AppLocalizations strings) {
  switch (interval) {
    case _ReportBucketInterval.day:
      return strings.workoutReportDay;
    case _ReportBucketInterval.week:
      return strings.workoutReportWeek;
    case _ReportBucketInterval.month:
      return strings.workoutReportMonth;
  }
}

/// Swipeable workout report card for workouts, time, and volume.
///
/// The database returns raw completed sessions for the selected range. This
/// widget buckets those sessions by day/week/month, caches the bucket set for
/// the current range, and lets the user swipe between metric views without
/// refetching the same data.
class WorkoutMetricChartCard extends StatefulWidget {
  final int refreshToken;

  const WorkoutMetricChartCard({super.key, this.refreshToken = 0});

  @override
  State<WorkoutMetricChartCard> createState() => _WorkoutMetricChartCardState();
}

class _WorkoutMetricChartCardState extends State<WorkoutMetricChartCard> {
  AppRepository get _repo => context.read<AppRepository>();
  final _pageController = PageController();

  late Future<List<WorkoutReportSession>> _sessionsFuture;
  List<WorkoutReportSession>? _lastSessions;
  List<WorkoutReportSession>? _bucketSessionsSource;
  WorkoutReportRange? _bucketRangeSource;
  DateTime? _bucketTodaySource;
  _ReportBucketSet? _bucketCache;
  WorkoutReportRange _range = WorkoutReportRange.all;
  int _selectedMetricIndex = 0;
  bool _showAdditionalDetails = false;

  static const _metrics = [
    WorkoutReportMetric.workouts,
    WorkoutReportMetric.minutes,
    WorkoutReportMetric.volume,
  ];

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _loadSessions();
  }

  @override
  void didUpdateWidget(covariant WorkoutMetricChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _reload();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime? get _rangeStart {
    final today = DateUtils.dateOnly(DateTime.now());
    switch (_range) {
      case WorkoutReportRange.oneWeek:
        return today.subtract(const Duration(days: 6));
      case WorkoutReportRange.oneMonth:
        return DateTime(today.year, today.month - 1, today.day);
      case WorkoutReportRange.threeMonths:
        return DateTime(today.year, today.month - 3, today.day);
      case WorkoutReportRange.sixMonths:
        return DateTime(today.year, today.month - 6, today.day);
      case WorkoutReportRange.oneYear:
        return DateTime(today.year - 1, today.month, today.day);
      case WorkoutReportRange.all:
        return null;
    }
  }

  Future<List<WorkoutReportSession>> _loadSessions() {
    return _repo.fetchWorkoutReportSessions(start: _rangeStart);
  }

  void _reload() {
    setState(() {
      _sessionsFuture = _loadSessions();
    });
  }

  void _selectRange(WorkoutReportRange range) {
    if (_range == range) return;
    setState(() {
      _range = range;
      _sessionsFuture = _loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.colors;

    return FutureBuilder<List<WorkoutReportSession>>(
      future: _sessionsFuture,
      initialData: _lastSessions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              height: 260,
              child: Center(
                child: CircularProgressIndicator(
                  color: colors.historySummaryProgress,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError && !snapshot.hasData) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(strings.workoutReportLoadFailed),
            ),
          );
        }

        final sessions = snapshot.data ?? const <WorkoutReportSession>[];
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          _lastSessions = sessions;
        }

        final bucketSet = _reportBucketsFor(sessions);
        final buckets = bucketSet.buckets;
        void selectMetric(int index) {
          if (_selectedMetricIndex == index) return;
          if (!_pageController.hasClients) {
            setState(() => _selectedMetricIndex = index);
            return;
          }
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
          );
        }

        final totalWorkouts = sessions.length;
        final totalDurationSeconds = sessions.fold<int>(
          0,
          (sum, session) => sum + session.durationSeconds,
        );
        final totalVolume = sessions.fold<double>(
          0,
          (sum, session) => sum + session.totalVolume,
        );
        final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
        final insights = _ReportInsightSummary.fromSessions(
          sessions: sessions,
          buckets: buckets,
          interval: bucketSet.interval,
          weightUnit: weightUnit,
          strings: strings,
        );
        final reportStats = <Widget>[
          _ReportStat(
            label: strings.workoutReportWorkouts,
            value: _formatCompact(totalWorkouts.toDouble()),
            unit:
                totalWorkouts == 1
                    ? strings.workoutReportWorkout
                    : strings.workoutReportTotal,
            trend: _metricTrend(
              buckets,
              WorkoutReportMetric.workouts,
              weightUnit,
              strings,
            ),
            selected:
                _metrics[_selectedMetricIndex] == WorkoutReportMetric.workouts,
            onTap: () => selectMetric(0),
          ),
          _ReportStat(
            label: strings.workoutReportTime,
            value: formatCompletedWorkoutDuration(
              strings,
              totalDurationSeconds,
            ),
            unit: null,
            trend: _metricTrend(
              buckets,
              WorkoutReportMetric.minutes,
              weightUnit,
              strings,
            ),
            selected:
                _metrics[_selectedMetricIndex] == WorkoutReportMetric.minutes,
            onTap: () => selectMetric(1),
          ),
          _ReportStat(
            label: strings.workoutReportVolume,
            value: WeightUnitFormatter.formatCompactVolumeValue(
              totalVolume,
              weightUnit,
            ),
            unit: weightUnit.shortLabel,
            trend: _metricTrend(
              buckets,
              WorkoutReportMetric.volume,
              weightUnit,
              strings,
            ),
            selected:
                _metrics[_selectedMetricIndex] == WorkoutReportMetric.volume,
            onTap: () => selectMetric(2),
          ),
        ];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.workoutReportTitle,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final usesLocalizedLayout =
                        Localizations.localeOf(context).languageCode != 'en';
                    final useTwoRows =
                        usesLocalizedLayout &&
                        (constraints.maxWidth < 360 ||
                            MediaQuery.textScalerOf(context).scale(1) > 1.15);
                    if (!useTwoRows) {
                      return Row(
                        children: [
                          Expanded(child: reportStats[0]),
                          const SizedBox(width: 10),
                          Expanded(child: reportStats[1]),
                          const SizedBox(width: 10),
                          Expanded(child: reportStats[2]),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: reportStats[0]),
                            const SizedBox(width: 10),
                            Expanded(child: reportStats[1]),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(width: double.infinity, child: reportStats[2]),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _metrics.length,
                    onPageChanged: (index) {
                      setState(() => _selectedMetricIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final metric = _metrics[index];
                      return _MetricChartPage(
                        buckets: buckets,
                        metric: metric,
                        interval: bucketSet.interval,
                        range: _range,
                        weightUnit: weightUnit,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _RangeSelector(
                  selectedRange: _range,
                  onSelectRange: _selectRange,
                ),
                const SizedBox(height: 8),
                _AdditionalDetailsDropdown(
                  expanded: _showAdditionalDetails,
                  insights: insights.insights,
                  onToggle: () {
                    setState(() {
                      _showAdditionalDetails = !_showAdditionalDetails;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _ReportBucketSet _buildReportBuckets(List<WorkoutReportSession> sessions) {
    final today = DateUtils.dateOnly(DateTime.now());
    final earliestSessionDate =
        sessions.isEmpty
            ? null
            : sessions
                .map((session) => session.date)
                .reduce((a, b) => a.isBefore(b) ? a : b);
    final rawStart =
        _rangeStart ??
        (earliestSessionDate ?? today.subtract(const Duration(days: 7 * 7)));
    final weekStart = _startOfWeek(rawStart);
    final weekEnd = _startOfWeek(today);
    final weekCount = (weekEnd.difference(weekStart).inDays ~/ 7) + 1;
    final interval = _bucketIntervalForRange(_range, weekCount);

    switch (interval) {
      case _ReportBucketInterval.day:
        return _ReportBucketSet(
          interval: interval,
          buckets: _buildDailyBuckets(sessions, rawStart, today),
        );
      case _ReportBucketInterval.week:
        return _ReportBucketSet(
          interval: interval,
          buckets: _buildWeeklyBuckets(
            sessions,
            weekStart,
            weekEnd,
            rawStart,
            today,
          ),
        );
      case _ReportBucketInterval.month:
        return _ReportBucketSet(
          interval: interval,
          buckets: _buildMonthlyBuckets(sessions, rawStart, today),
        );
    }
  }

  _ReportBucketSet _reportBucketsFor(List<WorkoutReportSession> sessions) {
    final today = DateUtils.dateOnly(DateTime.now());
    final cached = _bucketCache;
    if (cached != null &&
        identical(_bucketSessionsSource, sessions) &&
        _bucketRangeSource == _range &&
        _bucketTodaySource == today) {
      return cached;
    }

    final computed = _buildReportBuckets(sessions);
    _bucketSessionsSource = sessions;
    _bucketRangeSource = _range;
    _bucketTodaySource = today;
    _bucketCache = computed;
    return computed;
  }

  List<WorkoutReportBucket> _buildDailyBuckets(
    List<WorkoutReportSession> sessions,
    DateTime start,
    DateTime end,
  ) {
    final normalizedStart = DateUtils.dateOnly(start);
    final normalizedEnd = DateUtils.dateOnly(end);
    final mutableBuckets = <DateTime, _MutableReportBucket>{};

    for (
      var current = normalizedStart;
      !current.isAfter(normalizedEnd);
      current = current.add(const Duration(days: 1))
    ) {
      mutableBuckets[current] = _MutableReportBucket(
        start: current,
        end: current,
      );
    }

    for (final session in sessions) {
      final sessionDay = DateUtils.dateOnly(session.date);
      if (sessionDay.isBefore(normalizedStart) ||
          sessionDay.isAfter(normalizedEnd)) {
        continue;
      }

      final bucketStart = sessionDay;
      final bucket = mutableBuckets.putIfAbsent(
        bucketStart,
        () => _MutableReportBucket(start: bucketStart, end: bucketStart),
      );
      bucket.workoutCount++;
      bucket.durationSeconds += session.durationSeconds;
      bucket.totalVolume += session.totalVolume;
    }

    return _finalizeBuckets(mutableBuckets);
  }

  List<WorkoutReportBucket> _buildWeeklyBuckets(
    List<WorkoutReportSession> sessions,
    DateTime start,
    DateTime end,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final normalizedRangeStart = DateUtils.dateOnly(rangeStart);
    final normalizedRangeEnd = DateUtils.dateOnly(rangeEnd);
    final mutableBuckets = <DateTime, _MutableReportBucket>{};

    for (
      var current = start;
      !current.isAfter(end);
      current = current.add(const Duration(days: 7))
    ) {
      mutableBuckets[current] = _MutableReportBucket(
        start: current,
        end: current.add(const Duration(days: 6)),
      );
    }

    for (final session in sessions) {
      final sessionDay = DateUtils.dateOnly(session.date);
      if (sessionDay.isBefore(normalizedRangeStart) ||
          sessionDay.isAfter(normalizedRangeEnd)) {
        continue;
      }

      final bucketStart = _startOfWeek(sessionDay);
      final bucket = mutableBuckets.putIfAbsent(
        bucketStart,
        () => _MutableReportBucket(
          start: bucketStart,
          end: bucketStart.add(const Duration(days: 6)),
        ),
      );
      bucket.workoutCount++;
      bucket.durationSeconds += session.durationSeconds;
      bucket.totalVolume += session.totalVolume;
    }

    return _finalizeBuckets(mutableBuckets);
  }

  List<WorkoutReportBucket> _buildMonthlyBuckets(
    List<WorkoutReportSession> sessions,
    DateTime rawStart,
    DateTime today,
  ) {
    final start = _startOfMonth(rawStart);
    final end = _startOfMonth(today);
    final normalizedRangeStart = DateUtils.dateOnly(rawStart);
    final normalizedRangeEnd = DateUtils.dateOnly(today);
    final mutableBuckets = <DateTime, _MutableReportBucket>{};

    for (
      var current = start;
      !current.isAfter(end);
      current = _addMonth(current)
    ) {
      mutableBuckets[current] = _MutableReportBucket(
        start: current,
        end: _endOfMonth(current),
      );
    }

    for (final session in sessions) {
      final sessionDay = DateUtils.dateOnly(session.date);
      if (sessionDay.isBefore(normalizedRangeStart) ||
          sessionDay.isAfter(normalizedRangeEnd)) {
        continue;
      }

      final bucketStart = _startOfMonth(sessionDay);
      final bucket = mutableBuckets.putIfAbsent(
        bucketStart,
        () => _MutableReportBucket(
          start: bucketStart,
          end: _endOfMonth(bucketStart),
        ),
      );
      bucket.workoutCount++;
      bucket.durationSeconds += session.durationSeconds;
      bucket.totalVolume += session.totalVolume;
    }

    return _finalizeBuckets(mutableBuckets);
  }

  List<WorkoutReportBucket> _finalizeBuckets(
    Map<DateTime, _MutableReportBucket> mutableBuckets,
  ) {
    final ordered =
        mutableBuckets.values.toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    return ordered.map(_toReportBucket).toList();
  }

  WorkoutReportBucket _toReportBucket(_MutableReportBucket bucket) {
    return WorkoutReportBucket(
      start: bucket.start,
      end: bucket.end,
      workoutCount: bucket.workoutCount,
      durationSeconds: bucket.durationSeconds,
      totalVolume: bucket.totalVolume,
    );
  }

  DateTime _startOfWeek(DateTime date) {
    final day = DateUtils.dateOnly(date);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  DateTime _startOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  DateTime _endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  DateTime _addMonth(DateTime date) {
    return DateTime(date.year, date.month + 1);
  }
}

/// Bucket output plus the interval needed by the chart axis formatter.
class _ReportBucketSet {
  final _ReportBucketInterval interval;
  final List<WorkoutReportBucket> buckets;

  const _ReportBucketSet({required this.interval, required this.buckets});
}

/// Mutable accumulator used while folding many sessions into chart buckets.
class _MutableReportBucket {
  final DateTime start;
  final DateTime end;
  int workoutCount = 0;
  int durationSeconds = 0;
  double totalVolume = 0;

  _MutableReportBucket({required this.start, required this.end});
}

class _ReportInsightSummary {
  final List<_ReportInsight> insights;

  const _ReportInsightSummary({required this.insights});

  factory _ReportInsightSummary.fromSessions({
    required List<WorkoutReportSession> sessions,
    required List<WorkoutReportBucket> buckets,
    required _ReportBucketInterval interval,
    required WeightUnit weightUnit,
    required AppLocalizations strings,
  }) {
    final workoutCount = sessions.length;
    final activeBucketCount = buckets.isEmpty ? 1 : buckets.length;
    final avgWorkouts = workoutCount / activeBucketCount;
    final bucketLabel = _bucketNoun(interval, strings);
    final longestStreak = _longestWorkoutDayStreak(sessions);
    final activeDay = _mostActiveWeekday(sessions, strings.localeName);
    final bestVolume = _bestVolumeDay(sessions, weightUnit, strings);

    return _ReportInsightSummary(
      insights: [
        _ReportInsight(
          label: strings.workoutReportAveragePer(bucketLabel),
          value: avgWorkouts.toStringAsFixed(avgWorkouts >= 10 ? 0 : 1),
          detail: strings.workoutReportWorkoutsLowercase,
          icon: Icons.trending_up,
        ),
        _ReportInsight(
          label: strings.workoutReportLongestStreak,
          value: longestStreak.toString(),
          detail:
              longestStreak == 1
                  ? strings.workoutReportDay
                  : strings.workoutReportDays,
          icon: Icons.local_fire_department_outlined,
        ),
        _ReportInsight(
          label: strings.workoutReportMostActive,
          value: activeDay,
          detail:
              workoutCount == 0
                  ? strings.workoutReportNoSessions
                  : strings.workoutReportWeekday,
          icon: Icons.calendar_today_outlined,
        ),
        _ReportInsight(
          label: strings.recordVolumeBest,
          value: bestVolume.value,
          detail: bestVolume.detail,
          icon: Icons.fitness_center,
        ),
      ],
    );
  }
}

class _ReportInsight {
  final String label;
  final String value;
  final String detail;
  final IconData icon;

  const _ReportInsight({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
  });
}

class _BestVolumeDay {
  final String value;
  final String detail;

  const _BestVolumeDay({required this.value, required this.detail});
}

enum _MetricTrendDirection { up, down, flat }

class _MetricTrend {
  final String label;
  final _MetricTrendDirection direction;

  const _MetricTrend({required this.label, required this.direction});
}

class _ReportStat extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final _MetricTrend trend;
  final bool selected;
  final VoidCallback onTap;

  const _ReportStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.trend,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final strings = AppLocalizations.of(context);
    final trendColor = _trendColor(cs);
    return Semantics(
      button: true,
      selected: selected,
      label: strings.workoutReportMetricSemantics(label),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color:
                  selected
                      ? cs.primary.withValues(alpha: 0.14)
                      : cs.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    selected
                        ? cs.primary.withValues(alpha: 0.75)
                        : cs.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selected ? cs.primary : cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value,
                          maxLines: 1,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: selected ? cs.primary : cs.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (unit != null) ...[
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              unit!,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      trend.label,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: trendColor,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _trendColor(ColorScheme cs) {
    switch (trend.direction) {
      case _MetricTrendDirection.up:
        return Colors.green.shade400;
      case _MetricTrendDirection.down:
        return Colors.red.shade400;
      case _MetricTrendDirection.flat:
        return cs.onSurfaceVariant;
    }
  }
}

class _MetricChartPage extends StatelessWidget {
  final List<WorkoutReportBucket> buckets;
  final WorkoutReportMetric metric;
  final _ReportBucketInterval interval;
  final WorkoutReportRange range;
  final WeightUnit weightUnit;

  const _MetricChartPage({
    required this.buckets,
    required this.metric,
    required this.interval,
    required this.range,
    required this.weightUnit,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final hasValue = buckets.any((bucket) => bucket.valueFor(metric) > 0);
    return Container(
      decoration: BoxDecoration(
        color: context.cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _chartTitle(metric, range, strings),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child:
                hasValue
                    ? _InteractiveWorkoutLineChart(
                      buckets: buckets,
                      metric: metric,
                      interval: interval,
                      showValueLabels: buckets.length <= 6,
                      weightUnit: weightUnit,
                    )
                    : _EmptyMetricChartMessage(metric: metric),
          ),
        ],
      ),
    );
  }
}

class _InteractiveWorkoutLineChart extends StatefulWidget {
  final List<WorkoutReportBucket> buckets;
  final WorkoutReportMetric metric;
  final _ReportBucketInterval interval;
  final bool showValueLabels;
  final WeightUnit weightUnit;

  const _InteractiveWorkoutLineChart({
    required this.buckets,
    required this.metric,
    required this.interval,
    required this.showValueLabels,
    required this.weightUnit,
  });

  @override
  State<_InteractiveWorkoutLineChart> createState() =>
      _InteractiveWorkoutLineChartState();
}

class _InteractiveWorkoutLineChartState
    extends State<_InteractiveWorkoutLineChart> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant _InteractiveWorkoutLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.buckets != widget.buckets ||
        oldWidget.metric != widget.metric ||
        oldWidget.interval != widget.interval) {
      _selectedIndex = null;
    } else if ((_selectedIndex ?? -1) >= widget.buckets.length) {
      _selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final chart = CustomPaint(
          size: size,
          painter: _WorkoutLineChartPainter(
            buckets: widget.buckets,
            metric: widget.metric,
            interval: widget.interval,
            strings: AppLocalizations.of(context),
            accent: context.cs.primary,
            grid: context.cs.outlineVariant,
            labelColor: context.cs.onSurfaceVariant,
            tooltipBackground: context.cs.surfaceContainerHighest,
            tooltipTextColor: context.cs.onSurface,
            showValueLabels: widget.showValueLabels,
            selectedIndex: _selectedIndex,
            weightUnit: widget.weightUnit,
            locale: Localizations.localeOf(context),
          ),
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final selected = _nearestBucketIndex(details.localPosition, size);
            if (selected == null) return;
            setState(() => _selectedIndex = selected);
          },
          child: chart,
        );
      },
    );
  }

  int? _nearestBucketIndex(Offset tapPosition, Size size) {
    if (widget.buckets.isEmpty) return null;
    final geometry = _WorkoutLineChartGeometry(
      buckets: widget.buckets,
      metric: widget.metric,
      size: size,
    );
    if (!geometry.plotRect.inflate(28).contains(tapPosition)) return null;

    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var index = 0; index < widget.buckets.length; index++) {
      final distance = (tapPosition.dx - geometry.xFor(index)).abs();
      if (distance < bestDistance) {
        bestIndex = index;
        bestDistance = distance;
      }
    }
    return bestIndex;
  }
}

class _EmptyMetricChartMessage extends StatelessWidget {
  final WorkoutReportMetric metric;

  const _EmptyMetricChartMessage({required this.metric});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final cs = context.cs;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_emptyMetricIcon(metric), color: cs.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              _emptyMetricTitle(metric, strings),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              _emptyMetricSubtitle(metric, strings),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  final WorkoutReportRange selectedRange;
  final ValueChanged<WorkoutReportRange> onSelectRange;

  const _RangeSelector({
    required this.selectedRange,
    required this.onSelectRange,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children:
            WorkoutReportRange.values.map((range) {
              final selected = selectedRange == range;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: () => onSelectRange(range),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            selected ? context.cs.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        _rangeLabel(range, strings),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color:
                              selected
                                  ? context.cs.onPrimary
                                  : context.cs.onSurfaceVariant,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _AdditionalDetailsDropdown extends StatelessWidget {
  final bool expanded;
  final List<_ReportInsight> insights;
  final VoidCallback onToggle;

  const _AdditionalDetailsDropdown({
    required this.expanded,
    required this.insights,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.55),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).workoutReportAdditionalDetails,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _ReportInsightGrid(insights: insights),
          ),
          crossFadeState:
              expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
          firstCurve: Curves.easeOutCubic,
          secondCurve: Curves.easeOutCubic,
          sizeCurve: Curves.easeOutCubic,
        ),
      ],
    );
  }
}

class _ReportInsightGrid extends StatelessWidget {
  final List<_ReportInsight> insights;

  const _ReportInsightGrid({required this.insights});

  @override
  Widget build(BuildContext context) {
    final usesLocalizedLayout =
        Localizations.localeOf(context).languageCode != 'en';
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: insights.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: usesLocalizedLayout ? 88 : 68,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return _ReportInsightTile(insight: insights[index]);
      },
    );
  }
}

class _ReportInsightTile extends StatelessWidget {
  final _ReportInsight insight;

  const _ReportInsightTile({required this.insight});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final usesLocalizedLayout =
        Localizations.localeOf(context).languageCode != 'en';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Icon(insight.icon, size: 18, color: cs.primary),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  insight.label,
                  maxLines: usesLocalizedLayout ? 2 : 1,
                  overflow:
                      usesLocalizedLayout
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                usesLocalizedLayout
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          insight.detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    )
                    : Row(
                      children: [
                        Flexible(
                          child: Text(
                            insight.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            insight.detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutLineChartGeometry {
  static const left = 42.0;
  static const right = 14.0;
  static const top = 18.0;
  static const bottom = 32.0;

  final List<WorkoutReportBucket> buckets;
  final WorkoutReportMetric metric;
  final Size size;

  _WorkoutLineChartGeometry({
    required this.buckets,
    required this.metric,
    required this.size,
  });

  late final Rect plotRect = Rect.fromLTWH(
    left,
    top,
    math.max(1.0, size.width - left - right),
    math.max(1.0, size.height - top - bottom),
  );

  late final List<double> values =
      buckets.map((bucket) => bucket.valueFor(metric)).toList();

  late final double yMax = _WorkoutLineChartPainter._niceMax(
    metric,
    values.fold<double>(0, math.max),
  );

  late final List<Offset> points = [
    for (var index = 0; index < buckets.length; index++)
      Offset(xFor(index), yFor(values[index])),
  ];

  double xFor(int index) {
    if (buckets.length <= 1) return plotRect.center.dx;
    return plotRect.left + plotRect.width * (index / (buckets.length - 1));
  }

  double yFor(double value) {
    if (yMax <= 0) return plotRect.bottom;
    final normalized = (value / yMax).clamp(0.0, 1.0).toDouble();
    return plotRect.bottom - plotRect.height * normalized;
  }
}

class _WorkoutLineChartPainter extends CustomPainter {
  final List<WorkoutReportBucket> buckets;
  final WorkoutReportMetric metric;
  final _ReportBucketInterval interval;
  final AppLocalizations strings;
  final Color accent;
  final Color grid;
  final Color labelColor;
  final Color tooltipBackground;
  final Color tooltipTextColor;
  final bool showValueLabels;
  final int? selectedIndex;
  final WeightUnit weightUnit;
  final Locale locale;

  const _WorkoutLineChartPainter({
    required this.buckets,
    required this.metric,
    required this.interval,
    required this.strings,
    required this.accent,
    required this.grid,
    required this.labelColor,
    required this.tooltipBackground,
    required this.tooltipTextColor,
    this.showValueLabels = false,
    this.selectedIndex,
    required this.weightUnit,
    required this.locale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = _WorkoutLineChartGeometry(
      buckets: buckets,
      metric: metric,
      size: size,
    );
    final values = geometry.values;
    final yMax = geometry.yMax;
    final plotRect = geometry.plotRect;

    final gridPaint =
        Paint()
          ..color = grid.withValues(alpha: 0.55)
          ..strokeWidth = 1;
    final labelStyle = TextStyle(
      color: labelColor.withValues(alpha: 0.82),
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    for (var i = 0; i <= 5; i++) {
      final y = geometry.yFor(yMax * (i / 5));
      final value = yMax * (i / 5);
      _drawDashedLine(
        canvas,
        Offset(plotRect.left, y),
        Offset(plotRect.right, y),
        gridPaint,
      );
      _drawText(
        canvas,
        _formatAxis(value, metric, weightUnit),
        Offset(0, y - 8),
        labelStyle,
        maxWidth: _WorkoutLineChartGeometry.left - 8,
        align: TextAlign.right,
      );
    }

    if (buckets.isEmpty) return;

    final pointCount = buckets.length;
    final labelEvery = math.max(1, (pointCount / 4).ceil());
    final dateFormat =
        interval == _ReportBucketInterval.month
            ? DateFormat.MMM(locale.toLanguageTag())
            : DateFormat('d MMM', locale.toLanguageTag());
    final points = geometry.points;

    final fillPath =
        Path()
          ..moveTo(points.first.dx, plotRect.bottom)
          ..lineTo(points.first.dx, points.first.dy);
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final current = points[index];
      linePath.lineTo(current.dx, current.dy);
      fillPath.lineTo(current.dx, current.dy);
    }
    fillPath
      ..lineTo(points.last.dx, plotRect.bottom)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, plotRect.top),
          Offset(0, plotRect.bottom),
          [accent.withValues(alpha: 0.24), accent.withValues(alpha: 0.02)],
        ),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = accent
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    for (var i = 0; i < buckets.length; i++) {
      final value = values[i];
      final point = points[i];
      final pointRadius = value > 0 ? 4.5 : 2.8;
      canvas.drawCircle(point, pointRadius, Paint()..color = accent);
      canvas.drawCircle(
        point,
        value > 0 ? 2.4 : 1.4,
        Paint()..color = labelColor.withValues(alpha: 0.9),
      );

      if (showValueLabels && value > 0) {
        _drawText(
          canvas,
          _formatAxis(value, metric, weightUnit),
          Offset(point.dx - 18, math.max(0, point.dy - 20)),
          labelStyle.copyWith(
            color: labelColor.withValues(alpha: 0.95),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
          maxWidth: 36,
          align: TextAlign.center,
        );
      }

      if (i % labelEvery == 0 || i == buckets.length - 1) {
        _drawText(
          canvas,
          _chartDateLabel(dateFormat, buckets[i], interval, locale),
          Offset(point.dx - 28, plotRect.bottom + 8),
          labelStyle.copyWith(fontSize: 10),
          maxWidth: 56,
          align: TextAlign.center,
        );
      }
    }

    if (selectedIndex != null) {
      _drawSelectedBucket(canvas, size, geometry, selectedIndex!, labelStyle);
    }
  }

  void _drawSelectedBucket(
    Canvas canvas,
    Size size,
    _WorkoutLineChartGeometry geometry,
    int index,
    TextStyle labelStyle,
  ) {
    if (index < 0 || index >= buckets.length) return;

    final point = geometry.points[index];
    final bucket = buckets[index];
    final value = bucket.valueFor(metric);
    final guidePaint =
        Paint()
          ..color = accent.withValues(alpha: 0.28)
          ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(point.dx, geometry.plotRect.top),
      Offset(point.dx, geometry.plotRect.bottom),
      guidePaint,
    );
    canvas.drawCircle(
      point,
      7,
      Paint()..color = tooltipBackground.withValues(alpha: 0.98),
    );
    canvas.drawCircle(point, 4.8, Paint()..color = accent);

    final titleStyle = labelStyle.copyWith(
      color: tooltipTextColor,
      fontSize: 11,
      fontWeight: FontWeight.w900,
    );
    final bodyStyle = labelStyle.copyWith(
      color: tooltipTextColor.withValues(alpha: 0.86),
      fontSize: 10,
      fontWeight: FontWeight.w800,
    );
    final tooltipLines = [
      (_bucketTooltipLabel(bucket, interval, strings.localeName), titleStyle),
      (_metricTooltipValue(value, metric, weightUnit, strings), bodyStyle),
    ];
    final painters =
        tooltipLines
            .map(
              (line) => TextPainter(
                text: TextSpan(text: line.$1, style: line.$2),
                textDirection: ui.TextDirection.ltr,
              )..layout(maxWidth: 150),
            )
            .toList();
    final width =
        painters.fold<double>(
          0,
          (maxWidth, painter) => math.max(maxWidth, painter.width),
        ) +
        20;
    final height =
        painters.fold<double>(0, (sum, painter) => sum + painter.height) + 16;
    final left = math.max(
      2.0,
      math.min(size.width - width - 2, point.dx - width / 2),
    );
    final top = math.max(2.0, geometry.plotRect.top - height + 16);
    final rect = Rect.fromLTWH(left, top, width, height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = tooltipBackground.withValues(alpha: 0.97)
        ..style = PaintingStyle.fill,
    );

    var y = rect.top + 8;
    for (final painter in painters) {
      painter.paint(canvas, Offset(rect.left + 10, y));
      y += painter.height;
    }
  }

  @override
  bool shouldRepaint(covariant _WorkoutLineChartPainter oldDelegate) {
    return oldDelegate.buckets != buckets ||
        oldDelegate.metric != metric ||
        oldDelegate.interval != interval ||
        oldDelegate.strings.localeName != strings.localeName ||
        oldDelegate.accent != accent ||
        oldDelegate.grid != grid ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.tooltipBackground != tooltipBackground ||
        oldDelegate.tooltipTextColor != tooltipTextColor ||
        oldDelegate.showValueLabels != showValueLabels ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.weightUnit != weightUnit ||
        oldDelegate.locale != locale;
  }

  static double _niceMax(WorkoutReportMetric metric, double value) {
    if (metric == WorkoutReportMetric.workouts) {
      return math.max(6, value.ceil()).toDouble();
    }
    if (value <= 0) return 1;
    final magnitude = math.pow(
      10,
      math.max(0, value.floor().toString().length - 1),
    );
    final normalized = value / magnitude;
    final nice =
        normalized <= 2
            ? 2
            : normalized <= 5
            ? 5
            : 10;
    return nice * magnitude.toDouble();
  }

  static String _chartDateLabel(
    DateFormat dateFormat,
    WorkoutReportBucket bucket,
    _ReportBucketInterval interval,
    Locale locale,
  ) {
    final label =
        preserveWesternDigits(
          dateFormat.format(bucket.start),
          locale,
        ).toUpperCase();
    if (interval == _ReportBucketInterval.month) return label;
    return label.replaceAll(' ', '\n');
  }

  static void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const dashWidth = 5.0;
    const dashGap = 6.0;
    var x = start.dx;
    while (x < end.dx) {
      canvas.drawLine(
        Offset(x, start.dy),
        Offset(math.min(x + dashWidth, end.dx), end.dy),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  static void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    required double maxWidth,
    TextAlign align = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      textAlign: align,
      maxLines: 2,
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, offset);
  }
}

String _rangeLabel(WorkoutReportRange range, AppLocalizations strings) {
  switch (range) {
    case WorkoutReportRange.oneWeek:
      return strings.workoutReportRangeOneWeekShort;
    case WorkoutReportRange.oneMonth:
      return strings.workoutReportRangeOneMonthShort;
    case WorkoutReportRange.threeMonths:
      return strings.workoutReportRangeThreeMonthsShort;
    case WorkoutReportRange.sixMonths:
      return strings.workoutReportRangeSixMonthsShort;
    case WorkoutReportRange.oneYear:
      return strings.workoutReportRangeOneYearShort;
    case WorkoutReportRange.all:
      return strings.workoutReportRangeAll;
  }
}

String _chartTitle(
  WorkoutReportMetric metric,
  WorkoutReportRange range,
  AppLocalizations strings,
) {
  final period = _rangeTitlePhrase(range, strings);
  final metricLabel = switch (metric) {
    WorkoutReportMetric.workouts => strings.workoutReportWorkouts,
    WorkoutReportMetric.minutes => strings.workoutReportTime,
    WorkoutReportMetric.volume => strings.workoutReportVolume,
  };
  return strings.workoutReportChartTitle(metricLabel, period);
}

String _bucketTooltipLabel(
  WorkoutReportBucket bucket,
  _ReportBucketInterval interval,
  String localeName,
) {
  final label = switch (interval) {
    _ReportBucketInterval.day => DateFormat.yMMMd(
      localeName,
    ).format(bucket.start),
    _ReportBucketInterval.week =>
      DateUtils.isSameDay(bucket.start, bucket.end)
          ? DateFormat.yMMMd(localeName).format(bucket.start)
          : '${DateFormat.MMMd(localeName).format(bucket.start)} - '
              '${DateFormat.yMMMd(localeName).format(bucket.end)}',
    _ReportBucketInterval.month => DateFormat.yMMMM(
      localeName,
    ).format(bucket.start),
  };
  return preserveWesternDigitsForLocale(label, localeName);
}

String _metricTooltipValue(
  double value,
  WorkoutReportMetric metric,
  WeightUnit weightUnit,
  AppLocalizations strings,
) {
  switch (metric) {
    case WorkoutReportMetric.workouts:
      return strings.workoutReportWorkoutCount(value.round());
    case WorkoutReportMetric.minutes:
      return formatCompletedWorkoutDuration(strings, (value * 60).round());
    case WorkoutReportMetric.volume:
      return WeightUnitFormatter.formatVolume(value, weightUnit);
  }
}

String _rangeTitlePhrase(WorkoutReportRange range, AppLocalizations strings) {
  switch (range) {
    case WorkoutReportRange.oneWeek:
      return strings.workoutReportRangeOneWeek;
    case WorkoutReportRange.oneMonth:
      return strings.workoutReportRangeOneMonth;
    case WorkoutReportRange.threeMonths:
      return strings.workoutReportRangeThreeMonths;
    case WorkoutReportRange.sixMonths:
      return strings.workoutReportRangeSixMonths;
    case WorkoutReportRange.oneYear:
      return strings.workoutReportRangeOneYear;
    case WorkoutReportRange.all:
      return strings.workoutReportRangeAll;
  }
}

_MetricTrend _metricTrend(
  List<WorkoutReportBucket> buckets,
  WorkoutReportMetric metric,
  WeightUnit weightUnit,
  AppLocalizations strings,
) {
  if (buckets.isEmpty) return _flatMetricTrend(metric, weightUnit, strings);

  final current = buckets.last.valueFor(metric);
  final previous =
      buckets.length > 1 ? buckets[buckets.length - 2].valueFor(metric) : 0.0;
  if (current <= 0 && previous <= 0) {
    return _flatMetricTrend(metric, weightUnit, strings);
  }

  final diff = current - previous;
  if (diff.abs() < 0.001) {
    return _flatMetricTrend(metric, weightUnit, strings);
  }

  final isUp = diff > 0;
  final arrow = isUp ? '↑' : '↓';
  return _MetricTrend(
    label:
        '$arrow ${_formatTrendAmount(diff.abs(), metric, weightUnit, strings)}',
    direction: isUp ? _MetricTrendDirection.up : _MetricTrendDirection.down,
  );
}

_MetricTrend _flatMetricTrend(
  WorkoutReportMetric metric,
  WeightUnit weightUnit,
  AppLocalizations strings,
) {
  return _MetricTrend(
    label: _formatTrendAmount(0, metric, weightUnit, strings),
    direction: _MetricTrendDirection.flat,
  );
}

String _formatTrendAmount(
  double value,
  WorkoutReportMetric metric,
  WeightUnit weightUnit,
  AppLocalizations strings,
) {
  switch (metric) {
    case WorkoutReportMetric.workouts:
      return strings.workoutReportWorkoutCount(value.round());
    case WorkoutReportMetric.minutes:
      return formatCompletedWorkoutDuration(strings, (value * 60).round());
    case WorkoutReportMetric.volume:
      return '${WeightUnitFormatter.formatCompactVolumeValue(value, weightUnit)} ${weightUnit.shortLabel}';
  }
}

IconData _emptyMetricIcon(WorkoutReportMetric metric) {
  switch (metric) {
    case WorkoutReportMetric.workouts:
      return Icons.fitness_center;
    case WorkoutReportMetric.minutes:
      return Icons.timer_outlined;
    case WorkoutReportMetric.volume:
      return Icons.monitor_weight_outlined;
  }
}

String _emptyMetricTitle(WorkoutReportMetric metric, AppLocalizations strings) {
  switch (metric) {
    case WorkoutReportMetric.workouts:
      return strings.workoutReportNoWorkoutsYet;
    case WorkoutReportMetric.minutes:
      return strings.workoutReportNoTrainingTimeYet;
    case WorkoutReportMetric.volume:
      return strings.workoutReportNoVolumeYet;
  }
}

String _emptyMetricSubtitle(
  WorkoutReportMetric metric,
  AppLocalizations strings,
) {
  switch (metric) {
    case WorkoutReportMetric.workouts:
      return strings.workoutReportNoWorkoutsBody;
    case WorkoutReportMetric.minutes:
      return strings.workoutReportNoTrainingTimeBody;
    case WorkoutReportMetric.volume:
      return strings.workoutReportNoVolumeBody;
  }
}

int _longestWorkoutDayStreak(List<WorkoutReportSession> sessions) {
  if (sessions.isEmpty) return 0;
  final days =
      sessions
          .map((session) => DateUtils.dateOnly(session.date))
          .toSet()
          .toList()
        ..sort();

  var longest = 1;
  var current = 1;
  for (var index = 1; index < days.length; index++) {
    final dayGap = days[index].difference(days[index - 1]).inDays;
    if (dayGap == 1) {
      current++;
      if (current > longest) longest = current;
    } else if (dayGap > 1) {
      current = 1;
    }
  }
  return longest;
}

String _mostActiveWeekday(
  List<WorkoutReportSession> sessions,
  String localeName,
) {
  if (sessions.isEmpty) return '-';
  final counts = <int, int>{};
  for (final session in sessions) {
    counts.update(
      session.date.weekday,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }
  final bestWeekday = counts.entries.reduce(
    (best, entry) => entry.value > best.value ? entry : best,
  );
  final monday = DateTime(2026, 1, 5);
  return DateFormat.E(
    localeName,
  ).format(monday.add(Duration(days: bestWeekday.key - DateTime.monday)));
}

_BestVolumeDay _bestVolumeDay(
  List<WorkoutReportSession> sessions,
  WeightUnit weightUnit,
  AppLocalizations strings,
) {
  if (sessions.isEmpty) {
    return _BestVolumeDay(value: '-', detail: strings.workoutReportNoSessions);
  }

  final totalsByDay = <DateTime, double>{};
  for (final session in sessions) {
    final day = DateUtils.dateOnly(session.date);
    totalsByDay.update(
      day,
      (volume) => volume + session.totalVolume,
      ifAbsent: () => session.totalVolume,
    );
  }

  final best = totalsByDay.entries.reduce(
    (best, entry) => entry.value > best.value ? entry : best,
  );
  if (best.value <= 0) {
    return _BestVolumeDay(
      value: '0',
      detail: strings.workoutReportUnitLogged(weightUnit.shortLabel),
    );
  }
  return _BestVolumeDay(
    value: WeightUnitFormatter.formatCompactVolumeValue(best.value, weightUnit),
    detail: strings.workoutReportUnitOnDate(
      weightUnit.shortLabel,
      preserveWesternDigitsForLocale(
        DateFormat.MMMd(strings.localeName).format(best.key),
        strings.localeName,
      ),
    ),
  );
}

String _formatAxis(
  double value,
  WorkoutReportMetric metric, [
  WeightUnit weightUnit = WeightUnit.pounds,
]) {
  if (metric == WorkoutReportMetric.workouts) {
    return value.round().toString();
  }
  if (metric == WorkoutReportMetric.volume) {
    return WeightUnitFormatter.formatCompactVolumeValue(value, weightUnit);
  }
  return _formatCompact(value);
}

String _formatCompact(double value) {
  final abs = value.abs();
  if (abs >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (abs >= 1000) {
    final digits = abs >= 10000 ? 0 : 1;
    return '${(value / 1000).toStringAsFixed(digits)}k';
  }
  return value.round().toString();
}
