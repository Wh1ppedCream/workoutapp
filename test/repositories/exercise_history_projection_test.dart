import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _HistoryRepository extends AppRepository {
  List<Map<String, dynamic>> rows = [];
  int? definition;
  int? timestamp;
  int? exercise;
  int? count;

  @override
  Future<List<Map<String, dynamic>>> fetchRecentWeightExerciseHistoryRows({
    required int definitionId,
    int? beforeCompletedAtMilliseconds,
    int? beforeExerciseId,
    int limit = 10,
  }) async {
    definition = definitionId;
    timestamp = beforeCompletedAtMilliseconds;
    exercise = beforeExerciseId;
    count = limit;
    return rows;
  }
}

void main() {
  test(
    'typed projection preserves override dispatch, order and cursor arguments',
    () async {
      final repository = _HistoryRepository()
        ..rows = [
          for (final id in [9, 8])
            {
              'exercise_id': id,
              'session_id': 3,
              'session_completed_at_ms': 1704153600000,
              'session_training_day': '2024-01-01',
              'session_date': '2024-01-02T00:00:00Z',
            },
        ];
      final history = await repository.fetchRecentWeightExerciseHistory(
        definitionId: 7,
        beforeCompletedAtMilliseconds: 1704153600001,
        beforeExerciseId: 12,
        limit: 11,
      );
      expect(history.map((entry) => entry.exerciseId), [9, 8]);
      expect(history.first.sessionId, 3);
      expect(history.first.completedAtMilliseconds, 1704153600000);
      expect(history.first.completedAt.toUtc(), DateTime.utc(2024, 1, 2));
      expect(history.first.calendarDay.storageKey, '2024-01-01');
      expect(
        [
          repository.definition,
          repository.timestamp,
          repository.exercise,
          repository.count,
        ],
        [7, 1704153600001, 12, 11],
      );
      expect(() => history.clear(), throwsUnsupportedError);
    },
  );

  test('legacy history retains its recorded day and decodes its instant', () {
    final entry = ExerciseHistoryEntry.fromDatabaseRow({
      'exercise_id': 1,
      'session_id': 2,
      'session_date': '2024-01-01T23:00:00-05:00',
    });
    expect(entry.completedAt.toUtc(), DateTime.utc(2024, 1, 2, 4));
    expect(
      entry.completedAtMilliseconds,
      DateTime.utc(2024, 1, 2, 4).millisecondsSinceEpoch,
    );
    expect(entry.calendarDay.storageKey, '2024-01-01');
  });

  test('malformed identity fails instead of silently inventing a cursor', () {
    expect(
      () => ExerciseHistoryEntry.fromDatabaseRow({
        'session_date': '2024-01-01',
        'session_id': 1,
      }),
      throwsA(isA<TypeError>()),
    );
  });
}
