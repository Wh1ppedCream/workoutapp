// File: lib/repositories/app_repository_presets.dart

import '../db/preset_definition_dao.dart';
import '../db/preset_exercise_dao.dart';
import '../db/preset_detail_dao.dart';
import 'app_repository.dart';
import '../models/preset_models.dart';
import '../models/models.dart';

/// Extension of [AppRepository] adding Preset support:
/// - CRUD operations for Preset definitions and their exercises/details
/// - Ability to scope presets to a GymProfile via profileId
extension PresetRepository on AppRepository {
  // ─── PRESETS: Definition CRUD ──────────────────────────────────────

  /// Creates a new Preset with the given [name], optionally scoped to [profileId].
  /// Returns the new Preset's database ID.
  Future<int> createPreset(
    String name, {
    int? profileId,
  }) async {
    final db = await dbHelper.database;
    return PresetDefinitionDao.insertPreset(
      db,
      name,
      profileId: profileId,
    );
  }

  /// Finds an existing Preset by [name] and optional [profileId], or creates one.
  /// Returns the Preset's database ID.
  Future<int> findOrCreatePreset(
    String name, {
    int? profileId,
  }) async {
    final db = await dbHelper.database;
    return PresetDefinitionDao.findOrCreatePresetDefinition(
      db,
      name,
      profileId: profileId,
    );
  }

  /// Retrieves all Presets as raw maps, scoped to [profileId] if provided.
  Future<List<Map<String, dynamic>>> fetchAllPresetsRaw({
    int? profileId,
  }) async {
    final db = await dbHelper.database;
    return PresetDefinitionDao.getAllPresetsRaw(
      db,
      profileId: profileId,
    );
  }

  /// Fetches a single Preset by its [presetId].
  Future<PresetDefinition?> fetchPresetById(int presetId) async {
    final db = await dbHelper.database;
    final row = await PresetDefinitionDao.getPresetById(db, presetId);
    if (row == null) return null;
    return PresetDefinition(
      id: row['id'] as int,
      name: row['name'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  /// Updates the name of an existing Preset.
  Future<void> updatePresetName(int presetId, String name) async {
    final db = await dbHelper.database;
    await PresetDefinitionDao.updatePresetName(db, presetId, name);
  }

  /// Deletes a Preset and cascades removal of its exercises and details.
  Future<void> deletePreset(int presetId) async {
    final db = await dbHelper.database;
    await PresetDefinitionDao.deletePreset(db, presetId);
  }

  // ─── PRESETS: Exercise CRUD ──────────────────────────────────────

  /// Adds a new exercise to a Preset.
  Future<int> addExerciseToPreset(
    int presetId,
    int? exerciseDefId,
    String type,
    int orderIndex,
  ) async {
    final db = await dbHelper.database;
    return PresetExerciseDao.insertPresetExercise(
      db: db,
      presetId: presetId,
      exerciseDefId: exerciseDefId,
      type: type,
      orderIndex: orderIndex,
    );
  }

  /// Retrieves raw exercise rows for a given Preset.
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async {
    final db = await dbHelper.database;
    return PresetExerciseDao.getExercisesForPreset(db, presetId);
  }

  /// Deletes all exercises from a Preset.
  Future<void> deletePresetExercises(int presetId) async {
    final db = await dbHelper.database;
    await PresetExerciseDao.deleteExercisesForPreset(db, presetId);
  }

  // ─── PRESETS: Detail CRUD ──────────────────────────────────────

  /// Saves weight sets for a Preset exercise.
  Future<void> savePresetWeightSets(
    int presetExerciseId,
    List<ExerciseSet> parents,
    Map<int, List<ExerciseSet>> children,
  ) async {
    final db = await dbHelper.database;
    await PresetDetailDao.insertPresetSets(
      db: db,
      presetExerciseId: presetExerciseId,
      parentSets: parents,
      childChangeSets: children,
    );
  }

  /// Fetches weight sets for a Preset exercise.
  Future<List<Map<String, dynamic>>> fetchPresetSets(int presetExerciseId) async {
    final db = await dbHelper.database;
    return PresetDetailDao.getPresetSets(db, presetExerciseId);
  }

  /// Saves cardio details for a Preset exercise.
  Future<void> savePresetCardio(
    int presetExerciseId,
    String cardioName,
    String? note,
    int plannedMinutes,
    int elapsedSeconds,
  ) async {
    final db = await dbHelper.database;
    await PresetDetailDao.insertPresetCardioDetails(
      db: db,
      presetExerciseId: presetExerciseId,
      cardioName: cardioName,
      note: note,
      plannedMinutes: plannedMinutes,
      elapsedSeconds: elapsedSeconds,
    );
  }

  /// Fetches the saved cardio details row for a Preset exercise.
  Future<Map<String, dynamic>?> fetchPresetCardio(int presetExerciseId) async {
    final db = await dbHelper.database;
    return PresetDetailDao.getPresetCardioDetails(db, presetExerciseId);
  }

  /// Saves stretch items for a Preset exercise.
  Future<void> savePresetStretch(
    int presetExerciseId,
    List<Map<String, dynamic>> items,
  ) async {
    final db = await dbHelper.database;
    await PresetDetailDao.insertPresetStretchItems(
      db: db,
      presetExerciseId: presetExerciseId,
      items: items,
    );
  }

  /// Fetches stored stretch items for a Preset exercise.
  Future<List<Map<String, dynamic>>> fetchPresetStretchItems(int presetExerciseId) async {
    final db = await dbHelper.database;
    return PresetDetailDao.getPresetStretchItems(db, presetExerciseId);
  }
}
