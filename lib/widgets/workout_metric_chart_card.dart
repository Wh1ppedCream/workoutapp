import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';

enum WorkoutReportRange { twelveWeeks, sixMonths, oneYear, all }

enum _ReportBucketInterval { week, month }

class WorkoutMetricChartCard extends StatefulWidget {
  final int refreshToken;

  const WorkoutMetricChartCard({super.key, this.refreshToken = 0});

  @override
  State<WorkoutMetricChartCard> createState() => _WorkoutMetricChartCardState();
}

class _WorkoutMetricChartCardState extends State<WorkoutMetricChartCard> {
  final _repo = AppRepository();
  final _pageController = PageController();

  late Future<List<WorkoutReportSession>> _sessionsFuture;
  List<WorkoutReportSession>? _lastSessions;
  List<WorkoutReportSession>? _bucketSessionsSource;
  WorkoutReportRange? _bucketRangeSource;
  DateTime? _bucketTodaySource;
  _ReportBucketSet? _bucketCache;
  WorkoutReportRange _range = WorkoutReportRange.all;
  int _selectedMetricIndex = 0;

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
      case WorkoutReportRange.twelveWeeks:
        return today.subtract(const Duration(days: 12 * 7));
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
    final colors = context.colors;
    final cs = context.cs;

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
          return const Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Unable to load workout report.'),
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
        final totalWorkouts = sessions.length;
        final totalMinutes = sessions.fold<int>(
          0,
          (sum, session) => sum + session.durationMinutes,
        );
        final totalVolume = sessions.fold<double>(
          0,
          (sum, session) => sum + session.totalVolume,
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'Report',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    Text(
                      'Swipe chart',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ReportStat(
                        label: 'Workouts',
                        value: totalWorkouts.toString(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ReportStat(
                        label: 'Time(min)',
                        value: _formatCompact(totalMinutes.toDouble()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ReportStat(
                        label: 'Volume(lbs)',
                        value: _formatCompact(totalVolume),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _MetricSelector(
                  metrics: _metrics,
                  selectedIndex: _selectedMetricIndex,
                  onSelected: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                    );
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 240,
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
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RangeChip(
                      label: '12W',
                      selected: _range == WorkoutReportRange.twelveWeeks,
                      onTap: () => _selectRange(WorkoutReportRange.twelveWeeks),
                    ),
                    _RangeChip(
                      label: '6M',
                      selected: _range == WorkoutReportRange.sixMonths,
                      onTap: () => _selectRange(WorkoutReportRange.sixMonths),
                    ),
                    _RangeChip(
                      label: '1Y',
                      selected: _range == WorkoutReportRange.oneYear,
                      onTap: () => _selectRange(WorkoutReportRange.oneYear),
                    ),
                    _RangeChip(
                      label: 'All',
                      selected: _range == WorkoutReportRange.all,
                      onTap: () => _selectRange(WorkoutReportRange.all),
                    ),
                  ],
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
    final interval =
        _range == WorkoutReportRange.all && weekCount > 80
            ? _ReportBucketInterval.month
            : _ReportBucketInterval.week;

    if (interval == _ReportBucketInterval.month) {
      return _ReportBucketSet(
        interval: interval,
        buckets: _buildMonthlyBuckets(sessions, rawStart, today),
      );
    }

    return _ReportBucketSet(
      interval: interval,
      buckets: _buildWeeklyBuckets(sessions, weekStart, weekEnd),
    );
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

  List<WorkoutReportBucket> _buildWeeklyBuckets(
    List<WorkoutReportSession> sessions,
    DateTime start,
    DateTime end,
  ) {
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
      final bucketStart = _startOfWeek(session.date);
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

    final ordered =
        mutableBuckets.values.toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    return ordered
        .map(
          (bucket) => WorkoutReportBucket(
            start: bucket.start,
            end: bucket.end,
            workoutCount: bucket.workoutCount,
            durationSeconds: bucket.durationSeconds,
            totalVolume: bucket.totalVolume,
          ),
        )
        .toList();
  }

  List<WorkoutReportBucket> _buildMonthlyBuckets(
    List<WorkoutReportSession> sessions,
    DateTime rawStart,
    DateTime today,
  ) {
    final start = _startOfMonth(rawStart);
    final end = _startOfMonth(today);
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
      final bucketStart = _startOfMonth(session.date);
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

    final ordered =
        mutableBuckets.values.toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    return ordered
        .map(
          (bucket) => WorkoutReportBucket(
            start: bucket.start,
            end: bucket.end,
            workoutCount: bucket.workoutCount,
            durationSeconds: bucket.durationSeconds,
            totalVolume: bucket.totalVolume,
          ),
        )
        .toList();
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

class _ReportBucketSet {
  final _ReportBucketInterval interval;
  final List<WorkoutReportBucket> buckets;

  const _ReportBucketSet({required this.interval, required this.buckets});
}

class _MutableReportBucket {
  final DateTime start;
  final DateTime end;
  int workoutCount = 0;
  int durationSeconds = 0;
  double totalVolume = 0;

  _MutableReportBucket({required this.start, required this.end});
}

class _ReportStat extends StatelessWidget {
  final String label;
  final String value;

  const _ReportStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSelector extends StatelessWidget {
  final List<WorkoutReportMetric> metrics;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _MetricSelector({
    required this.metrics,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(metrics.length, (index) {
        final selected = selectedIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                right: index == metrics.length - 1 ? 0 : 8,
              ),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color:
                    selected
                        ? context.cs.primary.withValues(alpha: 0.16)
                        : context.cs.surfaceContainerHighest.withValues(
                          alpha: 0.6,
                        ),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                _metricLabel(metrics[index]),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color:
                      selected
                          ? context.cs.primary
                          : context.cs.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _MetricChartPage extends StatelessWidget {
  final List<WorkoutReportBucket> buckets;
  final WorkoutReportMetric metric;
  final _ReportBucketInterval interval;

  const _MetricChartPage({
    required this.buckets,
    required this.metric,
    required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    final chartWidth = math.max(320.0, buckets.length * 54.0);
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
              _chartTitle(metric, interval),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: CustomPaint(
                size: Size(chartWidth, 184),
                painter: _VerticalWorkoutBarPainter(
                  buckets: buckets,
                  metric: metric,
                  interval: interval,
                  accent: context.cs.primary,
                  grid: context.cs.outlineVariant,
                  labelColor: context.cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected ? context.cs.onPrimary : context.cs.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
      selectedColor: context.cs.primary,
      backgroundColor: context.cs.surfaceContainerHighest,
      side: BorderSide.none,
    );
  }
}

class _VerticalWorkoutBarPainter extends CustomPainter {
  final List<WorkoutReportBucket> buckets;
  final WorkoutReportMetric metric;
  final _ReportBucketInterval interval;
  final Color accent;
  final Color grid;
  final Color labelColor;

  const _VerticalWorkoutBarPainter({
    required this.buckets,
    required this.metric,
    required this.interval,
    required this.accent,
    required this.grid,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const right = 12.0;
    const top = 12.0;
    const bottom = 34.0;
    final chartHeight = size.height - top - bottom;
    final chartWidth = size.width - left - right;
    final chartBottom = size.height - bottom;

    final values = buckets.map((bucket) => bucket.valueFor(metric)).toList();
    final maxValue = values.fold<double>(0, math.max);
    final yMax = _niceMax(metric, maxValue);

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
      final y = chartBottom - chartHeight * (i / 5);
      final value = yMax * (i / 5);
      _drawDashedLine(
        canvas,
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
      _drawText(
        canvas,
        _formatAxis(value, metric),
        Offset(0, y - 8),
        labelStyle,
        maxWidth: left - 8,
        align: TextAlign.right,
      );
    }

    if (buckets.isEmpty) return;

    final step = chartWidth / buckets.length;
    final barWidth = math.min(26.0, step * 0.5);
    final labelEvery = math.max(1, (buckets.length / 7).ceil());
    final dateFormat =
        interval == _ReportBucketInterval.month
            ? DateFormat('MMM\nyy')
            : DateFormat('d\nMMM');
    final barPaint = Paint()..color = accent.withValues(alpha: 0.86);

    for (var i = 0; i < buckets.length; i++) {
      final value = values[i];
      final x = left + step * i + (step - barWidth) / 2;
      final rawHeight = yMax == 0 ? 0.0 : chartHeight * (value / yMax);
      final barHeight = value > 0 ? math.max(8.0, rawHeight) : 0.0;
      final y = chartBottom - barHeight;

      if (barHeight > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, barWidth, barHeight),
            const Radius.circular(8),
          ),
          barPaint,
        );
      }

      if (i % labelEvery == 0 || i == buckets.length - 1) {
        _drawText(
          canvas,
          dateFormat.format(buckets[i].start).toUpperCase(),
          Offset(left + step * i, chartBottom + 8),
          labelStyle.copyWith(fontSize: 10),
          maxWidth: step,
          align: TextAlign.center,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalWorkoutBarPainter oldDelegate) {
    return oldDelegate.buckets != buckets ||
        oldDelegate.metric != metric ||
        oldDelegate.interval != interval ||
        oldDelegate.accent != accent ||
        oldDelegate.grid != grid ||
        oldDelegate.labelColor != labelColor;
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

String _metricLabel(WorkoutReportMetric metric) {
  switch (metric) {
    case WorkoutReportMetric.workouts:
      return 'Workouts';
    case WorkoutReportMetric.minutes:
      return 'Time';
    case WorkoutReportMetric.volume:
      return 'Volume';
  }
}

String _chartTitle(WorkoutReportMetric metric, _ReportBucketInterval interval) {
  final unit =
      interval == _ReportBucketInterval.month ? 'per month' : 'per week';
  switch (metric) {
    case WorkoutReportMetric.workouts:
      return 'Workouts $unit';
    case WorkoutReportMetric.minutes:
      return 'Minutes $unit';
    case WorkoutReportMetric.volume:
      return 'Volume $unit';
  }
}

String _formatAxis(double value, WorkoutReportMetric metric) {
  if (metric == WorkoutReportMetric.workouts) {
    return value.round().toString();
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
