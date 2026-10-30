import 'dart:convert';

import 'package:env_test/db/database_helper.dart';
import 'package:env_test/db/schema.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/durable_active_session.dart';
import 'package:env_test/providers/nutrition_profile.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/widgets/exercise_card.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('bound NutritionProfile reuses SelectedProfile cold-start seeding without duplicate General profiles', () async {
    final repo = _SyncProfileRepository(initialProfiles: const []);
    final selectedProfile = SelectedProfile(repository: repo);
    final nutritionProfile = NutritionProfile(
      repository: repo,
      initialDay: DateTime(2026, 10, 29),
    )..bindSelectedProfile(selectedProfile);

    addTearDown(() {
      nutritionProfile.dispose();
      selectedProfile.dispose();
    });

    await Future.wait([selectedProfile.ready, nutritionProfile.ready]);

    expect(repo.saveGymProfileAtomicCalls, 1);
    expect(repo.createProfileCalls, 0);
    expect(selectedProfile.profiles, hasLength(1));
    expect(selectedProfile.currentProfile?.name, 'General');
    expect(nutritionProfile.profiles, hasLength(1));
    expect(nutritionProfile.current?.id, selectedProfile.currentProfile?.id);
    expect(nutritionProfile.totals?.kcal, 1800);
    expect(nutritionProfile.favoriteFoodIds, {101});
  });

  test('bound SelectedProfile and NutritionProfile synchronize switches, renames, creations, and database reloads', () async {
    final repo = _SyncProfileRepository(
      initialProfiles: [
        GymProfile(id: 1, name: 'Home Gym', createdAt: DateTime.utc(2026)),
        GymProfile(id: 2, name: 'Travel Gym', createdAt: DateTime.utc(2026)),
      ],
      persistedSelectedProfileId: '2',
    );
    final selectedProfile = SelectedProfile(repository: repo);
    final nutritionProfile = NutritionProfile(
      repository: repo,
      initialDay: DateTime(2026, 10, 29),
    )..bindSelectedProfile(selectedProfile);

    addTearDown(() {
      nutritionProfile.dispose();
      selectedProfile.dispose();
    });

    await Future.wait([selectedProfile.ready, nutritionProfile.ready]);
    expect(selectedProfile.currentProfile?.id, 2);
    expect(nutritionProfile.current?.id, 2);
    expect(nutritionProfile.totals?.kcal, 2200);
    expect(nutritionProfile.favoriteFoodIds, {202});

    // Switching from SelectedProfile updates NutritionProfile day totals and favorites.
    await selectedProfile.selectProfile(repo.profiles.first);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(nutritionProfile.current?.id, 1);
    expect(nutritionProfile.totals?.kcal, 1800);
    expect(nutritionProfile.favoriteFoodIds, {101});

    // Switching from NutritionProfile forwards back to SelectedProfile.
    await nutritionProfile.selectProfile(repo.profiles[1]);
    expect(selectedProfile.currentProfile?.id, 2);
    expect(repo.storedSelection, '2');
    expect(nutritionProfile.current?.id, 2);
    expect(nutritionProfile.totals?.kcal, 2200);

    // Renaming in SelectedProfile updates NutritionProfile.current.name.
    await selectedProfile.updateProfile(
      GymProfile(id: 2, name: 'Hotel Gym', createdAt: DateTime.utc(2026)),
    );
    expect(nutritionProfile.current?.name, 'Hotel Gym');

    // Creating from NutritionProfile creates once and updates both providers.
    await nutritionProfile.createAndSelectProfile('Competition Gym');
    expect(selectedProfile.currentProfile?.name, 'Competition Gym');
    expect(nutritionProfile.current?.name, 'Competition Gym');
    expect(selectedProfile.profiles, hasLength(3));
    expect(nutritionProfile.profiles, hasLength(3));

    // Simulating a database replacement with the same active profile ID
    // reloads day totals and favorites via reloadFromDatabase().
    final activeId = nutritionProfile.current!.id!;
    repo.kcalByProfile[activeId] = 3150;
    repo.favoritesByProfile[activeId] = [909];
    await nutritionProfile.reloadFromDatabase();
    expect(nutritionProfile.totals?.kcal, 3150);
    expect(nutritionProfile.favoriteFoodIds, {909});
  });

  test('ActiveSession pauses draft writes during database replace, resumes on abort, and reloads on success', () async {
    final repo = _ActiveSessionImportRepository();
    final session = ActiveSession(repository: repo, retryDelay: (_) async {});
    addTearDown(session.dispose);
    await session.ready;

    final started = await session.startWithExercises(
      workoutExercises: [
        WeightExercise(
          name: 'Bench Press',
          equipment: 'Barbell',
          sets: [ExerciseSet(weight: 100, reps: 5)],
        ),
      ],
      workoutCardTypes: const [CardType.weight],
    );
    expect(started, isTrue);
    expect(repo.draftSaveCount, 1);

    await session.prepareForDatabaseReplace();
    session.refresh();
    session.didChangeAppLifecycleState(AppLifecycleState.paused);
    await Future<void>.delayed(const Duration(milliseconds: 160));
    expect(repo.draftSaveCount, 1);

    // Failed import aborts replacement and allows draft persistence again.
    session.abortDatabaseReplace();
    session.didChangeAppLifecycleState(AppLifecycleState.paused);
    await Future<void>.delayed(Duration.zero);
    expect(repo.draftSaveCount, 2);
    expect(session.isActive, isTrue);

    // Successful import clears active draft and bumps completedSessionVersion.
    final priorCompletedVersion = session.completedSessionVersion;
    await session.prepareForDatabaseReplace();
    repo.persistedDraft = null;
    await session.reloadFromDatabase();

    expect(session.isActive, isFalse);
    expect(session.exercises, isEmpty);
    expect(session.completedSessionVersion, priorCompletedVersion + 1);
  });

  test('AppRepository.importDatabase clears cached exercise analysis and DatabaseHelper caches PRAGMA table_info per table', () async {
    final rawDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(rawDb.close);
    await Schema.createTables(rawDb);

    final countingDb = _PragmaCountingDatabase(rawDb);
    final helper = _MuscleCountingDatabaseHelper(countingDb);
    final repo = AppRepository(db: helper);

    final firstPercents = await repo.computeMusclePercents(7);
    final cachedPercents = await repo.computeMusclePercents(7);
    expect(helper.musclePercentCalls, 1);
    expect(firstPercents.single.percent, 60);
    expect(cachedPercents.single.percent, 60);

    helper.nextPercent = 85;
    final legacyMergePayload = jsonEncode({
      'sessions': [
        for (var i = 1; i <= 10; i++)
          {
            'id': i,
            'date': '2026-10-${i.toString().padLeft(2, '0')}T12:00:00.000Z',
            'duration': 30 + i * 5,
            'unknown_legacy_col': 'ignored',
          },
      ],
    });

    await repo.importDatabase(legacyMergePayload, clearFirst: false);

    // One PRAGMA table_info(sessions) for row sanitization + one inside
    // _bumpAutoincrement(txn) = 2 total across all 10 rows (constant O(1)).
    expect(countingDb.txnTableInfoCallsByTable['sessions'], 2);
    final importedSessions = await rawDb.query('sessions', orderBy: 'id ASC');
    expect(importedSessions, hasLength(10));
    expect(importedSessions[2]['duration'], 45);

    countingDb.txnTableInfoCallsByTable.clear();
    final largerPayload = jsonEncode({
      'sessions': [
        for (var i = 11; i <= 35; i++)
          {
            'id': i,
            'date':
                '2026-11-${(i - 10).toString().padLeft(2, '0')}T12:00:00.000Z',
            'duration': 50,
          },
      ],
    });
    await repo.importDatabase(largerPayload, clearFirst: false);
    expect(countingDb.txnTableInfoCallsByTable['sessions'], 2);
    expect(await rawDb.query('sessions'), hasLength(35));

    final refreshedPercents = await repo.computeMusclePercents(7);
    expect(helper.musclePercentCalls, 2);
    expect(refreshedPercents.single.percent, 85);
  });
}

class _SyncProfileRepository extends AppRepository {
  _SyncProfileRepository({
    required List<GymProfile> initialProfiles,
    this.persistedSelectedProfileId,
  }) : profiles = List<GymProfile>.of(initialProfiles);

  final List<GymProfile> profiles;
  String? persistedSelectedProfileId;
  String? get storedSelection => persistedSelectedProfileId;
  int _nextProfileId = 10;
  int saveGymProfileAtomicCalls = 0;
  int createProfileCalls = 0;

  final Map<int, double> kcalByProfile = {1: 1800, 2: 2200};
  final Map<int, List<int>> favoritesByProfile = {
    1: [101],
    2: [202],
  };

  @override
  Future<void> seedNutrientsIfEmpty() async {}

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => List.of(profiles);

  @override
  Future<List<Equipment>> fetchAllEquipment() async => [
    Equipment(1, 'Barbell'),
    Equipment(2, 'Dumbbell'),
  ];

  @override
  Future<int> saveGymProfileAtomic({
    required GymProfile? existingProfile,
    required String name,
    required Set<int> equipmentIds,
  }) async {
    saveGymProfileAtomicCalls++;
    final id = existingProfile?.id ?? (profiles.isEmpty ? 1 : _nextProfileId++);
    final created = GymProfile(
      id: id,
      name: name,
      createdAt: DateTime.utc(2026),
    );
    profiles
      ..removeWhere((item) => item.id == id)
      ..add(created);
    return id;
  }

  @override
  Future<int> createProfile(String name) async {
    createProfileCalls++;
    final id = profiles.isEmpty ? 1 : _nextProfileId++;
    profiles.add(GymProfile(id: id, name: name, createdAt: DateTime.utc(2026)));
    kcalByProfile.putIfAbsent(id, () => 2500);
    favoritesByProfile.putIfAbsent(id, () => [303]);
    return id;
  }

  @override
  Future<int> updateProfile(GymProfile profile) async {
    final index = profiles.indexWhere((item) => item.id == profile.id);
    if (index != -1) {
      profiles[index] = profile;
    }
    return 1;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => [
    {'id': 1, 'name': 'Barbell'},
  ];

  @override
  Future<String?> getAppState(String key) async =>
      key == 'selected_gym_profile_id' ? persistedSelectedProfileId : null;

  @override
  Future<void> setAppState(String key, String? value) async {
    if (key == 'selected_gym_profile_id') {
      persistedSelectedProfileId = value;
    }
  }

  @override
  Future<List<Food>> listFavorites(
    int profileId, {
    int limit = 100,
    int offset = 0,
  }) async {
    final ids = favoritesByProfile[profileId] ?? const <int>[];
    final now = DateTime.utc(2026, 10, 29);
    return [
      for (final id in ids)
        Food(
          id: id,
          name: 'Food $id',
          isCustom: true,
          createdAt: now,
          updatedAt: now,
        ),
    ];
  }

  @override
  Future<DayTotals> getDayTotals(int profileId, DateTime date) async =>
      DayTotals(
        profileId: profileId,
        date: date,
        kcal: kcalByProfile[profileId] ?? 2000,
      );

  @override
  Future<NutritionGoal?> getActiveGoals(int profileId, DateTime date) async =>
      null;

  @override
  Future<List<DiaryEntryWithItem>> getDiaryEntriesWithItemsForDate(
    int profileId,
    DateTime date,
  ) async => const [];
}

class _ActiveSessionImportRepository extends AppRepository {
  Map<String, dynamic>? persistedDraft;
  int draftSaveCount = 0;

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async =>
      persistedDraft;

  @override
  Future<void> saveActiveWorkoutDraft({
    required DateTime startedAt,
    int? autoPresetId,
    required String payloadJson,
  }) async {
    draftSaveCount++;
    persistedDraft = {
      'started_at': startedAt.toUtc().toIso8601String(),
      'auto_preset_id': autoPresetId,
      'payload_json': payloadJson,
    };
  }

  @override
  Future<void> clearActiveWorkoutDraft() async {
    persistedDraft = null;
  }

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];
}

class _MuscleCountingDatabaseHelper extends DatabaseHelper {
  _MuscleCountingDatabaseHelper(super.db) : super.forTesting();

  int musclePercentCalls = 0;
  double nextPercent = 60;

  @override
  Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) async {
    musclePercentCalls++;
    return [
      ExerciseMusclePercent(
        exerciseDefId: defId,
        muscleId: 1,
        percent: nextPercent,
      ),
    ];
  }
}

class _PragmaCountingDatabase implements Database {
  _PragmaCountingDatabase(this._inner);

  final Database _inner;
  final Map<String, int> txnTableInfoCallsByTable = {};

  void _recordTxnQuery(String sql) {
    final match = RegExp(
      r'^PRAGMA\s+table_info\(([^)]+)\)',
      caseSensitive: false,
    ).firstMatch(sql.trim());
    if (match != null) {
      final table = match.group(1)!.trim();
      txnTableInfoCallsByTable[table] =
          (txnTableInfoCallsByTable[table] ?? 0) + 1;
    }
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) {
    return _inner.transaction(
      (txn) => action(_PragmaCountingTransaction(txn, _recordTxnQuery)),
      exclusive: exclusive,
    );
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) => _inner.rawQuery(sql, arguments);

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) =>
      _inner.execute(sql, arguments);

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) =>
      _inner.rawInsert(sql, arguments);

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) => _inner.insert(
    table,
    values,
    nullColumnHack: nullColumnHack,
    conflictAlgorithm: conflictAlgorithm,
  );

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) => _inner.query(
    table,
    distinct: distinct,
    columns: columns,
    where: where,
    whereArgs: whereArgs,
    groupBy: groupBy,
    having: having,
    orderBy: orderBy,
    limit: limit,
    offset: offset,
  );

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) => _inner.update(
    table,
    values,
    where: where,
    whereArgs: whereArgs,
    conflictAlgorithm: conflictAlgorithm,
  );

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) =>
      _inner.delete(table, where: where, whereArgs: whereArgs);

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) =>
      _inner.rawUpdate(sql, arguments);

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) =>
      _inner.rawDelete(sql, arguments);

  @override
  Batch batch() => _inner.batch();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PragmaCountingTransaction implements Transaction {
  _PragmaCountingTransaction(this._inner, this._onQuery);

  final Transaction _inner;
  final void Function(String sql) _onQuery;

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) {
    _onQuery(sql);
    return _inner.rawQuery(sql, arguments);
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) =>
      _inner.execute(sql, arguments);

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) =>
      _inner.rawInsert(sql, arguments);

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) => _inner.insert(
    table,
    values,
    nullColumnHack: nullColumnHack,
    conflictAlgorithm: conflictAlgorithm,
  );

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) => _inner.query(
    table,
    distinct: distinct,
    columns: columns,
    where: where,
    whereArgs: whereArgs,
    groupBy: groupBy,
    having: having,
    orderBy: orderBy,
    limit: limit,
    offset: offset,
  );

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) => _inner.update(
    table,
    values,
    where: where,
    whereArgs: whereArgs,
    conflictAlgorithm: conflictAlgorithm,
  );

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) =>
      _inner.delete(table, where: where, whereArgs: whereArgs);

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) =>
      _inner.rawUpdate(sql, arguments);

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) =>
      _inner.rawDelete(sql, arguments);

  @override
  Batch batch() => _inner.batch();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
