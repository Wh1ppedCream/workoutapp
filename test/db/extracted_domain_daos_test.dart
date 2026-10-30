import 'dart:convert';

import 'package:env_test/db/catalog_json_export_dao.dart';
import 'package:env_test/db/database_metadata_dao.dart';
import 'package:env_test/db/food_fts_maintenance_dao.dart';
import 'package:env_test/db/measurement_dao.dart';
import 'package:env_test/db/ranking_and_volume_dao.dart';
import 'package:env_test/db/schema.dart';
import 'package:env_test/db/schema_repair_dao.dart';
import 'package:env_test/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await Schema.createTables(db);
  });
  tearDown(() => db.close());

  test('schema repairs are repeatable and preserve existing data', () async {
    final id = await db.insert('equipment', {'name': 'Kept equipment'});
    for (var attempt = 0; attempt < 2; attempt++) {
      await SchemaRepairDao.ensureSchemaRepairs(db);
      await SchemaRepairDao.ensureExerciseMediaTable(db);
      await SchemaRepairDao.ensureFavoriteFoodsShape(db);
    }
    expect(await DatabaseMetadataDao.tableExists(db, 'exercise_media'), isTrue);
    expect(
      await DatabaseMetadataDao.tableHasColumn(
        db,
        'nutrition_goals',
        'protein_g',
      ),
      isTrue,
    );
    expect(
      (await db.query(
        'equipment',
        where: 'id = ?',
        whereArgs: [id],
      )).single['name'],
      'Kept equipment',
    );
  });

  test('measurement CRUD keeps units, timestamps and context intact', () async {
    final dao = MeasurementDao(db);
    final def = await dao.insertMeasurementDefinition(
      name: 'Test weight',
      type: MeasurementType.BodyWeight,
    );
    final at = DateTime(2026, 10, 30, 10);
    final id = await dao.insertMeasurement(def, at, 100, 'kg', 'note', null);
    expect(await dao.fetchLatestBodyWeightLbs(), closeTo(220.462, .001));
    final measurement = (await dao.fetchClassMeasurementsForDefinition(def))
        .single;
    expect(measurement.timestamp, at);
    expect(measurement.note, 'note');
    await dao.updateMeasurement(
      measurementId: id,
      timestamp: at,
      value: 200,
      unit: 'lbs',
      note: 'updated',
    );
    expect(await dao.fetchLatestBodyWeightLbs(), 200);
    await dao.deleteMeasurement(id);
    expect(await dao.fetchMeasurementsRaw(def), isEmpty);
  });

  test('measurement DAO participates in its caller transaction', () async {
    await expectLater(
      db.transaction((txn) async {
        await MeasurementDao(txn).insertMeasurementDefinition(
          name: 'Rolled back',
          type: MeasurementType.Custom,
        );
        throw StateError('abort');
      }),
      throwsStateError,
    );
    expect(
      await MeasurementDao(db).fetchMeasurementDefinitionId('Rolled back'),
      isNull,
    );
  });

  test('ranking, stats and catalog exports retain their payloads', () async {
    final bodypart = await db.insert('bodypart', {'name': 'Test bodypart'});
    final muscle = await db.insert('muscles', {'name': 'Test muscle'});
    final definition = await db.insert('exercise_definitions', {
      'name': 'Test exercise',
    });
    final dao = RankingAndVolumeDao(db);
    await dao.linkMuscleToBodyPart(muscle, bodypart);
    await dao.setBodyPartRank(bodypart, 2);
    await dao.setMuscleRank(muscle, 3);
    await dao.upsertRepMax(definition, 5, 'all', 100, 116, false);
    await dao.upsertVolumeMax(definition, 'all', 1500);
    expect((await dao.getBodyPartRank(bodypart))!.rank, 2);
    expect((await dao.fetchRepMaxes(definition, 'all')).single.repCount, 5);
    expect(await dao.fetchVolumeMax(definition, 'all'), 1500);
    final exporter = CatalogJsonExportDao(db);
    expect(jsonDecode(await exporter.exportBodypartsJson()), [
      {'name': 'Test bodypart'},
    ]);
    expect(jsonDecode(await exporter.exportMuscleBodypartJson()), [
      {
        'bodypart': 'Test bodypart',
        'muscles': ['Test muscle'],
      },
    ]);
    expect(jsonDecode(await exporter.exportBodypartRankingJson()), [
      {'bodypart': 'Test bodypart', 'rank': 2},
    ]);
  });

  test('empty time-range volume queries retain their empty results', () async {
    final dao = RankingAndVolumeDao(db);
    final start = DateTime(2026, 10, 1);
    final end = DateTime(2026, 10, 30);
    expect(
      await dao.fetchAllBodyPartSetsOverTimeRange(start: start, end: end),
      isEmpty,
    );
    expect(
      await dao.fetchAllMuscleSetsOverTimeRange(start: start, end: end),
      isEmpty,
    );
    expect(await dao.calculateTotalVolumeForSessions([]), 0);
  });

  test(
    'food trigger ownership and maintenance flags remain idempotent',
    () async {
      await FoodFtsMaintenanceDao.ensureAppMetaTable(db);
      await FoodFtsMaintenanceDao.resetDbTriggers(db);
      await FoodFtsMaintenanceDao.resetDbTriggers(db);
      expect(
        await FoodFtsMaintenanceDao.getAppMeta(db, 'open_trigger_reset_v1'),
        startsWith('done:'),
      );
      await FoodFtsMaintenanceDao.ensureFoodFtsTriggers(db);
      await FoodFtsMaintenanceDao.dropFoodFtsTriggers(db);
      final triggers = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'trigger' AND name IN ('foods_ai','foods_ad','foods_au')",
      );
      expect(triggers, isEmpty);
    },
  );
}
