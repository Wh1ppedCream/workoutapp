part of '../app_repository.dart';

/// Compatibility adapter deliberately dispatches through the public repository
/// methods. No helper/backend detection and no fallback database access.
class _RepositoryPresetReadSession implements PresetReadSession {
  _RepositoryPresetReadSession(this.repository, this.presetId);

  final AppRepository repository;
  final int presetId;

  @override
  Future<PresetDefinition?> fetchPreset() =>
      repository.fetchPresetById(presetId);

  @override
  Future<List<PresetExerciseRow>> fetchExercises() async => List.unmodifiable(
    (await repository.fetchPresetExercises(presetId))
        .map(PresetExerciseRow.new),
  );

  @override
  Future<ExerciseDefinitionInfo> fetchDefinitionInfo(int definitionId) async =>
      ExerciseDefinitionInfo.fromRow(
        await repository.fetchDefinitionInfo(definitionId),
      );

  @override
  Future<List<PresetSetRow>> fetchSets(int presetExerciseId) async =>
      List.unmodifiable(
        (await repository.fetchPresetSets(presetExerciseId))
            .map(PresetSetRow.new),
      );

  @override
  Future<PresetCardioRow?> fetchCardio(int presetExerciseId) async {
    final row = await repository.fetchPresetCardio(presetExerciseId);
    return row == null ? null : PresetCardioRow(row);
  }

  @override
  Future<List<PresetStretchRow>> fetchStretchItems(
    int presetExerciseId,
  ) async => List.unmodifiable(
    (await repository.fetchPresetStretchItems(presetExerciseId))
        .map(PresetStretchRow.new),
  );

  @override
  Future<String?> fetchStretchName(int stretchId) =>
      repository.fetchStretchDefinitionNameById(stretchId);

  @override
  Future<PresetAutoSettingsRow?> fetchAutoSettings() async {
    final row = await repository.fetchPresetAutoSettings(presetId);
    return row == null ? null : PresetAutoSettingsRow(row);
  }

  @override
  Future<PresetExerciseAutoRow?> fetchExerciseAuto(int presetExerciseId) async {
    final row = await repository.fetchPresetExerciseAuto(presetExerciseId);
    return row == null ? null : PresetExerciseAutoRow(row);
  }

  @override
  Future<PresetSetAutoRow?> fetchSetAuto(int presetSetId) async {
    final row = await repository.fetchPresetSetAuto(presetSetId);
    return row == null ? null : PresetSetAutoRow(row);
  }
}
