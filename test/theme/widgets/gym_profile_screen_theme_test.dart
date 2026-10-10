import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/content_models.dart';
import 'package:env_test/models/definition_models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/content_repository.dart';
import 'package:env_test/screens/exercise/gym_profile_screen.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/expressive_planning_tokens.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/shared_entity_media_thumbnail.dart';

ToggleablePainter _toggleablePainter(WidgetTester tester, Finder control) {
  final paintFinder = find.descendant(
    of: control,
    matching: find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is ToggleablePainter,
    ),
  );
  expect(paintFinder, findsOneWidget);
  return tester.widget<CustomPaint>(paintFinder).painter! as ToggleablePainter;
}

void _focusToggleable(WidgetTester tester, Finder control) {
  final paintFinder = find.descendant(
    of: control,
    matching: find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is ToggleablePainter,
    ),
  );
  Focus.of(tester.element(paintFinder)).requestFocus();
}

void main() {
  final themes = <String, ThemeData>{
    'Classic light': ClassicThemeDefinition.light(),
    'Classic dark': ClassicThemeDefinition.dark(),
    'Neo light': NeoBrutalismThemeDefinition.light(),
    'Neo dark': NeoBrutalismThemeDefinition.dark(),
    'Expressive light': ExpressiveThemeDefinition.light(),
    'Expressive dark': ExpressiveThemeDefinition.dark(),
  };

  for (final entry in themes.entries) {
    testWidgets('${entry.key} gym profile recipes and draft behavior', (
      tester,
    ) async {
      final previousHighlightStrategy = FocusManager.instance.highlightStrategy;
      final expressive = entry.key.startsWith('Expressive');
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = previousHighlightStrategy;
      });
      await tester.binding.setSurfaceSize(Size(expressive ? 320 : 420, 980));
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
            builder: (context, child) => expressive
                ? MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: const TextScaler.linear(2)),
                    child: child!,
                  )
                : child!,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () async {
                      savedDraft = await Navigator.of(context)
                          .push<GymProfileDraft>(
                            MaterialPageRoute(
                              builder: (_) => const GymProfileScreen(
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
      final planning = AppExpressivePlanningTokens.maybeOf(pageContext);
      final profileSurface =
          planning?.planFocalSurface ??
          (neo
              ? surfaces.settingsSection
              : scheme.surfaceContainerHighest.withValues(alpha: 0.42));
      final sectionSurface =
          planning?.equipmentSurface ??
          (neo
              ? surfaces.settingsSection
              : scheme.surfaceContainerHighest.withValues(alpha: 0.28));
      final fieldSurface =
          planning?.equipmentSurface ??
          (neo
              ? surfaces.settingsInput
              : scheme.surfaceContainerHighest.withValues(alpha: 0.48));
      final selectedTileSurface =
          planning?.selectedSurface ??
          (neo
              ? surfaces.settingsInput
              : scheme.primary.withValues(alpha: 0.18));
      final unselectedTileSurface =
          planning?.planSupportSurface ??
          (neo
              ? surfaces.settingsSection
              : scheme.surface.withValues(alpha: 0.34));
      final selectedTileOutline =
          planning?.outline ??
          (neo
              ? tonosOutlineForSurface(pageContext, surfaces.settingsInput)
              : scheme.primary.withValues(alpha: 0.6));
      final unselectedTileOutline =
          planning?.outline ??
          (neo
              ? tonosOutlineForSurface(pageContext, surfaces.settingsSection)
              : scheme.outlineVariant.withValues(alpha: 0.34));

      final pageScaffold = tester.widget<Scaffold>(
        find.descendant(
          of: find.byType(GymProfileScreen),
          matching: find.byType(Scaffold),
        ),
      );
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(pageScaffold.backgroundColor, planning?.pageCanvas);
      expect(appBar.backgroundColor, planning?.planSupportSurface);
      expect(appBar.foregroundColor, planning?.planSupportForeground);

      final nameDecoration = tester
          .widgetList<InputDecorator>(find.byType(InputDecorator))
          .map((decorator) => decorator.decoration)
          .singleWhere(
            (decoration) => decoration.labelText == strings.gymProfileName,
          );
      expect(
        nameDecoration.fillColor,
        planning?.planSupportSurface ??
            (neo
                ? surfaces.settingsInput
                : scheme.surface.withValues(alpha: 0.45)),
      );
      expect(
        (nameDecoration.border! as OutlineInputBorder).borderRadius,
        planning != null
            ? planning.rowShape
            : neo
            ? shapes.settingsField
            : BorderRadius.circular(16),
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
        planning != null
            ? planning.rowShape
            : neo
            ? shapes.settingsPicker
            : const BorderRadius.all(Radius.circular(999)),
      );
      expect(
        searchDecoration.hintStyle?.color,
        planning != null
            ? planning.equipmentForeground.withValues(alpha: 0.72)
            : neo
            ? tonosForegroundForSurface(
                pageContext,
                fieldSurface,
              ).withValues(alpha: 0.62)
            : null,
      );

      List<BoxDecoration> currentDecorations() => tester
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
                  (planning != null
                      ? planning.focalShape
                      : neo
                      ? shapes.settingsPanel
                      : BorderRadius.circular(24)),
        ),
        isNotEmpty,
      );
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();
      final visibleSectionDecorations = currentDecorations();
      expect(
        visibleSectionDecorations.where(
          (decoration) =>
              decoration.color == sectionSurface &&
              decoration.borderRadius ==
                  (planning != null
                      ? planning.supportShape
                      : neo
                      ? shapes.settingsPanel
                      : BorderRadius.circular(22)),
        ),
        planning != null ? isNotEmpty : hasLength(neo ? 4 : 3),
      );
      expect(
        decorations.any(
          (decoration) =>
              decoration.shape == BoxShape.circle &&
              decoration.color ==
                  (planning?.planAccent ??
                      (neo
                          ? surfaces.dialogChoice
                          : scheme.primaryContainer.withValues(alpha: 0.75))),
        ),
        isTrue,
      );

      final thumbnails = tester
          .widgetList<SharedEntityMediaThumbnail>(
            find.byType(SharedEntityMediaThumbnail),
          )
          .toList();
      if (expressive) {
        expect(thumbnails, isNotEmpty);
        expect(thumbnails.first.backgroundColor, selectedTileSurface);
        expect(
          thumbnails.skip(1).map((thumbnail) => thumbnail.backgroundColor),
          everyElement(unselectedTileSurface),
        );
        expect(thumbnails.first.borderColor, selectedTileOutline);
        expect(
          thumbnails.skip(1).map((thumbnail) => thumbnail.borderColor),
          everyElement(unselectedTileOutline),
        );
        expect(
          tester.widget<Text>(find.text('Barbell')).style?.color,
          planning!.equipmentForeground,
        );
        expect(
          tester
              .widget<Text>(find.text(strings.equipmentFreeWeightTraining))
              .style
              ?.color,
          planning.equipmentForeground,
        );
      } else {
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
      }
      expect(
        thumbnails.map((thumbnail) => thumbnail.borderRadius),
        everyElement(BorderRadius.circular(planning == null ? 11 : 14)),
      );
      final checkboxFinder = find.byType(Checkbox);
      final checkboxes = tester.widgetList<Checkbox>(checkboxFinder).toList();
      if (expressive) {
        expect(checkboxes, isNotEmpty);
        expect(checkboxes.first.value, isTrue);
        expect(checkboxes.skip(1).map((box) => box.value), everyElement(false));
      } else {
        expect(checkboxes.map((box) => box.value), [true, false, false]);
      }
      expect(checkboxes.every((box) => box.onChanged != null), isTrue);
      final neoCheckboxFill = tonosForegroundForSurface(
        pageContext,
        surfaces.dialogChoice,
      );
      if (neo) {
        final sharedCheckboxFill = Theme.of(pageContext)
            .checkboxTheme
            .fillColor!;
        expect(
          sharedCheckboxFill.resolve({WidgetState.selected}),
          isNot(neoCheckboxFill),
        );
        expect(
          sharedCheckboxFill.resolve(const <WidgetState>{}),
          Colors.transparent,
        );
      }
      for (var index = 0; index < checkboxes.length; index++) {
        final checkbox = checkboxes[index];
        final painter = _toggleablePainter(tester, checkboxFinder.at(index));
        expect(painter.position.value, checkbox.value == true ? 1 : 0);
        expect(
          painter.activeColor,
          planning != null
              ? (checkbox.value == true
                    ? planning.actionPrimary
                    : planning.planSupportSurface)
              : neo
              ? neoCheckboxFill
              : scheme.primary,
        );
        expect(
          painter.inactiveColor,
          planning != null
              ? (checkbox.value == true
                    ? planning.actionPrimary
                    : planning.planSupportSurface)
              : neo
              ? neoCheckboxFill
              : Colors.transparent,
        );
        if (neo) {
          expect(
            checkbox.fillColor?.resolve({WidgetState.selected}),
            neoCheckboxFill,
          );
          expect(
            checkbox.fillColor?.resolve(const <WidgetState>{}),
            neoCheckboxFill,
          );
          expect(checkbox.checkColor, surfaces.dialogChoice);
        } else if (planning != null) {
          expect(
            checkbox.fillColor?.resolve({WidgetState.selected}),
            checkbox.value == true
                ? planning.actionPrimary
                : planning.planSupportSurface,
          );
          expect(checkbox.checkColor, planning.actionPrimaryForeground);
        } else {
          expect(checkbox.fillColor, isNull);
          expect(checkbox.checkColor, isNull);
        }
      }

      final focusedCheckbox = checkboxFinder.at(0);
      _focusToggleable(tester, focusedCheckbox);
      await tester.pumpAndSettle();
      final focusedPainter = _toggleablePainter(tester, focusedCheckbox);
      expect(focusedPainter.isFocused, isTrue);
      expect(
        focusedPainter.activeColor,
        planning != null
            ? planning.actionPrimary
            : neo
            ? neoCheckboxFill
            : scheme.primary,
      );
      expect(
        focusedPainter.inactiveColor,
        planning != null
            ? planning.actionPrimary
            : neo
            ? neoCheckboxFill
            : Colors.transparent,
      );

      final saveSurface =
          planning?.planSupportSurface ??
          (neo
              ? surfaces.settingsSaveBar
              : scheme.surface.withValues(alpha: 0.96));
      final saveDecoration = decorations.singleWhere(
        (decoration) =>
            decoration.color == saveSurface &&
            decoration.borderRadius ==
                (planning != null
                    ? planning.supportShape
                    : neo
                    ? shapes.actionBar
                    : BorderRadius.zero),
      );
      final saveBorder = saveDecoration.border! as Border;
      expect(
        saveBorder.top.color,
        planning?.outline ??
            (neo
                ? tonosOutlineForSurface(pageContext, surfaces.settingsSaveBar)
                : scheme.outlineVariant),
      );
      expect(saveBorder.top.width, neo ? shapes.outlineWidth : 1);

      if (planning != null) {
        await tester.drag(find.byType(ListView), const Offset(0, 1200));
        await tester.pumpAndSettle();
      }
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

      await tester.ensureVisible(searchFinder);
      await tester.enterText(searchFinder, 'no matching equipment');
      await tester.pumpAndSettle();
      if (planning != null) {
        await tester.drag(find.byType(ListView), const Offset(0, -1000));
        await tester.pumpAndSettle();
      }
      expect(
        find.text(strings.gymProfileNoEquipmentMatch('no matching equipment')),
        findsOneWidget,
      );
      final emptyDecorations = currentDecorations();
      final emptySurface =
          planning?.configurationSurface ??
          (neo
              ? surfaces.panel
              : scheme.surfaceContainerHighest.withValues(alpha: 0.32));
      expect(
        emptyDecorations.any(
          (decoration) =>
              decoration.color == emptySurface &&
              decoration.borderRadius ==
                  (planning != null
                      ? planning.supportShape
                      : BorderRadius.circular(20)) &&
              (planning != null
                  ? decoration.border == Border.all(color: planning.outline)
                  : neo
                  ? decoration.border != null
                  : decoration.border == null),
        ),
        isTrue,
      );

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

  for (final entry in <String, ThemeData>{
    'Classic': ClassicThemeDefinition.light(),
    'Neo': NeoBrutalismThemeDefinition.light(),
  }.entries) {
    testWidgets(
      '${entry.key} compact gym profile keeps header actions in one row',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 980));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.gym_profile_editor_v1': true,
        });

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: _GymProfileRepository()),
            ],
            child: MaterialApp(
              locale: const Locale('en'),
              theme: entry.value,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const GymProfileScreen(
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
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
        final strings = AppLocalizations.of(
          tester.element(find.byType(GymProfileScreen)),
        );
        final resetRect = tester.getRect(
          find.widgetWithText(TextButton, strings.commonReset),
        );
        final selectAllRect = tester.getRect(
          find.widgetWithText(FilledButton, strings.gymProfileSelectAll),
        );

        expect(resetRect.top, selectAllRect.top);
        expect(resetRect.right, lessThanOrEqualTo(selectAllRect.left));

        await tester.drag(find.byType(ListView), const Offset(0, -1000));
        await tester.pumpAndSettle();
        final selectedCountLabel = find.text(
          strings.gymProfileSelectedCount(1, 1),
        );
        expect(selectedCountLabel, findsOneWidget);
        final categoryRow = find
            .ancestor(of: selectedCountLabel, matching: find.byType(Row))
            .first;
        final categoryAction = find.descendant(
          of: categoryRow,
          matching: find.widgetWithText(TextButton, strings.gymProfileClear),
        );
        expect(categoryAction, findsOneWidget);
        expect(
          tester.getCenter(selectedCountLabel).dy,
          closeTo(tester.getCenter(categoryAction).dy, 1),
        );
        expect(tester.takeException(), isNull);
      },
    );
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
