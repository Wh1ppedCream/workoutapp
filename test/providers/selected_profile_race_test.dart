import 'dart:async';

import 'package:env_test/models/models.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}

class _ProfileRepository extends AppRepository {
  final profiles = [
    for (var id = 1; id <= 3; id++)
      GymProfile(id: id, name: 'Gym $id', createdAt: DateTime.utc(2026)),
  ];
  final equipmentGates = <int, Completer<List<Map<String, dynamic>>>>{};
  Completer<void>? selectionWriteGate;
  final selectionWriteStarted = Completer<void>();
  String? storedSelection;

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => profiles;

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async =>
      equipmentGates[profileId]?.future ??
      Future.value([
        {'id': profileId * 10},
      ]);

  @override
  Future<String?> getAppState(String key) async => storedSelection;

  @override
  Future<void> setAppState(String key, String? value) async {
    if (value == '2' && selectionWriteGate != null) {
      selectionWriteStarted.complete();
      await selectionWriteGate!.future;
    }
    storedSelection = value;
  }
}
