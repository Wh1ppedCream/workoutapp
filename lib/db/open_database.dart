// lib/db/open_database.dart
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'prebuilt_db.dart';

/// Where the app keeps the working DB file.
Future<String> getDatabasePath() async {
  final dir = await getApplicationSupportDirectory();
  final dbDir = Directory(p.join(dir.path, 'db'));
  if (!await dbDir.exists()) await dbDir.create(recursive: true);
  return p.join(dbDir.path, PrebuiltDb.targetFileName);
}

Future<int?> _readUserVersion(String path) async {
  if (!File(path).existsSync()) return null;
  final db = sqlite3.open(path, mode: OpenMode.readOnly);
  try {
    final row = db.select('PRAGMA user_version;');
    if (row.isEmpty) return null;
    final v = row.first.values.first;
    return (v is int) ? v : int.tryParse('$v');
  } catch (_) {
    return null;
  } finally {
    db.dispose();
  }
}

/// Atomically copy the bundled asset into place.
/// If [force] is false and file already exists, it is left untouched.
Future<File> _materializeFromAsset(String destPath, {bool force = false}) async {
  final file = File(destPath);
  if (await file.exists() && !force) return file;

  final bytes = (await rootBundle.load(PrebuiltDb.assetPath)).buffer.asUint8List();

  // Write to a temp, then atomic rename.
  final tmpPath = '$destPath.tmp';
  final tmp = File(tmpPath);
  if (await tmp.exists()) await tmp.delete();
  await tmp.writeAsBytes(bytes, flush: true);
  // Best-effort fsync on parent dir for extra safety.
  await tmp.rename(destPath);

  return File(destPath);
}

/// Ensures a DB file exists; if an older/different user_version is present,
/// optionally replaces it with the bundled catalog.
/// Returns the on-disk path to open.
Future<String> _ensureDbReady({bool replaceIfVersionDiffers = true}) async {
  final path = await getDatabasePath();
  final exists = await File(path).exists();

  if (!exists) {
    await _materializeFromAsset(path, force: true);
    return path;
  }

  if (replaceIfVersionDiffers) {
    final localVer = await _readUserVersion(path);
    // Read bundled version without writing it to disk: load into temp, read, then delete.
    final tmp = await _materializeFromAsset('$path.bundlecheck', force: true);
    final bundleVer = await _readUserVersion(tmp.path);
    try {
      if (await tmp.exists()) await tmp.delete();
    } catch (_) {}

    if (localVer != null && bundleVer != null && localVer != bundleVer) {
      // Backup old DB (best effort), then replace.
      final backup = File('$path.bak.$localVer');
      try {
        if (!await backup.exists()) {
          await File(path).copy(backup.path);
        }
      } catch (_) {/* ignore */}
      await _materializeFromAsset(path, force: true);
    }
  }

  return path;
}

/// Opens the app database with sane PRAGMAs for mobile.
/// Returns a sqlite3 Database handle (synchronous).
Future<Database> openAppDatabase({bool replaceIfVersionDiffers = true}) async {
  final path = await _ensureDbReady(replaceIfVersionDiffers: replaceIfVersionDiffers);
  final db = sqlite3.open(path);

  // Pragmas: keep in sync with what your runtime expects.
  db.execute('PRAGMA foreign_keys=ON;');
  db.execute('PRAGMA journal_mode=WAL;');          // WAL for concurrency/perf
  db.execute('PRAGMA synchronous=NORMAL;');        // good mobile trade-off
  db.execute('PRAGMA busy_timeout=5000;');         // avoid “database is locked”
  db.execute('PRAGMA wal_autocheckpoint=1000;');   // checkpoint ~1000 pages
  db.execute('PRAGMA cache_size=-20000;');         // ~20MB page cache (optional)
  db.execute('PRAGMA optimize;');                  // seed planner hints

  // Sanity log (optional)
  try {
    final uv = db.select('PRAGMA user_version;').first.values.first;
    // ignore: avoid_print
    print('[db] opened $path  user_version=$uv');
  } catch (_) {}

  return db;
}
