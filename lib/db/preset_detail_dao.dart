// File: lib/db/preset_detail_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/models.dart';
import 'db_query_utils.dart';

/// Data Access Object for preset-specific detail tables:
/// sets, cardio details, and stretch items.
class PresetDetailDao {
  static Map<String, Object?> _presetSetValues({
    required int presetExerciseId,
    required double weight,
    required int reps,
    required int orderIndex,
    int? parentSetId,
  }) {
    return {
      'preset_exercise_id': presetExerciseId,
      'weight': weight,
      'reps': reps,
      'order_index': orderIndex,
      'parent_set_id': parentSetId,
    };
  }

  static Map<String, Object?> _presetCardioValues({
    required int presetExerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) {
    return {
      'preset_exercise_id': presetExerciseId,
      'cardio_name': cardioName,
      'note': note,
      'planned_minutes': plannedMinutes,
      'elapsed_seconds': elapsedSeconds,
    };
  }

  static int _intFlag(Object? rawValue) {
    return rawValue is bool ? (rawValue ? 1 : 0) : rawValue as int;
  }

  /// Inserts parent and child weight sets for a preset exercise.
  static Future<void> insertPresetSets({
    required Database db,
    required int presetExerciseId,
    required List<ExerciseSet> parentSets,
    required Map<int, List<ExerciseSet>> childChangeSets,
  }) async {
    if (parentSets.isEmpty) return;

    await db.transaction((txn) async {
      for (var i = 0; i < parentSets.length; i++) {
        final parent = parentSets[i];
        final parentId = await txn.insert(
          'preset_sets',
          _presetSetValues(
            presetExerciseId: presetExerciseId,
            weight: parent.weight,
            reps: parent.reps,
            orderIndex: i,
          ),
        );
        final children = childChangeSets[i];
        if (children == null) continue;
        for (var j = 0; j < children.length; j++) {
          final child = children[j];
          await txn.insert(
            'preset_sets',
            _presetSetValues(
              presetExerciseId: presetExerciseId,
              weight: child.weight,
              reps: child.reps,
              orderIndex: j,
              parentSetId: parentId,
            ),
          );
        }
      }
    });
  }

  /// Retrieves all weight sets (parent and child) for a preset exercise.
  static Future<List<Map<String, dynamic>>> getPresetSets(
    Database db,
    int presetExerciseId,
  ) {
    return db.query(
      'preset_sets',
      where: 'preset_exercise_id = ?',
      whereArgs: [presetExerciseId],
      orderBy: 'order_index',
    );
  }

  /// Inserts cardio details for a preset exercise.
  static Future<void> insertPresetCardioDetails({
    required Database db,
    required int presetExerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) async {
    await db.insert(
      'preset_cardio_details',
      _presetCardioValues(
        presetExerciseId: presetExerciseId,
        cardioName: cardioName,
        note: note,
        plannedMinutes: plannedMinutes,
        elapsedSeconds: elapsedSeconds,
      ),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves cardio details for a preset exercise.
  static Future<Map<String, dynamic>?> getPresetCardioDetails(
    Database db,
    int presetExerciseId,
  ) async {
    final rows = await db.query(
      'preset_cardio_details',
      columns: ['*'], // includes elapsed_seconds
      where: 'preset_exercise_id = ?',
      whereArgs: [presetExerciseId],
      limit: 1,
    );
    return firstDynamicRow(rows);
  }

  /// Inserts stretch items for a preset exercise.
  static Future<void> insertPresetStretchItems({
    required Database db,
    required int presetExerciseId,
    required List<Map<String, dynamic>> items,
  }) async {
    if (items.isEmpty) return;

    final batch = db.batch();
    for (var i = 0; i < items.length; i++) {
      final m = items[i];
      batch.insert('preset_stretch_items', {
        'preset_exercise_id': presetExerciseId,
        'stretch_id': m['stretch_id'],
        'is_custom': _intFlag(m['is_custom']),
        // no 'is_checked' column in preset_stretch_items
        'custom_name': m['custom_name'],
        'custom_desc': m['custom_desc'],
        'order_index': m['order_index'] as int,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  /// Retrieves stretch items for a preset exercise.
  static Future<List<Map<String, dynamic>>> getPresetStretchItems(
    Database db,
    int presetExerciseId,
  ) {
    return db.query(
      'preset_stretch_items',
      where: 'preset_exercise_id = ?',
      whereArgs: [presetExerciseId],
      orderBy: 'order_index',
    );
  }

  /// Updates the weight for a preset set.
  static Future<int> updatePresetSetWeight({
    required Database db,
    required int presetSetId,
    required double weight,
  }) {
    return db.update(
      'preset_sets',
      {'weight': weight},
      where: 'id = ?',
      whereArgs: [presetSetId],
    );
  }

  /// Update just the `reps` column for one preset_set.
  static Future<void> updatePresetSetReps({
    required Database db,
    required int presetSetId,
    required int reps,
  }) async {
    await db.update(
      'preset_sets',
      {'reps': reps},
      where: 'id = ?',
      whereArgs: [presetSetId],
    );
  }

  /// Insert one new set into `preset_sets`.
  /// If you want to clone a set, pass weight & reps from an existing row.
  static Future<int> addPresetSet({
    required Database db,
    required int presetExerciseId,
    required double weight,
    required int reps,
    required int orderIndex,
    int? parentSetId,
  }) async {
    return db.insert(
      'preset_sets',
      _presetSetValues(
        presetExerciseId: presetExerciseId,
        weight: weight,
        reps: reps,
        orderIndex: orderIndex,
        parentSetId: parentSetId,
      ),
    );
  }

  /// Delete a single preset_set by its ID.
  static Future<int> deletePresetSet({
    required Database db,
    required int presetSetId,
  }) {
    return db.delete('preset_sets', where: 'id = ?', whereArgs: [presetSetId]);
  }
}
