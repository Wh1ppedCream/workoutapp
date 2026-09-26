import 'package:env_test/db/personal_info_transaction_dao.dart';
import 'package:env_test/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE personal_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        gender TEXT,
        dob TEXT,
        height TEXT,
        weight TEXT,
        bodyfat_estimate TEXT,
        weight_trend TEXT,
        activity_level TEXT
      )
    ''');
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
        note TEXT
      )
    ''');
  });

  tearDown(() => db.close());

  test(
    'stores canonical profile weight and body-weight history together',
    () async {
      await PersonalInfoTransactionDao.save(
        db,
        info: PersonalInfo(name: 'Taylor', weight: '154'),
        bodyWeightValue: 70,
        bodyWeightUnit: WeightUnit.kilograms,
        measurementNote: 'Onboarding',
        measuredAt: DateTime.utc(2026, 7, 26),
      );

      expect((await db.query('personal_info')).single['weight'], '154');
      final measurement = (await db.query('measurements')).single;
      expect(measurement['value'], 70.0);
      expect(measurement['unit'], 'kg');
      expect(measurement['note'], 'Onboarding');
    },
  );

  test(
    'does not add duplicate history for the same normalized weight',
    () async {
      await PersonalInfoTransactionDao.save(
        db,
        info: PersonalInfo(weight: '154'),
        bodyWeightValue: 70,
        bodyWeightUnit: WeightUnit.kilograms,
      );
      await PersonalInfoTransactionDao.save(
        db,
        info: PersonalInfo(weight: '154'),
        bodyWeightValue: 154,
        bodyWeightUnit: WeightUnit.pounds,
      );

      expect(await db.query('measurements'), hasLength(1));
    },
  );

  test(
    'rolls back personal info if body-weight history cannot be saved',
    () async {
      await db.execute('DROP TABLE measurements');

      await expectLater(
        PersonalInfoTransactionDao.save(
          db,
          info: PersonalInfo(name: 'Taylor', weight: '154'),
          bodyWeightValue: 154,
          bodyWeightUnit: WeightUnit.pounds,
        ),
        throwsA(anything),
      );

      expect(await db.query('personal_info'), isEmpty);
      expect(await db.query('measurement_definitions'), isEmpty);
    },
  );
}
