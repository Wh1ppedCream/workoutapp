import 'package:env_test/db/definition_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await _createSchema(db);
  });

  tearDown(() => db.close());

  test(
    'detailed definitions retain equipment and muscle catalog identities',
    () async {
      await db.insert('equipment', {
        'id': 1,
        'name': 'Barbell',
        'catalog_id': 'tonos.equipment.0001',
      });
      await db.insert('equipment', {
        'id': 2,
        'name': 'Adjustable Bench',
        'catalog_id': 'tonos.equipment.0002',
      });
      await db.insert('muscles', {
        'id': 10,
        'name': 'Pectoralis Major',
        'catalog_id': 'tonos.muscle.0001',
      });
      await db.insert('exercise_definitions', {
        'id': 1,
        'name': 'Bench Press - Barbell',
        'equipment_id': 1,
        'rating': 90,
      });
      await db.insert('exercise_equipment', {
        'exercise_id': 1,
        'equipment_id': 2,
      });
      await db.insert('exercise_muscle', {
        'exercise_id': 1,
        'muscle_id': 10,
        'rank': 1,
      });

      final definitions =
          await DefinitionDao.getAllExerciseDefinitionsDetailedBatched(db);

      expect(definitions, hasLength(1));
      expect(
        definitions.single.equipmentList.map((equipment) => equipment.id),
        [1, 2],
      );
      expect(
        definitions.single.equipmentList.first.catalogId,
        'tonos.equipment.0001',
      );
      expect(
        definitions.single.muscles.single.muscle.catalogId,
        'tonos.muscle.0001',
      );

      final batched = await DefinitionDao.getExerciseDefinitionsDetailedByIds(
        db,
        [1],
      );
      expect(
        batched.single.equipmentList.first.catalogId,
        'tonos.equipment.0001',
      );
      expect(
        batched.single.muscles.single.muscle.catalogId,
        'tonos.muscle.0001',
      );
    },
  );
}

Future<void> _createSchema(Database db) async {
  await db.execute('''
    CREATE TABLE exercise_definitions (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      equipment_id INTEGER,
      rating INTEGER NOT NULL DEFAULT 0
    )
  ''');
  await db.execute('''
    CREATE TABLE equipment (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      catalog_id TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE exercise_equipment (
      exercise_id INTEGER NOT NULL,
      equipment_id INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE bodypart (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE exercise_bodypart (
      exercise_id INTEGER NOT NULL,
      bodypart_id INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE muscles (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      catalog_id TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE exercise_muscle (
      exercise_id INTEGER NOT NULL,
      muscle_id INTEGER NOT NULL,
      rank INTEGER NOT NULL
    )
  ''');
}
