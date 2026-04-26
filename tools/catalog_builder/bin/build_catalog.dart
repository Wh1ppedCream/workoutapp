// file: tools/catalog_builder/bin/build_catalog.dart
//
// Orchestrator:
//   1) tools/catalog_builder/tool/generate_seed_sql.dart  -> seed_catalog.sql
//   2) tools/catalog_builder/tool/build_food_db.dart      -> app_nutrition.db
//   3) Optional summary + integrity checks (CI-friendly)
//
// Examples:
// dart run tools/catalog_builder/bin/build_catalog.dart \
//   --schema lib/db/schema_latest.sql \
//   --jsonl-gz tools/catalog_builder/jsonl/foods.min.jsonl.gz \
//   --out build/app_nutrition.db --page-size 4096 --turbo \
//   --min-foods 1 --assert-fts --expect-user-version 22
//

import 'dart:ffi';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sq;
import 'package:sqlite3/open.dart' as sq_open;

Future<ProcessResult> _run(
  String exec,
  List<String> args, {
  String? cwd,
  bool verbose = true,
}) {
  if (verbose) {
    final where = cwd == null ? '' : ' (cwd=$cwd)';
    stdout.writeln('> $exec ${args.join(' ')}$where');
  }
  return Process.run(exec, args, workingDirectory: cwd);
}

Never _fail(String msg, {int code = 2}) {
  stderr.writeln(msg);
  exit(code);
}

/// Optional: allow Windows devs to point at a local sqlite3.dll for the summary step.
void _ensureSqlite3LoadedForSummary() {
  if (Platform.isWindows) {
    final dllPath = Platform.environment['SQLITE3_DLL_PATH'];
    if (dllPath != null && dllPath.isNotEmpty) {
      sq_open.open.overrideFor(sq_open.OperatingSystem.windows, () {
        return DynamicLibrary.open(dllPath);
      });
    }
  }
}

void main(List<String> argv) async {
  final ap = ArgParser()
    ..addOption('schema',
        abbr: 's',
        help: 'Path to schema_latest.sql',
        defaultsTo: p.normalize(p.join('lib', 'db', 'schema_latest.sql')))
    ..addOption('in',
        help: 'Input directory with JSON seed files (legacy path)',
        defaultsTo: p.normalize(p.join('tools', 'catalog_builder', 'json')))
    ..addMultiOption('jsonl',
        help: 'Path(s) to foods JSONL file(s) (one JSON object per line). Optional.')
    ..addMultiOption('jsonl-gz',
        help: 'Path(s) to gzipped JSONL file(s). Optional.')
    ..addOption('out',
        abbr: 'o',
        help: 'Output SQLite DB path',
        defaultsTo: p.normalize(p.join('build', 'app_nutrition.db')))
    ..addOption('page-size',
        help: 'Desired page size (power of two 512..65536). Set BEFORE writes.',
        defaultsTo: '4096')
    ..addFlag('turbo',
        abbr: 'T',
        help:
            'Use fast PRAGMAs during build; builder restores safe defaults after.',
        defaultsTo: true)
    ..addOption('cache-mb',
        help: 'Pass-through: cache size in MB for builder turbo mode.',
        defaultsTo: '800')
    ..addOption('mmap-mb',
        help: 'Pass-through: MMAP size in MB for builder turbo mode (0=off).',
        defaultsTo: '256')
    ..addFlag('vacuum',
        help: 'Request a final VACUUM at end of build (slow; usually unnecessary).',
        defaultsTo: false)
    ..addOption('seed-sql',
        help: 'Where to write the generated SQL seeds.',
        defaultsTo: p.normalize(
            p.join('tools', 'catalog_builder', 'data', 'seed_catalog.sql')))
    ..addMultiOption('extra-sql',
        help: 'Additional SQL files to apply after the seed (0..N).',
        valueHelp: 'patch.sql')
    ..addFlag('verbose',
        abbr: 'v', help: 'Print progress along the way', defaultsTo: true)
    // --- CI/quality gates ---
    ..addFlag('no-summary',
        help: 'Skip opening the output DB for summary/integrity checks.',
        defaultsTo: false)
    ..addOption('min-foods',
        help: 'Fail if foods table has fewer than this count.',
        defaultsTo: '1')
    ..addFlag('assert-fts',
        help: 'Fail if food_search_fts is empty.', defaultsTo: false)
    ..addOption('expect-user-version',
        help: 'Fail if PRAGMA user_version does not equal this value.',
        defaultsTo: '22')
    ..addOption('cwd',
        help: 'Run the dart subcommands from this directory (optional).');

  final a = ap.parse(argv);

  final schema = p.normalize(a['schema'] as String);
  final inDir = p.normalize(a['in'] as String);
  final jsonlList = (a['jsonl'] as List<String>? ?? const <String>[]);
  final jsonlGzList = (a['jsonl-gz'] as List<String>? ?? const <String>[]);
  final outDb = p.normalize(a['out'] as String);
  final pageSize = a['page-size'] as String;
  final turbo = a['turbo'] as bool;
  final verbose = a['verbose'] as bool;
  final seedSql = p.normalize(a['seed-sql'] as String);
  final noSummary = a['no-summary'] as bool;
  final minFoods = int.tryParse(a['min-foods'] as String) ?? 1;
  final assertFts = a['assert-fts'] as bool;
  final expectUserVersion =
      int.tryParse(a['expect-user-version'] as String) ?? 22;
  final rawCwd = (a['cwd'] as String?)?.trim();
  final runCwd = (rawCwd == null || rawCwd.isEmpty) ? null : p.normalize(rawCwd);
  final cacheMb = a['cache-mb'] as String;
  final mmapMb = a['mmap-mb'] as String;
  final doVacuum = a['vacuum'] as bool;
  final extraSql =
      (a['extra-sql'] as List<String>?)?.map(p.normalize).toList() ?? const <String>[];

  

  // Early input check: if neither jsonl* provided, ensure legacy input dir exists
  final dirExists = Directory(inDir).existsSync();
  final noJsonlProvided = jsonlList.isEmpty && jsonlGzList.isEmpty;
  if (noJsonlProvided && !dirExists) {
    _fail('No --jsonl/--jsonl-gz provided and input dir does not exist: $inDir');
  }

  // Ensure output folders exist
  Directory(p.dirname(outDb)).createSync(recursive: true);
  Directory(p.dirname(seedSql)).createSync(recursive: true);

  // Validate extra SQL files (if any)
  for (final x in extraSql) {
    if (!File(x).existsSync()) {
      _fail('Extra SQL not found: $x');
    }
  }

  // 1) Generate seeds
  final genArgs = <String>[
    'run',
    p.join('tools', 'catalog_builder', 'tool', 'generate_seed_sql.dart'),
    '--in',
    inDir,
    '--out',
    seedSql,
  ];
  for (final p in jsonlList) {
    genArgs..add('--jsonl')..add(p);
  }
  for (final p in jsonlGzList) {
    genArgs..add('--jsonl-gz')..add(p);
  }

  final res1 = await _run('dart', genArgs, cwd: runCwd, verbose: verbose);
  if (res1.exitCode != 0) {
    if (verbose) {
      final so = res1.stdout.toString();
      final se = res1.stderr.toString();
      if (so.isNotEmpty) stdout.write(so);
      if (se.isNotEmpty) stderr.write(se);
    }
    _fail('Seed generation failed (exit ${res1.exitCode}). See logs above.');
  } else if (verbose) {
    final so = res1.stdout.toString();
    if (so.isNotEmpty) stdout.write(so);
  }

  // Sanity: ensure seed file exists & not empty
  final seedFile = File(seedSql);
  if (!seedFile.existsSync() || seedFile.lengthSync() == 0) {
    _fail('Generated seed SQL missing or empty at $seedSql');
  } else if (verbose) {
    final sz = (seedFile.lengthSync() / (1024 * 1024)).toStringAsFixed(2);
    stdout.writeln('  seed size: $sz MB');
  }

  // 2) Build DB
  final buildArgs = <String>[
    'run',
    p.join('tools', 'catalog_builder', 'tool', 'build_food_db.dart'),
    '--schema', schema,
    '--import-sql', seedSql,
    ...extraSql.expand((e) => ['--import-sql', e]),
    '--page-size', pageSize,
    '--out', outDb,
    '--cache-mb', cacheMb,
    '--mmap-mb', mmapMb,
  ];
  if (turbo) buildArgs.add('--turbo');
  if (doVacuum) buildArgs.add('--vacuum');
  if (verbose) {
    buildArgs.add('--verbose');
  } else {
    buildArgs.add('--no-verbose');
  }

  final res2 = await _run('dart', buildArgs, cwd: runCwd, verbose: verbose);
  if (res2.exitCode != 0) {
    if (verbose) {
      final so = res2.stdout.toString();
      final se = res2.stderr.toString();
      if (so.isNotEmpty) stdout.write(so);
      if (se.isNotEmpty) stderr.write(se);
    }
    _fail('DB build failed (exit ${res2.exitCode}). See logs above.');
  } else {
    final so = res2.stdout.toString();
    if (so.isNotEmpty) stdout.write(so);
  }

  if (noSummary) {
    stdout.writeln('✔ Build complete: $outDb (summary skipped by --no-summary)');
    return;
  }

  // 3) Summary + integrity checks (CI friendly)
  try {
    _ensureSqlite3LoadedForSummary();
    final db = sq.sqlite3.open(outDb);

    final ver = db.select('PRAGMA user_version;').first.values.first as int;
    final ps = db.select('PRAGMA page_size;').first.values.first;

    final nFoods =
        db.select('SELECT COUNT(*) AS n FROM foods;').first['n'] as int;

    final hasFts = db
        .select(
          "SELECT 1 FROM sqlite_master WHERE type='table' AND name='food_search_fts' LIMIT 1;")
        .isNotEmpty;

    final nFts = hasFts
        ? db.select('SELECT COUNT(*) AS n FROM food_search_fts;').first['n'] as int
        : 0;

    final ic =
        db.select('PRAGMA integrity_check;').first.values.first as String;
    if (ic.toLowerCase() != 'ok') {
      db.dispose();
      _fail('integrity_check failed: $ic');
    }
    final fkRows = db.select('PRAGMA foreign_key_check;');
    if (fkRows.isNotEmpty) {
      db.dispose();
      _fail('foreign_key_check failed: ${fkRows.length} issues');
    }

    if (ver != expectUserVersion) {
      db.dispose();
      _fail('user_version $ver ≠ expected $expectUserVersion');
    }
    if (nFoods < minFoods) {
      db.dispose();
      _fail('foods count $nFoods < required min $minFoods');
    }
    if (assertFts && (!hasFts || nFts <= 0)) {
      db.dispose();
      _fail(hasFts
          ? 'FTS appears empty (food_search_fts has 0 rows)'
          : 'FTS table missing (food_search_fts not found)');
    }

    final sample = db.select(
      "SELECT id, name, COALESCE(brand, '') AS brand FROM foods WHERE is_deleted=0 LIMIT 3;"
    );
    db.dispose();

    final sizeBytes = File(outDb).lengthSync();
    stdout.writeln('✔ Build complete: $outDb');
    stdout.writeln(
        '  user_version=$ver  page_size=$ps  size=${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB');
    stdout.writeln('  foods=$nFoods  fts_rows=$nFts  integrity=ok  fks=ok');
    if (sample.isNotEmpty) {
      stdout.writeln('  sample: ${sample.map((r)=>"${r['id']}:${r['name']} (${r['brand']})").join(" | ")}');
    }
  } catch (e) {
    // Non-fatal: still provide path
    stdout.writeln('✔ Build complete: $outDb (summary unavailable: $e)');
  }
}
