import 'dart:async';
import 'dart:io';

import 'package:env_test/db/database_helper.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/content_repository.dart';
import 'package:env_test/screens/catalog_page.dart';
import 'package:env_test/screens/exercise/definitions_by_bodypart_page.dart';
import 'package:env_test/screens/exercise/definitions_by_muscle_page.dart';
import 'package:env_test/screens/exercise/muscle_filter_page.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/painting.dart' show TextPainter;
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const responsiveViewports = <({String label, Size size})>[
    (label: '320 dp compact portrait', size: Size(320, 780)),
    (label: '360 dp compact phone', size: Size(360, 800)),
    (label: '390 dp phone', size: Size(390, 844)),
    (label: '430 dp large phone', size: Size(430, 932)),
    (label: '600 dp compact tablet', size: Size(600, 960)),
    (label: '800 dp tablet', size: Size(800, 1280)),
    (label: '1024 dp tablet', size: Size(1024, 768)),
    (label: 'compact landscape', size: Size(640, 360)),
    (label: 'wide landscape', size: Size(800, 360)),
  ];

  for (final brightness in Brightness.values) {
    for (final textScale in <double>[1, 1.3, 1.5, 2]) {
      for (final viewport in responsiveViewports) {
        testWidgets('Expressive Catalog and anatomy browse remain usable at '
            '${viewport.label}, ${brightness.name}, ${textScale}x text', (
          tester,
        ) async {
          await tester.binding.setSurfaceSize(viewport.size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          SharedPreferences.setMockInitialValues({
            'guided_tutorial_completed.catalog_home_v1': true,
            'guided_tutorial_completed.target_anatomy_v1': true,
          });

          final repository = _ResponsiveCatalogRepository();
          final activeSession = ActiveSession(repository: repository);
          addTearDown(activeSession.dispose);
          await activeSession.ready;

          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(value: repository),
                ChangeNotifierProvider<ActiveSession>.value(
                  value: activeSession,
                ),
              ],
              child: MaterialApp(
                theme: brightness == Brightness.dark
                    ? ExpressiveThemeDefinition.dark()
                    : ExpressiveThemeDefinition.light(),
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(textScale)),
                  child: child!,
                ),
                home: const CatalogPage(),
              ),
            ),
          );
          await _settle(tester);

          final strings = AppLocalizations.of(
            tester.element(find.byType(CatalogPage)),
          );
          expect(find.text(strings.catalogExerciseTitle), findsOneWidget);
          expect(find.text('Bench Press'), findsOneWidget);
          expect(find.text('Goblet Squat'), findsOneWidget);
          expect(tester.takeException(), isNull);

          if (viewport.size.width == 320 && textScale == 2) {
            final leadRow = find.byKey(
              const ValueKey('catalog-exercise-usage-lead'),
            );
            final supportName = find.text('Goblet Squat');
            expect(leadRow, findsOneWidget);
            expect(
              tester.getTopLeft(find.text('Bench Press')).dy,
              lessThan(tester.getTopLeft(supportName).dy),
            );

            final leadContainer = find.descendant(
              of: leadRow,
              matching: find.byKey(
                const ValueKey('catalog-exercise-usage-lead-row'),
              ),
            );
            final supportRow = find
                .ancestor(of: supportName, matching: find.byType(Container))
                .first;
            expect(leadContainer, findsOneWidget);
            expect(
              tester.getSize(leadContainer).height,
              greaterThan(tester.getSize(supportRow).height),
              reason:
                  'The lead row should gain room for its metadata and inset.',
            );

            final metadata = find.byWidgetPredicate(
              (widget) =>
                  widget is Text &&
                  widget.data?.contains(
                        _ResponsiveCatalogRepository.longEquipmentName,
                      ) ==
                      true,
            );
            expect(metadata, findsOneWidget);
            final metadataText = tester.widget<Text>(metadata);
            expect(metadataText.data, contains(strings.catalogTimesUsed(4)));
            expect(metadataText.maxLines, isNull);
            final metadataElement = tester.element(metadata);
            final metadataPainter = TextPainter(
              text: TextSpan(
                text: metadataText.data,
                style: metadataText.style,
              ),
              textDirection: Directionality.of(metadataElement),
              textScaler: MediaQuery.textScalerOf(metadataElement),
              maxLines: metadataText.maxLines,
            )..layout(maxWidth: tester.getSize(metadata).width);
            final metadataLines = metadataPainter.computeLineMetrics();
            expect(
              metadataLines.length,
              greaterThan(1),
              reason: 'Equipment and use count should wrap across lines.',
            );
            expect(
              metadataPainter.didExceedMaxLines,
              isFalse,
              reason: 'Long equipment and count metadata must remain visible.',
            );
            final leadTitle = tester.widget<Text>(find.text('Bench Press'));
            final leadTitleWeight = leadTitle.style?.fontWeight?.index ?? 0;
            final metadataWeight = metadataText.style?.fontWeight?.index ?? 0;
            expect(leadTitleWeight, greaterThan(metadataWeight));
            expect(tester.takeException(), isNull);
          }

          await tester.scrollUntilVisible(
            find.text(strings.catalogTargetAnatomyTitle),
            240,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(find.text(strings.catalogTargetAnatomyTitle), findsOneWidget);
          expect(find.text('Chest'), findsOneWidget);

          if (viewport.size.width == 320 && textScale == 2) {
            final panes = find.byKey(
              const ValueKey('catalog-target-anatomy-panes'),
            );
            expect(panes, findsOneWidget);
            expect(
              find.byKey(const ValueKey('catalog-bodyparts-summary')),
              findsOneWidget,
            );
            expect(
              find.byKey(const ValueKey('catalog-muscles-summary')),
              findsOneWidget,
            );
            expect(
              tester.getTopLeft(find.text(strings.catalogMuscles)).dy,
              greaterThan(
                tester.getTopLeft(find.text(strings.catalogBodyparts)).dy,
              ),
              reason: 'The anatomy panes should stack at 320 dp and 2x text.',
            );
            expect(tester.takeException(), isNull);
          }

          if (viewport.size.width >= 390 &&
              viewport.size.height != 360 &&
              textScale == 1) {
            expect(
              tester.getTopLeft(find.text(strings.catalogMuscles)).dy,
              lessThanOrEqualTo(
                tester.getTopLeft(find.text(strings.catalogBodyparts)).dy + 1,
              ),
              reason:
                  'Anatomy panes should remain side by side at normal size.',
            );
          }

          if (brightness == Brightness.light && textScale == 1) {
            // Follow both existing root -> anatomy library workflows and
            // verify that each route preserves its expressive presentation.
            await tester.scrollUntilVisible(
              find.text(strings.catalogBodyparts),
              240,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.pumpAndSettle();
            await tester.tap(find.text(strings.catalogBodyparts));
            await _settle(tester);
            expect(find.byType(MuscleFilterPage), findsOneWidget);
            expect(
              tester
                  .widget<MuscleFilterPage>(find.byType(MuscleFilterPage))
                  .expressiveCatalogPresentation,
              isTrue,
            );
            expect(
              tester
                  .widget<MuscleFilterPage>(find.byType(MuscleFilterPage))
                  .initialTabIndex,
              0,
            );
            Navigator.of(tester.element(find.byType(MuscleFilterPage))).pop();
            await _settle(tester);

            await tester.scrollUntilVisible(
              find.text(strings.catalogMuscles),
              240,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.pumpAndSettle();
            await tester.tap(find.text(strings.catalogMuscles));
            await _settle(tester);
            expect(find.byType(MuscleFilterPage), findsOneWidget);
            expect(
              tester
                  .widget<MuscleFilterPage>(find.byType(MuscleFilterPage))
                  .expressiveCatalogPresentation,
              isTrue,
            );
            expect(
              tester
                  .widget<MuscleFilterPage>(find.byType(MuscleFilterPage))
                  .initialTabIndex,
              1,
            );
          }
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }

  for (final brightness in Brightness.values) {
    for (final textScale in <double>[1, 1.3, 1.5, 2]) {
      for (final viewport in responsiveViewports) {
        testWidgets(
          'Expressive anatomy list search stays usable at '
          '${viewport.label}, ${brightness.name}, ${textScale}x text',
          (tester) async {
            await tester.binding.setSurfaceSize(viewport.size);
            addTearDown(() => tester.binding.setSurfaceSize(null));
            SharedPreferences.setMockInitialValues({
              'guided_tutorial_completed.target_anatomy_v1': true,
            });
            final repository = _ResponsiveCatalogRepository();

            await tester.pumpWidget(
              MultiProvider(
                providers: [Provider<AppRepository>.value(value: repository)],
                child: MaterialApp(
                  theme: brightness == Brightness.dark
                      ? ExpressiveThemeDefinition.dark()
                      : ExpressiveThemeDefinition.light(),
                  themeAnimationDuration: Duration.zero,
                  localizationsDelegates: tonosLocalizationDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(textScale)),
                    child: child!,
                  ),
                  home: const MuscleFilterPage(
                    expressiveCatalogPresentation: true,
                  ),
                ),
              ),
            );
            await _settle(tester);

            final strings = AppLocalizations.of(
              tester.element(find.byType(MuscleFilterPage)),
            );
            expect(find.byType(TextField), findsOneWidget);
            expect(find.text(strings.anatomyBodyParts), findsOneWidget);
            expect(find.text(strings.anatomyMuscles), findsOneWidget);
            expect(find.text('Chest'), findsOneWidget);
            expect(tester.takeException(), isNull);

            final search = find.byType(TextField).first;
            final decoration = tester.widget<TextField>(search).decoration!;
            expect(
              decoration.labelText ?? decoration.label,
              isNotNull,
              reason:
                  'The anatomy search needs a discoverable accessible label.',
            );
            await tester.enterText(search, 'leg');
            await tester.pump();
            expect(find.text('Chest'), findsNothing);
            expect(find.text('Legs'), findsOneWidget);
            expect(tester.takeException(), isNull);
            // The tutorial's delayed check is scheduled from a data-backed
            // post-frame callback. Drain it before disposing the route.
            await tester.pump(const Duration(milliseconds: 600));
            await tester.pump();
            await tester.pumpWidget(const SizedBox.shrink());
          },
        );
      }
    }
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive anatomy details wrap long metadata at 320 dp and 2x text '
      'in ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 780));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.bodypart_detail_v1': true,
          'guided_tutorial_completed.muscle_detail_v1': true,
        });
        final repository = _ResponsiveDetailRepository();
        final bodyPart = _ResponsiveDetailRepository.bodyPart;
        final muscle = _ResponsiveDetailRepository.muscle;

        Future<void> pumpDetail(Widget route) async {
          await tester.pumpWidget(
            Provider<AppRepository>.value(
              value: repository,
              child: MaterialApp(
                theme: brightness == Brightness.dark
                    ? ExpressiveThemeDefinition.dark()
                    : ExpressiveThemeDefinition.light(),
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(2)),
                  child: child!,
                ),
                home: route,
              ),
            ),
          );
          await _settle(tester);
        }

        await pumpDetail(
          DefinitionsByBodyPartPage(
            bodyPart: bodyPart,
            expressiveCatalogPresentation: true,
          ),
        );
        await tester.scrollUntilVisible(
          find.text('High and Low Pulley'),
          180,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('High and Low Pulley'), findsOneWidget);
        await _expectWrappedText(tester, 'High and Low Pulley');
        await _expectWrappedText(tester, 'Long Head Triceps');
        expect(tester.takeException(), isNull);

        await pumpDetail(
          DefinitionsByMusclePage(
            muscle: muscle,
            expressiveCatalogPresentation: true,
          ),
        );
        final strings = AppLocalizations.of(
          tester.element(find.byType(DefinitionsByMusclePage)),
        );
        final rank = strings.anatomyRankForMuscle(1, 'Upper Chest');
        await tester.scrollUntilVisible(
          find.text('Overhead Cable Press'),
          180,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await _expectWrappedText(tester, 'High and Low Pulley');
        await _expectWrappedText(tester, rank);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> _expectWrappedText(WidgetTester tester, String content) async {
  final finder = find.byWidgetPredicate(
    (widget) => widget is Text && widget.data?.contains(content) == true,
  );
  final matches = finder.evaluate().toList();
  expect(matches, isNotEmpty, reason: content);
  var wrapped = false;
  for (var index = 0; index < matches.length; index++) {
    final paragraph = tester.renderObject<RenderParagraph>(finder.at(index));
    final painter = TextPainter(
      text: paragraph.text,
      textDirection: paragraph.textDirection,
      textScaler: paragraph.textScaler,
      maxLines: paragraph.maxLines,
    )..layout(maxWidth: paragraph.size.width);
    final lines = painter.computeLineMetrics().length;
    expect(paragraph.didExceedMaxLines, isFalse, reason: content);
    wrapped = wrapped || lines > 1;
  }
  expect(wrapped, isTrue, reason: content);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump();
  // Root/anatomy tutorial gates schedule their one-shot check from a
  // post-frame callback, so advance once more after that callback runs.
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump();
}

class _ResponsiveCatalogRepository extends AppRepository {
  _ResponsiveCatalogRepository() : super(db: _ResponsiveCatalogDatabase());

  static final chest = BodyPart(1, 'Chest');
  static final legs = BodyPart(2, 'Legs');
  static final shoulders = BodyPart(3, 'Shoulders');
  static final lowerBack = BodyPart(4, 'Lower Back');
  static final core = BodyPart(5, 'Core');
  static final pectorals = Muscle(id: 1, name: 'Pectorals');
  static final quadriceps = Muscle(id: 2, name: 'Quadriceps');
  static final anteriorDeltoid = Muscle(id: 3, name: 'Anterior Deltoid');
  static final tricepsBrachii = Muscle(id: 4, name: 'Triceps Brachii');
  static final latissimusDorsi = Muscle(id: 5, name: 'Latissimus Dorsi');
  static final bicepsBrachii = Muscle(id: 6, name: 'Biceps Brachii');
  static const longEquipmentName =
      'Adjustable dual-pulley cable machine with '
      'independent high and low stations';
  static final equipment = Equipment(1, longEquipmentName);
  static final barbell = Equipment(2, 'Barbell');
  static final definitions = <ExerciseDefinition>[
    ExerciseDefinition(
      id: 1,
      name: 'Bench Press',
      equipmentList: [equipment],
      bodyParts: [chest],
      muscles: [RankedMuscle(muscle: pectorals, rank: 1)],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
    ExerciseDefinition(
      id: 2,
      name: 'Goblet Squat',
      equipmentList: [barbell],
      bodyParts: [legs],
      muscles: [RankedMuscle(muscle: quadriceps, rank: 1)],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
  ];

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];

  @override
  Future<List<Map<String, dynamic>>> fetchMostUsedExerciseDefinitionsRaw({
    int limit = 5,
  }) async => [
    {'definition_id': 1, 'use_count': 4},
    {'definition_id': 2, 'use_count': 2},
  ];

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => definitions;

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailedByIds(
    List<int> definitionIds,
  ) async =>
      definitions.where((item) => definitionIds.contains(item.id)).toList();

  @override
  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async => {chest: 3, legs: 2, shoulders: 5, lowerBack: 4, core: 1};

  @override
  Future<Map<int, double>> fetchSetsPerMuscle({
    required DateTime start,
    required DateTime end,
  }) async => {1: 1, 2: 2, 3: 5, 4: 4, 5: 3, 6: 2};

  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => [
    pectorals,
    quadriceps,
    anteriorDeltoid,
    tricepsBrachii,
    latissimusDorsi,
    bicepsBrachii,
  ];

  @override
  Future<void> ensureExerciseMediaManifestReady() async {}

  @override
  Future<ExerciseMediaItem?> fetchPrimaryExerciseMedia(int defId) async => null;

  @override
  Future<File?> cachedExerciseMediaFile(
    ExerciseMediaItem item, {
    required bool thumbnail,
  }) async => null;

  @override
  Stream<ContentMediaCacheChange> get mediaCacheChanges =>
      const Stream<ContentMediaCacheChange>.empty();
}

class _ResponsiveCatalogDatabase implements DatabaseHelper {
  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => [
    _ResponsiveCatalogRepository.chest,
    _ResponsiveCatalogRepository.legs,
    _ResponsiveCatalogRepository.shoulders,
    _ResponsiveCatalogRepository.lowerBack,
    _ResponsiveCatalogRepository.core,
  ];

  @override
  Future<List<Muscle>> fetchAllMuscles() async => [
    _ResponsiveCatalogRepository.pectorals,
    _ResponsiveCatalogRepository.quadriceps,
    _ResponsiveCatalogRepository.anteriorDeltoid,
    _ResponsiveCatalogRepository.tricepsBrachii,
    _ResponsiveCatalogRepository.latissimusDorsi,
    _ResponsiveCatalogRepository.bicepsBrachii,
  ];

  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => fetchAllMuscles();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ResponsiveDetailRepository extends AppRepository {
  _ResponsiveDetailRepository() : super(db: _ResponsiveDetailDatabase());

  static final bodyPart = BodyPart(1, 'Upper Chest');
  static final muscle = Muscle(id: 1, name: 'Long Head Triceps');
  static final equipment = Equipment(1, 'High and Low Pulley');
  static final definition = ExerciseDefinition(
    id: 1,
    name: 'Overhead Cable Press',
    equipmentList: [equipment],
    bodyParts: [bodyPart],
    muscles: [RankedMuscle(muscle: muscle, rank: 1)],
    useManualBodyparts: false,
    multiplyByRating: false,
  );

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => [definition];

  @override
  Future<List<Muscle>> fetchAllMuscles() async => [muscle];

  @override
  Future<List<MuscleBodyPart>> fetchMusclesForBodyPart(int bodypartId) async =>
      [MuscleBodyPart(muscleId: muscle.id, bodyPartId: bodyPart.id)];

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => [bodyPart];

  @override
  Future<List<MuscleBodyPart>> fetchBodyPartsForMuscle(int muscleId) async => [
    MuscleBodyPart(muscleId: muscle.id, bodyPartId: bodyPart.id),
  ];

  @override
  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async => {bodyPart: 8.5};

  @override
  Future<Map<int, double>> fetchSetsPerMuscle({
    required DateTime start,
    required DateTime end,
  }) async => {muscle.id: 6.5};

  @override
  Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) async =>
      null;

  @override
  Future<VolumeBoundaries?> fetchMuscleVolumeBounds(int muscleId) async => null;

  @override
  Future<void> ensureSharedMediaManifestReady() async {}

  @override
  Future<SharedMediaItem?> fetchPrimarySharedMedia(
    SharedMediaEntityType entityType,
    int entityId,
  ) async => null;

  @override
  Stream<ContentMediaCacheChange> get mediaCacheChanges =>
      const Stream<ContentMediaCacheChange>.empty();
}

class _ResponsiveDetailDatabase implements DatabaseHelper {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
