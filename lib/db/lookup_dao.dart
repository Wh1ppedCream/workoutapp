// File: lib/db/lookup_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

/// Data Access Object for measurement records and lookup tables.
///
/// Encapsulates CRUD operations for:
///  • measurement definitions & measurements
///  • equipment, bodypart, and muscle lookup tables
///  • stretch definitions
class LookupDao {
  /// Retrieves all measurement definitions.
  ///
  /// - [db]: Open SQLite database instance.
  ///
  /// Returns a list of maps containing keys: `id`, `name`, `type`.
  static Future<List<Map<String, dynamic>>> getMeasurementDefinitions(
    Database db,
  ) {
    return db.query(
      'measurement_definitions',
      orderBy: 'name',
    );
  }

  /// Inserts a new measurement record tied to a definition.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [defId]: ID of the measurement definition.
  /// - [ts]: Timestamp of the measurement.
  /// - [value]: Numeric measurement value.
  /// - [unit]: Measurement unit string (e.g., "kg").
  /// - [note]: Optional note text.
  ///
  /// Returns the new measurement row ID.
  static Future<int> insertMeasurement(
    Database db,
    int defId,
    DateTime ts,
    double value,
    String unit,
    String? note,
  ) {
    return db.insert(
      'measurements',
      {
        'def_id':    defId,
        'timestamp': ts.toIso8601String(),
        'value':     value,
        'unit':      unit,
        'note':      note,
      },
    );
  }

  /// Retrieves all measurements for a given definition.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [defId]: Measurement definition ID to filter by.
  ///
  /// Returns a list of maps ordered by timestamp descending.
  static Future<List<Map<String, dynamic>>> getMeasurementsForDefinition(
    Database db,
    int defId,
  ) {
    return db.query(
      'measurements',
      where: 'def_id = ?',
      whereArgs: [defId],
      orderBy: 'timestamp DESC',
    );
  }

  /// Retrieves only measurement definitions that have at least one entry.
  ///
  /// - [db]: Open SQLite database instance.
  ///
  /// Returns a list of maps containing keys: `id`, `name`, `type`.
  static Future<List<Map<String, dynamic>>> getUsedMeasurementDefinitions(
    Database db,
  ) {
    return db.rawQuery('''
      SELECT md.id, md.name, md.type
        FROM measurement_definitions md
        JOIN measurements m ON m.def_id = md.id
       GROUP BY md.id
       ORDER BY md.name
    ''');
  }

  /// Retrieves all equipment names.
  ///
  /// - [db]: Open SQLite database instance.
  ///
  /// Returns a list of equipment name strings.
  static Future<List<String>> getAllEquipmentNames(
    Database db,
  ) async {
    final rows = await db.query(
      'equipment',
      columns: ['name'],
      orderBy: 'name',
    );
    return rows.map((r) => r['name'] as String).toList();
  }

  /// Retrieves all body part lookup entries as [BodyPart] models.
  ///
  /// - [db]: Open SQLite database instance.
  ///
  /// Returns a list of [BodyPart] objects.
  static Future<List<BodyPart>> getAllBodyParts(
    Database db,
  ) async {
    final rows = await db.query(
      'bodypart',
      orderBy: 'name',
    );
    return rows
        .map((r) => BodyPart(r['id'] as int, r['name'] as String))
        .toList();
  }

  /// Retrieves stretch definitions, optionally filtered by body part.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [bodypartId]: If provided, filters stretches linked to this ID.
  ///
  /// Returns a list of [StretchDefinition] objects.
  static Future<List<StretchDefinition>> getStretches(
    Database db, [
    int? bodypartId,
  ]) async {
    final stretchRows = bodypartId == null
        ? await db.query('stretch_definitions', orderBy: 'name')
        : await db.rawQuery('''
            SELECT sd.id, sd.name, sd.description
              FROM stretch_definitions sd
              JOIN stretch_bodypart sb ON sb.stretch_id = sd.id
             WHERE sb.bodypart_id = ?
             ORDER BY sd.name
          ''', [bodypartId]);

    final List<StretchDefinition> result = [];
    for (final r in stretchRows) {
      final id = r['id'] as int;
      final nm = r['name'] as String;
      final desc = (r['description'] as String?) ?? '';

      final bpRows = await db.rawQuery('''
        SELECT b.id, b.name
          FROM bodypart b
          JOIN stretch_bodypart sb ON sb.bodypart_id = b.id
         WHERE sb.stretch_id = ?
         ORDER BY b.name
      ''', [id]);
      final bpList = bpRows
          .map((b) => BodyPart(b['id'] as int, b['name'] as String))
          .toList();

      result.add(StretchDefinition(
        id: id,
        name: nm,
        description: desc,
        bodyParts: bpList,
      ));
    }
    return result;
  }

  /// Retrieves all muscle names.
  ///
  /// - [db]: Open SQLite database instance.
  ///
  /// Returns a list of muscle name strings.
  static Future<List<String>> getAllMuscleNames(
    Database db,
  ) async {
    final rows = await db.query(
      'muscles',
      columns: ['name'],
      orderBy: 'name',
    );
    return rows.map((r) => r['name'] as String).toList();
  }

  /// Retrieves all muscles as [Muscle] models.
  ///
  /// - [db]: Open SQLite database instance.
  ///
  /// Returns a list of [Muscle] objects.
  static Future<List<Muscle>> getAllMuscles(Database db) async {
    final rows = await db.query(
      'muscles',
      orderBy: 'name',
    );
    return rows.map((r) => Muscle(id: r['id'] as int, name: r['name'] as String)).toList();
  }

  /// Retrieves the name of a stretch definition by its ID.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [stretchId]: ID of the stretch definition.
  ///
  /// Returns the stretch name or null if not found.
  static Future<String?> getStretchDefinitionNameById(
    Database db,
    int stretchId,
  ) async {
    final rows = await db.query(
      'stretch_definitions',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [stretchId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['name'] as String;
  }

  /// Retrieves the ID of a measurement definition by name.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [name]: Definition name to match.
  ///
  /// Returns the definition ID or null if none exists.
  static Future<int?> getMeasurementDefinitionId(
    Database db,
    String name,
  ) async {
    final rows = await db.query(
      'measurement_definitions',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int;
  }

  /// Retrieves a single measurement by its ID.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [measurementId]: ID of the measurement to fetch.
  ///
  /// Returns a map of column values or null if not found.
  static Future<Map<String, dynamic>?> getMeasurementById(
    Database db,
    int measurementId,
  ) async {
    final rows = await db.query(
      'measurements',
      where: 'id = ?',
      whereArgs: [measurementId],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Updates an existing measurement record.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [measurementId]: ID of the measurement to update.
  /// - [timestamp]: New timestamp value.
  /// - [value]: New measurement value.
  /// - [unit]: New unit string.
  /// - [note]: Optional updated note.
  ///
  /// Returns number of rows affected.
  static Future<int> updateMeasurement({
    required Database db,
    required int measurementId,
    required DateTime timestamp,
    required double value,
    required String unit,
    String? note,
  }) {
    return db.update(
      'measurements',
      {
        'timestamp': timestamp.toIso8601String(),
        'value':     value,
        'unit':      unit,
        'note':      note,
      },
      where: 'id = ?',
      whereArgs: [measurementId],
    );
  }

  /// Deletes a measurement by its ID.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [measurementId]: ID of the measurement to delete.
  ///
  /// Returns number of rows deleted.
  static Future<int> deleteMeasurement(
    Database db,
    int measurementId,
  ) {
    return db.delete(
      'measurements',
      where: 'id = ?',
      whereArgs: [measurementId],
    );
  }

  /// Inserts a new equipment lookup entry.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [name]: Equipment name to insert.
  ///
  /// Returns the new equipment row ID.
  static Future<int> insertEquipment(Database db, String name) {
    return db.insert('equipment', {'name': name});
  }

  /// Updates an existing equipment lookup entry.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [id]: Equipment row ID to update.
  /// - [name]: New equipment name.
  ///
  /// Returns number of rows affected.
  static Future<int> updateEquipment(Database db, int id, String name) {
    return db.update(
      'equipment',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes an equipment lookup entry by ID.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [id]: Equipment row ID to delete.
  ///
  /// Returns number of rows deleted.
  static Future<int> deleteEquipment(Database db, int id) {
    return db.delete(
      'equipment',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves all equipment as [Equipment] models.
  ///
  /// - [db]: Open SQLite database instance.
  ///
  /// Returns a list of [Equipment] objects.
  static Future<List<Equipment>> getAllEquipment(Database db) async {
    final rows = await db.query('equipment', orderBy: 'name');
    return rows.map((r) => Equipment(r['id'] as int, r['name'] as String)).toList();
  }

  /// Inserts a new body part lookup entry.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [name]: Body part name to insert.
  ///
  /// Returns the new body part row ID.
  static Future<int> insertBodyPart(Database db, String name) {
    return db.insert('bodypart', {'name': name});
  }

  /// Updates an existing body part lookup entry.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [id]: Body part row ID to update.
  /// - [name]: New body part name.
  ///
  /// Returns number of rows affected.
  static Future<int> updateBodyPart(Database db, int id, String name) {
    return db.update(
      'bodypart',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a body part lookup entry by ID.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [id]: Body part row ID to delete.
  ///
  /// Returns number of rows deleted.
  static Future<int> deleteBodyPart(Database db, int id) {
    return db.delete(
      'bodypart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Inserts a new muscle lookup entry.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [name]: Muscle name to insert.
  ///
  /// Returns the new muscle row ID.
  static Future<int> insertMuscle(Database db, String name) {
    return db.insert('muscles', {'name': name});
  }

  /// Updates an existing muscle lookup entry.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [id]: Muscle row ID to update.
  /// - [name]: New muscle name.
  ///
  /// Returns number of rows affected.
  static Future<int> updateMuscle(Database db, int id, String name) {
    return db.update(
      'muscles',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a muscle lookup entry by ID.
  ///
  /// - [db]: Open SQLite database instance.
  /// - [id]: Muscle row ID to delete.
  ///
  /// Returns number of rows deleted.
  static Future<int> deleteMuscle(Database db, int id) {
    return db.delete(
      'muscles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
