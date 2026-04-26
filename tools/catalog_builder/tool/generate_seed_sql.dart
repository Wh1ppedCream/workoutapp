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

/// Strict UPC/EAN lengths matching the original pipeline.
bool _isLikelyUpc(String rawDigits) {
  const valid = {8, 12, 13, 14};
  return valid.contains(rawDigits.length);
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

// Small records for batching
class _NutRow {
  final String ext;
  final String code;
  final num amount;
  _NutRow(this.ext, this.code, this.amount);
}

class _BcRow {
  final String ext;
  final String upc;
  _BcRow(this.ext, this.upc);
}

// ─────────────────────────────────────────────────────────────────────────────
void main(List<String> argv) {
  const int kNutrientBatch = 400; // keep VALUES tree modest
  const int kBarcodeBatch = 100;

  final ap = ArgParser()
    ..addOption('in',
        help: 'Input directory containing JSON files (legacy path)',
        valueHelp: 'tools/catalog_builder/json',
        defaultsTo: 'tools/catalog_builder/json')
    ..addOption('out',
        help: 'Output SQL file (no BEGIN/COMMIT; builder wraps in a txn)',
        valueHelp: 'tools/catalog_builder/data/seed_catalog.sql',
        defaultsTo: 'tools/catalog_builder/data/seed_catalog.sql')
    ..addMultiOption('jsonl',
        help: 'Path(s) to foods JSONL file(s) (one JSON object per line)',
        valueHelp: 'tools/catalog_builder/jsonl/*.jsonl')
    ..addMultiOption('jsonl-gz',
        help: 'Path(s) to gzipped JSONL file(s)',
        valueHelp: 'tools/catalog_builder/jsonl/*.jsonl.gz')
    ..addFlag('verbose', defaultsTo: false); // accepted, but not used

  final args = ap.parse(argv);
  final inDir = args['in'] as String;
  final outPath = args['out'] as String;
  final jsonlPaths = (args['jsonl'] as List<String>? ?? const <String>[]);
  final jsonlGzPaths = (args['jsonl-gz'] as List<String>? ?? const <String>[]);

  // Output
  final outFile = File(outPath);
  outFile.createSync(recursive: true);
  final sink = outFile.openWrite();
  void writeLine(String s) => sink.writeln(s);

  // NOTE: No BEGIN/COMMIT here — the build step wraps with savepoints/txn.

  // Temp mapping + staging tables used by the builder import phase.
  writeLine(
      "CREATE TEMP TABLE IF NOT EXISTS _import_food_map (ext TEXT PRIMARY KEY, food_id INTEGER NOT NULL);");
  writeLine(
      "CREATE TEMP TABLE IF NOT EXISTS _import_portion_map (ext TEXT PRIMARY KEY, portion_id INTEGER NOT NULL);");
  // Create once and reuse for barcode batches.
  writeLine(
      "CREATE TEMP TABLE IF NOT EXISTS _staging_barcodes(ext TEXT, upc TEXT);");

  int foodsCount = 0,
      portionsCount = 0,
      per100gCount = 0,
      perPortionCount = 0,
      barcodesCount = 0;

  // Dedup sets (reduce tiny INSERT chatter)
  final seenBrands = <String>{};
  final seenCategories = <String>{};
  final seenSources = <String>{};

  // Batched buffers
  final nutBatch = <_NutRow>[];
  final bcBatch = <_BcRow>[];

  // Nutrient batch flush via CTE for broad SQLite compatibility
  void flushNutrientBatch() {
    if (nutBatch.isEmpty) return;
    final rows = nutBatch
        .map((n) => "(${q(n.ext)}, ${q(n.code)}, ${qNum(n.amount)})")
        .join(",\n    ");
    writeLine("""
WITH v(ext, code, amount) AS (
  VALUES
    $rows
)
INSERT INTO food_nutrient_values(food_id, nutrient_id, amount, basis, portion_id)
SELECT
  (SELECT food_id FROM _import_food_map WHERE ext=v.ext),
  (SELECT id FROM nutrients WHERE code=v.code),
  v.amount,
  'per_100g',
  NULL
FROM v
WHERE EXISTS (SELECT 1 FROM nutrients WHERE code=v.code)
  AND EXISTS (SELECT 1 FROM _import_food_map WHERE ext=v.ext);
""");
    nutBatch.clear();
  }

  // Barcode batch flush using the persistent temp table
  void flushBarcodeBatch() {
    if (bcBatch.isEmpty) return;
    final rows =
        bcBatch.map((b) => "(${q(b.ext)}, ${q(b.upc)})").join(",\n  ");
    writeLine("""
DELETE FROM _staging_barcodes;
INSERT INTO _staging_barcodes(ext, upc)
VALUES
  $rows;

INSERT OR IGNORE INTO food_barcodes(food_id, upc)
SELECT m.food_id, s.upc
FROM _staging_barcodes s
JOIN _import_food_map m ON m.ext = s.ext;
""");
    bcBatch.clear();
  }

  // ── Fast lane: JSONL / JSONL.GZ (multi-file) ───────────────────────────────
if (jsonlPaths.isNotEmpty || jsonlGzPaths.isNotEmpty) {
  // Validate existence of all declared files (fail fast on any missing).
  for (final path in [...jsonlPaths, ...jsonlGzPaths]) {
    final f = File(path);
    if (!f.existsSync()) {
      stderr.writeln('Input JSONL file not found: ${f.path}');
      exitCode = 2;
      sink.close();
      return;
    }
  }

  // One global counter across all files to keep ext unique.
  int i = 0;

  // Local helper to process a sequence of rows with the original per-row logic.
  void processRows(Iterable<Map<String, dynamic>> rows) {
    for (final m in rows) {
      i++;
      final ext = 'food_${i.toString().padLeft(7, '0')}';

      final name = (m['name'] as String).trim();
      final brand = (m['brand'] as String?)?.trim();
      final category = (m['category'] as String?)?.trim();
      final sourceName = (m['source'] as String?)?.trim();
      final sourceId = m['source_id'];
      final dataSource = sourceName ?? 'prebuilt';
      final dataSourceId = sourceId == null ? null : '$sourceId';

      // dictionaries (use OR IGNORE; rely on unique index if present)
      if (brand != null && brand.isNotEmpty && seenBrands.add(brand.toLowerCase())) {
        writeLine("INSERT OR IGNORE INTO brands(name) VALUES (${q(brand)});");
      }
      if (category != null &&
          category.isNotEmpty &&
          seenCategories.add(category.toLowerCase())) {
        writeLine("INSERT OR IGNORE INTO categories(name) VALUES (${q(category)});");
      }
      if (sourceName != null &&
          sourceName.isNotEmpty &&
          seenSources.add(sourceName.toLowerCase())) {
        writeLine("INSERT OR IGNORE INTO sources(name) VALUES (${q(sourceName)});");
      }

      // normalize barcodes (collect; flush in batches later)
      final rawBcs =
          (m['barcodes'] is List) ? List.from(m['barcodes'] as List) : const [];
      for (final b in rawBcs) {
        final digits = '$b'.replaceAll(RegExp(r'\D'), '');
        if (digits.isEmpty) continue;
        if (_isLikelyUpc(digits)) {
          bcBatch.add(_BcRow(ext, digits));
          barcodesCount++;
          if (bcBatch.length >= kBarcodeBatch) flushBarcodeBatch();
        }
      }

      // portions (with synthesized fallback)
final portions = <Map<String, dynamic>>[];
if (m['portions'] is List) {
  for (final p0 in (m['portions'] as List)) {
    final mp = Map<String, dynamic>.from(p0 as Map);
    final measure = (mp['measure_name'] as String).trim();
    final gw = (mp['gram_weight'] as num?)?.toDouble();

    // Preserve *source* default only; do NOT force 100g to default.
    final isDefault = (mp['is_default'] == true);

    // Try to keep semantic units (piece/serving/slice) when the measure name implies them.
    String? semanticUnit;
    num? semanticAmount;
    final lname = measure.toLowerCase();
    if (lname.contains('serving')) {
      semanticUnit = 'serving';
      semanticAmount = 1;
    } else if (lname.contains('piece')) {
      semanticUnit = 'piece';
      semanticAmount = 1;
    } else if (lname.contains('slice')) {
      semanticUnit = 'slice';
      semanticAmount = 1;
    } else if (lname.replaceAll(' ', '') == '100g' || gw == 100.0) {
      // Explicit 100g measure
      semanticUnit = 'g';
      semanticAmount = 100;
    }

        // Fallbacks when no semantic unit and no gram weight are available:
    String? fallbackUnit;
    num? fallbackAmount;
    if (semanticUnit == null && gw == null) {
      final tokens = lname
          .split(RegExp(r'\s+'))
          .where((t) => t.isNotEmpty)
          .toList();

            num parseNumberToken(String s) {
        // Strip common punctuation like commas and trailing parentheses
        final t = s.replaceAll(RegExp(r'[(),]'), '');
        // Mixed fraction: "2 1/2"
        final mixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)$');
        final m = mixed.firstMatch(t);
        if (m != null) {
          final whole = num.parse(m.group(1)!);
          final nume  = num.parse(m.group(2)!);
          final den   = num.parse(m.group(3)!);
          return whole + (nume / den);
        }
        // Simple fraction: "1/2"
        final frac = RegExp(r'^(\d+)\s*/\s*(\d+)$');
        final f = frac.firstMatch(t);
        if (f != null) {
          final nume = num.parse(f.group(1)!);
          final den  = num.parse(f.group(2)!);
          return nume / den;
        }
        // Decimal or integer
        return num.parse(t);
      }

      bool looksNumeric(String s) =>
          RegExp(r'^\d+([.,]\d+)?$').hasMatch(s) ||
          RegExp(r'^\d+\s+\d+/\d+$').hasMatch(s) ||
          RegExp(r'^\d+/\d+$').hasMatch(s);

      const stop = {'of', 'a', 'an', 'the'};

      // pick first non-numeric, non-stopword token as the unit (strip punctuation)
      String? picked;
      for (var t in tokens) {
        t = t.replaceAll(RegExp(r'[().,]'), '');
        if (t.isEmpty) continue;
        if (looksNumeric(t) || stop.contains(t)) continue;
        picked = t;
        break;
      }
      if (picked != null) {
        fallbackUnit = picked; // e.g., "cup", "tbsp"
        // Leading amount like "1", "1/2", or mixed "2 1/2"
 num? maybeMixedFractionAmount() {
   if (tokens.isEmpty) return null;
   final first = tokens[0].replaceAll(RegExp(r'[().,]'), '');
   if (tokens.length >= 2) {
     final second = tokens[1].replaceAll(RegExp(r'[().,]'), '');
     if (RegExp(r'^\d+$').hasMatch(first) && RegExp(r'^\d+/\d+$').hasMatch(second)) {
       final parts = second.split('/');
       final whole = num.parse(first);
       final nume  = num.parse(parts[0]);
       final den   = num.parse(parts[1]);
       return whole + (nume / den);
     }
   }
   return looksNumeric(first) ? parseNumberToken(first) : null;
 }
 final maybe = maybeMixedFractionAmount();
 fallbackAmount = (maybe == null || maybe <= 0 || maybe.isNaN) ? 1 : maybe;
      }

    }


    portions.add({
      'measure_name': measure,
      'gram_weight': gw, // conversion anchor if present
      'ml_volume': null,
      'is_default': isDefault ? 1 : 0,
      'list_kind': 'basis',
      'sort_order': portions.length,
      'amount': semanticAmount ?? fallbackAmount ?? gw,
      'unit': semanticUnit ?? fallbackUnit ?? (gw != null ? 'g' : null),
      'label': null,
    });
  }
} else if (m['serving_size'] is Map) {
        // synthesize one portion from serving_size (preserve semantic unit)
        final ss = Map<String, dynamic>.from(m['serving_size'] as Map);
        final amount = (ss['amount'] as num?)?.toDouble();
        final unitRaw = (ss['unit'] as String?)?.toLowerCase();
        final isMl = unitRaw == 'ml' || unitRaw == 'milliliter' || unitRaw == 'milliliters';
        final isGram = unitRaw == 'g' || unitRaw == 'gram' || unitRaw == 'grams';
        final text = (ss['text'] as String?) ?? '${amount ?? ''} ${ss['unit'] ?? ''}'.trim();

        if (amount != null) {
          portions.add({
            'measure_name': text,
            'gram_weight': isMl ? null : (isGram ? amount : null),
            'ml_volume': isMl ? amount : null,
            'is_default': 1,
            'list_kind': 'basis',
            'sort_order': 0,
            'amount': amount,
            'unit': isMl ? 'ml' : (unitRaw ?? (isGram ? 'g' : null)), // keep 'serving', 'piece', etc. if provided
            'label': null,
          });
        }
      }

      // Append serving_size portion if missing (non-100 g)
if (m['serving_size'] is Map) {
  final ss = Map<String, dynamic>.from(m['serving_size'] as Map);
  final amt = (ss['amount'] as num?)?.toDouble();
  final unitRaw = (ss['unit'] as String?)?.toLowerCase();
  final text = (ss['text'] as String?)?.trim();
  final isMl = unitRaw == 'ml' || unitRaw == 'milliliter' || unitRaw == 'milliliters';
  final isGram = unitRaw == 'g' || unitRaw == 'gram' || unitRaw == 'grams';

  bool hasServing = portions.any((p) {
    final name = ((p['measure_name'] as String?) ?? '').toLowerCase();
    final gw = (p['gram_weight'] as num?)?.toDouble();
    final mv = (p['ml_volume'] as num?)?.toDouble();
    final is100g = name.replaceAll(' ', '') == '100g' || gw == 100.0;
    final matchesAmt = isMl ? (mv == amt) : (gw == amt);
    final mentionsText = text != null && name.contains(text.toLowerCase());
    return !is100g && (matchesAmt || mentionsText);
  });

  if (!hasServing && amt != null) {
    portions.insert(0, {
      'measure_name': text ?? '${amt.toString()} ${ss['unit'] ?? ''}'.trim(),
      // ✅ Only set gram_weight when serving unit is grams; otherwise leave null.
      'gram_weight': isMl ? null : (isGram ? amt : null),
      'ml_volume': isMl ? amt : null,
      'is_default': 0,
      'list_kind': 'basis',
      'sort_order': 0,
      'amount': amt,
      // ✅ Preserve the semantic unit instead of forcing 'g'
      'unit': isMl ? 'ml' : (unitRaw ?? (isGram ? 'g' : null)),
      'label': null,
    });
  }
}


            // Re-sequence & ensure exactly one sensible default (prefer non-100g semantic servings)
      for (var idx = 0; idx < portions.length; idx++) {
        portions[idx]['sort_order'] = idx;
      }
      if (portions.isNotEmpty) {
        bool is100g(Map<String, dynamic> p) {
          final name = ((p['measure_name'] as String?) ?? '').toLowerCase().replaceAll(' ', '');
          final gw = (p['gram_weight'] as num?)?.toDouble();
          return name == '100g' || gw == 100.0;
        }
        bool looksSemantic(Map<String, dynamic> p) {
          final name = ((p['measure_name'] as String?) ?? '').toLowerCase();
          final unit = ((p['unit'] as String?) ?? '').toLowerCase();
          const sem = {
            'serving','piece','slice','portion','each','cup','tbsp','tsp','oz',
            'packet','pack','bar','bottle','can'
          };
          final inName = sem.any((s) => name.contains(s));
          final inUnit = sem.contains(unit);
          return inName || inUnit;
        }

        int defaultIdx = portions.indexWhere((p) => p['is_default'] == 1);

        // If there is a default but it's 100 g, move it to a better candidate when possible.
        if (defaultIdx >= 0 && is100g(portions[defaultIdx])) {
          int cand = portions.indexWhere((p) => looksSemantic(p) && !is100g(p));
          if (cand < 0) {
            cand = portions.indexWhere((p) => !is100g(p)); // any non-100 g
          }
          if (cand >= 0) defaultIdx = cand;
        }

        // If none was marked default, choose one now.
        if (defaultIdx < 0) {
          defaultIdx = portions.indexWhere((p) => looksSemantic(p) && !is100g(p));
          if (defaultIdx < 0) {
            defaultIdx = portions.indexWhere((p) => !is100g(p));
          }
          if (defaultIdx < 0) defaultIdx = 0; // last resort
        }

        // Apply exactly one default flag
        for (var k = 0; k < portions.length; k++) {
          portions[k]['is_default'] = (k == defaultIdx) ? 1 : 0;
        }
      }

      // Collect per_100g nutrients (flush in batches later)
      if (m['per_100g'] is Map) {
        final nmap = Map<String, dynamic>.from(m['per_100g'] as Map);
        for (final entry in nmap.entries) {
          final code = entry.key.toString().trim().toUpperCase();
          final val = entry.value;
          if (val == null) continue;
          final amount =
              (val is num) ? val.toDouble() : double.tryParse('$val');
          if (amount == null) continue;
          nutBatch.add(_NutRow(ext, code, amount));
          per100gCount++;
          if (nutBatch.length >= kNutrientBatch) flushNutrientBatch();
        }
      }

      // ── SQL: foods (created_at/updated_at use SQLite date('now'))
      writeLine("""
INSERT INTO foods(
  name, brand, brand_id, category_id, is_custom, verified,
  data_source, data_source_id, source_id, density_g_per_ml, quality_score,
  version, preparation, created_at, updated_at, is_deleted
)
VALUES(
  ${q(name)},
  ${q(brand)},
  ${brand == null ? 'NULL' : "(SELECT id FROM brands WHERE lower(name)=lower(${q(brand)}) LIMIT 1)"},
  ${category == null ? 'NULL' : "(SELECT id FROM categories WHERE lower(name)=lower(${q(category)}) LIMIT 1)"},
  0,
  1,
  ${q(dataSource)},
  ${q(dataSourceId)},
  ${sourceName == null ? 'NULL' : "(SELECT id FROM sources WHERE lower(name)=lower(${q(sourceName)}) LIMIT 1)"},
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

      // portions (per-row to capture mapping reliably)
      int localPortionIdx = 0;
      for (final pmap in portions) {
        localPortionIdx++;
        final pext = '${ext}_p${localPortionIdx.toString().padLeft(3, '0')}';
        writeLine("""
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

      // Safe points to flush (maps exist now)
      if (nutBatch.length >= kNutrientBatch) flushNutrientBatch();
      if (bcBatch.length >= kBarcodeBatch) flushBarcodeBatch();
    }
  }

  // Process all provided JSONL then JSONL.GZ files in-order.
  for (final path in jsonlPaths) {
    processRows(_readJsonl(File(path)));
  }
  for (final path in jsonlGzPaths) {
    processRows(_readJsonlGz(File(path)));
  }

  // final flushes
  flushNutrientBatch();
  flushBarcodeBatch();

  // Normalize to one default portion per food (keep lowest id of claimed defaults)
  writeLine("""
-- Normalize: keep exactly one default portion per food (lowest id among rows that claim default)
CREATE TEMP TABLE IF NOT EXISTS _keep_default_ids(id INTEGER);
DELETE FROM _keep_default_ids;

INSERT INTO _keep_default_ids(id)
SELECT MIN(id)
FROM food_portions
WHERE COALESCE(is_default,0)=1
GROUP BY food_id;

UPDATE food_portions
SET is_default = CASE WHEN id IN (SELECT id FROM _keep_default_ids) THEN 1 ELSE 0 END
WHERE COALESCE(is_default,0)=1;

DROP TABLE IF EXISTS _keep_default_ids;
""");

  // Set foods.default_portion_id where a default exists.
  writeLine("""
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
  writeLine("""
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


  // ── Legacy path: separate JSON files (kept, with batching where safe) ──────
  final foodsPath = p.join(inDir, 'foods.json');
  final portionsPath = p.join(inDir, 'portions.json');
  final per100gPath = p.join(inDir, 'per100g.json');
  final perPortionPath = p.join(inDir, 'per_portion.json');
  final barcodesPath = p.join(inDir, 'barcodes.json');
  final sourcesPath = p.join(inDir, 'sources.json'); // optional
  final aliasesPath = p.join(inDir, 'nutrient_aliases.json'); // optional
  final recipesPath = p.join(inDir, 'recipes.json'); // optional
  final ringsPath = p.join(inDir, 'recipe_ingredients.json'); // optional

  final foods = _loadJsonArray(foodsPath);
  if (foods.isEmpty) {
    stderr.writeln(
        'No foods found at $foodsPath (this file is required unless --jsonl* is provided).');
    exitCode = 2;
    sink.close();
    return;
  }
  final portions = _loadJsonArray(portionsPath);
  final per100g = _loadJsonArray(per100gPath);
  final perPortion = _loadJsonArray(perPortionPath);
  final barcodes = _loadJsonArray(barcodesPath);
  final sources = _loadJsonArray(sourcesPath);
  final aliases = _loadJsonArray(aliasesPath);
  final recipes = _loadJsonArray(recipesPath);
  final rings = _loadJsonArray(ringsPath);

  // Optional sources/aliases
  for (final e in sources) {
    final m = Map<String, dynamic>.from(e as Map);
    final n = (m['name'] as String?)?.trim();
    if (n != null && n.isNotEmpty && seenSources.add(n.toLowerCase())) {
      writeLine("INSERT OR IGNORE INTO sources(name) VALUES (${q(n)});");
    }
  }
  for (final e in aliases) {
    final m = Map<String, dynamic>.from(e as Map);
    writeLine("""
INSERT OR IGNORE INTO nutrient_aliases(nutrient_id, alias)
SELECT id, ${q(m['alias'] as String)} FROM nutrients WHERE code=${q(m['code'] as String)};
""");
  }

  // Foods (with brand/category dictionaries)
  for (final e in foods) {
    final m = Map<String, dynamic>.from(e as Map);
    final ext = m['ext'] as String;
    final name = m['name'] as String;
    final brand = (m['brand'] as String?)?.trim();
    final category = (m['category'] as String?)?.trim();

    if (brand != null &&
        brand.isNotEmpty &&
        seenBrands.add(brand.toLowerCase())) {
      writeLine("INSERT OR IGNORE INTO brands(name) VALUES (${q(brand)});");
    }
    if (category != null &&
        category.isNotEmpty &&
        seenCategories.add(category.toLowerCase())) {
      writeLine("INSERT OR IGNORE INTO categories(name) VALUES (${q(category)});");
    }

    writeLine("""
INSERT INTO foods (
  name, brand, brand_id, category_id, is_custom, verified, data_source, data_source_id,
  density_g_per_ml, quality_score, version, preparation, created_at, updated_at, is_deleted
)
VALUES (
  ${q(name)},
  ${q(brand)},
  ${brand == null ? 'NULL' : "(SELECT id FROM brands WHERE lower(name)=lower(${q(brand)}) LIMIT 1)"},
  ${category == null ? 'NULL' : "(SELECT id FROM categories WHERE lower(name)=lower(${q(category)}) LIMIT 1)"},
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

  // Portions (per-row to capture mapping reliably)
  for (final e in portions) {
    final m = Map<String, dynamic>.from(e as Map);
    final ext = m['ext'] as String;
    final foodExt = m['food_ext'] as String;

    writeLine("""
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

  // per_100g batched (legacy)
  for (final e in per100g) {
    final m = Map<String, dynamic>.from(e as Map);
    final foodExt = m['food_ext'] as String;
    final code = (m['nutrient_code'] as String).trim().toUpperCase();
    final amount = m['amount'] as num;
    nutBatch.add(_NutRow(foodExt, code, amount));
    per100gCount++;
    if (nutBatch.length >= kNutrientBatch) flushNutrientBatch();
  }
  flushNutrientBatch();

  // per_portion (needs portion map)
  for (final e in perPortion) {
    final m = Map<String, dynamic>.from(e as Map);
    final foodExt = m['food_ext'] as String;
    final portionExt = m['portion_ext'] as String;
    final code = (m['nutrient_code'] as String).trim().toUpperCase();
    final amount = (m['amount'] as num).toString();
    writeLine("""
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

  // barcodes batched (legacy)
  for (final e in barcodes) {
    final m = Map<String, dynamic>.from(e as Map);
    final foodExt = m['food_ext'] as String;
    final upc = (m['upc'] as String).replaceAll(RegExp(r'\D'), '');
    if (_isLikelyUpc(upc)) {
      bcBatch.add(_BcRow(foodExt, upc));
      barcodesCount++;
      if (bcBatch.length >= kBarcodeBatch) flushBarcodeBatch();
    }
  }
  flushBarcodeBatch();

  // (Optional) recipes & ingredients (simple passthrough)
  for (final e in recipes) {
    final m = Map<String, dynamic>.from(e as Map);
    writeLine("""
INSERT INTO recipes(name, notes, is_deleted, created_at, updated_at)
VALUES(${q(m['name'] as String)}, ${q(m['notes'] as String?)}, 0, ${q(m['created_at'] as String? ?? '2025-01-01')}, ${q(m['updated_at'] as String? ?? '2025-01-01')});
""");
  }
  for (final e in rings) {
    final m = Map<String, dynamic>.from(e as Map);
    writeLine("""
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
  writeLine("""
-- Normalize: keep exactly one default portion per food (lowest id among rows that claim default)
CREATE TEMP TABLE IF NOT EXISTS _keep_default_ids(id INTEGER);
DELETE FROM _keep_default_ids;

INSERT INTO _keep_default_ids(id)
SELECT MIN(id)
FROM food_portions
WHERE COALESCE(is_default,0)=1
GROUP BY food_id;

UPDATE food_portions
SET is_default = CASE WHEN id IN (SELECT id FROM _keep_default_ids) THEN 1 ELSE 0 END
WHERE COALESCE(is_default,0)=1;

DROP TABLE IF EXISTS _keep_default_ids;
""");

  // Set foods.default_portion_id where a default exists.
  writeLine("""
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
  writeLine("""
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
