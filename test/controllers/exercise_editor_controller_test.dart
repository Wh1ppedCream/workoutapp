import 'dart:async';

import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/exercise_editor/exercise_editor_controller.dart';
import 'package:flutter_test/flutter_test.dart';

ExerciseDefinition _definition(int id) => ExerciseDefinition(
  id: id,
  name: 'Exercise $id',
  useManualBodyparts: false,
  multiplyByRating: false,
);

ExerciseDefinitionWrite _write(ExerciseDefinition definition) =>
    ExerciseDefinitionWrite(
      definition: definition,
      useManualMuscles: false,
      muscleIds: [],
      musclePercents: {},
      equipmentIds: {},
      bodyPartPercents: {},
      mediaItems: [],
    );

class _EditorRepository extends AppRepository {
  final reads = <int, Completer<List<ExerciseMusclePercent>>>{};
  Completer<void>? saveGate;
  Completer<List<Equipment>>? equipmentGate;
  bool saveFails = false;
  bool missingDefinition = false;
  int saves = 0;
  int refreshes = 0;

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => [
    _definition(1),
  ];
  @override
  Future<List<Equipment>> fetchAllEquipment() async => equipmentGate == null
      ? [Equipment(1, 'Barbell')]
      : await equipmentGate!.future;
  @override
  Future<List<ExerciseMusclePercent>> computeMusclePercents(int id) async =>
      reads[id] == null ? [] : await reads[id]!.future;
  @override
  Future<bool> getUseManualMuscles(int id) async => false;
  @override
  Future<Map<BodyPart, double>> computeMuscleCalculatedBodyparts(
    int id,
  ) async => {};
  @override
  Future<List<ExerciseBodyPartPercent>> fetchBodyPartPercentsManual(
    int id,
  ) async => [];
  @override
  Future<bool> getUseManualBodyparts(int id) async => false;
  @override
  Future<List<ExerciseMediaItem>> fetchExerciseMedia(int id) async => [];
  @override
  Future<bool> getMultiplyByRating(int id) async => false;
  @override
  Future<void> saveExerciseDefinitionAtomic(
    ExerciseDefinitionWrite write,
  ) async {
    saves++;
    if (saveFails) throw StateError('injected save failure');
    await saveGate?.future;
  }

  @override
  Future<ExerciseDefinition?> fetchDefinitionById(int id) async {
    refreshes++;
    return missingDefinition ? null : _definition(id);
  }
}

void main() {
  late _EditorRepository repository;
  late ExerciseEditorController controller;
  setUp(() {
    repository = _EditorRepository();
    controller = ExerciseEditorController(repository);
  });
  tearDown(() => controller.dispose());

  test('catalog exposes immutable equipment and completes loading', () async {
    expect(controller.loadingCatalog, isTrue);
    expect(await controller.loadCatalog(), isTrue);
    expect(controller.loadingCatalog, isFalse);
    expect(controller.equipment.single.name, 'Barbell');
    expect(() => controller.equipment.clear(), throwsUnsupportedError);
  });

  test('a late catalog response cannot clear a newer selection', () async {
    final gate = repository.equipmentGate = Completer();
    final catalog = controller.loadCatalog();
    await controller.loadDefinition(_definition(2));
    gate.complete([Equipment(1, 'Barbell')]);
    expect(await catalog, isFalse);
    expect(controller.definition!.id, 2);
    expect(controller.loadingCatalog, isFalse);
    expect(controller.equipment.single.name, 'Barbell');
  });

  test('catalog refresh cancels the old detail spinner and response', () async {
    final gate = repository.reads[1] = Completer();
    final details = controller.loadDefinition(_definition(1));
    expect(controller.loadingDetails, isTrue);
    expect(await controller.loadCatalog(), isTrue);
    expect(controller.loadingDetails, isFalse);
    gate.complete([]);
    expect(await details, isNull);
    expect(controller.definition, isNull);
  });

  test('latest selection wins when an earlier request finishes last', () async {
    final gate = repository.reads[1] = Completer();
    final first = controller.loadDefinition(_definition(1));
    final second = await controller.loadDefinition(_definition(2));
    expect(second!.definition.id, 2);
    gate.complete([]);
    expect(await first, isNull);
    expect(controller.definition!.id, 2);
    expect(controller.loadingDetails, isFalse);
  });

  test(
    'a stale failed read cannot report failure for the new selection',
    () async {
      final gate = repository.reads[1] = Completer();
      final first = controller.loadDefinition(_definition(1));
      await controller.loadDefinition(_definition(2));
      gate.completeError(StateError('old request failed'));
      expect(await first, isNull);
      expect(controller.definition!.id, 2);
    },
  );

  test(
    'failed selection keeps the previous definition and releases loading',
    () async {
      await controller.loadDefinition(_definition(1));
      final gate = repository.reads[2] = Completer();
      final failed = controller.loadDefinition(_definition(2));
      final check = expectLater(failed, throwsStateError);
      gate.completeError(StateError('read failed'));
      await check;
      expect(controller.definition!.id, 1);
      expect(controller.loadingDetails, isFalse);
    },
  );

  test('failed replacement of an in-flight selection cannot expose unloaded fields', () async {
    final firstGate = repository.reads[1] = Completer();
    final first = controller.loadDefinition(_definition(1));
    final secondGate = repository.reads[2] = Completer();
    final second = controller.loadDefinition(_definition(2));
    final check = expectLater(second, throwsStateError);
    secondGate.completeError(StateError('new selection failed'));
    await check;
    firstGate.complete([]);
    expect(await first, isNull);
    expect(controller.definition, isNull);
  });

  test(
    'save excludes duplicate writes and returns refreshed details',
    () async {
      await controller.loadDefinition(_definition(1));
      final gate = repository.saveGate = Completer();
      final first = controller.save(_write(_definition(1)));
      expect(controller.saving, isTrue);
      expect(await controller.save(_write(_definition(1))), isNull);
      expect(repository.saves, 1);
      gate.complete();
      expect((await first)!.definition.id, 1);
      expect(repository.refreshes, 1);
      expect(controller.saving, isFalse);
    },
  );

  test(
    'failed write retains selection and does not reload away the draft',
    () async {
      await controller.loadDefinition(_definition(1));
      repository.saveFails = true;
      await expectLater(
        controller.save(_write(_definition(1))),
        throwsStateError,
      );
      expect(controller.definition!.id, 1);
      expect(controller.saving, isFalse);
      expect(repository.refreshes, 0);
    },
  );

  test(
    'late save completion cannot switch back from a newer selection',
    () async {
      await controller.loadDefinition(_definition(1));
      final gate = repository.saveGate = Completer();
      final saving = controller.save(_write(_definition(1)));
      await controller.loadDefinition(_definition(2));
      gate.complete();
      expect(await saving, isNull);
      expect(controller.definition!.id, 2);
      expect(repository.refreshes, 0);
    },
  );

  test(
    'missing saved definition is an error and does not clear the selection',
    () async {
      await controller.loadDefinition(_definition(1));
      repository.missingDefinition = true;
      await expectLater(controller.reloadSelection(), throwsStateError);
      expect(controller.definition!.id, 1);
      expect(controller.loadingDetails, isFalse);
    },
  );

  test(
    'disposed controller ignores late results without notifications',
    () async {
      final disposed = ExerciseEditorController(repository);
      var notifications = 0;
      disposed.addListener(() => notifications++);
      final gate = repository.reads[1] = Completer();
      final loading = disposed.loadDefinition(_definition(1));
      disposed.dispose();
      final before = notifications;
      gate.complete([]);
      expect(await loading, isNull);
      expect(notifications, before);
      expect(await disposed.save(_write(_definition(1))), isNull);
      expect(repository.saves, 0);
    },
  );
}
