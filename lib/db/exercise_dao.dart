// File: lib/db/exercise_dao.dart

import 'package:sqflite/sqflite.dart';

/// Encapsulates exercise CRUD operations.
class ExerciseDao {
  /// Legacy helper for weight‐only exercises.
  static Future<int> insertExercise(
    Database db,
    int sessionId,
    String name,
    String equipmentName,
    int orderIndex,
  ) async {
    // 1. Lookup equipment_id
    final eq = await db.query(
      'equipment',
      where: 'name = ?',
      whereArgs: [equipmentName],
      limit: 1,
    );
    final eqId = eq.isNotEmpty ? eq.first['id'] as int : null;

    // 2. Lookup or insert into exercise_definitions
    final defRows = await db.query(
      'exercise_definitions',
      where: eqId != null
          ? 'name = ? AND equipment_id = ?'
          : 'name = ? AND equipment_id IS NULL',
      whereArgs: eqId != null ? [name, eqId] : [name],
      limit: 1,
    );
    final defId = defRows.isNotEmpty
        ? defRows.first['id'] as int
        : await db.insert(
            'exercise_definitions',
            {'name': name, 'equipment_id': eqId},
          );

    // 3. Insert the exercise instance (defaults to 'weight')
    return db.insert('exercises', {
      'session_id':      sessionId,
      'exercise_def_id': defId,
      'order_index':     orderIndex,
      // 'type' omitted => defaults to 'weight'
    });
  }

  /// Inserts an exercise of any type. Returns the new row’s id.
  static Future<int> insertExerciseRow({
    required Database db,
    int?    exerciseDefId,
    required String type,   // 'weight' | 'cardio' | 'stretch'
    required int orderIndex,
    required int sessionId,
  }) {
    return db.insert('exercises', {
      'session_id':      sessionId,
      'exercise_def_id': exerciseDefId,
      'type':            type,
      'order_index':     orderIndex,
    });
  }

  /// Fetches all exercises for a session, ordered by `order_index`.
  static Future<List<Map<String, dynamic>>> getExercisesForSession(
    Database db,
    int sessionId,
  ) {
    return db.query(
      'exercises',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'order_index',
    );
  }

  /// Deletes all exercises for a session (cascades sets/cardio/stretch).
  static Future<void> deleteExercisesForSession(
    Database db,
    int sessionId,
  ) {
    return db.delete(
      'exercises',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }
}
