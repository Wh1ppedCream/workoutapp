import 'dart:convert';

import 'package:sqflite/sqflite.dart';

/// Reconciles the shipped exercise catalog without changing local row IDs.
///
/// Catalog IDs are durable public-content identities. Database IDs remain local
/// implementation details because workouts, plans, records, and media all
/// reference them directly.
class ExerciseCatalog {
  const ExerciseCatalog._();

  static Future<void> synchronize(
    Database db, {
    required String sourceJson,
  }) async {
    final catalog = _CatalogDocument.parse(sourceJson);

    await db.transaction((txn) async {
      final state = await txn.query(
        'exercise_catalog_state',
        where: 'singleton = 1',
        limit: 1,
      );
      final installedRevision =
          state.isEmpty ? null : state.single['revision'] as int;
      if (installedRevision != null && installedRevision >= catalog.revision) {
        return;
      }

      await _seedLookups(txn, catalog.exercises);
      final equipmentIds = await _lookupIds(txn, 'equipment');
      final bodyPartIds = await _lookupIds(txn, 'bodypart');
      final muscleIds = await _lookupIds(txn, 'muscles');
      final catalogIds = <String>[];

      for (final exercise in catalog.exercises) {
        final definitionId = await _upsertDefinition(
          txn,
          exercise,
          equipmentIds: equipmentIds,
          allowLegacyIdentityMatching: installedRevision == null,
        );
        catalogIds.add(exercise.catalogId);
        await _replaceRelationships(
          txn,
          definitionId: definitionId,
          exercise: exercise,
          equipmentIds: equipmentIds,
          bodyPartIds: bodyPartIds,
          muscleIds: muscleIds,
        );
        await _replaceAliases(txn, definitionId, exercise.aliases);
      }

      final placeholders = List.filled(catalogIds.length, '?').join(', ');
      await txn.update(
        'exercise_definitions',
        {'catalog_status': 'retired'},
        where:
            'catalog_id IS NOT NULL '
            'AND catalog_id NOT IN ($placeholders)',
        whereArgs: catalogIds,
      );
      await txn.insert('exercise_catalog_state', {
        'singleton': 1,
        'revision': catalog.revision,
        'synced_at': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  static Future<void> _seedLookups(
    Transaction txn,
    List<_CatalogExercise> exercises,
  ) async {
    for (final exercise in exercises) {
      for (final name in exercise.equipment) {
        await txn.insert('equipment', {
          'name': name,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      for (final name in exercise.bodyParts) {
        await txn.insert('bodypart', {
          'name': name,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      for (final muscle in exercise.muscles) {
        await txn.insert('muscles', {
          'name': muscle.name,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
  }

  static Future<Map<String, int>> _lookupIds(
    Transaction txn,
    String table,
  ) async {
    final rows = await txn.query(table, columns: ['id', 'name']);
    return {for (final row in rows) row['name'] as String: row['id'] as int};
  }

  static Future<int> _upsertDefinition(
    Transaction txn,
    _CatalogExercise exercise, {
    required Map<String, int> equipmentIds,
    required bool allowLegacyIdentityMatching,
  }) async {
    final primaryEquipment =
        exercise.equipment.isEmpty
            ? null
            : equipmentIds[exercise.equipment.first];
    if (exercise.equipment.isNotEmpty && primaryEquipment == null) {
      throw FormatException(
        'Unknown equipment "${exercise.equipment.first}" for ${exercise.name}.',
      );
    }

    var rows = await txn.query(
      'exercise_definitions',
      columns: ['id'],
      where: 'catalog_id = ?',
      whereArgs: [exercise.catalogId],
      limit: 1,
    );
    if (rows.isEmpty && allowLegacyIdentityMatching) {
      rows = await txn.query(
        'exercise_definitions',
        columns: ['id'],
        where: 'name = ? AND equipment_id IS ?',
        whereArgs: [exercise.name, primaryEquipment],
        limit: 1,
      );
    }
    // This one-time fallback assigns catalog IDs to databases seeded before
    // catalog IDs existed, including definitions subsequently renamed here.
    if (rows.isEmpty && allowLegacyIdentityMatching) {
      rows = await txn.query(
        'exercise_definitions',
        columns: ['id'],
        where: 'id = ? AND catalog_id IS NULL',
        whereArgs: [exercise.legacyMediaId],
        limit: 1,
      );
    }

    final values = exercise.definitionValues(primaryEquipment);
    if (rows.isEmpty) {
      return txn.insert('exercise_definitions', values);
    }

    final id = rows.single['id'] as int;
    await txn.update(
      'exercise_definitions',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
    return id;
  }

  static Future<void> _replaceRelationships(
    Transaction txn, {
    required int definitionId,
    required _CatalogExercise exercise,
    required Map<String, int> equipmentIds,
    required Map<String, int> bodyPartIds,
    required Map<String, int> muscleIds,
  }) async {
    await txn.delete(
      'exercise_equipment',
      where: 'exercise_id = ?',
      whereArgs: [definitionId],
    );
    await txn.delete(
      'exercise_bodypart',
      where: 'exercise_id = ?',
      whereArgs: [definitionId],
    );
    await txn.delete(
      'exercise_muscle',
      where: 'exercise_id = ?',
      whereArgs: [definitionId],
    );

    for (final name in exercise.equipment) {
      final id = equipmentIds[name];
      if (id == null) throw FormatException('Unknown equipment "$name".');
      await txn.insert('exercise_equipment', {
        'exercise_id': definitionId,
        'equipment_id': id,
      });
    }
    for (final name in exercise.bodyParts) {
      final id = bodyPartIds[name];
      if (id == null) throw FormatException('Unknown body part "$name".');
      await txn.insert('exercise_bodypart', {
        'exercise_id': definitionId,
        'bodypart_id': id,
      });
    }
    for (final muscle in exercise.muscles) {
      final id = muscleIds[muscle.name];
      if (id == null) {
        throw FormatException('Unknown muscle "${muscle.name}".');
      }
      await txn.insert('exercise_muscle', {
        'exercise_id': definitionId,
        'muscle_id': id,
        'rank': muscle.rank,
      });
    }
  }

  static Future<void> _replaceAliases(
    Transaction txn,
    int definitionId,
    List<String> aliases,
  ) async {
    await txn.delete(
      'exercise_definition_aliases',
      where: 'exercise_def_id = ?',
      whereArgs: [definitionId],
    );
    for (final alias in aliases) {
      await txn.insert('exercise_definition_aliases', {
        'exercise_def_id': definitionId,
        'alias': alias,
      });
    }
  }
}

class _CatalogDocument {
  final int revision;
  final List<_CatalogExercise> exercises;

  const _CatalogDocument({required this.revision, required this.exercises});

  factory _CatalogDocument.parse(String sourceJson) {
    final decoded = jsonDecode(sourceJson);
    if (decoded is! Map) {
      throw const FormatException(
        'exercises.json must contain a catalog object with revision and exercises.',
      );
    }
    final revision = (decoded['revision'] as num?)?.toInt();
    final rawExercises = decoded['exercises'];
    if (revision == null || revision < 1 || rawExercises is! List) {
      throw const FormatException(
        'exercises.json needs a positive revision and an exercises list.',
      );
    }
    final exercises = rawExercises
        .whereType<Map>()
        .map((raw) => _CatalogExercise.parse(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    if (exercises.length != rawExercises.length || exercises.isEmpty) {
      throw const FormatException('Every catalog exercise must be an object.');
    }
    final ids = exercises.map((exercise) => exercise.catalogId).toSet();
    final legacyIds =
        exercises.map((exercise) => exercise.legacyMediaId).toSet();
    if (ids.length != exercises.length ||
        legacyIds.length != exercises.length) {
      throw const FormatException(
        'Catalog IDs and legacy media IDs must both be unique.',
      );
    }
    final names = {
      for (final exercise in exercises) exercise.name.toLowerCase(),
    };
    if (names.length != exercises.length) {
      throw const FormatException(
        'Catalog exercise names must be unique ignoring case.',
      );
    }
    final aliasOwners = <String, String>{};
    for (final exercise in exercises) {
      for (final alias in exercise.aliases) {
        final normalizedAlias = alias.toLowerCase();
        if (normalizedAlias == exercise.name.toLowerCase() ||
            names.contains(normalizedAlias)) {
          throw FormatException(
            'Alias "$alias" conflicts with a catalog exercise name.',
          );
        }
        final previousOwner = aliasOwners[normalizedAlias];
        if (previousOwner != null && previousOwner != exercise.catalogId) {
          throw FormatException(
            'Alias "$alias" is assigned to multiple catalog exercises.',
          );
        }
        aliasOwners[normalizedAlias] = exercise.catalogId;
      }
    }
    return _CatalogDocument(revision: revision, exercises: exercises);
  }
}

class _CatalogExercise {
  final String catalogId;
  final int legacyMediaId;
  final String name;
  final List<String> aliases;
  final List<String> equipment;
  final List<String> bodyParts;
  final List<_CatalogMuscle> muscles;
  final Map<String, dynamic> raw;

  const _CatalogExercise({
    required this.catalogId,
    required this.legacyMediaId,
    required this.name,
    required this.aliases,
    required this.equipment,
    required this.bodyParts,
    required this.muscles,
    required this.raw,
  });

  factory _CatalogExercise.parse(Map<String, dynamic> raw) {
    String requiredText(String key) {
      final value = raw[key]?.toString().trim();
      if (value == null || value.isEmpty) {
        throw FormatException('Exercise is missing $key.');
      }
      return value;
    }

    List<String> textList(String key) => (raw[key] as List? ?? const [])
        .map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final legacyMediaId = (raw['legacyMediaId'] as num?)?.toInt();
    if (legacyMediaId == null || legacyMediaId < 1) {
      throw FormatException(
        'Exercise ${requiredText('name')} has no legacyMediaId.',
      );
    }
    final muscles = <_CatalogMuscle>[];
    for (final value in raw['muscles'] as List? ?? const []) {
      if (value is! Map) {
        throw const FormatException('Every muscle must be an object.');
      }
      final map = Map<String, dynamic>.from(value);
      final muscleName = map['name']?.toString().trim();
      final rank = (map['rank'] as num?)?.toInt();
      if (muscleName == null ||
          muscleName.isEmpty ||
          rank == null ||
          rank < 1) {
        throw const FormatException(
          'Each muscle needs a name and positive rank.',
        );
      }
      muscles.add(_CatalogMuscle(muscleName, rank));
    }
    final ranks = muscles.map((muscle) => muscle.rank).toSet();
    if (ranks.length != muscles.length) {
      throw FormatException(
        'Exercise ${requiredText('name')} repeats a muscle rank.',
      );
    }
    final muscleNames =
        muscles.map((muscle) => muscle.name.toLowerCase()).toSet();
    if (muscleNames.length != muscles.length) {
      throw FormatException(
        'Exercise ${requiredText('name')} repeats a muscle relationship.',
      );
    }
    final catalogId = requiredText('catalogId');
    if (!RegExp(r'^tonos\.exercise\.\d{4}$').hasMatch(catalogId)) {
      throw FormatException(
        'Exercise ${requiredText('name')} has an invalid catalogId.',
      );
    }
    return _CatalogExercise(
      catalogId: catalogId,
      legacyMediaId: legacyMediaId,
      name: requiredText('name'),
      aliases: textList('aliases'),
      equipment: textList('equipment'),
      bodyParts: textList('bodyparts'),
      muscles: muscles,
      raw: raw,
    );
  }

  Map<String, Object?> definitionValues(int? primaryEquipmentId) {
    final starter = raw['starterLoadProfile'] as Map?;
    Object? number(String key) {
      final value = starter?[key];
      return value is num ? value.toDouble() : null;
    }

    return {
      'name': name,
      'equipment_id': primaryEquipmentId,
      'rating': (raw['rating'] as num?)?.toInt() ?? 0,
      'use_manual_bodyparts': raw['useManualBodyparts'] == true ? 1 : 0,
      'use_manual_muscles': raw['useManualMuscles'] == true ? 1 : 0,
      'setup_notes': raw['setupNotes'] as String? ?? '',
      'execution_notes': raw['executionNotes'] as String? ?? '',
      'tips_notes': raw['tipsNotes'] as String? ?? '',
      'multiply_by_rating': raw['multiplyByRating'] == true ? 1 : 0,
      'starter_load_type': starter?['type'] as String?,
      'starter_easy_value': number('easy'),
      'starter_medium_value': number('medium'),
      'starter_hard_value': number('hard'),
      'starter_minimum_weight': number('minimumWeight') ?? 0.0,
      'starter_maximum_weight': number('maximumWeight'),
      'starter_rounding_increment': number('roundingIncrement') ?? 5.0,
      'starter_unit_mode': starter?['unitMode'] as String? ?? 'total',
      'starter_confidence': starter?['confidence'] as String? ?? 'medium',
      'starter_note': starter?['note'] as String? ?? '',
      'catalog_id': catalogId,
      'legacy_media_id': legacyMediaId,
      'catalog_status': 'active',
    };
  }
}

class _CatalogMuscle {
  final String name;
  final int rank;

  const _CatalogMuscle(this.name, this.rank);
}
