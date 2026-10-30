import 'package:sqflite/sqflite.dart';

/// Database operations for DatabaseMetadata without owning a connection.
class DatabaseMetadataDao {
  static Future<bool> tableHasColumn(
    DatabaseExecutor db,
    String table,
    String col,
  ) async {
    final rows = await db.rawQuery("PRAGMA table_info($table)");
    return rows.any(
      (r) => (r['name'] as String).toLowerCase() == col.toLowerCase(),
    );
  }

  static Future<bool> tableExists(DatabaseExecutor db, String name) async {
    final rows = await db.rawQuery(
      "SELECT 1 FROM sqlite_master WHERE type='table' AND name=? LIMIT 1",
      [name],
    );
    return rows.isNotEmpty;
  }
}
