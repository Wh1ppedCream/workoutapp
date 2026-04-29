// File: lib/providers/active_session.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../widgets/exercise_card.dart';
import '../repositories/app_repository.dart';
import '../services/auto_increment_service.dart';

/// Holds the in-memory state of a workout session, including timer and exercises.
class ActiveSession extends ChangeNotifier {
  final _repo = AppRepository();

  // NEW: track which preset (if any) this session was started from
  int? _autoPresetId;

  Timer? _timer;
  int _elapsedSeconds = 0;
  int _completedSessionVersion = 0;

  bool get isActive => _timer != null;
  int get elapsedSeconds => _elapsedSeconds;
  int get completedSessionVersion => _completedSessionVersion;
  String get formattedTime {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// Lists to hold the in-flight workout data.
  final List<WorkoutExercise> exercises = [];
  final List<CardType> cardTypes = [];

  /// Starts a new workout timer and state.
  void start({int? presetId}) {
    if (_timer != null) return;
    _autoPresetId = presetId;
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
  Future<int?> finish() async {
    if (_timer == null) return null;
    _timer!.cancel();

    // ── 0) FILTER OUT UNCHECKED ITEMS ─────────────────────────────────
    for (var i = 0; i < exercises.length; i++) {
      final we = exercises[i];
      final type = cardTypes[i];

      if (type == CardType.weight && we is WeightExercise) {
        final keptParents = <ExerciseSet>[];
        final keptChildrenMap = <int, List<ExerciseSet>>{};

        for (var pIdx = 0; pIdx < we.sets.length; pIdx++) {
          if (we.completedParents.contains(pIdx)) {
            final keptParentIndex = keptParents.length;
            keptParents.add(we.sets[pIdx]);

            final originalChildren = we.changeSets[pIdx] ?? [];
            final keptChildren = <ExerciseSet>[];
            for (var cIdx = 0; cIdx < originalChildren.length; cIdx++) {
              if (we.completedChildren[pIdx]?.contains(cIdx) ?? false) {
                keptChildren.add(originalChildren[cIdx]);
              }
            }
            if (keptChildren.isNotEmpty) {
              keptChildrenMap[keptParentIndex] = keptChildren;
            }
          }
        }

        we.sets
          ..clear()
          ..addAll(keptParents);
        we.changeSets
          ..clear()
          ..addAll(keptChildrenMap);
      } else if (type == CardType.stretch && we is StretchExercise) {
        final kept = <StretchInstance>[];
        for (var idx = 0; idx < we.stretchInstances.length; idx++) {
          if (we.completedStretchIndices.contains(idx)) {
            kept.add(we.stretchInstances[idx]);
          }
        }
        we.stretchInstances
          ..clear()
          ..addAll(kept);
      }
    }

    // 1) Create session row (non-deprecated API)
    final sid = await _repo.createSessionAt(DateTime.now(), _elapsedSeconds);
    // If your codebase doesn't yet expose createSessionAt, temporarily fall back:
    // final sid = await _repo.createSession(DateTime.now().toIso8601String(), _elapsedSeconds);

    // 2) Persist exercises
    for (var i = 0; i < exercises.length; i++) {
      final we = exercises[i];
      final type = cardTypes[i];

      if (type == CardType.weight && we is WeightExercise) {
        final defId = await _repo.findOrCreateExerciseDefinition(
          we.name,
          we.equipment,
        );
        final exId = await _repo.addExerciseRow(
          sessionId: sid,
          exerciseDefId: defId,
          type: 'weight',
          orderIndex: i,
        );

        await _repo.addWeightSets(
          exerciseId: exId,
          parentSets: we.sets,
          childChangeSets: we.changeSets,
        );

        // ── Session-level stats ────────────────────────────────────────
        double sessionVm = 0;
        for (final set in we.sets) {
          final weight = set.weight;
          final reps = set.reps;

          sessionVm = max(sessionVm, weight * reps);

          final oneErm = weight * (1 + 0.0333 * reps);

          await _repo.updateRepMax(
            defId,
            reps,
            'all',
            weight, // rm_value
            oneErm, // one_erm
            false, // is_erm (actual record)
          );
        }
        await _repo.updateVolumeMax(defId, 'all', sessionVm);
      } else if (type == CardType.cardio && we is CardioExercise) {
        final exId = await _repo.addExerciseRow(
          sessionId: sid,
          exerciseDefId: null,
          type: 'cardio',
          orderIndex: i,
        );
        await _repo.saveCardioDetails(
          exerciseId: exId,
          cardioName: we.cardioName,
          note: we.cardioNote,
          plannedMinutes: we.plannedMinutes,
          elapsedSeconds: we.elapsedSeconds,
        );
      } else if (type == CardType.stretch && we is StretchExercise) {
        final exId = await _repo.addExerciseRow(
          sessionId: sid,
          exerciseDefId: null,
          type: 'stretch',
          orderIndex: i,
        );
        await _repo.saveStretchInstance(
          exerciseId: exId,
          items: we.stretchInstances.map((inst) => inst.toMap()).toList(),
        );
      }
    }

    // ─── APPLY AUTO-INCREMENT IF STARTED FROM A PRESET ────────────────
    if (_autoPresetId != null) {
      await AutoIncrementService(
        _repo,
      ).apply(sessionId: sid, presetId: _autoPresetId!);
      _autoPresetId = null;
    }

    // 3) Clear state
    _timer = null;
    exercises.clear();
    cardTypes.clear();
    _elapsedSeconds = 0;
    _completedSessionVersion++;
    notifyListeners();
    return sid;
  }
}
