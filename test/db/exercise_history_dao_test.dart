import 'package:env_test/db/exercise_history_dao.dart';
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
  });

  tearDown(() => db.close());

  test(
    'loads the next history page without repeating earlier exercise rows',
    () async {
      for (var day = 1; day <= 12; day++) {
        await _insertWeightExercise(
          db,
          definitionId: 7,
          date: '2026-07-${day.toString().padLeft(2, '0')}T10:00:00.000',
        );
      }

      final firstPage = await ExerciseHistoryDao.fetchWeightExerciseRows(
        db,
        definitionId: 7,
        limit: 10,
      );
      final firstIds =
          firstPage.map((row) => row['exercise_id'] as int).toList();
      expect(firstIds, List<int>.generate(10, (index) => 12 - index));

      final cursor = firstPage.last;
      final secondPage = await ExerciseHistoryDao.fetchWeightExerciseRows(
        db,
        definitionId: 7,
        beforeSessionDate: cursor['session_date'] as String,
        beforeExerciseId: cursor['exercise_id'] as int,
        limit: 10,
      );
      final secondIds =
          secondPage.map((row) => row['exercise_id'] as int).toList();

      expect(secondIds, [2, 1]);
      expect(secondIds.toSet().intersection(firstIds.toSet()), isEmpty);
    },
  );

  test(
    'uses exercise ID as a stable cursor when session timestamps match',
    () async {
      final olderId = await _insertWeightExercise(
        db,
        definitionId: 7,
        date: '2026-07-10T10:00:00.000',
      );
      final sameDateOlderId = await _insertWeightExercise(
        db,
        definitionId: 7,
        date: '2026-07-11T10:00:00.000',
      );
      final sameDateNewerId = await _insertWeightExercise(
        db,
        definitionId: 7,
        date: '2026-07-11T10:00:00.000',
      );

      final newest = await ExerciseHistoryDao.fetchWeightExerciseRows(
        db,
        definitionId: 7,
        limit: 1,
      );
      expect(newest.single['exercise_id'], sameDateNewerId);

      final sameDatePrevious = await ExerciseHistoryDao.fetchWeightExerciseRows(
        db,
        definitionId: 7,
        beforeSessionDate: newest.single['session_date'] as String,
        beforeExerciseId: newest.single['exercise_id'] as int,
        limit: 1,
      );
      expect(sameDatePrevious.single['exercise_id'], sameDateOlderId);

      final olderPage = await ExerciseHistoryDao.fetchWeightExerciseRows(
        db,
        definitionId: 7,
        beforeSessionDate: sameDatePrevious.single['session_date'] as String,
        beforeExerciseId: sameDatePrevious.single['exercise_id'] as int,
        limit: 1,
      );
      expect(olderPage.single['exercise_id'], olderId);
    },
  );
}

Future<int> _insertWeightExercise(
  Database db, {
  required int definitionId,
  required String date,
}) async {
  final sessionId = await db.insert('sessions', {'date': date, 'duration': 0});
  return db.insert('exercises', {
    'session_id': sessionId,
    'exercise_def_id': definitionId,
    'type': 'weight',
    'order_index': 0,
  });
}
