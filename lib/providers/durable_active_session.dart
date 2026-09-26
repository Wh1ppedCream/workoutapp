import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../services/auto_increment_service.dart';
import '../widgets/exercise_card.dart';

enum ActiveSessionDurabilityIssue { restore, draftSave, progression }

typedef ActiveSessionRetryDelay = Future<void> Function(Duration duration);
typedef PendingProgressionRunner =
    Future<void> Function(int sessionId, int presetId);

class _RestoredWorkoutDraft {
  const _RestoredWorkoutDraft({
    required this.exercises,
    required this.cardTypes,
    required this.autoPresetId,
    required this.startedAt,
  });

  final List<WorkoutExercise> exercises;
  final List<CardType> cardTypes;
  final int? autoPresetId;
  final DateTime startedAt;
}

/// Owns the durable state of the workout currently in progress.
class ActiveSession extends ChangeNotifier with WidgetsBindingObserver {
  static const int _maxDurabilityAttempts = 3;
  static const List<Duration> _retryDelays = [
    Duration(milliseconds: 40),
    Duration(milliseconds: 160),
  ];

  static Future<void> _defaultRetryDelay(Duration duration) =>
      Future<void>.delayed(duration);

  final AppRepository _repo;
  final ActiveSessionRetryDelay _retryDelay;
  final PendingProgressionRunner _progressionRunner;
  late final Future<void> _restoreFuture;

  int? _autoPresetId;
  DateTime? _startedAt;
  Timer? _timer;
  Timer? _draftSaveTimer;
  Future<void>? _draftSaveInFlight;
  bool _draftSaveRequested = false;
  int _elapsedSeconds = 0;
  int _completedSessionVersion = 0;
  bool _isRestoring = true;
  bool _isFinishing = false;
  bool _isRetryingDurability = false;
  bool _restoreFailed = false;
  bool _draftSaveFailed = false;
  bool _progressionFailed = false;

  ActiveSession({
    required AppRepository repository,
    ActiveSessionRetryDelay? retryDelay,
    PendingProgressionRunner? progressionRunner,
  }) : _repo = repository,
       _retryDelay = retryDelay ?? _defaultRetryDelay,
       _progressionRunner =
           progressionRunner ??
           ((sessionId, presetId) => AutoIncrementService(
             repository,
           ).applyPending(sessionId: sessionId, presetId: presetId)) {
    WidgetsBinding.instance.addObserver(this);
    _restoreFuture = _initializeDurability();
  }

  final ValueNotifier<int> elapsedSecondsListenable = ValueNotifier<int>(0);

  Future<void> get ready => _restoreFuture;
  bool get isActive => _timer != null || _isRestoring;
  bool get isRestoring => _isRestoring;
  bool get isFinishing => _isFinishing;
  bool get isRetryingDurability => _isRetryingDurability;
  ActiveSessionDurabilityIssue? get durabilityIssue {
    if (_restoreFailed) return ActiveSessionDurabilityIssue.restore;
    if (_draftSaveFailed) return ActiveSessionDurabilityIssue.draftSave;
    if (_progressionFailed) return ActiveSessionDurabilityIssue.progression;
    return null;
  }

  int get elapsedSeconds => _elapsedSeconds;
  int get completedSessionVersion => _completedSessionVersion;
  int get completedSetCount {
    var count = 0;
    for (final exercise in exercises) {
      if (exercise is! WeightExercise) continue;
      count += exercise.completedParents.length;
      for (final children in exercise.completedChildren.values) {
        count += children.length;
      }
    }
    return count;
  }

  bool get hasCompletedWork => _completedExerciseWrites().isNotEmpty;

  String get formattedTime {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  final List<WorkoutExercise> exercises = [];
  final List<CardType> cardTypes = [];

  /// Starts an empty workout after any persisted draft has finished restoring.
  /// Returns false rather than replacing an existing workout.
  Future<bool> start({int? presetId}) async {
    await _restoreFuture;
    if (_restoreFailed || _timer != null || _isFinishing) return false;
    _beginWorkout(presetId: presetId);
    await _persistDraft();
    return true;
  }

  /// Seeds and starts a workout without exposing a clear-then-add race.
  Future<bool> startWithExercises({
    required List<WorkoutExercise> workoutExercises,
    required List<CardType> workoutCardTypes,
    int? presetId,
  }) async {
    if (workoutExercises.length != workoutCardTypes.length) {
      throw ArgumentError('Exercise and card-type counts must match.');
    }
    await _restoreFuture;
    if (_restoreFailed || _timer != null || _isFinishing) return false;
    exercises
      ..clear()
      ..addAll(workoutExercises);
    cardTypes
      ..clear()
      ..addAll(workoutCardTypes);
    _beginWorkout(presetId: presetId);
    await _persistDraft();
    return true;
  }

  void _beginWorkout({int? presetId}) {
    _autoPresetId = presetId;
    _startedAt = DateTime.now();
    _elapsedSeconds = 0;
    elapsedSecondsListenable.value = 0;
    _startTimer();
    notifyListeners();
  }

  void refresh() {
    _persistDraftSoon();
    notifyListeners();
  }

  void addExercise(WorkoutExercise exercise, CardType type) {
    exercises.add(exercise);
    cardTypes.add(type);
    _persistDraftSoon();
    notifyListeners();
  }

  void removeExercise(int index) {
    exercises.removeAt(index);
    cardTypes.removeAt(index);
    _persistDraftSoon();
    notifyListeners();
  }

  /// Saves only explicitly completed work. On failure, the durable draft and
  /// live provider remain untouched so the user can retry.
  Future<int?> finish() async {
    await _restoreFuture;
    if (_timer == null || _isFinishing) return null;
    final completedExercises = _completedExerciseWrites();
    if (completedExercises.isEmpty) return null;
    _syncElapsed();
    _isFinishing = true;
    _draftSaveTimer?.cancel();
    _draftSaveTimer = null;
    notifyListeners();

    final inFlightSave = _draftSaveInFlight;
    if (inFlightSave != null) await inFlightSave;

    final autoPresetId = _autoPresetId;
    try {
      final sessionId = await _repo.completeWorkoutAtomic(
        completedAt: DateTime.now(),
        durationSeconds: _elapsedSeconds,
        exercises: completedExercises,
        autoPresetId: autoPresetId,
      );
      _resetActiveState();
      markHistoryChanged();
      if (autoPresetId != null) await _resumePendingProgressions();
      return sessionId;
    } catch (_) {
      _isFinishing = false;
      _persistDraftSoon();
      notifyListeners();
      rethrow;
    }
  }

  /// Discards the active draft without adding anything to workout history.
  Future<void> discard() async {
    await _restoreFuture;
    if (_isFinishing) return;
    _isFinishing = true;
    _draftSaveTimer?.cancel();
    _draftSaveTimer = null;
    notifyListeners();
    final inFlightSave = _draftSaveInFlight;
    if (inFlightSave != null) await inFlightSave;
    try {
      await _withRetries(_repo.clearActiveWorkoutDraft);
      _resetActiveState();
      notifyListeners();
    } catch (_) {
      _isFinishing = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Invalidates every screen whose contents derive from workout history.
  void markHistoryChanged() {
    _completedSessionVersion++;
    notifyListeners();
  }

  List<WorkoutExerciseWrite> _completedExerciseWrites() {
    final writes = <WorkoutExerciseWrite>[];
    for (var index = 0; index < exercises.length; index++) {
      final exercise = exercises[index];
      final type = cardTypes[index];
      WorkoutExercise completedExercise = exercise;

      if (type == CardType.weight && exercise is WeightExercise) {
        final parents = <ExerciseSet>[];
        final children = <int, List<ExerciseSet>>{};
        for (
          var parentIndex = 0;
          parentIndex < exercise.sets.length;
          parentIndex++
        ) {
          if (!exercise.completedParents.contains(parentIndex)) continue;
          final newParentIndex = parents.length;
          parents.add(_copySet(exercise.sets[parentIndex]));
          final sourceChildren =
              exercise.changeSets[parentIndex] ?? const <ExerciseSet>[];
          final keptChildren = <ExerciseSet>[];
          for (
            var childIndex = 0;
            childIndex < sourceChildren.length;
            childIndex++
          ) {
            if (exercise.completedChildren[parentIndex]?.contains(childIndex) ==
                true) {
              keptChildren.add(_copySet(sourceChildren[childIndex]));
            }
          }
          if (keptChildren.isNotEmpty) children[newParentIndex] = keptChildren;
        }
        completedExercise = WeightExercise(
          name: exercise.name,
          equipment: exercise.equipment,
          sourcePresetExerciseId: exercise.sourcePresetExerciseId,
          sets: parents,
          changeSets: children,
        );
        if (parents.isEmpty) continue;
      } else if (type == CardType.stretch && exercise is StretchExercise) {
        final kept = <StretchInstance>[];
        for (
          var stretchIndex = 0;
          stretchIndex < exercise.stretchInstances.length;
          stretchIndex++
        ) {
          if (exercise.completedStretchIndices.contains(stretchIndex)) {
            kept.add(_copyStretch(exercise.stretchInstances[stretchIndex]));
          }
        }
        completedExercise = StretchExercise(
          name: exercise.name,
          equipment: exercise.equipment,
          stretchInstances: kept,
        );
        if (kept.isEmpty) continue;
      } else if (exercise is CardioExercise) {
        completedExercise = CardioExercise(
          name: exercise.name,
          equipment: exercise.equipment,
          cardioName: exercise.cardioName,
          cardioNote: exercise.cardioNote,
          plannedMinutes: exercise.plannedMinutes,
          elapsedSeconds: exercise.elapsedSeconds,
        );
      }

      writes.add(
        WorkoutExerciseWrite(
          exercise: completedExercise,
          type: type.name,
          sourcePresetExerciseId:
              exercise is WeightExercise
                  ? exercise.sourcePresetExerciseId
                  : null,
        ),
      );
    }
    return writes;
  }

  Future<void> _initializeDurability() async {
    await _restoreDraft();
    if (!_restoreFailed) await _resumePendingProgressions();
  }

  Future<void> _restoreDraft() async {
    try {
      final restored = await _withRetries(_loadRestoredDraft);
      // A successful read is enough to clear a prior restore warning, even
      // when there was no active workout to restore.
      _restoreFailed = false;
      if (restored == null) return;
      exercises
        ..clear()
        ..addAll(restored.exercises);
      cardTypes
        ..clear()
        ..addAll(restored.cardTypes);
      _autoPresetId = restored.autoPresetId;
      _startedAt = restored.startedAt;
      _syncElapsed();
      _startTimer();
    } catch (error, stackTrace) {
      _restoreFailed = true;
      debugPrint('Could not restore active workout (${error.runtimeType}).');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  Future<_RestoredWorkoutDraft?> _loadRestoredDraft() async {
    final row = await _repo.loadActiveWorkoutDraft();
    if (row == null) return null;
    final payload =
        jsonDecode(row['payload_json'] as String) as Map<String, dynamic>;
    final rawExercises = payload['exercises'] as List? ?? const [];
    final restoredExercises = <WorkoutExercise>[];
    final restoredCardTypes = <CardType>[];
    for (final raw in rawExercises.whereType<Map>()) {
      final map = Map<String, dynamic>.from(raw);
      final type = CardType.values.firstWhere(
        (candidate) => candidate.name == map['type'],
        orElse: () => CardType.weight,
      );
      restoredExercises.add(_exerciseFromJson(map, type));
      restoredCardTypes.add(type);
    }
    return _RestoredWorkoutDraft(
      exercises: restoredExercises,
      cardTypes: restoredCardTypes,
      autoPresetId: row['auto_preset_id'] as int?,
      startedAt: DateTime.parse(row['started_at'] as String).toLocal(),
    );
  }

  Future<void> retryDurability() async {
    if (_isRetryingDurability) return;
    _isRetryingDurability = true;
    notifyListeners();
    try {
      if (_restoreFailed) {
        _isRestoring = true;
        await _restoreDraft();
      }
      if (_draftSaveFailed && _startedAt != null) await _persistDraft();
      if (_progressionFailed || !_restoreFailed) {
        await _resumePendingProgressions();
      }
    } finally {
      _isRetryingDurability = false;
      notifyListeners();
    }
  }

  Future<void> _resumePendingProgressions() async {
    var failed = false;
    try {
      final jobs = await _withRetries(_repo.loadPendingWorkoutProgressions);
      for (final job in jobs) {
        final sessionId = (job['session_id'] as num).toInt();
        final presetId = (job['preset_id'] as num).toInt();
        try {
          await _withRetries(() => _progressionRunner(sessionId, presetId));
        } catch (error, stackTrace) {
          failed = true;
          debugPrint(
            'Automatic plan progression remains pending '
            '(${error.runtimeType}).',
          );
          debugPrintStack(stackTrace: stackTrace);
          try {
            await _repo.recordPendingWorkoutProgressionFailure(sessionId);
          } catch (_) {
            // The job itself remains durable even if attempt metadata fails.
          }
        }
      }
    } catch (error, stackTrace) {
      failed = true;
      debugPrint(
        'Could not load pending plan progression (${error.runtimeType}).',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
    if (_progressionFailed != failed) {
      _progressionFailed = failed;
      notifyListeners();
    }
  }

  Future<T> _withRetries<T>(Future<T> Function() operation) async {
    Object? lastError;
    StackTrace? lastStackTrace;
    for (var attempt = 0; attempt < _maxDurabilityAttempts; attempt++) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
        if (attempt < _retryDelays.length) {
          await _retryDelay(_retryDelays[attempt]);
        }
      }
    }
    Error.throwWithStackTrace(lastError!, lastStackTrace!);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _syncElapsed());
  }

  void _syncElapsed() {
    final startedAt = _startedAt;
    if (startedAt == null) return;
    _elapsedSeconds =
        DateTime.now()
            .difference(startedAt)
            .inSeconds
            .clamp(0, 1 << 31)
            .toInt();
    elapsedSecondsListenable.value = _elapsedSeconds;
  }

  void _persistDraftSoon() {
    if (_startedAt == null || _isRestoring || _isFinishing) return;
    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(const Duration(milliseconds: 120), () {
      unawaited(_persistDraft());
    });
  }

  Future<void> _persistDraft() {
    final inFlight = _draftSaveInFlight;
    if (inFlight != null) {
      _draftSaveRequested = true;
      return inFlight;
    }
    late final Future<void> trackedSave;
    trackedSave = _drainDraftSaves().whenComplete(() {
      if (identical(_draftSaveInFlight, trackedSave)) {
        _draftSaveInFlight = null;
      }
    });
    _draftSaveInFlight = trackedSave;
    return trackedSave;
  }

  Future<void> _drainDraftSaves() async {
    do {
      _draftSaveRequested = false;
      await _persistDraftOnce();
    } while (_draftSaveRequested && _startedAt != null && !_isFinishing);
  }

  Future<void> _persistDraftOnce() async {
    final startedAt = _startedAt;
    if (startedAt == null || _isFinishing) return;
    try {
      final autoPresetId = _autoPresetId;
      final payloadJson = jsonEncode({
        'version': 1,
        'exercises': [
          for (var index = 0; index < exercises.length; index++)
            _exerciseToJson(exercises[index], cardTypes[index]),
        ],
      });
      await _withRetries(() async {
        if (_isFinishing || _startedAt != startedAt) return;
        await _repo.saveActiveWorkoutDraft(
          startedAt: startedAt,
          autoPresetId: autoPresetId,
          payloadJson: payloadJson,
        );
      });
      if (_draftSaveFailed) {
        _draftSaveFailed = false;
        notifyListeners();
      }
    } catch (error, stackTrace) {
      _draftSaveFailed = true;
      debugPrint(
        'Could not persist active workout draft (${error.runtimeType}).',
      );
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
    }
  }

  Map<String, dynamic> _exerciseToJson(
    WorkoutExercise exercise,
    CardType type,
  ) {
    final map = <String, dynamic>{
      'type': type.name,
      'name': exercise.name,
      'equipment': exercise.equipment,
    };
    if (exercise is WeightExercise) {
      map.addAll({
        'sourcePresetExerciseId': exercise.sourcePresetExerciseId,
        'sets': exercise.sets.map(_setToJson).toList(),
        'changeSets': {
          for (final entry in exercise.changeSets.entries)
            entry.key.toString(): entry.value.map(_setToJson).toList(),
        },
        'completedParents': exercise.completedParents.toList(),
        'completedChildren': {
          for (final entry in exercise.completedChildren.entries)
            entry.key.toString(): entry.value.toList(),
        },
      });
    } else if (exercise is CardioExercise) {
      map.addAll({
        'cardioName': exercise.cardioName,
        'cardioNote': exercise.cardioNote,
        'plannedMinutes': exercise.plannedMinutes,
        'elapsedSeconds': exercise.elapsedSeconds,
      });
    } else if (exercise is StretchExercise) {
      map.addAll({
        'stretchInstances':
            exercise.stretchInstances.map((item) => item.toMap()).toList(),
        'completedStretchIndices': exercise.completedStretchIndices.toList(),
      });
    }
    return map;
  }

  WorkoutExercise _exerciseFromJson(Map<String, dynamic> map, CardType type) {
    final name = map['name'] as String? ?? '';
    final equipment = map['equipment'] as String? ?? '';
    if (type == CardType.weight) {
      final sets =
          (map['sets'] as List? ?? const [])
              .whereType<Map>()
              .map((item) => _setFromJson(Map<String, dynamic>.from(item)))
              .toList();
      final changeSets = <int, List<ExerciseSet>>{};
      final rawChangeSets = map['changeSets'];
      if (rawChangeSets is Map) {
        for (final entry in rawChangeSets.entries) {
          final parentIndex = int.tryParse(entry.key.toString());
          if (parentIndex == null || entry.value is! List) continue;
          changeSets[parentIndex] =
              (entry.value as List)
                  .whereType<Map>()
                  .map((item) => _setFromJson(Map<String, dynamic>.from(item)))
                  .toList();
        }
      }
      return WeightExercise(
        name: name,
        equipment: equipment,
        sourcePresetExerciseId:
            (map['sourcePresetExerciseId'] as num?)?.toInt(),
        sets: sets,
        changeSets: changeSets,
        completedParents:
            (map['completedParents'] as List? ?? const [])
                .whereType<num>()
                .map((value) => value.toInt())
                .toSet(),
        completedChildren: _completedChildrenFromJson(map['completedChildren']),
      );
    }
    if (type == CardType.cardio) {
      return CardioExercise(
        name: name,
        equipment: equipment,
        cardioName: map['cardioName'] as String?,
        cardioNote: map['cardioNote'] as String?,
        plannedMinutes: (map['plannedMinutes'] as num?)?.toInt(),
        elapsedSeconds: (map['elapsedSeconds'] as num?)?.toInt(),
      );
    }
    return StretchExercise(
      name: name,
      equipment: equipment,
      stretchInstances:
          (map['stretchInstances'] as List? ?? const [])
              .whereType<Map>()
              .map(
                (item) =>
                    StretchInstance.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList(),
      completedStretchIndices:
          (map['completedStretchIndices'] as List? ?? const [])
              .whereType<num>()
              .map((value) => value.toInt())
              .toSet(),
    );
  }

  Map<int, Set<int>> _completedChildrenFromJson(Object? raw) {
    if (raw is! Map) return <int, Set<int>>{};
    final result = <int, Set<int>>{};
    for (final entry in raw.entries) {
      final parentIndex = int.tryParse(entry.key.toString());
      if (parentIndex == null || entry.value is! List) continue;
      result[parentIndex] =
          (entry.value as List)
              .whereType<num>()
              .map((value) => value.toInt())
              .toSet();
    }
    return result;
  }

  Map<String, dynamic> _setToJson(ExerciseSet set) => {
    'sourcePresetSetId': set.sourcePresetSetId,
    'weight': set.weight,
    'reps': set.reps,
  };

  ExerciseSet _setFromJson(Map<String, dynamic> map) => ExerciseSet(
    sourcePresetSetId: (map['sourcePresetSetId'] as num?)?.toInt(),
    weight: (map['weight'] as num?)?.toDouble() ?? 0,
    reps: (map['reps'] as num?)?.toInt() ?? 10,
  );

  ExerciseSet _copySet(ExerciseSet set) => ExerciseSet(
    sourcePresetSetId: set.sourcePresetSetId,
    weight: set.weight,
    reps: set.reps,
  );

  StretchInstance _copyStretch(StretchInstance stretch) => StretchInstance(
    stretchId: stretch.stretchId,
    isCustom: stretch.isCustom,
    customName: stretch.customName,
    customDesc: stretch.customDesc,
    isChecked: stretch.isChecked,
    orderIndex: stretch.orderIndex,
  );

  void _resetActiveState() {
    _timer?.cancel();
    _timer = null;
    _draftSaveTimer?.cancel();
    _draftSaveTimer = null;
    _autoPresetId = null;
    _startedAt = null;
    _elapsedSeconds = 0;
    _isFinishing = false;
    _draftSaveFailed = false;
    exercises.clear();
    cardTypes.clear();
    elapsedSecondsListenable.value = 0;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_persistDraft());
    } else if (state == AppLifecycleState.resumed) {
      _syncElapsed();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _draftSaveTimer?.cancel();
    elapsedSecondsListenable.dispose();
    super.dispose();
  }
}
