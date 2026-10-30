import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/widgets/tonos_expressive_inset_accordion.dart';
import '../theme/widgets/tonos_expressive_navigation_motion.dart';
import '../theme/widgets/tonos_expressive_state_motion.dart';

import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../theme/tokens/app_expressive_train_tokens.dart';
import '../theme/widgets/tonos_surface.dart';
import '../utils/completed_workout_duration_formatter.dart';
import '../utils/localized_formatters.dart';
import '../utils/weight_unit_formatter.dart';

part 'workout_metric_chart/report_models.dart';
part 'workout_metric_chart/report_composition.dart';
part 'workout_metric_chart/report_selectors_and_insights.dart';
part 'workout_metric_chart/workout_line_chart.dart';
part 'workout_metric_chart/report_formatters_and_math.dart';

enum WorkoutReportRange {
  oneWeek,
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
  all,
}

bool _usesProgressExpressiveReport(BuildContext context) {
  final destination = Theme.of(context)
      .extension<AppExpressiveDestinationTokens>();
  return context.usesExpressivePresentation &&
      destination?.family == AppExpressiveDestinationFamily.progress;
}

Color _workoutReportChartSurface(BuildContext context) {
  final chartSurface = context.surfaceTokens.workoutMetricChart;
  final destination = Theme.of(context)
      .extension<AppExpressiveDestinationTokens>();
  if (_usesProgressExpressiveReport(context)) {
    return Color.lerp(chartSurface, destination!.surfacePrimary, 0.06)!;
  }
  return chartSurface;
}

typedef WorkoutReportDateLabelPlacement = ({
  int index,
  double left,
  double width,
});

@visibleForTesting
List<WorkoutReportDateLabelPlacement> layoutWorkoutReportDateLabelPlacements({
  required List<Offset> pointCenters,
  required List<double> labelWidths,
  required int labelEvery,
  required Rect plotRect,
  required double minimumGap,
}) {
  assert(pointCenters.length == labelWidths.length);
  assert(labelEvery > 0);

  final placements = <WorkoutReportDateLabelPlacement>[];
  var previousRight = double.negativeInfinity;
  for (var index = 0; index < pointCenters.length; index++) {
    if (index % labelEvery != 0 && index != pointCenters.length - 1) continue;

    final width = math.min(plotRect.width, labelWidths[index]).toDouble();
    final left = (pointCenters[index].dx - width / 2)
        .clamp(plotRect.left, plotRect.right - width)
        .toDouble();
    if (left < previousRight + minimumGap && index == pointCenters.length - 1) {
      while (placements.isNotEmpty && left < previousRight + minimumGap) {
        placements.removeLast();
        previousRight = placements.isEmpty
            ? double.negativeInfinity
            : placements.last.left + placements.last.width;
      }
    }
    if (left < previousRight + minimumGap) continue;

    placements.add((index: index, left: left, width: width));
    previousRight = left + width;
  }
  return placements;
}

@visibleForTesting
List<double> workoutReportAxisTickValues({
  required WorkoutReportMetric metric,
  required double maximum,
}) {
  if (maximum <= 0) return const <double>[0];
  if (metric == WorkoutReportMetric.workouts) {
    final step = _WorkoutLineChartPainter._niceIntegerStep(maximum / 6);
    final snappedMaximum = (maximum / step).ceil() * step;
    final intervalCount = (snappedMaximum / step).round();
    return List<double>.generate(intervalCount + 1, (index) => index * step);
  }
  return List<double>.generate(6, (index) => maximum * index / 5);
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
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressiveRecipe = context.usesExpressivePresentation;
    final expressiveTokens = usesExpressiveRecipe
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()
        : null;
    final destinationTokens = usesExpressiveRecipe
        ? Theme.of(context).extension<AppExpressiveDestinationTokens>()
        : null;
    final isProgressDestination = _usesProgressExpressiveReport(context);
    final surfaces = context.surfaceTokens;
    final shellForeground = usesInkRecipe
        ? tonosForegroundForSurface(context, surfaces.settingsHero)
        : isProgressDestination
        ? destinationTokens!.onSurfacePrimary
        : expressiveTokens?.actionPrimary;

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
      if (usesExpressiveRecipe) {
        return Card(
          color: isProgressDestination
              ? destinationTokens!.surfacePrimary
              : surfaces.card,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: context.shapeTokens.card),
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
                style: usesInkRecipe || usesExpressiveRecipe
                    ? Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: shellForeground)
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
            unit: totalWorkouts == 1
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

        final chartViewport = SizedBox(
          key: usesExpressiveRecipe
              ? const ValueKey('workout-report-expressive-chart-viewport')
              : null,
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
                rangeDataReady:
                    snapshot.connectionState == ConnectionState.done,
                weightUnit: weightUnit,
              );
            },
          ),
        );
        final rangeSelector = _RangeSelector(
          selectedRange: _range,
          onSelectRange: _selectRange,
        );
        final additionalDetails = _AdditionalDetailsDropdown(
          expanded: _showAdditionalDetails,
          insights: insights.insights,
          onToggle: () {
            setState(() {
              _showAdditionalDetails = !_showAdditionalDetails;
            });
          },
        );

        if (usesExpressiveRecipe) {
          return shell(
            _ExpressiveWorkoutReportComposition(
              title: strings.workoutReportTitle,
              stats: reportStats,
              selectedMetricIndex: _selectedMetricIndex,
              chartViewport: chartViewport,
              rangeSelector: rangeSelector,
              additionalDetails: additionalDetails,
            ),
          );
        }

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
                    final useTwoRows = context.usesNeoPresentation
                        ? MediaQuery.textScalerOf(context).scale(1) > 1.15 ||
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
                chartViewport,
                const SizedBox(height: 12),
                rangeSelector,
                const SizedBox(height: 8),
                additionalDetails,
              ],
            ),
          ),
        );
      },
    );
  }

  _ReportBucketSet _buildReportBuckets(List<WorkoutReportSession> sessions) {
    final today = DateUtils.dateOnly(DateTime.now());
    final earliestSessionDate = sessions.isEmpty
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
    final ordered = mutableBuckets.values.toList()
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
