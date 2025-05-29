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
/// A master definition of an exercise.  
/// Now supports:
///  • rating (0–100)  
///  • one “primary” equipment_id (legacy)  
///  • many-to-many Equipment via [equipmentList]  
///  • many-to-many BodyPart via [bodyParts]  
///  • up to 7 ranked muscles via [muscles]
class ExerciseDefinition {
  final int id;
  final String name;
  final int? equipmentId;             // legacy single-equipment
  final int rating;
  final List<Equipment> equipmentList;
  final List<BodyPart> bodyParts;
  final List<RankedMuscle> muscles;

  ExerciseDefinition({
    required this.id,
    required this.name,
    this.equipmentId,
    this.rating = 0,
    this.equipmentList = const [],
    this.bodyParts = const [],
    this.muscles = const [],
  });
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

/// A muscle lookup.
class Muscle {
  final int id;
  final String name;

  Muscle({
    required this.id,
    required this.name,
  });
}

/// A muscle-with-rank for an exercise, where [rank] goes 1..7.
class RankedMuscle {
  final int muscleId;
  final String muscleName;
  final int rank;

  RankedMuscle({
    required this.muscleId,
    required this.muscleName,
    required this.rank,
  });
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
