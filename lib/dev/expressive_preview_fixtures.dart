import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../services/tutorial_state_store.dart';

/// Seeds and resets only rows recorded in this preview database's manifest.
class ExpressivePreviewFixtures {
  ExpressivePreviewFixtures._(
    this._repository,
    this.profileId, {
    this._startupStopwatch,
  });

  static const _manifestKey = 'tonos.expressive_preview.fixtures.v1';
  static const _profileName = 'Expressive Preview';
  static const _activePlanCount = 4;
  static const _archivedPlanCount = 4;

  final AppRepository _repository;
  final int profileId;
  Stopwatch? _startupStopwatch;

  void _startupCheckpoint(String stage) {
    final stopwatch = _startupStopwatch;
    if (stopwatch == null) return;
    debugPrint(
      '[expressive-preview] +${stopwatch.elapsedMilliseconds}ms fixtures.$stage',
    );
  }

  static Future<ExpressivePreviewFixtures> prepare(
    AppRepository repository,
  ) async {
    final startupStopwatch = Stopwatch()..start();
    final fixtures = ExpressivePreviewFixtures._(
      repository,
      0,
      startupStopwatch: startupStopwatch,
    );
    fixtures._startupCheckpoint('repository.warmUp started');
    await repository.warmUp();
    fixtures._startupCheckpoint('repository.warmUp completed');
    fixtures._startupCheckpoint('removeRecordedRows started');
    await fixtures._removeRecordedRows();
    fixtures._startupCheckpoint('removeRecordedRows completed');
    final profileId = await fixtures._seed();
    final prepared = ExpressivePreviewFixtures._(
      repository,
      profileId,
      startupStopwatch: startupStopwatch,
    );
    prepared._startupCheckpoint('reviewPreferences started');
    await prepared._configureReviewOnlyPreferences();
    prepared._startupCheckpoint('reviewPreferences completed');
    startupStopwatch.stop();
    prepared._startupStopwatch = null;
    return prepared;
  }

  /// Rebuilds the known preview fixtures without clearing any other database rows.
  Future<ExpressivePreviewFixtures> resetAndSeed() async {
    await _removeRecordedRows();
    final nextProfileId = await _seed();
    await _configureReviewOnlyPreferences();
    return ExpressivePreviewFixtures._(_repository, nextProfileId);
  }

  Future<void> _removeRecordedRows() async {
    final encoded = await _repository.getAppState(_manifestKey);
    if (encoded == null) return;

    final Object? decoded;
    try {
      decoded = jsonDecode(encoded);
    } on FormatException {
      await _repository.setAppState(_manifestKey, null);
      return;
    }
    if (decoded is! Map<String, dynamic>) {
      await _repository.setAppState(_manifestKey, null);
      return;
    }

    final profileId = decoded['profileId'] as int?;
    final presetIds = _readIds(decoded['presetIds']);
    final sessionIds = _readIds(decoded['sessionIds']);

    if (profileId != null) {
      await _repository.replaceActivePlans(profileId, const <int>{});
    }
    for (final sessionId in sessionIds) {
      await _repository.deleteSession(sessionId);
    }
    for (final presetId in presetIds) {
      await _repository.deletePreset(presetId);
    }
    if (profileId != null) await _repository.deleteProfile(profileId);
    await _repository.setAppState(_manifestKey, null);
  }

  Future<int> _seed() async {
    _startupCheckpoint('detailedExerciseDefinitions query started');
    final definitions = await _repository.lookupDefsDetailed();
    _startupCheckpoint(
      'detailedExerciseDefinitions query completed count=${definitions.length}',
    );
    final eligibleDefinitions = definitions
        .where(
          (definition) =>
              !definition.isRetiredCatalogEntry &&
              definition.bodyParts.isNotEmpty &&
              definition.muscles.isNotEmpty,
        )
        .toList(growable: false);
    _startupCheckpoint(
      'exerciseDefinitions eligible=${eligibleDefinitions.length}',
    );
    if (eligibleDefinitions.length < 3) {
      throw StateError(
        'The local exercise catalog is not ready for preview fixtures.',
      );
    }

    _startupCheckpoint('equipment query started');
    final equipment = await _repository.fetchAllEquipment();
    _startupCheckpoint('equipment query completed count=${equipment.length}');
    _startupCheckpoint('profile creation started');
    final profileId = await _repository.saveGymProfileAtomic(
      existingProfile: null,
      name: _profileName,
      equipmentIds: equipment.map((item) => item.id).toSet(),
    );
    _startupCheckpoint('profile creation completed');
    var presetIds = <int>[];
    var sessionIds = <int>[];
    await _writeManifest(
      profileId: profileId,
      presetIds: presetIds,
      sessionIds: sessionIds,
    );

    final activePresetIds = <int>{};
    final planCount = _activePlanCount + _archivedPlanCount;
    for (var planIndex = 0; planIndex < planCount; planIndex++) {
      final isActive = planIndex < _activePlanCount;
      final exerciseWrites = <WorkoutExerciseWrite>[];
      for (var exerciseOffset = 0; exerciseOffset < 3; exerciseOffset++) {
        final definition =
            eligibleDefinitions[(planIndex + exerciseOffset) %
                eligibleDefinitions.length];
        exerciseWrites.add(_exerciseWrite(definition, planIndex));
      }

      final prefix = isActive ? 'Active Review' : 'Archived Review';
      _startupCheckpoint('preset ${planIndex + 1}/$planCount creation started');
      final presetId = await _repository.createPresetAtomic(
        name: '$prefix ${planIndex + 1}',
        profileId: profileId,
        exercises: exerciseWrites,
      );
      presetIds = [...presetIds, presetId];
      if (isActive) activePresetIds.add(presetId);
      await _writeManifest(
        profileId: profileId,
        presetIds: presetIds,
        sessionIds: sessionIds,
      );
      _startupCheckpoint('preset ${planIndex + 1}/$planCount completed');
    }
    _startupCheckpoint('activePlan replacement started');
    await _repository.replaceActivePlans(profileId, activePresetIds);
    _startupCheckpoint('activePlan replacement completed');

    final now = DateTime.now();
    for (var sessionIndex = 0; sessionIndex < 3; sessionIndex++) {
      _startupCheckpoint('session ${sessionIndex + 1}/3 creation started');
      final completedAt = DateTime(
        now.year,
        now.month,
        now.day - (1 + sessionIndex * 2),
        18,
      );
      final sessionExercises = <WorkoutExerciseWrite>[];
      for (var exerciseOffset = 0; exerciseOffset < 2; exerciseOffset++) {
        final definition =
            eligibleDefinitions[(sessionIndex + exerciseOffset) %
                eligibleDefinitions.length];
        sessionExercises.add(
          WorkoutExerciseWrite(
            exercise: WeightExercise(
              name: definition.name,
              equipment: _equipmentName(definition),
              sets: [
                ExerciseSet(
                  weight: 20 + sessionIndex * 5,
                  reps: 10 + exerciseOffset,
                ),
                ExerciseSet(
                  weight: 20 + sessionIndex * 5,
                  reps: 10 + exerciseOffset,
                ),
                ExerciseSet(
                  weight: 20 + sessionIndex * 5,
                  reps: 10 + exerciseOffset,
                ),
              ],
            ),
            type: 'weight',
            definitionId: definition.id,
          ),
        );
      }
      final sessionId = await _repository.completeWorkoutAtomic(
        completedAt: completedAt,
        durationSeconds: 32 * 60 + sessionIndex * 4 * 60,
        exercises: sessionExercises,
      );
      sessionIds = [...sessionIds, sessionId];
      await _writeManifest(
        profileId: profileId,
        presetIds: presetIds,
        sessionIds: sessionIds,
      );
      _startupCheckpoint('session ${sessionIndex + 1}/3 completed');
    }

    _startupCheckpoint('selectedProfile write started');
    await _repository.setAppState(
      'selected_gym_profile_id',
      profileId.toString(),
    );
    _startupCheckpoint('seed completed');
    return profileId;
  }

  WorkoutExerciseWrite _exerciseWrite(
    ExerciseDefinition definition,
    int planIndex,
  ) => WorkoutExerciseWrite(
    exercise: WeightExercise(
      name: definition.name,
      equipment: _equipmentName(definition),
      sets: [
        ExerciseSet(weight: 20 + planIndex * 2, reps: 10),
        ExerciseSet(weight: 20 + planIndex * 2, reps: 10),
        ExerciseSet(weight: 20 + planIndex * 2, reps: 10),
      ],
    ),
    type: 'weight',
    definitionId: definition.id,
  );

  String _equipmentName(ExerciseDefinition definition) =>
      definition.equipmentList.isEmpty
      ? 'Bodyweight'
      : definition.equipmentList.first.name;

  Future<void> _writeManifest({
    required int profileId,
    required List<int> presetIds,
    required List<int> sessionIds,
  }) => _repository.setAppState(
    _manifestKey,
    jsonEncode({
      'profileId': profileId,
      'presetIds': presetIds,
      'sessionIds': sessionIds,
    }),
  );

  List<int> _readIds(Object? value) =>
      value is List ? value.whereType<int>().toList(growable: false) : const [];

  Future<void> _configureReviewOnlyPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('onboarding_completed', true);
    await preferences.setBool('always_show_onboarding', false);
    await preferences.setInt('train.optimized_min_sets_per_exercise', 1);
    await preferences.setInt('train.optimized_max_sets_per_exercise', 1);
    await preferences.setInt('train.optimized_session_minutes', 45);
    await const TutorialStateStore().skipAll();
  }
}
