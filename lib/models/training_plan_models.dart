// lib/models/training_plan_models.dart

import 'definition_models.dart'; // for BodyPart, ExerciseDefinition

/// Specification for the kind of session we want to auto-generate.
class SessionSpec {
  /// Which gym profile this is for (equipment filters, etc.).
  final int profileId;

  /// Name for the preset/session (e.g. "Upper A", "Legs", "Full Body").
  final String name;

  /// Bodyparts we want this session to primarily target.
  final List<int> focusBodypartIds;

  /// Upper bound on how many exercises to include.
  final int maxExercises;

  /// Minimum sets per exercise.
  final int minSetsPerExercise;

  /// Maximum sets per exercise.
  final int maxSetsPerExercise;

  /// How far back we look into history for volume (e.g. 7 days).
  final Duration historyWindow;

  /// Reference “now” so we can test with fixed timestamps if needed.
  final DateTime now;

  const SessionSpec({
    required this.profileId,
    required this.name,
    required this.focusBodypartIds,
    this.maxExercises = 8,
    this.minSetsPerExercise = 3,
    this.maxSetsPerExercise = 5,
    this.historyWindow = const Duration(days: 7),
    required this.now,
  });
}

/// Target & progress for a single bodypart over a week.
class BodyPartTarget {
  final BodyPart bodyPart;

  /// Desired “set-units” / “bodypart-units” per week.
  final double weeklyTargetUnits;

  /// How many units have already been done in the history window.
  final double doneThisWeek;

  /// How far below target we are (never negative).
  double get deficit =>
      (weeklyTargetUnits - doneThisWeek).clamp(0.0, double.infinity);

  const BodyPartTarget({
    required this.bodyPart,
    required this.weeklyTargetUnits,
    required this.doneThisWeek,
  });
}

/// A scored candidate exercise for inclusion in an auto-generated session.
class CandidateExercisePlan {
  /// Underlying catalog definition.
  final ExerciseDefinition def;

  /// How much each set “hits” each bodypart (units from computeBodyPartPercents).
  final Map<BodyPart, double> unitsPerSet;

  /// Scalar score used to rank candidates (higher = more preferred).
  final double score;

  /// How many sets we plan to give this exercise in the generated preset.
  final int suggestedSets;

  const CandidateExercisePlan({
    required this.def,
    required this.unitsPerSet,
    required this.score,
    required this.suggestedSets,
  });
}
