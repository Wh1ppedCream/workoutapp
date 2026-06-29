// lib/models/training_plan_models.dart

import 'definition_models.dart'; // for BodyPart, ExerciseDefinition

/// How generated sessions decide which areas should receive more sets.
enum TrainingPriorityMode { equalBodyPart, bodyPartRanking, muscleRanking }

/// How generated presets should fill in reps and suggested weights.
enum RepWeightGenerationMode { pyramid, consistent, mixed }

/// Immutable input for both Generate Custom Preset and Start Optimized Workout.
///
/// This object keeps generation behavior explicit at the call site: UI pages
/// collect duration, focus/avoid bodyparts, ranking mode, rep/weight settings,
/// and whether recent history should matter, then pass one complete spec into
/// PresetGenerationService.
class SessionSpec {
  static const int defaultSessionDurationMinutes = 60;
  static const int defaultMinutesPerSet = 3;
  static const int defaultSetupMinutesPerExercise = 5;
  static const int defaultMinSetsPerExercise = 1;
  static const int preferredMinSetsPerExercise = 2;
  static const int defaultMaxSetsPerExercise = 5;
  static const int maxAllowedSetsPerExercise = 5;
  static const double defaultWeeklyTargetSetUnits = 20.0;
  static const double maxBodyPartSetUnitsPerSession = 15.0;
  static const double preferredBodypartBiasMultiplier = 8.0;
  static const double preferredBodypartCandidateScoreMultiplier = 16.0;
  static const int restWarningBodyPartLimitCount = 4;
  static const int oneSetExerciseRestWarningCount = 2;
  static const int defaultTargetRepCount = 6;
  static const int maxGeneratedPlansPerBundle = 7;
  static const double recoverySignificantBodyPartUnits = 4.0;

  /// Which gym profile this is for (equipment filters, etc.).
  final int profileId;

  /// Name for the preset/session (e.g. "Upper A", "Legs", "Full Body").
  final String name;

  /// Bodyparts we want this session to primarily target.
  final List<int> focusBodypartIds;

  /// Bodyparts to bias upward for this generated session.
  final List<int> preferredBodypartIds;

  /// Bodyparts to exclude from this generated session.
  final List<int> blacklistedBodypartIds;

  /// How generated volume should be prioritized across bodyparts/muscles.
  final TrainingPriorityMode priorityMode;

  /// Whether generated presets should fill in reps and suggested weights.
  final bool useGeneratedRepWeights;

  /// How reps and weights should be arranged across sets.
  final RepWeightGenerationMode repWeightMode;

  /// Peak reps for pyramid mode, or target reps for consistent mode.
  final int targetRepCount;

  /// Whether optimized generation should avoid the most-worked bodypart from
  /// the most recent session when other viable options exist.
  final bool avoidMostRecentBodyPart;

  /// Whether generation should use recent completed workout volume.
  final bool useRecentTrainingHistory;

  /// Upper bound on how many exercises to include.
  final int maxExercises;

  /// Minimum sets per exercise.
  final int minSetsPerExercise;

  /// Maximum sets per exercise.
  final int maxSetsPerExercise;

  /// Target length for the generated workout.
  final int sessionDurationMinutes;

  /// Estimated active/rest time spent on each set.
  final int minutesPerSet;

  /// Estimated setup/transition time for each exercise.
  final int setupMinutesPerExercise;

  /// How far back we look into history for volume (e.g. 7 days).
  final Duration historyWindow;

  /// Reference "now" so we can test with fixed timestamps if needed.
  final DateTime now;

  const SessionSpec({
    required this.profileId,
    required this.name,
    required this.focusBodypartIds,
    this.preferredBodypartIds = const [],
    this.blacklistedBodypartIds = const [],
    this.priorityMode = TrainingPriorityMode.equalBodyPart,
    this.useGeneratedRepWeights = false,
    this.repWeightMode = RepWeightGenerationMode.mixed,
    this.targetRepCount = defaultTargetRepCount,
    this.avoidMostRecentBodyPart = false,
    this.useRecentTrainingHistory = true,
    this.maxExercises = 8,
    this.minSetsPerExercise = defaultMinSetsPerExercise,
    this.maxSetsPerExercise = defaultMaxSetsPerExercise,
    this.sessionDurationMinutes = defaultSessionDurationMinutes,
    this.minutesPerSet = defaultMinutesPerSet,
    this.setupMinutesPerExercise = defaultSetupMinutesPerExercise,
    this.historyWindow = const Duration(days: 7),
    required this.now,
  });

  SessionSpec copyWith({
    int? profileId,
    String? name,
    List<int>? focusBodypartIds,
    List<int>? preferredBodypartIds,
    List<int>? blacklistedBodypartIds,
    TrainingPriorityMode? priorityMode,
    bool? useGeneratedRepWeights,
    RepWeightGenerationMode? repWeightMode,
    int? targetRepCount,
    bool? avoidMostRecentBodyPart,
    bool? useRecentTrainingHistory,
    int? maxExercises,
    int? minSetsPerExercise,
    int? maxSetsPerExercise,
    int? sessionDurationMinutes,
    int? minutesPerSet,
    int? setupMinutesPerExercise,
    Duration? historyWindow,
    DateTime? now,
  }) {
    return SessionSpec(
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      focusBodypartIds: focusBodypartIds ?? this.focusBodypartIds,
      preferredBodypartIds:
          preferredBodypartIds ?? this.preferredBodypartIds,
      blacklistedBodypartIds:
          blacklistedBodypartIds ?? this.blacklistedBodypartIds,
      priorityMode: priorityMode ?? this.priorityMode,
      useGeneratedRepWeights:
          useGeneratedRepWeights ?? this.useGeneratedRepWeights,
      repWeightMode: repWeightMode ?? this.repWeightMode,
      targetRepCount: targetRepCount ?? this.targetRepCount,
      avoidMostRecentBodyPart:
          avoidMostRecentBodyPart ?? this.avoidMostRecentBodyPart,
      useRecentTrainingHistory:
          useRecentTrainingHistory ?? this.useRecentTrainingHistory,
      maxExercises: maxExercises ?? this.maxExercises,
      minSetsPerExercise: minSetsPerExercise ?? this.minSetsPerExercise,
      maxSetsPerExercise: maxSetsPerExercise ?? this.maxSetsPerExercise,
      sessionDurationMinutes:
          sessionDurationMinutes ?? this.sessionDurationMinutes,
      minutesPerSet: minutesPerSet ?? this.minutesPerSet,
      setupMinutesPerExercise:
          setupMinutesPerExercise ?? this.setupMinutesPerExercise,
      historyWindow: historyWindow ?? this.historyWindow,
      now: now ?? this.now,
    );
  }

  static int maxExercisesForDuration({
    required int sessionDurationMinutes,
    required int minSetsPerExercise,
    int cap = 10,
    int minutesPerSet = defaultMinutesPerSet,
    int setupMinutesPerExercise = defaultSetupMinutesPerExercise,
  }) {
    final minimumExerciseMinutes =
        setupMinutesPerExercise + minSetsPerExercise * minutesPerSet;
    if (minimumExerciseMinutes <= 0) return 1;
    return (sessionDurationMinutes ~/ minimumExerciseMinutes)
        .clamp(1, cap)
        .toInt();
  }
}

class PresetGenerationResult {
  final int presetId;
  final List<String> exercisesMissingWeightHistory;

  const PresetGenerationResult({
    required this.presetId,
    this.exercisesMissingWeightHistory = const [],
  });
}

class PresetBundleGenerationResult {
  final List<PresetGenerationResult> plans;
  final int requestedCount;

  const PresetBundleGenerationResult({
    required this.plans,
    required this.requestedCount,
  });

  int get generatedCount => plans.length;
  bool get isPartial => generatedCount < requestedCount;
}

/// Target & progress for a single bodypart over a week.
class BodyPartTarget {
  final BodyPart bodyPart;

  /// Desired set-units / bodypart-units per week.
  final double weeklyTargetUnits;

  /// How many units have already been done in the history window.
  final double doneThisWeek;

  /// Priority multiplier. Use 0 to keep the bodypart capped but not targeted.
  final double biasWeight;

  /// How far below target we are (never negative).
  double get deficit =>
      (weeklyTargetUnits - doneThisWeek).clamp(0.0, double.infinity);

  const BodyPartTarget({
    required this.bodyPart,
    required this.weeklyTargetUnits,
    required this.doneThisWeek,
    this.biasWeight = 1.0,
  });

  BodyPartTarget copyWith({double? doneThisWeek}) {
    return BodyPartTarget(
      bodyPart: bodyPart,
      weeklyTargetUnits: weeklyTargetUnits,
      doneThisWeek: doneThisWeek ?? this.doneThisWeek,
      biasWeight: biasWeight,
    );
  }
}

/// Target & progress for a single muscle over a week.
class MuscleTarget {
  final int muscleId;
  final double weeklyTargetUnits;
  final double doneThisWeek;
  final double biasWeight;

  double get deficit =>
      (weeklyTargetUnits - doneThisWeek).clamp(0.0, double.infinity);

  const MuscleTarget({
    required this.muscleId,
    required this.weeklyTargetUnits,
    required this.doneThisWeek,
    this.biasWeight = 1.0,
  });

  MuscleTarget copyWith({double? doneThisWeek}) {
    return MuscleTarget(
      muscleId: muscleId,
      weeklyTargetUnits: weeklyTargetUnits,
      doneThisWeek: doneThisWeek ?? this.doneThisWeek,
      biasWeight: biasWeight,
    );
  }
}

/// A scored candidate exercise for inclusion in an auto-generated session.
class CandidateExercisePlan {
  /// Underlying catalog definition.
  final ExerciseDefinition def;

  /// How much each set hits each bodypart (units from computeBodyPartPercents).
  final Map<BodyPart, double> unitsPerSet;

  /// How much each set hits each muscle.
  final Map<int, double> muscleUnitsPerSet;

  /// Scalar score used to rank candidates (higher = more preferred).
  final double score;

  /// How many sets we plan to give this exercise in the generated preset.
  final int suggestedSets;

  const CandidateExercisePlan({
    required this.def,
    required this.unitsPerSet,
    this.muscleUnitsPerSet = const {},
    required this.score,
    required this.suggestedSets,
  });

  CandidateExercisePlan copyWith({double? score, int? suggestedSets}) {
    return CandidateExercisePlan(
      def: def,
      unitsPerSet: unitsPerSet,
      muscleUnitsPerSet: muscleUnitsPerSet,
      score: score ?? this.score,
      suggestedSets: suggestedSets ?? this.suggestedSets,
    );
  }
}
