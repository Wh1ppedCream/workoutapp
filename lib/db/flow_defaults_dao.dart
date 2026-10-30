import 'dart:convert';

import 'package:sqflite/sqflite.dart';

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

  /// Upsert one method into `flow_default_methods`.
  static Future<int> upsertDefaultFlowMethod(
    Database db,
    String scope, {
    int? profileId,
    required String name,
    required String type,
    required Map<String, dynamic> params,
  }) async {
    final paramsJson = jsonEncode(params);
    final filter = scopeFilter(scope, profileId);
    final defaultRows = await db.query(
      'flow_defaults',
      columns: ['scope'],
      where: filter.whereClause,
      whereArgs: filter.arguments,
      limit: 1,
    );
    if (defaultRows.isEmpty) {
      await db.insert('flow_defaults', {
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
    final updated = await db.update(
      'flow_default_methods',
      values,
      where: whereClause,
      whereArgs: args,
    );
    if (updated == 0) {
      await db.insert('flow_default_methods', values);
    }
    final rows = await db.rawQuery(
      'SELECT rowid AS id FROM flow_default_methods WHERE $whereClause LIMIT 1',
      args,
    );
    return rows.isEmpty ? 0 : rows.first['id'] as int;
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
}
