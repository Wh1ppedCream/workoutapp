import 'package:sqflite/sqflite.dart';

import '../models/models.dart';
import '../utils/weight_unit_formatter.dart';
import 'lookup_dao.dart';

/// Database operations for Measurement without owning a connection.
class MeasurementDao {
  const MeasurementDao(this.db);

  final DatabaseExecutor db;

  /// Fetch all measurement definitions.
  Future<List<Map<String, dynamic>>> fetchMeasurementDefinitions() async {
    return LookupDao.getMeasurementDefinitions(db);
  }

  Future<void> ensureDefaultMeasurementDefinitions() async {
    await LookupDao.ensureDefaultMeasurementDefinitions(db);
  }

  Future<int> insertMeasurementDefinition({
    required String name,
    required MeasurementType type,
  }) async {
    return LookupDao.insertMeasurementDefinition(db, name: name, type: type);
  }

  Future<int?> fetchMeasurementDefinitionId(String name) async {
    return LookupDao.getMeasurementDefinitionId(db, name);
  }

  /// Insert a new measurement instance.
  Future<int> insertMeasurement(
    int defId,
    DateTime timestamp,
    double value,
    String unit,
    String? note,
    MeasurementContext? context,
  ) async {
    return LookupDao.insertMeasurement(
      db,
      defId,
      timestamp,
      value,
      unit,
      note,
      context,
    );
  }

  /// Fetch all measurements for a definition.
  Future<List<Map<String, dynamic>>> fetchMeasurementsRaw(int defId) async {
    return LookupDao.getMeasurementsForDefinition(db, defId);
  }

  Future<List<Measurement>> fetchClassMeasurementsForDefinition(
    int defId,
  ) async {
    final rows = await fetchMeasurementsRaw(defId);
    return rows
        .map(
          (r) => Measurement(
            id: r['id'] as int,
            defId: r['def_id'] as int,
            timestamp: TemporalSemantics.readLocalDateTime(
              epochMilliseconds: r['measured_at_ms'],
              legacyIso: r['timestamp'],
            ),
            calendarDayKey: TemporalSemantics.readCalendarDay(
              calendarDay: r['measured_on'],
              legacyIso: r['timestamp'],
              epochMilliseconds: r['measured_at_ms'],
            ).storageKey,
            value: (r['value'] as num).toDouble(),
            unit: r['unit'] as String,
            note: r['note'] as String?,
            context: _measurementContextFromValue(r['context'] as String?),
          ),
        )
        .toList();
  }

  Future<double?> fetchLatestBodyWeightLbs() async {
    final rows = await db.rawQuery(
      '''
      SELECT m.value, m.unit
        FROM measurements m
        JOIN measurement_definitions md ON md.id = m.def_id
       WHERE md.type = ?
       ORDER BY m.measured_at_ms DESC, m.id DESC
       LIMIT 1
    ''',
      [MeasurementType.BodyWeight.name],
    );

    if (rows.isEmpty) return null;
    final value = (rows.first['value'] as num?)?.toDouble();
    if (value == null || value <= 0) return null;

    final unit = ((rows.first['unit'] as String?) ?? 'lbs')
        .trim()
        .toLowerCase();
    if (unit == 'kg' ||
        unit == 'kgs' ||
        unit == 'kilogram' ||
        unit == 'kilograms') {
      return WeightUnitFormatter.toPounds(value, WeightUnit.kilograms);
    }
    if (unit == 'lb' || unit == 'lbs' || unit == 'pound' || unit == 'pounds') {
      return value;
    }
    return null;
  }

  /// Returns only the definitions that have at least one measurement recorded.
  Future<List<Map<String, dynamic>>>
  fetchUsedMeasurementDefinitionsRaw() async {
    return LookupDao.getUsedMeasurementDefinitions(db);
  }

  MeasurementDefinition _measurementDefinitionFromRow(
    Map<String, dynamic> row,
  ) {
    return MeasurementDefinition(
      id: row['id'] as int,
      name: row['name'] as String,
      type: MeasurementType.values.firstWhere(
        (mt) => mt.name == (row['type'] as String),
        orElse: () => MeasurementType.Custom,
      ),
    );
  }

  Future<List<MeasurementDefinition>> fetchClassMeasurementDefinitions() async {
    final raw = await fetchMeasurementDefinitions();
    return raw.map(_measurementDefinitionFromRow).toList();
  }

  Future<List<MeasurementDefinition>>
  fetchUsedClassMeasurementDefinitions() async {
    final raw = await fetchUsedMeasurementDefinitionsRaw();
    return raw.map(_measurementDefinitionFromRow).toList();
  }

  Future<Map<String, dynamic>?> fetchMeasurementById(int id) async {
    return LookupDao.getMeasurementById(db, id);
  }

  Future<void> updateMeasurement({
    required int measurementId,
    required DateTime timestamp,
    required double value,
    required String unit,
    String? note,
    MeasurementContext? context,
  }) async {
    await LookupDao.updateMeasurement(
      db: db,
      measurementId: measurementId,
      timestamp: timestamp,
      value: value,
      unit: unit,
      note: note,
      context: context,
    );
  }

  MeasurementContext? _measurementContextFromValue(String? value) {
    for (final context in MeasurementContext.values) {
      if (context.name == value) return context;
    }
    return null;
  }

  Future<void> deleteMeasurement(int measurementId) async {
    await LookupDao.deleteMeasurement(db, measurementId);
  }
}
