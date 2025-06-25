// File: lib/repositories/app_repository_presets.dart

import '../db/preset_definition_dao.dart';
import '../db/preset_exercise_dao.dart';
import '../db/preset_detail_dao.dart';
import 'app_repository.dart';
import '../models/preset_models.dart';
import '../models/models.dart';

/// Extension of [AppRepository] adding Preset support:
/// - CRUD operations for Preset definitions and their exercises/details
/// - A helper to clone a Preset into an active session
extension PresetRepository on AppRepository {
  // ─── PRESETS: Definition CRUD ──────────────────────────────────────
  /// Creates a new Preset with the given [name].
  ///
  /// Returns the new Preset's database ID, which can be used to add exercises.
  Future<int> createPreset(String name) async {
    final db = await dbHelper.database; // get writable db
    return PresetDefinitionDao.insertPreset(db, name);  // insert row and return ID
  }

Future<int> findOrCreatePreset(String name) async {
  final db = await dbHelper.database;
  return PresetDefinitionDao.findOrCreatePresetDefinition(db, name);
}


 /// Retrieves all Presets as raw maps.
  ///
  /// Each map contains keys:
  ///   - 'id': Preset ID
  ///   - 'name': Preset name
  ///   - 'created_at': timestamp of creation
  Future<List<Map<String, dynamic>>> fetchAllPresetsRaw() async {
    final db = await dbHelper.database;
    return PresetDefinitionDao.getAllPresetsRaw(db);
  }

/// Fetches a single Preset by its [presetId].
  ///
  /// Returns a [PresetDefinition] model or `null` if not found.
  Future<PresetDefinition?> fetchPresetById(int presetId) async {
    final db = await dbHelper.database;
    final row = await PresetDefinitionDao.getPresetById(db, presetId);
    if (row == null) return null;
    // Map raw row to model
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
  ///
  /// [presetId]: ID of the Preset to augment.
  /// [exerciseDefId]: Optional reference to an existing definition.
  /// [type]: One of 'weight', 'cardio', or 'stretch'.
  /// [orderIndex]: Position within the Preset's sequence.
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
  ///
  /// Each map contains keys: id, preset_id, exercise_def_id, type, order_index.
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async {
    final db = await dbHelper.database;
    return PresetExerciseDao.getExercisesForPreset(db, presetId);
  }

/// Deletes all exercises from a Preset (and cascades details).
  Future<void> deletePresetExercises(int presetId) async {
    final db = await dbHelper.database;
    await PresetExerciseDao.deleteExercisesForPreset(db, presetId);
  }

  // ─── PRESETS: Single-Exercise CRUD ────────────────────────────



 // ─── PRESETS: Detail CRUD ──────────────────────────────────────
  /// Saves weight sets for a Preset exercise.
  ///
  /// [parents] is the list of parent sets; [children] maps parent index → list of change sets.
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

/// Fetches weight sets (parents+children) for a Preset exercise.
  Future<List<Map<String, dynamic>>> fetchPresetSets(int presetExerciseId) async {
    final db = await dbHelper.database;
    return PresetDetailDao.getPresetSets(db, presetExerciseId);
  }

/// Saves cardio details for a Preset exercise (insert or replace).
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
      elapsedSeconds :    elapsedSeconds,
    );
  }

 /// Fetches the saved cardio details row for a Preset exercise.
  Future<Map<String, dynamic>?> fetchPresetCardio(int presetExerciseId) async {
    final db = await dbHelper.database;
    return PresetDetailDao.getPresetCardioDetails(db, presetExerciseId);
  }

/// Saves stretch items for a Preset exercise.
  ///
  /// [items] is a list of maps with keys: stretch_id, is_custom, custom_name, custom_desc, order_index.
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
  Future<List<Map<String, dynamic>>> fetchPresetStretchItems(
    int presetExerciseId,
  ) async {
    final db = await dbHelper.database;
    return PresetDetailDao.getPresetStretchItems(db, presetExerciseId);
  }

// ─── PRESETS: Fetch Full ───────────────────────────────────────




}
