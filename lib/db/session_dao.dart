// File: lib/db/session_dao.dart

import 'package:sqflite/sqflite.dart';

/// Data Access Object for workout sessions.
///
/// Provides CRUD operations on the `sessions` table, including inserting,
/// querying, updating, and deleting sessions.
class SessionDao {
  /// Inserts a new session row.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [date]: ISO 8601 date string representing session date/time.
  /// - [duration]: Total session duration in seconds.
  ///
  /// Returns the new session row ID.
  static Future<int> insertSession(
    Database db,
    String date,
    int duration,
  ) {
    return db.insert('sessions', {
      'date': date,
      'duration': duration,
    });
  }

  /// Retrieves all sessions as raw maps, ordered by date descending.
  ///
  /// - [db]: Open SQLite database instance.
  ///
  /// Returns a list of maps with keys: `id`, `date`, `duration`.
  static Future<List<Map<String, dynamic>>> getAllSessionsRaw(
    Database db,
  ) {
    return db.query(
      'sessions',
      orderBy: 'date DESC',
    );
  }

  /// Deletes the session with the given ID.
  ///
  /// Cascades deletions to related exercise and set rows via foreign keys.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [sessionId]: ID of the session to delete.
  static Future<void> deleteSession(
    Database db,
    int sessionId,
  ) {
    return db.delete(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Fetches a single session by its ID.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [sessionId]: ID of the session to fetch.
  ///
  /// Returns a map of column values or `null` if not found.
  static Future<Map<String, dynamic>?> getSessionById(
    Database db,
    int sessionId,
  ) async {
    final rows = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Updates the date and duration of an existing session.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [sessionId]: ID of the session to update.
  /// - [date]: New ISO date string.
  /// - [duration]: New duration in seconds.
  ///
  /// Returns number of rows affected (0 or 1).
  static Future<int> updateSession(
    Database db,
    int sessionId,
    String date,
    int duration,
  ) {
    return db.update(
      'sessions',
      {'date': date, 'duration': duration},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Retrieves sessions with dates between [start] and [end].
  ///
  /// - [db]: Open SQLite database instance.
  /// - [start]: ISO date string for start of range (inclusive).
  /// - [end]: ISO date string for end of range (inclusive).
  ///
  /// Returns a list of session maps ordered by date descending.
  static Future<List<Map<String, dynamic>>> getSessionsInRange(
    Database db,
    String start,
    String end,
  ) {
    return db.query(
      'sessions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
  }
}
