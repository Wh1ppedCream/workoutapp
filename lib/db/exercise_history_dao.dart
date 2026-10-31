import 'package:sqflite/sqflite.dart';

import 'db_query_utils.dart';

/// Queries paged, completed weight-exercise history for one definition.
class ExerciseHistoryDao {
  static Future<List<Map<String, dynamic>>> fetchWeightExerciseRows(
    Database db, {
    required int definitionId,
    int? beforeCompletedAtMilliseconds,
    int? beforeExerciseId,
    int limit = 10,
  }) async {
    if (limit <= 0) return const <Map<String, dynamic>>[];
    if ((beforeCompletedAtMilliseconds == null) != (beforeExerciseId == null)) {
      throw ArgumentError(
        'beforeCompletedAtMilliseconds and beforeExerciseId must be provided together.',
      );
    }

    final hasCursor = beforeCompletedAtMilliseconds != null;
    final args = <Object?>[
      definitionId,
      if (hasCursor) ...[
        beforeCompletedAtMilliseconds,
        beforeCompletedAtMilliseconds,
        beforeExerciseId,
      ],
      limit,
    ];
    final rows = await db.rawQuery('''
      SELECT
        e.id AS exercise_id,
        s.id AS session_id,
        s.date AS session_date,
        s.completed_at_ms AS session_completed_at_ms,
        s.training_day AS session_training_day
      FROM exercises e
      INNER JOIN sessions s ON s.id = e.session_id
      WHERE e.type = 'weight'
        AND e.exercise_def_id = ?
        ${hasCursor ? 'AND (s.completed_at_ms < ? OR (s.completed_at_ms = ? AND e.id < ?))' : ''}
      ORDER BY s.completed_at_ms DESC, e.id DESC
      LIMIT ?
      ''', args);
    return dynamicRows(rows);
  }

  static Future<List<Map<String, dynamic>>> fetchExerciseOneRmTrendRows(
    DatabaseExecutor db, {
    required int definitionId,
    int limit = 60,
  }) async {
    if (limit <= 0) return const <Map<String, dynamic>>[];

    return db.rawQuery(
      '''
      SELECT *
      FROM (
        SELECT
          sess.id AS session_id,
          sess.date AS session_date,
          sess.completed_at_ms AS completed_at_ms,
          sess.training_day AS training_day,
          MAX(CASE WHEN st.reps = 1 THEN st.weight ELSE NULL END)
            AS actual_one_rm,
          MAX(
            CASE
              WHEN st.reps <= 1 THEN st.weight
              ELSE st.weight * (1 + 0.0333 * st.reps)
            END
          ) AS estimated_one_rm
        FROM sets st
        INNER JOIN exercises e ON e.id = st.exercise_id
        INNER JOIN sessions sess ON sess.id = e.session_id
        WHERE e.type = 'weight'
          AND e.exercise_def_id = ?
          AND st.parent_set_id IS NULL
        GROUP BY sess.id
        ORDER BY sess.completed_at_ms DESC, sess.id DESC
        LIMIT ?
      )
      ORDER BY completed_at_ms ASC, session_id ASC
      ''',
      [definitionId, limit],
    );
  }
}
