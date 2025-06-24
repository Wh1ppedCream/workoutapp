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
  final int    id;
  final int?   exerciseDefId;
  final String type;
  final int   orderIndex;

  // New:
  final String name;
  final String equipment;

  PresetExercise({
    required this.id,
    this.exerciseDefId,
    required this.type,
    required this.orderIndex,
    this.name = '',
    this.equipment = '',
  });
}


/// A full Preset, including its definition, exercises, and all detail data.
///
/// - [definition]: The PresetDefinition metadata.
/// - [exercises]: List of PresetExercise entries.
/// - [presetSets]: Map of parent+child weight sets by exercise ID.
/// - [presetCardioDetails]: Map of cardio detail rows by exercise ID.
/// - [presetStretchItems]: Map of stretch item rows by exercise ID.
// ─── before FullPreset ──────────────────────────────────────
class FullPreset {
  final PresetDefinition definition;
  final List<PresetExercise> exercises;

  /// For each PresetExercise ID: the list of parent sets
  final Map<int, List<ExerciseSet>> presetSets;

  // ─── add this line ─────────────────────────────────────────
  /// For each PresetExercise ID: map parentIndex → list of change-sets
  final Map<int, Map<int, List<ExerciseSet>>> changeSetsMap;

  final Map<int, Map<String, dynamic>> presetCardioDetails;
  final Map<int, List<Map<String, dynamic>>> presetStretchItems;

  FullPreset({
    required this.definition,
    required this.exercises,
    required this.presetSets,
    // ─── include in constructor ─────────────────────────────
    required this.changeSetsMap,
    required this.presetCardioDetails,
    required this.presetStretchItems,
  });
}

