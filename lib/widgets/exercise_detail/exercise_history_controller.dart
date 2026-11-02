import 'package:flutter/foundation.dart';

import '../../models/exercise_history_record.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../services/safe_failure.dart';

/// Ignored work was superseded, disposed, or excluded by an active request.
enum ExerciseHistoryLoadResult { loaded, failed, ignored }

/// Owns Records paging for one detail sheet, without presentation or navigation.
class ExerciseHistoryController extends ChangeNotifier {
  ExerciseHistoryController(this._repository, this._definitionId);

  static const _pageSize = 10;
  final AppRepository _repository;
  int _definitionId;
  int _generation = 0;
  bool _disposed = false;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  SafeFailure? _failure;
  List<HistoryRecord> _records = const [];
  ExerciseHistoryEntry? _cursor;
  Map<int, WorkoutExerciseRecordBadges> _badges = const {};

  int get definitionId => _definitionId;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  SafeFailure? get failure => _failure;
  List<HistoryRecord> get records => _records;

  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  /// Reloads records and badges together; invalidates all older page requests.
  Future<ExerciseHistoryLoadResult> refresh({int? definitionId}) async {
    if (_disposed) return ExerciseHistoryLoadResult.ignored;
    if (definitionId != null) _definitionId = definitionId;
    final generation = ++_generation;
    final requestedDefinition = _definitionId;
    _loading = true;
    _loadingMore = false;
    _failure = null;
    _records = const [];
    _cursor = null;
    _badges = const {};
    _hasMore = false;
    notifyListeners();
    try {
      final page = await _readPage(
        requestedDefinition,
        badges: _repository.fetchCurrentExerciseRecordBadges(
          requestedDefinition,
        ),
      );
      if (!_isCurrent(generation)) return ExerciseHistoryLoadResult.ignored;
      _records = page.records;
      _cursor = page.cursor;
      _hasMore = page.hasMore;
      _badges = page.badges;
      return ExerciseHistoryLoadResult.loaded;
    } catch (error) {
      if (!_isCurrent(generation)) return ExerciseHistoryLoadResult.ignored;
      _failure = SafeFailure.classify(error);
      return ExerciseHistoryLoadResult.failed;
    } finally {
      if (_isCurrent(generation)) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  /// Commits a fully hydrated page atomically. Failure leaves its cursor intact.
  Future<ExerciseHistoryLoadResult> loadMore() async {
    if (_disposed || _loading || _loadingMore || !_hasMore || _cursor == null) {
      return ExerciseHistoryLoadResult.ignored;
    }
    final generation = _generation;
    final requestedDefinition = _definitionId;
    final cursor = _cursor;
    final badges = _badges;
    _loadingMore = true;
    _failure = null;
    notifyListeners();
    try {
      final page = await _readPage(
        requestedDefinition,
        before: cursor,
        badges: Future.value(badges),
      );
      if (!_isCurrent(generation)) return ExerciseHistoryLoadResult.ignored;
      _records = List.unmodifiable([..._records, ...page.records]);
      _cursor = page.cursor;
      _hasMore = page.hasMore;
      return ExerciseHistoryLoadResult.loaded;
    } catch (error) {
      if (!_isCurrent(generation)) return ExerciseHistoryLoadResult.ignored;
      _failure = SafeFailure.classify(error);
      return ExerciseHistoryLoadResult.failed;
    } finally {
      if (_isCurrent(generation)) {
        _loadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<_HistoryPage> _readPage(
    int definitionId, {
    ExerciseHistoryEntry? before,
    required Future<Map<int, WorkoutExerciseRecordBadges>> badges,
  }) async {
    // Attach both futures immediately: an early badge failure must not escape
    // while rows or individual exercises are still loading.
    final results = await Future.wait<Object>([
      _readExercises(definitionId, before),
      badges,
    ]);
    final page = results[0] as _HydratedHistory;
    final capturedBadges = results[1] as Map<int, WorkoutExerciseRecordBadges>;
    return _HistoryPage(
      records: List.unmodifiable([
        for (var index = 0; index < page.entries.length; index++)
          if (page.exercises[index] case final WeightExercise exercise)
            HistoryRecord(
              date: page.entries[index].completedAt,
              calendarDay: page.entries[index].calendarDay,
              sessionId: page.entries[index].sessionId,
              exerciseId: page.entries[index].exerciseId,
              sessionCompletedAtMilliseconds:
                  page.entries[index].completedAtMilliseconds,
              sets: exercise.sets,
              badges:
                  capturedBadges[page.entries[index].exerciseId] ??
                  const WorkoutExerciseRecordBadges(isFirstRecord: false),
            ),
      ]),
      // Advance by raw rows, including a missing/non-weight hydration result,
      // rather than repeating rows after the last renderable exercise.
      cursor: page.entries.lastOrNull,
      hasMore: page.hasMore,
      badges: Map.unmodifiable(capturedBadges),
    );
  }

  Future<_HydratedHistory> _readExercises(
    int definitionId,
    ExerciseHistoryEntry? before,
  ) async {
    final rows = await _repository.fetchRecentWeightExerciseHistory(
      definitionId: definitionId,
      beforeCompletedAtMilliseconds: before?.completedAtMilliseconds,
      beforeExerciseId: before?.exerciseId,
      limit: _pageSize + 1,
    );
    final entries = rows.take(_pageSize).toList(growable: false);
    final exercises = await Future.wait(
      entries.map(
        (entry) => _repository.fetchDetailedExercise(entry.exerciseId),
      ),
    );
    return _HydratedHistory(entries, exercises, rows.length > _pageSize);
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}

class _HydratedHistory {
  const _HydratedHistory(this.entries, this.exercises, this.hasMore);

  final List<ExerciseHistoryEntry> entries;
  final List<WorkoutExercise?> exercises;
  final bool hasMore;
}

class _HistoryPage {
  const _HistoryPage({
    required this.records,
    required this.cursor,
    required this.hasMore,
    required this.badges,
  });

  final List<HistoryRecord> records;
  final ExerciseHistoryEntry? cursor;
  final bool hasMore;
  final Map<int, WorkoutExerciseRecordBadges> badges;
}
