// File: lib/db/definition_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

/// Encapsulates all exercise‐definition queries and filters.
class DefinitionDao {
  /// Fetch by body‐part.
  static Future<List<Map<String, dynamic>>> getExerciseDefsByBodyPart(
    Database db,
    int bodyPartId,
  ) {
    return db.rawQuery(
      '''
      SELECT ed.id, ed.name, ed.equipment_id
        FROM exercise_definitions ed
        JOIN exercise_bodypart eb ON eb.exercise_id = ed.id
       WHERE eb.bodypart_id = ?
       ORDER BY ed.name
      ''',
      [bodyPartId],
    );
  }

  /// Fully‐detailed definitions (joins equipment, bodyParts, muscles).
  static Future<List<ExerciseDefinition>> getAllExerciseDefinitionsDetailed(
    Database db,
  ) async {
    final defRows = await db.query('exercise_definitions', orderBy: 'name');
    final List<ExerciseDefinition> defs = [];

    for (final row in defRows) {
      final defId       = row['id'] as int;
      final name        = row['name'] as String;
      final equipmentId = row['equipment_id'] as int?;
      final rating      = (row['rating'] as num?)?.toInt() ?? 0;

      // equipmentList
      final equipRows = await db.rawQuery('''
        SELECT e.id, e.name
          FROM equipment e
          JOIN exercise_equipment ee ON ee.equipment_id = e.id
         WHERE ee.exercise_id = ?
         ORDER BY e.name
      ''', [defId]);
      final equipmentList = equipRows
          .map((e) => Equipment(e['id'] as int, e['name'] as String))
          .toList();

      // bodyParts
      final bpRows = await db.rawQuery('''
        SELECT b.id, b.name
          FROM bodypart b
          JOIN exercise_bodypart eb ON eb.bodypart_id = b.id
         WHERE eb.exercise_id = ?
         ORDER BY b.name
      ''', [defId]);
      final bodyParts = bpRows
          .map((b) => BodyPart(b['id'] as int, b['name'] as String))
          .toList();

      // muscles
      final mRows = await db.rawQuery('''
        SELECT m.id AS muscle_id, m.name AS muscle_name, em.rank
          FROM muscles m
          JOIN exercise_muscle em ON em.muscle_id = m.id
         WHERE em.exercise_id = ?
         ORDER BY em.rank
      ''', [defId]);
      final muscles = mRows.map((m) {
        return RankedMuscle(
          muscle: Muscle(id: m['muscle_id'] as int, name: m['muscle_name'] as String),
          rank: (m['rank'] as num).toInt(),
        );
      }).toList();

      defs.add(ExerciseDefinition(
        id:            defId,
        name:          name,
        equipmentId:   equipmentId,
        rating:        rating,
        equipmentList: equipmentList,
        bodyParts:     bodyParts,
        muscles:       muscles,
      ));
    }
    return defs;
  }

  /// Shallow list of raw definitions.
  static Future<List<Map<String, dynamic>>> getAllExercisesRaw(
    Database db,
  ) {
    return db.query('exercise_definitions', orderBy: 'name');
  }

  /// Equipment‐any filter.
  static Future<List<ExerciseDefinition>> getExerciseDefsWithAnyEquipment(
    Database db,
    List<String> equipmentNames,
  ) async {
    if (equipmentNames.isEmpty) return [];
    final eqRows = await db.query(
      'equipment',
      where:    'name IN (${List.filled(equipmentNames.length, '?').join(',')})',
      whereArgs: equipmentNames,
    );
    final eqIds = eqRows.map((r) => r['id'] as int).toList();
    if (eqIds.isEmpty) return [];

    final defRows = await db.query(
      'exercise_definitions',
      where:    'equipment_id IN (${List.filled(eqIds.length, '?').join(',')})',
      whereArgs: eqIds,
      orderBy:  'name',
    );
    return defRows.map((r) {
      return ExerciseDefinition(
        id:            r['id']   as int,
        name:          r['name'] as String,
        equipmentId:   r['equipment_id'] as int?,
        rating:        r['rating'] as int,
        equipmentList: const [],
        bodyParts:     const [],
        muscles:       const [],
      );
    }).toList();
  }

  /// Equipment‐only filter.
  static Future<List<ExerciseDefinition>> getExerciseDefsOnlyWithEquipment(
    Database db,
    List<String> equipmentNames, {
    bool includeNone = true,
  }) async {
    // lookup IDs
    final eqRows = await db.query(
      'equipment',
      where:    'name IN (${List.filled(equipmentNames.length, '?').join(',')})',
      whereArgs: equipmentNames,
    );
    final eqIds = eqRows.map((r) => r['id'] as int).toList();

    // build WHERE
    final whereClauses = <String>[];
    final args         = <Object?>[];
    if (eqIds.isNotEmpty) {
      whereClauses.add('equipment_id IN (${List.filled(eqIds.length, '?').join(',')})');
      args.addAll(eqIds);
    }
    if (includeNone) whereClauses.add('equipment_id IS NULL');
    if (whereClauses.isEmpty) {
      return getAllExerciseDefinitionsDetailed(db);
    }

    final defRows = await db.query(
      'exercise_definitions',
      where:     whereClauses.join(' OR '),
      whereArgs: args,
      orderBy:   'name',
    );
    return defRows.map((r) {
      return ExerciseDefinition(
        id:            r['id']   as int,
        name:          r['name'] as String,
        equipmentId:   r['equipment_id'] as int?,
        rating:        r['rating'] as int,
        equipmentList: const [],
        bodyParts:     const [],
        muscles:       const [],
      );
    }).toList();
  }

  /// Multi-filter (equipment/bodyparts/muscles).
  static Future<List<ExerciseDefinition>> getExerciseDefinitionsFiltered(
    Database db, {
    List<String>? equipmentNames,
    List<int>?    bodypartIds,
    List<int>?    muscleIds,
  }) async {
    // Resolve equipment → IDs
    List<int> equipmentIds = [];
    if (equipmentNames != null && equipmentNames.isNotEmpty) {
      final eqRows = await db.query(
        'equipment',
        columns:   ['id'],
        where:     'name IN (${List.filled(equipmentNames.length, '?').join(',')})',
        whereArgs: equipmentNames,
      );
      equipmentIds = eqRows.map((r) => r['id'] as int).toList();
    }

    final whereClauses = <String>[];
    final whereArgs    = <Object?>[];

    if (equipmentIds.isNotEmpty) {
      whereClauses.add('ed.equipment_id IN (${List.filled(equipmentIds.length, '?').join(',')})');
      whereArgs.addAll(equipmentIds);
    }
    if (bodypartIds != null && bodypartIds.isNotEmpty) {
      whereClauses.add('eb.bodypart_id IN (${List.filled(bodypartIds.length, '?').join(',')})');
      whereArgs.addAll(bodypartIds);
    }
    if (muscleIds != null && muscleIds.isNotEmpty) {
      whereClauses.add('em.muscle_id IN (${List.filled(muscleIds.length, '?').join(',')})');
      whereArgs.addAll(muscleIds);
    }

    final sql = StringBuffer()
      ..write('''
        SELECT DISTINCT ed.id, ed.name, ed.equipment_id, ed.rating
          FROM exercise_definitions ed
      ''')
      ..write(bodypartIds != null && bodypartIds.isNotEmpty
        ? 'JOIN exercise_bodypart eb ON eb.exercise_id = ed.id '
        : '')
      ..write(muscleIds != null && muscleIds.isNotEmpty
        ? 'JOIN exercise_muscle em ON em.exercise_id = ed.id '
        : '')
      ..write(whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')} '
        : '')
      ..write('ORDER BY ed.name');

    final rows = await db.rawQuery(sql.toString(), whereArgs);
    return rows.map((r) {
      return ExerciseDefinition(
        id:            r['id']   as int,
        name:          r['name'] as String,
        equipmentId:   r['equipment_id'] as int?,
        rating:        r['rating'] as int,
        equipmentList: const [],
        bodyParts:     const [],
        muscles:       const [],
      );
    }).toList();
  }

/// Finds an exercise_definition by name+equipment (inserting if missing),
  /// and returns its ID.
  static Future<int> findOrCreateExerciseDefinition(
    Database db,
    String name,
    String equipmentName,
  ) async {
    // 1) Lookup equipment_id if the name is non-empty
    int? eqId;
    if (equipmentName.isNotEmpty) {
      final eqRows = await db.query(
        'equipment',
        where: 'name = ?',
        whereArgs: [equipmentName],
      );
      if (eqRows.isNotEmpty) {
        eqId = eqRows.first['id'] as int;
      }
    }

    // 2) Try to find an existing definition
    final whereClause = eqId != null
        ? 'name = ? AND equipment_id = ?'
        : 'name = ? AND equipment_id IS NULL';
    final whereArgs = eqId != null ? [name, eqId] : [name];
    final defRows = await db.query(
      'exercise_definitions',
      where: whereClause,
      whereArgs: whereArgs,
    );
    if (defRows.isNotEmpty) {
      return defRows.first['id'] as int;
    }

    // 3) Not found—insert new
    return await db.insert(
      'exercise_definitions',
      {
        'name': name,
        'equipment_id': eqId,
        'rating': 0,  // default
      },
    );
  }

  /// Returns {'name': .., 'equipmentName': ..} for the given definition ID.
  static Future<Map<String, String?>> getDefinitionInfo(
    Database db,
    int defId,
  ) async {
    final rows = await db.rawQuery('''
      SELECT 
        ed.name            AS name,
        e.name            AS equipment_name
      FROM exercise_definitions ed
      LEFT JOIN equipment e ON ed.equipment_id = e.id
      WHERE ed.id = ?
    ''', [defId]);

    if (rows.isEmpty) {
      throw Exception('Definition $defId not found');
    }
    final row = rows.first;
    return {
      'name':           row['name'] as String,
      'equipmentName':  row['equipment_name'] as String?,
    };
  }

}
