import 'package:env_test/db/database_helper.dart';
import 'package:env_test/main.dart' as tonos;
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/durable_active_session.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/onboarding_flow.dart';
import 'package:env_test/widgets/exercise_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _integrationTestEnabled = bool.fromEnvironment('TONOS_INTEGRATION_TEST');
const _integrationDatabaseName = String.fromEnvironment(
  'TONOS_DATABASE_NAME',
  defaultValue: '',
);
const _expectedIntegrationDatabaseName = 'tonos_integration_test.db';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppRepository repository;

  setUpAll(() async {
    if (!_integrationTestEnabled ||
        _integrationDatabaseName != _expectedIntegrationDatabaseName) {
      throw StateError(
        'Run this suite with TONOS_INTEGRATION_TEST=true and '
        'TONOS_DATABASE_NAME=$_expectedIntegrationDatabaseName. This keeps '
        'device tests isolated from the normal Tonos database.',
      );
    }

    await DatabaseHelper().resetIntegrationTestDatabase();
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    await preferences.setString('app_language_preference', 'english');

    repository = AppRepository();
    await repository.warmUp(verify: true);
  });

  tearDownAll(() => repository.close());

  testWidgets('first install opens onboarding and advances from welcome', (
    tester,
  ) async {
    await tonos.main();
    await tester.pumpAndSettle(const Duration(seconds: 8));

    expect(find.byType(OnboardingFlow), findsOneWidget);
    expect(find.text('Welcome to Tonos'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Tell us the basics'), findsOneWidget);
  });

  testWidgets('media bootstrap, profile changes, plan flow, and workout', (
    tester,
  ) async {
    final database = await repository.dbHelper.database;

    // Initial warm-up must make both bundled/remote manifest namespaces
    // available before any catalog screen needs a thumbnail.
    final manifests = await database.query('content_manifest');
    expect(
      manifests.map((row) => row['namespace']),
      contains('exercise_media'),
    );
    expect(manifests.map((row) => row['namespace']), contains('shared_media'));

    final equipmentId =
        (await database.query(
              'equipment',
              columns: const ['id'],
              limit: 1,
            )).single['id']
            as int;
    final exerciseRow =
        (await database.rawQuery('''
          SELECT definitions.id, definitions.name, equipment.name AS equipment_name
          FROM exercise_definitions definitions
          JOIN equipment ON equipment.id = definitions.equipment_id
          ORDER BY definitions.id
          LIMIT 1
        ''')).single;
    final definitionId = exerciseRow['id'] as int;
    final exerciseName = exerciseRow['name'] as String;
    final equipmentName = exerciseRow['equipment_name'] as String? ?? '';

    // Create app defaults before the profile, then assert that each new plan
    // receives the profile snapshot instead of a dynamically inherited value.
    await database.delete('flow_defaults');
    await database.delete('flow_default_methods');
    await database.insert('flow_defaults', {
      'scope': 'app',
      'profile_id': null,
      'flow_json': '{"nodes":["app"],"edges":[]}',
    });
    await database.insert('flow_default_methods', {
      'scope': 'app',
      'profile_id': null,
      'name': 'Increase weight',
      'type': 'weight',
      'params': '{"sign":"+","factor":1.0}',
    });

    final profileId = await repository.saveGymProfileAtomic(
      existingProfile: null,
      name: 'Integration Home Gym',
      equipmentIds: {equipmentId},
    );
    var profile = (await repository.fetchAllProfiles()).firstWhere(
      (item) => item.id == profileId,
    );
    expect(profile.name, 'Integration Home Gym');

    await repository.saveGymProfileAtomic(
      existingProfile: profile,
      name: 'Integration Home Gym Updated',
      equipmentIds: {equipmentId},
    );
    profile = (await repository.fetchAllProfiles()).firstWhere(
      (item) => item.id == profileId,
    );
    expect(profile.name, 'Integration Home Gym Updated');

    final presetId = await repository.createPresetAtomic(
      name: 'Integration Progression Plan',
      profileId: profileId,
      activate: true,
      exercises: [
        WorkoutExerciseWrite(
          exercise: WeightExercise(
            name: exerciseName,
            equipment: equipmentName,
            sets: [ExerciseSet(weight: 100, reps: 5)],
          ),
          type: 'weight',
          definitionId: definitionId,
        ),
      ],
    );
    expect(await repository.loadActivePlans(profileId), contains(presetId));
    expect(
      (await repository.fetchPresetAutoSettings(presetId))?['flow_definition'],
      '{"nodes":["app"],"edges":[]}',
    );

    // Start an active workout, recreate the provider to prove it restores the
    // durable draft, then complete it and verify the draft is cleared.
    final initialSession = ActiveSession(repository: repository);
    await initialSession.ready;
    final started = await initialSession.startWithExercises(
      workoutExercises: [
        WeightExercise(
          name: exerciseName,
          equipment: equipmentName,
          sets: [ExerciseSet(weight: 100, reps: 5)],
          completedParents: {0},
        ),
      ],
      workoutCardTypes: const [CardType.weight],
      presetId: presetId,
    );
    expect(started, isTrue);
    expect(await repository.loadActiveWorkoutDraft(), isNotNull);
    initialSession.dispose();

    final restoredSession = ActiveSession(repository: repository);
    addTearDown(restoredSession.dispose);
    await restoredSession.ready;
    expect(restoredSession.isActive, isTrue);
    expect(restoredSession.completedSetCount, 1);

    final completedSessionId = await restoredSession.finish();
    expect(completedSessionId, isNotNull);
    expect(await repository.loadActiveWorkoutDraft(), isNull);
    expect(await repository.fetchSessionById(completedSessionId!), isNotNull);

    // The first completed weighted exercise creates persistent record events.
    final badges = await repository.fetchSessionRecordBadges(
      completedSessionId,
    );
    expect(badges.values.any((entry) => entry.isFirstRecord), isTrue);
    expect(
      badges.values
          .expand((entry) => entry.setBadges.values)
          .expand((badges) => badges),
      isNotEmpty,
    );
  });
}
