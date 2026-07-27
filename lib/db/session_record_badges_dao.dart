import 'package:sqflite/sqflite.dart';

import '../models/session_record_badge_models.dart';

/// Computes completion-sheet record badges from persisted workout history.
///
/// The current session is always excluded from the comparisons. This keeps the
/// result accurate even though completion has already updated cached PR tables.
class SessionRecordBadgesDao {
  static Future<Map<int, WorkoutExerciseRecordBadges>> forSession(
    Database db,
    int sessionId,
  ) async {
    final sessionRows = await db.query(
      'sessions',
      columns: const ['date'],
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (sessionRows.isEmpty) return const <int, WorkoutExerciseRecordBadges>{};

    final sessionDate = DateTime.tryParse(sessionRows.single['date'] as String);
    if (sessionDate == null) {
      return const <int, WorkoutExerciseRecordBadges>{};
    }

    final currentRows = await db.rawQuery(
      '''
      SELECT
        e.id AS exercise_id,
        e.exercise_def_id AS definition_id,
        st.order_index AS set_index,
        st.weight AS weight,
        st.reps AS reps
      FROM exercises e
      INNER JOIN sets st ON st.exercise_id = e.id
      WHERE e.session_id = ?
        AND e.type = 'weight'
        AND e.exercise_def_id IS NOT NULL
        AND st.parent_set_id IS NULL
      ORDER BY e.order_index ASC, st.order_index ASC
    ''',
      [sessionId],
    );

    final byExercise = <int, List<_RecordedSet>>{};
    final definitionByExercise = <int, int>{};
    for (final row in currentRows) {
      final exerciseId = row['exercise_id'] as int;
      definitionByExercise[exerciseId] = row['definition_id'] as int;
      byExercise
          .putIfAbsent(exerciseId, () => <_RecordedSet>[])
          .add(
            _RecordedSet(
              index: row['set_index'] as int,
              weight: (row['weight'] as num).toDouble(),
              reps: row['reps'] as int,
            ),
          );
    }

    if (byExercise.isEmpty) return const <int, WorkoutExerciseRecordBadges>{};

    final monthStart = DateTime(sessionDate.year, sessionDate.month);
    final nextMonthStart = DateTime(sessionDate.year, sessionDate.month + 1);
    final badges = <int, WorkoutExerciseRecordBadges>{};
    final exercisesByDefinition =
        <int, List<MapEntry<int, List<_RecordedSet>>>>{};
    for (final entry in byExercise.entries) {
      final definitionId = definitionByExercise[entry.key]!;
      exercisesByDefinition
          .putIfAbsent(
            definitionId,
            () => <MapEntry<int, List<_RecordedSet>>>[],
          )
          .add(entry);
    }

    for (final entry in exercisesByDefinition.entries) {
      final definitionId = entry.key;
      final priorSets = await _historyForDefinition(
        db,
        definitionId: definitionId,
        excludedSessionId: sessionId,
      );
      final comparisonHistory = List<_HistoricalSet>.from(priorSets);

      for (final currentExercise in entry.value) {
        badges[currentExercise.key] = _evaluate(
          currentSets: currentExercise.value,
          history: comparisonHistory,
          monthStart: monthStart,
          nextMonthStart: nextMonthStart,
        );
        comparisonHistory.addAll(
          currentExercise.value.map(
            (set) => _HistoricalSet(
              weight: set.weight,
              reps: set.reps,
              completedAt: sessionDate,
            ),
          ),
        );
      }
    }

    return badges;
  }

  static Future<List<_HistoricalSet>> _historyForDefinition(
    Database db, {
    required int definitionId,
    required int excludedSessionId,
  }) async {
    final rows = await db.rawQuery(
      '''
      SELECT
        st.weight AS weight,
        st.reps AS reps,
        sess.date AS session_date
      FROM sets st
      INNER JOIN exercises e ON e.id = st.exercise_id
      INNER JOIN sessions sess ON sess.id = e.session_id
      WHERE e.type = 'weight'
        AND e.exercise_def_id = ?
        AND e.session_id != ?
        AND st.parent_set_id IS NULL
    ''',
      [definitionId, excludedSessionId],
    );

    return rows
        .map(
          (row) => _HistoricalSet(
            weight: (row['weight'] as num).toDouble(),
            reps: row['reps'] as int,
            completedAt: DateTime.parse(row['session_date'] as String),
          ),
        )
        .toList();
  }

  static WorkoutExerciseRecordBadges _evaluate({
    required List<_RecordedSet> currentSets,
    required List<_HistoricalSet> history,
    required DateTime monthStart,
    required DateTime nextMonthStart,
  }) {
    final monthlyHistory =
        history
            .where(
              (set) =>
                  !set.completedAt.isBefore(monthStart) &&
                  set.completedAt.isBefore(nextMonthStart),
            )
            .toList();
    final allTimeWeights = _maxWeightByRep(history);
    final monthlyWeights = _maxWeightByRep(monthlyHistory);
    final badgesBySet = <int, List<WorkoutRecordBadge>>{};

    void addBadge(int setIndex, WorkoutRecordBadge badge) {
      badgesBySet
          .putIfAbsent(setIndex, () => <WorkoutRecordBadge>[])
          .add(badge);
    }

    final strongestCurrentSetByRep = <int, _RecordedSet>{};
    for (final set in currentSets) {
      if (set.weight <= 0 || set.reps <= 0) continue;
      final existing = strongestCurrentSetByRep[set.reps];
      if (existing == null || set.weight > existing.weight) {
        strongestCurrentSetByRep[set.reps] = set;
      }
    }

    for (final entry in strongestCurrentSetByRep.entries) {
      final reps = entry.key;
      final set = entry.value;
      final allTimeMax = allTimeWeights[reps];
      final monthlyMax = monthlyWeights[reps];
      if (allTimeMax == null || set.weight > allTimeMax) {
        addBadge(
          set.index,
          WorkoutRecordBadge(
            tier: WorkoutRecordBadgeTier.allTime,
            type: WorkoutRecordBadgeType.repBest,
            reps: reps,
          ),
        );
      } else if (monthlyMax == null || set.weight > monthlyMax) {
        addBadge(
          set.index,
          WorkoutRecordBadge(
            tier: WorkoutRecordBadgeTier.monthly,
            type: WorkoutRecordBadgeType.repBest,
            reps: reps,
          ),
        );
      }
    }

    final strongestVolumeSet = _strongestVolumeSet(currentSets);
    if (strongestVolumeSet != null && strongestVolumeSet.volume > 0) {
      final allTimeVolume = _maxSetVolume(history);
      final monthlyVolume = _maxSetVolume(monthlyHistory);
      if (allTimeVolume == null || strongestVolumeSet.volume > allTimeVolume) {
        addBadge(
          strongestVolumeSet.index,
          const WorkoutRecordBadge(
            tier: WorkoutRecordBadgeTier.allTime,
            type: WorkoutRecordBadgeType.volumeBest,
          ),
        );
      } else if (monthlyVolume == null ||
          strongestVolumeSet.volume > monthlyVolume) {
        addBadge(
          strongestVolumeSet.index,
          const WorkoutRecordBadge(
            tier: WorkoutRecordBadgeTier.monthly,
            type: WorkoutRecordBadgeType.volumeBest,
          ),
        );
      }
    }

    return WorkoutExerciseRecordBadges(
      isFirstRecord: history.isEmpty,
      setBadges: badgesBySet,
    );
  }

  static Map<int, double> _maxWeightByRep(List<_HistoricalSet> sets) {
    final maxByRep = <int, double>{};
    for (final set in sets) {
      if (set.weight <= 0 || set.reps <= 0) continue;
      final previous = maxByRep[set.reps];
      if (previous == null || set.weight > previous) {
        maxByRep[set.reps] = set.weight;
      }
    }
    return maxByRep;
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
}

class _RecordedSet {
  final int index;
  final double weight;
  final int reps;

  const _RecordedSet({
    required this.index,
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
