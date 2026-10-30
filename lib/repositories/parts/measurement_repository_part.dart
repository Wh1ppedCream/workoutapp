part of '../app_repository.dart';

/// Instance APIs for the measurement domain.
mixin _MeasurementRepositoryMethods on _RepositoryDependencies {
  Future<List<Map<String, dynamic>>> fetchMeasurementDefinitions() =>
      _dbHelper.fetchMeasurementDefinitions();

  Future<void> ensureDefaultMeasurementDefinitions() =>
      _dbHelper.ensureDefaultMeasurementDefinitions();

  Future<int> insertMeasurementDefinition({
    required String name,
    required MeasurementType type,
  }) => _dbHelper.insertMeasurementDefinition(name: name, type: type);

  Future<List<MeasurementDefinition>> fetchClassMeasurementDefinitions() =>
      _dbHelper.fetchClassMeasurementDefinitions();

  Future<int?> fetchMeasurementDefinitionId(String name) =>
      _dbHelper.fetchMeasurementDefinitionId(name);

  Future<int> insertMeasurement(
    int defId,
    DateTime timestamp,
    double value,
    String unit,
    String? note,
    MeasurementContext? context,
  ) =>
      _dbHelper.insertMeasurement(defId, timestamp, value, unit, note, context);

  Future<List<Map<String, dynamic>>> fetchMeasurementsForDefinition(
    int defId,
  ) => _dbHelper.fetchMeasurementsRaw(defId);

  Future<List<Measurement>> fetchClassMeasurementsForDefinition(int defId) =>
      _dbHelper.fetchClassMeasurementsForDefinition(defId);

  Future<double?> fetchLatestBodyWeightLbs() =>
      _dbHelper.fetchLatestBodyWeightLbs();

  Future<List<Map<String, dynamic>>> fetchUsedMeasurementDefinitions() =>
      _dbHelper.fetchUsedMeasurementDefinitionsRaw();

  Future<List<MeasurementDefinition>> fetchUsedClassMeasurementDefinitions() =>
      _dbHelper.fetchUsedClassMeasurementDefinitions();

  Future<Map<String, dynamic>?> fetchMeasurementById(int id) =>
      _dbHelper.fetchMeasurementById(id);

  Future<void> updateMeasurement({
    required int measurementId,
    required DateTime timestamp,
    required double value,
    required String unit,
    String? note,
    MeasurementContext? context,
  }) => _dbHelper.updateMeasurement(
    measurementId: measurementId,
    timestamp: timestamp,
    value: value,
    unit: unit,
    note: note,
    context: context,
  );
}
