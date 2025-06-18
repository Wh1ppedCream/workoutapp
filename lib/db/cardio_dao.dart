// File: lib/db/cardio_dao.dart

import 'package:sqflite/sqflite.dart';

/// Encapsulates cardio‐related CRUD operations.
class CardioDao {
  /// Inserts or updates the cardio_details row for an exercise.
  static Future<void> insertCardioDetails({
    required Database db,
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) {
    return db.insert(
      'cardio_details',
      {
        'exercise_id':     exerciseId,
        'cardio_name':     cardioName,
        'note':            note,
        'planned_minutes': plannedMinutes,
        'elapsed_seconds': elapsedSeconds,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetches the cardio_details for a given exercise (or null if none).
  static Future<Map<String, dynamic>?> getCardioDetailsForExercise(
    Database db,
    int exerciseId,
  ) async {
    final rows = await db.query(
      'cardio_details',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

/// Updates an existing cardio_details row for an exercise.
  static Future<int> updateCardioDetails({
    required Database db,
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) {
    return db.update(
      'cardio_details',
      {
        'cardio_name':     cardioName,
        'note':            note,
        'planned_minutes': plannedMinutes,
        'elapsed_seconds': elapsedSeconds,
      },
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }

  /// Deletes the cardio_details entry for a specific exercise.
  static Future<int> deleteCardioDetails(
    Database db,
    int exerciseId,
  ) {
    return db.delete(
      'cardio_details',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }

}
