import 'package:env_test/models/models.dart';
import 'package:env_test/providers/preset_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/preset_repository_fixture.dart';

void main() {
  test(
    'typed fallback retains partial fake rows and parent/child alignment',
    () async {
      final repo = _ReadFixture();
      final session = PresetSession(1, repository: repo);
      addTearDown(session.dispose);
      await session.ready;

      expect(session.loadFailure, isNull);
      expect(session.exercises, hasLength(1));
      final exercise = session.exercises.single as WeightExercise;
      expect(exercise.sets.single.weight, 20.0);
      expect(exercise.changeSets[0]!.single.weight, 15.5);
      expect(session.presetParentSetIds.single, [101]);
      expect(session.presetChildSetIds.single, {
        0: [102],
      });
      expect(repo.readIds, [11]); // Unknown exercise is never hydrated.
    },
  );

  test(
    'malformed consumed values fail safely instead of becoming defaults',
    () async {
      for (final row in [
        <String, dynamic>{'id': 101, 'weight': null, 'reps': 8},
        <String, dynamic>{'id': 101, 'weight': 20, 'reps': 8.5},
      ]) {
        final repo = _ReadFixture()..sets = [row];
        final session = PresetSession(1, repository: repo);
        await session.ready;
        expect(session.hasLoaded, isFalse);
        expect(session.loadFailure, isNotNull);
        expect(session.requireLoaded, throwsA(anything));
        expect(session.exercises, isEmpty);
        session.dispose();
      }
    },
  );

  test('typed rows snapshot caller-owned maps and lists', () async {
    final repo = _ReadFixture();
    final reads = repo.openPresetReadSession(1);
    final sets = await reads.fetchSets(11);
    repo.sets[1]['weight'] = 900;
    repo.sets.clear();
    expect(sets[1].weight, 20.0);
    expect(() => sets.clear(), throwsUnsupportedError);
  });

  test(
    'editor flags, null overrides and explicit zero preserve existing policy',
    () async {
      final repo = _ReadFixture()
        ..automatic = {'global_increment': 5, 'adjust_all_sets': 2};
      final session = PresetSession(1, repository: repo);
      addTearDown(session.dispose);
      await session.ready;
      expect(session.loadFailure, isNull);
      expect(session.isAutomatic, isFalse);
      expect(session.skipFirstSet, isTrue);
      expect(session.adjustAllSets, isTrue);
      expect(session.weightCheck, isTrue);
      expect(session.successScope, ProgressionSuccessScope.set);
      expect(session.lastSetIndexByExercise[11], 2);
      expect(session.exerciseIncrementOverrides[11], 0.0);
      expect(session.setIncrementOverrides[101], 0.0);
      expect(session.setIncrementOverrides[102], isNull);
    },
  );

  test(
    'catalog stretches use the overridable name lookup and start unchecked',
    () async {
      final repo = _StretchFixture();
      final session = PresetSession(1, repository: repo);
      addTearDown(session.dispose);
      await session.ready;
      expect(session.loadFailure, isNull);
      expect(repo.requestedStretchId, 7);
      final stretch = session.exercises.single as StretchExercise;
      expect(stretch.name, 'Catalog stretch');
      expect(stretch.stretchInstances.single.isChecked, isFalse);
      expect(stretch.stretchInstances.single.orderIndex, 0);
    },
  );
}

class _ReadFixture extends PresetRepositoryFixture {
  final List<int> readIds = [];
  List<Map<String, dynamic>> sets = [
    {'id': 102, 'parent_set_id': 101, 'weight': 15.5, 'reps': 9},
    {'id': 101, 'weight': 20, 'reps': 8},
    // An ignored orphan deliberately has no otherwise required set fields.
    {'parent_set_id': 999},
  ];
  Map<String, dynamic>? automatic;

  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async =>
      [
        {'id': 11, 'type': 'weight', 'exercise_def_id': 21},
        {'id': 12, 'type': 'unknown'},
      ];

  @override
  Future<List<Map<String, dynamic>>> fetchPresetSets(
    int presetExerciseId,
  ) async {
    readIds.add(presetExerciseId);
    return sets;
  }

  @override
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async =>
      automatic;

  @override
  Future<Map<String, dynamic>?> fetchPresetExerciseAuto(int id) async => {
    'increment_amount': 0,
  };

  @override
  Future<Map<String, dynamic>?> fetchPresetSetAuto(int id) async =>
      id == 101 ? {'increment_amount': 0} : null;
}

class _StretchFixture extends PresetRepositoryFixture {
  int? requestedStretchId;

  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int id) async => [
    {'id': 11, 'type': 'stretch'},
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchPresetStretchItems(int id) async => [
    {'stretch_id': 7, 'is_custom': 0, 'order_index': 0.0},
  ];

  @override
  Future<String?> fetchStretchDefinitionNameById(int id) async {
    requestedStretchId = id;
    return 'Catalog stretch';
  }
}
