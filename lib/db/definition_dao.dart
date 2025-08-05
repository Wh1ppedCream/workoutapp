// File: lib/db/definition_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

/// Data Access Object for exercise definitions and related lookups.
///
/// Provides query methods to fetch, filter, search, create, update, and delete
/// records in the `exercise_definitions` table and its join relationships.
class DefinitionDao {
  /// Fetches exercise definition IDs, names, and equipment IDs for definitions
  /// associated with a specific body part.
  ///
  /// - [db]: Open database instance.
  /// - [bodyPartId]: ID of the body part to filter by.
  ///
  /// Returns a list of maps containing keys: `id`, `name`, `equipment_id`.
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

  /// Retrieves full details for all exercise definitions, including
  /// equipmentList, bodyParts, and ranked muscles.
  ///
  /// - [db]: Open database instance.
  ///
  /// Returns a list of [ExerciseDefinition] with all join lists populated.
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
      final useManual = (row['use_manual_bodyparts'] as int? ?? 0) == 1;
      // ↓ new, read your INTEGER 0/1 flag
final multiplyByRating = (row['multiply_by_rating'] as int? ?? 0) == 1;

      // NEW: read notes columns
    final setupNotes     = (row['setup_notes']     as String?) ?? '';
    final executionNotes = (row['execution_notes'] as String?) ?? '';
    final tipsNotes      = (row['tips_notes']      as String?) ?? '';

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
        useManualBodyparts: useManual,
        multiplyByRating:   multiplyByRating,
        setupNotes:     setupNotes,
      executionNotes: executionNotes,
      tipsNotes:      tipsNotes,
      ));
    }
    return defs;
  }

  /// Retrieves a shallow list of all exercise definition rows.
  ///
  /// - [db]: Open database instance.
  ///
  /// Returns list of maps with keys directly from the table (no joins).
  static Future<List<Map<String, dynamic>>> getAllExercisesRaw(
    Database db,
  ) {
    return db.query('exercise_definitions', orderBy: 'name');
  }

  /// Filters definitions by any of the given equipment names (primary only).
  ///
  /// - [db]: Open database instance.
  /// - [equipmentNames]: List of equipment names to match.
  ///
  /// Returns definitions that have a primary equipment in [equipmentNames].
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
        useManualBodyparts: (r['use_manual_bodyparts'] as int? ?? 0) == 1,
        multiplyByRating:    (r['multiply_by_rating']    as int? ?? 0)==1,
         setupNotes:     '',
 executionNotes: '',
 tipsNotes:      '',
      );
    }).toList();
  }

  /// Filters definitions to only those matching given equipment names, and
  /// optionally those with no equipment if [includeNone] is true.
  ///
  /// - [db]: Open database instance.
  /// - [equipmentNames]: Names to include.
  /// - [includeNone]: Whether to include definitions without equipment.
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
        useManualBodyparts: (r['use_manual_bodyparts'] as int? ?? 0) == 1,
        multiplyByRating:    (r['multiply_by_rating']    as int? ?? 0)==1,
         setupNotes:     '',
 executionNotes: '',
 tipsNotes:      '',
      );
    }).toList();
  }

  /// Applies combined filters for equipment, body parts, and muscles.
  ///
  /// - [db]: Open database instance.
  /// - [equipmentNames]: Optional list of equipment to filter by.
  /// - [bodypartIds]: Optional list of body part IDs to filter by.
  /// - [muscleIds]: Optional list of muscle IDs to filter by.
  ///
  /// Returns distinct [ExerciseDefinition] objects matching all specified filters.
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
        SELECT DISTINCT ed.id, ed.name, ed.equipment_id, ed.rating, ed.use_manual_bodyparts, ed.multiply_by_rating
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
        useManualBodyparts: (r['use_manual_bodyparts'] as int? ?? 0) == 1,
        multiplyByRating:    (r['multiply_by_rating']    as int? ?? 0)==1,
   setupNotes:          '',
   executionNotes:      '',
   tipsNotes:           '',
      );
    }).toList();
  }

/// Finds or creates an [ExerciseDefinition] by [name] and [equipmentName].
/// Returns the definition ID.
static Future<int> findOrCreateExerciseDefinition(
  Database db,
  String name,
  String equipmentName,
) async {
  // 1) Resolve equipment_id if provided
  int? eqId;
  if (equipmentName.isNotEmpty) {
    final eqRows = await db.query(
      'equipment',
      where: 'name = ?',
      whereArgs: [equipmentName],
      limit: 1,
    );
    if (eqRows.isNotEmpty) eqId = eqRows.first['id'] as int;
  }

  // 2) Lookup existing definition by name + any equipment (primary or via join table)
  final lookupArgs = eqId != null ? [name, eqId, eqId] : [name];
  // new: interpolated string (Dart will replace ${…})
final defRows = await db.rawQuery('''
  SELECT ed.id
    FROM exercise_definitions ed
    LEFT JOIN exercise_equipment ee ON ee.exercise_id = ed.id
   WHERE ed.name = ?
     AND (
       ${eqId != null ? 'ed.equipment_id = ? OR ee.equipment_id = ?' : 'ed.equipment_id IS NULL'}
     )
   LIMIT 1
''', lookupArgs);


  if (defRows.isNotEmpty) {
    // Found an existing definition
    return defRows.first['id'] as int;
  }

  // 3) Not found — insert a new definition
  await db.insert(
    'exercise_definitions',
    {
      'name': name,
      'equipment_id': eqId,
      'rating': 0,
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );

  // 4) Re-query for the ID (either our insert or an existing one)
  final requery = await db.rawQuery('''
  SELECT ed.id
    FROM exercise_definitions ed
    LEFT JOIN exercise_equipment ee ON ee.exercise_id = ed.id
   WHERE ed.name = ?
     AND (
       ${eqId != null ? 'ed.equipment_id = ? OR ee.equipment_id = ?' : 'ed.equipment_id IS NULL'}
     )
   LIMIT 1
''', lookupArgs);
  return requery.first['id'] as int;
}


  /// Retrieves the name and equipmentName for a definition ID.
  ///
  /// - [db]: Open database instance.
  /// - [defId]: Definition ID to lookup.
  ///
  /// Returns map {'name': String, 'equipmentName': String?}.
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

/// Updates core fields of an existing [ExerciseDefinition].
  ///
  /// - [db]: Open database instance.
  /// - [def]: Definition object with updated fields.
  ///
  /// Returns number of rows affected.
static Future<int> updateExerciseDefinition(
  Database db,
  ExerciseDefinition def,
) {
  return db.update(
    'exercise_definitions',
    {
      'name': def.name,
      'equipment_id': def.equipmentId,
      'rating': def.rating,
      'use_manual_bodyparts': def.useManualBodyparts ? 1 : 0,
      'multiply_by_rating':    def.multiplyByRating   ? 1 : 0,
      
      // NEW: persist notes columns
      'setup_notes':     def.setupNotes,
      'execution_notes': def.executionNotes,
      'tips_notes':      def.tipsNotes,
    },
    where: 'id = ?',
    whereArgs: [def.id],
  );
}

 /// Deletes an exercise definition, cascading to join tables.
  ///
  /// - [db]: Open database instance.
  /// - [defId]: Definition ID to delete.
  ///
  /// Returns number of rows removed.
static Future<int> deleteExerciseDefinition(
  Database db,
  int defId,
) {
  return db.delete(
    'exercise_definitions',
    where: 'id = ?',
    whereArgs: [defId],
  );
}

/// Performs case-insensitive name search on definitions.
  ///
  /// - [db]: Open database instance.
  /// - [query]: Substring to search in lower-case.
  ///
  /// Returns shallow [ExerciseDefinition] list.
static Future<List<ExerciseDefinition>> searchExerciseDefinitions(
  Database db,
  String query,
) async {
  final rows = await db.query(
    'exercise_definitions',
    where: 'LOWER(name) LIKE ?',
    whereArgs: ['%${query.toLowerCase()}%'],
    orderBy: 'name',
  );
  return rows.map((r) => ExerciseDefinition(
    id:           r['id'] as int,
    name:         r['name'] as String,
    equipmentId:  r['equipment_id'] as int?,
    rating:       (r['rating'] as num).toInt(),
    equipmentList: const [],
    bodyParts:     const [],
    muscles:       const [],
    useManualBodyparts: (r['use_manual_bodyparts'] as int? ?? 0) == 1,
    multiplyByRating:    (r['multiply_by_rating']    as int? ?? 0)==1,
         setupNotes:     '',
 executionNotes: '',
 tipsNotes:      '',
  )).toList();
}

  /// Performs fuzzy search on definition names with SQL LIKE.
  ///
  /// - [db]: Open database instance.
  /// - [searchTerm]: Pattern to match in names.
  ///
  /// Returns shallow [ExerciseDefinition] list.
  static Future<List<ExerciseDefinition>> fuzzsearchExerciseDefinitions(
    Database db,
    String searchTerm,
  ) async {
    final likeArg = '%${searchTerm.replaceAll("'", "''")}%';
    final rows = await db.query(
      'exercise_definitions',
      where: 'name LIKE ?',
      whereArgs: [likeArg],
      orderBy: 'name',
    );
    return rows.map((r) {
      return ExerciseDefinition(
        id:            r['id']            as int,
        name:          r['name']          as String,
        equipmentId:   r['equipment_id']  as int?,
        rating:       (r['rating'] as num?)?.toInt() ?? 0,
        equipmentList: const [],
        bodyParts:     const [],
        muscles:       const [],
        useManualBodyparts: (r['use_manual_bodyparts'] as int? ?? 0) == 1,
        multiplyByRating:    (r['multiply_by_rating']    as int? ?? 0)==1,
   setupNotes:          '',
   executionNotes:      '',
   tipsNotes:           '',
      );
    }).toList();
  }


/// Fetches a single ExerciseDefinition with all joins populated.
static Future<ExerciseDefinition?> getExerciseDefinitionById(
  Database db,
  int defId,
) async {
  final rows = await db.query(
    'exercise_definitions',
    where: 'id = ?',
    whereArgs: [defId],
    limit: 1,
  );
  if (rows.isEmpty) return null;
  final row = rows.first;
  final name        = row['name']            as String;
  final equipmentId = row['equipment_id']    as int?;
  final rating      = (row['rating'] as num?)?.toInt() ?? 0;
  final useManual = (row['use_manual_bodyparts'] as int? ?? 0) == 1;
  final multiplyByRating = (row['multiply_by_rating'] as int? ?? 0) == 1;


  // NEW: read notes columns
  final setupNotes     = (row['setup_notes']     as String?) ?? '';
  final executionNotes = (row['execution_notes'] as String?) ?? '';
  final tipsNotes      = (row['tips_notes']      as String?) ?? '';

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
      rank:  (m['rank'] as num).toInt(),
    );
  }).toList();

  return ExerciseDefinition(
    id:            defId,
    name:          name,
    equipmentId:   equipmentId,
    rating:        rating,
    equipmentList: equipmentList,
    bodyParts:     bodyParts,
    muscles:       muscles,
    useManualBodyparts: useManual,
    multiplyByRating:   multiplyByRating,
    setupNotes:     setupNotes,
    executionNotes: executionNotes,
    tipsNotes:      tipsNotes,
  );
}

/// Inserts a muscle↔exercise link at a given rank.
static Future<int> insertExerciseMuscleMapping(
  Database db,
  int exerciseId,
  int muscleId,
  int rank,
) {
  return db.insert(
    'exercise_muscle',
    {
      'exercise_id': exerciseId,
      'muscle_id':   muscleId,
      'rank':        rank,
    },
  );
}

/// Deletes the association between an exercise definition and a muscle.
static Future<int> deleteExerciseMuscleMapping(
  Database db,
  int exerciseId,
  int muscleId,
) {
  return db.delete(
    'exercise_muscle',
    where: 'exercise_id = ? AND muscle_id = ?',
    whereArgs: [exerciseId, muscleId],
  );
}

/// Inserts a body-part↔exercise link.
static Future<int> insertExerciseBodypartMapping(
  Database db,
  int exerciseId,
  int bodypartId,
) {
  return db.insert(
    'exercise_bodypart',
    {
      'exercise_id': exerciseId,
      'bodypart_id': bodypartId,
    },
  );
}

/// Deletes a body-part↔exercise link.
static Future<int> deleteExerciseBodypartMapping(
  Database db,
  int exerciseId,
  int bodypartId,
) {
  return db.delete(
    'exercise_bodypart',
    where: 'exercise_id = ? AND bodypart_id = ?',
    whereArgs: [exerciseId, bodypartId],
  );
}

/// Inserts an equipment↔exercise link.
static Future<int> insertExerciseEquipmentMapping(
  Database db,
  int exerciseId,
  int equipmentId,
) {
  return db.insert(
    'exercise_equipment',
    {
      'exercise_id':  exerciseId,
      'equipment_id': equipmentId,
    },
  );
}

/// Deletes an equipment↔exercise link.
static Future<int> deleteExerciseEquipmentMapping(
  Database db,
  int exerciseId,
  int equipmentId,
) {
  return db.delete(
    'exercise_equipment',
    where: 'exercise_id = ? AND equipment_id = ?',
    whereArgs: [exerciseId, equipmentId],
  );
}


/// Reads the “multiply_by_rating” flag from the exercise_definitions row.
static Future<bool> getMultiplyByRating(
  Database db,
  int defId,
) async {
  final rows = await db.query(
    'exercise_definitions',
    columns: ['multiply_by_rating'],
    where: 'id = ?',
    whereArgs: [defId],
    limit: 1,
  );
  if (rows.isEmpty) return false;
  return (rows.first['multiply_by_rating'] as int? ?? 0) == 1;
}

/// Updates the “multiply_by_rating” flag for a definition.
static Future<int> setMultiplyByRating(
  Database db,
  int defId,
  bool enabled,
) {
  return db.update(
    'exercise_definitions',
    {'multiply_by_rating': enabled ? 1 : 0},
    where: 'id = ?',
    whereArgs: [defId],
  );
}


}
