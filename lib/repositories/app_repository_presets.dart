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

/// Changes the order of exercises within a Preset.
  ///
  /// [ids] is the list of PresetExercise IDs in the desired new order.
  Future<void> reorderPresetExercises(int presetId, List<int> ids) async {
    final db = await dbHelper.database;
    await PresetExerciseDao.reorderExercises(db, presetId, ids);
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

  /// Deletes one exercise from a Preset.
  Future<void> deletePresetExercise(int presetExerciseId) async {
    final db = await dbHelper.database;
    await PresetExerciseDao.deletePresetExercise(db, presetExerciseId);
  }

  /// Updates fields of an existing preset exercise.
  Future<void> updatePresetExercise(
    int presetExerciseId, {
    int? exerciseDefId,
    String? type,
  }) async {
    final db = await dbHelper.database;
    await PresetExerciseDao.updatePresetExercise(
      db: db,
      id: presetExerciseId,
      exerciseDefId: exerciseDefId,
      type: type,
    );
  }

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

  /// Fetches a full preset including its exercises and all their details.
  Future<FullPreset?> fetchFullPreset(int presetId) async {
    // 1) definition
    final def = await fetchPresetById(presetId);
    if (def == null) return null;

    // 2) exercises
    final rawExs = await fetchPresetExercises(presetId);
    final exs = rawExs.map((r) => PresetExercise(
      id:            r['id']                as int,
      exerciseDefId: r['exercise_def_id']   as int?,
      type:          r['type']              as String,
      orderIndex:    r['order_index']       as int,
    )).toList();

      // 4) details maps
  final setsMap       = <int, List<ExerciseSet>>{};
  final changeSetsMap = <int, Map<int, List<ExerciseSet>>>{};
  final cardioMap     = <int, Map<String, dynamic>>{};
  final stretchMap    = <int, List<Map<String, dynamic>>>{};

  for (var ex in exs) {
    // --- parent vs change-sets split ---
    final rawSets      = await fetchPresetSets(ex.id);
    final parents      = <ExerciseSet>[];
    final childrenMap  = <int, List<ExerciseSet>>{};
    final idToParentIx = <int, int>{};

    for (var row in rawSets) {
      final rowId    = row['id']            as int;
      final parentId = row['parent_set_id'] as int?;
      final set = ExerciseSet(
        weight: (row['weight'] as num).toDouble(),
        reps:   row['reps']   as int,
      );

      if (parentId == null) {
        idToParentIx[rowId] = parents.length;
        parents.add(set);
      } else {
        final pIx = idToParentIx[parentId]!;
        (childrenMap[pIx] ??= []).add(set);
      }
    }

    setsMap[ex.id]       = parents;
    changeSetsMap[ex.id] = childrenMap;

    // --- cardio & stretch as before ---
    final c = await fetchPresetCardio(ex.id);
    if (c != null) cardioMap[ex.id] = c;
    stretchMap[ex.id] = await fetchPresetStretchItems(ex.id);
  }

  return FullPreset(
    definition:          def,
    exercises:           exs,
    presetSets:          setsMap,
    changeSetsMap:       changeSetsMap,      // pass in here
    presetCardioDetails: cardioMap,
    presetStretchItems:  stretchMap,
  );


  }

// ─── CLONING: Preset → Active Session ─────────────────────────────────────
  /// Clones a Preset into a new workout session.
  ///
  /// - Creates a new session at the current time.
  /// - Iterates each PresetExercise and replays its data into the session.
  ///   • For 'weight', reuses addWeightSets
  ///   • For 'cardio', calls saveCardioDetails
  ///   • For 'stretch', calls saveStretchInstance
  ///
  /// Returns the newly created session ID.
  Future<int> startSessionFromPreset(int presetId) async {
    final preset = await fetchPresetById(presetId);
    if (preset == null) throw Exception('Preset $presetId not found');
    final nowIso = DateTime.now().toIso8601String();
    final sessionId = await createSession(nowIso, 0);


    final exercises = await fetchPresetExercises(presetId);
    for (var ex in exercises) {
      final exId = await addExerciseRow(
        exerciseDefId: ex['exercise_def_id'] as int?,
        type: ex['type'] as String,
        orderIndex: ex['order_index'] as int,
        sessionId: sessionId,
      );

      if (ex['type'] == 'weight') {
        final rawSets = await fetchPresetSets(ex['id'] as int);
        final parents = <ExerciseSet>[];
        final children = <int, List<ExerciseSet>>{};
        final indexMap = <int, int>{};
        for (var row in rawSets) {
          final id = row['id'] as int;
          final parentId = row['parent_set_id'] as int?;
          final set = ExerciseSet(
            weight: (row['weight'] as num).toDouble(),
            reps: row['reps'] as int,
          );
          if (parentId == null) {
            indexMap[id] = parents.length;
            parents.add(set);
          } else {
            final pIdx = indexMap[parentId]!;
            children.putIfAbsent(pIdx, () => []).add(set);
          }
        }
        await addWeightSets(
          exerciseId: exId,
          parentSets: parents,
          childChangeSets: children,
        );
      } else if (ex['type'] == 'cardio') {
        final c = await fetchPresetCardio(ex['id'] as int);
        if (c != null) {
          await saveCardioDetails(
            exerciseId: exId,
            cardioName: c['cardio_name'] as String,
            note: c['note'] as String?,
            plannedMinutes: c['planned_minutes'] as int,
            elapsedSeconds: 0,
          );
        }
      } else if (ex['type'] == 'stretch') {
        final items = await fetchPresetStretchItems(ex['id'] as int);
        await saveStretchInstance(
          exerciseId: exId,
          items: items,
        );
      }
    }
    return sessionId;
  }
}
