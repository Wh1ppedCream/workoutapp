import 'dart:convert';

import 'package:env_test/db/exercise_catalog.dart';
import 'package:env_test/db/definition_dao.dart';
import 'package:env_test/db/schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await Schema.createTables(db);
  });

  tearDown(() => db.close());

  test(
    'updates a renamed catalog definition in place and replaces relations',
    () async {
      final bodyweightId = await db.insert('equipment', {'name': 'Bodyweight'});
      final oldBodyPartId = await db.insert('bodypart', {
        'name': 'Old body part',
      });
      final oldMuscleId = await db.insert('muscles', {'name': 'Old muscle'});
      await db.insert('bodypart', {'name': 'Core'});
      await db.insert('muscles', {'name': 'Rectus Abdominis'});
      await db.insert('exercise_definitions', {
        'id': 37,
        'name': 'Old rollout',
        'equipment_id': bodyweightId,
        'rating': 1,
      });
      await db.insert('exercise_bodypart', {
        'exercise_id': 37,
        'bodypart_id': oldBodyPartId,
      });
      await db.insert('exercise_muscle', {
        'exercise_id': 37,
        'muscle_id': oldMuscleId,
        'rank': 1,
      });
      await db.insert('sessions', {'date': '2026-01-01', 'duration': 60});
      final instanceId = await db.insert('exercises', {
        'session_id': 1,
        'exercise_def_id': 37,
        'type': 'weight',
        'order_index': 0,
      });

      await ExerciseCatalog.synchronize(
        db,
        sourceJson: _catalogJson(
          revision: 1,
          exercises: [
            _exercise(
              catalogId: 'tonos.exercise.0037',
              legacyMediaId: 37,
              name: 'Ab Wheel Rollout',
              aliases: ['Old rollout'],
            ),
          ],
        ),
      );

      final definition =
          (await db.query(
            'exercise_definitions',
            where: 'id = ?',
            whereArgs: [37],
          )).single;
      expect(definition['name'], 'Ab Wheel Rollout');
      expect(definition['catalog_id'], 'tonos.exercise.0037');
      expect(definition['legacy_media_id'], 37);
      expect(definition['catalog_status'], 'active');
      expect(
        (await db.query(
          'exercises',
          where: 'id = ?',
          whereArgs: [instanceId],
        )).single['exercise_def_id'],
        37,
      );
      expect(
        (await db.query(
          'exercise_bodypart',
          whereArgs: [37],
          where: 'exercise_id = ?',
        )).single['bodypart_id'],
        isNot(oldBodyPartId),
      );
      expect(
        (await db.query(
          'exercise_muscle',
          whereArgs: [37],
          where: 'exercise_id = ?',
        )).single['muscle_id'],
        isNot(oldMuscleId),
      );
      expect(
        (await db.query(
          'exercise_definition_aliases',
          where: 'exercise_def_id = ?',
          whereArgs: [37],
        )).single['alias'],
        'Old rollout',
      );
      final aliasSearch = await DefinitionDao.searchExerciseDefinitions(
        db,
        'old rollout',
      );
      expect(aliasSearch.single.name, 'Ab Wheel Rollout');
    },
  );

  test(
    'retires missing shipped definitions without touching user definitions',
    () async {
      await ExerciseCatalog.synchronize(
        db,
        sourceJson: _catalogJson(
          revision: 1,
          exercises: [
            _exercise(
              catalogId: 'tonos.exercise.0001',
              legacyMediaId: 1,
              name: 'Alpha',
            ),
            _exercise(
              catalogId: 'tonos.exercise.0002',
              legacyMediaId: 2,
              name: 'Beta',
            ),
          ],
        ),
      );
      final userDefinitionId = await db.insert('exercise_definitions', {
        'name': 'My custom exercise',
        'rating': 4,
      });

      await ExerciseCatalog.synchronize(
        db,
        sourceJson: _catalogJson(
          revision: 2,
          exercises: [
            _exercise(
              catalogId: 'tonos.exercise.0001',
              legacyMediaId: 1,
              name: 'Alpha renamed',
            ),
          ],
        ),
      );

      final definitions = await db.query('exercise_definitions', orderBy: 'id');
      expect(definitions, hasLength(3));
      expect(definitions[0]['name'], 'Alpha renamed');
      expect(definitions[0]['catalog_status'], 'active');
      expect(definitions[1]['name'], 'Beta');
      expect(definitions[1]['catalog_status'], 'retired');
      expect(definitions[2]['id'], userDefinitionId);
      expect(definitions[2]['catalog_id'], isNull);

      final selectableDefinitions = DefinitionDao.selectableCatalogDefinitions(
        await DefinitionDao.getAllExerciseDefinitionsDetailedBatched(db),
      );
      expect(selectableDefinitions.map((definition) => definition.name), [
        'Alpha renamed',
        'My custom exercise',
      ]);
      expect(
        await DefinitionDao.searchExerciseDefinitions(db, 'Beta'),
        isEmpty,
      );
    },
  );

  test(
    'does not rewrite a catalog revision that is already installed',
    () async {
      final initial = _catalogJson(
        revision: 4,
        exercises: [
          _exercise(
            catalogId: 'tonos.exercise.0001',
            legacyMediaId: 1,
            name: 'Original',
          ),
        ],
      );
      await ExerciseCatalog.synchronize(db, sourceJson: initial);
      await ExerciseCatalog.synchronize(
        db,
        sourceJson: _catalogJson(
          revision: 4,
          exercises: [
            _exercise(
              catalogId: 'tonos.exercise.0001',
              legacyMediaId: 1,
              name: 'Ignored without revision bump',
            ),
          ],
        ),
      );

      expect(
        (await db.query('exercise_definitions')).single['name'],
        'Original',
      );
      expect((await db.query('exercise_catalog_state')).single['revision'], 4);
    },
  );

  test(
    'does not adopt a matching user definition for a later catalog addition',
    () async {
      await ExerciseCatalog.synchronize(
        db,
        sourceJson: _catalogJson(
          revision: 1,
          exercises: [
            _exercise(
              catalogId: 'tonos.exercise.0001',
              legacyMediaId: 1,
              name: 'Alpha',
            ),
          ],
        ),
      );
      final userDefinitionId = await db.insert('exercise_definitions', {
        'name': 'Beta',
        'rating': 7,
      });

      await ExerciseCatalog.synchronize(
        db,
        sourceJson: _catalogJson(
          revision: 2,
          exercises: [
            _exercise(
              catalogId: 'tonos.exercise.0001',
              legacyMediaId: 1,
              name: 'Alpha',
            ),
            _exercise(
              catalogId: 'tonos.exercise.0002',
              legacyMediaId: 2,
              name: 'Beta',
            ),
          ],
        ),
      );

      final betaRows = await db.query(
        'exercise_definitions',
        where: 'name = ?',
        whereArgs: ['Beta'],
        orderBy: 'id',
      );
      expect(betaRows, hasLength(2));
      expect(betaRows.first['id'], userDefinitionId);
      expect(betaRows.first['catalog_id'], isNull);
      expect(betaRows.last['catalog_id'], 'tonos.exercise.0002');
    },
  );

  test(
    'rejects duplicate catalog identities before writing any definitions',
    () async {
      await expectLater(
        ExerciseCatalog.synchronize(
          db,
          sourceJson: _catalogJson(
            revision: 1,
            exercises: [
              _exercise(
                catalogId: 'tonos.exercise.0001',
                legacyMediaId: 1,
                name: 'Alpha',
              ),
              _exercise(
                catalogId: 'tonos.exercise.0001',
                legacyMediaId: 2,
                name: 'Beta',
              ),
            ],
          ),
        ),
        throwsA(isA<FormatException>()),
      );
      expect(await db.query('exercise_definitions'), isEmpty);
      expect(await db.query('exercise_catalog_state'), isEmpty);
    },
  );

  test('rejects aliases that would make shipped search ambiguous', () async {
    await expectLater(
      ExerciseCatalog.synchronize(
        db,
        sourceJson: _catalogJson(
          revision: 1,
          exercises: [
            _exercise(
              catalogId: 'tonos.exercise.0001',
              legacyMediaId: 1,
              name: 'Alpha',
              aliases: ['Former move'],
            ),
            _exercise(
              catalogId: 'tonos.exercise.0002',
              legacyMediaId: 2,
              name: 'Beta',
              aliases: ['Former move'],
            ),
          ],
        ),
      ),
      throwsA(isA<FormatException>()),
    );
    expect(await db.query('exercise_definitions'), isEmpty);
  });

  test(
    'rejects duplicate muscle relationships before writing definitions',
    () async {
      await expectLater(
        ExerciseCatalog.synchronize(
          db,
          sourceJson: _catalogJson(
            revision: 1,
            exercises: [
              _exercise(
                catalogId: 'tonos.exercise.0001',
                legacyMediaId: 1,
                name: 'Alpha',
                muscles: [
                  {'name': 'Rectus Abdominis', 'rank': 1},
                  {'name': 'Rectus Abdominis', 'rank': 2},
                ],
              ),
            ],
          ),
        ),
        throwsA(isA<FormatException>()),
      );
      expect(await db.query('exercise_definitions'), isEmpty);
    },
  );
}

String _catalogJson({
  required int revision,
  required List<Map<String, Object?>> exercises,
}) => jsonEncode({'revision': revision, 'exercises': exercises});

Map<String, Object?> _exercise({
  required String catalogId,
  required int legacyMediaId,
  required String name,
  List<String> aliases = const [],
  List<Map<String, Object>> muscles = const [
    {'name': 'Rectus Abdominis', 'rank': 1},
  ],
}) => {
  'catalogId': catalogId,
  'legacyMediaId': legacyMediaId,
  'name': name,
  'rating': 80,
  'aliases': aliases,
  'equipment': ['Bodyweight'],
  'bodyparts': ['Core'],
  'muscles': muscles,
  'setupNotes': 'Set up.',
  'executionNotes': 'Move.',
  'tipsNotes': 'Control it.',
};
