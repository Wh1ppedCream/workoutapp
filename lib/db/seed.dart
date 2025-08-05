// File: lib/db/seed.dart

import 'dart:convert';
import 'package:flutter/services.dart';  // For rootBundle.loadString
import 'package:sqflite/sqflite.dart';

/// Handles JSON-based seeding of lookup tables, exercise definitions, and stretches.
///
/// Reads static JSON files from assets and populates the database using transactions.
class Seed {
  /// Seeds equipment, body parts, muscles, and exercise definitions.
  static Future<void> seedLookupsAndExercises(Database db) async {
    final eqJson = await rootBundle.loadString('assets/equipment.json');
    final List eqList = json.decode(eqJson);

    final bpJson = await rootBundle.loadString('assets/bodyparts.json');
    final List bpList = json.decode(bpJson);

    final mJson = await rootBundle.loadString('assets/muscles.json');
    final List mList = json.decode(mJson);

    final exJson = await rootBundle.loadString('assets/exercises.json');
    final List exList = json.decode(exJson);

    await db.transaction((txn) async {
      for (var item in eqList) {
        await txn.insert(
          'equipment',
          {'name': item['name']},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      for (var item in bpList) {
        await txn.insert(
          'bodypart',
          {'name': item['name']},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      for (var item in mList) {
        await txn.insert(
          'muscles',
          {'name': item['name']},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      for (var item in exList) {
        final List eqNames = item['equipment'] as List;
        int? eqId;
        if (eqNames.isNotEmpty) {
          final primary = eqNames.first as String;
          final rows = await txn.query(
            'equipment',
            where: 'name = ?',
            whereArgs: [primary],
          );
          eqId = rows.isNotEmpty ? rows.first['id'] as int : null;
        }

        final defMap = <String, dynamic>{
  'name':         item['name'],
  'equipment_id': eqId,
  'rating':       item['rating'],
};

if (item.containsKey('useManualBodyparts')) {
  defMap['use_manual_bodyparts'] = item['useManualBodyparts'] ? 1 : 0;
}
if (item.containsKey('useManualMuscles')) {
  defMap['use_manual_muscles'] = item['useManualMuscles'] ? 1 : 0;
}
if (item.containsKey('setupNotes')) {
  defMap['setup_notes'] = item['setupNotes'] as String;
}
if (item.containsKey('executionNotes')) {
  defMap['execution_notes'] = item['executionNotes'] as String;
}
if (item.containsKey('tipsNotes')) {
  defMap['tips_notes'] = item['tipsNotes'] as String;
}
if (item.containsKey('multiplyByRating')) {
  defMap['multiply_by_rating'] = item['multiplyByRating'] ? 1 : 0;
}

final defId = await txn.insert(
  'exercise_definitions',
  defMap,
  conflictAlgorithm: ConflictAlgorithm.ignore,
);

        for (var eName in eqNames) {
          final rows2 = await txn.query(
            'equipment',
            where: 'name = ?',
            whereArgs: [eName],
          );
          if (rows2.isNotEmpty) {
            await txn.insert(
              'exercise_equipment',
              {
                'exercise_id': defId,
                'equipment_id': rows2.first['id'] as int,
              },
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }

        for (var bpName in (item['bodyparts'] as List)) {
          final bRows = await txn.query(
            'bodypart',
            where: 'name = ?',
            whereArgs: [bpName],
          );
          if (bRows.isNotEmpty) {
            await txn.insert(
              'exercise_bodypart',
              {
                'exercise_id': defId,
                'bodypart_id': bRows.first['id'] as int,
              },
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }

        for (var mEntry in (item['muscles'] as List)) {
          final name = mEntry['name'] as String;
          final rank = (mEntry['rank'] as num).toInt();
          final mRows = await txn.query(
            'muscles',
            where: 'name = ?',
            whereArgs: [name],
          );
          if (mRows.isNotEmpty) {
            await txn.insert(
              'exercise_muscle',
              {
                'exercise_id': defId,
                'muscle_id': mRows.first['id'] as int,
                'rank': rank,
              },
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }
      }
    });
  }

  /// Seeds stretch definitions and their body part associations.
  static Future<void> seedStretches(Database db) async {
    final stJson = await rootBundle.loadString('assets/stretches.json');
    final List stList = json.decode(stJson);

    await db.transaction((txn) async {
      for (var item in stList) {
        final sid = await txn.insert(
          'stretch_definitions',
          {
            'name': item['name'],
            'description': item['description'] ?? '',
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );

        for (var bpName in (item['bodyparts'] as List)) {
          final bRows = await txn.query(
            'bodypart',
            where: 'name = ?',
            whereArgs: [bpName],
          );
          if (bRows.isNotEmpty) {
            await txn.insert(
              'stretch_bodypart',
              {
                'stretch_id': sid,
                'bodypart_id': bRows.first['id'] as int,
              },
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }
      }
    });
  }

  /// Seeds all the analytics-default tables.
  static Future<void> seedAnalyticsDefaults(Database db) async {
    final mbpJson = await rootBundle.loadString('assets/muscle_bodypart.json');
    final bpRankJson = await rootBundle.loadString('assets/bodypart_ranking.json');
    final mRankJson = await rootBundle.loadString('assets/muscle_ranking.json');
    final bpmRankJson = await rootBundle.loadString('assets/bodypart_muscle_rankings.json');
    final volJson = await rootBundle.loadString('assets/volume_boundaries.json');

    final List mbpList = json.decode(mbpJson);
    final List bpRankList = json.decode(bpRankJson);
    final List mRankList = json.decode(mRankJson);
    final List bpmRankList = json.decode(bpmRankJson);
    final Map<String, dynamic> volMap = json.decode(volJson);

    await db.transaction((txn) async {
      for (var entry in mbpList) {
        final bpRows = await txn.query(
          'bodypart',
          where: 'name = ?',
          whereArgs: [entry['bodypart']],
          limit: 1,
        );
        if (bpRows.isEmpty) continue;
        final bpId = bpRows.first['id'] as int;

        for (var mName in (entry['muscles'] as List)) {
          final mRows = await txn.query(
            'muscles',
            where: 'name = ?',
            whereArgs: [mName],
            limit: 1,
          );
          if (mRows.isEmpty) continue;
          final mId = mRows.first['id'] as int;

          await txn.insert(
            'muscle_bodypart',
            {'bodypart_id': bpId, 'muscle_id': mId},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }

      for (var entry in bpRankList) {
        final bpRows = await txn.query(
          'bodypart',
          where: 'name = ?',
          whereArgs: [entry['bodypart']],
          limit: 1,
        );
        if (bpRows.isEmpty) continue;
        await txn.insert(
          'bodypart_ranking',
          {
            'bodypart_id': bpRows.first['id'],
            'rank': entry['rank'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (var entry in mRankList) {
        final mRows = await txn.query(
          'muscles',
          where: 'name = ?',
          whereArgs: [entry['muscle']],
          limit: 1,
        );
        if (mRows.isEmpty) continue;
        await txn.insert(
          'muscle_ranking',
          {
            'muscle_id': mRows.first['id'],
            'rank': entry['rank'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (var entry in bpmRankList) {
        final bpRows = await txn.query(
          'bodypart',
          where: 'name = ?',
          whereArgs: [entry['bodypart']],
          limit: 1,
        );
        if (bpRows.isEmpty) continue;
        final bpId = bpRows.first['id'] as int;

        for (var mr in (entry['muscleRanks'] as List)) {
          final mRows = await txn.query(
            'muscles',
            where: 'name = ?',
            whereArgs: [mr['muscle']],
            limit: 1,
          );
          if (mRows.isEmpty) continue;
          await txn.insert(
            'bodypart_muscle_rankings',
            {
              'bodypart_id': bpId,
              'muscle_id': mRows.first['id'],
              'rank': mr['rank'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      for (var bpEntry in (volMap['bodyparts'] as List)) {
        final bpRows = await txn.query(
          'bodypart',
          where: 'name = ?',
          whereArgs: [bpEntry['bodypart']],
          limit: 1,
        );
        if (bpRows.isEmpty) continue;
        final bpId = bpRows.first['id'] as int;

        await txn.insert(
          'bodypart_volume_boundaries',
          {
            'bodypart_id': bpId,
            'maintenance_volume': bpEntry['maintenance'],
            'min_effective_volume': bpEntry['minEffective'],
            'max_adaptive_volume': bpEntry['maxAdaptive'],
            'max_recoverable_volume': bpEntry['maxRecoverable'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (var mEntry in (volMap['muscles'] as List)) {
        final mRows = await txn.query(
          'muscles',
          where: 'name = ?',
          whereArgs: [mEntry['muscle']],
          limit: 1,
        );
        if (mRows.isEmpty) continue;
        final mId = mRows.first['id'] as int;

        await txn.insert(
          'muscle_volume_boundaries',
          {
            'muscle_id': mId,
            'maintenance_volume': mEntry['maintenance'],
            'min_effective_volume': mEntry['minEffective'],
            'max_adaptive_volume': mEntry['maxAdaptive'],
            'max_recoverable_volume': mEntry['maxRecoverable'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
