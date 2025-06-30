// File: lib/db/stretch_dao.dart

import 'package:sqflite/sqflite.dart';

/// Data Access Object for stretch instances and their items.
///
/// Provides methods to insert, query, update, delete, and reorder stretch
/// instance data in the `stretch_instances` and `stretch_instance_items` tables.
class StretchDao {
  /// Inserts a new stretch instance for an exercise and its detail items.
  static Future<void> insertStretchInstance({
    required Database db,
    required int exerciseId,
    required List<Map<String, dynamic>> items,
  }) async {
    // 1) Create the container row and get its id
    final instanceId = await db.insert(
      'stretch_instances',
      {'exercise_id': exerciseId},
    );

    // 2) Insert each detail item
    for (var i = 0; i < items.length; i++) {
      final m = items[i];
      final stretchId  = m['stretch_id'] as int?;
      final isCustom   = (m['is_custom'] as bool) ? 1 : 0;
      final customName = m['custom_name'] as String?;
      final customDesc = m['custom_desc'] as String?;
      final isChecked  = (m['is_checked'] as bool) ? 1 : 0;
      final orderIndex = m['order_index'] as int;

      await db.insert(
        'stretch_instance_items',
        {
          'instance_id':  instanceId,
          'stretch_id':   stretchId,
          'is_custom':    isCustom,
          'custom_name':  customName,
          'custom_desc':  customDesc,
          'is_checked':   isChecked,
          'order_index':  orderIndex,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /// Retrieves all stretch instance items for a given exercise.
  static Future<List<Map<String, dynamic>>> getStretchItemsForExercise(
    Database db,
    int exerciseId,
  ) {
    return db.rawQuery('''
      SELECT sii.*
        FROM stretch_instance_items sii
        JOIN stretch_instances si ON sii.instance_id = si.id
       WHERE si.exercise_id = ?
       ORDER BY sii.order_index
    ''', [exerciseId]);
  }

  /// Updates fields of a single stretch instance item by its ID.
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
    if (stretchId   != null) fields['stretch_id']  = stretchId;
    if (isCustom    != null) fields['is_custom']   = isCustom ? 1 : 0;
    if (customName  != null) fields['custom_name'] = customName;
    if (customDesc  != null) fields['custom_desc'] = customDesc;
    if (isChecked   != null) fields['is_checked']  = isChecked ? 1 : 0;
    if (orderIndex  != null) fields['order_index'] = orderIndex;

    if (fields.isEmpty) return Future.value(0);
    return db.update(
      'stretch_instance_items',
      fields,
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  /// Deletes a single stretch instance item by its ID.
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

  /// Deletes an entire stretch instance and its items.
  static Future<void> deleteStretchInstance(
    Database db,
    int exerciseId,
  ) async {
    // 1) find instance id
    final rows = await db.query(
      'stretch_instances',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final instanceId = rows.first['id'] as int;

    // 2) Delete child items
    await db.delete(
      'stretch_instance_items',
      where: 'instance_id = ?',
      whereArgs: [instanceId],
    );
    // 3) Delete container row
    await db.delete(
      'stretch_instances',
      where: 'id = ?',
      whereArgs: [instanceId],
    );
  }

  /// Reorders stretch instance items by updating their `order_index`.
  static Future<void> reorderStretchItems(
    Database db,
    int exerciseId,
    List<int> itemIds,
  ) async {
    // 1) find instance id
    final rows = await db.query(
      'stretch_instances',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final instanceId = rows.first['id'] as int;

    // 2) reorder items by itemIds order
    for (var i = 0; i < itemIds.length; i++) {
      await db.update(
        'stretch_instance_items',
        {'order_index': i},
        where: 'instance_id = ? AND id = ?',
        whereArgs: [instanceId, itemIds[i]],
      );
    }
  }
}
