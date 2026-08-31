// File: lib/db/stats_dao.dart

import 'package:sqflite/sqflite.dart';

import '../models/temporal_semantics.dart';
import 'db_query_utils.dart';

/// DAO for rep-max and volume-max stats.
class StatsDao {
  /// Inserts a rep-max entry only when it improves the stored max.
  ///
  /// defId: exercise_definition.id
  /// repCount: reps completed for the set
  /// timeframe: currently written as 'all'; timeframe reads are derived live
  /// rmValue: recorded max weight for this repCount
  /// oneErm: estimated 1-rep max for the set
  /// isErm: true if rmValue is an ERM fallback
  static Future<void> upsertRepMax(
    Database db,
    int defId,
    int repCount,
    String timeframe,
    double rmValue,
    double oneErm,
    bool isErm,
  ) async {
    final existing = await db.query(
      'exercise_rep_max',
      columns: ['rm_value', 'one_erm'],
      where: 'def_id = ? AND rep_count = ? AND timeframe = ?',
      whereArgs: [defId, repCount, timeframe],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final current = existing.first;
      final currentRmValue = (current['rm_value'] as num).toDouble();
      final currentOneErm = (current['one_erm'] as num).toDouble();
      final isDowngrade =
          oneErm < currentOneErm ||
          (oneErm == currentOneErm && rmValue <= currentRmValue);
      if (isDowngrade) return;
    }

    await db.insert('exercise_rep_max', {
      'def_id': defId,
      'rep_count': repCount,
      'timeframe': timeframe,
      'rm_value': rmValue,
      'one_erm': oneErm,
      'is_erm': isErm ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Inserts a volume-max entry only when it improves the stored max.
  static Future<void> upsertVolumeMax(
    Database db,
    int defId,
    String timeframe,
    double vmValue,
  ) async {
    final existing = await db.query(
      'exercise_volume_max',
      columns: ['vm_value'],
      where: 'def_id = ? AND timeframe = ?',
      whereArgs: [defId, timeframe],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final currentVmValue = (existing.first['vm_value'] as num).toDouble();
      if (vmValue <= currentVmValue) return;
    }

    await db.insert('exercise_volume_max', {
      'def_id': defId,
      'timeframe': timeframe,
      'vm_value': vmValue,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetches rep-max rows for a given exercise definition and timeframe.
  ///
  /// Reads are calculated from completed set history so week/month/all are
  /// always current. The stored table remains as a fallback for older imports.
  static Future<List<Map<String, dynamic>>> getRepMaxes(
    Database db,
    int defId,
    String timeframe,
  ) async {
    final cutoff = _cutoffForTimeframe(timeframe);
    final dateClause = cutoff == null ? '' : 'AND sess.completed_at_ms >= ?';
    final args = <Object?>[defId];
    if (cutoff != null) {
      args.add(TemporalSemantics.utcEpochMilliseconds(cutoff));
    }

    final rows = await db.rawQuery(
      '''
      SELECT
        e.exercise_def_id AS def_id,
        s.reps AS rep_count,
        ? AS timeframe,
        MAX(s.weight) AS rm_value,
        MAX(s.weight * (1 + 0.0333 * s.reps)) AS one_erm,
        0 AS is_erm
      FROM sets s
      INNER JOIN exercises e ON e.id = s.exercise_id
      INNER JOIN sessions sess ON sess.id = e.session_id
      WHERE e.type = 'weight'
        AND e.exercise_def_id = ?
        AND s.parent_set_id IS NULL
        $dateClause
      GROUP BY e.exercise_def_id, s.reps
      ORDER BY s.reps
    ''',
      <Object?>[timeframe, ...args],
    );

    final mappedRows = dynamicRows(rows);
    if (mappedRows.isNotEmpty || timeframe != 'all') return mappedRows;

    return _getStoredRepMaxes(db, defId, timeframe);
  }

  /// Fetches the volume-max entry for a given exercise definition and timeframe.
  ///
  /// Volume max is calculated as the highest total volume for one completed
  /// exercise instance inside the selected timeframe.
  static Future<Map<String, dynamic>?> getVolumeMax(
    Database db,
    int defId,
    String timeframe,
  ) async {
    final cutoff = _cutoffForTimeframe(timeframe);
    final dateClause = cutoff == null ? '' : 'AND sess.completed_at_ms >= ?';
    final args = <Object?>[defId];
    if (cutoff != null) {
      args.add(TemporalSemantics.utcEpochMilliseconds(cutoff));
    }

    final rows = await db.rawQuery('''
      SELECT MAX(exercise_volume) AS vm_value
      FROM (
        SELECT SUM(s.weight * s.reps) AS exercise_volume
        FROM sets s
        INNER JOIN exercises e ON e.id = s.exercise_id
        INNER JOIN sessions sess ON sess.id = e.session_id
        WHERE e.type = 'weight'
          AND e.exercise_def_id = ?
          AND s.parent_set_id IS NULL
          $dateClause
        GROUP BY e.id
      )
    ''', args);

    final row = firstDynamicRow(rows);
    if (row != null && row['vm_value'] != null) {
      return row;
    }
    if (timeframe != 'all') return null;

    return _getStoredVolumeMax(db, defId, timeframe);
  }

  static Future<List<Map<String, dynamic>>> _getStoredRepMaxes(
    Database db,
    int defId,
    String timeframe,
  ) async {
    final rows = await db.query(
      'exercise_rep_max',
      where: 'def_id = ? AND timeframe = ?',
      whereArgs: [defId, timeframe],
      orderBy: 'rep_count',
    );
    return dynamicRows(rows);
  }

  static Future<Map<String, dynamic>?> _getStoredVolumeMax(
    Database db,
    int defId,
    String timeframe,
  ) async {
    final rows = await db.query(
      'exercise_volume_max',
      where: 'def_id = ? AND timeframe = ?',
      whereArgs: [defId, timeframe],
      limit: 1,
    );
    return firstDynamicRow(rows);
  }

  static DateTime? _cutoffForTimeframe(String timeframe) {
    final now = DateTime.now();
    switch (timeframe) {
      case 'week':
        return now.subtract(const Duration(days: 7));
      case 'month':
        return now.subtract(const Duration(days: 30));
      case 'all':
      default:
        return null;
    }
  }
}
