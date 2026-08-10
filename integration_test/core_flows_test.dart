import 'package:env_test/db/database_helper.dart';
import 'package:env_test/main.dart' as tonos;
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/onboarding_flow.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/workout_record_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _integrationTestEnabled = bool.fromEnvironment('TONOS_INTEGRATION_TEST');
const _integrationDatabaseName = String.fromEnvironment(
  'TONOS_DATABASE_NAME',
  defaultValue: '',
);
const _expectedIntegrationDatabaseName = 'tonos_integration_test.db';
const _filePickerChannel = MethodChannel(
  'miguelruivo.flutter.plugins.filepicker',
);

void _logPhase(String phase) {
  debugPrint('[integration] $phase');
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 120,
}) async {
  for (var pump = 0; pump < maxPumps; pump++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for the requested widget.');
}

Future<void> _tapAndWait(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 120,
}) async {
  await _waitFor(tester, finder, maxPumps: maxPumps);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _hideKeyboard(WidgetTester tester) async {
  await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  await tester.pump();
}

Future<void> _pressSystemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pump();
}

Future<void> _ensureRemoteMediaSynced(AppRepository repository) async {
  final database = await repository.dbHelper.database;
  Future<int> rowCount(String table) async =>
      (await database.rawQuery(
            'SELECT COUNT(*) AS count FROM $table',
          )).single['count']
          as int;

  var exerciseMediaCount = await rowCount('exercise_media');
  var sharedMediaCount = await rowCount('shared_media');
  if (exerciseMediaCount == 0 || sharedMediaCount == 0) {
    final config = await repository.loadContentEnvironments();
    final environment = config.defaultEnvironment;
    await Future.wait<void>([
      repository
          .syncRemoteExerciseMediaManifest(
            Uri.parse(environment.exerciseMediaManifestUrl),
          )
          .then<void>((_) {}),
      repository
          .syncRemoteSharedMediaManifest(
            Uri.parse(environment.sharedMediaManifestUrl),
          )
          .then<void>((_) {}),
    ]);
    exerciseMediaCount = await rowCount('exercise_media');
    sharedMediaCount = await rowCount('shared_media');
  }

  expect(exerciseMediaCount, greaterThan(0));
  expect(sharedMediaCount, greaterThan(0));
}

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

  testWidgets('first install and core flows use the UI', (tester) async {
    _logPhase('verify first-install onboarding');
    await tester.pumpWidget(
      tonos.buildTonosApp(repo: repository, closeRepositoryOnDispose: false),
    );
    await _waitFor(tester, find.byType(OnboardingFlow));

    expect(find.text('Welcome to Tonos'), findsOneWidget);
    await _tapAndWait(tester, find.widgetWithText(FilledButton, 'Next'));
    await _waitFor(tester, find.text('Tell us the basics'));
    expect(find.text('Tell us the basics'), findsOneWidget);

    // Recreate all providers from the configured fixture rather than retaining
    // the first-install onboarding state for the training flow.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('onboarding_completed', true);
    await preferences.setString('app_language_preference', 'english');
    await const TutorialStateStore().skipAll();

    _logPhase('prepare training fixture');
    final database = await repository.dbHelper.database;

    // A fresh database must receive both remote media manifests before the UI
    // starts exercising catalog-backed training surfaces.
    final manifests = await database.query('content_manifest');
    expect(
      manifests.map((row) => row['namespace']),
      containsAll(<String>['exercise_media', 'shared_media']),
    );
    await _ensureRemoteMediaSynced(repository);

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

    final profileId = await repository.saveGymProfileAtomic(
      existingProfile: null,
      name: 'UI Integration Gym',
      equipmentIds: {equipmentId},
    );
    await repository.setAppState('selected_gym_profile_id', '$profileId');
    final fixturePlanId = await repository.createPresetAtomic(
      name: 'UI Workout Plan',
      profileId: profileId,
      activate: true,
      exercises: [
        WorkoutExerciseWrite(
          exercise: WeightExercise(
            name: exerciseName,
            equipment: equipmentName,
            sets: [
              ExerciseSet(weight: 100, reps: 8),
              ExerciseSet(weight: 110, reps: 6),
            ],
          ),
          type: 'weight',
          definitionId: definitionId,
        ),
      ],
    );
    expect(
      await repository.loadActivePlans(profileId),
      contains(fixturePlanId),
    );

    await tester.pumpWidget(
      tonos.buildTonosApp(repo: repository, closeRepositoryOnDispose: false),
    );
    // MainScreen keeps tab pages alive in an IndexedStack. Select Train through
    // the bottom bar before interacting with its child controls so the test
    // never targets a cached but inactive page.
    await _tapAndWait(tester, find.byKey(AppTestKeys.mainTab('train')));
    await _waitFor(tester, find.byKey(AppTestKeys.trainPlansTab));

    // Create and rename a plan through the Train UI.
    _logPhase('create and rename manual plan');
    await _tapAndWait(tester, find.byKey(AppTestKeys.trainPlansTab));
    await _waitFor(tester, find.byKey(AppTestKeys.trainPlansList));
    // The manual action is below the plan summaries on shorter emulators.
    // Scroll the actual Plans list so its lazily built control is available.
    final visiblePlansList =
        find.byKey(AppTestKeys.trainPlansList).hitTestable();
    final plansScrollable = find.descendant(
      of: visiblePlansList,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable &&
            widget.physics is! NeverScrollableScrollPhysics,
      ),
    );
    final manualPlanAction = find.descendant(
      of: visiblePlansList,
      matching: find.byKey(AppTestKeys.trainCreateManualPlan),
    );
    expect(visiblePlansList, findsOneWidget);
    expect(plansScrollable, findsOneWidget);
    await tester.scrollUntilVisible(
      manualPlanAction,
      300,
      scrollable: plansScrollable,
    );
    // Plan previews can rebuild after their asynchronous data load. Tap in
    // the frame that exposed the lazy action before that rebuild can evict it.
    await tester.tap(manualPlanAction);
    await tester.pump();
    await _waitFor(tester, find.byKey(AppTestKeys.planEdit));
    final manualPlanRows = await repository.fetchAllPresetsRaw(
      profileId: profileId,
    );
    final manualPlanName =
        manualPlanRows.firstWhere((row) => row['id'] != fixturePlanId)['name']
            as String;
    expect(find.text(manualPlanName), findsWidgets);
    await _tapAndWait(tester, find.byKey(AppTestKeys.planEdit));
    await _waitFor(tester, find.byKey(AppTestKeys.planName));
    await tester.enterText(find.byKey(AppTestKeys.planName), 'UI Created Plan');
    await _hideKeyboard(tester);
    await _tapAndWait(tester, find.byKey(AppTestKeys.planSave));
    await _waitFor(tester, find.text('UI Created Plan'));
    expect(
      (await repository.fetchAllPresetsRaw(
        profileId: profileId,
      )).map((row) => row['name']),
      contains('UI Created Plan'),
    );

    await tester.pageBack();
    await _waitFor(tester, find.byKey(AppTestKeys.trainOverviewTab));
    await _tapAndWait(tester, find.byKey(AppTestKeys.trainOverviewTab));

    // Open the active fixture plan and start its session through the UI.
    _logPhase('start fixture workout');
    await _tapAndWait(tester, find.text('UI Workout Plan'));
    await _waitFor(tester, find.text(exerciseName));
    await _tapAndWait(tester, find.byKey(AppTestKeys.planStartSession));
    await _waitFor(tester, find.byKey(AppTestKeys.sessionFinish));

    // Leaving the route keeps the durable workout available to resume.
    _logPhase('resume durable workout');
    await _pressSystemBack(tester);
    await _waitFor(tester, find.byKey(AppTestKeys.ongoingSessionMenu));
    await _tapAndWait(tester, find.byKey(AppTestKeys.ongoingSessionMenu));
    await _tapAndWait(tester, find.byKey(AppTestKeys.ongoingSessionResume));
    await _waitFor(tester, find.byKey(AppTestKeys.sessionFinish));

    // Exercise the explicit Exit path, choose to keep the workout, and resume.
    _logPhase('exit and keep durable workout');
    await _pressSystemBack(tester);
    await _waitFor(tester, find.byKey(AppTestKeys.ongoingSessionMenu));
    await _tapAndWait(tester, find.byKey(AppTestKeys.ongoingSessionMenu));
    await _tapAndWait(tester, find.byKey(AppTestKeys.ongoingSessionExit));
    await _tapAndWait(tester, find.byKey(AppTestKeys.ongoingSessionKeep));
    await _tapAndWait(tester, find.byKey(AppTestKeys.ongoingSessionResume));
    await _waitFor(tester, find.byKey(AppTestKeys.sessionFinish));

    // Complete the first visible set, finish, and verify record presentation.
    _logPhase('complete workout and verify records');
    await _waitFor(tester, find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    await _tapAndWait(tester, find.byKey(AppTestKeys.sessionFinish));
    await _waitFor(tester, find.byKey(AppTestKeys.sessionCompleteDone));
    expect(find.byType(FirstRecordBadge), findsWidgets);
    expect(find.byType(WorkoutRecordBadgeChip), findsWidgets);

    final completedRows = await repository.fetchAllSessions();
    expect(completedRows, isNotEmpty);
    final completedSessionId = completedRows.first['id'] as int;
    expect(await repository.loadActiveWorkoutDraft(), isNull);

    await _tapAndWait(tester, find.byKey(AppTestKeys.sessionCompleteDone));
    await _waitFor(tester, find.byKey(AppTestKeys.mainTab('history')));

    // Open the persisted Logbook record and verify its badges remain visible.
    _logPhase('open logbook record');
    await _tapAndWait(tester, find.byKey(AppTestKeys.mainTab('history')));
    final historyRow = find.byKey(
      AppTestKeys.historySession(completedSessionId),
    );
    await _tapAndWait(tester, historyRow);
    await _waitFor(tester, find.byKey(AppTestKeys.workoutSaveAsPlan));
    // The action bar renders before the historical exercise details finish
    // loading their persisted record events.
    await _waitFor(tester, find.byType(FirstRecordBadge));
    await _waitFor(tester, find.byType(WorkoutRecordBadgeChip));

    // Save the completed workout as a new plan through its dialog.
    _logPhase('save completed workout as plan');
    await _tapAndWait(tester, find.byKey(AppTestKeys.workoutSaveAsPlan));
    await _waitFor(tester, find.byKey(AppTestKeys.workoutPlanName));
    await tester.enterText(
      find.byKey(AppTestKeys.workoutPlanName),
      'UI Saved Workout Plan',
    );
    await _hideKeyboard(tester);
    await _tapAndWait(tester, find.byKey(AppTestKeys.workoutPlanSave));
    await _waitFor(
      tester,
      find.text('Saved "UI Saved Workout Plan" as a plan.'),
    );
    expect(
      (await repository.fetchAllPresetsRaw(
        profileId: profileId,
      )).map((row) => row['name']),
      contains('UI Saved Workout Plan'),
    );

    await tester.pageBack();
    await _waitFor(tester, find.byKey(AppTestKeys.mainTab('profile')));
    await _tapAndWait(tester, find.byKey(AppTestKeys.mainTab('profile')));

    // Edit profile information through the Settings form.
    _logPhase('edit profile information');
    await _tapAndWait(tester, find.byKey(AppTestKeys.profileUserInformation));
    await _waitFor(tester, find.byKey(AppTestKeys.userInformationName));
    await tester.enterText(
      find.byKey(AppTestKeys.userInformationName),
      'UI Profile Name',
    );
    await _hideKeyboard(tester);
    await _tapAndWait(tester, find.byKey(AppTestKeys.userInformationSave));
    await _waitFor(tester, find.text('Changes saved'));
    expect((await repository.fetchPersonalInfo())?.name, 'UI Profile Name');

    await tester.pageBack();
    await _waitFor(tester, find.byKey(AppTestKeys.profileDatabaseSettings));
    await _tapAndWait(tester, find.byKey(AppTestKeys.profileDatabaseSettings));

    // Mock only the native document-picker boundary. All Settings actions,
    // dialogs, backups, export/import work, and result UI remain production code.
    _logPhase('export and import database backup');
    Uint8List? exportedBytes;
    var saveCallCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_filePickerChannel, (call) async {
          if (call.method == 'save') {
            saveCallCount++;
            final arguments = call.arguments as Map<Object?, Object?>;
            if (saveCallCount == 1) {
              exportedBytes = arguments['bytes'] as Uint8List;
            }
            return 'content://tonos-integration/export-$saveCallCount.json';
          }
          if (call.method == 'custom') {
            final bytes = exportedBytes;
            if (bytes == null) return null;
            return <Map<String, Object?>>[
              {
                'name': 'ui-integration-export.json',
                'path': null,
                'bytes': bytes,
                'size': bytes.length,
                'identifier': 'content://tonos-integration/import.json',
              },
            ];
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_filePickerChannel, null),
    );

    await _tapAndWait(tester, find.byKey(AppTestKeys.databaseExport));
    await _waitFor(tester, find.byKey(AppTestKeys.databaseResultClose));
    expect(exportedBytes, isNotNull);
    await _tapAndWait(tester, find.byKey(AppTestKeys.databaseResultClose));

    // Change exported data, then import the captured backup through the UI and
    // prove that the original value is restored.
    await repository.savePersonalInfo(PersonalInfo(name: 'Changed'));
    expect((await repository.fetchPersonalInfo())?.name, 'Changed');

    await _tapAndWait(tester, find.byKey(AppTestKeys.databaseImport));
    await _tapAndWait(tester, find.byKey(AppTestKeys.databaseConfirmImport));
    await _waitFor(
      tester,
      find.byKey(AppTestKeys.databaseResultClose),
      maxPumps: 240,
    );
    expect(saveCallCount, 2, reason: 'Import must save a safety backup first.');
    expect((await repository.fetchPersonalInfo())?.name, 'UI Profile Name');
    await _tapAndWait(tester, find.byKey(AppTestKeys.databaseResultClose));
  });
}
