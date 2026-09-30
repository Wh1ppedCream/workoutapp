import 'dart:ui' as ui;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kProfileMode;
import 'package:flutter/scheduler.dart' show TimingsCallback;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'package:env_test/dev/expressive_preview_fixtures.dart';
import 'package:env_test/dev/expressive_preview_safety.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/main.dart' show MainScreen, buildTonosApp;
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/providers/nav_bar_config.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/analytics_dashboard_screen.dart';
import 'package:env_test/screens/exercise/optimized_workout_settings_page.dart';
import 'package:env_test/screens/exercise/premade_plans_page.dart';
import 'package:env_test/screens/exercise/preset_detail_screen.dart';
import 'package:env_test/screens/exercise/preset_generation_qa.dart';
import 'package:env_test/screens/exercise/session_screen.dart';
import 'package:env_test/screens/catalog_page.dart';
import 'package:env_test/screens/exercise/train_page.dart';
import 'package:env_test/providers/theme_provider.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tonos_preview_presentation.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/tonos_bottom_navigation_bar.dart';
import 'package:env_test/widgets/tonos_train_tabs.dart';
import 'package:env_test/widgets/seven_day_focus_card.dart';
import 'package:env_test/widgets/weight_card.dart';

const _timingFlushDelay = Duration(seconds: 2);
const _idleObservationDuration = Duration(seconds: 3);
const _rapidSelectionCadence = Duration(milliseconds: 80);
const _measuredCyclesPerBatch = 6;
const _smokeOnlyDeviceRun = bool.fromEnvironment(
  'TONOS_PREVIEW_DEVICE_SMOKE_ONLY',
  defaultValue: false,
);
const _measurementOrder = <TonosPreviewLook>[
  TonosPreviewLook.classic,
  TonosPreviewLook.expressive,
  TonosPreviewLook.expressive,
  TonosPreviewLook.classic,
];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    _smokeOnlyDeviceRun
        ? 'smoke-only Workout compatibility on the isolated preview database'
        : 'profile matched Train shell interactions on the isolated preview database',
    (tester) async {
      final startupStopwatch = Stopwatch()..start();

      void startupCheckpoint(String stage) {
        debugPrint(
          '[expressive-preview-startup] '
          '+${startupStopwatch.elapsedMilliseconds}ms $stage',
        );
      }

      expect(
        kProfileMode,
        isTrue,
        reason: 'Device qualification must use a profile build.',
      );

      // This identity check must complete before preferences, the repository,
      // or the preview fixture manifest are read.
      startupCheckpoint('identity guard started');
      await ExpressivePreviewSafety.verifyBeforeDataAccess();
      startupCheckpoint('identity guard completed');
      final themeProvider = await ThemeProvider.load();
      startupCheckpoint('theme provider loaded');
      final repository = AppRepository();
      final fixtures = await ExpressivePreviewFixtures.prepare(repository);
      startupCheckpoint('fixtures prepared');
      final presentation = TonosPreviewPresentation();
      presentation.setLocaleOverride(const Locale('en'));
      final semanticsHandle = tester.ensureSemantics();
      try {
        startupCheckpoint('app mount started');
        await tester.pumpWidget(
          buildTonosApp(
            repo: repository,
            closeRepositoryOnDispose: false,
            themeProvider: themeProvider,
            previewPresentation: presentation,
          ),
        );
        startupCheckpoint('app mount completed; waiting for TrainPage');
        // MainScreen initially shows an indeterminate spinner while
        // NavBarConfig loads preferences. pumpAndSettle cannot finish while
        // that spinner is active, so wait for the concrete route readiness
        // condition with a fixed pump bound instead.
        await _waitForElement(
          tester,
          find.byType(TrainPage),
          maxPumps: 120,
        );
        startupCheckpoint('TrainPage ready');

        expect(find.byType(MainScreen), findsOneWidget);
        expect(find.byType(TrainPage), findsOneWidget);
        final trainContext = tester.element(find.byType(TrainPage));
        expect(trainContext.read<NavBarConfig>().items, hasLength(5));
        expect(fixtures.profileId, greaterThan(0));
        expect(
          await repository.loadActiveWorkoutDraft(),
          isNull,
          reason: 'The same seeded fixture starts each measured theme clean.',
        );

        final view = ui.PlatformDispatcher.instance.implicitView!;
        final refreshRateHz = view.display.refreshRate;
        expect(refreshRateHz, greaterThan(0));
        final frameBudgetMicros = (1000000 / refreshRateHz).round();
        final logicalSize = view.physicalSize / view.devicePixelRatio;
        debugPrint(
          '[expressive-preview-profile] '
          'platform=${defaultTargetPlatform.name} '
          'refreshRateHz=$refreshRateHz '
          'frameBudgetMicros=$frameBudgetMicros '
          'physicalSize=${view.physicalSize} '
          'logicalWidthDp=${logicalSize.width} '
          'logicalHeightDp=${logicalSize.height} '
          'devicePixelRatio=${view.devicePixelRatio}',
        );

        if (_smokeOnlyDeviceRun) {
          startupCheckpoint('smoke presentation setup started');
          presentation.setLook(TonosPreviewLook.expressive);
          presentation.setPaletteTreatment(ExpressivePaletteTreatment.curated);
          presentation.setBrightness(Brightness.light);
          presentation.setTextScaleOverride(1);
          presentation.setReducedMotion(false);
          presentation.setEffectsOff(false);
          await tester.pump(const Duration(milliseconds: 250));
          startupCheckpoint('smoke presentation setup rendered');

          final productionSession =
              await _exerciseProductionSessionCompatibility(
                tester,
                repository: repository,
                presentation: presentation,
              );
          expect(await repository.loadActiveWorkoutDraft(), isNull);
          expect(tester.takeException(), isNull);
          final previewContext = tester.element(find.byType(TrainPage));
          binding.reportData = <String, dynamic>{
            'expressivePreviewDeviceSmoke': <String, Object>{
              'mode': 'profile',
              'smokeOnly': true,
              'timingsMeasured': false,
              'phases': const <Object>[],
              'platform': defaultTargetPlatform.name,
              'deviceRefreshRateHz': refreshRateHz,
              'frameBudgetMicros': frameBudgetMicros,
              'logicalWidthDp': logicalSize.width,
              'logicalHeightDp': logicalSize.height,
              'devicePixelRatio': view.devicePixelRatio,
              'look': presentation.look.name,
              'paletteTreatment': presentation.paletteTreatment.name,
              'brightness': presentation.brightness.name,
              'textScaleOverride': presentation.textScaleOverride!,
              'reducedMotionControl': presentation.reducedMotion,
              'effectsOffControl': presentation.effectsOff,
              'effectiveAnimationsDisabled': MediaQuery.disableAnimationsOf(
                previewContext,
              ),
              'productionSessionCompatibility': productionSession,
            },
          };
          return;
        }

        // Warm both looks in both brightness modes before collecting samples.
        // No timing callback is attached during these interactions.
        for (final brightness in [Brightness.light, Brightness.dark]) {
          presentation.setBrightness(brightness);
          await tester.pumpAndSettle();
          for (final look in [
            TonosPreviewLook.classic,
            TonosPreviewLook.expressive,
          ]) {
            presentation.setLook(look);
            await tester.pumpAndSettle();
            await _resetTrainPosition(tester);
            await _exerciseMatchedInteractions(tester, cycles: 1);
          }
        }

        final phases = <Map<String, Object>>[];
        for (final brightness in [Brightness.light, Brightness.dark]) {
          presentation.setBrightness(brightness);
          await tester.pumpAndSettle();
          for (final look in [
            TonosPreviewLook.classic,
            TonosPreviewLook.expressive,
          ]) {
            presentation.setLook(look);
            await tester.pumpAndSettle();
            await _resetTrainPosition(tester);
            await Future<void>.delayed(_timingFlushDelay);

            late DateTime idleStartedAtUtc;
            late int idleDurationMicros;
            final timings = await _captureTimings(binding, () async {
              idleStartedAtUtc = DateTime.now().toUtc();
              final idleStopwatch = Stopwatch()..start();
              await Future<void>.delayed(_idleObservationDuration);
              idleStopwatch.stop();
              idleDurationMicros = idleStopwatch.elapsedMicroseconds;
            });
            final idlePhase =
                _profilePhase(
                    batch: 1,
                    brightness: brightness,
                    look: look,
                    pattern: 'quiet-idle-observation',
                    timings: timings,
                    frameBudgetMicros: frameBudgetMicros,
                    interactionCycles: null,
                  )
                  ..['idleStartedAtUtc'] = idleStartedAtUtc.toIso8601String()
                  ..['idleDurationMicros'] = idleDurationMicros
                  ..['idleFrameCount'] = timings.length;
            phases.add(idlePhase);
            debugPrint('[expressive-preview-profile] $idlePhase');
          }
        }

        for (final brightness in [Brightness.light, Brightness.dark]) {
          presentation.setBrightness(brightness);
          await tester.pumpAndSettle();
          for (var index = 0; index < _measurementOrder.length; index++) {
            final look = _measurementOrder[index];
            presentation.setLook(look);
            await tester.pumpAndSettle();
            await _resetTrainPosition(tester);
            await Future<void>.delayed(_timingFlushDelay);

            var timings = await _captureTimings(
              binding,
              () => _exerciseMatchedInteractions(
                tester,
                cycles: _measuredCyclesPerBatch,
              ),
            );
            expect(timings, isNotEmpty);
            var phase = _profilePhase(
              batch: index + 1,
              brightness: brightness,
              look: look,
              pattern: 'settled-mixed-interactions',
              timings: timings,
              frameBudgetMicros: frameBudgetMicros,
            );
            phases.add(phase);
            debugPrint('[expressive-preview-profile] $phase');

            await _resetTrainPosition(tester);
            await Future<void>.delayed(_timingFlushDelay);
            timings = await _captureTimings(
              binding,
              () => _exerciseRapidSelectionRetargeting(
                tester,
                cycles: _measuredCyclesPerBatch,
              ),
            );
            expect(timings, isNotEmpty);
            phase = _profilePhase(
              batch: index + 1,
              brightness: brightness,
              look: look,
              pattern: 'rapid-tab-and-nav-retargeting',
              timings: timings,
              frameBudgetMicros: frameBudgetMicros,
              inputCadenceMicros: _rapidSelectionCadence.inMicroseconds,
            );
            phases.add(phase);
            debugPrint('[expressive-preview-profile] $phase');
          }
        }
        presentation.setBrightness(Brightness.light);
        await tester.pumpAndSettle();

        final finalTrainContext = tester.element(find.byType(TrainPage));
        expect(
          await repository.loadActiveWorkoutDraft(),
          isNull,
          reason: 'The matched pointer-cancel Start response must not start a workout.',
        );
        expect(find.byType(CatalogPage), findsNothing);
        expect(find.byKey(AppTestKeys.trainOverviewTab), findsOneWidget);
        expect(finalTrainContext.read<NavBarConfig>().items, hasLength(5));
        expect(tester.takeException(), isNull);

        final functionalFlows = await _exerciseFunctionalPreviewFlows(
          tester,
          repository: repository,
          profileId: fixtures.profileId,
          presentation: presentation,
        );
        final productionSession = await _exerciseProductionSessionCompatibility(
          tester,
          repository: repository,
          presentation: presentation,
        );
        expect(await repository.loadActiveWorkoutDraft(), isNull);
        expect(tester.takeException(), isNull);

        binding.reportData = <String, dynamic>{
          'expressivePreviewProfile': <String, Object>{
            'mode': 'profile',
            'platform': defaultTargetPlatform.name,
            'targetPlatformIsAndroid':
                defaultTargetPlatform == TargetPlatform.android,
            'deviceRefreshRateHz': refreshRateHz,
            'frameBudgetMicros': frameBudgetMicros,
            'logicalWidthDp': logicalSize.width,
            'logicalHeightDp': logicalSize.height,
            'devicePixelRatio': view.devicePixelRatio,
            'measuredBrightnesses': <String>['light', 'dark'],
            'brightness': presentation.brightness.name,
            'fixtureProfileId': fixtures.profileId,
            'matchedInteractionOrder': _measurementOrder
                .map((look) => look.name)
                .toList(growable: false),
            'warmupExcluded': true,
            'phases': phases,
            'functionalFlows': functionalFlows,
            'productionSessionCompatibility': productionSession,
          },
        };
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        semanticsHandle.dispose();
        presentation.dispose();
        themeProvider.dispose();
        await repository.close();
      }
    },
  );
}

Map<String, Object> _profilePhase({
  required int batch,
  required Brightness brightness,
  required TonosPreviewLook look,
  required String pattern,
  required List<ui.FrameTiming> timings,
  required int frameBudgetMicros,
  int? interactionCycles = _measuredCyclesPerBatch,
  int? inputCadenceMicros,
}) {
  final phase = <String, Object>{
    'batch': batch,
    'brightness': brightness.name,
    'look': look.name,
    'pattern': pattern,
    'frameCount': timings.length,
    'build': _durationSummary(
      timings.map((frame) => frame.buildDuration.inMicroseconds),
      frameBudgetMicros,
    ),
    'raster': _durationSummary(
      timings.map((frame) => frame.rasterDuration.inMicroseconds),
      frameBudgetMicros,
    ),
    'slowFrameClusters': _slowFrameClusterCount(timings, frameBudgetMicros),
  };
  if (interactionCycles != null) {
    phase['interactionCycles'] = interactionCycles;
  }
  if (inputCadenceMicros != null) {
    phase['inputCadenceMicros'] = inputCadenceMicros;
  }
  return phase;
}

Future<List<String>> _exerciseFunctionalPreviewFlows(
  WidgetTester tester, {
  required AppRepository repository,
  required int profileId,
  required TonosPreviewPresentation presentation,
}) async {
  final completedFlows = <String>[];
  presentation.setLook(TonosPreviewLook.expressive);
  await tester.pumpAndSettle();
  await _showTrainOverview(tester);

  final focusCardAction = find.descendant(
    of: find.byType(SevenDayFocusPresentation),
    matching: find.byType(InkWell),
  );
  expect(focusCardAction, findsOneWidget);
  await tester.tap(focusCardAction);
  await tester.pumpAndSettle();
  expect(find.byType(AnalyticsDashboardScreen), findsOneWidget);
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
  completedFlows.add('analytics dashboard route and Back');

  final trainPage = find.byType(TrainPage);
  final strings = AppLocalizations.of(tester.element(trainPage));
  await tester.tap(find.byTooltip(strings.trainOptimizedSettings));
  await tester.pumpAndSettle();
  expect(find.byType(OptimizedWorkoutSettingsPage), findsOneWidget);
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
  completedFlows.add('Optimize settings gear route and Back');

  final entry = find.byIcon(Icons.tune);
  expect(entry, findsOneWidget);
  await tester.tap(entry);
  await tester.pumpAndSettle();
  expect(find.text('Preview controls'), findsOneWidget);
  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();
  completedFlows.add('root preview controls dialog open and close');

  await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
  await tester.pumpAndSettle();
  final plansList = find.byKey(AppTestKeys.trainPlansList).hitTestable();
  final plansScrollable = find.descendant(
    of: plansList,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable &&
          widget.physics is! NeverScrollableScrollPhysics,
    ),
  );
  expect(plansScrollable, findsOneWidget);

  final premadeAction = find.text(strings.trainBrowsePremadePlans);
  await tester.scrollUntilVisible(
    premadeAction,
    300,
    scrollable: plansScrollable,
  );
  await tester.tap(premadeAction);
  await tester.pumpAndSettle();
  expect(find.byType(PremadePlansPage), findsOneWidget);
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
  completedFlows.add('premade plans route and Back');

  final generateAction = find.text(strings.trainGenerateCustomPlans);
  await tester.scrollUntilVisible(
    generateAction,
    300,
    scrollable: plansScrollable,
  );
  await tester.tap(generateAction);
  await tester.pumpAndSettle();
  expect(find.byType(PresetGenerationQaScreen), findsOneWidget);
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
  completedFlows.add('custom plan generation route and Back');

  final initialPresetIds = (await repository.fetchAllPresetsRaw(
    profileId: profileId,
  )).map((row) => row['id'] as int).toSet();
  final initialActiveIds = await repository.loadActivePlans(profileId);
  try {
    final manualAction = find.byKey(AppTestKeys.trainCreateManualPlan);
    await tester.scrollUntilVisible(
      manualAction,
      300,
      scrollable: plansScrollable,
    );
    await tester.tap(manualAction);
    await tester.pump();
    await _waitForElement(tester, find.byType(PresetDetailScreen));
    expect(find.byType(PresetDetailScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    completedFlows.add('manual plan creation and detail route');
  } finally {
    await repository.replaceActivePlans(profileId, initialActiveIds);
    final currentPresetIds = (await repository.fetchAllPresetsRaw(
      profileId: profileId,
    )).map((row) => row['id'] as int);
    for (final presetId in currentPresetIds.where(
      (id) => !initialPresetIds.contains(id),
    )) {
      await repository.deletePreset(presetId);
    }
  }

  await _showTrainOverview(tester);
  final activeSession = tester
      .element(find.byType(MainScreen))
      .read<ActiveSession>();
  try {
    await tester.tap(find.byKey(AppTestKeys.trainStartWorkout));
    await tester.pump();
    await _waitForElement(tester, find.byType(SessionScreen));
    expect(find.byType(SessionScreen), findsOneWidget);
    expect(await repository.loadActiveWorkoutDraft(), isNotNull);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    final ongoingSessionMenu = find.byKey(AppTestKeys.ongoingSessionMenu);
    await _waitForElement(tester, ongoingSessionMenu);
    expect(ongoingSessionMenu, findsOneWidget);
    final menuRect = tester.getRect(ongoingSessionMenu);
    final logicalViewport =
        tester.view.physicalSize / tester.view.devicePixelRatio;
    final hitTestableMenu = ongoingSessionMenu.hitTestable();
    debugPrint(
      '[expressive-preview-workout-smoke] '
      'ongoing-session-menu rectDp='
      'left:${menuRect.left.toStringAsFixed(1)},'
      'top:${menuRect.top.toStringAsFixed(1)},'
      'width:${menuRect.width.toStringAsFixed(1)},'
      'height:${menuRect.height.toStringAsFixed(1)} '
      'logicalViewportDp='
      '${logicalViewport.width.toStringAsFixed(1)}x'
      '${logicalViewport.height.toStringAsFixed(1)} '
      'hitTestable=${hitTestableMenu.evaluate().isNotEmpty}',
    );
    expect(menuRect.width, greaterThanOrEqualTo(48));
    expect(menuRect.height, greaterThanOrEqualTo(48));
    expect(
      hitTestableMenu,
      findsOneWidget,
      reason: 'The returned-home session menu must be hit-testable.',
    );
    await tester.tap(hitTestableMenu);
    await tester.pumpAndSettle();
    await _waitForElement(tester, find.byKey(AppTestKeys.ongoingSessionExit));
    await tester.tap(find.byKey(AppTestKeys.ongoingSessionExit));
    await tester.pump();
    final cancelWorkout = find.text(strings.sessionCancelWorkout);
    await _waitForElement(tester, cancelWorkout);
    expect(cancelWorkout, findsOneWidget);
    await tester.tap(cancelWorkout);
    await tester.pumpAndSettle();
  } finally {
    if (activeSession.isActive) await activeSession.discard();
  }
  expect(await repository.loadActiveWorkoutDraft(), isNull);
  completedFlows.add('Start callback, Session route, and draft discard');

  return completedFlows;
}

Future<void> _waitForElement(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 120,
}) async {
  for (var pump = 0; pump < maxPumps; pump++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 250));
  }
  throw TestFailure(
    'Timed out waiting for the expected production route or control.',
  );
}

Future<Map<String, Object>> _exerciseProductionSessionCompatibility(
  WidgetTester tester, {
  required AppRepository repository,
  required TonosPreviewPresentation presentation,
}) async {
  final trainPage = find.byType(TrainPage);
  final strings = AppLocalizations.of(tester.element(trainPage));
  final activeSession = tester
      .element(find.byType(MainScreen))
      .read<ActiveSession>();
  final historyCountBefore = (await repository.fetchAllSessions()).length;

  var motionDisabled = false;
  var expansionDuration = Duration.zero;
  var expandedHeight = 0.0;
  var midpointHeight = 0.0;
  var collapsedHeight = 0.0;
  var autoCollapsedHeight = 0.0;
  var collapseInnerRect = Rect.zero;
  var collapseGlyphRect = Rect.zero;
  var collapseRect = Rect.zero;
  var menuGlyphRect = Rect.zero;
  var menuRect = Rect.zero;
  var checkboxRect = Rect.zero;
  var textScale = 1.0;
  try {
    await _showTrainOverview(tester);
    final presetTitle = find.text('Active Review 1').first;
    await tester.ensureVisible(presetTitle);
    await tester.tap(presetTitle);
    await tester.pump();
    await _waitForElement(tester, find.byType(PresetDetailScreen));

    final startPlan = find.byKey(AppTestKeys.planStartSession);
    await tester.ensureVisible(startPlan);
    await tester.tap(startPlan);
    await tester.pump();
    await _waitForElement(tester, find.byType(SessionScreen));
    await tester.pump(const Duration(milliseconds: 400));

    final card = find.byType(WeightCard).first;
    await tester.ensureVisible(card);
    expect(tester.widget<WeightCard>(card).animateExpansion, isTrue);
    expect(Theme.of(tester.element(card)).usesExpressivePresentation, isTrue);
    motionDisabled = MediaQuery.disableAnimationsOf(tester.element(card));
    textScale = MediaQuery.textScalerOf(tester.element(card)).scale(1);
    expansionDuration = motionDisabled
        ? Duration.zero
        : const Duration(milliseconds: 180);
    final expansionBuilder = find.descendant(
      of: card,
      matching: find.byType(TweenAnimationBuilder<double>),
    );
    if (motionDisabled) {
      expect(expansionBuilder, findsNothing);
    } else {
      expect(expansionBuilder, findsOneWidget);
      expect(
        tester.widget<TweenAnimationBuilder<double>>(expansionBuilder).duration,
        expansionDuration,
      );
    }

    final collapseTooltip = find.descendant(
      of: card,
      matching: find.byTooltip(strings.weightCollapseSets),
    );
    expect(collapseTooltip, findsOneWidget);
    final collapseControl = find.ancestor(
      of: collapseTooltip,
      matching: find.byType(IconButton),
    );
    expect(collapseControl, findsOneWidget);
    await tester.ensureVisible(collapseControl);
    collapseInnerRect = tester.getRect(collapseTooltip);
    final collapseGlyph = find.descendant(
      of: card,
      matching: find.byIcon(Icons.keyboard_arrow_up),
    );
    expect(collapseGlyph, findsOneWidget);
    collapseGlyphRect = tester.getRect(collapseGlyph);
    collapseRect = tester.getRect(collapseControl);
    final hitTestableCollapse = collapseControl.hitTestable();
    debugPrint(
      '[expressive-preview-workout-smoke] '
      'collapse innerDp='
      '${collapseInnerRect.width.toStringAsFixed(1)}x'
      '${collapseInnerRect.height.toStringAsFixed(1)} '
      'glyphDp='
      '${collapseGlyphRect.width.toStringAsFixed(1)}x'
      '${collapseGlyphRect.height.toStringAsFixed(1)} '
      'outerTargetDp='
      '${collapseRect.width.toStringAsFixed(1)}x'
      '${collapseRect.height.toStringAsFixed(1)} '
      'hitTestable=${hitTestableCollapse.evaluate().isNotEmpty}',
    );
    expect(collapseRect.width, greaterThanOrEqualTo(48));
    expect(collapseRect.height, greaterThanOrEqualTo(48));
    expect(hitTestableCollapse, findsOneWidget);

    final cardMenuGlyph = find.descendant(
      of: card,
      matching: find.byIcon(Icons.more_vert),
    );
    expect(cardMenuGlyph, findsOneWidget);
    menuGlyphRect = tester.getRect(cardMenuGlyph);
    final cardMenu = find.ancestor(
      of: cardMenuGlyph,
      matching: find.byType(IconButton),
    );
    expect(cardMenu, findsOneWidget);
    menuRect = tester.getRect(cardMenu);
    final hitTestableCardMenu = cardMenu.hitTestable();
    debugPrint(
      '[expressive-preview-workout-smoke] '
      'menu glyphDp='
      '${menuGlyphRect.width.toStringAsFixed(1)}x'
      '${menuGlyphRect.height.toStringAsFixed(1)} '
      'outerTargetDp='
      '${menuRect.width.toStringAsFixed(1)}x'
      '${menuRect.height.toStringAsFixed(1)} '
      'hitTestable=${hitTestableCardMenu.evaluate().isNotEmpty}',
    );
    expect(menuRect.width, greaterThanOrEqualTo(48));
    expect(menuRect.height, greaterThanOrEqualTo(48));
    expect(hitTestableCardMenu, findsOneWidget);
    await tester.tapAt(Offset(menuRect.left + 1, menuRect.center.dy));
    await tester.pumpAndSettle();
    await _waitForElement(tester, find.text(strings.weightMakeChangeSet));
    expect(find.text(strings.weightMakeChangeSet), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(strings.weightMakeChangeSet), findsNothing);

    final collapseTooltipAfterMenu = find.descendant(
      of: card,
      matching: find.byTooltip(strings.weightCollapseSets),
    );
    expect(collapseTooltipAfterMenu, findsOneWidget);
    final collapseControlAfterMenu = find.ancestor(
      of: collapseTooltipAfterMenu,
      matching: find.byType(IconButton),
    );
    expect(collapseControlAfterMenu, findsOneWidget);
    await tester.ensureVisible(collapseControlAfterMenu);
    final collapseRectAfterMenu = tester.getRect(collapseControlAfterMenu);
    final collapseRectDelta =
        collapseRectAfterMenu.topLeft - collapseRect.topLeft;
    debugPrint(
      '[expressive-preview-workout-smoke] '
      'collapse target beforeMenu='
      '${collapseRect.left.toStringAsFixed(1)},'
      '${collapseRect.top.toStringAsFixed(1)},'
      '${collapseRect.width.toStringAsFixed(1)}x'
      '${collapseRect.height.toStringAsFixed(1)} '
      'afterMenu='
      '${collapseRectAfterMenu.left.toStringAsFixed(1)},'
      '${collapseRectAfterMenu.top.toStringAsFixed(1)},'
      '${collapseRectAfterMenu.width.toStringAsFixed(1)}x'
      '${collapseRectAfterMenu.height.toStringAsFixed(1)} '
      'deltaDp=${collapseRectDelta.dx.toStringAsFixed(1)},'
      '${collapseRectDelta.dy.toStringAsFixed(1)}',
    );
    expect(collapseRectAfterMenu.width, greaterThanOrEqualTo(48));
    expect(collapseRectAfterMenu.height, greaterThanOrEqualTo(48));
    expect(collapseControlAfterMenu.hitTestable(), findsOneWidget);

    expandedHeight = tester.getSize(card).height;
    await tester.tapAt(
      Offset(collapseRectAfterMenu.left + 1, collapseRectAfterMenu.center.dy),
    );
    await tester.pump();
    if (motionDisabled) {
      midpointHeight = tester.getSize(card).height;
    } else {
      await tester.pump(const Duration(milliseconds: 80));
      midpointHeight = tester.getSize(card).height;
      await tester.pump(const Duration(milliseconds: 120));
    }
    collapsedHeight = tester.getSize(card).height;
    final expandTooltip = find.descendant(
      of: card,
      matching: find.byTooltip(strings.weightExpandSets),
    );
    debugPrint(
      '[expressive-preview-workout-smoke] collapse edge result '
      'expandTooltipCount=${expandTooltip.evaluate().length} '
      'expandedHeightDp=${expandedHeight.toStringAsFixed(1)} '
      'collapsedHeightDp=${collapsedHeight.toStringAsFixed(1)}',
    );
    expect(expandTooltip, findsOneWidget);
    expect(collapsedHeight, lessThan(expandedHeight));
    if (!motionDisabled) {
      expect(midpointHeight, lessThan(expandedHeight));
      expect(midpointHeight, greaterThan(collapsedHeight));
    }

    final expandControl = find.ancestor(
      of: expandTooltip,
      matching: find.byType(IconButton),
    );
    expect(expandTooltip, findsOneWidget);
    expect(expandControl, findsOneWidget);
    final expandRect = tester.getRect(expandControl);
    debugPrint(
      '[expressive-preview-workout-smoke] '
      'expand outerTargetDp='
      '${expandRect.width.toStringAsFixed(1)}x'
      '${expandRect.height.toStringAsFixed(1)}',
    );
    expect(expandRect.width, greaterThanOrEqualTo(48));
    expect(expandRect.height, greaterThanOrEqualTo(48));
    await tester.tapAt(Offset(expandRect.right - 1, expandRect.center.dy));
    await tester.pump();
    if (!motionDisabled) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    final checkboxes = find.descendant(
      of: card,
      matching: find.byType(Checkbox),
    );
    expect(checkboxes, findsNWidgets(3));
    expect(tester.getSize(checkboxes.first), const Size(48, 48));
    checkboxRect = tester.getRect(checkboxes.first);
    await tester.ensureVisible(checkboxes.first);
    await tester.tap(checkboxes.first);
    await tester.pump();
    expect(
      find.descendant(
        of: card,
        matching: find.byTooltip(strings.weightCollapseSets),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.byType(TextFormField)),
      findsNWidgets(6),
    );

    await tester.ensureVisible(checkboxes.at(1));
    await tester.tap(checkboxes.at(1));
    await tester.pump();
    expect(
      find.descendant(
        of: card,
        matching: find.byTooltip(strings.weightCollapseSets),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(checkboxes.at(2));
    await tester.tap(checkboxes.at(2));
    await tester.pump();
    expect(expandTooltip, findsOneWidget);
    if (!motionDisabled) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    autoCollapsedHeight = tester.getSize(card).height;
    expect(autoCollapsedHeight, lessThan(expandedHeight));

    await tester.tap(expandTooltip);
    await tester.pump();
    if (!motionDisabled) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(
      tester.widgetList<Checkbox>(checkboxes).map((checkbox) => checkbox.value),
      everyElement(isTrue),
    );

    // This session contains completed sets. Discard it through the production
    // confirmation so no fixture history or progression data is written.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    final ongoingSessionMenu = find.byKey(AppTestKeys.ongoingSessionMenu);
    await _waitForElement(tester, ongoingSessionMenu);
    final ongoingMenuRect = tester.getRect(ongoingSessionMenu);
    final hitTestableOngoingMenu = ongoingSessionMenu.hitTestable();
    debugPrint(
      '[expressive-preview-workout-smoke] '
      'completed-session-menu rectDp='
      'left:${ongoingMenuRect.left.toStringAsFixed(1)},'
      'top:${ongoingMenuRect.top.toStringAsFixed(1)},'
      'width:${ongoingMenuRect.width.toStringAsFixed(1)},'
      'height:${ongoingMenuRect.height.toStringAsFixed(1)} '
      'hitTestable=${hitTestableOngoingMenu.evaluate().isNotEmpty}',
    );
    expect(ongoingMenuRect.width, greaterThanOrEqualTo(48));
    expect(ongoingMenuRect.height, greaterThanOrEqualTo(48));
    expect(hitTestableOngoingMenu, findsOneWidget);
    await tester.tap(hitTestableOngoingMenu);
    await tester.pumpAndSettle();
    await _waitForElement(tester, find.byKey(AppTestKeys.ongoingSessionExit));
    await tester.tap(find.byKey(AppTestKeys.ongoingSessionExit));
    await tester.pump();
    final discardCompletedWorkout = find.text(strings.sessionCancelDelete);
    await _waitForElement(tester, discardCompletedWorkout);
    await tester.tap(discardCompletedWorkout);
    await tester.pumpAndSettle();
  } finally {
    if (activeSession.isActive) await activeSession.discard();
  }

  expect(await repository.loadActiveWorkoutDraft(), isNull);
  expect((await repository.fetchAllSessions()).length, historyCountBefore);
  return <String, Object>{
    'look': presentation.look.name,
    'motionDisabledByMediaQuery': motionDisabled,
    'expansionRequested': true,
    'expansionDurationMicros': expansionDuration.inMicroseconds,
    'expandedCardHeightDp': expandedHeight,
    'midpointCardHeightDp': midpointHeight,
    'collapsedCardHeightDp': collapsedHeight,
    'autoCollapsedAfterFinalSetHeightDp': autoCollapsedHeight,
    'collapseHitBoundsDp': '${collapseRect.width}x${collapseRect.height}',
    'menuHitBoundsDp': '${menuRect.width}x${menuRect.height}',
    'menuGlyphBoundsDp': '${menuGlyphRect.width}x${menuGlyphRect.height}',
    'checkboxHitBoundsDp': '${checkboxRect.width}x${checkboxRect.height}',
    'textScaleAt1x': textScale,
    'menuAnchorOpened': true,
    'nonFinalSetKeptCardOpen': true,
    'finalSetAutoCollapsedCard': true,
    'reopenPreservedCompletedChecks': true,
    'collapseInnerBoundsDp':
        '${collapseInnerRect.width}x${collapseInnerRect.height}',
    'collapseGlyphBoundsDp':
        '${collapseGlyphRect.width}x${collapseGlyphRect.height}',
    'completedHistoryCountUnchanged': true,
  };
}

Future<List<ui.FrameTiming>> _captureTimings(
  IntegrationTestWidgetsFlutterBinding binding,
  Future<void> Function() action,
) async {
  await Future<void>.delayed(_timingFlushDelay);
  final timings = <ui.FrameTiming>[];
  final TimingsCallback callback = timings.addAll;
  binding.addTimingsCallback(callback);
  try {
    await action();
    await Future<void>.delayed(_timingFlushDelay);
  } finally {
    binding.removeTimingsCallback(callback);
  }
  return timings;
}

Map<String, Object> _durationSummary(
  Iterable<int> durationsMicros,
  int frameBudgetMicros,
) {
  final sorted = durationsMicros.toList()..sort();
  if (sorted.isEmpty) {
    return const <String, Object>{'sampleCount': 0};
  }

  int percentile(int percent) =>
      sorted[((sorted.length - 1) * percent / 100).round()];

  final buckets = <String, int>{
    'under50Percent': 0,
    '50To75Percent': 0,
    '75To100Percent': 0,
    '100To150Percent': 0,
    'over150Percent': 0,
  };
  var overBudget = 0;
  for (final duration in sorted) {
    if (duration > frameBudgetMicros) overBudget++;
    final utilization = duration / frameBudgetMicros;
    final bucket = switch (utilization) {
      < 0.5 => 'under50Percent',
      < 0.75 => '50To75Percent',
      < 1.0 => '75To100Percent',
      <= 1.5 => '100To150Percent',
      _ => 'over150Percent',
    };
    buckets[bucket] = buckets[bucket]! + 1;
  }

  return <String, Object>{
    'sampleCount': sorted.length,
    'p50Micros': percentile(50),
    'p90Micros': percentile(90),
    'p95Micros': percentile(95),
    'p99Micros': percentile(99),
    'maxMicros': sorted.last,
    'overBudgetFrames': overBudget,
    'overBudgetPercent': 100 * overBudget / sorted.length,
    'utilizationBuckets': buckets,
  };
}

int _slowFrameClusterCount(List<ui.FrameTiming> timings, int budgetMicros) {
  var clusters = 0;
  var previousWasSlow = false;
  for (final timing in timings) {
    final isSlow =
        timing.buildDuration.inMicroseconds > budgetMicros ||
        timing.rasterDuration.inMicroseconds > budgetMicros;
    if (isSlow && !previousWasSlow) clusters++;
    previousWasSlow = isSlow;
  }
  return clusters;
}

Future<void> _resetTrainPosition(WidgetTester tester) async {
  await _showTrainOverview(tester);
  final scrollable = find
      .descendant(of: find.byType(TrainPage), matching: find.byType(Scrollable))
      .first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pumpAndSettle();
}

Future<void> _showTrainOverview(WidgetTester tester) async {
  if (find.byType(TrainPage).evaluate().isEmpty) {
    await tester.tap(find.byKey(AppTestKeys.mainTab('train')));
    await tester.pumpAndSettle();
  }
  final overviewTab = find.byKey(AppTestKeys.trainOverviewTab);
  if (overviewTab.evaluate().isNotEmpty) {
    await tester.tap(overviewTab);
    await tester.pumpAndSettle();
  }
}

Future<void> _exerciseMatchedInteractions(
  WidgetTester tester, {
  required int cycles,
}) async {
  final plansTab = find.byKey(AppTestKeys.trainPlansTab);
  final overviewTab = find.byKey(AppTestKeys.trainOverviewTab);
  final catalogTab = find.byKey(AppTestKeys.mainTab('catalog'));
  final trainTab = find.byKey(AppTestKeys.mainTab('train'));
  final trainPage = find.byType(TrainPage);
  final overviewScrollable = find
      .descendant(of: trainPage, matching: find.byType(Scrollable))
      .first;

  expect(find.byType(MainScreen), findsOneWidget);
  expect(plansTab, findsOneWidget);
  expect(overviewTab, findsOneWidget);
  expect(catalogTab, findsOneWidget);
  expect(trainTab, findsOneWidget);

  for (var cycle = 0; cycle < cycles; cycle++) {
    await tester.tap(plansTab);
    await tester.pumpAndSettle();
    await tester.tap(overviewTab);
    await tester.pumpAndSettle();

    await tester.drag(overviewScrollable, const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.drag(overviewScrollable, const Offset(0, 120));
    await tester.pumpAndSettle();

    if (cycle.isEven) {
      final startAction = find.byKey(AppTestKeys.trainStartWorkout);
      expect(startAction, findsOneWidget);
      final gesture = await tester.startGesture(tester.getCenter(startAction));
      await tester.pump();
      await gesture.cancel();
      await tester.pumpAndSettle();
    }

    await tester.tap(catalogTab);
    await tester.pumpAndSettle();
    expect(find.byType(CatalogPage), findsOneWidget);
    await tester.tap(trainTab);
    await tester.pumpAndSettle();
    expect(find.byType(TrainPage), findsOneWidget);
  }
  await _showTrainOverview(tester);
}

Future<void> _exerciseRapidSelectionRetargeting(
  WidgetTester tester, {
  required int cycles,
}) async {
  final plansTab = find.byKey(AppTestKeys.trainPlansTab);
  final overviewTab = find.byKey(AppTestKeys.trainOverviewTab);
  final catalogTab = find.byKey(AppTestKeys.mainTab('catalog'));
  final trainTab = find.byKey(AppTestKeys.mainTab('train'));

  expect(_selectedTrainTabIndex(tester), 0);
  expect(_selectedNavigationIndex(tester), 0);
  for (var cycle = 0; cycle < cycles; cycle++) {
    await tester.tap(plansTab);
    await tester.pump(_rapidSelectionCadence);
    expect(_selectedTrainTabIndex(tester), 1);

    await tester.tap(overviewTab);
    await tester.pump(_rapidSelectionCadence);
    expect(_selectedTrainTabIndex(tester), 0);

    await tester.tap(catalogTab);
    await tester.pump(_rapidSelectionCadence);
    expect(_selectedNavigationIndex(tester), 1);

    await tester.tap(trainTab);
    await tester.pump(_rapidSelectionCadence);
    expect(_selectedNavigationIndex(tester), 0);
  }
  await tester.pumpAndSettle();
  expect(_selectedTrainTabIndex(tester), 0);
  expect(_selectedNavigationIndex(tester), 0);
}

int _selectedTrainTabIndex(WidgetTester tester) =>
    tester.widget<TonosTrainTabs>(find.byType(TonosTrainTabs)).selectedIndex;

int _selectedNavigationIndex(WidgetTester tester) => tester
    .widget<TonosBottomNavigationBar>(find.byType(TonosBottomNavigationBar))
    .currentIndex;
