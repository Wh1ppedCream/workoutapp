import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/tokens/app_progress_colors.dart';
import 'package:env_test/widgets/workout_metric_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
            final theme =
                brightness == Brightness.light
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
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
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
                  )[direction] =
                  trendColor;
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

              final unselectedTrendColor =
                  tester.widget<Text>(trendText).style!.color!;
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
                  )[direction] =
                  unselectedTrendColor;
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
              theme:
                  brightness == Brightness.light
                      ? AppThemeFactory.light(AppThemeFamily.classic)
                      : AppThemeFactory.dark(AppThemeFamily.classic),
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: const [Locale('en')],
              builder:
                  (context, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(scale)),
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
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
        final theme =
            brightness == Brightness.dark
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
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: const [Locale('fr')],
              builder:
                  (context, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(textScale)),
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
      expect(lightInsightTexts, findsAtLeastNWidgets(12));
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
  final lighter =
      foregroundLuminance > backgroundLuminance
          ? foregroundLuminance
          : backgroundLuminance;
  final darker =
      foregroundLuminance > backgroundLuminance
          ? backgroundLuminance
          : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
