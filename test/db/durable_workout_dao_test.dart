import 'package:env_test/db/active_workout_dao.dart';
import 'package:env_test/db/workout_record_events_dao.dart';
import 'package:env_test/db/workout_transaction_dao.dart';
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
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        duration INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE equipment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE exercise_definitions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        equipment_id INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE exercise_equipment (
        exercise_id INTEGER NOT NULL,
        equipment_id INTEGER NOT NULL
      )
    ''');
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
        reps INTEGER NOT NULL CHECK(reps >= 0),
        order_index INTEGER NOT NULL,
        parent_set_id INTEGER,
        source_preset_set_id INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE cardio_details (
        exercise_id INTEGER PRIMARY KEY,
        cardio_name TEXT,
        note TEXT,
        planned_minutes INTEGER,
        elapsed_seconds INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE stretch_instance_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        stretch_id INTEGER,
        is_custom INTEGER NOT NULL,
        custom_name TEXT,
        custom_desc TEXT,
        is_checked INTEGER NOT NULL,
        order_index INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE exercise_rep_max (
        def_id INTEGER NOT NULL,
        rep_count INTEGER NOT NULL,
        timeframe TEXT NOT NULL,
        rm_value REAL NOT NULL,
        one_erm REAL NOT NULL,
        is_erm INTEGER NOT NULL,
        PRIMARY KEY(def_id, rep_count, timeframe)
      )
    ''');
    await db.execute('''
      CREATE TABLE exercise_volume_max (
        def_id INTEGER NOT NULL,
        timeframe TEXT NOT NULL,
        vm_value REAL NOT NULL,
        PRIMARY KEY(def_id, timeframe)
      )
    ''');
    await db.execute('''
      CREATE TABLE active_workout_draft (
        id INTEGER PRIMARY KEY CHECK(id = 1),
        started_at TEXT NOT NULL,
        auto_preset_id INTEGER,
        payload_json TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE workout_exercise_record_events (
        exercise_id INTEGER PRIMARY KEY,
        is_first_record INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE workout_set_record_events (
        set_id INTEGER NOT NULL,
        badge_type TEXT NOT NULL,
        badge_tier TEXT NOT NULL,
        reps INTEGER,
        PRIMARY KEY(set_id, badge_type)
      )
    ''');
  });

  tearDown(() => db.close());

  test('draft is replaced in place and can be cleared', () async {
    final startedAt = DateTime.utc(2026, 7, 13, 12);
    await ActiveWorkoutDao.save(
      db,
      startedAt: startedAt,
      autoPresetId: null,
      payloadJson: '{"version":1}',
    );
    await ActiveWorkoutDao.save(
      db,
      startedAt: startedAt,
      autoPresetId: null,
      payloadJson: '{"version":2}',
    );

    final draft = await ActiveWorkoutDao.load(db);
    expect(draft?['payload_json'], '{"version":2}');
    expect(await db.query('active_workout_draft'), hasLength(1));

    await ActiveWorkoutDao.clear(db);
    expect(await ActiveWorkoutDao.load(db), isNull);
  });

  test('completion commits history and removes the draft together', () async {
    await ActiveWorkoutDao.save(
      db,
      startedAt: DateTime.utc(2026, 7, 13, 12),
      autoPresetId: null,
      payloadJson: '{}',
    );

    final sessionId = await WorkoutTransactionDao.completeWorkout(
      db,
      completedAt: DateTime.utc(2026, 7, 13, 13),
      durationSeconds: 3600,
      exercises: [
        WorkoutExerciseWrite(
          exercise: WeightExercise(
            name: 'Bench Press',
            equipment: 'Barbell',
            sets: [ExerciseSet(weight: 135, reps: 5)],
          ),
          type: 'weight',
        ),
      ],
    );

    expect(sessionId, 1);
    expect(await db.query('sessions'), hasLength(1));
    expect(await db.query('sets'), hasLength(1));
    expect(await ActiveWorkoutDao.load(db), isNull);
    final badges =
        (await WorkoutRecordEventsDao.forSession(db, sessionId)).values.single;
    expect(badges.isFirstRecord, isTrue);
    expect(
      badges
          .forSet(0)
          .any(
            (badge) =>
                badge.type == WorkoutRecordBadgeType.repBest &&
                badge.tier == WorkoutRecordBadgeTier.allTime &&
                badge.reps == 5,
          ),
      isTrue,
    );
  });

  test('failed completion keeps both draft and history unchanged', () async {
    await ActiveWorkoutDao.save(
      db,
      startedAt: DateTime.utc(2026, 7, 13, 12),
      autoPresetId: null,
      payloadJson: '{}',
    );

    await expectLater(
      WorkoutTransactionDao.completeWorkout(
        db,
        completedAt: DateTime.utc(2026, 7, 13, 13),
        durationSeconds: 3600,
        exercises: [
          WorkoutExerciseWrite(
            exercise: WeightExercise(
              name: 'Bench Press',
              equipment: 'Barbell',
              sets: [ExerciseSet(weight: 135, reps: -1)],
            ),
            type: 'weight',
          ),
        ],
      ),
      throwsA(anything),
    );

    expect(await db.query('sessions'), isEmpty);
    expect(await db.query('exercises'), isEmpty);
    expect(await ActiveWorkoutDao.load(db), isNotNull);
  });

  test('empty completion cannot create a history session', () async {
    await ActiveWorkoutDao.save(
      db,
      startedAt: DateTime.utc(2026, 7, 13, 12),
      autoPresetId: null,
      payloadJson: '{}',
    );

    expect(
      () => WorkoutTransactionDao.completeWorkout(
        db,
        completedAt: DateTime.utc(2026, 7, 13, 13),
        durationSeconds: 120,
        exercises: const <WorkoutExerciseWrite>[],
      ),
      throwsArgumentError,
    );

    expect(await db.query('sessions'), isEmpty);
    expect(await ActiveWorkoutDao.load(db), isNotNull);
  });
}
