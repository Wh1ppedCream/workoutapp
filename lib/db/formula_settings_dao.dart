// File: lib/db/formula_settings_dao.dart

import 'package:sqflite/sqflite.dart';

/// DAO for the formula_settings table.
///
/// Stores key/value pairs for parameters like
///   - 'step'  (decrement per rank, default 0.05)
///   - 'min'   (minimum clamp, default 0.0)
///   - 'max'   (maximum clamp, default 1.0)
class FormulaSettingsDao {
  static const _table = 'formula_settings';

  static Map<String, Object?> _paramValues(String key, double value) {
    return {'key': key, 'value': value};
  }

  /// Sets (inserts or replaces) a formula parameter.
  static Future<void> setParam(Database db, String key, double value) async {
    await db.insert(
      _table,
      _paramValues(key, value),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Reads a formula parameter by [key], or null if none set.
  static Future<double?> getParam(Database db, String key) async {
    final rows = await db.query(
      _table,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return (rows.first['value'] as num).toDouble();
  }
}
