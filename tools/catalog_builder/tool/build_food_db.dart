// tool/build_food_db.dart
import 'dart:ffi';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sq;
import 'package:sqlite3/open.dart' as sq_open;

/// Keep this in sync with your app's schema version (PRAGMA user_version)
const int kSchemaUserVersion = 22;

/// On Windows, load sqlite3.dll via env var SQLITE3_DLL_PATH if present.
void _ensureSqlite3Loaded() {
  if (Platform.isWindows) {
    final dllPath = Platform.environment['SQLITE3_DLL_PATH'];
    if (dllPath != null && dllPath.isNotEmpty) {
      sq_open.open.overrideFor(sq_open.OperatingSystem.windows, () {
        return DynamicLibrary.open(dllPath);
      });
    }
  }
}

void _fail(String message, {int code = 2}) {
  stderr.writeln(message);
  exit(code);
}

bool _isValidPageSize(int v) =>
    const {512, 1024, 2048, 4096, 8192, 16384, 32768, 65536}.contains(v);

void _applyTurboPragmas(sq.Database db) {
  db.execute('PRAGMA journal_mode=MEMORY;');
  db.execute('PRAGMA synchronous=OFF;');
  db.execute('PRAGMA temp_store=MEMORY;');
  db.execute('PRAGMA cache_size=-200000;'); // ~200MB if available
  db.execute('PRAGMA locking_mode=EXCLUSIVE;');
  db.execute('PRAGMA foreign_keys=OFF;');   // re-enable later
}

void _restoreSafePragmas(sq.Database db) {
  db.execute('PRAGMA foreign_keys=ON;');
  db.execute('PRAGMA journal_mode=DELETE;');
  db.execute('PRAGMA synchronous=NORMAL;');
}

/// Remove FTS and its triggers so they don't fire during bulk import.
void _dropFtsAndTriggers(sq.Database db, {bool verbose = true}) {
  if (verbose) stdout.writeln('> Disabling FTS (drop triggers & table) …');
  db.execute('DROP TRIGGER IF EXISTS foods_ai;');
  db.execute('DROP TRIGGER IF EXISTS foods_ad;');
  db.execute('DROP TRIGGER IF EXISTS foods_au;');
  db.execute('DROP TABLE   IF EXISTS food_search_fts;');
}

/// Recreate FTS (contentless FTS4) + triggers, then bulk-fill it.
void _rebuildFtsAndTriggers(sq.Database db, {bool verbose = true}) {
  if (verbose) stdout.writeln('> Rebuilding FTS in one pass …');

  // contentless FTS keeps things simple & works on all SQLite builds.
  db.execute('''
    CREATE VIRTUAL TABLE IF NOT EXISTS food_search_fts USING fts4(
      name,
      brand,
      tokenize=unicode61
    );
  ''');

  db.execute('BEGIN;');
  db.execute('''
    INSERT INTO food_search_fts(rowid, name, brand)
    SELECT id, name, COALESCE(brand,'')
    FROM foods
    WHERE is_deleted = 0;
  ''');
  db.execute('COMMIT;');

  // Recreate sync triggers for future app edits.
  db.execute('''
    CREATE TRIGGER IF NOT EXISTS foods_ai
    AFTER INSERT ON foods
    BEGIN
      INSERT INTO food_search_fts(rowid, name, brand)
      VALUES (NEW.id, NEW.name, COALESCE(NEW.brand,''));
    END;
  ''');

  db.execute('''
    CREATE TRIGGER IF NOT EXISTS foods_ad
    AFTER DELETE ON foods
    BEGIN
      DELETE FROM food_search_fts WHERE rowid = OLD.id;
    END;
  ''');

  db.execute('''
    CREATE TRIGGER IF NOT EXISTS foods_au
    AFTER UPDATE ON foods
    BEGIN
      DELETE FROM food_search_fts WHERE rowid = OLD.id;
      INSERT INTO food_search_fts(rowid, name, brand)
      VALUES (NEW.id, NEW.name, COALESCE(NEW.brand,''));
    END;
  ''');
}

/// Capture all explicit CREATE INDEX ddls (not autoindexes), drop them, and return ddls.
List<String> _captureAndDropIndexes(sq.Database db, {bool verbose = true}) {
  final rows = db.select('''
    SELECT name, sql FROM sqlite_master
    WHERE type='index'
      AND sql IS NOT NULL
      AND name NOT LIKE 'sqlite_%'
      AND name NOT LIKE 'food_search_fts%' -- FTS shadows handled elsewhere
    ORDER BY name;
  ''');

  final ddls = <String>[];
  for (final r in rows) {
    final name = r['name'] as String;
    final sql = r['sql'] as String;
    ddls.add(sql); // we'll run this later to recreate
    db.execute('DROP INDEX IF EXISTS "$name";');
  }
  if (verbose) stdout.writeln('> Dropped ${ddls.length} secondary indexes …');
  return ddls;
}

void _recreateIndexes(sq.Database db, List<String> ddls, {bool verbose = true}) {
  if (ddls.isEmpty) return;
  if (verbose) stdout.writeln('> Recreating ${ddls.length} secondary indexes …');
  db.execute('BEGIN;');
  for (final sql in ddls) {
    db.execute(sql);
  }
  db.execute('COMMIT;');
}

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('schema',
        abbr: 's', help: 'Path to schema_latest.sql', mandatory: true)
    ..addOption('out',
        abbr: 'o', help: 'Output db path', defaultsTo: 'build/app_nutrition.db')
    ..addFlag('verbose', abbr: 'v', defaultsTo: true)
    ..addMultiOption('import-sql',
        help: 'Path(s) to additional SQL with INSERTs (no BEGIN/COMMIT).',
        valueHelp: 'file.sql')
    ..addFlag('turbo',
        abbr: 'T',
        help: 'Use fast PRAGMAs during build (MEMORY journal, sync OFF, etc.)',
        defaultsTo: false)
    ..addOption('page-size',
        help: 'Final page size (power of two 512..65536). Applied on VACUUM.',
        defaultsTo: '4096');

  final a = parser.parse(args);

  final schemaPath = p.normalize(a['schema'] as String);
  final outPath = p.normalize(a['out'] as String);
  final verbose = a['verbose'] as bool;
  final importSql = (a['import-sql'] as List<String>?) ?? const <String>[];
  final turbo = a['turbo'] as bool;

  int pageSize;
  try {
    pageSize = int.parse(a['page-size'] as String);
  } catch (_) {
    pageSize = 4096;
  }
  if (!_isValidPageSize(pageSize)) {
    if (verbose) {
      stdout.writeln('> Warning: invalid --page-size; using 4096');
    }
    pageSize = 4096;
  }

  if (!File(schemaPath).existsSync()) _fail('Schema not found: $schemaPath');
  for (final f in importSql) {
    if (!File(f).existsSync()) _fail('Import SQL not found: $f');
  }

  Directory(p.dirname(outPath)).createSync(recursive: true);
  if (File(outPath).existsSync()) File(outPath).deleteSync();

  _ensureSqlite3Loaded();
  final db = sq.sqlite3.open(outPath);

  try {
    if (verbose) stdout.writeln('> Opened: $outPath   -${p.basenameWithoutExtension(outPath).hashCode.toRadixString(16)}');

    if (turbo) {
      if (verbose) stdout.writeln('> Turbo mode: enabling fast PRAGMAs …');
      _applyTurboPragmas(db);
    } else {
      db.execute('PRAGMA foreign_keys=ON;');
      db.execute('PRAGMA synchronous=NORMAL;');
    }

    // 1) schema
    final schemaSql = File(schemaPath).readAsStringSync();
    if (verbose) stdout.writeln('> Applying schema from $schemaPath …');
    db.execute(schemaSql);

    // 2) nuke FTS & triggers (schema may have created them)
    _dropFtsAndTriggers(db, verbose: verbose);

    // 2b) capture & drop secondary indexes to speed up inserts
    final droppedIndexDdls = _captureAndDropIndexes(db, verbose: verbose);

    // 3) tiny core seeds
    if (verbose) stdout.writeln('> Seeding core nutrients …');
    db.execute('BEGIN;');
    db.execute('''
      INSERT OR IGNORE INTO nutrients(code, name, unit) VALUES
        ('KCAL','Calories','kcal'),
        ('PROTEIN_G','Protein','g'),
        ('CARB_G','Carbohydrate','g'),
        ('FAT_G','Fat','g'),
        ('FIBER_G','Fiber','g'),
        ('SUGARS_TOTAL_G','Sugars, total','g'),
        ('FA_SAT_G','Saturated fat','g'),
        ('SODIUM_MG','Sodium','mg');
    ''');
    db.execute("INSERT OR IGNORE INTO sources(name) VALUES('user');");
    db.execute('COMMIT;');

    // 4) bulk import (fast, with no FTS triggers / no secondary indexes)
    final sw = Stopwatch()..start();
    if (importSql.isNotEmpty) {
      for (var i = 0; i < importSql.length; i++) {
        final path = p.normalize(importSql[i]);
        final sql = File(path).readAsStringSync();
        if (verbose) stdout.writeln('> Importing SQL from $path …');
        final sp = 'imp_$i';
        db.execute('SAVEPOINT $sp;');
        try {
          db.execute(sql);
          db.execute('RELEASE $sp;');
        } catch (e) {
          db.execute('ROLLBACK TO $sp;');
          rethrow;
        }
      }
    }
    final tImport = sw.elapsed;

    // 5) rebuild FTS once
    _rebuildFtsAndTriggers(db, verbose: verbose);
    final tFts = sw.elapsed - tImport;

    // 5b) recreate secondary indexes after data is in
    _recreateIndexes(db, droppedIndexDdls, verbose: verbose);
    final tIdx = sw.elapsed - tImport - tFts;

    // 6) finish & compact
    db.execute('PRAGMA user_version = $kSchemaUserVersion;');
    db.execute('ANALYZE;');
    db.execute('PRAGMA page_size = $pageSize;'); // applied on VACUUM
    db.execute('VACUUM;');
    _restoreSafePragmas(db);
    db.execute('PRAGMA optimize;');

    if (verbose) {
      final ver = db.select('PRAGMA user_version;').first.values.first;
      final ps = db.select('PRAGMA page_size;').first.values.first;
      final jm = db.select('PRAGMA journal_mode;').first.values.first;
      final tables = db
          .select("SELECT name FROM sqlite_master WHERE type='table' ORDER BY 1;")
          .map((r) => r['name'])
          .join(', ');
      stdout.writeln('> Done. user_version=$ver');
      stdout.writeln('> Page size: $ps  • Journal mode: $jm');
      stdout.writeln('> Tables: $tables');
      stdout.writeln('> Timing: import=${tImport.inMilliseconds}ms  fts=${tFts.inMilliseconds}ms  indexes=${tIdx.inMilliseconds}ms');
      stdout.writeln('> Output DB: $outPath');
    }
  } finally {
    db.dispose();
  }
}
