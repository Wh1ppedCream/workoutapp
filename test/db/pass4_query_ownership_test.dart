import 'package:env_test/db/database_helper.dart';
import 'package:env_test/db/schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Database db;
  late DatabaseHelper helper;
  late int definitionId;
  late int sessionId;
  late int exerciseId;
  late int setId;
  final at = DateTime.utc(2026, 10, 30, 12);

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await Schema.createTables(db);
    helper = DatabaseHelper.forTesting(db);
    definitionId = await db.insert('exercise_definitions', {
      'name': 'P4 press',
    });
    sessionId = await helper.createSession(at, 60);
    exerciseId = await helper.addExerciseRow(
      sessionId: sessionId,
      exerciseDefId: definitionId,
      type: 'weight',
      orderIndex: 0,
    );
    setId = await helper.addSet(exerciseId, 100, 5, 0);
  });
  tearDown(() => db.close());

  test('moved report/history queries preserve bounds, aliases and parent filtering', () async {
    await db.insert('sets', {
      'exercise_id': exerciseId,
      'weight': 200,
      'reps': 1,
      'order_index': 0,
      'parent_set_id': setId,
    });
    final report = (await helper.fetchWorkoutReportSessionsRaw(
      start: at,
      end: at,
    )).single;
    expect(report['session_id'], sessionId);
    expect(report['duration'], 60);
    expect(report['exercise_count'], 1);
    expect(report['set_count'], 2);
    expect(report['total_volume'], 700);
    expect(
      await helper.fetchWorkoutReportSessionsRaw(
        start: at.add(const Duration(milliseconds: 1)),
      ),
      isEmpty,
    );
    final trend = (await helper.fetchExerciseOneRmTrendRows(
      definitionId: definitionId,
    )).single;
    expect(trend['actual_one_rm'], isNull);
    expect(trend['estimated_one_rm'], closeTo(116.65, .001));
    expect(
      await helper.fetchExerciseOneRmTrendRows(
        definitionId: definitionId,
        limit: 0,
      ),
      isEmpty,
    );
    final mostUsed =
        (await helper.fetchMostUsedExerciseDefinitionsRaw()).single;
    expect(mostUsed['definition_id'], definitionId);
    expect(mostUsed['use_count'], 1);
  });

  test(
    'moved preset queries retain draft/profile filtering and child-set counts',
    () async {
      final profileId = await db.insert('gym_profiles', {'name': 'P4 profile'});
      final presetId = await helper.createPreset(
        'Visible',
        profileId: profileId,
      );
      await helper.createPreset('Draft', profileId: profileId, isDraft: true);
      final presetExercise = await helper.addExerciseToPreset(
        presetId,
        definitionId,
        'weight',
        0,
      );
      final parent = await helper.addPresetSet(
        presetExerciseId: presetExercise,
        weight: 20,
        reps: 8,
        orderIndex: 0,
      );
      await helper.addPresetSet(
        presetExerciseId: presetExercise,
        weight: 15,
        reps: 8,
        orderIndex: 0,
        parentSetId: parent,
      );
      final summaries = await helper.fetchPresetSummariesRaw(
        profileId: profileId,
      );
      expect(summaries.map((row) => row['name']), ['Visible']);
      expect(summaries.single['is_automatic'], 0);
      final focus = await helper.fetchPresetFocusSetCountsRaw(
        presetIds: [presetId, presetId],
      );
      expect(focus.single['preset_id'], presetId);
      expect(focus.single['def_id'], definitionId);
      expect(focus.single['set_count'], 2);
      expect(await helper.fetchPresetFocusSetCountsRaw(presetIds: []), isEmpty);
    },
  );

  for (final action in ['update session', 'update set', 'delete set']) {
    test('$action rolls back if record-event rebuilding fails', () async {
      await helper.addSet(exerciseId, 80, 8, 1);
      final beforeSessions = await db.query('sessions');
      final beforeSets = await db.query('sets');
      await db.execute('''
        CREATE TRIGGER p4_rebuild_failure BEFORE INSERT ON workout_exercise_record_events
        BEGIN SELECT RAISE(ABORT, 'injected record failure'); END
      ''');
      final operation = switch (action) {
        'update session' => helper.updateSession(
          sessionId,
          at.add(const Duration(days: 1)),
          120,
        ),
        'update set' => helper.updateSet(setId, 250, 3),
        _ => helper.deleteSet(setId),
      };
      await expectLater(operation, throwsA(isA<DatabaseException>()));
      expect(await db.query('sessions'), beforeSessions);
      expect(await db.query('sets'), beforeSets);
      expect(await db.query('workout_exercise_record_events'), isEmpty);
    });
  }
}
