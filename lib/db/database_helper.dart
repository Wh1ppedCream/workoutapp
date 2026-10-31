// File: lib/db/database_helper.dart

import 'dart:convert';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/models.dart';
import 'schema.dart';
import 'seed.dart';
import 'session_dao.dart';
import 'exercise_dao.dart';
import 'exercise_history_dao.dart';
import 'set_dao.dart';
import 'cardio_dao.dart';
import 'stretch_dao.dart';
import 'definition_dao.dart';
import 'lookup_dao.dart';
import 'formula_settings_dao.dart';
import 'gym_profile_dao.dart';
import 'preset_definition_dao.dart';
import 'preset_exercise_dao.dart';
import 'preset_detail_dao.dart';
import 'preset_auto_settings_dao.dart';
import 'preset_exercise_auto_dao.dart';
import 'preset_set_auto_dao.dart';
import 'preset_progression_dao.dart';
import 'preset_flow_methods_dao.dart';
import 'personal_info_dao.dart';
import 'personal_info_transaction_dao.dart';
import 'nutrition_dao.dart';
import 'food_customization_dao.dart';
import 'flow_defaults_dao.dart';
import 'content_dao.dart';
import 'database_connection.dart';
import 'database_backup_policy.dart';
import 'database_maintenance.dart';
import 'active_plan_dao.dart';
import 'active_workout_dao.dart';
import 'pending_workout_progression_dao.dart';
import 'preset_transaction_dao.dart';
import 'profile_transaction_dao.dart';
import 'progression_rule_propagation_dao.dart';
import 'workout_transaction_dao.dart';
import 'workout_record_events_dao.dart';
import 'exercise_allocation_dao.dart';
import '../services/exercise_allocation_resolver.dart';
import '../services/exercise_equipment_compatibility.dart';

import 'package:flutter/foundation.dart' show debugPrint;

import 'database_metadata_dao.dart';
import 'schema_repair_dao.dart';
import 'food_fts_maintenance_dao.dart';
import 'measurement_dao.dart';
import 'catalog_json_export_dao.dart';
import 'ranking_and_volume_dao.dart';

/// Singleton helper for managing the SQLite database.
class DatabaseHelper {
  static const int _kDbVersion = 62;
  static const bool _kIntegrationTestMode = bool.fromEnvironment(
    'TONOS_INTEGRATION_TEST',
  );
  static const String _kDatabaseName = String.fromEnvironment(
    'TONOS_DATABASE_NAME',
    defaultValue: 'fitness_tracker.db',
  );
  static const String _kIntegrationTestDatabaseName =
      'tonos_integration_test.db';
  static int get currentSchemaVersion => _kDbVersion;

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal() : _testDb = null;
  DatabaseHelper.forTesting(Database db) : _testDb = db;

  final Database? _testDb;
  static Database? _db;
  static Future<Database>? _dbFuture;

  Future<Database> get database {
    if (_testDb != null) return Future.value(_testDb);
    if (_db != null) return Future.value(_db!);
    return _dbFuture ??= _initDatabase()
        .then((db) {
          _db = db;
          return db;
        })
        .catchError((error) {
          _dbFuture = null;
          throw error;
        });
  }

  Future<Database> _initDatabase() async {
    final sw = Stopwatch()..start();

    final path = await _dbFilePath();
    final dbFile = File(path);
    final existedBeforeOpen = await dbFile.exists();
    final existingBytes = existedBeforeOpen ? await dbFile.length() : 0;
    debugPrint(
      '[db] opening ${existedBeforeOpen ? 'existing' : 'new'} database '
      '(size=${existingBytes}B)',
    );

    final db = await openDatabase(
      path,
      version: _kDbVersion,
      onConfigure: DatabaseConnection.configure,

      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        final sw = Stopwatch()..start();
        debugPrint('[db] onUpgrade $oldVersion -> $newVersion (begin)');

        await Schema.onUpgrade(db, oldVersion, newVersion);
        await _ensureAppMetaTable(db);
        await _ensureExerciseDefNewCols(db); // from previous step
        await _ensureExerciseJoinTables(db); // ← add this line
        await _ensureStatsTables(db); // ← add here
        await _ensureStretchLookups(db);
        await _ensureAutoPresetFlowTables(db); // ← add this line
        await _ensureCardioTables(db); // ← add this
        await _ensureFormulaSettings(db); // ← add
        await _ensureExerciseBodypartPercent(db); // ← add
        await _ensureExerciseMediaTable(db);
        await ContentDao.ensureTables(db);
        await _ensureNutritionGoalsColumns(db);
        await ensureSchemaRepairs(db);
        await _ensureFavoriteFoodsShape(db);

        // triggers, seeding, backfills, FTS, indexes…
        await _resetDbTriggers(db, force: true);
        await SeedBootstrap.seedMissingBlocks(
          db,
          onFoodProgress: (c) => _logProgress('foods', c),
        );
        await Seed.syncExerciseCatalogIfNeeded(db);
        await Seed.syncCreatorExerciseAllocationDefaults(db);
        await _backfillNormalizedFoodKeys(db);
        await _backfillEnergyKcalFromMacros(db);
        if (oldVersion < 22 && await _tableExists(db, 'recipes')) {
          await _rebuildAllRecipeCaches(db);
        }
        await _resetDbTriggers(db);
        await _rebuildFoodFtsIfExists(db);
        await _ensureIndexes(db);
        if (oldVersion < 61) {
          await WorkoutRecordEventsDao.rebuildAll(db);
        }

        debugPrint(
          '[db] onUpgrade $oldVersion -> $newVersion (done in ${sw.elapsedMilliseconds}ms)',
        );
      },

      // NEW:
      onOpen: (db) async {
        final sw = Stopwatch()..start();
        debugPrint('[db] onOpen (begin)');
        await _ensureAppMetaTable(db);
        await _ensureExerciseMediaTable(db);
        await ContentDao.ensureTables(db);
        await Schema.migrateV49(db);
        await Schema.migrateV50(db);
        await Schema.migrateV51(db);
        await Schema.migrateV52(db);
        await Schema.migrateV53(db);
        await Schema.migrateV54(db);
        await Schema.migrateV55(db);
        await Schema.migrateV56(db);
        await Schema.migrateV57(db);
        await Schema.migrateV58(db);
        await Schema.migrateV59(db);
        await Schema.migrateV60(db);
        await Schema.migrateV61(db);
        await Seed.syncExerciseCatalogIfNeeded(db);
        await _resetDbTriggers(db); // <—
        await _maybeCompactLegacyFoodCatalog(db);
        await _removeEmptyStarterPlans(db);
        final didSeed = await _seedFoodsIfEmpty(db); // now returns bool
        await _ensureIndexes(db); // still safe if already created
        if (!didSeed) {
          await _ensureFoodFtsReady(db);
        }
        debugPrint(
          '[db] onOpen (done in ${sw.elapsedMilliseconds}ms) - seeded: $didSeed',
        );
      },
    );
    debugPrint(
      '[db] openDatabase ready in ${sw.elapsedMilliseconds}ms '
      '(existingDb: $existedBeforeOpen)',
    );
    return db;
  }

  /// Builds initial schema and seeds all data.
  Future<void> _onCreate(Database db, int version) async {
    final sw = Stopwatch()..start();
    debugPrint('[db] onCreate -> v$version');
    final stepSw = Stopwatch();

    // 1) Create schema
    stepSw
      ..reset()
      ..start();
    await Schema.createTables(db);
    _logDbInitStep('onCreate', 'create-schema', stepSw.elapsedMilliseconds);

    stepSw
      ..reset()
      ..start();
    await _ensureAppMetaTable(db);
    await _ensureExerciseMediaTable(db);
    await ContentDao.ensureTables(db);
    _logDbInitStep('onCreate', 'ensure-meta-media', stepSw.elapsedMilliseconds);

    // 2) Triggers that are safe to have before foods seeding
    stepSw
      ..reset()
      ..start();
    await _resetDbTriggers(db);
    _logDbInitStep('onCreate', 'prepare-triggers', stepSw.elapsedMilliseconds);

    // 3) Seed only the missing blocks (lookups, stretches, analytics, nutrients, foods)
    stepSw
      ..reset()
      ..start();
    await SeedBootstrap.seedMissingBlocks(
      db,
      onFoodProgress: (c) => _logProgress('foods', c),
    );
    await Seed.syncCreatorExerciseAllocationDefaults(db);
    _logDbInitStep(
      'onCreate',
      'seed-missing-blocks',
      stepSw.elapsedMilliseconds,
    );

    // 4) Normalizations & caches (safe no-ops when nothing was seeded)
    stepSw
      ..reset()
      ..start();
    await _backfillNormalizedFoodKeys(db);
    _logDbInitStep(
      'onCreate',
      'backfill-food-keys',
      stepSw.elapsedMilliseconds,
    );
    stepSw
      ..reset()
      ..start();
    await _backfillEnergyKcalFromMacros(db);
    _logDbInitStep('onCreate', 'backfill-energy', stepSw.elapsedMilliseconds);

    await _rebuildAllRecipeCaches(db); // fresh installs won’t have cache yet
    await _rebuildFoodFtsIfExists(db); // if FTS exists, backfill it once
    await _ensureIndexes(db);

    debugPrint('[db] onCreate complete in ${sw.elapsedMilliseconds}ms');
  }

  Future<void> _ensureExerciseDefNewCols(Database db) async =>
      SchemaRepairDao.ensureExerciseDefNewCols(db);

  Future<void> _ensureExerciseJoinTables(Database db) async =>
      SchemaRepairDao.ensureExerciseJoinTables(db);

  Future<void> _ensureStatsTables(Database db) async =>
      SchemaRepairDao.ensureStatsTables(db);

  Future<void> _ensureStretchLookups(Database db) async =>
      SchemaRepairDao.ensureStretchLookups(db);

  Future<void> _ensureAutoPresetFlowTables(Database db) async =>
      SchemaRepairDao.ensureAutoPresetFlowTables(db);

  Future<void> _ensureCardioTables(Database db) async =>
      SchemaRepairDao.ensureCardioTables(db);

  Future<void> _ensureFormulaSettings(Database db) async =>
      SchemaRepairDao.ensureFormulaSettings(db);

  Future<void> _ensureExerciseBodypartPercent(Database db) async =>
      SchemaRepairDao.ensureExerciseBodypartPercent(db);

  Future<void> _ensureExerciseMediaTable(Database db) async =>
      SchemaRepairDao.ensureExerciseMediaTable(db);

  Future<void> _ensureNutritionGoalsColumns(Database db) async =>
      SchemaRepairDao.ensureNutritionGoalsColumns(db);

  Future<void> ensureSchemaRepairs(Database db) async =>
      SchemaRepairDao.ensureSchemaRepairs(db);

  Future<void> _ensureFavoriteFoodsShape(Database db) async =>
      SchemaRepairDao.ensureFavoriteFoodsShape(db);

  // ────────────────────────────────────────────────────────────────────────────
  // BACKFILL METHODS
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _resetDbTriggers(Database db, {bool force = false}) async =>
      FoodFtsMaintenanceDao.resetDbTriggers(db, force: force);

  void _logDbInitStep(String phase, String label, int elapsedMs) {
    debugPrint('[db] $phase step $label: ${elapsedMs}ms');
  }

  // Log at 1, 1k, then every 5k to keep console readable.
  void _logProgress(String phase, int total) =>
      FoodFtsMaintenanceDao.logProgress(phase, total);

  Future<void> _backfillNormalizedFoodKeysTx(DatabaseExecutor ex) async =>
      FoodFtsMaintenanceDao.backfillNormalizedFoodKeysTx(ex);

  Future<void> _backfillNormalizedFoodKeys(Database db) async =>
      FoodFtsMaintenanceDao.backfillNormalizedFoodKeys(db);

  Future<void> _rebuildFoodFtsIfExists(Database db) async =>
      FoodFtsMaintenanceDao.rebuildFoodFtsIfExists(db);

  Future<void> _ensureFoodFtsReady(Database db) async =>
      FoodFtsMaintenanceDao.ensureFoodFtsReady(db);

  Future<void> _ensureFoodFtsTriggers(DatabaseExecutor db) async =>
      FoodFtsMaintenanceDao.ensureFoodFtsTriggers(db);

  Future<void> _dropFoodFtsTriggers(DatabaseExecutor db) async =>
      FoodFtsMaintenanceDao.dropFoodFtsTriggers(db);

  Future<bool> _hasFoodFtsTable(DatabaseExecutor db) async =>
      FoodFtsMaintenanceDao.hasFoodFtsTable(db);

  Future<void> _ensureIndexes(Database db, {bool force = false}) async =>
      FoodFtsMaintenanceDao.ensureIndexes(db, force: force);

  Future<void> _ensureAppMetaTable(DatabaseExecutor db) async =>
      FoodFtsMaintenanceDao.ensureAppMetaTable(db);

  Future<String?> _getAppMeta(DatabaseExecutor db, String key) async =>
      FoodFtsMaintenanceDao.getAppMeta(db, key);

  Future<void> _setAppMeta(
    DatabaseExecutor db,
    String key,
    String value,
  ) async => FoodFtsMaintenanceDao.setAppMeta(db, key, value);

  Future<void> _maybeCompactLegacyFoodCatalog(Database db) async =>
      FoodFtsMaintenanceDao.maybeCompactLegacyFoodCatalog(db);

  Future<void> _removeEmptyStarterPlans(Database db) async =>
      FoodFtsMaintenanceDao.removeEmptyStarterPlans(db);

  Future<bool> _seedFoodsIfEmpty(Database db) async =>
      FoodFtsMaintenanceDao.seedFoodsIfEmpty(db);

  // ────────────────────────────────────────────────────────────────────────────
  // CRUD METHODS
  // ────────────────────────────────────────────────────────────────────────────

  //session_dao

  Future<int> createSession(DateTime completedAt, int duration) async {
    final db = await database;
    return SessionDao.insertSession(
      db,
      completedAt: completedAt,
      duration: duration,
    );
  }

  Future<List<Map<String, dynamic>>> getAllSessionsRaw() async {
    final db = await database;
    return SessionDao.getAllSessionsRaw(db);
  }

  Future<List<Map<String, dynamic>>> fetchWorkoutReportSessionsRaw({
    DateTime? start,
    DateTime? end,
  }) async {
    final db = await database;
    return SessionDao.fetchWorkoutReportSessionsRaw(db, start: start, end: end);
  }

  Future<void> deleteSession(int sid) async {
    final db = await database;
    return WorkoutTransactionDao.deleteSession(db, sid);
  }

  Future<int> completeWorkoutAtomic({
    required DateTime completedAt,
    required int durationSeconds,
    required List<WorkoutExerciseWrite> exercises,
    int? autoPresetId,
  }) async {
    final db = await database;
    return WorkoutTransactionDao.completeWorkout(
      db,
      completedAt: completedAt,
      durationSeconds: durationSeconds,
      exercises: exercises,
      autoPresetId: autoPresetId,
    );
  }

  Future<void> replaceSessionExercisesAtomic({
    required int sessionId,
    required List<WorkoutExerciseWrite> exercises,
  }) async {
    final db = await database;
    await WorkoutTransactionDao.replaceSessionExercises(
      db,
      sessionId: sessionId,
      exercises: exercises,
    );
  }

  Future<void> saveActiveWorkoutDraft({
    required DateTime startedAt,
    required int? autoPresetId,
    required String payloadJson,
  }) async {
    final db = await database;
    await ActiveWorkoutDao.save(
      db,
      startedAt: startedAt,
      autoPresetId: autoPresetId,
      payloadJson: payloadJson,
    );
  }

  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async {
    final db = await database;
    return ActiveWorkoutDao.load(db);
  }

  Future<void> clearActiveWorkoutDraft() async {
    final db = await database;
    await ActiveWorkoutDao.clear(db);
  }

  Future<WorkoutSession?> fetchSessionById(int sessionId) async {
    final db = await database;
    final row = await SessionDao.getSessionById(db, sessionId);
    if (row == null) return null;
    return WorkoutSession(
      id: row['id'] as int,
      date: TemporalSemantics.readLocalDateTime(
        epochMilliseconds: row['completed_at_ms'],
        legacyIso: row['date'],
      ),
      calendarDayKey: TemporalSemantics.readCalendarDay(
        calendarDay: row['training_day'],
        legacyIso: row['date'],
        epochMilliseconds: row['completed_at_ms'],
      ).storageKey,
      duration: row['duration'] as int,
    );
  }

  Future<void> updateSession(int id, DateTime newDate, int newDuration) async {
    final db = await database;
    await WorkoutTransactionDao.updateSession(db, id, newDate, newDuration);
  }

  // Fetch an inclusive exact-instant range and map it to sessions.
  Future<List<WorkoutSession>> fetchSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final rows = await SessionDao.getSessionsForInstantRange(db, start, end);
    return rows
        .map(
          (row) => WorkoutSession(
            id: row['id'] as int,
            date: TemporalSemantics.readLocalDateTime(
              epochMilliseconds: row['completed_at_ms'],
              legacyIso: row['date'],
            ),
            calendarDayKey: TemporalSemantics.readCalendarDay(
              calendarDay: row['training_day'],
              legacyIso: row['date'],
              epochMilliseconds: row['completed_at_ms'],
            ).storageKey,
            duration: row['duration'] as int,
          ),
        )
        .toList();
  }

  //exercise_dao

  Future<int> addExercise(
    int sessionId,
    String name,
    String equipment,
    int idx,
  ) async {
    final db = await database;
    return ExerciseDao.insertExercise(db, sessionId, name, equipment, idx);
  }

  Future<List<Map<String, dynamic>>> fetchExercisesRaw(int sessionId) async {
    final db = await database;
    return ExerciseDao.getExercisesForSession(db, sessionId);
  }

  /// Calculates record badges for the parent sets saved in one workout.
  Future<Map<int, WorkoutExerciseRecordBadges>> fetchSessionRecordBadges(
    int sessionId,
  ) async {
    final db = await database;
    return WorkoutRecordEventsDao.forSession(db, sessionId);
  }

  Future<Map<int, WorkoutExerciseRecordBadges>> fetchExerciseRecordBadges(
    Iterable<int> exerciseIds,
  ) async {
    final db = await database;
    return WorkoutRecordEventsDao.forExerciseIds(db, exerciseIds);
  }

  Future<Map<int, WorkoutExerciseRecordBadges>>
  fetchCurrentExerciseRecordBadges(int definitionId) async {
    final db = await database;
    return WorkoutRecordEventsDao.currentLeadersForDefinition(db, definitionId);
  }

  Future<List<Map<String, dynamic>>> fetchRecentWeightExerciseHistoryRows({
    required int definitionId,
    int? beforeCompletedAtMilliseconds,
    int? beforeExerciseId,
    int limit = 10,
  }) async {
    final db = await database;
    return ExerciseHistoryDao.fetchWeightExerciseRows(
      db,
      definitionId: definitionId,
      beforeCompletedAtMilliseconds: beforeCompletedAtMilliseconds,
      beforeExerciseId: beforeExerciseId,
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> fetchExerciseOneRmTrendRows({
    required int definitionId,
    int limit = 60,
  }) async {
    if (limit <= 0) return const <Map<String, dynamic>>[];

    final db = await database;
    return ExerciseHistoryDao.fetchExerciseOneRmTrendRows(
      db,
      definitionId: definitionId,
      limit: limit,
    );
  }

  Future<void> deleteExercises(int sessionId) async {
    final db = await database;
    await WorkoutTransactionDao.replaceSessionExercises(
      db,
      sessionId: sessionId,
      exercises: const <WorkoutExerciseWrite>[],
    );
  }

  Future<void> saveExerciseDefinitionAtomic(
    ExerciseDefinitionWrite write,
  ) async {
    final db = await database;
    await ProfileTransactionDao.saveExerciseDefinition(db, write);
  }

  Future<int> addExerciseRow({
    int? exerciseDefId,
    required String type,
    required int orderIndex,
    required int sessionId,
    int? sourcePresetExerciseId,
  }) async {
    final db = await database;
    return ExerciseDao.insertExerciseRow(
      db: db,
      exerciseDefId: exerciseDefId,
      type: type,
      orderIndex: orderIndex,
      sessionId: sessionId,
      sourcePresetExerciseId: sourcePresetExerciseId,
    );
  }

  /// Fetches a fully-detailed WorkoutExercise (Weight/Cardio/Stretch).
  Future<WorkoutExercise?> fetchDetailedExercise(int exerciseId) async {
    final db = await database;

    // 1) Base row
    final exRow = await ExerciseDao.getExerciseById(db, exerciseId);
    if (exRow == null) return null;
    final type = exRow['type'] as String;

    if (type == 'weight') {
      // — definition info (name+equipment)
      final defInfoFuture = DefinitionDao.getDefinitionInfo(
        db,
        exRow['exercise_def_id'] as int,
      );

      // — sets & changeSets
      final allSetRowsFuture = SetDao.getSetsForExercise(db, exerciseId);
      final defInfo = await defInfoFuture;
      final allSetRows = await allSetRowsFuture;
      final parentRows = allSetRows
          .where((row) => row['parent_set_id'] == null)
          .toList();
      final childRowsByParentId = <int, List<Map<String, dynamic>>>{};
      for (final row in allSetRows) {
        final parentId = row['parent_set_id'] as int?;
        if (parentId == null) continue;
        childRowsByParentId
            .putIfAbsent(parentId, () => <Map<String, dynamic>>[])
            .add(row);
      }
      final sets = <ExerciseSet>[];
      final changeSets = <int, List<ExerciseSet>>{};
      final completedParents = <int>{};
      final completedChildren = <int, Set<int>>{};

      for (var i = 0; i < parentRows.length; i++) {
        final p = parentRows[i];
        sets.add(
          ExerciseSet(
            sourcePresetSetId: p['source_preset_set_id'] as int?,
            weight: (p['weight'] as num).toDouble(),
            reps: p['reps'] as int,
          ),
        );
        completedParents.add(i);

        final children =
            childRowsByParentId[p['id'] as int] ??
            const <Map<String, dynamic>>[];
        if (children.isNotEmpty) {
          changeSets[i] = children
              .map(
                (c) => ExerciseSet(
                  sourcePresetSetId: c['source_preset_set_id'] as int?,
                  weight: (c['weight'] as num).toDouble(),
                  reps: c['reps'] as int,
                ),
              )
              .toList();
          completedChildren[i] = Set.from(
            List.generate(children.length, (j) => j),
          );
        }
      }

      return WeightExercise(
        name: defInfo['name']!,
        equipment: defInfo['equipmentName'] ?? '',
        sourcePresetExerciseId: exRow['source_preset_exercise_id'] as int?,
        sets: sets,
        changeSets: changeSets,
        completedParents: completedParents,
        completedChildren: completedChildren,
      );
    }

    if (type == 'cardio') {
      final c = await getCardioDetailsForExercise(exerciseId);
      if (c == null) return null;
      return CardioExercise(
        name: c['cardio_name'] as String,
        equipment: '',
        cardioName: c['cardio_name'] as String,
        cardioNote: c['note'] as String?,
        plannedMinutes: (c['planned_minutes'] as num).toInt(),
        elapsedSeconds: (c['elapsed_seconds'] as num).toInt(),
      );
    }

    if (type == 'stretch') {
      final items = await getStretchItemsForExercise(exerciseId);
      // Decode rows into our StretchInstance models
      final insts = items.map((r) => StretchInstance.fromMap(r)).toList();
      // Track which indices were checked
      final completed = <int>{};
      for (var i = 0; i < insts.length; i++) {
        if (insts[i].isChecked) completed.add(i);
      }
      // determine header name…
      String hdr = 'Stretch';
      if (insts.isNotEmpty && insts.first.stretchId != null) {
        final sd = await DefinitionDao.getDefinitionInfo(
          db,
          insts.first.stretchId!,
        );
        hdr = sd['name']!;
      }
      return StretchExercise(
        name: hdr,
        equipment: '',
        stretchInstances: insts,
        completedStretchIndices: completed,
      );
    }

    return null;
  }

  /// Deletes a single exercise (and all its child rows) by ID.
  Future<void> deleteExercise(int exerciseId) async {
    final db = await database;
    // Delegate to the DAO
    await ExerciseDao.deleteExerciseById(db, exerciseId);
  }

  // set_dao.dart

  /// Inserts a set belonging to an exercise instance.
  Future<int> addSet(
    int exerciseId,
    double weight,
    int reps,
    int orderIndex,
  ) async {
    final db = await database;
    return SetDao.insertSet(db, exerciseId, weight, reps, orderIndex);
  }

  /// Given a parentSets list and childChangeSets map, insert into sets.
  /// parentSets is List < ExerciseSet >  where each is a top-level set.
  /// childChangeSets is a Map < parentIndex, List < ExerciseSet>>.
  Future<void> addWeightSets({
    required int exerciseId,
    required List<ExerciseSet> parentSets,
    required Map<int, List<ExerciseSet>> childChangeSets,
  }) async {
    final db = await database;
    await SetDao.insertWeightSets(
      db: db,
      exerciseId: exerciseId,
      parentSets: parentSets,
      childChangeSets: childChangeSets,
    );
  }

  // Fetch raw set-rows.
  Future<List<Map<String, dynamic>>> fetchSetsRaw(int exerciseId) async {
    final db = await database;
    return SetDao.getSetsForExercise(db, exerciseId);
  }

  // Update a single set.
  Future<void> updateSet(int setId, double weight, int reps) async {
    final db = await database;
    await WorkoutTransactionDao.updateSet(db, setId, weight, reps);
  }

  // Delete a single set.
  Future<void> deleteSet(int setId) async {
    final db = await database;
    await WorkoutTransactionDao.deleteSet(db, setId);
  }

  // Reorder sets.
  Future<void> reorderSets(int exerciseId, List<int> setIds) async {
    final db = await database;
    await SetDao.reorderSets(db, exerciseId, setIds);
  }

  //cardio_dao.dart

  /// After you create a cardio exercise row (type='cardio'), call:
  Future<void> saveCardioDetails({
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) async {
    final db = await database;
    await CardioDao.insertCardioDetails(
      db: db,
      exerciseId: exerciseId,
      cardioName: cardioName,
      note: note,
      plannedMinutes: plannedMinutes,
      elapsedSeconds: elapsedSeconds,
    );
  }

  /// Fetch cardio_details for a session.
  Future<Map<String, dynamic>?> getCardioDetailsForExercise(int eid) async {
    final db = await database;
    return CardioDao.getCardioDetailsForExercise(db, eid);
  }

  // Fetch raw cardio map.
  Future<Map<String, dynamic>?> fetchCardioDetails(int exerciseId) async {
    final db = await database;
    return CardioDao.getCardioDetailsForExercise(db, exerciseId);
  }

  // Update cardio details.
  Future<void> updateCardioDetails({
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) async {
    final db = await database;
    await CardioDao.updateCardioDetails(
      db: db,
      exerciseId: exerciseId,
      cardioName: cardioName,
      note: note,
      plannedMinutes: plannedMinutes,
      elapsedSeconds: elapsedSeconds,
    );
  }

  // Delete cardio details.
  Future<void> deleteCardioDetails(int exerciseId) async {
    final db = await database;
    await CardioDao.deleteCardioDetails(db, exerciseId);
  }

  //stretch_dao.dart

  /// After you create a stretch-type exercise row, call:
  /// Inserts one stretch-type exercise’s “instance” and all of its items.
  /// uses class StretchInstance.
  Future<void> saveClassStretchInstance({
    required int exerciseId,
    required List<StretchInstance> instances,
  }) async {
    final db = await database;
    await StretchDao.insertStretchInstance(
      db: db,
      exerciseId: exerciseId,
      items: instances,
    );
  }

  Future<void> saveStretchInstance({
    required int exerciseId,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await database;
    final instances = items.map((m) => StretchInstance.fromMap(m)).toList();
    await StretchDao.insertStretchInstance(
      db: db,
      exerciseId: exerciseId,
      items: instances,
    );
  }

  /// Fetch all items in a stretch instance for a given exercise.
  Future<List<Map<String, dynamic>>> getStretchItemsForExercise(int eid) async {
    final db = await database;
    // DAO now returns List<StretchInstance>
    final instances = await StretchDao.getStretchItemsForExercise(db, eid);
    // convert back to the old map format so callers see the same type
    return instances.map((inst) => inst.toMap()).toList();
  }

  // Fetch raw stretch-item maps.
  Future<List<Map<String, dynamic>>> fetchStretchItemsRaw(
    int exerciseId,
  ) async {
    final db = await database;
    final insts = await StretchDao.getStretchItemsForExercise(db, exerciseId);
    return insts.map((i) => i.toMap()).toList();
  }

  // Update one stretch item.
  Future<int> updateStretchItem({
    required int itemId,
    int? stretchId,
    bool? isCustom,
    String? customName,
    String? customDesc,
    bool? isChecked,
    int? orderIndex,
  }) async {
    final db = await database;
    return StretchDao.updateStretchItem(
      db: db,
      itemId: itemId,
      stretchId: stretchId,
      isCustom: isCustom,
      customName: customName,
      customDesc: customDesc,
      isChecked: isChecked,
      orderIndex: orderIndex,
    );
  }

  // Delete a stretch item.
  Future<void> deleteStretchItem(int itemId) async {
    final db = await database;
    await StretchDao.deleteStretchItem(db, itemId);
  }

  // Delete whole stretch instance.
  Future<void> deleteStretchInstance(int exerciseId) async {
    final db = await database;
    await StretchDao.deleteStretchInstance(db, exerciseId);
  }

  // Reorder stretch items.
  Future<void> reorderStretchItems(int exerciseId, List<int> itemIds) async {
    final db = await database;
    await StretchDao.reorderStretchItems(db, exerciseId, itemIds);
  }

  //definition_dao.dart

  /// Fetch exercise definitions by bodyPart ID.
  Future<List<Map<String, dynamic>>> lookupDefsByBodyPart(
    int bodyPartId,
  ) async {
    final db = await database;
    return DefinitionDao.getExerciseDefsByBodyPart(db, bodyPartId);
  }

  /// Fetch every definition with its full equipmentList, bodyParts, and muscles.
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async {
    final db = await database;
    final definitions =
        await DefinitionDao.getAllExerciseDefinitionsDetailedBatched(db);
    return DefinitionDao.selectableCatalogDefinitions(definitions);
  }

  /// Fetch a selected subset of definitions with their full join data.
  Future<List<ExerciseDefinition>> lookupDefsDetailedByIds(
    List<int> definitionIds,
  ) async {
    final db = await database;
    return DefinitionDao.getExerciseDefinitionsDetailedByIds(db, definitionIds);
  }

  Future<List<Map<String, dynamic>>> fetchMostUsedExerciseDefinitionsRaw({
    int limit = 5,
  }) async {
    final db = await database;
    return DefinitionDao.fetchMostUsedExerciseDefinitionsRaw(db, limit: limit);
  }

  /// Fetch all exercise definitions (shallow, without join lists).
  Future<List<Map<String, dynamic>>> fetchAllExercisesRaw() async {
    final db = await database;
    return DefinitionDao.getAllExercisesRaw(db);
  }

  /// Fetch all exercises whose equipment is *at least one* of [equipmentNames].
  Future<List<ExerciseDefinition>> lookupDefsWithAnyEquipment(
    List<String> equipmentNames,
  ) async {
    final db = await database;
    return DefinitionDao.getExerciseDefsWithAnyEquipment(db, equipmentNames);
  }

  /// Fetch all exercises whose equipment is *only* drawn from [equipmentNames].
  ///
  /// Because each definition has a single equipment_id, this currently
  /// returns those whose equipment_id ∈ list, or NULL if you consider
  /// “bodyweight/no equipment” as allowed.
  Future<List<ExerciseDefinition>> lookupDefsOnlyWithEquipment(
    List<String> equipmentNames, {
    bool includeNone = true,
  }) async {
    final db = await database;
    return DefinitionDao.getExerciseDefsOnlyWithEquipment(
      db,
      equipmentNames,
      includeNone: includeNone,
    );
  }

  /// Fetch exercise definitions, optionally filtering by:
  ///  – equipmentNames: list of equipment.name
  ///  – bodypartIds:    list of bodypart.id
  ///  – muscleIds:      list of muscle.id
  ///
  /// Each non-null filter list requires the definition to be associated
  /// with *at least one* entry in that list. All supplied filters are ANDed.
  Future<List<ExerciseDefinition>> lookupDefsFiltered({
    List<String>? equipmentNames,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) async {
    final db = await database;
    return DefinitionDao.getExerciseDefinitionsFiltered(
      db,
      equipmentNames: equipmentNames,
      bodypartIds: bodypartIds,
      muscleIds: muscleIds,
    );
  }

  Future<int> findOrCreateExerciseDefinition(
    String name,
    String equipmentName,
  ) async {
    final db = await database;
    return DefinitionDao.findOrCreateExerciseDefinition(
      db,
      name,
      equipmentName,
    );
  }

  Future<Map<String, String?>> fetchDefinitionInfo(int defId) async {
    final db = await database;
    return DefinitionDao.getDefinitionInfo(db, defId);
  }

  Future<void> updateExerciseDefinition(ExerciseDefinition def) async {
    final db = await database;
    await DefinitionDao.updateExerciseDefinition(db, def);
  }

  Future<void> deleteExerciseDefinition(int defId) async {
    final db = await database;
    await DefinitionDao.deleteExerciseDefinition(db, defId);
  }

  Future<List<ExerciseDefinition>> searchExerciseDefinitions(
    String query,
  ) async {
    final db = await database;
    return DefinitionDao.searchExerciseDefinitions(db, query);
  }

  /// Fetch a single detailed ExerciseDefinition by its ID.
  Future<ExerciseDefinition?> getExerciseDefinitionById(int defId) async {
    final db = await database;
    return DefinitionDao.getExerciseDefinitionById(db, defId);
  }

  /// Fetches a shipped exercise by its immutable catalog identity.
  Future<ExerciseDefinition?> getExerciseDefinitionByCatalogId(
    String catalogId,
  ) async {
    final db = await database;
    return DefinitionDao.getExerciseDefinitionByCatalogId(db, catalogId);
  }

  Future<List<ExerciseMediaItem>> getExerciseMedia(int defId) async {
    final db = await database;
    final rows = await db.query(
      'exercise_media',
      where: 'exercise_def_id = ?',
      whereArgs: [defId],
      orderBy: 'sort_order, id',
    );
    return rows.map(ExerciseMediaItem.fromMap).toList();
  }

  Future<List<SharedMediaItem>> getSharedMedia(
    SharedMediaEntityType entityType,
    int entityId,
  ) async {
    final db = await database;
    return ContentDao.getSharedMedia(db, entityType, entityId);
  }

  Future<void> replaceExerciseMedia(
    int defId,
    List<ExerciseMediaItem> items,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'exercise_media',
        where: 'exercise_def_id = ?',
        whereArgs: [defId],
      );
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        await txn.insert('exercise_media', {
          'exercise_def_id': defId,
          'asset_id': item.assetId,
          'media_type': item.mediaType,
          'remote_url': item.remoteUrl,
          'thumbnail_url': item.thumbnailUrl,
          'local_cache_path': item.localCachePath,
          'local_thumbnail_path': item.localThumbnailPath,
          'title': item.title,
          'sort_order': i,
          'version': item.version,
          'bytes': item.bytes,
          'width': item.width,
          'height': item.height,
          'sha256': item.sha256,
          'license_id': item.licenseId,
          'last_accessed_at': item.lastAccessedAt?.toIso8601String(),
          'downloaded_at': item.downloadedAt?.toIso8601String(),
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
    });
  }

  /// Fetches catalog definitions with optional profile & filters.
  Future<List<ExerciseDefinition>> fetchCatalogDefinitions({
    required bool useProfileFilter,
    int? profileId,
    String? equipmentFilter,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) async {
    var definitions = await lookupDefsDetailed();

    // Require the complete equipment list for profile-aware generation.
    if (useProfileFilter && profileId != null) {
      final profileEquipment = await fetchEquipmentForProfile(profileId);
      final profileEquipmentIds = <int>{
        for (final row in profileEquipment)
          if (row['id'] is int) row['id'] as int,
      };
      definitions = definitions
          .where(
            (definition) => ExerciseEquipmentCompatibility.fitsProfileIds(
              definition,
              profileEquipmentIds,
            ),
          )
          .toList();
    }

    final selectedEquipment = equipmentFilter?.trim();
    if (selectedEquipment != null &&
        selectedEquipment.isNotEmpty &&
        selectedEquipment != 'All') {
      definitions = definitions
          .where(
            (definition) => ExerciseEquipmentCompatibility.usesEquipmentName(
              definition,
              selectedEquipment,
            ),
          )
          .toList();
    }

    // 4) Post‐filter by body/muscle
    if (bodypartIds != null && bodypartIds.isNotEmpty) {
      final selectedBodypartIds = bodypartIds.toSet();
      definitions = definitions
          .where(
            (definition) => definition.bodyParts.any(
              (bodyPart) => selectedBodypartIds.contains(bodyPart.id),
            ),
          )
          .toList();
    }

    if (muscleIds != null && muscleIds.isNotEmpty) {
      final selectedMuscleIds = muscleIds.toSet();
      definitions = definitions
          .where(
            (definition) => definition.muscles.any(
              (muscle) => selectedMuscleIds.contains(muscle.muscle.id),
            ),
          )
          .toList();
    }

    return definitions;
  }

  Future<int> insertExerciseMuscleMapping(
    int defId,
    int muscleId,
    int rank,
  ) async {
    final db = await database;
    return DefinitionDao.insertExerciseMuscleMapping(db, defId, muscleId, rank);
  }

  /// Deletes the link between a definition and a muscle.
  Future<int> deleteExerciseMuscleMapping(int defId, int muscleId) async {
    final db = await database;
    return DefinitionDao.deleteExerciseMuscleMapping(db, defId, muscleId);
  }

  Future<int> insertExerciseBodypartMapping(int defId, int bpId) async {
    final db = await database;
    return DefinitionDao.insertExerciseBodypartMapping(db, defId, bpId);
  }

  Future<int> deleteExerciseBodypartMapping(int defId, int bpId) async {
    final db = await database;
    return DefinitionDao.deleteExerciseBodypartMapping(db, defId, bpId);
  }

  Future<int> insertExerciseEquipmentMapping(int defId, int eqId) async {
    final db = await database;
    return DefinitionDao.insertExerciseEquipmentMapping(db, defId, eqId);
  }

  Future<int> deleteExerciseEquipmentMapping(int defId, int eqId) async {
    final db = await database;
    return DefinitionDao.deleteExerciseEquipmentMapping(db, defId, eqId);
  }

  //lookup_dao.dart

  /// Fetch all measurement definitions.
  Future<List<Map<String, dynamic>>> fetchMeasurementDefinitions() async =>
      MeasurementDao(await database).fetchMeasurementDefinitions();

  Future<void> ensureDefaultMeasurementDefinitions() async =>
      MeasurementDao(await database).ensureDefaultMeasurementDefinitions();

  Future<int> insertMeasurementDefinition({
    required String name,
    required MeasurementType type,
  }) async =>
      MeasurementDao(await database)
          .insertMeasurementDefinition(name: name, type: type);

  Future<int?> fetchMeasurementDefinitionId(String name) async =>
      MeasurementDao(await database).fetchMeasurementDefinitionId(name);

  /// Insert a new measurement instance.
  Future<int> insertMeasurement(
    int defId,
    DateTime timestamp,
    double value,
    String unit,
    String? note,
    MeasurementContext? context,
  ) async =>
      MeasurementDao(await database)
          .insertMeasurement(defId, timestamp, value, unit, note, context);

  /// Fetch all measurements for a definition.
  Future<List<Map<String, dynamic>>> fetchMeasurementsRaw(int defId) async =>
      MeasurementDao(await database).fetchMeasurementsRaw(defId);

  Future<List<Measurement>> fetchClassMeasurementsForDefinition(
    int defId,
  ) async =>
      MeasurementDao(await database).fetchClassMeasurementsForDefinition(defId);

  Future<double?> fetchLatestBodyWeightLbs() async =>
      MeasurementDao(await database).fetchLatestBodyWeightLbs();

  /// Returns only the definitions that have at least one measurement recorded.
  Future<List<Map<String, dynamic>>>
  fetchUsedMeasurementDefinitionsRaw() async =>
      MeasurementDao(await database).fetchUsedMeasurementDefinitionsRaw();

  Future<List<MeasurementDefinition>>
  fetchClassMeasurementDefinitions() async =>
      MeasurementDao(await database).fetchClassMeasurementDefinitions();

  Future<List<MeasurementDefinition>>
  fetchUsedClassMeasurementDefinitions() async =>
      MeasurementDao(await database).fetchUsedClassMeasurementDefinitions();

  Future<Map<String, dynamic>?> fetchMeasurementById(int id) async =>
      MeasurementDao(await database).fetchMeasurementById(id);

  Future<void> updateMeasurement({
    required int measurementId,
    required DateTime timestamp,
    required double value,
    required String unit,
    String? note,
    MeasurementContext? context,
  }) async => MeasurementDao(await database).updateMeasurement(
    measurementId: measurementId,
    timestamp: timestamp,
    value: value,
    unit: unit,
    note: note,
    context: context,
  );

  Future<void> deleteMeasurement(int measurementId) async =>
      MeasurementDao(await database).deleteMeasurement(measurementId);

  /// Fetch all equipment names.
  Future<List<String>> fetchAllEquipmentNames() async {
    final db = await database;
    return LookupDao.getAllEquipmentNames(db);
  }

  /// Fetch all body-part IDs and names.
  Future<List<BodyPart>> fetchAllBodyParts() async {
    final db = await database;
    return LookupDao.getAllBodyParts(db);
  }

  /// Fetch all muscle names.
  Future<List<Muscle>> fetchAllMuscles() async {
    final db = await database;
    return LookupDao.getAllMuscles(db);
  }

  Future<List<String>> fetchAllMuscleNames() async {
    final db = await database;
    return LookupDao.getAllMuscleNames(db);
  }

  /// Fetch stretches by an optional bodypart ID (or all if null).
  Future<List<StretchDefinition>> fetchStretches({int? bodypartId}) async {
    final db = await database;
    return LookupDao.getStretches(db, bodypartId);
  }

  Future<String?> fetchStretchDefinitionNameById(int stretchId) async {
    final db = await database;
    return LookupDao.getStretchDefinitionNameById(db, stretchId);
  }

  Future<List<Equipment>> fetchAllEquipment() async {
    final db = await database;
    return LookupDao.getAllEquipment(db);
  }

  Future<int> createEquipment(String name) async {
    final db = await database;
    return LookupDao.insertEquipment(db, name);
  }

  Future<void> updateEquipment(int id, String name) async {
    final db = await database;
    await LookupDao.updateEquipment(db, id, name);
  }

  Future<void> deleteEquipment(int id) async {
    final db = await database;
    await LookupDao.deleteEquipment(db, id);
  }

  Future<List<BodyPart>> fetchAllBodyPartsFull() async {
    final db = await database;
    return LookupDao.getAllBodyParts(db);
  }

  Future<int> createBodyPart(String name) async {
    final db = await database;
    return LookupDao.insertBodyPart(db, name);
  }

  Future<void> updateBodyPartEntry(int id, String name) async {
    final db = await database;
    await LookupDao.updateBodyPart(db, id, name);
  }

  Future<void> deleteBodyPartEntry(int id) async {
    final db = await database;
    await LookupDao.deleteBodyPart(db, id);
  }

  Future<List<Muscle>> fetchAllMusclesFull() async {
    final db = await database;
    return LookupDao.getAllMuscles(db);
  }

  Future<int> createMuscle(String name) async {
    final db = await database;
    return LookupDao.insertMuscle(db, name);
  }

  Future<void> updateMuscleEntry(int id, String name) async {
    final db = await database;
    await LookupDao.updateMuscle(db, id, name);
  }

  Future<void> deleteMuscleEntry(int id) async {
    final db = await database;
    await LookupDao.deleteMuscle(db, id);
  }

  /// Rerun JSON-seeding for lookup tables & stretches.
  Future<void> reseedLookupData() async {
    final db = await database;
    await Seed.seedLookupsAndExercises(db);
    await Seed.seedStretches(db);
  }

  Future<DatabaseHealthSnapshot> getDatabaseHealthSnapshot() async {
    final db = await database;
    final path = await _dbFilePath();
    final dbFile = File(path);
    final walFile = File('$path-wal');
    final shmFile = File('$path-shm');

    Future<int> fileLength(File file) async {
      try {
        return await file.exists() ? await file.length() : 0;
      } catch (_) {
        return 0;
      }
    }

    Future<int> intPragma(String pragma) async {
      try {
        return Sqflite.firstIntValue(await db.rawQuery('PRAGMA $pragma')) ?? 0;
      } catch (_) {
        return 0;
      }
    }

    String journalMode = 'unknown';
    try {
      final rows = await db.rawQuery('PRAGMA journal_mode');
      if (rows.isNotEmpty && rows.first.values.isNotEmpty) {
        journalMode = rows.first.values.first.toString();
      }
    } catch (_) {
      journalMode = 'unknown';
    }

    final schemaVersion = await db.getVersion();
    final pageCount = await intPragma('page_count');
    final pageSize = await intPragma('page_size');
    final tableCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM sqlite_master "
            "WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
          ),
        ) ??
        0;
    final indexCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM sqlite_master "
            "WHERE type = 'index' AND name NOT LIKE 'sqlite_%'",
          ),
        ) ??
        0;
    final triggerCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM sqlite_master WHERE type = 'trigger'",
          ),
        ) ??
        0;

    return DatabaseHealthSnapshot(
      path: path,
      schemaVersion: schemaVersion,
      targetSchemaVersion: _kDbVersion,
      journalMode: journalMode,
      databaseBytes: await fileLength(dbFile),
      walBytes: await fileLength(walFile),
      shmBytes: await fileLength(shmFile),
      pageCount: pageCount,
      pageSize: pageSize,
      tableCount: tableCount,
      indexCount: indexCount,
      triggerCount: triggerCount,
      foodCount: await _countRowsIfTableExists(db, 'foods'),
      foodFtsCount: await _countRowsIfTableExists(db, 'food_search_fts'),
      checkedAt: DateTime.now(),
    );
  }

  Future<DatabaseMaintenanceResult> runDatabaseIntegrityCheck() async {
    final db = await database;
    final rows = await db.rawQuery('PRAGMA integrity_check');
    final messages = rows
        .map((row) => row.values.isEmpty ? '' : row.values.first.toString())
        .where((message) => message.isNotEmpty)
        .toList();
    final ok = messages.length == 1 && messages.first.toLowerCase() == 'ok';

    return DatabaseMaintenanceResult(
      title: 'Integrity Check',
      message: ok ? 'Database integrity check passed.' : messages.join('\n'),
      rows: rows.map((row) => Map<String, Object?>.from(row)).toList(),
    );
  }

  Future<DatabaseMaintenanceResult> optimizeDatabase() async {
    final db = await database;
    await db.rawQuery('PRAGMA optimize');
    return const DatabaseMaintenanceResult(
      title: 'Optimize Database',
      message: 'SQLite optimize completed.',
    );
  }

  Future<DatabaseMaintenanceResult> checkpointWal() async {
    final db = await database;
    final rows = await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
    return DatabaseMaintenanceResult(
      title: 'WAL Checkpoint',
      message: 'Write-ahead log checkpoint completed.',
      rows: rows.map((row) => Map<String, Object?>.from(row)).toList(),
    );
  }

  Future<DatabaseMaintenanceResult> vacuumDatabase() async {
    final db = await database;
    await db.execute('VACUUM');
    return const DatabaseMaintenanceResult(
      title: 'Vacuum Database',
      message: 'Database vacuum completed.',
    );
  }

  DatabaseImportPreview previewDatabaseImport(String jsonStr) {
    return inspectDatabaseImport(jsonStr, currentSchemaVersion: _kDbVersion);
  }

  /// Export the entire database to a JSON string.
  Future<String> exportDatabase() async {
    final db = await database;
    final tables = kDatabaseExportTableNames;
    final existingTables = await _tableNames(db);
    final missingRequiredTables = tables
        .where((table) => !existingTables.contains(table))
        .toList();
    if (missingRequiredTables.isNotEmpty) {
      throw StateError(
        'Database backup cannot be created because required tables are missing.',
      );
    }

    final Map<String, dynamic> data = {};
    await db.transaction((txn) async {
      for (final table in tables) {
        data[table] = await txn.query(table);
      }
    });
    return jsonEncode(
      buildDatabaseExportEnvelope(schemaVersion: _kDbVersion, tables: data),
    );
  }

  /// Imports a database backup from JSON.
  ///
  /// Full v3 snapshots replace authoritative rows atomically. Older or partial
  /// exports are merged without clearing existing rows first, so they cannot
  /// erase unrelated current data that the old format did not contain.
  Future<void> importDatabase(String jsonStr, {bool clearFirst = true}) async {
    final db = await database;
    final preview = previewDatabaseImport(jsonStr);
    if (!preview.canImport) {
      throw FormatException(preview.message);
    }
    final data = decodeDatabaseExportTables(jsonStr);
    final tablesToRestore = kDatabaseExportTableNames
        .where(data.containsKey)
        .toList();
    final replaceSnapshot = clearFirst && preview.canReplace;
    var committed = false;

    final suspendFoodFtsTriggers = await _hasFoodFtsTable(db);
    if (suspendFoodFtsTriggers) {
      await _dropFoodFtsTriggers(db);
    }

    try {
      final foreignKeySetting =
          Sqflite.firstIntValue(await db.rawQuery('PRAGMA foreign_keys')) ?? 0;
      await db.execute('PRAGMA foreign_keys = OFF;');
      try {
        await db.transaction((txn) async {
          final existingTables = await _tableNames(txn);
          if (replaceSnapshot) {
            final missingLocalTables = kDatabaseExportTableNames
                .where((table) => !existingTables.contains(table))
                .toList();
            if (missingLocalTables.isNotEmpty) {
              throw StateError(
                'Current database cannot accept a complete backup because required tables are missing.',
              );
            }
          }
          if (replaceSnapshot) {
            // Remove snapshot rows in reverse dependency order. Tables omitted
            // from the backup contract are either rebuilt or discarded below.
            final tablesToClear = kDatabaseExportTableNames.reversed;
            for (final table in tablesToClear) {
              if (existingTables.contains(table)) {
                await txn.delete(table);
              }
            }
          }

          // Derived/cache/app-owned rows must never survive a full replacement
          // if they point at the prior snapshot's local IDs.
          for (final table in kDatabaseDerivedOrDiscardedTableNames) {
            if (existingTables.contains(table)) {
              await txn.delete(table);
            }
          }

          // Restore only authoritative snapshot rows. Legacy exports may carry
          // cache rows; their policy intentionally ignores them.
          for (final table in tablesToRestore) {
            if (!existingTables.contains(table)) continue; // skip unknown
            final rows = List<Map<String, dynamic>>.from(data[table] as List);
            if (rows.isEmpty) continue;
            final columnInfo = await _tableColumnInfo(txn, table);
            for (final row in rows) {
              final sane = await _sanitizeRowForTable(
                txn,
                table,
                row,
                columnInfo: columnInfo,
              );
              if (sane.isNotEmpty) {
                await txn.insert(
                  table,
                  sane,
                  conflictAlgorithm: ConflictAlgorithm.replace,
                );
              }
            }
          }

          // Keep every authoritative data mutation inside this transaction so
          // a malformed import or storage failure cannot replace only part of
          // the person's existing database.
          await _backfillNormalizedFoodKeysTx(txn);
          await _backfillEnergyKcalFromMacros(txn);

          await _bumpAutoincrement(txn);

          final foreignKeyViolations = await txn.rawQuery(
            'PRAGMA foreign_key_check',
          );
          if (foreignKeyViolations.isNotEmpty) {
            throw StateError(
              'Imported database has ${foreignKeyViolations.length} foreign key '
              'violation(s).',
            );
          }
        });
        committed = true;
      } finally {
        if (foreignKeySetting == 1) {
          await db.execute('PRAGMA foreign_keys = ON;');
        }
      }
      // The imported history must be canonical before any following reader can
      // observe it. Derived search/index maintenance remains best-effort.
      await Schema.migrateV61(db);

      // Re-seed current app-owned catalog rows after a full snapshot. The
      // policy clears catalog state, so stable catalog IDs reconcile instead
      // of leaving the backup's bundled revision in control.
      await _ensureAppMetaTable(db);
      if (replaceSnapshot) {
        await Seed.syncExerciseCatalogIfNeeded(db);
        await Seed.syncCreatorExerciseAllocationDefaults(db);
      }

      // Rebuild derived results from restored authoritative data. These are
      // intentionally not serialized as backup payload.
      if (await _tableExists(db, 'recipes')) {
        await _rebuildAllRecipeCaches(db);
      }
      await WorkoutRecordEventsDao.rebuildAll(db);
      await _rebuildFoodFtsIfExists(db);
      await Schema.migrateV49(db);
      await _ensureIndexes(db);
    } catch (error, stackTrace) {
      if (committed) {
        Error.throwWithStackTrace(
          DatabaseImportCommittedException(error),
          stackTrace,
        );
      }
      rethrow;
    } finally {
      if (suspendFoodFtsTriggers) {
        try {
          await _ensureFoodFtsTriggers(db);
        } catch (_) {
          // Search falls back safely until maintenance can recreate triggers.
        }
      }
    }
  }

  // equipment.json
  Future<String> exportEquipmentJson() async =>
      CatalogJsonExportDao(await database).exportEquipmentJson();

  /// bodyparts.json
  Future<String> exportBodypartsJson() async =>
      CatalogJsonExportDao(await database).exportBodypartsJson();

  /// muscles.json
  Future<String> exportMusclesJson() async =>
      CatalogJsonExportDao(await database).exportMusclesJson();

  /// exercises.json
  Future<String> exportExercisesJson() async =>
      CatalogJsonExportDao(await database).exportExercisesJson();

  /// stretches.json
  Future<String> exportStretchesJson() async =>
      CatalogJsonExportDao(await database).exportStretchesJson();

  /// muscle_bodypart.json
  Future<String> exportMuscleBodypartJson() async =>
      CatalogJsonExportDao(await database).exportMuscleBodypartJson();

  /// bodypart_ranking.json
  Future<String> exportBodypartRankingJson() async =>
      CatalogJsonExportDao(await database).exportBodypartRankingJson();

  /// muscle_ranking.json
  Future<String> exportMuscleRankingJson() async =>
      CatalogJsonExportDao(await database).exportMuscleRankingJson();

  /// bodypart_muscle_rankings.json
  Future<String> exportBodypartMuscleRankingsJson() async =>
      CatalogJsonExportDao(await database).exportBodypartMuscleRankingsJson();

  /// volume_boundaries.json
  Future<String> exportVolumeBoundariesJson() async =>
      CatalogJsonExportDao(await database).exportVolumeBoundariesJson();

  /// Performs fuzzy search on exercise definition names.
  Future<List<ExerciseDefinition>> fuzzsearchExercises(String term) async {
    final db = await database;
    return DefinitionDao.fuzzsearchExerciseDefinitions(db, term);
  }

  // stats_dao.dart methods:

  /// Upsert a rep-max stat row.
  Future<void> upsertRepMax(
    int defId,
    int repCount,
    String timeframe,
    double rmValue,
    double oneErm,
    bool isErm,
  ) async =>
      RankingAndVolumeDao(await database)
          .upsertRepMax(defId, repCount, timeframe, rmValue, oneErm, isErm);

  /// Upsert a volume-max stat row.
  Future<void> upsertVolumeMax(
    int defId,
    String timeframe,
    double vmValue,
  ) async =>
      RankingAndVolumeDao(await database)
          .upsertVolumeMax(defId, timeframe, vmValue);

  // —————————————— Rep-Max + Volume-Max Queries ——————————————

  /// Returns list of rep-max rows for [defId] & [timeframe].
  Future<List<Map<String, dynamic>>> getRepMaxes(
    int defId,
    String timeframe,
  ) async => RankingAndVolumeDao(await database).getRepMaxes(defId, timeframe);

  /// Returns the volume-max row (or null) for [defId] & [timeframe].
  Future<Map<String, dynamic>?> getVolumeMax(
    int defId,
    String timeframe,
  ) async => RankingAndVolumeDao(await database).getVolumeMax(defId, timeframe);

  Future<double> calculateTotalVolumeForSessions(List<int> sessionIds) async =>
      RankingAndVolumeDao(await database)
          .calculateTotalVolumeForSessions(sessionIds);

  // ─── Formula Settings ──────────────────────────────────────

  static const _stepKey = 'step';
  static const _minKey = 'min';
  static const _maxKey = 'max';

  /// Reads a formula parameter or returns [fallback].
  Future<double> _getFormulaParam(String key, double fallback) async {
    final db = await database;
    final v = await FormulaSettingsDao.getParam(db, key);
    return v ?? fallback;
  }

  Future<double> getFormulaStep() => _getFormulaParam(_stepKey, 0.05);
  Future<double> getFormulaMin() => _getFormulaParam(_minKey, 0.0);
  Future<double> getFormulaMax() => _getFormulaParam(_maxKey, 1.0);

  Future<void> setFormulaStep(double step) async {
    final db = await database;
    await FormulaSettingsDao.setParam(db, _stepKey, step);
  }

  Future<void> setFormulaMin(double min) async {
    final db = await database;
    await FormulaSettingsDao.setParam(db, _minKey, min);
  }

  Future<void> setFormulaMax(double max) async {
    final db = await database;
    await FormulaSettingsDao.setParam(db, _maxKey, max);
  }

  // ─── ANALYTICS ─────────────────────────────────────────────

  Future<int> linkMuscleToBodyPart(int muscleId, int bodypartId) async =>
      RankingAndVolumeDao(await database)
          .linkMuscleToBodyPart(muscleId, bodypartId);

  Future<int> unlinkMuscleFromBodyPart(int muscleId, int bodypartId) async =>
      RankingAndVolumeDao(await database)
          .unlinkMuscleFromBodyPart(muscleId, bodypartId);

  Future<List<MuscleBodyPart>> fetchBodyPartsForMuscle(int muscleId) async =>
      RankingAndVolumeDao(await database).fetchBodyPartsForMuscle(muscleId);

  Future<List<MuscleBodyPart>> fetchMusclesForBodyPart(int bodypartId) async =>
      RankingAndVolumeDao(await database).fetchMusclesForBodyPart(bodypartId);

  Future<int> setBodyPartRank(int bodypartId, int rank) async =>
      RankingAndVolumeDao(await database).setBodyPartRank(bodypartId, rank);

  Future<BodyPartRanking?> getBodyPartRank(int bodypartId) async =>
      RankingAndVolumeDao(await database).getBodyPartRank(bodypartId);

  Future<List<BodyPartRanking>> getAllBodyPartRanks() async =>
      RankingAndVolumeDao(await database).getAllBodyPartRanks();

  Future<int> deleteBodyPartRank(int bodypartId) async =>
      RankingAndVolumeDao(await database).deleteBodyPartRank(bodypartId);

  Future<int> setMuscleRank(int muscleId, int rank) async =>
      RankingAndVolumeDao(await database).setMuscleRank(muscleId, rank);

  Future<MuscleRanking?> getMuscleRank(int muscleId) async =>
      RankingAndVolumeDao(await database).getMuscleRank(muscleId);

  Future<List<MuscleRanking>> getAllMuscleRanks() async =>
      RankingAndVolumeDao(await database).getAllMuscleRanks();

  Future<int> deleteMuscleRank(int muscleId) async =>
      RankingAndVolumeDao(await database).deleteMuscleRank(muscleId);

  Future<int> setExerciseMuscleHitPercent(
    int defId,
    int muscleId,
    double pct,
  ) async =>
      RankingAndVolumeDao(await database)
          .setExerciseMuscleHitPercent(defId, muscleId, pct);

  Future<ExerciseMusclePercent?> fetchExerciseMusclePercent(
    int defId,
    int muscleId,
  ) async =>
      RankingAndVolumeDao(await database)
          .fetchExerciseMusclePercent(defId, muscleId);

  Future<int> removeExerciseMusclePercent(int defId, int muscleId) async =>
      RankingAndVolumeDao(await database)
          .removeExerciseMusclePercent(defId, muscleId);

  Future<List<ExerciseMusclePercent>> fetchPercentsForExercise(
    int defId,
  ) async =>
      RankingAndVolumeDao(await database).fetchPercentsForExercise(defId);

  Future<int> setMuscleVolumeBounds(int muscleId, VolumeBoundaries b) async =>
      RankingAndVolumeDao(await database).setMuscleVolumeBounds(muscleId, b);

  Future<VolumeBoundaries?> fetchMuscleVolumeBounds(int muscleId) async =>
      RankingAndVolumeDao(await database).fetchMuscleVolumeBounds(muscleId);

  Future<List<Map<String, dynamic>>> fetchAllMuscleVolumeBounds() async =>
      RankingAndVolumeDao(await database).fetchAllMuscleVolumeBounds();

  Future<int> removeMuscleVolumeBounds(int muscleId) async =>
      RankingAndVolumeDao(await database).removeMuscleVolumeBounds(muscleId);

  Future<int> setBodyPartVolumeBounds(
    int bodyPartId,
    VolumeBoundaries bounds,
  ) async =>
      RankingAndVolumeDao(await database)
          .setBodyPartVolumeBounds(bodyPartId, bounds);

  Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) async =>
      RankingAndVolumeDao(await database).fetchBodyPartVolumeBounds(bodyPartId);

  Future<List<Map<String, dynamic>>> fetchAllBodyPartVolumeBounds() async =>
      RankingAndVolumeDao(await database).fetchAllBodyPartVolumeBounds();

  Future<int> removeBodyPartVolumeBounds(int bodyPartId) async =>
      RankingAndVolumeDao(await database)
          .removeBodyPartVolumeBounds(bodyPartId);

  /// Fetch manual body-part percent overrides for an exercise definition
  Future<List<ExerciseBodyPartPercent>> fetchBodyPartPercentsManual(
    int defId,
  ) async =>
      RankingAndVolumeDao(await database).fetchBodyPartPercentsManual(defId);

  /// Upsert a manual body-part percent override
  Future<int> setExerciseBodyPartPercent(
    int defId,
    int bpId,
    double pct,
  ) async =>
      RankingAndVolumeDao(await database)
          .setExerciseBodyPartPercent(defId, bpId, pct);

  /// Delete a manual body-part percent override
  Future<int> deleteExerciseBodyPartPercent(int defId, int bpId) async =>
      RankingAndVolumeDao(await database)
          .deleteExerciseBodyPartPercent(defId, bpId);

  /// Fetches rep‐max rows and maps to model.
  Future<List<RepMaxRow>> fetchRepMaxes(int defId, String timeframe) async =>
      RankingAndVolumeDao(await database).fetchRepMaxes(defId, timeframe);

  /// Fetches a volume‐max value (or null).
  Future<double?> fetchVolumeMax(int defId, String timeframe) async =>
      RankingAndVolumeDao(await database).fetchVolumeMax(defId, timeframe);

  // ─── Exercise allocation resolution ────────────────────────

  /// Returns the source-aware anatomy allocation for one exercise.
  ///
  /// New personal values and future creator values are resolved here, while
  /// legacy percent rows are preserved as a compatibility source.
  Future<ResolvedExerciseAllocation> resolveExerciseAllocation(
    int defId,
  ) async {
    return ExerciseAllocationResolver.resolve(await database, defId);
  }

  Future<void> setPersonalExerciseAllocationCredit({
    required int defId,
    required ExerciseAllocationDimension dimension,
    required int targetId,
    required double credit,
  }) async {
    if (!credit.isFinite || credit < 0) {
      throw ArgumentError.value(
        credit,
        'credit',
        'Set credit must be a finite value of zero or more.',
      );
    }
    final current = await resolveExerciseAllocation(defId);
    final credits = Map<int, double>.from(
      dimension == ExerciseAllocationDimension.muscle
          ? current.muscleCredits
          : current.bodyPartCredits,
    );
    credits[targetId] = credit;
    await ExerciseAllocationDao.replacePersonalCredits(
      await database,
      exerciseDefinitionId: defId,
      dimension: dimension,
      credits: credits,
    );
  }

  Future<void> replacePersonalExerciseAllocationCredits({
    required int defId,
    required ExerciseAllocationDimension dimension,
    required Map<int, double> credits,
  }) async {
    if (credits.values.any((credit) => !credit.isFinite || credit < 0)) {
      throw ArgumentError(
        'Personal allocation credits must be finite and non-negative.',
      );
    }
    await ExerciseAllocationDao.replacePersonalCredits(
      await database,
      exerciseDefinitionId: defId,
      dimension: dimension,
      credits: credits,
    );
  }

  Future<void> resetPersonalExerciseAllocation({
    required int defId,
    required ExerciseAllocationDimension dimension,
  }) async {
    await ExerciseAllocationDao.resetPersonalCredits(
      await database,
      exerciseDefinitionId: defId,
      dimension: dimension,
    );
  }

  /// Creator defaults are content-owned. This API exists for content seeding
  /// and tests, not normal user-facing settings.
  Future<void> replaceCreatorExerciseAllocationCredits({
    required int defId,
    required ExerciseAllocationDimension dimension,
    required Map<int, double> credits,
  }) async {
    if (credits.values.any((credit) => !credit.isFinite || credit < 0)) {
      throw ArgumentError(
        'Creator allocation credits must be finite and non-negative.',
      );
    }
    await ExerciseAllocationDao.replaceCreatorCredits(
      await database,
      exerciseDefinitionId: defId,
      dimension: dimension,
      credits: credits,
    );
  }

  Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) async {
    final def = await getExerciseDefinitionById(defId);
    if (def == null) return [];
    final allocation = await resolveExerciseAllocation(defId);

    return def.muscles.map((rm) {
      return ExerciseMusclePercent(
        exerciseDefId: defId,
        muscleId: rm.muscle.id,
        percent: allocation.muscleCredits[rm.muscle.id] ?? 0.0,
      );
    }).toList();
  }

  Future<Map<BodyPart, double>> computeBodyPartPercents(int defId) async {
    final db = await database;
    final allocation = await resolveExerciseAllocation(defId);
    if (allocation.bodyPartCredits.isEmpty) return {};
    final bodyParts = await LookupDao.getAllBodyParts(db);
    final byId = {for (final bodyPart in bodyParts) bodyPart.id: bodyPart};
    return <BodyPart, double>{
      for (final entry in allocation.bodyPartCredits.entries)
        if (byId[entry.key] != null) byId[entry.key]!: entry.value,
    };
  }

  /// Estimate how one single set of [exerciseDefId] splits across its body-parts,
  /// *based on the definition’s muscle-percent hits*, not on logged history.
  Future<Map<BodyPart, double>> estimateBodyPartSetDistribution(
    int defId,
  ) async {
    return computeMuscleCalculatedBodyparts(defId);
  }

  /// For a given exercise definition, look at each associated muscle’s %-hit
  /// and push that % into every body-part that muscle maps to.
  Future<Map<BodyPart, double>> computeMuscleCalculatedBodyparts(
    int defId,
  ) async {
    final db = await database;
    final allocation = await resolveExerciseAllocation(defId);
    if (allocation.derivedBodyPartCredits.isEmpty) return {};
    final bodyParts = await LookupDao.getAllBodyParts(db);
    final byId = {for (final bodyPart in bodyParts) bodyPart.id: bodyPart};
    return <BodyPart, double>{
      for (final entry in allocation.derivedBodyPartCredits.entries)
        if (byId[entry.key] != null) byId[entry.key]!: entry.value,
    };
  }

  // ─── Session/Set Analytics ───────────────────────────────

  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async =>
      RankingAndVolumeDao(await database)
          .fetchAllBodyPartSetsOverTimeRange(start: start, end: end);

  ///// Fetches the total number of sets per body-part for a specific exercise definition
  /// over a given time range.
  Future<Map<BodyPart, double>> fetchBodyPartSetsForExerciseOverTimeRange({
    required int defId,
    required DateTime start,
    required DateTime end,
    int? setCountOverride,
    Map<int, BodyPart>? bodyPartByIdOverride,
  }) async =>
      RankingAndVolumeDao(await database)
          .fetchBodyPartSetsForExerciseOverTimeRange(
            defId: defId,
            start: start,
            end: end,
            setCountOverride: setCountOverride,
            bodyPartByIdOverride: bodyPartByIdOverride,
          );

  /// Fetches muscle set credits for a specific exercise definition over a time
  /// range. The allocation resolver retains the legacy manual-toggle behavior
  /// until an explicit creator or personal allocation replaces it.
  Future<Map<int, double>> fetchMuscleSetsForExerciseOverTimeRange({
    required int defId,
    required DateTime start,
    required DateTime end,
    int? setCountOverride,
  }) async => RankingAndVolumeDao(await database)
      .fetchMuscleSetsForExerciseOverTimeRange(
        defId: defId,
        start: start,
        end: end,
        setCountOverride: setCountOverride,
      );

  /// Fetches the total number of “muscle-units” across *all* definitions
  /// for weight exercises in the given time window.
  Future<Map<int, double>> fetchAllMuscleSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async =>
      RankingAndVolumeDao(await database)
          .fetchAllMuscleSetsOverTimeRange(start: start, end: end);

  // GYM PROFILES

  /// Creates a new gym profile and returns its ID.
  Future<int> createProfile(String name) async {
    final db = await database;
    final newId = await ProfileTransactionDao.saveGymProfile(
      db,
      existingProfile: null,
      name: name,
      equipmentIds: const <int>{},
    );
    // copy app‐wide methods into the new profile default:
    return newId;
  }

  Future<int> saveGymProfileAtomic({
    required GymProfile? existingProfile,
    required String name,
    required Set<int> equipmentIds,
  }) async {
    final db = await database;
    return ProfileTransactionDao.saveGymProfile(
      db,
      existingProfile: existingProfile,
      name: name,
      equipmentIds: equipmentIds,
    );
  }

  Future<Set<int>> loadActivePlans(int profileId) async {
    final db = await database;
    return ActivePlanDao.load(db, profileId);
  }

  Future<void> replaceActivePlans(int profileId, Set<int> presetIds) async {
    final db = await database;
    await ActivePlanDao.replace(db, profileId, presetIds);
  }

  Future<void> addActivePlan(int profileId, int presetId) async {
    final db = await database;
    await ActivePlanDao.add(db, profileId, presetId);
  }

  Future<void> removeActivePlan(int profileId, int presetId) async {
    final db = await database;
    await ActivePlanDao.remove(db, profileId, presetId);
  }

  Future<String?> getAppState(String key) async {
    final db = await database;
    await _ensureAppMetaTable(db);
    return _getAppMeta(db, key);
  }

  Future<void> setAppState(String key, String? value) async {
    final db = await database;
    await _ensureAppMetaTable(db);
    if (value == null) {
      await db.delete('app_meta', where: 'key = ?', whereArgs: [key]);
      return;
    }
    await _setAppMeta(db, key, value);
  }

  /// Retrieves all gym profiles.
  Future<List<GymProfile>> fetchAllProfiles() async {
    final db = await database;
    return GymProfileDao.getAllProfiles(db);
  }

  /// Updates an existing gym profile.
  Future<int> updateProfile(GymProfile profile) async {
    final db = await database;
    return GymProfileDao.updateProfile(db, profile);
  }

  /// Deletes a gym profile by ID.
  Future<int> deleteProfile(int profileId) async {
    final db = await database;
    return GymProfileDao.deleteProfile(db, profileId);
  }

  /// Adds equipment to a gym profile.
  Future<void> addEquipmentToProfile(int profileId, int equipmentId) async {
    final db = await database;
    await GymProfileDao.insertProfileEquipment(db, profileId, equipmentId);
  }

  /// Removes equipment from a gym profile.
  Future<void> removeEquipmentFromProfile(
    int profileId,
    int equipmentId,
  ) async {
    final db = await database;
    await GymProfileDao.deleteProfileEquipment(db, profileId, equipmentId);
  }

  /// Fetches equipment for a specific gym profile.
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async {
    final db = await database;
    return GymProfileDao.getEquipmentForProfile(db, profileId);
  }

  /// Look up an existing definition by name+equipment; throws if not found.
  Future<int> findExerciseDefinitionId(
    String name,
    String equipmentName,
  ) async {
    final db = await database;
    int? eqId;
    if (equipmentName.isNotEmpty) {
      final eqRows = await db.query(
        'equipment',
        where: 'name = ?',
        whereArgs: [equipmentName],
      );
      if (eqRows.isNotEmpty) eqId = eqRows.first['id'] as int;
    }
    final whereClause = eqId != null
        ? 'name = ? AND equipment_id = ?'
        : 'name = ? AND equipment_id IS NULL';
    final args = eqId != null ? [name, eqId] : [name];
    final rows = await db.query(
      'exercise_definitions',
      columns: ['id'],
      where: whereClause,
      whereArgs: args,
    );
    if (rows.isEmpty) {
      throw Exception('ExerciseDefinition("$name",$equipmentName) not found');
    }
    return rows.first['id'] as int;
  }

  /// Returns all sessions as WorkoutSession objects, sorted by date desc.
  Future<List<WorkoutSession>> fetchWorkoutSessions() async {
    // raw maps
    final raw = await getAllSessionsRaw();
    // map to model
    return raw
        .map(
          (row) => WorkoutSession(
            id: row['id'] as int,
            date: TemporalSemantics.readLocalDateTime(
              epochMilliseconds: row['completed_at_ms'],
              legacyIso: row['date'],
            ),
            calendarDayKey: TemporalSemantics.readCalendarDay(
              calendarDay: row['training_day'],
              legacyIso: row['date'],
              epochMilliseconds: row['completed_at_ms'],
            ).storageKey,
            duration: row['duration'] as int,
          ),
        )
        .toList();
  }

  // ─── PRESETS: Definition CRUD ─────────────────────────────

  Future<int> createPreset(
    String name, {
    int? profileId,
    bool isDraft = false,
  }) async {
    final db = await database;
    return PresetTransactionDao.createPreset(
      db,
      name: name,
      profileId: profileId,
      exercises: const <WorkoutExerciseWrite>[],
      isDraft: isDraft,
    );
    // copy profile‐default methods into this preset (if profileId != null)
  }

  Future<int> createPresetAtomic({
    required String name,
    required int? profileId,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
    bool activate = false,
    bool uniqueName = false,
    bool isDraft = false,
  }) async {
    final db = await database;
    return PresetTransactionDao.createPreset(
      db,
      name: name,
      profileId: profileId,
      exercises: exercises,
      autoSettings: autoSettings,
      activate: activate,
      uniqueName: uniqueName,
      isDraft: isDraft,
    );
  }

  Future<void> replacePresetAtomic({
    required int presetId,
    required String? name,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
    bool publishDraft = false,
  }) async {
    final db = await database;
    await PresetTransactionDao.replacePreset(
      db,
      presetId: presetId,
      name: name,
      exercises: exercises,
      autoSettings: autoSettings,
      publishDraft: publishDraft,
    );
  }

  Future<void> savePresetAutoConfigurationAtomic({
    required int presetId,
    required PresetAutoConfigurationWrite configuration,
  }) async {
    final db = await database;
    await PresetTransactionDao.saveAutoConfiguration(
      db,
      presetId: presetId,
      configuration: configuration,
    );
  }

  Future<int> findOrCreatePreset(String name, {int? profileId}) async {
    final db = await database;
    final whereClause = profileId != null
        ? 'name = ? AND profile_id = ? AND is_draft = 0'
        : 'name = ? AND profile_id IS NULL AND is_draft = 0';
    final whereArgs = profileId != null ? [name, profileId] : [name];
    final existing = await db.query(
      'preset_definitions',
      columns: ['id'],
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    return createPreset(name, profileId: profileId);
  }

  Future<Map<String, dynamic>?> fetchDraftPresetForProfile(
    int profileId,
  ) async {
    final db = await database;
    return PresetDefinitionDao.getDraftForProfile(db, profileId);
  }

  Future<void> deleteDraftPresetsForProfile(int profileId) async {
    final db = await database;
    await PresetDefinitionDao.deleteDraftsForProfile(db, profileId);
  }

  Future<List<Map<String, dynamic>>> fetchAllPresetsRaw({
    int? profileId,
  }) async {
    final db = await database;
    return PresetDefinitionDao.getAllPresetsRaw(db, profileId: profileId);
  }

  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({
    int? profileId,
  }) async {
    final db = await database;
    return PresetDefinitionDao.fetchPresetSummariesRaw(
      db,
      profileId: profileId,
    );
  }

  Future<List<Map<String, dynamic>>> fetchPresetFocusSetCountsRaw({
    required List<int> presetIds,
  }) async {
    if (presetIds.isEmpty) return const <Map<String, dynamic>>[];

    final db = await database;
    return PresetDefinitionDao.fetchPresetFocusSetCountsRaw(
      db,
      presetIds: presetIds,
    );
  }

  Future<PresetDefinition?> fetchPresetById(int presetId) async {
    final db = await database;
    final row = await PresetDefinitionDao.getPresetById(db, presetId);
    if (row == null) return null;
    return PresetDefinition.fromRow(row);
  }

  Future<void> updatePresetName(int presetId, String name) async {
    final db = await database;
    await PresetDefinitionDao.updatePresetName(db, presetId, name);
  }

  Future<void> deletePreset(int presetId) async {
    final db = await database;
    await PresetDefinitionDao.deletePreset(db, presetId);
  }

  // ─── PRESETS: Exercise CRUD ───────────────────────────────

  Future<int> addExerciseToPreset(
    int presetId,
    int? exerciseDefId,
    String type,
    int orderIndex,
  ) async {
    final db = await database;
    return PresetExerciseDao.insertPresetExercise(
      db: db,
      presetId: presetId,
      exerciseDefId: exerciseDefId,
      type: type,
      orderIndex: orderIndex,
    );
  }

  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async {
    final db = await database;
    return PresetExerciseDao.getExercisesForPreset(db, presetId);
  }

  Future<void> deletePresetExercises(int presetId) async {
    final db = await database;
    await PresetExerciseDao.deleteExercisesForPreset(db, presetId);
  }

  // ─── PRESETS: Detail CRUD ─────────────────────────────────

  Future<void> savePresetWeightSets(
    int presetExerciseId,
    List<ExerciseSet> parents,
    Map<int, List<ExerciseSet>> children,
  ) async {
    final db = await database;
    await PresetDetailDao.insertPresetSets(
      db: db,
      presetExerciseId: presetExerciseId,
      parentSets: parents,
      childChangeSets: children,
    );
  }

  Future<List<Map<String, dynamic>>> fetchPresetSets(
    int presetExerciseId,
  ) async {
    final db = await database;
    return PresetDetailDao.getPresetSets(db, presetExerciseId);
  }

  Future<void> savePresetCardio(
    int presetExerciseId,
    String cardioName,
    String? note,
    int plannedMinutes,
    int elapsedSeconds,
  ) async {
    final db = await database;
    await PresetDetailDao.insertPresetCardioDetails(
      db: db,
      presetExerciseId: presetExerciseId,
      cardioName: cardioName,
      note: note,
      plannedMinutes: plannedMinutes,
      elapsedSeconds: elapsedSeconds,
    );
  }

  Future<Map<String, dynamic>?> fetchPresetCardio(int presetExerciseId) async {
    final db = await database;
    return PresetDetailDao.getPresetCardioDetails(db, presetExerciseId);
  }

  Future<void> savePresetStretch(
    int presetExerciseId,
    List<Map<String, dynamic>> items,
  ) async {
    final db = await database;
    await PresetDetailDao.insertPresetStretchItems(
      db: db,
      presetExerciseId: presetExerciseId,
      items: items,
    );
  }

  Future<List<Map<String, dynamic>>> fetchPresetStretchItems(
    int presetExerciseId,
  ) async {
    final db = await database;
    return PresetDetailDao.getPresetStretchItems(db, presetExerciseId);
  }

  // ─── AUTOPRESET SETTINGS WRAPPERS ───────────────────────────────────────

  /// Fetches the global auto‐preset settings for a given preset.
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async {
    final db = await database;
    return PresetAutoSettingsDao.getAutoSettings(db, presetId);
  }

  /// Inserts or updates the global auto‐preset settings.
  Future<void> upsertPresetAutoSettings({
    required int presetId,
    required bool isAutomatic,
    required double globalIncrement,
    required bool skipFirstSet,
    required bool weightCheck,
    required bool repCheck,
    required bool volumeCheck,
    required bool adjustAllSets,
    required bool useManualSelect, // ← NEW
    String? manualSelectionJson, // ← NEW
    String? successCountMode,
  }) async {
    final db = await database;
    await PresetAutoSettingsDao.upsertAutoSettings(
      db,
      presetId: presetId,
      isAutomatic: isAutomatic,
      globalIncrement: globalIncrement,
      skipFirstSet: skipFirstSet,
      weightCheck: weightCheck,
      repCheck: repCheck,
      volumeCheck: volumeCheck,
      adjustAllSets: adjustAllSets,
      useManualSelect: useManualSelect, // ← PASS THROUGH
      manualSelectionJson: manualSelectionJson, // ← PASS THROUGH
      successCountMode: successCountMode,
    );
  }

  /// Deletes the auto‐preset settings (disables automatic) for a preset.
  Future<void> deletePresetAutoSettings(int presetId) async {
    final db = await database;
    await PresetAutoSettingsDao.deleteAutoSettings(db, presetId);
  }

  // ─── PER-EXERCISE OVERRIDES ──────────────────────────────────────────────

  /// Fetches the auto override (IA + rotation) for a specific preset exercise.
  /// Fetches auto overrides _including_ last_node.
  Future<Map<String, dynamic>?> fetchPresetExerciseAuto(
    int presetExerciseId,
  ) async {
    final db = await database;
    return PresetExerciseAutoDao.getExerciseAuto(db, presetExerciseId);
  }

  /// Inserts or updates the per-exercise IA override and last_set_index.
  /// Upsert with lastNode.
  Future<void> upsertPresetExerciseAuto({
    required int presetExerciseId,
    double? incrementAmount,
    required int lastSetIndex,
    String? lastNode,
  }) async {
    final db = await database;
    await PresetExerciseAutoDao.upsertExerciseAuto(
      db,
      presetExerciseId: presetExerciseId,
      incrementAmount: incrementAmount,
      lastSetIndex: lastSetIndex,
      lastNode: lastNode,
    );
  }

  /// Deletes the per-exercise auto override for a preset exercise.
  Future<void> deletePresetExerciseAuto(int presetExerciseId) async {
    final db = await database;
    await PresetExerciseAutoDao.deleteExerciseAuto(db, presetExerciseId);
  }

  // ─── PER-SET OVERRIDES ──────────────────────────────────────────────────

  /// Fetches the per-set IA override for a specific preset set.
  Future<Map<String, dynamic>?> fetchPresetSetAuto(int presetSetId) async {
    final db = await database;
    return PresetSetAutoDao.getSetAuto(db, presetSetId);
  }

  /// Inserts or updates the per-set IA override.
  Future<void> upsertPresetSetAuto({
    required int presetSetId,
    double? incrementAmount,
  }) async {
    final db = await database;
    await PresetSetAutoDao.upsertSetAuto(
      db,
      presetSetId: presetSetId,
      incrementAmount: incrementAmount,
    );
  }

  /// Deletes the per-set IA override for a preset set.
  Future<void> deletePresetSetAuto(int presetSetId) async {
    final db = await database;
    await PresetSetAutoDao.deleteSetAuto(db, presetSetId);
  }

  /// Update the target weight of a preset set.
  Future<void> updatePresetSetWeight(int presetSetId, double weight) async {
    final db = await database;
    await PresetDetailDao.updatePresetSetWeight(
      db: db,
      presetSetId: presetSetId,
      weight: weight,
    );
  }

  /// Fetch the flow‐graph JSON for a preset.
  Future<String> fetchFlowDefinition(int presetId) async {
    final db = await database;
    return PresetAutoSettingsDao.getFlowDefinition(db, presetId);
  }

  /// Save the flow‐graph JSON for a preset.
  Future<void> upsertFlowDefinition(int presetId, String flowJson) async {
    final db = await database;
    await PresetAutoSettingsDao.upsertFlowDefinition(db, presetId, flowJson);
  }

  /// Fetch all user‐defined methods for a preset.
  Future<List<Map<String, dynamic>>> fetchFlowMethods(int presetId) async {
    final db = await database;
    return PresetFlowMethodsDao.getMethods(db, presetId);
  }

  /// Insert or update a flow method; returns its new row ID.
  Future<int> upsertFlowMethod({
    required int presetId,
    required String name,
    required String type,
    required Map<String, dynamic> params,
  }) async {
    final db = await database;
    final paramsJson = jsonEncode(params);
    return PresetFlowMethodsDao.upsertMethod(
      db,
      presetId: presetId,
      name: name,
      type: type,
      paramsJson: paramsJson,
    );
  }

  /// Delete a flow method by ID.
  Future<int> deleteFlowMethod(int methodId) async {
    final db = await database;
    return PresetFlowMethodsDao.deleteMethod(db, methodId);
  }

  /// Atomically upserts a preset flow method, retargeting graph edges and
  /// deleting the old method row when renamed.
  Future<int> saveFlowMethodAtomic({
    required int presetId,
    required String name,
    required String type,
    required Map<String, dynamic> params,
    int? previousMethodId,
    String? previousName,
  }) async {
    final db = await database;
    return PresetFlowMethodsDao.saveMethodAtomic(
      db,
      presetId: presetId,
      name: name,
      type: type,
      paramsJson: jsonEncode(params),
      previousMethodId: previousMethodId,
      previousName: previousName,
    );
  }

  /// Atomically renames `method` graph edges for a preset.
  Future<void> renameFlowMethodReferences({
    required int presetId,
    required String oldName,
    required String newName,
  }) async {
    final db = await database;
    await PresetFlowMethodsDao.renameMethodReferences(
      db,
      presetId: presetId,
      oldName: oldName,
      newName: newName,
    );
  }

  /// Atomically removes `method` graph edges and deletes the preset rule row.
  Future<void> deleteFlowMethodAndReferences({
    required int presetId,
    required int methodId,
    required String methodName,
  }) async {
    final db = await database;
    await PresetFlowMethodsDao.deleteMethodAndReferences(
      db,
      presetId: presetId,
      methodId: methodId,
      methodName: methodName,
    );
  }

  Future<void> updatePresetSetReps(int presetSetId, int reps) async {
    final db = await database;
    await PresetDetailDao.updatePresetSetReps(
      db: db,
      presetSetId: presetSetId,
      reps: reps,
    );
  }

  Future<int> addPresetSet({
    required int presetExerciseId,
    required double weight,
    required int reps,
    required int orderIndex,
    int? parentSetId,
  }) async {
    final db = await database;
    return PresetDetailDao.addPresetSet(
      db: db,
      presetExerciseId: presetExerciseId,
      weight: weight,
      reps: reps,
      orderIndex: orderIndex,
      parentSetId: parentSetId,
    );
  }

  Future<int> deletePresetSet(int presetSetId) async {
    final db = await database;
    return PresetDetailDao.deletePresetSet(db: db, presetSetId: presetSetId);
  }

  /// Applies one workout's preset progression as a single transaction.
  Future<void> applyPresetProgressionBatch(
    PresetProgressionBatch progression,
  ) async {
    final db = await database;
    await PresetProgressionDao.apply(db, progression);
  }

  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async {
    final db = await database;
    return PendingWorkoutProgressionDao.loadAll(db);
  }

  Future<void> recordPendingWorkoutProgressionFailure(int sessionId) async {
    final db = await database;
    await PendingWorkoutProgressionDao.recordFailedAttempt(db, sessionId);
  }

  Future<void> completePendingWorkoutProgression({
    required int sessionId,
    required PresetProgressionBatch progression,
  }) async {
    final db = await database;
    await PendingWorkoutProgressionDao.applyAndDelete(
      db,
      sessionId: sessionId,
      progression: progression,
    );
  }

  Future<bool> getUseManualBodyparts(int defId) async {
    final db = await database;
    final r = await db.query(
      'exercise_definitions',
      columns: ['use_manual_bodyparts'],
      where: 'id = ?',
      whereArgs: [defId],
      limit: 1,
    );
    if (r.isEmpty) return false;
    final v = r.first['use_manual_bodyparts'];
    return v is int ? v == 1 : (v is bool ? v : false);
  }

  Future<void> setUseManualBodyparts(int defId, bool value) async {
    final db = await database;
    await db.update(
      'exercise_definitions',
      {'use_manual_bodyparts': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [defId],
    );
  }

  /// Returns whether the exercise definition uses manual muscle selection.
  Future<bool> getUseManualMuscles(int defId) async {
    final db = await database;
    final r = await db.query(
      'exercise_definitions',
      columns: ['use_manual_muscles'],
      where: 'id = ?',
      whereArgs: [defId],
      limit: 1,
    );
    if (r.isEmpty) return false;
    final v = r.first['use_manual_muscles'];
    return v is int ? v == 1 : (v is bool ? v : false);
  }

  /// Sets whether the exercise definition uses manual muscle selection.
  Future<void> setUseManualMuscles(int defId, bool v) async {
    final db = await database;
    await db.update(
      'exercise_definitions',
      {'use_manual_muscles': v ? 1 : 0},
      where: 'id = ?',
      whereArgs: [defId],
    );
  }

  /// Proxy onto DefinitionDao for multiply-by-rating.
  Future<bool> getMultiplyByRating(int defId) async {
    final db = await database; // ensure you await your getter
    return DefinitionDao.getMultiplyByRating(db, defId);
  }

  /// Proxy onto DefinitionDao for multiply-by-rating.
  Future<void> setMultiplyByRating(int defId, bool enabled) async {
    final db = await database; // unwrap the nullable
    await DefinitionDao.setMultiplyByRating(db, defId, enabled);
  }

  // ─── FLOW‐CHART DEFAULTS (v17 tables) ───────────────────────────────────

  /// Fetch the saved default flow JSON for either the whole app or a specific profile.
  Future<String> fetchDefaultFlow(String scope, {int? profileId}) async {
    final db = await database;
    return FlowDefaultsDao.fetchDefaultFlow(db, scope, profileId: profileId);
  }

  /// Upsert default flow JSON for scope=('app' or 'profile') and optional profileId.
  Future<void> upsertDefaultFlow(
    String scope, {
    int? profileId,
    required String flowJson,
  }) async {
    final db = await database;
    await FlowDefaultsDao.upsertDefaultFlow(
      db,
      scope,
      profileId: profileId,
      flowJson: flowJson,
    );
  }

  /// Delete a default flow entry.
  Future<int> deleteDefaultFlow(String scope, {int? profileId}) async {
    final db = await database;
    return FlowDefaultsDao.deleteDefaultFlow(db, scope, profileId: profileId);
  }

  /// Fetch all the methods attached to an app/profile default.
  Future<List<Map<String, dynamic>>> fetchDefaultFlowMethods(
    String scope, {
    int? profileId,
  }) async {
    final db = await database;
    return FlowDefaultsDao.fetchDefaultFlowMethods(
      db,
      scope,
      profileId: profileId,
    );
  }

  /// Upsert one method into the default‐methods table (conflict on PK(scope,profile_id,name)).
  Future<int> upsertDefaultFlowMethod(
    String scope, {
    int? profileId,
    required String name,
    required String type,
    required Map<String, dynamic> params,
  }) async {
    final db = await database;
    return FlowDefaultsDao.upsertDefaultFlowMethod(
      db,
      scope,
      profileId: profileId,
      name: name,
      type: type,
      params: params,
    );
  }

  /// Adds a new app default rule to existing profiles without changing
  /// profile-specific rules or saved flow graphs.
  Future<int> copyAppDefaultRuleToExistingProfiles({
    required String name,
    required String type,
    required Map<String, dynamic> params,
  }) async {
    final db = await database;
    return ProgressionRulePropagationDao.copyAppRuleToExistingProfiles(
      db,
      name: name,
      type: type,
      paramsJson: jsonEncode(params),
    );
  }

  /// Adds a new profile default rule to that profile's existing plans without
  /// replacing plan-specific rules or saved flow graphs.
  Future<int> copyProfileDefaultRuleToExistingPlans({
    required int profileId,
    required String name,
    required String type,
    required Map<String, dynamic> params,
  }) async {
    final db = await database;
    return ProgressionRulePropagationDao.copyProfileRuleToExistingPlans(
      db,
      profileId: profileId,
      name: name,
      type: type,
      paramsJson: jsonEncode(params),
    );
  }

  /// Delete one default method by name.
  Future<int> deleteDefaultFlowMethod(
    String scope, {
    int? profileId,
    required String name,
  }) async {
    final db = await database;
    return FlowDefaultsDao.deleteDefaultFlowMethod(
      db,
      scope,
      profileId: profileId,
      name: name,
    );
  }

  /// Atomically upserts a default flow method, retargeting graph edges and
  /// removing the previous rule row when renamed.
  Future<int> saveDefaultFlowMethodAtomic(
    String scope, {
    int? profileId,
    required String name,
    required String type,
    required Map<String, dynamic> params,
    String? previousName,
  }) async {
    final db = await database;
    return FlowDefaultsDao.saveDefaultFlowMethodAtomic(
      db,
      scope,
      profileId: profileId,
      name: name,
      type: type,
      params: params,
      previousName: previousName,
    );
  }

  /// Atomically renames `method` graph edges on an app or profile default flow.
  Future<void> renameDefaultFlowMethodReferences(
    String scope, {
    int? profileId,
    required String oldName,
    required String newName,
  }) async {
    final db = await database;
    await FlowDefaultsDao.renameDefaultFlowMethodReferences(
      db,
      scope,
      profileId: profileId,
      oldName: oldName,
      newName: newName,
    );
  }

  /// Atomically removes `method` graph edges and deletes the default rule row.
  Future<void> deleteDefaultFlowMethodAndReferences(
    String scope, {
    int? profileId,
    required String name,
  }) async {
    final db = await database;
    await FlowDefaultsDao.deleteDefaultFlowMethodAndReferences(
      db,
      scope,
      profileId: profileId,
      name: name,
    );
  }

  /// Returns a FlowDefinition for the given scope ('app' or 'profile') by
  /// delegating to the flow_defaults table and parsing its JSON.
  Future<FlowDefinition> fetchDefaultFlowDefinition(
    String scope, {
    int? profileId,
  }) async {
    // Reuse the string-based helper
    final jsonStr = await fetchDefaultFlow(scope, profileId: profileId);
    return FlowDefinition.fromJson(jsonStr);
  }

  // ── Forwarders that wrap the DAO ─────────────────────────────

  Future<PersonalInfo?> getPersonalInfo() async {
    final db = await database;
    return PersonalInfoDao(db).get();
  }

  Future<int> upsertPersonalInfo(PersonalInfo info) async {
    final db = await database;
    return PersonalInfoDao(db).upsert(info);
  }

  Future<void> savePersonalInfoWithBodyWeight({
    required PersonalInfo info,
    double? bodyWeightValue,
    required WeightUnit bodyWeightUnit,
    String? measurementNote,
  }) async {
    final db = await database;
    await PersonalInfoTransactionDao.save(
      db,
      info: info,
      bodyWeightValue: bodyWeightValue,
      bodyWeightUnit: bodyWeightUnit,
      measurementNote: measurementNote,
    );
  }

  // NUTIRITOINNNNN ------------------------------------

  Future<void> seedNutrientsIfEmpty() async {
    final d = NutritionDao(await database);
    await d.seedNutrientsIfEmpty();
  }

  // Foods & search
  Future<int> upsertFood(Food f) async =>
      NutritionDao(await database).upsertFood(f);
  Future<Food?> getFood(int id) async =>
      NutritionDao(await database).getFood(id);
  Future<List<Food>> searchFoods(String query, {int limit = 50}) async =>
      NutritionDao(await database).searchFoods(query, limit: limit);
  Future<int> upsertFoodPortion(FoodPortion p) async =>
      NutritionDao(await database).upsertFoodPortion(p);
  Future<List<FoodPortion>> getPortionsForFood(int foodId) async =>
      NutritionDao(await database).getPortionsForFood(foodId);
  Future<void> setDefaultPortion(int foodId, int portionId) async =>
      NutritionDao(await database).setDefaultPortion(foodId, portionId);

  // Nutrients
  Future<void> upsertFoodNutrients(int foodId, List<FoodNutrient> rows) async =>
      NutritionDao(await database).upsertFoodNutrients(foodId, rows);
  Future<Map<int, double>> getFoodNutrientsPer100g(int foodId) async =>
      NutritionDao(await database).getFoodNutrientsPer100g(foodId);

  Future<Map<String, double>> getFoodNutrientsPer100gByCode(int foodId) async {
    return NutritionDao(await database).getFoodNutrientsPer100gByCode(foodId);
  }

  Future<Map<String, double>> getMacroPer100gLegacySafe(int foodId) async {
    final all = await getFoodNutrientsPer100gByCode(foodId);

    double? pick(List<String> codes) {
      for (final code in codes) {
        final value = all[code];
        if (value != null) return value;
      }
      return null;
    }

    final out = <String, double>{};
    final protein = pick(['PROTEIN_G', 'PROTEIN']);
    if (protein != null) out['PROTEIN_G'] = protein;
    final carbs = pick(['CARB_G', 'CARB']);
    if (carbs != null) out['CARB_G'] = carbs;
    final fat = pick(['FAT_G', 'FAT']);
    if (fat != null) out['FAT_G'] = fat;
    final kcal = pick(['KCAL', 'ENERGY_KCAL', 'CALORIES']);
    if (kcal != null) out['KCAL'] = kcal;
    return out;
  }

  // Recipes
  Future<int> createOrUpdateRecipe(
    Recipe r,
    List<RecipeIngredient> ings,
  ) async => NutritionDao(await database).createOrUpdateRecipe(r, ings);
  Future<Recipe?> getRecipe(int id) async =>
      NutritionDao(await database).getRecipe(id);
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async =>
      NutritionDao(await database).getRecipeIngredients(recipeId);

  // Diary
  Future<int> addDiaryFood({
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    double? gramsOverride, // legacy
    double? loggedGrams, // NEW: forward to DAO
    DateTime? loggedAt, // NEW: forward to DAO
    String? notes,
  }) async => NutritionDao(await database).addDiaryFood(
    profileId: profileId,
    date: date,
    mealType: mealType,
    foodId: foodId,
    portionId: portionId,
    quantity: quantity,
    gramsOverride: gramsOverride,
    loggedGrams: loggedGrams, // <—
    loggedAt: loggedAt, // <—
    notes: notes,
  );

  Future<int> addDiaryRecipe({
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int recipeId,
    double quantity = 1.0,
    DateTime? loggedAt, // NEW: forward to DAO
    String? notes,
  }) async => NutritionDao(await database).addDiaryRecipe(
    profileId: profileId,
    date: date,
    mealType: mealType,
    recipeId: recipeId,
    quantity: quantity,
    loggedAt: loggedAt, // <—
    notes: notes,
  );

  Future<void> updateDiaryEntry(DiaryEntry e) async =>
      NutritionDao(await database).updateDiaryEntry(e);

  Future<void> deleteDiaryEntry(
    int id, {
    required int profileId,
    required DateTime date,
  }) async =>
      NutritionDao(await database)
          .deleteDiaryEntry(id, profileId: profileId, date: date);

  Future<List<DiaryEntry>> getDiaryEntriesForDate(
    int profileId,
    DateTime date,
  ) async =>
      NutritionDao(await database).getDiaryEntriesForDate(profileId, date);

  Future<List<DiaryEntryWithItem>> getDiaryEntriesWithItemsForDate(
    int profileId,
    DateTime day,
  ) async =>
      NutritionDao(await database)
          .getDiaryEntriesWithItemsForDate(profileId, day);

  // Goals
  Future<void> setGoals(NutritionGoal goal) async =>
      NutritionDao(await database).setGoals(goal);

  Future<NutritionGoal?> getActiveGoals(int profileId, DateTime date) async =>
      NutritionDao(await database).getActiveGoals(profileId, date);

  // Day totals cache
  Future<DayTotals> getDayTotals(int profileId, DateTime date) async =>
      NutritionDao(await database).getDayTotals(profileId, date);

  Future<void> recalcDayTotals(int profileId, DateTime date) async =>
      NutritionDao(await database).recalcDayTotals(profileId, date);

  Future<int> createCustomFood({required String name, String? brand}) async {
    return NutritionDao(await database)
        .insertCustomFood(name: name, brand: brand);
  }

  Future<void> savePer100gByCode(
    int foodId,
    Map<String, double> codeToAmount,
  ) async {
    await NutritionDao(await database)
        .replacePer100gByCode(foodId, codeToAmount);
  }

  Future<void> savePer100gFromLabelPayload(
    int foodId,
    Map<String, dynamic> payload,
  ) async {
    await NutritionDao(await database)
        .savePer100gFromLabelPayload(foodId, payload);
  }

  /// Extracts leaf labels from the customization payload and persists per-100g values
  /// using nutrient_aliases to resolve labels.
  Future<void> saveExtendedPer100gFromPayload(
    int foodId,
    Map<String, dynamic> payload,
  ) async {
    const skip = {
      'name',
      'brand',
      'calories',
      'protein_g',
      'carbs_g',
      'fats_g',
    };

    final aliasMap = <String, double>{};
    for (final entry in payload.entries) {
      final key = entry.key;
      if (skip.contains(key)) continue;

      final rawVal = entry.value;
      if (rawVal == null) continue;

      final val = (rawVal is num)
          ? rawVal.toDouble()
          : double.tryParse('$rawVal');
      if (val == null) continue;

      final lastGt = key.lastIndexOf('>');
      final alias = (lastGt == -1 ? key : key.substring(lastGt + 1)).trim();

      aliasMap[alias] = val;
    }
    if (aliasMap.isEmpty) return;
    await NutritionDao(await database).savePer100gByAlias(foodId, aliasMap);
  }

  Future<int> addPortion(
    int foodId, {
    required String measureName,
    double? gramWeight,
    double? mlVolume,
    bool isDefault = false,
    // v23 fields:
    String? listKind,
    int? sortOrder,
    double? amount,
    String? unit,
    String? label,
  }) async {
    return NutritionDao(await database).addPortion(
      foodId,
      measureName: measureName,
      gramWeight: gramWeight,
      mlVolume: mlVolume,
      isDefault: isDefault,
      listKind: listKind,
      sortOrder: sortOrder,
      amount: amount,
      unit: unit,
      label: label,
    );
  }

  Future<void> replacePortions(int foodId, List<FoodPortion> portions) async {
    await NutritionDao(await database).replacePortions(foodId, portions);
  }

  Future<void> updateFoodBasics(int id, {String? name, String? brand}) async {
    return NutritionDao(await database)
        .updateFoodBasics(id, name: name, brand: brand);
  }

  Future<void> updateFoodFromCustomizationPayload(Map payload) async {
    await FoodCustomizationDao.update(await database, payload);
  }

  Future<int> createFoodFromCustomizationPayload(Map payload) async {
    return FoodCustomizationDao.create(await database, payload);
  }

  // Normalized upsert using brand/source/category + barcodes
  Future<int> upsertFoodWithKeys({
    int? id,
    required String name,
    String? brandName,
    String? sourceName,
    String? categoryName,
    List<String> barcodes = const [],
    double? densityGPerMl,
    bool isCustom = false,
    String? dataSource,
    String? dataSourceId,
  }) async => NutritionDao(await database).upsertFoodWithKeys(
    id: id,
    name: name,
    brandName: brandName,
    sourceName: sourceName,
    categoryName: categoryName,
    barcodes: barcodes,
    densityGPerMl: densityGPerMl,
    isCustom: isCustom,
    dataSource: dataSource,
    dataSourceId: dataSourceId,
  );

  Future<Food?> getFoodByBarcode(String code) async =>
      NutritionDao(await database).getFoodByBarcode(code);

  Future<void> addBarcode(int foodId, String code) async {
    await NutritionDao(await database).addBarcode(foodId, code);
  }

  // Quick calculator for a portion selection
  Future<Map<String, double>> calcForPortion({
    required int foodId,
    required int portionId,
    double quantity = 1.0,
  }) async => NutritionDao(await database)
      .calcForPortion(foodId: foodId, portionId: portionId, quantity: quantity);

  // Optional: manual rebuild for FTS caller
  Future<void> rebuildFoodFts() async =>
      _rebuildFoodFtsIfExists(await database);

  Future<bool> _tableExists(DatabaseExecutor db, String name) async =>
      DatabaseMetadataDao.tableExists(db, name);

  Future<Set<String>> _tableNames(DatabaseExecutor db) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    return rows.map((row) => row['name']).whereType<String>().toSet();
  }

  Future<int> _countRowsIfTableExists(DatabaseExecutor db, String name) async {
    if (!await _tableExists(db, name)) return 0;
    try {
      return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $name'),
          ) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _rebuildAllRecipeCaches(Database db) async {
    final rows = await db.query('recipes', columns: ['id']);
    final dao = NutritionDao(db);
    for (final r in rows) {
      await dao.rebuildRecipeNutrientCache(r['id'] as int);
    }
  }

  /// Ensures KCAL exists per_100g for foods that have P/C/F but no KCAL yet.
  /// Also mirrors into legacy food_nutrients for back-compat reads.
  Future<void> _backfillEnergyKcalFromMacros(DatabaseExecutor db) async =>
      FoodFtsMaintenanceDao.backfillEnergyKcalFromMacros(db);

  // --- Diary (range) ---------------------------------------------------------
  Future<List<DiaryEntry>> getDiaryEntriesBetween(
    int profileId,
    DateTime start,
    DateTime end, {
    MealType? mealType,
    int limit = 1000,
  }) async {
    var s = start, e = end;
    if (s.isAfter(e)) {
      final t = s;
      s = e;
      e = t;
    }
    return NutritionDao(
      await database,
    ).getDiaryEntriesBetween(profileId, s, e, mealType: mealType, limit: limit);
  }

  // --- Day micro aggregation -------------------------------------------------
  Future<Map<String, double>> getDayMicros(
    int profileId,
    DateTime date,
    List<String> codes,
  ) async => NutritionDao(await database).getDayMicros(profileId, date, codes);

  // --- Favorites -------------------------------------------------------------
  Future<void> addFavorite(int profileId, int foodId) async =>
      NutritionDao(await database).addFavorite(profileId, foodId);

  Future<void> removeFavorite(int profileId, int foodId) async =>
      NutritionDao(await database).removeFavorite(profileId, foodId);

  Future<List<Food>> listFavorites(int profileId, {int limit = 100}) async =>
      NutritionDao(await database).listFavorites(profileId, limit: limit);

  // --- Recents ---------------------------------------------------------------
  Future<List<Food>> getRecentFoods(int profileId, {int limit = 20}) async =>
      NutritionDao(await database).getRecentFoods(profileId, limit: limit);

  Future<List<Recipe>> getRecentRecipes(
    int profileId, {
    int limit = 20,
  }) async =>
      NutritionDao(await database).getRecentRecipes(profileId, limit: limit);

  // --- Tags ------------------------------------------------------------------
  Future<void> addDiaryTag(int entryId, String tag) async =>
      NutritionDao(await database).addDiaryTag(entryId, tag);

  Future<void> removeDiaryTag(int entryId, String tag) async =>
      NutritionDao(await database).removeDiaryTag(entryId, tag);

  Future<List<String>> getTagsForEntry(int entryId) async =>
      NutritionDao(await database).getTagsForEntry(entryId);

  Future<List<DiaryEntry>> getEntriesByTag({
    required int profileId,
    required String tag,
    DateTime? start,
    DateTime? end,
    int limit = 200,
  }) async => NutritionDao(await database).getEntriesByTag(
    profileId: profileId,
    tag: tag,
    start: start,
    end: end,
    limit: limit,
  );

  // --- Recipe cache reads (handy for UI) ------------------------------------
  Future<Map<String, double>> getRecipePer100gByCode(int recipeId) async =>
      NutritionDao(await database).getRecipePer100gByCode(recipeId);

  Future<void> rebuildRecipeNutrientCache(int recipeId) async =>
      NutritionDao(await database).rebuildRecipeNutrientCache(recipeId);

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
    _dbFuture = null;
  }

  /// Removes only the explicitly named device-test database.
  ///
  /// This is intentionally guarded by compile-time defines so integration
  /// tests cannot accidentally clear a person's normal workout history.
  Future<void> resetIntegrationTestDatabase() async {
    if (!_kIntegrationTestMode ||
        _kDatabaseName != _kIntegrationTestDatabaseName) {
      throw StateError(
        'Integration database reset requires '
        'TONOS_INTEGRATION_TEST=true and '
        'TONOS_DATABASE_NAME=$_kIntegrationTestDatabaseName.',
      );
    }
    await close();
    await deleteDatabase(await _dbFilePath());
    FoodFtsMaintenanceDao.resetCapabilities();
  }

  Future<void> _bumpAutoincrement(DatabaseExecutor db) async {
    // sqlite_sequence only exists if at least one table was created with AUTOINCREMENT
    if (!await _tableExists(db, 'sqlite_sequence')) return;

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );

    for (final t in tables) {
      final name = t['name'] as String;

      // Only if there's an integer PK called `id`
      final cols = await db.rawQuery("PRAGMA table_info($name)");
      final hasIdPk = cols.any(
        (c) =>
            (c['name'] as String).toLowerCase() == 'id' &&
            (c['pk'] as int) == 1,
      );
      if (!hasIdPk) continue;

      final maxId =
          Sqflite.firstIntValue(
            await db.rawQuery("SELECT MAX(id) FROM $name"),
          ) ??
          0;

      // Update or insert sqlite_sequence row
      final exists =
          Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM sqlite_sequence WHERE name = ?",
              [name],
            ),
          ) ??
          0;

      if (exists > 0) {
        await db.rawUpdate(
          "UPDATE sqlite_sequence SET seq = ? WHERE name = ?",
          [maxId, name],
        );
      } else {
        // Will succeed only for AUTOINCREMENT tables; ignore otherwise
        try {
          await db.rawInsert(
            "INSERT INTO sqlite_sequence(name, seq) VALUES(?, ?)",
            [name, maxId],
          );
        } catch (_) {
          /* ignore */
        }
      }
    }
  }

  // Coerce any bool → 0/1. Leave everything else alone.
  Object? _sqlBool(Object? v) {
    if (v is bool) return v ? 1 : 0;
    return v;
  }

  // Numeric-ish column?
  bool _isNumericType(String? t) {
    if (t == null) return false;
    final up = t.toUpperCase();
    return up.contains('INT') || up.contains('REAL') || up.contains('NUM');
  }

  Future<Map<String, Map<String, Object?>>> _tableColumnInfo(
    DatabaseExecutor ex,
    String table,
  ) async {
    final cols = await ex.rawQuery('PRAGMA table_info($table)');
    return <String, Map<String, Object?>>{
      for (final c in cols) (c['name'] as String): c,
    };
  }

  // Filter a row to existing columns for [table], coerce booleans → 0/1,
  // and turn empty strings into NULL for numeric columns.
  Future<Map<String, Object?>> _sanitizeRowForTable(
    DatabaseExecutor ex,
    String table,
    Map row, {
    Map<String, Map<String, Object?>>? columnInfo,
  }) async {
    final info = columnInfo ?? await _tableColumnInfo(ex, table);

    final out = <String, Object?>{};
    row.forEach((k, v) {
      final key = k.toString();
      final meta = info[key];
      if (meta == null) return; // drop unknown columns (older schema)

      var val = _sqlBool(v);

      // If the column is numeric and value is an empty string → NULL
      if (val is String &&
          val.trim().isEmpty &&
          _isNumericType(meta['type'] as String?)) {
        val = null;
      }
      out[key] = val;
    });
    return out;
  }

  Future<String> _dbFilePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _kDatabaseName);
  }
}
