import 'dart:convert';

import 'package:env_test/db/database_helper.dart';
import 'package:env_test/db/database_maintenance.dart';
import 'package:env_test/db/nutrition_dao.dart';
import 'package:env_test/db/schema.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/durable_active_session.dart';
import 'package:env_test/providers/nutrition_profile.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/services/database_import_coordinator.dart';
import 'package:env_test/widgets/exercise_card.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  for (final maintenanceFailed in [false, true]) {
    test(
      'all providers reconcile after profile reload failure; maintenanceFailed=$maintenanceFailed',
      () async {
        final calls = <String>[];
        final reloadError = StateError('Injected profile reload failure');
        final maintenanceError = DatabaseImportCommittedException(
          StateError('Injected maintenance failure'),
        );
        final repo = _ReconciliationRepository(
          calls,
          maintenanceFailed ? maintenanceError : null,
        );
        await expectLater(
          importDatabaseWithLiveState(
            repository: repo,
            json: '{}',
            activeSession: _ReconciliationSession(calls),
            selectedProfile: _ReconciliationProfile(calls, reloadError),
            nutritionProfile: _ReconciliationNutrition(calls),
          ),
          throwsA(
            maintenanceFailed
                ? same(maintenanceError)
                : isA<DatabaseImportCommittedException>().having(
                    (error) => error.cause,
                    'cause',
                    same(reloadError),
                  ),
          ),
        );
        expect(calls, [
          'prepare',
          'import',
          'workout',
          'profiles',
          'nutrition',
        ]);
      },
    );
  }

  test(
    'pre-commit rejection resumes the original live draft without reloading',
    () async {
      final repo = _RejectedImportRepository();
      final active = ActiveSession(repository: repo, retryDelay: (_) async {});
      addTearDown(active.dispose);
      await active.ready;
      await active.start();
      expect(repo.saves, 1);
      await expectLater(
        importDatabaseWithLiveState(
          repository: repo,
          json: 'invalid',
          activeSession: active,
        ),
        throwsFormatException,
      );
      active.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future<void>.delayed(Duration.zero);
      expect(repo.saves, 2);
      expect(active.isActive, isTrue);
      expect(repo.loads, 1);
    },
  );
  test(
    'post-commit import failure must not resume the pre-import draft',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      await Schema.createTables(db);
      final nutrition = NutritionDao(db);
      await nutrition.seedNutrientsIfEmpty();
      final foodId = await nutrition.insertCustomFood(
        name: 'Recipe ingredient',
      );
      await nutrition.replacePer100gByCode(foodId, {'ENERGY_KCAL': 100});
      await nutrition.createOrUpdateRecipe(
        Recipe(
          name: 'Recipe',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
        [RecipeIngredient(recipeId: 0, foodId: foodId, grams: 50)],
      );
      final repo = AppRepository(db: DatabaseHelper.forTesting(db));
      final active = ActiveSession(repository: repo, retryDelay: (_) async {});
      addTearDown(active.dispose);
      await active.ready;
      await active.startWithExercises(
        workoutExercises: [
          WeightExercise(
            name: 'Original workout',
            equipment: '',
            sets: [ExerciseSet(weight: 20, reps: 5)],
          ),
        ],
        workoutCardTypes: [CardType.weight],
      );
      final backupDraft = Map<String, dynamic>.from(
        (await repo.loadActiveWorkoutDraft())!,
      );
      backupDraft['payload_json'] = (backupDraft['payload_json'] as String)
          .replaceAll('Original workout', 'Imported workout');
      await db.execute(
        "CREATE TRIGGER fail_recipe_cache BEFORE INSERT ON recipe_nutrients BEGIN SELECT RAISE(ABORT, 'Injected rebuild failure'); END",
      );
      final cached = repo.computeMusclePercents(999);
      await cached;
      await expectLater(
        importDatabaseWithLiveState(
          repository: repo,
          activeSession: active,
          json: jsonEncode({
            'sessions': [
              {'id': 901, 'date': '2026-10-29T12:00:00Z', 'duration': 30},
            ],
            'active_workout_draft': [backupDraft],
          }),
        ),
        throwsA(isA<DatabaseImportCommittedException>()),
      );
      final refreshed = repo.computeMusclePercents(999);
      await refreshed;
      expect(identical(refreshed, cached), isFalse);
      expect(active.exercises.single.name, 'Imported workout');
      expect(await db.query('sessions', where: 'id = 901'), hasLength(1));
      expect(
        (await repo.loadActiveWorkoutDraft())!['payload_json'],
        contains('Imported workout'),
      );
      active.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(
        (await repo.loadActiveWorkoutDraft())!['payload_json'],
        contains('Imported workout'),
        reason: 'The old live session must not overwrite the committed imported draft',
      );
    },
  );
}

class _RejectedImportRepository extends AppRepository {
  int saves = 0;
  int loads = 0;
  @override
  Future<void> importDatabase(String jsonStr, {bool clearFirst = true}) async =>
      throw const FormatException('Injected validation failure');
  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async {
    loads++;
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      [];
  @override
  Future<void> saveActiveWorkoutDraft({
    required DateTime startedAt,
    int? autoPresetId,
    required String payloadJson,
  }) async {
    saves++;
  }
}

class _ReconciliationRepository extends AppRepository {
  _ReconciliationRepository(this.calls, this.failure);
  final List<String> calls;
  final Object? failure;
  @override
  Future<void> importDatabase(String jsonStr, {bool clearFirst = true}) async {
    calls.add('import');
    final error = failure;
    if (error != null) throw error;
  }
}

class _ReconciliationSession implements ActiveSession {
  _ReconciliationSession(this.calls);
  final List<String> calls;
  @override
  Future<void> prepareForDatabaseReplace() async {
    calls.add('prepare');
  }

  @override
  Future<void> reloadFromDatabase() async {
    calls.add('workout');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ReconciliationProfile implements SelectedProfile {
  _ReconciliationProfile(this.calls, this.failure);
  final List<String> calls;
  final Object failure;
  @override
  Future<void> loadProfiles({int? preferredProfileId}) async {
    calls.add('profiles');
    throw failure;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ReconciliationNutrition implements NutritionProfile {
  _ReconciliationNutrition(this.calls);
  final List<String> calls;
  @override
  Future<void> reloadFromDatabase() async {
    calls.add('nutrition');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
