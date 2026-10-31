import 'dart:async';
import 'dart:convert';

import 'package:env_test/db/database_helper.dart';
import 'package:env_test/db/schema.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/durable_active_session.dart';
import 'package:env_test/providers/nutrition_profile.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/services/safe_failure.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  for (final mutation in ['food', 'recipe', 'delete']) {
    test(
      'failed nutrition $mutation writes reject instead of allowing false success',
      () async {
        final repo = _FailingNutritionWriteRepository();
        final profile = NutritionProfile(repository: repo);
        addTearDown(profile.dispose);
        await profile.ready;
        final Future<void> operation = switch (mutation) {
          'food' => profile.addFood(meal: MealType.breakfast, foodId: 1),
          'recipe' => profile.addRecipe(meal: MealType.breakfast, recipeId: 1),
          _ => profile.deleteEntry(1),
        };
        var success = false;
        await expectLater(
          operation.then((_) => success = true),
          throwsA(isA<SafeFailure>()),
        );
        expect(success, isFalse);
        expect(profile.error, isA<SafeFailure>());
        expect(repo.writeCalls, 1);
      },
    );
  }

  test(
    'nutrition writes without a selected profile cannot report success',
    () async {
      final repo = _FailingNutritionWriteRepository();
      final profile = NutritionProfile(repository: repo);
      addTearDown(profile.dispose);
      await profile.ready;
      profile.current = null;
      await expectLater(
        profile.addFood(meal: MealType.breakfast, foodId: 1),
        throwsA(isA<SafeFailure>()),
      );
      expect(repo.writeCalls, 0);
    },
  );

  test('profile-switch notifications never pair new favorites with old totals, goals or meals', () async {
    final day = DateTime(2026, 10, 30);
    final repo = _SyncProfileRepository(
      initialProfiles: [
        GymProfile(id: 1, name: 'Home', createdAt: day),
        GymProfile(id: 2, name: 'Away', createdAt: day),
      ],
    );
    for (final id in [1, 2]) {
      repo.goalsByProfile[id] = NutritionGoal(
        profileId: id,
        startDate: day,
        kcalTarget: 2000,
      );
      repo.mealsByProfile[id] = [
        DiaryEntryWithItem(
          entry: DiaryEntry(
            profileId: id,
            date: day,
            mealType: MealType.breakfast,
            foodId: 101,
          ),
          itemName: 'Profile $id meal',
        ),
      ];
    }
    final selected = SelectedProfile(repository: repo);
    final nutrition = NutritionProfile(repository: repo)
      ..bindSelectedProfile(selected);
    addTearDown(() {
      nutrition.dispose();
      selected.dispose();
    });
    await Future.wait([selected.ready, nutrition.ready]);
    expect(nutrition.totals?.profileId, 1);
    expect(nutrition.activeGoal?.profileId, 1);
    expect(nutrition.meals.single.profileId, 1);
    nutrition.error = const SafeFailure(
      kind: SafeFailureKind.offline,
      retryable: true,
    );
    final gate = Completer<DayTotals>();
    repo.totalsGates[2] = gate;
    final staleNotifications = <bool>[];
    nutrition.addListener(() {
      if (nutrition.profileId == 2) {
        staleNotifications.add(
          nutrition.totals?.profileId == 1 ||
              nutrition.activeGoal?.profileId == 1 ||
              nutrition.meals.any((entry) => entry.profileId == 1) ||
              nutrition.error != null,
        );
      }
    });
    final change = nutrition.selectProfile(repo.profiles[1]);
    await Future<void>.delayed(Duration.zero);
    expect(nutrition.favoriteFoodIds, {202});
    expect(nutrition.totals, isNull);
    expect(nutrition.activeGoal, isNull);
    expect(nutrition.meals, isEmpty);
    expect(nutrition.error, isNull);
    expect(staleNotifications, isNotEmpty);
    expect(staleNotifications, everyElement(isFalse));
    gate.complete(DayTotals(profileId: 2, date: day, kcal: 2200));
    await change;
    expect(nutrition.totals?.profileId, 2);
    expect(nutrition.activeGoal?.profileId, 2);
    expect(nutrition.meals.single.profileId, 2);
    expect(staleNotifications, everyElement(isFalse));
  });

  test(
    'a failed favorite toggle cannot roll back into a newly selected profile',
    () async {
      final repo = _SyncProfileRepository(
        initialProfiles: [
          GymProfile(id: 1, name: 'Home', createdAt: DateTime.utc(2026)),
          GymProfile(id: 2, name: 'Away', createdAt: DateTime.utc(2026)),
        ],
      );
      final selected = SelectedProfile(repository: repo);
      final nutrition = NutritionProfile(repository: repo)
        ..bindSelectedProfile(selected);
      addTearDown(() {
        nutrition.dispose();
        selected.dispose();
      });
      await Future.wait([selected.ready, nutrition.ready]);
      repo.favoriteWriteGate = Completer<void>();
      final change = nutrition.toggleFavorite(101);
      await nutrition.selectProfile(repo.profiles[1]);
      expect(nutrition.favoriteFoodIds, {202});
      repo.favoriteWriteGate!.completeError(
        TimeoutException('Injected write failure'),
      );
      await change;
      expect(nutrition.favoriteFoodIds, {202});
      expect(nutrition.error, isNull);
    },
  );

  test(
    'late favorites from a prior profile cannot overwrite the selected profile',
    () async {
      final repo = _SyncProfileRepository(
        initialProfiles: [
          GymProfile(id: 1, name: 'Home', createdAt: DateTime.utc(2026)),
          GymProfile(id: 2, name: 'Away', createdAt: DateTime.utc(2026)),
        ],
      );
      final selected = SelectedProfile(repository: repo);
      final nutrition = NutritionProfile(repository: repo)
        ..bindSelectedProfile(selected);
      addTearDown(() {
        nutrition.dispose();
        selected.dispose();
      });
      await Future.wait([selected.ready, nutrition.ready]);
      final gate = Completer<List<Food>>();
      repo.favoritesGates[2] = gate;
      await selected.selectProfile(repo.profiles[1]);
      await selected.selectProfile(repo.profiles[0]);
      await Future<void>.delayed(Duration.zero);
      expect(nutrition.favoriteFoodIds, {101});
      gate.complete([
        Food(
          id: 202,
          name: 'Delayed',
          isCustom: true,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(nutrition.profileId, 1);
      expect(nutrition.favoriteFoodIds, {101});
    },
  );

  test('database reload invalidates old favorites even when the profile ID is unchanged', () async {
    final repo = _SyncProfileRepository(
      initialProfiles: [
        GymProfile(id: 1, name: 'Home', createdAt: DateTime.utc(2026)),
      ],
    );
    final nutrition = NutritionProfile(repository: repo);
    addTearDown(nutrition.dispose);
    await nutrition.ready;
    final gate = Completer<List<Food>>();
    repo.favoritesGates[1] = gate;
    final stale = nutrition.refreshFavorites();
    repo.favoritesGates.remove(1);
    repo.favoritesByProfile[1] = [909];
    await nutrition.reloadFromDatabase();
    gate.complete([
      Food(
        id: 101,
        name: 'Old',
        isCustom: true,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    ]);
    await stale;
    expect(nutrition.favoriteFoodIds, {909});
  });

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

class _FailingNutritionWriteRepository extends _SyncProfileRepository {
  _FailingNutritionWriteRepository()
    : super(
        initialProfiles: [
          GymProfile(id: 1, name: 'Home', createdAt: DateTime(2026)),
        ],
      );

  int writeCalls = 0;
  Never _fail() {
    writeCalls++;
    throw StateError('Injected write failure');
  }

  @override
  Future<int> addDiaryFood({
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int foodId,
    int? portionId,
    double quantity = 1,
    double? gramsOverride,
    double? loggedGrams,
    DateTime? loggedAt,
    String? notes,
  }) async => _fail();

  @override
  Future<int> addDiaryRecipe({
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int recipeId,
    double quantity = 1,
    DateTime? loggedAt,
    String? notes,
  }) async => _fail();

  @override
  Future<void> deleteDiaryEntry(
    int id, {
    required int profileId,
    required DateTime date,
  }) async => _fail();
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
  final totalsGates = <int, Completer<DayTotals>>{};
  final goalsByProfile = <int, NutritionGoal>{};
  final mealsByProfile = <int, List<DiaryEntryWithItem>>{};
  final favoritesGates = <int, Completer<List<Food>>>{};
  Completer<void>? favoriteWriteGate;

  @override
  Future<void> removeFavorite(int profileId, int foodId) async {
    await favoriteWriteGate?.future;
    favoritesByProfile[profileId]?.remove(foodId);
  }

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
    final gate = favoritesGates[profileId];
    if (gate != null) return gate.future;
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
  Future<DayTotals> getDayTotals(int profileId, DateTime date) async {
    final gate = totalsGates[profileId];
    if (gate != null) return gate.future;
    return DayTotals(
      profileId: profileId,
      date: date,
      kcal: kcalByProfile[profileId] ?? 2000,
    );
  }

  @override
  Future<NutritionGoal?> getActiveGoals(int profileId, DateTime date) async =>
      goalsByProfile[profileId];

  @override
  Future<List<DiaryEntryWithItem>> getDiaryEntriesWithItemsForDate(
    int profileId,
    DateTime date,
  ) async => mealsByProfile[profileId] ?? const [];
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
