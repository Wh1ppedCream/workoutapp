import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/train_page.dart';
import 'package:env_test/services/active_plan_store.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_data_visualization_tokens.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/theme/tokens/app_progress_colors.dart';
import 'package:env_test/theme/tokens/app_semantic_colors.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/generic_bar.dart';
import 'package:env_test/widgets/preset_bar.dart';
import 'package:env_test/widgets/seven_day_focus_card.dart';
import 'package:env_test/widgets/tonos_train_tabs.dart';

void main() {
  test(
    'paired Expressive recipes register slots and freeze domain palettes',
    () {
      for (final brightness in Brightness.values) {
        final treatmentFactory = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light
            : ExpressiveThemeDefinition.dark;
        final generated = treatmentFactory(
          treatment: ExpressivePaletteTreatment.generated,
        );
        final curated = treatmentFactory(
          treatment: ExpressivePaletteTreatment.curated,
        );
        final classic = brightness == Brightness.light
            ? ClassicThemeDefinition.light()
            : ClassicThemeDefinition.dark();

        expect(
          curated.appThemeFamilyIdentity,
          AppThemeFamilyIdentity.expressivePreview,
        );
        expect(curated.extensions.length, 16);
        expect(
          identical(
            curated,
            treatmentFactory(treatment: ExpressivePaletteTreatment.curated),
          ),
          isTrue,
        );
        expect(generated.colorScheme, curated.colorScheme);
        expect(
          curated.semanticColors.primaryAction,
          curated.colorScheme.primary,
        );
        expect(
          curated.semanticColors.startWorkoutAction,
          curated.colorScheme.primary,
        );
        final trainTokens = curated.extension<AppExpressiveTrainTokens>()!;
        expect(
          trainTokens.actionPrimary,
          isNot(curated.semanticColors.startWorkoutAction),
        );
        expect(generated.extension<AppExpressiveTrainTokens>(), trainTokens);
        expect(classic.extension<AppExpressiveTrainTokens>(), isNull);
        expect(curated.shapeTokens.card, BorderRadius.circular(18));
        expect(curated.shapeTokens.planCard, BorderRadius.circular(18));
        expect(
          curated.surfaceTokens.card,
          curated.colorScheme.surfaceContainer,
        );
        expect(
          curated.surfaceTokens.sheet,
          curated.colorScheme.surfaceContainerHigh,
        );

        final expressiveProgress = curated.extension<AppProgressColors>()!;
        final classicProgress = classic.extension<AppProgressColors>()!;
        expect(expressiveProgress.accent, classicProgress.accent);
        expect(
          expressiveProgress.workoutIncrease,
          classicProgress.workoutIncrease,
        );
        expect(
          expressiveProgress.workoutDecrease,
          classicProgress.workoutDecrease,
        );
        expect(
          expressiveProgress.estimatedOneRm,
          classicProgress.estimatedOneRm,
        );

        final expressiveSeries = curated
            .extension<AppDataVisualizationTokens>()!;
        final classicSeries = classic.extension<AppDataVisualizationTokens>()!;
        expect(expressiveSeries.primarySeries, classicSeries.primarySeries);
        expect(expressiveSeries.secondarySeries, classicSeries.secondarySeries);
        expect(expressiveSeries.tertiarySeries, classicSeries.tertiarySeries);
        expect(curated.extension<AppSemanticColors>(), isNotNull);
      }
    },
  );

  testWidgets('shared PresetBar stays scoped without the Train opt-in', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ExpressiveThemeDefinition.light(),
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PresetBar(
            presetId: 91,
            label: 'Route Plan',
            color: const Color(0xff4285f4),
            index: 0,
            onRefresh: () {},
          ),
        ),
      ),
    );

    expect(find.byType(GenericBar), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('expressive-plan-91')),
      findsNothing,
    );
    expect(find.byType(TonosExpressiveReveal), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Train Overview and Plans keep their real states and actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final brightness in Brightness.values) {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await const TutorialStateStore().skipAll();
      final repository = _ExpressiveTrainRepository();
      final profile = _ExpressiveSelectedProfile(repository: repository);
      final session = ActiveSession(
        repository: repository,
        retryDelay: (_) async {},
      );
      addTearDown(profile.dispose);
      addTearDown(session.dispose);
      await session.ready;

      final lightTheme = ExpressiveThemeDefinition.light();
      final darkTheme = ExpressiveThemeDefinition.dark();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            Provider<ActivePlanStore>.value(
              value: ActivePlanStore(repository: repository),
            ),
            ChangeNotifierProvider<SelectedProfile>.value(value: profile),
            ChangeNotifierProvider<ActiveSession>.value(value: session),
          ],
          child: MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TrainPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      final pageContext = tester.element(find.byType(TrainPage));
      final theme = Theme.of(pageContext);
      final strings = AppLocalizations.of(pageContext);
      expect(theme.usesExpressivePresentation, isTrue);
      expect(find.byKey(AppTestKeys.trainStartWorkout), findsOneWidget);
      expect(find.text(strings.sevenDayFocusTitle), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);

      final start = find.byKey(AppTestKeys.trainStartWorkout);
      final startText = find.text(strings.trainStartWorkout);
      expect(tester.widget<Text>(startText).style?.fontWeight, FontWeight.w600);
      final startSize = tester.getSize(start);
      final responseFinder = find.ancestor(
        of: start,
        matching: find.byType(TonosExpressivePressResponse),
      );
      expect(responseFinder, findsOneWidget);
      final responseClip = find.descendant(
        of: responseFinder,
        matching: find.byType(ClipRRect),
      );
      final press = await tester.startGesture(tester.getCenter(start));
      await tester.pump();
      final pressedRadius =
          tester.widget<ClipRRect>(responseClip).borderRadius as BorderRadius;
      expect(pressedRadius.topLeft.x, 14);
      expect(pressedRadius.topRight.x, 14);
      expect(tester.getSize(start), startSize);
      await press.cancel();
      await tester.pump();
      await _pumpExpressiveFrames(tester);
      final restRadius =
          tester.widget<ClipRRect>(responseClip).borderRadius as BorderRadius;
      expect(restRadius.topLeft.x, 22);
      expect(restRadius.topRight.x, 22);

      final plansTab = find.byKey(AppTestKeys.trainPlansTab);
      await tester.tap(plansTab);
      await tester.pump();
      await tester.pump();
      final plansEntry = find.byKey(
        const ValueKey<String>('expressive-plans-entry'),
      );
      final planReveals = find.descendant(
        of: plansEntry,
        matching: find.byType(TonosExpressiveReveal),
      );
      expect(planReveals, findsWidgets);
      expect(
        tester
            .widgetList<TonosExpressiveReveal>(planReveals)
            .every((reveal) => reveal.enabled),
        isTrue,
      );
      final plansSemantics = tester
          .getSemantics(find.bySemanticsLabel(strings.trainPlansTab))
          .getSemanticsData();
      expect(plansSemantics.flagsCollection.isSelected, Tristate.isTrue);

      final plansList = find.byKey(AppTestKeys.trainPlansList);
      for (final label in [
        strings.trainActivePlans,
        strings.trainArchivedPlans,
        strings.trainPremadePlans,
        strings.trainGenerateCustomPlans,
        strings.trainManuallyAddPlan,
      ]) {
        final finder = find.descendant(
          of: plansList,
          matching: find.text(label),
        );
        await tester.ensureVisible(finder);
        await tester.pump();
        expect(finder, findsOneWidget, reason: label);
      }
      expect(find.text('Plan 1'), findsOneWidget);
      expect(find.text('Plan 2'), findsOneWidget);
      expect(find.text('Plan 3'), findsOneWidget);
      expect(find.text('Plan 4'), findsNothing);
      expect(
        find.byKey(const ValueKey<String>('expressive-plan-1')),
        findsOneWidget,
      );

      final showMore = find.byKey(
        const ValueKey<String>('expressive-plan-show-more'),
      );
      expect(showMore, findsOneWidget);
      await tester.ensureVisible(showMore);
      await _pumpExpressiveFrames(tester);
      await tester.tap(showMore);
      await _pumpExpressiveFrames(tester);
      for (var index = 4; index <= 8; index++) {
        expect(find.text('Plan $index'), findsOneWidget);
      }
      expect(find.text('Plan 9'), findsNothing);
      final showMoreAgain = find.byKey(
        const ValueKey<String>('expressive-plan-show-more'),
      );
      expect(showMoreAgain, findsOneWidget);
      await tester.ensureVisible(showMoreAgain);
      await _pumpExpressiveFrames(tester);
      await tester.tap(showMoreAgain);
      await _pumpExpressiveFrames(tester);
      expect(find.text('Plan 9'), findsOneWidget);
      await tester.tap(find.byKey(AppTestKeys.trainOverviewTab));
      await _pumpExpressiveFrames(tester);
      expect(
        tester
            .widgetList<TonosExpressiveReveal>(planReveals)
            .every((reveal) => !reveal.enabled),
        isTrue,
      );
      await tester.tap(plansTab);
      await _pumpExpressiveFrames(tester);
      expect(
        tester
            .widgetList<TonosExpressiveReveal>(planReveals)
            .every((reveal) => reveal.enabled),
        isTrue,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('Weekly Overview fits Pixel 7 size and text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    tester.platformDispatcher.textScaleFactorTestValue = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await const TutorialStateStore().skipAll();
    final repository = _ExpressiveTrainRepository(
      bodyPartSets: <BodyPart, double>{
        BodyPart(1, 'Shoulders'): 12,
        BodyPart(2, 'Lower Back'): 3,
        BodyPart(3, 'Core'): 2,
        BodyPart(4, 'Chest'): 1,
      },
    );
    final profile = _ExpressiveSelectedProfile(repository: repository);
    final session = ActiveSession(
      repository: repository,
      retryDelay: (_) async {},
    );
    addTearDown(profile.dispose);
    addTearDown(session.dispose);
    await session.ready;

    await _pumpExpressiveTrain(tester, repository, profile, session);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 700));
    final focusLayout = find.byKey(
      const ValueKey('seven-day-focus-side-by-side'),
    );
    expect(
      tester.takeException(),
      isNull,
      reason: 'the Weekly Overview should fit at the default text scale',
    );

    tester.platformDispatcher.textScaleFactorTestValue = 1.15;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    final scale = MediaQuery.textScalerOf(
      tester.element(find.byType(TrainPage)),
    ).scale(1);
    expect(scale, 1.15);
    expect(tester.getSize(focusLayout).height, greaterThan(198));

    expect(
      tester.takeException(),
      isNull,
      reason: 'the Weekly Overview should not overflow at Pixel 7 font scaling',
    );

    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(
      find.byKey(const ValueKey('seven-day-focus-stacked')),
      findsOneWidget,
    );
    expect(
      tester.takeException(),
      isNull,
      reason: 'the Weekly Overview should stack cleanly at 2x text scale',
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Weekly Overview ambient motion follows its visible viewport state',
    (tester) async {
      tester.view.physicalSize = const Size(360, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues(<String, Object>{});
      await const TutorialStateStore().skipAll();
      final repository = _ExpressiveTrainRepository();
      final profile = _ExpressiveSelectedProfile(repository: repository);
      final session = ActiveSession(
        repository: repository,
        retryDelay: (_) async {},
      );
      addTearDown(profile.dispose);
      addTearDown(session.dispose);
      await session.ready;

      await _pumpExpressiveTrain(tester, repository, profile, session);
      await tester.pump(const Duration(milliseconds: 100));

      final overviewScroll = find.byKey(
        const ValueKey<String>('expressive-overview-scroll'),
      );
      final focusCard = find.byType(SevenDayFocusCard);
      final ambientMotion = find.byType(TonosExpressiveAmbientMotion);
      expect(overviewScroll, findsOneWidget);
      expect(focusCard, findsOneWidget);
      expect(ambientMotion, findsOneWidget);
      expect(
        tester.widget<TonosExpressiveAmbientMotion>(ambientMotion).enabled,
        isTrue,
        reason: 'the Weekly Overview card starts inside the viewport',
      );

      final scrollable = find
          .descendant(of: overviewScroll, matching: find.byType(Scrollable))
          .first;
      await tester.drag(scrollable, const Offset(0, -420));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final scrollRect = tester.getRect(overviewScroll);
      final focusRect = tester.getRect(focusCard);
      final verticalIntersection =
          (focusRect.bottom.clamp(scrollRect.top, scrollRect.bottom) -
                  focusRect.top.clamp(scrollRect.top, scrollRect.bottom))
              .clamp(0.0, double.infinity);
      expect(verticalIntersection, greaterThan(0));
      expect(verticalIntersection, lessThan(24));
      expect(
        tester.widget<TonosExpressiveAmbientMotion>(ambientMotion).enabled,
        isFalse,
        reason:
            'ambient motion pauses when less than 24 dp of the card is visible',
      );

      await tester.drag(scrollable, const Offset(0, 420));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester.widget<TonosExpressiveAmbientMotion>(ambientMotion).enabled,
        isTrue,
        reason: 'ambient motion resumes when the card returns to view',
      );
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Expressive tab arrival is brief and preserves tab scroll state',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues(<String, Object>{});
      await const TutorialStateStore().skipAll();
      final repository = _ExpressiveTrainRepository();
      final profile = _ExpressiveSelectedProfile(repository: repository);
      final session = ActiveSession(
        repository: repository,
        retryDelay: (_) async {},
      );
      addTearDown(profile.dispose);
      addTearDown(session.dispose);
      await session.ready;

      await _pumpExpressiveTrain(tester, repository, profile, session);
      await _pumpExpressiveFrames(tester);

      final plansEntry = find.byKey(const ValueKey('expressive-plans-entry'));
      await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
      await tester.pump();
      final initialOffset = tester
          .widget<SlideTransition>(plansEntry)
          .position
          .value
          .dy;
      expect(initialOffset, greaterThan(0));
      expect(
        tester
            .getSemantics(
              find.bySemanticsLabel(
                AppLocalizations.of(tester.element(find.byType(TrainPage)))
                    .trainPlansTab,
              ),
            )
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
      await tester.pump(const Duration(milliseconds: 100));
      final middleOffset = tester
          .widget<SlideTransition>(plansEntry)
          .position
          .value
          .dy;
      expect(middleOffset, greaterThan(0));
      expect(middleOffset, lessThan(initialOffset));
      await _pumpExpressiveFrames(tester);
      await tester.pumpAndSettle();

      final plansList = find.byKey(AppTestKeys.trainPlansList);
      final manualAdd = find.text(
        AppLocalizations.of(tester.element(find.byType(TrainPage)))
            .trainManuallyAddPlan,
      );
      for (
        var attempt = 0;
        attempt < 8 && manualAdd.evaluate().isEmpty;
        attempt++
      ) {
        await tester.drag(plansList, const Offset(0, -360));
        await _pumpExpressiveFrames(tester);
      }
      expect(manualAdd, findsOneWidget);
      await tester.ensureVisible(manualAdd);
      await _pumpExpressiveFrames(tester);
      final scrollable = find
          .descendant(of: plansList, matching: find.byType(Scrollable))
          .first;
      final savedScrollPosition = tester
          .state<ScrollableState>(scrollable)
          .position
          .pixels;

      await tester.tap(find.byKey(AppTestKeys.trainOverviewTab));
      await _pumpExpressiveFrames(tester);
      await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
      await tester.pump();
      await _pumpExpressiveFrames(tester);
      await tester.pumpAndSettle();
      final returnedPosition = tester
          .state<ScrollableState>(scrollable)
          .position;
      expect(returnedPosition.pixels, savedScrollPosition);
      await tester.pump(const Duration(milliseconds: 700));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Expressive tab arrival snaps when reduced motion is enabled', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await const TutorialStateStore().skipAll();
    final repository = _ExpressiveTrainRepository();
    final profile = _ExpressiveSelectedProfile(repository: repository);
    final session = ActiveSession(
      repository: repository,
      retryDelay: (_) async {},
    );
    addTearDown(profile.dispose);
    addTearDown(session.dispose);
    await session.ready;

    await _pumpExpressiveTrain(
      tester,
      repository,
      profile,
      session,
      disableAnimations: true,
    );
    await _pumpExpressiveFrames(tester);

    final plansEntry = find.byKey(const ValueKey('expressive-plans-entry'));
    await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
    await tester.pump();
    expect(
      tester.widget<SlideTransition>(plansEntry).position.value,
      Offset.zero,
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      tester.widget<SlideTransition>(plansEntry).position.value,
      Offset.zero,
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Expressive horizontal action bar mirrors outer corners in RTL', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await const TutorialStateStore().skipAll();
    final repository = _ExpressiveTrainRepository();
    final profile = _ExpressiveSelectedProfile(repository: repository);
    final session = ActiveSession(
      repository: repository,
      retryDelay: (_) async {},
    );
    addTearDown(profile.dispose);
    addTearDown(session.dispose);
    await session.ready;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppRepository>.value(value: repository),
          Provider<ActivePlanStore>.value(
            value: ActivePlanStore(repository: repository),
          ),
          ChangeNotifierProvider<SelectedProfile>.value(value: profile),
          ChangeNotifierProvider<ActiveSession>.value(value: session),
        ],
        child: MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: TrainPage(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final pageContext = tester.element(find.byType(TrainPage));
    final strings = AppLocalizations.of(pageContext);
    final start = find.byKey(AppTestKeys.trainStartWorkout);
    final startRect = tester.getRect(start);
    final startSize = tester.getSize(start);
    final startResponse = find.ancestor(
      of: start,
      matching: find.byType(TonosExpressivePressResponse),
    );
    final startClip = find.descendant(
      of: startResponse,
      matching: find.byType(ClipRRect),
    );
    final startRestRadius =
        tester.widget<ClipRRect>(startClip).borderRadius as BorderRadius;
    expect(startRestRadius.topLeft.x, 0);
    expect(startRestRadius.bottomLeft.x, 0);
    expect(startRestRadius.topRight.x, 22);
    expect(startRestRadius.bottomRight.x, 22);

    final optimizeLabel = find.text(strings.trainOptimize);
    final optimizeClip = find.ancestor(
      of: optimizeLabel,
      matching: find.byWidgetPredicate((widget) {
        if (widget is! ClipRRect || widget.borderRadius is! BorderRadius) {
          return false;
        }
        final radius = widget.borderRadius as BorderRadius;
        return radius.topLeft.x == 22 &&
            radius.bottomLeft.x == 22 &&
            radius.topRight.x == 0 &&
            radius.bottomRight.x == 0;
      }),
    );
    expect(optimizeClip, findsOneWidget);
    final optimizeRadius =
        tester.widget<ClipRRect>(optimizeClip).borderRadius as BorderRadius;
    expect(optimizeRadius.topLeft.x, 22);
    expect(optimizeRadius.bottomLeft.x, 22);
    expect(optimizeRadius.topRight.x, 0);
    expect(optimizeRadius.bottomRight.x, 0);

    final settingsButton = find.ancestor(
      of: find.byTooltip(strings.trainOptimizedSettings),
      matching: find.byType(IconButton),
    );
    final settingsRect = tester.getRect(settingsButton);
    expect(startRect.left, greaterThan(settingsRect.right));

    final press = await tester.startGesture(tester.getCenter(start));
    await tester.pump();
    final pressedRadius =
        tester.widget<ClipRRect>(startClip).borderRadius as BorderRadius;
    expect(pressedRadius.topLeft.x, 0);
    expect(pressedRadius.bottomLeft.x, 0);
    expect(pressedRadius.topRight.x, 14);
    expect(pressedRadius.bottomRight.x, 14);
    expect(tester.getSize(start), startSize);
    await press.cancel();
    await tester.pump();
    await _pumpExpressiveFrames(tester);
    expect(tester.getSize(start), startSize);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Expressive Train tabs and action bar fit 320dp at 2x in French',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues(<String, Object>{});
      final repository = _ExpressiveTrainRepository();
      final profile = _ExpressiveSelectedProfile(repository: repository);
      final session = ActiveSession(
        repository: repository,
        retryDelay: (_) async {},
      );
      addTearDown(profile.dispose);
      addTearDown(session.dispose);
      await session.ready;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            Provider<ActivePlanStore>.value(
              value: ActivePlanStore(repository: repository),
            ),
            ChangeNotifierProvider<SelectedProfile>.value(value: profile),
            ChangeNotifierProvider<ActiveSession>.value(value: session),
          ],
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            locale: const Locale('fr'),
            supportedLocales: const [Locale('en'), Locale('fr')],
            localizationsDelegates: tonosLocalizationDelegates,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 900),
                textScaler: TextScaler.linear(2),
              ),
              child: const TickerMode(enabled: false, child: TrainPage()),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final tabs = find.byType(TonosTrainTabs);
      final tabsSize = tester.getSize(tabs);
      expect(tabsSize.width, lessThanOrEqualTo(320));
      final frameHeight = tester
          .getSize(find.byKey(const ValueKey('tonos-train-tabs-frame')))
          .height;
      final tabTexts = tester.widgetList<Text>(
        find.descendant(of: tabs, matching: find.byType(Text)),
      );
      for (final text in tabTexts) {
        expect(
          tester.getSize(find.text(text.data!)).height,
          lessThanOrEqualTo(frameHeight - 8),
        );
      }

      final start = find.byKey(AppTestKeys.trainStartWorkout);
      final actionBar = find.ancestor(
        of: start,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).borderRadius ==
                  ExpressiveTrainShapes.primaryAction,
        ),
      );
      expect(tester.getSize(actionBar).width, lessThanOrEqualTo(288));
      expect(tester.getSize(actionBar).height, greaterThanOrEqualTo(120));

      await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
      await _pumpExpressiveFrames(tester);
      final plansList = find.byKey(AppTestKeys.trainPlansList);
      for (final label in [
        AppLocalizations.of(tester.element(find.byType(TrainPage)))
            .trainActivePlans,
        AppLocalizations.of(tester.element(find.byType(TrainPage)))
            .trainArchivedPlans,
        AppLocalizations.of(tester.element(find.byType(TrainPage)))
            .trainPremadePlans,
        AppLocalizations.of(tester.element(find.byType(TrainPage)))
            .trainGenerateCustomPlans,
        AppLocalizations.of(tester.element(find.byType(TrainPage)))
            .trainManuallyAddPlan,
      ]) {
        final section = find.descendant(
          of: plansList,
          matching: find.text(label),
        );
        for (
          var attempt = 0;
          attempt < 8 && section.evaluate().isEmpty;
          attempt++
        ) {
          await tester.drag(plansList, const Offset(0, -360));
          await _pumpExpressiveFrames(tester);
        }
        expect(
          section,
          findsOneWidget,
          reason: '$label is reachable by scrolling',
        );
        await tester.ensureVisible(section);
        await _pumpExpressiveFrames(tester);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Expressive Train shows loading and repository failure states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await const TutorialStateStore().skipAll();
    final summaries = Completer<List<Map<String, dynamic>>>();
    final bodyPartSets = Completer<Map<BodyPart, double>>();
    final repository = _ExpressiveTrainRepository(
      presetSummariesFuture: summaries.future,
      bodyPartSetsFuture: bodyPartSets.future,
    );
    final profile = _ExpressiveSelectedProfile(repository: repository);
    final session = ActiveSession(
      repository: repository,
      retryDelay: (_) async {},
    );
    addTearDown(profile.dispose);
    addTearDown(session.dispose);
    await session.ready;

    await _pumpExpressiveTrain(tester, repository, profile, session);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    final pageContext = tester.element(find.byType(TrainPage));
    final strings = AppLocalizations.of(pageContext);
    await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    summaries.completeError(StateError('preset read failed'));
    bodyPartSets.completeError(StateError('history read failed'));
    await tester.pump();
    await tester.pump();

    expect(find.text(strings.presetsLoadError), findsWidgets);
    await tester.tap(find.byKey(AppTestKeys.trainOverviewTab));
    await tester.pump();
    expect(find.text(strings.sevenDayFocusLoadFailed), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Expressive Train keeps missing-profile and empty states clear', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await const TutorialStateStore().skipAll();
    final repository = _ExpressiveTrainRepository(presetSummaries: const []);
    final profile = _ExpressiveSelectedProfile(
      repository: repository,
      hasProfile: false,
    );
    final session = ActiveSession(
      repository: repository,
      retryDelay: (_) async {},
    );
    addTearDown(profile.dispose);
    addTearDown(session.dispose);
    await session.ready;

    await _pumpExpressiveTrain(tester, repository, profile, session);
    final strings = AppLocalizations.of(tester.element(find.byType(TrainPage)));
    expect(find.text(strings.trainSelectProfileForPlans), findsOneWidget);

    await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
    await tester.pump();
    expect(find.text(strings.presetsNoProfile), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());

    final emptyRepository = _ExpressiveTrainRepository(
      presetSummaries: const [],
      bodyPartSets: const <BodyPart, double>{},
    );
    final emptyProfile = _ExpressiveSelectedProfile(
      repository: emptyRepository,
    );
    final emptySession = ActiveSession(
      repository: emptyRepository,
      retryDelay: (_) async {},
    );
    addTearDown(emptyProfile.dispose);
    addTearDown(emptySession.dispose);
    await emptySession.ready;

    await _pumpExpressiveTrain(
      tester,
      emptyRepository,
      emptyProfile,
      emptySession,
    );
    final emptyStrings = AppLocalizations.of(
      tester.element(find.byType(TrainPage)),
    );
    expect(find.text(emptyStrings.sevenDayFocusEmpty), findsOneWidget);
    await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
    await tester.pump();
    await tester.pump();
    expect(find.text(emptyStrings.trainNoActivePlans), findsOneWidget);
    expect(find.text(emptyStrings.trainNoArchivedPlans), findsOneWidget);
    expect(find.text(emptyStrings.presetsNoPlans), findsNothing);
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Expressive Train surfaces stale plan selection and archived plans',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues(<String, Object>{});
      await const TutorialStateStore().skipAll();
      final repository = _ExpressiveTrainRepository(
        activePlanIds: const <int>{2, 4},
      );
      final profile = _ExpressiveSelectedProfile(repository: repository);
      final session = ActiveSession(
        repository: repository,
        retryDelay: (_) async {},
      );
      addTearDown(profile.dispose);
      addTearDown(session.dispose);
      await session.ready;

      await _pumpExpressiveTrain(tester, repository, profile, session);
      await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
      await tester.pump();
      await tester.pump();
      for (final name in ['Plan 2', 'Plan 4']) {
        expect(find.text(name), findsOneWidget);
      }
      for (final name in ['Plan 1', 'Plan 3', 'Plan 5']) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('Plan 6'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 700));

      final missingRepository = _ExpressiveTrainRepository(
        activePlanIds: const <int>{99},
      );
      final missingProfile = _ExpressiveSelectedProfile(
        repository: missingRepository,
      );
      final missingSession = ActiveSession(
        repository: missingRepository,
        retryDelay: (_) async {},
      );
      addTearDown(missingProfile.dispose);
      addTearDown(missingSession.dispose);
      await missingSession.ready;
      await _pumpExpressiveTrain(
        tester,
        missingRepository,
        missingProfile,
        missingSession,
      );
      await tester.tap(find.byKey(AppTestKeys.trainOverviewTab));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      final missingStrings = AppLocalizations.of(
        tester.element(find.byType(TrainPage)),
      );
      expect(
        find.text(missingStrings.trainSelectedPlansMissing),
        findsOneWidget,
      );
      await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
      await tester.pump();
      await tester.pump();
      expect(find.text(missingStrings.trainNoActivePlans), findsOneWidget);
      expect(find.text('Plan 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Expressive Optimize disables itself while generation is busy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await const TutorialStateStore().skipAll();
    final allBodyParts = Completer<List<BodyPart>>();
    final repository = _ExpressiveTrainRepository(
      allBodyPartsFuture: allBodyParts.future,
    );
    final profile = _ExpressiveSelectedProfile(repository: repository);
    final session = ActiveSession(
      repository: repository,
      retryDelay: (_) async {},
    );
    addTearDown(profile.dispose);
    addTearDown(session.dispose);
    await session.ready;

    await _pumpExpressiveTrain(tester, repository, profile, session);
    final strings = AppLocalizations.of(tester.element(find.byType(TrainPage)));
    await tester.tap(find.text(strings.trainOptimize));
    await tester.pump();
    await tester.pump();

    expect(find.text(strings.trainOptimize), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    final settingsTooltip = find.byTooltip(strings.trainOptimizedSettings);
    final settingsButton = find.ancestor(
      of: settingsTooltip,
      matching: find.byType(IconButton),
    );
    expect(tester.widget<IconButton>(settingsButton).onPressed, isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    allBodyParts.completeError(StateError('test cleanup'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
  });
}

class _ExpressiveTrainRepository extends AppRepository {
  _ExpressiveTrainRepository({
    this.activePlanIds = const <int>{},
    this.presetSummaries,
    this.presetSummariesFuture,
    this.bodyPartSets,
    this.bodyPartSetsFuture,
    this.allBodyPartsFuture,
  });

  final Set<int> activePlanIds;
  final List<Map<String, dynamic>>? presetSummaries;
  final Future<List<Map<String, dynamic>>>? presetSummariesFuture;
  final Map<BodyPart, double>? bodyPartSets;
  final Future<Map<BodyPart, double>>? bodyPartSetsFuture;
  final Future<List<BodyPart>>? allBodyPartsFuture;

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async {
    final pending = allBodyPartsFuture;
    if (pending != null) return pending;
    return const <BodyPart>[];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({
    int? profileId,
  }) async {
    final pending = presetSummariesFuture;
    if (pending != null) return pending;
    return presetSummaries ??
        List<Map<String, dynamic>>.generate(
          9,
          (index) => <String, dynamic>{
            'id': index + 1,
            'name': 'Plan ${index + 1}',
            'is_automatic': 0,
          },
        );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPresetFocusSetCountsRaw({
    required List<int> presetIds,
  }) async => const [];

  @override
  Future<Set<int>> loadActivePlans(int profileId) async => activePlanIds;

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];

  @override
  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final pending = bodyPartSetsFuture;
    if (pending != null) return pending;
    return bodyPartSets ??
        <BodyPart, double>{BodyPart(1, 'Chest'): 8, BodyPart(2, 'Back'): 3};
  }
}

class _ExpressiveSelectedProfile extends SelectedProfile {
  _ExpressiveSelectedProfile({
    required super.repository,
    bool hasProfile = true,
  }) {
    if (hasProfile) {
      final profile = GymProfile(
        id: 1,
        name: 'Test profile',
        createdAt: DateTime(2026),
      );
      profiles = [profile];
      currentProfile = profile;
    } else {
      profiles = [];
      currentProfile = null;
    }
  }

  @override
  Future<void> loadProfiles({int? preferredProfileId}) async {}
}

Future<void> _pumpExpressiveTrain(
  WidgetTester tester,
  AppRepository repository,
  SelectedProfile profile,
  ActiveSession session, {
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AppRepository>.value(value: repository),
        Provider<ActivePlanStore>.value(
          value: ActivePlanStore(repository: repository),
        ),
        ChangeNotifierProvider<SelectedProfile>.value(value: profile),
        ChangeNotifierProvider<ActiveSession>.value(value: session),
      ],
      child: MaterialApp(
        theme: ExpressiveThemeDefinition.light(),
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: disableAnimations),
            child: const TrainPage(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _pumpExpressiveFrames(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 800));
