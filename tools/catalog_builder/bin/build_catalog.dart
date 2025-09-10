import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:csv/csv.dart';
import 'package:sqlite3/sqlite3.dart';

// Small helpers
String _readText(String path) => File(path).readAsStringSync();
List<List<dynamic>> _readCsv(String path, {bool hasHeader = true}) {
  if (!File(path).existsSync()) return const [];
  final rows = const CsvToListConverter(eol: '\n').convert(_readText(path));
  return hasHeader && rows.isNotEmpty ? rows.skip(1).toList() : rows;
}

Stream<Map<String, dynamic>> _readJsonl(String path) async* {
  if (!File(path).existsSync()) return;
  final f = File(path).openRead();
  await for (final line in f.transform(utf8.decoder).transform(const LineSplitter())) {
    final s = line.trim();
    if (s.isEmpty) continue;
    yield json.decode(s) as Map<String, dynamic>;
  }
}

void main(List<String> args) async {
  final ap = ArgParser()
    ..addOption('schema-sql', defaultsTo: p.normalize(p.join('lib','db','schema_latest.sql')))
    ..addOption('seeds-dir',  defaultsTo: p.normalize(p.join('tools','catalog_builder','seeds')))
    ..addOption('out',        defaultsTo: p.normalize(p.join('assets','db','nutrition_v22.db')))
    ..addOption('user-version', defaultsTo: '22')
    ..addFlag('verbose', defaultsTo: true);

  final a = ap.parse(args);
  final schemaSqlPath = a['schema-sql'] as String;
  final seedsDir = a['seeds-dir'] as String;
  final outPath = a['out'] as String;
  final userVersion = int.parse(a['user-version'] as String);
  final verbose = a['verbose'] as bool;

  // Ensure folders
  Directory(p.dirname(outPath)).createSync(recursive: true);

  // (Re)create DB
  if (File(outPath).existsSync()) File(outPath).deleteSync();
  final db = sqlite3.open(outPath);

  void exec(String sql) { db.execute(sql); }
  void pragma(String k, Object v) => exec('PRAGMA $k=$v;');

  try {
    // Fast build pragmas
    pragma('journal_mode', 'MEMORY');
    pragma('synchronous', 'OFF');
    pragma('temp_store', 2);      // memory
    pragma('page_size', 4096);

    // Schema
    final schemaSql = _readText(schemaSqlPath);
    db.executeBatch(schemaSql);

    // Seed data in one big tx
    db.execute('BEGIN IMMEDIATE;');

    // ---- nutrients
    final nutrientsCsv = _readCsv(p.join(seedsDir, 'nutrients.csv'));
    if (nutrientsCsv.isNotEmpty) {
      final stmt = db.prepare('INSERT OR IGNORE INTO nutrients(code,name,unit) VALUES(?,?,?);');
      for (final r in nutrientsCsv) {
        stmt.execute([r[0], r[1], r[2]]);
      }
      stmt.dispose();
    }

    // ---- nutrient_aliases
    final nAliasesCsv = _readCsv(p.join(seedsDir, 'nutrient_aliases.csv'));
    if (nAliasesCsv.isNotEmpty) {
      final stmt = db.prepare('INSERT OR IGNORE INTO nutrient_aliases(nutrient_id,alias) VALUES(?,?);');
      for (final r in nAliasesCsv) {
        stmt.execute([r[0], r[1]]);
      }
      stmt.dispose();
    }

    // ---- brands (optional)
    final brandsCsv = _readCsv(p.join(seedsDir, 'brands.csv'));
    if (brandsCsv.isNotEmpty) {
      final stmt = db.prepare('INSERT OR IGNORE INTO brands(id,name) VALUES(?,?);');
      for (final r in brandsCsv) {
        stmt.execute([r[0], r[1]]);
      }
      stmt.dispose();
    }

    // ---- sources (seed common sources so foreign keys exist)
    final sourcesCsv = _readCsv(p.join(seedsDir, 'sources.csv'));
    if (sourcesCsv.isNotEmpty) {
      final stmt = db.prepare('INSERT OR IGNORE INTO sources(id,name) VALUES(?,?);');
      for (final r in sourcesCsv) {
        stmt.execute([r[0], r[1]]);
      }
      stmt.dispose();
    }

    // ---- categories (optional)
    final categoriesCsv = _readCsv(p.join(seedsDir, 'categories.csv'));
    if (categoriesCsv.isNotEmpty) {
      final stmt = db.prepare('INSERT OR IGNORE INTO categories(id,name) VALUES(?,?);');
      for (final r in categoriesCsv) {
        stmt.execute([r[0], r[1]]);
      }
      stmt.dispose();
    }

    // ---- foods (JSONL, one per line)
    final insFood = db.prepare('''
      INSERT OR REPLACE INTO foods(
        id, name, brand, brand_id, category_id, source_id,
        data_source, data_source_id, density_g_per_ml,
        is_custom, is_deleted, verified, quality_score, version, preparation,
        created_at, updated_at
      ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);
    ''');
    await for (final m in _readJsonl(p.join(seedsDir, 'foods.jsonl'))) {
      // assume your lines already normalized; keep NULLs where absent
      insFood.execute([
        m['id'],
        m['name'],
        m['brand'],
        m['brand_id'],
        m['category_id'],
        m['source_id'],
        m['data_source'],
        m['data_source_id'],
        m['density_g_per_ml'],
        m['is_custom'] ?? 0,
        m['is_deleted'] ?? 0,
        m['verified'],
        m['quality_score'],
        m['version'],
        m['preparation'],
        m['created_at'] ?? DateTime.now().toIso8601String(),
        m['updated_at'] ?? DateTime.now().toIso8601String(),
      ]);
    }
    insFood.dispose();

    // ---- portions (JSONL)
    final insPort = db.prepare('''
      INSERT OR REPLACE INTO food_portions(
        id, food_id, measure_name, gram_weight, ml_volume,
        is_default, list_kind, sort_order, amount, unit, label
      ) VALUES (?,?,?,?,?,?,?,?,?,?,?);
    ''');
    await for (final m in _readJsonl(p.join(seedsDir, 'portions.jsonl'))) {
      insPort.execute([
        m['id'],
        m['food_id'],
        m['measure_name'],
        m['gram_weight'],
        m['ml_volume'],
        m['is_default'] ?? 0,
        m['list_kind'],
        m['sort_order'],
        m['amount'],
        m['unit'],
        m['label'],
      ]);
    }
    insPort.dispose();

    // ---- food_nutrient_values (JSONL)  (per_100g preferred; you can include per_portion/per_100ml too)
    final insFNV = db.prepare('''
      INSERT OR REPLACE INTO food_nutrient_values(
        food_id, nutrient_id, amount, basis, portion_id
      ) VALUES (?,?,?,?,?);
    ''');
    await for (final m in _readJsonl(p.join(seedsDir, 'food_nutrient_values.jsonl'))) {
      insFNV.execute([
        m['food_id'],
        m['nutrient_id'],
        m['amount'],
        m['basis'] ?? 'per_100g',
        m['portion_id'],
      ]);
    }
    insFNV.dispose();

    // ---- legacy mirror (optional but keeps back-compat)
    final fnCsv = _readCsv(p.join(seedsDir, 'food_nutrients_legacy.csv'));
    if (fnCsv.isNotEmpty) {
      final stmt = db.prepare('INSERT OR REPLACE INTO food_nutrients(food_id,nutrient_id,amount_per_100g) VALUES(?,?,?);');
      for (final r in fnCsv) {
        stmt.execute([r[0], r[1], r[2]]);
      }
      stmt.dispose();
    }

    // ---- barcodes
    final bCsv = _readCsv(p.join(seedsDir, 'barcodes.csv'));
    if (bCsv.isNotEmpty) {
      final stmt = db.prepare('INSERT OR IGNORE INTO food_barcodes(food_id, upc) VALUES(?,?);');
      for (final r in bCsv) {
        // expect UPC/EAN digits-only string in r[1]
        stmt.execute([r[0], r[1]]);
      }
      stmt.dispose();
    }

    // app metadata
    db.execute("CREATE TABLE IF NOT EXISTS app_metadata (k TEXT PRIMARY KEY, v TEXT);");
    final nowIso = DateTime.now().toIso8601String();
    db.execute("INSERT OR REPLACE INTO app_metadata(k,v) VALUES('catalog_built_at', ?);", [nowIso]);

    db.execute('COMMIT;');

    // Rebuild FTS (once, at the end)
    try {
      db.execute("INSERT INTO food_search_fts(food_search_fts) VALUES('rebuild');");
    } catch (_) {/* FTS table absent? then you probably didn’t include it in schema_latest.sql */}

    // Normal mode pragmas for runtime
    pragma('journal_mode', 'DELETE');  // shrink size on disk
    pragma('synchronous', 'NORMAL');   // your app will set WAL+NORMAL when opening

    // user_version must match openDatabase(... version: X)
    pragma('user_version', userVersion);

    // Optimize & compact
    exec('PRAGMA optimize;');
    exec('VACUUM;');

    if (verbose) {
      final cFoods = db.select('SELECT COUNT(*) AS n FROM foods;').first['n'];
      final cPorts = db.select('SELECT COUNT(*) AS n FROM food_portions;').first['n'];
      final cNutr  = db.select('SELECT COUNT(*) AS n FROM food_nutrient_values;').first['n'];
      stdout.writeln('Built $outPath  foods=$cFoods portions=$cPorts fnv=$cNutr');
    }
  } finally {
    db.dispose();
  }
}
