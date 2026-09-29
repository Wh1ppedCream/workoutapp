import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/session_detail_screen.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';
import 'package:env_test/theme/tokens/app_surface_tokens.dart';
import 'package:env_test/utils/app_test_keys.dart';
import '../../../tools/theme_style_inventory.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode Session Detail surfaces use existing theme owners', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
        });
        final units = UnitPreferenceProvider();
        await units.ready;
        addTearDown(units.dispose);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: _SessionDetailRepository()),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: SessionDetailScreen(
                WorkoutSession(
                  id: 4,
                  date: DateTime(2026, 9, 26, 12),
                  duration: 2700,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final surfaces = theme.extension<AppSurfaceTokens>()!;
        final shapes = theme.extension<AppShapeTokens>()!;
        final metricTiles =
            tester.widgetList<Container>(find.byType(Container)).where((
              container,
            ) {
              final decoration = container.decoration;
              return decoration is BoxDecoration &&
                  decoration.color == surfaces.sessionSummary &&
                  decoration.borderRadius == shapes.metric;
            }).toList();
        expect(metricTiles, hasLength(3));

        final setIndex = tester.widget<Container>(
          find.byWidgetPredicate((widget) {
            if (widget is! Container ||
                widget.constraints !=
                    const BoxConstraints.tightFor(width: 28, height: 28)) {
              return false;
            }
            final decoration = widget.decoration;
            return decoration is BoxDecoration &&
                decoration.color == surfaces.panelRaised &&
                decoration.shape == BoxShape.circle;
          }),
        );
        expect(
          setIndex.constraints,
          const BoxConstraints.tightFor(width: 28, height: 28),
        );
        expect(tester.takeException(), isNull);

        final saveAsPlan = find.byKey(AppTestKeys.workoutSaveAsPlan);
        await tester.ensureVisible(saveAsPlan);
        await tester.tap(saveAsPlan);
        await tester.pumpAndSettle();

        final fieldFinder = find.byKey(AppTestKeys.workoutPlanName);
        final inputDecoratorFinder = find.descendant(
          of: fieldFinder,
          matching: find.byType(InputDecorator),
        );
        expect(inputDecoratorFinder, findsOneWidget);
        final inputDecorator = tester.widget<InputDecorator>(
          inputDecoratorFinder,
        );
        expect(inputDecorator.decoration.labelText, isNotNull);
        final dialogInputTheme =
            Theme.of(tester.element(fieldFinder)).inputDecorationTheme;
        if (family == AppThemeFamily.neoBrutalism) {
          expect(dialogInputTheme.filled, isTrue);
          expect(dialogInputTheme.fillColor, surfaces.dialogChoice);
        } else {
          expect(dialogInputTheme, theme.inputDecorationTheme);
        }

        final strings = AppLocalizations.of(tester.element(fieldFinder));
        await tester.tap(find.text(strings.commonCancel));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  test('active-workout screen styles have exact measured ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final expectedRules = <(String, String, String, int)>[
      (
        'lib/screens/exercise/session_screen.dart',
        'text_style',
        'session-screen-timer-material-typography',
        1,
      ),
      (
        'lib/screens/exercise/session_screen.dart',
        'color',
        'session-screen-completion-sheet-surface',
        1,
      ),
      (
        'lib/screens/exercise/session_detail_screen.dart',
        'decoration',
        'session-detail-summary-material-and-token-owners',
        3,
      ),
    ];

    for (final (file, kind, id, count) in expectedRules) {
      final rule = inventory.ruleFor(file, kind);
      expect(rule?.id, id);
      expect(rule?.status, 'migrated');
      expect(
        report.findings.where((finding) => finding.ruleId == id),
        hasLength(count),
      );
    }

    final sessionFindings = report.findings.where(
      (finding) =>
          finding.file == 'lib/screens/exercise/session_screen.dart' ||
          finding.file == 'lib/screens/exercise/session_detail_screen.dart',
    );
    expect(sessionFindings, hasLength(5));
    expect(
      sessionFindings.map((finding) => finding.status),
      everyElement('migrated'),
    );

    final sessionSource =
        File('lib/screens/exercise/session_screen.dart').readAsStringSync();
    expect(sessionSource, contains('Theme.of(context).textTheme.bodyMedium'));
    expect(
      sessionSource,
      contains('context.surfaceDecorationTokens.sheet.outlined'),
    );
    final detailSource =
        File(
          'lib/screens/exercise/session_detail_screen.dart',
        ).readAsStringSync();
    expect(detailSource, contains('styleFormControls: true'));
    expect(detailSource, contains('color: surfaces.sessionSummary'));
    expect(detailSource, contains('borderRadius: shapes.metric'));
    expect(detailSource, contains('color: surfaces.panelRaised'));
    expect(detailSource, contains('shape: BoxShape.circle'));
  });
}

class _SessionDetailRepository extends AppRepository {
  @override
  Future<List<Map<String, dynamic>>> fetchExercises(int sessionId) async => [
    <String, dynamic>{'id': 8, 'type': 'weight', 'exercise_def_id': 12},
  ];

  @override
  Future<Map<int, WorkoutExerciseRecordBadges>> fetchSessionRecordBadges(
    int sessionId,
  ) async => const <int, WorkoutExerciseRecordBadges>{};

  @override
  Future<Map<String, String?>> fetchDefinitionInfo(int definitionId) async =>
      const <String, String?>{'name': 'Squat', 'equipmentName': 'Barbell'};

  @override
  Future<ExerciseDefinition?> fetchDefinitionById(int definitionId) async =>
      null;

  @override
  Future<List<Map<String, dynamic>>> fetchSets(int exerciseId) async => [
    <String, dynamic>{
      'id': 20,
      'parent_set_id': null,
      'weight': 100.0,
      'reps': 5,
    },
  ];

  @override
  Future<Map<BodyPart, double>> computeBodyPartPercents(
    int definitionId,
  ) async => const <BodyPart, double>{};
}
