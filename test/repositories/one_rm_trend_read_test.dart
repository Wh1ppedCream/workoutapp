import 'package:env_test/repositories/app_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('typed trend preserves query arguments, ordering, numeric/null values and explicit calendar day', () async {
    final repo = _TrendRepository([
      {
        'session_id': 7,
        'completed_at_ms': DateTime.utc(2026, 10, 31, 1).millisecondsSinceEpoch,
        'session_date': '2000-01-01',
        'training_day': '2026-10-30',
        'actual_one_rm': 100,
        'estimated_one_rm': 110.5,
      },
      {
        'session_id': 8,
        'session_date': '2026-11-01T10:30:00Z',
        'actual_one_rm': null,
        'estimated_one_rm': null,
      },
    ]);
    final points = await repo.fetchExerciseOneRmTrend(
      definitionId: 42,
      limit: 2,
    );
    expect(repo.definitionId, 42);
    expect(repo.limit, 2);
    expect(points.map((point) => point.sessionId), [7, 8]);
    expect(points.first.completedAt.toUtc(), DateTime.utc(2026, 10, 31, 1));
    expect(points.first.calendarDay.storageKey, '2026-10-30');
    expect(points.first.displayDateTime.day, 30);
    expect(points.first.actualOneRm, 100.0);
    expect(points.first.estimatedOneRm, 110.5);
    expect(points.last.actualOneRm, isNull);
    expect(points.last.estimatedOneRm, 0);
    expect(points.last.completedAt.toUtc(), DateTime.utc(2026, 11, 1, 10, 30));
    expect(() => points.clear(), throwsUnsupportedError);
  });

  test(
    'empty typed trend remains empty and retains the raw override seam',
    () async {
      final repo = _TrendRepository([]);
      expect(await repo.fetchExerciseOneRmTrend(definitionId: 3), isEmpty);
      expect(repo.limit, 60);
    },
  );

  test('malformed required values fail at the repository boundary', () async {
    final repo = _TrendRepository([
      {'session_id': 'invalid'},
    ]);
    await expectLater(
      repo.fetchExerciseOneRmTrend(definitionId: 3),
      throwsA(isA<TypeError>()),
    );
  });
}

class _TrendRepository extends AppRepository {
  _TrendRepository(this.rows);
  final List<Map<String, dynamic>> rows;
  int? definitionId;
  int? limit;

  @override
  Future<List<Map<String, dynamic>>> fetchExerciseOneRmTrendRows({
    required int definitionId,
    int limit = 60,
  }) async {
    this.definitionId = definitionId;
    this.limit = limit;
    return rows;
  }
}
