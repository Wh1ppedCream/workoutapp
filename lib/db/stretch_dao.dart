// File: lib/db/stretch_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/models.dart';
import 'db_query_utils.dart';

/// Data Access Object for stretch instances and their items.
///
/// Provides methods to insert, query, update, delete, and reorder stretch
/// instance data in the `stretch_instances` and `stretch_instance_items` tables.
class StretchDao {
  static Map<String, Object?> _stretchItemValues(
    int exerciseId,
    StretchInstance item,
  ) {
    return {
      'exercise_id': exerciseId,
      'stretch_id': item.stretchId,
      'is_custom': sqliteBool(item.isCustom),
      'custom_name': item.customName,
      'custom_desc': item.customDesc,
      'is_checked': sqliteBool(item.isChecked),
      'order_index': item.orderIndex,
    };
  }

  /// Inserts all detail items for a stretch-type exercise directly using exercise_id
  static Future<void> insertStretchInstance({
    required Database db,
    required int exerciseId,
    required List<StretchInstance> items,
  }) async {
    if (items.isEmpty) return;

    // We no longer need the 'stretch_instances' table,
    // just insert items with the real exercise_id.
    final batch = db.batch();
    for (var m in items) {
      batch.insert(
        'stretch_instance_items',
        _stretchItemValues(exerciseId, m),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Loads the items by exercise_id
  static Future<List<StretchInstance>> getStretchItemsForExercise(
    Database db,
    int exerciseId,
  ) async {
    final rows = await db.query(
      'stretch_instance_items',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'order_index',
    );
    return rows.map(StretchInstance.fromMap).toList();
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
    if (stretchId != null) fields['stretch_id'] = stretchId;
    if (isCustom != null) fields['is_custom'] = sqliteBool(isCustom);
    if (customName != null) fields['custom_name'] = customName;
    if (customDesc != null) fields['custom_desc'] = customDesc;
    if (isChecked != null) fields['is_checked'] = sqliteBool(isChecked);
    if (orderIndex != null) fields['order_index'] = orderIndex;

    if (fields.isEmpty) return Future.value(0);
    return db.update(
      'stretch_instance_items',
      fields,
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  /// Deletes a single stretch instance item by its ID.
  static Future<int> deleteStretchItem(Database db, int itemId) {
    return db.delete(
      'stretch_instance_items',
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  /// Deletes all items for an exercise.
  static Future<void> deleteStretchInstance(Database db, int exerciseId) async {
    await db.delete(
      'stretch_instance_items',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }

  /// Reorders items by exercise_id and item ids
  static Future<void> reorderStretchItems(
    Database db,
    int exerciseId,
    List<int> itemIds,
  ) async {
    if (itemIds.isEmpty) return;

    final batch = db.batch();
    for (var i = 0; i < itemIds.length; i++) {
      batch.update(
        'stretch_instance_items',
        {'order_index': i},
        where: 'exercise_id = ? AND id = ?',
        whereArgs: [exerciseId, itemIds[i]],
      );
    }
    await batch.commit(noResult: true);
  }
}
