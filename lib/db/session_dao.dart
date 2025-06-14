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
}
