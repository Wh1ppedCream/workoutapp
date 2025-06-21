// File: lib/db/preset_exercise_dao.dart

import 'package:sqflite/sqflite.dart';

/// Data Access Object for exercises within a preset.
class PresetExerciseDao {
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
      {
        'preset_id': presetId,
        'exercise_def_id': exerciseDefId,
        'type': type,
        'order_index': orderIndex,
      },
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

  /// Reorders exercises within a preset.
  static Future<void> reorderExercises(
    Database db,
    int presetId,
    List<int> exerciseIds,
  ) async {
    for (var i = 0; i < exerciseIds.length; i++) {
      await db.update(
        'preset_exercises',
        {'order_index': i},
        where: 'id = ?',
        whereArgs: [exerciseIds[i]],
      );
    }
  }

  /// Deletes all exercises for a preset.
  static Future<int> deleteExercisesForPreset(
    Database db,
    int presetId,
  ) {
    return db.delete(
      'preset_exercises',
      where: 'preset_id = ?',
      whereArgs: [presetId],
    );
  }

  /// Deletes a single exercise by its ID.
static Future<int> deletePresetExercise(
  Database db,
  int presetExerciseId,
) {
  return db.delete(
    'preset_exercises',
    where: 'id = ?',
    whereArgs: [presetExerciseId],
  );
}

/// Updates an existing preset exercise’s definition or type.
static Future<int> updatePresetExercise({
  required Database db,
  required int id,
  int? exerciseDefId,
  String? type,
}) {
  final fields = <String, Object?>{};
  if (exerciseDefId != null) fields['exercise_def_id'] = exerciseDefId;
  if (type          != null) fields['type']             = type;
  if (fields.isEmpty) return Future.value(0);
  return db.update(
    'preset_exercises',
    fields,
    where: 'id = ?',
    whereArgs: [id],
  );
}

}


