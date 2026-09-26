import 'dart:ui' as ui;

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/nutrition/measured_items_page.dart';
import 'package:env_test/widgets/health_trends_section.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:flutter/material.dart';
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: HealthTrendsSection()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final card = find.byKey(const ValueKey('measurement-trend-1'));
      final material =
          find.ancestor(of: card, matching: find.byType(Material)).first;
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
          final theme =
              brightness == Brightness.light
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
                localizationsDelegates: AppLocalizations.localizationsDelegates,
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
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

  testWidgets('keeps dashboard trends compact and horizontal', (tester) async {
    await tester.pumpWidget(
      Provider<AppRepository>.value(
        value: _MeasurementRepository(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
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
      final pixels =
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
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
  _MeasurementRepository({this.empty = false});

  final bool empty;

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
    ];
  }

  @override
  Future<List<Measurement>> fetchClassMeasurementsForDefinition(
    int defId,
  ) async {
    if (empty) return [];
    return [
      Measurement(
        id: defId,
        defId: defId,
        timestamp: DateTime(2026, 8, 13),
        value: defId == 1 ? 180 : 32,
        unit: defId == 1 ? 'lbs' : 'in',
      ),
    ];
  }
}
