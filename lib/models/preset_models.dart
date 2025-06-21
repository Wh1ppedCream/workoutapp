// File: lib/models/preset_models.dart

// Import existing models (e.g., ExerciseSet) for preset details
import 'models.dart';

/// Represents a stored Preset definition, including metadata.
///
/// - [id]: Unique database identifier for the preset.
/// - [name]: Human-readable name of the preset.
/// - [createdAt]: Timestamp when the preset was created.
class PresetDefinition {
  final int id;
  final String name;
  final DateTime createdAt;

  PresetDefinition({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}

/// A single exercise entry within a Preset.
///
/// - [id]: Unique identifier of the preset exercise row.
/// - [exerciseDefId]: Optional FK to an existing ExerciseDefinition.
/// - [type]: One of 'weight', 'cardio', or 'stretch'.
/// - [orderIndex]: Sequence order within the preset.
class PresetExercise {
  final int id;
  final int? exerciseDefId;
  final String type;
  final int orderIndex;

  PresetExercise({
    required this.id,
    this.exerciseDefId,
    required this.type,
    required this.orderIndex,
  });
}

/// A full Preset, including its definition, exercises, and all detail data.
///
/// - [definition]: The PresetDefinition metadata.
/// - [exercises]: List of PresetExercise entries.
/// - [presetSets]: Map of parent+child weight sets by exercise ID.
/// - [presetCardioDetails]: Map of cardio detail rows by exercise ID.
/// - [presetStretchItems]: Map of stretch item rows by exercise ID.
class FullPreset {
  final PresetDefinition definition;
  final List<PresetExercise> exercises;
  final Map<int, List<ExerciseSet>> presetSets;
  final Map<int, Map<String, dynamic>> presetCardioDetails;
  final Map<int, List<Map<String, dynamic>>> presetStretchItems;

  FullPreset({
    required this.definition,
    required this.exercises,
    required this.presetSets,
    required this.presetCardioDetails,
    required this.presetStretchItems,
  });
}
