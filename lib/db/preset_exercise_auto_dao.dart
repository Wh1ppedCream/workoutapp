// File: lib/db/preset_exercise_auto_dao.dart

import 'package:sqflite/sqflite.dart';

/// DAO for managing per-exercise automatic‐preset overrides.
class PresetExerciseAutoDao {
  /// Reads the auto settings for a given preset_exercise.
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
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Inserts or updates the auto override for a preset exercise.
  static Future<void> upsertExerciseAuto(
    Database db, {
    required int presetExerciseId,
    double? incrementAmount,
    required int lastSetIndex,
    String? lastNode,               // ← new
  }) async {
    await db.insert(
      'preset_exercise_auto',
      {
        'preset_exercise_id': presetExerciseId,
        'increment_amount':   incrementAmount,
        'last_set_index':     lastSetIndex,
        'last_node':          lastNode,   // ← store the key of the last node
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes the auto override for a preset exercise.
  static Future<int> deleteExerciseAuto(
    Database db,
    int presetExerciseId,
  ) {
    return db.delete(
      'preset_exercise_auto',
      where: 'preset_exercise_id = ?',
      whereArgs: [presetExerciseId],
    );
  }

}
