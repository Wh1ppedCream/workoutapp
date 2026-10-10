import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_data_visualization_tokens.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/theme/tokens/app_progress_colors.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/widgets/workout_metric_chart_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('workout count axis uses regular integer intervals', () {
    expect(
      workoutReportAxisTickValues(
        metric: WorkoutReportMetric.workouts,
        maximum: 6,
      ),
      <double>[0, 1, 2, 3, 4, 5, 6],
    );
    expect(
      workoutReportAxisTickValues(
        metric: WorkoutReportMetric.workouts,
        maximum: 8,
      ),
      <double>[0, 2, 4, 6, 8],
    );
  });

  test('report date tick labels keep their scaled width without overlap', () {
    for (final scale in [1.0, 2.0]) {
      final labelWidth = 94 * scale;
      final placements = layoutWorkoutReportDateLabelPlacements(
        pointCenters: [
          const Offset(20, 0),
          const Offset(70, 0),
          const Offset(120, 0),
          const Offset(170, 0),
          const Offset(220, 0),
        ],
        labelWidths: List<double>.filled(5, labelWidth),
        labelEvery: 1,
        plotRect: const Rect.fromLTWH(0, 0, 240, 100),
        minimumGap: 6 * scale,
      );

      expect(placements, isNotEmpty);
      expect(placements.last.index, 4);
      expect(placements.last.width, labelWidth);
      for (var index = 1; index < placements.length; index++) {
        expect(
          placements[index].left,
          greaterThanOrEqualTo(
            placements[index - 1].left +
                placements[index - 1].width +
                6 * scale,
          ),
        );
      }
    }
  });

  testWidgets(
    'workout trend text preserves Classic colors and contrasts in Neo',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      addTearDown(units.dispose);
      await units.ready;
      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      final neoTrendColorsBySurface = <String, Map<int, Color>>{};

      for (final counts in [
        (current: 2, previous: 1),
        (current: 1, previous: 2),
        (current: 2, previous: 2),
      ]) {
        final direction = counts.current.compareTo(counts.previous);
        for (final family in [
          AppThemeFamily.classic,
          AppThemeFamily.neoBrutalism,
        ]) {
          for (final brightness in Brightness.values) {
            final theme = brightness == Brightness.light
                ? AppThemeFactory.light(family)
                : AppThemeFactory.dark(family);
            await tester.pumpWidget(
              MultiProvider(
                providers: [
                  Provider<AppRepository>.value(
                    value: _DirectionalTrendRepository(
                      currentCount: counts.current,
                      previousCount: counts.previous,
                    ),
                  ),
                  ChangeNotifierProvider<UnitPreferenceProvider>.value(
                    value: units,
                  ),
                ],
                child: MaterialApp(
                  key: ValueKey(
                    'trend-${family.name}-${brightness.name}-$direction',
                  ),
                  theme: theme,
                  locale: const Locale('en'),
                  localizationsDelegates: tonosLocalizationDelegates,
                  supportedLocales: const [Locale('en')],
                  home: const Scaffold(
                    body: SingleChildScrollView(
                      child: WorkoutMetricChartCard(),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle(
              const Duration(milliseconds: 100),
              EnginePhase.sendSemanticsUpdate,
              const Duration(seconds: 5),
            );

            final workoutsTile = find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics &&
                  widget.properties.label ==
                      strings.workoutReportMetricSemantics(
                        strings.workoutReportWorkouts,
                      ),
            );
            final trendText = find.descendant(
              of: workoutsTile,
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Text &&
                    widget.style?.fontWeight == FontWeight.w800 &&
                    widget.style?.height == 1.05,
              ),
            );
            expect(trendText, findsOneWidget);
            final trendColor = tester.widget<Text>(trendText).style!.color!;
            if (family == AppThemeFamily.classic) {
              final progressColors = theme.extension<AppProgressColors>()!;
              expect(trendColor, switch (direction) {
                1 => progressColors.workoutIncrease,
                -1 => progressColors.workoutDecrease,
                _ => progressColors.neutral,
              });
            } else {
              final statInk = tester.widget<Ink>(
                find.ancestor(of: trendText, matching: find.byType(Ink)).first,
              );
              final statSurface = (statInk.decoration! as BoxDecoration).color!;
              neoTrendColorsBySurface.putIfAbsent(
                '${family.name}-${brightness.name}-selected',
                () => <int, Color>{},
              )[direction] = trendColor;
              expect(
                _contrastRatio(trendColor, statSurface),
                greaterThanOrEqualTo(4.5),
              );

              final timeTile = find.byWidgetPredicate(
                (widget) =>
                    widget is Semantics &&
                    widget.properties.label ==
                        strings.workoutReportMetricSemantics(
                          strings.workoutReportTime,
                        ),
              );
              await tester.tap(timeTile);
              await tester.pumpAndSettle(
                const Duration(milliseconds: 100),
                EnginePhase.sendSemanticsUpdate,
                const Duration(seconds: 5),
              );

              final unselectedTrendColor = tester
                  .widget<Text>(trendText)
                  .style!
                  .color!;
              final unselectedStatInk = tester.widget<Ink>(
                find.ancestor(of: trendText, matching: find.byType(Ink)).first,
              );
              final unselectedStatSurface =
                  (unselectedStatInk.decoration! as BoxDecoration).color!;
              expect(unselectedStatSurface, isNot(statSurface));
              expect(
                _contrastRatio(unselectedTrendColor, unselectedStatSurface),
                greaterThanOrEqualTo(4.5),
              );
              neoTrendColorsBySurface.putIfAbsent(
                '${family.name}-${brightness.name}-unselected',
                () => <int, Color>{},
              )[direction] = unselectedTrendColor;
            }
            expect(tester.takeException(), isNull);
          }
        }
      }
      for (final trendColors in neoTrendColorsBySurface.values) {
        expect(trendColors, hasLength(3));
        expect(trendColors.values.toSet(), hasLength(3));
      }
    },
  );

  testWidgets('Classic report metrics retain equal compact heights', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final units = UnitPreferenceProvider();
    addTearDown(units.dispose);
    await units.ready;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(420, 1400));
    final strings = await AppLocalizations.delegate.load(const Locale('en'));

    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 1.15]) {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: _ReportRepository()),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              key: ValueKey('$brightness-$scale'),
              theme: brightness == Brightness.light
                  ? AppThemeFactory.light(AppThemeFamily.classic)
                  : AppThemeFactory.dark(AppThemeFamily.classic),
              locale: const Locale('en'),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: const [Locale('en')],
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const Scaffold(
                body: SingleChildScrollView(child: WorkoutMetricChartCard()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 5),
        );
        Finder tile(String label) => find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label ==
                  strings.workoutReportMetricSemantics(label),
        );
        final workouts = tile(strings.workoutReportWorkouts);
        final time = tile(strings.workoutReportTime);
        final volume = tile(strings.workoutReportVolume);
        final initialSize = tester.getSize(time);
        expect(tester.getSize(workouts), initialSize);
        expect(tester.getSize(volume), initialSize);
        final valueRow = find.descendant(of: time, matching: find.byType(Row));
        expect(valueRow, findsOneWidget);
        final fittedValue = find.ancestor(
          of: valueRow,
          matching: find.byType(FittedBox),
        );
        expect(fittedValue, findsOneWidget);
        expect(
          tester.getSize(valueRow).width,
          greaterThan(tester.getSize(fittedValue).width),
        );
        await tester.tap(find.text(strings.workoutReportAdditionalDetails));
        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 5),
        );
        final insightGrid = find.byKey(
          const ValueKey('workout-report-insight-grid-two-columns'),
        );
        expect(insightGrid, findsOneWidget);
        expect(
          find.descendant(
            of: insightGrid,
            matching: find.byKey(
              const ValueKey('workout-report-insight-values-inline'),
            ),
          ),
          findsNWidgets(4),
        );
        expect(
          find.descendant(of: insightGrid, matching: find.text('lbs')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: insightGrid,
            matching: find.textContaining(' on '),
          ),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(time);
        await tester.pumpAndSettle();
        expect(tester.getSize(time), initialSize);
        expect(tester.getSize(workouts), initialSize);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('Neo report keeps compact normal-scale controls in one row', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final units = UnitPreferenceProvider();
    addTearDown(units.dispose);
    await units.ready;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 1400));
    final strings = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppRepository>.value(value: _ReportRepository()),
          ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
        ],
        child: MaterialApp(
          theme: AppThemeFactory.light(AppThemeFamily.neoBrutalism),
          locale: const Locale('en'),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: const [Locale('en')],
          home: const Scaffold(
            body: SingleChildScrollView(child: WorkoutMetricChartCard()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );

    Finder tile(String label) => find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label ==
              strings.workoutReportMetricSemantics(label),
    );
    final metricTiles = [
      tile(strings.workoutReportWorkouts),
      tile(strings.workoutReportTime),
      tile(strings.workoutReportVolume),
    ];
    final metricTop = tester.getTopLeft(metricTiles.first).dy;
    for (final metricTile in metricTiles) {
      expect(tester.getTopLeft(metricTile).dy, closeTo(metricTop, 0.1));
    }

    final rangeLabels = [
      strings.workoutReportRangeOneWeekShort,
      strings.workoutReportRangeOneMonthShort,
      strings.workoutReportRangeThreeMonthsShort,
      strings.workoutReportRangeSixMonthsShort,
      strings.workoutReportRangeOneYearShort,
      strings.workoutReportRangeAll,
    ];
    final rangeTop = tester.getTopLeft(find.text(rangeLabels.first)).dy;
    for (final label in rangeLabels) {
      expect(tester.getTopLeft(find.text(label)).dy, closeTo(rangeTop, 0.1));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('identity-less outlined themes keep generic report scaling', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final units = UnitPreferenceProvider();
    addTearDown(units.dispose);
    await units.ready;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(700, 1400));
    final strings = await AppLocalizations.delegate.load(const Locale('en'));
    final neoTheme = AppThemeFactory.light(AppThemeFamily.neoBrutalism);
    final genericTheme = neoTheme.copyWith(
      extensions: neoTheme.extensions.values
          .where((extension) => extension is! AppThemeIdentity)
          .toList(),
    );
    expect(genericTheme.appThemeFamilyIdentity, isNull);
    expect(genericTheme.surfaceDecorationTokens.panel.outlined, isTrue);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppRepository>.value(value: _ReportRepository()),
          ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
        ],
        child: MaterialApp(
          theme: genericTheme,
          locale: const Locale('en'),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: const [Locale('en')],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(child: WorkoutMetricChartCard()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );

    Finder tile(String label) => find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label ==
              strings.workoutReportMetricSemantics(label),
    );
    final metricTiles = [
      tile(strings.workoutReportWorkouts),
      tile(strings.workoutReportTime),
      tile(strings.workoutReportVolume),
    ];
    var commonRows = find
        .ancestor(of: metricTiles.first, matching: find.byType(Row))
        .evaluate()
        .toSet();
    for (final metricTile in metricTiles.skip(1)) {
      commonRows = commonRows.intersection(
        find
            .ancestor(of: metricTile, matching: find.byType(Row))
            .evaluate()
            .toSet(),
      );
    }
    expect(commonRows, isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Workout Report expands complete insight content at responsive scales',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      addTearDown(units.dispose);
      await units.ready;
      expect(units.loaded, isTrue);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Future<void> settleReport() async {
        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 5),
        );
      }

      Future<void> pumpAt({
        required double width,
        required double textScale,
        required AppThemeFamily family,
        required Brightness brightness,
      }) async {
        await tester.binding.setSurfaceSize(Size(width, 1400));
        final theme = brightness == Brightness.dark
            ? AppThemeFactory.dark(family)
            : AppThemeFactory.light(family);
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: _ReportRepository()),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              // Each case must start with a collapsed report and fresh scroll
              // position, including when only the theme or text size changes.
              key: ValueKey(
                '${family.name}-${brightness.name}-$width-$textScale',
              ),
              theme: theme,
              locale: const Locale('fr'),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: const [Locale('fr')],
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(textScale)),
                child: child!,
              ),
              home: const Scaffold(
                body: SingleChildScrollView(child: WorkoutMetricChartCard()),
              ),
            ),
          ),
        );
        await settleReport();
        expect(tester.takeException(), isNull);
      }

      await pumpAt(
        width: 420,
        textScale: 1,
        family: AppThemeFamily.neoBrutalism,
        brightness: Brightness.light,
      );
      final strings = await AppLocalizations.delegate.load(const Locale('fr'));
      Future<void> expandDetails({required bool twoColumns}) async {
        final toggle = find.text(strings.workoutReportAdditionalDetails);
        await tester.ensureVisible(toggle);
        await settleReport();
        await tester.tap(toggle);
        await settleReport();
        final grid = find.byKey(
          ValueKey(
            twoColumns
                ? 'workout-report-insight-grid-two-columns'
                : 'workout-report-insight-grid-one-column',
          ),
        );
        expect(grid, findsOneWidget);
        final crossFade = tester.widget<AnimatedCrossFade>(
          find.ancestor(of: grid, matching: find.byType(AnimatedCrossFade)),
        );
        expect(crossFade.crossFadeState, CrossFadeState.showSecond);
      }

      await expandDetails(twoColumns: true);
      final lightGrid = find.byKey(
        const ValueKey('workout-report-insight-grid-two-columns'),
      );
      expect(lightGrid, findsOneWidget);
      expect(
        find.byKey(const ValueKey('workout-report-insight-values-inline')),
        findsNWidgets(4),
      );
      final lightInsightTexts = find.descendant(
        of: lightGrid,
        matching: find.byType(Text),
      );
      expect(lightInsightTexts, findsNWidgets(11));
      expect(
        find.descendant(of: lightGrid, matching: find.text('jeudi')),
        findsOneWidget,
        reason: 'The full weekday value remains visible in Most Active.',
      );
      for (final text in tester.widgetList<Text>(lightInsightTexts)) {
        expect(text.maxLines, isNull);
        expect(text.overflow, isNull);
      }
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -900),
      );
      await settleReport();
      expect(tester.takeException(), isNull);

      await pumpAt(
        width: 320,
        textScale: 2,
        family: AppThemeFamily.neoBrutalism,
        brightness: Brightness.dark,
      );
      await expandDetails(twoColumns: false);
      expect(
        find.byKey(const ValueKey('workout-report-insight-grid-one-column')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('workout-report-insight-values-stacked')),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);

      await pumpAt(
        width: 420,
        textScale: 2,
        family: AppThemeFamily.neoBrutalism,
        brightness: Brightness.light,
      );
      await expandDetails(twoColumns: false);
      expect(
        find.byKey(const ValueKey('workout-report-insight-grid-one-column')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('workout-report-insight-values-stacked')),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);

      await pumpAt(
        width: 320,
        textScale: 2,
        family: AppThemeFamily.classic,
        brightness: Brightness.light,
      );
      await expandDetails(twoColumns: false);
      expect(tester.takeException(), isNull);

      await pumpAt(
        width: 320,
        textScale: 2,
        family: AppThemeFamily.classic,
        brightness: Brightness.dark,
      );
      await expandDetails(twoColumns: false);
      expect(
        find.byKey(const ValueKey('workout-report-insight-grid-one-column')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 1)),
  );

  testWidgets(
    'Expressive Workout Report keeps its tonal composition responsive',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      addTearDown(units.dispose);
      await units.ready;
      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const configurations = [
        (
          width: 320.0,
          scale: 1.0,
          brightness: Brightness.light,
          reduced: false,
        ),
        (width: 320.0, scale: 1.15, brightness: Brightness.dark, reduced: true),
        (width: 320.0, scale: 1.5, brightness: Brightness.light, reduced: true),
        (width: 320.0, scale: 2.0, brightness: Brightness.dark, reduced: false),
        (width: 420.0, scale: 1.0, brightness: Brightness.light, reduced: true),
      ];

      for (
        var configurationIndex = 0;
        configurationIndex < configurations.length;
        configurationIndex++
      ) {
        final configuration = configurations[configurationIndex];
        final theme = configuration.brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final expressiveTokens = theme.extension<AppExpressiveTrainTokens>()!;
        final surfaces = theme.surfaceTokens;
        final shapes = theme.shapeTokens;
        expect(theme.usesExpressivePresentation, isTrue);
        final expectedDataTokens = AppDataVisualizationTokens.fromBrightness(
          configuration.brightness,
        );
        expect(
          theme.dataVisualizationTokens.primarySeries,
          expectedDataTokens.primarySeries,
        );
        expect(
          theme.dataVisualizationTokens.secondarySeries,
          expectedDataTokens.secondarySeries,
        );
        expect(
          theme.dataVisualizationTokens.selection,
          expectedDataTokens.selection,
        );

        await tester.binding.setSurfaceSize(Size(configuration.width, 1400));
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: _ReportRepository()),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              key: ValueKey('expressive-report-$configurationIndex'),
              theme: theme,
              locale: const Locale('en'),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: const [Locale('en')],
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(configuration.scale),
                  disableAnimations: configuration.reduced,
                ),
                child: child!,
              ),
              home: const Scaffold(
                body: SingleChildScrollView(child: WorkoutMetricChartCard()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final reportCard = tester.widget<Card>(
          find
              .descendant(
                of: find.byType(WorkoutMetricChartCard),
                matching: find.byType(Card),
              )
              .first,
        );
        expect(reportCard.color, surfaces.card);
        expect(
          (reportCard.shape! as RoundedRectangleBorder).borderRadius,
          shapes.card,
        );

        final reportTitle = tester.widget<Text>(
          find.byKey(const ValueKey('workout-report-expressive-title')),
        );
        expect(reportTitle.textAlign, TextAlign.start);
        expect(reportTitle.style!.color, expressiveTokens.actionPrimary);
        expect(
          find.byKey(const ValueKey('workout-report-expressive-title-rule')),
          findsOneWidget,
        );

        final cluster = tester.widget<Container>(
          find.byKey(
            const ValueKey('workout-report-expressive-metric-cluster'),
          ),
        );
        final clusterDecoration = cluster.decoration! as BoxDecoration;
        expect(clusterDecoration.color, expressiveTokens.selectorTrack);
        expect(clusterDecoration.border, isNull);

        final metricLabels = [
          strings.workoutReportWorkouts,
          strings.workoutReportTime,
          strings.workoutReportVolume,
        ];
        final metricSemantics = [
          for (final label in metricLabels)
            find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics &&
                  widget.properties.button == true &&
                  widget.properties.label ==
                      strings.workoutReportMetricSemantics(label),
            ),
        ];
        for (final metric in metricSemantics) {
          expect(metric, findsOneWidget);
        }
        final selectedMetric = metricSemantics.first;
        expect(
          tester.widget<Semantics>(selectedMetric).properties.selected,
          isTrue,
        );
        for (final peerMetric in metricSemantics.skip(1)) {
          final peerSemantics = tester.widget<Semantics>(peerMetric);
          expect(peerSemantics.properties.selected, isFalse);
          expect(peerSemantics.properties.onTap, isNotNull);
        }
        final metricInk = tester.widget<Ink>(
          find.descendant(of: selectedMetric, matching: find.byType(Ink)).first,
        );
        final metricDecoration = metricInk.decoration! as BoxDecoration;
        expect(
          metricDecoration.color,
          Color.lerp(expressiveTokens.focusSurface, Colors.black, 0.36),
        );
        expect(metricDecoration.border, isA<BorderDirectional>());
        expect((metricDecoration.border! as BorderDirectional).start.width, 4);
        final selectedMetricLabel = find.descendant(
          of: selectedMetric,
          matching: find.text(strings.workoutReportWorkouts),
        );
        expect(
          tester.widget<Text>(selectedMetricLabel).style!.color,
          expressiveTokens.focusForeground,
        );
        final trendText = find.descendant(
          of: selectedMetric,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                widget.style?.fontWeight == FontWeight.w800 &&
                widget.style?.height == 1.05,
          ),
        );
        expect(trendText, findsOneWidget);
        expect(
          _contrastRatio(
            tester.widget<Text>(trendText).style!.color!,
            metricDecoration.color!,
          ),
          greaterThanOrEqualTo(4.5),
        );

        final rangeLabels = [
          strings.workoutReportRangeOneWeekShort,
          strings.workoutReportRangeOneMonthShort,
          strings.workoutReportRangeThreeMonthsShort,
          strings.workoutReportRangeSixMonthsShort,
          strings.workoutReportRangeOneYearShort,
          strings.workoutReportRangeAll,
        ];
        final rangeOptions = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              rangeLabels.contains(widget.properties.label),
        );
        expect(rangeOptions, findsNWidgets(6));
        final selectedRange = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.selected == true &&
              widget.properties.label == strings.workoutReportRangeAll,
        );
        expect(selectedRange, findsOneWidget);
        if (configuration.scale <= 1.15) {
          final rangeOption = tester.widget<AnimatedContainer>(
            find
                .descendant(
                  of: selectedRange,
                  matching: find.byType(AnimatedContainer),
                )
                .first,
          );
          expect(
            (rangeOption.decoration! as BoxDecoration).color,
            expressiveTokens.selectorActive,
          );
          expect(rangeOption.duration == Duration.zero, configuration.reduced);
        }

        expect(
          tester
              .getSize(
                find.byKey(
                  const ValueKey('workout-report-expressive-chart-viewport'),
                ),
              )
              .height,
          220,
        );
        final chartSurface = tester.widget<Container>(
          find
              .ancestor(
                of: find.byKey(const ValueKey('workout-report-chart-canvas')),
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Container &&
                      widget.decoration is BoxDecoration &&
                      (widget.decoration! as BoxDecoration).color ==
                          surfaces.workoutMetricChart,
                ),
              )
              .first,
        );
        expect(
          (chartSurface.decoration! as BoxDecoration).color,
          surfaces.workoutMetricChart,
        );
        expect(tester.takeException(), isNull);

        if (configurationIndex == 0) {
          await tester.tap(
            find.descendant(
              of: metricSemantics[2],
              matching: find.text(strings.workoutReportVolume),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.widget<Semantics>(metricSemantics[2]).properties.selected,
            isTrue,
          );
          await tester.tap(find.text(strings.workoutReportRangeOneMonthShort));
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<Semantics>(
                  find.byWidgetPredicate(
                    (widget) =>
                        widget is Semantics &&
                        widget.properties.button == true &&
                        widget.properties.label ==
                            strings.workoutReportRangeOneMonthShort,
                  ),
                )
                .properties
                .selected,
            isTrue,
          );
          await tester.tap(find.text(strings.workoutReportAdditionalDetails));
          await tester.pumpAndSettle();
          expect(
            find.byKey(
              const ValueKey('workout-report-insight-grid-one-column'),
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'Progress report uses its lavender and warm module roles only in Progress',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      addTearDown(units.dispose);
      await units.ready;
      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(360, 1200));

      for (final (family, brightness) in [
        (AppExpressiveDestinationFamily.progress, Brightness.light),
        (AppExpressiveDestinationFamily.progress, Brightness.dark),
        (AppExpressiveDestinationFamily.dashboard, Brightness.light),
      ]) {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final destination = AppExpressiveDestinationTokens.forFamily(
          family,
          brightness,
        );
        final expressiveTokens = theme.extension<AppExpressiveTrainTokens>()!;
        final metricRestingSurface = theme.surfaceTokens.workoutMetricStat;
        final chartSurfaceColor = theme.surfaceTokens.workoutMetricChart;
        final isProgress = family == AppExpressiveDestinationFamily.progress;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: _ReportRepository()),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              key: ValueKey('expressive-report-family-${family.name}'),
              theme: theme,
              locale: const Locale('en'),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: const [Locale('en')],
              home: AppExpressiveDestinationTheme(
                family: family,
                child: const Scaffold(
                  body: SingleChildScrollView(child: WorkoutMetricChartCard()),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final reportCard = tester.widget<Card>(
          find
              .descendant(
                of: find.byType(WorkoutMetricChartCard),
                matching: find.byType(Card),
              )
              .first,
        );
        expect(
          reportCard.color,
          isProgress ? destination.surfacePrimary : theme.surfaceTokens.card,
        );
        final reportTitle = tester.widget<Text>(
          find.byKey(const ValueKey('workout-report-expressive-title')),
        );
        expect(
          reportTitle.style!.color,
          isProgress
              ? destination.onSurfacePrimary
              : theme.extension<AppExpressiveTrainTokens>()!.actionPrimary,
        );

        final cluster = tester.widget<Container>(
          find.byKey(
            const ValueKey('workout-report-expressive-metric-cluster'),
          ),
        );
        expect(
          (cluster.decoration! as BoxDecoration).color,
          isProgress ? Colors.transparent : expressiveTokens.selectorTrack,
        );
        expect(
          cluster.padding,
          isProgress ? EdgeInsets.zero : const EdgeInsets.all(5),
        );
        final chartSurface = find.byKey(
          const ValueKey('workout-report-expressive-chart-surface'),
        );
        expect(chartSurface, isProgress ? findsOneWidget : findsNothing);
        if (isProgress) {
          final titleRule = find.byKey(
            const ValueKey('workout-report-expressive-title-rule'),
          );
          final titleRuleMarker = find.descendant(
            of: titleRule,
            matching: find.byType(Container),
          );
          expect(titleRuleMarker, findsOneWidget);
          expect(
            tester.getRect(titleRuleMarker).left,
            closeTo(
              tester
                  .getRect(
                    find.byKey(
                      const ValueKey('workout-report-expressive-title'),
                    ),
                  )
                  .left,
              0.5,
            ),
          );
          expect(
            tester.getRect(titleRuleMarker).top -
                tester
                    .getRect(
                      find.byKey(
                        const ValueKey('workout-report-expressive-title'),
                      ),
                    )
                    .bottom,
            closeTo(4, 1),
          );
          expect(
            (tester.widget<Container>(chartSurface).decoration!
                    as BoxDecoration)
                .color,
            Color.lerp(chartSurfaceColor, destination.surfacePrimary, 0.06)!,
          );
        }
        final rangeRail = find.byKey(
          const ValueKey('workout-report-expressive-range-rail'),
        );
        expect(rangeRail, isProgress ? findsOneWidget : findsNothing);
        if (isProgress) {
          final rangeRailDecoration =
              tester.widget<Container>(rangeRail).decoration! as BoxDecoration;
          expect(
            rangeRailDecoration.color,
            Color.lerp(
              destination.surfacePrimary,
              destination.surfaceSelected,
              0.12,
            )!,
          );
          if (brightness == Brightness.dark) {
            expect(rangeRailDecoration.border, isA<Border>());
            final railBorder = rangeRailDecoration.border! as Border;
            expect(railBorder.top.width, 1);
            expect(
              railBorder.top.color,
              destination.outlineAccent.withValues(alpha: 0.2),
            );
          } else {
            expect(rangeRailDecoration.border, isNull);
          }
          final selectedRange = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                widget.properties.selected == true &&
                widget.properties.label == strings.workoutReportRangeAll,
          );
          expect(selectedRange, findsOneWidget);
          final selectedRangeOption = tester.widget<AnimatedContainer>(
            find
                .descendant(
                  of: selectedRange,
                  matching: find.byType(AnimatedContainer),
                )
                .first,
          );
          expect(
            (selectedRangeOption.decoration! as BoxDecoration).color,
            destination.surfaceSelected,
          );
          final selectedRangeLabel = find.descendant(
            of: selectedRange,
            matching: find.text(strings.workoutReportRangeAll),
          );
          expect(
            tester.widget<Text>(selectedRangeLabel).style!.color,
            destination.onSurfaceSelected,
          );
          final unselectedRange = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                widget.properties.selected != true &&
                widget.properties.label ==
                    strings.workoutReportRangeOneWeekShort,
          );
          expect(unselectedRange, findsOneWidget);
          final unselectedRangeLabel = find.descendant(
            of: unselectedRange,
            matching: find.text(strings.workoutReportRangeOneWeekShort),
          );
          expect(
            tester.widget<Text>(unselectedRangeLabel).style!.color,
            destination.onSurfacePrimary,
          );
          final selectedMetric = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                widget.properties.selected == true &&
                widget.properties.label ==
                    strings.workoutReportMetricSemantics(
                      strings.workoutReportWorkouts,
                    ),
          );
          final selectedInk = tester.widget<Ink>(
            find
                .descendant(of: selectedMetric, matching: find.byType(Ink))
                .first,
          );
          expect(
            (selectedInk.decoration! as BoxDecoration).color,
            destination.surfaceSelected,
          );
          final selectedLabel = find.descendant(
            of: selectedMetric,
            matching: find.text(strings.workoutReportWorkouts),
          );
          expect(
            tester.widget<Text>(selectedLabel).style!.color,
            destination.onSurfaceSelected,
          );
          final unselectedMetric = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                widget.properties.selected != true &&
                widget.properties.label ==
                    strings.workoutReportMetricSemantics(
                      strings.workoutReportTime,
                    ),
          );
          final unselectedInk = tester.widget<Ink>(
            find
                .descendant(of: unselectedMetric, matching: find.byType(Ink))
                .first,
          );
          expect(
            (unselectedInk.decoration! as BoxDecoration).color,
            Color.lerp(
              metricRestingSurface,
              destination.surfaceSelected,
              0.12,
            )!,
          );
        } else {
          final selectedMetric = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                widget.properties.selected == true &&
                widget.properties.label ==
                    strings.workoutReportMetricSemantics(
                      strings.workoutReportWorkouts,
                    ),
          );
          final selectedInk = tester.widget<Ink>(
            find
                .descendant(of: selectedMetric, matching: find.byType(Ink))
                .first,
          );
          expect(
            (selectedInk.decoration! as BoxDecoration).color,
            Color.lerp(expressiveTokens.focusSurface, Colors.black, 0.36),
          );
          final selectedLabel = find.descendant(
            of: selectedMetric,
            matching: find.text(strings.workoutReportWorkouts),
          );
          expect(
            tester.widget<Text>(selectedLabel).style!.color,
            expressiveTokens.focusForeground,
          );
          final selectedDecoration = selectedInk.decoration! as BoxDecoration;
          expect(
            (selectedDecoration.border! as BorderDirectional).start.color,
            expressiveTokens.selectorActive,
          );
          final unselectedMetric = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                widget.properties.selected != true &&
                widget.properties.label ==
                    strings.workoutReportMetricSemantics(
                      strings.workoutReportTime,
                    ),
          );
          final unselectedInk = tester.widget<Ink>(
            find
                .descendant(of: unselectedMetric, matching: find.byType(Ink))
                .first,
          );
          expect(
            (unselectedInk.decoration! as BoxDecoration).color,
            Colors.transparent,
          );
          final unselectedLabel = find.descendant(
            of: unselectedMetric,
            matching: find.text(strings.workoutReportTime),
          );
          expect(
            tester.widget<Text>(unselectedLabel).style!.color,
            expressiveTokens.focusSurface,
          );
        }

        await tester.tap(find.text('Additional Details'));
        await tester.pumpAndSettle();
        final detailsModule = find.byKey(
          const ValueKey('workout-report-expressive-details-module'),
        );
        expect(detailsModule, isProgress ? findsOneWidget : findsNothing);
        if (isProgress) {
          expect(
            tester.widget<Material>(detailsModule).color,
            destination.surfaceAccent,
          );
          final detailsDisclosureIcon = find.descendant(
            of: detailsModule,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Icon &&
                  (widget.icon == Icons.keyboard_arrow_up ||
                      widget.icon == Icons.keyboard_arrow_down),
            ),
          );
          expect(detailsDisclosureIcon, findsOneWidget);
          expect(
            tester.widget<Icon>(detailsDisclosureIcon).color,
            destination.onSurfaceAccent,
          );
          final insightNodes = find.descendant(
            of: detailsModule,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics &&
                  widget.properties.label?.contains(',') == true,
            ),
          );
          expect(insightNodes, findsNWidgets(4));
          for (final insightNode in insightNodes.evaluate()) {
            final tile = insightNode.widget as Semantics;
            final tileFinder = find.byWidget(tile);
            final tileContainers = find.descendant(
              of: tileFinder,
              matching: find.byType(Container),
            );
            final insightContainer = tester.widget<Container>(
              tileContainers.first,
            );
            expect(
              (insightContainer.decoration! as BoxDecoration).color,
              Color.lerp(
                destination.surfaceAccent,
                destination.surfaceSelected,
                brightness == Brightness.dark ? 0.4 : 0.16,
              )!,
            );
            final textWidgets = find
                .descendant(of: tileFinder, matching: find.byType(Text))
                .evaluate()
                .map((element) => element.widget as Text)
                .toList();
            expect(textWidgets, isNotEmpty);
            expect(
              (textWidgets.first.textSpan! as TextSpan)
                  .children!
                  .first
                  .style!
                  .fontSize!,
              greaterThan(textWidgets[1].style!.fontSize!),
            );
          }
          final insightGrid = find.descendant(
            of: detailsModule,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Wrap &&
                  (widget.key ==
                          const ValueKey(
                            'workout-report-insight-grid-one-column',
                          ) ||
                      widget.key ==
                          const ValueKey(
                            'workout-report-insight-grid-two-columns',
                          )),
            ),
          );
          expect(insightGrid, findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'Expressive focal metric preserves positive and negative delta colors',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      addTearDown(units.dispose);
      await units.ready;
      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(360, 1200));

      for (final counts in [
        (current: 2, previous: 1),
        (current: 1, previous: 2),
        (current: 2, previous: 2),
      ]) {
        for (final brightness in Brightness.values) {
          final theme = brightness == Brightness.light
              ? ExpressiveThemeDefinition.light()
              : ExpressiveThemeDefinition.dark();
          final progressColors = theme.extension<AppProgressColors>()!;
          final expressiveTokens = theme.extension<AppExpressiveTrainTokens>()!;
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(
                  value: _DirectionalTrendRepository(
                    currentCount: counts.current,
                    previousCount: counts.previous,
                  ),
                ),
                ChangeNotifierProvider<UnitPreferenceProvider>.value(
                  value: units,
                ),
              ],
              child: MaterialApp(
                key: ValueKey(
                  'expressive-trend-${brightness.name}-${counts.current}-${counts.previous}',
                ),
                theme: theme,
                locale: const Locale('en'),
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: const [Locale('en')],
                home: const Scaffold(
                  body: SingleChildScrollView(child: WorkoutMetricChartCard()),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final workoutsTile = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label ==
                    strings.workoutReportMetricSemantics(
                      strings.workoutReportWorkouts,
                    ),
          );
          final trendText = find.descendant(
            of: workoutsTile,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Text &&
                  widget.style?.fontWeight == FontWeight.w800 &&
                  widget.style?.height == 1.05,
            ),
          );
          expect(trendText, findsOneWidget);
          final color = tester.widget<Text>(trendText).style!.color!;
          final direction = counts.current.compareTo(counts.previous);
          if (direction > 0) {
            expect(color, progressColors.workoutIncrease);
          } else if (direction < 0) {
            expect(color, progressColors.workoutDecrease);
          } else {
            expect(color, expressiveTokens.focusForeground);
          }
          final statInk = tester.widget<Ink>(
            find.ancestor(of: trendText, matching: find.byType(Ink)).first,
          );
          final statSurface = (statInk.decoration! as BoxDecoration).color!;
          expect(_contrastRatio(color, statSurface), greaterThanOrEqualTo(4.5));
          expect(tester.takeException(), isNull);
        }
      }
    },
  );
}

class _ReportRepository extends AppRepository {
  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async => [
    WorkoutReportSession(
      id: 1,
      date: DateTime(2026, 1, 15),
      durationSeconds: 3600,
      totalVolume: 200,
      exerciseCount: 4,
      setCount: 12,
    ),
    WorkoutReportSession(
      id: 2,
      date: DateTime(2026, 1, 16),
      durationSeconds: 2640,
      totalVolume: 1234567890,
      exerciseCount: 5,
      setCount: 15,
    ),
  ];
}

class _DirectionalTrendRepository extends AppRepository {
  final int currentCount;
  final int previousCount;

  _DirectionalTrendRepository({
    required this.currentCount,
    required this.previousCount,
  });

  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final previousWeek = today.subtract(const Duration(days: 7));
    final sessions = <WorkoutReportSession>[];

    void addSessions(DateTime date, int count) {
      for (var index = 0; index < count; index++) {
        sessions.add(
          WorkoutReportSession(
            id: sessions.length + 1,
            date: date,
            durationSeconds: 1800,
            totalVolume: 100,
            exerciseCount: 1,
            setCount: 3,
          ),
        );
      }
    }

    addSessions(previousWeek, previousCount);
    addSessions(today, currentCount);
    return sessions;
  }
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
