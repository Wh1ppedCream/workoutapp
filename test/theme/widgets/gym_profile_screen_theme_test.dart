import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/content_models.dart';
import 'package:env_test/models/definition_models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/content_repository.dart';
import 'package:env_test/screens/exercise/gym_profile_screen.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/shared_entity_media_thumbnail.dart';

void main() {
  final themes = <String, ThemeData>{
    'Classic light': ClassicThemeDefinition.light(),
    'Classic dark': ClassicThemeDefinition.dark(),
    'Neo light': NeoBrutalismThemeDefinition.light(),
    'Neo dark': NeoBrutalismThemeDefinition.dark(),
  };

  for (final entry in themes.entries) {
    testWidgets('${entry.key} gym profile recipes and draft behavior', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(420, 980));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.gym_profile_editor_v1': true,
      });

      final repository = _GymProfileRepository();
      GymProfileDraft? savedDraft;
      await tester.pumpWidget(
        MultiProvider(
          providers: [Provider<AppRepository>.value(value: repository)],
          child: MaterialApp(
            locale: const Locale('en'),
            theme: entry.value,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: Center(
                      child: TextButton(
                        onPressed: () async {
                          savedDraft = await Navigator.of(
                            context,
                          ).push<GymProfileDraft>(
                            MaterialPageRoute(
                              builder:
                                  (_) => const GymProfileScreen(
                                    initialName: 'Home gym',
                                    initialEquipmentNames: {'Barbell'},
                                    returnDraftOnly: true,
                                  ),
                            ),
                          );
                        },
                        child: const Text('Open gym profile'),
                      ),
                    ),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open gym profile'));
      await tester.pumpAndSettle();

      final pageContext = tester.element(find.byType(GymProfileScreen));
      final strings = AppLocalizations.of(pageContext);
      final scheme = Theme.of(pageContext).colorScheme;
      final surfaces = pageContext.surfaceTokens;
      final shapes = pageContext.shapeTokens;
      final neo = entry.key.startsWith('Neo');
      final profileSurface =
          neo
              ? surfaces.settingsSection
              : scheme.surfaceContainerHighest.withValues(alpha: 0.42);
      final sectionSurface =
          neo
              ? surfaces.settingsSection
              : scheme.surfaceContainerHighest.withValues(alpha: 0.28);
      final fieldSurface =
          neo
              ? surfaces.settingsInput
              : scheme.surfaceContainerHighest.withValues(alpha: 0.48);
      final selectedTileSurface =
          neo ? surfaces.settingsInput : scheme.primary.withValues(alpha: 0.18);
      final unselectedTileSurface =
          neo
              ? surfaces.settingsSection
              : scheme.surface.withValues(alpha: 0.34);
      final selectedTileOutline =
          neo
              ? tonosOutlineForSurface(pageContext, surfaces.settingsInput)
              : scheme.primary.withValues(alpha: 0.6);
      final unselectedTileOutline =
          neo
              ? tonosOutlineForSurface(pageContext, surfaces.settingsSection)
              : scheme.outlineVariant.withValues(alpha: 0.34);

      final nameDecoration = tester
          .widgetList<InputDecorator>(find.byType(InputDecorator))
          .map((decorator) => decorator.decoration)
          .singleWhere(
            (decoration) => decoration.labelText == strings.gymProfileName,
          );
      expect(
        nameDecoration.fillColor,
        neo ? surfaces.settingsInput : scheme.surface.withValues(alpha: 0.45),
      );
      expect(
        (nameDecoration.border! as OutlineInputBorder).borderRadius,
        neo ? shapes.settingsField : BorderRadius.circular(16),
      );

      final searchFinder = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == strings.gymProfileFilterEquipment,
      );
      final searchField = tester.widget<TextField>(searchFinder);
      final searchDecoration = searchField.decoration!;
      expect(searchDecoration.fillColor, fieldSurface);
      expect(
        (searchDecoration.border! as OutlineInputBorder).borderRadius,
        neo
            ? shapes.settingsPicker
            : const BorderRadius.all(Radius.circular(999)),
      );
      expect(
        searchDecoration.hintStyle?.color,
        neo
            ? tonosForegroundForSurface(
              pageContext,
              fieldSurface,
            ).withValues(alpha: 0.62)
            : null,
      );

      List<BoxDecoration> currentDecorations() =>
          tester
              .widgetList<Container>(find.byType(Container))
              .map((container) => container.decoration)
              .whereType<BoxDecoration>()
              .toList();

      final decorations = currentDecorations();
      expect(
        decorations.where(
          (decoration) =>
              decoration.color == profileSurface &&
              decoration.borderRadius ==
                  (neo ? shapes.settingsPanel : BorderRadius.circular(24)),
        ),
        isNotEmpty,
      );
      expect(
        decorations.where(
          (decoration) =>
              decoration.color == sectionSurface &&
              decoration.borderRadius ==
                  (neo ? shapes.settingsPanel : BorderRadius.circular(22)),
        ),
        hasLength(neo ? 4 : 3),
      );
      expect(
        decorations.any(
          (decoration) =>
              decoration.shape == BoxShape.circle &&
              decoration.color ==
                  (neo
                      ? surfaces.dialogChoice
                      : scheme.primaryContainer.withValues(alpha: 0.75)),
        ),
        isTrue,
      );

      final thumbnails =
          tester
              .widgetList<SharedEntityMediaThumbnail>(
                find.byType(SharedEntityMediaThumbnail),
              )
              .toList();
      expect(thumbnails, hasLength(3));
      expect(thumbnails.map((thumbnail) => thumbnail.backgroundColor), [
        selectedTileSurface,
        unselectedTileSurface,
        unselectedTileSurface,
      ]);
      expect(thumbnails.map((thumbnail) => thumbnail.borderColor), [
        selectedTileOutline,
        unselectedTileOutline,
        unselectedTileOutline,
      ]);
      expect(
        thumbnails.map((thumbnail) => thumbnail.borderRadius),
        everyElement(BorderRadius.circular(11)),
      );
      expect(
        tester
            .widgetList<Checkbox>(find.byType(Checkbox))
            .map((box) => box.value),
        [true, false, false],
      );

      final saveSurface =
          neo
              ? surfaces.settingsSaveBar
              : scheme.surface.withValues(alpha: 0.96);
      final saveDecoration = decorations.singleWhere(
        (decoration) =>
            decoration.color == saveSurface &&
            decoration.borderRadius ==
                (neo ? shapes.actionBar : BorderRadius.zero),
      );
      final saveBorder = saveDecoration.border! as Border;
      expect(
        saveBorder.top.color,
        neo
            ? tonosOutlineForSurface(pageContext, surfaces.settingsSaveBar)
            : scheme.outlineVariant,
      );
      expect(saveBorder.top.width, neo ? shapes.outlineWidth : 1);

      await tester.tap(
        find.widgetWithText(FilledButton, strings.gymProfileSelectAll),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<Checkbox>(find.byType(Checkbox))
            .map((box) => box.value),
        everyElement(true),
      );

      await tester.enterText(searchFinder, 'no matching equipment');
      await tester.pumpAndSettle();
      expect(
        find.text(strings.gymProfileNoEquipmentMatch('no matching equipment')),
        findsOneWidget,
      );
      final emptyDecorations = currentDecorations();
      final emptySurface =
          neo
              ? surfaces.panel
              : scheme.surfaceContainerHighest.withValues(alpha: 0.32);
      expect(
        emptyDecorations.any(
          (decoration) =>
              decoration.color == emptySurface &&
              decoration.borderRadius == BorderRadius.circular(20) &&
              (neo ? decoration.border != null : decoration.border == null),
        ),
        isTrue,
      );

      await tester.enterText(searchFinder, '');
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, strings.gymProfileSave),
      );
      await tester.pumpAndSettle();

      expect(savedDraft?.name, 'Home gym');
      expect(savedDraft?.equipmentNames, {
        'Barbell',
        'Cable Attachment',
        'Smith Machine',
      });
      expect(tester.takeException(), isNull);
    });
  }
}

class _GymProfileRepository extends AppRepository {
  @override
  Future<List<Equipment>> fetchAllEquipment() async => [
    Equipment(1, 'Barbell'),
    Equipment(2, 'Cable Attachment'),
    Equipment(3, 'Smith Machine'),
  ];

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
