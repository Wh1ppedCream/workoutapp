class WorkoutExercise {
  final String name;
  final String equipment;
  final List<ExerciseSet> sets;

  WorkoutExercise({
    required this.name,
    required this.equipment,
    required this.sets,
  });
}

class ExerciseSet {
  double weight;
  int reps;

  ExerciseSet({this.weight = 0, this.reps = 10});
}

class WorkoutSession {
  final int id;
  final DateTime date;
  final int duration; // in seconds

  WorkoutSession({
    required this.id,
    required this.date,
    required this.duration,
  });
}
