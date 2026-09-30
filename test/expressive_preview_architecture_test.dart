import 'dart:async' show Completer, Zone;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/dev/expressive_preview_safety.dart';
import 'package:env_test/dev/expressive_preview_fixtures.dart';
import 'package:env_test/expressive_preview_main.dart' as preview_entry;
import 'package:env_test/main.dart'
    show
        MyApp,
        buildTonosApp,
        hasRequiredPreviewIdentityGuard,
        previewIdentityVerificationAllowsStartup,
        runPreviewDataAccessGuard,
        shouldCaptureTonosStartupDiagnostic,
        showExpressivePreviewStartupFailure;
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tonos_preview_presentation.dart';
import 'package:env_test/theme/tokens/app_data_visualization_tokens.dart';
import 'package:env_test/theme/tokens/app_effect_tokens.dart';
import 'package:env_test/theme/tokens/app_flow_tokens.dart';
import 'package:env_test/theme/tokens/app_generation_tokens.dart';
import 'package:env_test/theme/tokens/app_media_tokens.dart';
import 'package:env_test/theme/tokens/app_motion_tokens.dart';
import 'package:env_test/theme/tokens/app_nutrition_tokens.dart';
import 'package:env_test/theme/tokens/app_progress_colors.dart';
import 'package:env_test/theme/tokens/app_semantic_colors.dart';
import 'package:env_test/theme/tokens/app_settings_presentation_tokens.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';
import 'package:env_test/theme/tokens/app_surface_decoration_tokens.dart';
import 'package:env_test/theme/tokens/app_surface_tokens.dart';
import 'package:env_test/theme/tokens/app_tutorial_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Expressive recipe carries a distinct rendered identity in both modes',
    () {
      for (final theme in <ThemeData>[
        ExpressiveThemeDefinition.light(),
        ExpressiveThemeDefinition.dark(),
        ExpressiveThemeDefinition.light(
          treatment: ExpressivePaletteTreatment.generated,
        ),
        ExpressiveThemeDefinition.dark(
          treatment: ExpressivePaletteTreatment.generated,
        ),
      ]) {
        expect(
          theme.appThemeFamilyIdentity,
          AppThemeFamilyIdentity.expressivePreview,
        );
        expect(theme.usesExpressivePresentation, isTrue);
        expect(theme.usesClassicPresentation, isFalse);
        expect(theme.usesNeoPresentation, isFalse);
        expect(theme.extension<AppSemanticColors>(), isNotNull);
        expect(theme.extension<AppShapeTokens>(), isNotNull);
        expect(theme.extension<AppSurfaceTokens>(), isNotNull);
        expect(theme.extension<AppSurfaceDecorationTokens>(), isNotNull);
        expect(theme.extension<AppEffectTokens>(), isNotNull);
        expect(theme.extension<AppMotionTokens>(), isNotNull);
        expect(theme.extension<AppDataVisualizationTokens>(), isNotNull);
        expect(theme.extension<AppProgressColors>(), isNotNull);
        expect(theme.extension<AppSettingsPresentationTokens>(), isNotNull);
        expect(theme.extension<AppTutorialTokens>(), isNotNull);
        expect(theme.extension<AppMediaTokens>(), isNotNull);
        expect(theme.extension<AppFlowTokens>(), isNotNull);
        expect(theme.extension<AppGenerationTokens>(), isNotNull);
        expect(theme.extension<AppNutritionTokens>(), isNotNull);
      }

      expect(
        ExpressiveThemeDefinition.light(),
        same(ExpressiveThemeDefinition.light()),
      );
      expect(
        ExpressiveThemeDefinition.dark(),
        same(ExpressiveThemeDefinition.dark()),
      );
      expect(
        ExpressiveThemeDefinition.light(
          treatment: ExpressivePaletteTreatment.generated,
        ),
        isNot(same(ExpressiveThemeDefinition.light())),
      );
    },
  );

  test('preview controls change only the rendered in-memory recipe', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'sentinel': 'keep',
    });
    final preferences = await SharedPreferences.getInstance();
    final beforeKeys = preferences.getKeys();
    final beforeSentinel = preferences.getString('sentinel');
    final presentation = TonosPreviewPresentation();

    expect(presentation.look, TonosPreviewLook.expressive);
    expect(presentation.paletteTreatment, ExpressivePaletteTreatment.curated);
    expect(presentation.activeTheme, same(ExpressiveThemeDefinition.light()));

    presentation.setPaletteTreatment(ExpressivePaletteTreatment.generated);
    expect(
      presentation.activeTheme,
      same(
        ExpressiveThemeDefinition.light(
          treatment: ExpressivePaletteTreatment.generated,
        ),
      ),
    );
    presentation.setLook(TonosPreviewLook.classic);
    expect(
      presentation.activeTheme,
      same(AppThemeFactory.light(AppThemeFamily.classic)),
    );
    presentation.setBrightness(Brightness.dark);
    expect(
      presentation.activeTheme,
      same(AppThemeFactory.dark(AppThemeFamily.classic)),
    );
    presentation.setEffectsOff(true);
    final noEffectsTheme = presentation.activeTheme;
    expect(noEffectsTheme.effectTokens.shadowOpacity, 0);
    expect(noEffectsTheme.effectTokens.shadowBlur, 0);
    expect(noEffectsTheme.effectTokens.backdropBlurSigma, 0);
    expect(noEffectsTheme.cardTheme.elevation, 0);
    expect(noEffectsTheme.dialogTheme.elevation, 0);
    expect(noEffectsTheme.bottomSheetTheme.elevation, 0);
    expect(noEffectsTheme.extension<AppMediaTokens>()?.overlayShadow, isEmpty);
    expect(noEffectsTheme.extensions.length, 15);

    presentation
      ..setLocaleOverride(const Locale('fr'))
      ..setTextScaleOverride(1.5)
      ..setReducedMotion(true)
      ..setEffectsOff(true)
      ..resetReviewSettings();
    expect(presentation.look, TonosPreviewLook.expressive);
    expect(presentation.paletteTreatment, ExpressivePaletteTreatment.curated);
    expect(presentation.brightness, Brightness.light);
    expect(presentation.localeOverride, isNull);
    expect(presentation.textScaleOverride, isNull);
    expect(presentation.reducedMotion, isFalse);
    expect(presentation.effectsOff, isFalse);
    expect(preferences.getKeys(), beforeKeys);
    expect(preferences.getString('sentinel'), beforeSentinel);
    presentation.dispose();
  });

  test('persisted theme families still contain only Classic and Neo', () {
    expect(AppThemeFamily.values.toSet(), <AppThemeFamily>{
      AppThemeFamily.classic,
      AppThemeFamily.neoBrutalism,
    });
  });

  test(
    'buildTonosApp defaults to the same null preview seam as explicit null',
    () {
      final withoutArgument = buildTonosApp(
        repo: AppRepository(),
        closeRepositoryOnDispose: false,
      );
      final explicitNull = buildTonosApp(
        repo: AppRepository(),
        closeRepositoryOnDispose: false,
        previewPresentation: null,
      );

      expect(withoutArgument, isA<MultiProvider>());
      expect(explicitNull, isA<MultiProvider>());
      expect(const MyApp().previewPresentation, isNull);
      expect(
        const MyApp(previewPresentation: null).previewPresentation,
        isNull,
      );
    },
  );

  test(
    'preview entry rejects missing build flags before preference access',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'sentinel': 'untouched',
      });

      Object? failure;
      Zone? failureZone;
      final callerZone = Zone.current;
      final identityAccepted = await runPreviewDataAccessGuard(
        guard: ExpressivePreviewSafety.verifyBeforeDataAccess,
        onFailure: (error, _) {
          failure = error;
          failureZone = Zone.current;
        },
      );
      expect(identityAccepted, isFalse);
      expect(failure, isA<StateError>());
      expect(failureZone, same(callerZone));

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getKeys(), {'sentinel'});
      expect(preferences.getString('sentinel'), 'untouched');
    },
  );

  test('preview startup requires identity verification before diagnostics', () {
    expect(
      hasRequiredPreviewIdentityGuard(
        isExpressivePreview: true,
        hasIdentityGuard: false,
      ),
      isFalse,
    );
    expect(
      hasRequiredPreviewIdentityGuard(
        isExpressivePreview: true,
        hasIdentityGuard: true,
      ),
      isTrue,
    );
    expect(
      hasRequiredPreviewIdentityGuard(
        isExpressivePreview: false,
        hasIdentityGuard: false,
      ),
      isTrue,
    );

    expect(
      shouldCaptureTonosStartupDiagnostic(
        isExpressivePreview: true,
        identityGuardVerified: false,
      ),
      isFalse,
    );
    expect(
      shouldCaptureTonosStartupDiagnostic(
        isExpressivePreview: true,
        identityGuardVerified: true,
      ),
      isTrue,
    );
    expect(
      shouldCaptureTonosStartupDiagnostic(
        isExpressivePreview: false,
        identityGuardVerified: false,
      ),
      isTrue,
    );
    expect(
      previewIdentityVerificationAllowsStartup(
        accepted: true,
        startupFailureShown: false,
      ),
      isTrue,
    );
    expect(
      previewIdentityVerificationAllowsStartup(
        accepted: true,
        startupFailureShown: true,
      ),
      isFalse,
    );
    expect(
      previewIdentityVerificationAllowsStartup(
        accepted: false,
        startupFailureShown: false,
      ),
      isFalse,
    );
  });

  testWidgets('preview startup failures render an actionable error surface', (
    tester,
  ) async {
    showExpressivePreviewStartupFailure(StateError('preview flags missing'));

    await tester.pump();

    expect(find.text('Expressive preview could not start'), findsOneWidget);
    expect(find.text('Bad state: preview flags missing'), findsOneWidget);
  });

  test(
    'preview fixture reset waits for session and pending progression work',
    () async {
      var sessionIsFinishing = true;
      var pendingProgressions = true;
      var pendingReadCount = 0;
      var discardCount = 0;
      var fixtureMutationCount = 0;
      var busyFeedbackCount = 0;

      Future<bool> attemptReset({
        bool startFinishDuringProgressionRead = false,
      }) {
        return preview_entry.resetExpressivePreviewFixturesSafely(
          sessionIsFinishing: () => sessionIsFinishing,
          hasPendingProgressions: () async {
            pendingReadCount++;
            if (startFinishDuringProgressionRead) {
              sessionIsFinishing = true;
              return false;
            }
            return pendingProgressions;
          },
          discardSession: () async => discardCount++,
          resetFixtures: () async => fixtureMutationCount++,
          onBusy: () => busyFeedbackCount++,
        );
      }

      expect(await attemptReset(), isFalse);
      expect(pendingReadCount, 0);
      expect(discardCount, 0);
      expect(fixtureMutationCount, 0);

      sessionIsFinishing = false;
      expect(await attemptReset(), isFalse);
      expect(pendingReadCount, 1);
      expect(discardCount, 0);
      expect(fixtureMutationCount, 0);

      pendingProgressions = false;
      sessionIsFinishing = false;
      expect(
        await attemptReset(startFinishDuringProgressionRead: true),
        isFalse,
      );
      expect(pendingReadCount, 2);
      expect(discardCount, 0);
      expect(fixtureMutationCount, 0);

      sessionIsFinishing = false;
      expect(await attemptReset(), isTrue);
      expect(pendingReadCount, 3);
      expect(discardCount, 1);
      expect(fixtureMutationCount, 1);
      expect(busyFeedbackCount, 3);
    },
  );

  testWidgets('preview fixture reset ignores overlapping invocations', (
    tester,
  ) async {
    final resetCompleter = Completer<void>();
    var resetCallCount = 0;
    final presentation = TonosPreviewPresentation(
      fixtureReset: (_) {
        resetCallCount++;
        return resetCompleter.future;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: presentation.navigatorKey,
        home: const SizedBox.shrink(),
      ),
    );

    final firstReset = presentation.resetFixtures();
    final overlappingReset = presentation.resetFixtures();
    expect(resetCallCount, 1);
    expect(presentation.fixtureResetInProgress, isTrue);

    resetCompleter.complete();
    await Future.wait<void>([firstReset, overlappingReset]);
    expect(presentation.fixtureResetInProgress, isFalse);
    expect(resetCallCount, 1);

    presentation.dispose();
  });

  test(
    'preview fixtures use hydrated catalog definitions and real IDs',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final detailed = <ExerciseDefinition>[
        for (var id = 1; id <= 3; id++) _definition(id, hydrated: true),
      ];
      final shallow = <ExerciseDefinition>[
        for (var id = 1; id <= 3; id++) _definition(id, hydrated: false),
      ];
      final repository = _FixtureRepository(
        detailedDefinitions: detailed,
        shallowDefinitions: shallow,
      );

      await ExpressivePreviewFixtures.prepare(repository);

      expect(repository.detailedLookupCount, 1);
      expect(repository.shallowLookupCount, 0);
      expect(repository.usedDefinitionIds, isNotEmpty);
      expect(repository.usedDefinitionIds.toSet(), {1, 2, 3});
      expect(repository.createdPresetCount, 8);
      expect(repository.completedSessionCount, 3);
    },
  );

  test('preview startup guard rejects any shared or conflicting identity', () {
    void validate({
      String packageName = ExpressivePreviewSafety.applicationId,
      String databaseName = ExpressivePreviewSafety.databaseName,
      bool previewEnabled = true,
      bool previewAndroidBuild = true,
      bool internalAndroidBuild = false,
    }) => ExpressivePreviewSafety.validateIdentity(
      packageName: packageName,
      databaseName: databaseName,
      previewEnabled: previewEnabled,
      previewAndroidBuild: previewAndroidBuild,
      internalAndroidBuild: internalAndroidBuild,
    );

    expect(validate, returnsNormally);
    expect(() => validate(packageName: 'com.tonos'), throwsStateError);
    expect(() => validate(packageName: 'com.tonos.internal'), throwsStateError);
    expect(
      () => validate(databaseName: 'fitness_tracker.db'),
      throwsStateError,
    );
    expect(() => validate(previewEnabled: false), throwsStateError);
    expect(() => validate(previewAndroidBuild: false), throwsStateError);
    expect(() => validate(internalAndroidBuild: true), throwsStateError);
  });
}

ExerciseDefinition _definition(int id, {required bool hydrated}) {
  return ExerciseDefinition(
    id: id,
    name: 'Exercise $id',
    equipmentId: 7,
    equipmentList: [Equipment(7, 'Dumbbell')],
    bodyParts: hydrated ? [BodyPart(11, 'Upper body')] : const [],
    muscles: hydrated
        ? [RankedMuscle(muscle: Muscle(id: 21, name: 'Biceps'), rank: 1)]
        : const [],
    useManualBodyparts: false,
    multiplyByRating: false,
  );
}

class _FixtureRepository extends AppRepository {
  _FixtureRepository({
    required this.detailedDefinitions,
    required this.shallowDefinitions,
  });

  final List<ExerciseDefinition> detailedDefinitions;
  final List<ExerciseDefinition> shallowDefinitions;
  final Map<String, String> _appState = <String, String>{};
  final List<int> usedDefinitionIds = <int>[];
  int detailedLookupCount = 0;
  int shallowLookupCount = 0;
  int createdPresetCount = 0;
  int completedSessionCount = 0;

  @override
  Future<bool> warmUp({bool verify = false}) async => true;

  @override
  Future<String?> getAppState(String key) async => _appState[key];

  @override
  Future<void> setAppState(String key, String? value) async {
    if (value == null) {
      _appState.remove(key);
    } else {
      _appState[key] = value;
    }
  }

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async {
    detailedLookupCount++;
    return detailedDefinitions;
  }

  @override
  Future<List<ExerciseDefinition>> fetchExerciseDefinitionsFiltered({
    List<String>? equipmentNames,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) async {
    shallowLookupCount++;
    return shallowDefinitions;
  }

  @override
  Future<List<Equipment>> fetchAllEquipment() async => [
    Equipment(7, 'Dumbbell'),
  ];

  @override
  Future<int> saveGymProfileAtomic({
    required GymProfile? existingProfile,
    required String name,
    required Set<int> equipmentIds,
  }) async => 41;

  @override
  Future<void> replaceActivePlans(int profileId, Set<int> presetIds) async {}

  @override
  Future<int> createPresetAtomic({
    required String name,
    required int? profileId,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
    bool activate = false,
    bool uniqueName = false,
    bool isDraft = false,
  }) async {
    createdPresetCount++;
    usedDefinitionIds.addAll(
      exercises.map((write) => write.definitionId!).toList(),
    );
    return createdPresetCount;
  }

  @override
  Future<int> completeWorkoutAtomic({
    required DateTime completedAt,
    required int durationSeconds,
    required List<WorkoutExerciseWrite> exercises,
    int? autoPresetId,
  }) async {
    completedSessionCount++;
    usedDefinitionIds.addAll(
      exercises.map((write) => write.definitionId!).toList(),
    );
    return completedSessionCount;
  }
}
