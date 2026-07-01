// File: lib/db/seed.dart

import 'dart:io'; // for gzip.decoder
import 'dart:convert';
import 'package:flutter/services.dart'; // For rootBundle.loadString
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:sqflite/sqflite.dart';

typedef SeedProgress = void Function(int inserted);

/// Legacy → canonical code hints (UPPERCASE keys).
/// Also includes a few common external tags (USDA-like) for convenience.
/// Prefer your house codes where multiple exist (e.g., SUGAR_G, SAT_FAT_G).
const Map<String, String> _legacyCodeMap = {
  'ENERGY_KCAL': 'KCAL',
  'ENERC_KCAL': 'KCAL',
  'ENERC_KJ': 'KCAL', // will convert amount kJ → kcal
  'ENERGY_KJ': 'KCAL', // will convert amount kJ → kcal
  'KJ': 'KCAL', // will convert amount kJ → kcal
  'PROTEIN': 'PROTEIN_G',
  'PROCNT': 'PROTEIN_G',
  'FAT': 'FAT_G',
  'CHOCDF': 'CARB_G',
  'CARB': 'CARB_G',
  'FIBER': 'FIBER_G',
  'FIBTG': 'FIBER_G',
  'SUGARS': 'SUGARS_TOTAL_G',
  'SUGAR': 'SUGARS_TOTAL_G',
  'SUGAR_G': 'SUGARS_TOTAL_G', // treat old key as alias to your primary
  'FASAT': 'FA_SAT_G',
  'SAT_FAT_G': 'FA_SAT_G', // accept old key, map to primary
  'SODIUM': 'SODIUM_MG',
  'NA': 'SODIUM_MG',
};

/// Extra synonyms when a single legacy label might map to multiple house codes.
/// We’ll try these in order if the primary mapping isn’t found.
const Map<String, List<String>> _legacySynonyms = {
  'SUGARS': ['SUGARS_TOTAL_G', 'SUGAR_G'],
  'SUGAR': ['SUGARS_TOTAL_G', 'SUGAR_G'],
  'FASAT': ['FA_SAT_G', 'SAT_FAT_G'],
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
  final rs = await db.query(
    'nutrient_aliases',
    columns: ['nutrient_id', 'alias'],
  );
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
      Future<Map<String, int>> loadIdMap(String table) async {
        final rows = await txn.query(table, columns: ['id', 'name']);
        return {
          for (final row in rows) (row['name'] as String): row['id'] as int,
        };
      }

      String defKey(String name, int? equipmentId) =>
          '$name\x1f${equipmentId ?? 'null'}';

      final lookupBatch = txn.batch();
      for (var item in eqList) {
        lookupBatch.insert('equipment', {
          'name': item['name'],
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      for (var item in bpList) {
        lookupBatch.insert('bodypart', {
          'name': item['name'],
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      for (var item in mList) {
        lookupBatch.insert('muscles', {
          'name': item['name'],
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await lookupBatch.commit(noResult: true);

      final equipmentIds = await loadIdMap('equipment');
      final bodypartIds = await loadIdMap('bodypart');
      final muscleIds = await loadIdMap('muscles');

      final definitionBatch = txn.batch();
      for (var item in exList) {
        final List eqNames = (item['equipment'] as List?) ?? const [];
        final eqId =
            eqNames.isNotEmpty ? equipmentIds[eqNames.first as String] : null;

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
        final starterLoad = item['starterLoadProfile'];
        if (starterLoad is Map) {
          final loadType = starterLoad['type'] as String?;
          if (loadType != null) {
            defMap['starter_load_type'] = loadType;
          }
          final easyValue = starterLoad['easy'];
          if (easyValue is num) {
            defMap['starter_easy_value'] = easyValue.toDouble();
          }
          final mediumValue = starterLoad['medium'];
          if (mediumValue is num) {
            defMap['starter_medium_value'] = mediumValue.toDouble();
          }
          final hardValue = starterLoad['hard'];
          if (hardValue is num) {
            defMap['starter_hard_value'] = hardValue.toDouble();
          }
          final minimumWeight = starterLoad['minimumWeight'];
          if (minimumWeight is num) {
            defMap['starter_minimum_weight'] = minimumWeight.toDouble();
          }
          final maximumWeight = starterLoad['maximumWeight'];
          if (maximumWeight is num) {
            defMap['starter_maximum_weight'] = maximumWeight.toDouble();
          }
          final roundingIncrement = starterLoad['roundingIncrement'];
          if (roundingIncrement is num) {
            defMap['starter_rounding_increment'] = roundingIncrement.toDouble();
          }
          final unitMode = starterLoad['unitMode'] as String?;
          if (unitMode != null) {
            defMap['starter_unit_mode'] = unitMode;
          }
          final confidence = starterLoad['confidence'] as String?;
          if (confidence != null) {
            defMap['starter_confidence'] = confidence;
          }
          final note = starterLoad['note'] as String?;
          if (note != null) {
            defMap['starter_note'] = note;
          }
        }

        definitionBatch.insert(
          'exercise_definitions',
          defMap,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await definitionBatch.commit(noResult: true);

      final defRows = await txn.query(
        'exercise_definitions',
        columns: ['id', 'name', 'equipment_id'],
      );
      final definitionIds = <String, int>{
        for (final row in defRows)
          defKey(row['name'] as String, row['equipment_id'] as int?):
              row['id'] as int,
      };

      final relationBatch = txn.batch();
      for (var item in exList) {
        final List eqNames = (item['equipment'] as List?) ?? const [];
        final eqId =
            eqNames.isNotEmpty ? equipmentIds[eqNames.first as String] : null;
        final resolvedDefId =
            definitionIds[defKey(item['name'] as String, eqId)];
        if (resolvedDefId == null) {
          throw Exception('exercise_def not found after seed: ${item['name']}');
        }

        for (var eName in eqNames) {
          final equipmentId = equipmentIds[eName as String];
          if (equipmentId != null) {
            relationBatch.insert('exercise_equipment', {
              'exercise_id': resolvedDefId,
              'equipment_id': equipmentId,
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }

        final List bpNames = (item['bodyparts'] as List?) ?? const [];
        for (var bpName in bpNames) {
          final bodypartId = bodypartIds[bpName as String];
          if (bodypartId != null) {
            relationBatch.insert('exercise_bodypart', {
              'exercise_id': resolvedDefId,
              'bodypart_id': bodypartId,
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }

        final List muscles = (item['muscles'] as List?) ?? const [];
        for (var mEntry in muscles) {
          final name = mEntry['name'] as String;
          final rank = (mEntry['rank'] as num).toInt();
          final muscleId = muscleIds[name];
          if (muscleId != null) {
            relationBatch.insert('exercise_muscle', {
              'exercise_id': resolvedDefId,
              'muscle_id': muscleId,
              'rank': rank,
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }
      }
      await relationBatch.commit(noResult: true);
    });
  }

  /// Seeds stretch definitions and their body part associations.
  static Future<void> seedStretches(Database db) async {
    final stJson = await rootBundle.loadString('assets/stretches.json');
    final List stList = json.decode(stJson);

    await db.transaction((txn) async {
      Future<Map<String, int>> loadIdMap(String table) async {
        final rows = await txn.query(table, columns: ['id', 'name']);
        return {
          for (final row in rows) (row['name'] as String): row['id'] as int,
        };
      }

      final stretchBatch = txn.batch();
      for (var item in stList) {
        stretchBatch.insert('stretch_definitions', {
          'name': item['name'],
          'description': item['description'] ?? '',
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await stretchBatch.commit(noResult: true);

      final stretchIds = await loadIdMap('stretch_definitions');
      final bodypartIds = await loadIdMap('bodypart');

      final relationBatch = txn.batch();
      for (var item in stList) {
        final sid = stretchIds[item['name'] as String];
        if (sid == null) {
          throw Exception('stretch not found after seed: ${item['name']}');
        }
        final List bpNames = (item['bodyparts'] as List?) ?? const [];
        for (var bpName in bpNames) {
          final bodypartId = bodypartIds[bpName as String];
          if (bodypartId != null) {
            relationBatch.insert('stretch_bodypart', {
              'stretch_id': sid,
              'bodypart_id': bodypartId,
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }
      }
      await relationBatch.commit(noResult: true);
    });
  }

  /// Seeds all the analytics-default tables.
  static Future<void> seedAnalyticsDefaults(Database db) async {
    final mbpJson = await rootBundle.loadString('assets/muscle_bodypart.json');
    final bpRankJson = await rootBundle.loadString(
      'assets/bodypart_ranking.json',
    );
    final mRankJson = await rootBundle.loadString('assets/muscle_ranking.json');
    final bpmRankJson = await rootBundle.loadString(
      'assets/bodypart_muscle_rankings.json',
    );
    final volJson = await rootBundle.loadString(
      'assets/volume_boundaries.json',
    );

    final List mbpList = json.decode(mbpJson);
    final List bpRankList = json.decode(bpRankJson);
    final List mRankList = json.decode(mRankJson);
    final List bpmRankList = json.decode(bpmRankJson);
    final Map<String, dynamic> volMap = json.decode(volJson);

    await db.transaction((txn) async {
      Future<Map<String, int>> loadIdMap(String table) async {
        final rows = await txn.query(table, columns: ['id', 'name']);
        return {
          for (final row in rows) (row['name'] as String): row['id'] as int,
        };
      }

      final bodypartIds = await loadIdMap('bodypart');
      final muscleIds = await loadIdMap('muscles');
      final batch = txn.batch();

      for (var entry in mbpList) {
        final bpId = bodypartIds[entry['bodypart'] as String];
        if (bpId == null) continue;

        for (var mName in (entry['muscles'] as List)) {
          final mId = muscleIds[mName as String];
          if (mId == null) continue;

          batch.insert('muscle_bodypart', {
            'bodypart_id': bpId,
            'muscle_id': mId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }

      for (var entry in bpRankList) {
        final bpId = bodypartIds[entry['bodypart'] as String];
        if (bpId == null) continue;
        batch.insert('bodypart_ranking', {
          'bodypart_id': bpId,
          'rank': entry['rank'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      for (var entry in mRankList) {
        final muscleId = muscleIds[entry['muscle'] as String];
        if (muscleId == null) continue;
        batch.insert('muscle_ranking', {
          'muscle_id': muscleId,
          'rank': entry['rank'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      for (var entry in bpmRankList) {
        final bpId = bodypartIds[entry['bodypart'] as String];
        if (bpId == null) continue;

        for (var mr in (entry['muscleRanks'] as List)) {
          final muscleId = muscleIds[mr['muscle'] as String];
          if (muscleId == null) continue;
          batch.insert(
            'bodypart_muscle_rankings',
            {'bodypart_id': bpId, 'muscle_id': muscleId, 'rank': mr['rank']},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      for (var bpEntry in (volMap['bodyparts'] as List)) {
        final bpId = bodypartIds[bpEntry['bodypart'] as String];
        if (bpId == null) continue;

        batch.insert(
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
        final mId = muscleIds[mEntry['muscle'] as String];
        if (mId == null) continue;

        batch.insert('muscle_volume_boundaries', {
          'muscle_id': mId,
          'maintenance_volume': mEntry['maintenance'],
          'min_effective_volume': mEntry['minEffective'],
          'max_adaptive_volume': mEntry['maxAdaptive'],
          'max_recoverable_volume': mEntry['maxRecoverable'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  /// Seeds starter foods from assets/foods.json.
  /// Works with the old shape and accepts richer optional fields:
  /// - brand/manufacturer, category_path, fdc_id, data_source, data_source_id
  /// - portions: list_kind, sort_order, amount, unit, label, ml_volume
  /// - nutrients_by_basis: { per_100g: {CODE:amt,...}, per_100ml:{...}, per_portion:[{code,amount,portion_desc}], absolute:{...} }
  static const String defaultFoodsAssetPath = 'assets/foods.json';
  static const String extendedFoodsAssetPath =
      'assets/foods/foods.min.jsonl.gz';
  static Future<void> seedFoods(
    Database db, {
    String assetPath = defaultFoodsAssetPath,
    SeedProgress? onProgress, // ← add this
  }) async {
    if (assetPath.endsWith('.jsonl.gz')) {
      return seedFoodsFromJsonlGzip(
        db,
        assetPath: assetPath,
        onProgress: onProgress, // ← pass through
      );
    } else if (assetPath.endsWith('.jsonl')) {
      return seedFoodsFromJsonl(
        db,
        assetPath: assetPath,
        onProgress: onProgress, // ← pass through
      );
    }
    return _seedFoodsFromLegacyArray(
      db,
      assetPath: assetPath,
      onProgress: onProgress,
    );
  }

  static Future<void> _seedFoodsFromLegacyArray(
    Database db, {
    required String assetPath,
    SeedProgress? onProgress,
  }) async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final List list = json.decode(jsonStr);

    final codeToId = await _nutrientCodeMap(db);
    final aliasToId = await _nutrientAliasMap(db);
    if (codeToId.isEmpty) {
      throw StateError(
        'Seed nutrients first: call Seed.seedExtendedNutrients(db) before seeding foods.',
      );
    }

    var processed = 0;
    const tick = 250;

    await db.transaction((txn) async {
      for (final raw in list) {
        final item = Map<String, dynamic>.from(raw as Map);
        final name = _s(item['name']);
        if (name == null) continue;

        final brandText = _s(item['brand']) ?? _s(item['manufacturer']);
        final manufacturer = _s(item['manufacturer']);
        final dataSource =
            _s(item['data_source'] ?? item['source']) ?? 'starter_local';
        final dataSourceId = _s(item['data_source_id'] ?? item['source_id']);
        final fdcId =
            (item['fdc_id'] as num?)?.toInt() ??
            (item['fdcId'] as num?)?.toInt();
        final density = _posOrNull(_num(item['density_g_per_ml']));
        final verified = item['verified'] == true;
        final qualityScore = _clamp01(_num(item['quality_score']));
        final version = (item['version'] as num?)?.toInt() ?? 1;
        final preparation = _trimOrNull(item['preparation'] as String?);
        final ediblePct = _clampPct(_num(item['edible_portion_pct']));
        final yieldPct = _clampPct(_num(item['yield_pct']));

        List<dynamic>? categoryPath;
        if (item['category_path'] is List) {
          categoryPath = List<dynamic>.from(item['category_path'] as List);
        } else {
          final category = _s(item['category']);
          categoryPath = category == null ? null : <dynamic>[category];
        }

        final brandId = await _ensureBrand(
          txn,
          brandText,
          manufacturer: manufacturer,
        );
        final foodId = await _upsertFood(
          txn: txn,
          name: name,
          brandId: brandId,
          brandText: brandText,
          categoryPath: categoryPath,
          dataSource: dataSource,
          dataSourceId: dataSourceId,
          fdcId: fdcId,
          barcode: _s(item['barcode']),
          densityGPerMl: density,
          verified: verified,
          qualityScore: qualityScore,
          version: version,
          preparation: preparation,
          ediblePortionPct: ediblePct,
          yieldPct: yieldPct,
        );

        if (item['barcodes'] is List) {
          for (final b in (item['barcodes'] as List)) {
            await _attachBarcode(txn, foodId, _s(b));
          }
        } else {
          await _attachBarcode(txn, foodId, _s(item['barcode']));
        }

        await txn.delete(
          'food_portions',
          where: 'food_id = ?',
          whereArgs: [foodId],
        );
        final portions = (item['portions'] as List? ?? const []);
        for (var i = 0; i < portions.length; i++) {
          final p = Map<String, dynamic>.from(portions[i] as Map);
          final gw = _posOrNull(_num(p['gram_weight']));
          final ml = _posOrNull(_num(p['ml_volume']));
          if (gw == null && ml == null) continue;

          await txn.insert('food_portions', {
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
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }

        await _ensureGramPortion(txn, foodId);
        await _ensureOneDefaultPortion(txn, foodId);

        await _replaceLegacyFoodNutrients(
          txn: txn,
          foodId: foodId,
          item: item,
          densityGPerMl: density,
          codeToId: codeToId,
          aliasToId: aliasToId,
        );

        processed++;
        if (processed % tick == 0) onProgress?.call(processed);
      }
    });

    onProgress?.call(processed);
  }

  static Future<void> _replaceLegacyFoodNutrients({
    required DatabaseExecutor txn,
    required int foodId,
    required Map<String, dynamic> item,
    required double? densityGPerMl,
    required Map<String, int> codeToId,
    required Map<String, int> aliasToId,
  }) async {
    await txn.delete(
      'food_nutrient_values',
      where: 'food_id = ?',
      whereArgs: [foodId],
    );
    await txn.delete(
      'food_nutrients',
      where: 'food_id = ?',
      whereArgs: [foodId],
    );

    final byBasis =
        item['nutrients_by_basis'] is Map
            ? Map<String, dynamic>.from(item['nutrients_by_basis'] as Map)
            : null;

    final per100g = <String, dynamic>{};
    void absorb(Map? raw) {
      if (raw == null) return;
      for (final e in raw.entries) {
        final key = e.key.toString().trim().toUpperCase();
        if (key.isEmpty) continue;
        per100g[key] = e.value;
      }
    }

    if (item['nutrients'] is Map) {
      absorb(Map<String, dynamic>.from(item['nutrients'] as Map));
    }
    if (item['per_100g'] is Map) {
      absorb(Map<String, dynamic>.from(item['per_100g'] as Map));
    }
    if (byBasis != null && byBasis['per_100g'] is Map) {
      absorb(Map<String, dynamic>.from(byBasis['per_100g'] as Map));
    }

    for (final k in const [
      'KCAL',
      'PROTEIN_G',
      'CARB_G',
      'FAT_G',
      'FIBER_G',
      'SODIUM_MG',
    ]) {
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

      await txn.insert('food_nutrient_values', {
        'food_id': foodId,
        'nutrient_id': nid,
        'amount': amt,
        'basis': 'per_100g',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      await txn.insert('food_nutrients', {
        'food_id': foodId,
        'nutrient_id': nid,
        'amount_per_100g': amt,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await _maybeEnsureEnergyKcalPer100g(
      txn,
      foodId,
      codeToId,
      aliasToId,
      per100g,
    );

    if (byBasis == null) return;

    final per100ml =
        (byBasis['per_100ml'] as Map? ?? const {}).cast<String, dynamic>();
    for (final e in per100ml.entries) {
      final nid = _resolveNutrientIdFast(codeToId, aliasToId, e.key);
      if (nid == null) continue;
      final amt = _nonNegKcalAware(e.key, e.value);
      if (amt == null) continue;

      await txn.insert('food_nutrient_values', {
        'food_id': foodId,
        'nutrient_id': nid,
        'amount': amt,
        'basis': 'per_100ml',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await _maybeBackfillPer100gFromPer100ml(
      txn,
      foodId,
      per100ml,
      densityGPerMl,
      codeToId,
      aliasToId,
    );
    await _maybeEnsureEnergyKcalPer100gFromDb(txn, foodId, codeToId);

    final perPortion = (byBasis['per_portion'] as List? ?? const []);
    for (final rawPP in perPortion) {
      final pp = Map<String, dynamic>.from(rawPP as Map);
      final code = _s(pp['code']);
      if (code == null) continue;
      final nid = _resolveNutrientIdFast(codeToId, aliasToId, code);
      if (nid == null) continue;
      final amt = _nonNegKcalAware(code, pp['amount']);
      if (amt == null) continue;

      int? portionId;
      if (pp['portion_desc'] != null) {
        portionId = await _findPortionId(
          txn,
          foodId,
          pp['portion_desc'] as String,
        );
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
        await txn.insert('food_nutrient_values', {
          'food_id': foodId,
          'nutrient_id': nid,
          'amount': amt,
          'basis': 'per_portion',
          'portion_id': portionId,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }

    final absolute =
        (byBasis['absolute'] as Map? ?? const {}).cast<String, dynamic>();
    for (final e in absolute.entries) {
      final nid = _resolveNutrientIdFast(codeToId, aliasToId, e.key);
      if (nid == null) continue;
      final amt = _nonNegKcalAware(e.key, e.value);
      if (amt == null) continue;

      await txn.insert('food_nutrient_values', {
        'food_id': foodId,
        'nutrient_id': nid,
        'amount': amt,
        'basis': 'absolute',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  /// Seeds the extended nutrient catalog (codes/units), aliases, and group hierarchy.
  /// Safe to run multiple times.
  static Future<void> seedExtendedNutrients(Database db) async {
    final jsonStr = await rootBundle.loadString(
      'assets/nutrients_extended.json',
    );
    final Map<String, dynamic> data =
        json.decode(jsonStr) as Map<String, dynamic>;

    final List nutrients = (data['nutrients'] as List? ?? const []);
    final List aliases = (data['aliases'] as List? ?? const []);
    final List groups = (data['groups'] as List? ?? const []);

    await db.transaction((txn) async {
      // 1) Upsert nutrients
      for (final n in nutrients) {
        final code = _trimOrNull(n['code'] as String)!;
        final name = _trimOrNull(n['name'] as String)!;
        final unit = _normUnit(n['unit'] as String);

        await txn.insert('nutrients', {
          'code': code,
          'name': name,
          'unit': unit,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
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
        for (final r in rows) (r['code'] as String): (r['id'] as int),
      };

      // 2) Upsert aliases
      for (final a in aliases) {
        final code = _trimOrNull(a['code'] as String)!;
        final alias = _trimOrNull(a['alias'] as String)!;
        final nid = codeToId[code];
        if (nid == null) continue;

        await txn.insert('nutrient_aliases', {
          'nutrient_id': nid,
          'alias': alias,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
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

        await txn.insert('nutrient_groups', {
          'name': name,
          'parent_id': parentId,
          'sort_key': sortKey,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

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
          await txn.insert('nutrient_group_members', {
            'group_id': groupId,
            'nutrient_id': nid,
            'sort_key': sort++,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }

      Future<void> walkGroups(List<dynamic> nodes, {int? parentId}) async {
        for (final g in nodes) {
          final name = _trimOrNull(g['name'] as String)!;
          final sort = (g['sort'] as num?)?.toInt() ?? 0;

          final gid = await ensureGroup(
            name: name,
            parentId: parentId,
            sortKey: sort,
          );
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

  static Future<int?> _ensureBrand(
    DatabaseExecutor txn,
    String? name, {
    String? manufacturer,
  }) async {
    final brand = _trimOrNull(name);
    if (brand == null) return null;

    // try insert with manufacturer; fall back if column doesn't exist
    try {
      await txn.insert('brands', {
        'name': brand,
        'manufacturer': _trimOrNull(manufacturer),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (_) {
      await txn.insert('brands', {
        'name': brand,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    final row = await txn.query(
      'brands',
      where: 'lower(name) = lower(?)',
      whereArgs: [brand],
      limit: 1,
    );
    if (row.isEmpty) return null;
    final id = row.first['id'] as int;

    // best-effort backfill if the column exists
    if (manufacturer != null && manufacturer.trim().isNotEmpty) {
      try {
        final currentManu = row.first['manufacturer'] as String?;
        if (currentManu == null || currentManu.trim().isEmpty) {
          await txn.update(
            'brands',
            {'manufacturer': manufacturer.trim()},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      } catch (_) {
        /* no manufacturer column on this schema */
      }
    }
    return id;
  }

  /// Accepts a path like ["Beverages","Coffee","Instant"] and returns the leaf category_id.
  /// Creates intermediate nodes if needed. Case-insensitive & idempotent.
  static Future<int?> _ensureCategoryPath(
    DatabaseExecutor txn,
    List<dynamic>? path,
  ) async {
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
        await txn.insert('categories', {
          'name': name,
          'parent_id': parentId,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
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
  static Future<int?> _findPortionId(
    DatabaseExecutor txn,
    int foodId,
    String description,
  ) async {
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
  // Replace your current _attachBarcode with this hardened version.
  static Future<void> _attachBarcode(
    DatabaseExecutor txn,
    int foodId,
    String? barcode,
  ) async {
    if (barcode == null) return;

    // Normalize strictly to digits and enforce 8..18 (UPC/EAN-ish).
    final digits = barcode.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^\d{8,18}$').hasMatch(digits)) return;

    try {
      await txn.insert('food_barcodes', {
        'food_id': foodId,
        'upc': digits,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } on DatabaseException catch (e) {
      // Old installs might still have a BEFORE INSERT trigger that RAISE(ABORT)s.
      final msg = e.toString();
      final isBenign =
          msg.contains('UNIQUE') ||
          msg.contains('constraint failed') ||
          msg.contains(
            'SQL logic error',
          ) || // legacy trigger RAISE without message
          msg.contains('RAISE('); // some SQLite builds include this text
      if (!isBenign) rethrow;
      // else ignore: upsert intent achieved / or legacy guard fired
    }
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
        (barcode == null || barcode.trim().isEmpty)
            ? null
            : barcode.replaceAll(RegExp(r'\D'), '');

    // try fdc_id
    if (fdcId != null) {
      final row = await txn.query(
        'foods',
        where: 'fdc_id = ?',
        whereArgs: [fdcId],
        limit: 1,
      );
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

    final bool hasBrand = brandId != null;

    if (dataSource == 'starter_local') {
      final crossSourceWhere =
          hasBrand
              ? "lower(name) = lower(?) AND brand_id = ?"
              : "lower(name) = lower(?) AND brand_id IS NULL";
      final crossSourceArgs = hasBrand ? [name, brandId] : [name];
      final crossSourceRow = await txn.query(
        'foods',
        where: crossSourceWhere,
        whereArgs: crossSourceArgs,
        limit: 1,
      );

      if (crossSourceRow.isNotEmpty) {
        final id = crossSourceRow.first['id'] as int;
        await txn.update(
          'foods',
          {
            'brand': brandText,
            'category_id': categoryId,
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
    final where =
        hasBrand
            ? "lower(name) = lower(?) AND brand_id = ? AND COALESCE(data_source, '') = ?"
            : "lower(name) = lower(?) AND brand_id IS NULL AND COALESCE(data_source, '') = ?";
    final whereArgs =
        hasBrand ? [name, brandId, dataSource] : [name, dataSource];

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
  static Future<void> seedFoodsExtended(
    Database db, {
    String assetPath = 'assets/foods_extended.json',
  }) async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final List list = json.decode(jsonStr);

    final Map<String, int> codeToId = await _nutrientCodeMap(db);
    final Map<String, int> aliasToId = await _nutrientAliasMap(db);
    if (codeToId.isEmpty) {
      throw StateError(
        'Seed nutrients first: call Seed.seedExtendedNutrients(db) before Seed.seedFoods(db).',
      );
    }

    await db.transaction((txn) async {
      for (final raw in list) {
        final Map<String, dynamic> item = Map<String, dynamic>.from(raw as Map);

        final name = _s(item['name']);
        if (name == null) continue;

        final brandText = _s(item['brand']) ?? _s(item['manufacturer']);
        final manufacturer = _s(item['manufacturer']);
        final categoryPath =
            item['category_path'] as List?; // dataset-defined; usually strings
        final fdcId = (item['fdc_id'] as num?)?.toInt();
        final source = _s(item['data_source']) ?? 'external';
        final sourceId = _s(item['data_source_id']);

        final rawBarcode = _s(item['barcode']);
        final barcode = rawBarcode?.replaceAll(RegExp(r'\D'), '');

        final density = _posOrNull(_num(item['density_g_per_ml']));
        final verified = item['verified'] == true;
        final qualityScore = _clamp01(_num(item['quality_score']));
        final version = (item['version'] as num?)?.toInt() ?? 1;
        final preparation = _trimOrNull(item['preparation'] as String?);
        final ediblePct = _clampPct(_num(item['edible_portion_pct']));
        final yieldPct = _clampPct(_num(item['yield_pct']));

        final brandId = await _ensureBrand(
          txn,
          brandText,
          manufacturer: manufacturer,
        );
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
        await txn.delete(
          'food_portions',
          where: 'food_id = ?',
          whereArgs: [foodId],
        );
        final portions = (item['portions'] as List? ?? const []);
        for (var i = 0; i < portions.length; i++) {
          final pRaw = portions[i];
          final p = Map<String, dynamic>.from(pRaw as Map);

          final gw = _posOrNull(_num(p['gram_weight']));
          final ml = _posOrNull(_num(p['ml_volume']));
          if (gw == null && ml == null) {
            continue;
          }

          await txn.insert('food_portions', {
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
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }

        // Ensure there's a gram-based portion (fallback) and one default
        await _ensureGramPortion(txn, foodId);
        await _ensureOneDefaultPortion(txn, foodId);

        // Nutrients (by basis)
        await txn.delete(
          'food_nutrient_values',
          where: 'food_id = ?',
          whereArgs: [foodId],
        );

        final Map<String, dynamic>? byBasis =
            item['nutrients_by_basis'] == null
                ? null
                : Map<String, dynamic>.from(item['nutrients_by_basis'] as Map);
        if (byBasis != null) {
          // keep legacy per_100g table in sync (avoid stale rows)
          await txn.delete(
            'food_nutrients',
            where: 'food_id = ?',
            whereArgs: [foodId],
          );

          // per_100g
          final Map<String, dynamic> per100g =
              (byBasis['per_100g'] as Map? ?? const {}).cast<String, dynamic>();
          for (final e in per100g.entries) {
            final nid = _resolveNutrientIdFast(codeToId, aliasToId, e.key);
            if (nid == null) continue;
            final amt = _nonNegKcalAware(e.key, e.value);
            if (amt == null) continue;
            await txn.insert('food_nutrient_values', {
              'food_id': foodId,
              'nutrient_id': nid,
              'amount': amt,
              'basis': 'per_100g',
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
            await txn.insert('food_nutrients', {
              'food_id': foodId,
              'nutrient_id': nid,
              'amount_per_100g': amt,
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
          // Optional: ensure KCAL if missing and macros present
          await _maybeEnsureEnergyKcalPer100g(
            txn,
            foodId,
            codeToId,
            aliasToId,
            per100g,
          );

          // per_100ml
          final Map<String, dynamic> per100ml =
              (byBasis['per_100ml'] as Map? ?? const {})
                  .cast<String, dynamic>();
          for (final e in per100ml.entries) {
            final nid = _resolveNutrientIdFast(codeToId, aliasToId, e.key);
            if (nid == null) continue;
            final amt = _nonNegKcalAware(e.key, e.value);
            if (amt == null) continue;
            await txn.insert('food_nutrient_values', {
              'food_id': foodId,
              'nutrient_id': nid,
              'amount': amt,
              'basis': 'per_100ml',
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }

          // If only per_100ml given and we know density, derive per_100g
          await _maybeBackfillPer100gFromPer100ml(
            txn,
            foodId,
            per100ml,
            density,
            codeToId,
            aliasToId,
          );

          // After derivation, ensure KCAL from DB if macros now exist
          await _maybeEnsureEnergyKcalPer100gFromDb(txn, foodId, codeToId);

          // per_portion
          final List perPortion = (byBasis['per_portion'] as List? ?? const []);
          for (final rawPP in perPortion) {
            final pp = Map<String, dynamic>.from(rawPP as Map);
            final code = _s(pp['code']);
            if (code == null) continue; // <- guard
            final nid = _resolveNutrientIdFast(codeToId, aliasToId, code);
            if (nid == null) continue;
            final amt = _nonNegKcalAware(code, pp['amount']);
            if (amt == null) continue;

            int? portionId;
            if (pp['portion_desc'] != null) {
              portionId = await _findPortionId(
                txn,
                foodId,
                pp['portion_desc'] as String,
              );
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
            await txn.insert('food_nutrient_values', {
              'food_id': foodId,
              'nutrient_id': nid,
              'amount': amt,
              'basis': 'absolute',
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }
      }
    });
  }

  static Future<int?> _ensureSource(DatabaseExecutor txn, String? name) async {
    final s = _trimOrNull(name);
    if (s == null) return null;
    await txn.insert('sources', {
      'name': s,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    final row = await txn.query(
      'sources',
      where: 'name = ?',
      whereArgs: [s],
      limit: 1,
    );
    return row.isNotEmpty ? row.first['id'] as int : null;
  }

  /// Ensure there is exactly one default portion for a food; if none, mark first as default.
  static Future<void> _ensureOneDefaultPortion(
    DatabaseExecutor txn,
    int foodId,
  ) async {
    final cur = await txn.query(
      'food_portions',
      where: 'food_id = ?',
      whereArgs: [foodId],
      orderBy: 'sort_order, id',
    );
    final hasDefault = cur.any((r) => (r['is_default'] as int? ?? 0) == 1);
    if (!hasDefault && cur.isNotEmpty) {
      final firstId = cur.first['id'] as int;
      await txn.update(
        'food_portions',
        {'is_default': 1},
        where: 'id = ?',
        whereArgs: [firstId],
      );
    }
  }

  /// Ensure at least one gram-based portion exists.
  /// - If none exist and there are no portions at all: add a "1 g" portion as default.
  /// - If none exist and portions already exist: add a non-default "1 g" portion.
  static Future<void> _ensureGramPortion(
    DatabaseExecutor txn,
    int foodId,
  ) async {
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

    await txn.insert('food_portions', {
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
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

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

      await txn.insert('food_nutrient_values', {
        'food_id': foodId,
        'nutrient_id': nid,
        'amount': derived,
        'basis': 'per_100g',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      await txn.insert('food_nutrients', {
        'food_id': foodId,
        'nutrient_id': nid,
        'amount_per_100g': derived,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
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
    bool hasKcal = per100g.keys.any(
      (k) => k.toString().trim().toUpperCase() == 'KCAL',
    );
    if (hasKcal) return;

    final p = _num(per100g['PROTEIN_G']) ?? _num(per100g['PROCNT']) ?? 0.0;
    final c =
        _num(per100g['CARB_G']) ??
        _num(per100g['CHOCDF']) ??
        _num(per100g['CARB']) ??
        0.0;
    final f = _num(per100g['FAT_G']) ?? _num(per100g['FAT']) ?? 0.0;

    final est = 4.0 * (p + c) + 9.0 * f;
    if (est <= 0) return;

    final nid = _resolveNutrientIdFast(codeToId, aliasToId, 'KCAL');
    if (nid == null) return;

    await txn.insert('food_nutrient_values', {
      'food_id': foodId,
      'nutrient_id': nid,
      'amount': est,
      'basis': 'per_100g',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await txn.insert('food_nutrients', {
      'food_id': foodId,
      'nutrient_id': nid,
      'amount_per_100g': est,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
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

    final rows = await txn.rawQuery(
      '''
      SELECT nutrient_id, amount
      FROM food_nutrient_values
      WHERE food_id = ? AND basis = 'per_100g' AND nutrient_id IN (?,?,?,?)
    ''',
      [foodId, kcalId, pId, cId, fId],
    );

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

    await txn.insert('food_nutrient_values', {
      'food_id': foodId,
      'nutrient_id': kcalId,
      'amount': est,
      'basis': 'per_100g',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await txn.insert('food_nutrients', {
      'food_id': foodId,
      'nutrient_id': kcalId,
      'amount_per_100g': est,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Seeds foods from a gzip-compressed JSONL asset (one JSON object per line),
  /// e.g. assets/foods/foods.min.jsonl.gz produced by your USDA condense script.
  /// This reuses the same schema helpers used by seedFoods().
  static Future<void> seedFoodsFromJsonlGzip(
    Database db, {
    String assetPath = extendedFoodsAssetPath,
    int batchSize = 800,
    SeedProgress? onProgress, // ← add this
  }) async {
    final bd = await rootBundle.load(assetPath);
    final bytes = bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);
    final lines = Stream<List<int>>.fromIterable([bytes])
        .transform(gzip.decoder)
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await _ingestJsonlStream(
      db,
      lines,
      batchSize: batchSize,
      onProgress: onProgress, // ← pass through
    );
  }

  static Future<void> _rebuildFoodFtsIfExists(Database db) async {
    try {
      final exists = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='food_search_fts' LIMIT 1;",
      );
      if (exists.isNotEmpty) {
        // Works for FTS4/5; harmless if no pending changes.
        await db.rawInsert(
          "INSERT INTO food_search_fts(food_search_fts) VALUES('rebuild');",
        );
      }
    } catch (_) {
      // If older schemas don't have FTS yet, just ignore.
    }
  }

  static Future<void> seedFoodsFromJsonl(
    Database db, {
    required String assetPath,
    int batchSize = 800,
    SeedProgress? onProgress, // ← add this
  }) async {
    final text = await rootBundle.loadString(assetPath);
    final lines = Stream.value(text).transform(const LineSplitter());
    await _ingestJsonlStream(
      db,
      lines,
      batchSize: batchSize,
      onProgress: onProgress, // ← pass through
    );
  }

  static Future<void> _ingestJsonlStream(
    Database db,
    Stream<String> lines, {
    int batchSize = 800,
    SeedProgress? onProgress, // ← add this
  }) async {
    final codeToId = await _nutrientCodeMap(db);
    final aliasToId = await _nutrientAliasMap(db);
    if (codeToId.isEmpty) {
      throw StateError(
        'Seed nutrients first: call Seed.seedExtendedNutrients(db) before seeding foods.',
      );
    }

    final buffer = <Map<String, dynamic>>[];
    var processed = 0; // ← running total

    Future<void> flush() async {
      if (buffer.isEmpty) return;
      final count = buffer.length; // ← will add to processed after commit
      await db.transaction((txn) async {
        for (final raw in buffer) {
          final item = Map<String, dynamic>.from(raw);

          // —— field normalization (same as gzip version) ——
          final name = _s(item['name']);
          if (name == null) continue;

          final brandText = _s(item['brand'] ?? item['manufacturer']);
          final manufacturer = _s(item['manufacturer']);
          final dataSource =
              _s(item['data_source'] ?? item['source']) ?? 'external';
          final dataSourceId = _s(item['data_source_id'] ?? item['source_id']);
          final fdcId =
              (item['fdc_id'] as num?)?.toInt() ??
              (item['fdcId'] as num?)?.toInt();
          final density = _posOrNull(_num(item['density_g_per_ml']));

          List<dynamic>? categoryPath;
          if (item['category_path'] is List) {
            categoryPath = item['category_path'] as List;
          } else {
            final single = _s(item['category']);
            categoryPath = single == null ? null : <dynamic>[single];
          }

          final barcodes =
              (item['barcodes'] is List)
                  ? (item['barcodes'] as List)
                      .map(_s)
                      .whereType<String>()
                      .toList()
                  : (() {
                    final b = _s(item['barcode']);
                    return b == null ? <String>[] : <String>[b];
                  })();

          // —— upsert food/brand ——
          final brandId = await _ensureBrand(
            txn,
            brandText,
            manufacturer: manufacturer,
          );
          final foodId = await _upsertFood(
            txn: txn,
            name: name,
            brandId: brandId,
            brandText: brandText,
            categoryPath: categoryPath,
            dataSource: dataSource,
            dataSourceId: dataSourceId,
            fdcId: fdcId,
            barcode: barcodes.isNotEmpty ? barcodes.first : null,
            densityGPerMl: density,
            verified: item['verified'] == true,
            qualityScore: _clamp01(_num(item['quality_score'])),
            version: (item['version'] as num?)?.toInt() ?? 1,
            preparation: _trimOrNull(item['preparation'] as String?),
            ediblePortionPct: _clampPct(_num(item['edible_portion_pct'])),
            yieldPct: _clampPct(_num(item['yield_pct'])),
          );

          for (final b in barcodes) {
            await _attachBarcode(txn, foodId, b);
          }

          // —— portions ——
          await txn.delete(
            'food_portions',
            where: 'food_id = ?',
            whereArgs: [foodId],
          );
          for (var i = 0; i < ((item['portions'] as List?)?.length ?? 0); i++) {
            final p = Map<String, dynamic>.from(
              (item['portions'] as List)[i] as Map,
            );
            final gw = _posOrNull(_num(p['gram_weight']));
            final ml = _posOrNull(_num(p['ml_volume']));
            if (gw == null && ml == null) continue;
            await txn.insert('food_portions', {
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
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
          await _ensureGramPortion(txn, foodId);
          await _ensureOneDefaultPortion(txn, foodId);

          // —— nutrients (per_100g only for condensed JSONL) ——
          await txn.delete(
            'food_nutrient_values',
            where: 'food_id = ?',
            whereArgs: [foodId],
          );
          await txn.delete(
            'food_nutrients',
            where: 'food_id = ?',
            whereArgs: [foodId],
          );

          final per100g = <String, dynamic>{};
          if (item['per_100g'] is Map) {
            final m = Map<String, dynamic>.from(item['per_100g'] as Map);
            for (final e in m.entries) {
              final key = e.key.toString().trim().toUpperCase();
              final val = e.value;
              if (val is num ||
                  (val is String && double.tryParse(val) != null)) {
                per100g[key] = val;
              }
            }
          }
          for (final k in const [
            'KCAL',
            'PROTEIN_G',
            'CARB_G',
            'FAT_G',
            'FIBER_G',
            'SODIUM_MG',
          ]) {
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
            await txn.insert('food_nutrient_values', {
              'food_id': foodId,
              'nutrient_id': nid,
              'amount': amt,
              'basis': 'per_100g',
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
            await txn.insert('food_nutrients', {
              'food_id': foodId,
              'nutrient_id': nid,
              'amount_per_100g': amt,
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
          await _maybeEnsureEnergyKcalPer100g(
            txn,
            foodId,
            codeToId,
            aliasToId,
            per100g,
          );
          await _maybeEnsureEnergyKcalPer100gFromDb(txn, foodId, codeToId);
        }
      });
      buffer.clear();
      processed += count; // ← update total
      onProgress?.call(processed); // ← ping caller (DatabaseHelper)
    }

    await for (final line in lines) {
      if (line.isEmpty) continue;
      buffer.add(json.decode(line) as Map<String, dynamic>);
      if (buffer.length >= batchSize) await flush();
    }
    await flush();

    await _rebuildFoodFtsIfExists(db); // keep your existing FTS rebuild
  }
}

/// One-shot helper to seed only what’s missing (runs safely after your migrations).
/// It inspects each table and only invokes the corresponding seeder if that table
/// (or group of tables) is empty. Existing data is never duplicated.
class SeedBootstrap {
  static Future<void> seedMissingBlocks(
    Database db, {
    SeedProgress? onFoodProgress,
  }) async {
    Future<void> runStep(String label, Future<void> Function() action) async {
      final sw = Stopwatch()..start();
      await action();
      debugPrint('[seed] $label in ${sw.elapsedMilliseconds}ms');
    }

    void logSkip(String label) {
      debugPrint('[seed] $label skipped');
    }

    // ——— tiny local helpers ———
    Future<bool> hasTable(String name) async {
      final r = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name = ? LIMIT 1;",
        [name],
      );
      return r.isNotEmpty;
    }

    Future<bool> tableEmpty(String name) async {
      if (!await hasTable(name)) return false; // table not present yet → skip
      final r = await db.rawQuery("SELECT 1 FROM $name LIMIT 1;");
      return r.isEmpty;
    }

    // ——— 1) Lookups + exercises (seed if ANY of these are empty) ———
    final needEquipment = await tableEmpty('equipment');
    final needBodypart = await tableEmpty('bodypart');
    final needMuscles = await tableEmpty('muscles');
    final needExDefs = await tableEmpty('exercise_definitions');

    if (needEquipment || needBodypart || needMuscles || needExDefs) {
      await runStep(
        'lookups-and-exercises',
        () => Seed.seedLookupsAndExercises(db),
      );
    } else {
      logSkip('lookups-and-exercises');
    }

    // ——— 2) Stretches (hangs off stretch_definitions) ———
    final needStretches = await tableEmpty('stretch_definitions');
    if (needStretches) {
      await runStep('stretches', () => Seed.seedStretches(db));
    } else {
      logSkip('stretches');
    }

    // ——— 3) Analytics defaults (seed if ANY of these are empty) ———
    final needMBP = await tableEmpty('muscle_bodypart');
    final needBPR = await tableEmpty('bodypart_ranking');
    final needMR = await tableEmpty('muscle_ranking');
    final needBPMR = await tableEmpty('bodypart_muscle_rankings');
    final needBPVB = await tableEmpty('bodypart_volume_boundaries');
    final needMVB = await tableEmpty('muscle_volume_boundaries');

    if (needMBP || needBPR || needMR || needBPMR || needBPVB || needMVB) {
      await runStep('analytics-defaults', () => Seed.seedAnalyticsDefaults(db));
    } else {
      logSkip('analytics-defaults');
    }

    // ——— 4) Nutrients catalog must exist before foods ———
    final needNutrients = await tableEmpty('nutrients');
    if (needNutrients) {
      await runStep('extended-nutrients', () => Seed.seedExtendedNutrients(db));
    } else {
      logSkip('extended-nutrients');
    }

    // ——— 5) Foods (optional; only if you ship the asset) ———
    final needFoods = await tableEmpty('foods');
    if (needFoods) {
      try {
        await runStep(
          'starter-foods',
          () => Seed.seedFoods(db, onProgress: onFoodProgress),
        );
      } catch (_) {
        // If the foods asset isn't bundled on some builds, ignore gracefully.
        debugPrint('[seed] starter-foods failed');
      }
    } else {
      logSkip('starter-foods');
    }
  }
}
