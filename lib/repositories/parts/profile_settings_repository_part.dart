part of '../app_repository.dart';

/// Instance APIs for the profile settings domain.
mixin _ProfileSettingsRepositoryMethods on _RepositoryDependencies {
  Future<DatabaseHealthSnapshot> getDatabaseHealthSnapshot() =>
      _dbHelper.getDatabaseHealthSnapshot();

  Future<DatabaseMaintenanceResult> runDatabaseIntegrityCheck() =>
      _dbHelper.runDatabaseIntegrityCheck();

  Future<DatabaseMaintenanceResult> optimizeDatabase() =>
      _dbHelper.optimizeDatabase();

  Future<DatabaseMaintenanceResult> checkpointWal() =>
      _dbHelper.checkpointWal();

  Future<DatabaseMaintenanceResult> vacuumDatabase() =>
      _dbHelper.vacuumDatabase();

  DatabaseImportPreview previewDatabaseImport(String jsonStr) =>
      _dbHelper.previewDatabaseImport(jsonStr);

  Future<String> exportDatabase() => _dbHelper.exportDatabase();

  Future<String> exportEquipmentJson() => _dbHelper.exportEquipmentJson();

  Future<String> exportBodypartsJson() => _dbHelper.exportBodypartsJson();

  Future<String> exportMusclesJson() => _dbHelper.exportMusclesJson();

  Future<String> exportExercisesJson() => _dbHelper.exportExercisesJson();

  Future<String> exportStretchesJson() => _dbHelper.exportStretchesJson();

  Future<String> exportMuscleBodypartJson() =>
      _dbHelper.exportMuscleBodypartJson();

  Future<String> exportBodypartRankingJson() =>
      _dbHelper.exportBodypartRankingJson();

  Future<String> exportMuscleRankingJson() =>
      _dbHelper.exportMuscleRankingJson();

  Future<String> exportBodypartMuscleRankingsJson() =>
      _dbHelper.exportBodypartMuscleRankingsJson();

  Future<String> exportVolumeBoundariesJson() =>
      _dbHelper.exportVolumeBoundariesJson();

  Future<Set<int>> loadActivePlans(int profileId) =>
      _dbHelper.loadActivePlans(profileId);

  Future<void> replaceActivePlans(int profileId, Set<int> presetIds) =>
      _dbHelper.replaceActivePlans(profileId, presetIds);

  Future<void> addActivePlan(int profileId, int presetId) =>
      _dbHelper.addActivePlan(profileId, presetId);

  Future<void> removeActivePlan(int profileId, int presetId) =>
      _dbHelper.removeActivePlan(profileId, presetId);

  Future<String?> getAppState(String key) => _dbHelper.getAppState(key);

  Future<void> setAppState(String key, String? value) =>
      _dbHelper.setAppState(key, value);

  Future<List<GymProfile>> fetchAllProfiles() => _dbHelper.fetchAllProfiles();

  Future<int> updateProfile(GymProfile profile) =>
      _dbHelper.updateProfile(profile);

  Future<int> deleteProfile(int profileId) =>
      _dbHelper.deleteProfile(profileId);

  Future<void> addEquipmentToProfile(int profileId, int equipmentId) =>
      _dbHelper.addEquipmentToProfile(profileId, equipmentId);

  Future<void> removeEquipmentFromProfile(int profileId, int equipmentId) =>
      _dbHelper.removeEquipmentFromProfile(profileId, equipmentId);

  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(int profileId) =>
      _dbHelper.fetchEquipmentForProfile(profileId);

  Future<PersonalInfo?> fetchPersonalInfo() => _dbHelper.getPersonalInfo();

  Future<void> savePersonalInfo(PersonalInfo info) =>
      _dbHelper.upsertPersonalInfo(info);

  Future<void> savePersonalInfoWithBodyWeight({
    required PersonalInfo info,
    double? bodyWeightValue,
    required WeightUnit bodyWeightUnit,
    String? measurementNote,
  }) => _dbHelper.savePersonalInfoWithBodyWeight(
    info: info,
    bodyWeightValue: bodyWeightValue,
    bodyWeightUnit: bodyWeightUnit,
    measurementNote: measurementNote,
  );

  Future<void> close() => _dbHelper.close();

  Future<void> seedNutrientsIfEmpty() => _dbHelper.seedNutrientsIfEmpty();

  /// Opens the DB once so first-run copy/migrations happen before UI.
  /// Optionally runs a quick integrity check.
  Future<bool> warmUp({bool verify = false}) async {
    final db = await _dbHelper.database;
    await Future.wait<void>([
      _repository.ensureExerciseMediaManifestReady(),
      _repository.ensureSharedMediaManifestReady(),
    ]);
    await _repository.reconcileMediaCache();
    if (!verify) return true;
    try {
      final rows = await db.rawQuery('PRAGMA quick_check');
      return rows.length == 1 &&
          rows.single.length == 1 &&
          rows.single.values.single == 'ok';
    } catch (_) {
      return false;
    }
  }
}
