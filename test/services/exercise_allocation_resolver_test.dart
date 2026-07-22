import 'package:env_test/db/exercise_allocation_dao.dart';
import 'package:env_test/models/exercise_allocation_models.dart';
import 'package:env_test/services/exercise_allocation_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await _createSchema(db);
    await _seedExercise(db);
  });

  tearDown(() => db.close());

  test(
    'automatic allocation preserves ranked focus and legacy muscle history',
    () async {
      final allocation = await ExerciseAllocationResolver.resolve(db, 1);

      expect(allocation.muscleSource, ExerciseAllocationSource.automatic);
      expect(allocation.bodyPartSource, ExerciseAllocationSource.automatic);
      expect(allocation.muscleCredits, {1: 1.0, 2: 0.85});
      expect(allocation.bodyPartCredits, {10: 1.0, 20: 0.85});
      expect(allocation.muscleHistoryCredits, {1: 1.0, 2: 1.0});
      expect(allocation.bodyPartHistoryCredits, {10: 1.0, 20: 0.85});
    },
  );

  test(
    'personal muscle credits override focus, derived body parts, and history',
    () async {
      await ExerciseAllocationDao.replacePersonalCredits(
        db,
        exerciseDefinitionId: 1,
        dimension: ExerciseAllocationDimension.muscle,
        credits: const {1: 0.70, 2: 0.35},
      );

      final allocation = await ExerciseAllocationResolver.resolve(db, 1);

      expect(
        allocation.muscleSource,
        ExerciseAllocationSource.personalOverride,
      );
      expect(allocation.muscleCredits, {1: 0.70, 2: 0.35});
      expect(allocation.bodyPartCredits, {10: 1.0, 20: 0.5});
      expect(allocation.muscleHistoryCredits, {1: 0.70, 2: 0.35});
    },
  );

  test(
    'creator bodypart defaults replace only bodypart calculations',
    () async {
      await ExerciseAllocationDao.replaceCreatorCredits(
        db,
        exerciseDefinitionId: 1,
        dimension: ExerciseAllocationDimension.bodyPart,
        credits: const {10: 0.90, 20: 0.25},
      );

      final allocation = await ExerciseAllocationResolver.resolve(db, 1);

      expect(allocation.muscleSource, ExerciseAllocationSource.automatic);
      expect(
        allocation.bodyPartSource,
        ExerciseAllocationSource.creatorDefault,
      );
      expect(allocation.bodyPartCredits, {10: 0.90, 20: 0.25});
      expect(allocation.muscleHistoryCredits, {1: 1.0, 2: 1.0});
      expect(allocation.bodyPartHistoryCredits, {10: 0.90, 20: 0.25});
    },
  );

  test(
    'legacy rows remain compatible until a personal allocation is saved',
    () async {
      await db.insert('exercise_muscle_percent', {
        'exercise_def_id': 1,
        'muscle_id': 2,
        'percent': 0.50,
      });

      final legacy = await ExerciseAllocationResolver.resolve(db, 1);
      expect(legacy.muscleSource, ExerciseAllocationSource.legacy);
      expect(legacy.muscleCredits, {1: 1.0, 2: 0.50});
      expect(legacy.muscleHistoryCredits, {1: 1.0, 2: 0.50});

      await ExerciseAllocationDao.replacePersonalCredits(
        db,
        exerciseDefinitionId: 1,
        dimension: ExerciseAllocationDimension.muscle,
        credits: const {1: 0.80, 2: 0.40},
      );
      await ExerciseAllocationDao.resetPersonalCredits(
        db,
        exerciseDefinitionId: 1,
        dimension: ExerciseAllocationDimension.muscle,
      );

      final reset = await ExerciseAllocationResolver.resolve(db, 1);
      expect(reset.muscleSource, ExerciseAllocationSource.legacy);
      expect(reset.muscleCredits, {1: 1.0, 2: 0.50});
    },
  );
}

Future<void> _createSchema(Database db) async {
  await db.execute('''
    CREATE TABLE exercise_definitions (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      equipment_id INTEGER,
      rating INTEGER NOT NULL DEFAULT 0,
      use_manual_muscles INTEGER NOT NULL DEFAULT 1,
      use_manual_bodyparts INTEGER NOT NULL DEFAULT 0,
      multiply_by_rating INTEGER NOT NULL DEFAULT 0
    )
  ''');
  await db.execute(
    'CREATE TABLE equipment (id INTEGER PRIMARY KEY, name TEXT)',
  );
  await db.execute('CREATE TABLE muscles (id INTEGER PRIMARY KEY, name TEXT)');
  await db.execute('CREATE TABLE bodypart (id INTEGER PRIMARY KEY, name TEXT)');
  await db.execute('''
    CREATE TABLE exercise_muscle (
      exercise_id INTEGER NOT NULL,
      muscle_id INTEGER NOT NULL,
      rank INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE exercise_bodypart (
      exercise_id INTEGER NOT NULL,
      bodypart_id INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE exercise_equipment (
      exercise_id INTEGER NOT NULL,
      equipment_id INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE muscle_bodypart (
      muscle_id INTEGER NOT NULL,
      bodypart_id INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE exercise_muscle_percent (
      exercise_def_id INTEGER NOT NULL,
      muscle_id INTEGER NOT NULL,
      percent REAL NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE exercise_bodypart_percent (
      exercise_def_id INTEGER NOT NULL,
      bodypart_id INTEGER NOT NULL,
      percent REAL NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE exercise_allocation_source (
      exercise_def_id INTEGER PRIMARY KEY,
      muscle_mode TEXT NOT NULL DEFAULT 'automatic',
      bodypart_mode TEXT NOT NULL DEFAULT 'automatic'
    )
  ''');
  await db.execute('''
    CREATE TABLE exercise_allocation_creator_default (
      exercise_def_id INTEGER NOT NULL,
      dimension TEXT NOT NULL,
      target_id INTEGER NOT NULL,
      credit REAL NOT NULL,
      PRIMARY KEY(exercise_def_id, dimension, target_id)
    )
  ''');
  await db.execute('''
    CREATE TABLE exercise_allocation_user_override (
      exercise_def_id INTEGER NOT NULL,
      dimension TEXT NOT NULL,
      target_id INTEGER NOT NULL,
      credit REAL NOT NULL,
      PRIMARY KEY(exercise_def_id, dimension, target_id)
    )
  ''');
}

Future<void> _seedExercise(Database db) async {
  await db.insert('exercise_definitions', {
    'id': 1,
    'name': 'Example press',
    'use_manual_muscles': 1,
    'use_manual_bodyparts': 0,
  });
  await db.insert('muscles', {'id': 1, 'name': 'Chest'});
  await db.insert('muscles', {'id': 2, 'name': 'Triceps'});
  await db.insert('bodypart', {'id': 10, 'name': 'Chest'});
  await db.insert('bodypart', {'id': 20, 'name': 'Arms'});
  await db.insert('exercise_muscle', {
    'exercise_id': 1,
    'muscle_id': 1,
    'rank': 1,
  });
  await db.insert('exercise_muscle', {
    'exercise_id': 1,
    'muscle_id': 2,
    'rank': 2,
  });
  await db.insert('exercise_bodypart', {'exercise_id': 1, 'bodypart_id': 10});
  await db.insert('exercise_bodypart', {'exercise_id': 1, 'bodypart_id': 20});
  await db.insert('muscle_bodypart', {'muscle_id': 1, 'bodypart_id': 10});
  await db.insert('muscle_bodypart', {'muscle_id': 2, 'bodypart_id': 20});
}
