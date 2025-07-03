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
    required int elapsedSeconds,
  }) async {
  await db.insert(
    'preset_cardio_details',
    {
      'preset_exercise_id': presetExerciseId,
      'cardio_name':        cardioName,
      'note':               note,
      'planned_minutes':    plannedMinutes,
      'elapsed_seconds':    elapsedSeconds,
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
    columns: ['*'],   // includes elapsed_seconds
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

    // Normalize is_custom (could be bool or int) to 0/1:
    final rawIsCustom = m['is_custom'];
    final int isCustomFlag = rawIsCustom is bool
        ? (rawIsCustom ? 1 : 0)
        : (rawIsCustom as int);

    // Normalize is_checked if you ever store it here (presets don't, but safe):

    await db.insert(
      'preset_stretch_items',
      {
        'preset_exercise_id': presetExerciseId,
        'stretch_id':         m['stretch_id'],
        'is_custom':          isCustomFlag,
        // no 'is_checked' column in preset_stretch_items
        'custom_name':        m['custom_name'],
        'custom_desc':        m['custom_desc'],
        'order_index':        m['order_index'] as int,
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



}
