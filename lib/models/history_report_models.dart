import 'temporal_semantics.dart';

enum WorkoutReportMetric { workouts, minutes, volume }

class WorkoutReportSession {
  final int id;
  final DateTime date;
  final String? calendarDayKey;
  final int durationSeconds;
  final double totalVolume;
  final int exerciseCount;
  final int setCount;

  const WorkoutReportSession({
    required this.id,
    required this.date,
    this.calendarDayKey,
    required this.durationSeconds,
    required this.totalVolume,
    required this.exerciseCount,
    this.setCount = 0,
  });

  LocalCalendarDay get calendarDay => TemporalSemantics.readCalendarDay(
    calendarDay: calendarDayKey,
    epochMilliseconds: TemporalSemantics.utcEpochMilliseconds(date),
  );

  /// Date and time for labels: persisted calendar day plus the completion time.
  DateTime get displayDateTime => calendarDay.atLocalTime(date);
}

class WorkoutReportBucket {
  final DateTime start;
  final DateTime end;
  final int workoutCount;
  final int durationSeconds;
  final double totalVolume;

  const WorkoutReportBucket({
    required this.start,
    required this.end,
    required this.workoutCount,
    required this.durationSeconds,
    required this.totalVolume,
  });

  double valueFor(WorkoutReportMetric metric) {
    switch (metric) {
      case WorkoutReportMetric.workouts:
        return workoutCount.toDouble();
      case WorkoutReportMetric.minutes:
        return durationSeconds / 60;
      case WorkoutReportMetric.volume:
        return totalVolume;
    }
  }
}
