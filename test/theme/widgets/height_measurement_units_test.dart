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
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.measurement_trend_detail_v1': true,
    }),
  );

  for (final brightness in Brightness.values) {
    for (final input in [
      (mode: 'feet', value: '5.5', expected: 5.5, unit: 'ft'),
      (mode: 'inches', value: '71.125', expected: 71.125, unit: 'in'),
      (mode: 'centimeters', value: '180.34', expected: 180.34, unit: 'cm'),
      (mode: 'feetAndInches', value: '6', expected: 72.0, unit: 'in'),
    ]) {
      testWidgets('height accepts ${input.mode} independently $brightness', (
        tester,
      ) async {
        final units = await _units(tester);
        final repository = _Repository([_entry(1, 180.34, 'cm')]);
        await tester.pumpWidget(_host(units, repository, brightness));
        await _settle(tester);
        await tester.tap(
          find.byKey(const ValueKey('measurement-trend-entry-1')),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(ValueKey('measurement-height-unit-${input.mode}')),
        );
        await tester.pumpAndSettle();
        final pair = input.mode == 'feetAndInches';
        await tester.enterText(
          pair
              ? find.byKey(const ValueKey('measurement-entry-height-feet'))
              : find.byKey(AppTestKeys.measurementEntryValue),
          input.value,
        );
        if (pair) {
          await tester.enterText(
            find.byKey(const ValueKey('measurement-entry-height-inches')),
            '',
          );
        }
        expect(find.byKey(AppTestKeys.measurementEntryUnit), findsNothing);
        await tester.ensureVisible(
          find.byKey(AppTestKeys.measurementEntrySave),
        );
        await tester.tap(find.byKey(AppTestKeys.measurementEntrySave));
        await _settle(tester);
        expect(repository.saved?.value, closeTo(input.expected, 1e-9));
        expect(repository.saved?.unit, input.unit);
        expect(repository.saved?.timestamp, repository.original.timestamp);
        expect(repository.saved?.note, 'Original note');
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('switching units preserves fractional inches $brightness', (
      tester,
    ) async {
      final units = await _units(tester);
      final repository = _Repository([_entry(1, 71.125, 'in')]);
      await tester.pumpWidget(_host(units, repository, brightness));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('measurement-trend-entry-1')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('measurement-entry-height-inches')),
            )
            .controller!
            .text,
        '11.125',
      );
      for (final mode in ['feet', 'centimeters', 'inches', 'feetAndInches']) {
        await tester.tap(find.byKey(ValueKey('measurement-height-unit-$mode')));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(find.byKey(AppTestKeys.measurementEntrySave));
      await tester.tap(find.byKey(AppTestKeys.measurementEntrySave));
      await _settle(tester);
      expect(repository.saved?.value, 71.125);
      expect(repository.saved?.unit, 'in');
      expect(tester.takeException(), isNull);
    });

    for (final order in [
      [(72.0, 'in'), (6.0, 'ft'), (182.88, 'cm')],
      [(182.88, 'cm'), (6.0, 'ft'), (72.0, 'in')],
      [(182.88, 'cm'), (72.0, 'in'), (6.0, 'ft')],
    ]) {
      testWidgets(
        'mixed height units plot equally in ${order.last.$2} $brightness',
        (tester) async {
          final units = await _units(tester);
          final repository = _Repository([
            for (var index = 0; index < order.length; index++)
              _entry(index + 1, order[index].$1, order[index].$2),
          ]);
          await tester.pumpWidget(_host(units, repository, brightness));
          await _settle(tester);
          final data = tester.widget<LineChart>(find.byType(LineChart)).data;
          expect(
            data.lineBarsData.single.spots.map((point) => point.y),
            everyElement(order.last.$1),
          );
          final strings = AppLocalizations.of(
            tester.element(find.byType(LineChart)),
          );
          expect(
            tester
                .widget<Text>(
                  find.byKey(
                    const ValueKey('measurement-trend-summary-change'),
                  ),
                )
                .data,
            strings.healthNoChange,
          );
          // Original records and their units remain untouched for editing/labels.
          expect(
            repository.entries.map((entry) => entry.unit),
            order.map((item) => item.$2),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final family in [
      AppExpressiveDestinationFamily.nutrition,
      AppExpressiveDestinationFamily.dashboard,
      AppExpressiveDestinationFamily.profile,
    ]) {
      testWidgets(
        'height mini chart converts mixed units $family $brightness',
        (tester) async {
          final units = await _units(tester);
          final repository = _Repository([
            _entry(1, 72, 'in'),
            _entry(2, 6, 'ft'),
            _entry(3, 182.88, 'cm'),
          ]);
          await tester.pumpWidget(
            _host(units, repository, brightness, mini: true, family: family),
          );
          await _settle(tester);
          final data = tester.widget<LineChart>(find.byType(LineChart)).data;
          expect(
            data.lineBarsData.single.spots.map((point) => point.y),
            everyElement(182.88),
          );
          final strings = AppLocalizations.of(
            tester.element(find.byType(LineChart)),
          );
          expect(find.text(strings.healthNoChange), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('rounded decimal feet do not create a false height spike', (
    tester,
  ) async {
    final units = await _units(tester);
    final repository = _Repository([
      _entry(1, 53, 'in'),
      _entry(2, 4.416666667, 'ft'),
      _entry(3, 134.62, 'cm'),
    ]);
    await tester.pumpWidget(_host(units, repository, Brightness.light));
    await _settle(tester);
    final data = tester.widget<LineChart>(find.byType(LineChart)).data;
    expect(
      data.lineBarsData.single.spots.map((spot) => spot.y),
      everyElement(134.62),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('height change uses the latest unit rather than raw numbers', (
    tester,
  ) async {
    final units = await _units(tester);
    final repository = _Repository([_entry(1, 180, 'cm'), _entry(2, 6, 'ft')]);
    await tester.pumpWidget(_host(units, repository, Brightness.light));
    await _settle(tester);
    final text = tester
        .widget<Text>(
          find.byKey(const ValueKey('measurement-trend-summary-change')),
        )
        .data!;
    expect(text, contains('+0.1 ft'));
    expect(text, isNot(contains('-174')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('height modes fit a narrow screen with large text and keyboard', (
    tester,
  ) async {
    final units = await _units(tester, size: const Size(320, 760));
    final repository = _Repository([_entry(1, 180, 'cm')]);
    await tester.pumpWidget(
      _host(units, repository, Brightness.dark, textScale: 2, keyboard: 250),
    );
    await _settle(tester);
    await tester.tap(
      find.byKey(const ValueKey('measurement-trend-detail-add')),
    );
    await tester.pumpAndSettle();
    final selector = find.byKey(
      const ValueKey('measurement-height-unit-selector'),
    );
    expect(
      find.descendant(of: selector, matching: find.byType(ChoiceChip)),
      findsNWidgets(4),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('measurement-height-unit-inches')),
    );
    await tester.tap(
      find.byKey(const ValueKey('measurement-height-unit-inches')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(AppTestKeys.measurementEntryValue), findsOneWidget);
    await tester.ensureVisible(find.byKey(AppTestKeys.measurementEntrySave));
    expect(
      tester.getRect(find.byKey(AppTestKeys.measurementEntrySave)).bottom,
      lessThanOrEqualTo(510),
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

Future<UnitPreferenceProvider> _units(
  WidgetTester tester, {
  Size size = const Size(420, 1200),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final units = UnitPreferenceProvider();
  addTearDown(units.dispose);
  await units.ready;
  return units;
}

final _definition = MeasurementDefinition(
  id: 1,
  name: 'Height',
  type: MeasurementType.Height,
);

Measurement _entry(int id, double value, String unit) => Measurement(
  id: id,
  defId: 1,
  timestamp: DateTime(2026, 1, id + 10, 8),
  value: value,
  unit: unit,
  note: 'Original note',
);

Widget _host(
  UnitPreferenceProvider units,
  _Repository repository,
  Brightness brightness, {
  bool mini = false,
  AppExpressiveDestinationFamily family =
      AppExpressiveDestinationFamily.progress,
  double textScale = 1,
  double keyboard = 0,
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
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        viewInsets: EdgeInsets.only(bottom: keyboard),
      ),
      child: child!,
    ),
    home: AppExpressiveDestinationTheme(
      family: family,
      child: mini
          ? Scaffold(body: ListView(children: const [HealthTrendsSection()]))
          : MeasurementTrendDetailPage(definition: _definition),
    ),
  ),
);

class _Repository extends AppRepository {
  _Repository(this.entries) : original = entries.first;
  final List<Measurement> entries;
  final Measurement original;
  Measurement? saved;
  @override
  Future<void> ensureDefaultMeasurementDefinitions() async {}
  @override
  Future<List<MeasurementDefinition>>
  fetchClassMeasurementDefinitions() async => [_definition];
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
