part of '../workout_metric_chart_card.dart';

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
          detail: longestStreak == 1
              ? strings.workoutReportDay
              : strings.workoutReportDays,
          icon: Icons.local_fire_department_outlined,
        ),
        _ReportInsight(
          label: strings.workoutReportMostActive,
          value: activeDay,
          detail: workoutCount == 0 ? strings.workoutReportNoSessions : '',
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
