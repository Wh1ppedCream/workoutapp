part of '../workout_metric_chart_card.dart';

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
  final previous = buckets.length > 1
      ? buckets[buckets.length - 2].valueFor(metric)
      : 0.0;
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
  return LocalizedFormatters.weekdayLong(
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
    final text = locale == null
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
    final text = locale == null
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
