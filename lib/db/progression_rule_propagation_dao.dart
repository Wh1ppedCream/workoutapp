import 'package:sqflite/sqflite.dart';

/// Copies newly created progression-rule defaults into existing snapshots.
///
/// Propagation intentionally adds only a missing rule definition. It never
/// replaces an existing profile/plan rule or edits a saved flow graph.
class ProgressionRulePropagationDao {
  static const _defaultPlanSettings = <String, Object?>{
    'is_automatic': 0,
    'global_increment': 5.0,
    'skip_first_set': 1,
    'weight_check': 1,
    'rep_check': 1,
    'volume_check': 0,
    'adjust_all_sets': 0,
    'use_manual_select': 0,
    'manual_selection_json': '{}',
    'success_count_mode': 'set',
    'flow_definition': '{}',
  };

  /// Adds an app-wide rule to profiles that do not already define that name.
  /// Returns the number of profile snapshots changed.
  static Future<int> copyAppRuleToExistingProfiles(
    Database db, {
    required String name,
    required String type,
    required String paramsJson,
  }) {
    return db.transaction((txn) async {
      final profiles = await txn.query('gym_profiles', columns: ['id']);
      var copied = 0;

      for (final profile in profiles) {
        final profileId = profile['id'] as int;
        final existing = await txn.query(
          'flow_default_methods',
          columns: ['name'],
          where: 'scope = ? AND profile_id = ? AND name = ?',
          whereArgs: ['profile', profileId, name],
          limit: 1,
        );
        if (existing.isNotEmpty) continue;

        final defaultFlow = await txn.query(
          'flow_defaults',
          columns: ['scope'],
          where: 'scope = ? AND profile_id = ?',
          whereArgs: ['profile', profileId],
          limit: 1,
        );
        if (defaultFlow.isEmpty) {
          await txn.insert('flow_defaults', {
            'scope': 'profile',
            'profile_id': profileId,
            'flow_json': '{}',
          });
        }

        await txn.insert('flow_default_methods', {
          'scope': 'profile',
          'profile_id': profileId,
          'name': name,
          'type': type,
          'params': paramsJson,
        });
        copied++;
      }
      return copied;
    });
  }

  /// Adds a profile-default rule to that profile's plans when the plan does
  /// not already define a rule with the same name. Existing flow definitions
  /// and automatic settings are preserved.
  static Future<int> copyProfileRuleToExistingPlans(
    Database db, {
    required int profileId,
    required String name,
    required String type,
    required String paramsJson,
  }) {
    return db.transaction((txn) async {
      final plans = await txn.query(
        'preset_definitions',
        columns: ['id'],
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );
      var copied = 0;

      for (final plan in plans) {
        final presetId = plan['id'] as int;
        final existing = await txn.query(
          'preset_flow_methods',
          columns: ['id'],
          where: 'preset_id = ? AND name = ?',
          whereArgs: [presetId, name],
          limit: 1,
        );
        if (existing.isNotEmpty) continue;

        final settings = await txn.query(
          'preset_auto_settings',
          columns: ['preset_id'],
          where: 'preset_id = ?',
          whereArgs: [presetId],
          limit: 1,
        );
        if (settings.isEmpty) {
          await txn.insert('preset_auto_settings', {
            'preset_id': presetId,
            ..._defaultPlanSettings,
          });
        }

        await txn.insert('preset_flow_methods', {
          'preset_id': presetId,
          'name': name,
          'type': type,
          'params': paramsJson,
        });
        copied++;
      }
      return copied;
    });
  }
}
