// File: lib/models/active_session.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../widgets/exercise_card.dart'; // for CardType
import '../repositories/app_repository.dart';

/// Holds the in-memory state of a workout session, including timer and exercises.
class ActiveSession extends ChangeNotifier {
  final _repo = AppRepository();

  Timer? _timer;
  int _elapsedSeconds = 0;

  bool get isActive => _timer != null;
  int get elapsedSeconds => _elapsedSeconds;
  String get formattedTime {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// Lists to hold the in-flight workout data.
  final List<WorkoutExercise> exercises = [];
  final List<CardType> cardTypes = [];

  /// Starts a new workout timer and state.
  void start() {
    if (_timer != null) return;
    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  /// Tell Provider to rebuild any listeners
  void refresh() {
    notifyListeners();
  }

  /// Adds a new exercise card to the session.
  void addExercise(WorkoutExercise ex, CardType type) {
    exercises.add(ex);
    cardTypes.add(type);
    notifyListeners();
  }

  /// Removes an exercise at [index].
  void removeExercise(int index) {
    exercises.removeAt(index);
    cardTypes.removeAt(index);
    notifyListeners();
  }

  /// Finishes the session: writes to DB and clears in-memory state.
  Future<void> finish() async {
    if (_timer == null) return;
    _timer!.cancel();

    // 1) Create session row
    final nowIso = DateTime.now().toIso8601String();
    final sid = await _repo.createSession(nowIso, _elapsedSeconds);

    // 2) Persist exercises
    for (var i = 0; i < exercises.length; i++) {
      final we   = exercises[i];
      final type = cardTypes[i];

      if (type == CardType.weight && we is WeightExercise) {
        final defId = await _repo.findOrCreateExerciseDefinition(
          we.name, we.equipment,
        );
        final exId = await _repo.addExerciseRow(
          sessionId:     sid,
          exerciseDefId: defId,
          type:          'weight',
          orderIndex:    i,
        );
        await _repo.addWeightSets(
          exerciseId:      exId,
          parentSets:      we.sets,
          childChangeSets: we.changeSets,
        );
      } else if (type == CardType.cardio && we is CardioExercise) {
        final exId = await _repo.addExerciseRow(
          sessionId:     sid,
          exerciseDefId: null,
          type:          'cardio',
          orderIndex:    i,
        );
        await _repo.saveCardioDetails(
          exerciseId:     exId,
          cardioName:     we.cardioName,
          note:           we.cardioNote,
          plannedMinutes: we.plannedMinutes,
          elapsedSeconds: we.elapsedSeconds,
        );
      } else if (type == CardType.stretch && we is StretchExercise) {
        final exId = await _repo.addExerciseRow(
          sessionId:     sid,
          exerciseDefId: null,
          type:          'stretch',
          orderIndex:    i,
        );
        await _repo.saveStretchInstance(
          exerciseId: exId,
          items:      we.stretchInstances,
        );
      }
    }

    // 3) Clear state
    _timer = null;
    exercises.clear();
    cardTypes.clear();
    _elapsedSeconds = 0;
    notifyListeners();
  }
}