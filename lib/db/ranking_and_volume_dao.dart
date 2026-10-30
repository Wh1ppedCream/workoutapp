import 'package:sqflite/sqflite.dart';

import '../models/models.dart';
import '../services/exercise_allocation_resolver.dart';
import 'analytics_dao.dart';
import 'stats_dao.dart';
import 'lookup_dao.dart';
import 'definition_dao.dart';
import 'db_query_utils.dart';

/// Database operations for RankingAndVolume without owning a connection.
class RankingAndVolumeDao {
  const RankingAndVolumeDao(this.db);

  final DatabaseExecutor db;

  /// Upsert a rep-max stat row.
  Future<void> upsertRepMax(
    int defId,
    int repCount,
    String timeframe,
    double rmValue,
    double oneErm,
    bool isErm,
  ) async {
    return StatsDao.upsertRepMax(
      db,
      defId,
      repCount,
      timeframe,
      rmValue,
      oneErm,
      isErm,
    );
  }

  /// Upsert a volume-max stat row.
  Future<void> upsertVolumeMax(
    int defId,
    String timeframe,
    double vmValue,
  ) async {
    return StatsDao.upsertVolumeMax(db, defId, timeframe, vmValue);
  }

  /// Returns list of rep-max rows for [defId] & [timeframe].
  Future<List<Map<String, dynamic>>> getRepMaxes(
    int defId,
    String timeframe,
  ) async {
    return StatsDao.getRepMaxes(db, defId, timeframe);
  }

  /// Returns the volume-max row (or null) for [defId] & [timeframe].
  Future<Map<String, dynamic>?> getVolumeMax(
    int defId,
    String timeframe,
  ) async {
    return StatsDao.getVolumeMax(db, defId, timeframe);
  }

  Future<double> calculateTotalVolumeForSessions(List<int> sessionIds) async {
    if (sessionIds.isEmpty) return 0.0;

    var totalVolume = 0.0;
    final uniqueSessionIds = sessionIds.toSet().toList();
    for (final chunk in sqliteChunks(uniqueSessionIds)) {
      final placeholders = sqlitePlaceholders(chunk.length);
      final rows = await db.rawQuery('''
        SELECT COALESCE(SUM(s.weight * s.reps), 0) AS total_volume
        FROM sets s
        INNER JOIN exercises e ON e.id = s.exercise_id
        WHERE e.type = 'weight'
          AND e.session_id IN ($placeholders)
        ''', chunk);
      totalVolume += ((rows.first['total_volume'] as num?) ?? 0).toDouble();
    }

    return totalVolume;
  }

  Future<int> linkMuscleToBodyPart(int muscleId, int bodypartId) async {
    return AnalyticsDao.insertMuscleBodyPart(db, muscleId, bodypartId);
  }

  Future<int> unlinkMuscleFromBodyPart(int muscleId, int bodypartId) async {
    return AnalyticsDao.deleteMuscleBodyPart(db, muscleId, bodypartId);
  }

  Future<List<MuscleBodyPart>> fetchBodyPartsForMuscle(int muscleId) async {
    return AnalyticsDao.getBodyPartsForMuscle(db, muscleId);
  }

  Future<List<MuscleBodyPart>> fetchMusclesForBodyPart(int bodypartId) async {
    return AnalyticsDao.getMusclesForBodyPart(db, bodypartId);
  }

  Future<int> setBodyPartRank(int bodypartId, int rank) async {
    return AnalyticsDao.setBodyPartRanking(db, bodypartId, rank);
  }

  Future<BodyPartRanking?> getBodyPartRank(int bodypartId) async {
    return AnalyticsDao.getBodyPartRanking(db, bodypartId);
  }

  Future<List<BodyPartRanking>> getAllBodyPartRanks() async {
    return AnalyticsDao.getAllBodyPartRankings(db);
  }

  Future<int> deleteBodyPartRank(int bodypartId) async {
    return AnalyticsDao.deleteBodyPartRanking(db, bodypartId);
  }

  Future<int> setMuscleRank(int muscleId, int rank) async {
    return AnalyticsDao.setMuscleRanking(db, muscleId, rank);
  }

  Future<MuscleRanking?> getMuscleRank(int muscleId) async {
    return AnalyticsDao.getMuscleRanking(db, muscleId);
  }

  Future<List<MuscleRanking>> getAllMuscleRanks() async {
    return AnalyticsDao.getAllMuscleRankings(db);
  }

  Future<int> deleteMuscleRank(int muscleId) async {
    return AnalyticsDao.deleteMuscleRanking(db, muscleId);
  }

  Future<int> setExerciseMuscleHitPercent(
    int defId,
    int muscleId,
    double pct,
  ) async {
    return AnalyticsDao.setExerciseMusclePercent(db, defId, muscleId, pct);
  }

  Future<ExerciseMusclePercent?> fetchExerciseMusclePercent(
    int defId,
    int muscleId,
  ) async {
    return AnalyticsDao.getExerciseMusclePercent(db, defId, muscleId);
  }

  Future<int> removeExerciseMusclePercent(int defId, int muscleId) async {
    return AnalyticsDao.deleteExerciseMusclePercent(db, defId, muscleId);
  }

  Future<List<ExerciseMusclePercent>> fetchPercentsForExercise(
    int defId,
  ) async {
    return AnalyticsDao.getPercentsForExercise(db, defId);
  }

  Future<int> setMuscleVolumeBounds(int muscleId, VolumeBoundaries b) async {
    return AnalyticsDao.setMuscleVolumeBoundaries(db, muscleId, b);
  }

  Future<VolumeBoundaries?> fetchMuscleVolumeBounds(int muscleId) async {
    return AnalyticsDao.getMuscleVolumeBoundaries(db, muscleId);
  }

  Future<List<Map<String, dynamic>>> fetchAllMuscleVolumeBounds() async {
    return AnalyticsDao.getAllMuscleVolumeBoundaries(db);
  }

  Future<int> removeMuscleVolumeBounds(int muscleId) async {
    return AnalyticsDao.deleteMuscleVolumeBoundaries(db, muscleId);
  }

  Future<int> setBodyPartVolumeBounds(
    int bodyPartId,
    VolumeBoundaries bounds,
  ) async {
    return AnalyticsDao.setBodyPartVolumeBoundaries(db, bodyPartId, bounds);
  }

  Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) async {
    return AnalyticsDao.getBodyPartVolumeBoundaries(db, bodyPartId);
  }

  Future<List<Map<String, dynamic>>> fetchAllBodyPartVolumeBounds() async {
    return AnalyticsDao.getAllBodyPartVolumeBoundaries(db);
  }

  Future<int> removeBodyPartVolumeBounds(int bodyPartId) async {
    return AnalyticsDao.deleteBodyPartVolumeBoundaries(db, bodyPartId);
  }

  /// Fetch manual body-part percent overrides for an exercise definition
  Future<List<ExerciseBodyPartPercent>> fetchBodyPartPercentsManual(
    int defId,
  ) async {
    return AnalyticsDao.getPercentsForExerciseBodyPart(db, defId);
  }

  /// Upsert a manual body-part percent override
  Future<int> setExerciseBodyPartPercent(
    int defId,
    int bpId,
    double pct,
  ) async {
    return AnalyticsDao.setExerciseBodyPartPercent(db, defId, bpId, pct);
  }

  /// Delete a manual body-part percent override
  Future<int> deleteExerciseBodyPartPercent(int defId, int bpId) async {
    return AnalyticsDao.deleteExerciseBodyPartPercent(db, defId, bpId);
  }

  /// Fetches rep‐max rows and maps to model.
  Future<List<RepMaxRow>> fetchRepMaxes(int defId, String timeframe) async {
    final raw = await StatsDao.getRepMaxes(db, defId, timeframe);
    return raw
        .map(
          (r) => RepMaxRow(
            repCount: r['rep_count'] as int,
            rmValue: (r['rm_value'] as num).toDouble(),
            oneErm: (r['one_erm'] as num).toDouble(),
            isErm: (r['is_erm'] as int) == 1,
          ),
        )
        .toList();
  }

  /// Fetches a volume‐max value (or null).
  Future<double?> fetchVolumeMax(int defId, String timeframe) async {
    final row = await StatsDao.getVolumeMax(db, defId, timeframe);
    if (row == null) return null;
    return (row['vm_value'] as num).toDouble();
  }

  /// Fetches the total number of sets per body-part for a given time range.
  Future<Map<int, int>> _fetchWeightSetCountsByDefinition({
    required DateTime start,
    required DateTime end,
    int? defId,
  }) async {
    final args = <Object?>[
      TemporalSemantics.utcEpochMilliseconds(start),
      TemporalSemantics.utcEpochMilliseconds(end),
    ];
    final defFilter = defId == null ? '' : 'AND e.exercise_def_id = ?';
    if (defId != null) args.add(defId);

    final rows = await db.rawQuery('''
      SELECT e.exercise_def_id AS def_id, COUNT(s.id) AS set_count
      FROM sets s
      INNER JOIN exercises e ON e.id = s.exercise_id
      INNER JOIN sessions sess ON sess.id = e.session_id
      WHERE e.type = 'weight'
        AND e.exercise_def_id IS NOT NULL
        AND sess.completed_at_ms >= ? AND sess.completed_at_ms <= ?
        $defFilter
      GROUP BY e.exercise_def_id
      ''', args);

    return {
      for (final row in rows)
        row['def_id'] as int: ((row['set_count'] as num?) ?? 0).toInt(),
    };
  }

  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final setCounts = await _fetchWeightSetCountsByDefinition(
      start: start,
      end: end,
    );
    if (setCounts.isEmpty) return {};

    // For each definition, fetch its body-part map and sum by lookup ID.
    // BodyPart is a plain value object, so two BodyPart(Chest) instances from
    // different exercise definitions are not equal as Map keys.
    final allBodyParts = await LookupDao.getAllBodyParts(db);
    final bodyPartById = {
      for (final bodyPart in allBodyParts) bodyPart.id: bodyPart,
    };
    final combinedById = <int, double>{};
    for (final entry in setCounts.entries) {
      final perDef = await fetchBodyPartSetsForExerciseOverTimeRange(
        defId: entry.key,
        start: start,
        end: end,
        setCountOverride: entry.value,
        bodyPartByIdOverride: bodyPartById,
      );
      perDef.forEach((bp, val) {
        combinedById[bp.id] = (combinedById[bp.id] ?? 0.0) + val;
      });
    }
    final combined = <BodyPart, double>{};
    combinedById.forEach((bodyPartId, val) {
      final bodyPart = bodyPartById[bodyPartId];
      if (bodyPart != null) {
        combined[bodyPart] = val;
      }
    });
    return combined;
  }

  ///// Fetches the total number of sets per body-part for a specific exercise definition
  /// over a given time range.
  Future<Map<BodyPart, double>> fetchBodyPartSetsForExerciseOverTimeRange({
    required int defId,
    required DateTime start,
    required DateTime end,
    int? setCountOverride,
    Map<int, BodyPart>? bodyPartByIdOverride,
  }) async {
    final setCount =
        setCountOverride ??
        (await _fetchWeightSetCountsByDefinition(
          start: start,
          end: end,
          defId: defId,
        ))[defId] ??
        0;
    if (setCount <= 0) return {};

    // 2) prepare results & body-part lookup
    final result = <BodyPart, double>{};
    final bpById =
        bodyPartByIdOverride ??
        {for (final bp in await LookupDao.getAllBodyParts(db)) bp.id: bp};

    final def = await DefinitionDao.getExerciseDefinitionById(db, defId);
    if (def == null) return {};
    final multiply = def.multiplyByRating;
    final ratingMul = def.rating / 100.0;
    final allocation = await ExerciseAllocationResolver.resolve(db, defId);
    allocation.bodyPartHistoryCredits.forEach((bodyPartId, perSetCredit) {
      final bodyPart = bpById[bodyPartId];
      if (bodyPart != null) {
        result[bodyPart] = (result[bodyPart] ?? 0.0) + perSetCredit * setCount;
      }
    });

    if (multiply) {
      result.updateAll((bp, val) => val * ratingMul);
    }
    return result;
  }

  /// Fetches muscle set credits for a specific exercise definition over a time
  /// range. The allocation resolver retains the legacy manual-toggle behavior
  /// until an explicit creator or personal allocation replaces it.
  Future<Map<int, double>> fetchMuscleSetsForExerciseOverTimeRange({
    required int defId,
    required DateTime start,
    required DateTime end,
    int? setCountOverride,
  }) async {
    final setCount =
        setCountOverride ??
        (await _fetchWeightSetCountsByDefinition(
          start: start,
          end: end,
          defId: defId,
        ))[defId] ??
        0;
    if (setCount <= 0) return {};

    final def = await DefinitionDao.getExerciseDefinitionById(db, defId);
    if (def == null) return {};

    final multiply = def.multiplyByRating;
    final ratingMul = def.rating / 100.0;

    final allocation = await ExerciseAllocationResolver.resolve(db, defId);

    // Multiply resolved per-set credits by the SQL-counted completed rows.
    final result = <int, double>{};
    allocation.muscleHistoryCredits.forEach((mid, perSet) {
      result[mid] = (result[mid] ?? 0) + perSet * setCount;
    });

    if (multiply) {
      result.updateAll((mid, val) => val * ratingMul);
    }
    return result;
  }

  /// Fetches the total number of “muscle-units” across *all* definitions
  /// for weight exercises in the given time window.
  Future<Map<int, double>> fetchAllMuscleSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final setCounts = await _fetchWeightSetCountsByDefinition(
      start: start,
      end: end,
    );
    if (setCounts.isEmpty) return {};

    // sum each definition’s muscle-units
    final combined = <int, double>{};
    for (final entry in setCounts.entries) {
      final perDef = await fetchMuscleSetsForExerciseOverTimeRange(
        defId: entry.key,
        start: start,
        end: end,
        setCountOverride: entry.value,
      );
      perDef.forEach((mid, val) {
        combined[mid] = (combined[mid] ?? 0) + val;
      });
    }

    return combined;
  }
}
