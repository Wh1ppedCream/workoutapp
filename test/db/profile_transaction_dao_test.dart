import 'package:env_test/db/profile_transaction_dao.dart';
import 'package:env_test/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE gym_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
      )
    ''');
    await db.execute('''
      CREATE TABLE profile_equipment (
        profile_id INTEGER NOT NULL,
        equipment_id INTEGER NOT NULL CHECK(equipment_id > 0),
        PRIMARY KEY(profile_id, equipment_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE flow_defaults (
        scope TEXT NOT NULL,
        profile_id INTEGER,
        flow_json TEXT NOT NULL,
        PRIMARY KEY(scope, profile_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE flow_default_methods (
        scope TEXT NOT NULL,
        profile_id INTEGER,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        params TEXT NOT NULL,
        PRIMARY KEY(scope, profile_id, name)
      )
    ''');
  });

  tearDown(() => db.close());

  test('copies app progression defaults into a new gym profile once', () async {
    await _insertAppDefaults(db);

    final profileId = await ProfileTransactionDao.saveGymProfile(
      db,
      existingProfile: null,
      name: 'Home Gym',
      equipmentIds: {1, 2},
    );

    expect((await db.query('gym_profiles')).single['name'], 'Home Gym');
    expect(await db.query('profile_equipment'), hasLength(2));
    expect((await _profileFlow(db, profileId))['flow_json'], _appFlowJson);
    expect(
      (await _profileMethods(db, profileId)).map((row) => row['name']),
      orderedEquals(['Add a set', 'Increase weight']),
    );

    await db.update(
      'flow_defaults',
      {'flow_json': '{"nodes":["changed"],"edges":[]}'},
      where: 'scope = ? AND profile_id IS NULL',
      whereArgs: const ['app'],
    );
    await db.update(
      'flow_default_methods',
      {'params': '{"sign":"+","factor":99.0}'},
      where: 'scope = ? AND profile_id IS NULL AND name = ?',
      whereArgs: const ['app', 'Increase weight'],
    );

    expect((await _profileFlow(db, profileId))['flow_json'], _appFlowJson);
    expect(
      (await _profileMethods(
        db,
        profileId,
      )).firstWhere((row) => row['name'] == 'Increase weight')['params'],
      '{"sign":"+","factor":1.0}',
    );
  });

  test('editing an existing profile does not recopy app defaults', () async {
    await _insertAppDefaults(db);
    final profileId = await ProfileTransactionDao.saveGymProfile(
      db,
      existingProfile: null,
      name: 'Commercial Gym',
      equipmentIds: const {1},
    );
    await db.update(
      'flow_defaults',
      {'flow_json': '{"nodes":["profile"],"edges":[]}'},
      where: 'scope = ? AND profile_id = ?',
      whereArgs: ['profile', profileId],
    );
    await db.delete(
      'flow_default_methods',
      where: 'scope = ? AND profile_id = ?',
      whereArgs: ['profile', profileId],
    );

    await ProfileTransactionDao.saveGymProfile(
      db,
      existingProfile: GymProfile(
        id: profileId,
        name: 'Commercial Gym',
        createdAt: DateTime.utc(2026),
      ),
      name: 'Commercial Gym Updated',
      equipmentIds: const {2},
    );

    expect(
      (await _profileFlow(db, profileId))['flow_json'],
      '{"nodes":["profile"],"edges":[]}',
    );
    expect(await _profileMethods(db, profileId), isEmpty);
    expect(
      (await db.query('gym_profiles')).single['name'],
      'Commercial Gym Updated',
    );
    expect((await db.query('profile_equipment')).single['equipment_id'], 2);
  });

  test(
    'a failed new profile write rolls back copied progression defaults',
    () async {
      await _insertAppDefaults(db);

      await expectLater(
        ProfileTransactionDao.saveGymProfile(
          db,
          existingProfile: null,
          name: 'Invalid Gym',
          equipmentIds: {1, -1},
        ),
        throwsA(anything),
      );

      expect(await db.query('gym_profiles'), isEmpty);
      expect(
        await db.query(
          'flow_defaults',
          where: 'scope = ?',
          whereArgs: const ['profile'],
        ),
        isEmpty,
      );
      expect(
        await db.query(
          'flow_default_methods',
          where: 'scope = ?',
          whereArgs: const ['profile'],
        ),
        isEmpty,
      );
    },
  );
}

const _appFlowJson = '{"nodes":["1st attempt","success1","fail1"],"edges":[]}';

Future<void> _insertAppDefaults(Database db) async {
  await db.insert('flow_defaults', {
    'scope': 'app',
    'profile_id': null,
    'flow_json': _appFlowJson,
  });
  await db.insert('flow_default_methods', {
    'scope': 'app',
    'profile_id': null,
    'name': 'Increase weight',
    'type': 'weight',
    'params': '{"sign":"+","factor":1.0}',
  });
  await db.insert('flow_default_methods', {
    'scope': 'app',
    'profile_id': null,
    'name': 'Add a set',
    'type': 'addSet',
    'params': '{"weight":100.0,"reps":8}',
  });
}

Future<Map<String, Object?>> _profileFlow(Database db, int profileId) async {
  final rows = await db.query(
    'flow_defaults',
    where: 'scope = ? AND profile_id = ?',
    whereArgs: ['profile', profileId],
  );
  return rows.single;
}

Future<List<Map<String, Object?>>> _profileMethods(Database db, int profileId) {
  return db.query(
    'flow_default_methods',
    where: 'scope = ? AND profile_id = ?',
    whereArgs: ['profile', profileId],
    orderBy: 'name',
  );
}
