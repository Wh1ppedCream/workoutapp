import 'package:sqflite/sqflite.dart';

/// Platform-level SQLite connection configuration shared by database startup.
///
/// Schema creation, migrations, and Tonos-specific maintenance intentionally
/// remain in [DatabaseHelper].
class DatabaseConnection {
  const DatabaseConnection._();

  static Future<void> configure(Database database) async {
    await database.execute('PRAGMA foreign_keys = ON');
    try {
      await database.rawQuery('PRAGMA journal_mode = WAL');
    } catch (_) {
      // WAL is an optional performance optimization on constrained platforms.
    }
  }
}
