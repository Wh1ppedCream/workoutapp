// models.dart

// ─────────────────────────────────────────────────────────────────────────────
// STRETCH DEFINITIONS
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a master definition of a stretch, including related body parts.
class StretchDefinition {
  final int id;
  final String name;
  final String description;
  final List<BodyPart> bodyParts; // pulled via join

  StretchDefinition({
    required this.id,
    required this.name,
    required this.description,
    this.bodyParts = const [],
  });
}

/// Represents a single instance of a stretch in a workout.
class StretchInstance {
  final int? stretchId;    // null if custom
  final bool isCustom;
  final String? customName;
  final String? customDesc;
  bool isChecked;
  final int orderIndex;

  StretchInstance({
    this.stretchId,
    required this.isCustom,
    this.customName,
    this.customDesc,
    required this.isChecked,
    required this.orderIndex,
  });
}


// ─────────────────────────────────────────────────────────────────────────────
// WORKOUT EXERCISES
// ─────────────────────────────────────────────────────────────────────────────

/// Base class for all types of exercises in a workout.
abstract class WorkoutExercise {
  final String name;
  final String equipment; // free-form description or name of equipment

  /// Every exercise—whether weight, cardio, or stretch—carries a
  /// `stretchInstances` list.  Non-stretch cards will just leave it empty.
  final List<Map<String, dynamic>> stretchInstances;

  WorkoutExercise({
    required this.name,
    required this.equipment,
    List<Map<String, dynamic>>? stretchInstances,
  }) : stretchInstances = stretchInstances ?? <Map<String, dynamic>>[];
}

/// Represents a weight-based exercise, including sets and optional changeSets.
class WeightExercise extends WorkoutExercise {
  final List<ExerciseSet> sets;
  final Map<int, List<ExerciseSet>> changeSets;

  /// NEW: which parent‐set indices were checked (completed) when saved
  final Set<int> completedParentIndices;

  /// NEW: for each parent index, which child‐set indices were checked
  final Map<int, Set<int>> completedChildIndices;

  WeightExercise({
    required String name,
    required String equipment,
    required this.sets,
    Map<int, List<ExerciseSet>>? changeSets,
    Set<int>? completedParents,
    Map<int, Set<int>>? completedChildren,
  })  : changeSets = changeSets ?? <int, List<ExerciseSet>>{},
        completedParentIndices = completedParents ?? <int>{},
        completedChildIndices  = completedChildren ?? <int, Set<int>>{},
        super(name: name, equipment: equipment);
}

/// Represents a cardio exercise, with planned duration and elapsed time.
class CardioExercise extends WorkoutExercise {
  final String cardioName;
  final String? cardioNote;
  final int plannedMinutes;
  final int elapsedSeconds;

  CardioExercise({
    required String name,
    required String equipment,
    String? cardioName,
    this.cardioNote,
    int? plannedMinutes,
    int? elapsedSeconds,
  })  : cardioName = cardioName ?? 'Walking',
        plannedMinutes = plannedMinutes ?? 0,
        elapsedSeconds = elapsedSeconds ?? 0,
        super(name: name, equipment: equipment);
}

/// Represents a stretch exercise, holding a list of StretchInstance objects.
class StretchExercise extends WorkoutExercise {
  /// Indices of which stretch‐rows were checked
  final Set<int> completedStretchIndices;

  StretchExercise({
    required String name,
    required String equipment,
    List<Map<String, dynamic>>? stretchInstances,
    Set<int>? completedStretchIndices,
  })  : completedStretchIndices = completedStretchIndices ?? <int>{},
        super(
          name:            name,
          equipment:       equipment,
          stretchInstances: stretchInstances,
        );
}

/// Represents one set of a weight exercise (weight + reps).
class ExerciseSet {
  final double weight;
  final int reps;

  ExerciseSet({
    this.weight = 0,
    this.reps = 10,
  });
}

/// Represents a single workout session with date and duration.
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


// ─────────────────────────────────────────────────────────────────────────────
// EXERCISE DEFINITIONS
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a stored exercise definition (master record).
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
  final int rating;                   // 0–100
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

/// Equipment lookup table.
class Equipment {
  final int id;
  final String name;

  Equipment(this.id, this.name);
}

/// BodyPart lookup table.
class BodyPart {
  final int id;
  final String name;

  BodyPart(this.id, this.name);
}

/// A muscle lookup table.
class Muscle {
  final int id;
  final String name;

  Muscle({
    required this.id,
    required this.name,
  });
}

/// Associates a Muscle with a rank (1 through 7).
class RankedMuscle {
  final Muscle muscle;
  final int rank; // 1..7

  RankedMuscle({
    required this.muscle,
    required this.rank,
  });
}


// ─────────────────────────────────────────────────────────────────────────────
// MEASUREMENTS
// ─────────────────────────────────────────────────────────────────────────────

/// Types of measurements a user can track.
enum MeasurementType {
  BodyWeight,
  Height,
  Forearm,
  Arm,
  Neck,
  Shoulder,
  Chest,
  Waist,
  Hip,
  Thigh,
  Calf,
}

/// Represents a definition (kind) of measurement (e.g. “Body Weight”, “Blood Pressure”).
class MeasurementDefinition {
  final int id;
  final String name;
  final MeasurementType type;

  MeasurementDefinition({
    required this.id,
    required this.name,
    required this.type,
  });
}

/// Represents a single recorded measurement (with timestamp and numeric value).
class Measurement {
  final int id;
  final int defId;          // links back to MeasurementDefinition.id
  final DateTime timestamp;
  final double value;
  final String unit;        // e.g. "kg", "%", "mmHg"
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
