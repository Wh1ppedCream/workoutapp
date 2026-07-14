import 'definition_models.dart';
import 'workout_models.dart';

/// A fully prepared exercise graph that can be committed in one transaction.
class WorkoutExerciseWrite {
  final WorkoutExercise exercise;
  final String type;
  final int? definitionId;
  final int? sourcePresetExerciseId;
  final int? previousPresetExerciseId;

  const WorkoutExerciseWrite({
    required this.exercise,
    required this.type,
    this.definitionId,
    this.sourcePresetExerciseId,
    this.previousPresetExerciseId,
  });
}

/// Automatic-plan settings written alongside a new or replaced plan.
class PresetAutoSettingsWrite {
  final bool isAutomatic;
  final double globalIncrement;
  final bool skipFirstSet;
  final bool weightCheck;
  final bool repCheck;
  final bool volumeCheck;
  final bool adjustAllSets;
  final bool useManualSelect;
  final Map<int, bool> manualSelections;
  final String successCountMode;

  const PresetAutoSettingsWrite({
    required this.isAutomatic,
    required this.globalIncrement,
    required this.skipFirstSet,
    required this.weightCheck,
    required this.repCheck,
    required this.volumeCheck,
    required this.adjustAllSets,
    required this.useManualSelect,
    this.manualSelections = const <int, bool>{},
    this.successCountMode = 'set',
  });
}

/// Complete automatic-progression configuration committed as one unit.
class PresetAutoConfigurationWrite {
  final PresetAutoSettingsWrite settings;
  final Map<int, double?> exerciseIncrements;
  final Map<int, int> exerciseLastSetIndices;
  final Map<int, double?> setIncrements;

  const PresetAutoConfigurationWrite({
    required this.settings,
    required this.exerciseIncrements,
    required this.exerciseLastSetIndices,
    required this.setIncrements,
  });
}

/// Complete editable exercise-definition state committed as one unit.
class ExerciseDefinitionWrite {
  final ExerciseDefinition definition;
  final bool useManualMuscles;
  final List<int> muscleIds;
  final Map<int, double> musclePercents;
  final Set<int> equipmentIds;
  final Map<int, double> bodyPartPercents;
  final List<ExerciseMediaItem> mediaItems;

  const ExerciseDefinitionWrite({
    required this.definition,
    required this.useManualMuscles,
    required this.muscleIds,
    required this.musclePercents,
    required this.equipmentIds,
    required this.bodyPartPercents,
    required this.mediaItems,
  });
}
