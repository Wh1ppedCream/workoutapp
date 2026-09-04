import 'package:env_test/db/preset_progression_dao.dart';
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
      CREATE TABLE preset_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_exercise_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL CHECK(reps >= 0),
        order_index INTEGER NOT NULL,
        parent_set_id INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE preset_exercise_auto (
        preset_exercise_id INTEGER PRIMARY KEY,
        increment_amount REAL,
        last_set_index INTEGER NOT NULL,
        last_node TEXT
      )
    ''');
    await db.insert('preset_sets', {
      'id': 1,
      'preset_exercise_id': 10,
      'weight': 100.0,
      'reps': 5,
      'order_index': 0,
      'parent_set_id': null,
    });
    await db.insert('preset_sets', {
      'id': 2,
      'preset_exercise_id': 10,
      'weight': 90.0,
      'reps': 8,
      'order_index': 1,
      'parent_set_id': null,
    });
  });

  tearDown(() => db.close());

  test('commits set and traversal mutations together', () async {
    await PresetProgressionDao.apply(
      db,
      const PresetProgressionBatch(
        updates: [
          PresetSetProgressionUpdate(
            setId: 1,
            weight: 105,
            reps: 5,
            orderIndex: 0,
          ),
        ],
        deletedSetIds: [2],
        inserts: [
          PresetSetProgressionInsert(
            presetExerciseId: 10,
            weight: 80,
            reps: 10,
            orderIndex: 1,
          ),
        ],
        exerciseStates: [
          PresetExerciseProgressionState(
            presetExerciseId: 10,
            incrementAmount: 5,
            lastSetIndex: 2,
            lastNode: 'success2',
          ),
        ],
      ),
    );

    final sets = await db.query('preset_sets', orderBy: 'order_index');
    expect(sets, hasLength(2));
    expect(sets.first['weight'], 105.0);
    expect(sets.last['weight'], 80.0);
    final state = (await db.query('preset_exercise_auto')).single;
    expect(state['last_set_index'], 2);
    expect(state['last_node'], 'success2');
  });

  test('rolls back every mutation when one progression write fails', () async {
    await expectLater(
      PresetProgressionDao.apply(
        db,
        const PresetProgressionBatch(
          updates: [
            PresetSetProgressionUpdate(
              setId: 1,
              weight: 105,
              reps: 5,
              orderIndex: 0,
            ),
          ],
          inserts: [
            PresetSetProgressionInsert(
              presetExerciseId: 10,
              weight: 80,
              reps: -1,
              orderIndex: 2,
            ),
          ],
        ),
      ),
      throwsA(anything),
    );

    final sets = await db.query('preset_sets', orderBy: 'order_index');
    expect(sets, hasLength(2));
    expect(sets.first['weight'], 100.0);
    expect(await db.query('preset_exercise_auto'), isEmpty);
  });

  test('rejects malformed mutations before any preset write', () async {
    await expectLater(
      PresetProgressionDao.apply(
        db,
        const PresetProgressionBatch(
          updates: [
            PresetSetProgressionUpdate(
              setId: 1,
              weight: 105,
              reps: 5,
              orderIndex: 0,
            ),
          ],
          deletedSetIds: [1],
        ),
      ),
      throwsArgumentError,
    );

    final sets = await db.query('preset_sets', orderBy: 'order_index');
    expect(sets, hasLength(2));
    expect(sets.first['weight'], 100.0);
  });
}
