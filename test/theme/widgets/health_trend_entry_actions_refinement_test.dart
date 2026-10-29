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
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive ${brightness.name} weight entry menu and delete dialog are tonal',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 720));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.measurement_trend_detail_v1': true,
        });
        final units = UnitPreferenceProvider();
        addTearDown(units.dispose);
        await units.ready;
        final entry = _entry(id: 43, value: 74.5, unit: 'kg');
        final repository = _TestRepository([
          entry,
          for (var index = 0; index < 7; index++)
            _entry(
              id: 44 + index,
              value: 75 + index.toDouble(),
              unit: 'kg',
              timestamp: DateTime(2026, 1, 11 + index, 8),
            ),
        ]);
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final tokens = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.progress,
          brightness,
        );
        final dialogSurface = Color.lerp(
          tokens.pageCanvas,
          tokens.surfaceSelected,
          brightness == Brightness.light ? 0.54 : 0.56,
        );

        await tester.pumpWidget(_detailApp(repository, units, theme));
        await _settleDetail(tester);
        final row = find.byKey(const ValueKey('measurement-trend-entry-43'));
        await tester.ensureVisible(row);
        await tester.pumpAndSettle();
        final logEntryButton = tester.getRect(
          find.widgetWithText(FilledButton, 'Log entry'),
        );
        expect(
          tester.getRect(row).bottom,
          lessThanOrEqualTo(logEntryButton.top),
          reason: 'The final entry scrolls fully above the persistent action.',
        );
        final actions = find.byKey(
          const ValueKey('measurement-trend-entry-actions-43'),
        );
        await tester.tap(actions);
        await tester.pumpAndSettle();

        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
        final menu = tester.widget<PopupMenuButton<String>>(actions);
        expect(menu.position, PopupMenuPosition.over);
        expect(menu.offset, const Offset(0, -112));
        expect(menu.color, dialogSurface);
        expect(menu.surfaceTintColor, Colors.transparent);
        expect(menu.shape, isA<RoundedRectangleBorder>());
        expect(
          tester.getRect(find.text('Delete')).bottom,
          lessThanOrEqualTo(tester.getRect(actions).top),
        );
        final viewport = tester.getRect(find.byType(Scaffold).first);
        expect(tester.getRect(find.text('Edit')).top, greaterThanOrEqualTo(0));
        expect(
          tester.getRect(find.text('Delete')).bottom,
          lessThanOrEqualTo(viewport.bottom),
          reason: 'The menu remains in view for an entry near the list end.',
        );
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        final dialog = tester.widget<AlertDialog>(
          find.byKey(const ValueKey('measurement-trend-delete-entry-dialog')),
        );
        expect(dialog.backgroundColor, dialogSurface);
        expect(dialog.scrollable, isTrue);
        expect(dialog.shape, isA<RoundedRectangleBorder>());
        final confirmationText = dialog.content! as Text;
        expect(confirmationText.data, contains('74.5 kg'));
        expect(confirmationText.data, contains('2026'));
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
        final deleteButton = tester.widget<FilledButton>(
          find.byKey(const ValueKey('measurement-trend-delete-confirm')),
        );
        final deleteScheme = Theme.of(
          tester.element(
            find.byKey(const ValueKey('measurement-trend-delete-confirm')),
          ),
        ).colorScheme;
        expect(
          deleteButton.style?.backgroundColor?.resolve(const <WidgetState>{}),
          deleteScheme.error,
        );
        expect(
          deleteButton.style?.foregroundColor?.resolve(const <WidgetState>{}),
          deleteScheme.onError,
        );
        expect(
          deleteButton.style?.minimumSize?.resolve(const <WidgetState>{}),
          const Size(84, 48),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Expressive weight summary formats signed unit deltas and counts',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.measurement_trend_detail_v1': true,
      });
      final units = UnitPreferenceProvider();
      addTearDown(units.dispose);
      await units.ready;

      for (final scenario in [
        (previous: 80.0, latest: 80.5, unit: 'kg', expected: '+0.5 kg'),
        (previous: 80.5, latest: 80.0, unit: 'lbs', expected: '-0.5 lbs'),
        (previous: 80.0, latest: 80.0, unit: 'kg', expected: '0 kg'),
      ]) {
        final repository = _TestRepository([
          _entry(id: 1, value: scenario.previous, unit: scenario.unit),
          _entry(
            id: 2,
            value: scenario.latest,
            unit: scenario.unit,
            timestamp: DateTime(2026, 1, 11, 8),
          ),
        ]);
        await tester.pumpWidget(
          _detailApp(repository, units, ExpressiveThemeDefinition.light()),
        );
        await _settleDetail(tester);

        final change = find.byKey(
          const ValueKey('measurement-trend-summary-change'),
        );
        expect(find.text(scenario.expected), findsOneWidget);
        expect(find.text('Vs previous'), findsOneWidget);
        final destination = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.progress,
          Brightness.light,
        );
        expect(
          tester.widget<Text>(change).style?.color,
          destination.onSurfacePrimary,
        );
        final records = find.byKey(
          const ValueKey('measurement-trend-summary-records'),
        );
        expect(find.text('2 records'), findsOneWidget);
        expect(tester.widget<Text>(records).style?.color, isNotNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets('Expressive weight edit fields remain reachable with keyboard', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.measurement_trend_detail_v1': true,
    });
    final units = UnitPreferenceProvider();
    addTearDown(units.dispose);
    await units.ready;
    final repository = _TestRepository([_entry(id: 51, value: 75, unit: 'kg')]);
    final theme = ExpressiveThemeDefinition.dark();

    await tester.pumpWidget(
      _detailApp(repository, units, theme, textScale: 1.4),
    );
    await _settleDetail(tester);
    final row = find.byKey(const ValueKey('measurement-trend-entry-51'));
    await tester.scrollUntilVisible(
      row,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('measurement-trend-entry-actions-51')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _detailApp(
        repository,
        units,
        theme,
        textScale: 1.4,
        viewInsets: const EdgeInsets.only(bottom: 280),
      ),
    );
    await _settleDetail(tester);

    final dialog = tester.widget<AlertDialog>(
      find.byKey(const ValueKey('measurement-trend-entry-dialog')),
    );
    expect(dialog.scrollable, isTrue);
    expect(find.byKey(AppTestKeys.measurementEntryValue), findsOneWidget);
    expect(find.byKey(AppTestKeys.measurementEntryUnit), findsOneWidget);
    for (final key in ['weight', 'unit', 'variation', 'note']) {
      expect(
        find.byKey(ValueKey('measurement-entry-label-$key')),
        findsOneWidget,
      );
    }
    expect(
      find.byKey(const ValueKey('measurement-entry-note')),
      findsOneWidget,
    );
    expect(find.byKey(AppTestKeys.measurementEntrySave), findsOneWidget);
    final valueField = tester.widget<TextField>(
      find.byKey(AppTestKeys.measurementEntryValue),
    );
    expect(
      valueField.keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );
    expect(valueField.decoration?.filled, isTrue);
    expect(valueField.decoration?.labelText, isNull);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('measurement-entry-variation')),
        matching: find.text('Optional'),
      ),
      findsOneWidget,
    );
    final fieldTheme = Theme.of(
      tester.element(find.byKey(AppTestKeys.measurementEntryUnit)),
    );
    expect(fieldTheme.inputDecorationTheme.filled, isTrue);
    expect(fieldTheme.inputDecorationTheme.border, isA<OutlineInputBorder>());
    expect(
      fieldTheme.inputDecorationTheme.floatingLabelBehavior,
      FloatingLabelBehavior.always,
    );
    final dateButton = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('measurement-entry-date')),
    );
    expect(dateButton.child, isA<Row>());
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(
      tester.getRect(find.byKey(AppTestKeys.measurementEntrySave)).bottom,
      lessThanOrEqualTo(440),
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Expressive non-weight entry uses the same tonal dialog fields', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.measurement_trend_detail_v1': true,
    });
    final units = UnitPreferenceProvider();
    addTearDown(units.dispose);
    await units.ready;
    final repository = _TestRepository([
      _entry(id: 61, value: 175, unit: 'cm'),
    ]);

    await tester.pumpWidget(
      _detailApp(
        repository,
        units,
        ExpressiveThemeDefinition.light(),
        definitionType: MeasurementType.Height,
      ),
    );
    await _settleDetail(tester);
    await tester.tap(
      find.byKey(const ValueKey('measurement-trend-entry-actions-61')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final dialog = tester.widget<AlertDialog>(
      find.byKey(const ValueKey('measurement-trend-entry-dialog')),
    );
    expect(dialog.scrollable, isTrue);
    expect(dialog.backgroundColor, isNotNull);
    expect(find.byKey(AppTestKeys.measurementEntryUnit), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('measurement-height-unit-selector')),
        matching: find.byType(ChoiceChip),
      ),
      findsNWidgets(4),
    );
    final dateButton = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('measurement-entry-date')),
    );
    expect(dateButton.child, isA<Row>());
    final fieldTheme = Theme.of(
      tester.element(find.byKey(AppTestKeys.measurementEntryValue)),
    );
    expect(fieldTheme.inputDecorationTheme.filled, isTrue);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _settleDetail(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

Measurement _entry({
  required int id,
  required double value,
  required String unit,
  DateTime? timestamp,
}) => Measurement(
  id: id,
  defId: 1,
  timestamp: timestamp ?? DateTime(2026, 1, 10, 8),
  value: value,
  unit: unit,
);

Widget _detailApp(
  _TestRepository repository,
  UnitPreferenceProvider units,
  ThemeData theme, {
  double textScale = 1,
  EdgeInsets viewInsets = EdgeInsets.zero,
  MeasurementType definitionType = MeasurementType.BodyWeight,
}) => MultiProvider(
  providers: [
    Provider<AppRepository>.value(value: repository),
    ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
  ],
  child: MaterialApp(
    theme: theme,
    locale: const Locale('en'),
    localizationsDelegates: tonosLocalizationDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        viewInsets: viewInsets,
      ),
      child: child!,
    ),
    home: AppExpressiveDestinationTheme(
      family: AppExpressiveDestinationFamily.progress,
      child: Scaffold(
        body: MeasurementTrendDetailPage(
          definition: MeasurementDefinition(
            id: 1,
            name: definitionType == MeasurementType.Height
                ? 'Height'
                : 'Weight',
            type: definitionType,
          ),
        ),
      ),
    ),
  ),
);

class _TestRepository extends AppRepository {
  _TestRepository(this.entries);

  final List<Measurement> entries;

  @override
  Future<List<Measurement>> fetchClassMeasurementsForDefinition(
    int defId,
  ) async => List<Measurement>.of(entries);
}
