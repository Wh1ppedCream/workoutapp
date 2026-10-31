import '../db/database_helper.dart';
import '../db/preset_read_dao.dart';
import '../models/models.dart';
import 'preset_read_source.dart';

/// Production-only composition choice; fakes retain the default repository
/// adapter unless they explicitly inject a different source.
class SqlitePresetReadSource implements PresetReadSource {
  const SqlitePresetReadSource(this.helper);
  final DatabaseHelper helper;

  @override
  PresetReadSession open(int presetId) =>
      _SqlitePresetReadSession(helper, presetId);
}

class _SqlitePresetReadSession implements PresetReadSession {
  _SqlitePresetReadSession(this.helper, this.presetId);
  final DatabaseHelper helper;
  final int presetId;
  Future<PresetReadSnapshot>? _loading;

  Future<PresetReadSnapshot> get _snapshot => _loading ??= _load();

  Future<PresetReadSnapshot> _load() async {
    final db = await helper.database;
    return db.transaction(
      (transaction) => PresetReadDao.load(transaction, presetId),
    );
  }

  @override
  Future<PresetDefinition?> fetchPreset() async => (await _snapshot).preset;
  @override
  Future<List<PresetExerciseRow>> fetchExercises() async =>
      (await _snapshot).exercises;
  @override
  Future<ExerciseDefinitionInfo> fetchDefinitionInfo(int id) async =>
      (await _snapshot).definitions[id] ??
      (throw Exception('Definition $id not found'));
  @override
  Future<List<PresetSetRow>> fetchSets(int id) async =>
      (await _snapshot).sets[id] ?? const [];
  @override
  Future<PresetCardioRow?> fetchCardio(int id) async =>
      (await _snapshot).cardio[id];
  @override
  Future<List<PresetStretchRow>> fetchStretchItems(int id) async =>
      (await _snapshot).stretches[id] ?? const [];
  @override
  Future<String?> fetchStretchName(int id) async =>
      (await _snapshot).stretchNames[id];
  @override
  Future<PresetAutoSettingsRow?> fetchAutoSettings() async =>
      (await _snapshot).autoSettings;
  @override
  Future<PresetExerciseAutoRow?> fetchExerciseAuto(int id) async =>
      (await _snapshot).exerciseAuto[id];
  @override
  Future<PresetSetAutoRow?> fetchSetAuto(int id) async =>
      (await _snapshot).setAuto[id];
}
