// File: lib/db/exercise_dao.dart

import 'package:sqflite/sqflite.dart';

/// Data Access Object for exercise instances within workout sessions.
///
/// Provides methods for inserting, querying, and deleting exercises,
/// including legacy support for weight-only insertions and
/// generic CRUD operations by exercise type.
class ExerciseDao {
  /// Legacy helper for inserting weight-only exercises.
  ///
  /// Steps:
  ///  1) Resolves [equipmentName] to an equipment ID if present.
  ///  2) Finds or creates an [exercise_definitions] entry for [name] and equipment.
  ///  3) Inserts into [exercises] with default type 'weight'.
  ///
  /// Returns the newly created exercise row ID.
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

    // 3. Insert the exercise instance
    return db.insert('exercises', {
      'session_id':      sessionId,
      'exercise_def_id': defId,
      'order_index':     orderIndex,
      // 'type' omitted => defaults to 'weight'
    });
  }

  /// Inserts an exercise row of any type ('weight', 'cardio', 'stretch').
  ///
  /// - [db]: Open database instance.
  /// - [exerciseDefId]: Optional reference to an exercise_definitions ID.
  /// - [type]: String constant indicating exercise category.
  /// - [orderIndex]: Sequence order within the session.
  /// - [sessionId]: Parent session identifier.
  ///
  /// Returns the inserted row's ID.
  static Future<int> insertExerciseRow({
    required Database db,
    int? exerciseDefId,
    required String type,
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

  /// Retrieves all exercises for a given session, ordered by `order_index`.
  ///
  /// - [db]: Open database instance.
  /// - [sessionId]: ID of the session to query.
  ///
  /// Returns a list of maps representing the exercise rows.
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

  /// Deletes all exercises for a specific session.
  ///
  /// Cascades deletions to related sets, cardio, and stretch tables.
  ///
  /// Returns when the delete operation completes.
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

  /// Retrieves a single exercise row by its ID, or null if not found.
  ///
  /// - [db]: Open database instance.
  /// - [exerciseId]: ID of the exercise to fetch.
  ///
  /// Returns a map of column values or null.
  static Future<Map<String, dynamic>?> getExerciseById(
      Database db, int exerciseId) {
    return db
        .query(
          'exercises',
          where: 'id = ?',
          whereArgs: [exerciseId],
          limit: 1,
        )
        .then((rows) => rows.isNotEmpty ? rows.first : null);
  }

  /// Deletes a single exercise by its ID.
  ///
  /// - [db]: Open database instance.
  /// - [exerciseId]: ID of the exercise to remove.
  ///
  /// Returns the number of rows deleted (0 or 1).
  static Future<int> deleteExerciseById(
      Database db, int exerciseId) {
    return db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [exerciseId],
    );
  }
}
