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
      final databaseFiles = tempDirectory.listSync().whereType<File>().where(
        (file) => file.path.endsWith('.db'),
      );
      for (final file in databaseFiles) {
        await databaseFactoryFfi.deleteDatabase(file.path);
      }
      await tempDirectory.delete(recursive: true);
    }
  });

  for (final historicalVersion in const [
    1,
    7,
    18,
    21,
    42,
    47,
    52,
    54,
    55,
    56,
    59,
    60,
  ]) {
    test(
      'upgrades a populated v$historicalVersion database and preserves data',
      () async {
        var db = await databaseFactoryFfi.openDatabase(
          databasePath,
          options: OpenDatabaseOptions(
            version: historicalVersion,
            onConfigure:
                (database) => database.execute('PRAGMA foreign_keys = ON'),
            onCreate:
                (database, _) =>
                    _createSchemaThroughVersion(database, historicalVersion),
          ),
        );
        final fixture = await _populateHistoricalDatabase(
          db,
          historicalVersion,
        );
        await db.close();

        db = await databaseFactoryFfi.openDatabase(
          databasePath,
          options: OpenDatabaseOptions(
            version: DatabaseHelper.currentSchemaVersion,
            onConfigure:
                (database) => database.execute('PRAGMA foreign_keys = ON'),
            onUpgrade: Schema.onUpgrade,
          ),
        );

        await _expectHistoricalDataPreserved(db, fixture);
        await _expectFoodMutationTriggersHealthy(
          db,
          fixture,
          historicalVersion,
        );
        final definitionColumns = await db.rawQuery(
          "PRAGMA table_info('exercise_definitions')",
        );
        final definitionColumnNames =
            definitionColumns.map((column) => column['name']).toSet();
        expect(
          definitionColumnNames,
          containsAll(<String>{
            'catalog_id',
            'legacy_media_id',
            'catalog_status',
          }),
        );
        final sessionColumns = await db.rawQuery(
          "PRAGMA table_info('sessions')",
        );
        final measurementColumns = await db.rawQuery(
          "PRAGMA table_info('measurements')",
        );
        expect(
          sessionColumns.map((column) => column['name']).toSet(),
          containsAll(<String>{'completed_at_ms', 'training_day'}),
        );
        expect(
          measurementColumns.map((column) => column['name']).toSet(),
          containsAll(<String>{'measured_at_ms', 'measured_on'}),
        );
        expect(
          await db.query('exercise_catalog_state'),
          isEmpty,
          reason: 'Schema migration must not fabricate catalog sync state.',
        );
        expect(await db.getVersion(), DatabaseHelper.currentSchemaVersion);
        expect(
          (await db.rawQuery('PRAGMA integrity_check')).single.values.single,
          'ok',
        );
        expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
        final upgradedSchema = await _schemaSignature(db);
        await db.close();

        // Reopening current databases exercises idempotent defensive repairs.
        db = await databaseFactoryFfi.openDatabase(
          databasePath,
          options: OpenDatabaseOptions(
            version: DatabaseHelper.currentSchemaVersion,
            onUpgrade: Schema.onUpgrade,
          ),
        );
        await _expectHistoricalDataPreserved(db, fixture);
        await db.close();

        final freshPath = p.join(
          tempDirectory.path,
          'fresh-current-v$historicalVersion.db',
        );
        final freshDb = await databaseFactoryFfi.openDatabase(
          freshPath,
          options: OpenDatabaseOptions(
            version: DatabaseHelper.currentSchemaVersion,
            onConfigure:
                (database) => database.execute('PRAGMA foreign_keys = ON'),
            onCreate: (database, _) => Schema.createTables(database),
          ),
        );
        expect(
          upgradedSchema,
          await _schemaSignature(freshDb),
          reason:
              'Upgrading v$historicalVersion must produce the same schema as a fresh install.',
        );
        await freshDb.close();
      },
    );
  }

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

Future<void> _createSchemaThroughVersion(Database db, int version) async {
  await Schema.createV1(db);
  final migrations = <int, Future<void> Function(Database)>{
    3: Schema.migrateV3,
    4: Schema.migrateV4,
    5: Schema.migrateV5,
    6: Schema.migrateV6,
    7: Schema.migrateV7,
    8: Schema.migrateV8,
    9: Schema.migrateV9,
    10: Schema.migrateV10,
    11: Schema.migrateV11,
    12: Schema.migrateV12,
    13: Schema.migrateV13,
    14: Schema.migrateV14,
    15: Schema.migrateV15,
    16: Schema.migrateV16,
    17: Schema.migrateV17,
    18: Schema.migrateV18,
    19: Schema.migrateV19,
    20: Schema.migrateV20,
    21: Schema.migrateV21,
    22: Schema.migrateV22,
    23: Schema.migrateV23,
    24: Schema.migrateV24,
    25: Schema.migrateV25,
    26: Schema.migrateV26,
    27: Schema.migrateV27,
    28: Schema.migrateV28,
    29: Schema.migrateV29,
    30: Schema.migrateV30,
    31: Schema.migrateV31,
    32: Schema.migrateV32,
    33: Schema.migrateV33,
    34: Schema.migrateV34,
    35: Schema.migrateV35,
    36: Schema.migrateV36,
    37: Schema.migrateV37,
    38: Schema.migrateV38,
    39: Schema.migrateV39,
    40: Schema.migrateV40,
    41: Schema.migrateV41,
    42: Schema.migrateV42,
    43: Schema.migrateV43,
    44: Schema.migrateV44,
    45: Schema.migrateV45,
    46: Schema.migrateV46,
    47: Schema.migrateV47,
    48: Schema.migrateV48,
    49: Schema.migrateV49,
    50: Schema.migrateV50,
    51: Schema.migrateV51,
    52: Schema.migrateV52,
    53: Schema.migrateV53,
    54: Schema.migrateV54,
    55: Schema.migrateV55,
    56: Schema.migrateV56,
    57: Schema.migrateV57,
    58: Schema.migrateV58,
    59: Schema.migrateV59,
    60: Schema.migrateV60,
  };
  for (final entry in migrations.entries) {
    if (entry.key > version) break;
    await entry.value(db);
  }
}

Future<_HistoricalFixture> _populateHistoricalDatabase(
  Database db,
  int version,
) async {
  final marker = 'upgrade-v$version';
  final equipmentId = await db.insert('equipment', {
    'name': 'Equipment $marker',
  });
  final definitionId = await db.insert('exercise_definitions', {
    'name': 'Exercise $marker',
    'equipment_id': equipmentId,
  });
  final sessionId = await db.insert('sessions', {
    'date':
        DateTime.utc(2026, 1, version.clamp(1, 28).toInt()).toIso8601String(),
    'duration': 37,
  });
  final exerciseId = await db.insert('exercises', {
    'session_id': sessionId,
    'exercise_def_id': definitionId,
    'type': 'weight',
    'order_index': 0,
  });
  await db.insert('sets', {
    'exercise_id': exerciseId,
    'weight': 135.0,
    'reps': 5,
    'order_index': 0,
  });
  final measurementDefinitionId = await db.insert('measurement_definitions', {
    'name': 'BodyWeight',
    'type': 'BodyWeight',
  });
  await db.insert('measurements', {
    'def_id': measurementDefinitionId,
    'timestamp': DateTime.utc(2026, 1, 1).toIso8601String(),
    'value': 70.0,
    'unit': 'kg',
    'note': marker,
  });

  int? presetId;
  int? profileId;
  if (await _tableExists(db, 'gym_profiles')) {
    profileId = await db.insert('gym_profiles', {'name': 'Profile $marker'});
  }
  if (await _tableExists(db, 'preset_definitions')) {
    presetId = await db.insert('preset_definitions', {
      'name': 'Plan $marker',
      if (profileId != null) 'profile_id': profileId,
    });
  }
  if (await _tableExists(db, 'personal_info')) {
    await db.insert('personal_info', {
      'name': 'Taylor $marker',
      'weight': '154',
    });
  }

  int? foodId;
  if (await _tableExists(db, 'foods')) {
    foodId = await db.insert('foods', {'name': 'Food $marker'});
  }
  String? barcode;
  if (foodId != null && await _tableExists(db, 'food_barcodes')) {
    barcode = '00${version.toString().padLeft(10, '0')}';
    await _insertHistoricalBarcode(db, foodId, barcode);
  }

  if (await _tableExists(db, 'active_workout_draft')) {
    await db.insert('active_workout_draft', {
      'id': 1,
      'started_at': DateTime.utc(2026, 1, 1).toIso8601String(),
      'auto_preset_id': presetId,
      'payload_json': '{"marker":"$marker"}',
      'updated_at': DateTime.utc(2026, 1, 1).toIso8601String(),
    });
  }

  String? mediaAssetId;
  if (await _tableExists(db, 'exercise_media')) {
    mediaAssetId = 'asset-$marker';
    await db.insert('exercise_media', {
      'exercise_def_id': definitionId,
      'asset_id': mediaAssetId,
      'media_type': 'thumbnail',
      'remote_url': 'https://example.invalid/$marker.webp',
    });
  }

  return _HistoricalFixture(
    marker: marker,
    sessionId: sessionId,
    presetId: presetId,
    foodId: foodId,
    barcode: barcode,
    hadPersonalInfo: await _tableExists(db, 'personal_info'),
    hadActiveDraft: await _tableExists(db, 'active_workout_draft'),
    mediaAssetId: mediaAssetId,
  );
}

Future<void> _insertHistoricalBarcode(
  Database db,
  int foodId,
  String barcode,
) async {
  final triggerRows = await db.rawQuery('''
    SELECT sql
    FROM sqlite_master
    WHERE type = 'trigger' AND name = 'foods_au'
    LIMIT 1
  ''');
  final triggerSql =
      triggerRows.isEmpty ? null : triggerRows.single['sql'] as String?;

  // Preserve the historical trigger definition while bypassing its known
  // FTS4/FTS5 syntax mismatch long enough to create representative old data.
  if (triggerSql != null) {
    await db.execute('DROP TRIGGER foods_au');
  }
  try {
    await db.insert('food_barcodes', {'food_id': foodId, 'upc': barcode});
  } finally {
    if (triggerSql != null) {
      await db.execute(triggerSql);
    }
  }
}

Future<void> _expectFoodMutationTriggersHealthy(
  Database db,
  _HistoricalFixture fixture,
  int historicalVersion,
) async {
  if (fixture.foodId == null || !await _tableExists(db, 'food_barcodes')) {
    return;
  }

  final probeBarcode = '99${historicalVersion.toString().padLeft(10, '0')}';
  final probeId = await db.insert('food_barcodes', {
    'food_id': fixture.foodId,
    'upc': probeBarcode,
  });
  await db.delete('food_barcodes', where: 'id = ?', whereArgs: [probeId]);

  expect(
    await db.query(
      'foods',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [fixture.foodId],
    ),
    hasLength(1),
  );
}

Future<void> _expectHistoricalDataPreserved(
  Database db,
  _HistoricalFixture fixture,
) async {
  final session =
      (await db.query(
        'sessions',
        where: 'id = ?',
        whereArgs: [fixture.sessionId],
      )).single;
  expect(session['duration'], 37);
  expect(
    session['completed_at_ms'],
    DateTime.parse(session['date'] as String).toUtc().millisecondsSinceEpoch,
  );
  expect(session['training_day'], (session['date'] as String).substring(0, 10));

  final measurement =
      (await db.query(
        'measurements',
        where: 'note = ?',
        whereArgs: [fixture.marker],
      )).single;
  expect(measurement['value'], 70.0);
  expect(
    measurement['measured_at_ms'],
    DateTime.parse(
      measurement['timestamp'] as String,
    ).toUtc().millisecondsSinceEpoch,
  );
  expect(
    measurement['measured_on'],
    (measurement['timestamp'] as String).substring(0, 10),
  );
  if (fixture.presetId != null) {
    final preset =
        (await db.query(
          'preset_definitions',
          where: 'id = ?',
          whereArgs: [fixture.presetId],
        )).single;
    expect(preset['name'], 'Plan ${fixture.marker}');
    expect(preset['is_draft'], 0);
  }
  if (fixture.hadPersonalInfo) {
    expect(
      (await db.query('personal_info')).single['name'],
      'Taylor ${fixture.marker}',
    );
  }
  if (fixture.foodId != null) {
    expect(
      (await db.query(
        'foods',
        where: 'id = ?',
        whereArgs: [fixture.foodId],
      )).single['name'],
      'Food ${fixture.marker}',
    );
  }
  if (fixture.barcode != null) {
    expect((await db.query('food_barcodes')).single['upc'], fixture.barcode);
  }
  if (fixture.hadActiveDraft) {
    expect(
      (await db.query('active_workout_draft')).single['payload_json'],
      '{"marker":"${fixture.marker}"}',
    );
  }
  if (fixture.mediaAssetId != null) {
    expect(
      (await db.query('exercise_media')).single['asset_id'],
      fixture.mediaAssetId,
    );
  }
}

Future<bool> _tableExists(Database db, String table) async {
  final rows = await db.rawQuery(
    "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ? LIMIT 1",
    [table],
  );
  return rows.isNotEmpty;
}

Future<Map<String, Object>> _schemaSignature(Database db) async {
  final tableRows = await db.rawQuery('''
    SELECT name
    FROM sqlite_master
    WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
    ORDER BY name
  ''');
  final signature = <String, Object>{};
  for (final tableRow in tableRows) {
    final table = tableRow['name']! as String;
    final columns = await db.rawQuery("PRAGMA table_info('$table')");
    final indexes = await db.rawQuery("PRAGMA index_list('$table')");
    final foreignKeys = await db.rawQuery("PRAGMA foreign_key_list('$table')");
    signature[table] = <String, Object>{
      'columns': [
        for (final column in columns)
          <String, Object?>{
            'name': column['name'],
            'type': column['type'],
            'notnull': column['notnull'],
            'default': column['dflt_value'],
            'primaryKey': column['pk'],
          },
      ],
      'indexes': [
        for (final index in indexes)
          if (!(index['name'] as String).startsWith('sqlite_autoindex_'))
            <String, Object?>{
              'name': index['name'],
              'unique': index['unique'],
              'partial': index['partial'],
            },
      ]..sort(
        (left, right) =>
            (left['name']! as String).compareTo(right['name']! as String),
      ),
      'foreignKeys': [
        for (final foreignKey in foreignKeys)
          <String, Object?>{
            'table': foreignKey['table'],
            'from': foreignKey['from'],
            'to': foreignKey['to'],
            'onUpdate': foreignKey['on_update'],
            'onDelete': foreignKey['on_delete'],
          },
      ]..sort(
        (left, right) => '${left['table']}.${left['from']}'.compareTo(
          '${right['table']}.${right['from']}',
        ),
      ),
    };
  }
  return signature;
}

class _HistoricalFixture {
  const _HistoricalFixture({
    required this.marker,
    required this.sessionId,
    required this.presetId,
    required this.foodId,
    required this.barcode,
    required this.hadPersonalInfo,
    required this.hadActiveDraft,
    required this.mediaAssetId,
  });

  final String marker;
  final int sessionId;
  final int? presetId;
  final int? foodId;
  final String? barcode;
  final bool hadPersonalInfo;
  final bool hadActiveDraft;
  final String? mediaAssetId;
}
