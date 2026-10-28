import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/db/database_helper.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/theme/widgets/tonos_expressive_inset_accordion.dart';
import 'package:env_test/widgets/exercise_definition_info_tile.dart';
import 'package:env_test/widgets/exercise_detail_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final brightness in Brightness.values) {
    for (final caller in [
      'Browser',
      'Anatomy',
      'Analytics anatomy',
      'Plan/workout default',
      'History',
      'Progress',
    ]) {
      testWidgets(
        'Expressive $caller media and heatmap stay compact at 320dp ${brightness.name}',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(320, 780));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          SharedPreferences.setMockInitialValues({
            'guided_tutorial_completed.exercise_detail_v1': true,
          });
          final tempDir = (await tester.runAsync(
            () => Directory.systemTemp.createTemp('tonos-detail-media-'),
          ))!;
          addTearDown(() async {
            await tester.runAsync(() => tempDir.delete(recursive: true));
          });
          final previewFile = File(
            '${tempDir.path}${Platform.pathSeparator}preview.png',
          );
          await tester.runAsync(
            () => previewFile.writeAsBytes(
              base64Decode(
                'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jv4sAAAAASUVORK5CYII=',
              ),
            ),
          );

          final repository = _MediaRepository(previewFile: previewFile);
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
              ],
              child: MaterialApp(
                theme: brightness == Brightness.dark
                    ? ExpressiveThemeDefinition.dark()
                    : ExpressiveThemeDefinition.light(),
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: caller == 'Anatomy' || caller == 'Analytics anatomy'
                    ? AppExpressiveDestinationTheme(
                        family: caller == 'Anatomy'
                            ? AppExpressiveDestinationFamily.catalog
                            : AppExpressiveDestinationFamily.analytics,
                        child: Scaffold(
                          body: ExerciseDefinitionInfoTile(
                            definition: _definition,
                            subtitle: const Text('Strength'),
                            expressiveCatalogPresentation: caller == 'Anatomy',
                          ),
                        ),
                      )
                    : caller == 'History' || caller == 'Progress'
                    ? AppExpressiveDestinationTheme(
                        family: caller == 'History'
                            ? AppExpressiveDestinationFamily.logbook
                            : AppExpressiveDestinationFamily.progress,
                        child: _BrowserCaller(
                          definition: _definition,
                          explicitCatalog: false,
                        ),
                      )
                    : _BrowserCaller(
                        definition: _definition,
                        explicitCatalog: caller == 'Browser',
                      ),
              ),
            ),
          );

          if (caller == 'Anatomy' || caller == 'Analytics anatomy') {
            final strings = AppLocalizations.of(
              tester.element(find.byType(ExerciseDefinitionInfoTile)),
            );
            await tester.tap(find.byTooltip(strings.catalogOpenExerciseInfo));
          } else {
            await tester.tap(find.text('Open details'));
          }
          await _settle(tester);
          final sheet = tester.widget<ExerciseDetailSheet>(
            find.byType(ExerciseDetailSheet),
          );
          expect(sheet.expressiveCatalogPresentation, isTrue);
          expect(sheet.catalogBrowserDetailRefinement, isTrue);
          expect(find.byType(TonosExpressiveInsetAccordion), findsNWidgets(3));
          expect(
            Theme.of(tester.element(find.byType(ExerciseDetailSheet)))
                .extension<AppExpressiveDestinationTokens>()
                ?.family,
            AppExpressiveDestinationFamily.catalog,
          );

          final media = find.byKey(
            const ValueKey('exercise-detail-expressive-media-preview'),
          );
          final image = find.descendant(
            of: media,
            matching: find.byType(Image),
          );
          expect(media, findsOneWidget);
          expect(image, findsOneWidget);
          expect(tester.widget<Image>(image).fit, BoxFit.cover);
          expect(tester.getRect(image), tester.getRect(media));
          final titlePill = find.byKey(
            const ValueKey('exercise-detail-expressive-title-pill'),
          );
          final closeButton = find.byKey(
            const ValueKey('exercise-detail-expressive-close-button'),
          );
          final destination = AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.catalog,
            brightness,
          );
          expect(titlePill, findsOneWidget);
          expect(closeButton, findsOneWidget);
          expect(
            (tester.widget<DecoratedBox>(titlePill).decoration as BoxDecoration)
                .color,
            destination.surfacePrimary,
          );
          expect(
            (tester.widget<DecoratedBox>(closeButton).decoration
                    as BoxDecoration)
                .color,
            destination.surfacePrimary,
          );
          expect(
            tester.getCenter(titlePill).dx,
            closeTo(tester.getSize(find.byType(Scaffold).first).width / 2, 0.5),
          );
          expect(tester.getSize(media).height, greaterThan(180));
          final strings = AppLocalizations.of(tester.element(media));

          await tester.tap(media);
          await _settle(tester);
          final viewer = find.byKey(const ValueKey('expressive-media-viewer'));
          expect(viewer, findsOneWidget);
          expect(
            find.descendant(
              of: viewer,
              matching: find.byType(TonosExpressiveInsetAccordion),
            ),
            findsNothing,
            reason: 'The static image-viewer guide retains its existing layout',
          );
          expect(tester.getSize(viewer), const Size(320, 780));
          final interactiveViewer = find.descendant(
            of: viewer,
            matching: find.byType(InteractiveViewer),
          );
          expect(interactiveViewer, findsOneWidget);
          final viewerState = tester.widget<InteractiveViewer>(
            interactiveViewer,
          );
          expect(viewerState.minScale, 1);
          expect(viewerState.maxScale, 4);
          expect(viewerState.boundaryMargin, EdgeInsets.zero);
          expect(
            find.descendant(
              of: viewer,
              matching: find.text(strings.exerciseDetailZoomPanHint),
            ),
            findsOneWidget,
          );
          final transformation = viewerState.transformationController!;
          final imageCenter = tester.getCenter(interactiveViewer);
          final first = await tester.startGesture(
            imageCenter - const Offset(30, 0),
            pointer: 1,
          );
          final second = await tester.startGesture(
            imageCenter + const Offset(30, 0),
            pointer: 2,
          );
          await tester.pump();
          await first.moveTo(imageCenter - const Offset(80, 0));
          await second.moveTo(imageCenter + const Offset(80, 0));
          await tester.pump();
          expect(transformation.value.getMaxScaleOnAxis(), greaterThan(1));
          await first.up();
          await second.up();
          await tester.pumpAndSettle();

          final beforePan = transformation.value.getTranslation().clone();
          final pan = await tester.startGesture(imageCenter, pointer: 3);
          await tester.pump();
          await pan.moveBy(const Offset(0, 40));
          await tester.pump();
          await pan.moveBy(const Offset(0, 40));
          await pan.up();
          await tester.pumpAndSettle();
          expect(transformation.value.getTranslation(), isNot(beforePan));
          transformation.value = Matrix4.identity();
          await tester.pumpAndSettle();

          expect(
            find.descendant(
              of: viewer,
              matching: find.text(strings.exerciseDetailFormGuide),
            ),
            findsOneWidget,
          );
          for (final heading in [
            strings.exerciseDetailSetup,
            strings.exerciseDetailExecution,
            strings.exerciseDetailTips,
          ]) {
            expect(
              find.descendant(of: viewer, matching: find.text(heading)),
              findsOneWidget,
            );
          }
          await tester.binding.setSurfaceSize(const Size(320, 600));
          await _settle(tester);
          final title = find.byKey(
            const ValueKey('expressive-media-viewer-title'),
          );
          final titleTop = tester.getTopLeft(title).dy;
          final imageTop = tester.getTopLeft(interactiveViewer).dy;
          await tester.drag(interactiveViewer, const Offset(0, -80));
          await tester.pumpAndSettle();
          expect(tester.getTopLeft(interactiveViewer).dy, lessThan(imageTop));
          await tester.ensureVisible(
            find.descendant(
              of: viewer,
              matching: find.text(strings.exerciseDetailTips),
            ),
          );
          await _settle(tester);
          expect(tester.getTopLeft(title).dy, titleTop);
          expect(tester.takeException(), isNull);
          await tester.binding.setSurfaceSize(const Size(320, 780));
          await _settle(tester);
          expect(
            find.descendant(
              of: viewer,
              matching: find.byKey(
                const ValueKey('expressive-media-viewer-title'),
              ),
            ),
            findsOneWidget,
          );
          await tester.tapAt(const Offset(8, 8));
          await _settle(tester);
          expect(viewer, findsOneWidget);
          await tester.tap(
            find.descendant(
              of: viewer,
              matching: find.byTooltip(strings.commonClose),
            ),
          );
          await _settle(tester);
          expect(viewer, findsNothing);
          expect(find.text(strings.exerciseDetailTabDetails), findsOneWidget);
          expect(find.text(strings.exerciseDetailFormGuide), findsOneWidget);
          expect(
            find.text(strings.exerciseDetailTargetAnatomy),
            findsOneWidget,
          );
          expect(repository.requestedThumbnailModes, contains(false));

          final heatmap = find.byKey(
            const ValueKey('exercise-detail-expressive-heatmap-overlay'),
          );
          final overview = find.byKey(
            const ValueKey('exercise-detail-catalog-overview'),
          );
          final overviewHeatmap = find.byKey(
            const ValueKey('exercise-detail-catalog-overview-heatmap'),
          );
          expect(heatmap, findsOneWidget);
          expect(overview, findsNothing);
          expect(overviewHeatmap, findsNothing);
          expect(tester.takeException(), isNull);

          await tester.tap(heatmap);
          await _settle(tester);
          expect(find.byType(InteractiveViewer), findsOneWidget);
          expect(tester.takeException(), isNull);
          Navigator.of(tester.element(find.byType(InteractiveViewer))).pop();
          await _settle(tester);
          Navigator.of(tester.element(find.byType(ExerciseDetailSheet))).pop();
          await _settle(tester);
          expect(find.byType(ExerciseDetailSheet), findsNothing);
          expect(
            caller == 'Anatomy' || caller == 'Analytics anatomy'
                ? find.byType(ExerciseDefinitionInfoTile)
                : find.text('Open details'),
            findsOneWidget,
          );
        },
      );
    }

    testWidgets(
      'Catalog missing media keeps the corner heatmap access ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 780));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.exercise_detail_v1': true,
        });
        final repository = _MediaRepository(previewFile: null);
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
            ],
            child: MaterialApp(
              theme: brightness == Brightness.dark
                  ? ExpressiveThemeDefinition.dark()
                  : ExpressiveThemeDefinition.light(),
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: _BrowserCaller(definition: _definition),
            ),
          ),
        );
        await tester.tap(find.text('Open details'));
        await _settle(tester);

        final media = find.byKey(
          const ValueKey('exercise-detail-expressive-media-preview'),
        );
        expect(media, findsOneWidget);
        expect(
          find.descendant(
            of: media,
            matching: find.byIcon(Icons.image_not_supported_outlined),
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(
            const ValueKey('exercise-detail-expressive-heatmap-overlay'),
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(
            const ValueKey('exercise-detail-catalog-overview-heatmap'),
          ),
          findsNothing,
        );
        expect(
          find.text(
            AppLocalizations.of(
              tester.element(find.byType(ExerciseDetailSheet)),
            ).exerciseDetailTargetAnatomy,
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final family in [AppThemeFamily.classic, AppThemeFamily.neoBrutalism]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'Default detail caller preserves $family ${brightness.name}',
        (tester) async {
          SharedPreferences.setMockInitialValues({
            'guided_tutorial_completed.exercise_detail_v1': true,
          });
          final units = UnitPreferenceProvider();
          addTearDown(units.dispose);
          await units.ready;
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(
                  value: _MediaRepository(previewFile: null),
                ),
                ChangeNotifierProvider<UnitPreferenceProvider>.value(
                  value: units,
                ),
              ],
              child: MaterialApp(
                theme: brightness == Brightness.light
                    ? AppThemeFactory.light(family)
                    : AppThemeFactory.dark(family),
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: _BrowserCaller(
                  definition: _definition,
                  explicitCatalog: false,
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open details'));
          await _settle(tester);
          final sheet = tester.widget<ExerciseDetailSheet>(
            find.byType(ExerciseDetailSheet),
          );
          expect(sheet.expressiveCatalogPresentation, isFalse);
          expect(sheet.catalogBrowserDetailRefinement, isFalse);
          expect(find.byType(TonosExpressiveInsetAccordion), findsNothing);
          expect(
            find.byKey(const ValueKey('exercise-detail-expressive-title-pill')),
            findsNothing,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

final ExerciseDefinition _definition = ExerciseDefinition(
  id: 1,
  name: 'Goblet Squat',
  equipmentList: const [],
  bodyParts: [BodyPart(1, 'Chest')],
  muscles: const [],
  setupNotes: 'Hold the weight close to your chest.',
  executionNotes: 'Lower under control, then stand tall.',
  tipsNotes: 'Keep your feet planted.',
  useManualBodyparts: false,
  multiplyByRating: false,
);

class _BrowserCaller extends StatelessWidget {
  const _BrowserCaller({required this.definition, this.explicitCatalog = true});

  final ExerciseDefinition definition;
  final bool explicitCatalog;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => ExerciseDetailSheet.show(
          context: context,
          definition: definition,
          defId: definition.id,
          expressiveCatalogPresentation: explicitCatalog,
          catalogBrowserDetailRefinement: explicitCatalog,
        ),
        child: const Text('Open details'),
      ),
    ),
  );
}

class _MediaRepository extends AppRepository {
  _MediaRepository({required this.previewFile}) : super(db: _MediaDatabase());

  final File? previewFile;
  final List<bool> requestedThumbnailModes = [];

  @override
  Future<ContentManifest> syncBundledExerciseMediaManifest() async {
    throw UnimplementedError();
  }

  @override
  Future<ExerciseMediaItem?> fetchPrimaryExerciseMedia(int defId) async =>
      previewFile == null
      ? null
      : ExerciseMediaItem(
          exerciseDefId: defId,
          mediaType: 'image',
          remoteUrl: 'preview.png',
          thumbnailUrl: 'preview.png',
        );

  @override
  Future<File?> cachedExerciseMediaFile(
    ExerciseMediaItem item, {
    required bool thumbnail,
  }) async {
    requestedThumbnailModes.add(thumbnail);
    return previewFile;
  }

  @override
  Future<Map<int, WorkoutExerciseRecordBadges>>
  fetchCurrentExerciseRecordBadges(int definitionId) async => {};

  @override
  Future<List<Map<String, dynamic>>> fetchRecentWeightExerciseHistoryRows({
    required int definitionId,
    int? beforeCompletedAtMilliseconds,
    int? beforeExerciseId,
    int limit = 10,
  }) async => [];

  @override
  Future<List<RepMaxRow>> fetchRepMaxes(int defId, String timeframe) async =>
      [];

  @override
  Future<double?> fetchVolumeMax(int defId, String timeframe) async => null;
}

class _MediaDatabase implements DatabaseHelper {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
}
