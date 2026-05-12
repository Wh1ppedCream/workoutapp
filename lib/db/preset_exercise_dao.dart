// File: lib/db/preset_exercise_dao.dart

import 'package:sqflite/sqflite.dart';

/// Data Access Object for exercises within a preset.
class PresetExerciseDao {
  static Map<String, Object?> _exerciseValues({
    required int presetId,
    int? exerciseDefId,
    required String type,
    required int orderIndex,
  }) {
    return {
      'preset_id': presetId,
      'exercise_def_id': exerciseDefId,
      'type': type,
      'order_index': orderIndex,
    };
  }

  /// Inserts a new exercise into a preset.
  static Future<int> insertPresetExercise({
    required Database db,
    required int presetId,
    int? exerciseDefId,
    required String type,
    required int orderIndex,
  }) {
    return db.insert(
      'preset_exercises',
      _exerciseValues(
        presetId: presetId,
        exerciseDefId: exerciseDefId,
        type: type,
        orderIndex: orderIndex,
      ),
    );
  }

  /// Retrieves all exercises for a given preset.
  static Future<List<Map<String, dynamic>>> getExercisesForPreset(
    Database db,
    int presetId,
  ) {
    return db.query(
      'preset_exercises',
      where: 'preset_id = ?',
      whereArgs: [presetId],
      orderBy: 'order_index',
    );
  }

  /// Deletes all exercises for a preset.
  static Future<int> deleteExercisesForPreset(Database db, int presetId) {
    return db.delete(
      'preset_exercises',
      where: 'preset_id = ?',
      whereArgs: [presetId],
    );
  }
}
