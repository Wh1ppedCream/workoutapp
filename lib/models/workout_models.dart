// file: lib/models/workout_models.dart

import 'definition_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STRETCH DEFINITIONS
// ─────────────────────────────────────────────────────────────────────────────

/// A master definition of a stretch, including its name, description, and
/// related body parts. Used for lookup and selection in the app.
///
/// - [id]: Unique database identifier for the stretch definition.
/// - [name]: Human-readable name of the stretch.
/// - [description]: Detailed instructions or notes about the stretch.
/// - [bodyParts]: List of targeted body parts (populated via join query).
class StretchDefinition {
  /// Unique identifier in the database.
  final int id;

  /// Display name of the stretch.
  final String name;

  /// Detailed instructions or description for the stretch.
  final String description;

  /// List of body parts targeted by this stretch.
  final List<BodyPart> bodyParts;

  /// Creates a [StretchDefinition].
  ///
  /// Defaults [bodyParts] to an empty list if not provided.
  StretchDefinition({
    required this.id,
    required this.name,
    required this.description,
    this.bodyParts = const [],
  });
}

/// A single occurrence of a stretch within a workout session.
///
/// - [stretchId]: References the master definition or null if custom.
/// - [isCustom]: True if this instance uses user-defined name/desc.
/// - [customName]/[customDesc]: Custom metadata when [isCustom] is true.
/// - [isChecked]: Whether the stretch was marked complete in the session.
/// - [orderIndex]: Sequence order of this stretch in the workout.
class StretchInstance {
  final int? stretchId;
  final bool isCustom;
  final String? customName;
  final String? customDesc;
  bool isChecked;
  final int orderIndex;

  /// Creates a [StretchInstance].
  ///
  /// If [stretchId] is null, this represents a custom stretch defined by the user.
  StretchInstance({
    this.stretchId,
    required this.isCustom,
    this.customName,
    this.customDesc,
    required this.isChecked,
    required this.orderIndex,
  });

  /// Deserialize from a Map (e.g. from SQLite or JSON blob).
  factory StretchInstance.fromMap(Map<String, dynamic> m) => StretchInstance(
        stretchId:  m['stretch_id'] as int?,
        isCustom:   (m['is_custom'] as int) == 1,
        customName: m['custom_name'] as String?,
        customDesc: m['custom_desc'] as String?,
        isChecked:  (m['is_checked'] as int) == 1,
        orderIndex: m['order_index'] as int,
      );

  /// Serialize to a Map (e.g. for SQLite or JSON blob).
  Map<String, dynamic> toMap() => {
        'stretch_id':  stretchId,
        'is_custom':   isCustom ? 1 : 0,
        'custom_name': customName,
        'custom_desc': customDesc,
        'is_checked':  isChecked ? 1 : 0,
        'order_index': orderIndex,
      };
}


// ─────────────────────────────────────────────────────────────────────────────
// WORKOUT EXERCISES
// ─────────────────────────────────────────────────────────────────────────────

/// Abstract base for any exercise in a workout (weight, cardio, or stretch).
///
/// - [name]: Display name of the exercise.
/// - [equipment]: Description or name of equipment used.
/// - [stretchInstances]: Optional list of stretch items if this exercise includes stretches.
abstract class WorkoutExercise {
  final String name;
  final String equipment;
  final List<StretchInstance> stretchInstances;

  /// Creates a [WorkoutExercise].
  ///
  /// The [stretchInstances] parameter defaults to an empty list if omitted.
  WorkoutExercise({
    required this.name,
    required this.equipment,
    List<StretchInstance>? stretchInstances,
  }) : stretchInstances = stretchInstances ?? <StretchInstance>[];
}

/// A weight-based exercise with parent sets and optional supersets/changesets.
///
/// - [sets]: List of primary [ExerciseSet] entries.
/// - [changeSets]: Map from parent index to list of child sets (supersets).
/// - [completedParents]/[completedChildren]: Tracks which sets were marked complete.
class WeightExercise extends WorkoutExercise {
  final List<ExerciseSet> sets;
  final Map<int, List<ExerciseSet>> changeSets;
  final Set<int> completedParents;
  final Map<int, Set<int>> completedChildren;

  /// Creates a [WeightExercise].
  ///
  /// [changeSets], [completedParents], and [completedChildren] default to empty collections if not provided.
  WeightExercise({
    required super.name,
    required super.equipment,
    required this.sets,
    Map<int, List<ExerciseSet>>? changeSets,
    Set<int>? completedParents,
    Map<int, Set<int>>? completedChildren,
    super.stretchInstances,
  })  : changeSets = changeSets ?? <int, List<ExerciseSet>>{},
        completedParents = completedParents ?? <int>{},
        completedChildren = completedChildren ?? <int, Set<int>>{};
}

/// A cardio exercise with planned duration, elapsed time, and optional notes.
///
/// - [cardioName]: Specific cardio activity name.
/// - [cardioNote]: Additional notes.
/// - [plannedMinutes]: Intended duration.
/// - [elapsedSeconds]: Actual time tracked.
class CardioExercise extends WorkoutExercise {
  String cardioName;
  String? cardioNote;
  int plannedMinutes;
  int elapsedSeconds;

  /// Creates a [CardioExercise].
  ///
  /// If [cardioName] is omitted, defaults to 'Walking'.
  /// [plannedMinutes] and [elapsedSeconds] default to zero.
  CardioExercise({
    required super.name,
    required super.equipment,
    String? cardioName,
    this.cardioNote,
    int? plannedMinutes,
    int? elapsedSeconds,
    super.stretchInstances,
  })  : cardioName     = cardioName ?? 'Walking',
        plannedMinutes = plannedMinutes ?? 0,
        elapsedSeconds = elapsedSeconds ?? 0;
}

/// A stretch exercise containing multiple [StretchInstance] items.
///
/// - [completedStretchIndices]: Set of indices marked complete.
class StretchExercise extends WorkoutExercise {
  final Set<int> completedStretchIndices;

  /// Creates a [StretchExercise].
  StretchExercise({
    required super.name,
    required super.equipment,
    super.stretchInstances,
    Set<int>? completedStretchIndices,
  })  : completedStretchIndices = completedStretchIndices ?? <int>{};
}

/// A single weight-rep entry.
///
/// - [weight]: Weight amount.
/// - [reps]: Number of repetitions.
class ExerciseSet {
  double weight;
  int reps;

  /// Creates an [ExerciseSet].
  ///
  /// Defaults to 0 weight and 10 reps if not provided.
  ExerciseSet({
    this.weight = 0,
    this.reps   = 10,
  });
}

/// Represents a recorded workout session with metadata.
///
/// - [id]: Unique session identifier.
/// - [date]: Session timestamp.
/// - [duration]: Total duration in seconds.
class WorkoutSession {
  final int id;
  final DateTime date;
  final int duration;

  /// Creates a [WorkoutSession].
  WorkoutSession({
    required this.id,
    required this.date,
    required this.duration,
  });
}