// File: lib/db/seed.dart

import 'dart:convert';
import 'package:flutter/services.dart';  // For rootBundle.loadString
import 'package:sqflite/sqflite.dart';

/// Handles JSON-based seeding of lookup and exercise data.
class Seed {
  /// Seeds equipment, body parts, muscles, and exercises from JSON files.
  static Future<void> seedLookupsAndExercises(Database db) async {
    // 1) Equipment lookup
    final eqJson = await rootBundle.loadString('assets/data/equipment.json');
    final List eqList = json.decode(eqJson);

    // 2) Body parts lookup
    final bpJson = await rootBundle.loadString('assets/data/bodyparts.json');
    final List bpList = json.decode(bpJson);

    // 3) Muscles lookup
    final mJson = await rootBundle.loadString('assets/data/muscles.json');
    final List mList = json.decode(mJson);

    // 4) Exercises definitions
    final exJson = await rootBundle.loadString('assets/data/exercises.json');
    final List exList = json.decode(exJson);

    await db.transaction((txn) async {
      // Insert equipment
      for (var item in eqList) {
        await txn.insert(
          'equipment',
          {'name': item['name']},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // Insert body parts
      for (var item in bpList) {
        await txn.insert(
          'bodypart',
          {'name': item['name']},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // Insert muscles
      for (var item in mList) {
        await txn.insert(
          'muscles',
          {'name': item['name']},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // Insert exercise definitions and relationships
      for (var item in exList) {
        // Determine primary equipment_id
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

        // Insert definition
        final defId = await txn.insert(
          'exercise_definitions',
          {
            'name': item['name'],
            'equipment_id': eqId,
            'rating': item['rating'],
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );

        // Link many-to-many equipment
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

        // Link body parts
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

        // Link ranked muscles
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

  /// Seeds stretch definitions and their associated body parts.
  static Future<void> seedStretches(Database db) async {
    final stJson = await rootBundle.loadString('assets/data/stretches.json');
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
}
