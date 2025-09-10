import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

String q(String? s) {
  if (s == null) return 'NULL';
  // escape single quotes by doubling them
  return "'${s.replaceAll("'", "''")}'";
}

String qNum(num? n) => n == null ? 'NULL' : n.toString();
String qBool(dynamic v) {
  if (v == null) return 'NULL';
  if (v is num) return v == 0 ? '0' : '1';
  if (v is bool) return v ? '1' : '0';
  return (v.toString().trim().toLowerCase() == 'true' || v.toString().trim() == '1') ? '1' : '0';
}

List<dynamic> _loadJsonArray(String path) {
  final f = File(path);
  if (!f.existsSync()) return const [];
  final txt = f.readAsStringSync();
  final data = json.decode(txt);
  if (data is List) return data;
  throw StateError('Expected JSON array in $path');
}

void main(List<String> argv) {
  final ap = ArgParser()
    ..addOption('in',
        help: 'Input directory containing JSON files',
        valueHelp: 'tools/catalog_builder/json',
        defaultsTo: 'tools/catalog_builder/json')
    ..addOption('out',
        help: 'Output SQL file',
        valueHelp: 'tools/catalog_builder/data/seed_catalog.sql',
        defaultsTo: 'tools/catalog_builder/data/seed_catalog.sql');

  final args = ap.parse(argv);
  final inDir = args['in'] as String;
  final outPath = args['out'] as String;

  final foodsPath        = p.join(inDir, 'foods.json');
  final portionsPath     = p.join(inDir, 'portions.json');
  final per100gPath      = p.join(inDir, 'per100g.json');
  final perPortionPath   = p.join(inDir, 'per_portion.json');
  final barcodesPath     = p.join(inDir, 'barcodes.json');

  final foods     = _loadJsonArray(foodsPath);
  if (foods.isEmpty) {
    stderr.writeln('No foods found at $foodsPath (this file is required).');
    exitCode = 2;
    return;
  }
  final portions  = _loadJsonArray(portionsPath);
  final per100g   = _loadJsonArray(per100gPath);
  final perPortion= _loadJsonArray(perPortionPath);
  final barcodes  = _loadJsonArray(barcodesPath);

  final outFile = File(outPath);
  outFile.createSync(recursive: true);
  final sink = outFile.openWrite();

  // We do NOT emit BEGIN/COMMIT here — the builder wraps in one transaction.

  // temp mapping tables to resolve ext -> ids
  sink.writeln("CREATE TEMP TABLE IF NOT EXISTS _import_food_map (ext TEXT PRIMARY KEY, food_id INTEGER NOT NULL);");
  sink.writeln("CREATE TEMP TABLE IF NOT EXISTS _import_portion_map (ext TEXT PRIMARY KEY, portion_id INTEGER NOT NULL);");

  // 1) Foods (+ brands/categories inline)
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
  }

  // 2) Portions
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
  ${qBool(m['is_default'])},
  ${q(m['list_kind'] as String?)},
  ${qNum(m['sort_order'] as num?)},
  ${qNum(m['amount'] as num?)},
  ${q(m['unit'] as String?)},
  ${q(m['label'] as String?)};
INSERT INTO _import_portion_map(ext, portion_id) VALUES (${q(ext)}, last_insert_rowid());
""");
  }

  // 3) Nutrients per 100 g/ml
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
  NULL;
""");
  }

  // 4) Nutrients per portion
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
  (SELECT portion_id FROM _import_portion_map WHERE ext=${q(portionExt)});
""");
  }

  // 5) Barcodes
  for (final e in barcodes) {
    final m = Map<String, dynamic>.from(e as Map);
    final foodExt = m['food_ext'] as String;
    final upc = m['upc'] as String;
    sink.writeln("""
INSERT OR IGNORE INTO food_barcodes(food_id, upc)
SELECT (SELECT food_id FROM _import_food_map WHERE ext=${q(foodExt)}), ${q(upc)};
""");
  }

  // done
  sink.close();
  stdout.writeln('> Wrote ${p.normalize(outPath)} '
      '(foods=${foods.length}, portions=${portions.length}, '
      'per100g=${per100g.length}, per_portion=${perPortion.length}, barcodes=${barcodes.length})');
}
