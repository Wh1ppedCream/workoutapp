import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';

/// Small preset fixture shared by progression editor tests. Never opens SQLite.
class PresetRepositoryFixture extends AppRepository {
  PresetRepositoryFixture({this.includeChildSet = true});
  final bool includeChildSet;
  PresetAutoConfigurationWrite? autoWrite;
  bool failAutoSave = false;
  int autoSaveCalls = 0;

  @override
  Future<PresetDefinition?> fetchPresetById(int presetId) async =>
      PresetDefinition(
        id: presetId,
        name: 'Test preset',
        createdAt: DateTime.utc(2026),
      );
  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async =>
      [
        {'id': 11, 'type': 'weight', 'exercise_def_id': 21},
      ];
  @override
  Future<Map<String, String?>> fetchDefinitionInfo(int defId) async => {
    'name': 'Squat',
    'equipmentName': 'Barbell',
  };
  @override
  Future<List<Map<String, dynamic>>> fetchPresetSets(
    int presetExerciseId,
  ) async => [
    {'id': 101, 'parent_set_id': null, 'weight': 20.0, 'reps': 8},
    {'id': 102, 'parent_set_id': null, 'weight': 25.0, 'reps': 6},
    if (includeChildSet)
      {'id': 103, 'parent_set_id': 101, 'weight': 20.0, 'reps': 8},
  ];
  @override
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async =>
      null;
  @override
  Future<Map<String, dynamic>?> fetchPresetExerciseAuto(
    int presetExerciseId,
  ) async => null;
  @override
  Future<Map<String, dynamic>?> fetchPresetSetAuto(int presetSetId) async =>
      null;
  @override
  Future<void> savePresetAutoConfigurationAtomic({
    required int presetId,
    required PresetAutoConfigurationWrite configuration,
  }) async {
    autoSaveCalls++;
    if (failAutoSave) throw StateError('Injected save failure');
    autoWrite = configuration;
  }
}
