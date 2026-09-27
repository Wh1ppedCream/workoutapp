import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/screens/exercise/analytics_dashboard_screen.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../tools/theme_style_inventory.dart';

void main() {
  test('Weekly Set Analytics owns its qualified theme recipes', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'weekly-set-analytics-theme-recipes',
    );

    expect(
      rule.pattern,
      'lib/screens/exercise/analytics_dashboard_screen.dart',
    );
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(
      rule.kinds,
      unorderedEquals(['color', 'color_transform', 'decoration', 'geometry']),
    );
    expect(rule.rationale, contains('eight current inventory findings'));

    final ownedFindings =
        report.findings.where((finding) => finding.ruleId == rule.id).toList();
    expect(ownedFindings, hasLength(8));
    expect(
      ownedFindings.where((finding) => finding.kind == 'color_transform'),
      hasLength(4),
    );
    expect(
      ownedFindings.where((finding) => finding.kind == 'decoration'),
      hasLength(3),
    );
    expect(
      ownedFindings.where((finding) => finding.kind == 'geometry'),
      hasLength(1),
    );
    expect(
      ownedFindings.map((finding) => finding.status),
      everyElement('migrated'),
    );

    final remaining =
        report.findings
            .where(
              (finding) =>
                  finding.file == rule.pattern && finding.status == 'pending',
            )
            .toList();
    expect(remaining, isEmpty);
  });

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode Weekly Set Analytics resolves theme roles', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.${TutorialIds.weeklySetsOverview}': true,
        });
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repository = _WeeklySetsRepository();
        final units = UnitPreferenceProvider();
        await units.ready;
        addTearDown(units.dispose);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const AnalyticsDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pageContext = tester.element(
          find.byType(AnalyticsDashboardScreen),
        );
        final strings = AppLocalizations.of(pageContext);
        final scheme = Theme.of(pageContext).colorScheme;
        final shapes = theme.shapeTokens;
        expect(
          shapes.dashboardRow,
          BorderRadius.circular(family == AppThemeFamily.classic ? 14 : 4),
        );
        expect(
          shapes.weeklySetRow,
          BorderRadius.circular(family == AppThemeFamily.classic ? 18 : 4),
        );
        expect(shapes.outlineWidth, family == AppThemeFamily.classic ? 1 : 2);
        final statFill = scheme.surfaceContainerHighest.withValues(alpha: 0.7);
        final statBoxes =
            tester.widgetList<Container>(find.byType(Container)).where((box) {
              final decoration = box.decoration;
              return box.padding ==
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ) &&
                  decoration is BoxDecoration &&
                  decoration.color == statFill;
            }).toList();

        expect(find.text(strings.weeklySetsTitle), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);
        expect(statBoxes, hasLength(3));
        expect(
          statBoxes.map(
            (box) => (box.decoration! as BoxDecoration).borderRadius,
          ),
          everyElement(shapes.dashboardRow),
        );
        expect(find.text(strings.weeklySetsNoBodyParts), findsOneWidget);

        final iconFill = scheme.primaryContainer.withValues(alpha: 0.55);
        final positive = theme.dataVisualizationTokens.positive;
        final rowFills = <Color>{
          positive.withValues(alpha: 0.13),
          scheme.surfaceContainerHighest.withValues(alpha: 0.13),
          scheme.error.withValues(alpha: 0.13),
          scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        };
        final rowBorders = <Color, Color>{
          positive.withValues(alpha: 0.13): positive.withValues(alpha: 0.35),
          scheme.surfaceContainerHighest.withValues(alpha: 0.13): scheme
              .surfaceContainerHighest
              .withValues(alpha: 0.35),
          scheme.error.withValues(alpha: 0.13): scheme.error.withValues(
            alpha: 0.35,
          ),
          scheme.surfaceContainerHighest.withValues(alpha: 0.45): scheme
              .surfaceContainerHighest
              .withValues(alpha: 0.7),
        };

        await tester.tap(find.text(strings.weeklySetsMuscles));
        await tester.pumpAndSettle();
        expect(find.text(strings.weeklySetsNoMuscles), findsNothing);

        final iconContainers =
            tester.widgetList<Container>(find.byType(Container)).where((box) {
              final decoration = box.decoration;
              return box.child is Icon &&
                  (box.child! as Icon).icon == Icons.fitness_center &&
                  decoration is BoxDecoration &&
                  decoration.color == iconFill;
            }).toList();
        expect(iconContainers, hasLength(4));
        expect(
          iconContainers.map(
            (box) => (box.decoration! as BoxDecoration).borderRadius,
          ),
          everyElement(shapes.dashboardRow),
        );

        final rowInkWells = tester
            .widgetList<InkWell>(find.byType(InkWell))
            .where((inkWell) => inkWell.borderRadius == shapes.weeklySetRow);
        expect(rowInkWells, hasLength(4));
        expect(
          tester
              .widgetList<Material>(find.byType(Material))
              .where((material) => material.type == MaterialType.transparency),
          hasLength(4),
        );

        final statusRows =
            tester.widgetList<Ink>(find.byType(Ink)).where((ink) {
              final decoration = ink.decoration;
              return decoration is BoxDecoration &&
                  rowFills.contains(decoration.color);
            }).toList();
        expect(statusRows, hasLength(4));
        for (final row in statusRows) {
          final decoration = row.decoration! as BoxDecoration;
          final fill = decoration.color!;
          expect(decoration.border, isA<Border>());
          expect(decoration.borderRadius, shapes.weeklySetRow);
          final border = decoration.border! as Border;
          expect(border.top.color, rowBorders[fill]);
          expect(border.top.width, shapes.outlineWidth);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}

class _WeeklySetsRepository extends AppRepository {
  static final _muscles = <Muscle>[
    Muscle(id: 1, name: 'Pectoralis major'),
    Muscle(id: 2, name: 'Rectus abdominis'),
    Muscle(id: 3, name: 'Deltoid'),
    Muscle(id: 4, name: 'Biceps brachii'),
  ];

  static const _counts = <int, double>{1: 2, 2: 0.5, 3: 5, 4: 1};

  static Map<String, dynamic> _bounds(int id) => {
    'muscle_id': id,
    'maintenance_volume': 0.5,
    'min_effective_volume': 1.0,
    'max_adaptive_volume': 3.0,
    'max_recoverable_volume': 4.0,
  };

  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async => [
    WorkoutReportSession(
      id: 1,
      date: DateTime.utc(2026, 1, 1),
      durationSeconds: 600,
      totalVolume: 1200,
      exerciseCount: 4,
      setCount: 8,
    ),
  ];

  @override
  Future<Map<int, double>> fetchSetsPerMuscle({
    required DateTime start,
    required DateTime end,
  }) async => _counts;

  @override
  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async => const {};

  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => _muscles;

  @override
  Future<List<Map<String, dynamic>>> fetchAllMuscleVolumeBounds() async => [
    _bounds(1),
    _bounds(2),
    _bounds(3),
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchAllBodyPartVolumeBounds() async =>
      const [];
}
