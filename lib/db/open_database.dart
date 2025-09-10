import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'prebuilt_db.dart';

Future<String> _dbPath() async {
  final dir = await getApplicationSupportDirectory();
  final dbDir = Directory(p.join(dir.path, 'db'));
  if (!await dbDir.exists()) await dbDir.create(recursive: true);
  return p.join(dbDir.path, PrebuiltDb.targetFileName);
}

Future<File> _ensureDbMaterialized() async {
  final path = await _dbPath();
  final file = File(path);
  if (await file.exists()) return file;

  final bytes = (await rootBundle.load(PrebuiltDb.assetPath)).buffer.asUint8List();
  await file.writeAsBytes(bytes, flush: true);

  // Optional sanity check
  final db = sqlite3.open(path);
  try {
    final uv = db.select('PRAGMA user_version;').first.values.first as int;
    if (uv != PrebuiltDb.schemaUserVersion) {
      // ignore: avoid_print
      print('WARN: bundled DB user_version=$uv, expected=${PrebuiltDb.schemaUserVersion}');
    }
  } finally {
    db.dispose();
  }
  return file;
}

Future<Database> openAppDatabase() async {
  final file = await _ensureDbMaterialized();
  final db = sqlite3.open(file.path);
  db.execute('PRAGMA foreign_keys=ON;');
  db.execute('PRAGMA journal_mode=WAL;');
  db.execute('PRAGMA synchronous=NORMAL;');
  return db;
}
