enum WorkoutReportMetric { workouts, minutes, volume }

class WorkoutReportSession {
  final int id;
  final DateTime date;
  final int durationSeconds;
  final double totalVolume;
  final int exerciseCount;
  final int setCount;

  const WorkoutReportSession({
    required this.id,
    required this.date,
    required this.durationSeconds,
    required this.totalVolume,
    required this.exerciseCount,
    this.setCount = 0,
  });

  int get durationMinutes => (durationSeconds / 60).ceil();
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
