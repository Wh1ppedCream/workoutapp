import 'dart:io';

import 'package:env_test/db/database_helper.dart';
import 'package:env_test/db/schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Directory tempDirectory;
  late String databasePath;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'tonos_database_upgrade_',
    );
    databasePath = p.join(tempDirectory.path, 'historical.db');
  });

  tearDown(() async {
    if (tempDirectory.existsSync()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('upgrades a populated v18 database and preserves user data', () async {
    var db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 18,
        onConfigure: (database) => database.execute('PRAGMA foreign_keys = ON'),
        onCreate: (database, _) => _createSchemaThroughV18(database),
      ),
    );

    final profileId = await db.insert('gym_profiles', {'name': 'Home Gym'});
    final presetId = await db.insert('preset_definitions', {
      'name': 'Upper Body',
      'profile_id': profileId,
    });
    await db.insert('personal_info', {'name': 'Taylor', 'weight': '154'});
    final bodyWeightDefinitionId = await db.insert('measurement_definitions', {
      'name': 'BodyWeight',
      'type': 'BodyWeight',
    });
    await db.insert('measurements', {
      'def_id': bodyWeightDefinitionId,
      'timestamp': DateTime.utc(2026, 7, 1).toIso8601String(),
      'value': 70.0,
      'unit': 'kg',
      'note': 'Historical fixture',
    });
    await db.close();

    db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: DatabaseHelper.currentSchemaVersion,
        onConfigure: (database) => database.execute('PRAGMA foreign_keys = ON'),
        onUpgrade: Schema.onUpgrade,
      ),
    );

    expect(await db.getVersion(), DatabaseHelper.currentSchemaVersion);
    expect(
      (await db.query(
        'preset_definitions',
        where: 'id = ?',
        whereArgs: [presetId],
      )).single['is_draft'],
      0,
    );
    expect((await db.query('personal_info')).single['name'], 'Taylor');
    expect((await db.query('measurements')).single['value'], 70.0);
    expect(
      (await db.rawQuery('PRAGMA integrity_check')).single.values.single,
      'ok',
    );
    expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    await db.close();

    db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: DatabaseHelper.currentSchemaVersion,
        onUpgrade: Schema.onUpgrade,
      ),
    );
    expect((await db.query('preset_definitions')).single['name'], 'Upper Body');
    await db.close();
  });

  test('v55 migration recovers when its column already exists', () async {
    var db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: DatabaseHelper.currentSchemaVersion,
        onCreate: (database, _) => Schema.createTables(database),
      ),
    );
    await db.execute(
      'DROP INDEX IF EXISTS idx_preset_definitions_draft_profile',
    );
    await db.setVersion(54);
    await db.close();

    db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: DatabaseHelper.currentSchemaVersion,
        onUpgrade: Schema.onUpgrade,
      ),
    );

    final columns = await db.rawQuery(
      "PRAGMA table_info('preset_definitions')",
    );
    final indexes = await db.rawQuery(
      "PRAGMA index_list('preset_definitions')",
    );
    expect(columns.where((row) => row['name'] == 'is_draft'), hasLength(1));
    expect(
      indexes.any(
        (row) => row['name'] == 'idx_preset_definitions_draft_profile',
      ),
      isTrue,
    );
    await db.close();
  });
}

Future<void> _createSchemaThroughV18(Database db) async {
  await Schema.createV1(db);
  await Schema.migrateV3(db);
  await Schema.migrateV4(db);
  await Schema.migrateV5(db);
  await Schema.migrateV6(db);
  await Schema.migrateV7(db);
  await Schema.migrateV8(db);
  await Schema.migrateV9(db);
  await Schema.migrateV10(db);
  await Schema.migrateV11(db);
  await Schema.migrateV12(db);
  await Schema.migrateV13(db);
  await Schema.migrateV14(db);
  await Schema.migrateV15(db);
  await Schema.migrateV16(db);
  await Schema.migrateV17(db);
  await Schema.migrateV18(db);
}
