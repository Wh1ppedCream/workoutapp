// File: lib/db/set_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

/// Data Access Object for managing weight exercise sets and changesets.
///
/// Provides CRUD operations on the `sets` table, including parent-child
/// relationships for supersets or change sets.
class SetDao {
  /// Inserts a single parent set row for an exercise.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [exerciseId]: ID of the parent exercise.
  /// - [weight]: Weight for the set.
  /// - [reps]: Number of repetitions.
  /// - [orderIndex]: Sequence order among parent sets.
  ///
  /// Returns the newly created set row ID.
  static Future<int> insertSet(
    Database db,
    int exerciseId,
    double weight,
    int reps,
    int orderIndex,
  ) {
    return db.insert('sets', {
      'exercise_id':   exerciseId,
      'weight':        weight,
      'reps':          reps,
      'order_index':   orderIndex,
      'parent_set_id': null,
    });
  }

  /// Inserts a list of parent sets and their optional child changesets.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [exerciseId]: ID of the parent exercise.
  /// - [parentSets]: List of [ExerciseSet] representing parent sets.
  /// - [childChangeSets]: Map of parent index to list of child [ExerciseSet].
  ///
  /// Inserts parent rows with `parent_set_id` null, then for each parent
  /// index in [childChangeSets], inserts its children referencing the parent row.
  static Future<void> insertWeightSets({
    required Database db,
    required int exerciseId,
    required List<ExerciseSet> parentSets,
    required Map<int, List<ExerciseSet>> childChangeSets,
  }) async {
    for (var i = 0; i < parentSets.length; i++) {
      final parent = parentSets[i];
      // 1) Insert parent row
      final parentId = await db.insert('sets', {
        'exercise_id':   exerciseId,
        'weight':        parent.weight,
        'reps':          parent.reps,
        'order_index':   i,
        'parent_set_id': null,
      });
      // 2) Insert child change sets if any
      if (childChangeSets.containsKey(i)) {
        for (var ci = 0; ci < childChangeSets[i]!.length; ci++) {

          final child = childChangeSets[i]![ci];
          await db.insert('sets', {
            'exercise_id':   exerciseId,
            'weight':        child.weight,
            'reps':          child.reps,
            'order_index':   ci,
            'parent_set_id': parentId,
          });
        }
      }
    }
  }

  /// Retrieves all sets (parent and child) for an exercise, ordered.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [exerciseId]: ID of the parent exercise.
  ///
  /// Returns a list of maps representing each set row, ordered by `order_index`.
  static Future<List<Map<String, dynamic>>> getSetsForExercise(
    Database db,
    int exerciseId,
  ) {
    return db.query(
      'sets',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'order_index',
    );
  }

  /// Retrieves only parent sets (those with no `parent_set_id`) for an exercise.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [exerciseId]: ID of the parent exercise.
  ///
  /// Returns a list of parent set rows ordered by `order_index`.
  static Future<List<Map<String, dynamic>>> getParentSets(
    Database db,
    int exerciseId,
  ) {
    return db.query(
      'sets',
      where: 'exercise_id = ? AND parent_set_id IS NULL',
      whereArgs: [exerciseId],
      orderBy: 'order_index',
    );
  }

  /// Retrieves child sets for a given parent set row.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [parentId]: ID of the parent set row.
  ///
  /// Returns a list of child set rows ordered by `order_index`.
  static Future<List<Map<String, dynamic>>> getChildSets(
    Database db,
    int parentId,
  ) {
    return db.query(
      'sets',
      where: 'parent_set_id = ?',
      whereArgs: [parentId],
      orderBy: 'order_index',
    );
  }

  /// Updates the weight and reps of a specific set row.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [setId]: ID of the set row to update.
  /// - [weight]: New weight value.
  /// - [reps]: New rep count.
  ///
  /// Returns the number of rows affected (0 or 1).
  static Future<int> updateSet(
    Database db,
    int setId,
    double weight,
    int reps,
  ) {
    return db.update(
      'sets',
      {
        'weight': weight,
        'reps':   reps,
      },
      where: 'id = ?',
      whereArgs: [setId],
    );
  }

  /// Deletes a single set row (parent or child) by its ID.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [setId]: ID of the set to delete.
  ///
  /// Returns when deletion completes.
  static Future<void> deleteSet(
    Database db,
    int setId,
  ) async {
  await db.delete(
      'sets',
      where: 'id = ?',
      whereArgs: [setId],
    );
  }

  /// Reorders a flat list of set IDs by applying `order_index` based on list position.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [exerciseId]: ID of the parent exercise (assumed for the IDs).
  /// - [setIds]: Ordered list of set IDs to update.
  ///
  /// Updates each row’s `order_index` to its new index in [setIds].
  static Future<void> reorderSets(
    Database db,
    int exerciseId,
    List<int> setIds,
  ) async {
    for (var i = 0; i < setIds.length; i++) {
      await db.update(
        'sets',
        {'order_index': i},
        where: 'id = ?',
        whereArgs: [setIds[i]],
      );
    }
  }
}
