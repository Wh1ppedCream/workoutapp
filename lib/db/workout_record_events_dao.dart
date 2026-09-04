import 'package:sqflite/sqflite.dart';

import '../models/session_record_badge_models.dart';
import '../models/temporal_semantics.dart';
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

  /// Resolves the current record holders for one exercise definition.
  ///
  /// Unlike persisted event history, this is intended for leaderboard-style
  /// history lists: a set loses its visible record badge when a later set
  /// surpasses it. Monthly leaders are evaluated independently per calendar
  /// month, while all-time leaders are evaluated across the full history.
  static Future<Map<int, WorkoutExerciseRecordBadges>>
  currentLeadersForDefinition(DatabaseExecutor db, int definitionId) async {
    final exerciseRows = await db.rawQuery(
      '''
      SELECT e.id AS exercise_id, er.is_first_record AS is_first_record
      FROM exercises e
      LEFT JOIN workout_exercise_record_events er ON er.exercise_id = e.id
      WHERE e.type = 'weight' AND e.exercise_def_id = ?
      ''',
      [definitionId],
    );
    final badgesByExercise = <int, Map<int, List<WorkoutRecordBadge>>>{
      for (final row in exerciseRows)
        row['exercise_id'] as int: <int, List<WorkoutRecordBadge>>{},
    };
    final firstByExercise = <int, bool>{
      for (final row in exerciseRows)
        row['exercise_id'] as int:
            ((row['is_first_record'] as num?)?.toInt() ?? 0) == 1,
    };
    if (badgesByExercise.isEmpty) {
      return const <int, WorkoutExerciseRecordBadges>{};
    }

    final rows = await db.rawQuery(
      '''
      SELECT
        e.id AS exercise_id,
        sess.date AS session_date,
        sess.completed_at_ms AS session_completed_at_ms,
        sess.training_day AS session_training_day,
        st.id AS set_id,
        st.order_index AS set_index,
        st.weight AS weight,
        st.reps AS reps
      FROM exercises e
      INNER JOIN sessions sess ON sess.id = e.session_id
      INNER JOIN sets st ON st.exercise_id = e.id
      WHERE e.type = 'weight'
        AND e.exercise_def_id = ?
        AND st.parent_set_id IS NULL
      ORDER BY sess.completed_at_ms ASC, sess.id ASC, e.id ASC, st.order_index ASC
      ''',
      [definitionId],
    );

    final allTimeRepLeaders = <int, _CurrentRecordSet>{};
    final monthlyRepLeaders = <String, _CurrentRecordSet>{};
    _CurrentRecordSet? allTimeVolumeLeader;
    final monthlyVolumeLeaders = <String, _CurrentRecordSet>{};

    for (final row in rows) {
      final set = _CurrentRecordSet(
        id: row['set_id'] as int,
        exerciseId: row['exercise_id'] as int,
        setIndex: row['set_index'] as int,
        trainingDay: TemporalSemantics.readCalendarDay(
          calendarDay: row['session_training_day'],
          legacyIso: row['session_date'],
          epochMilliseconds: row['session_completed_at_ms'],
        ),
        weight: (row['weight'] as num).toDouble(),
        reps: (row['reps'] as num).toInt(),
      );
      if (set.weight <= 0 || set.reps <= 0) continue;

      final currentRepLeader = allTimeRepLeaders[set.reps];
      if (currentRepLeader == null || set.weight > currentRepLeader.weight) {
        allTimeRepLeaders[set.reps] = set;
      }
      final monthRepKey = _monthlyKey(set.trainingDay, set.reps);
      final currentMonthlyRepLeader = monthlyRepLeaders[monthRepKey];
      if (currentMonthlyRepLeader == null ||
          set.weight > currentMonthlyRepLeader.weight) {
        monthlyRepLeaders[monthRepKey] = set;
      }

      if (allTimeVolumeLeader == null ||
          set.volume > allTimeVolumeLeader.volume) {
        allTimeVolumeLeader = set;
      }
      final monthVolumeKey = _monthlyKey(set.trainingDay, null);
      final currentMonthlyVolumeLeader = monthlyVolumeLeaders[monthVolumeKey];
      if (currentMonthlyVolumeLeader == null ||
          set.volume > currentMonthlyVolumeLeader.volume) {
        monthlyVolumeLeaders[monthVolumeKey] = set;
      }
    }

    void addBadge(_CurrentRecordSet set, WorkoutRecordBadge badge) {
      badgesByExercise[set.exerciseId]!
          .putIfAbsent(set.setIndex, () => <WorkoutRecordBadge>[])
          .add(badge);
    }

    for (final entry in allTimeRepLeaders.entries) {
      addBadge(
        entry.value,
        WorkoutRecordBadge(
          type: WorkoutRecordBadgeType.repBest,
          tier: WorkoutRecordBadgeTier.allTime,
          reps: entry.key,
        ),
      );
    }
    for (final entry in monthlyRepLeaders.entries) {
      final allTimeLeader = allTimeRepLeaders[entry.value.reps];
      if (allTimeLeader?.id == entry.value.id) continue;
      addBadge(
        entry.value,
        WorkoutRecordBadge(
          type: WorkoutRecordBadgeType.repBest,
          tier: WorkoutRecordBadgeTier.monthly,
          reps: entry.value.reps,
        ),
      );
    }
    if (allTimeVolumeLeader != null) {
      addBadge(
        allTimeVolumeLeader,
        const WorkoutRecordBadge(
          type: WorkoutRecordBadgeType.volumeBest,
          tier: WorkoutRecordBadgeTier.allTime,
        ),
      );
    }
    for (final entry in monthlyVolumeLeaders.entries) {
      if (allTimeVolumeLeader?.id == entry.value.id) continue;
      addBadge(
        entry.value,
        const WorkoutRecordBadge(
          type: WorkoutRecordBadgeType.volumeBest,
          tier: WorkoutRecordBadgeTier.monthly,
        ),
      );
    }

    return <int, WorkoutExerciseRecordBadges>{
      for (final exerciseId in badgesByExercise.keys)
        exerciseId: WorkoutExerciseRecordBadges(
          isFirstRecord: firstByExercise[exerciseId] ?? false,
          setBadges: badgesByExercise[exerciseId]!,
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
        sess.completed_at_ms AS session_completed_at_ms,
        sess.training_day AS session_training_day,
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
        sess.completed_at_ms ASC,
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
          trainingDay: TemporalSemantics.readCalendarDay(
            calendarDay: row['session_training_day'],
            legacyIso: row['session_date'],
            epochMilliseconds: row['session_completed_at_ms'],
          ),
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
            trainingDay: exercise.trainingDay,
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
    final monthlyHistory = history
        .where(
          (set) =>
              set.trainingDay.year == exercise.trainingDay.year &&
              set.trainingDay.month == exercise.trainingDay.month,
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

  static String _monthlyKey(LocalCalendarDay day, int? reps) {
    return reps == null
        ? '${day.year}-${day.month}'
        : '${day.year}-${day.month}-$reps';
  }
}

class _RecordedExercise {
  final int exerciseId;
  final int definitionId;
  final LocalCalendarDay trainingDay;
  final List<_RecordedSet> sets = <_RecordedSet>[];

  _RecordedExercise({
    required this.exerciseId,
    required this.definitionId,
    required this.trainingDay,
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
  final LocalCalendarDay trainingDay;

  const _HistoricalSet({
    required this.weight,
    required this.reps,
    required this.trainingDay,
  });

  double get volume => weight * reps;
}

class _CurrentRecordSet {
  final int id;
  final int exerciseId;
  final int setIndex;
  final LocalCalendarDay trainingDay;
  final double weight;
  final int reps;

  const _CurrentRecordSet({
    required this.id,
    required this.exerciseId,
    required this.setIndex,
    required this.trainingDay,
    required this.weight,
    required this.reps,
  });

  double get volume => weight * reps;
}
