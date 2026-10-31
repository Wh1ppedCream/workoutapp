import '../models/models.dart';

/// Explicit opt-in backend for a single preset load. An absent source uses
/// the repository's overridable single-item APIs, including test fakes.
abstract interface class PresetReadSource {
  PresetReadSession open(int presetId);
}

/// One load's typed reads. A backend may serve a consistent prefetched snapshot;
/// the compatibility implementation performs the existing individual reads.
abstract interface class PresetReadSession {
  Future<PresetDefinition?> fetchPreset();
  Future<List<PresetExerciseRow>> fetchExercises();
  Future<ExerciseDefinitionInfo> fetchDefinitionInfo(int definitionId);
  Future<List<PresetSetRow>> fetchSets(int presetExerciseId);
  Future<PresetCardioRow?> fetchCardio(int presetExerciseId);
  Future<List<PresetStretchRow>> fetchStretchItems(int presetExerciseId);
  Future<String?> fetchStretchName(int stretchId);
  Future<PresetAutoSettingsRow?> fetchAutoSettings();
  Future<PresetExerciseAutoRow?> fetchExerciseAuto(int presetExerciseId);
  Future<PresetSetAutoRow?> fetchSetAuto(int presetSetId);
}
