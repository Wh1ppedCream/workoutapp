import 'package:env_test/db/flow_defaults_dao.dart';
import 'package:env_test/models/preset_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('''
      CREATE TABLE gym_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    await db.insert('gym_profiles', {'id': 2, 'name': 'Home Gym'});
    await db.execute('''
      CREATE TABLE flow_defaults (
        scope TEXT NOT NULL,
        profile_id INTEGER REFERENCES gym_profiles(id) ON DELETE CASCADE,
        flow_json TEXT NOT NULL,
        PRIMARY KEY(scope, profile_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE flow_default_methods (
        scope TEXT NOT NULL,
        profile_id INTEGER REFERENCES gym_profiles(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        params TEXT NOT NULL,
        PRIMARY KEY(scope, profile_id, name),
        FOREIGN KEY(scope, profile_id)
          REFERENCES flow_defaults(scope, profile_id) ON DELETE CASCADE
      )
    ''');
  });

  tearDown(() => db.close());

  test('isolates app-null and profile scopes and rolls back parent row on insert failure', () async {
    await db.execute('''
        CREATE TRIGGER fail_app_method_insert
        BEFORE INSERT ON flow_default_methods
        WHEN NEW.name = 'Broken rule'
        BEGIN
          SELECT RAISE(ABORT, 'simulated method insert failure');
        END
      ''');

    await expectLater(
      FlowDefaultsDao.upsertDefaultFlowMethod(
        db,
        'app',
        name: 'Broken rule',
        type: 'weight',
        params: const {'sign': '+', 'factor': 1.0},
      ),
      throwsA(isA<DatabaseException>()),
    );

    expect(await db.query('flow_defaults'), isEmpty);
    expect(await db.query('flow_default_methods'), isEmpty);

    final appId = await FlowDefaultsDao.upsertDefaultFlowMethod(
      db,
      'app',
      name: 'Shared name',
      type: 'weight',
      params: const {'sign': '+', 'factor': 1.0},
    );
    final profileId = await FlowDefaultsDao.upsertDefaultFlowMethod(
      db,
      'profile',
      profileId: 2,
      name: 'Shared name',
      type: 'rep',
      params: const {'sign': '+', 'amount': 2},
    );

    expect(appId, greaterThan(0));
    expect(profileId, greaterThan(0));
    expect(appId, isNot(profileId));
    expect(
      (await FlowDefaultsDao.fetchDefaultFlowMethods(db, 'app')).single['type'],
      'weight',
    );
    expect(
      (await FlowDefaultsDao.fetchDefaultFlowMethods(
        db,
        'profile',
        profileId: 2,
      )).single['type'],
      'rep',
    );
  });

  test('renames default rule and graph edges atomically and rolls back on late failure', () async {
    await FlowDefaultsDao.upsertDefaultFlowMethod(
      db,
      'profile',
      profileId: 2,
      name: 'Add 5 lb',
      type: 'weight',
      params: const {'sign': '+', 'factor': 1.0},
    );
    final initialGraph = FlowDefinition(
      nodes: const ['start', 'next'],
      edges: [
        FlowEdge(from: 'start', outcome: 'method', to: 'Add 5 lb'),
        FlowEdge(from: 'start', outcome: 'failure', to: 'Add 5 lb'),
      ],
    );
    await FlowDefaultsDao.upsertDefaultFlow(
      db,
      'profile',
      profileId: 2,
      flowJson: initialGraph.toJson(),
    );

    await db.execute('''
        CREATE TRIGGER block_old_method_delete
        BEFORE DELETE ON flow_default_methods
        BEGIN
          SELECT RAISE(ABORT, 'simulated delete failure');
        END
      ''');

    await expectLater(
      FlowDefaultsDao.saveDefaultFlowMethodAtomic(
        db,
        'profile',
        profileId: 2,
        name: 'Add 10 lb',
        type: 'weight',
        params: const {'sign': '+', 'factor': 2.0},
        previousName: 'Add 5 lb',
      ),
      throwsA(isA<DatabaseException>()),
    );

    final methodsAfterAbort = await FlowDefaultsDao.fetchDefaultFlowMethods(
      db,
      'profile',
      profileId: 2,
    );
    expect(methodsAfterAbort.map((r) => r['name']), ['Add 5 lb']);
    final graphAfterAbort = FlowDefinition.fromJson(
      await FlowDefaultsDao.fetchDefaultFlow(db, 'profile', profileId: 2),
    );
    expect(graphAfterAbort.edges.first.to, 'Add 5 lb');

    await db.execute('DROP TRIGGER block_old_method_delete');

    await FlowDefaultsDao.saveDefaultFlowMethodAtomic(
      db,
      'profile',
      profileId: 2,
      name: 'Add 10 lb',
      type: 'weight',
      params: const {'sign': '+', 'factor': 2.0},
      previousName: 'Add 5 lb',
    );

    final methodsAfterCommit = await FlowDefaultsDao.fetchDefaultFlowMethods(
      db,
      'profile',
      profileId: 2,
    );
    expect(methodsAfterCommit.map((r) => r['name']), ['Add 10 lb']);
    final graphAfterCommit = FlowDefinition.fromJson(
      await FlowDefaultsDao.fetchDefaultFlow(db, 'profile', profileId: 2),
    );
    expect(graphAfterCommit.edges[0].to, 'Add 10 lb');
    expect(graphAfterCommit.edges[1].to, 'Add 5 lb');
  });

  test('deletes default rule and graph references atomically and rolls back on failure', () async {
    await FlowDefaultsDao.upsertDefaultFlowMethod(
      db,
      'app',
      name: 'Deload',
      type: 'weight',
      params: const {'sign': '-', 'factor': 1.0},
    );
    final initialGraph = FlowDefinition(
      nodes: const ['start', 'retry'],
      edges: [
        FlowEdge(from: 'start', outcome: 'method', to: 'Deload'),
        FlowEdge(from: 'start', outcome: 'success', to: 'retry'),
      ],
    );
    await FlowDefaultsDao.upsertDefaultFlow(
      db,
      'app',
      flowJson: initialGraph.toJson(),
    );

    await db.execute('''
        CREATE TRIGGER block_app_method_delete
        BEFORE DELETE ON flow_default_methods
        BEGIN
          SELECT RAISE(ABORT, 'simulated delete failure');
        END
      ''');

    await expectLater(
      FlowDefaultsDao.deleteDefaultFlowMethodAndReferences(
        db,
        'app',
        name: 'Deload',
      ),
      throwsA(isA<DatabaseException>()),
    );

    final preservedGraph = FlowDefinition.fromJson(
      await FlowDefaultsDao.fetchDefaultFlow(db, 'app'),
    );
    expect(preservedGraph.edges, hasLength(2));
    expect(
      await FlowDefaultsDao.fetchDefaultFlowMethods(db, 'app'),
      hasLength(1),
    );

    await db.execute('DROP TRIGGER block_app_method_delete');
    await FlowDefaultsDao.deleteDefaultFlowMethodAndReferences(
      db,
      'app',
      name: 'Deload',
    );

    final cleanedGraph = FlowDefinition.fromJson(
      await FlowDefaultsDao.fetchDefaultFlow(db, 'app'),
    );
    expect(cleanedGraph.edges, hasLength(1));
    expect(cleanedGraph.edges.single.outcome, 'success');
    expect(await FlowDefaultsDao.fetchDefaultFlowMethods(db, 'app'), isEmpty);
  });
}
