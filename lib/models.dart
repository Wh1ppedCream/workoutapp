class WorkoutExercise {
  String name;
  String equipment;
  List<ExerciseSet> sets;
  WorkoutExercise({required this.name, required this.equipment, required this.sets});
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

/// Represents a stored exercise definition.
class ExerciseDefinition {
  final int id;
  final String name;
  final int? equipmentId;

  ExerciseDefinition({required this.id, required this.name, this.equipmentId});
}

/// Equipment lookup.
class Equipment {
  final int id;
  final String name;
  Equipment(this.id, this.name);
}

/// BodyPart lookup.
class BodyPart {
  final int id;
  final String name;
  BodyPart(this.id, this.name);
}

// Add after BodyPart...
class MeasurementDefinition {
  final int id;
  final String name;
  final String type;
  MeasurementDefinition({required this.id, required this.name, required this.type});
}

class Measurement {
  final int id;
  final int defId;
  final DateTime timestamp;
  final double value;
  final String unit;
  final String? note;
  Measurement({
    required this.id,
    required this.defId,
    required this.timestamp,
    required this.value,
    required this.unit,
    this.note,
  });
}
