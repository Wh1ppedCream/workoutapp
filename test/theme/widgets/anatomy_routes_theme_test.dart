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
import 'package:env_test/widgets/exercise_media_thumbnail.dart';
import 'package:env_test/widgets/exercise_definition_info_tile.dart';
import 'package:env_test/widgets/shared_entity_media_thumbnail.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../tools/theme_style_inventory.dart';
import '../theme_inventory_assertions.dart';

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
        6,
        'structural_theme',
        'migrated',
        ['color', 'text_style'],
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
        5,
        'structural_theme',
        'migrated',
        ['color', 'decoration', 'geometry'],
      ),
      'anatomy-filter-expressive-search-recipe': (
        7,
        'structural_theme',
        'migrated',
        ['text_style', 'geometry', 'color_transform'],
      ),
      'anatomy-filter-expressive-row-shape': (
        4,
        'structural_theme',
        'migrated',
        ['geometry', 'color_transform'],
      ),
      'anatomy-filter-fallback-artwork': (
        9,
        'intentional_one_off',
        'allowlisted',
        ['color', 'color_transform', 'geometry'],
      ),
      'anatomy-filter-expressive-empty-search-state': (
        2,
        'structural_theme',
        'migrated',
        ['geometry'],
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
      expectPendingStyleBacklog(report, file: path);
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
        expect(exerciseTile.expressiveCatalogPresentation, isFalse);
        expect(
          exerciseTile.expressiveDestinationFamily,
          AppExpressiveDestinationFamily.catalog,
        );

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

  for (final brightness in Brightness.values) {
    for (final sample in [
      (width: 430.0, scale: 1.0),
      (width: 320.0, scale: 2.0),
    ]) {
      testWidgets(
        'Bodypart exercise previews keep complete ranked summaries at '
        '${sample.width} dp, ${sample.scale}x in ${brightness.name}',
        (tester) async {
          await _prepareAnatomyTest(tester);
          await tester.binding.setSurfaceSize(Size(sample.width, 1000));
          final chest = BodyPart(1, 'Chest');
          final muscles = [
            Muscle(id: 1, name: 'Anterior Deltoid'),
            Muscle(id: 2, name: 'Pectoralis Major'),
            Muscle(id: 3, name: 'Coracobrachialis'),
            Muscle(id: 4, name: 'Triceps Brachii'),
          ];
          final definition = ExerciseDefinition(
            id: 1,
            name:
                'Bench Press - Barbell with a Deliberately Long Variation Name',
            bodyParts: [chest],
            equipmentList: [
              Equipment(1, 'Barbell'),
              Equipment(2, 'Adjustable Bench'),
              Equipment(3, 'Weight Plates'),
            ],
            muscles: [
              for (var index = 0; index < muscles.length; index++)
                RankedMuscle(muscle: muscles[index], rank: [3, 1, 4, 2][index]),
            ],
            useManualBodyparts: false,
            multiplyByRating: false,
          );
          final repository = _AnatomyRepository(
            bodyParts: [chest],
            muscles: muscles,
            definitions: [definition],
          );
          await _pumpRoute(
            tester,
            brightness == Brightness.dark
                ? ExpressiveThemeDefinition.dark()
                : ExpressiveThemeDefinition.light(),
            repository,
            Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(sample.scale)),
                child: DefinitionsByBodyPartPage(
                  bodyPart: chest,
                  expressiveCatalogPresentation: true,
                ),
              ),
            ),
          );
          await tester.scrollUntilVisible(
            find.byType(ExerciseDefinitionInfoTile),
            180,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();

          const equipmentSummary = 'Barbell · Adjustable Bench  +1 more';
          const muscleSummary =
              'Pectoralis Major · Triceps Brachii · Anterior Deltoid  +1 more';
          for (final label in [
            definition.name,
            equipmentSummary,
            muscleSummary,
          ]) {
            final text = tester.widget<Text>(find.text(label));
            final isTitle = label == definition.name;
            expect(text.maxLines, isTitle ? isNull : 1);
            expect(text.overflow, isTitle ? isNull : TextOverflow.ellipsis);
            if (isTitle) {
              expect(
                tester
                    .renderObject<RenderParagraph>(find.text(label))
                    .didExceedMaxLines,
                isFalse,
              );
            }
          }
          expect(
            find.byTooltip('Barbell, Adjustable Bench, Weight Plates'),
            findsOneWidget,
          );
          expect(
            find.byTooltip(
              'Pectoralis Major, Triceps Brachii, Anterior Deltoid, Coracobrachialis',
            ),
            findsOneWidget,
          );
          final tile = tester.widget<ExerciseDefinitionInfoTile>(
            find.byType(ExerciseDefinitionInfoTile),
          );
          expect(tile.definition, same(definition));
          expect(tile.bodypartExercisePreview, isTrue);
          expect(definition.muscles.map((muscle) => muscle.rank), [3, 1, 4, 2]);
          final info = find.byKey(
            ValueKey('anatomy-exercise-thumbnail-${definition.id}'),
          );
          expect(tester.getSize(info).width, greaterThanOrEqualTo(48));
          expect(tester.getSize(info).height, greaterThanOrEqualTo(48));
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'Bodypart exercise search matches, opens details, and clears in ${brightness.name}',
      (tester) async {
        await _prepareAnatomyTest(tester);
        final chest = BodyPart(1, 'Chest');
        final legs = BodyPart(2, 'Quads');
        final repository = _AnatomyRepository(
          bodyParts: [chest, legs],
          muscles: const [],
          definitions: [
            _definition(id: 1, name: 'Bench Press', bodyPart: chest),
            _definition(id: 2, name: 'Dip', bodyPart: chest),
            _definition(id: 3, name: 'Goblet Squat', bodyPart: legs),
          ],
        );
        await _pumpRoute(
          tester,
          brightness == Brightness.dark
              ? ExpressiveThemeDefinition.dark()
              : ExpressiveThemeDefinition.light(),
          repository,
          DefinitionsByBodyPartPage(
            bodyPart: chest,
            expressiveCatalogPresentation: true,
          ),
        );
        final search = find.byKey(const ValueKey('bodypart-exercise-search'));
        final strings = AppLocalizations.of(tester.element(search));
        await tester.ensureVisible(search);
        await tester.enterText(search, '  bEnCh  ');
        await tester.pumpAndSettle();
        final tile = tester.widget<ExerciseDefinitionInfoTile>(
          find.byType(ExerciseDefinitionInfoTile),
        );
        expect(tile.definition.id, 1);
        expect(find.text('Dip'), findsNothing);
        expect(find.text('Goblet Squat'), findsNothing);
        expect(find.text(strings.anatomyNoEquipment), findsOneWidget);
        expect(find.text(strings.anatomyNoMusclesListed), findsOneWidget);
        expect(
          find.text(strings.anatomyLinkedExerciseCount(2)),
          findsOneWidget,
        );

        FocusManager.instance.primaryFocus?.unfocus();
        final info = find.byKey(const ValueKey('anatomy-exercise-thumbnail-1'));
        await tester.ensureVisible(info);
        await tester.tap(info);
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

        await tester.ensureVisible(search);
        await tester.enterText(search, 'nothing matches this name');
        await tester.pumpAndSettle();
        expect(find.byType(ExerciseDefinitionInfoTile), findsNothing);
        expect(find.text(strings.catalogNoSearchMatches), findsOneWidget);
        expect(find.text(strings.catalogNoSearchMatchesBody), findsOneWidget);
        await tester.tap(find.byTooltip(strings.catalogClearSearch));
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(search).controller!.text, isEmpty);
        expect(find.text(strings.catalogNoSearchMatches), findsNothing);
        expect(find.byType(ExerciseDefinitionInfoTile), findsNWidgets(2));
        expect(find.text('Goblet Squat'), findsNothing);
        expect(repository.definitionReadCount, 1);
        expect(repository.definitions, hasLength(3));
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final brightness in Brightness.values) {
    for (final sample in [
      (width: 430.0, scale: 1.0),
      (width: 320.0, scale: 2.0),
    ]) {
      testWidgets(
        'Muscle exercise cards wrap and identify their relationships at '
        '${sample.width} dp, ${sample.scale}x in ${brightness.name}',
        (tester) async {
          await _prepareAnatomyTest(tester);
          await tester.binding.setSurfaceSize(Size(sample.width, 1200));
          final muscle = Muscle(id: 1, name: 'Adductor Brevis');
          final hamstrings = BodyPart(1, 'Hamstrings');
          final lowerBack = BodyPart(2, 'Lower Back');
          const equipmentName =
              'Barbell with Adjustable Safety Supports and Weight Plates';
          final definition = ExerciseDefinition(
            id: 1,
            name: 'Deadlift - Barbell with a Deliberately Long Variation Name',
            bodyParts: [hamstrings, lowerBack],
            equipmentList: [Equipment(1, equipmentName)],
            muscles: [RankedMuscle(muscle: muscle, rank: 4)],
            useManualBodyparts: false,
            multiplyByRating: false,
          );
          final sparseDefinition = ExerciseDefinition(
            id: 2,
            name: 'Z Movement',
            bodyParts: const [],
            equipmentList: const [],
            muscles: [RankedMuscle(muscle: muscle, rank: 6)],
            useManualBodyparts: false,
            multiplyByRating: false,
          );
          await _pumpRoute(
            tester,
            brightness == Brightness.dark
                ? ExpressiveThemeDefinition.dark()
                : ExpressiveThemeDefinition.light(),
            _AnatomyRepository(
              bodyParts: [hamstrings, lowerBack],
              muscles: [muscle],
              definitions: [sparseDefinition, definition],
            ),
            Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(sample.scale)),
                child: DefinitionsByMusclePage(
                  muscle: muscle,
                  expressiveCatalogPresentation: true,
                ),
              ),
            ),
          );
          await tester.scrollUntilVisible(
            find.text(definition.name),
            180,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          final card = find.widgetWithText(
            ExerciseDefinitionInfoTile,
            definition.name,
          );
          final cardContext = tester.element(card);
          final strings = AppLocalizations.of(cardContext);
          final bodypartsLabel =
              '${strings.anatomyBodyParts}: '
              '${localizedBodyPartName(cardContext, hamstrings.name)}, '
              '${localizedBodyPartName(cardContext, lowerBack.name)}';
          for (final label in [
            definition.name,
            equipmentName,
            '${strings.rankingsRank} 4 · ${muscle.name}',
            bodypartsLabel,
          ]) {
            final text = find.descendant(of: card, matching: find.text(label));
            expect(text, findsOneWidget);
            final singleLine =
                label == equipmentName || label == bodypartsLabel;
            expect(tester.widget<Text>(text).maxLines, singleLine ? 1 : isNull);
            expect(
              tester.widget<Text>(text).overflow,
              singleLine ? TextOverflow.ellipsis : isNull,
            );
            if (!singleLine) {
              expect(
                tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
                isFalse,
              );
            }
          }
          expect(
            tester.widget<Text>(find.text(definition.name)).style?.fontWeight,
            FontWeight.w700,
          );
          expect(find.byTooltip(equipmentName), findsOneWidget);
          final tile = tester.widget<ExerciseDefinitionInfoTile>(card);
          expect(tile.definition, same(definition));
          expect(tile.muscleExercisePreview, isTrue);
          expect(tile.bodypartExercisePreview, isFalse);
          final info = find.descendant(
            of: card,
            matching: find.byKey(
              ValueKey('anatomy-exercise-thumbnail-${definition.id}'),
            ),
          );
          expect(tester.getSize(info).width, greaterThanOrEqualTo(48));
          expect(tester.getSize(info).height, greaterThanOrEqualTo(48));
          expect(
            find.byKey(const ValueKey('muscle-exercise-search')),
            findsNothing,
          );
          await tester.scrollUntilVisible(
            find.text(sparseDefinition.name),
            180,
            scrollable: find.byType(Scrollable).first,
          );
          expect(find.text(strings.anatomyNoEquipment), findsOneWidget);
          expect(
            find.text(
              '${strings.anatomyBodyParts}: ${strings.anatomyNoBodyPartsListed}',
            ),
            findsOneWidget,
          );
          expect(definition.muscles.single.rank, 4);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'Muscle exercise search handles large lists, equipment, empty results, '
      'and details in ${brightness.name}',
      (tester) async {
        await _prepareAnatomyTest(tester);
        final muscle = Muscle(id: 1, name: 'Biceps Brachii');
        final unrelatedMuscle = Muscle(id: 2, name: 'Adductor Brevis');
        final bodypart = BodyPart(1, 'Biceps');
        final definitions = [
          for (var index = 0; index < 75; index++)
            ExerciseDefinition(
              id: index,
              name: index < 2 ? 'Cable Curl $index' : 'Dumbbell Curl $index',
              bodyParts: [bodypart],
              equipmentList: [
                Equipment(index, index < 2 ? 'High Pulley' : 'Dumbbell'),
              ],
              muscles: [RankedMuscle(muscle: muscle, rank: 7 - index % 7)],
              useManualBodyparts: false,
              multiplyByRating: false,
            ),
          _definition(
            id: 100,
            name: 'Cable Curl Unrelated',
            bodyPart: bodypart,
            muscle: unrelatedMuscle,
            equipment: Equipment(100, 'High Pulley'),
          ),
        ];
        final originalOrder = definitions
            .map((definition) => definition.id)
            .toList();
        final repository = _AnatomyRepository(
          bodyParts: [bodypart],
          muscles: [muscle, unrelatedMuscle],
          definitions: definitions,
        );
        await _pumpRoute(
          tester,
          brightness == Brightness.dark
              ? ExpressiveThemeDefinition.dark()
              : ExpressiveThemeDefinition.light(),
          repository,
          DefinitionsByMusclePage(
            muscle: muscle,
            expressiveCatalogPresentation: true,
          ),
        );
        final search = find.byKey(const ValueKey('muscle-exercise-search'));
        final strings = AppLocalizations.of(tester.element(search));
        await tester.ensureVisible(search);
        await tester.enterText(search, '  cAbLe cUrL 0  ');
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<ExerciseDefinitionInfoTile>(
                find.byType(ExerciseDefinitionInfoTile),
              )
              .definition
              .id,
          0,
        );
        await tester.enterText(search, '  pUlLeY  ');
        await tester.pumpAndSettle();
        expect(
          tester
              .widgetList<ExerciseDefinitionInfoTile>(
                find.byType(ExerciseDefinitionInfoTile),
              )
              .map((tile) => tile.definition.id),
          [1, 0],
        );
        expect(find.text('Cable Curl Unrelated'), findsNothing);
        expect(
          find.text(strings.anatomyLinkedExerciseCount(75)),
          findsOneWidget,
        );
        expect(
          tester
              .widget<ListView>(find.byType(ListView).first)
              .keyboardDismissBehavior,
          ScrollViewKeyboardDismissBehavior.onDrag,
        );

        await tester.enterText(search, 'no such exercise or equipment');
        await tester.pumpAndSettle();
        expect(find.byType(ExerciseDefinitionInfoTile), findsNothing);
        expect(find.text(strings.catalogNoSearchMatches), findsOneWidget);
        await tester.tap(
          find.widgetWithText(TextButton, strings.catalogClearSearch),
        );
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(search).controller!.text, isEmpty);
        expect(find.text(strings.catalogNoSearchMatches), findsNothing);
        expect(find.byType(ExerciseDefinitionInfoTile), findsWidgets);
        await tester.enterText(search, 'pulley');
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip(strings.catalogClearSearch));
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(search).controller!.text, isEmpty);

        await tester.enterText(search, 'cable curl 0');
        await tester.pumpAndSettle();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: search,
                  matching: find.byType(EditableText),
                ),
              )
              .focusNode
              .hasFocus,
          isFalse,
        );
        final info = find.byKey(const ValueKey('anatomy-exercise-thumbnail-0'));
        await tester.ensureVisible(info);
        await tester.tap(info);
        await tester.pumpAndSettle();
        final sheet = tester.widget<ExerciseDetailSheet>(
          find.byType(ExerciseDetailSheet),
        );
        expect(sheet.definition.id, 0);
        expect(sheet.expressiveCatalogPresentation, isTrue);
        expect(repository.definitionReadCount, 1);
        expect(definitions.map((definition) => definition.id), originalOrder);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Muscle exercise search starts at ten linked exercises', (
    tester,
  ) async {
    await _prepareAnatomyTest(tester);
    final muscle = Muscle(id: 1, name: 'Biceps Brachii');
    final bodypart = BodyPart(1, 'Biceps');
    for (final count in [9, 10]) {
      await _pumpRoute(
        tester,
        ExpressiveThemeDefinition.light(),
        _AnatomyRepository(
          bodyParts: [bodypart],
          muscles: [muscle],
          definitions: [
            for (var index = 0; index < count; index++)
              _definition(
                id: index,
                name: 'Curl $index',
                bodyPart: bodypart,
                muscle: muscle,
              ),
          ],
        ),
        DefinitionsByMusclePage(
          key: ValueKey(count),
          muscle: muscle,
          expressiveCatalogPresentation: true,
        ),
      );
      expect(
        find.byKey(const ValueKey('muscle-exercise-search')),
        count == 10 ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Muscle exercise refinement stays local to Expressive Catalog', (
    tester,
  ) async {
    await _prepareAnatomyTest(tester);
    final muscle = Muscle(id: 1, name: 'Biceps Brachii');
    final bodypart = BodyPart(1, 'Biceps');
    final repository = _AnatomyRepository(
      bodyParts: [bodypart],
      muscles: [muscle],
      definitions: [
        for (var index = 0; index < 10; index++)
          _definition(
            id: index,
            name: 'Curl $index',
            bodyPart: bodypart,
            muscle: muscle,
          ),
      ],
    );
    for (final sample in [
      (theme: AppThemeFactory.light(AppThemeFamily.classic), analytics: false),
      (
        theme: AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
        analytics: false,
      ),
      (theme: ExpressiveThemeDefinition.dark(), analytics: true),
    ]) {
      await _pumpRoute(
        tester,
        sample.theme,
        repository,
        DefinitionsByMusclePage(
          muscle: muscle,
          expressiveCatalogPresentation: !sample.analytics,
          expressiveAnalyticsPresentation: sample.analytics,
        ),
      );
      await tester.scrollUntilVisible(
        find.byType(ExerciseDefinitionInfoTile).first,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.byKey(const ValueKey('muscle-exercise-search')),
        findsNothing,
      );
      for (final tile in tester.widgetList<ExerciseDefinitionInfoTile>(
        find.byType(ExerciseDefinitionInfoTile),
      )) {
        expect(tile.muscleExercisePreview, isFalse);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'Bodypart exercise refinement stays local to Expressive Catalog',
    (tester) async {
      await _prepareAnatomyTest(tester);
      final chest = BodyPart(1, 'Chest');
      final repository = _AnatomyRepository(
        bodyParts: [chest],
        muscles: const [],
        definitions: [_definition(id: 1, name: 'Press', bodyPart: chest)],
      );
      for (final sample in [
        (
          theme: AppThemeFactory.light(AppThemeFamily.classic),
          analytics: false,
        ),
        (
          theme: AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
          analytics: false,
        ),
        (theme: ExpressiveThemeDefinition.light(), analytics: true),
      ]) {
        await _pumpRoute(
          tester,
          sample.theme,
          repository,
          DefinitionsByBodyPartPage(
            bodyPart: chest,
            expressiveCatalogPresentation: !sample.analytics,
            expressiveAnalyticsPresentation: sample.analytics,
          ),
        );
        await tester.scrollUntilVisible(
          find.byType(ExerciseDefinitionInfoTile),
          180,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          find.byKey(const ValueKey('bodypart-exercise-search')),
          findsNothing,
        );
        expect(
          tester
              .widget<ExerciseDefinitionInfoTile>(
                find.byType(ExerciseDefinitionInfoTile),
              )
              .bodypartExercisePreview,
          isFalse,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

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
        expect(tabBar.controller?.index, 1);
        final colorScheme = Theme.of(filterContext).colorScheme;
        final expectedRowSurface = Color.lerp(
          brightness == Brightness.dark
              ? tokens.surfaceAccent
              : tokens.surfaceTertiary,
          colorScheme.surface,
          brightness == Brightness.dark ? 0.45 : 0.60,
        );

        final muscleRow = find
            .ancestor(
              of: find.text(pectorals.name),
              matching: find.byType(ListTile),
            )
            .first;
        expect(
          tester.widget<ListTile>(muscleRow).tileColor,
          expectedRowSurface,
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
        expect(muscleMedia.size, 54);
        expect(muscleMedia.padding, const EdgeInsets.all(3));
        expect(muscleMedia.borderRadius, BorderRadius.circular(16));
        expect(
          muscleMedia.backgroundColor,
          Color.lerp(tokens.surfaceAccent, colorScheme.surface, 0.78),
        );
        expect(
          muscleMedia.borderColor,
          tokens.outlineAccent.withValues(alpha: 0.30),
        );
        expect(find.text(strings.anatomyBodyParts), findsOneWidget);
        expect(find.text(strings.anatomyMuscles), findsOneWidget);

        final search = find.byType(TextField);
        expect(tester.widget<TextField>(search).decoration?.labelText, isNull);
        expect(
          tester.widget<TextField>(search).decoration?.hintText,
          strings.mappingSearchMuscles,
        );
        await tester.enterText(search, 'pect');
        await tester.pumpAndSettle();
        expect(find.text(pectorals.name), findsOneWidget);
        expect(find.text(quadriceps.name), findsNothing);

        await tester.tap(find.text(strings.anatomyBodyParts));
        await tester.pumpAndSettle();
        expect(tester.widget<TabBar>(find.byType(TabBar)).controller?.index, 0);
        expect(tester.widget<TextField>(search).controller?.text, isEmpty);
        expect(
          tester.widget<TextField>(search).decoration?.hintText,
          strings.anatomySearchBodyParts,
        );
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
          expectedRowSurface,
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
        expect(bodyPartMedia.padding, const EdgeInsets.all(2));
        expect(bodyPartMedia.borderRadius, BorderRadius.circular(16));
        expect(
          bodyPartMedia.backgroundColor,
          Color.lerp(tokens.surfaceAccent, colorScheme.surface, 0.78),
        );
        expect(
          bodyPartMedia.borderColor,
          tokens.outlineAccent.withValues(alpha: 0.30),
        );
        expect(find.byType(SingleBodyPartHeatmap), findsWidgets);

        await tester.enterText(search, 'no matching anatomy');
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
        expect(find.text(strings.anatomyNoBodyParts), findsOneWidget);
        final clearSearch = find.widgetWithText(
          OutlinedButton,
          strings.catalogClearSearch,
        );
        expect(clearSearch, findsOneWidget);
        await tester.tap(clearSearch);
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(search).controller?.text, isEmpty);
        expect(find.text('Chest'), findsOneWidget);
        expect(find.text('Legs'), findsOneWidget);

        await tester.enterText(search, 'leg');
        await tester.pumpAndSettle();
        await tester.drag(find.byType(TabBarView), const Offset(-280, 0));
        await tester.pumpAndSettle();
        expect(tester.widget<TabBar>(find.byType(TabBar)).controller?.index, 1);
        expect(tester.widget<TextField>(search).controller?.text, isEmpty);
        expect(
          tester.widget<TextField>(search).decoration?.hintText,
          strings.mappingSearchMuscles,
        );
        expect(find.text(pectorals.name), findsOneWidget);
        expect(find.text(quadriceps.name), findsOneWidget);
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
      expect(find.text(strings.anatomyDoneSevenDaysCompact), findsOneWidget);
      expect(
        find.text(strings.anatomyRecommendedWeeklyCompact),
        findsOneWidget,
      );
      expect(find.text(strings.anatomySetUnits('8.5')), findsOneWidget);
      expect(find.text(strings.anatomySetRange('6', '18')), findsOneWidget);
      expect(find.widgetWithText(ActionChip, muscle.name), findsOneWidget);

      final recommendedStat = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == strings.recommendedSetsEdit,
      );
      expect(recommendedStat, findsOneWidget);
      await tester.tap(recommendedStat);
      await tester.pumpAndSettle();
      expect(find.text(strings.recommendedSetsTitle), findsOneWidget);
      await tester.tap(find.text(strings.commonCancel));
      await tester.pumpAndSettle();

      final detailInfoButton = find.byType(ExerciseMediaThumbnail);
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
    expect(
      find.text(muscleStrings.anatomyDoneSevenDaysCompact),
      findsOneWidget,
    );
    expect(
      find.text(muscleStrings.anatomyRecommendedWeeklyCompact),
      findsOneWidget,
    );
    expect(find.text(muscleStrings.anatomySetUnits('5.5')), findsOneWidget);
    expect(find.text(muscleStrings.anatomySetRange('7', '15')), findsOneWidget);
    expect(find.byType(ActionChip), findsOneWidget);
    final muscleRecommendedStat = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.button == true &&
          widget.properties.label == muscleStrings.recommendedSetsEdit,
    );
    expect(muscleRecommendedStat, findsOneWidget);
    await tester.tap(muscleRecommendedStat);
    await tester.pumpAndSettle();
    expect(find.text(muscleStrings.recommendedSetsTitle), findsOneWidget);
    await tester.tap(find.text(muscleStrings.commonCancel));
    await tester.pumpAndSettle();
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
  int definitionReadCount = 0;

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => bodyParts;

  @override
  Future<List<Muscle>> fetchAllMuscles() async => muscles;

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async {
    definitionReadCount++;
    return definitions;
  }

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
  Future<void> ensureExerciseMediaManifestReady() async {}

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
