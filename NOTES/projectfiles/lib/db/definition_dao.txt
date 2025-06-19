definition_dao.dart

Purpose:Provides query methods for retrieving and filtering exercise definitions (exercise_definitions and related junction tables).

Key methods:

getExerciseDefsByBodyPart(db, bodyPartId):Uses rawQuery to join exercise_definitions with exercise_bodypart and fetch definitions linked to a specific body part.

getAllExerciseDefinitionsDetailed(db):Retrieves full ExerciseDefinition objects by:

Querying exercise_definitions.

For each definition, fetching associated equipmentList, bodyParts, and muscles via joins.

Mapping rows to domain models (Equipment, BodyPart, RankedMuscle).

getAllExercisesRaw(db):Performs a simple query to fetch raw maps of all exercise definitions without related data.

getExerciseDefsWithAnyEquipment(db, equipmentNames):Filters definitions whose equipment_id matches any of the provided equipment names, returning partial ExerciseDefinition objects (no related lists).

getExerciseDefsOnlyWithEquipment(db, equipmentNames, includeNone):Retrieves definitions that either have equipment in the provided list or (optionally) none, using dynamically built WHERE clauses and IN lists.

getExerciseDefinitionsFiltered(db, equipmentNames?, bodypartIds?, muscleIds?):A flexible multi-filter method:

Resolves equipment names to IDs.

Builds WHERE clauses for equipment, body parts (exercise_bodypart), and muscles (exercise_muscle).

Constructs a dynamic rawQuery with optional JOINs and filters, returning ExerciseDefinition objects (without related lists).

Observations & suggestions:

Batch loading: The detailed fetch performs N+1 queries (one per definition). Consider using fewer JOINs or batching to reduce DB round-trips.

Typed results: For raw map queries, wrap results in DTOs or domain classes rather than returning Map<String, dynamic>.

Query builders: Use a query builder or ORM-like layer (e.g., Drift) to reduce manual SQL string concatenation and improve maintainability.

Parameter safety: Ensure that dynamic IN-list building properly sanitizes arguments to avoid SQL injection (though sqflite uses parameter binding here).

Cache lookups: Cache equipment ID lookups when filtering by equipment to avoid repeated queries in loops.

Pagination & limits: Add optional limit and offset parameters to filter methods to handle large result sets gracefully.


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
}
