import 'dart:async';

import 'package:env_test/models/models.dart';
import 'package:env_test/providers/preset_session.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/services/safe_failure.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/preset_repository_fixture.dart';

void main() {
  test('failed initial loads reject editing, saving and starting until retry succeeds', () async {
    final repo = _FailedInitialPresetRepository();
    final session = PresetSession(1, repository: repo);
    addTearDown(session.dispose);
    await session.ready;
    expect(session.hasLoaded, isFalse);
    expect(session.isLoading, isFalse);
    expect(session.requireLoaded, throwsA(isA<SafeFailure>()));
    expect(
      () => session.addExercise(
        WeightExercise(name: 'Unsafe partial edit', equipment: '', sets: []),
        CardType.weight,
        defId: 21,
      ),
      throwsA(isA<SafeFailure>()),
    );
    await expectLater(session.saveChanges(), throwsA(isA<SafeFailure>()));
    await expectLater(session.startSession(), throwsA(isA<SafeFailure>()));
    expect(repo.replaceCalls, 0);
    expect(session.exercises, isEmpty);

    repo.failRead = false;
    await session.retryLoad();
    expect(session.hasLoaded, isTrue);
    expect(session.loadFailure, isNull);
    expect(session.isLoading, isFalse);
    await session.saveChanges();
    expect(repo.replaceCalls, 1);
  });

  test('editing before initial loading completes cannot cancel the persisted plan load', () async {
    final repo = _ReloadRacePresetRepository();
    final gate = Completer<PresetDefinition?>();
    repo.fetchQueue.add(gate.future);
    final session = PresetSession(1, repository: repo);
    addTearDown(session.dispose);
    expect(session.isLoading, isTrue);
    expect(session.refresh, throwsA(isA<SafeFailure>()));
    gate.complete(
      PresetDefinition(
        id: 1,
        name: 'Original plan',
        createdAt: DateTime.utc(2026),
      ),
    );
    await session.ready;
    expect(session.hasLoaded, isTrue);
    expect(session.presetName, 'Original plan');
  });
  test('skips missing cardio details and unknown types without skewing exercise metadata', () async {
    final repo = _AlignedPresetRepository();
    final session = PresetSession(1, repository: repo);
    addTearDown(session.dispose);
    await session.ready;

    expect(session.loadFailure, isNull);
    expect(session.exercises, hasLength(3));
    expect(session.cardTypes, [
      CardType.weight,
      CardType.cardio,
      CardType.stretch,
    ]);
    expect(session.presetExerciseIds, [11, 13, 14]);
    expect(session.presetParentSetIds, [
      [201, 202],
      <int>[],
      <int>[],
    ]);
    expect(session.presetChildSetIds, [
      {
        0: [203],
      },
      <int, List<int>>{},
      <int, List<int>>{},
    ]);
    expect(session.definitionIdForExercise(0), 50);
    expect(session.definitionIdForExercise(1), isNull);
    expect(session.definitionIdForExercise(2), isNull);
    expect(
      session.exerciseIncrementOverrides.keys,
      unorderedEquals([11, 13, 14]),
    );

    session.reorderExercise(0, 3);
    expect(session.cardTypes, [
      CardType.cardio,
      CardType.stretch,
      CardType.weight,
    ]);
    expect(session.presetExerciseIds, [13, 14, 11]);
    expect(session.definitionIdForExercise(2), 50);
    expect(session.presetParentSetIds[2], [201, 202]);

    session.replaceWeightExerciseDefinition(
      2,
      ExerciseDefinition(
        id: 99,
        name: 'Front Squat',
        useManualBodyparts: false,
        multiplyByRating: false,
        equipmentList: [Equipment(1, 'Barbell')],
      ),
    );
    expect(session.exercises[2].name, 'Front Squat');
    expect(session.definitionIdForExercise(2), 99);

    session.removeExercise(2);
    expect(session.exercises, hasLength(2));
    expect(session.presetExerciseIds, [13, 14]);
    expect(session.exerciseIncrementOverrides.containsKey(11), isFalse);
    expect(session.setIncrementOverrides.containsKey(201), isFalse);
    expect(session.setIncrementOverrides.containsKey(203), isFalse);
  });

  test('an older overlapping discardChanges reload cannot overwrite a newer reload', () async {
    final repo = _ReloadRacePresetRepository();
    final session = PresetSession(1, repository: repo);
    addTearDown(session.dispose);
    await session.ready;
    expect(session.presetName, 'Initial plan');

    final olderGate = Completer<PresetDefinition?>();
    final newerGate = Completer<PresetDefinition?>();
    repo.fetchQueue.addAll([olderGate.future, newerGate.future]);

    final olderReload = session.discardChanges();
    final newerReload = session.discardChanges();

    newerGate.complete(
      PresetDefinition(
        id: 1,
        name: 'Newest plan',
        createdAt: DateTime.utc(2026),
      ),
    );
    await newerReload;
    expect(session.presetName, 'Newest plan');

    olderGate.complete(
      PresetDefinition(
        id: 1,
        name: 'Stale plan',
        createdAt: DateTime.utc(2026),
      ),
    );
    await olderReload;
    expect(session.presetName, 'Newest plan');
  });

  test('disposing during initialization completes ready without notifying disposed listeners', () async {
    final repo = _ReloadRacePresetRepository();
    final gate = Completer<PresetDefinition?>();
    repo.fetchQueue.add(gate.future);

    final session = PresetSession(1, repository: repo);
    var notifications = 0;
    session.addListener(() => notifications++);
    session.dispose();

    gate.complete(
      PresetDefinition(id: 1, name: 'Late plan', createdAt: DateTime.utc(2026)),
    );
    await expectLater(session.ready, completes);
    expect(notifications, 0);
  });

  test('classifies initial and reload failures with SafeFailure while preserving unsaved edits', () async {
    final failingRepo = _ReloadRacePresetRepository()..failFetch = true;
    final failedBoot = PresetSession(1, repository: failingRepo);
    addTearDown(failedBoot.dispose);
    await expectLater(failedBoot.ready, completes);
    expect(failedBoot.loadFailure?.kind, SafeFailureKind.temporary);

    final repo = _ReloadRacePresetRepository();
    final session = PresetSession(1, repository: repo);
    addTearDown(session.dispose);
    await session.ready;

    session.addExercise(
      WeightExercise(
        name: 'Bench Press',
        equipment: 'Barbell',
        sets: [ExerciseSet(weight: 60, reps: 8)],
        changeSets: {},
      ),
      CardType.weight,
      defId: 42,
    );
    expect(session.exercises, hasLength(1));
    expect(session.hasChanges, isTrue);

    repo.failFetch = true;
    await expectLater(
      session.discardChanges(),
      throwsA(isA<TimeoutException>()),
    );
    expect(session.loadFailure?.kind, SafeFailureKind.temporary);
    expect(session.exercises, hasLength(1));
    expect(session.exercises.single.name, 'Bench Press');
    expect(session.hasChanges, isTrue);
  });
}

class _FailedInitialPresetRepository extends PresetRepositoryFixture {
  bool failRead = true;
  int replaceCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) {
    if (failRead) throw TimeoutException('Injected read failure');
    return super.fetchPresetExercises(presetId);
  }

  @override
  Future<void> replacePresetAtomic({
    required int presetId,
    required String? name,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
    bool publishDraft = false,
  }) async {
    replaceCalls++;
  }
}

class _AlignedPresetRepository extends AppRepository {
  @override
  Future<PresetDefinition?> fetchPresetById(int presetId) async =>
      PresetDefinition(
        id: presetId,
        name: 'Mixed plan',
        createdAt: DateTime.utc(2026),
      );

  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async =>
      [
        {'id': 11, 'type': 'weight', 'exercise_def_id': 50},
        {'id': 12, 'type': 'cardio', 'exercise_def_id': null},
        {'id': 13, 'type': 'cardio', 'exercise_def_id': null},
        {'id': 14, 'type': 'stretch', 'exercise_def_id': null},
        {'id': 15, 'type': 'legacy_unknown', 'exercise_def_id': null},
      ];

  @override
  Future<Map<String, String?>> fetchDefinitionInfo(int defId) async => {
    'name': 'Back Squat',
    'equipmentName': 'Barbell',
  };

  @override
  Future<List<Map<String, dynamic>>> fetchPresetSets(
    int presetExerciseId,
  ) async => [
    {'id': 201, 'parent_set_id': null, 'weight': 100.0, 'reps': 5},
    {'id': 202, 'parent_set_id': null, 'weight': 100.0, 'reps': 5},
    {'id': 203, 'parent_set_id': 201, 'weight': 80.0, 'reps': 8},
  ];

  @override
  Future<Map<String, dynamic>?> fetchPresetCardio(int presetExerciseId) async {
    if (presetExerciseId == 12) return null; // Corrupted/missing cardio row.
    return {
      'cardio_name': 'Rowing',
      'note': 'Steady pace',
      'planned_minutes': 15,
      'elapsed_seconds': 0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPresetStretchItems(
    int presetExerciseId,
  ) async => [
    {
      'stretch_id': null,
      'is_custom': 1,
      'custom_name': 'Hip Flexor Stretch',
      'custom_desc': null,
      'order_index': 0,
    },
  ];

  @override
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async => {
    'is_automatic': 1,
    'global_increment': 5.0,
    'skip_first_set': 1,
    'weight_check': 1,
    'rep_check': 1,
    'volume_check': 0,
    'adjust_all_sets': 0,
    'use_manual_select': 1,
    'manual_selection_json': '{"201":true,"bad_key":true}',
    'success_count_mode': 'set',
  };

  @override
  Future<Map<String, dynamic>?> fetchPresetExerciseAuto(
    int presetExerciseId,
  ) async => {'increment_amount': 2.5, 'last_set_index': 1};

  @override
  Future<Map<String, dynamic>?> fetchPresetSetAuto(int presetSetId) async => {
    'increment_amount': 1.25,
  };
}

class _ReloadRacePresetRepository extends AppRepository {
  final List<Future<PresetDefinition?>> fetchQueue = [];
  bool failFetch = false;

  @override
  Future<PresetDefinition?> fetchPresetById(int presetId) {
    if (failFetch) {
      return Future<PresetDefinition?>.error(
        TimeoutException('simulated storage timeout'),
      );
    }
    if (fetchQueue.isNotEmpty) {
      return fetchQueue.removeAt(0);
    }
    return Future.value(
      PresetDefinition(
        id: presetId,
        name: 'Initial plan',
        createdAt: DateTime.utc(2026),
      ),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async =>
      const [];

  @override
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async =>
      null;
}
