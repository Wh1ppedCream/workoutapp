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
}
