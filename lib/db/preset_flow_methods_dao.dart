import 'package:sqflite/sqflite.dart';

import '../models/preset_models.dart';
import 'preset_auto_settings_dao.dart';

/// DAO for CRUD and transactional graph-reference updates on user-defined
/// flow-chart methods.
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
    DatabaseExecutor db,
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
    DatabaseExecutor db, {
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
  static Future<int> deleteMethod(DatabaseExecutor db, int methodId) {
    return db.delete(
      'preset_flow_methods',
      where: 'id = ?',
      whereArgs: [methodId],
    );
  }

  /// Atomically upserts a preset flow method, retargeting graph edges and
  /// removing the previous rule row when [previousName] differs from [name].
  static Future<int> saveMethodAtomic(
    Database db, {
    required int presetId,
    required String name,
    required String type,
    required String paramsJson,
    int? previousMethodId,
    String? previousName,
  }) {
    return db.transaction((txn) async {
      final id = await upsertMethod(
        txn,
        presetId: presetId,
        name: name,
        type: type,
        paramsJson: paramsJson,
      );
      if (previousName != null && previousName != name) {
        await _renameReferencesInExecutor(
          txn,
          presetId: presetId,
          oldName: previousName,
          newName: name,
        );
        if (previousMethodId != null &&
            previousMethodId > 0 &&
            previousMethodId != id) {
          final deleted = await deleteMethod(txn, previousMethodId);
          if (deleted == 0) {
            await txn.delete(
              'preset_flow_methods',
              where: 'preset_id = ? AND name = ?',
              whereArgs: [presetId, previousName],
            );
          }
        } else {
          await txn.delete(
            'preset_flow_methods',
            where: 'preset_id = ? AND name = ?',
            whereArgs: [presetId, previousName],
          );
        }
      }
      return id;
    });
  }

  /// Atomically renames `method` graph edges inside one transaction.
  static Future<void> renameMethodReferences(
    Database db, {
    required int presetId,
    required String oldName,
    required String newName,
  }) {
    return db.transaction((txn) async {
      await _renameReferencesInExecutor(
        txn,
        presetId: presetId,
        oldName: oldName,
        newName: newName,
      );
    });
  }

  /// Atomically strips `method` graph edges referencing [methodName] and
  /// deletes the rule row.
  static Future<void> deleteMethodAndReferences(
    Database db, {
    required int presetId,
    required int methodId,
    required String methodName,
  }) {
    return db.transaction((txn) async {
      final rawFlow = await PresetAutoSettingsDao.getFlowDefinition(
        txn,
        presetId,
      );
      final def = FlowDefinition.fromJson(rawFlow);
      final updated = def.removeMethodReferences(methodName);
      if (!identical(updated, def)) {
        await PresetAutoSettingsDao.upsertFlowDefinition(
          txn,
          presetId,
          updated.toJson(),
        );
      }
      final deleted = methodId > 0 ? await deleteMethod(txn, methodId) : 0;
      if (deleted == 0 && methodName.isNotEmpty) {
        await txn.delete(
          'preset_flow_methods',
          where: 'preset_id = ? AND name = ?',
          whereArgs: [presetId, methodName],
        );
      }
    });
  }

  static Future<void> _renameReferencesInExecutor(
    DatabaseExecutor executor, {
    required int presetId,
    required String oldName,
    required String newName,
  }) async {
    final rawFlow = await PresetAutoSettingsDao.getFlowDefinition(
      executor,
      presetId,
    );
    final def = FlowDefinition.fromJson(rawFlow);
    final updated = def.renameMethodReferences(oldName, newName);
    if (!identical(updated, def)) {
      await PresetAutoSettingsDao.upsertFlowDefinition(
        executor,
        presetId,
        updated.toJson(),
      );
    }
  }
}
