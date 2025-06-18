// File: lib/db/session_dao.dart

import 'package:sqflite/sqflite.dart';

/// Encapsulates session CRUD operations.
class SessionDao {
  /// Inserts a new session row and returns its id.
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

  /// Fetches all sessions as raw maps, ordered by date descending.
  static Future<List<Map<String, dynamic>>> getAllSessionsRaw(
    Database db,
  ) {
    return db.query(
      'sessions',
      orderBy: 'date DESC',
    );
  }

  /// Deletes the session with the given id (cascades to exercises/sets).
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

 /// Fetches a single session by its id, or null if not found.
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

  /// Updates the date and/or duration of an existing session.
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

  /// Fetches sessions whose date is between [start] and [end].
  static Future<List<Map<String, dynamic>>> getSessionsInRange(
    Database db,
    String start, // ISO date strings
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
