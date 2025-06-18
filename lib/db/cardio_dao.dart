// File: lib/db/cardio_dao.dart

import 'package:sqflite/sqflite.dart';

/// Data Access Object for cardio exercise details.
///
/// Encapsulates all CRUD operations on the `cardio_details` table:
///  • Insert or replace details
///  • Query details for an exercise
///  • Update existing details
///  • Delete details by exercise
class CardioDao {
  /// Inserts or replaces the cardio details for a specific exercise.
  ///
  /// Parameters:
  /// - [db]: Open SQLite database instance.
  /// - [exerciseId]: Foreign key referencing the exercise.
  /// - [cardioName]: Name of the cardio activity.
  /// - [note]: Optional notes or description.
  /// - [plannedMinutes]: Intended duration in minutes.
  /// - [elapsedSeconds]: Recorded elapsed time in seconds.
  ///
  /// Uses `ConflictAlgorithm.replace` to overwrite existing records.
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

  /// Retrieves the cardio details for a given exercise.
  ///
  /// Returns a map of column names to values if found, otherwise `null`.
  /// - [db]: Open SQLite database instance.
  /// - [exerciseId]: Foreign key referencing the exercise.
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

  /// Updates the cardio details for a specific exercise.
  ///
  /// Parameters and behavior mirror [insertCardioDetails], except
  /// this method only updates existing rows.
  /// Returns the number of rows affected.
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

  /// Deletes the cardio details entry associated with a given exercise.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [exerciseId]: Foreign key referencing the exercise.
  ///
  /// Returns the number of rows removed (should be 0 or 1).
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
