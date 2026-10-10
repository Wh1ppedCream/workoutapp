import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/preset_session.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/screens/exercise/preset_detail_screen.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_planning_tokens.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';
import 'package:env_test/theme/widgets/tonos_expressive_workout_shapes.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/add_exercise_fab.dart';
import 'package:env_test/widgets/exercise_card.dart';
import 'package:env_test/widgets/weight_card.dart';
import 'package:env_test/widgets/preset_info_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../tools/theme_style_inventory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('preset plan-name styling has exact route ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'preset-detail-plan-name-field',
    );

    expect(rule.pattern, 'lib/screens/exercise/preset_detail_screen.dart');
    expect(rule.classification, 'structural_theme');
    expect(
      rule.kinds,
      unorderedEquals(<String>['decoration', 'geometry', 'text_style']),
    );
    final findings = report.findings.where((f) => f.ruleId == rule.id).toList();
    expect(findings, hasLength(9));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
    expect(
      report.findings.where(
        (finding) =>
            finding.file == rule.pattern && finding.status == 'pending',
      ),
      isEmpty,
    );
  });

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? AppThemeFactory.light(family)
          : AppThemeFactory.dark(family);

      testWidgets(
        '${family.code} ${brightness.name} resolves the guided plan-name field',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(430, 900));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          SharedPreferences.setMockInitialValues(<String, Object>{});

          final repository = _PresetRepository();
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(value: repository),
                ChangeNotifierProvider(
                  create: (_) => PresetSession(1, repository: repository),
                ),
              ],
              child: MaterialApp(
                theme: theme,
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const PresetDetailScreen(
                  startInEditingMode: true,
                  showOnboardingManualPlanTutorial: true,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final field = tester.widget<TextField>(
            find.byKey(AppTestKeys.planName),
          );
          if (family == AppThemeFamily.classic) {
            final fab = tester.widget<AddExerciseFab>(
              find.byType(AddExerciseFab),
            );
            expect(fab.expressiveWorkoutPresentation, isFalse);
          }
          expect(field.style?.fontSize, 20);
          expect(field.style?.fontWeight, FontWeight.bold);
          final border = field.decoration!.border! as UnderlineInputBorder;
          expect(border.borderSide.color, theme.colorScheme.primary);
          expect(border.borderSide.width, 2);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final brightness in Brightness.values) {
    final theme = brightness == Brightness.light
        ? ExpressiveThemeDefinition.light()
        : ExpressiveThemeDefinition.dark();
    testWidgets(
      'Expressive ${brightness.name} plan detail styling and edit toggle',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues(<String, Object>{});

        final repository = _PresetRepository(withExercise: true);
        final units = UnitPreferenceProvider();
        addTearDown(units.dispose);
        await units.ready;
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
              ChangeNotifierProvider(
                create: (_) => PresetSession(1, repository: repository),
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const PresetDetailScreen(startInEditingMode: true),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pageContext = tester.element(find.byType(PresetDetailScreen));
        final planning = AppExpressivePlanningTokens.maybeOf(pageContext)!;
        final pageScaffold = tester.widget<Scaffold>(
          find.descendant(
            of: find.byType(PresetDetailScreen),
            matching: find.byType(Scaffold),
          ),
        );
        expect(pageScaffold.backgroundColor, planning.pageCanvas);
        expect(
          tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
          planning.planFocalSurface,
        );
        expect(
          tester.widget<AppBar>(find.byType(AppBar)).foregroundColor,
          planning.planFocalForeground,
        );

        final saveButton = tester.widget<ElevatedButton>(
          find.byKey(AppTestKeys.planSave),
        );
        expect(
          saveButton.style?.backgroundColor?.resolve(const <WidgetState>{}),
          planning.actionPrimary,
        );
        expect(
          saveButton.style?.foregroundColor?.resolve(const <WidgetState>{}),
          planning.actionPrimaryForeground,
        );
        final saveAction = find.byKey(AppTestKeys.planSave);
        expect(
          find.ancestor(
            of: saveAction,
            matching: find.byType(TonosExpressivePressResponse),
          ),
          findsOneWidget,
        );
        final addExerciseFab = tester.widget<AddExerciseFab>(
          find.byType(AddExerciseFab),
        );
        expect(addExerciseFab.expressiveWorkoutPresentation, isTrue);
        _expectExpressivePresetExerciseCard(tester, readOnly: false);

        await tester.tap(find.byKey(AppTestKeys.planEdit));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.byKey(AppTestKeys.planSave), findsNothing);
        expect(find.byKey(AppTestKeys.planStartSession), findsOneWidget);
        expect(
          find.byWidgetPredicate((widget) {
            if (widget is! Container || widget.decoration is! BoxDecoration) {
              return false;
            }
            final decoration = widget.decoration! as BoxDecoration;
            return decoration.color == planning.planFocalSurface &&
                decoration.borderRadius == planning.focalShape &&
                decoration.border?.top.color == planning.outline;
          }),
          findsOneWidget,
        );
        expect(
          Theme.of(tester.element(find.byType(PresetInfoCard)))
              .colorScheme
              .surfaceContainerLow,
          planning.planSupportSurface,
        );
        await tester.ensureVisible(find.byType(WeightCard));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        _expectExpressivePresetExerciseCard(tester, readOnly: true);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Preset detail is reachable across layouts', (tester) async {
    const layouts = <({Size size, double scale, double keyboardInset})>[
      (size: Size(320, 900), scale: 2, keyboardInset: 300),
      (size: Size(390, 844), scale: 1, keyboardInset: 0),
      (size: Size(600, 1000), scale: 1.5, keyboardInset: 0),
      (size: Size(800, 390), scale: 1.5, keyboardInset: 0),
      (size: Size(1024, 768), scale: 2, keyboardInset: 0),
    ];
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final layout in layouts) {
      await tester.binding.setSurfaceSize(layout.size);
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.planDetail}': true,
      });
      final repository = _PresetRepository(withExercise: true);
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
            ChangeNotifierProvider(
              create: (_) => PresetSession(1, repository: repository),
            ),
          ],
          child: MaterialApp(
            key: ValueKey('preset-detail-responsive-$layout'),
            theme: ExpressiveThemeDefinition.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(layout.scale),
                viewInsets: EdgeInsets.only(bottom: layout.keyboardInset),
              ),
              child: child!,
            ),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PresetDetailScreen(startInEditingMode: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nameField = find.byKey(AppTestKeys.planName);
      expect(nameField, findsOneWidget, reason: '$layout');
      await tester.ensureVisible(nameField);
      await tester.tap(nameField);
      await tester.enterText(nameField, 'Responsive Plan');
      await tester.pumpAndSettle();

      final save = find.byKey(AppTestKeys.planSave);
      expect(save.hitTestable(), findsOneWidget, reason: '$layout');
      expect(
        tester.getRect(save).bottom,
        lessThanOrEqualTo(layout.size.height - layout.keyboardInset),
        reason: '$layout',
      );
      expect(tester.takeException(), isNull, reason: '$layout');
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}

void _expectExpressivePresetExerciseCard(
  WidgetTester tester, {
  required bool readOnly,
}) {
  final exerciseCard = tester.widget<ExerciseCard>(find.byType(ExerciseCard));
  expect(exerciseCard.expressiveWorkoutPresentation, isTrue);
  expect(exerciseCard.readOnlyMode, readOnly);

  final weightCard = tester.widget<WeightCard>(find.byType(WeightCard));
  expect(weightCard.expressiveWorkoutPresentation, isTrue);
  expect(weightCard.readOnlyMode, readOnly);

  final outerCard = tester.widget<Card>(
    find.descendant(of: find.byType(WeightCard), matching: find.byType(Card)),
  );
  final planning = AppExpressivePlanningTokens.maybeOf(
    tester.element(find.byType(PresetDetailScreen)),
  )!;
  expect(outerCard.color, planning.planSupportSurface);
  expect(
    outerCard.shape,
    RoundedRectangleBorder(
      borderRadius: TonosExpressiveWorkoutShapes.exerciseCard,
    ),
  );

  final header = tester.widget<Container>(
    find.descendant(
      of: find.byType(WeightCard),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).borderRadius ==
                TonosExpressiveWorkoutShapes.exerciseHeader,
      ),
    ),
  );
  expect((header.decoration! as BoxDecoration).color, planning.planAccent);

  final setRow = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(WeightCard),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).borderRadius ==
                    TonosExpressiveWorkoutShapes.setRow,
          ),
        )
        .first,
  );
  expect(
    (setRow.decoration! as BoxDecoration).color,
    planning.configurationSurface,
  );
}

class _PresetRepository extends AppRepository {
  _PresetRepository({this.withExercise = false});

  final bool withExercise;

  @override
  Future<PresetDefinition?> fetchPresetById(int presetId) async =>
      PresetDefinition(
        id: presetId,
        name: 'New Plan',
        createdAt: DateTime.utc(2026, 9, 1),
        profileId: 1,
        isDraft: true,
      );

  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async =>
      withExercise
      ? const <Map<String, dynamic>>[
          {'id': 10, 'type': 'weight', 'exercise_def_id': 20},
        ]
      : const <Map<String, dynamic>>[];

  @override
  Future<Map<String, String?>> fetchDefinitionInfo(int defId) async =>
      const <String, String?>{
        'name': 'Ab Wheel',
        'equipmentName': 'Bodyweight',
      };

  @override
  Future<List<Map<String, dynamic>>> fetchPresetSets(
    int presetExerciseId,
  ) async => withExercise
      ? const <Map<String, dynamic>>[
          {'id': 100, 'parent_set_id': null, 'weight': 20.0, 'reps': 10},
        ]
      : const <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>?> fetchPresetExerciseAuto(
    int presetExerciseId,
  ) async => null;

  @override
  Future<Map<String, dynamic>?> fetchPresetSetAuto(int presetSetId) async =>
      null;

  @override
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async =>
      null;
}
