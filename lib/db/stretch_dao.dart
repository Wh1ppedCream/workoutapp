// File: lib/db/stretch_dao.dart

import 'package:sqflite/sqflite.dart';

/// Encapsulates stretch‐instance CRUD operations.
class StretchDao {
  /// Inserts a stretch_instances row plus its items.
  static Future<void> insertStretchInstance({
    required Database db,
    required int exerciseId,
    required List<Map<String, dynamic>> items,
  }) async {
    // 1) Create the “container” row
    await db.insert(
      'stretch_instances',
      {'exercise_id': exerciseId},
    );

    // 2) Insert each item
    for (var i = 0; i < items.length; i++) {
      final m = items[i];
      final stretchId  = m['stretch_id'] as int?;
      final isCustom   = (m['is_custom'] as bool) ? 1 : 0;
      final customName = m['custom_name']   as String?;
      final customDesc = m['custom_desc']   as String?;
      final isChecked  = (m['is_checked'] as bool) ? 1 : 0;
      final orderIndex = m['order_index']   as int;

      await db.insert(
        'stretch_instance_items',
        {
          'exercise_id': exerciseId,
          'stretch_id':  stretchId,
          'is_custom':   isCustom,
          'custom_name': customName,
          'custom_desc': customDesc,
          'is_checked':  isChecked,
          'order_index': orderIndex,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /// Fetches all items for a stretch‐instance, ordered by index.
  static Future<List<Map<String, dynamic>>> getStretchItemsForExercise(
    Database db,
    int exerciseId,
  ) {
    return db.query(
      'stretch_instance_items',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'order_index',
    );
  }
}
