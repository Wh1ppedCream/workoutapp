import 'package:env_test/db/lookup_dao.dart';
import 'package:env_test/db/schema.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/services/measurement_validation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE measurement_definitions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        def_id INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        measured_at_ms INTEGER,
        measured_on TEXT,
        value REAL NOT NULL,
        unit TEXT NOT NULL,
        note TEXT,
        context TEXT
      )
    ''');
  });

  tearDown(() => db.close());

  test(
    'rejects duplicate definitions and validates direct DAO writes',
    () async {
      final definitionId = await LookupDao.insertMeasurementDefinition(
        db,
        name: '  Body mass  ',
        type: MeasurementType.Custom,
      );

      await expectLater(
        LookupDao.insertMeasurementDefinition(
          db,
          name: 'body mass',
          type: MeasurementType.Custom,
        ),
        throwsA(
          isA<MeasurementValidationException>().having(
            (error) => error.error,
            'error',
            MeasurementValidationError.duplicateName,
          ),
        ),
      );

      await expectLater(
        LookupDao.insertMeasurement(
          db,
          definitionId,
          DateTime.utc(2026, 8, 14),
          0,
          'kg',
          null,
          null,
        ),
        throwsA(isA<MeasurementValidationException>()),
      );

      final measurementId = await LookupDao.insertMeasurement(
        db,
        definitionId,
        DateTime.utc(2026, 8, 14),
        72.5,
        'kg',
        'Morning check-in',
        null,
      );
      final row = (await db.query(
        'measurements',
        where: 'id = ?',
        whereArgs: [measurementId],
      )).single;
      expect(row['note'], 'Morning check-in');
    },
  );

  test('height writes retain feet, inches and centimeters without rewriting history', () async {
    final definitionId = await LookupDao.insertMeasurementDefinition(
      db,
      name: 'Height',
      type: MeasurementType.Height,
    );
    for (final entry in [(6.0, 'ft'), (72.0, 'in'), (182.88, 'cm')]) {
      await LookupDao.insertMeasurement(
        db,
        definitionId,
        DateTime.utc(2026, 8, 14),
        entry.$1,
        entry.$2,
        null,
        null,
      );
    }
    final rows = await db.query('measurements', orderBy: 'id');
    expect(rows.map((row) => row['value']), [6.0, 72.0, 182.88]);
    expect(rows.map((row) => row['unit']), ['ft', 'in', 'cm']);
    await LookupDao.updateMeasurement(
      db: db,
      measurementId: rows.first['id'] as int,
      timestamp: DateTime.utc(2026, 8, 14),
      value: 5.5,
      unit: 'ft',
    );
    final updated = await db.query('measurements', orderBy: 'id');
    expect(updated.map((row) => row['value']), [5.5, 72.0, 182.88]);
    expect(updated.map((row) => row['unit']), ['ft', 'in', 'cm']);
  });

  test('migrates only recognized legacy context notes', () async {
    final bodyWeightId = await db.insert('measurement_definitions', {
      'name': 'BodyWeight',
      'type': MeasurementType.BodyWeight.name,
    });
    final customId = await db.insert('measurement_definitions', {
      'name': 'Check-in',
      'type': MeasurementType.Custom.name,
    });
    await db.insert('measurements', {
      'def_id': bodyWeightId,
      'timestamp': DateTime.utc(2026, 8, 14).toIso8601String(),
      'value': 72.5,
      'unit': 'kg',
      'note': 'WakeUp',
    });
    await db.insert('measurements', {
      'def_id': customId,
      'timestamp': DateTime.utc(2026, 8, 14).toIso8601String(),
      'value': 5,
      'unit': 'score',
      'note': 'With pump',
    });

    await Schema.migrateV59(db);

    final rows = await db.query('measurements', orderBy: 'id');
    expect(rows[0]['context'], MeasurementContext.wakeUp.name);
    expect(rows[0]['note'], isNull);
    expect(rows[1]['context'], isNull);
    expect(rows[1]['note'], 'With pump');
  });
}
