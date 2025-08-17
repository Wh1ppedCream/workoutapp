// File: lib/db/seed.dart

import 'dart:convert';
import 'package:flutter/services.dart';  // For rootBundle.loadString
import 'package:sqflite/sqflite.dart';

const Map<String, String> _legacyCodeMap = {
  'ENERGY_KCAL': 'KCAL',
  'PROTEIN'    : 'PROTEIN_G',
  'FAT'        : 'FAT_G',
  'CARB'       : 'CARB_G',
  'FIBER'      : 'FIBER_G',
  'SUGARS'     : 'SUGARS_TOTAL_G',
  'FASAT'      : 'FA_SAT_G',
  'SODIUM'     : 'SODIUM_MG',
};

Future<int?> _resolveNutrientId(
  DatabaseExecutor txn,
  Map<String,int> codeToId,
  String rawCode,
) async {
  // exact code
  final direct = codeToId[rawCode];
  if (direct != null) return direct;

  // legacy -> new
  final mapped = _legacyCodeMap[rawCode];
  if (mapped != null) {
    final nid = codeToId[mapped];
    if (nid != null) return nid;
  }

  // last resort: try alias match (your seedExtendedNutrients loaded these)
  final rs = await txn.query(
    'nutrient_aliases',
    columns: ['nutrient_id'],
    where: 'alias = ?',
    whereArgs: [rawCode],
    limit: 1,
  );
  return rs.isNotEmpty ? rs.first['nutrient_id'] as int : null;
}



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
        final List eqNames   = (item['equipment']  as List?) ?? const [];
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
};
// only set if present; otherwise let NOT NULL DEFAULT 0 kick in
final rating = item['rating'];
if (rating != null) {
  defMap['rating'] = (rating as num).toInt();
}

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

final defIdRaw = await txn.insert(
  'exercise_definitions',
  defMap,
  conflictAlgorithm: ConflictAlgorithm.ignore,
);

// Get the real id if ignored
int defId = defIdRaw;
if (defId == 0) {
  final rows = await txn.query(
    'exercise_definitions',
    where: 'name = ? AND equipment_id ${eqId == null ? "IS NULL" : "= ?"}',
    whereArgs: eqId == null ? [item['name']] : [item['name'], eqId],
    limit: 1,
  );
  if (rows.isEmpty) throw Exception('exercise_def not found after ignore: ${item['name']}');
  defId = rows.first['id'] as int;
}


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

        final List bpNames   = (item['bodyparts']  as List?) ?? const [];

        for (var bpName in bpNames) {
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
        final List muscles   = (item['muscles']    as List?) ?? const [];

        for (var mEntry in muscles) {
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
        final sidRaw = await txn.insert(
  'stretch_definitions',
  {
    'name': item['name'],
    'description': item['description'] ?? '',
  },
  conflictAlgorithm: ConflictAlgorithm.ignore,
);

int sid = sidRaw;
if (sid == 0) {
  final r = await txn.query(
    'stretch_definitions',
    where: 'name = ?',
    whereArgs: [item['name']],
    limit: 1,
  );
  if (r.isEmpty) throw Exception('stretch not found after ignore: ${item['name']}');
  sid = r.first['id'] as int;
}

        final List bpNames   = (item['bodyparts']  as List?) ?? const [];

        for (var bpName in bpNames) {
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



/// Seeds starter foods from assets/foods.json.
/// Works with the old shape and accepts richer optional fields:
/// - brand/manufacturer, category_path, fdc_id, data_source, data_source_id
/// - portions: list_kind, sort_order, amount, unit, label, ml_volume
/// - nutrients_by_basis: { per_100g: {CODE:amt,...}, per_100ml:{...}, per_portion:[{code,amount,portion_desc}], absolute:{...} }
static Future<void> seedFoods(Database db) async {
  final jsonStr = await rootBundle.loadString('assets/foods.json');
  final List list = json.decode(jsonStr);

  // Build nutrient code -> id mapping once
  final Map<String, int> codeToId = await _nutrientCodeMap(db);
   if (codeToId.isEmpty) {
    throw StateError('Seed nutrients first: call Seed.seedExtendedNutrients(db) before Seed.seedFoods(db).');
  }

  await db.transaction((txn) async {
    for (final raw in list) {
      final Map<String, dynamic> item = Map<String, dynamic>.from(raw as Map);

      final name           = item['name'] as String;
      final brandText      = item['brand'] as String?;
      final manufacturer   = item['manufacturer'] as String?;
      final categoryPath   = item['category_path'] as List?;
      final fdcId          = (item['fdc_id'] as num?)?.toInt();
      final source         = (item['data_source'] as String?) ?? 'seed';
      final sourceId       = item['data_source_id'] as String?;
      final barcode        = item['barcode'] as String?;
      final density        = (item['density_g_per_ml'] as num?)?.toDouble();
      final verified       = item['verified'] == true;
      final qualityScore   = (item['quality_score'] as num?)?.toDouble();
      final version        = (item['version'] as num?)?.toInt() ?? 1;
      final preparation    = item['preparation'] as String?;
      final ediblePct      = (item['edible_portion_pct'] as num?)?.toDouble();
      final yieldPct       = (item['yield_pct'] as num?)?.toDouble();

      final brandId = await _ensureBrand(txn, brandText, manufacturer: manufacturer);

      // Upsert food row using best key
      final foodId = await _upsertFood(
        txn: txn,
        name: name,
        brandId: brandId,
        brandText: brandText,
        categoryPath: categoryPath,
        dataSource: source,
        dataSourceId: sourceId,
        fdcId: fdcId,
        barcode: barcode,
        densityGPerMl: density,
        verified: verified,
        qualityScore: qualityScore,
        version: version,
        preparation: preparation,
        ediblePortionPct: ediblePct,
        yieldPct: yieldPct,
      );

      // Portions
      await txn.delete('food_portions', where: 'food_id = ?', whereArgs: [foodId]);
      final portions = (item['portions'] as List? ?? []);
      for (var i = 0; i < portions.length; i++) {
        final p = Map<String, dynamic>.from(portions[i] as Map);
        await txn.insert('food_portions', {
          'food_id'     : foodId,
          'measure_name': p['measure_name'] as String,
          'gram_weight' : (p['gram_weight'] as num?)?.toDouble(),
          'ml_volume'   : (p['ml_volume'] as num?)?.toDouble(),
          'is_default'  : (p['is_default'] == true) ? 1 : 0,
          'list_kind'   : p['list_kind'] as String?,
          'sort_order'  : (p['sort_order'] as num?)?.toInt() ?? i,
          'amount'      : (p['amount'] as num?)?.toDouble(),
          'unit'        : p['unit'] as String?,
          'label'       : p['label'] as String?,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      // Clear flexible table (deterministic reseed)
      await txn.delete('food_nutrient_values', where: 'food_id = ?', whereArgs: [foodId]);

      // Accept either legacy "nutrients" (per_100g) or new "nutrients_by_basis"
      final Map<String, dynamic>? byBasis = item['nutrients_by_basis'] != null
          ? Map<String, dynamic>.from(item['nutrients_by_basis'] as Map)
          : null;

      if (byBasis != null) {
        // keep legacy per_100g table in sync (avoid stale rows)
        await txn.delete('food_nutrients', where: 'food_id = ?', whereArgs: [foodId]);

        // per_100g
        final per100g = (byBasis['per_100g'] as Map?)?.cast<String, dynamic>() ?? const {};
        for (final e in per100g.entries) {
          final nid = await _resolveNutrientId(txn, codeToId, e.key);
          if (nid == null) continue;
          final amt = (e.value as num).toDouble();
          await txn.insert('food_nutrient_values', {
            'food_id': foodId, 'nutrient_id': nid, 'amount': amt, 'basis': 'per_100g',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          // Back-compat legacy table only for per_100g
          await txn.insert('food_nutrients', {
            'food_id': foodId, 'nutrient_id': nid, 'amount_per_100g': amt,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }

        // per_100ml
        final per100ml = (byBasis['per_100ml'] as Map?)?.cast<String, dynamic>() ?? const {};
        for (final e in per100ml.entries) {
          final nid = await _resolveNutrientId(txn, codeToId, e.key);
          if (nid == null) continue;
          final amt = (e.value as num).toDouble();
          await txn.insert('food_nutrient_values', {
            'food_id': foodId, 'nutrient_id': nid, 'amount': amt, 'basis': 'per_100ml',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }

        // per_portion: [{code, amount, portion_desc}] or {code, amount, portion_index}
        final perPortion = (byBasis['per_portion'] as List?) ?? const [];
        for (final rawPP in perPortion) {
          final pp = Map<String, dynamic>.from(rawPP as Map);
          final nid = await _resolveNutrientId(txn, codeToId, pp['code'] as String);
          if (nid == null) continue;

          final amt = (pp['amount'] as num).toDouble();
          int? portionId;
          if (pp['portion_desc'] != null) {
            portionId = await _findPortionId(txn, foodId, pp['portion_desc'] as String);
          } else if (pp['portion_index'] != null) {
            final idx = (pp['portion_index'] as num).toInt();
            final rows = await txn.query(
              'food_portions',
              where: 'food_id = ?',
              whereArgs: [foodId],
              orderBy: 'sort_order, id',
            );
            if (idx >= 0 && idx < rows.length) {
              portionId = rows[idx]['id'] as int;
            }
          }

          await txn.insert('food_nutrient_values', {
            'food_id': foodId, 'nutrient_id': nid, 'amount': amt, 'basis': 'per_portion', 'portion_id': portionId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }

        // absolute
        final absolute = (byBasis['absolute'] as Map?)?.cast<String, dynamic>() ?? const {};
        for (final e in absolute.entries) {
          final nid = await _resolveNutrientId(txn, codeToId, e.key);
          if (nid == null) continue;
          final amt = (e.value as num).toDouble();
          await txn.insert('food_nutrient_values', {
            'food_id': foodId, 'nutrient_id': nid, 'amount': amt, 'basis': 'absolute',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      } else {
        // Legacy per_100g only
        final nutrients = Map<String, dynamic>.from(item['nutrients'] as Map);
        // wipe legacy per_100g table and reinsert deterministically
        await txn.delete('food_nutrients', where: 'food_id = ?', whereArgs: [foodId]);

        for (final entry in nutrients.entries) {
          final code = entry.key;
          final amount = (entry.value as num).toDouble();
          final nid = await _resolveNutrientId(txn, codeToId, code);
          if (nid == null) continue;

          // Write to both flexible table and legacy table (per_100g)
          await txn.insert('food_nutrient_values', {
            'food_id': foodId, 'nutrient_id': nid, 'amount': amount, 'basis': 'per_100g',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await txn.insert('food_nutrients', {
            'food_id': foodId, 'nutrient_id': nid, 'amount_per_100g': amount,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }
  });
}


   /// Seeds the extended nutrient catalog (codes/units), aliases, and group hierarchy.
  /// Safe to run multiple times.
  static Future<void> seedExtendedNutrients(Database db) async {
    final jsonStr = await rootBundle.loadString('assets/nutrients_extended.json');
    final Map<String, dynamic> data = json.decode(jsonStr) as Map<String, dynamic>;

    final List nutrients = (data['nutrients'] as List? ?? const []);
    final List aliases   = (data['aliases'] as List? ?? const []);
    final List groups    = (data['groups'] as List? ?? const []);

    await db.transaction((txn) async {
  // 1) Upsert nutrients
  for (final n in nutrients) {
    final code = (n['code'] as String).trim();
final name = (n['name'] as String).trim();
final unit = (n['unit'] as String).trim();

    await txn.insert(
      'nutrients',
      {'code': code, 'name': name, 'unit': unit},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    // keep name/unit current on reseed
    await txn.update(
      'nutrients',
      {'name': name, 'unit': unit},
      where: 'code = ?',
      whereArgs: [code],
    );
  }

  // Build code -> id map
  final rows = await txn.query('nutrients', columns: ['id','code']);
  final Map<String, int> codeToId = {
    for (final r in rows) (r['code'] as String): (r['id'] as int)
  };

  // 2) Upsert aliases
  for (final a in aliases) {
    final code  = (a['code'] as String).trim();
final alias = (a['alias'] as String).trim();
    final nid = codeToId[code];
    if (nid == null) continue;

    await txn.insert(
      'nutrient_aliases',
      {'nutrient_id': nid, 'alias': alias},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // 3) Upsert group tree

  // close over txn so we never pass null in whereArgs
  Future<int> ensureGroup({
    required String name,
    int? parentId,
    int sortKey = 0,
  }) async {
    Map<String, Object?>? row;

    if (parentId == null) {
      final rs = await txn.query(
        'nutrient_groups',
        where: 'name = ? AND parent_id IS NULL',
        whereArgs: [name],
        limit: 1,
      );
      if (rs.isNotEmpty) row = rs.first;
    } else {
      final rs = await txn.query(
        'nutrient_groups',
        where: 'name = ? AND parent_id = ?',
        whereArgs: [name, parentId],
        limit: 1,
      );
      if (rs.isNotEmpty) row = rs.first;
    }

    if (row != null) {
      // keep sortKey current
      final id = row['id'] as int;
      await txn.update(
        'nutrient_groups',
        {'sort_key': sortKey},
        where: 'id = ?',
        whereArgs: [id],
      );
      return id;
    }

    await txn.insert(
      'nutrient_groups',
      {'name': name, 'parent_id': parentId, 'sort_key': sortKey},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    if (parentId == null) {
      final rs2 = await txn.query(
        'nutrient_groups',
        where: 'name = ? AND parent_id IS NULL',
        whereArgs: [name],
        limit: 1,
      );
      return rs2.first['id'] as int;
    } else {
      final rs2 = await txn.query(
        'nutrient_groups',
        where: 'name = ? AND parent_id = ?',
        whereArgs: [name, parentId],
        limit: 1,
      );
      return rs2.first['id'] as int;
    }
  }

  Future<void> attachMembers(int groupId, List<dynamic>? members) async {
    if (members == null) return;
    // replace membership for deterministic reseed
    await txn.delete(
      'nutrient_group_members',
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
    var sort = 0;
    for (final m in members) {
      final code = m as String;
      final nid = codeToId[code];
      if (nid == null) continue;
      await txn.insert(
        'nutrient_group_members',
        {'group_id': groupId, 'nutrient_id': nid, 'sort_key': sort++},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> walkGroups(List<dynamic> nodes, {int? parentId}) async {
    for (final g in nodes) {
      final name = (g['name'] as String).trim();
      final sort = (g['sort'] as num?)?.toInt() ?? 0;

      final gid = await ensureGroup(name: name, parentId: parentId, sortKey: sort);
      await attachMembers(gid, g['members'] as List?);

      final children = g['children'] as List?;
      if (children != null && children.isNotEmpty) {
        await walkGroups(children, parentId: gid);
      }
    }
  }

  await walkGroups(groups);
});

  
  }


/// ————— Helpers for foods seeding —————

static Future<int?> _ensureBrand(DatabaseExecutor txn, String? name, {String? manufacturer}) async {
  final brand = (name ?? '').trim();
  if (brand.isEmpty) return null;
  await txn.insert('brands', {'name': brand, 'manufacturer': manufacturer}, conflictAlgorithm: ConflictAlgorithm.ignore);
  final row = await txn.query('brands', where: 'name = ?', whereArgs: [brand], limit: 1);
  return row.isNotEmpty ? row.first['id'] as int : null;
}

/// Accepts a path like ["Beverages","Coffee","Instant"] and returns the leaf category_id.
/// Creates intermediate nodes if needed. Idempotent.
static Future<int?> _ensureCategoryPath(DatabaseExecutor txn, List<dynamic>? path) async {
  if (path == null || path.isEmpty) return null;
  int? parentId;
  for (final raw in path) {
    final name = (raw as String).trim();
    // UNIQUE(name, parent_id) lets us upsert safely
    await txn.insert(
      'categories',
      {'name': name, 'parent_id': parentId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    final row = parentId == null
      ? await txn.query('categories', where: 'name = ? AND parent_id IS NULL', whereArgs: [name], limit: 1)
      : await txn.query('categories', where: 'name = ? AND parent_id = ?', whereArgs: [name, parentId], limit: 1);
    if (row.isEmpty) return parentId; // shouldn’t happen, but bail safely
    parentId = row.first['id'] as int;
  }
  return parentId;
}

/// Finds a portion by its description/measure_name for a given food.
static Future<int?> _findPortionId(DatabaseExecutor txn, int foodId, String description) async {
  final row = await txn.query(
    'food_portions',
    where: 'food_id = ? AND measure_name = ?',
    whereArgs: [foodId, description],
    limit: 1,
  );
  return row.isNotEmpty ? row.first['id'] as int : null;
}

/// Insert/ignore a barcode → food mapping.
static Future<void> _attachBarcode(DatabaseExecutor txn, int foodId, String? barcode) async {
  final upc = (barcode ?? '').trim();
  if (upc.isEmpty) return;
  await txn.insert(
    'food_barcodes',
    {'food_id': foodId, 'upc': upc},
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

/// Resolve nutrient code → id map (within an open txn recommended)
static Future<Map<String, int>> _nutrientCodeMap(DatabaseExecutor db) async {
  final rows = await db.query('nutrients', columns: ['id','code']);
  return {
    for (final r in rows)
      if (r['code'] != null) (r['code'] as String): (r['id'] as int)
  };
}

/// Upsert a food row using best available dedupe key:
/// 1) fdc_id if provided
/// 2) barcode match (food_barcodes)
/// 3) (name, brand_id, data_source)
static Future<int> _upsertFood({
  required DatabaseExecutor txn,
  required String name,
  required int? brandId,
  required String? brandText,
  List<dynamic>? categoryPath,
  String dataSource = 'seed',
  String? dataSourceId,
  int? fdcId,
  String? barcode,
  double? densityGPerMl,
  bool? verified,
  double? qualityScore,
  int version = 1,
  String? preparation,
  double? ediblePortionPct,
  double? yieldPct,
}) async {
  // try fdc_id
  if (fdcId != null) {
    final row = await txn.query('foods', where: 'fdc_id = ?', whereArgs: [fdcId], limit: 1);
    if (row.isNotEmpty) {
      final id = row.first['id'] as int;
      await txn.update('foods', {
        'name': name,
        'brand_id': brandId,
        'brand': brandText, // keep for UI convenience
        'category_id': await _ensureCategoryPath(txn, categoryPath),
        'data_source': dataSource,
        'data_source_id': dataSourceId,
        'density_g_per_ml': densityGPerMl,
        'verified': (verified ?? false) ? 1 : 0,
        'quality_score': qualityScore,
        'version': version,
        'preparation': preparation,
        'edible_portion_pct': ediblePortionPct,
        'yield_pct': yieldPct,
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': 0,
      }, where: 'id = ?', whereArgs: [id]);
      await _attachBarcode(txn, id, barcode);
      return id;
    }
  }

  // try barcode
  if ((barcode ?? '').trim().isNotEmpty) {
    final r = await txn.query('food_barcodes', where: 'upc = ?', whereArgs: [(barcode!).trim()], limit: 1);
    if (r.isNotEmpty) {
      final id = r.first['food_id'] as int;
      await txn.update('foods', {
        'name': name,
        'brand_id': brandId,
        'brand': brandText,
        'category_id': await _ensureCategoryPath(txn, categoryPath),
        'data_source': dataSource,
        'data_source_id': dataSourceId,
        'fdc_id': fdcId,
        'density_g_per_ml': densityGPerMl,
        'verified': (verified ?? false) ? 1 : 0,
        'quality_score': qualityScore,
        'version': version,
        'preparation': preparation,
        'edible_portion_pct': ediblePortionPct,
        'yield_pct': yieldPct,
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': 0,
      }, where: 'id = ?', whereArgs: [id]);
      await _attachBarcode(txn, id, barcode);
      return id;
    }
  }

  // fallback: name + brand_id + data_source
  // Replace the fallback block in _upsertFood with:
final bool hasBrand = brandId != null;
final where = hasBrand
    ? "name = ? AND brand_id = ? AND COALESCE(data_source, '') = ?"
    : "name = ? AND brand_id IS NULL AND COALESCE(data_source, '') = ?";
final whereArgs = hasBrand ? [name, brandId, dataSource] : [name, dataSource];

final row = await txn.query(
  'foods',
  where: where,
  whereArgs: whereArgs,
  limit: 1,
);

  if (row.isNotEmpty) {
    final id = row.first['id'] as int;
    await txn.update('foods', {
      'brand': brandText,
      'category_id': await _ensureCategoryPath(txn, categoryPath),
      'data_source_id': dataSourceId,
      'fdc_id': fdcId,
      'density_g_per_ml': densityGPerMl,
      'verified': (verified ?? false) ? 1 : 0,
      'quality_score': qualityScore,
      'version': version,
      'preparation': preparation,
      'edible_portion_pct': ediblePortionPct,
      'yield_pct': yieldPct,
      'updated_at': DateTime.now().toIso8601String(),
      'is_deleted': 0,
    }, where: 'id = ?', whereArgs: [id]);
    await _attachBarcode(txn, id, barcode);
    return id;
  }

  final id = await txn.insert('foods', {
    'name': name,
    'brand_id': brandId,
    'brand': brandText,
    'category_id': await _ensureCategoryPath(txn, categoryPath),
    'is_custom': 0,
    'data_source': dataSource,
    'data_source_id': dataSourceId,
    'fdc_id': fdcId,
    'density_g_per_ml': densityGPerMl,
    'verified': (verified ?? false) ? 1 : 0,
    'quality_score': qualityScore,
    'version': version,
    'preparation': preparation,
    'edible_portion_pct': ediblePortionPct,
    'yield_pct': yieldPct,
  });
  await _attachBarcode(txn, id, barcode);
  return id;
}

/// Import a large, detailed dataset (e.g., USDA/Open Food Facts) with a richer schema.
/// Default asset path: assets/foods_extended.json (you supply the file).
static Future<void> seedFoodsExtended(Database db, {String assetPath = 'assets/foods_extended.json'}) async {
  final jsonStr = await rootBundle.loadString(assetPath);
  final List list = json.decode(jsonStr);

  final Map<String, int> codeToId = await _nutrientCodeMap(db);
  if (codeToId.isEmpty) {
    throw StateError('Seed nutrients first: call Seed.seedExtendedNutrients(db) before Seed.seedFoods(db).');
  }

  await db.transaction((txn) async {
    for (final raw in list) {
      final Map<String, dynamic> item = Map<String, dynamic>.from(raw as Map);

      final name           = item['name'] as String;
      final brandText      = item['brand'] as String?;
      final manufacturer   = item['manufacturer'] as String?;
      final categoryPath   = item['category_path'] as List?;
      final fdcId          = (item['fdc_id'] as num?)?.toInt();
      final source         = (item['data_source'] as String?) ?? 'external';
      final sourceId       = item['data_source_id'] as String?;
      final barcode        = item['barcode'] as String?;
      final density        = (item['density_g_per_ml'] as num?)?.toDouble();
      final verified       = item['verified'] == true;
      final qualityScore   = (item['quality_score'] as num?)?.toDouble();
      final version        = (item['version'] as num?)?.toInt() ?? 1;
      final preparation    = item['preparation'] as String?;
      final ediblePct      = (item['edible_portion_pct'] as num?)?.toDouble();
      final yieldPct       = (item['yield_pct'] as num?)?.toDouble();

      final brandId = await _ensureBrand(txn, brandText, manufacturer: manufacturer);
      final foodId = await _upsertFood(
        txn: txn,
        name: name,
        brandId: brandId,
        brandText: brandText,
        categoryPath: categoryPath,
        dataSource: source,
        dataSourceId: sourceId,
        fdcId: fdcId,
        barcode: barcode,
        densityGPerMl: density,
        verified: verified,
        qualityScore: qualityScore,
        version: version,
        preparation: preparation,
        ediblePortionPct: ediblePct,
        yieldPct: yieldPct,
      );

      // Optional multiple barcodes
      if (item['barcodes'] is List) {
        for (final b in (item['barcodes'] as List)) {
          await _attachBarcode(txn, foodId, b as String?);
        }
      } else {
        await _attachBarcode(txn, foodId, barcode);
      }

      // Portions (avoid Dart 3 indexed() dependency)
      await txn.delete('food_portions', where: 'food_id = ?', whereArgs: [foodId]);
      final portions = (item['portions'] as List? ?? const []);
      for (var i = 0; i < portions.length; i++) {
        final pRaw = portions[i];
        final p = Map<String, dynamic>.from(pRaw as Map);
        await txn.insert('food_portions', {
          'food_id'     : foodId,
          'measure_name': p['measure_name'] as String,
          'gram_weight' : (p['gram_weight'] as num?)?.toDouble(),
          'ml_volume'   : (p['ml_volume'] as num?)?.toDouble(),
          'is_default'  : (p['is_default'] == true) ? 1 : 0,
          'list_kind'   : p['list_kind'] as String?,
          'sort_order'  : (p['sort_order'] as num?)?.toInt() ?? i,
          'amount'      : (p['amount'] as num?)?.toDouble(),
          'unit'        : p['unit'] as String?,
          'label'       : p['label'] as String?,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      // Nutrients (by basis)
      await txn.delete('food_nutrient_values', where: 'food_id = ?', whereArgs: [foodId]);

      final byBasis = item['nutrients_by_basis'] as Map?;
      if (byBasis != null) {
        // keep legacy per_100g table in sync (avoid stale rows)
        await txn.delete('food_nutrients', where: 'food_id = ?', whereArgs: [foodId]);

        // per_100g
        for (final e in (byBasis['per_100g'] as Map? ?? const {}).entries) {
          final nid = await _resolveNutrientId(txn, codeToId, e.key);
          if (nid == null) continue;
          final amt = (e.value as num).toDouble();
          await txn.insert(
            'food_nutrient_values',
            {'food_id': foodId, 'nutrient_id': nid, 'amount': amt, 'basis': 'per_100g'},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
          await txn.insert(
            'food_nutrients',
            {'food_id': foodId, 'nutrient_id': nid, 'amount_per_100g': amt},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }

        // per_100ml
        for (final e in (byBasis['per_100ml'] as Map? ?? const {}).entries) {
          final nid = await _resolveNutrientId(txn, codeToId, e.key);
          if (nid == null) continue;
          final amt = (e.value as num).toDouble();
          await txn.insert(
            'food_nutrient_values',
            {'food_id': foodId, 'nutrient_id': nid, 'amount': amt, 'basis': 'per_100ml'},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }

        // per_portion (IGNORE to avoid unique conflicts when portion_id is NULL twice)
        for (final rawPP in (byBasis['per_portion'] as List? ?? const [])) {
          final pp = Map<String, dynamic>.from(rawPP as Map);
          final nid = await _resolveNutrientId(txn, codeToId, pp['code'] as String);
          if (nid == null) continue;

          final amt = (pp['amount'] as num).toDouble();
          int? portionId;
          if (pp['portion_desc'] != null) {
            portionId = await _findPortionId(txn, foodId, pp['portion_desc'] as String);
          } else if (pp['portion_index'] != null) {
            final idx = (pp['portion_index'] as num).toInt();
            final rows = await txn.query(
              'food_portions',
              where: 'food_id = ?',
              whereArgs: [foodId],
              orderBy: 'sort_order, id',
            );
            if (idx >= 0 && idx < rows.length) {
              portionId = rows[idx]['id'] as int;
            }
          }

          await txn.insert(
            'food_nutrient_values',
            {
              'food_id': foodId,
              'nutrient_id': nid,
              'amount': amt,
              'basis': 'per_portion',
              'portion_id': portionId,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }

        // absolute
        for (final e in (byBasis['absolute'] as Map? ?? const {}).entries) {
          final nid = await _resolveNutrientId(txn, codeToId, e.key);
          if (nid == null) continue;
          final amt = (e.value as num).toDouble();
          await txn.insert(
            'food_nutrient_values',
            {'food_id': foodId, 'nutrient_id': nid, 'amount': amt, 'basis': 'absolute'},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    }
  });
}


}
