import 'package:env_test/db/preset_auto_settings_dao.dart';
import 'package:env_test/db/preset_flow_methods_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE preset_auto_settings (
        preset_id INTEGER PRIMARY KEY,
        is_automatic INTEGER NOT NULL DEFAULT 0,
        global_increment REAL NOT NULL DEFAULT 5,
        skip_first_set INTEGER NOT NULL DEFAULT 1,
        weight_check INTEGER NOT NULL DEFAULT 1,
        rep_check INTEGER NOT NULL DEFAULT 1,
        volume_check INTEGER NOT NULL DEFAULT 0,
        adjust_all_sets INTEGER NOT NULL DEFAULT 0,
        flow_definition TEXT NOT NULL DEFAULT '{}',
        use_manual_select INTEGER NOT NULL DEFAULT 0,
        manual_selection_json TEXT,
        success_count_mode TEXT NOT NULL DEFAULT 'set'
      )
    ''');
    await db.execute('''
      CREATE TABLE preset_flow_methods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        params TEXT NOT NULL,
        UNIQUE(preset_id, name)
      )
    ''');
  });

  tearDown(() => db.close());

  test(
    'preserves the flow definition while automatic settings are updated',
    () async {
      await PresetAutoSettingsDao.upsertAutoSettings(
        db,
        presetId: 7,
        isAutomatic: true,
        globalIncrement: 5,
        skipFirstSet: true,
        weightCheck: true,
        repCheck: true,
        volumeCheck: false,
        adjustAllSets: false,
        useManualSelect: false,
      );
      await PresetAutoSettingsDao.upsertFlowDefinition(
        db,
        7,
        '{"nodes":["first"],"edges":[]}',
      );

      await PresetAutoSettingsDao.upsertAutoSettings(
        db,
        presetId: 7,
        isAutomatic: true,
        globalIncrement: 10,
        skipFirstSet: false,
        weightCheck: true,
        repCheck: true,
        volumeCheck: true,
        adjustAllSets: true,
        useManualSelect: false,
        successCountMode: 'exercise',
      );

      final settings = await PresetAutoSettingsDao.getAutoSettings(db, 7);
      expect(settings?['global_increment'], 10.0);
      expect(settings?['flow_definition'], '{"nodes":["first"],"edges":[]}');
      expect(settings?['success_count_mode'], 'exercise');
    },
  );

  test('replaces a same-named rule instead of creating duplicates', () async {
    await PresetAutoSettingsDao.upsertAutoSettings(
      db,
      presetId: 7,
      isAutomatic: true,
      globalIncrement: 5,
      skipFirstSet: true,
      weightCheck: true,
      repCheck: true,
      volumeCheck: false,
      adjustAllSets: false,
      useManualSelect: false,
    );
    await PresetFlowMethodsDao.upsertMethod(
      db,
      presetId: 7,
      name: 'Increase weight',
      type: 'weight',
      paramsJson: '{"amount":5}',
    );
    await PresetFlowMethodsDao.upsertMethod(
      db,
      presetId: 7,
      name: 'Increase weight',
      type: 'weight',
      paramsJson: '{"amount":10}',
    );

    final rules = await PresetFlowMethodsDao.getMethods(db, 7);
    expect(rules, hasLength(1));
    expect(rules.single['params'], '{"amount":10}');
  });
}
