import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/nutrition/measured_items_page.dart';
import 'package:env_test/widgets/health_trends_section.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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

class _MeasurementRepository extends AppRepository {
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
