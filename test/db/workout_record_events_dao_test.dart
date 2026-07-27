import 'package:env_test/db/workout_record_events_dao.dart';
import 'package:env_test/models/session_record_badge_models.dart';
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
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        exercise_def_id INTEGER,
        type TEXT NOT NULL,
        order_index INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        parent_set_id INTEGER
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

  test(
    'persists all-time and monthly awards in chronological history',
    () async {
      final januarySession = await _insertSession(db, DateTime(2026, 1, 15));
      final januaryExercise = await _insertWeightExercise(
        db,
        sessionId: januarySession,
        definitionId: 1,
        orderIndex: 0,
        sets: const [(100.0, 5)],
      );
      final februarySession = await _insertSession(db, DateTime(2026, 2, 2));
      final februaryExercise = await _insertWeightExercise(
        db,
        sessionId: februarySession,
        definitionId: 1,
        orderIndex: 0,
        sets: const [(140.0, 5)],
      );
      final marchSession = await _insertSession(db, DateTime(2026, 3, 2));
      final marchExercise = await _insertWeightExercise(
        db,
        sessionId: marchSession,
        definitionId: 1,
        orderIndex: 0,
        sets: const [(120.0, 5)],
      );

      await WorkoutRecordEventsDao.rebuildAll(db);

      final january =
          (await WorkoutRecordEventsDao.forSession(
            db,
            januarySession,
          ))[januaryExercise]!;
      final february =
          (await WorkoutRecordEventsDao.forSession(
            db,
            februarySession,
          ))[februaryExercise]!;
      final march =
          (await WorkoutRecordEventsDao.forSession(
            db,
            marchSession,
          ))[marchExercise]!;

      expect(january.isFirstRecord, isTrue);
      expect(
        _contains(
          january.forSet(0),
          WorkoutRecordBadgeType.repBest,
          WorkoutRecordBadgeTier.allTime,
          reps: 5,
        ),
        isTrue,
      );
      expect(
        _contains(
          january.forSet(0),
          WorkoutRecordBadgeType.volumeBest,
          WorkoutRecordBadgeTier.allTime,
        ),
        isTrue,
      );
      expect(february.isFirstRecord, isFalse);
      expect(
        _contains(
          february.forSet(0),
          WorkoutRecordBadgeType.repBest,
          WorkoutRecordBadgeTier.allTime,
          reps: 5,
        ),
        isTrue,
      );
      expect(
        _contains(
          march.forSet(0),
          WorkoutRecordBadgeType.repBest,
          WorkoutRecordBadgeTier.monthly,
          reps: 5,
        ),
        isTrue,
      );
      expect(
        _contains(
          march.forSet(0),
          WorkoutRecordBadgeType.repBest,
          WorkoutRecordBadgeTier.allTime,
          reps: 5,
        ),
        isFalse,
      );
      expect(
        _contains(
          march.forSet(0),
          WorkoutRecordBadgeType.volumeBest,
          WorkoutRecordBadgeTier.monthly,
        ),
        isTrue,
      );
    },
  );

  test(
    'rebuild moves first-record history after an earlier workout is removed',
    () async {
      final firstSession = await _insertSession(db, DateTime(2026, 1, 15));
      final firstExercise = await _insertWeightExercise(
        db,
        sessionId: firstSession,
        definitionId: 1,
        orderIndex: 0,
        sets: const [(100.0, 5)],
      );
      final secondSession = await _insertSession(db, DateTime(2026, 2, 15));
      final secondExercise = await _insertWeightExercise(
        db,
        sessionId: secondSession,
        definitionId: 1,
        orderIndex: 0,
        sets: const [(110.0, 5)],
      );

      await WorkoutRecordEventsDao.rebuildAll(db);
      expect(
        (await WorkoutRecordEventsDao.forSession(
          db,
          firstSession,
        ))[firstExercise]!.isFirstRecord,
        isTrue,
      );

      await db.delete(
        'sets',
        where: 'exercise_id = ?',
        whereArgs: [firstExercise],
      );
      await db.delete('exercises', where: 'id = ?', whereArgs: [firstExercise]);
      await db.delete('sessions', where: 'id = ?', whereArgs: [firstSession]);
      await WorkoutRecordEventsDao.rebuildForDefinitions(db, const [1]);

      final second =
          (await WorkoutRecordEventsDao.forSession(
            db,
            secondSession,
          ))[secondExercise]!;
      expect(second.isFirstRecord, isTrue);
      expect(
        _contains(
          second.forSet(0),
          WorkoutRecordBadgeType.repBest,
          WorkoutRecordBadgeTier.allTime,
          reps: 5,
        ),
        isTrue,
      );
    },
  );

  test('only parent sets receive persisted record awards', () async {
    final session = await _insertSession(db, DateTime(2026, 1, 15));
    final exercise = await _insertWeightExercise(
      db,
      sessionId: session,
      definitionId: 1,
      orderIndex: 0,
      sets: const [(100.0, 5)],
    );
    final parentSet =
        (await db.query(
              'sets',
              columns: const ['id'],
              where: 'exercise_id = ?',
              whereArgs: [exercise],
            )).single['id']
            as int;
    await db.insert('sets', {
      'exercise_id': exercise,
      'weight': 300.0,
      'reps': 5,
      'order_index': 0,
      'parent_set_id': parentSet,
    });

    await WorkoutRecordEventsDao.rebuildAll(db);

    final events = await db.query('workout_set_record_events');
    expect(events, hasLength(2));
    expect(events.every((event) => event['set_id'] == parentSet), isTrue);
  });
}

Future<int> _insertSession(Database db, DateTime date) {
  return db.insert('sessions', {
    'date': date.toIso8601String(),
    'duration': 3600,
  });
}

Future<int> _insertWeightExercise(
  Database db, {
  required int sessionId,
  required int definitionId,
  required int orderIndex,
  required List<(double, int)> sets,
}) async {
  final exerciseId = await db.insert('exercises', {
    'session_id': sessionId,
    'exercise_def_id': definitionId,
    'type': 'weight',
    'order_index': orderIndex,
  });
  for (var index = 0; index < sets.length; index++) {
    final set = sets[index];
    await db.insert('sets', {
      'exercise_id': exerciseId,
      'weight': set.$1,
      'reps': set.$2,
      'order_index': index,
      'parent_set_id': null,
    });
  }
  return exerciseId;
}

bool _contains(
  List<WorkoutRecordBadge> badges,
  WorkoutRecordBadgeType type,
  WorkoutRecordBadgeTier tier, {
  int? reps,
}) {
  return badges.any(
    (badge) => badge.type == type && badge.tier == tier && badge.reps == reps,
  );
}
