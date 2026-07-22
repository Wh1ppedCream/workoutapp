// File: lib/db/definition_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/models.dart';
import 'db_query_utils.dart';

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
  ) {
    return getAllExerciseDefinitionsDetailedBatched(db);
  }

  /// Batched detailed-definition loader used by all detailed lookup paths.
  ///
  /// Reads each join table once, groups the rows in memory, and keeps the
  /// resulting model shape identical for callers.
  static Future<List<ExerciseDefinition>>
  getAllExerciseDefinitionsDetailedBatched(Database db) async {
    final defRows = await db.rawQuery('''
      SELECT ed.*, primary_equipment.name AS equipment_name
      FROM exercise_definitions ed
      LEFT JOIN equipment primary_equipment
        ON primary_equipment.id = ed.equipment_id
      ORDER BY ed.name
    ''');
    if (defRows.isEmpty) return const <ExerciseDefinition>[];

    final equipmentRowsFuture = db.rawQuery('''
      SELECT
        ee.exercise_id AS exercise_id,
        e.id AS equipment_id,
        e.name AS equipment_name
      FROM exercise_equipment ee
      JOIN equipment e ON e.id = ee.equipment_id
      ORDER BY ee.exercise_id, e.name
    ''');
    final bodyPartRowsFuture = db.rawQuery('''
      SELECT
        eb.exercise_id AS exercise_id,
        b.id AS bodypart_id,
        b.name AS bodypart_name
      FROM exercise_bodypart eb
      JOIN bodypart b ON b.id = eb.bodypart_id
      ORDER BY eb.exercise_id, b.name
    ''');
    final muscleRowsFuture = db.rawQuery('''
      SELECT
        em.exercise_id AS exercise_id,
        m.id AS muscle_id,
        m.name AS muscle_name,
        em.rank AS rank
      FROM exercise_muscle em
      JOIN muscles m ON m.id = em.muscle_id
      ORDER BY em.exercise_id, em.rank, m.name
    ''');

    final equipmentRows = await equipmentRowsFuture;
    final bodyPartRows = await bodyPartRowsFuture;
    final muscleRows = await muscleRowsFuture;

    return _hydrateDefinitions(
      defRows: defRows,
      equipmentRows: equipmentRows,
      bodyPartRows: bodyPartRows,
      muscleRows: muscleRows,
    );
  }

  static List<ExerciseDefinition> _hydrateDefinitions({
    required List<Map<String, Object?>> defRows,
    required List<Map<String, Object?>> equipmentRows,
    required List<Map<String, Object?>> bodyPartRows,
    required List<Map<String, Object?>> muscleRows,
  }) {
    final equipmentByDefinition = <int, List<Equipment>>{};
    for (final row in equipmentRows) {
      final defId = row['exercise_id'] as int;
      equipmentByDefinition
          .putIfAbsent(defId, () => <Equipment>[])
          .add(
            Equipment(
              row['equipment_id'] as int,
              row['equipment_name'] as String,
            ),
          );
    }

    final bodyPartsByDefinition = <int, List<BodyPart>>{};
    for (final row in bodyPartRows) {
      final defId = row['exercise_id'] as int;
      bodyPartsByDefinition
          .putIfAbsent(defId, () => <BodyPart>[])
          .add(
            BodyPart(row['bodypart_id'] as int, row['bodypart_name'] as String),
          );
    }

    final musclesByDefinition = <int, List<RankedMuscle>>{};
    for (final row in muscleRows) {
      final defId = row['exercise_id'] as int;
      musclesByDefinition
          .putIfAbsent(defId, () => <RankedMuscle>[])
          .add(
            RankedMuscle(
              muscle: Muscle(
                id: row['muscle_id'] as int,
                name: row['muscle_name'] as String,
              ),
              rank: (row['rank'] as num).toInt(),
            ),
          );
    }

    return defRows
        .map(
          (row) => _definitionFromRow(
            row,
            equipmentList:
                equipmentByDefinition[row['id'] as int] ?? const <Equipment>[],
            bodyParts:
                bodyPartsByDefinition[row['id'] as int] ?? const <BodyPart>[],
            muscles:
                musclesByDefinition[row['id'] as int] ?? const <RankedMuscle>[],
          ),
        )
        .toList();
  }

  static ExerciseDefinition _definitionFromRow(
    Map<String, Object?> row, {
    List<Equipment> equipmentList = const <Equipment>[],
    List<BodyPart> bodyParts = const <BodyPart>[],
    List<RankedMuscle> muscles = const <RankedMuscle>[],
  }) {
    final primaryEquipmentId = row['equipment_id'] as int?;
    final primaryEquipmentName = row['equipment_name'] as String?;
    final resolvedEquipmentList = List<Equipment>.from(equipmentList);
    if (primaryEquipmentId != null &&
        primaryEquipmentName != null &&
        !resolvedEquipmentList.any(
          (equipment) => equipment.id == primaryEquipmentId,
        )) {
      // Older rows can have a primary equipment value without its matching
      // join-table row. Keep it a required item while loading the definition.
      resolvedEquipmentList.insert(
        0,
        Equipment(primaryEquipmentId, primaryEquipmentName),
      );
    }

    return ExerciseDefinition(
      id: row['id'] as int,
      name: row['name'] as String,
      equipmentId: primaryEquipmentId,
      rating: (row['rating'] as num?)?.toInt() ?? 0,
      equipmentList: resolvedEquipmentList,
      bodyParts: bodyParts,
      muscles: muscles,
      useManualBodyparts: (row['use_manual_bodyparts'] as int? ?? 0) == 1,
      multiplyByRating: (row['multiply_by_rating'] as int? ?? 0) == 1,
      setupNotes: (row['setup_notes'] as String?) ?? '',
      executionNotes: (row['execution_notes'] as String?) ?? '',
      tipsNotes: (row['tips_notes'] as String?) ?? '',
      starterLoadProfile: _starterLoadProfileFromRow(row),
    );
  }

  static StarterLoadProfile? _starterLoadProfileFromRow(
    Map<String, Object?> row,
  ) {
    final type = starterLoadTypeFromString(row['starter_load_type'] as String?);
    if (type == StarterLoadType.unknown) return null;

    return StarterLoadProfile(
      type: type,
      easyValue: (row['starter_easy_value'] as num?)?.toDouble(),
      mediumValue: (row['starter_medium_value'] as num?)?.toDouble(),
      hardValue: (row['starter_hard_value'] as num?)?.toDouble(),
      minimumWeight: (row['starter_minimum_weight'] as num?)?.toDouble() ?? 0.0,
      maximumWeight: (row['starter_maximum_weight'] as num?)?.toDouble(),
      roundingIncrement:
          (row['starter_rounding_increment'] as num?)?.toDouble() ?? 5.0,
      unitMode: starterLoadUnitModeFromString(
        row['starter_unit_mode'] as String?,
      ),
      confidence: starterWeightConfidenceFromString(
        row['starter_confidence'] as String?,
      ),
      note: (row['starter_note'] as String?) ?? '',
    );
  }

  static List<ExerciseDefinition> _shallowDefinitions(
    List<Map<String, Object?>> rows,
  ) {
    return rows.map(_definitionFromRow).toList();
  }

  static Future<List<int>> _equipmentIdsForNames(
    Database db,
    List<String> equipmentNames,
  ) async {
    if (equipmentNames.isEmpty) return const <int>[];

    final rows = await db.query(
      'equipment',
      columns: ['id'],
      where: 'name IN (${sqlitePlaceholders(equipmentNames.length)})',
      whereArgs: equipmentNames,
    );
    return rows.map((row) => row['id'] as int).toList();
  }

  /// Batched detailed-definition lookup for a known subset of exercise IDs.
  static Future<List<ExerciseDefinition>> getExerciseDefinitionsDetailedByIds(
    Database db,
    List<int> definitionIds,
  ) async {
    if (definitionIds.isEmpty) return const <ExerciseDefinition>[];

    final uniqueDefinitionIds = definitionIds.toSet().toList();
    final defRows = <Map<String, Object?>>[];
    for (final chunk in sqliteChunks(uniqueDefinitionIds)) {
      final placeholders = sqlitePlaceholders(chunk.length);
      defRows.addAll(
        await db.rawQuery('''
            SELECT ed.*, primary_equipment.name AS equipment_name
            FROM exercise_definitions ed
            LEFT JOIN equipment primary_equipment
              ON primary_equipment.id = ed.equipment_id
            WHERE ed.id IN ($placeholders)
            ORDER BY ed.name
          ''', chunk),
      );
    }
    if (defRows.isEmpty) return const <ExerciseDefinition>[];
    defRows.sort(
      (a, b) => (a['name'] as String).compareTo(b['name'] as String),
    );

    final selectedIds = defRows.map((row) => row['id'] as int).toList();
    final equipmentRows = <Map<String, Object?>>[];
    final bodyPartRows = <Map<String, Object?>>[];
    final muscleRows = <Map<String, Object?>>[];

    for (final chunk in sqliteChunks(selectedIds)) {
      final placeholders = sqlitePlaceholders(chunk.length);
      final equipmentRowsFuture = db.rawQuery('''
        SELECT
          ee.exercise_id AS exercise_id,
          e.id AS equipment_id,
          e.name AS equipment_name
        FROM exercise_equipment ee
        JOIN equipment e ON e.id = ee.equipment_id
        WHERE ee.exercise_id IN ($placeholders)
        ORDER BY ee.exercise_id, e.name
      ''', chunk);
      final bodyPartRowsFuture = db.rawQuery('''
        SELECT
          eb.exercise_id AS exercise_id,
          b.id AS bodypart_id,
          b.name AS bodypart_name
        FROM exercise_bodypart eb
        JOIN bodypart b ON b.id = eb.bodypart_id
        WHERE eb.exercise_id IN ($placeholders)
        ORDER BY eb.exercise_id, b.name
      ''', chunk);
      final muscleRowsFuture = db.rawQuery('''
        SELECT
          em.exercise_id AS exercise_id,
          m.id AS muscle_id,
          m.name AS muscle_name,
          em.rank AS rank
        FROM exercise_muscle em
        JOIN muscles m ON m.id = em.muscle_id
        WHERE em.exercise_id IN ($placeholders)
        ORDER BY em.exercise_id, em.rank, m.name
      ''', chunk);

      equipmentRows.addAll(await equipmentRowsFuture);
      bodyPartRows.addAll(await bodyPartRowsFuture);
      muscleRows.addAll(await muscleRowsFuture);
    }

    return _hydrateDefinitions(
      defRows: defRows,
      equipmentRows: equipmentRows,
      bodyPartRows: bodyPartRows,
      muscleRows: muscleRows,
    );
  }

  /// Retrieves a shallow list of all exercise definition rows.
  ///
  /// - [db]: Open database instance.
  ///
  /// Returns list of maps with keys directly from the table (no joins).
  static Future<List<Map<String, dynamic>>> getAllExercisesRaw(Database db) {
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
    final eqIds = await _equipmentIdsForNames(db, equipmentNames);
    if (eqIds.isEmpty) return [];

    final defRows = await db.query(
      'exercise_definitions',
      where: 'equipment_id IN (${sqlitePlaceholders(eqIds.length)})',
      whereArgs: eqIds,
      orderBy: 'name',
    );
    return _shallowDefinitions(defRows);
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
    final eqIds = await _equipmentIdsForNames(db, equipmentNames);

    // build WHERE
    final whereClauses = <String>[];
    final args = <Object?>[];
    if (eqIds.isNotEmpty) {
      whereClauses.add('equipment_id IN (${sqlitePlaceholders(eqIds.length)})');
      args.addAll(eqIds);
    }
    if (includeNone) whereClauses.add('equipment_id IS NULL');
    if (whereClauses.isEmpty) {
      return getAllExerciseDefinitionsDetailedBatched(db);
    }

    final defRows = await db.query(
      'exercise_definitions',
      where: whereClauses.join(' OR '),
      whereArgs: args,
      orderBy: 'name',
    );
    return _shallowDefinitions(defRows);
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
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) async {
    // Resolve equipment → IDs
    List<int> equipmentIds = [];
    if (equipmentNames != null && equipmentNames.isNotEmpty) {
      equipmentIds = await _equipmentIdsForNames(db, equipmentNames);
    }

    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (equipmentIds.isNotEmpty) {
      whereClauses.add(
        'ed.equipment_id IN (${sqlitePlaceholders(equipmentIds.length)})',
      );
      whereArgs.addAll(equipmentIds);
    }
    if (bodypartIds != null && bodypartIds.isNotEmpty) {
      whereClauses.add(
        'eb.bodypart_id IN (${sqlitePlaceholders(bodypartIds.length)})',
      );
      whereArgs.addAll(bodypartIds);
    }
    if (muscleIds != null && muscleIds.isNotEmpty) {
      whereClauses.add(
        'em.muscle_id IN (${sqlitePlaceholders(muscleIds.length)})',
      );
      whereArgs.addAll(muscleIds);
    }

    final sql =
        StringBuffer()
          ..write('''
        SELECT DISTINCT
          ed.id,
          ed.name,
          ed.equipment_id,
          primary_equipment.name AS equipment_name,
          ed.rating,
          ed.use_manual_bodyparts,
          ed.multiply_by_rating,
          ed.starter_load_type,
          ed.starter_easy_value,
          ed.starter_medium_value,
          ed.starter_hard_value,
          ed.starter_minimum_weight,
          ed.starter_maximum_weight,
          ed.starter_rounding_increment,
          ed.starter_unit_mode,
          ed.starter_confidence,
          ed.starter_note
          FROM exercise_definitions ed
          LEFT JOIN equipment primary_equipment ON primary_equipment.id = ed.equipment_id
      ''')
          ..write(
            bodypartIds != null && bodypartIds.isNotEmpty
                ? 'JOIN exercise_bodypart eb ON eb.exercise_id = ed.id '
                : '',
          )
          ..write(
            muscleIds != null && muscleIds.isNotEmpty
                ? 'JOIN exercise_muscle em ON em.exercise_id = ed.id '
                : '',
          )
          ..write(
            whereClauses.isNotEmpty
                ? 'WHERE ${whereClauses.join(' AND ')} '
                : '',
          )
          ..write('ORDER BY ed.name');

    final rows = await db.rawQuery(sql.toString(), whereArgs);
    return _shallowDefinitions(rows);
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
    await db.insert('exercise_definitions', {
      'name': name,
      'equipment_id': eqId,
      'rating': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

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
    final rows = await db.rawQuery(
      '''
      SELECT 
        ed.name            AS name,
        e.name            AS equipment_name
      FROM exercise_definitions ed
      LEFT JOIN equipment e ON ed.equipment_id = e.id
      WHERE ed.id = ?
    ''',
      [defId],
    );

    if (rows.isEmpty) {
      throw Exception('Definition $defId not found');
    }
    final row = rows.first;
    return {
      'name': row['name'] as String,
      'equipmentName': row['equipment_name'] as String?,
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
        'multiply_by_rating': def.multiplyByRating ? 1 : 0,

        // NEW: persist notes columns
        'setup_notes': def.setupNotes,
        'execution_notes': def.executionNotes,
        'tips_notes': def.tipsNotes,
        'starter_load_type':
            def.starterLoadProfile == null
                ? null
                : starterLoadTypeToString(def.starterLoadProfile!.type),
        'starter_easy_value': def.starterLoadProfile?.easyValue,
        'starter_medium_value': def.starterLoadProfile?.mediumValue,
        'starter_hard_value': def.starterLoadProfile?.hardValue,
        'starter_minimum_weight': def.starterLoadProfile?.minimumWeight ?? 0.0,
        'starter_maximum_weight': def.starterLoadProfile?.maximumWeight,
        'starter_rounding_increment':
            def.starterLoadProfile?.roundingIncrement ?? 5.0,
        'starter_unit_mode': starterLoadUnitModeToString(
          def.starterLoadProfile?.unitMode ?? StarterLoadUnitMode.total,
        ),
        'starter_confidence': starterWeightConfidenceToString(
          def.starterLoadProfile?.confidence ?? StarterWeightConfidence.medium,
        ),
        'starter_note': def.starterLoadProfile?.note ?? '',
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
  static Future<int> deleteExerciseDefinition(Database db, int defId) {
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
    return _shallowDefinitions(rows);
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
    return _shallowDefinitions(rows);
  }

  /// Fetches a single ExerciseDefinition with all joins populated.
  static Future<ExerciseDefinition?> getExerciseDefinitionById(
    Database db,
    int defId,
  ) async {
    final definitions = await getExerciseDefinitionsDetailedByIds(db, [defId]);
    return definitions.isEmpty ? null : definitions.first;
  }

  /// Inserts a muscle↔exercise link at a given rank.
  static Future<int> insertExerciseMuscleMapping(
    Database db,
    int exerciseId,
    int muscleId,
    int rank,
  ) {
    return db.insert('exercise_muscle', {
      'exercise_id': exerciseId,
      'muscle_id': muscleId,
      'rank': rank,
    });
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
    return db.insert('exercise_bodypart', {
      'exercise_id': exerciseId,
      'bodypart_id': bodypartId,
    });
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
    return db.insert('exercise_equipment', {
      'exercise_id': exerciseId,
      'equipment_id': equipmentId,
    });
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
  static Future<bool> getMultiplyByRating(Database db, int defId) async {
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
  static Future<int> setMultiplyByRating(Database db, int defId, bool enabled) {
    return db.update(
      'exercise_definitions',
      {'multiply_by_rating': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [defId],
    );
  }
}
