// File: lib/db/session_dao.dart

import 'package:sqflite/sqflite.dart';

import '../models/temporal_semantics.dart';
import 'db_query_utils.dart';

/// Data Access Object for workout sessions.
///
/// Provides CRUD operations on the `sessions` table, including inserting,
/// querying, updating, and deleting sessions.
class SessionDao {
  /// Inserts a new session row.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [completedAt]: Exact instant when the session was completed.
  /// - [trainingDay]: Stable local calendar day shown in history.
  /// - [duration]: Total session duration in seconds.
  ///
  /// Returns the new session row ID.
  static Future<int> insertSession(
    DatabaseExecutor db, {
    required DateTime completedAt,
    required int duration,
    LocalCalendarDay? trainingDay,
  }) {
    final day =
        trainingDay ?? LocalCalendarDay.fromDateTime(completedAt.toLocal());
    return db.insert('sessions', {
      // Retained for backwards-compatible JSON exports and older app builds.
      'date': TemporalSemantics.legacyUtcIso8601(completedAt),
      'completed_at_ms': TemporalSemantics.utcEpochMilliseconds(completedAt),
      'training_day': day.storageKey,
      'duration': duration,
    });
  }

  /// Retrieves all sessions as raw maps, newest completion instant first.
  ///
  /// - [db]: Open SQLite database instance.
  ///
  /// Rows include canonical instant/day columns and legacy export text.
  static Future<List<Map<String, dynamic>>> getAllSessionsRaw(
    DatabaseExecutor db,
  ) {
    return db.query('sessions', orderBy: 'completed_at_ms DESC, id DESC');
  }

  /// Deletes the session with the given ID.
  ///
  /// Cascades deletions to related exercise and set rows via foreign keys.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [sessionId]: ID of the session to delete.
  static Future<void> deleteSession(Database db, int sessionId) async {
    await db.delete('sessions', where: 'id = ?', whereArgs: [sessionId]);
  }

  /// Fetches a single session by its ID.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [sessionId]: ID of the session to fetch.
  ///
  /// Returns a map of column values or `null` if not found.
  static Future<Map<String, dynamic>?> getSessionById(
    DatabaseExecutor db,
    int sessionId,
  ) async {
    final rows = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    return firstDynamicRow(rows);
  }

  /// Updates the date and duration of an existing session.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [sessionId]: ID of the session to update.
  /// - [completedAt]: New exact completion instant.
  /// - [trainingDay]: New stable local calendar day.
  /// - [duration]: New duration in seconds.
  ///
  /// Returns number of rows affected (0 or 1).
  static Future<int> updateSession(
    DatabaseExecutor db,
    int sessionId, {
    required DateTime completedAt,
    required int duration,
    LocalCalendarDay? trainingDay,
  }) {
    final day =
        trainingDay ?? LocalCalendarDay.fromDateTime(completedAt.toLocal());
    return db.update(
      'sessions',
      {
        'date': TemporalSemantics.legacyUtcIso8601(completedAt),
        'completed_at_ms': TemporalSemantics.utcEpochMilliseconds(completedAt),
        'training_day': day.storageKey,
        'duration': duration,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Retrieves sessions for exact instants between [start] and [end].
  ///
  /// This intentionally keeps the historic inclusive range contract. Calendar
  /// reporting should use [getSessionsForCalendarRange] instead.
  static Future<List<Map<String, dynamic>>> getSessionsForInstantRange(
    DatabaseExecutor db,
    DateTime start,
    DateTime end,
  ) {
    return db.query(
      'sessions',
      where: 'completed_at_ms >= ? AND completed_at_ms <= ?',
      whereArgs: [
        TemporalSemantics.utcEpochMilliseconds(start),
        TemporalSemantics.utcEpochMilliseconds(end),
      ],
      orderBy: 'completed_at_ms DESC, id DESC',
    );
  }

  /// Retrieves sessions for calendar days between [startDay] and [endDay].
  ///
  /// - [db]: Open SQLite database instance.
  /// - [startDay]: First local calendar day (inclusive).
  /// - [endDay]: Last local calendar day (inclusive).
  ///
  /// Returns a list of session maps ordered by calendar day and instant.
  static Future<List<Map<String, dynamic>>> getSessionsForCalendarRange(
    DatabaseExecutor db,
    LocalCalendarDay startDay,
    LocalCalendarDay endDay,
  ) {
    return db.query(
      'sessions',
      where: 'training_day >= ? AND training_day <= ?',
      whereArgs: [startDay.storageKey, endDay.storageKey],
      orderBy: 'training_day DESC, completed_at_ms DESC, id DESC',
    );
  }

  static Future<List<Map<String, dynamic>>> fetchWorkoutReportSessionsRaw(
    DatabaseExecutor db, {
    DateTime? start,
    DateTime? end,
  }) async {
    final whereClauses = <String>[];
    final args = <Object?>[];

    if (start != null) {
      whereClauses.add('sess.completed_at_ms >= ?');
      args.add(TemporalSemantics.utcEpochMilliseconds(start));
    }
    if (end != null) {
      whereClauses.add('sess.completed_at_ms <= ?');
      args.add(TemporalSemantics.utcEpochMilliseconds(end));
    }

    final whereSql = whereClauses.isEmpty
        ? ''
        : 'WHERE ${whereClauses.join(' AND ')}';

    return db.rawQuery('''
      SELECT
        sess.id AS session_id,
        sess.date AS date,
        sess.completed_at_ms AS completed_at_ms,
        sess.training_day AS training_day,
        sess.duration AS duration,
        COUNT(DISTINCT e.id) AS exercise_count,
        COUNT(st.id) AS set_count,
        COALESCE(SUM(
          CASE
            WHEN e.type = 'weight' THEN st.weight * st.reps
            ELSE 0
          END
        ), 0) AS total_volume
      FROM sessions sess
      LEFT JOIN exercises e ON e.session_id = sess.id
      LEFT JOIN sets st ON st.exercise_id = e.id
      $whereSql
      GROUP BY sess.id
      ORDER BY sess.completed_at_ms ASC, sess.id ASC
      ''', args);
  }
}
