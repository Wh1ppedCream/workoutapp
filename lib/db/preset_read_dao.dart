import 'package:sqflite/sqflite.dart';

import '../models/models.dart';
import 'db_query_utils.dart';
import 'preset_auto_settings_dao.dart';
import 'preset_definition_dao.dart';
import 'preset_exercise_dao.dart';

/// Bounded/chunked reads of a preset graph. The caller owns the transaction;
/// every query uses that executor, and this DAO never opens a connection.
class PresetReadDao {
  static Future<PresetReadSnapshot> load(
    DatabaseExecutor db,
    int presetId,
  ) async {
    final preset = await PresetDefinitionDao.getPresetById(db, presetId);
    final exercises = await PresetExerciseDao.getExercisesForPreset(
      db,
      presetId,
    );
    final automatic = await PresetAutoSettingsDao.getAutoSettings(db, presetId);
    List<int> idsFor(String type) => exercises
        .where((row) => row['type'] == type)
        .map((row) => row['id'])
        .whereType<int>()
        .toList();
    final weightIds = idsFor('weight');
    final cardioIds = idsFor('cardio');
    final stretchIds = idsFor('stretch');
    final definitionIds = exercises
        .where((row) => row['type'] == 'weight')
        .map((row) => row['exercise_def_id'])
        .whereType<int>()
        .toSet()
        .toList();
    final definitions = <int, ExerciseDefinitionInfo>{};
    for (final chunk in sqliteChunks(definitionIds)) {
      final rows = await db.rawQuery('''
        SELECT ed.id, ed.name, e.name AS equipmentName
        FROM exercise_definitions ed
        LEFT JOIN equipment e ON ed.equipment_id = e.id
        WHERE ed.id IN (${sqlitePlaceholders(chunk.length)})
      ''', chunk);
      for (final row in rows) {
        definitions[row['id'] as int] = ExerciseDefinitionInfo.fromRow(row);
      }
    }
    final setRows = await _forOwners(
      db,
      'preset_sets',
      'preset_exercise_id',
      weightIds,
      ordered: true,
    );
    final cardioRows = await _forOwners(
      db,
      'preset_cardio_details',
      'preset_exercise_id',
      cardioIds,
    );
    final stretchRows = await _forOwners(
      db,
      'preset_stretch_items',
      'preset_exercise_id',
      stretchIds,
      ordered: true,
    );
    final exerciseAuto = await _forOwners(
      db,
      'preset_exercise_auto',
      'preset_exercise_id',
      [...weightIds, ...cardioIds, ...stretchIds],
    );
    final setAuto = await _forOwners(
      db,
      'preset_set_auto',
      'preset_set_id',
      setRows.map((row) => row['id']).whereType<int>().toList(),
    );
    final sets = <int, List<PresetSetRow>>{};
    for (final row in setRows) {
      sets
          .putIfAbsent(row['preset_exercise_id'] as int, () => [])
          .add(PresetSetRow(row));
    }
    final stretches = <int, List<PresetStretchRow>>{};
    final firstStretchByOwner = <int, Map<String, Object?>>{};
    for (final row in stretchRows) {
      final owner = row['preset_exercise_id'] as int;
      stretches.putIfAbsent(owner, () => []).add(PresetStretchRow(row));
      firstStretchByOwner.putIfAbsent(owner, () => row);
    }
    final stretchNames = <int, String>{};
    final stretchDefinitionIds = firstStretchByOwner.values
        .map((row) => row['stretch_id'])
        .whereType<int>()
        .toSet()
        .toList();
    for (final chunk in sqliteChunks(stretchDefinitionIds)) {
      final rows = await db.query(
        'stretch_definitions',
        columns: ['id', 'name'],
        where: 'id IN (${sqlitePlaceholders(chunk.length)})',
        whereArgs: chunk,
      );
      for (final row in rows) {
        stretchNames[row['id'] as int] = row['name'] as String;
      }
    }
    return PresetReadSnapshot(
      preset: preset == null ? null : PresetDefinition.fromRow(preset),
      exercises: exercises.map(PresetExerciseRow.new).toList(),
      definitions: definitions,
      sets: sets,
      cardio: {
        for (final row in cardioRows)
          row['preset_exercise_id'] as int: PresetCardioRow(row),
      },
      stretches: stretches,
      stretchNames: stretchNames,
      autoSettings: automatic == null ? null : PresetAutoSettingsRow(automatic),
      exerciseAuto: {
        for (final row in exerciseAuto)
          row['preset_exercise_id'] as int: PresetExerciseAutoRow(row),
      },
      setAuto: {
        for (final row in setAuto)
          row['preset_set_id'] as int: PresetSetAutoRow(row),
      },
    );
  }

  static Future<List<Map<String, Object?>>> _forOwners(
    DatabaseExecutor db,
    String table,
    String ownerColumn,
    List<int> ownerIds, {
    bool ordered = false,
  }) async {
    final rows = <Map<String, Object?>>[];
    for (final chunk in sqliteChunks(ownerIds.toSet().toList())) {
      rows.addAll(
        await db.query(
          table,
          where: '$ownerColumn IN (${sqlitePlaceholders(chunk.length)})',
          whereArgs: chunk,
          orderBy: ordered ? 'order_index' : null,
        ),
      );
    }
    return rows;
  }
}
