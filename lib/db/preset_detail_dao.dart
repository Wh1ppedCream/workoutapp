// File: lib/db/preset_detail_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

/// Data Access Object for preset-specific detail tables:
/// sets, cardio details, and stretch items.
class PresetDetailDao {
  /// Inserts parent and child weight sets for a preset exercise.
  static Future<void> insertPresetSets({
    required Database db,
    required int presetExerciseId,
    required List<ExerciseSet> parentSets,
    required Map<int, List<ExerciseSet>> childChangeSets,
  }) async {
    for (var i = 0; i < parentSets.length; i++) {
      final parent = parentSets[i];
      final parentId = await db.insert('preset_sets', {
        'preset_exercise_id': presetExerciseId,
        'weight': parent.weight,
        'reps': parent.reps,
        'order_index': i,
        'parent_set_id': null,
      });
      if (childChangeSets.containsKey(i)) {
        for (var j = 0; j < childChangeSets[i]!.length; j++) {
          final child = childChangeSets[i]![j];
          await db.insert('preset_sets', {
            'preset_exercise_id': presetExerciseId,
            'weight': child.weight,
            'reps': child.reps,
            'order_index': j,
            'parent_set_id': parentId,
          });
        }
      }
    }
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
  }) {
    return db.insert(
      'preset_cardio_details',
      {
        'preset_exercise_id': presetExerciseId,
        'cardio_name': cardioName,
        'note': note,
        'planned_minutes': plannedMinutes,
      },
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
      where: 'preset_exercise_id = ?',
      whereArgs: [presetExerciseId],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Inserts stretch items for a preset exercise.
  static Future<void> insertPresetStretchItems({
    required Database db,
    required int presetExerciseId,
    required List<Map<String, dynamic>> items,
  }) async {
    for (var i = 0; i < items.length; i++) {
      final m = items[i];
      await db.insert(
        'preset_stretch_items',
        {
          'preset_exercise_id': presetExerciseId,
          'stretch_id': m['stretch_id'],
          'is_custom': m['is_custom'] ? 1 : 0,
          'custom_name': m['custom_name'],
          'custom_desc': m['custom_desc'],
          'order_index': m['order_index'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
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
}
