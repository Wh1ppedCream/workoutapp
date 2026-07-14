import 'package:env_test/db/exercise_dao.dart';
import 'package:env_test/db/set_dao.dart';
import 'package:env_test/models/workout_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        exercise_def_id INTEGER,
        type TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        source_preset_exercise_id INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        parent_set_id INTEGER,
        source_preset_set_id INTEGER
      )
    ''');
  });

  tearDown(() => db.close());

  test('persists source plan IDs on completed workout rows', () async {
    final exerciseId = await ExerciseDao.insertExerciseRow(
      db: db,
      exerciseDefId: 7,
      type: 'weight',
      orderIndex: 0,
      sessionId: 1,
      sourcePresetExerciseId: 41,
    );
    await SetDao.insertWeightSets(
      db: db,
      exerciseId: exerciseId,
      parentSets: [ExerciseSet(sourcePresetSetId: 51, weight: 100, reps: 5)],
      childChangeSets: {
        0: [ExerciseSet(sourcePresetSetId: 52, weight: 80, reps: 8)],
      },
    );

    final exercise = (await db.query('exercises')).single;
    expect(exercise['source_preset_exercise_id'], 41);
    final sets = await db.query('sets', orderBy: 'id');
    expect(sets.first['source_preset_set_id'], 51);
    expect(sets.last['source_preset_set_id'], 52);
  });
}
