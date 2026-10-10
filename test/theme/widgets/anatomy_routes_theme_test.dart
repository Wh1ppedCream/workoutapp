import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/content_repository.dart';
import 'package:env_test/screens/exercise/definitions_by_bodypart_page.dart';
import 'package:env_test/screens/exercise/definitions_by_muscle_page.dart';
import 'package:env_test/screens/exercise/muscle_filter_page.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/utils/localized_body_part_name.dart';
import 'package:env_test/widgets/body_heatmap.dart';
import 'package:env_test/widgets/exercise_detail_sheet.dart';
import 'package:env_test/widgets/exercise_definition_info_tile.dart';
import 'package:env_test/widgets/recommended_sets_editor_dialog.dart';
import 'package:env_test/widgets/shared_entity_media_thumbnail.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../tools/theme_style_inventory.dart';

void main() {
  final themes = <AppThemeFamily, Map<Brightness, ThemeData>>{
    for (final family in AppThemeFamily.values)
      family: {
        Brightness.light: AppThemeFactory.light(family),
        Brightness.dark: AppThemeFactory.dark(family),
      },
  };

  test('anatomy route findings have exact theme and Material owners', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );

    const expectedRules = <String, (int, String, String, List<String>)>{
      'anatomy-bodypart-detail-recipes': (
        7,
        'structural_theme',
        'migrated',
        ['color', 'text_style'],
      ),
      'anatomy-bodypart-expressive-header-shape': (
        2,
        'structural_theme',
        'migrated',
        ['geometry'],
      ),
      'anatomy-bodypart-responsive-metric-bay': (
        6,
        'structural_theme',
        'migrated',
        ['decoration', 'geometry', 'color_transform'],
      ),
      'anatomy-muscle-detail-recipes': (
        4,
        'structural_theme',
        'migrated',
        ['color', 'text_style'],
      ),
      'anatomy-muscle-expressive-header-shape': (
        2,
        'structural_theme',
        'migrated',
        ['geometry'],
      ),
      'anatomy-muscle-responsive-metric-bay': (
        6,
        'structural_theme',
        'migrated',
        ['decoration', 'geometry', 'color_transform'],
      ),
      'anatomy-filter-material-search': (
        1,
        'material_component',
        'migrated',
        ['decoration'],
      ),
      'anatomy-filter-expressive-surfaces': (
        6,
        'structural_theme',
        'migrated',
        ['decoration', 'geometry'],
      ),
      'anatomy-filter-expressive-search-recipe': (
        7,
        'structural_theme',
        'migrated',
        ['text_style', 'geometry'],
      ),
      'anatomy-filter-expressive-row-shape': (
        3,
        'structural_theme',
        'migrated',
        ['geometry'],
      ),
      'anatomy-filter-fallback-artwork': (
        7,
        'intentional_one_off',
        'allowlisted',
        ['color', 'geometry'],
      ),
    };

    for (final entry in expectedRules.entries) {
      final rule = inventory.pathRules.singleWhere(
        (rule) => rule.id == entry.key,
      );
      expect(rule.classification, entry.value.$2, reason: entry.key);
      expect(rule.status, entry.value.$3, reason: entry.key);
      expect(rule.kinds, unorderedEquals(entry.value.$4), reason: entry.key);
      final owned = report.findings.where(
        (finding) => finding.ruleId == rule.id,
      );
      expect(owned, hasLength(entry.value.$1), reason: entry.key);
      expect(
        owned.map((finding) => finding.status),
        everyElement(entry.value.$3),
        reason: entry.key,
      );
    }

    for (final path in const [
      'lib/screens/exercise/definitions_by_bodypart_page.dart',
      'lib/screens/exercise/definitions_by_muscle_page.dart',
      'lib/screens/exercise/muscle_filter_page.dart',
    ]) {
      expect(
        report.findings.where(
          (finding) => finding.file == path && finding.status == 'pending',
        ),
        isEmpty,
        reason: '$path should have no pending anatomy-route candidates.',
      );
    }
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'Catalog anatomy route scopes its palette in ${brightness.name} mode',
      (tester) async {
        await _prepareAnatomyTest(tester);
        final bodyPart = BodyPart(1, 'Chest');
        final muscle = Muscle(id: 2, name: 'Pectoralis major');
        final repository = _AnatomyRepository(
          bodyParts: [bodyPart],
          muscles: [muscle],
          definitions: [
            _definition(
              id: 1,
              name: 'Long Cable Chest Press Variation',
              bodyPart: bodyPart,
              muscle: muscle,
              equipment: Equipment(1, 'Cable Machine'),
            ),
          ],
          bodyPartLinks: [
            MuscleBodyPart(muscleId: muscle.id, bodyPartId: bodyPart.id),
          ],
        );
        final theme = brightness == Brightness.dark
            ? ExpressiveThemeDefinition.dark()
            : ExpressiveThemeDefinition.light();

        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: repository,
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const MuscleFilterPage(expressiveCatalogPresentation: true),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final filterContext = tester.element(find.byType(Scaffold).first);
        final tokens = Theme.of(filterContext)
            .extension<AppExpressiveDestinationTokens>()!;
        expect(tokens.family, AppExpressiveDestinationFamily.catalog);
        expect(
          tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
          tokens.pageCanvas,
        );

        await tester.tap(find.text('Chest'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final detailContext = tester.element(find.byType(Scaffold).last);
        expect(
          Theme.of(detailContext)
              .extension<AppExpressiveDestinationTokens>()
              ?.family,
          AppExpressiveDestinationFamily.catalog,
        );
        expect(
          tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor,
          tokens.pageCanvas,
        );
        final exerciseTile = tester.widget<ExerciseDefinitionInfoTile>(
          find.byType(ExerciseDefinitionInfoTile),
        );
        expect(exerciseTile.expressiveCatalogPresentation, isTrue);

        await tester.tap(find.text(muscle.name).first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
        expect(find.byType(DefinitionsByMusclePage), findsOneWidget);
        final muscleContext = tester.element(find.byType(Scaffold).last);
        expect(
          Theme.of(muscleContext)
              .extension<AppExpressiveDestinationTokens>()
              ?.family,
          AppExpressiveDestinationFamily.catalog,
        );
        expect(
          tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor,
          tokens.pageCanvas,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final family in [AppThemeFamily.classic, AppThemeFamily.neoBrutalism]) {
    testWidgets(
      '${family.code} keeps Catalog anatomy fallback when opt-in is set',
      (tester) async {
        await _prepareAnatomyTest(tester);
        final repository = _AnatomyRepository(
          bodyParts: [BodyPart(1, 'Chest')],
          muscles: const [],
          definitions: const [],
        );

        await _pumpRoute(
          tester,
          AppThemeFactory.light(family),
          repository,
          const MuscleFilterPage(expressiveCatalogPresentation: true),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, isNull);
        expect(
          Theme.of(tester.element(find.byType(MuscleFilterPage)))
              .extension<AppExpressiveDestinationTokens>(),
          isNull,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive anatomy selector owns tabs, search, and identity media in ${brightness.name}',
      (tester) async {
        await _prepareAnatomyTest(tester);
        final chest = BodyPart(1, 'Chest');
        final legs = BodyPart(2, 'Legs');
        final pectorals = Muscle(id: 1, name: 'Pectorals');
        final quadriceps = Muscle(id: 2, name: 'Quadriceps');
        final repository = _AnatomyRepository(
          bodyParts: [chest, legs],
          muscles: [pectorals, quadriceps],
          definitions: [
            _definition(
              id: 1,
              name: 'Press',
              bodyPart: chest,
              muscle: pectorals,
            ),
            _definition(
              id: 2,
              name: 'Squat',
              bodyPart: legs,
              muscle: quadriceps,
            ),
          ],
        );
        final theme = brightness == Brightness.dark
            ? ExpressiveThemeDefinition.dark()
            : ExpressiveThemeDefinition.light();

        await _pumpRoute(
          tester,
          theme,
          repository,
          const MuscleFilterPage(
            initialTabIndex: 1,
            expressiveCatalogPresentation: true,
          ),
        );

        final pageContext = tester.element(find.byType(MuscleFilterPage));
        final strings = AppLocalizations.of(pageContext);
        final filterContext = tester.element(find.byType(Scaffold).first);
        final tokens = Theme.of(filterContext)
            .extension<AppExpressiveDestinationTokens>()!;
        final tabBar = tester.widget<TabBar>(find.byType(TabBar));
        expect(tabBar.indicator, isA<BoxDecoration>());
        expect(
          (tabBar.indicator! as BoxDecoration).color,
          tokens.actionPrimary,
        );
        expect(tabBar.labelColor, tokens.onActionPrimary);
        expect(tabBar.unselectedLabelColor, tokens.onSurfaceAccent);
        expect(
          DefaultTabController.of(tester.element(find.byType(TabBar))).index,
          1,
        );

        final muscleRow = find
            .ancestor(
              of: find.text(pectorals.name),
              matching: find.byType(ListTile),
            )
            .first;
        expect(
          tester.widget<ListTile>(muscleRow).tileColor,
          tokens.surfaceTertiary,
        );
        final muscleMedia = tester.widget<SharedEntityMediaThumbnail>(
          find.descendant(
            of: muscleRow,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is SharedEntityMediaThumbnail &&
                  widget.entityType == SharedMediaEntityType.muscle &&
                  widget.entityId == pectorals.id,
            ),
          ),
        );
        expect(muscleMedia.size, 50);
        expect(muscleMedia.padding, const EdgeInsets.all(4));
        expect(muscleMedia.borderRadius, BorderRadius.circular(15));
        expect(muscleMedia.backgroundColor, tokens.actionPrimary);
        expect(muscleMedia.borderColor, tokens.outlineAccent);
        expect(find.text(strings.anatomyBodyParts), findsOneWidget);
        expect(find.text(strings.anatomyMuscles), findsOneWidget);

        final search = find.byType(TextField);
        expect(
          tester.widget<TextField>(search).decoration?.labelText,
          strings.anatomySearchLabel,
        );
        await tester.enterText(search, 'pect');
        await tester.pumpAndSettle();
        expect(find.text(pectorals.name), findsOneWidget);
        expect(find.text(quadriceps.name), findsNothing);

        await tester.tap(find.text(strings.anatomyBodyParts));
        await tester.pumpAndSettle();
        expect(
          DefaultTabController.of(tester.element(find.byType(TabBar))).index,
          0,
        );
        await tester.enterText(search, '');
        await tester.pumpAndSettle();
        expect(find.text('Chest'), findsOneWidget);
        expect(find.text('Legs'), findsOneWidget);
        final bodyPartRow = find
            .ancestor(
              of: find.text(chest.name),
              matching: find.byType(ListTile),
            )
            .first;
        expect(
          tester.widget<ListTile>(bodyPartRow).tileColor,
          tokens.surfaceTertiary,
        );
        final bodyPartMedia = tester.widget<SharedEntityMediaThumbnail>(
          find.descendant(
            of: bodyPartRow,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is SharedEntityMediaThumbnail &&
                  widget.entityType == SharedMediaEntityType.bodypart &&
                  widget.entityId == chest.id,
            ),
          ),
        );
        expect(bodyPartMedia.size, 54);
        expect(bodyPartMedia.padding, EdgeInsets.zero);
        expect(
          bodyPartMedia.borderRadius,
          const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(6),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
          ),
        );
        expect(find.byType(SingleBodyPartHeatmap), findsWidgets);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Expressive anatomy details show values, navigate associations, edit recommendations, and open exercise info',
    (tester) async {
      await _prepareAnatomyTest(tester);
      final bodyPart = BodyPart(1, 'Chest');
      final muscle = Muscle(id: 2, name: 'Pectoralis major');
      final definition = _definition(
        id: 1,
        name: 'Cable Press',
        bodyPart: bodyPart,
        muscle: muscle,
        equipment: Equipment(1, 'Long Cable Station'),
      );
      final bounds = VolumeBoundaries(
        id: bodyPart.id,
        maintenance: 4,
        minEffective: 6,
        maxAdaptive: 14,
        maxRecoverable: 18,
      );
      final repository = _AnatomyRepository(
        bodyParts: [bodyPart],
        muscles: [muscle],
        definitions: [definition],
        bodyPartLinks: [
          MuscleBodyPart(muscleId: muscle.id, bodyPartId: bodyPart.id),
        ],
        muscleLinks: [
          MuscleBodyPart(muscleId: muscle.id, bodyPartId: bodyPart.id),
        ],
        bodyPartSetUnits: {bodyPart.id: 8.5},
        muscleSetUnits: {muscle.id: 5.5},
        bodyPartBounds: bounds,
      );

      await _pumpRoute(
        tester,
        ExpressiveThemeDefinition.light(),
        repository,
        DefinitionsByBodyPartPage(
          bodyPart: bodyPart,
          expressiveCatalogPresentation: true,
        ),
      );

      final bodyContext = tester.element(
        find.byType(DefinitionsByBodyPartPage),
      );
      final strings = AppLocalizations.of(bodyContext);
      expect(find.text(strings.anatomySetUnits('8.5')), findsOneWidget);
      expect(find.text(strings.anatomySetRange('6', '18')), findsOneWidget);
      expect(find.widgetWithText(ActionChip, muscle.name), findsOneWidget);

      await tester.tap(find.byType(RecommendedSetsEditButton).first);
      await tester.pumpAndSettle();
      expect(find.text(strings.recommendedSetsTitle), findsOneWidget);
      await tester.tap(find.text(strings.commonCancel));
      await tester.pumpAndSettle();

      final detailInfoButton = find.widgetWithIcon(
        IconButton,
        Icons.info_outline,
      );
      expect(detailInfoButton, findsOneWidget);
      await tester.tap(detailInfoButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseDetailSheet), findsOneWidget);
      expect(
        tester
            .widget<ExerciseDetailSheet>(find.byType(ExerciseDetailSheet))
            .expressiveCatalogPresentation,
        isTrue,
      );
      Navigator.of(tester.element(find.byType(ExerciseDetailSheet))).pop();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Bodypart and muscle association chips navigate both ways', (
    tester,
  ) async {
    await _prepareAnatomyTest(tester);
    final bodyPart = BodyPart(1, 'Chest');
    final muscle = Muscle(id: 2, name: 'Pectoralis major');
    final repository = _AnatomyRepository(
      bodyParts: [bodyPart],
      muscles: [muscle],
      definitions: [
        _definition(
          id: 1,
          name: 'Cable Press',
          bodyPart: bodyPart,
          muscle: muscle,
        ),
      ],
      bodyPartLinks: [
        MuscleBodyPart(muscleId: muscle.id, bodyPartId: bodyPart.id),
      ],
      muscleLinks: [
        MuscleBodyPart(muscleId: muscle.id, bodyPartId: bodyPart.id),
      ],
      muscleSetUnits: {muscle.id: 5.5},
      muscleBounds: VolumeBoundaries(
        id: muscle.id,
        maintenance: 5,
        minEffective: 7,
        maxAdaptive: 13,
        maxRecoverable: 15,
      ),
    );
    await _pumpRoute(
      tester,
      ExpressiveThemeDefinition.light(),
      repository,
      DefinitionsByBodyPartPage(
        bodyPart: bodyPart,
        expressiveCatalogPresentation: true,
      ),
    );

    await tester.tap(find.widgetWithText(ActionChip, muscle.name));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    final musclePage = tester.widget<DefinitionsByMusclePage>(
      find.byType(DefinitionsByMusclePage),
    );
    expect(musclePage.expressiveCatalogPresentation, isTrue);
    expect(musclePage.sourceBodyPart, bodyPart);
    final muscleStrings = AppLocalizations.of(
      tester.element(find.byType(DefinitionsByMusclePage)),
    );
    expect(find.text(muscleStrings.anatomySetUnits('5.5')), findsOneWidget);
    expect(find.text(muscleStrings.anatomySetRange('7', '15')), findsOneWidget);
    expect(find.byType(ActionChip), findsOneWidget);
    await tester.tap(find.widgetWithText(ActionChip, 'Chest'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.byType(DefinitionsByBodyPartPage), findsOneWidget);
    expect(find.byType(DefinitionsByMusclePage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final familyEntry in themes.entries) {
    for (final modeEntry in familyEntry.value.entries) {
      final family = familyEntry.key;
      final brightness = modeEntry.key;
      final theme = modeEntry.value;
      final mode = '${family.code} ${brightness.name}';
      final positiveInk = family == AppThemeFamily.neoBrutalism
          ? theme.semanticColors.positive
          : Colors.green.shade600;

      testWidgets('$mode body-part details keep owned metadata colors', (
        tester,
      ) async {
        await _prepareAnatomyTest(tester);
        final bodyPart = BodyPart(1, 'Chest');
        final muscle = Muscle(id: 2, name: 'Pectoralis major');
        final repository = _AnatomyRepository(
          bodyParts: [bodyPart],
          muscles: [muscle],
          definitions: [
            _definition(id: 1, name: 'Cable Press', bodyPart: bodyPart),
            _definition(
              id: 2,
              name: 'Machine Press',
              bodyPart: bodyPart,
              muscle: muscle,
              equipment: Equipment(1, 'Machine'),
            ),
          ],
          bodyPartLinks: [MuscleBodyPart(muscleId: muscle.id, bodyPartId: 1)],
        );

        await _pumpRoute(
          tester,
          theme,
          repository,
          DefinitionsByBodyPartPage(bodyPart: bodyPart),
        );

        final pageContext = tester.element(
          find.byType(DefinitionsByBodyPartPage),
        );
        final strings = AppLocalizations.of(pageContext);
        expect(
          tester
              .widget<SingleBodyPartHeatmap>(find.byType(SingleBodyPartHeatmap))
              .backgroundColor,
          Colors.transparent,
        );
        await _expectTextColor(
          tester,
          strings.anatomyNoEquipment,
          theme.colorScheme.primary,
        );
        await _expectTextColor(tester, 'Machine', theme.colorScheme.primary);
        await _expectTextColor(
          tester,
          strings.anatomyNoMusclesListed,
          positiveInk,
        );
        await _expectLastTextColor(tester, muscle.name, positiveInk);
        expect(tester.takeException(), isNull);
      });

      testWidgets('$mode muscle details keep owned metadata colors', (
        tester,
      ) async {
        await _prepareAnatomyTest(tester);
        final bodyPart = BodyPart(1, 'Chest');
        final muscle = Muscle(id: 2, name: 'Pectoralis major');
        final repository = _AnatomyRepository(
          bodyParts: [bodyPart],
          muscles: [muscle],
          definitions: [
            _definition(
              id: 1,
              name: 'Cable Press',
              bodyPart: bodyPart,
              muscle: muscle,
            ),
            _definition(
              id: 2,
              name: 'Machine Press',
              bodyPart: bodyPart,
              muscle: muscle,
              equipment: Equipment(1, 'Machine'),
            ),
          ],
          muscleLinks: [MuscleBodyPart(muscleId: muscle.id, bodyPartId: 1)],
        );

        await _pumpRoute(
          tester,
          theme,
          repository,
          DefinitionsByMusclePage(muscle: muscle),
        );

        final pageContext = tester.element(
          find.byType(DefinitionsByMusclePage),
        );
        final strings = AppLocalizations.of(pageContext);
        await _expectTextColor(
          tester,
          strings.anatomyNoEquipment,
          theme.colorScheme.primary,
        );
        await _expectTextColor(tester, 'Machine', theme.colorScheme.primary);
        final rankText = strings.anatomyRankForMuscle(
          1,
          localizedBodyPartName(pageContext, bodyPart.name),
        );
        await _expectTextColor(tester, rankText, positiveInk);
        expect(tester.takeException(), isNull);
      });

      testWidgets('$mode anatomy filter keeps Material and artwork ownership', (
        tester,
      ) async {
        await _prepareAnatomyTest(tester);
        final bodyPart = BodyPart(1, 'Chest');
        final muscle = Muscle(id: 2, name: 'Pectoralis major');
        final repository = _AnatomyRepository(
          bodyParts: [bodyPart],
          muscles: [muscle],
          definitions: [
            _definition(
              id: 1,
              name: 'Machine Press',
              bodyPart: bodyPart,
              muscle: muscle,
            ),
          ],
        );

        await _pumpRoute(tester, theme, repository, const MuscleFilterPage());

        final strings = AppLocalizations.of(
          tester.element(find.byType(MuscleFilterPage)),
        );
        final searchField = tester.widget<TextField>(find.byType(TextField));
        expect(searchField.decoration?.labelText, strings.anatomySearchLabel);
        expect(searchField.decoration?.border, isA<OutlineInputBorder>());

        final heatmap = tester.widget<SingleBodyPartHeatmap>(
          find.byType(SingleBodyPartHeatmap),
        );
        expect(heatmap.backgroundColor, Colors.transparent);
        expect(heatmap.borderRadius, BorderRadius.zero);

        await tester.tap(find.text(strings.anatomyMuscles));
        await tester.pumpAndSettle();

        final muscleThumbnail = tester.widget<SharedEntityMediaThumbnail>(
          find.byWidgetPredicate(
            (widget) =>
                widget is SharedEntityMediaThumbnail &&
                widget.entityType == SharedMediaEntityType.muscle,
          ),
        );
        expect(muscleThumbnail.size, 44);
        expect(muscleThumbnail.borderRadius, BorderRadius.circular(22));
        expect(muscleThumbnail.backgroundColor, theme.colorScheme.primary);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Icon &&
                widget.icon == Icons.fitness_center &&
                widget.color == theme.colorScheme.onPrimary,
          ),
          findsOneWidget,
        );
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}

Future<void> _prepareAnatomyTest(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    'guided_tutorial_completed.${TutorialIds.targetAnatomy}': true,
    'guided_tutorial_completed.${TutorialIds.bodypartDetail}': true,
    'guided_tutorial_completed.${TutorialIds.muscleDetail}': true,
    'guided_tutorial_completed.${TutorialIds.exerciseDetail}': true,
  });
  await tester.binding.setSurfaceSize(const Size(430, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> _pumpRoute(
  WidgetTester tester,
  ThemeData theme,
  _AnatomyRepository repository,
  Widget route,
) async {
  final unitPreferences = UnitPreferenceProvider();
  addTearDown(unitPreferences.dispose);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AppRepository>.value(value: repository),
        ChangeNotifierProvider<UnitPreferenceProvider>.value(
          value: unitPreferences,
        ),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        theme: theme,
        themeAnimationDuration: Duration.zero,
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: route,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

Future<void> _expectTextColor(
  WidgetTester tester,
  String value,
  Color expected,
) async {
  final finder = find.text(value);
  await tester.scrollUntilVisible(
    finder.first,
    180,
    scrollable: find.byType(Scrollable).first,
  );
  expect(finder, findsWidgets, reason: value);
  for (final text in tester.widgetList<Text>(finder)) {
    expect(text.style?.color, expected, reason: value);
  }
}

Future<void> _expectLastTextColor(
  WidgetTester tester,
  String value,
  Color expected,
) async {
  final finder = find.text(value);
  await tester.scrollUntilVisible(
    finder.last,
    180,
    scrollable: find.byType(Scrollable).first,
  );
  expect(finder, findsWidgets, reason: value);
  expect(
    tester.widget<Text>(finder.last).style?.color,
    expected,
    reason: value,
  );
}

ExerciseDefinition _definition({
  required int id,
  required String name,
  required BodyPart bodyPart,
  Muscle? muscle,
  Equipment? equipment,
}) => ExerciseDefinition(
  id: id,
  name: name,
  equipmentList: equipment == null ? const [] : [equipment],
  bodyParts: [bodyPart],
  muscles: muscle == null ? const [] : [RankedMuscle(muscle: muscle, rank: 1)],
  useManualBodyparts: false,
  multiplyByRating: false,
);

class _AnatomyRepository extends AppRepository {
  _AnatomyRepository({
    required this.bodyParts,
    required this.muscles,
    required this.definitions,
    this.bodyPartLinks = const [],
    this.muscleLinks = const [],
    this.bodyPartSetUnits = const {},
    this.muscleSetUnits = const {},
    this.bodyPartBounds,
    this.muscleBounds,
  });

  final List<BodyPart> bodyParts;
  final List<Muscle> muscles;
  final List<ExerciseDefinition> definitions;
  final List<MuscleBodyPart> bodyPartLinks;
  final List<MuscleBodyPart> muscleLinks;
  final Map<int, double> bodyPartSetUnits;
  final Map<int, double> muscleSetUnits;
  final VolumeBoundaries? bodyPartBounds;
  final VolumeBoundaries? muscleBounds;

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => bodyParts;

  @override
  Future<List<Muscle>> fetchAllMuscles() async => muscles;

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => definitions;

  @override
  Future<List<MuscleBodyPart>> fetchMusclesForBodyPart(int bodypartId) async =>
      bodyPartLinks;

  @override
  Future<List<MuscleBodyPart>> fetchBodyPartsForMuscle(int muscleId) async =>
      muscleLinks;

  @override
  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async => {
    for (final bodyPart in bodyParts)
      if (bodyPartSetUnits.containsKey(bodyPart.id))
        bodyPart: bodyPartSetUnits[bodyPart.id]!,
  };

  @override
  Future<Map<int, double>> fetchSetsPerMuscle({
    required DateTime start,
    required DateTime end,
  }) async => muscleSetUnits;

  @override
  Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) async =>
      bodyPartBounds;

  @override
  Future<VolumeBoundaries?> fetchMuscleVolumeBounds(int muscleId) async =>
      muscleBounds;

  @override
  Future<Map<int, WorkoutExerciseRecordBadges>>
  fetchCurrentExerciseRecordBadges(int definitionId) async => const {};

  @override
  Future<List<RepMaxRow>> fetchRepMaxes(int defId, String timeframe) async =>
      const [];

  @override
  Future<List<Map<String, dynamic>>> fetchRecentWeightExerciseHistoryRows({
    required int definitionId,
    int? beforeCompletedAtMilliseconds,
    int? beforeExerciseId,
    int limit = 10,
  }) async => const [];

  @override
  Future<ContentManifest> syncBundledExerciseMediaManifest() async =>
      const ContentManifest(namespace: 'exercise_media', version: 0);

  @override
  Future<ExerciseMediaItem?> fetchPrimaryExerciseMedia(int defId) async => null;

  @override
  Future<void> ensureSharedMediaManifestReady() async {}

  @override
  Stream<ContentMediaCacheChange> get mediaCacheChanges =>
      const Stream<ContentMediaCacheChange>.empty();

  @override
  Future<SharedMediaItem?> fetchPrimarySharedMedia(
    SharedMediaEntityType entityType,
    int entityId,
  ) async => null;
}
