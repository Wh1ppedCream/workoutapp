import 'package:sqflite/sqflite.dart';

import '../models/session_record_badge_models.dart';
import 'db_query_utils.dart';

/// Stores factual record events for completed weighted parent sets.
///
/// Events are rebuilt in chronological order whenever completed workout
/// history changes. Historical screens can therefore show the awards that
/// were valid when a workout happened instead of recalculating against later
/// workouts.
class WorkoutRecordEventsDao {
  static Future<Map<int, WorkoutExerciseRecordBadges>> forSession(
    DatabaseExecutor db,
    int sessionId,
  ) async {
    final rows = await db.query(
      'exercises',
      columns: const ['id'],
      where: 'session_id = ? AND type = ?',
      whereArgs: [sessionId, 'weight'],
    );
    return forExerciseIds(
      db,
      rows.map((row) => row['id'] as int).toList(growable: false),
    );
  }

  static Future<Map<int, WorkoutExerciseRecordBadges>> forExerciseIds(
    DatabaseExecutor db,
    Iterable<int> exerciseIds,
  ) async {
    final ids = exerciseIds.toSet().toList(growable: false);
    if (ids.isEmpty) return const <int, WorkoutExerciseRecordBadges>{};

    final placeholders = sqlitePlaceholders(ids.length);
    final firstRows = await db.rawQuery('''
      SELECT e.id AS exercise_id, er.is_first_record AS is_first_record
      FROM exercises e
      LEFT JOIN workout_exercise_record_events er ON er.exercise_id = e.id
      WHERE e.id IN ($placeholders)
      ''', ids);
    final firstByExercise = <int, bool>{
      for (final row in firstRows)
        row['exercise_id'] as int:
            ((row['is_first_record'] as num?)?.toInt() ?? 0) == 1,
    };
    final badgesByExercise = <int, Map<int, List<WorkoutRecordBadge>>>{
      for (final id in ids) id: <int, List<WorkoutRecordBadge>>{},
    };
    final setRows = await db.rawQuery('''
      SELECT
        st.exercise_id AS exercise_id,
        st.order_index AS set_index,
        se.badge_type AS badge_type,
        se.badge_tier AS badge_tier,
        se.reps AS reps
      FROM sets st
      INNER JOIN workout_set_record_events se ON se.set_id = st.id
      WHERE st.parent_set_id IS NULL
        AND st.exercise_id IN ($placeholders)
      ORDER BY st.exercise_id ASC, st.order_index ASC, se.badge_type ASC
      ''', ids);
    for (final row in setRows) {
      final exerciseId = row['exercise_id'] as int;
      final setIndex = row['set_index'] as int;
      badgesByExercise[exerciseId]!
          .putIfAbsent(setIndex, () => <WorkoutRecordBadge>[])
          .add(
            WorkoutRecordBadge(
              tier: _tierFromDb(row['badge_tier'] as String),
              type: _typeFromDb(row['badge_type'] as String),
              reps: (row['reps'] as num?)?.toInt(),
            ),
          );
    }

    return <int, WorkoutExerciseRecordBadges>{
      for (final id in ids)
        id: WorkoutExerciseRecordBadges(
          isFirstRecord: firstByExercise[id] ?? false,
          setBadges: badgesByExercise[id]!,
        ),
    };
  }

  static Future<void> rebuildAll(DatabaseExecutor db) async {
    final rows = await db.rawQuery('''
      SELECT DISTINCT exercise_def_id
      FROM exercises
      WHERE type = 'weight' AND exercise_def_id IS NOT NULL
    ''');
    await rebuildForDefinitions(
      db,
      rows.map((row) => row['exercise_def_id'] as int),
    );
  }

  /// Rebuilds history by session date, session id, exercise id, and set order.
  /// The ordering keeps same-day record events deterministic.
  static Future<void> rebuildForDefinitions(
    DatabaseExecutor db,
    Iterable<int> definitionIds,
  ) async {
    final ids = definitionIds.toSet().toList(growable: false);
    if (ids.isEmpty) return;

    final placeholders = sqlitePlaceholders(ids.length);
    await db.delete(
      'workout_set_record_events',
      where: '''
        set_id IN (
          SELECT st.id
          FROM sets st
          INNER JOIN exercises e ON e.id = st.exercise_id
          WHERE st.parent_set_id IS NULL
            AND e.type = 'weight'
            AND e.exercise_def_id IN ($placeholders)
        )
      ''',
      whereArgs: ids,
    );
    await db.delete(
      'workout_exercise_record_events',
      where: '''
        exercise_id IN (
          SELECT id
          FROM exercises
          WHERE type = 'weight' AND exercise_def_id IN ($placeholders)
        )
      ''',
      whereArgs: ids,
    );

    final rows = await db.rawQuery('''
      SELECT
        e.id AS exercise_id,
        e.exercise_def_id AS definition_id,
        sess.date AS session_date,
        st.id AS set_id,
        st.weight AS weight,
        st.reps AS reps
      FROM exercises e
      INNER JOIN sessions sess ON sess.id = e.session_id
      INNER JOIN sets st ON st.exercise_id = e.id
      WHERE e.type = 'weight'
        AND e.exercise_def_id IN ($placeholders)
        AND st.parent_set_id IS NULL
      ORDER BY
        e.exercise_def_id ASC,
        sess.date ASC,
        sess.id ASC,
        e.id ASC,
        st.order_index ASC
      ''', ids);

    final exercises = <_RecordedExercise>[];
    _RecordedExercise? current;
    for (final row in rows) {
      final exerciseId = row['exercise_id'] as int;
      if (current == null || current.exerciseId != exerciseId) {
        current = _RecordedExercise(
          exerciseId: exerciseId,
          definitionId: row['definition_id'] as int,
          completedAt: DateTime.parse(row['session_date'] as String),
        );
        exercises.add(current);
      }
      current.sets.add(
        _RecordedSet(
          id: row['set_id'] as int,
          weight: (row['weight'] as num).toDouble(),
          reps: (row['reps'] as num).toInt(),
        ),
      );
    }

    final historyByDefinition = <int, List<_HistoricalSet>>{};
    for (final exercise in exercises) {
      final history = historyByDefinition.putIfAbsent(
        exercise.definitionId,
        () => <_HistoricalSet>[],
      );
      if (history.isEmpty) {
        await db.insert('workout_exercise_record_events', {
          'exercise_id': exercise.exerciseId,
          'is_first_record': 1,
        });
      }
      await _recordSetEvents(db, exercise, history);
      history.addAll(
        exercise.sets.map(
          (set) => _HistoricalSet(
            weight: set.weight,
            reps: set.reps,
            completedAt: exercise.completedAt,
          ),
        ),
      );
    }
  }

  static Future<void> _recordSetEvents(
    DatabaseExecutor db,
    _RecordedExercise exercise,
    List<_HistoricalSet> history,
  ) async {
    final monthStart = DateTime(
      exercise.completedAt.year,
      exercise.completedAt.month,
    );
    final nextMonthStart = DateTime(
      exercise.completedAt.year,
      exercise.completedAt.month + 1,
    );
    final monthlyHistory = history
        .where(
          (set) =>
              !set.completedAt.isBefore(monthStart) &&
              set.completedAt.isBefore(nextMonthStart),
        )
        .toList(growable: false);
    final allTimeWeights = _maxWeightByRep(history);
    final monthlyWeights = _maxWeightByRep(monthlyHistory);

    final strongestByRep = <int, _RecordedSet>{};
    for (final set in exercise.sets) {
      if (set.weight <= 0 || set.reps <= 0) continue;
      final existing = strongestByRep[set.reps];
      if (existing == null || set.weight > existing.weight) {
        strongestByRep[set.reps] = set;
      }
    }
    for (final entry in strongestByRep.entries) {
      final reps = entry.key;
      final set = entry.value;
      final allTimeMax = allTimeWeights[reps];
      final monthlyMax = monthlyWeights[reps];
      if (allTimeMax == null || set.weight > allTimeMax) {
        await _insertSetEvent(
          db,
          set: set,
          type: WorkoutRecordBadgeType.repBest,
          tier: WorkoutRecordBadgeTier.allTime,
          reps: reps,
        );
      } else if (monthlyMax == null || set.weight > monthlyMax) {
        await _insertSetEvent(
          db,
          set: set,
          type: WorkoutRecordBadgeType.repBest,
          tier: WorkoutRecordBadgeTier.monthly,
          reps: reps,
        );
      }
    }

    final strongestVolumeSet = _strongestVolumeSet(exercise.sets);
    if (strongestVolumeSet == null || strongestVolumeSet.volume <= 0) return;

    final allTimeVolume = _maxSetVolume(history);
    final monthlyVolume = _maxSetVolume(monthlyHistory);
    if (allTimeVolume == null || strongestVolumeSet.volume > allTimeVolume) {
      await _insertSetEvent(
        db,
        set: strongestVolumeSet,
        type: WorkoutRecordBadgeType.volumeBest,
        tier: WorkoutRecordBadgeTier.allTime,
      );
    } else if (monthlyVolume == null ||
        strongestVolumeSet.volume > monthlyVolume) {
      await _insertSetEvent(
        db,
        set: strongestVolumeSet,
        type: WorkoutRecordBadgeType.volumeBest,
        tier: WorkoutRecordBadgeTier.monthly,
      );
    }
  }

  static Future<void> _insertSetEvent(
    DatabaseExecutor db, {
    required _RecordedSet set,
    required WorkoutRecordBadgeType type,
    required WorkoutRecordBadgeTier tier,
    int? reps,
  }) {
    return db.insert('workout_set_record_events', {
      'set_id': set.id,
      'badge_type': _typeToDb(type),
      'badge_tier': _tierToDb(tier),
      'reps': reps,
    });
  }

  static Map<int, double> _maxWeightByRep(List<_HistoricalSet> sets) {
    final maximums = <int, double>{};
    for (final set in sets) {
      if (set.weight <= 0 || set.reps <= 0) continue;
      final previous = maximums[set.reps];
      if (previous == null || set.weight > previous) {
        maximums[set.reps] = set.weight;
      }
    }
    return maximums;
  }

  static _RecordedSet? _strongestVolumeSet(List<_RecordedSet> sets) {
    _RecordedSet? strongest;
    for (final set in sets) {
      if (set.weight <= 0 || set.reps <= 0) continue;
      if (strongest == null || set.volume > strongest.volume) strongest = set;
    }
    return strongest;
  }

  static double? _maxSetVolume(List<_HistoricalSet> sets) {
    double? maximum;
    for (final set in sets) {
      if (set.weight <= 0 || set.reps <= 0) continue;
      if (maximum == null || set.volume > maximum) maximum = set.volume;
    }
    return maximum;
  }

  static WorkoutRecordBadgeType _typeFromDb(String value) {
    return value == 'set_volume_best'
        ? WorkoutRecordBadgeType.volumeBest
        : WorkoutRecordBadgeType.repBest;
  }

  static String _typeToDb(WorkoutRecordBadgeType type) {
    return type == WorkoutRecordBadgeType.volumeBest
        ? 'set_volume_best'
        : 'rep_best';
  }

  static WorkoutRecordBadgeTier _tierFromDb(String value) {
    return value == 'monthly'
        ? WorkoutRecordBadgeTier.monthly
        : WorkoutRecordBadgeTier.allTime;
  }

  static String _tierToDb(WorkoutRecordBadgeTier tier) {
    return tier == WorkoutRecordBadgeTier.monthly ? 'monthly' : 'all_time';
  }
}

class _RecordedExercise {
  final int exerciseId;
  final int definitionId;
  final DateTime completedAt;
  final List<_RecordedSet> sets = <_RecordedSet>[];

  _RecordedExercise({
    required this.exerciseId,
    required this.definitionId,
    required this.completedAt,
  });
}

class _RecordedSet {
  final int id;
  final double weight;
  final int reps;

  const _RecordedSet({
    required this.id,
    required this.weight,
    required this.reps,
  });

  double get volume => weight * reps;
}

class _HistoricalSet {
  final double weight;
  final int reps;
  final DateTime completedAt;

  const _HistoricalSet({
    required this.weight,
    required this.reps,
    required this.completedAt,
  });

  double get volume => weight * reps;
}
