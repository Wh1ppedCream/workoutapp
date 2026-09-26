import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/widgets/current_metrics_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  const types = <MeasurementType>[
    MeasurementType.BodyWeight,
    MeasurementType.Height,
    MeasurementType.Waist,
    MeasurementType.Chest,
    MeasurementType.Forearm,
  ];

  for (final family in AppThemeFamily.values) {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      testWidgets(
        '${family.code} ${brightness.name} preserves measurement category colors',
        (tester) async {
          final theme =
              brightness == Brightness.light
                  ? AppThemeFactory.light(family)
                  : AppThemeFactory.dark(family);
          final definitions = [
            for (var index = 0; index < types.length; index++)
              MeasurementDefinition(
                id: index + 1,
                name: 'Metric ${index + 1}',
                type: types[index],
              ),
          ];
          final recordedAt = DateTime.utc(2026, 9, 1);
          final entriesByDefinition = <int, List<Measurement>>{
            for (final definition in definitions)
              definition.id: [
                Measurement(
                  id: definition.id,
                  defId: definition.id,
                  timestamp: recordedAt.add(Duration(days: definition.id)),
                  value: definition.id.toDouble(),
                  unit: 'unit',
                ),
              ],
          };
          final repository = _MetricsRepository(
            definitions: definitions,
            entriesByDefinition: entriesByDefinition,
          );

          await tester.pumpWidget(
            _testApp(theme: theme, repository: repository),
          );
          await tester.pumpAndSettle();

          final dots = find.byWidgetPredicate((widget) {
            if (widget is! Container) return false;
            final decoration = widget.decoration;
            return decoration is BoxDecoration &&
                decoration.shape == BoxShape.circle;
          });
          expect(dots, findsNWidgets(types.length));

          final actualColors =
              tester
                  .widgetList<Container>(dots)
                  .map((dot) => (dot.decoration! as BoxDecoration).color)
                  .toList();
          final data = theme.dataVisualizationTokens;
          final expectedColors =
              family == AppThemeFamily.classic
                  ? <Color>[
                    Colors.green,
                    Colors.blue,
                    Colors.purple,
                    Colors.orange,
                    Colors.teal,
                  ]
                  : <Color>[
                    data.positive,
                    data.secondarySeries,
                    data.primarySeries,
                    data.tertiarySeries,
                    data.neutral,
                  ];

          expect(actualColors, unorderedEquals(expectedColors));
        },
      );
    }
  }

  for (final family in AppThemeFamily.values) {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      testWidgets(
        '${family.code} ${brightness.name} empty message uses the panel recipe',
        (tester) async {
          final theme =
              brightness == Brightness.light
                  ? AppThemeFactory.light(family)
                  : AppThemeFactory.dark(family);
          final repository = _MetricsRepository(
            definitions: const <MeasurementDefinition>[],
            entriesByDefinition: const <int, List<Measurement>>{},
          );

          await tester.pumpWidget(
            _testApp(theme: theme, repository: repository),
          );
          await tester.pumpAndSettle();

          final panel = find.byType(TonosSurface);
          expect(panel, findsOneWidget);
          final surface = tester.widget<TonosSurface>(panel);
          expect(surface.variant, TonosSurfaceVariant.panelRaised);
          expect(surface.padding, const EdgeInsets.all(16));

          final material =
              find.descendant(of: panel, matching: find.byType(Material)).first;
          final renderedSurface = tester.widget<Material>(material);
          expect(renderedSurface.color, theme.surfaceTokens.panelRaised);
          expect(
            tester.getSize(material).width,
            tester.getSize(find.byType(Scaffold)).width - 32,
          );
          expect(
            (renderedSurface.shape! as RoundedRectangleBorder).borderRadius,
            theme.shapeTokens.control,
          );

          final strings = AppLocalizations.of(
            tester.element(find.byType(CurrentMetricsSection)),
          );
          final titleFinder = find.text(strings.healthNoMeasurements);
          final bodyFinder = find.text(strings.healthNoMeasurementsBody);
          expect(titleFinder, findsOneWidget);
          expect(bodyFinder, findsOneWidget);
          final titleContext = tester.element(titleFinder);
          final scopedTheme = Theme.of(titleContext);
          final expectedForeground =
              theme.surfaceDecorationTokens.panel.outlined
                  ? tonosForegroundForSurface(
                    titleContext,
                    theme.surfaceTokens.panelRaised,
                  )
                  : null;
          final expectedTitleColor =
              expectedForeground ?? theme.textTheme.titleSmall?.color;
          final expectedBodyColor =
              expectedForeground ?? theme.textTheme.bodySmall?.color;
          expect(
            tester.widget<Text>(titleFinder).style?.color,
            expectedTitleColor,
          );
          expect(
            tester.widget<Text>(bodyFinder).style?.color,
            expectedBodyColor,
          );
          expect(
            scopedTheme.colorScheme.onSurface,
            theme.surfaceDecorationTokens.panel.outlined
                ? expectedForeground
                : theme.colorScheme.onSurface,
          );

          if (family == AppThemeFamily.classic) {
            expect(
              theme.surfaceTokens.panelRaised,
              theme.colorScheme.surfaceContainerHighest,
            );
            expect(
              theme.shapeTokens.control,
              const BorderRadius.all(Radius.circular(12)),
            );
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Widget _testApp({required ThemeData theme, required AppRepository repository}) {
  return Provider<AppRepository>.value(
    value: repository,
    child: MaterialApp(
      theme: theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: CurrentMetricsSection()),
    ),
  );
}

class _MetricsRepository extends AppRepository {
  _MetricsRepository({
    required this.definitions,
    required this.entriesByDefinition,
  });

  final List<MeasurementDefinition> definitions;
  final Map<int, List<Measurement>> entriesByDefinition;

  @override
  Future<void> ensureDefaultMeasurementDefinitions() async {}

  @override
  Future<List<MeasurementDefinition>> fetchClassMeasurementDefinitions() async {
    return definitions;
  }

  @override
  Future<List<Measurement>> fetchClassMeasurementsForDefinition(
    int defId,
  ) async {
    return List<Measurement>.from(entriesByDefinition[defId] ?? const []);
  }
}
