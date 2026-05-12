// File: lib/db/analytics_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

/// Data Access Object for analytics‐related tables:
///  • muscle_bodypart
///  • bodypart_ranking
///  • muscle_ranking
///  • exercise_muscle_percent
///  • muscle_volume_boundaries
///  • bodypart_volume_boundaries
class AnalyticsDao {
  static MuscleBodyPart _muscleBodyPartFromRow(Map<String, Object?> row) {
    return MuscleBodyPart(
      muscleId: row['muscle_id'] as int,
      bodyPartId: row['bodypart_id'] as int,
    );
  }

  static BodyPartRanking _bodyPartRankingFromRow(Map<String, Object?> row) {
    return BodyPartRanking(
      bodyPartId: row['bodypart_id'] as int,
      rank: row['rank'] as int,
    );
  }

  static MuscleRanking _muscleRankingFromRow(Map<String, Object?> row) {
    return MuscleRanking(
      muscleId: row['muscle_id'] as int,
      rank: row['rank'] as int,
    );
  }

  static ExerciseMusclePercent _exerciseMusclePercentFromRow(
    Map<String, Object?> row,
  ) {
    return ExerciseMusclePercent(
      exerciseDefId: row['exercise_def_id'] as int,
      muscleId: row['muscle_id'] as int,
      percent: (row['percent'] as num).toDouble(),
    );
  }

  static ExerciseBodyPartPercent _exerciseBodyPartPercentFromRow(
    Map<String, Object?> row,
  ) {
    return ExerciseBodyPartPercent(
      exerciseDefId: row['exercise_def_id'] as int,
      bodyPartId: row['bodypart_id'] as int,
      percent: (row['percent'] as num).toDouble(),
    );
  }

  static VolumeBoundaries _volumeBoundariesFromRow(
    Map<String, Object?> row,
    String idColumn,
  ) {
    return VolumeBoundaries(
      id: row[idColumn] as int,
      maintenance: (row['maintenance_volume'] as num).toDouble(),
      minEffective: (row['min_effective_volume'] as num).toDouble(),
      maxAdaptive: (row['max_adaptive_volume'] as num).toDouble(),
      maxRecoverable: (row['max_recoverable_volume'] as num).toDouble(),
    );
  }

  static Map<String, Object?> _volumeBoundaryValues(
    String idColumn,
    int id,
    VolumeBoundaries bounds,
  ) {
    return {
      idColumn: id,
      'maintenance_volume': bounds.maintenance,
      'min_effective_volume': bounds.minEffective,
      'max_adaptive_volume': bounds.maxAdaptive,
      'max_recoverable_volume': bounds.maxRecoverable,
    };
  }

  // ─── MUSCLE ←→ BODYPART ─────────────────────────────────

  /// Link a muscle to a body part.
  static Future<int> insertMuscleBodyPart(
    Database db,
    int muscleId,
    int bodypartId,
  ) {
    return db.insert('muscle_bodypart', {
      'muscle_id': muscleId,
      'bodypart_id': bodypartId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Remove a link between a muscle and a body part.
  static Future<int> deleteMuscleBodyPart(
    Database db,
    int muscleId,
    int bodypartId,
  ) {
    return db.delete(
      'muscle_bodypart',
      where: 'muscle_id = ? AND bodypart_id = ?',
      whereArgs: [muscleId, bodypartId],
    );
  }

  /// Get all body-part links for a given muscle.
  static Future<List<MuscleBodyPart>> getBodyPartsForMuscle(
    Database db,
    int muscleId,
  ) async {
    final rows = await db.query(
      'muscle_bodypart',
      where: 'muscle_id = ?',
      whereArgs: [muscleId],
    );
    return rows.map(_muscleBodyPartFromRow).toList();
  }

  /// Get all muscle links for a given body part.
  static Future<List<MuscleBodyPart>> getMusclesForBodyPart(
    Database db,
    int bodypartId,
  ) async {
    final rows = await db.query(
      'muscle_bodypart',
      where: 'bodypart_id = ?',
      whereArgs: [bodypartId],
    );
    return rows.map(_muscleBodyPartFromRow).toList();
  }

  // ─── RANKING ─────────────────────────────────────────────

  /// Upsert a body-part ranking.
  static Future<int> setBodyPartRanking(Database db, int bodypartId, int rank) {
    return db.insert('bodypart_ranking', {
      'bodypart_id': bodypartId,
      'rank': rank,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch ranking for one body part.
  static Future<BodyPartRanking?> getBodyPartRanking(
    Database db,
    int bodypartId,
  ) async {
    final rows = await db.query(
      'bodypart_ranking',
      where: 'bodypart_id = ?',
      whereArgs: [bodypartId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _bodyPartRankingFromRow(rows.first);
  }

  /// Fetch all body-part rankings.
  static Future<List<BodyPartRanking>> getAllBodyPartRankings(
    Database db,
  ) async {
    final rows = await db.query('bodypart_ranking', orderBy: 'rank');
    return rows.map(_bodyPartRankingFromRow).toList();
  }

  /// Remove a body-part ranking.
  static Future<int> deleteBodyPartRanking(Database db, int bodypartId) {
    return db.delete(
      'bodypart_ranking',
      where: 'bodypart_id = ?',
      whereArgs: [bodypartId],
    );
  }

  /// Upsert a muscle ranking.
  static Future<int> setMuscleRanking(Database db, int muscleId, int rank) {
    return db.insert('muscle_ranking', {
      'muscle_id': muscleId,
      'rank': rank,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch ranking for one muscle.
  static Future<MuscleRanking?> getMuscleRanking(
    Database db,
    int muscleId,
  ) async {
    final rows = await db.query(
      'muscle_ranking',
      where: 'muscle_id = ?',
      whereArgs: [muscleId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _muscleRankingFromRow(rows.first);
  }

  /// Fetch all muscle rankings.
  static Future<List<MuscleRanking>> getAllMuscleRankings(Database db) async {
    final rows = await db.query('muscle_ranking', orderBy: 'rank');
    return rows.map(_muscleRankingFromRow).toList();
  }

  /// Remove a muscle ranking.
  static Future<int> deleteMuscleRanking(Database db, int muscleId) {
    return db.delete(
      'muscle_ranking',
      where: 'muscle_id = ?',
      whereArgs: [muscleId],
    );
  }

  // ─── EXERCISE ↔ MUSCLE % HIT ─────────────────────────────

  /// Upsert a %-hit for a muscle in an exercise definition.
  static Future<int> setExerciseMusclePercent(
    Database db,
    int exerciseDefId,
    int muscleId,
    double percent,
  ) {
    return db.insert('exercise_muscle_percent', {
      'exercise_def_id': exerciseDefId,
      'muscle_id': muscleId,
      'percent': percent,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch one %-hit entry.
  static Future<ExerciseMusclePercent?> getExerciseMusclePercent(
    Database db,
    int exerciseDefId,
    int muscleId,
  ) async {
    final rows = await db.query(
      'exercise_muscle_percent',
      where: 'exercise_def_id = ? AND muscle_id = ?',
      whereArgs: [exerciseDefId, muscleId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _exerciseMusclePercentFromRow(rows.first);
  }

  /// Fetch all %-hits for an exercise.
  static Future<List<ExerciseMusclePercent>> getPercentsForExercise(
    Database db,
    int exerciseDefId,
  ) async {
    final rows = await db.query(
      'exercise_muscle_percent',
      where: 'exercise_def_id = ?',
      whereArgs: [exerciseDefId],
    );
    return rows.map(_exerciseMusclePercentFromRow).toList();
  }

  /// Remove one %-hit entry.
  static Future<int> deleteExerciseMusclePercent(
    Database db,
    int exerciseDefId,
    int muscleId,
  ) {
    return db.delete(
      'exercise_muscle_percent',
      where: 'exercise_def_id = ? AND muscle_id = ?',
      whereArgs: [exerciseDefId, muscleId],
    );
  }

  // ─── VOLUME BOUNDARIES ───────────────────────────────────

  /// Upsert volume boundaries for a muscle.
  static Future<int> setMuscleVolumeBoundaries(
    Database db,
    int muscleId,
    VolumeBoundaries bounds,
  ) {
    return db.insert(
      'muscle_volume_boundaries',
      _volumeBoundaryValues('muscle_id', muscleId, bounds),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch boundaries for one muscle.
  static Future<VolumeBoundaries?> getMuscleVolumeBoundaries(
    Database db,
    int muscleId,
  ) async {
    final rows = await db.query(
      'muscle_volume_boundaries',
      where: 'muscle_id = ?',
      whereArgs: [muscleId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _volumeBoundariesFromRow(rows.first, 'muscle_id');
  }

  /// Fetch all muscle boundaries (raw map).
  static Future<List<Map<String, dynamic>>> getAllMuscleVolumeBoundaries(
    Database db,
  ) {
    return db.query('muscle_volume_boundaries', orderBy: 'muscle_id');
  }

  /// Remove muscle boundaries.
  static Future<int> deleteMuscleVolumeBoundaries(Database db, int muscleId) {
    return db.delete(
      'muscle_volume_boundaries',
      where: 'muscle_id = ?',
      whereArgs: [muscleId],
    );
  }

  /// Upsert volume boundaries for a body part.
  static Future<int> setBodyPartVolumeBoundaries(
    Database db,
    int bodypartId,
    VolumeBoundaries bounds,
  ) {
    return db.insert(
      'bodypart_volume_boundaries',
      _volumeBoundaryValues('bodypart_id', bodypartId, bounds),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch boundaries for one body part.
  static Future<VolumeBoundaries?> getBodyPartVolumeBoundaries(
    Database db,
    int bodypartId,
  ) async {
    final rows = await db.query(
      'bodypart_volume_boundaries',
      where: 'bodypart_id = ?',
      whereArgs: [bodypartId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _volumeBoundariesFromRow(rows.first, 'bodypart_id');
  }

  /// Fetch all body-part boundaries (raw map).
  static Future<List<Map<String, dynamic>>> getAllBodyPartVolumeBoundaries(
    Database db,
  ) {
    return db.query('bodypart_volume_boundaries', orderBy: 'bodypart_id');
  }

  /// Remove body-part boundaries.
  static Future<int> deleteBodyPartVolumeBoundaries(
    Database db,
    int bodypartId,
  ) {
    return db.delete(
      'bodypart_volume_boundaries',
      where: 'bodypart_id = ?',
      whereArgs: [bodypartId],
    );
  }

  // ─── EXERCISE ↔ BODYPART % OVERRIDES ─────────────────────

  static Future<int> setExerciseBodyPartPercent(
    Database db,
    int exerciseDefId,
    int bodypartId,
    double percent,
  ) {
    return db.insert('exercise_bodypart_percent', {
      'exercise_def_id': exerciseDefId,
      'bodypart_id': bodypartId,
      'percent': percent,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<ExerciseBodyPartPercent>> getPercentsForExerciseBodyPart(
    Database db,
    int exerciseDefId,
  ) async {
    final rows = await db.query(
      'exercise_bodypart_percent',
      where: 'exercise_def_id = ?',
      whereArgs: [exerciseDefId],
    );
    return rows.map(_exerciseBodyPartPercentFromRow).toList();
  }

  static Future<int> deleteExerciseBodyPartPercent(
    Database db,
    int exerciseDefId,
    int bodypartId,
  ) {
    return db.delete(
      'exercise_bodypart_percent',
      where: 'exercise_def_id = ? AND bodypart_id = ?',
      whereArgs: [exerciseDefId, bodypartId],
    );
  }
}
