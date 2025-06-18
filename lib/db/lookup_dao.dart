// File: lib/db/lookup_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

/// Encapsulates measurements, equipment/bodypart/muscle lookups, and stretches.
class LookupDao {
  /// Fetch all measurement definitions.
  static Future<List<Map<String, dynamic>>> getMeasurementDefinitions(
    Database db,
  ) {
    return db.query(
      'measurement_definitions',
      orderBy: 'name',
    );
  }

  /// Insert a new measurement instance.
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

  /// Fetch all measurements for a given definition.
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

  /// Returns only the definitions that have at least one measurement recorded.
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

  /// Fetch all equipment names.
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

  /// Fetch all body-part IDs and names.
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

  /// Fetch stretches by an optional bodypart ID (or all if null).
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
      final id   = r['id'] as int;
      final nm   = r['name'] as String;
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
        id: id, name: nm, description: desc, bodyParts: bpList,
      ));
    }
    return result;
  }

  /// Fetch all muscle names.
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

  /// Fetch all muscles as full [Muscle] models.
  static Future<List<Muscle>> getAllMuscles(Database db) async {
    final rows = await db.query(
      'muscles',
      orderBy: 'name',
    );
    return rows.map((r) {
      return Muscle(
        id:   r['id']   as int,
        name: r['name'] as String,
      );
    }).toList();
  }

  /// Returns the name of a stretch definition by its ID.
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

  /// Returns the ID of the measurement_definition with the given name,
  /// or null if none exists.
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

/// Fetch a single measurement by its ID (or null if none).
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


  /// Insert a new equipment.
  static Future<int> insertEquipment(Database db, String name) {
    return db.insert('equipment', {'name': name});
  }

  /// Update an existing equipment.
  static Future<int> updateEquipment(Database db, int id, String name) {
    return db.update(
      'equipment',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete an equipment by ID.
  static Future<int> deleteEquipment(Database db, int id) {
    return db.delete(
      'equipment',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Fetch all equipment as full [Equipment] models.
  static Future<List<Equipment>> getAllEquipment(Database db) async {
    final rows = await db.query('equipment', orderBy: 'name');
   return rows.map((r) => Equipment(r['id'] as int, r['name'] as String)).toList();
  }

  /// Insert a new body part.
  static Future<int> insertBodyPart(Database db, String name) {
    return db.insert('bodypart', {'name': name});
  }

  /// Update an existing body part.

  static Future<int> updateBodyPart(Database db, int id, String name) {
    return db.update(
      'bodypart',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a body part by ID.
  static Future<int> deleteBodyPart(Database db, int id) {
    return db.delete(
      'bodypart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Insert a new muscle.
  static Future<int> insertMuscle(Database db, String name) {
    return db.insert('muscles', {'name': name});
  }

  /// Update an existing muscle.
  static Future<int> updateMuscle(Database db, int id, String name) {
    return db.update(
      'muscles',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a muscle by ID.
  static Future<int> deleteMuscle(Database db, int id) {
    return db.delete(
      'muscles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
