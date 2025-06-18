// File: lib/db/stretch_dao.dart

import 'package:sqflite/sqflite.dart';

/// Data Access Object for stretch instances and their items.
///
/// Provides methods to insert, query, update, delete, and reorder stretch
/// instance data in the `stretch_instances` and `stretch_instance_items` tables.
class StretchDao {
  /// Inserts a new stretch instance for an exercise and its detail items.
  ///
  /// - [db]: Open database instance.
  /// - [exerciseId]: ID of the exercise to which this stretch instance belongs.
  /// - [items]: List of item maps, each containing keys:
  ///   • `stretch_id` (int?)
  ///   • `is_custom` (bool)
  ///   • `custom_name` (String?)
  ///   • `custom_desc` (String?)
  ///   • `is_checked` (bool)
  ///   • `order_index` (int)
  ///
  /// Inserts one row into `stretch_instances`, then each map into
  /// `stretch_instance_items`, using `ConflictAlgorithm.ignore` to skip
  /// duplicates.
  static Future<void> insertStretchInstance({
    required Database db,
    required int exerciseId,
    required List<Map<String, dynamic>> items,
  }) async {
    // 1) Create the container row
    await db.insert(
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

  /// Retrieves all stretch instance items for a given exercise.
  ///
  /// - [db]: Open database instance.
  /// - [exerciseId]: ID of the parent exercise.
  ///
  /// Returns a list of maps representing each row in
  /// `stretch_instance_items`, ordered by `order_index`.
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

  /// Updates fields of a single stretch instance item by its ID.
  ///
  /// - [db]: Open database instance.
  /// - [itemId]: ID of the item to update.
  /// - [stretchId]: New stretch definition ID, if updating.
  /// - [isCustom]: New custom flag, if updating.
  /// - [customName]: New custom name, if updating.
  /// - [customDesc]: New custom description, if updating.
  /// - [isChecked]: New checked state, if updating.
  /// - [orderIndex]: New ordering index, if updating.
  ///
  /// Only non-null parameters will be applied. Returns number of rows updated.
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

  /// Deletes a single stretch instance item by its ID.
  ///
  /// - [db]: Open database instance.
  /// - [itemId]: ID of the item to remove.
  ///
  /// Returns number of rows deleted.
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
  ///
  /// - [db]: Open database instance.
  /// - [exerciseId]: ID of the parent exercise whose stretch instance is removed.
  ///
  /// Deletes rows from `stretch_instance_items` then `stretch_instances`.
  static Future<void> deleteStretchInstance(
    Database db,
    int exerciseId,
  ) async {
    // Remove child items first (cascade not guaranteed)
    await db.delete(
      'stretch_instance_items',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
    // Remove the container row
    await db.delete(
      'stretch_instances',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }

  /// Reorders stretch instance items by updating their `order_index`.
  ///
  /// - [db]: Open database instance.
  /// - [exerciseId]: ID of the parent exercise.
  /// - [itemIds]: List of item IDs in desired new order.
  ///
  /// Updates each item’s `order_index` to its position in [itemIds].
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
