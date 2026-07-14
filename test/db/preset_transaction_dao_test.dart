import 'package:env_test/db/preset_transaction_dao.dart';
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
      CREATE TABLE preset_definitions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        profile_id INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE preset_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_id INTEGER NOT NULL,
        exercise_def_id INTEGER,
        type TEXT NOT NULL,
        order_index INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE preset_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_exercise_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL CHECK(reps >= 0),
        order_index INTEGER NOT NULL,
        parent_set_id INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE preset_cardio_details (
        preset_exercise_id INTEGER PRIMARY KEY,
        cardio_name TEXT,
        note TEXT,
        planned_minutes INTEGER,
        elapsed_seconds INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE preset_stretch_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_exercise_id INTEGER NOT NULL,
        stretch_id INTEGER,
        is_custom INTEGER NOT NULL,
        custom_name TEXT,
        custom_desc TEXT,
        order_index INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE preset_auto_settings (
        preset_id INTEGER PRIMARY KEY,
        is_automatic INTEGER NOT NULL,
        global_increment REAL NOT NULL,
        skip_first_set INTEGER NOT NULL,
        weight_check INTEGER NOT NULL,
        rep_check INTEGER NOT NULL,
        volume_check INTEGER NOT NULL,
        adjust_all_sets INTEGER NOT NULL,
        use_manual_select INTEGER NOT NULL,
        manual_selection_json TEXT,
        success_count_mode TEXT NOT NULL,
        flow_definition TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE preset_exercise_auto (
        preset_exercise_id INTEGER PRIMARY KEY,
        increment_amount REAL,
        last_set_index INTEGER,
        last_node TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE preset_set_auto (
        preset_set_id INTEGER PRIMARY KEY,
        increment_amount REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE preset_flow_methods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        params TEXT NOT NULL,
        UNIQUE(preset_id, name)
      )
    ''');
    await db.execute('''
      CREATE TABLE flow_defaults (
        scope TEXT NOT NULL,
        profile_id INTEGER,
        flow_json TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE flow_default_methods (
        scope TEXT NOT NULL,
        profile_id INTEGER,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        params TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE active_plans (
        profile_id INTEGER NOT NULL,
        preset_id INTEGER NOT NULL,
        activated_at TEXT NOT NULL,
        PRIMARY KEY(profile_id, preset_id)
      )
    ''');
  });

  tearDown(() => db.close());

  test('creates the plan graph and active membership together', () async {
    final presetId = await PresetTransactionDao.createPreset(
      db,
      name: 'Upper',
      profileId: 2,
      activate: true,
      exercises: [
        WorkoutExerciseWrite(
          exercise: WeightExercise(
            name: 'Bench Press',
            equipment: 'Barbell',
            sets: [ExerciseSet(weight: 135, reps: 5)],
          ),
          type: 'weight',
          definitionId: 7,
        ),
      ],
    );

    expect(presetId, 1);
    expect(await db.query('preset_definitions'), hasLength(1));
    expect(await db.query('preset_exercises'), hasLength(1));
    expect(await db.query('preset_sets'), hasLength(1));
    expect((await db.query('active_plans')).single['preset_id'], presetId);
  });

  test('failed child write does not leave an orphaned plan', () async {
    await expectLater(
      PresetTransactionDao.createPreset(
        db,
        name: 'Invalid',
        profileId: 2,
        activate: true,
        exercises: [
          WorkoutExerciseWrite(
            exercise: WeightExercise(
              name: 'Bench Press',
              equipment: 'Barbell',
              sets: [ExerciseSet(weight: 135, reps: -1)],
            ),
            type: 'weight',
            definitionId: 7,
          ),
        ],
      ),
      throwsA(anything),
    );

    expect(await db.query('preset_definitions'), isEmpty);
    expect(await db.query('preset_exercises'), isEmpty);
    expect(await db.query('active_plans'), isEmpty);
  });

  test(
    'copies profile flow and rules into a profile plan as a snapshot',
    () async {
      const appFlow = '{"nodes":["app"],"edges":[]}';
      const profileFlow = '{"nodes":["profile"],"edges":[]}';
      await db.insert('flow_defaults', {
        'scope': 'app',
        'profile_id': null,
        'flow_json': appFlow,
      });
      await db.insert('flow_default_methods', {
        'scope': 'app',
        'profile_id': null,
        'name': 'App rule',
        'type': 'weight',
        'params': '{"sign":"+","factor":1.0}',
      });
      await db.insert('flow_defaults', {
        'scope': 'profile',
        'profile_id': 2,
        'flow_json': profileFlow,
      });
      await db.insert('flow_default_methods', {
        'scope': 'profile',
        'profile_id': 2,
        'name': 'Profile rule',
        'type': 'rep',
        'params': '{"sign":"+","amount":1}',
      });

      final presetId = await PresetTransactionDao.createPreset(
        db,
        name: 'Profile Plan',
        profileId: 2,
        exercises: const <WorkoutExerciseWrite>[],
      );

      final settings =
          (await db.query(
            'preset_auto_settings',
            where: 'preset_id = ?',
            whereArgs: [presetId],
          )).single;
      expect(settings['flow_definition'], profileFlow);
      expect(
        (await db.query(
          'preset_flow_methods',
          where: 'preset_id = ?',
          whereArgs: [presetId],
        )).single['name'],
        'Profile rule',
      );

      await db.update(
        'flow_defaults',
        {'flow_json': '{"nodes":["changed"],"edges":[]}'},
        where: 'scope = ? AND profile_id = ?',
        whereArgs: const ['profile', 2],
      );
      expect(
        (await db.query(
          'preset_auto_settings',
          where: 'preset_id = ?',
          whereArgs: [presetId],
        )).single['flow_definition'],
        profileFlow,
      );
    },
  );

  test('copies app flow and rules into a plan without a gym profile', () async {
    const appFlow = '{"nodes":["app"],"edges":[]}';
    await db.insert('flow_defaults', {
      'scope': 'app',
      'profile_id': null,
      'flow_json': appFlow,
    });
    await db.insert('flow_default_methods', {
      'scope': 'app',
      'profile_id': null,
      'name': 'App rule',
      'type': 'weight',
      'params': '{"sign":"+","factor":1.0}',
    });

    final presetId = await PresetTransactionDao.createPreset(
      db,
      name: 'No Profile Plan',
      profileId: null,
      exercises: const <WorkoutExerciseWrite>[],
    );

    expect(
      (await db.query(
        'preset_auto_settings',
        where: 'preset_id = ?',
        whereArgs: [presetId],
      )).single['flow_definition'],
      appFlow,
    );
    expect(
      (await db.query(
        'preset_flow_methods',
        where: 'preset_id = ?',
        whereArgs: [presetId],
      )).single['name'],
      'App rule',
    );
  });

  test('automatic settings and overrides commit together', () async {
    final presetId = await PresetTransactionDao.createPreset(
      db,
      name: 'Automatic Upper',
      profileId: 2,
      exercises: [
        WorkoutExerciseWrite(
          exercise: WeightExercise(
            name: 'Bench Press',
            equipment: 'Barbell',
            sets: [ExerciseSet(weight: 135, reps: 5)],
          ),
          type: 'weight',
          definitionId: 7,
        ),
      ],
    );
    final exerciseId = (await db.query('preset_exercises')).single['id'] as int;
    final setId = (await db.query('preset_sets')).single['id'] as int;

    await PresetTransactionDao.saveAutoConfiguration(
      db,
      presetId: presetId,
      configuration: PresetAutoConfigurationWrite(
        settings: PresetAutoSettingsWrite(
          isAutomatic: true,
          globalIncrement: 10,
          skipFirstSet: false,
          weightCheck: true,
          repCheck: true,
          volumeCheck: false,
          adjustAllSets: true,
          useManualSelect: true,
          manualSelections: {setId: true},
        ),
        exerciseIncrements: {exerciseId: 7.5},
        exerciseLastSetIndices: {exerciseId: 1},
        setIncrements: {setId: 2.5},
      ),
    );

    final settings = (await db.query('preset_auto_settings')).single;
    expect(settings['global_increment'], 10.0);
    expect(settings['manual_selection_json'], '{"$setId":true}');
    expect(
      (await db.query('preset_exercise_auto')).single['increment_amount'],
      7.5,
    );
    expect((await db.query('preset_set_auto')).single['increment_amount'], 2.5);
  });

  test('invalid automatic override rolls back global settings', () async {
    final presetId = await PresetTransactionDao.createPreset(
      db,
      name: 'Atomic Settings',
      profileId: 2,
      exercises: [
        WorkoutExerciseWrite(
          exercise: WeightExercise(
            name: 'Bench Press',
            equipment: 'Barbell',
            sets: [ExerciseSet(weight: 135, reps: 5)],
          ),
          type: 'weight',
          definitionId: 7,
        ),
      ],
      autoSettings: const PresetAutoSettingsWrite(
        isAutomatic: true,
        globalIncrement: 5,
        skipFirstSet: true,
        weightCheck: true,
        repCheck: true,
        volumeCheck: false,
        adjustAllSets: false,
        useManualSelect: false,
      ),
    );
    final exerciseId = (await db.query('preset_exercises')).single['id'] as int;

    await expectLater(
      PresetTransactionDao.saveAutoConfiguration(
        db,
        presetId: presetId,
        configuration: PresetAutoConfigurationWrite(
          settings: const PresetAutoSettingsWrite(
            isAutomatic: true,
            globalIncrement: 20,
            skipFirstSet: false,
            weightCheck: true,
            repCheck: true,
            volumeCheck: true,
            adjustAllSets: true,
            useManualSelect: true,
          ),
          exerciseIncrements: {exerciseId: 10},
          exerciseLastSetIndices: {exerciseId: 1},
          setIncrements: const {999999: 10},
        ),
      ),
      throwsStateError,
    );

    final settings = (await db.query('preset_auto_settings')).single;
    expect(settings['global_increment'], 5.0);
    expect(await db.query('preset_exercise_auto'), isEmpty);
    expect(await db.query('preset_set_auto'), isEmpty);
  });
}
