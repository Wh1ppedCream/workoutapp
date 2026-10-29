import 'dart:async';
import 'dart:math' as math;

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/tokens/app_motion_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/widgets/workout_metric_chart_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _chart = find.byKey(const ValueKey('workout-report-chart-canvas'));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final brightness in Brightness.values) {
    testWidgets('points rise into place on first entry $brightness', (
      tester,
    ) async {
      final units = await _units(tester);
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      await tester.pumpWidget(_host(units, theme: theme));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      final dynamic entering = tester.widget<CustomPaint>(_chart).painter!;
      final targets = <double>[
        for (final dynamic bucket in entering.buckets)
          bucket.valueFor(entering.metric),
      ];
      expect(entering.seriesOpacity, 1);
      expect(targets.any((value) => value > 0), isTrue);
      for (var i = 0; i < targets.length; i++) {
        if (targets[i] > 0) {
          expect(entering.seriesValues[i], lessThan(targets[i]));
        }
      }
      await tester.pumpAndSettle();
      final dynamic settled = tester.widget<CustomPaint>(_chart).painter!;
      expect(settled.seriesValues, targets);
      expect(tester.takeException(), isNull);
    });

    for (final family in [
      AppExpressiveDestinationFamily.progress,
      AppExpressiveDestinationFamily.dashboard,
    ]) {
      testWidgets('point bubble paints a visible border $family $brightness', (
        tester,
      ) async {
        final units = await _units(tester);
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        await tester.pumpWidget(_host(units, theme: theme, family: family));
        await tester.pumpAndSettle();
        await tester.ensureVisible(_chart);
        await tester.tapAt(tester.getRect(_chart).center);
        await tester.pumpAndSettle();

        final dynamic painter = tester.widget<CustomPaint>(_chart).painter!;
        final tokens = AppExpressiveDestinationTokens.forFamily(
          family,
          brightness,
        );
        expect(painter.tooltipBackground, tokens.surfaceSelected);
        expect(painter.tooltipTextColor, tokens.onSurfaceSelected);
        expect(painter.tooltipOutline, tokens.outlineAccent);
        expect(
          _contrast(tokens.onSurfaceSelected, tokens.surfaceSelected),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(tokens.outlineAccent, tokens.surfaceSelected),
          greaterThanOrEqualTo(3),
        );
        expect(
          _chart,
          paints
            ..rrect(
              color: tokens.surfaceSelected.withValues(alpha: .97),
              style: PaintingStyle.fill,
            )
            ..rrect(color: tokens.outlineAccent, style: PaintingStyle.stroke),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('each range visibly moves points into place $brightness', (
      tester,
    ) async {
      final units = await _units(tester);
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      await tester.pumpWidget(_host(units, theme: theme));
      await tester.pumpAndSettle();
      final strings = await AppLocalizations.delegate.load(const Locale('en'));

      for (final range in [
        strings.workoutReportRangeOneWeekShort,
        strings.workoutReportRangeOneMonthShort,
        strings.workoutReportRangeThreeMonthsShort,
        strings.workoutReportRangeSixMonthsShort,
        strings.workoutReportRangeOneYearShort,
        strings.workoutReportRangeAll,
      ]) {
        await tester.ensureVisible(find.text(range));
        await tester.tap(find.text(range));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 30));
        final dynamic arriving = tester.widget<CustomPaint>(_chart).painter!;
        expect(arriving.seriesOpacity, 1, reason: range);
        final targets = <double>[
          for (final dynamic bucket in arriving.buckets)
            bucket.valueFor(arriving.metric),
        ];
        final values = List<double>.from(arriving.seriesValues);
        expect(targets.any((value) => value > 0), isTrue);
        for (var i = 0; i < targets.length; i++) {
          expect(values[i], greaterThanOrEqualTo(0));
          if (targets[i] > 0) {
            expect(values[i], lessThan(targets[i]), reason: range);
          }
        }
        await tester.pump(const Duration(milliseconds: 100));
        final dynamic movingPoints = tester
            .widget<CustomPaint>(_chart)
            .painter!;
        for (var i = 0; i < targets.length; i++) {
          if (targets[i] > 0) {
            expect(movingPoints.seriesValues[i], greaterThan(values[i]));
            expect(movingPoints.seriesValues[i], lessThan(targets[i]));
          }
        }
        await tester.pumpAndSettle();
        final dynamic settled = tester.widget<CustomPaint>(_chart).painter!;
        expect(settled.seriesOpacity, 1);
        expect(settled.seriesValues, targets);
      }

      await tester.ensureVisible(_chart);
      final rect = tester.getRect(_chart);
      await tester.tapAt(Offset(rect.left + rect.width * .3, rect.center.dy));
      await tester.pumpAndSettle();
      final dynamic selected = tester.widget<CustomPaint>(_chart).painter!;
      final previousPosition = selected.selectionPosition as double;
      await tester.tapAt(Offset(rect.left + rect.width * .8, rect.center.dy));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      final dynamic moving = tester.widget<CustomPaint>(_chart).painter!;
      expect(moving.seriesOpacity, 1);
      expect(moving.selectionPosition, greaterThan(previousPosition));
      expect(moving.selectionPosition, lessThan(moving.selectedIndex));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_host(units, theme: theme, refreshToken: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      final dynamic unchanged = tester.widget<CustomPaint>(_chart).painter!;
      expect(
        unchanged.seriesOpacity,
        1,
        reason: 'An idle refresh does not replay',
      );
      expect(unchanged.seriesValues, [
        for (final dynamic bucket in unchanged.buckets)
          bucket.valueFor(unchanged.metric),
      ], reason: 'An idle refresh keeps points in place');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('point movement waits for the actual query result', (
    tester,
  ) async {
    final units = await _units(tester);
    final repository = _DelayedReportRepository();
    await tester.pumpWidget(
      _host(
        units,
        theme: ExpressiveThemeDefinition.light(),
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();
    repository.holdNext = true;
    final strings = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.ensureVisible(
      find.text(strings.workoutReportRangeOneWeekShort),
    );
    await tester.tap(find.text(strings.workoutReportRangeOneWeekShort));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final dynamic waiting = tester.widget<CustomPaint>(_chart).painter!;
    expect(waiting.seriesOpacity, 0);
    await repository.completePending();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    final dynamic arriving = tester.widget<CustomPaint>(_chart).painter!;
    expect(arriving.seriesOpacity, 1);
    final targets = <double>[
      for (final dynamic bucket in arriving.buckets)
        bucket.valueFor(arriving.metric),
    ];
    expect(targets.any((value) => value > 0), isTrue);
    for (var i = 0; i < targets.length; i++) {
      if (targets[i] > 0) {
        expect(arriving.seriesValues[i], greaterThan(0));
        expect(arriving.seriesValues[i], lessThan(targets[i]));
      }
    }
    await tester.pumpAndSettle();
    final dynamic settled = tester.widget<CustomPaint>(_chart).painter!;
    expect(settled.seriesOpacity, 1);
    expect(settled.seriesValues, targets);
    expect(tester.takeException(), isNull);
  });

  for (final mode in ['reduced', 'effects-off', 'classic', 'neo']) {
    testWidgets('point movement settles immediately for $mode', (tester) async {
      final units = await _units(tester);
      var theme = ExpressiveThemeDefinition.light();
      if (mode == 'classic' || mode == 'neo') {
        theme = AppThemeFactory.light(
          mode == 'classic'
              ? AppThemeFamily.classic
              : AppThemeFamily.neoBrutalism,
        );
      } else if (mode == 'effects-off') {
        theme = theme.copyWith(
          extensions: theme.extensions.values.map(
            (extension) => extension is AppMotionTokens
                ? extension.copyWith(standard: Duration.zero)
                : extension,
          ),
        );
      }
      await tester.pumpWidget(
        _host(units, theme: theme, reducedMotion: mode == 'reduced'),
      );
      await tester.pumpAndSettle();
      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.ensureVisible(
        find.text(strings.workoutReportRangeOneMonthShort),
      );
      await tester.tap(find.text(strings.workoutReportRangeOneMonthShort));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      final dynamic painter = tester.widget<CustomPaint>(_chart).painter!;
      expect(painter.seriesOpacity, 1);
      if (mode == 'reduced' || mode == 'effects-off') {
        expect(painter.seriesValues, [
          for (final dynamic bucket in painter.buckets)
            bucket.valueFor(painter.metric),
        ]);
      }
      if (mode == 'classic' || mode == 'neo') {
        expect(painter.tooltipOutline, isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

Future<UnitPreferenceProvider> _units(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(420, 1300));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final units = UnitPreferenceProvider();
  addTearDown(units.dispose);
  await units.ready;
  return units;
}

Widget _host(
  UnitPreferenceProvider units, {
  required ThemeData theme,
  AppExpressiveDestinationFamily family =
      AppExpressiveDestinationFamily.progress,
  bool reducedMotion = false,
  int refreshToken = 0,
  AppRepository? repository,
}) => MultiProvider(
  providers: [
    Provider<AppRepository>.value(value: repository ?? _ReportRepository()),
    ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
  ],
  child: MaterialApp(
    theme: theme,
    locale: const Locale('en'),
    localizationsDelegates: tonosLocalizationDelegates,
    supportedLocales: const [Locale('en')],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
      child: child!,
    ),
    home: AppExpressiveDestinationTheme(
      family: family,
      child: Scaffold(
        body: SingleChildScrollView(
          child: WorkoutMetricChartCard(refreshToken: refreshToken),
        ),
      ),
    ),
  ),
);

double _contrast(Color a, Color b) {
  final left = a.computeLuminance();
  final right = b.computeLuminance();
  return (math.max(left, right) + .05) / (math.min(left, right) + .05);
}

class _ReportRepository extends AppRepository {
  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async {
    final today = DateUtils.dateOnly(DateTime.now());
    return [
      for (final daysAgo in [400, 80, 10, 2, 0])
        if (start == null ||
            !today.subtract(Duration(days: daysAgo)).isBefore(start))
          WorkoutReportSession(
            id: daysAgo,
            date: today.subtract(Duration(days: daysAgo)),
            durationSeconds: 1800,
            totalVolume: 2400,
            exerciseCount: 4,
            setCount: 12,
          ),
    ];
  }
}

class _DelayedReportRepository extends _ReportRepository {
  bool holdNext = false;
  Completer<List<WorkoutReportSession>>? _pending;
  DateTime? _pendingStart;

  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) {
    if (!holdNext) {
      return super.fetchWorkoutReportSessions(start: start, end: end);
    }
    holdNext = false;
    _pendingStart = start;
    _pending = Completer<List<WorkoutReportSession>>();
    return _pending!.future;
  }

  Future<void> completePending() async {
    _pending!.complete(
      await super.fetchWorkoutReportSessions(start: _pendingStart),
    );
  }
}
