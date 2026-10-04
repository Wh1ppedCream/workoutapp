import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/content_repository.dart';
import 'package:env_test/screens/exercise/definitions_by_bodypart_page.dart';
import 'package:env_test/screens/exercise/definitions_by_muscle_page.dart';
import 'package:env_test/screens/exercise/muscle_filter_page.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/utils/localized_body_part_name.dart';
import 'package:env_test/widgets/body_heatmap.dart';
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
      'anatomy-muscle-detail-recipes': (
        4,
        'structural_theme',
        'migrated',
        ['color', 'text_style'],
      ),
      'anatomy-filter-material-search': (
        1,
        'material_component',
        'migrated',
        ['decoration'],
      ),
      'anatomy-filter-fallback-artwork': (
        10,
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

  for (final familyEntry in themes.entries) {
    for (final modeEntry in familyEntry.value.entries) {
      final family = familyEntry.key;
      final brightness = modeEntry.key;
      final theme = modeEntry.value;
      final mode = '${family.code} ${brightness.name}';
      final positiveInk =
          family == AppThemeFamily.neoBrutalism
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
  await tester.pumpWidget(
    Provider<AppRepository>.value(
      value: repository,
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
  });

  final List<BodyPart> bodyParts;
  final List<Muscle> muscles;
  final List<ExerciseDefinition> definitions;
  final List<MuscleBodyPart> bodyPartLinks;
  final List<MuscleBodyPart> muscleLinks;

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
  }) async => const {};

  @override
  Future<Map<int, double>> fetchSetsPerMuscle({
    required DateTime start,
    required DateTime end,
  }) async => const {};

  @override
  Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) async =>
      null;

  @override
  Future<VolumeBoundaries?> fetchMuscleVolumeBounds(int muscleId) async => null;

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
