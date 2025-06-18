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

/// Updates one stretch‐instance item by its ID.
  static Future<int> updateStretchItem({
    required Database db,
    required int itemId,
    int? stretchId,
    bool? isCustom,
    String? customName,
    String? customDesc,
    bool? isChecked,
    int? orderIndex,
  }) {
    final fields = <String, Object?>{};
    if (stretchId   != null) fields['stretch_id']   = stretchId;
    if (isCustom    != null) fields['is_custom']    = isCustom ? 1 : 0;
    if (customName  != null) fields['custom_name']  = customName;
    if (customDesc  != null) fields['custom_desc']  = customDesc;
    if (isChecked   != null) fields['is_checked']   = isChecked ? 1 : 0;
    if (orderIndex  != null) fields['order_index']  = orderIndex;

    if (fields.isEmpty) return Future.value(0);
    return db.update(
      'stretch_instance_items',
      fields,
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  /// Deletes one stretch‐instance item by its ID.
  static Future<int> deleteStretchItem(
    Database db,
    int itemId,
  ) {
    return db.delete(
      'stretch_instance_items',
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  /// Deletes an entire stretch instance (both container & its items).
  static Future<void> deleteStretchInstance(
    Database db,
    int exerciseId,
  ) async {
    // items table has FK ON DELETE CASCADE if you set it up; if not, delete explicitly:
    await db.delete(
      'stretch_instance_items',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
    await db.delete(
      'stretch_instances',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }

  /// Reorders the given list of item IDs under one exercise.
  static Future<void> reorderStretchItems(
    Database db,
    int exerciseId,
    List<int> itemIds,
  ) async {
    for (var i = 0; i < itemIds.length; i++) {
      await db.update(
        'stretch_instance_items',
        {'order_index': i},
        where: 'id = ?',
        whereArgs: [itemIds[i]],
      );
    }
  }

}
