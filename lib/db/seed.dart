// File: lib/db/seed.dart

import 'dart:io'; // for gzip.decoder
import 'dart:convert';
import 'package:flutter/services.dart'; // For rootBundle.loadString
import 'package:sqflite/sqflite.dart';

/// Legacy → canonical code hints (UPPERCASE keys).
/// Also includes a few common external tags (USDA-like) for convenience.
/// Prefer your house codes where multiple exist (e.g., SUGAR_G, SAT_FAT_G).
const Map<String, String> _legacyCodeMap = {
  'ENERGY_KCAL': 'KCAL',
  'ENERC_KCAL': 'KCAL',
  'ENERC_KJ': 'KCAL',     // will convert amount kJ → kcal
  'ENERGY_KJ': 'KCAL',    // will convert amount kJ → kcal
  'KJ': 'KCAL',           // will convert amount kJ → kcal
  'PROTEIN': 'PROTEIN_G',
  'PROCNT': 'PROTEIN_G',
  'FAT': 'FAT_G',
  'CHOCDF': 'CARB_G',
  'CARB': 'CARB_G',
  'FIBER': 'FIBER_G',
  'FIBTG': 'FIBER_G',
  'SUGARS': 'SUGARS_TOTAL_G',
  'SUGAR': 'SUGARS_TOTAL_G',
  'SUGAR_G': 'SUGARS_TOTAL_G',   // treat old key as alias to your primary
  'FASAT': 'FA_SAT_G',
  'SAT_FAT_G': 'FA_SAT_G',       // accept old key, map to primary
  'SODIUM': 'SODIUM_MG',
  'NA': 'SODIUM_MG',
};

/// Extra synonyms when a single legacy label might map to multiple house codes.
/// We’ll try these in order if the primary mapping isn’t found.
const Map<String, List<String>> _legacySynonyms = {
  'SUGARS': ['SUGARS_TOTAL_G', 'SUGAR_G'],
  'SUGAR':  ['SUGARS_TOTAL_G', 'SUGAR_G'],
  'FASAT':  ['FA_SAT_G', 'SAT_FAT_G'],
};

/// Safe numeric parsing (accepts num or numeric strings).
double? _num(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim());
  return null;
}

/// Trims a string; returns null if empty/whitespace or null input.
String? _trimOrNull(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}

/// Clamp to [0,1].
double? _clamp01(double? v) => v?.clamp(0.0, 1.0).toDouble();

/// Clamp to [0,100].
double? _clampPct(double? v) => v?.clamp(0.0, 100.0).toDouble();

/// Return positive value or null.
double? _posOrNull(double? v) => (v != null && v > 0) ? v : null;

/// Normalize unit strings into canonical set.
String _normUnit(String u) {
  final s = u.trim().toLowerCase();
  if (s == 'kcal') return 'kcal';
  if (s == 'g') return 'g';
  if (s == 'mg') return 'mg';
  if (s == 'µg' || s == 'μg' || s == 'mcg' || s == 'ug') return 'µg';
  // Fallback: return as-is; schema may still accept or later guards may reject.
  return u.trim();
}

/// Recognize energy-in-kilojoules codes (converted to kcal).
bool _isKjCode(String upper) =>
    upper == 'ENERC_KJ' || upper == 'ENERGY_KJ' || upper == 'KJ';

/// Parse a numeric amount and convert to kcal if the provided code is kJ.
double? _toSeedAmount(Object codeKey, dynamic rawVal) {
  final amt = _num(rawVal);
  if (amt == null) return null;
  final codeU = codeKey.toString().trim().toUpperCase();
  return _isKjCode(codeU) ? (amt / 4.184) : amt;
}

/// kcal-aware parse that also rejects negatives / NaN / Infinity.
double? _nonNegKcalAware(Object codeKey, dynamic rawVal) {
  final v = _toSeedAmount(codeKey, rawVal);
  if (v == null) return null;
  if (v.isNaN || v.isInfinite) return null;
  if (v < 0) return null;
  return v;
}

/// Safe-to-string + trim; returns null if empty or null.
String? _s(dynamic v) {
  if (v == null) return null;
  final t = v.toString().trim();
  return t.isEmpty ? null : t;
}

/// Lowercased + trimmed (null-safe).
String? _sLower(dynamic v) => _s(v)?.toLowerCase();


/// Build a map of canonical nutrient codes (UPPERCASE) to ids.
Future<Map<String, int>> _nutrientCodeMap(DatabaseExecutor db) async {
  final rows = await db.query('nutrients', columns: ['id', 'code']);
  final map = <String, int>{};
  for (final r in rows) {
    final code = (r['code'] as String?)?.trim();
    if (code == null || code.isEmpty) continue;
    map[code.toUpperCase()] = r['id'] as int;
  }
  return map;
}

/// Build a map of alias (UPPERCASE) to nutrient id for fast in-memory resolution.
Future<Map<String, int>> _nutrientAliasMap(DatabaseExecutor db) async {
  final rs = await db.query('nutrient_aliases', columns: ['nutrient_id', 'alias']);
  final m = <String, int>{};
  for (final r in rs) {
    final alias = (r['alias'] as String?)?.trim();
    if (alias == null || alias.isEmpty) continue;
    m[alias.toUpperCase()] = r['nutrient_id'] as int;
  }
  return m;
}

/// Resolve a nutrient raw code → id using in-memory maps (fast).
int? _resolveNutrientIdFast(
  Map<String, int> codeToId,
  Map<String, int> aliasToId,
  String rawCode,
) {
  final norm = rawCode.trim().toUpperCase();

  // 1) Exact canonical code (map is UPPERCASE)
  final direct = codeToId[norm];
  if (direct != null) return direct;

  // 2) Legacy → canonical map
  final mapped = _legacyCodeMap[norm];
  if (mapped != null) {
    final nid = codeToId[mapped];
    if (nid != null) return nid;
  }

  // 3) Try synonym list if present
  final syn = _legacySynonyms[norm];
  if (syn != null) {
    for (final c in syn) {
      final nid = codeToId[c];
      if (nid != null) return nid;
    }
  }

  // 4) Alias fallback (case-insensitive via UPPERCASE map)
  return aliasToId[norm];
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
        final List eqNames = (item['equipment'] as List?) ?? const [];
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
          'name': item['name'],
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
          if (rows.isEmpty) {
            throw Exception('exercise_def not found after ignore: ${item['name']}');
          }
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

        final List bpNames = (item['bodyparts'] as List?) ?? const [];
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

        final List muscles = (item['muscles'] as List?) ?? const [];
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

        final List bpNames = (item['bodyparts'] as List?) ?? const [];
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
  static Future<void> seedFoods(
  Database db, {
  String assetPath = 'assets/foods/foods.min.jsonl.gz', // default to new file
}) async {
  if (assetPath.endsWith('.jsonl.gz')) {
    return seedFoodsFromJsonlGzip(db, assetPath: assetPath);
  }
  // Fallback to legacy array JSON (your current implementation):
  final jsonStr = await rootBundle.loadString(assetPath); // e.g., assets/foods.json
  final List list = json.decode(jsonStr);
  // ... keep your existing loop here unchanged ...
}



  /// Seeds the extended nutrient catalog (codes/units), aliases, and group hierarchy.
  /// Safe to run multiple times.
  static Future<void> seedExtendedNutrients(Database db) async {
    final jsonStr = await rootBundle.loadString('assets/nutrients_extended.json');
    final Map<String, dynamic> data = json.decode(jsonStr) as Map<String, dynamic>;

    final List nutrients = (data['nutrients'] as List? ?? const []);
    final List aliases = (data['aliases'] as List? ?? const []);
    final List groups = (data['groups'] as List? ?? const []);

    await db.transaction((txn) async {
      // 1) Upsert nutrients
      for (final n in nutrients) {
        final code = _trimOrNull(n['code'] as String)!;
        final name = _trimOrNull(n['name'] as String)!;
        final unit = _normUnit(n['unit'] as String);

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
      final rows = await txn.query('nutrients', columns: ['id', 'code']);
      final Map<String, int> codeToId = {
        for (final r in rows) (r['code'] as String): (r['id'] as int)
      };

      // 2) Upsert aliases
      for (final a in aliases) {
        final code = _trimOrNull(a['code'] as String)!;
        final alias = _trimOrNull(a['alias'] as String)!;
        final nid = codeToId[code];
        if (nid == null) continue;

        await txn.insert(
          'nutrient_aliases',
          {'nutrient_id': nid, 'alias': alias},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // 3) Upsert group tree

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
          final name = _trimOrNull(g['name'] as String)!;
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

  // ————— Helpers for foods seeding —————

  static Future<int?> _ensureBrand(DatabaseExecutor txn, String? name, {String? manufacturer}) async {
    final brand = _trimOrNull(name);
    if (brand == null) return null;

    await txn.insert(
      'brands',
      {'name': brand, 'manufacturer': _trimOrNull(manufacturer)},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Case-insensitive fetch to align with NOCASE unique
    final row = await txn.query(
      'brands',
      where: 'lower(name) = lower(?)',
      whereArgs: [brand],
      limit: 1,
    );
    if (row.isEmpty) return null;
    final id = row.first['id'] as int;

    // If manufacturer was missing, fill it when we learn it later
    final currentManu = row.first['manufacturer'] as String?;
    if ((currentManu == null || currentManu.trim().isEmpty) &&
        (manufacturer != null && manufacturer.trim().isNotEmpty)) {
      await txn.update('brands', {'manufacturer': manufacturer.trim()}, where: 'id = ?', whereArgs: [id]);
    }
    return id;
  }

  /// Accepts a path like ["Beverages","Coffee","Instant"] and returns the leaf category_id.
  /// Creates intermediate nodes if needed. Case-insensitive & idempotent.
  static Future<int?> _ensureCategoryPath(DatabaseExecutor txn, List<dynamic>? path) async {
    if (path == null || path.isEmpty) return null;
    int? parentId;
    for (final raw in path) {
      final name = raw.toString().trim();

      Map<String, Object?>? row;
      if (parentId == null) {
        final rs = await txn.rawQuery(
          'SELECT id FROM categories WHERE lower(name)=lower(?) AND parent_id IS NULL LIMIT 1;',
          [name],
        );
        if (rs.isNotEmpty) row = rs.first;
      } else {
        final rs = await txn.rawQuery(
          'SELECT id FROM categories WHERE lower(name)=lower(?) AND parent_id = ? LIMIT 1;',
          [name, parentId],
        );
        if (rs.isNotEmpty) row = rs.first;
      }

      if (row == null) {
        await txn.insert(
          'categories',
          {'name': name, 'parent_id': parentId},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        // read back, case-insensitive
        if (parentId == null) {
          final rs2 = await txn.rawQuery(
            'SELECT id FROM categories WHERE lower(name)=lower(?) AND parent_id IS NULL LIMIT 1;',
            [name],
          );
          row = rs2.first;
        } else {
          final rs2 = await txn.rawQuery(
            'SELECT id FROM categories WHERE lower(name)=lower(?) AND parent_id = ? LIMIT 1;',
            [name, parentId],
          );
          row = rs2.first;
        }
      }
      parentId = row['id'] as int;
    }
    return parentId;
  }

  /// Finds a portion by its description/measure_name or label (case-insensitive, trimmed).
  static Future<int?> _findPortionId(DatabaseExecutor txn, int foodId, String description) async {
    final d = description.trim().toLowerCase();
    final row = await txn.rawQuery(
      '''
      SELECT id FROM food_portions
      WHERE food_id = ?
        AND (
              lower(trim(measure_name)) = ?
           OR lower(trim(COALESCE(label,''))) = ?
        )
      LIMIT 1;
      ''',
      [foodId, d, d],
    );
    return row.isNotEmpty ? row.first['id'] as int : null;
  }

  /// Insert/ignore a barcode → food mapping (normalize to digits; check length).
  static Future<void> _attachBarcode(DatabaseExecutor txn, int foodId, String? barcode) async {
    if (barcode == null) return;
    final digits = barcode.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    if (digits.length < 8 || digits.length > 18) return; // keep in sync with schema guards
    await txn.insert(
      'food_barcodes',
      {'food_id': foodId, 'upc': digits},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Upsert a food row using best available dedupe key:
  /// 1) fdc_id if provided
  /// 2) barcode match (food_barcodes)
  /// 3) (name [NOCASE], brand_id, data_source)
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
    final sourceId = await _ensureSource(txn, dataSource);
    final int? categoryId = await _ensureCategoryPath(txn, categoryPath);
    final String? normalizedBarcode =
        (barcode == null || barcode.trim().isEmpty) ? null : barcode.replaceAll(RegExp(r'\D'), '');

    // try fdc_id
    if (fdcId != null) {
      final row = await txn.query('foods', where: 'fdc_id = ?', whereArgs: [fdcId], limit: 1);
      if (row.isNotEmpty) {
        final id = row.first['id'] as int;
        await txn.update(
          'foods',
          {
            'name': name,
            'brand_id': brandId,
            'brand': brandText, // schema triggers keep FTS in sync
            'category_id': categoryId,
            'data_source': dataSource,
            'data_source_id': dataSourceId,
            'source_id': sourceId,
            'density_g_per_ml': densityGPerMl,
            'verified': (verified ?? false) ? 1 : 0,
            'quality_score': qualityScore,
            'version': version,
            'preparation': preparation,
            'edible_portion_pct': ediblePortionPct,
            'yield_pct': yieldPct,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            'is_deleted': 0,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        await _attachBarcode(txn, id, normalizedBarcode);
        return id;
      }
    }

    // try barcode
    if (normalizedBarcode != null && normalizedBarcode.isNotEmpty) {
      final r = await txn.query(
        'food_barcodes',
        where: 'upc = ?',
        whereArgs: [normalizedBarcode],
        limit: 1,
      );
      if (r.isNotEmpty) {
        final id = r.first['food_id'] as int;
        await txn.update(
          'foods',
          {
            'name': name,
            'brand_id': brandId,
            'brand': brandText,
            'category_id': categoryId,
            'data_source': dataSource,
            'data_source_id': dataSourceId,
            'fdc_id': fdcId,
            'source_id': sourceId,
            'density_g_per_ml': densityGPerMl,
            'verified': (verified ?? false) ? 1 : 0,
            'quality_score': qualityScore,
            'version': version,
            'preparation': preparation,
            'edible_portion_pct': ediblePortionPct,
            'yield_pct': yieldPct,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            'is_deleted': 0,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        await _attachBarcode(txn, id, normalizedBarcode);
        return id;
      }
    }

    // fallback: name + brand_id + data_source (case-insensitive name)
    final bool hasBrand = brandId != null;
    final where = hasBrand
        ? "lower(name) = lower(?) AND brand_id = ? AND COALESCE(data_source, '') = ?"
        : "lower(name) = lower(?) AND brand_id IS NULL AND COALESCE(data_source, '') = ?";
    final whereArgs = hasBrand ? [name, brandId, dataSource] : [name, dataSource];

    final row = await txn.query(
      'foods',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    if (row.isNotEmpty) {
      final id = row.first['id'] as int;
      await txn.update(
        'foods',
        {
          'brand': brandText,
          'category_id': categoryId,
          'data_source_id': dataSourceId,
          'fdc_id': fdcId,
          'source_id': sourceId,
          'density_g_per_ml': densityGPerMl,
          'verified': (verified ?? false) ? 1 : 0,
          'quality_score': qualityScore,
          'version': version,
          'preparation': preparation,
          'edible_portion_pct': ediblePortionPct,
          'yield_pct': yieldPct,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
          'is_deleted': 0,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      await _attachBarcode(txn, id, normalizedBarcode);
      return id;
    }

    final id = await txn.insert('foods', {
      'name': name,
      'brand_id': brandId,
      'brand': brandText,
      'category_id': categoryId,
      'is_custom': 0,
      'data_source': dataSource,
      'data_source_id': dataSourceId,
      'fdc_id': fdcId,
      'source_id': sourceId,
      'density_g_per_ml': densityGPerMl,
      'verified': (verified ?? false) ? 1 : 0,
      'quality_score': qualityScore,
      'version': version,
      'preparation': preparation,
      'edible_portion_pct': ediblePortionPct,
      'yield_pct': yieldPct,
    });
    await _attachBarcode(txn, id, normalizedBarcode);
    return id;
  }

  /// Import a large, detailed dataset (e.g., USDA/Open Food Facts) with a richer schema.
  /// Default asset path: assets/foods_extended.json (you supply the file).
  static Future<void> seedFoodsExtended(Database db, {String assetPath = 'assets/foods_extended.json'}) async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final List list = json.decode(jsonStr);

    final Map<String, int> codeToId = await _nutrientCodeMap(db);
    final Map<String, int> aliasToId = await _nutrientAliasMap(db);
    if (codeToId.isEmpty) {
      throw StateError('Seed nutrients first: call Seed.seedExtendedNutrients(db) before Seed.seedFoods(db).');
    }

    await db.transaction((txn) async {
      for (final raw in list) {
        final Map<String, dynamic> item = Map<String, dynamic>.from(raw as Map);

        final name         = _s(item['name']);
if (name == null) continue;

final brandText    = _s(item['brand']);
final manufacturer = _s(item['manufacturer']);
final categoryPath = item['category_path'] as List?; // dataset-defined; usually strings
final fdcId        = (item['fdc_id'] as num?)?.toInt();
final source       = _s(item['data_source']) ?? 'external';
final sourceId     = _s(item['data_source_id']);

final rawBarcode   = _s(item['barcode']);
final barcode      = rawBarcode?.replaceAll(RegExp(r'\D'), '');


        final density = _posOrNull(_num(item['density_g_per_ml']));
        final verified = item['verified'] == true;
        final qualityScore = _clamp01(_num(item['quality_score']));
        final version = (item['version'] as num?)?.toInt() ?? 1;
        final preparation = _trimOrNull(item['preparation'] as String?);
        final ediblePct = _clampPct(_num(item['edible_portion_pct']));
        final yieldPct = _clampPct(_num(item['yield_pct']));

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
    await _attachBarcode(txn, foodId, _s(b));
  }
} else {
  await _attachBarcode(txn, foodId, barcode);
}


        // Portions (skip invalid rows lacking a converter)
        await txn.delete('food_portions', where: 'food_id = ?', whereArgs: [foodId]);
        final portions = (item['portions'] as List? ?? const []);
        for (var i = 0; i < portions.length; i++) {
          final pRaw = portions[i];
          final p = Map<String, dynamic>.from(pRaw as Map);

          final gw = _posOrNull(_num(p['gram_weight']));
          final ml = _posOrNull(_num(p['ml_volume']));
          if (gw == null && ml == null) {
            continue;
          }

          await txn.insert(
            'food_portions',
            {
              'food_id': foodId,
              'measure_name': _s(p['measure_name']) ?? 'portion',
              'gram_weight': gw,
              'ml_volume': ml,
              'is_default': (p['is_default'] == true) ? 1 : 0,
              'list_kind': _sLower(p['list_kind']),
              'sort_order': (p['sort_order'] as num?)?.toInt() ?? i,
              'amount': _posOrNull(_num(p['amount'])),
              'unit': _s(p['unit']),
              'label': _s(p['label']),
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }

        // Ensure there's a gram-based portion (fallback) and one default
        await _ensureGramPortion(txn, foodId);
        await _ensureOneDefaultPortion(txn, foodId);

        // Nutrients (by basis)
        await txn.delete('food_nutrient_values', where: 'food_id = ?', whereArgs: [foodId]);

        final Map<String, dynamic>? byBasis =
            item['nutrients_by_basis'] == null ? null : Map<String, dynamic>.from(item['nutrients_by_basis'] as Map);
        if (byBasis != null) {
          // keep legacy per_100g table in sync (avoid stale rows)
          await txn.delete('food_nutrients', where: 'food_id = ?', whereArgs: [foodId]);

          // per_100g
          final Map<String, dynamic> per100g =
              (byBasis['per_100g'] as Map? ?? const {}).cast<String, dynamic>();
          for (final e in per100g.entries) {
            final nid = _resolveNutrientIdFast(codeToId, aliasToId, e.key);
            if (nid == null) continue;
            final amt = _nonNegKcalAware(e.key, e.value);
            if (amt == null) continue;
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
          // Optional: ensure KCAL if missing and macros present
          await _maybeEnsureEnergyKcalPer100g(txn, foodId, codeToId, aliasToId, per100g);

          // per_100ml
          final Map<String, dynamic> per100ml =
              (byBasis['per_100ml'] as Map? ?? const {}).cast<String, dynamic>();
          for (final e in per100ml.entries) {
            final nid = _resolveNutrientIdFast(codeToId, aliasToId, e.key);
            if (nid == null) continue;
            final amt = _nonNegKcalAware(e.key, e.value);
            if (amt == null) continue;
            await txn.insert(
              'food_nutrient_values',
              {'food_id': foodId, 'nutrient_id': nid, 'amount': amt, 'basis': 'per_100ml'},
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }

          // If only per_100ml given and we know density, derive per_100g
          await _maybeBackfillPer100gFromPer100ml(
            txn, foodId, per100ml, density, codeToId, aliasToId);

          // After derivation, ensure KCAL from DB if macros now exist
          await _maybeEnsureEnergyKcalPer100gFromDb(txn, foodId, codeToId);

          // per_portion
          final List perPortion = (byBasis['per_portion'] as List? ?? const []);
          for (final rawPP in perPortion) {
            final pp = Map<String, dynamic>.from(rawPP as Map);
            final nid = _resolveNutrientIdFast(codeToId, aliasToId, pp['code'] as String);
            if (nid == null) continue;

            final amt = _nonNegKcalAware(pp['code'] ?? '', pp['amount']);
            if (amt == null) continue;

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

            if (portionId != null) {
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
          }

          // absolute
          final Map<String, dynamic> absolute =
              (byBasis['absolute'] as Map? ?? const {}).cast<String, dynamic>();
          for (final e in absolute.entries) {
            final nid = _resolveNutrientIdFast(codeToId, aliasToId, e.key);
            if (nid == null) continue;
            final amt = _nonNegKcalAware(e.key, e.value);
            if (amt == null) continue;
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

  static Future<int?> _ensureSource(DatabaseExecutor txn, String? name) async {
    final s = _trimOrNull(name);
    if (s == null) return null;
    await txn.insert(
      'sources',
      {'name': s},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    final row = await txn.query(
      'sources',
      where: 'name = ?',
      whereArgs: [s],
      limit: 1,
    );
    return row.isNotEmpty ? row.first['id'] as int : null;
  }

  /// Ensure there is exactly one default portion for a food; if none, mark first as default.
  static Future<void> _ensureOneDefaultPortion(DatabaseExecutor txn, int foodId) async {
    final cur = await txn.query(
      'food_portions',
      where: 'food_id = ?',
      whereArgs: [foodId],
      orderBy: 'sort_order, id',
    );
    final hasDefault = cur.any((r) => (r['is_default'] as int? ?? 0) == 1);
    if (!hasDefault && cur.isNotEmpty) {
      final firstId = cur.first['id'] as int;
      await txn.update('food_portions', {'is_default': 1}, where: 'id = ?', whereArgs: [firstId]);
    }
  }

  /// Ensure at least one gram-based portion exists.
  /// - If none exist and there are no portions at all: add a "1 g" portion as default.
  /// - If none exist and portions already exist: add a non-default "1 g" portion.
  static Future<void> _ensureGramPortion(DatabaseExecutor txn, int foodId) async {
    final rows = await txn.query(
      'food_portions',
      where: 'food_id = ?',
      whereArgs: [foodId],
      orderBy: 'sort_order, id',
    );

    final hasGram = rows.any((r) {
      final gw = (r['gram_weight'] as num?)?.toDouble();
      return gw != null && gw > 0;
    });
    if (hasGram) return;

    final hasAny = rows.isNotEmpty;
    final makeDefault = !hasAny; // if no portions at all, make this default

    await txn.insert(
      'food_portions',
      {
        'food_id': foodId,
        'measure_name': 'g',
        'gram_weight': 1.0,
        'ml_volume': null,
        'is_default': makeDefault ? 1 : 0,
        'list_kind': 'basis',
        'sort_order': -1,
        'amount': 1.0,
        'unit': 'g',
        'label': '1 g',
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // If we didn’t make it default above and there’s still no default, ensure exactly one.
    if (!makeDefault) {
      await _ensureOneDefaultPortion(txn, foodId);
    }
  }

  /// Derive per_100g data from per_100ml using density (g/ml) where helpful.
  static Future<void> _maybeBackfillPer100gFromPer100ml(
    DatabaseExecutor txn,
    int foodId,
    Map<String, dynamic> per100ml,
    double? densityGPerMl,
    Map<String, int> codeToId,
    Map<String, int> aliasToId,
  ) async {
    if (densityGPerMl == null || densityGPerMl <= 0) return;
    if (per100ml.isEmpty) return;

    for (final e in per100ml.entries) {
      final nid = _resolveNutrientIdFast(codeToId, aliasToId, e.key);
      if (nid == null) continue;

      final amt100ml = _nonNegKcalAware(e.key, e.value);
      if (amt100ml == null) continue;

      final derived = amt100ml / densityGPerMl;
      if (derived <= 0) continue;

      await txn.insert(
        'food_nutrient_values',
        {
          'food_id': foodId,
          'nutrient_id': nid,
          'amount': derived,
          'basis': 'per_100g',
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      await txn.insert(
        'food_nutrients',
        {
          'food_id': foodId,
          'nutrient_id': nid,
          'amount_per_100g': derived,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /// Computes per-100g nutrient cache for all recipes using current ingredients.
  /// Safe to run multiple times; uses REPLACE semantics.
  static Future<void> backfillRecipeNutrientCache(Database db) async {
    await db.transaction((txn) async {
      // wipe existing cache for recipes that have ingredients
      await txn.execute('''
        DELETE FROM recipe_nutrients
        WHERE recipe_id IN (SELECT DISTINCT recipe_id FROM recipe_ingredients);
      ''');

      await txn.execute('''
        INSERT OR REPLACE INTO recipe_nutrients (recipe_id, code, per_100g)
        SELECT
          ri.recipe_id,
          n.code AS code,
          CASE
            WHEN SUM(ri.grams) > 0
            THEN SUM(ri.grams * fn.amount_per_100g) / SUM(ri.grams)
            ELSE 0
          END AS per_100g
        FROM recipe_ingredients ri
        JOIN food_nutrients fn ON fn.food_id = ri.food_id
        JOIN nutrients n       ON n.id      = fn.nutrient_id
        WHERE ri.grams IS NOT NULL
        GROUP BY ri.recipe_id, n.code;
      ''');
    });
  }

  /// If per_100g section lacks KCAL but macros exist, compute and insert it:
  /// energy (kcal) ≈ 4*(protein+carbs) + 9*fat
  static Future<void> _maybeEnsureEnergyKcalPer100g(
    DatabaseExecutor txn,
    int foodId,
    Map<String, int> codeToId,
    Map<String, int> aliasToId,
    Map<String, dynamic> per100g,
  ) async {
    bool hasKcal = per100g.keys.any((k) => k.toString().trim().toUpperCase() == 'KCAL');
    if (hasKcal) return;

    final p = _num(per100g['PROTEIN_G']) ?? _num(per100g['PROCNT']) ?? 0.0;
    final c = _num(per100g['CARB_G']) ?? _num(per100g['CHOCDF']) ?? _num(per100g['CARB']) ?? 0.0;
    final f = _num(per100g['FAT_G']) ?? _num(per100g['FAT']) ?? 0.0;

    final est = 4.0 * (p + c) + 9.0 * f;
    if (est <= 0) return;

    final nid = _resolveNutrientIdFast(codeToId, aliasToId, 'KCAL');
    if (nid == null) return;

    await txn.insert(
      'food_nutrient_values',
      {'food_id': foodId, 'nutrient_id': nid, 'amount': est, 'basis': 'per_100g'},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await txn.insert(
      'food_nutrients',
      {'food_id': foodId, 'nutrient_id': nid, 'amount_per_100g': est},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// After we may have derived per_100g rows (e.g., from per_100ml + density),
  /// ensure KCAL exists if macros exist in the DB now.
  static Future<void> _maybeEnsureEnergyKcalPer100gFromDb(
    DatabaseExecutor txn,
    int foodId,
    Map<String, int> codeToId,
  ) async {
    final kcalId = codeToId['KCAL'];
    final pId = codeToId['PROTEIN_G'];
    final cId = codeToId['CARB_G'];
    final fId = codeToId['FAT_G'];
    if (kcalId == null || pId == null || cId == null || fId == null) return;

    final rows = await txn.rawQuery('''
      SELECT nutrient_id, amount
      FROM food_nutrient_values
      WHERE food_id = ? AND basis = 'per_100g' AND nutrient_id IN (?,?,?,?)
    ''', [foodId, kcalId, pId, cId, fId]);

    double? kcal, p, c, f;
    for (final r in rows) {
      final nid = r['nutrient_id'] as int;
      final amt = (r['amount'] as num).toDouble();
      if (nid == kcalId) kcal = amt;
      if (nid == pId) p = amt;
      if (nid == cId) c = amt;
      if (nid == fId) f = amt;
    }
    if (kcal != null) return;

    final pp = (p ?? 0), cc = (c ?? 0), ff = (f ?? 0);
    final est = 4.0 * (pp + cc) + 9.0 * ff;
    if (est <= 0) return;

    await txn.insert(
      'food_nutrient_values',
      {'food_id': foodId, 'nutrient_id': kcalId, 'amount': est, 'basis': 'per_100g'},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await txn.insert(
      'food_nutrients',
      {'food_id': foodId, 'nutrient_id': kcalId, 'amount_per_100g': est},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }


/// Seeds foods from a gzip-compressed JSONL asset (one JSON object per line),
/// e.g. assets/foods/foods.min.jsonl.gz produced by your USDA condense script.
/// This reuses the same schema helpers used by seedFoods().
static Future<void> seedFoodsFromJsonlGzip(
  Database db, {
  String assetPath = 'assets/foods/foods.min.jsonl.gz',
  int batchSize = 800,
}) async {
  // 1) Build nutrient code maps once
  final Map<String, int> codeToId = await _nutrientCodeMap(db);
  final Map<String, int> aliasToId = await _nutrientAliasMap(db);
  if (codeToId.isEmpty) {
    throw StateError('Seed nutrients first: call Seed.seedExtendedNutrients(db) before seeding foods.');
  }

  // 2) Load compressed asset as bytes, then stream-decompress + line-split
  final bd = await rootBundle.load(assetPath);
  final bytes = bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);
  final lines = Stream<List<int>>.fromIterable([bytes])
      .transform(gzip.decoder)
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  // 3) Buffer lines into transactions for speed
  final buffer = <Map<String, dynamic>>[];

  Future<void> flush() async {
    if (buffer.isEmpty) return;
    await db.transaction((txn) async {
      for (final raw in buffer) {
        final item = Map<String, dynamic>.from(raw);

        // ----- Field normalization (accept both new + old keys) -----
        final name         = _s(item['name']);
if (name == null) continue;

final brandText    = _s(item['brand'] ?? item['manufacturer']);
final manufacturer = _s(item['manufacturer']);
final dataSource   = _s(item['data_source'] ?? item['source']) ?? 'external';
final dataSourceId = _s(item['data_source_id'] ?? item['source_id']);
final fdcId        = (item['fdc_id'] as num?)?.toInt() ?? (item['fdcId'] as num?)?.toInt();
final density      = _posOrNull(_num(item['density_g_per_ml']));

// category can be a single string or a path array
List<dynamic>? categoryPath;
if (item['category_path'] is List) {
  categoryPath = item['category_path'] as List;
} else {
  final single = _s(item['category']);
  categoryPath = single == null ? null : <dynamic>[single];
}

// barcodes: prefer list; fall back to single
final List<String> barcodes =
    (item['barcodes'] is List
        ? (item['barcodes'] as List)
            .map((e) => _s(e))
            .whereType<String>()
            .toList()
        : (() { final b = _s(item['barcode']); return b == null ? <String>[] : <String>[b]; })());


        // ----- Upsert brand/food -----
        final brandId = await _ensureBrand(txn, brandText, manufacturer: manufacturer);
        final foodId = await _upsertFood(
          txn: txn,
          name: name,
          brandId: brandId,
          brandText: brandText,
          categoryPath: categoryPath,
          dataSource: dataSource,
          dataSourceId: dataSourceId,
          fdcId: fdcId,
          barcode: barcodes.isNotEmpty ? barcodes.first : null, // also attached individually below
          densityGPerMl: density,
          verified: item['verified'] == true,
          qualityScore: _clamp01(_num(item['quality_score'])),
          version: (item['version'] as num?)?.toInt() ?? 1,
          preparation: _trimOrNull(item['preparation'] as String?),
          ediblePortionPct: _clampPct(_num(item['edible_portion_pct'])),
          yieldPct: _clampPct(_num(item['yield_pct'])),
        );

        // attach all barcodes
        for (final b in barcodes) {
          await _attachBarcode(txn, foodId, b);
        }

        // ----- Portions -----
        await txn.delete('food_portions', where: 'food_id = ?', whereArgs: [foodId]);
        for (var i = 0; i < ((item['portions'] as List?)?.length ?? 0); i++) {
          final p = Map<String, dynamic>.from((item['portions'] as List)[i] as Map);
          final gw = _posOrNull(_num(p['gram_weight']));
          final ml = _posOrNull(_num(p['ml_volume']));
          if (gw == null && ml == null) continue;

          await txn.insert(
            'food_portions',
            {
              'food_id': foodId,
              'measure_name': _s(p['measure_name']) ?? 'portion',
              'gram_weight': gw,
              'ml_volume': ml,
              'is_default': (p['is_default'] == true) ? 1 : 0,
              'list_kind': _sLower(p['list_kind']),
              'sort_order': (p['sort_order'] as num?)?.toInt() ?? i,
              'amount': _posOrNull(_num(p['amount'])),
              'unit': _s(p['unit']),
              'label': _s(p['label']),
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
        await _ensureGramPortion(txn, foodId);
        await _ensureOneDefaultPortion(txn, foodId);

        // ----- Nutrients -----
        // Clear flexible + legacy tables deterministically
        await txn.delete('food_nutrient_values', where: 'food_id = ?', whereArgs: [foodId]);
        await txn.delete('food_nutrients',       where: 'food_id = ?', whereArgs: [foodId]);

        // Your condensed JSONL puts macros at top-level (e.g., KCAL, PROTEIN_G, ...).
        // Build a per_100g map on the fly and reuse the legacy-per100g path.
        final per100g = <String, dynamic>{};
        for (final k in const ['KCAL','PROTEIN_G','CARB_G','FAT_G','FIBER_G','SODIUM_MG']) {
          final v = item[k];
          if (v is num || (v is String && double.tryParse(v) != null)) {
            per100g[k] = v;
          }
        }

        for (final e in per100g.entries) {
          final nid = _resolveNutrientIdFast(codeToId, aliasToId, e.key);
          if (nid == null) continue;
          final amt = _nonNegKcalAware(e.key, e.value);
          if (amt == null) continue;

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

        // Ensure KCAL if missing but macros present
        await _maybeEnsureEnergyKcalPer100g(txn, foodId, codeToId, aliasToId, per100g);
        await _maybeEnsureEnergyKcalPer100gFromDb(txn, foodId, codeToId);
      }
    });
    buffer.clear();
  }

  await for (final line in lines) {
    if (line.isEmpty) continue;
    buffer.add(json.decode(line) as Map<String, dynamic>);
    if (buffer.length >= batchSize) {
      await flush();
    }
  }
  await flush();
  await _rebuildFoodFtsIfExists(db);
}

static Future<void> _rebuildFoodFtsIfExists(Database db) async {
  try {
    final exists = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='food_search_fts' LIMIT 1;"
    );
    if (exists.isNotEmpty) {
      // Works for FTS4/5; harmless if no pending changes.
      await db.rawInsert(
        "INSERT INTO food_search_fts(food_search_fts) VALUES('rebuild');"
      );
    }
  } catch (_) {
    // If older schemas don't have FTS yet, just ignore.
  }
}


}
