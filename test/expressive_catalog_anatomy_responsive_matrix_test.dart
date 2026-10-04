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
import 'package:env_test/screens/exercise/muscle_filter_page.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final brightness in Brightness.values) {
    for (final textScale in <double>[1, 1.15, 1.5, 2]) {
      for (final width in <double>[320, 411]) {
        testWidgets('Expressive Catalog and anatomy browse remain usable at '
            '${width.toInt()} dp, ${brightness.name}, ${textScale}x text', (
          tester,
        ) async {
          await tester.binding.setSurfaceSize(
            Size(width, width == 411 ? 914 : 780),
          );
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
          expect(find.text(strings.catalogTargetAnatomyTitle), findsOneWidget);
          expect(find.text('Bench Press'), findsOneWidget);
          expect(find.text('Chest'), findsOneWidget);
          expect(tester.takeException(), isNull);

          if (brightness == Brightness.light && textScale == 1) {
            // Follow the existing root -> anatomy library workflow once to
            // verify that only the Catalog route opts into this treatment.
            await tester.ensureVisible(find.text(strings.catalogBodyparts));
            await tester.tap(find.text(strings.catalogBodyparts));
            await _settle(tester);
            expect(find.byType(MuscleFilterPage), findsOneWidget);
            expect(
              tester
                  .widget<MuscleFilterPage>(find.byType(MuscleFilterPage))
                  .expressiveCatalogPresentation,
              isTrue,
            );
          }
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }

  for (final brightness in Brightness.values) {
    for (final textScale in <double>[1, 1.15, 1.5, 2]) {
      testWidgets('Expressive anatomy list search stays usable at 320 dp, '
          '${brightness.name}, ${textScale}x text', (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 780));
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
              home: const MuscleFilterPage(expressiveCatalogPresentation: true),
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
          reason: 'The anatomy search needs a discoverable accessible label.',
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
      });
    }
  }
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
  static final equipment = Equipment(1, 'Barbell');
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
      equipmentList: [equipment],
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
