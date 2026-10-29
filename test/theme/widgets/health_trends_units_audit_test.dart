import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/current_metrics_section.dart';
import 'package:env_test/widgets/health_trends_section.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.measurement_trend_detail_v1': true,
    }),
  );
  for (final brightness in Brightness.values) {
    testWidgets(
      'sparse custom mixed units remain accessible at large text $brightness',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          final units = await _units(tester);
          await tester.binding.setSurfaceSize(const Size(320, 760));
          final repository = _Repository(MeasurementType.Custom, [
            _entry(1, 60, 'bpm'),
            _entry(2, 20, '%'),
          ]);
          await tester.pumpWidget(
            _host(units, repository, brightness, textScale: 2),
          );
          await _settle(tester);
          final chart = find.byKey(
            const ValueKey('measurement-trend-chart-semantics'),
          );
          await tester.ensureVisible(chart);
          await tester.pumpAndSettle();
          expect(find.byType(LineChart), findsNothing);
          final data = tester.getSemantics(chart).getSemanticsData();
          expect(data.value, contains('20 %'));
          expect(data.hasAction(SemanticsAction.decrease), isFalse);
          final strings = AppLocalizations.of(tester.element(chart));
          expect(find.text(strings.healthChartUnitNote('%')), findsOneWidget);
          expect(repository.entries.length, 2);
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
          await tester.pump();
        }
      },
    );

    for (final type in MeasurementType.values.where(
      (type) =>
          type != MeasurementType.Height && type != MeasurementType.Custom,
    )) {
      testWidgets('$type mixed-unit chart and change are correct $brightness', (
        tester,
      ) async {
        final units = await _units(tester);
        final mass = type == MeasurementType.BodyWeight;
        final repository = _Repository(
          type,
          mass
              ? [_entry(1, 140, 'lbs'), _entry(2, 63.5029318, 'kg')]
              : [_entry(1, 25.4, 'cm'), _entry(2, 10, 'in')],
        );
        await tester.pumpWidget(_host(units, repository, brightness));
        await _settle(tester);
        final data = tester.widget<LineChart>(find.byType(LineChart)).data;
        expect(
          data.lineBarsData.single.spots.map((spot) => spot.y),
          everyElement(mass ? 63.5029318 : 10.0),
        );
        final strings = AppLocalizations.of(
          tester.element(find.byType(LineChart)),
        );
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey('measurement-trend-summary-change')),
              )
              .data,
          mass ? '0 kg' : strings.healthNoChange,
        );
        expect(repository.entries.first.unit, mass ? 'lbs' : 'cm');
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        '$type note-only edit preserves precision and context $brightness',
        (tester) async {
          final units = await _units(tester);
          final mass = type == MeasurementType.BodyWeight;
          final entry = _entry(
            1,
            mass ? 70.250123456 : 32.456789123,
            mass ? 'kg' : 'cm',
            note: mass ? 'WakeUp' : 'Original note',
            context: mass ? MeasurementContext.overall : null,
          );
          final repository = _Repository(type, [entry]);
          await tester.pumpWidget(_host(units, repository, brightness));
          await _settle(tester);
          await tester.tap(
            find.byKey(const ValueKey('measurement-trend-entry-1')),
          );
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<TextField>(
                  find.byKey(AppTestKeys.measurementEntryValue),
                )
                .controller!
                .text,
            entry.value.toString(),
          );
          expect(
            tester
                .widget<TextField>(
                  find.byKey(const ValueKey('measurement-entry-note')),
                )
                .controller!
                .text,
            entry.note,
          );
          await tester.enterText(
            find.byKey(const ValueKey('measurement-entry-note')),
            'Updated note',
          );
          await _save(tester);
          expect(repository.saved?.value, entry.value);
          expect(repository.saved?.unit, entry.unit);
          expect(repository.saved?.context, entry.context);
          expect(repository.saved?.timestamp, entry.timestamp);
          expect(repository.saved?.note, 'Updated note');
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final family in [
      AppExpressiveDestinationFamily.nutrition,
      AppExpressiveDestinationFamily.dashboard,
      AppExpressiveDestinationFamily.profile,
    ]) {
      for (final type in [MeasurementType.BodyWeight, MeasurementType.Waist]) {
        testWidgets('$type mini-chart converts units in $family $brightness', (
          tester,
        ) async {
          final units = await _units(tester);
          final mass = type == MeasurementType.BodyWeight;
          final repository = _Repository(
            type,
            mass
                ? [_entry(1, 140, 'lbs'), _entry(2, 63.5029318, 'kg')]
                : [_entry(1, 25.4, 'cm'), _entry(2, 10, 'in')],
          );
          await tester.pumpWidget(
            _host(units, repository, brightness, mini: true, family: family),
          );
          await _settle(tester);
          final data = tester.widget<LineChart>(find.byType(LineChart)).data;
          expect(
            data.lineBarsData.single.spots.map((spot) => spot.y),
            everyElement(mass ? 63.5029318 : 10.0),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets(
      'custom metric separates incompatible units without hiding history $brightness',
      (tester) async {
        final units = await _units(tester);
        final repository = _Repository(MeasurementType.Custom, [
          _entry(1, 60, 'bpm'),
          _entry(2, 20, '%'),
          _entry(3, 70, 'bpm'),
        ]);
        await tester.pumpWidget(_host(units, repository, brightness));
        await _settle(tester);
        final chart = tester.widget<LineChart>(find.byType(LineChart));
        expect(chart.data.lineBarsData.single.spots.map((spot) => spot.y), [
          60,
          70,
        ]);
        final strings = AppLocalizations.of(
          tester.element(find.byType(LineChart)),
        );
        expect(find.text(strings.healthUnitsNotComparable), findsOneWidget);
        expect(find.text(strings.healthChartUnitNote('bpm')), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(const ValueKey('measurement-trend-entry-2')),
        );
        expect(
          find.byKey(const ValueKey('measurement-trend-entry-2')),
          findsOneWidget,
        );
        expect(repository.entries.length, 3);
        expect(tester.takeException(), isNull);
      },
    );

    for (final value in [.000001, 1234.56789123]) {
      testWidgets(
        'custom edit preserves $value and ordinary reserved-word notes $brightness',
        (tester) async {
          final units = await _units(tester);
          final entry = _entry(1, value, 'score', note: 'WakeUp');
          final repository = _Repository(MeasurementType.Custom, [entry]);
          await tester.pumpWidget(_host(units, repository, brightness));
          await _settle(tester);
          if (value < 1) expect(find.text('0.000001 score'), findsWidgets);
          await tester.tap(
            find.byKey(const ValueKey('measurement-trend-entry-1')),
          );
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<TextField>(
                  find.byKey(const ValueKey('measurement-entry-note')),
                )
                .controller!
                .text,
            'WakeUp',
          );
          await tester.enterText(
            find.byKey(const ValueKey('measurement-entry-note')),
            'With pump',
          );
          await _save(tester);
          expect(repository.saved?.value, value);
          expect(repository.saved?.context, isNull);
          expect(repository.saved?.note, 'With pump');
          expect(find.textContaining('With pump'), findsWidgets);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'tiny custom changes stay visible in summaries and current metrics $brightness',
      (tester) async {
        final units = await _units(tester);
        final repository = _Repository(MeasurementType.Custom, [
          _entry(1, .000001, 'score'),
          _entry(2, .000002, 'score'),
        ]);
        await tester.pumpWidget(_host(units, repository, brightness));
        await _settle(tester);
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey('measurement-trend-summary-change')),
              )
              .data,
          contains('+0.000001'),
        );
        await tester.pumpWidget(
          _host(units, repository, brightness, metrics: true),
        );
        await _settle(tester);
        expect(find.text('0.000002 score'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'body-size pump context changes only when the checkbox is changed $brightness',
      (tester) async {
        final units = await _units(tester);
        final repository = _Repository(MeasurementType.Arm, [
          _entry(1, 32.5, 'cm', context: MeasurementContext.withPump),
        ]);
        await tester.pumpWidget(_host(units, repository, brightness));
        await _settle(tester);
        await tester.tap(
          find.byKey(const ValueKey('measurement-trend-entry-1')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pump();
        await _save(tester);
        expect(repository.saved?.context, MeasurementContext.withoutPump);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(AppTestKeys.measurementEntrySave));
  await tester.tap(find.byKey(AppTestKeys.measurementEntrySave));
  await _settle(tester);
}

Future<UnitPreferenceProvider> _units(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(420, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final units = UnitPreferenceProvider();
  addTearDown(units.dispose);
  await units.ready;
  return units;
}

Measurement _entry(
  int id,
  double value,
  String unit, {
  String? note,
  MeasurementContext? context,
}) => Measurement(
  id: id,
  defId: 1,
  timestamp: DateTime(2026, 1, id + 10, 8),
  value: value,
  unit: unit,
  note: note,
  context: context,
);

Widget _host(
  UnitPreferenceProvider units,
  _Repository repository,
  Brightness brightness, {
  bool mini = false,
  bool metrics = false,
  double textScale = 1,
  AppExpressiveDestinationFamily family =
      AppExpressiveDestinationFamily.progress,
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
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: AppExpressiveDestinationTheme(
      family: family,
      child: metrics
          ? const Scaffold(body: CurrentMetricsSection())
          : mini
          ? Scaffold(
              body: family == AppExpressiveDestinationFamily.profile
                  ? const HealthTrendsSection(fullPage: true)
                  : ListView(children: const [HealthTrendsSection()]),
            )
          : MeasurementTrendDetailPage(definition: repository.definition),
    ),
  ),
);

class _Repository extends AppRepository {
  _Repository(MeasurementType type, this.entries)
    : definition = MeasurementDefinition(id: 1, name: type.name, type: type);
  final MeasurementDefinition definition;
  final List<Measurement> entries;
  Measurement? saved;
  @override
  Future<void> ensureDefaultMeasurementDefinitions() async {}
  @override
  Future<List<MeasurementDefinition>>
  fetchClassMeasurementDefinitions() async => [definition];
  @override
  Future<List<Measurement>> fetchClassMeasurementsForDefinition(
    int defId,
  ) async => List.of(entries);
  @override
  Future<void> updateMeasurement({
    required int measurementId,
    required DateTime timestamp,
    required double value,
    required String unit,
    String? note,
    MeasurementContext? context,
  }) async {
    saved = Measurement(
      id: measurementId,
      defId: 1,
      timestamp: timestamp,
      value: value,
      unit: unit,
      note: note,
      context: context,
    );
    entries[entries.indexWhere((entry) => entry.id == measurementId)] = saved!;
  }
}
