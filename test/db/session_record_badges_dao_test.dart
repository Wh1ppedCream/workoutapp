import 'package:env_test/db/session_record_badges_dao.dart';
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
  });

  tearDown(() => db.close());

  test(
    'first completed exercise receives first-record and gold badges',
    () async {
      final sessionId = await _insertSession(db, DateTime(2026, 7, 15, 10));
      final exerciseId = await _insertWeightExercise(
        db,
        sessionId: sessionId,
        definitionId: 1,
        orderIndex: 0,
        sets: const [(100.0, 5), (90.0, 8)],
      );

      final result = await SessionRecordBadgesDao.forSession(db, sessionId);
      final badges = result[exerciseId]!;

      expect(badges.isFirstRecord, isTrue);
      expect(
        _contains(
          badges.forSet(0),
          WorkoutRecordBadgeType.repBest,
          WorkoutRecordBadgeTier.allTime,
          reps: 5,
        ),
        isTrue,
      );
      expect(
        _contains(
          badges.forSet(1),
          WorkoutRecordBadgeType.repBest,
          WorkoutRecordBadgeTier.allTime,
          reps: 8,
        ),
        isTrue,
      );
      expect(
        _contains(
          badges.forSet(1),
          WorkoutRecordBadgeType.volumeBest,
          WorkoutRecordBadgeTier.allTime,
        ),
        isTrue,
      );
    },
  );

  test('monthly best is awarded when all-time best remains higher', () async {
    await _insertCompletedWeightSession(
      db,
      date: DateTime(2026, 6, 15, 10),
      definitionId: 1,
      sets: const [(120.0, 5)],
    );
    await _insertCompletedWeightSession(
      db,
      date: DateTime(2026, 7, 2, 10),
      definitionId: 1,
      sets: const [(100.0, 5)],
    );
    final sessionId = await _insertSession(db, DateTime(2026, 7, 15, 10));
    final exerciseId = await _insertWeightExercise(
      db,
      sessionId: sessionId,
      definitionId: 1,
      orderIndex: 0,
      sets: const [(110.0, 5)],
    );

    final badges =
        (await SessionRecordBadgesDao.forSession(db, sessionId))[exerciseId]!;

    expect(
      _contains(
        badges.forSet(0),
        WorkoutRecordBadgeType.repBest,
        WorkoutRecordBadgeTier.monthly,
        reps: 5,
      ),
      isTrue,
    );
    expect(
      _contains(
        badges.forSet(0),
        WorkoutRecordBadgeType.repBest,
        WorkoutRecordBadgeTier.allTime,
        reps: 5,
      ),
      isFalse,
    );
  });

  test('all-time record suppresses the matching monthly record', () async {
    await _insertCompletedWeightSession(
      db,
      date: DateTime(2026, 6, 15, 10),
      definitionId: 1,
      sets: const [(100.0, 5)],
    );
    await _insertCompletedWeightSession(
      db,
      date: DateTime(2026, 7, 2, 10),
      definitionId: 1,
      sets: const [(110.0, 5)],
    );
    final sessionId = await _insertSession(db, DateTime(2026, 7, 15, 10));
    final exerciseId = await _insertWeightExercise(
      db,
      sessionId: sessionId,
      definitionId: 1,
      orderIndex: 0,
      sets: const [(120.0, 5)],
    );

    final badges =
        (await SessionRecordBadgesDao.forSession(db, sessionId))[exerciseId]!;

    expect(
      _contains(
        badges.forSet(0),
        WorkoutRecordBadgeType.repBest,
        WorkoutRecordBadgeTier.allTime,
        reps: 5,
      ),
      isTrue,
    );
    expect(
      _contains(
        badges.forSet(0),
        WorkoutRecordBadgeType.repBest,
        WorkoutRecordBadgeTier.monthly,
        reps: 5,
      ),
      isFalse,
    );
    expect(
      _contains(
        badges.forSet(0),
        WorkoutRecordBadgeType.volumeBest,
        WorkoutRecordBadgeTier.allTime,
      ),
      isTrue,
    );
  });

  test(
    'rep records compare only the same rep count and use the strongest set',
    () async {
      await _insertCompletedWeightSession(
        db,
        date: DateTime(2026, 7, 1, 10),
        definitionId: 1,
        sets: const [(250.0, 3), (100.0, 5)],
      );
      final sessionId = await _insertSession(db, DateTime(2026, 7, 15, 10));
      final exerciseId = await _insertWeightExercise(
        db,
        sessionId: sessionId,
        definitionId: 1,
        orderIndex: 0,
        sets: const [(105.0, 5), (115.0, 5), (200.0, 8)],
      );

      final badges =
          (await SessionRecordBadgesDao.forSession(db, sessionId))[exerciseId]!;

      expect(
        _contains(
          badges.forSet(0),
          WorkoutRecordBadgeType.repBest,
          WorkoutRecordBadgeTier.allTime,
          reps: 5,
        ),
        isFalse,
      );
      expect(
        _contains(
          badges.forSet(1),
          WorkoutRecordBadgeType.repBest,
          WorkoutRecordBadgeTier.allTime,
          reps: 5,
        ),
        isTrue,
      );
      expect(
        _contains(
          badges.forSet(2),
          WorkoutRecordBadgeType.repBest,
          WorkoutRecordBadgeTier.allTime,
          reps: 8,
        ),
        isTrue,
      );
    },
  );

  test(
    'later duplicate exercise instances compare against earlier instances',
    () async {
      final sessionId = await _insertSession(db, DateTime(2026, 7, 15, 10));
      final firstExerciseId = await _insertWeightExercise(
        db,
        sessionId: sessionId,
        definitionId: 1,
        orderIndex: 0,
        sets: const [(100.0, 5)],
      );
      final secondExerciseId = await _insertWeightExercise(
        db,
        sessionId: sessionId,
        definitionId: 1,
        orderIndex: 1,
        sets: const [(110.0, 5)],
      );

      final result = await SessionRecordBadgesDao.forSession(db, sessionId);

      expect(result[firstExerciseId]!.isFirstRecord, isTrue);
      expect(result[secondExerciseId]!.isFirstRecord, isFalse);
      expect(
        _contains(
          result[secondExerciseId]!.forSet(0),
          WorkoutRecordBadgeType.repBest,
          WorkoutRecordBadgeTier.allTime,
          reps: 5,
        ),
        isTrue,
      );
    },
  );
}

Future<int> _insertCompletedWeightSession(
  Database db, {
  required DateTime date,
  required int definitionId,
  required List<(double, int)> sets,
}) async {
  final sessionId = await _insertSession(db, date);
  await _insertWeightExercise(
    db,
    sessionId: sessionId,
    definitionId: definitionId,
    orderIndex: 0,
    sets: sets,
  );
  return sessionId;
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
