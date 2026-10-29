import 'dart:ui' as ui;

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/nutrition/measured_items_page.dart';
import 'package:env_test/widgets/health_trends_section.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('health cards resolve Classic and injected progress surfaces', (
    tester,
  ) async {
    final base = ClassicThemeDefinition.light();
    for (final color in [base.cardColor, Colors.orange]) {
      final theme = base.copyWith(
        extensions: [
          ...base.extensions.values.where(
            (extension) =>
                extension.runtimeType != base.progressColors.runtimeType,
          ),
          base.progressColors.copyWith(healthCard: color),
        ],
      );
      await tester.pumpWidget(
        Provider<AppRepository>.value(
          value: _MeasurementRepository(),
          child: MaterialApp(
            theme: theme,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: HealthTrendsSection()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final card = find.byKey(const ValueKey('measurement-trend-1'));
      final material = find
          .ancestor(of: card, matching: find.byType(Material))
          .first;
      expect(material, findsOneWidget);
      expect(tester.widget<Material>(material).color, color);
      expect(tester.getSize(card).width, 154);
      expect(tester.takeException(), isNull);
    }
  });

  for (final brightness in Brightness.values) {
    for (final empty in [true, false]) {
      testWidgets(
        'Neo ${brightness.name} health cards paint above shadows (empty=$empty)',
        (tester) async {
          SharedPreferences.setMockInitialValues({});
          final units = UnitPreferenceProvider();
          addTearDown(units.dispose);
          await units.ready;
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.binding.setSurfaceSize(const Size(380, 800));
          final strings = await AppLocalizations.delegate.load(
            const Locale('en'),
          );
          final theme = brightness == Brightness.light
              ? NeoBrutalismThemeDefinition.light()
              : NeoBrutalismThemeDefinition.dark();
          final captureKey = GlobalKey();
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(
                  value: _MeasurementRepository(empty: empty),
                ),
                ChangeNotifierProvider<UnitPreferenceProvider>.value(
                  value: units,
                ),
              ],
              child: MaterialApp(
                theme: theme,
                locale: const Locale('en'),
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: RepaintBoundary(
                    key: captureKey,
                    child: const HealthTrendsSection(),
                  ),
                ),
              ),
            ),
          );
          await _settleHealthTrends(tester);

          final card = find.byKey(AppTestKeys.measurementTrend(1));
          expect(tester.getSize(card), const Size(154, 162));
          final title = find.descendant(
            of: card,
            matching: find.text(strings.measurementWeight),
          );
          expect(title, findsOneWidget);
          if (empty) {
            expect(
              find.descendant(
                of: card,
                matching: find.text(strings.healthNoEntries),
              ),
              findsOneWidget,
            );
          }
          await _expectHealthCardPaint(tester, captureKey, card, title, theme);

          await tester.tap(find.byKey(AppTestKeys.measurementTrendAdd(1)));
          await _settleHealthTrends(tester);
          expect(find.byType(AlertDialog), findsOneWidget);
          expect(
            find.text(strings.healthLogMeasurement(strings.measurementWeight)),
            findsOneWidget,
          );
          await tester.tap(find.text(strings.commonCancel));
          await _settleHealthTrends(tester);
          expect(find.byType(AlertDialog), findsNothing);

          await tester.tap(find.text(strings.healthMetric));
          await _settleHealthTrends(tester);
          expect(find.byType(AlertDialog), findsOneWidget);
          expect(find.text(strings.healthCreateMetric), findsOneWidget);
          await tester.tap(find.text(strings.commonCancel));
          await _settleHealthTrends(tester);
          expect(find.byType(AlertDialog), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('uses a two-column trend grid in the measurements hub', (
    tester,
  ) async {
    await tester.pumpWidget(
      Provider<AppRepository>.value(
        value: _MeasurementRepository(),
        child: MaterialApp(
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MeasuredItemsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final grid = tester.widget<GridView>(find.byType(GridView));
    final layout =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(layout.crossAxisCount, 2);

    final card = find.byKey(const ValueKey('measurement-trend-1'));
    expect(card, findsOneWidget);
    final gridSize = tester.getSize(find.byType(GridView));
    expect(
      tester.getSize(card).width * 2 + 12,
      closeTo(gridSize.width - 32, 0.1),
    );
  });

  testWidgets(
    'Profile scope changes only the measured health card surface in both modes',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final semantics = tester.ensureSemantics();
      try {
        for (final brightness in Brightness.values) {
          final theme = brightness == Brightness.light
              ? ExpressiveThemeDefinition.light()
              : ExpressiveThemeDefinition.dark();
          final originalColors = theme.progressColors;
          final profileTokens = AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.profile,
            theme.brightness,
          );

          for (final profileScoped in [false, true]) {
            final page = profileScoped
                ? const AppExpressiveDestinationTheme(
                    family: AppExpressiveDestinationFamily.profile,
                    child: MeasuredItemsPage(),
                  )
                : const MeasuredItemsPage();
            await tester.pumpWidget(
              Provider<AppRepository>.value(
                value: _MeasurementRepository(),
                child: MaterialApp(
                  theme: theme,
                  localizationsDelegates: tonosLocalizationDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: const TextScaler.linear(1.5)),
                    child: child!,
                  ),
                  home: page,
                ),
              ),
            );
            await tester.pumpAndSettle();

            final healthSection = find.byType(HealthTrendsSection);
            final pageColors = Theme.of(tester.element(healthSection))
                .progressColors;
            final expectedHealthCard = profileScoped
                ? profileTokens.surfaceAccent
                : originalColors.healthCard;
            expect(pageColors.healthCard, expectedHealthCard);
            expect(pageColors.accent, originalColors.accent);
            expect(pageColors.estimated, originalColors.estimated);
            expect(pageColors.estimatedOneRm, originalColors.estimatedOneRm);
            expect(pageColors.grid, originalColors.grid);
            expect(pageColors.label, originalColors.label);
            expect(
              pageColors.exerciseIncrease,
              originalColors.exerciseIncrease,
            );
            expect(
              pageColors.exerciseDecrease,
              originalColors.exerciseDecrease,
            );
            expect(pageColors.neutral, originalColors.neutral);
            expect(pageColors.workoutIncrease, originalColors.workoutIncrease);
            expect(pageColors.workoutDecrease, originalColors.workoutDecrease);
            expect(pageColors.healthIncrease, originalColors.healthIncrease);
            expect(pageColors.healthDecrease, originalColors.healthDecrease);
            expect(pageColors.healthGrid, originalColors.healthGrid);

            final card = find.byKey(AppTestKeys.measurementTrend(1));
            expect(card, findsOneWidget);
            expect(tester.getSize(card).width, greaterThan(0));
            final logAction = find.byKey(
              const ValueKey('measurement-trend-1-log-semantics'),
            );
            expect(logAction, findsOneWidget);
            expect(
              tester
                  .getSemantics(logAction)
                  .getSemanticsData()
                  .hasAction(SemanticsAction.tap),
              isTrue,
            );
            expect(tester.takeException(), isNull);
          }
        }
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('keeps dashboard trends compact and horizontal', (tester) async {
    await tester.pumpWidget(
      Provider<AppRepository>.value(
        value: _MeasurementRepository(),
        child: MaterialApp(
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: HealthTrendsSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.scrollDirection, Axis.horizontal);
    expect(
      tester.getSize(find.byKey(const ValueKey('measurement-trend-1'))).width,
      154,
    );
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive Measurements title and concise empty cards (${brightness.name})',
      (tester) async {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final strings = await AppLocalizations.delegate.load(
          const Locale('en'),
        );
        await tester.binding.setSurfaceSize(const Size(380, 820));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: _MeasurementRepository(empty: true),
            child: MaterialApp(
              theme: theme,
              locale: const Locale('en'),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const AppExpressiveDestinationTheme(
                family: AppExpressiveDestinationFamily.profile,
                child: MeasuredItemsPage(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(strings.progressMeasurements), findsOneWidget);
        expect(find.text(strings.healthTrackedMetrics), findsOneWidget);
        expect(
          find.text(strings.healthTrendNeedEntries, skipOffstage: false),
          findsNothing,
        );
        expect(find.text(strings.healthNoEntries), findsNWidgets(2));
        expect(find.text(strings.healthTapToLog), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Expressive Measurement Library fields and height conversion (${brightness.name})',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final units = UnitPreferenceProvider();
        addTearDown(units.dispose);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await units.ready;
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final strings = await AppLocalizations.delegate.load(
          const Locale('en'),
        );

        for (final (size, textScale) in [
          (const Size(320, 860), 1.5),
          (const Size(400, 860), 1.0),
        ]) {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(
                  value: _MeasurementRepository(includeHeight: true),
                ),
                ChangeNotifierProvider<UnitPreferenceProvider>.value(
                  value: units,
                ),
              ],
              child: MaterialApp(
                theme: theme,
                locale: const Locale('en'),
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(textScale)),
                  child: child!,
                ),
                home: const AppExpressiveDestinationTheme(
                  family: AppExpressiveDestinationFamily.profile,
                  child: MeasuredItemsPage(),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text(strings.progressMeasurements), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.tap(find.text(strings.healthMetric));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'create dialog open');
          expect(find.byType(AlertDialog), findsOneWidget);
          expect(
            Theme.of(tester.element(find.byType(TextField).first))
                .inputDecorationTheme
                .filled,
            isTrue,
          );
          expect(
            Theme.of(tester.element(find.byType(TextField).first))
                .inputDecorationTheme
                .border,
            isA<OutlineInputBorder>(),
          );
          final note = tester.widget<TextField>(find.byType(TextField).last);
          expect(note.maxLines, 3);
          await tester.tap(find.text(strings.commonCancel));
          await tester.pumpAndSettle();

          final weightAdd = find.byKey(AppTestKeys.measurementTrendAdd(1));
          await tester.ensureVisible(weightAdd);
          await tester.tap(weightAdd);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'log dialog open');
          final measurementValue = tester.widget<TextField>(
            find.byKey(AppTestKeys.measurementEntryValue),
          );
          expect(measurementValue.decoration?.filled, isTrue);
          expect(
            measurementValue.keyboardType,
            const TextInputType.numberWithOptions(decimal: true),
          );
          expect(
            tester
                .widget<TextField>(find.byKey(AppTestKeys.measurementEntryUnit))
                .controller
                ?.text,
            'lbs',
          );
          expect(
            tester
                .widget<TextField>(
                  find.byKey(const ValueKey('measurement-entry-note')),
                )
                .maxLines,
            3,
          );
          await tester.tap(find.text(strings.commonCancel));
          await tester.pumpAndSettle();

          final heightAdd = find.byKey(AppTestKeys.measurementTrendAdd(3));
          await tester.ensureVisible(heightAdd);
          await tester.tap(heightAdd);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'height dialog open');
          final selector = find.byKey(
            const ValueKey('measurement-height-unit-selector'),
          );
          expect(
            find.descendant(of: selector, matching: find.byType(ChoiceChip)),
            findsNWidgets(4),
          );
          expect(
            tester
                .widget<ChoiceChip>(
                  find.byKey(
                    const ValueKey('measurement-height-unit-centimeters'),
                  ),
                )
                .selected,
            isTrue,
          );
          expect(
            tester
                .widget<TextField>(
                  find.byKey(AppTestKeys.measurementEntryValue),
                )
                .controller
                ?.text,
            '',
          );
          await tester.enterText(
            find.byKey(AppTestKeys.measurementEntryValue),
            '180',
          );

          await tester.tap(
            find.text(
              '${strings.measurementFeet}/${strings.measurementInches}',
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'height unit changed');
          expect(
            tester
                .widget<TextField>(
                  find.byKey(const ValueKey('measurement-entry-height-feet')),
                )
                .controller
                ?.text,
            '5',
          );
          expect(
            double.parse(
              tester
                  .widget<TextField>(
                    find.byKey(
                      const ValueKey('measurement-entry-height-inches'),
                    ),
                  )
                  .controller!
                  .text,
            ),
            closeTo(10.866142, 1e-6),
          );

          final dateButton = find.byKey(
            const ValueKey('measurement-entry-date'),
          );
          await tester.ensureVisible(dateButton);
          await tester.tap(dateButton);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'date picker open');
          final datePicker = find.byType(DatePickerDialog);
          expect(datePicker, findsOneWidget);
          expect(
            Theme.of(tester.element(datePicker)).datePickerTheme.shape,
            isNotNull,
          );
          Navigator.of(tester.element(datePicker)).pop();
          await tester.pumpAndSettle();
          await tester.tap(find.text(strings.commonCancel));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      'Measurement Library delta includes unit with neutral foreground (${brightness.name})',
      (tester) async {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final strings = await AppLocalizations.delegate.load(
          const Locale('en'),
        );
        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: _MeasurementRepository(multipleEntries: true),
            child: MaterialApp(
              theme: theme,
              locale: const Locale('en'),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const AppExpressiveDestinationTheme(
                family: AppExpressiveDestinationFamily.profile,
                child: MeasuredItemsPage(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final delta = find.text(strings.healthChangeSinceLast('+30 lbs'));
        expect(delta, findsOneWidget);
        expect(
          tester.widget<Text>(delta).style?.color,
          AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.profile,
            brightness,
          ).onSurfaceAccent,
        );
      },
    );
  }
}

Future<void> _settleHealthTrends(WidgetTester tester) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
  expect(tester.takeException(), isNull);
}

Future<void> _expectHealthCardPaint(
  WidgetTester tester,
  GlobalKey captureKey,
  Finder card,
  Finder title,
  ThemeData theme,
) async {
  final boundary =
      captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final origin = boundary.localToGlobal(Offset.zero);
  final cardRect = tester.getRect(card).shift(-origin);
  final titleRect = tester.getRect(title).shift(-origin);
  final shadow = theme.effectTokens.cardShadowOffset;
  final foreground = tonosForegroundForSurface(
    tester.element(card),
    theme.surfaceTokens.catalogSelection,
  );

  // Raster work must run outside the widget test's fake clock.
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final pixels = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      Color pixelAt(Offset position) {
        final index =
            (position.dy.floor() * image.width + position.dx.floor()) * 4;
        return Color.fromARGB(
          pixels.getUint8(index + 3),
          pixels.getUint8(index),
          pixels.getUint8(index + 1),
          pixels.getUint8(index + 2),
        );
      }

      // Material.color alone passed while the inner shadow hid the cyan face.
      for (final fraction in [0.25, 0.5, 0.75]) {
        expect(
          pixelAt(cardRect.topLeft + Offset(8, cardRect.height * fraction)),
          theme.surfaceTokens.catalogSelection,
          reason: 'The card face must paint over the shadow',
        );
      }
      expect(
        pixelAt(cardRect.centerRight + Offset(shadow.dx / 2, 0)),
        theme.effectTokens.cardShadow,
        reason: 'The right offset shadow must remain visible',
      );
      expect(
        pixelAt(cardRect.bottomCenter + Offset(0, shadow.dy / 2)),
        theme.effectTokens.cardShadow,
        reason: 'The list must not clip the bottom offset shadow',
      );

      var inkPixels = 0;
      for (var y = titleRect.top.ceil(); y < titleRect.bottom.floor(); y++) {
        for (var x = titleRect.left.ceil(); x < titleRect.right.floor(); x++) {
          if (pixelAt(Offset(x.toDouble(), y.toDouble())) == foreground) {
            inkPixels++;
          }
        }
      }
      expect(
        inkPixels,
        greaterThan(5),
        reason: 'The measurement title must be painted',
      );
    } finally {
      image.dispose();
    }
  });
}

class _MeasurementRepository extends AppRepository {
  _MeasurementRepository({
    this.empty = false,
    this.includeHeight = false,
    this.multipleEntries = false,
  });

  final bool empty;
  final bool includeHeight;
  final bool multipleEntries;

  @override
  Future<void> ensureDefaultMeasurementDefinitions() async {}

  @override
  Future<List<MeasurementDefinition>> fetchClassMeasurementDefinitions() async {
    return [
      MeasurementDefinition(
        id: 1,
        name: 'Weight',
        type: MeasurementType.BodyWeight,
      ),
      MeasurementDefinition(id: 2, name: 'Waist', type: MeasurementType.Waist),
      if (includeHeight)
        MeasurementDefinition(
          id: 3,
          name: 'Height',
          type: MeasurementType.Height,
        ),
    ];
  }

  @override
  Future<List<Measurement>> fetchClassMeasurementsForDefinition(
    int defId,
  ) async {
    if (empty) return [];
    final value = switch (defId) {
      1 => 180.0,
      2 => 32.0,
      3 => 180.0,
      _ => 1.0,
    };
    final unit = defId == 1
        ? 'lbs'
        : defId == 3
        ? 'cm'
        : 'in';
    if (multipleEntries) {
      return [
        Measurement(
          id: defId * 10,
          defId: defId,
          timestamp: DateTime(2026, 8, 1),
          value: value - 30,
          unit: unit,
        ),
        Measurement(
          id: defId * 10 + 1,
          defId: defId,
          timestamp: DateTime(2026, 8, 13),
          value: value,
          unit: unit,
        ),
      ];
    }
    return [
      Measurement(
        id: defId,
        defId: defId,
        timestamp: DateTime(2026, 8, 13),
        value: value,
        unit: unit,
      ),
    ];
  }
}
