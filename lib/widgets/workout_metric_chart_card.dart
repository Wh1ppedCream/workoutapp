import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/tonos_surface.dart';
import '../utils/completed_workout_duration_formatter.dart';
import '../utils/localized_formatters.dart';
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
    final dataVisualization = context.dataVisualizationTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final surfaces = context.surfaceTokens;
    final shellForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(context, surfaces.settingsHero)
            : null;

    Widget shell(Widget child) {
      if (usesInkRecipe) {
        return TonosSurface(
          variant: TonosSurfaceVariant.panelRaised,
          color: surfaces.settingsHero,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: EdgeInsets.zero,
          borderRadius: context.shapeTokens.card,
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      }
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: child,
      );
    }

    return FutureBuilder<List<WorkoutReportSession>>(
      future: _sessionsFuture,
      initialData: _lastSessions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return shell(
            SizedBox(
              height: 260,
              child: Center(
                child: CircularProgressIndicator(
                  color: dataVisualization.selection,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError && !snapshot.hasData) {
          return shell(
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                strings.workoutReportLoadFailed,
                style:
                    usesInkRecipe
                        ? Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: shellForeground)
                        : null,
              ),
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
          final duration = appMotionDuration(
            context,
            context.motionTokens.pageTransition,
          );
          if (duration == Duration.zero) {
            _pageController.jumpToPage(index);
            return;
          }
          _pageController.animateToPage(
            index,
            duration: duration,
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
          locale: Localizations.localeOf(context),
        );
        final reportStats = <Widget>[
          _ReportStat(
            label: strings.workoutReportWorkouts,
            value: _formatCompact(
              totalWorkouts.toDouble(),
              Localizations.localeOf(context),
            ),
            unit:
                totalWorkouts == 1
                    ? strings.workoutReportWorkout
                    : strings.workoutReportTotal,
            trend: _metricTrend(
              buckets,
              WorkoutReportMetric.workouts,
              weightUnit,
              strings,
              Localizations.localeOf(context),
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
              Localizations.localeOf(context),
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
              locale: Localizations.localeOf(context),
            ),
            unit: weightUnit.shortLabel,
            trend: _metricTrend(
              buckets,
              WorkoutReportMetric.volume,
              weightUnit,
              strings,
              Localizations.localeOf(context),
            ),
            selected:
                _metrics[_selectedMetricIndex] == WorkoutReportMetric.volume,
            onTap: () => selectMetric(2),
          ),
        ];

        return shell(
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.workoutReportTitle,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: shellForeground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final usesLocalizedLayout =
                        Localizations.localeOf(context).languageCode != 'en';
                    final useTwoRows =
                        context.surfaceDecorationTokens.panel.outlined
                            ? MediaQuery.textScalerOf(context).scale(1) >
                                    1.15 ||
                                (usesLocalizedLayout &&
                                    constraints.maxWidth < 360)
                            : usesLocalizedLayout &&
                                (constraints.maxWidth < 360 ||
                                    MediaQuery.textScalerOf(context).scale(1) >
                                        1.15);
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
                .map((session) => session.calendarDay.toLocalDateTime())
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
      final sessionDay = session.calendarDay.toLocalDateTime();
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
      final sessionDay = session.calendarDay.toLocalDateTime();
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
      final sessionDay = session.calendarDay.toLocalDateTime();
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
    required Locale locale,
  }) {
    final workoutCount = sessions.length;
    final activeBucketCount = buckets.isEmpty ? 1 : buckets.length;
    final avgWorkouts = workoutCount / activeBucketCount;
    final bucketLabel = _bucketNoun(interval, strings);
    final longestStreak = _longestWorkoutDayStreak(sessions);
    final activeDay = _mostActiveWeekday(sessions, locale);
    final bestVolume = _bestVolumeDay(sessions, weightUnit, strings, locale);
    final averageFractionDigits = avgWorkouts >= 10 ? 0 : 1;

    return _ReportInsightSummary(
      insights: [
        _ReportInsight(
          label: strings.workoutReportAveragePer(bucketLabel),
          value: LocalizedFormatters.number(
            avgWorkouts,
            locale,
            minimumFractionDigits: averageFractionDigits,
            maximumFractionDigits: averageFractionDigits,
          ),
          detail: strings.workoutReportWorkoutsLowercase,
          icon: Icons.trending_up,
        ),
        _ReportInsight(
          label: strings.workoutReportLongestStreak,
          value: LocalizedFormatters.number(
            longestStreak,
            locale,
            maximumFractionDigits: 0,
          ),
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
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final progressColors = context.progressColors;
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final unselectedFill =
        usesInkRecipe
            ? surfaces.workoutMetricRange
            : surfaces.workoutMetricStat;
    final selectedFill =
        usesInkRecipe
            ? surfaces.exerciseProgressSelector
            : progressColors.accent.withValues(alpha: 0.14);
    final unselectedForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(context, unselectedFill)
            : cs.onSurface;
    final selectedForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(
              context,
              selectedFill,
              parentSurface: unselectedFill,
            )
            : progressColors.accent;
    final unitForeground =
        usesInkRecipe
            ? (selected ? selectedForeground : unselectedForeground).withValues(
              alpha: 0.78,
            )
            : cs.onSurfaceVariant;
    final unselectedBorder =
        usesInkRecipe
            ? tonosOutlineForSurface(context, unselectedFill)
            : cs.outlineVariant.withValues(alpha: 0.7);
    final selectedBorder =
        usesInkRecipe
            ? tonosOutlineForSurface(context, selectedFill)
            : progressColors.accent.withValues(alpha: 0.75);
    final strings = AppLocalizations.of(context);
    final trendSurface = selected ? selectedFill : unselectedFill;
    final trendColor = _trendColor(context, trendSurface);
    final compactLayout = MediaQuery.textScalerOf(context).scale(1) <= 1.15;
    return Semantics(
      button: true,
      selected: selected,
      label: strings.workoutReportMetricSemantics(label),
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? selectedFill : unselectedFill,
            borderRadius: shapes.workoutMetricStat,
            border: Border.all(
              color: selected ? selectedBorder : unselectedBorder,
            ),
          ),
          child: InkWell(
            borderRadius: shapes.workoutMetricStat,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child:
                  compactLayout
                      ? _classicContent(
                        context,
                        selected ? selectedForeground : unselectedForeground,
                        unitForeground,
                        trendColor,
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 2,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color:
                                  selected
                                      ? selectedForeground
                                      : unselectedForeground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.end,
                            spacing: 4,
                            children: [
                              Text(
                                value,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  color:
                                      selected
                                          ? selectedForeground
                                          : unselectedForeground,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (unit != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    unit!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall?.copyWith(
                                      color:
                                          usesInkRecipe
                                              ? unitForeground
                                              : cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            trend.label,
                            maxLines: 2,
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: trendColor,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _classicContent(
    BuildContext context,
    Color foreground,
    Color unitColor,
    Color trendColor,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.bodyMedium!.copyWith(
      color: foreground,
      fontWeight: FontWeight.w700,
    );
    final valueStyle = textTheme.headlineSmall!.copyWith(
      color: foreground,
      fontWeight: FontWeight.w900,
    );
    final trendStyle = textTheme.labelSmall!.copyWith(
      color: trendColor,
      height: 1.05,
      fontWeight: FontWeight.w800,
    );

    // Equal line slots preserve Classic tile geometry while long values shrink.
    Widget fittedLine(TextStyle style, String measurementText, Widget child) {
      final painter = TextPainter(
        text: TextSpan(text: measurementText, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        locale: Localizations.localeOf(context),
      )..layout();
      final height = painter.height;
      painter.dispose();
      return SizedBox(
        width: double.infinity,
        height: height,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: child,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fittedLine(
          labelStyle,
          label,
          Text(label, maxLines: 1, style: labelStyle),
        ),
        const SizedBox(height: 4),
        fittedLine(
          valueStyle,
          value,
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, maxLines: 1, style: valueStyle),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit!,
                    maxLines: 1,
                    style: textTheme.labelSmall?.copyWith(color: unitColor),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 5),
        fittedLine(
          trendStyle,
          trend.label,
          Text(trend.label, maxLines: 1, style: trendStyle),
        ),
      ],
    );
  }

  Color _trendColor(BuildContext context, Color surface) {
    switch (trend.direction) {
      case _MetricTrendDirection.up:
        return tonosWorkoutIncreaseForSurface(context, surface);
      case _MetricTrendDirection.down:
        return tonosWorkoutDecreaseForSurface(context, surface);
      case _MetricTrendDirection.flat:
        return tonosWorkoutNeutralForSurface(context, surface);
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
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final hasValue = buckets.any((bucket) => bucket.valueFor(metric) > 0);
    return Container(
      decoration: BoxDecoration(
        color: surfaces.workoutMetricChart,
        borderRadius: shapes.workoutMetricChart,
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
    final progressColors = context.progressColors;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
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
            accent: tonosPrimarySeriesForSurface(
              context,
              surfaces.workoutMetricChart,
            ),
            grid: progressColors.grid,
            labelColor: progressColors.label,
            tooltipBackground: surfaces.workoutMetricTooltip,
            tooltipTextColor: context.cs.onSurface,
            tooltipBorderRadius: shapes.workoutMetricTooltip,
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
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final progressColors = context.progressColors;
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final selectedFill = progressColors.accent;
    final unselectedForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(context, surfaces.workoutMetricRange)
            : context.cs.onSurface;
    final selectedForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(
              context,
              selectedFill,
              parentSurface: surfaces.workoutMetricRange,
            )
            : context.cs.onPrimary;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaces.workoutMetricRange,
        borderRadius: shapes.workoutMetricRange,
        border:
            usesInkRecipe
                ? Border.all(
                  color: tonosOutlineForSurface(
                    context,
                    surfaces.workoutMetricRange,
                  ),
                  width: shapes.outlineWidth,
                )
                : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final compactLayout = textScale <= 1.15;
          final columns =
              compactLayout
                  ? WorkoutReportRange.values.length
                  : constraints.maxWidth < 360 || textScale > 1.15
                  ? 3
                  : WorkoutReportRange.values.length;
          const gap = 4.0;
          final itemWidth =
              (constraints.maxWidth - (columns - 1) * gap) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final range in WorkoutReportRange.values)
                SizedBox(
                  width: itemWidth,
                  child: _RangeSelectorOption(
                    label: _rangeLabel(range, strings),
                    selected: selectedRange == range,
                    selectedFill: selectedFill,
                    selectedForeground: selectedForeground,
                    unselectedForeground: unselectedForeground,
                    borderRadius: shapes.workoutMetricRangeOption,
                    onTap: () => onSelectRange(range),
                    compactLayout: compactLayout,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RangeSelectorOption extends StatelessWidget {
  const _RangeSelectorOption({
    required this.label,
    required this.selected,
    required this.selectedFill,
    required this.selectedForeground,
    required this.unselectedForeground,
    required this.borderRadius,
    required this.onTap,
    this.compactLayout = false,
  });

  final String label;
  final bool selected;
  final Color selectedFill;
  final Color selectedForeground;
  final Color unselectedForeground;
  final BorderRadiusGeometry borderRadius;
  final VoidCallback onTap;
  final bool compactLayout;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? selectedForeground : unselectedForeground;
    if (compactLayout) {
      return Semantics(
        button: true,
        selected: selected,
        label: label,
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius.resolve(Directionality.of(context)),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? selectedFill : Colors.transparent,
                borderRadius: borderRadius,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Ink(
              decoration: BoxDecoration(
                color: selected ? selectedFill : Colors.transparent,
                borderRadius: borderRadius,
              ),
              child: InkWell(
                borderRadius: borderRadius.resolve(Directionality.of(context)),
                onTap: onTap,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Text(
                      label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
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
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: surfaces.workoutMetricDetails,
              borderRadius: shapes.workoutMetricDetails,
              border: Border.all(
                color:
                    usesInkRecipe
                        ? tonosOutlineForSurface(
                          context,
                          surfaces.workoutMetricDetails,
                          neutral: true,
                        )
                        : cs.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: InkWell(
              borderRadius: shapes.workoutMetricDetails,
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
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
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _ReportInsightGrid(insights: insights),
          ),
          crossFadeState:
              expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: appMotionDuration(context, context.motionTokens.quick),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final preservesClassicLayout =
            context.usesClassicPresentation && textScale <= 1.15;
        const gridSpacing = 8.0;
        const neoMinimumTileWidth = 160.0;
        final useTwoColumns =
            preservesClassicLayout ||
            (textScale <= 1.15 &&
                !context.usesClassicPresentation &&
                constraints.maxWidth >= neoMinimumTileWidth * 2 + gridSpacing);
        final itemWidth =
            useTwoColumns
                ? (constraints.maxWidth - gridSpacing) / 2
                : constraints.maxWidth;
        final classicTileHeight =
            preservesClassicLayout
                ? (Localizations.localeOf(context).languageCode == 'en'
                    ? 68.0
                    : 88.0)
                : null;
        return Wrap(
          key: ValueKey(
            useTwoColumns
                ? 'workout-report-insight-grid-two-columns'
                : 'workout-report-insight-grid-one-column',
          ),
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final insight in insights)
              SizedBox(
                width: itemWidth,
                height: classicTileHeight,
                child: _ReportInsightTile(insight: insight),
              ),
          ],
        );
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
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final progressColors = context.progressColors;
    final usesClassicPresentation = context.usesClassicPresentation;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final classicNormalScale = usesClassicPresentation && textScale <= 1.15;
    final compactClassicTile = classicNormalScale && textScale > 1.0;
    return Semantics(
      container: true,
      label: '${insight.label}, ${insight.value}, ${insight.detail}',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: compactClassicTile ? 5 : 10,
          ),
          decoration: BoxDecoration(
            color: surfaces.workoutMetricInsight,
            borderRadius: shapes.workoutMetricInsight,
            border: Border.all(
              color:
                  context.surfaceDecorationTokens.panel.outlined
                      ? tonosOutlineForSurface(
                        context,
                        surfaces.workoutMetricInsight,
                      )
                      : cs.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(insight.icon, size: 18, color: progressColors.accent),
              const SizedBox(width: 9),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, _) {
                    final useStackedValues = textScale > 1.15;
                    return Column(
                      key: ValueKey(
                        useStackedValues
                            ? 'workout-report-insight-values-stacked'
                            : 'workout-report-insight-values-inline',
                      ),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          insight.label,
                          maxLines: classicNormalScale ? 1 : null,
                          overflow:
                              classicNormalScale ? TextOverflow.ellipsis : null,
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        useStackedValues
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  insight.value,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  insight.detail,
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
                                    maxLines: classicNormalScale ? 1 : null,
                                    overflow:
                                        classicNormalScale
                                            ? TextOverflow.ellipsis
                                            : null,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    insight.detail,
                                    maxLines: classicNormalScale ? 1 : null,
                                    overflow:
                                        classicNormalScale
                                            ? TextOverflow.ellipsis
                                            : null,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                ),
                              ],
                            ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
  final BorderRadius tooltipBorderRadius;
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
    required this.tooltipBorderRadius,
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
        _formatAxis(value, metric, weightUnit, locale),
        Offset(0, y - 8),
        labelStyle,
        maxWidth: _WorkoutLineChartGeometry.left - 8,
        align: TextAlign.right,
      );
    }

    if (buckets.isEmpty) return;

    final pointCount = buckets.length;
    final labelEvery = math.max(1, (pointCount / 4).ceil());
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
          _formatAxis(value, metric, weightUnit, locale),
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
          _chartDateLabel(buckets[i], interval, locale),
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
      (_bucketTooltipLabel(bucket, interval, locale), titleStyle),
      (
        _metricTooltipValue(value, metric, weightUnit, strings, locale),
        bodyStyle,
      ),
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
      tooltipBorderRadius.toRRect(rect),
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
        oldDelegate.tooltipBorderRadius != tooltipBorderRadius ||
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
    WorkoutReportBucket bucket,
    _ReportBucketInterval interval,
    Locale locale,
  ) {
    final label =
        (interval == _ReportBucketInterval.month
                ? LocalizedFormatters.monthShort(bucket.start, locale)
                : LocalizedFormatters.dayMonth(bucket.start, locale))
            .toUpperCase();
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
  Locale locale,
) {
  final label = switch (interval) {
    _ReportBucketInterval.day => LocalizedFormatters.date(bucket.start, locale),
    _ReportBucketInterval.week =>
      DateUtils.isSameDay(bucket.start, bucket.end)
          ? LocalizedFormatters.date(bucket.start, locale)
          : LocalizedFormatters.dateRange(bucket.start, bucket.end, locale),
    _ReportBucketInterval.month => LocalizedFormatters.monthYear(
      bucket.start,
      locale,
    ),
  };
  return label;
}

String _metricTooltipValue(
  double value,
  WorkoutReportMetric metric,
  WeightUnit weightUnit,
  AppLocalizations strings,
  Locale locale,
) {
  switch (metric) {
    case WorkoutReportMetric.workouts:
      return strings.workoutReportWorkoutCount(value.round());
    case WorkoutReportMetric.minutes:
      return formatCompletedWorkoutDuration(strings, (value * 60).round());
    case WorkoutReportMetric.volume:
      return WeightUnitFormatter.formatVolume(
        value,
        weightUnit,
        locale: locale,
      );
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
  Locale locale,
) {
  if (buckets.isEmpty) {
    return _flatMetricTrend(metric, weightUnit, strings, locale);
  }

  final current = buckets.last.valueFor(metric);
  final previous =
      buckets.length > 1 ? buckets[buckets.length - 2].valueFor(metric) : 0.0;
  if (current <= 0 && previous <= 0) {
    return _flatMetricTrend(metric, weightUnit, strings, locale);
  }

  final diff = current - previous;
  if (diff.abs() < 0.001) {
    return _flatMetricTrend(metric, weightUnit, strings, locale);
  }

  final isUp = diff > 0;
  final arrow = isUp ? '↑' : '↓';
  return _MetricTrend(
    label:
        '$arrow ${_formatTrendAmount(diff.abs(), metric, weightUnit, strings, locale)}',
    direction: isUp ? _MetricTrendDirection.up : _MetricTrendDirection.down,
  );
}

_MetricTrend _flatMetricTrend(
  WorkoutReportMetric metric,
  WeightUnit weightUnit,
  AppLocalizations strings,
  Locale locale,
) {
  return _MetricTrend(
    label: _formatTrendAmount(0, metric, weightUnit, strings, locale),
    direction: _MetricTrendDirection.flat,
  );
}

String _formatTrendAmount(
  double value,
  WorkoutReportMetric metric,
  WeightUnit weightUnit,
  AppLocalizations strings,
  Locale locale,
) {
  switch (metric) {
    case WorkoutReportMetric.workouts:
      return strings.workoutReportWorkoutCount(value.round());
    case WorkoutReportMetric.minutes:
      return formatCompletedWorkoutDuration(strings, (value * 60).round());
    case WorkoutReportMetric.volume:
      return '${WeightUnitFormatter.formatCompactVolumeValue(value, weightUnit, locale: locale)} ${weightUnit.shortLabel}';
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
          .map((session) => session.calendarDay.toLocalDateTime())
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

String _mostActiveWeekday(List<WorkoutReportSession> sessions, Locale locale) {
  if (sessions.isEmpty) return '-';
  final counts = <int, int>{};
  for (final session in sessions) {
    counts.update(
      session.calendarDay.toLocalDateTime().weekday,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }
  final bestWeekday = counts.entries.reduce(
    (best, entry) => entry.value > best.value ? entry : best,
  );
  final monday = DateTime(2026, 1, 5);
  return LocalizedFormatters.weekdayShort(
    monday.add(Duration(days: bestWeekday.key - DateTime.monday)),
    locale,
  );
}

_BestVolumeDay _bestVolumeDay(
  List<WorkoutReportSession> sessions,
  WeightUnit weightUnit,
  AppLocalizations strings,
  Locale locale,
) {
  if (sessions.isEmpty) {
    return _BestVolumeDay(value: '-', detail: strings.workoutReportNoSessions);
  }

  final totalsByDay = <DateTime, double>{};
  for (final session in sessions) {
    final day = session.calendarDay.toLocalDateTime();
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
    return _BestVolumeDay(value: '0', detail: weightUnit.shortLabel);
  }
  return _BestVolumeDay(
    value: WeightUnitFormatter.formatCompactVolumeValue(
      best.value,
      weightUnit,
      locale: locale,
    ),
    detail: weightUnit.shortLabel,
  );
}

String _formatAxis(
  double value,
  WorkoutReportMetric metric, [
  WeightUnit weightUnit = WeightUnit.pounds,
  Locale? locale,
]) {
  if (metric == WorkoutReportMetric.workouts) {
    final rounded = value.round();
    return locale == null
        ? rounded.toString()
        : LocalizedFormatters.number(rounded, locale, maximumFractionDigits: 0);
  }
  if (metric == WorkoutReportMetric.volume) {
    return WeightUnitFormatter.formatCompactVolumeValue(
      value,
      weightUnit,
      locale: locale,
    );
  }
  return _formatCompact(value, locale);
}

String _formatCompact(double value, [Locale? locale]) {
  final abs = value.abs();
  if (abs >= 1000000) {
    final text =
        locale == null
            ? (value / 1000000).toStringAsFixed(1)
            : LocalizedFormatters.number(
              value / 1000000,
              locale,
              minimumFractionDigits: 1,
              maximumFractionDigits: 1,
            );
    return '${text}M';
  }
  if (abs >= 1000) {
    final digits = abs >= 10000 ? 0 : 1;
    final text =
        locale == null
            ? (value / 1000).toStringAsFixed(digits)
            : LocalizedFormatters.number(
              value / 1000,
              locale,
              minimumFractionDigits: digits,
              maximumFractionDigits: digits,
            );
    return '${text}k';
  }
  final rounded = value.round();
  return locale == null
      ? rounded.toString()
      : LocalizedFormatters.number(rounded, locale, maximumFractionDigits: 0);
}
