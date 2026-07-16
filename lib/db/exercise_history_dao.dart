import 'package:sqflite/sqflite.dart';

import 'db_query_utils.dart';

/// Queries paged, completed weight-exercise history for one definition.
class ExerciseHistoryDao {
  static Future<List<Map<String, dynamic>>> fetchWeightExerciseRows(
    Database db, {
    required int definitionId,
    String? beforeSessionDate,
    int? beforeExerciseId,
    int limit = 10,
  }) async {
    if (limit <= 0) return const <Map<String, dynamic>>[];
    if ((beforeSessionDate == null) != (beforeExerciseId == null)) {
      throw ArgumentError(
        'beforeSessionDate and beforeExerciseId must be provided together.',
      );
    }

    final hasCursor = beforeSessionDate != null;
    final args = <Object?>[
      definitionId,
      if (hasCursor) ...[
        beforeSessionDate,
        beforeSessionDate,
        beforeExerciseId,
      ],
      limit,
    ];
    final rows = await db.rawQuery('''
      SELECT
        e.id AS exercise_id,
        s.id AS session_id,
        s.date AS session_date
      FROM exercises e
      INNER JOIN sessions s ON s.id = e.session_id
      WHERE e.type = 'weight'
        AND e.exercise_def_id = ?
        ${hasCursor ? 'AND (s.date < ? OR (s.date = ? AND e.id < ?))' : ''}
      ORDER BY s.date DESC, e.id DESC
      LIMIT ?
      ''', args);
    return dynamicRows(rows);
  }
}
