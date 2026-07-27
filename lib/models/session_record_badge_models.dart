/// The time scope for a workout-record badge shown after a completed session.
enum WorkoutRecordBadgeTier { monthly, allTime }

/// The type of achievement represented by a workout-record badge.
enum WorkoutRecordBadgeType { repBest, volumeBest }

/// A record achieved by one completed weight set.
class WorkoutRecordBadge {
  final WorkoutRecordBadgeTier tier;
  final WorkoutRecordBadgeType type;
  final int? reps;

  const WorkoutRecordBadge({required this.tier, required this.type, this.reps});

  String get label {
    switch (type) {
      case WorkoutRecordBadgeType.repBest:
        return '${reps ?? 0} Rep Best';
      case WorkoutRecordBadgeType.volumeBest:
        return 'Best Volume';
    }
  }
}

/// Record achievements for one completed exercise instance.
///
/// Keys in [setBadges] are zero-based parent-set indexes in the completed
/// exercise. Child change sets are intentionally excluded from this summary.
class WorkoutExerciseRecordBadges {
  final bool isFirstRecord;
  final Map<int, List<WorkoutRecordBadge>> setBadges;

  const WorkoutExerciseRecordBadges({
    required this.isFirstRecord,
    this.setBadges = const <int, List<WorkoutRecordBadge>>{},
  });

  List<WorkoutRecordBadge> forSet(int index) =>
      setBadges[index] ?? const <WorkoutRecordBadge>[];
}
