import 'dart:async';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/health_trends_section.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.measurement_trend_detail_v1': true,
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'restoring an old low pound value explains the limit $brightness',
      (tester) async {
        final units = await _units(tester);
        final repository = _Repository();
        repository.entries[2] = Measurement(
          id: 3,
          defId: 1,
          timestamp: DateTime(2026, 1, 13, 8),
          value: 25,
          unit: 'lbs',
        );
        await tester.pumpWidget(
          _host(units, repository, brightness: brightness),
        );
        await tester.pumpAndSettle();
        final row = find.byKey(const ValueKey('measurement-trend-entry-3'));
        await tester.tap(row);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(AppTestKeys.measurementEntryValue),
          '95',
        );
        await tester.tap(find.byKey(AppTestKeys.measurementEntrySave));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
        expect(repository.entries.last.value, 95);
        await tester.tap(row);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(AppTestKeys.measurementEntryValue),
          '25',
        );
        await tester.tap(find.byKey(AppTestKeys.measurementEntrySave));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expect(
          find.text('For body weight, enter 44–1100 lbs.'),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('measurement-trend-entry-dialog')),
          findsOneWidget,
        );
        expect(repository.entries.last.value, 95);
        expect(repository.updateCount, 1);
        await tester.enterText(
          find.byKey(AppTestKeys.measurementEntryValue),
          '70',
        );
        await tester.tap(find.byKey(AppTestKeys.measurementEntrySave));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
        expect(repository.entries.last.value, 70);
        expect(repository.updateCount, 2);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('mini chart moves after detail route closes $brightness', (
      tester,
    ) async {
      final units = await _units(tester);
      final repository = _Repository();
      await tester.pumpWidget(
        _host(units, repository, brightness: brightness, mini: true),
      );
      await tester.pumpAndSettle();
      final miniState = tester.state(find.byType(LineChart));
      await tester.tap(find.byKey(AppTestKeys.measurementTrend(1)));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('measurement-trend-entry-3')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(AppTestKeys.measurementEntryValue),
        '80',
      );
      await tester.tap(find.byKey(AppTestKeys.measurementEntrySave));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      repository.holdNext = true;
      await tester.tap(find.byTooltip('Back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(
        repository.pending,
        isNull,
        reason: 'Do not animate under the outgoing page.',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      expect(repository.pending, isNotNull);
      expect(tester.state(find.byType(LineChart)), same(miniState));
      repository.completePending();
      await _waitForTarget(tester, 80);
      await tester.pump(const Duration(milliseconds: 70));
      final middle = _paintedData(tester).lineBarsData.single.spots.last.y;
      expect(middle, greaterThan(72));
      expect(middle, lessThan(80));
      await tester.pumpAndSettle();
      expect(_paintedData(tester).lineBarsData.single.spots.last.y, 80);
      expect(tester.takeException(), isNull);
    });

    for (final reduced in [false, true]) {
      testWidgets(
        'saved entry visibly moves chart $brightness reduced=$reduced',
        (tester) async {
          final units = await _units(tester);
          final repository = _Repository();
          await tester.pumpWidget(
            _host(units, repository, brightness: brightness, reduced: reduced),
          );
          await tester.pumpAndSettle();
          final chartState = tester.state(find.byType(LineChart));
          expect(_paintedData(tester).lineBarsData.single.spots.last.y, 72);
          await tester.tap(
            find.byKey(const ValueKey('measurement-trend-entry-3')),
          );
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(AppTestKeys.measurementEntryValue),
            '80',
          );
          repository.holdNext = true;
          await tester.tap(find.byKey(AppTestKeys.measurementEntrySave));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 250));
          await tester.pump();

          expect(repository.pending, isNotNull);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(tester.state(find.byType(LineChart)), same(chartState));
          expect(_paintedData(tester).lineBarsData.single.spots.last.y, 72);
          await tester.pump(const Duration(milliseconds: 600));
          expect(tester.state(find.byType(LineChart)), same(chartState));
          repository.completePending();
          await _waitForTarget(tester, 80);
          await tester.pump(const Duration(milliseconds: 70));
          final middle = _paintedData(tester).lineBarsData.single.spots.last.y;
          if (reduced) {
            expect(middle, 80);
          } else {
            expect(middle, greaterThan(72));
            expect(middle, lessThan(80));
            await tester.pump(const Duration(milliseconds: 100));
            final later = _paintedData(tester).lineBarsData.single.spots.last.y;
            expect(later, greaterThan(middle));
            expect(later, lessThan(80));
          }
          await tester.pumpAndSettle();
          expect(_paintedData(tester).lineBarsData.single.spots.last.y, 80);
          expect(tester.state(find.byType(LineChart)), same(chartState));
          expect(repository.updateCount, 1);
          expect(tester.takeException(), isNull);
          await tester.pump(const Duration(milliseconds: 600));
          await tester.pumpAndSettle();
        },
      );
    }

    for (final family in [
      AppExpressiveDestinationFamily.nutrition,
      AppExpressiveDestinationFamily.dashboard,
      AppExpressiveDestinationFamily.profile,
    ]) {
      testWidgets('mini chart retains moving data $family $brightness', (
        tester,
      ) async {
        final units = await _units(tester);
        final repository = _Repository();
        await tester.pumpWidget(
          _host(
            units,
            repository,
            brightness: brightness,
            family: family,
            mini: true,
          ),
        );
        await tester.pumpAndSettle();
        final chartState = tester.state(find.byType(LineChart));
        repository.entries[2] = _entry(3, 80);
        repository.holdNext = true;
        await tester.pumpWidget(
          _host(
            units,
            repository,
            brightness: brightness,
            family: family,
            mini: true,
            refreshToken: 1,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(repository.pending, isNotNull);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(tester.state(find.byType(LineChart)), same(chartState));
        repository.completePending();
        await _waitForTarget(tester, 80);
        await tester.pump(const Duration(milliseconds: 70));
        final middle = _paintedData(tester).lineBarsData.single.spots.last.y;
        expect(middle, greaterThan(72));
        expect(middle, lessThan(80));
        await tester.pumpAndSettle();
        expect(_paintedData(tester).lineBarsData.single.spots.last.y, 80);
        expect(tester.state(find.byType(LineChart)), same(chartState));
        expect(tester.takeException(), isNull);
      });
    }
  }
}

Future<void> _waitForTarget(WidgetTester tester, double value) async {
  for (var frame = 0; frame < 10; frame++) {
    await tester.pump();
    if (tester
            .widget<LineChart>(find.byType(LineChart))
            .data
            .lineBarsData
            .single
            .spots
            .last
            .y ==
        value) {
      return;
    }
  }
  fail('The refreshed measurement did not reach the chart.');
}

LineChartData _paintedData(WidgetTester tester) {
  // Inspect the data actually supplied to the renderer, not only the target
  // LineChartData, to catch charts that remount and skip their interpolation.
  final dynamic leaf = tester.widget(
    find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == 'LineChartLeaf',
    ),
  );
  return leaf.data as LineChartData;
}

Future<UnitPreferenceProvider> _units(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(420, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final units = UnitPreferenceProvider();
  addTearDown(units.dispose);
  await units.ready;
  return units;
}

Widget _host(
  UnitPreferenceProvider units,
  _Repository repository, {
  required Brightness brightness,
  AppExpressiveDestinationFamily family =
      AppExpressiveDestinationFamily.progress,
  bool reduced = false,
  bool mini = false,
  int refreshToken = 0,
}) => MultiProvider(
  providers: [
    Provider<AppRepository>.value(value: repository),
    ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
  ],
  child: MaterialApp(
    theme: brightness == Brightness.light
        ? ExpressiveThemeDefinition.light()
        : ExpressiveThemeDefinition.dark(),
    locale: const Locale('en'),
    localizationsDelegates: tonosLocalizationDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
      child: child!,
    ),
    home: AppExpressiveDestinationTheme(
      family: family,
      child: mini
          ? Scaffold(
              body: family == AppExpressiveDestinationFamily.profile
                  ? HealthTrendsSection(
                      fullPage: true,
                      refreshToken: refreshToken,
                    )
                  : ListView(
                      children: [
                        HealthTrendsSection(refreshToken: refreshToken),
                      ],
                    ),
            )
          : MeasurementTrendDetailPage(definition: _definition),
    ),
  ),
);

final _definition = MeasurementDefinition(
  id: 1,
  name: 'Weight',
  type: MeasurementType.BodyWeight,
);

Measurement _entry(int id, double value) => Measurement(
  id: id,
  defId: 1,
  timestamp: DateTime(2026, 1, id + 10, 8),
  value: value,
  unit: 'kg',
);

class _Repository extends AppRepository {
  final entries = [_entry(1, 70), _entry(2, 71), _entry(3, 72)];
  bool holdNext = false;
  Completer<List<Measurement>>? pending;
  int updateCount = 0;

  @override
  Future<void> ensureDefaultMeasurementDefinitions() async {}

  @override
  Future<List<MeasurementDefinition>>
  fetchClassMeasurementDefinitions() async => [_definition];

  @override
  Future<List<Measurement>> fetchClassMeasurementsForDefinition(
    int defId,
  ) async {
    if (holdNext) {
      holdNext = false;
      pending = Completer<List<Measurement>>();
      return pending!.future;
    }
    return List<Measurement>.of(entries);
  }

  void completePending() => pending!.complete(List<Measurement>.of(entries));

  @override
  Future<void> updateMeasurement({
    required int measurementId,
    required DateTime timestamp,
    required double value,
    required String unit,
    String? note,
    MeasurementContext? context,
  }) async {
    updateCount++;
    entries[entries.indexWhere(
      (entry) => entry.id == measurementId,
    )] = Measurement(
      id: measurementId,
      defId: 1,
      timestamp: timestamp,
      value: value,
      unit: unit,
      note: note,
      context: context,
    );
  }
}
