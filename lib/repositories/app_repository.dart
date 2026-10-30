// File: lib/repositories/app_repository.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../db/database_helper.dart';
import '../db/database_maintenance.dart';
import '../models/models.dart';
import 'content_repository.dart';
import 'food_catalog_repository.dart';

part 'parts/workout_repository_part.dart';
part 'parts/catalog_repository_part.dart';
part 'parts/measurement_repository_part.dart';
part 'parts/analytics_repository_part.dart';
part 'parts/profile_settings_repository_part.dart';
part 'parts/preset_repository_part.dart';
part 'parts/nutrition_repository_part.dart';

/// Shared collaborators; domain mixins never construct their own repository.
abstract class _RepositoryDependencies {
  DatabaseHelper get _dbHelper;
  AppRepository get _repository;
  ContentRepository get content;
  FoodCatalogRepository get foodCatalog;
}

/// Central repository providing a unified interface for all
/// database operations in the UI layer.
/// Screens/widgets call into [AppRepository]; this forwards to DAOs via [DatabaseHelper].
class AppRepository extends _RepositoryDependencies
    with
        _WorkoutRepositoryMethods,
        _CatalogRepositoryMethods,
        _MeasurementRepositoryMethods,
        _AnalyticsRepositoryMethods,
        _ProfileSettingsRepositoryMethods,
        _PresetRepositoryMethods,
        _NutritionRepositoryMethods {
  @override
  AppRepository get _repository => this;

  // ✨ Allow DI in tests; default to the singleton helper.
  AppRepository({DatabaseHelper? db}) : _dbHelper = db ?? DatabaseHelper() {
    if (db != null) {
      clearExerciseAnalysisCache();
    }
  }

  static const int _maxExerciseAnalysisCacheEntries = 250;
  static final Map<int, Future<List<ExerciseMusclePercent>>>
  _musclePercentCache = <int, Future<List<ExerciseMusclePercent>>>{};
  static final Map<int, Future<Map<BodyPart, double>>> _bodyPartPercentCache =
      <int, Future<Map<BodyPart, double>>>{};
  static final Map<int, Future<ResolvedExerciseAllocation>>
  _exerciseAllocationCache = <int, Future<ResolvedExerciseAllocation>>{};

  @override
  final DatabaseHelper _dbHelper;
  @override
  late final ContentRepository content = ContentRepository(db: _dbHelper);
  @override
  late final FoodCatalogRepository foodCatalog = FoodCatalogRepository(
    source: LocalFoodCatalogSource(_dbHelper),
  );

  /// Exposes the internal DatabaseHelper instance for extensions.
  DatabaseHelper get dbHelper => _dbHelper;

  static void clearExerciseAnalysisCache() {
    _musclePercentCache.clear();
    _bodyPartPercentCache.clear();
    _exerciseAllocationCache.clear();
  }

  static void clearExerciseAnalysisCacheFor(int defId) {
    _musclePercentCache.remove(defId);
    _bodyPartPercentCache.remove(defId);
    _exerciseAllocationCache.remove(defId);
  }

  static void _trimExerciseAnalysisCache() {
    while (_musclePercentCache.length > _maxExerciseAnalysisCacheEntries) {
      _musclePercentCache.remove(_musclePercentCache.keys.first);
    }
    while (_bodyPartPercentCache.length > _maxExerciseAnalysisCacheEntries) {
      _bodyPartPercentCache.remove(_bodyPartPercentCache.keys.first);
    }
    while (_exerciseAllocationCache.length > _maxExerciseAnalysisCacheEntries) {
      _exerciseAllocationCache.remove(_exerciseAllocationCache.keys.first);
    }
  }

  /// Creates a new workout session using DateTime for safety.
  Future<int> createSessionAt(DateTime date, int duration) =>
      _dbHelper.createSession(date, duration);

  /// Saves cardio details for an exercise (insert or replace).
  Future<void> saveCardioDetails({
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) => _dbHelper.saveCardioDetails(
    exerciseId: exerciseId,
    cardioName: cardioName,
    note: note,
    plannedMinutes: plannedMinutes,
    elapsedSeconds: elapsedSeconds,
  );

  Future<int> addExerciseMuscleMapping(
    int defId,
    int muscleId,
    int rank,
  ) async {
    final id = await _dbHelper.insertExerciseMuscleMapping(
      defId,
      muscleId,
      rank,
    );
    clearExerciseAnalysisCacheFor(defId);
    return id;
  }

  Future<int> deleteExerciseMuscleMapping(int defId, int muscleId) async {
    final id = await _dbHelper.deleteExerciseMuscleMapping(defId, muscleId);
    clearExerciseAnalysisCacheFor(defId);
    return id;
  }

  Future<int> addExerciseBodypartMapping(int defId, int bpId) async {
    final id = await _dbHelper.insertExerciseBodypartMapping(defId, bpId);
    clearExerciseAnalysisCacheFor(defId);
    return id;
  }

  Future<int> deleteExerciseBodypartMapping(int defId, int bpId) async {
    final id = await _dbHelper.deleteExerciseBodypartMapping(defId, bpId);
    clearExerciseAnalysisCacheFor(defId);
    return id;
  }

  Future<void> updateExerciseDefinition(ExerciseDefinition def) async {
    await _dbHelper.updateExerciseDefinition(def);
    clearExerciseAnalysisCacheFor(def.id);
  }

  Future<void> saveExerciseDefinitionAtomic(
    ExerciseDefinitionWrite write,
  ) async {
    await _dbHelper.saveExerciseDefinitionAtomic(write);
    clearExerciseAnalysisCacheFor(write.definition.id);
  }

  Future<void> deleteExerciseDefinition(int defId) async {
    await _dbHelper.deleteExerciseDefinition(defId);
    clearExerciseAnalysisCacheFor(defId);
  }

  Future<int> createBodyPart(String name) async {
    final id = await _dbHelper.createBodyPart(name);
    clearExerciseAnalysisCache();
    return id;
  }

  Future<void> updateBodyPartEntry(int id, String name) async {
    await _dbHelper.updateBodyPartEntry(id, name);
    clearExerciseAnalysisCache();
  }

  Future<void> deleteBodyPartEntry(int id) async {
    await _dbHelper.deleteBodyPartEntry(id);
    clearExerciseAnalysisCache();
  }

  Future<int> createMuscle(String name) async {
    final id = await _dbHelper.createMuscle(name);
    clearExerciseAnalysisCache();
    return id;
  }

  Future<void> updateMuscleEntry(int id, String name) async {
    await _dbHelper.updateMuscleEntry(id, name);
    clearExerciseAnalysisCache();
  }

  Future<void> deleteMuscleEntry(int id) async {
    await _dbHelper.deleteMuscleEntry(id);
    clearExerciseAnalysisCache();
  }

  Future<void> reseedLookupData() async {
    await _dbHelper.reseedLookupData();
    clearExerciseAnalysisCache();
  }

  // Exporters

  /// Imports the database from a JSON string.
  Future<void> importDatabase(String jsonStr, {bool clearFirst = true}) async {
    try {
      await _dbHelper.importDatabase(jsonStr, clearFirst: clearFirst);
    } on DatabaseImportCommittedException {
      clearExerciseAnalysisCache();
      rethrow;
    }
    clearExerciseAnalysisCache();
  }

  // Stats queries

  Future<int> linkMuscleToBodyPart(int muscleId, int bodypartId) async {
    final id = await _dbHelper.linkMuscleToBodyPart(muscleId, bodypartId);
    clearExerciseAnalysisCache();
    return id;
  }

  Future<int> unlinkMuscleFromBodyPart(int muscleId, int bodypartId) async {
    final id = await _dbHelper.unlinkMuscleFromBodyPart(muscleId, bodypartId);
    clearExerciseAnalysisCache();
    return id;
  }

  Future<int> setExerciseMuscleHitPercent(
    int defId,
    int muscleId,
    double pct,
  ) async {
    final id = await _dbHelper.setExerciseMuscleHitPercent(
      defId,
      muscleId,
      pct,
    );
    clearExerciseAnalysisCacheFor(defId);
    return id;
  }

  Future<int> removeExerciseMusclePercent(int defId, int muscleId) async {
    final id = await _dbHelper.removeExerciseMusclePercent(defId, muscleId);
    clearExerciseAnalysisCacheFor(defId);
    return id;
  }

  Future<int> setExerciseBodyPartPercent(
    int defId,
    int bpId,
    double pct,
  ) async {
    final id = await _dbHelper.setExerciseBodyPartPercent(defId, bpId, pct);
    clearExerciseAnalysisCacheFor(defId);
    return id;
  }

  Future<int> removeExerciseBodyPartPercent(int defId, int bpId) async {
    final id = await _dbHelper.deleteExerciseBodyPartPercent(defId, bpId);
    clearExerciseAnalysisCacheFor(defId);
    return id;
  }

  Future<void> setFormulaStep(double s) async {
    await _dbHelper.setFormulaStep(s);
    clearExerciseAnalysisCache();
  }

  Future<void> setFormulaMin(double m) async {
    await _dbHelper.setFormulaMin(m);
    clearExerciseAnalysisCache();
  }

  Future<void> setFormulaMax(double m) async {
    await _dbHelper.setFormulaMax(m);
    clearExerciseAnalysisCache();
  }

  Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) {
    final cached = _musclePercentCache.remove(defId);
    if (cached != null) {
      _musclePercentCache[defId] = cached;
      return cached;
    }

    final future = _dbHelper.computeMusclePercents(defId).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      _musclePercentCache.remove(defId);
      Error.throwWithStackTrace(error, stackTrace);
    });
    _musclePercentCache[defId] = future;
    _trimExerciseAnalysisCache();
    return future;
  }

  Future<ResolvedExerciseAllocation> resolveExerciseAllocation(int defId) {
    final cached = _exerciseAllocationCache.remove(defId);
    if (cached != null) {
      _exerciseAllocationCache[defId] = cached;
      return cached;
    }

    final future = _dbHelper.resolveExerciseAllocation(defId).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      _exerciseAllocationCache.remove(defId);
      Error.throwWithStackTrace(error, stackTrace);
    });
    _exerciseAllocationCache[defId] = future;
    _trimExerciseAnalysisCache();
    return future;
  }

  Future<void> setPersonalExerciseAllocationCredit({
    required int defId,
    required ExerciseAllocationDimension dimension,
    required int targetId,
    required double credit,
  }) async {
    await _dbHelper.setPersonalExerciseAllocationCredit(
      defId: defId,
      dimension: dimension,
      targetId: targetId,
      credit: credit,
    );
    clearExerciseAnalysisCacheFor(defId);
  }

  Future<void> replacePersonalExerciseAllocationCredits({
    required int defId,
    required ExerciseAllocationDimension dimension,
    required Map<int, double> credits,
  }) async {
    await _dbHelper.replacePersonalExerciseAllocationCredits(
      defId: defId,
      dimension: dimension,
      credits: credits,
    );
    clearExerciseAnalysisCacheFor(defId);
  }

  Future<void> resetPersonalExerciseAllocation({
    required int defId,
    required ExerciseAllocationDimension dimension,
  }) async {
    await _dbHelper.resetPersonalExerciseAllocation(
      defId: defId,
      dimension: dimension,
    );
    clearExerciseAnalysisCacheFor(defId);
  }

  Future<void> replaceCreatorExerciseAllocationCredits({
    required int defId,
    required ExerciseAllocationDimension dimension,
    required Map<int, double> credits,
  }) async {
    await _dbHelper.replaceCreatorExerciseAllocationCredits(
      defId: defId,
      dimension: dimension,
      credits: credits,
    );
    clearExerciseAnalysisCacheFor(defId);
  }

  Future<Map<BodyPart, double>> computeBodyPartPercents(int defId) {
    final cached = _bodyPartPercentCache.remove(defId);
    if (cached != null) {
      _bodyPartPercentCache[defId] = cached;
      return cached;
    }

    final future = _dbHelper.computeBodyPartPercents(defId).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      _bodyPartPercentCache.remove(defId);
      Error.throwWithStackTrace(error, stackTrace);
    });
    _bodyPartPercentCache[defId] = future;
    _trimExerciseAnalysisCache();
    return future;
  }

  Future<void> setUseManualBodyparts(int defId, bool value) async {
    await _dbHelper.setUseManualBodyparts(defId, value);
    clearExerciseAnalysisCacheFor(defId);
  }

  Future<void> setUseManualMuscles(int defId, bool value) async {
    await _dbHelper.setUseManualMuscles(defId, value);
    clearExerciseAnalysisCacheFor(defId);
  }

  Future<void> setMultiplyByRating(int defId, bool enabled) async {
    await _dbHelper.setMultiplyByRating(defId, enabled);
    clearExerciseAnalysisCacheFor(defId);
  }

  // Day view

  // Logging

  // Foods & portions

  // Recipes

  // Goals & cache

  // Diary (range)

  // Day micro aggregation

  // Favorites

  // Recents

  // Tags

  // Recipe cache reads

  // FTS maintenance

  // DB lifecycle

  // Seed core nutrient catalog if the nutrients table is empty.
}
