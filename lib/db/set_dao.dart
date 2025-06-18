// File: lib/db/set_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

/// Encapsulates set‐related CRUD operations.
class SetDao {
  /// Inserts a single set row.
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

  /// Inserts parent sets and their child ChangeSets.
  static Future<void> insertWeightSets({
    required Database db,
    required int exerciseId,
    required List<ExerciseSet> parentSets,
    required Map<int, List<ExerciseSet>> childChangeSets,
  }) async {
    for (var i = 0; i < parentSets.length; i++) {
      final parent = parentSets[i];
      // 1) Insert parent
      final parentId = await db.insert('sets', {
        'exercise_id':   exerciseId,
        'weight':        parent.weight,
        'reps':          parent.reps,
        'order_index':   i,
        'parent_set_id': null,
      });
      // 2) Insert its children (if any)
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

  /// Retrieves all sets for an exercise, ordered.
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

static Future<List<Map<String,dynamic>>> getParentSets(
    Database db,int exerciseId
  ) {
    return db.query(
      'sets',
      where:    'exercise_id = ? AND parent_set_id IS NULL',
      whereArgs:[exerciseId],
      orderBy:  'order_index',
    );
  }
  static Future<List<Map<String,dynamic>>> getChildSets(
    Database db,int parentId
  ) {
    return db.query(
      'sets',
      where:    'parent_set_id = ?',
      whereArgs:[parentId],
      orderBy:  'order_index',
    );
  }

/// Updates the weight & reps of a single set.
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

 /// Deletes a single set (parent or child) by its ID.
  static Future<void> deleteSet(
    Database db,
    int setId,
 ) {
    return db.delete(
      'sets',
      where: 'id = ?',
      whereArgs: [setId],
    );
  }

  /// Reorders a flat list of set IDs for an exercise by assigning
  /// each ID a new order_index according to its position in [setIds].
  static Future<void> reorderSets(
    Database db,
    int exerciseId,
    List<int> setIds,
  ) async {
    // Only the passed IDs are reordered; assumes they all belong
    // to the given exerciseId.
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
