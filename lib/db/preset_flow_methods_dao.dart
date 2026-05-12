import 'package:sqflite/sqflite.dart';

/// DAO for CRUD on user-defined flow-chart methods.
class PresetFlowMethodsDao {
  static Map<String, Object?> _methodValues({
    required int presetId,
    required String name,
    required String type,
    required String paramsJson,
  }) {
    return {
      'preset_id': presetId,
      'name': name,
      'type': type,
      'params': paramsJson,
    };
  }

  /// Fetch all methods for a given preset.
  static Future<List<Map<String, dynamic>>> getMethods(
    Database db,
    int presetId,
  ) {
    return db.query(
      'preset_flow_methods',
      where: 'preset_id = ?',
      whereArgs: [presetId],
      orderBy: 'name',
    );
  }

  /// Insert or replace a method.
  static Future<int> upsertMethod(
    Database db, {
    required int presetId,
    required String name,
    required String type,
    required String paramsJson,
  }) {
    return db.insert(
      'preset_flow_methods',
      _methodValues(
        presetId: presetId,
        name: name,
        type: type,
        paramsJson: paramsJson,
      ),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete a method by its ID.
  static Future<int> deleteMethod(Database db, int methodId) {
    return db.delete(
      'preset_flow_methods',
      where: 'id = ?',
      whereArgs: [methodId],
    );
  }
}
