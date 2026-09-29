import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/content_repository.dart';
import 'package:env_test/screens/catalog_page.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/widgets/exercise_media_thumbnail.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.dark
              ? AppThemeFactory.dark(family)
              : AppThemeFactory.light(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode Catalog overview uses catalog shape owners', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.catalog_home_v1': true,
        });

        final repository = _CatalogRepository();
        final activeSession = ActiveSession(repository: repository);
        addTearDown(activeSession.dispose);
        await activeSession.ready;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<ActiveSession>.value(value: activeSession),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const CatalogPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final isNeo = family == AppThemeFamily.neoBrutalism;
        final context = tester.element(find.byType(CatalogPage));
        final shapes = context.shapeTokens;
        final surfaces = context.surfaceTokens;
        final effects = context.effectTokens;
        expect(shapes.catalogUsageRow, BorderRadius.circular(isNeo ? 4 : 14));
        expect(shapes.catalogUsageMedia, BorderRadius.circular(isNeo ? 4 : 12));
        expect(shapes.catalogFocusPane, BorderRadius.circular(isNeo ? 4 : 16));

        expect(find.text('Bench Press'), findsOneWidget);
        expect(
          find.byType(TonosSurface),
          isNeo ? findsNWidgets(2) : findsNothing,
        );
        expect(find.byType(Card), isNeo ? findsNothing : findsNWidgets(2));

        final rowColor =
            isNeo ? surfaces.catalogSelection : surfaces.catalogUsage;
        final usageRows =
            tester.widgetList<Container>(find.byType(Container)).where((row) {
              final decoration = row.decoration;
              return decoration is BoxDecoration &&
                  decoration.color == rowColor;
            }).toList();
        expect(usageRows, hasLength(1));

        final rowDecoration = usageRows.single.decoration! as BoxDecoration;
        expect(rowDecoration.borderRadius, shapes.catalogUsageRow);
        final rowBorder = rowDecoration.border! as Border;
        expect(rowBorder.top.width, shapes.outlineWidth);
        expect(
          rowBorder.top.color,
          isNeo
              ? tonosOutlineForSurface(context, rowColor)
              : surfaces.catalogOutline,
        );
        if (isNeo) {
          expect(rowDecoration.boxShadow, hasLength(1));
          expect(rowDecoration.boxShadow!.single.color, effects.cardShadow);
          expect(
            rowDecoration.boxShadow!.single.offset,
            effects.cardShadowOffset,
          );
        } else {
          expect(rowDecoration.boxShadow, isNull);
        }

        final mediaFrame = tester.widget<ExerciseMediaFrame>(
          find.byType(ExerciseMediaFrame),
        );
        expect(mediaFrame.borderRadius, shapes.catalogUsageMedia);
        for (final paneLabel in ['Bodyparts', 'Muscles']) {
          final paneInkWells = tester
              .widgetList<InkWell>(
                find.ancestor(
                  of: find.text(paneLabel),
                  matching: find.byType(InkWell),
                ),
              )
              .where((inkWell) => inkWell.borderRadius != null);
          expect(
            paneInkWells.any(
              (inkWell) => inkWell.borderRadius == shapes.catalogFocusPane,
            ),
            isTrue,
            reason: '$paneLabel should use its catalog focus-pane radius.',
          );
        }

        expect(tester.takeException(), isNull);
      });
    }
  }
}

class _CatalogRepository extends AppRepository {
  final _definition = ExerciseDefinition(
    id: 7,
    name: 'Bench Press',
    equipmentList: [Equipment(1, 'Barbell')],
    useManualBodyparts: false,
    multiplyByRating: false,
  );

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];

  @override
  Future<List<Map<String, dynamic>>> fetchMostUsedExerciseDefinitionsRaw({
    int limit = 5,
  }) async => [
    {'definition_id': _definition.id, 'use_count': 3},
  ];

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailedByIds(
    List<int> definitionIds,
  ) async => definitionIds.contains(_definition.id) ? [_definition] : const [];

  @override
  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async => {BodyPart(1, 'Chest'): 2};

  @override
  Future<Map<int, double>> fetchSetsPerMuscle({
    required DateTime start,
    required DateTime end,
  }) async => {9: 3};

  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => [
    Muscle(id: 9, name: 'Pectorals'),
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
