import 'package:env_test/db/progression_rule_propagation_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE gym_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE preset_definitions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        profile_id INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE flow_defaults (
        scope TEXT NOT NULL,
        profile_id INTEGER,
        flow_json TEXT NOT NULL,
        PRIMARY KEY(scope, profile_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE flow_default_methods (
        scope TEXT NOT NULL,
        profile_id INTEGER,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        params TEXT NOT NULL,
        PRIMARY KEY(scope, profile_id, name)
      )
    ''');
    await db.execute('''
      CREATE TABLE preset_auto_settings (
        preset_id INTEGER PRIMARY KEY,
        is_automatic INTEGER NOT NULL,
        global_increment REAL NOT NULL,
        skip_first_set INTEGER NOT NULL,
        weight_check INTEGER NOT NULL,
        rep_check INTEGER NOT NULL,
        volume_check INTEGER NOT NULL,
        adjust_all_sets INTEGER NOT NULL,
        use_manual_select INTEGER NOT NULL,
        manual_selection_json TEXT,
        success_count_mode TEXT NOT NULL,
        flow_definition TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE preset_flow_methods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('weight', 'rep')),
        params TEXT NOT NULL,
        UNIQUE(preset_id, name)
      )
    ''');
  });

  tearDown(() => db.close());

  test(
    'adds an app rule to profiles without replacing custom same-name rules',
    () async {
      final firstProfile = await db.insert('gym_profiles', {'name': 'Home'});
      final secondProfile = await db.insert('gym_profiles', {'name': 'Gym'});
      await db.insert('flow_defaults', {
        'scope': 'profile',
        'profile_id': firstProfile,
        'flow_json': '{"nodes":["custom"]}',
      });
      await db.insert('flow_default_methods', {
        'scope': 'profile',
        'profile_id': firstProfile,
        'name': 'Increase weight',
        'type': 'weight',
        'params': '{"factor":9}',
      });

      final copied =
          await ProgressionRulePropagationDao.copyAppRuleToExistingProfiles(
            db,
            name: 'Increase weight',
            type: 'weight',
            paramsJson: '{"factor":1}',
          );

      expect(copied, 1);
      expect(
        (await db.query(
          'flow_default_methods',
          where: 'profile_id = ? AND name = ?',
          whereArgs: [firstProfile, 'Increase weight'],
        )).single['params'],
        '{"factor":9}',
      );
      expect(
        (await db.query(
          'flow_default_methods',
          where: 'profile_id = ? AND name = ?',
          whereArgs: [secondProfile, 'Increase weight'],
        )).single['params'],
        '{"factor":1}',
      );
      expect(
        (await db.query(
          'flow_defaults',
          where: 'scope = ? AND profile_id = ?',
          whereArgs: ['profile', firstProfile],
        )).single['flow_json'],
        '{"nodes":["custom"]}',
      );
    },
  );

  test(
    'adds a profile rule to its plans without replacing plan rules or flows',
    () async {
      final profileId = await db.insert('gym_profiles', {'name': 'Home'});
      final firstPlan = await db.insert('preset_definitions', {
        'name': 'Upper',
        'profile_id': profileId,
      });
      final secondPlan = await db.insert('preset_definitions', {
        'name': 'Lower',
        'profile_id': profileId,
      });
      final otherPlan = await db.insert('preset_definitions', {
        'name': 'Other',
        'profile_id': profileId + 1,
      });
      await db.insert('preset_auto_settings', {
        'preset_id': firstPlan,
        'is_automatic': 1,
        'global_increment': 2.5,
        'skip_first_set': 0,
        'weight_check': 1,
        'rep_check': 1,
        'volume_check': 0,
        'adjust_all_sets': 1,
        'use_manual_select': 0,
        'manual_selection_json': '{}',
        'success_count_mode': 'set',
        'flow_definition': '{"nodes":["keep"]}',
      });
      await db.insert('preset_flow_methods', {
        'preset_id': firstPlan,
        'name': 'Add reps',
        'type': 'rep',
        'params': '{"amount":5}',
      });

      final copied =
          await ProgressionRulePropagationDao.copyProfileRuleToExistingPlans(
            db,
            profileId: profileId,
            name: 'Add reps',
            type: 'rep',
            paramsJson: '{"amount":1}',
          );

      expect(copied, 1);
      expect(
        (await db.query(
          'preset_flow_methods',
          where: 'preset_id = ? AND name = ?',
          whereArgs: [firstPlan, 'Add reps'],
        )).single['params'],
        '{"amount":5}',
      );
      expect(
        (await db.query(
          'preset_flow_methods',
          where: 'preset_id = ? AND name = ?',
          whereArgs: [secondPlan, 'Add reps'],
        )).single['params'],
        '{"amount":1}',
      );
      expect(
        (await db.query(
          'preset_auto_settings',
          where: 'preset_id = ?',
          whereArgs: [firstPlan],
        )).single['flow_definition'],
        '{"nodes":["keep"]}',
      );
      expect(
        await db.query(
          'preset_flow_methods',
          where: 'preset_id = ?',
          whereArgs: [otherPlan],
        ),
        isEmpty,
      );
    },
  );

  test(
    'rolls back profile-to-plan propagation if any destination write fails',
    () async {
      final profileId = await db.insert('gym_profiles', {'name': 'Home'});
      final firstPlan = await db.insert('preset_definitions', {
        'name': 'Upper',
        'profile_id': profileId,
      });
      final secondPlan = await db.insert('preset_definitions', {
        'name': 'Lower',
        'profile_id': profileId,
      });

      await expectLater(
        ProgressionRulePropagationDao.copyProfileRuleToExistingPlans(
          db,
          profileId: profileId,
          name: 'Unsupported',
          type: 'addSet',
          paramsJson: '{}',
        ),
        throwsA(anything),
      );

      expect(await db.query('preset_flow_methods'), isEmpty);
      expect(
        await db.query(
          'preset_auto_settings',
          where: 'preset_id IN (?, ?)',
          whereArgs: [firstPlan, secondPlan],
        ),
        isEmpty,
      );
    },
  );
}
