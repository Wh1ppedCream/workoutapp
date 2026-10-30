import 'package:env_test/db/database_helper.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('catalog convenience methods honor public subclass overrides', () async {
    final fake = _OverriddenRepository();
    final AppRepository repository = fake;
    await repository.fetchPrimaryEquipmentMedia(7);
    await repository.fetchPrimaryBodyPartMedia(8);
    await repository.fetchPrimaryMuscleMedia(9);
    expect(fake.mediaCalls, [
      (SharedMediaEntityType.equipment, 7),
      (SharedMediaEntityType.bodypart, 8),
      (SharedMediaEntityType.muscle, 9),
    ]);
  });

  test('warmup retains virtual dispatch across repository domains', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    final repository = _OverriddenRepository(db: DatabaseHelper.forTesting(db));
    expect(await repository.warmUp(verify: true), isTrue);
    expect(repository.warmupCalls, ['exercise', 'shared', 'reconcile']);
  });
}

class _OverriddenRepository extends AppRepository {
  _OverriddenRepository({super.db});

  final mediaCalls = <(SharedMediaEntityType, int)>[];
  final warmupCalls = <String>[];

  @override
  Future<SharedMediaItem?> fetchPrimarySharedMedia(
    SharedMediaEntityType entityType,
    int entityId,
  ) async {
    mediaCalls.add((entityType, entityId));
    return null;
  }

  @override
  Future<void> ensureExerciseMediaManifestReady() async {
    warmupCalls.add('exercise');
  }

  @override
  Future<void> ensureSharedMediaManifestReady() async {
    warmupCalls.add('shared');
  }

  @override
  Future<void> reconcileMediaCache() async {
    warmupCalls.add('reconcile');
  }
}
