import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/preset_models.dart';

/// Owns SQLite persistence for app-level and profile-level default progression
/// flow graphs and rule definitions (`flow_defaults` and `flow_default_methods`).
abstract final class FlowDefaultsDao {
  static ({String whereClause, List<Object?> arguments}) scopeFilter(
    String scope,
    int? profileId,
  ) {
    return profileId == null
        ? (
            whereClause: 'scope = ? AND profile_id IS NULL',
            arguments: <Object?>[scope],
          )
        : (
            whereClause: 'scope = ? AND profile_id = ?',
            arguments: <Object?>[scope, profileId],
          );
  }

  /// Fetch the saved default flow JSON for either the whole app or a profile.
  static Future<String> fetchDefaultFlow(
    DatabaseExecutor db,
    String scope, {
    int? profileId,
  }) async {
    final filter = scopeFilter(scope, profileId);
    final rows = await db.query(
      'flow_defaults',
      columns: ['flow_json'],
      where: filter.whereClause,
      whereArgs: filter.arguments,
      limit: 1,
    );
    if (rows.isEmpty) return '{}';
    return rows.first['flow_json'] as String;
  }

  /// Upsert default flow JSON for `scope` ('app' or 'profile') and `profileId`.
  static Future<void> upsertDefaultFlow(
    DatabaseExecutor db,
    String scope, {
    int? profileId,
    required String flowJson,
  }) async {
    final values = <String, Object?>{
      'scope': scope,
      'profile_id': profileId,
      'flow_json': flowJson,
    };
    final filter = scopeFilter(scope, profileId);
    final updated = await db.update(
      'flow_defaults',
      values,
      where: filter.whereClause,
      whereArgs: filter.arguments,
    );
    if (updated == 0) {
      await db.insert('flow_defaults', values);
    }
  }

  /// Delete a default flow entry.
  static Future<int> deleteDefaultFlow(
    DatabaseExecutor db,
    String scope, {
    int? profileId,
  }) {
    final filter = scopeFilter(scope, profileId);
    return db.delete(
      'flow_defaults',
      where: filter.whereClause,
      whereArgs: filter.arguments,
    );
  }

  /// Fetch all methods attached to an app or profile default.
  static Future<List<Map<String, dynamic>>> fetchDefaultFlowMethods(
    DatabaseExecutor db,
    String scope, {
    int? profileId,
  }) {
    final filter = scopeFilter(scope, profileId);
    return db.rawQuery('''
      SELECT rowid AS id, scope, profile_id, name, type, params
      FROM flow_default_methods
      WHERE ${filter.whereClause}
      ORDER BY name
      ''', filter.arguments);
  }

  /// Atomically ensures the owning `flow_defaults` row exists and upserts one
  /// method into `flow_default_methods`.
  static Future<int> upsertDefaultFlowMethod(
    Database db,
    String scope, {
    int? profileId,
    required String name,
    required String type,
    required Map<String, dynamic> params,
  }) {
    return db.transaction((txn) {
      return _upsertMethodInExecutor(
        txn,
        scope,
        profileId: profileId,
        name: name,
        type: type,
        params: params,
      );
    });
  }

  /// Atomically upserts a default flow method, retargeting graph edges and
  /// deleting the old method row when [previousName] differs from [name].
  static Future<int> saveDefaultFlowMethodAtomic(
    Database db,
    String scope, {
    int? profileId,
    required String name,
    required String type,
    required Map<String, dynamic> params,
    String? previousName,
  }) {
    return db.transaction((txn) async {
      final id = await _upsertMethodInExecutor(
        txn,
        scope,
        profileId: profileId,
        name: name,
        type: type,
        params: params,
      );
      if (previousName != null && previousName != name) {
        await _renameReferencesInExecutor(
          txn,
          scope,
          profileId: profileId,
          oldName: previousName,
          newName: name,
        );
        await deleteDefaultFlowMethod(
          txn,
          scope,
          profileId: profileId,
          name: previousName,
        );
      }
      return id;
    });
  }

  /// Atomically renames `method` graph edges inside one transaction.
  static Future<void> renameDefaultFlowMethodReferences(
    Database db,
    String scope, {
    int? profileId,
    required String oldName,
    required String newName,
  }) {
    return db.transaction((txn) async {
      await _renameReferencesInExecutor(
        txn,
        scope,
        profileId: profileId,
        oldName: oldName,
        newName: newName,
      );
    });
  }

  /// Atomically removes `method` graph edges referencing [name] and deletes the
  /// default rule row.
  static Future<void> deleteDefaultFlowMethodAndReferences(
    Database db,
    String scope, {
    int? profileId,
    required String name,
  }) {
    return db.transaction((txn) async {
      final rawFlow = await fetchDefaultFlow(txn, scope, profileId: profileId);
      final def = FlowDefinition.fromJson(rawFlow);
      final updated = def.removeMethodReferences(name);
      if (!identical(updated, def)) {
        await upsertDefaultFlow(
          txn,
          scope,
          profileId: profileId,
          flowJson: updated.toJson(),
        );
      }
      await deleteDefaultFlowMethod(
        txn,
        scope,
        profileId: profileId,
        name: name,
      );
    });
  }

  /// Delete one default method by name.
  static Future<int> deleteDefaultFlowMethod(
    DatabaseExecutor db,
    String scope, {
    int? profileId,
    required String name,
  }) {
    final filter = scopeFilter(scope, profileId);
    final whereClause = '${filter.whereClause} AND name = ?';
    final args = <Object?>[...filter.arguments, name];
    return db.delete(
      'flow_default_methods',
      where: whereClause,
      whereArgs: args,
    );
  }

  static Future<int> _upsertMethodInExecutor(
    DatabaseExecutor executor,
    String scope, {
    int? profileId,
    required String name,
    required String type,
    required Map<String, dynamic> params,
  }) async {
    final paramsJson = jsonEncode(params);
    final filter = scopeFilter(scope, profileId);
    final defaultRows = await executor.query(
      'flow_defaults',
      columns: ['scope'],
      where: filter.whereClause,
      whereArgs: filter.arguments,
      limit: 1,
    );
    if (defaultRows.isEmpty) {
      await executor.insert('flow_defaults', {
        'scope': scope,
        'profile_id': profileId,
        'flow_json': '{}',
      });
    }
    final values = <String, Object?>{
      'scope': scope,
      'profile_id': profileId,
      'name': name,
      'type': type,
      'params': paramsJson,
    };
    final whereClause = '${filter.whereClause} AND name = ?';
    final args = <Object?>[...filter.arguments, name];
    final updated = await executor.update(
      'flow_default_methods',
      values,
      where: whereClause,
      whereArgs: args,
    );
    if (updated == 0) {
      await executor.insert('flow_default_methods', values);
    }
    final rows = await executor.rawQuery(
      'SELECT rowid AS id FROM flow_default_methods WHERE $whereClause LIMIT 1',
      args,
    );
    return rows.isEmpty ? 0 : rows.first['id'] as int;
  }

  static Future<void> _renameReferencesInExecutor(
    DatabaseExecutor executor,
    String scope, {
    int? profileId,
    required String oldName,
    required String newName,
  }) async {
    final rawFlow = await fetchDefaultFlow(
      executor,
      scope,
      profileId: profileId,
    );
    final def = FlowDefinition.fromJson(rawFlow);
    final updated = def.renameMethodReferences(oldName, newName);
    if (!identical(updated, def)) {
      await upsertDefaultFlow(
        executor,
        scope,
        profileId: profileId,
        flowJson: updated.toJson(),
      );
    }
  }
}
