import 'dart:ui' show Tristate;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/main.dart' show MainScreen, buildTonosApp;
import 'package:env_test/l10n/app_localization_extensions.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/providers/dashboard_config.dart';
import 'package:env_test/providers/locale_preference_provider.dart';
import 'package:env_test/providers/nav_bar_config.dart';
import 'package:env_test/providers/nutrition_profile.dart';
import 'package:env_test/providers/onboarding_provider.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/providers/theme_provider.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/catalog_page.dart';
import 'package:env_test/screens/exercise/train_page.dart';
import 'package:env_test/screens/measurement_trends_page.dart';
import 'package:env_test/services/preset_generation_service.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tonos_preview_presentation.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/services/active_plan_store.dart';
import 'package:env_test/widgets/workout_metric_chart_card.dart';

const _profileName = 'Preview Space';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'production five-destination shell keeps Train tab state and unique actions',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final harness = await _PreviewHarness.create(tester);
      addTearDown(harness.dispose);
      final semanticsHandle = tester.ensureSemantics();
      try {
        final trainContext = tester.element(find.byType(TrainPage));
        final strings = AppLocalizations.of(trainContext);
        final navConfig = trainContext.read<NavBarConfig>();
        final navLabels = navConfig.items
            .map((item) => item.localizedTitle(strings))
            .toList(growable: false);
        expect(navLabels, hasLength(5));

        for (final label in navLabels) {
          _expectSingleTapNode(
            tester,
            label,
            selected: label == navLabels.first,
          );
        }
        _expectSingleTapNode(tester, strings.trainOverviewTab, selected: true);
        _expectSingleTapNode(tester, strings.trainPlansTab, selected: false);

        await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
        await _pumpTransientAnimations(tester);
        _expectSingleTapNode(tester, strings.trainOverviewTab, selected: false);
        _expectSingleTapNode(tester, strings.trainPlansTab, selected: true);

        await tester.tap(find.bySemanticsLabel(navLabels[1]));
        await _pumpTransientAnimations(tester);
        _expectSingleTapNode(tester, navLabels[1], selected: true);
        expect(find.byType(CatalogPage), findsOneWidget);

        await tester.tap(find.bySemanticsLabel(navLabels.first));
        await _pumpTransientAnimations(tester);
        _expectSingleTapNode(tester, navLabels.first, selected: true);
        _expectSingleTapNode(tester, strings.trainPlansTab, selected: true);
        expect(tester.takeException(), isNull);
        expect(find.byType(MainScreen), findsOneWidget);
        await _pumpTransientAnimations(tester);
        await tester.pumpWidget(const SizedBox.shrink());
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets(
    'default and explicit-null roots render the same production Train flow',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        for (final tutorialId in TutorialIds.all)
          'guided_tutorial_completed.$tutorialId': true,
        'onboarding_completed': true,
        'always_show_onboarding': false,
      });
      final repository = _QualificationRepository(restWarning: true);
      final themeProvider = await ThemeProvider.load();
      addTearDown(themeProvider.dispose);
      final preferences = await SharedPreferences.getInstance();
      final preferenceKeysBefore = preferences.getKeys();
      final semanticsHandle = tester.ensureSemantics();

      Future<Map<String, Object?>> renderAndExercise({
        required bool passExplicitNull,
      }) async {
        final app = passExplicitNull
            ? buildTonosApp(
                repo: repository,
                closeRepositoryOnDispose: false,
                themeProvider: themeProvider,
                previewPresentation: null,
              )
            : buildTonosApp(
                repo: repository,
                closeRepositoryOnDispose: false,
                themeProvider: themeProvider,
              );
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        expect(find.byType(MainScreen), findsOneWidget);
        expect(find.byType(TrainPage), findsOneWidget);
        expect(find.byType(TonosPreviewControls), findsNothing);
        final trainContext = tester.element(find.byType(TrainPage));
        final theme = Theme.of(trainContext);
        final media = MediaQuery.of(trainContext);
        expect(themeProvider.family, ThemeProvider.defaultFamily);
        expect(themeProvider.mode, ThemeProvider.defaultMode);
        expect(theme.usesClassicPresentation, isTrue);
        expect(theme.usesExpressivePresentation, isFalse);
        expect(theme.usesNeoPresentation, isFalse);
        expect(
          find.ancestor(
            of: find.byType(MainScreen),
            matching: find.byType(MultiProvider),
          ),
          findsOneWidget,
        );
        expect(trainContext.read<AppRepository>(), same(repository));
        expect(trainContext.read<ThemeProvider>(), same(themeProvider));

        final rootApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp).first,
        );
        expect(rootApp.navigatorKey, isNull);
        final rootProviders = <String>[
          trainContext.read<AppRepository>().runtimeType.toString(),
          trainContext.read<ActivePlanStore>().runtimeType.toString(),
          trainContext.read<NutritionProfile>().runtimeType.toString(),
          trainContext.read<OnboardingConfig>().runtimeType.toString(),
          trainContext.read<ActiveSession>().runtimeType.toString(),
          trainContext.read<SelectedProfile>().runtimeType.toString(),
          trainContext.read<DashboardConfig>().runtimeType.toString(),
          trainContext.read<ThemeProvider>().runtimeType.toString(),
          trainContext.read<UnitPreferenceProvider>().runtimeType.toString(),
          trainContext.read<LocalePreferenceProvider>().runtimeType.toString(),
          trainContext.read<NavBarConfig>().runtimeType.toString(),
        ];
        final navConfig = trainContext.read<NavBarConfig>();
        final strings = AppLocalizations.of(trainContext);
        final destinations = navConfig.items
            .map((item) => item.localizedTitle(strings))
            .toList(growable: false);
        expect(destinations, hasLength(5));

        _expectClassicBottomTabAction(
          tester,
          destinations.first,
          selected: true,
        );
        expect(find.byKey(AppTestKeys.trainOverviewTab), findsOneWidget);
        expect(find.byKey(AppTestKeys.trainPlansTab), findsOneWidget);
        await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
        await tester.pumpAndSettle();
        _expectSingleTapNode(tester, strings.trainPlansTab, selected: true);
        await tester.tap(find.byKey(AppTestKeys.mainTab('catalog')));
        await tester.pumpAndSettle();
        expect(find.byType(CatalogPage), findsOneWidget);
        await tester.tap(find.byKey(AppTestKeys.mainTab('train')));
        await tester.pumpAndSettle();
        expect(find.byType(TrainPage), findsOneWidget);
        _expectClassicBottomTabAction(
          tester,
          destinations.first,
          selected: true,
        );
        _expectSingleTapNode(tester, strings.trainPlansTab, selected: true);
        await tester.tap(find.byKey(AppTestKeys.trainOverviewTab));
        await tester.pumpAndSettle();

        await tester.tap(find.text(strings.trainOptimize));
        await tester.pump(const Duration(seconds: 5));
        final dialog = find.byType(AlertDialog);
        expect(dialog, findsOneWidget);
        await _pumpUntilDialogRouteCompletes(tester, dialog);
        final okay = tester
            .getSemantics(find.bySemanticsLabel(strings.commonOkay))
            .getSemanticsData();
        expect(okay.flagsCollection.isButton, isTrue);
        expect(okay.hasAction(SemanticsAction.tap), isTrue);
        await tester.tap(find.text(strings.commonOkay));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);

        final snapshot = <String, Object?>{
          'providerTypes': rootProviders,
          'themeFamily': themeProvider.family.name,
          'themeMode': themeProvider.mode.name,
          'themeIdentity': theme.appThemeFamilyIdentity?.name,
          'themeBrightness': theme.brightness.name,
          'destinations': destinations,
          'textScale': media.textScaler.scale(1),
          'disableAnimations': MediaQuery.disableAnimationsOf(trainContext),
          'locale': Localizations.localeOf(trainContext).toLanguageTag(),
          'logicalSize': '${media.size.width}x${media.size.height}',
          'previewControlsCount': find
              .byType(TonosPreviewControls)
              .evaluate()
              .length,
          'trainPlansSelectionRetained': true,
          'restDialogOkayButton': okay.label,
        };
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        return snapshot;
      }

      try {
        final defaultRoot = await renderAndExercise(passExplicitNull: false);
        final explicitNullRoot = await renderAndExercise(
          passExplicitNull: true,
        );
        expect(explicitNullRoot, defaultRoot);
        expect(preferences.getKeys(), preferenceKeysBefore);
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets(
    'root controls, route overlays, and Train dialog/snackbar inherit preview settings',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final harness = await _PreviewHarness.create(tester, restWarning: true);
      addTearDown(harness.dispose);
      final semanticsHandle = tester.ensureSemantics();
      try {
        expect(harness.presentation.navigatorKey.currentState, isNotNull);
        expect(
          harness.presentation.navigatorKey.currentState?.overlay,
          isNotNull,
        );
        _expectSingleTapNode(tester, 'Open preview controls', selected: false);
        _expectPreviewEntryDoesNotOverlapTrainTabs(tester);
        await tester.tap(find.byIcon(Icons.tune));
        await _pumpTransientAnimations(tester);
        expect(harness.presentation.controlsDialogOpen, isTrue);
        expect(find.text('Preview controls'), findsOneWidget);
        expect(find.bySemanticsLabel('Open preview controls'), findsNothing);
        final controlsContext = tester.element(find.text('Preview controls'));
        expect(Theme.of(controlsContext).usesExpressivePresentation, isTrue);
        expect(MediaQuery.disableAnimationsOf(controlsContext), isFalse);

        final reducedMotionSwitch = find.ancestor(
          of: find.text('Reduced motion'),
          matching: find.byType(SwitchListTile),
        );
        expect(reducedMotionSwitch, findsOneWidget);
        await tester.tap(reducedMotionSwitch);
        await _pumpTransientAnimations(tester);
        expect(harness.presentation.reducedMotion, isTrue);
        expect(
          tester.takeException(),
          isNull,
          reason:
              'Changing the root reduced-motion control must stay layout-safe.',
        );
        expect(
          MediaQuery.disableAnimationsOf(
            tester.element(find.text('Preview controls')),
          ),
          isTrue,
        );

        await tester.ensureVisible(find.text('App/device default'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('App/device default'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('fr-CA').last);
        await tester.pumpAndSettle();
        expect(harness.presentation.localeOverride, const Locale('fr', 'CA'));
        expect(
          tester.takeException(),
          isNull,
          reason: 'Applying the preview locale must stay layout-safe.',
        );

        await tester.ensureVisible(find.text('OS/app default'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OS/app default'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2×').last);
        await tester.pumpAndSettle();
        expect(harness.presentation.textScaleOverride, 2);
        expect(
          tester.takeException(),
          isNull,
          reason: 'Changing text scale while reduced motion is active must stay layout-safe.',
        );

        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Closing the root controls must stay layout-safe.',
        );
        final trainElement = tester.element(find.byType(TrainPage));
        expect(Localizations.localeOf(trainElement), const Locale('fr', 'CA'));
        expect(MediaQuery.disableAnimationsOf(trainElement), isTrue);
        expect(MediaQuery.textScalerOf(trainElement).scale(1), 2);
        _expectPreviewEntryDoesNotOverlapTrainTabs(tester);
        final frenchStrings = AppLocalizations.of(trainElement);
        _expectSingleTapNode(
          tester,
          frenchStrings.trainOverviewTab,
          selected: true,
        );
        _expectSingleTapNode(
          tester,
          frenchStrings.trainPlansTab,
          selected: false,
        );

        // The real Train selector remains tappable at the default width.
        expect(
          tester.getRect(find.byKey(AppTestKeys.trainOverviewTab)).size.height,
          greaterThanOrEqualTo(48),
        );
        expect(
          tester.getRect(find.byKey(AppTestKeys.trainPlansTab)).size.height,
          greaterThanOrEqualTo(48),
        );
        expect(tester.takeException(), isNull);

        // Exercise the actual Train rest warning through the app callback.
        final currentStrings = AppLocalizations.of(
          tester.element(find.byType(TrainPage)),
        );
        expect(
          await PresetGenerationService(harness.repository)
              .shouldRestBeforeOptimizedWorkout(
                SessionSpec(
                  profileId: harness.repository.profile.id!,
                  name: 'Preview qualification',
                  focusBodypartIds: const <int>[],
                  now: DateTime.now(),
                ),
              ),
          isTrue,
        );
        final bodyPartReadsBeforeOptimize =
            harness.repository.allBodyPartsFetchCount;
        await tester.tap(find.text(currentStrings.trainOptimize));
        await tester.pump(const Duration(seconds: 5));
        expect(
          harness.repository.allBodyPartsFetchCount,
          greaterThan(bodyPartReadsBeforeOptimize),
        );
        expect(find.text(currentStrings.trainRestTitle), findsOneWidget);
        expect(find.text(currentStrings.trainRestBody), findsOneWidget);
        await tester.tap(find.text(currentStrings.commonOkay));
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);

        // The production missing-profile branch presents its real SnackBar.
        final selectedProfile = tester
            .element(find.byType(TrainPage))
            .read<SelectedProfile>();
        selectedProfile
          ..currentProfile = null
          ..notifyListeners();
        await tester.pump();
        final missingProfileText = currentStrings.trainSelectProfileFirst;
        await tester.tap(find.text(currentStrings.trainOptimize));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text(missingProfileText), findsOneWidget);
        expect(find.bySemanticsLabel(missingProfileText), findsOneWidget);
        expect(
          tester
              .getSemantics(find.bySemanticsLabel(missingProfileText))
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isFalse,
        );

        // A real Train route on the root Navigator suppresses the floating
        // control; popping it restores the control without rebuilding the app.
        selectedProfile.currentProfile = harness.repository.profile;
        selectedProfile.notifyListeners();
        await tester.pumpAndSettle();
        final navigator = harness.presentation.navigatorKey.currentState!;
        final childRouteFuture = navigator.push<void>(
          MaterialPageRoute<void>(builder: (_) => const TrainPage()),
        );
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('Open preview controls'), findsNothing);
        await navigator.maybePop();
        await childRouteFuture;
        await tester.pumpAndSettle();
        _expectSingleTapNode(tester, 'Open preview controls', selected: false);
        expect(tester.takeException(), isNull);

        // The drawer comes from the production Train route and keeps a single
        // named, actionable profile row.
        await tester.tap(
          find.byTooltip(currentStrings.trainGymProfilesTooltip),
        );
        await tester.pumpAndSettle();
        expect(find.text(currentStrings.drawerGymProfiles), findsOneWidget);
        expect(find.text(_profileName), findsOneWidget);
        final profileNode = tester.getSemantics(find.text(_profileName));
        expect(
          profileNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
        expect(
          find.text(currentStrings.drawerProfileActive(_profileName)),
          findsOneWidget,
        );
        await tester.pumpWidget(const SizedBox.shrink());
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets('system Back restores focus to the root preview control', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final harness = await _PreviewHarness.create(tester);
    addTearDown(harness.dispose);
    final semanticsHandle = tester.ensureSemantics();
    try {
      final controlIcon = find.byIcon(Icons.tune);
      final focusBeforeOpen = Focus.of(tester.element(controlIcon));
      focusBeforeOpen.requestFocus();
      await tester.pump();
      expect(focusBeforeOpen.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _pumpTransientAnimations(tester);
      expect(harness.presentation.controlsDialogOpen, isTrue);
      expect(find.text('Preview controls'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await _pumpTransientAnimations(tester);
      expect(harness.presentation.controlsDialogOpen, isFalse);
      _expectSingleTapNode(tester, 'Open preview controls', selected: false);
      final focusAfterBack = Focus.of(tester.element(controlIcon));
      expect(
        focusAfterBack.hasFocus,
        isTrue,
        reason: 'Back should restore keyboard focus to the preview control.',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _pumpTransientAnimations(tester);
      expect(harness.presentation.controlsDialogOpen, isTrue);
      await tester.binding.handlePopRoute();
      await _pumpTransientAnimations(tester);
      expect(harness.presentation.controlsDialogOpen, isFalse);
      expect(tester.takeException(), isNull);
    } finally {
      semanticsHandle.dispose();
    }
  });

  for (final look in TonosPreviewLook.values) {
    testWidgets(
      '${look.name} rest dialog keeps title, body, and OK in one actionable semantics node',
      (tester) => _expectRestDialogSemantics(
        tester,
        look: look,
        localeOverride: null,
        textScaleOverride: null,
        reducedMotion: false,
      ),
    );
    testWidgets(
      look == TonosPreviewLook.classic
          ? 'Classic baseline classifies inactive Progress zero-duration crossfade while Rest semantics remain actionable'
          : 'Expressive Rest dialog semantics survive French 2x reduced-motion presentation without layout errors',
      (tester) => _expectRestDialogSemantics(
        tester,
        look: look,
        localeOverride: const Locale('fr', 'CA'),
        textScaleOverride: 2,
        reducedMotion: true,
      ),
    );
  }

  testWidgets(
    'Expressive Train shell lays out when first built at 320dp and 2x',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final harness = await _PreviewHarness.create(
        tester,
        look: TonosPreviewLook.expressive,
        textScaleOverride: 2,
      );
      addTearDown(harness.dispose);
      await tester.pump(const Duration(milliseconds: 700));
      await _pumpTransientAnimations(tester);
      final semanticsHandle = tester.ensureSemantics();
      try {
        _expectPreviewEntryDoesNotOverlapTrainTabs(tester);
        _expectTrainTabsAtLeast48(tester);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets('Classic survives matched 393-to-320dp resize at 2x', (
    tester,
  ) async {
    await _expectLookResizeHasNoLayoutError(
      tester,
      look: TonosPreviewLook.classic,
    );
  });

  testWidgets('Expressive survives matched 393-to-320dp resize at 2x', (
    tester,
  ) async {
    await _expectLookResizeHasNoLayoutError(
      tester,
      look: TonosPreviewLook.expressive,
    );
  });

  testWidgets('Classic accepts a live 2x scale change with reduced motion', (
    tester,
  ) async {
    await _expectLiveScaleChangeHasNoLayoutError(
      tester,
      look: TonosPreviewLook.classic,
    );
  });

  testWidgets('Expressive accepts a live 2x scale change with reduced motion', (
    tester,
  ) async {
    await _expectLiveScaleChangeHasNoLayoutError(
      tester,
      look: TonosPreviewLook.expressive,
    );
  });
}

Future<void> _expectLookResizeHasNoLayoutError(
  WidgetTester tester, {
  required TonosPreviewLook look,
}) async {
  await tester.binding.setSurfaceSize(const Size(393, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final harness = await _PreviewHarness.create(
    tester,
    look: look,
    textScaleOverride: 2,
  );
  addTearDown(harness.dispose);
  await tester.pump(const Duration(milliseconds: 700));
  await _settlePreviewMotion(tester, look: look);
  await tester.binding.setSurfaceSize(const Size(320, 844));
  await _settlePreviewMotion(tester, look: look);
  if (look == TonosPreviewLook.expressive) {
    _expectTrainTabsAtLeast48(tester);
  }
  expect(tester.takeException(), isNull);
  await tester.pumpWidget(const SizedBox.shrink());
}

Future<void> _expectLiveScaleChangeHasNoLayoutError(
  WidgetTester tester, {
  required TonosPreviewLook look,
}) async {
  await tester.binding.setSurfaceSize(const Size(393, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final harness = await _PreviewHarness.create(tester, look: look);
  addTearDown(harness.dispose);
  await tester.pump(const Duration(milliseconds: 700));
  await _settlePreviewMotion(tester, look: look);

  harness.presentation.setReducedMotion(true);
  await tester.pumpAndSettle();
  expect(
    tester.takeException(),
    isNull,
    reason: '$look should stay layout-safe when reduced motion is enabled.',
  );

  harness.presentation.setTextScaleOverride(2);
  await tester.pumpAndSettle();
  expect(
    tester.takeException(),
    isNull,
    reason: '$look should reflow safely when live text scale changes to 2x.',
  );
  if (look == TonosPreviewLook.expressive) {
    _expectTrainTabsAtLeast48(tester);
  }
  await tester.pumpWidget(const SizedBox.shrink());
}

Future<void> _expectRestDialogSemantics(
  WidgetTester tester, {
  required TonosPreviewLook look,
  required Locale? localeOverride,
  required double? textScaleOverride,
  required bool reducedMotion,
}) async {
  await tester.binding.setSurfaceSize(const Size(393, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final harness = await _PreviewHarness.create(
    tester,
    look: look,
    restWarning: true,
    localeOverride: localeOverride,
    textScaleOverride: textScaleOverride,
    reducedMotion: reducedMotion,
  );
  addTearDown(harness.dispose);
  final capturedLayoutErrors = <Object>[];
  _capturePendingFlutterErrors(tester, capturedLayoutErrors);
  final semanticsHandle = tester.ensureSemantics();
  try {
    await _settlePreviewMotion(
      tester,
      look: look,
      reducedMotion: reducedMotion,
    );
    _capturePendingFlutterErrors(tester, capturedLayoutErrors);
    final trainContext = tester.element(find.byType(TrainPage));
    final strings = AppLocalizations.of(trainContext);
    await tester.tap(find.text(strings.trainOptimize));
    _capturePendingFlutterErrors(tester, capturedLayoutErrors);
    await tester.pump(const Duration(seconds: 5));
    _capturePendingFlutterErrors(tester, capturedLayoutErrors);

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    final preFlushSnapshot = _restDialogSnapshot(tester, dialog);
    final preFlushNames = _restDialogSemanticCounts(strings);
    expect(preFlushSnapshot, contains('routeStatus=forward'));
    expect(preFlushNames['okay'], 0);

    // The Optimize action keeps its progress indicator alive until this
    // dialog is dismissed, so settle the modal route itself rather than the
    // whole application scheduler.
    await _pumpUntilDialogRouteCompletes(tester, dialog);
    await tester.pump();
    _capturePendingFlutterErrors(tester, capturedLayoutErrors);
    final settledSnapshot = _restDialogSnapshot(tester, dialog);
    final settledNames = _restDialogSemanticCounts(strings);

    expect(
      settledSnapshot,
      contains('routeStatus=completed'),
      reason: 'The actual dialog route must finish before semantics are read.',
    );
    expect(settledSnapshot, contains('offstage=false'));
    expect(settledNames['title'], 1);
    expect(settledNames['body'], 1);
    expect(settledNames['okay'], 1);

    final okaySemantics = find.bySemanticsLabel(strings.commonOkay);
    final okayData = tester.getSemantics(okaySemantics).getSemanticsData();
    expect(okayData.label, strings.commonOkay);
    expect(okayData.flagsCollection.isButton, isTrue);
    expect(okayData.hasAction(SemanticsAction.tap), isTrue);

    await tester.tap(find.text(strings.commonOkay));
    if (look == TonosPreviewLook.expressive && !reducedMotion) {
      await _pumpUntilDialogDismisses(tester);
    } else {
      await _settlePreviewMotion(
        tester,
        look: look,
        reducedMotion: reducedMotion,
      );
    }
    _capturePendingFlutterErrors(tester, capturedLayoutErrors);
    expect(find.byType(AlertDialog), findsNothing);
    if (look == TonosPreviewLook.classic &&
        localeOverride == const Locale('fr', 'CA') &&
        textScaleOverride == 2 &&
        reducedMotion) {
      _expectKnownClassicInactiveProgressCrossfade(
        tester,
        capturedLayoutErrors,
      );
    } else {
      expect(capturedLayoutErrors, isEmpty);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  } finally {
    semanticsHandle.dispose();
  }
}

void _capturePendingFlutterErrors(WidgetTester tester, List<Object> captured) {
  Object? exception;
  while ((exception = tester.takeException()) != null) {
    captured.add(exception!);
  }
}

void _expectKnownClassicInactiveProgressCrossfade(
  WidgetTester tester,
  List<Object> errors,
) {
  expect(errors, hasLength(1));
  expect(errors.single, isA<FlutterError>());
  expect(
    errors.single.toString(),
    contains('A RenderAnimatedSize was mutated in its own performLayout'),
  );

  final progressPage = find.byType(MeasurementsTrendsPage, skipOffstage: false);
  final chart = find.descendant(
    of: progressPage,
    matching: find.byType(WorkoutMetricChartCard, skipOffstage: false),
    skipOffstage: false,
  );
  expect(chart, findsOneWidget);
  final disclosure = find.descendant(
    of: chart,
    matching: find.byType(AnimatedCrossFade, skipOffstage: false),
    skipOffstage: false,
  );
  expect(disclosure, findsOneWidget);
  final disclosureElement = tester.element(disclosure);
  final disclosureWidget = tester.widget<AnimatedCrossFade>(disclosure);
  expect(disclosureWidget.crossFadeState, CrossFadeState.showFirst);
  expect(disclosureWidget.duration, Duration.zero);
  expect(TickerMode.valuesOf(disclosureElement).enabled, isFalse);
  expect(MediaQuery.disableAnimationsOf(disclosureElement), isTrue);
}

void _expectClassicBottomTabAction(
  WidgetTester tester,
  String label, {
  required bool selected,
}) {
  final tab = find.descendant(
    of: find.byType(BottomNavigationBar),
    matching: find.bySemanticsLabel(RegExp('^${RegExp.escape(label)}')),
  );
  expect(tab, findsOneWidget, reason: 'Expected one bottom-tab action: $label');
  final data = tester.getSemantics(tab).getSemanticsData();
  expect(data.hasAction(SemanticsAction.tap), isTrue, reason: label);
  _expectSelectedFlag(data.flagsCollection.isSelected, selected, label);
}

String _restDialogSnapshot(WidgetTester tester, Finder dialog) {
  final dialogElement = tester.element(dialog);
  final route = ModalRoute.of(dialogElement);
  final routeAnimation = route?.animation;
  final box = dialogElement.findRenderObject()! as RenderBox;
  final rect = box.localToGlobal(Offset.zero) & box.size;
  final offstage = find
      .ancestor(of: dialog, matching: find.byType(Offstage))
      .evaluate()
      .any((element) => (element.widget as Offstage).offstage);
  final fadeValues = find
      .ancestor(of: dialog, matching: find.byType(FadeTransition))
      .evaluate()
      .map(
        (element) =>
            (element.widget as FadeTransition).opacity.value.toStringAsFixed(3),
      )
      .toList(growable: false);
  return 'routeStatus=${routeAnimation?.status.name}, '
      'routeValue=${routeAnimation?.value.toStringAsFixed(3)}, '
      'routeCurrent=${route?.isCurrent}, size=${box.size}, rect=$rect, '
      'fade=$fadeValues, offstage=$offstage';
}

Map<String, int> _restDialogSemanticCounts(AppLocalizations strings) => {
  'title': find.bySemanticsLabel(strings.trainRestTitle).evaluate().length,
  'body': find.bySemanticsLabel(strings.trainRestBody).evaluate().length,
  'okay': find.bySemanticsLabel(strings.commonOkay).evaluate().length,
};

Future<void> _pumpUntilDialogRouteCompletes(
  WidgetTester tester,
  Finder dialog,
) async {
  final route = ModalRoute.of(tester.element(dialog));
  expect(route, isNotNull);
  for (var frame = 0; frame < 30; frame++) {
    final animation = route!.animation;
    if (animation?.status == AnimationStatus.completed &&
        animation?.value == 1) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(
    route!.animation?.status,
    AnimationStatus.completed,
    reason: 'The actual AlertDialog route must complete within 1.5 seconds.',
  );
}

void _expectTrainTabsAtLeast48(WidgetTester tester) {
  expect(
    tester.getRect(find.byKey(AppTestKeys.trainOverviewTab)).size.height,
    greaterThanOrEqualTo(48),
  );
  expect(
    tester.getRect(find.byKey(AppTestKeys.trainPlansTab)).size.height,
    greaterThanOrEqualTo(48),
  );
}

void _expectPreviewEntryDoesNotOverlapTrainTabs(WidgetTester tester) {
  final entry = tester.getRect(find.byIcon(Icons.tune));
  for (final tab in [
    find.byKey(AppTestKeys.trainOverviewTab),
    find.byKey(AppTestKeys.trainPlansTab),
  ]) {
    expect(entry.overlaps(tester.getRect(tab)), isFalse);
  }
}

void _expectSingleTapNode(
  WidgetTester tester,
  String label, {
  required bool selected,
}) {
  final finder = find.bySemanticsLabel(label);
  expect(finder, findsOneWidget, reason: 'Expected one semantic node: $label');
  final node = tester.getSemantics(finder);
  final data = node.getSemanticsData();
  expect(data.hasAction(SemanticsAction.tap), isTrue, reason: label);
  _expectSelectedFlag(data.flagsCollection.isSelected, selected, label);
}

void _expectSelectedFlag(Tristate actual, bool selected, String label) {
  if (selected) {
    expect(actual, Tristate.isTrue, reason: label);
  } else {
    expect(actual, isNot(Tristate.isTrue), reason: label);
  }
}

class _PreviewHarness {
  _PreviewHarness(this.repository, this.presentation, this.themeProvider);

  final _QualificationRepository repository;
  final TonosPreviewPresentation presentation;
  final ThemeProvider themeProvider;

  static Future<_PreviewHarness> create(
    WidgetTester tester, {
    bool restWarning = false,
    TonosPreviewLook look = TonosPreviewLook.expressive,
    double? textScaleOverride,
    Locale? localeOverride,
    bool reducedMotion = false,
  }) async {
    SharedPreferences.setMockInitialValues({
      for (final tutorialId in TutorialIds.all)
        'guided_tutorial_completed.$tutorialId': true,
    });
    final repository = _QualificationRepository(restWarning: restWarning);
    final presentation = TonosPreviewPresentation();
    presentation
      ..setLook(look)
      ..setTextScaleOverride(textScaleOverride)
      ..setLocaleOverride(localeOverride)
      ..setReducedMotion(reducedMotion);
    final themeProvider = await ThemeProvider.load();
    await tester.pumpWidget(
      buildTonosApp(
        repo: repository,
        closeRepositoryOnDispose: false,
        themeProvider: themeProvider,
        previewPresentation: presentation,
      ),
    );
    await _settlePreviewMotion(
      tester,
      look: look,
      reducedMotion: reducedMotion,
    );
    return _PreviewHarness(repository, presentation, themeProvider);
  }

  void dispose() {
    presentation.dispose();
    themeProvider.dispose();
  }
}

Future<void> _pumpTransientAnimations(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 750));

Future<void> _pumpUntilDialogDismisses(WidgetTester tester) async {
  final dialog = find.byType(AlertDialog);
  for (var frame = 0; frame < 30 && dialog.evaluate().isNotEmpty; frame++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(
    dialog,
    findsNothing,
    reason: 'The dialog route should dismiss within 1.5 seconds.',
  );
}

Future<void> _settlePreviewMotion(
  WidgetTester tester, {
  TonosPreviewLook look = TonosPreviewLook.expressive,
  bool reducedMotion = false,
}) async {
  if (look == TonosPreviewLook.expressive && !reducedMotion) {
    await _pumpTransientAnimations(tester);
  } else {
    await tester.pumpAndSettle();
  }
}

class _QualificationRepository extends AppRepository {
  _QualificationRepository({required this.restWarning})
    : profile = GymProfile(
        id: 1,
        name: _profileName,
        createdAt: DateTime(2026),
      ),
      _restBodyParts = List<BodyPart>.generate(
        4,
        (index) => BodyPart(index + 1, 'Body part ${index + 1}'),
      );

  final bool restWarning;
  final GymProfile profile;
  final List<BodyPart> _restBodyParts;
  int bodyPartHistoryFetchCount = 0;
  int allBodyPartsFetchCount = 0;

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => [profile];

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => const [];

  @override
  Future<String?> getAppState(String key) async => '1';

  @override
  Future<void> setAppState(String key, String? value) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({
    int? profileId,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> fetchPresetFocusSetCountsRaw({
    required List<int> presetIds,
  }) async => const [];

  @override
  Future<Set<int>> loadActivePlans(int profileId) async => const <int>{};

  @override
  Future<void> replaceActivePlans(int profileId, Set<int> presetIds) async {}

  @override
  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async {
    bodyPartHistoryFetchCount++;
    return {
      if (restWarning)
        for (final part in _restBodyParts) part: 20,
    };
  }

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async {
    allBodyPartsFetchCount++;
    return restWarning ? _restBodyParts : const <BodyPart>[];
  }

  @override
  Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) async =>
      null;

  @override
  Future<Map<int, double>> fetchSetsPerMuscle({
    required DateTime start,
    required DateTime end,
  }) async => const <int, double>{};

  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => const <Muscle>[];

  @override
  Future<List<Map<String, dynamic>>> fetchMostUsedExerciseDefinitionsRaw({
    int limit = 5,
  }) async => const [];

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailedByIds(
    List<int> definitionIds,
  ) async => const [];

  @override
  Future<List<Map<String, dynamic>>> fetchExerciseOneRmTrendRows({
    required int definitionId,
    int limit = 60,
  }) async => const [];

  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async => const [];

  @override
  Future<void> ensureDefaultMeasurementDefinitions() async {}

  @override
  Future<List<MeasurementDefinition>>
  fetchClassMeasurementDefinitions() async => const [];

  @override
  Future<List<Measurement>> fetchClassMeasurementsForDefinition(
    int defId,
  ) async => const [];
}
