import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/tokens/app_motion_tokens.dart';
import 'package:env_test/widgets/workout_metric_chart_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('workout chart exposes latest, selected points, and actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(360, 1200));
      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      final units = UnitPreferenceProvider();
      addTearDown(units.dispose);
      await units.ready;

      await tester.pumpWidget(
        _host(units: units, repository: _ReportRepository()),
      );
      await tester.pumpAndSettle();

      final chart = find.byKey(
        const ValueKey('workout-report-chart-semantics'),
      );
      var data = tester.getSemantics(chart).getSemanticsData();
      expect(
        data.label,
        '${strings.workoutReportTitle}, ${strings.workoutReportChartTitle(strings.workoutReportWorkouts, strings.workoutReportRangeAll)}',
      );
      expect(
        data.label,
        contains(
          strings.workoutReportChartTitle(
            strings.workoutReportWorkouts,
            strings.workoutReportRangeAll,
          ),
        ),
      );
      expect(data.value, contains('${strings.healthLatest}:'));
      expect(data.value, contains(strings.workoutReportWorkoutCount(1)));
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(data.increasedValue, isEmpty);
      expect(data.hasAction(SemanticsAction.increase), isFalse);
      expect(data.decreasedValue, isNotNull);
      expect(data.hasAction(SemanticsAction.decrease), isTrue);

      final chartFocus = find.descendant(
        of: chart,
        matching: find.byType(Focus),
      );
      tester.widget<Focus>(chartFocus).focusNode!.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      data = tester.getSemantics(chart).getSemanticsData();
      expect(tester.widget<Semantics>(chart).properties.selected, isFalse);
      expect(data.value, contains('${strings.healthLatest}:'));

      final chartLabel =
          '${strings.workoutReportTitle}, ${strings.workoutReportChartTitle(strings.workoutReportWorkouts, strings.workoutReportRangeAll)}';
      tester.semantics.tap(find.semantics.byLabel(chartLabel));
      await tester.pump();
      data = tester.getSemantics(chart).getSemanticsData();
      expect(tester.widget<Semantics>(chart).properties.selected, isTrue);
      expect(data.value, isNot(contains('${strings.healthLatest}:')));
      final latestValue = data.value;

      final previousValue = data.decreasedValue;
      tester.semantics.decrease(find.semantics.byLabel(chartLabel));
      await tester.pump();
      data = tester.getSemantics(chart).getSemanticsData();
      expect(data.value, previousValue);

      tester.semantics.tap(find.semantics.byLabel(chartLabel));
      await tester.pump();
      data = tester.getSemantics(chart).getSemanticsData();
      expect(data.value, latestValue);
      tester.semantics.decrease(find.semantics.byLabel(chartLabel));
      await tester.pump();
      data = tester.getSemantics(chart).getSemanticsData();
      expect(data.value, isNot(latestValue));

      final chartCanvas = find.byKey(
        const ValueKey('workout-report-chart-canvas'),
      );
      final chartRect = tester.getRect(chartCanvas);
      await tester.tapAt(
        Offset(chartRect.left + chartRect.width * 0.25, chartRect.center.dy),
      );
      await tester.pump();
      final beforeArrow = tester.getSemantics(chart).getSemanticsData().value;
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      final afterArrow = tester.getSemantics(chart).getSemanticsData().value;
      expect(afterArrow, isNot(beforeArrow));
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('single-bucket chart arrows do not create a selection', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(360, 1200));
      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      final units = UnitPreferenceProvider();
      addTearDown(units.dispose);
      await units.ready;

      await tester.pumpWidget(
        _host(units: units, repository: _SingleBucketReportRepository()),
      );
      await tester.pumpAndSettle();

      final chart = find.byKey(
        const ValueKey('workout-report-chart-semantics'),
      );
      final chartFocus = find.descendant(
        of: chart,
        matching: find.byType(Focus),
      );
      tester.widget<Focus>(chartFocus).focusNode!.requestFocus();
      await tester.pump();

      final initialValue = tester.getSemantics(chart).getSemanticsData().value;
      expect(initialValue, contains('${strings.healthLatest}:'));
      for (final key in [
        LogicalKeyboardKey.arrowRight,
        LogicalKeyboardKey.arrowLeft,
      ]) {
        await tester.sendKeyEvent(key);
        await tester.pump();
      }

      expect(tester.widget<Semantics>(chart).properties.selected, isFalse);
      expect(tester.getSemantics(chart).getSemanticsData().value, initialValue);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('empty workout chart announces its metric and empty state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final units = UnitPreferenceProvider();
      addTearDown(units.dispose);
      await units.ready;
      final strings = await AppLocalizations.delegate.load(const Locale('en'));

      await tester.pumpWidget(
        _host(units: units, repository: _EmptyReportRepository()),
      );
      await tester.pumpAndSettle();

      final chart = find.byKey(
        const ValueKey('workout-report-chart-semantics'),
      );
      final data = tester.getSemantics(chart).getSemanticsData();
      expect(
        data.label,
        contains(
          strings.workoutReportChartTitle(
            strings.workoutReportWorkouts,
            strings.workoutReportRangeAll,
          ),
        ),
      );
      expect(data.value, contains(strings.workoutReportNoWorkoutsYet));
      expect(data.value, contains(strings.workoutReportNoWorkoutsBody));
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      expect(data.hasAction(SemanticsAction.increase), isFalse);
      expect(data.hasAction(SemanticsAction.decrease), isFalse);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('chart labels fit narrow width at accessibility scales and RTL', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 1200));
    final units = UnitPreferenceProvider();
    addTearDown(units.dispose);
    await units.ready;

    for (final scale in [1.0, 1.15, 1.5, 2.0]) {
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(
          _host(
            units: units,
            repository: _ReportRepository(),
            textScale: scale,
            textDirection: direction,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('workout-report-chart-canvas')),
          findsOneWidget,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'scale=$scale $direction',
        );
      }
    }
  });

  testWidgets('workout report range selection follows reduced motion policy', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final units = UnitPreferenceProvider();
    addTearDown(units.dispose);
    await units.ready;

    for (final reduceMotion in [false, true]) {
      await tester.pumpWidget(
        _host(
          units: units,
          repository: _ReportRepository(),
          reduceMotion: reduceMotion,
        ),
      );
      await tester.pumpAndSettle();
      final options = tester.widgetList<AnimatedContainer>(
        find.descendant(
          of: find.byType(WorkoutMetricChartCard),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(options, isNotEmpty);
      final expected = reduceMotion
          ? AppThemeFactory.light(AppThemeFamily.classic)
                .extension<AppMotionTokens>()!
                .reduced
          : AppThemeFactory.light(AppThemeFamily.classic)
                .extension<AppMotionTokens>()!
                .quick;
      expect(options.first.duration, expected);
    }
  });
}

Widget _host({
  required UnitPreferenceProvider units,
  required AppRepository repository,
  double textScale = 1,
  TextDirection textDirection = TextDirection.ltr,
  bool reduceMotion = false,
}) {
  return MultiProvider(
    providers: [
      Provider<AppRepository>.value(value: repository),
      ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
    ],
    child: MaterialApp(
      key: ValueKey('workout-chart-$textScale-$textDirection-$reduceMotion'),
      theme: AppThemeFactory.light(AppThemeFamily.classic),
      locale: const Locale('en'),
      localizationsDelegates: tonosLocalizationDelegates,
      supportedLocales: const [Locale('en')],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reduceMotion,
        ),
        child: Directionality(textDirection: textDirection, child: child!),
      ),
      home: Directionality(
        textDirection: textDirection,
        child: const Scaffold(
          body: SingleChildScrollView(child: WorkoutMetricChartCard()),
        ),
      ),
    ),
  );
}

class _ReportRepository extends AppRepository {
  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async {
    final today = DateUtils.dateOnly(DateTime.now());
    return [
      WorkoutReportSession(
        id: 1,
        date: today.subtract(const Duration(days: 8)),
        durationSeconds: 3600,
        totalVolume: 200,
        exerciseCount: 4,
        setCount: 12,
      ),
      WorkoutReportSession(
        id: 2,
        date: today.subtract(const Duration(days: 2)),
        durationSeconds: 2640,
        totalVolume: 300,
        exerciseCount: 5,
        setCount: 15,
      ),
    ];
  }
}

class _EmptyReportRepository extends AppRepository {
  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async => [];
}

class _SingleBucketReportRepository extends _ReportRepository {
  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async => [
    WorkoutReportSession(
      id: 1,
      date: DateUtils.dateOnly(DateTime.now()).subtract(
        const Duration(days: 2),
      ),
      durationSeconds: 3600,
      totalVolume: 200,
      exerciseCount: 4,
      setCount: 12,
    ),
  ];
}
