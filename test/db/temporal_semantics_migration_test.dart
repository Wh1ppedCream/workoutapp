import 'package:env_test/db/lookup_dao.dart';
import 'package:env_test/db/nutrition_dao.dart';
import 'package:env_test/db/schema.dart';
import 'package:env_test/db/session_dao.dart';
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
        value REAL NOT NULL,
        unit TEXT NOT NULL,
        note TEXT,
        context TEXT
      )
    ''');
  });

  tearDown(() => db.close());

  test(
    'migrates legacy timestamps without changing their visible calendar day',
    () async {
      const sessionIso = '2026-03-08T00:30:00-05:00';
      const measurementIso = '2026-11-01T23:30:00+01:00';
      final definitionId = await db.insert('measurement_definitions', {
        'name': 'BodyWeight',
        'type': MeasurementType.BodyWeight.name,
      });
      final sessionId = await db.insert('sessions', {
        'date': sessionIso,
        'duration': 60,
      });
      final measurementId = await db.insert('measurements', {
        'def_id': definitionId,
        'timestamp': measurementIso,
        'value': 70,
        'unit': 'kg',
      });

      await Schema.migrateV61(db);
      await Schema.migrateV61(db);

      final session =
          (await db.query(
            'sessions',
            where: 'id = ?',
            whereArgs: [sessionId],
          )).single;
      expect(session['date'], sessionIso);
      expect(session['training_day'], '2026-03-08');
      expect(
        session['completed_at_ms'],
        DateTime.parse(sessionIso).toUtc().millisecondsSinceEpoch,
      );

      final measurement =
          (await db.query(
            'measurements',
            where: 'id = ?',
            whereArgs: [measurementId],
          )).single;
      expect(measurement['timestamp'], measurementIso);
      expect(measurement['measured_on'], '2026-11-01');
      expect(
        measurement['measured_at_ms'],
        DateTime.parse(measurementIso).toUtc().millisecondsSinceEpoch,
      );
    },
  );

  test(
    'new session and measurement writes populate canonical fields',
    () async {
      await Schema.migrateV61(db);
      final definitionId = await db.insert('measurement_definitions', {
        'name': 'BodyWeight',
        'type': MeasurementType.BodyWeight.name,
      });
      final completedAt = DateTime(2026, 3, 8, 23, 45);
      final sessionId = await SessionDao.insertSession(
        db,
        completedAt: completedAt,
        duration: 1800,
      );
      final measurementId = await LookupDao.insertMeasurement(
        db,
        definitionId,
        completedAt,
        72.5,
        'kg',
        null,
        null,
      );

      final session =
          (await db.query(
            'sessions',
            where: 'id = ?',
            whereArgs: [sessionId],
          )).single;
      expect(session['training_day'], '2026-03-08');
      expect(
        session['completed_at_ms'],
        completedAt.toUtc().millisecondsSinceEpoch,
      );
      final sessionsForDay = await SessionDao.getSessionsForCalendarRange(
        db,
        const LocalCalendarDay(2026, 3, 8),
        const LocalCalendarDay(2026, 3, 8),
      );
      expect(sessionsForDay.single['id'], sessionId);
      final sessionsForInstant = await SessionDao.getSessionsForInstantRange(
        db,
        completedAt.subtract(const Duration(seconds: 1)),
        completedAt.add(const Duration(seconds: 1)),
      );
      expect(sessionsForInstant.single['id'], sessionId);

      final measurement =
          (await db.query(
            'measurements',
            where: 'id = ?',
            whereArgs: [measurementId],
          )).single;
      expect(measurement['measured_on'], '2026-03-08');
      expect(
        measurement['measured_at_ms'],
        completedAt.toUtc().millisecondsSinceEpoch,
      );
    },
  );

  test(
    'instant and calendar session ranges keep their separate contracts',
    () async {
      await Schema.migrateV61(db);
      final completedAt = DateTime.utc(2026, 3, 9, 2, 30);
      final sessionId = await SessionDao.insertSession(
        db,
        completedAt: completedAt,
        duration: 1200,
        // A person completed this late-night workout on their saved March 8
        // local calendar day, even though its UTC instant is March 9.
        trainingDay: const LocalCalendarDay(2026, 3, 8),
      );

      final exactSessions = await SessionDao.getSessionsForInstantRange(
        db,
        completedAt,
        completedAt,
      );
      expect(exactSessions.map((row) => row['id']), [sessionId]);

      final calendarSessions = await SessionDao.getSessionsForCalendarRange(
        db,
        const LocalCalendarDay(2026, 3, 8),
        const LocalCalendarDay(2026, 3, 8),
      );
      expect(calendarSessions.map((row) => row['id']), [sessionId]);

      final nextDaySessions = await SessionDao.getSessionsForCalendarRange(
        db,
        const LocalCalendarDay(2026, 3, 9),
        const LocalCalendarDay(2026, 3, 9),
      );
      expect(nextDaySessions, isEmpty);
    },
  );

  test('nutrition precise-time ranges use an exclusive upper bound', () async {
    await db.execute('''
      CREATE TABLE diary_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        meal_type INTEGER NOT NULL,
        food_id INTEGER,
        recipe_id INTEGER,
        logged_at INTEGER,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    final start = DateTime.utc(2026, 1, 1, 12);
    final end = start.add(const Duration(hours: 1));
    await db.insert('diary_entries', {
      'profile_id': 1,
      'date': '2026-01-01',
      'meal_type': 0,
      'food_id': 1,
      'logged_at': start.millisecondsSinceEpoch,
      'is_deleted': 0,
    });
    await db.insert('diary_entries', {
      'profile_id': 1,
      'date': '2026-01-01',
      'meal_type': 0,
      'food_id': 1,
      'logged_at': end.millisecondsSinceEpoch,
      'is_deleted': 0,
    });

    final entries = await NutritionDao(
      db,
    ).getDiaryEntriesBetween(1, start, end);

    expect(entries, hasLength(1));
    expect(entries.single.loggedAt, start);
  });
}
