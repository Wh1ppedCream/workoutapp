import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../providers/active_session.dart';
import '../providers/preset_session.dart';
import '../repositories/app_repository.dart';
import '../utils/workout_exercise_clone.dart';
import 'active_plan_store.dart';
import 'preset_generation_service.dart';
import 'safe_failure.dart';

enum OptimizedWorkoutLaunchStatus {
  started,
  alreadyActive,
  restRecommended,
  noEligibleExercises,
  cancelled,
  inProgress,
}

class OptimizedWorkoutLaunchResult {
  const OptimizedWorkoutLaunchResult(this.status, {this.generationResult});

  final OptimizedWorkoutLaunchStatus status;
  final PresetGenerationResult? generationResult;
}

/// Shared workout/plan operations for the two training presentations.
/// Navigation, dialogs and page refreshes remain owned by their callers.
class WorkoutLaunchCoordinator {
  WorkoutLaunchCoordinator({
    required AppRepository repository,
    required this._activeSession,
    PresetGenerationService? generator,
  }) : _repository = repository,
       _generator = generator ?? PresetGenerationService(repository);

  final AppRepository _repository;
  final ActiveSession _activeSession;
  final PresetGenerationService _generator;

  /// A successful return means callers may open the session screen. Failed
  /// restoration/import/finishing must not masquerade as an empty workout.
  Future<void> startOrResume() async {
    await _activeSession.ready;
    if (_activeSession.startBlock == WorkoutStartBlock.alreadyActive) return;
    _requireAvailableSession();
    if (!await _activeSession.start() &&
        _activeSession.startBlock != WorkoutStartBlock.alreadyActive) {
      _requireAvailableSession();
    }
  }

  Future<int?> createManualPreset({
    required int? profileId,
    required String Function(int number) nameForNumber,
    required bool Function() canContinue,
  }) async {
    final existing = await _repository.fetchAllPresetsRaw(profileId: profileId);
    if (!canContinue()) return null;
    final name = nameForNumber(existing.length + 1);
    await ActivePlanStore(repository: _repository).load(profileId);
    if (!canContinue()) return null;
    return _repository.createPresetAtomic(
      name: name,
      profileId: profileId,
      exercises: const [],
      activate: true,
      uniqueName: true,
    );
  }

  /// Generates a one-off workout, leaving no saved preset behind. The shared
  /// ActiveSession remains responsible for rejecting competing session starts.
  Future<OptimizedWorkoutLaunchResult> startOptimized({
    required SessionSpec spec,
    required bool Function() canContinue,
  }) async {
    if (!_activeSession.tryBeginWorkoutPreparation()) {
      _requireAvailableSession();
      return const OptimizedWorkoutLaunchResult(
        OptimizedWorkoutLaunchStatus.inProgress,
      );
    }
    try {
      return await _startOptimized(spec: spec, canContinue: canContinue);
    } finally {
      _activeSession.endWorkoutPreparation();
    }
  }

  Future<OptimizedWorkoutLaunchResult> _startOptimized({
    required SessionSpec spec,
    required bool Function() canContinue,
  }) async {
    await _activeSession.ready;
    if (!canContinue()) {
      return const OptimizedWorkoutLaunchResult(
        OptimizedWorkoutLaunchStatus.cancelled,
      );
    }
    if (_activeSession.startBlock == WorkoutStartBlock.alreadyActive) {
      return const OptimizedWorkoutLaunchResult(
        OptimizedWorkoutLaunchStatus.alreadyActive,
      );
    }
    _requireAvailableSession();
    final shouldRest = await _generator.shouldRestBeforeOptimizedWorkout(spec);
    if (!canContinue()) {
      return const OptimizedWorkoutLaunchResult(
        OptimizedWorkoutLaunchStatus.cancelled,
      );
    }
    if (shouldRest) {
      return const OptimizedWorkoutLaunchResult(
        OptimizedWorkoutLaunchStatus.restRecommended,
      );
    }
    _requireAvailableSession();

    int? temporaryPresetId;
    try {
      final generation = await _generator.generatePresetWithDetails(spec);
      final presetId = generation.presetId;
      temporaryPresetId = presetId;
      _requireAvailableSession();
      if (!canContinue()) {
        return const OptimizedWorkoutLaunchResult(
          OptimizedWorkoutLaunchStatus.cancelled,
        );
      }
      final preset = PresetSession(presetId, repository: _repository);
      final exercises = <WorkoutExercise>[];
      final cardTypes = <CardType>[];
      try {
        await preset.ready;
        preset.requireLoaded();
        if (!canContinue()) {
          return const OptimizedWorkoutLaunchResult(
            OptimizedWorkoutLaunchStatus.cancelled,
          );
        }
        for (var i = 0; i < preset.exercises.length; i++) {
          // Keep generated sessions weight-only until cardio/stretch cards
          // support the existing training launch flow.
          if (preset.cardTypes[i] != CardType.weight) continue;
          exercises.add(cloneWorkoutExercise(preset.exercises[i]));
          cardTypes.add(preset.cardTypes[i]);
        }
      } finally {
        preset.dispose();
      }

      if (exercises.isEmpty) {
        await _repository.deletePreset(presetId);
        temporaryPresetId = null;
        return const OptimizedWorkoutLaunchResult(
          OptimizedWorkoutLaunchStatus.noEligibleExercises,
        );
      }

      final started = await _activeSession.startWithExercises(
        workoutExercises: exercises,
        workoutCardTypes: cardTypes,
      );
      await _repository.deletePreset(presetId);
      temporaryPresetId = null;
      if (!started &&
          _activeSession.startBlock != WorkoutStartBlock.alreadyActive) {
        _requireAvailableSession();
      }
      return OptimizedWorkoutLaunchResult(
        started
            ? OptimizedWorkoutLaunchStatus.started
            : OptimizedWorkoutLaunchStatus.alreadyActive,
        generationResult: generation,
      );
    } finally {
      if (temporaryPresetId != null) {
        try {
          await _repository.deletePreset(temporaryPresetId);
        } catch (error) {
          debugPrint('Failed to delete temporary optimized preset: $error');
        }
      }
    }
  }

  void _requireAvailableSession() {
    final block = _activeSession.startBlock;
    if (block != null && block != WorkoutStartBlock.alreadyActive) {
      // The persistent durability notice supplies the restore-specific retry.
      // A blocked import/finish must never be presented as another workout.
      throw const SafeFailure(kind: SafeFailureKind.temporary, retryable: true);
    }
  }
}
