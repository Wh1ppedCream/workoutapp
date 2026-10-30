import 'package:env_test/db/preset_auto_settings_dao.dart';
import 'package:env_test/db/preset_flow_methods_dao.dart';
import 'package:env_test/models/preset_models.dart';
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

  test('renames and deletes preset rules and graph edges atomically on failure and retry', () async {
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
    final initialId = await PresetFlowMethodsDao.upsertMethod(
      db,
      presetId: 7,
      name: 'Increase weight',
      type: 'weight',
      paramsJson: '{"sign":"+","factor":1.0}',
    );
    await PresetAutoSettingsDao.upsertFlowDefinition(
      db,
      7,
      FlowDefinition(
        nodes: const ['s1', 's2'],
        edges: [
          FlowEdge(from: 's1', outcome: 'method', to: 'Increase weight'),
          FlowEdge(from: 's1', outcome: 'success', to: 's2'),
        ],
      ).toJson(),
    );

    await db.execute('''
        CREATE TRIGGER block_preset_method_delete
        BEFORE DELETE ON preset_flow_methods
        BEGIN
          SELECT RAISE(ABORT, 'simulated preset delete failure');
        END
      ''');

    await expectLater(
      PresetFlowMethodsDao.saveMethodAtomic(
        db,
        presetId: 7,
        name: 'Heavy jump',
        type: 'weight',
        paramsJson: '{"sign":"+","factor":2.0}',
        previousMethodId: initialId,
        previousName: 'Increase weight',
      ),
      throwsA(isA<DatabaseException>()),
    );

    expect(
      (await PresetFlowMethodsDao.getMethods(db, 7)).map((r) => r['name']),
      ['Increase weight'],
    );
    expect(
      FlowDefinition.fromJson(
        await PresetAutoSettingsDao.getFlowDefinition(db, 7),
      ).edges.first.to,
      'Increase weight',
    );

    await expectLater(
      PresetFlowMethodsDao.deleteMethodAndReferences(
        db,
        presetId: 7,
        methodId: initialId,
        methodName: 'Increase weight',
      ),
      throwsA(isA<DatabaseException>()),
    );
    expect(
      FlowDefinition.fromJson(
        await PresetAutoSettingsDao.getFlowDefinition(db, 7),
      ).edges,
      hasLength(2),
    );

    await db.execute('DROP TRIGGER block_preset_method_delete');

    final renamedId = await PresetFlowMethodsDao.saveMethodAtomic(
      db,
      presetId: 7,
      name: 'Heavy jump',
      type: 'weight',
      paramsJson: '{"sign":"+","factor":2.0}',
      previousMethodId: initialId,
      previousName: 'Increase weight',
    );
    expect(
      (await PresetFlowMethodsDao.getMethods(db, 7)).map((r) => r['name']),
      ['Heavy jump'],
    );
    expect(
      FlowDefinition.fromJson(
        await PresetAutoSettingsDao.getFlowDefinition(db, 7),
      ).edges.first.to,
      'Heavy jump',
    );

    await PresetFlowMethodsDao.deleteMethodAndReferences(
      db,
      presetId: 7,
      methodId: renamedId,
      methodName: 'Heavy jump',
    );
    expect(await PresetFlowMethodsDao.getMethods(db, 7), isEmpty);
    final cleaned = FlowDefinition.fromJson(
      await PresetAutoSettingsDao.getFlowDefinition(db, 7),
    );
    expect(cleaned.edges, hasLength(1));
    expect(cleaned.edges.single.outcome, 'success');
  });
}
