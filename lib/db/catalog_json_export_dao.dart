import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'definition_dao.dart';
import 'lookup_dao.dart';

/// Database operations for CatalogJsonExport without owning a connection.
class CatalogJsonExportDao {
  const CatalogJsonExportDao(this.db);

  final DatabaseExecutor db;

  Future<String> _exportNameListJson(String table) async {
    final rows = await db.query(table);
    final out = rows.map((r) => {'name': r['name'] as String}).toList();
    return jsonEncode(out);
  }

  Future<String> exportEquipmentJson() => _exportNameListJson('equipment');

  /// bodyparts.json
  Future<String> exportBodypartsJson() => _exportNameListJson('bodypart');

  /// muscles.json
  Future<String> exportMusclesJson() => _exportNameListJson('muscles');

  /// exercises.json
  Future<String> exportExercisesJson() async {
    final defs = await DefinitionDao.getAllExerciseDefinitionsDetailedBatched(
      db,
    );
    final out = defs.map((def) {
      final map = <String, dynamic>{
        'name': def.name,
        'rating': def.rating,
        'equipment': def.equipmentList.map((e) => e.name).toList(),
        'bodyparts': def.bodyParts.map((bp) => bp.name).toList(),
        'muscles': def.muscles
            .map((rm) => {'name': rm.muscle.name, 'rank': rm.rank})
            .toList(),
      };
      if (def.useManualBodyparts) {
        map['useManualBodyparts'] = true;
      }
      if (def.setupNotes.isNotEmpty) {
        map['setupNotes'] = def.setupNotes;
      }
      if (def.executionNotes.isNotEmpty) {
        map['executionNotes'] = def.executionNotes;
      }
      if (def.tipsNotes.isNotEmpty) {
        map['tipsNotes'] = def.tipsNotes;
      }
      if (def.multiplyByRating) {
        map['multiplyByRating'] = true;
      }
      return map;
    }).toList();
    return jsonEncode(out);
  }

  /// stretches.json
  Future<String> exportStretchesJson() async {
    final defs = await LookupDao.getStretches(db, null);
    final out = defs
        .map(
          (s) => {
            'name': s.name,
            'bodyparts': s.bodyParts.map((bp) => bp.name).toList(),
            'description': s.description,
          },
        )
        .toList();
    return jsonEncode(out);
  }

  /// muscle_bodypart.json
  Future<String> exportMuscleBodypartJson() async {
    final rows = await db.rawQuery('''
      SELECT bp.name AS bodypart, m.name AS muscle
        FROM muscle_bodypart mb
        JOIN bodypart bp ON mb.bodypart_id = bp.id
        JOIN muscles m    ON mb.muscle_id   = m.id
    ''');
    final Map<String, List<String>> grouped = {};
    for (var r in rows) {
      final bp = r['bodypart'] as String;
      grouped.putIfAbsent(bp, () => []).add(r['muscle'] as String);
    }
    final out = grouped.entries
        .map((e) => {'bodypart': e.key, 'muscles': e.value})
        .toList();
    return jsonEncode(out);
  }

  /// bodypart_ranking.json
  Future<String> exportBodypartRankingJson() async {
    final rows = await db.rawQuery('''
      SELECT bp.name  AS bodypart,
             r.rank    AS rank
        FROM bodypart_ranking r
        JOIN bodypart bp ON r.bodypart_id = bp.id
    ''');
    final out = rows
        .map(
          (r) => {
            'bodypart': r['bodypart'] as String,
            'rank': r['rank'] as int,
          },
        )
        .toList();
    return jsonEncode(out);
  }

  /// muscle_ranking.json
  Future<String> exportMuscleRankingJson() async {
    final rows = await db.rawQuery('''
      SELECT m.name  AS muscle,
             r.rank  AS rank
        FROM muscle_ranking r
        JOIN muscles m ON r.muscle_id = m.id
    ''');
    final out = rows
        .map((r) => {'muscle': r['muscle'] as String, 'rank': r['rank'] as int})
        .toList();
    return jsonEncode(out);
  }

  /// bodypart_muscle_rankings.json
  Future<String> exportBodypartMuscleRankingsJson() async {
    final rows = await db.rawQuery('''
      SELECT bp.name  AS bodypart,
             m.name   AS muscle,
             r.rank   AS rank
        FROM bodypart_muscle_rankings r
        JOIN bodypart bp ON r.bodypart_id = bp.id
        JOIN muscles m    ON r.muscle_id   = m.id
        ORDER BY bp.name, r.rank
    ''');
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var row in rows) {
      final bp = row['bodypart'] as String;
      grouped.putIfAbsent(bp, () => []).add({
        'muscle': row['muscle'] as String,
        'rank': row['rank'] as int,
      });
    }
    final out = grouped.entries
        .map((e) => {'bodypart': e.key, 'muscleRanks': e.value})
        .toList();
    return jsonEncode(out);
  }

  /// volume_boundaries.json
  Future<String> exportVolumeBoundariesJson() async {
    final bpRows = await db.rawQuery('''
      SELECT bp.name                     AS bodypart,
             v.maintenance_volume       AS maintenance,
             v.min_effective_volume     AS minEffective,
             v.max_adaptive_volume      AS maxAdaptive,
             v.max_recoverable_volume   AS maxRecoverable
        FROM bodypart_volume_boundaries v
        JOIN bodypart bp ON v.bodypart_id = bp.id
    ''');
    final mRows = await db.rawQuery('''
      SELECT m.name                     AS muscle,
             v.maintenance_volume       AS maintenance,
             v.min_effective_volume     AS minEffective,
             v.max_adaptive_volume      AS maxAdaptive,
             v.max_recoverable_volume   AS maxRecoverable
        FROM muscle_volume_boundaries v
        JOIN muscles m ON v.muscle_id = m.id
    ''');

    return jsonEncode({'bodyparts': bpRows, 'muscles': mRows});
  }
}
