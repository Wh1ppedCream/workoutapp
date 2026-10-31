import 'package:env_test/db/database_helper.dart';
import 'package:env_test/db/preset_read_dao.dart';
import 'package:env_test/db/schema.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/preset_session.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/sqlite_preset_read_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Database db;
  late DatabaseHelper helper;
  late int presetId;
  late int definitionId;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await Schema.createTables(db);
    helper = DatabaseHelper.forTesting(db);
    definitionId = await db.insert('exercise_definitions', {
      'name': 'P4 squat',
    });
    presetId = await helper.createPreset('P4 preset');
  });
  tearDown(() => db.close());

  Future<int> weightExercise(int index) async {
    final id = await helper.addExerciseToPreset(
      presetId,
      definitionId,
      'weight',
      index,
    );
    await helper.addPresetSet(
      presetExerciseId: id,
      weight: 100,
      reps: 5,
      orderIndex: 0,
    );
    return id;
  }

  test(
    'weight-only query count stays bounded and crosses the bind chunk safely',
    () async {
      for (final count in [1, 40, 801]) {
        await db.delete('preset_exercises');
        final batch = db.batch();
        for (var i = 0; i < count; i++) {
          batch.insert('preset_exercises', {
            'id': i + 10000,
            'preset_id': presetId,
            'exercise_def_id': definitionId,
            'type': 'weight',
            'order_index': i,
          });
          batch.insert('preset_sets', {
            'id': i + 20000,
            'preset_exercise_id': i + 10000,
            'weight': 20,
            'reps': 8,
            'order_index': 0,
          });
        }
        await batch.commit(noResult: true);
        final counted = _CountingExecutor(db);
        final snapshot = await PresetReadDao.load(counted, presetId);
        expect(snapshot.exercises, hasLength(count));
        expect(snapshot.sets, hasLength(count));
        expect(counted.queries, count > 800 ? 10 : 7);
        expect(counted.largestBindCount, lessThanOrEqualTo(800));
        expect(snapshot.exercises.first.id, 10000);
        expect(snapshot.exercises.last.id, 9999 + count);
      }
    },
  );

  test('missing and empty presets need only the three root reads', () async {
    for (final id in [presetId, -1]) {
      final counted = _CountingExecutor(db);
      final snapshot = await PresetReadDao.load(counted, id);
      expect(counted.queries, 3);
      expect(snapshot.preset == null, id == -1);
      expect(snapshot.exercises, isEmpty);
      expect(snapshot.sets, isEmpty);
    }
  });

  test(
    'batched and compatibility paths publish equivalent mixed preset state',
    () async {
      final weightId = await weightExercise(0);
      final parentId =
          (await helper.fetchPresetSets(weightId)).single['id'] as int;
      await helper.addPresetSet(
        presetExerciseId: weightId,
        weight: 80,
        reps: 8,
        orderIndex: 1,
        parentSetId: parentId,
      );
      await helper.addPresetSet(
        presetExerciseId: weightId,
        weight: 1,
        reps: 1,
        orderIndex: 2,
        parentSetId: 999999,
      );
      await helper.addExerciseToPreset(
        presetId,
        null,
        'cardio',
        1,
      ); // Missing details are skipped.
      final cardioId = await helper.addExerciseToPreset(
        presetId,
        null,
        'cardio',
        2,
      );
      await helper.savePresetCardio(cardioId, 'Row', 'Steady', 15, 9);
      final stretchId = await helper.addExerciseToPreset(
        presetId,
        null,
        'stretch',
        3,
      );
      final stretchDefinition = await db.insert('stretch_definitions', {
        'name': 'P4 stretch',
        'description': 'Guide',
      });
      await helper.savePresetStretch(stretchId, [
        {'stretch_id': stretchDefinition, 'is_custom': 0, 'order_index': 0},
      ]);
      await helper.addExerciseToPreset(presetId, null, 'unknown', 4);
      await helper.upsertPresetAutoSettings(
        presetId: presetId,
        isAutomatic: true,
        globalIncrement: 2.5,
        skipFirstSet: true,
        weightCheck: true,
        repCheck: false,
        volumeCheck: false,
        adjustAllSets: false,
        useManualSelect: true,
        manualSelectionJson: '{"$parentId":true,"bad":true}',
        successCountMode: 'exercise',
      );
      await helper.upsertPresetExerciseAuto(
        presetExerciseId: weightId,
        incrementAmount: 0,
        lastSetIndex: 2,
        lastNode: 'kept',
      );
      await helper.upsertPresetSetAuto(
        presetSetId: parentId,
        incrementAmount: 0,
      );
      final regular = PresetSession(
        presetId,
        repository: AppRepository(db: helper),
      );
      final batched = PresetSession(
        presetId,
        repository: AppRepository(
          db: helper,
          presetReadSource: SqlitePresetReadSource(helper),
        ),
      );
      addTearDown(regular.dispose);
      addTearDown(batched.dispose);
      await Future.wait([regular.ready, batched.ready]);
      expect(regular.loadFailure, isNull);
      expect(batched.loadFailure, isNull);
      expect(_state(batched), _state(regular));
      expect(batched.cardTypes, hasLength(3));
      expect((batched.exercises.last as StretchExercise).name, 'P4 stretch');
    },
  );

  test(
    'a read session is detached and a new load observes subsequent edits',
    () async {
      final exerciseId = await weightExercise(0);
      final source = SqlitePresetReadSource(helper);
      final first = source.open(presetId);
      await first.fetchPreset();
      final setId =
          (await helper.fetchPresetSets(exerciseId)).single['id'] as int;
      await helper.updatePresetSetWeight(setId, 125);
      expect((await first.fetchSets(exerciseId)).single.weight, 100);
      expect(
        (await source.open(presetId).fetchSets(exerciseId)).single.weight,
        125,
      );
      final snapshot = await PresetReadDao.load(db, presetId);
      expect(() => snapshot.sets[exerciseId]!.clear(), throwsUnsupportedError);
      expect(() => snapshot.exerciseAuto.clear(), throwsUnsupportedError);
    },
  );

  test('a failed read can retry through a fresh load session without stale cache', () async {
    final exerciseId = await weightExercise(0);
    final definition = (await db.query(
      'exercise_definitions',
      where: 'id = ?',
      whereArgs: [definitionId],
    )).single;
    // The production schema permits no missing name; simulate a missing lookup
    // with FKs off, leaving the exercise identity intact for the failure path.
    await db.execute('PRAGMA foreign_keys = OFF');
    await db.delete(
      'exercise_definitions',
      where: 'id = ?',
      whereArgs: [definitionId],
    );
    final session = PresetSession(
      presetId,
      repository: AppRepository(
        db: helper,
        presetReadSource: SqlitePresetReadSource(helper),
      ),
    );
    addTearDown(session.dispose);
    await session.ready;
    expect(session.hasLoaded, isFalse);
    expect(session.loadFailure, isNotNull);
    await db.insert('exercise_definitions', definition);
    await db.execute('PRAGMA foreign_keys = ON');
    await session.retryLoad();
    expect(session.hasLoaded, isTrue);
    expect(session.presetExerciseIds, [exerciseId]);
  });

  test(
    'DAO joins its caller transaction without opening or committing another',
    () async {
      await expectLater(
        db.transaction((transaction) async {
          await transaction.update(
            'preset_definitions',
            {'name': 'Uncommitted'},
            where: 'id = ?',
            whereArgs: [presetId],
          );
          final snapshot = await PresetReadDao.load(transaction, presetId);
          expect(snapshot.preset!.name, 'Uncommitted');
          throw StateError('rollback');
        }),
        throwsStateError,
      );
      expect((await helper.fetchPresetById(presetId))!.name, 'P4 preset');
    },
  );
}

Map<String, Object?> _state(PresetSession session) => {
  'name': session.presetName,
  'profile': session.profileId,
  'draft': session.isDraft,
  'automatic': session.isAutomatic,
  'increment': session.globalIncrement,
  'scope': session.successScope,
  'manual': session.manualSelections,
  'exerciseOverrides': session.exerciseIncrementOverrides,
  'setOverrides': session.setIncrementOverrides,
  'rotation': session.lastSetIndexByExercise,
  'exerciseIds': session.presetExerciseIds.toList(),
  'parentIds': session.presetParentSetIds.toList(),
  'childIds': session.presetChildSetIds.toList(),
  'exercises': [
    for (final exercise in session.exercises)
      {
        'name': exercise.name,
        'equipment': exercise.equipment,
        if (exercise is WeightExercise) ...{
          'sets': [
            for (final set in exercise.sets)
              [set.weight, set.reps, set.sourcePresetSetId],
          ],
          'children': {
            for (final entry in exercise.changeSets.entries)
              entry.key: [
                for (final set in entry.value)
                  [set.weight, set.reps, set.sourcePresetSetId],
              ],
          },
        },
        if (exercise is CardioExercise)
          'cardio': [
            exercise.cardioName,
            exercise.cardioNote,
            exercise.plannedMinutes,
            exercise.elapsedSeconds,
          ],
        if (exercise is StretchExercise)
          'stretch': [
            for (final item in exercise.stretchInstances) item.toMap(),
          ],
      },
  ],
};

class _CountingExecutor implements DatabaseExecutor {
  _CountingExecutor(this.db);
  final DatabaseExecutor db;
  int queries = 0;
  int largestBindCount = 0;
  void _record(List<Object?>? arguments) {
    queries++;
    if ((arguments?.length ?? 0) > largestBindCount) {
      largestBindCount = arguments!.length;
    }
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    _record(whereArgs);
    return db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) {
    _record(arguments);
    return db.rawQuery(sql, arguments);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}
