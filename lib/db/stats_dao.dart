// File: lib/db/stats_dao.dart

import 'package:sqflite/sqflite.dart';

/// DAO for upserting and querying rep-max and volume-max stats.
class StatsDao {
  /// Inserts or replaces a rep-max entry.
  /// 
  /// defId: exercise_definition.id
  /// repCount: 1…20
  /// timeframe: 'all' (later ‘week’/’month’)
  /// rmValue: the recorded max weight for this repCount
  /// oneErm: estimated 1-Rep Max for the set
  /// isErm: true if rmValue is an ERM fallback
  static Future<void> upsertRepMax(
    Database db,
    int defId,
    int repCount,
    String timeframe,
    double rmValue,
    double oneErm,
    bool isErm,
  ) {
    return db.insert(
      'exercise_rep_max',
      {
        'def_id': defId,
        'rep_count': repCount,
        'timeframe': timeframe,
        'rm_value': rmValue,
        'one_erm': oneErm,
        'is_erm': isErm ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Inserts or replaces a volume-max entry.
  static Future<void> upsertVolumeMax(
    Database db,
    int defId,
    String timeframe,
    double vmValue,
  ) {
    return db.insert(
      'exercise_volume_max',
      {
        'def_id': defId,
        'timeframe': timeframe,
        'vm_value': vmValue,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetches all stored rep-max rows for a given exercise definition and timeframe.
  /// Returns rows sorted by rep_count ascending.
  static Future<List<Map<String, dynamic>>> getRepMaxes(
    Database db,
    int defId,
    String timeframe,
  ) {
    return db.query(
      'exercise_rep_max',
      where:    'def_id = ? AND timeframe = ?',
      whereArgs:[defId, timeframe],
      orderBy:  'rep_count',
    );
  }

  /// Fetches the volume-max entry for a given exercise definition and timeframe.
  /// Returns a single row with keys: `vm_value` (or null if none).
  static Future<Map<String, dynamic>?> getVolumeMax(
    Database db,
    int defId,
    String timeframe,
  ) async {
    final rows = await db.query(
      'exercise_volume_max',
      where:    'def_id = ? AND timeframe = ?',
      whereArgs:[defId, timeframe],
      limit:    1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

}
