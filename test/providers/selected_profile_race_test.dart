import 'dart:async';

import 'package:env_test/models/models.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'disposing during an equipment request prevents late publication',
    () async {
      final repo = _ProfileRepository();
      final selection = SelectedProfile(repository: repo);
      await selection.ready;
      repo.equipmentGates[2] = Completer<List<Map<String, dynamic>>>();
      final change = selection.selectProfile(repo.profiles[1]);
      selection.dispose();
      repo.equipmentGates[2]!.complete([
        {'id': 20},
      ]);
      await expectLater(change, completes);
      expect(selection.equipment.single['id'], 10);
      expect(repo.storedSelection, '1');
    },
  );

  test(
    'a stale equipment response cannot overwrite the latest profile',
    () async {
      final repo = _ProfileRepository();
      final selection = SelectedProfile(repository: repo);
      await selection.ready;
      addTearDown(selection.dispose);
      repo.equipmentGates[2] = Completer<List<Map<String, dynamic>>>();
      repo.equipmentGates[3] = Completer<List<Map<String, dynamic>>>();

      final older = selection.selectProfile(repo.profiles[1]);
      final newer = selection.selectProfile(repo.profiles[2]);
      repo.equipmentGates[3]!.complete([
        {'id': 30, 'name': 'Third profile equipment'},
      ]);
      await newer;
      repo.equipmentGates[2]!.complete([
        {'id': 20, 'name': 'Second profile equipment'},
      ]);
      await older;

      expect(selection.currentProfile!.id, 3);
      expect(selection.equipment.single['id'], 30);
      expect(repo.storedSelection, '3');
    },
  );

  test(
    'a delayed selection write cannot persist an older profile last',
    () async {
      final repo = _ProfileRepository();
      final selection = SelectedProfile(repository: repo);
      await selection.ready;
      addTearDown(selection.dispose);
      repo.selectionWriteGate = Completer<void>();
      final older = selection.selectProfile(repo.profiles[1]);
      await repo.selectionWriteStarted.future;
      final newer = selection.selectProfile(repo.profiles[2]);
      await Future<void>.delayed(Duration.zero);
      repo.selectionWriteGate!.complete();
      await Future.wait([older, newer]);

      expect(selection.currentProfile!.id, 3);
      expect(selection.equipment.single['id'], 30);
      expect(repo.storedSelection, '3');
    },
  );

  test('rapid toggleEquipment calls serialize instead of issuing duplicate removes', () async {
    final repo = _ProfileRepository();
    final selection = SelectedProfile(repository: repo);
    await selection.ready;
    addTearDown(selection.dispose);

    repo.removeGate = Completer<void>();
    final firstToggle = selection.toggleEquipment(10);
    final secondToggle = selection.toggleEquipment(10);
    await repo.removeStarted.future;

    expect(repo.removeCalls, [10]);
    expect(repo.addCalls, isEmpty);

    repo.removeGate!.complete();
    await Future.wait([firstToggle, secondToggle]);

    expect(repo.removeCalls, [10]);
    expect(repo.addCalls, [10]);
    expect(selection.equipment.map((item) => item['id']), [10]);
  });

  test(
    'an in-flight toggleEquipment cannot overwrite a newly selected profile',
    () async {
      final repo = _ProfileRepository();
      final selection = SelectedProfile(repository: repo);
      await selection.ready;
      addTearDown(selection.dispose);

      repo.removeGate = Completer<void>();
      final toggle = selection.toggleEquipment(10);
      await repo.removeStarted.future;

      await selection.selectProfile(repo.profiles[1]);
      expect(selection.currentProfile!.id, 2);
      expect(selection.equipment.map((item) => item['id']), [20]);

      var notificationsAfterSwitch = 0;
      selection.addListener(() => notificationsAfterSwitch++);
      repo.removeGate!.complete();
      await toggle;

      expect(selection.currentProfile!.id, 2);
      expect(selection.equipment.map((item) => item['id']), [20]);
      expect(notificationsAfterSwitch, 0);
    },
  );
}

class _ProfileRepository extends AppRepository {
  final profiles = [
    for (var id = 1; id <= 3; id++)
      GymProfile(id: id, name: 'Gym $id', createdAt: DateTime.utc(2026)),
  ];
  final Map<int, Set<int>> _assignedEquipment = {
    1: {10},
    2: {20},
    3: {30},
  };
  final equipmentGates = <int, Completer<List<Map<String, dynamic>>>>{};
  Completer<void>? selectionWriteGate;
  final selectionWriteStarted = Completer<void>();
  Completer<void>? removeGate;
  final removeStarted = Completer<void>();
  final List<int> addCalls = [];
  final List<int> removeCalls = [];
  String? storedSelection;

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => profiles;

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async =>
      equipmentGates[profileId]?.future ??
      Future.value([
        for (final id in _assignedEquipment[profileId] ?? const <int>{})
          {'id': id},
      ]);

  @override
  Future<void> addEquipmentToProfile(int profileId, int equipmentId) async {
    addCalls.add(equipmentId);
    (_assignedEquipment[profileId] ??= <int>{}).add(equipmentId);
  }

  @override
  Future<void> removeEquipmentFromProfile(
    int profileId,
    int equipmentId,
  ) async {
    removeCalls.add(equipmentId);
    if (removeGate != null && !removeStarted.isCompleted) {
      removeStarted.complete();
      await removeGate!.future;
    }
    _assignedEquipment[profileId]?.remove(equipmentId);
  }

  @override
  Future<String?> getAppState(String key) async => storedSelection;

  @override
  Future<void> setAppState(String key, String? value) async {
    if (value == '2' &&
        selectionWriteGate != null &&
        !selectionWriteStarted.isCompleted) {
      selectionWriteStarted.complete();
      await selectionWriteGate!.future;
    }
    storedSelection = value;
  }
}
