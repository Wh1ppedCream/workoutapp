// File: lib/db/preset_exercise_auto_dao.dart

import 'package:sqflite/sqflite.dart';
import 'db_query_utils.dart';

/// DAO for managing per-exercise automatic-preset overrides.
class PresetExerciseAutoDao {
  static Map<String, Object?> _autoValues({
    required int presetExerciseId,
    double? incrementAmount,
    required int lastSetIndex,
    String? lastNode,
  }) {
    return {
      'preset_exercise_id': presetExerciseId,
      'increment_amount': incrementAmount,
      'last_set_index': lastSetIndex,
      'last_node': lastNode,
    };
  }

  /// Reads the auto settings for a given preset exercise.
  static Future<Map<String, dynamic>?> getExerciseAuto(
    Database db,
    int presetExerciseId,
  ) async {
    final rows = await db.query(
      'preset_exercise_auto',
      where: 'preset_exercise_id = ?',
      whereArgs: [presetExerciseId],
      limit: 1,
    );
    return firstDynamicRow(rows);
  }

  /// Inserts or updates the auto override for a preset exercise.
  static Future<void> upsertExerciseAuto(
    Database db, {
    required int presetExerciseId,
    double? incrementAmount,
    required int lastSetIndex,
    String? lastNode,
  }) async {
    await db.insert(
      'preset_exercise_auto',
      _autoValues(
        presetExerciseId: presetExerciseId,
        incrementAmount: incrementAmount,
        lastSetIndex: lastSetIndex,
        lastNode: lastNode,
      ),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes the auto override for a preset exercise.
  static Future<int> deleteExerciseAuto(Database db, int presetExerciseId) {
    return db.delete(
      'preset_exercise_auto',
      where: 'preset_exercise_id = ?',
      whereArgs: [presetExerciseId],
    );
  }
}
