import 'dart:async';

import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/widgets/exercise_detail/exercise_history_controller.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Row = Map<String, dynamic>;
typedef _Badges = Map<int, WorkoutExerciseRecordBadges>;

List<_Row> _rows(int definitionId, int count) => [
  for (var index = count; index > 0; index--)
    {
      'exercise_id': definitionId * 100 + index,
      'session_id': index,
      'session_date': '2026-10-25T01:30:00Z',
      // Equal instants exercise the ID tie-breaker, not only date pagination.
      'session_completed_at_ms': DateTime.utc(
        2026,
        10,
        25,
        1,
        30,
      ).millisecondsSinceEpoch,
      'session_training_day': '2026-10-24',
    },
];

class _HistoryRepository extends AppRepository {
  final rows = <int, List<_Row>>{1: _rows(1, 25), 2: _rows(2, 14)};
  final requests = <({int definitionId, int? time, int? id, int limit})>[];
  final rowGates = <int, Completer<List<_Row>>>{};
  final badgeGates = <int, Completer<_Badges>>{};
  final detailGates = <int, Completer<WorkoutExercise?>>{};
  final failedRows = <int>{};
  final failedDetails = <int>{};
  final missingDetails = <int>{};
  final badges = <int, _Badges>{};
  final hydratedIds = <int>[];
  final badgeDefinitions = <int>[];

  // Deliberately override the raw virtual seam used by existing repository fakes.
  @override
  Future<List<_Row>> fetchRecentWeightExerciseHistoryRows({
    required int definitionId,
    int? beforeCompletedAtMilliseconds,
    int? beforeExerciseId,
    int limit = 10,
  }) async {
    final request = requests.length;
    requests.add((
      definitionId: definitionId,
      time: beforeCompletedAtMilliseconds,
      id: beforeExerciseId,
      limit: limit,
    ));
    if (failedRows.contains(request)) throw StateError('private row error');
    if (rowGates[request] case final gate?) return gate.future;
    return (rows[definitionId] ?? [])
        .where(
          (row) =>
              beforeExerciseId == null ||
              (row['exercise_id'] as int) < beforeExerciseId,
        )
        .take(limit)
        .toList();
  }

  @override
  Future<_Badges> fetchCurrentExerciseRecordBadges(int definitionId) async {
    final request = badgeDefinitions.length;
    badgeDefinitions.add(definitionId);
    return badgeGates[request]?.future ?? badges[definitionId] ?? {};
  }

  @override
  Future<WorkoutExercise?> fetchDetailedExercise(int id) async {
    hydratedIds.add(id);
    if (failedDetails.contains(id)) throw StateError('private hydration error');
    if (detailGates[id] case final gate?) return gate.future;
    if (missingDetails.contains(id)) return null;
    return WeightExercise(
      name: 'Exercise $id',
      equipment: '',
      sets: [ExerciseSet(weight: id.toDouble(), reps: 8)],
    );
  }
}

void main() {
  late _HistoryRepository repository;
  late ExerciseHistoryController controller;
  setUp(() {
    repository = _HistoryRepository();
    controller = ExerciseHistoryController(repository, 1);
  });
  tearDown(() => controller.dispose());

  test(
    'first page preserves ordering, recorded day, instant and badges',
    () async {
      final badges = WorkoutExerciseRecordBadges(isFirstRecord: true);
      repository.badges[1] = {125: badges};
      expect(controller.loading, isTrue);
      expect(await controller.refresh(), ExerciseHistoryLoadResult.loaded);
      expect(controller.loading, isFalse);
      expect(
        controller.records.map((r) => r.exerciseId),
        List.generate(10, (index) => 125 - index),
      );
      expect(controller.records.first.badges, same(badges));
      expect(controller.records.last.badges.isFirstRecord, isFalse);
      expect(controller.records.first.calendarDay.storageKey, '2026-10-24');
      expect(
        controller.records.first.date.toUtc(),
        DateTime.utc(2026, 10, 25, 1, 30),
      );
      expect(
        controller.records.first.sessionCompletedAtMilliseconds,
        DateTime.utc(2026, 10, 25, 1, 30).millisecondsSinceEpoch,
      );
      expect(controller.hasMore, isTrue);
      expect(repository.requests.single.limit, 11);
      expect(repository.hydratedIds, hasLength(10));
      expect(() => controller.records.clear(), throwsUnsupportedError);
      expect(
        () => controller.records.first.sets.clear(),
        throwsUnsupportedError,
      );
    },
  );

  test(
    'equal-time pagination uses the last raw ID and stops at the end',
    () async {
      repository.rows[1] = _rows(1, 13);
      await controller.refresh();
      expect(await controller.loadMore(), ExerciseHistoryLoadResult.loaded);
      expect(repository.requests.last.id, 104);
      expect(
        repository.requests.last.time,
        DateTime.utc(2026, 10, 25, 1, 30).millisecondsSinceEpoch,
      );
      expect(
        controller.records.map((r) => r.exerciseId),
        List.generate(13, (index) => 113 - index),
      );
      expect(controller.hasMore, isFalse);
      expect(await controller.loadMore(), ExerciseHistoryLoadResult.ignored);
      expect(repository.requests, hasLength(2));
    },
  );

  test('duplicate load-more calls cannot append the same page twice', () async {
    await controller.refresh();
    final gate = repository.rowGates[1] = Completer();
    final first = controller.loadMore();
    expect(controller.loadingMore, isTrue);
    expect(await controller.loadMore(), ExerciseHistoryLoadResult.ignored);
    gate.complete(_rows(1, 15).take(11).toList());
    expect(await first, ExerciseHistoryLoadResult.loaded);
    expect(controller.records, hasLength(20));
    expect(controller.records.map((r) => r.exerciseId).toSet(), hasLength(20));
    expect(repository.requests, hasLength(2));
  });

  test(
    'failed hydration retains records and retries the same cursor',
    () async {
      await controller.refresh();
      final firstPage = controller.records;
      repository.failedDetails.add(115);
      expect(await controller.loadMore(), ExerciseHistoryLoadResult.failed);
      expect(controller.records, same(firstPage));
      expect(controller.loadingMore, isFalse);
      expect(controller.hasMore, isTrue);
      expect(controller.failure, isNotNull);
      final failedCursor = repository.requests.last;
      repository.failedDetails.clear();
      expect(await controller.loadMore(), ExerciseHistoryLoadResult.loaded);
      expect(repository.requests.last, failedCursor);
      expect(controller.records, hasLength(20));
      expect(controller.failure, isNull);
    },
  );

  test(
    'failed row read retains records and releases load-more exclusion',
    () async {
      await controller.refresh();
      repository.failedRows.add(1);
      expect(await controller.loadMore(), ExerciseHistoryLoadResult.failed);
      expect(controller.records, hasLength(10));
      expect(controller.loadingMore, isFalse);
      expect(await controller.loadMore(), ExerciseHistoryLoadResult.loaded);
      expect(controller.records, hasLength(20));
    },
  );

  test(
    'late initial success and badges cannot replace a newer exercise',
    () async {
      final rows = repository.rowGates[0] = Completer();
      final oldBadges = repository.badgeGates[0] = Completer();
      final old = controller.refresh();
      await controller.refresh(definitionId: 2);
      rows.complete(_rows(1, 11));
      oldBadges.complete({
        111: const WorkoutExerciseRecordBadges(isFirstRecord: true),
      });
      expect(await old, ExerciseHistoryLoadResult.ignored);
      expect(controller.definitionId, 2);
      expect(controller.records.first.exerciseId, 214);
      expect(controller.records.first.badges.isFirstRecord, isFalse);
      expect(controller.failure, isNull);
    },
  );

  test(
    'stale failure and finally cannot clear a newer load-more spinner',
    () async {
      await controller.refresh();
      final oldGate = repository.rowGates[1] = Completer();
      final oldMore = controller.loadMore();
      await controller.refresh(definitionId: 2);
      final newGate = repository.rowGates[3] = Completer();
      final newMore = controller.loadMore();
      oldGate.completeError(StateError('obsolete private failure'));
      expect(await oldMore, ExerciseHistoryLoadResult.ignored);
      expect(controller.loadingMore, isTrue);
      expect(controller.failure, isNull);
      newGate.complete(_rows(2, 4));
      expect(await newMore, ExerciseHistoryLoadResult.loaded);
      expect(
        controller.records.map((r) => r.exerciseId),
        List.generate(14, (index) => 214 - index),
      );
    },
  );

  test(
    'stale success cannot append or finish a newer load-more request',
    () async {
      await controller.refresh();
      final oldGate = repository.rowGates[1] = Completer();
      final oldMore = controller.loadMore();
      await controller.refresh(definitionId: 2);
      final newGate = repository.rowGates[3] = Completer();
      final newMore = controller.loadMore();
      oldGate.complete(_rows(1, 15).take(11).toList());
      expect(await oldMore, ExerciseHistoryLoadResult.ignored);
      expect(controller.loadingMore, isTrue);
      expect(controller.records, hasLength(10));
      newGate.complete(_rows(2, 4));
      await newMore;
      expect(controller.records.every((r) => r.exerciseId > 200), isTrue);
    },
  );

  test(
    'refreshing the same exercise renews badges and invalidates old pages',
    () async {
      await controller.refresh();
      final oldGate = repository.rowGates[1] = Completer();
      final oldMore = controller.loadMore();
      repository.badges[1] = {
        125: const WorkoutExerciseRecordBadges(isFirstRecord: true),
      };
      await controller.refresh();
      oldGate.complete(_rows(1, 15).take(11).toList());
      expect(await oldMore, ExerciseHistoryLoadResult.ignored);
      expect(controller.records, hasLength(10));
      expect(controller.records.first.badges.isFirstRecord, isTrue);
      expect(repository.badgeDefinitions, [1, 1]);
    },
  );

  test(
    'missing hydration advances the raw cursor instead of repeating rows',
    () async {
      repository.missingDetails.add(116);
      await controller.refresh();
      expect(controller.records.last.exerciseId, 117);
      await controller.loadMore();
      expect(repository.requests.last.id, 116);
      expect(
        controller.records.map((r) => r.exerciseId).toSet(),
        hasLength(controller.records.length),
      );
    },
  );

  test(
    'badge failure is observed while row loading is still pending',
    () async {
      final rows = repository.rowGates[0] = Completer();
      final badges = repository.badgeGates[0] = Completer();
      final loading = controller.refresh();
      badges.completeError(StateError('private badge failure'));
      await Future<void>.delayed(Duration.zero);
      rows.complete(_rows(1, 1));
      expect(await loading, ExerciseHistoryLoadResult.failed);
      expect(controller.failure, isNotNull);
      expect(controller.loading, isFalse);
      expect(await controller.refresh(), ExerciseHistoryLoadResult.loaded);
    },
  );

  test('empty history has no cursor and cannot start pagination', () async {
    repository.rows[1] = [];
    await controller.refresh();
    expect(controller.records, isEmpty);
    expect(controller.hasMore, isFalse);
    expect(await controller.loadMore(), ExerciseHistoryLoadResult.ignored);
    expect(repository.requests, hasLength(1));
  });

  test(
    'initial failure exposes safe failure and supports refresh retry',
    () async {
      repository.failedRows.add(0);
      expect(await controller.refresh(), ExerciseHistoryLoadResult.failed);
      expect(controller.loading, isFalse);
      expect(controller.failure, isNotNull);
      expect(await controller.refresh(), ExerciseHistoryLoadResult.loaded);
      expect(controller.failure, isNull);
      expect(controller.records, hasLength(10));
    },
  );

  test(
    'disposal invalidates in-flight work and prevents notifications',
    () async {
      final owned = ExerciseHistoryController(repository, 1);
      var notifications = 0;
      owned.addListener(() => notifications++);
      final gate = repository.rowGates[0] = Completer();
      final loading = owned.refresh();
      final count = notifications;
      owned.dispose();
      gate.complete(_rows(1, 1));
      expect(await loading, ExerciseHistoryLoadResult.ignored);
      expect(await owned.loadMore(), ExerciseHistoryLoadResult.ignored);
      expect(await owned.refresh(), ExerciseHistoryLoadResult.ignored);
      expect(notifications, count);
    },
  );

  test('stale initial failure cannot end a newer initial load', () async {
    final oldGate = repository.rowGates[0] = Completer();
    final old = controller.refresh();
    final newGate = repository.rowGates[1] = Completer();
    final current = controller.refresh(definitionId: 2);
    oldGate.completeError(StateError('obsolete load'));
    expect(await old, ExerciseHistoryLoadResult.ignored);
    expect(controller.loading, isTrue);
    expect(controller.failure, isNull);
    newGate.complete(_rows(2, 1));
    expect(await current, ExerciseHistoryLoadResult.loaded);
    expect(controller.records.single.exerciseId, 201);
  });

  test('disposing during pagination suppresses its late failure', () async {
    final owned = ExerciseHistoryController(repository, 1);
    await owned.refresh();
    var notifications = 0;
    owned.addListener(() => notifications++);
    final gate = repository.rowGates[1] = Completer();
    final loading = owned.loadMore();
    final count = notifications;
    owned.dispose();
    gate.completeError(StateError('late page failure'));
    expect(await loading, ExerciseHistoryLoadResult.ignored);
    expect(notifications, count);
  });
}
