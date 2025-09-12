// tools/catalog_builder/tool/generate_seed_sql.dart
import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
String q(String? s) {
  if (s == null) return 'NULL';
  return "'${s.replaceAll("'", "''")}'";
}

String qNum(num? n) => n == null ? 'NULL' : n.toString();

/// 0/1/NULL as text for SQL (used when the column allows NULL).
String qBool(dynamic v) {
  if (v == null) return 'NULL';
  if (v is num) return v == 0 ? '0' : '1';
  if (v is bool) return v ? '1' : '0';
  final s = v.toString().trim().toLowerCase();
  return (s == 'true' || s == '1' || s == 'yes') ? '1' : '0';
}

/// Non-nullable bool (used where schema has NOT NULL); defaults to 0 if absent.
String qBoolNZ(dynamic v, {String ifNull = '0'}) =>
    v == null ? ifNull : qBool(v);

bool _isLikelyUpc(String rawDigits) {
  const validLen = {8, 12, 13, 14};
  return validLen.contains(rawDigits.length);
}

List<dynamic> _loadJsonArray(String path) {
  final f = File(path);
  if (!f.existsSync()) return const [];
  final txt = f.readAsStringSync();
  final data = json.decode(txt);
  if (data is List) return data;
  throw StateError('Expected JSON array in $path');
}

Iterable<Map<String, dynamic>> _readJsonl(File f) sync* {
  final lines = f.readAsLinesSync();
  for (final line in lines) {
    final t = line.trim();
    if (t.isEmpty) continue;
    final obj = json.decode(t);
    if (obj is Map<String, dynamic>) yield obj;
  }
}

Iterable<Map<String, dynamic>> _readJsonlGz(File f) sync* {
  final bytes = f.readAsBytesSync();
  final decompressed = gzip.decode(bytes);
  final lines = const LineSplitter().convert(utf8.decode(decompressed));
  for (final line in lines) {
    final t = line.trim();
    if (t.isEmpty) continue;
    final obj = json.decode(t);
    if (obj is Map<String, dynamic>) yield obj;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────────────────────────────────────
void main(List<String> argv) {
  final ap = ArgParser()
    ..addOption('in',
        help: 'Input directory containing JSON files (legacy path)',
        valueHelp: 'tools/catalog_builder/json',
        defaultsTo: 'tools/catalog_builder/json')
    ..addOption('out',
        help: 'Output SQL file (no BEGIN/COMMIT; builder wraps in a txn)',
        valueHelp: 'tools/catalog_builder/data/seed_catalog.sql',
        defaultsTo: 'tools/catalog_builder/data/seed_catalog.sql')
    ..addOption('jsonl',
        help: 'Path to foods JSONL (one JSON object per line)',
        valueHelp: 'tools/catalog_builder/jsonl/foods.jsonl')
    ..addOption('jsonl-gz',
        help: 'Path to foods JSONL.GZ (gzipped jsonl)',
        valueHelp: 'tools/catalog_builder/jsonl/foods.min.jsonl.gz')
    ..addFlag('verbose', defaultsTo: false); // accepted, but not used

  final args = ap.parse(argv);
  final inDir = args['in'] as String;
  final outPath = args['out'] as String;
  final jsonlPath = args['jsonl'] as String?;
  final jsonlGzPath = args['jsonl-gz'] as String?;

  // Output
  final outFile = File(outPath);
  outFile.createSync(recursive: true);
  final sink = outFile.openWrite();

  // NOTE: No BEGIN/COMMIT here — the build step wraps with savepoints/txn.

  // Temp mapping tables used by the builder import phase.
  sink.writeln("CREATE TEMP TABLE IF NOT EXISTS _import_food_map (ext TEXT PRIMARY KEY, food_id INTEGER NOT NULL);");
  sink.writeln("CREATE TEMP TABLE IF NOT EXISTS _import_portion_map (ext TEXT PRIMARY KEY, portion_id INTEGER NOT NULL);");

  int foodsCount = 0, portionsCount = 0, per100gCount = 0, perPortionCount = 0, barcodesCount = 0;

  // ── Fast lane: JSONL / JSONL.GZ ────────────────────────────────────────────
  if ((jsonlPath != null && jsonlPath.isNotEmpty) ||
      (jsonlGzPath != null && jsonlGzPath.isNotEmpty)) {
    final file = jsonlPath != null ? File(jsonlPath) : File(jsonlGzPath!);
    if (!file.existsSync()) {
      stderr.writeln('Input JSONL file not found: ${file.path}');
      exitCode = 2;
      sink.close();
      return;
    }

    final rows = jsonlPath != null ? _readJsonl(file) : _readJsonlGz(file);
    int i = 0;

    for (final m in rows) {
      i++;
      final ext = 'food_${i.toString().padLeft(6, '0')}';

      final name = (m['name'] as String).trim();
      final brand = (m['brand'] as String?)?.trim();
      final category = (m['category'] as String?)?.trim();
      final sourceName = (m['source'] as String?)?.trim();
      final sourceId = m['source_id'];
      final dataSource = sourceName ?? 'prebuilt';
      final dataSourceId = sourceId == null ? null : '$sourceId';

      // normalize barcodes
      final rawBcs = (m['barcodes'] is List) ? List.from(m['barcodes'] as List) : const [];
      final barcodes = <String>[];
      for (final b in rawBcs) {
        final digits = '$b'.replaceAll(RegExp(r'\D'), '');
        if (digits.isEmpty) continue;
        if (_isLikelyUpc(digits)) barcodes.add(digits);
      }

      // portions (with synthesized fallback)
      final portions = <Map<String, dynamic>>[];
      if (m['portions'] is List) {
        for (final p0 in (m['portions'] as List)) {
          final mp = Map<String, dynamic>.from(p0 as Map);
          final measure = (mp['measure_name'] as String).trim();
          final gw = (mp['gram_weight'] as num?)?.toDouble();
          final isDefault = (mp['is_default'] == true) ||
              (measure.toLowerCase() == '100 g') ||
              (measure.toLowerCase() == '100g') ||
              (gw == 100.0);
          portions.add({
            'measure_name': measure,
            'gram_weight': gw,
            'ml_volume': null,
            'is_default': isDefault ? 1 : 0,
            'list_kind': 'basis',
            'sort_order': 0,
            'amount': gw,
            'unit': 'g',
            'label': null,
          });
        }
      } else if (m['serving_size'] is Map) {
        // fallback: synthesize one portion from serving_size
        final ss = Map<String, dynamic>.from(m['serving_size'] as Map);
        final amount = (ss['amount'] as num?)?.toDouble();
        final unit = (ss['unit'] as String?)?.toLowerCase();
        final isMl = unit == 'ml' || unit == 'milliliter' || unit == 'milliliters';
        final text = (ss['text'] as String?) ?? '${amount ?? ''} ${ss['unit'] ?? ''}'.trim();
        if (amount != null) {
          portions.add({
            'measure_name': 'serving ($text)',
            'gram_weight': isMl ? null : amount,
            'ml_volume':   isMl ? amount : null,
            'is_default': 1,
            'list_kind': 'basis',
            'sort_order': 0,
            'amount': amount,
            'unit': isMl ? 'ml' : 'g',
            'label': null,
          });
        }
      }

      // ensure exactly one default
      if (portions.isNotEmpty && !portions.any((p) => p['is_default'] == 1)) {
        final idx100 = portions.indexWhere((p) =>
            (p['measure_name'] as String).toLowerCase().replaceAll(' ', '') == '100g' ||
            (p['gram_weight'] as num?)?.toDouble() == 100.0);
        final idx = idx100 >= 0 ? idx100 : 0;
        portions[idx]['is_default'] = 1;
      }

      // nutrients per_100g (extendable to per_100ml later)
      final per100g = <Map<String, dynamic>>[];
      if (m['per_100g'] is Map) {
        final nmap = Map<String, dynamic>.from(m['per_100g'] as Map);
        for (final entry in nmap.entries) {
          final code = entry.key.toString().trim().toUpperCase();
          final val = entry.value;
          if (val == null) continue;
          final amount = (val is num) ? val.toDouble() : double.tryParse('$val');
          if (amount == null) continue;
          per100g.add({'code': code, 'amount': amount});
        }
      }

      // ── SQL: brands/categories/sources
      if (brand != null && brand.isNotEmpty) {
        sink.writeln("INSERT OR IGNORE INTO brands(name) VALUES (${q(brand)});");
      }
      if (category != null && category.isNotEmpty) {
        sink.writeln("INSERT OR IGNORE INTO categories(name) VALUES (${q(category)});");
      }
      if (sourceName != null && sourceName.isNotEmpty) {
        sink.writeln("INSERT OR IGNORE INTO sources(name) VALUES (${q(sourceName)});");
      }

      // ── SQL: foods (created_at/updated_at use SQLite date('now'))
      sink.writeln("""
INSERT INTO foods(
  name, brand, brand_id, category_id, is_custom, verified,
  data_source, data_source_id, source_id, density_g_per_ml, quality_score,
  version, preparation, created_at, updated_at, is_deleted
)
VALUES(
  ${q(name)},
  ${q(brand)},
  ${brand == null ? 'NULL' : "(SELECT id FROM brands WHERE name=${q(brand)} LIMIT 1)"},
  ${category == null ? 'NULL' : "(SELECT id FROM categories WHERE name=${q(category)} LIMIT 1)"},
  0,
  1,
  ${q(dataSource)},
  ${q(dataSourceId)},
  ${sourceName == null ? 'NULL' : "(SELECT id FROM sources WHERE name=${q(sourceName)} LIMIT 1)"},
  NULL, NULL,
  1,
  NULL,
  date('now'),
  date('now'),
  0
);
INSERT INTO _import_food_map(ext, food_id) VALUES (${q(ext)}, last_insert_rowid());
""");
      foodsCount++;

      // ── SQL: portions
      int localPortionIdx = 0;
      for (final pmap in portions) {
        localPortionIdx++;
        final pext = '${ext}_p${localPortionIdx.toString().padLeft(3, '0')}';
        sink.writeln("""
INSERT INTO food_portions(
  food_id, measure_name, gram_weight, ml_volume, is_default, list_kind,
  sort_order, amount, unit, label
)
SELECT
  (SELECT food_id FROM _import_food_map WHERE ext=${q(ext)}),
  ${q(pmap['measure_name'] as String?)},
  ${qNum(pmap['gram_weight'] as num?)},
  ${qNum(pmap['ml_volume'] as num?)},
  ${qBoolNZ(pmap['is_default'])},
  ${q(pmap['list_kind'] as String?)},
  ${qNum(pmap['sort_order'] as num?)},
  ${qNum(pmap['amount'] as num?)},
  ${q(pmap['unit'] as String?)},
  ${q(pmap['label'] as String?)};
INSERT INTO _import_portion_map(ext, portion_id) VALUES (${q(pext)}, last_insert_rowid());
""");
        portionsCount++;
      }

      // ── SQL: per_100g nutrient values (guard unknown codes)
      for (final n in per100g) {
        sink.writeln("""
INSERT INTO food_nutrient_values(food_id, nutrient_id, amount, basis, portion_id)
SELECT
  (SELECT food_id FROM _import_food_map WHERE ext=${q(ext)}),
  (SELECT id FROM nutrients WHERE code=${q(n['code'] as String)}),
  ${qNum(n['amount'] as num?)},
  'per_100g',
  NULL
WHERE EXISTS (SELECT 1 FROM nutrients WHERE code=${q(n['code'] as String)});
""");
        per100gCount++;
      }

      // ── SQL: barcodes
      for (final bc in barcodes) {
        sink.writeln("""
INSERT OR IGNORE INTO food_barcodes(food_id, upc)
SELECT (SELECT food_id FROM _import_food_map WHERE ext=${q(ext)}), ${q(bc)};
""");
        barcodesCount++;
      }
    }

    // Normalize to one default portion per food (keep lowest id).
    sink.writeln("""
WITH d AS (
  SELECT food_id, MIN(id) AS keep_id
  FROM food_portions
  WHERE COALESCE(is_default,0)=1
  GROUP BY food_id
)
UPDATE food_portions
SET is_default = 0
WHERE COALESCE(is_default,0)=1
  AND id NOT IN (SELECT keep_id FROM d);
""");

    // Set foods.default_portion_id when a default exists.
    sink.writeln("""
UPDATE foods
SET default_portion_id = (
  SELECT id FROM food_portions p
  WHERE p.food_id = foods.id AND COALESCE(p.is_default,0) = 1
  ORDER BY p.id LIMIT 1
)
WHERE default_portion_id IS NULL
  AND EXISTS (SELECT 1 FROM food_portions x
              WHERE x.food_id = foods.id AND COALESCE(x.is_default,0) = 1);
""");

    // Mirror per_100g into legacy table for back-compat reads.
    sink.writeln("""
INSERT OR IGNORE INTO food_nutrients(food_id, nutrient_id, amount_per_100g)
SELECT food_id, nutrient_id, amount
FROM food_nutrient_values
WHERE basis='per_100g';
""");

    sink.close();
    stdout.writeln('> Wrote ${p.normalize(outPath)} '
        '(foods=$foodsCount, portions=$portionsCount, '
        'per_100g=$per100gCount, per_portion=$perPortionCount, barcodes=$barcodesCount)');
    return;
  }

  // ── Legacy path: separate JSON files ──────────────────────────────────────
  final foodsPath      = p.join(inDir, 'foods.json');
  final portionsPath   = p.join(inDir, 'portions.json');
  final per100gPath    = p.join(inDir, 'per100g.json');
  final perPortionPath = p.join(inDir, 'per_portion.json');
  final barcodesPath   = p.join(inDir, 'barcodes.json');
  final sourcesPath    = p.join(inDir, 'sources.json');            // optional
  final aliasesPath    = p.join(inDir, 'nutrient_aliases.json');   // optional
  final recipesPath    = p.join(inDir, 'recipes.json');            // optional
  final ringsPath      = p.join(inDir, 'recipe_ingredients.json'); // optional

  final foods = _loadJsonArray(foodsPath);
  if (foods.isEmpty) {
    stderr.writeln('No foods found at $foodsPath (this file is required unless --jsonl* is provided).');
    exitCode = 2;
    sink.close();
    return;
  }
  final portions   = _loadJsonArray(portionsPath);
  final per100g    = _loadJsonArray(per100gPath);
  final perPortion = _loadJsonArray(perPortionPath);
  final barcodes   = _loadJsonArray(barcodesPath);
  final sources    = _loadJsonArray(sourcesPath);
  final aliases    = _loadJsonArray(aliasesPath);
  final recipes    = _loadJsonArray(recipesPath);
  final rings      = _loadJsonArray(ringsPath);

  // Optional sources/aliases/recipes
  for (final e in sources) {
    final m = Map<String, dynamic>.from(e as Map);
    if ((m['name'] as String?)?.trim().isNotEmpty == true) {
      sink.writeln("INSERT OR IGNORE INTO sources(name) VALUES (${q(m['name'] as String)});");
    }
  }
  for (final e in aliases) {
    final m = Map<String, dynamic>.from(e as Map);
    sink.writeln("""
INSERT OR IGNORE INTO nutrient_aliases(nutrient_id, alias)
SELECT id, ${q(m['alias'] as String)} FROM nutrients WHERE code=${q(m['code'] as String)};
""");
  }

  for (final e in foods) {
    final m = Map<String, dynamic>.from(e as Map);
    final ext = m['ext'] as String;
    final name = m['name'] as String;
    final brand = m['brand'] as String?;
    final category = m['category'] as String?;

    if (brand != null && brand.trim().isNotEmpty) {
      sink.writeln("INSERT OR IGNORE INTO brands(name) VALUES (${q(brand)});");
    }
    if (category != null && category.trim().isNotEmpty) {
      sink.writeln("INSERT OR IGNORE INTO categories(name) VALUES (${q(category)});");
    }

    sink.writeln("""
INSERT INTO foods (
  name, brand, brand_id, category_id, is_custom, verified, data_source, data_source_id,
  density_g_per_ml, quality_score, version, preparation, created_at, updated_at, is_deleted
)
VALUES (
  ${q(name)},
  ${q(brand)},
  ${brand == null ? 'NULL' : "(SELECT id FROM brands WHERE name=${q(brand)} LIMIT 1)"},
  ${category == null ? 'NULL' : "(SELECT id FROM categories WHERE name=${q(category)} LIMIT 1)"},
  ${qBool(m['is_custom'])},
  ${qBool(m['verified'])},
  ${q(m['data_source'] as String?)},
  ${q(m['data_source_id'] as String?)},
  ${qNum(m['density_g_per_ml'] as num?)},
  ${qNum(m['quality_score'] as num?)},
  ${qNum(m['version'] as num?)},
  ${q(m['preparation'] as String?)},
  ${q(m['created_at'] as String? ?? '2025-01-01')},
  ${q(m['updated_at'] as String? ?? '2025-01-01')},
  0
);
INSERT INTO _import_food_map(ext, food_id) VALUES (${q(ext)}, last_insert_rowid());
""");
    foodsCount++;
  }

  for (final e in portions) {
    final m = Map<String, dynamic>.from(e as Map);
    final ext = m['ext'] as String;
    final foodExt = m['food_ext'] as String;

    sink.writeln("""
INSERT INTO food_portions(
  food_id, measure_name, gram_weight, ml_volume, is_default, list_kind,
  sort_order, amount, unit, label
)
SELECT
  (SELECT food_id FROM _import_food_map WHERE ext=${q(foodExt)}),
  ${q(m['measure_name'] as String)},
  ${qNum(m['gram_weight'] as num?)},
  ${qNum(m['ml_volume'] as num?)},
  ${qBoolNZ(m['is_default'])},
  ${q(m['list_kind'] as String?)},
  ${qNum(m['sort_order'] as num?)},
  ${qNum(m['amount'] as num?)},
  ${q(m['unit'] as String?)},
  ${q(m['label'] as String?)};
INSERT INTO _import_portion_map(ext, portion_id) VALUES (${q(ext)}, last_insert_rowid());
""");
    portionsCount++;
  }

  // per_100g with guard
  for (final e in per100g) {
    final m = Map<String, dynamic>.from(e as Map);
    final foodExt = m['food_ext'] as String;
    final code = m['nutrient_code'] as String;
    final amount = (m['amount'] as num).toString();
    final basis = q(m['basis'] as String? ?? 'per_100g');
    sink.writeln("""
INSERT INTO food_nutrient_values(food_id, nutrient_id, amount, basis, portion_id)
SELECT
  (SELECT food_id FROM _import_food_map WHERE ext=${q(foodExt)}),
  (SELECT id FROM nutrients WHERE code=${q(code)}),
  $amount,
  $basis,
  NULL
WHERE EXISTS (SELECT 1 FROM nutrients WHERE code=${q(code)});
""");
    per100gCount++;
  }

  // per_portion with guard (nutrient + portion)
  for (final e in perPortion) {
    final m = Map<String, dynamic>.from(e as Map);
    final foodExt = m['food_ext'] as String;
    final portionExt = m['portion_ext'] as String;
    final code = m['nutrient_code'] as String;
    final amount = (m['amount'] as num).toString();
    sink.writeln("""
INSERT INTO food_nutrient_values(food_id, nutrient_id, amount, basis, portion_id)
SELECT
  (SELECT food_id FROM _import_food_map WHERE ext=${q(foodExt)}),
  (SELECT id FROM nutrients WHERE code=${q(code)}),
  $amount,
  'per_portion',
  (SELECT portion_id FROM _import_portion_map WHERE ext=${q(portionExt)})
WHERE EXISTS (SELECT 1 FROM nutrients WHERE code=${q(code)})
  AND EXISTS (SELECT 1 FROM _import_portion_map WHERE ext=${q(portionExt)});
""");
    perPortionCount++;
  }

  for (final e in barcodes) {
    final m = Map<String, dynamic>.from(e as Map);
    final foodExt = m['food_ext'] as String;
    final upc = (m['upc'] as String).replaceAll(RegExp(r'\D'), '');
    if (_isLikelyUpc(upc)) {
      sink.writeln("""
INSERT OR IGNORE INTO food_barcodes(food_id, upc)
SELECT (SELECT food_id FROM _import_food_map WHERE ext=${q(foodExt)}), ${q(upc)};
""");
      barcodesCount++;
    }
  }

  // (Optional) recipes & ingredients (simple passthrough)
  for (final e in recipes) {
    final m = Map<String, dynamic>.from(e as Map);
    sink.writeln("""
INSERT INTO recipes(name, notes, is_deleted, created_at, updated_at)
VALUES(${q(m['name'] as String)}, ${q(m['notes'] as String?)}, 0, ${q(m['created_at'] as String? ?? '2025-01-01')}, ${q(m['updated_at'] as String? ?? '2025-01-01')});
""");
  }
  for (final e in rings) {
    final m = Map<String, dynamic>.from(e as Map);
    sink.writeln("""
INSERT INTO recipe_ingredients(recipe_id, food_id, portion_id, quantity, grams)
VALUES(
  ${qNum(m['recipe_id'] as num?)},
  ${qNum(m['food_id'] as num?)},
  ${qNum(m['portion_id'] as num?)},
  ${qNum(m['quantity'] as num?)},
  ${qNum(m['grams'] as num?)}
);
""");
  }

  // Normalize to one default portion per food (keep lowest id).
  sink.writeln("""
WITH d AS (
  SELECT food_id, MIN(id) AS keep_id
  FROM food_portions
  WHERE COALESCE(is_default,0)=1
  GROUP BY food_id
)
UPDATE food_portions
SET is_default = 0
WHERE COALESCE(is_default,0)=1
  AND id NOT IN (SELECT keep_id FROM d);
""");

  // Set foods.default_portion_id where a default exists.
  sink.writeln("""
UPDATE foods
SET default_portion_id = (
  SELECT id FROM food_portions p
  WHERE p.food_id = foods.id AND COALESCE(p.is_default,0) = 1
  ORDER BY p.id LIMIT 1
)
WHERE default_portion_id IS NULL
  AND EXISTS (SELECT 1 FROM food_portions x
              WHERE x.food_id = foods.id AND COALESCE(x.is_default,0) = 1);
""");

  // Mirror per_100g into legacy table for back-compat reads.
  sink.writeln("""
INSERT OR IGNORE INTO food_nutrients(food_id, nutrient_id, amount_per_100g)
SELECT food_id, nutrient_id, amount
FROM food_nutrient_values
WHERE basis='per_100g';
""");

  sink.close();
  stdout.writeln('> Wrote ${p.normalize(outPath)} '
      '(foods=$foodsCount, portions=$portionsCount, per_100g=$per100gCount, '
      'per_portion=$perPortionCount, barcodes=$barcodesCount)');
}
