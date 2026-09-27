import 'dart:async';
import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/exercise_analytics_screen.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../tools/theme_style_inventory.dart';

void main() {
  test('Exercise Analytics has exact theme-owned style coverage', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'exercise-analytics-theme-recipes',
    );

    expect(
      rule.pattern,
      'lib/screens/profile/settings/exercise_analytics_screen.dart',
    );
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(
      rule.kinds,
      unorderedEquals(['color', 'color_transform', 'decoration', 'geometry']),
    );

    final ownedFindings =
        report.findings.where((finding) => finding.ruleId == rule.id).toList();
    expect(ownedFindings, hasLength(25));
    expect(ownedFindings.map((finding) => finding.kind).toSet(), {
      'color',
      'color_transform',
      'decoration',
      'geometry',
    });
    expect(
      ownedFindings.map((finding) => finding.status),
      everyElement('migrated'),
    );
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
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode Exercise Analytics resolves its theme recipes', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(430, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final bodyPart = BodyPart(4, 'Chest');
        final muscle = Muscle(id: 7, name: 'Pectoralis major');
        final definition = ExerciseDefinition(
          id: 11,
          name: 'Cable Chest Press',
          bodyParts: [bodyPart],
          muscles: [RankedMuscle(muscle: muscle, rank: 1)],
          useManualBodyparts: false,
          multiplyByRating: false,
        );
        final repository = _ExerciseAnalyticsRepository(
          definition: definition,
          bodyPart: bodyPart,
          muscle: muscle,
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [Provider<AppRepository>.value(value: repository)],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const ExerciseAnalyticsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pageContext = tester.element(
          find.byType(ExerciseAnalyticsScreen),
        );
        final strings = AppLocalizations.of(pageContext);
        final scheme = theme.colorScheme;
        final shapes = theme.shapeTokens;
        final surfaces = theme.surfaceTokens;
        final neo = family == AppThemeFamily.neoBrutalism;
        final panelSurface =
            neo
                ? surfaces.settingsSection
                : scheme.surfaceContainerHighest.withValues(alpha: 0.34);
        final panelForeground =
            neo
                ? tonosForegroundForSurface(pageContext, panelSurface)
                : scheme.onSurface;
        final panelSecondary =
            neo
                ? tonosSecondaryForegroundForSurface(pageContext, panelSurface)
                : scheme.onSurfaceVariant;

        expect(find.text(definition.name), findsOneWidget);
        expect(find.text(muscle.name), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);

        final picker = _containerWithPadding(
          tester,
          const EdgeInsets.fromLTRB(16, 12, 12, 12),
        );
        final pickerDecoration = picker.decoration! as BoxDecoration;
        expect(pickerDecoration.color, panelSurface, reason: mode);
        expect(pickerDecoration.borderRadius, shapes.settingsPicker);
        expect(
          pickerDecoration.border,
          Border.all(
            color:
                neo
                    ? tonosOutlineForSurface(pageContext, panelSurface)
                    : SettingsAccent.advanced.withValues(alpha: 0.42),
            width: shapes.outlineWidth,
          ),
          reason: mode,
        );

        final tabBar = tester.widget<TabBar>(find.byType(TabBar));
        final tabBarContainerFinder =
            find
                .ancestor(
                  of: find.byType(TabBar),
                  matching: find.byType(Container),
                )
                .first;
        final tabBarContainer = tester.widget<Container>(tabBarContainerFinder);
        final tabDecoration = tabBarContainer.decoration! as BoxDecoration;
        expect(tabDecoration.color, panelSurface, reason: mode);
        expect(tabDecoration.borderRadius, shapes.profileTile);
        expect(tabBar.dividerColor, Colors.transparent);
        expect(
          tabBar.labelColor,
          neo ? panelForeground : SettingsAccent.advanced,
          reason: mode,
        );
        expect(tabBar.unselectedLabelColor, panelSecondary, reason: mode);
        final tabIndicator = tabBar.indicator! as BoxDecoration;
        expect(
          tabIndicator.color,
          neo
              ? surfaces.dialogChoice
              : SettingsAccent.advanced.withValues(alpha: 0.24),
          reason: mode,
        );
        expect(tabIndicator.borderRadius, shapes.settingsTabIndicator);

        final muscleCard = _containerWithPadding(
          tester,
          const EdgeInsets.fromLTRB(14, 12, 10, 12),
        );
        final muscleDecoration = muscleCard.decoration! as BoxDecoration;
        expect(muscleDecoration.color, panelSurface, reason: mode);
        expect(muscleDecoration.borderRadius, shapes.profileTile);
        expect(
          muscleDecoration.border,
          Border.all(
            color:
                neo
                    ? tonosOutlineForSurface(pageContext, panelSurface)
                    : scheme.outlineVariant.withValues(alpha: 0.56),
            width: neo ? shapes.outlineWidth : 1,
          ),
          reason: mode,
        );
        final muscleField = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TextFormField),
            matching: find.byType(TextField),
          ),
        );
        expect(muscleField.style, settingsInputTextStyle(pageContext));
        expect(muscleField.decoration?.labelText, strings.allocationCredit);
        expect(muscleField.decoration?.isDense, isTrue);

        final muscleIconTileFinder = _containerFinderWithColor(
          tester,
          SettingsAccent.advanced.withValues(alpha: 0.14),
          const Size(38, 38),
        );
        final muscleIconTile = tester.widget<Container>(muscleIconTileFinder);
        expect(tester.getSize(muscleIconTileFinder), const Size(38, 38));
        expect(
          (muscleIconTile.decoration! as BoxDecoration).borderRadius,
          shapes.control,
        );
        expect(
          tester
              .widget<Icon>(
                find.descendant(
                  of: find.byWidgetPredicate(
                    (widget) =>
                        widget is Container &&
                        widget.padding ==
                            const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  ),
                  matching: find.byIcon(Icons.fitness_center),
                ),
              )
              .color,
          SettingsAccent.advanced,
        );

        final muscleForm = tester.widget<TextFormField>(
          find.byType(TextFormField),
        );
        muscleForm.onChanged?.call('1.25');
        await tester.pumpAndSettle();
        final saveAction = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(saveAction.backgroundColor, SettingsAccent.advanced);
        expect(
          saveAction.foregroundColor,
          neo
              ? tonosForegroundForSurface(pageContext, SettingsAccent.advanced)
              : Colors.white,
          reason: mode,
        );

        tester.testTextInput.hide();
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.allocationBodypartCredit).first);
        await tester.pumpAndSettle();

        expect(find.text(bodyPart.name), findsOneWidget);
        final bodyPartCard = _containerWithPadding(
          tester,
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        );
        final bodyPartDecoration = bodyPartCard.decoration! as BoxDecoration;
        expect(bodyPartDecoration.color, panelSurface, reason: mode);
        expect(bodyPartDecoration.borderRadius, shapes.profileTile);
        expect(
          bodyPartDecoration.border,
          Border.all(
            color:
                neo
                    ? tonosOutlineForSurface(pageContext, panelSurface)
                    : SettingsAccent.training.withValues(alpha: 0.48),
            width: neo ? shapes.outlineWidth : 1,
          ),
          reason: mode,
        );
        final bodyPartIconTileFinder = _containerFinderWithColor(
          tester,
          SettingsAccent.training.withValues(alpha: 0.14),
          const Size(38, 38),
        );
        final bodyPartIconTile = tester.widget<Container>(
          bodyPartIconTileFinder,
        );
        expect(tester.getSize(bodyPartIconTileFinder), const Size(38, 38));
        expect(
          (bodyPartIconTile.decoration! as BoxDecoration).borderRadius,
          shapes.control,
        );
        expect(
          tester.widget<Icon>(find.byIcon(Icons.accessibility_new)).color,
          SettingsAccent.training,
        );
        expect(tester.takeException(), isNull, reason: mode);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  testWidgets('definition load failure can recover in all theme modes', (
    tester,
  ) async {
    for (final family in AppThemeFamily.values) {
      for (final brightness in Brightness.values) {
        final theme =
            brightness == Brightness.light
                ? AppThemeFactory.light(family)
                : AppThemeFactory.dark(family);
        final bodyPart = BodyPart(4, 'Chest');
        final muscle = Muscle(id: 7, name: 'Pectoralis major');
        final definition = ExerciseDefinition(
          id: 11,
          name: 'Cable Chest Press',
          bodyParts: [bodyPart],
          muscles: [RankedMuscle(muscle: muscle, rank: 1)],
          useManualBodyparts: false,
          multiplyByRating: false,
        );
        final repository = _ExerciseAnalyticsRepository(
          definition: definition,
          bodyPart: bodyPart,
          muscle: muscle,
          failFirstDefinitionLoad: true,
        );
        final mode = '${family.code} ${brightness.name}';

        await tester.pumpWidget(
          MultiProvider(
            providers: [Provider<AppRepository>.value(value: repository)],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const ExerciseAnalyticsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final strings = AppLocalizations.of(
          tester.element(find.byType(ExerciseAnalyticsScreen)),
        );
        expect(find.byIcon(Icons.error_outline), findsOneWidget, reason: mode);
        expect(find.text(strings.commonRetry), findsOneWidget, reason: mode);
        expect(
          find.textContaining('private query details'),
          findsNothing,
          reason: mode,
        );

        await tester.tap(find.text(strings.commonRetry));
        await tester.pumpAndSettle();

        expect(find.text(definition.name), findsOneWidget, reason: mode);
        expect(repository.definitionLoadCount, 2, reason: mode);
        expect(tester.takeException(), isNull, reason: mode);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });

  testWidgets('allocation loading resolves cleanly in all theme modes', (
    tester,
  ) async {
    for (final family in AppThemeFamily.values) {
      for (final brightness in Brightness.values) {
        final theme =
            brightness == Brightness.light
                ? AppThemeFactory.light(family)
                : AppThemeFactory.dark(family);
        final bodyPart = BodyPart(4, 'Chest');
        final muscle = Muscle(id: 7, name: 'Pectoralis major');
        final definition = ExerciseDefinition(
          id: 11,
          name: 'Cable Chest Press',
          bodyParts: [bodyPart],
          muscles: [RankedMuscle(muscle: muscle, rank: 1)],
          useManualBodyparts: false,
          multiplyByRating: false,
        );
        final allocationGate = Completer<ResolvedExerciseAllocation>();
        final repository = _ExerciseAnalyticsRepository(
          definition: definition,
          bodyPart: bodyPart,
          muscle: muscle,
          allocationGate: allocationGate,
        );
        final mode = '${family.code} ${brightness.name}';

        await tester.pumpWidget(
          MultiProvider(
            providers: [Provider<AppRepository>.value(value: repository)],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const ExerciseAnalyticsScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
          reason: mode,
        );
        allocationGate.complete(repository.allocation);
        await tester.pumpAndSettle();

        expect(find.text(definition.name), findsOneWidget, reason: mode);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(tester.takeException(), isNull, reason: mode);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });

  testWidgets('allocation save validates, retries, and clears dirty state', (
    tester,
  ) async {
    for (final family in AppThemeFamily.values) {
      for (final brightness in Brightness.values) {
        final theme =
            brightness == Brightness.light
                ? AppThemeFactory.light(family)
                : AppThemeFactory.dark(family);
        final bodyPart = BodyPart(4, 'Chest');
        final muscle = Muscle(id: 7, name: 'Pectoralis major');
        final definition = ExerciseDefinition(
          id: 11,
          name: 'Cable Chest Press',
          bodyParts: [bodyPart],
          muscles: [RankedMuscle(muscle: muscle, rank: 1)],
          useManualBodyparts: false,
          multiplyByRating: false,
        );
        final repository = _ExerciseAnalyticsRepository(
          definition: definition,
          bodyPart: bodyPart,
          muscle: muscle,
          failAllocationSave: true,
        );
        final mode = '${family.code} ${brightness.name}';

        await tester.pumpWidget(
          MultiProvider(
            providers: [Provider<AppRepository>.value(value: repository)],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const ExerciseAnalyticsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final pageContext = tester.element(
          find.byType(ExerciseAnalyticsScreen),
        );
        final strings = AppLocalizations.of(pageContext);
        final creditField = find.byType(TextFormField);

        await tester.enterText(creditField, '-1');
        tester.testTextInput.hide();
        await tester.pumpAndSettle();
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(
          find.text(strings.allocationInvalidCredit),
          findsOneWidget,
          reason: mode,
        );
        expect(repository.allocationSaveCalls, 0, reason: mode);

        ScaffoldMessenger.of(pageContext).hideCurrentSnackBar();
        await tester.pumpAndSettle();
        await tester.enterText(creditField, '2.5');
        tester.testTextInput.hide();
        await tester.pumpAndSettle();
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(
          find.text(strings.allocationSaveFailed),
          findsOneWidget,
          reason: mode,
        );
        expect(find.byType(FloatingActionButton), findsOneWidget, reason: mode);
        expect(repository.allocationSaveCalls, 1, reason: mode);

        ScaffoldMessenger.of(pageContext).hideCurrentSnackBar();
        await tester.pumpAndSettle();
        repository.failAllocationSave = false;
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(repository.allocationSaveCalls, 2, reason: mode);
        expect(find.byType(FloatingActionButton), findsNothing, reason: mode);
        expect(
          find.text(strings.allocationSaved),
          findsOneWidget,
          reason: mode,
        );
        expect(tester.takeException(), isNull, reason: mode);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });
}

Container _containerWithPadding(WidgetTester tester, EdgeInsets padding) {
  final finder = find.byWidgetPredicate(
    (widget) =>
        widget is Container &&
        widget.padding == padding &&
        widget.decoration is BoxDecoration,
  );
  expect(finder, findsOneWidget);
  return tester.widget<Container>(finder);
}

Finder _containerFinderWithColor(WidgetTester tester, Color color, Size size) {
  final finder = find.byWidgetPredicate((widget) {
    if (widget is! Container ||
        widget.decoration is! BoxDecoration ||
        widget.constraints != BoxConstraints.tight(size)) {
      return false;
    }
    return (widget.decoration! as BoxDecoration).color == color;
  });
  expect(finder, findsOneWidget);
  return finder;
}

class _ExerciseAnalyticsRepository extends AppRepository {
  _ExerciseAnalyticsRepository({
    required this.definition,
    required this.bodyPart,
    required this.muscle,
    this.failFirstDefinitionLoad = false,
    this.allocationGate,
    this.failAllocationSave = false,
  });

  final ExerciseDefinition definition;
  final BodyPart bodyPart;
  final Muscle muscle;
  final bool failFirstDefinitionLoad;
  final Completer<ResolvedExerciseAllocation>? allocationGate;
  bool failAllocationSave;
  var definitionLoadCount = 0;
  var allocationSaveCalls = 0;

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async {
    definitionLoadCount++;
    if (failFirstDefinitionLoad && definitionLoadCount == 1) {
      throw StateError('private query details');
    }
    return [definition];
  }

  @override
  Future<ResolvedExerciseAllocation> resolveExerciseAllocation(int defId) =>
      allocationGate?.future ?? Future.value(_allocationFor(defId));

  ResolvedExerciseAllocation get allocation => _allocationFor(definition.id);

  ResolvedExerciseAllocation _allocationFor(int defId) =>
      ResolvedExerciseAllocation(
        exerciseDefinitionId: defId,
        muscleCredits: {muscle.id: 1.25},
        bodyPartCredits: {bodyPart.id: 1.25},
        derivedBodyPartCredits: {bodyPart.id: 1.25},
        muscleHistoryCredits: const {},
        bodyPartHistoryCredits: const {},
        muscleSource: ExerciseAllocationSource.automatic,
        bodyPartSource: ExerciseAllocationSource.automatic,
      );

  @override
  Future<void> replacePersonalExerciseAllocationCredits({
    required int defId,
    required ExerciseAllocationDimension dimension,
    required Map<int, double> credits,
  }) async {
    allocationSaveCalls++;
    if (failAllocationSave) {
      throw StateError('private save details');
    }
  }

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => [bodyPart];
}
