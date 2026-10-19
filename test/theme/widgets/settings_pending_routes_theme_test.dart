import 'package:env_test/db/database_helper.dart';
import 'package:env_test/db/database_maintenance.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/exercise_catalog_page.dart';
import 'package:env_test/screens/profile/settings/database_settings_page.dart';
import 'package:env_test/screens/profile/settings/exercise_editor_screen.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_dialog.dart';
import 'package:env_test/theme/widgets/tonos_field.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_support.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? AppThemeFactory.light(family)
          : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode Exercise Editor retains route and field ownership', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(390, 1800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.${TutorialIds.exerciseCatalog}': true,
        });

        final repository = _SettingsRoutesRepository();
        final selectedProfile = SelectedProfile(repository: repository);
        addTearDown(selectedProfile.dispose);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<SelectedProfile>.value(
                value: selectedProfile,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const ExerciseEditorScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final strings = AppLocalizations.of(
          tester.element(find.byType(ExerciseEditorScreen)),
        );

        void expectDarkNeoPopup(Finder option) {
          if (family != AppThemeFamily.neoBrutalism ||
              brightness != Brightness.dark) {
            return;
          }
          final popupContext = tester.element(option);
          final popupTheme = Theme.of(popupContext);
          final dialogSurface =
              popupTheme.dialogTheme.backgroundColor ??
              popupContext.surfaceTokens.dialog;
          expect(popupTheme.canvasColor, dialogSurface);
          expect(
            DefaultTextStyle.of(popupContext).style.color,
            tonosForegroundForSurface(popupContext, dialogSurface),
          );
        }

        InputDecorator inputDecoratorFor(Finder field) {
          final decorator = find.descendant(
            of: field,
            matching: find.byType(InputDecorator),
          );
          expect(decorator, findsOneWidget);
          return tester.widget<InputDecorator>(decorator);
        }

        void expectDarkNeoFocusedFormField(Finder field) {
          if (family != AppThemeFamily.neoBrutalism ||
              brightness != Brightness.dark) {
            return;
          }
          final fieldContext = tester.element(field);
          final decorator = inputDecoratorFor(field);
          expect(decorator.isFocused, isTrue);
          expect(decorator.decoration.filled, isTrue);
          expect(
            decorator.decoration.fillColor,
            fieldContext.surfaceTokens.dialogChoice,
          );
          final focusedBorder = decorator.decoration.focusedBorder;
          expect(focusedBorder, isA<OutlineInputBorder>());
          final border = focusedBorder! as OutlineInputBorder;
          expect(
            border.borderSide.color,
            fieldContext.semanticColors.focusRing,
          );
          expect(
            border.borderSide.width,
            fieldContext.shapeTokens.focusRingWidth,
          );
        }

        await tester.tap(find.text(strings.exerciseEditorCreateCustomTitle));
        await tester.pumpAndSettle();
        expect(find.byType(TonosDialogFrame), findsOneWidget);
        final customExerciseDialog = find.byType(AlertDialog).last;
        expect(
          find.descendant(
            of: customExerciseDialog,
            matching: find.text(strings.exerciseEditorCreateCustomTitle),
          ),
          findsOneWidget,
        );
        expect(
          find.text(strings.exerciseEditorCreateCustomBody),
          findsOneWidget,
        );
        final customNameField = find.byType(TextFormField).first;
        expect(
          inputDecoratorFor(customNameField).decoration.labelText,
          strings.exerciseEditorExerciseName,
        );
        expect(inputDecoratorFor(customNameField).isFocused, isTrue);
        expectDarkNeoFocusedFormField(customNameField);
        final equipmentDropdown = tester.widget<DropdownButtonFormField<int>>(
          find.byType(DropdownButtonFormField<int>),
        );
        expect(
          equipmentDropdown.decoration.labelText,
          strings.exerciseEditorEquipment,
        );
        await tester.tap(find.byType(DropdownButtonFormField<int>));
        await tester.pumpAndSettle();
        final equipmentOption = find.text('Barbell');
        expect(equipmentOption, findsOneWidget);
        expectDarkNeoPopup(equipmentOption);
        await tester.tap(equipmentOption);
        await tester.pumpAndSettle();
        expect(find.text('Barbell'), findsOneWidget);
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog).last,
            matching: find.text(strings.commonCancel),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(findTonosTooltip(strings.exerciseEditorChoose));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        expect(find.byType(ExerciseCatalogPage), findsOneWidget);
        await tester.tap(find.text(repository.definition.name));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        expect(findTonosTooltip(strings.commonAdd), findsOneWidget);
        await tester.tap(findTonosTooltip(strings.commonAdd));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();

        final editorContext = tester.element(find.byType(ExerciseEditorScreen));
        final shapes = editorContext.shapeTokens;
        final surfaces = editorContext.surfaceTokens;
        final usesOutlinedPanels =
            editorContext.surfaceDecorationTokens.panel.outlined;
        final themeData = Theme.of(editorContext);
        final tabSurface = usesOutlinedPanels
            ? surfaces.settingsSection
            : themeData.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.34,
              );
        final headerForeground = usesOutlinedPanels
            ? tonosForegroundForSurface(editorContext, surfaces.settingsSection)
            : themeData.colorScheme.onSurface;
        final tabBar = tester.widget<TabBar>(find.byType(TabBar));
        expect(tabBar.controller?.index, 0);
        expect(tabBar.indicatorSize, TabBarIndicatorSize.tab);
        expect(tabBar.dividerColor, Colors.transparent);
        expect(tabBar.labelPadding, const EdgeInsets.symmetric(horizontal: 4));
        expect(tabBar.labelStyle?.fontSize, 14);
        expect(tabBar.unselectedLabelStyle?.fontSize, 14);
        expect(
          tabBar.indicator,
          isA<BoxDecoration>().having(
            (decoration) => decoration.borderRadius,
            'route-owned tab indicator shape',
            shapes.settingsTabIndicator,
          ),
        );
        expect(
          tabBar.labelColor,
          usesOutlinedPanels
              ? tonosForegroundForSurface(
                  editorContext,
                  surfaces.settingsSection,
                )
              : SettingsAccent.advanced,
        );
        expect(
          (tabBar.indicator! as BoxDecoration).color,
          usesOutlinedPanels
              ? surfaces.dialogChoice
              : SettingsAccent.advanced.withValues(alpha: 0.20),
        );
        expect(
          tabBar.unselectedLabelColor,
          usesOutlinedPanels
              ? tonosSecondaryForegroundForSurface(
                  editorContext,
                  surfaces.settingsSection,
                )
              : editorContext.cs.onSurfaceVariant,
        );
        expect(
          tester.widgetList<Container>(find.byType(Container)).any((container) {
            final decoration = container.decoration;
            return decoration is BoxDecoration &&
                decoration.gradient is LinearGradient &&
                decoration.borderRadius == shapes.settingsTitleCard;
          }),
          isTrue,
          reason: '$mode title card should keep token-owned geometry.',
        );
        expect(find.text(strings.exerciseEditorTitle), findsOneWidget);
        final titleCard = tester.widget<Container>(
          find.byWidgetPredicate((widget) {
            if (widget is! Container || widget.decoration is! BoxDecoration) {
              return false;
            }
            final decoration = widget.decoration! as BoxDecoration;
            return decoration.borderRadius == shapes.settingsTitleCard &&
                decoration.gradient is LinearGradient;
          }),
        );
        final titleDecoration = titleCard.decoration! as BoxDecoration;
        final titleGradient = titleDecoration.gradient! as LinearGradient;
        expect(titleGradient.colors, [
          SettingsAccent.advanced.withValues(alpha: 0.26),
          surfaces.settingsHero,
        ]);
        expect(titleDecoration.borderRadius, shapes.settingsTitleCard);
        expect(
          (titleDecoration.border! as Border).top.color,
          SettingsAccent.advanced.withValues(alpha: 0.42),
        );

        final tabSurfaceContainer = tester.widget<Container>(
          find
              .ancestor(
                of: find.byType(TabBar),
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Container && widget.decoration is BoxDecoration,
                ),
              )
              .first,
        );
        final tabSurfaceDecoration =
            tabSurfaceContainer.decoration! as BoxDecoration;
        expect(tabSurfaceDecoration.color, tabSurface);
        expect(tabSurfaceDecoration.borderRadius, shapes.profileTile);
        if (usesOutlinedPanels) {
          expect(
            (tabSurfaceDecoration.border! as Border).top.color,
            tonosOutlineForSurface(editorContext, tabSurface),
          );
        } else {
          expect(tabSurfaceDecoration.border, isNull);
        }

        final headerContainer = tester.widget<Container>(
          find.byWidgetPredicate((widget) {
            if (widget is! Container || widget.child is! Row) return false;
            final decoration = widget.decoration;
            return decoration is BoxDecoration &&
                decoration.borderRadius == shapes.profileTile &&
                decoration.color == tabSurface;
          }),
        );
        final headerDecoration = headerContainer.decoration! as BoxDecoration;
        expect(
          (headerDecoration.border! as Border).top.color,
          usesOutlinedPanels
              ? tonosOutlineForSurface(editorContext, tabSurface)
              : SettingsAccent.advanced.withValues(alpha: 0.42),
        );
        final ratingBadge = tester.widget<Container>(
          find.byWidgetPredicate((widget) {
            if (widget is! Container || widget.child is! Text) return false;
            return (widget.child! as Text).data == '80/100';
          }),
        );
        final ratingDecoration = ratingBadge.decoration! as BoxDecoration;
        expect(ratingDecoration.borderRadius, shapes.control);
        expect(
          ratingDecoration.color,
          usesOutlinedPanels
              ? surfaces.dialogChoice
              : SettingsAccent.advanced.withValues(alpha: 0.16),
        );
        final ratingText = ratingBadge.child! as Text;
        expect(
          ratingText.style?.color,
          usesOutlinedPanels ? headerForeground : SettingsAccent.advanced,
        );
        expect(ratingText.style?.fontWeight, FontWeight.w900);

        final allocationLabel = find.text(strings.exerciseEditorExactSetCredit);
        expect(allocationLabel, findsOneWidget);
        final allocationMaterial = tester.widget<Material>(
          find
              .ancestor(of: allocationLabel, matching: find.byType(Material))
              .first,
        );
        expect(allocationMaterial.color, tabSurface);
        expect(allocationMaterial.borderRadius, shapes.settingsPanel);
        final allocationIconBadge = tester.widget<Container>(
          find.byWidgetPredicate((widget) {
            if (widget is! Container || widget.child is! Icon) return false;
            final decoration = widget.decoration;
            return decoration is BoxDecoration &&
                decoration.borderRadius == shapes.settingsAction &&
                (widget.child! as Icon).icon == Icons.tune;
          }),
        );
        final allocationBadgeDecoration =
            allocationIconBadge.decoration! as BoxDecoration;
        expect(
          allocationBadgeDecoration.color,
          SettingsAccent.advanced.withValues(alpha: 0.16),
        );

        final muscleBadge = tester.widget<Container>(
          find.byWidgetPredicate((widget) {
            if (widget is! Container || widget.child is! Text) return false;
            final decoration = widget.decoration;
            return (widget.child! as Text).data == '1' &&
                decoration is BoxDecoration &&
                decoration.shape == BoxShape.circle;
          }),
        );
        final muscleBadgeDecoration = muscleBadge.decoration! as BoxDecoration;
        expect(
          muscleBadgeDecoration.color,
          SettingsAccent.training.withValues(alpha: 0.16),
        );
        expect((muscleBadge.child! as Text).style?.fontWeight, FontWeight.w900);

        await tester.tap(find.text(strings.exerciseEditorBodyparts));
        await tester.pumpAndSettle();
        final bodyPartBadge = tester.widget<Container>(
          find.byWidgetPredicate((widget) {
            if (widget is! Container || widget.child is! Icon) return false;
            final decoration = widget.decoration;
            return decoration is BoxDecoration &&
                decoration.borderRadius == shapes.control &&
                decoration.color ==
                    SettingsAccent.training.withValues(alpha: 0.14) &&
                (widget.child! as Icon).icon == Icons.accessibility_new;
          }),
        );
        expect(
          (bodyPartBadge.decoration! as BoxDecoration).color,
          SettingsAccent.training.withValues(alpha: 0.14),
        );

        await tester.tap(find.text(strings.exerciseEditorEquipment));
        await tester.pumpAndSettle();
        final equipmentBadge = tester.widget<Container>(
          find.byWidgetPredicate((widget) {
            if (widget is! Container || widget.child is! Icon) return false;
            final decoration = widget.decoration;
            return decoration is BoxDecoration &&
                decoration.borderRadius == shapes.settingsIcon &&
                decoration.color ==
                    SettingsAccent.training.withValues(alpha: 0.14) &&
                (widget.child! as Icon).icon ==
                    Icons.precision_manufacturing_outlined;
          }),
        );
        expect(
          (equipmentBadge.decoration! as BoxDecoration).color,
          SettingsAccent.training.withValues(alpha: 0.14),
        );

        await tester.tap(find.text(strings.exerciseEditorGuide));
        await tester.pumpAndSettle();
        expect(tester.widget<TabBar>(find.byType(TabBar)).controller?.index, 3);
        expect(
          tester
              .widgetList<TextField>(find.byType(TextField))
              .every((field) => field.readOnly),
          isTrue,
          reason: 'guide fields remain read-only until editing is enabled',
        );

        await tester.tap(findTonosTooltip(strings.exerciseEditorEdit));
        await tester.pumpAndSettle();
        expect(
          tester
              .widgetList<TextField>(find.byType(TextField))
              .every((field) => !field.readOnly),
          isTrue,
          reason: 'edit mode should enable the guide fields',
        );
        expect(
          tester
              .widget<IconButton>(
                find
                    .ancestor(
                      of: findTonosTooltip(strings.exerciseEditorChoose),
                      matching: find.byType(IconButton),
                    )
                    .first,
              )
              .onPressed,
          isNull,
        );
        expect(
          tester
              .widget<IconButton>(
                find
                    .ancestor(
                      of: findTonosTooltip(strings.exerciseEditorCreate),
                      matching: find.byType(IconButton),
                    )
                    .first,
              )
              .onPressed,
          isNull,
        );
        await tester.tap(find.text(strings.exerciseEditorMuscles));
        await tester.pumpAndSettle();
        final moveUp = tester.widget<IconButton>(
          find
              .ancestor(
                of: findTonosTooltip(strings.exerciseEditorMoveUp).first,
                matching: find.byType(IconButton),
              )
              .first,
        );
        expect(
          moveUp.onPressed,
          isNull,
          reason: 'the first muscle cannot move up',
        );

        await tester.tap(find.text(strings.exerciseEditorGuide));
        await tester.pumpAndSettle();
        final mediaTitle = find.text('Technique reference');
        final mediaTile = find.ancestor(
          of: mediaTitle,
          matching: find.byType(SettingsActionTile),
        );
        expect(mediaTile, findsOneWidget);
        expect(tester.widget<SettingsActionTile>(mediaTile).onTap, isNotNull);
        final mediaIcon = find.descendant(
          of: mediaTile,
          matching: find.byIcon(Icons.link),
        );
        expect(mediaIcon, findsOneWidget);
        final mediaTheme = Theme.of(tester.element(mediaIcon));
        expect(
          tester.widget<Icon>(mediaIcon).color,
          family == AppThemeFamily.neoBrutalism
              ? mediaTheme.colorScheme.onSurface
              : SettingsAccent.data,
        );
        expect(
          tester.renderObject<RenderParagraph>(mediaTitle).text.style?.color,
          mediaTheme.textTheme.titleSmall?.color,
        );
        final addMedia = find.text(strings.exerciseEditorAddMediaLink);
        await tester.tap(addMedia);
        await tester.pumpAndSettle();
        expect(find.byType(TonosDialogFrame), findsOneWidget);
        final addMediaDialog = find.byType(AlertDialog).last;
        expect(
          find.descendant(
            of: addMediaDialog,
            matching: find.text(strings.exerciseEditorAddMedia),
          ),
          findsOneWidget,
        );
        expect(find.byType(TonosFormField), findsNWidgets(3));
        final mediaTypeDropdown = tester
            .widget<DropdownButtonFormField<String>>(
              find.byType(DropdownButtonFormField<String>),
            );
        expect(
          mediaTypeDropdown.decoration.labelText,
          strings.exerciseEditorMediaType,
        );
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        final videoOption = find.text(strings.exerciseEditorMediaVideo);
        expect(videoOption, findsOneWidget);
        expectDarkNeoPopup(videoOption);
        await tester.tap(videoOption);
        await tester.pumpAndSettle();
        expect(find.text(strings.exerciseEditorMediaVideo), findsOneWidget);
        final mediaFields = find.byType(TextFormField);
        expect(mediaFields, findsNWidgets(3));
        final mediaDecorations = [
          for (var index = 0; index < 3; index++)
            inputDecoratorFor(mediaFields.at(index)).decoration,
        ];
        expect(
          mediaDecorations.map((decoration) => decoration.labelText).toList(),
          [
            strings.exerciseEditorMediaTitle,
            strings.exerciseEditorMediaRemoteUrl,
            strings.exerciseEditorMediaThumbnailUrl,
          ],
        );
        expect(
          mediaDecorations.map((decoration) => decoration.hintText).toList(),
          [
            strings.exerciseEditorMediaTitleHint,
            'https://...',
            strings.exerciseEditorMediaThumbnailHint,
          ],
        );
        final remoteUrlField = mediaFields.at(1);
        await tester.tap(remoteUrlField);
        await tester.pump();
        expect(inputDecoratorFor(remoteUrlField).isFocused, isTrue);
        expectDarkNeoFocusedFormField(remoteUrlField);
        await tester.enterText(remoteUrlField, 'https://example.test/a.png');
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog).last,
            matching: find.text(strings.commonCancel),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text(strings.exerciseEditorMuscles));
        await tester.pumpAndSettle();
        await tester.tap(findTonosTooltip(strings.exerciseEditorRemoveMuscle));
        await tester.pumpAndSettle();
        expect(
          find.text(
            strings.exerciseEditorRemoveItemTitle(
              strings.exerciseEditorMuscleItem,
            ),
          ),
          findsOneWidget,
        );
        await tester.tap(find.text(strings.exerciseEditorKeep));
        await tester.pumpAndSettle();
        expect(find.text('Pectorals'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: mode);
      });

      testWidgets('$mode Database health separators use Material ownership', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.${TutorialIds.databaseSettings}': true,
        });
        final repository = _SettingsRoutesRepository();

        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: repository,
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const DatabaseSettingsPage(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final strings = AppLocalizations.of(
          tester.element(find.byType(DatabaseSettingsPage)),
        );
        expect(find.text(strings.databaseHealthSchema), findsOneWidget);
        expect(find.text(strings.databaseHealthPath), findsOneWidget);
        final healthCard = find.byWidgetPredicate((widget) {
          if (widget is! Padding || widget.child is! Column) return false;
          final children = (widget.child! as Column).children;
          return children.whereType<Divider>().length == 5;
        });
        expect(healthCard, findsOneWidget);
        final healthDividers = tester
            .widgetList<Divider>(
              find.descendant(of: healthCard, matching: find.byType(Divider)),
            )
            .toList();
        expect(healthDividers, hasLength(5));
        expect(
          healthDividers.every(
            (divider) => divider.height == 1 && divider.color == null,
          ),
          isTrue,
          reason: '$mode health separators use DividerTheme ownership.',
        );
        expect(tester.takeException(), isNull, reason: mode);
      });
    }
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive ${brightness.name} Exercise Editor uses identity surfaces and labeled actions',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.${TutorialIds.exerciseCatalog}': true,
        });
        final repository = _SettingsRoutesRepository();
        final selectedProfile = SelectedProfile(repository: repository);
        addTearDown(selectedProfile.dispose);
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<SelectedProfile>.value(
                value: selectedProfile,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const ExerciseEditorScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final strings = AppLocalizations.of(
          tester.element(find.byType(ExerciseEditorScreen)),
        );
        final teal = brightness == Brightness.dark
            ? const Color(0xFF183F3C)
            : const Color(0xFF164F49);
        final heroShape = const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(26),
        );
        final hero = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).color == teal &&
              (widget.decoration! as BoxDecoration).borderRadius == heroShape,
        );
        expect(hero, findsOneWidget);
        final chooseCatalog = find.widgetWithText(
          FilledButton,
          strings.exerciseEditorChooseCatalog,
        );
        expect(chooseCatalog, findsOneWidget);
        expect(
          find.widgetWithText(
            OutlinedButton,
            strings.exerciseEditorCreateCustomTitle,
          ),
          findsOneWidget,
        );
        expect(tester.widget<AppBar>(find.byType(AppBar)).actions, isEmpty);

        await tester.tap(chooseCatalog);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        expect(find.byType(ExerciseCatalogPage), findsOneWidget);
        await tester.tap(find.text(repository.definition.name));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        final add = findTonosTooltip(strings.commonAdd);
        expect(add, findsOneWidget);
        await tester.tap(add);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();

        final selectedExerciseName = find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == repository.definition.name &&
              widget.maxLines == null &&
              widget.style?.fontWeight == FontWeight.w900,
        );
        expect(selectedExerciseName, findsOneWidget);
        expect(find.text('80/100'), findsOneWidget);
        expect(find.text(strings.exerciseEditorChoose), findsOneWidget);
        expect(find.text(strings.exerciseEditorEdit), findsOneWidget);
        expect(
          find.text(strings.exerciseEditorCreateCustomTitle),
          findsNothing,
        );
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is TextField &&
                widget.decoration?.labelText == strings.exerciseEditorRating,
          ),
          findsNothing,
          reason: 'Read-only selection shows the rating badge, not an editor.',
        );
        expect(find.byTooltip(strings.exerciseEditorChoose), findsNothing);
        expect(find.byTooltip(strings.exerciseEditorEdit), findsNothing);
        expect(find.byTooltip(strings.exerciseEditorCreate), findsNothing);

        expect(find.byType(TabBar), findsNothing);
        final compactTabLabels = [
          strings.exerciseEditorMuscles,
          strings.exerciseEditorBodyparts,
          strings.exerciseEditorEquipment,
          strings.exerciseEditorGuide,
        ];
        final musclesControl = find.widgetWithText(
          OutlinedButton,
          strings.exerciseEditorMuscles,
        );
        final tabSurfaceContainer = tester.widget<Container>(
          find
              .ancestor(
                of: musclesControl,
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Container && widget.decoration is BoxDecoration,
                ),
              )
              .first,
        );
        final tabSurface = tabSurfaceContainer.decoration! as BoxDecoration;
        final tabColor = brightness == Brightness.dark
            ? const Color(0xFF293432)
            : const Color(0xFFF5E9DC);
        final selectedTab = brightness == Brightness.dark
            ? const Color(0xFF573A2B)
            : const Color(0xFFFFD5B8);
        final selectedForeground = brightness == Brightness.dark
            ? const Color(0xFFFFE9D8)
            : const Color(0xFF45291D);
        expect(tabSurface.color, tabColor);
        expect(
          (tabSurface.border! as Border).top.color,
          teal.withValues(alpha: 0.24),
        );
        for (final label in compactTabLabels) {
          expect(
            find.widgetWithText(OutlinedButton, label),
            findsOneWidget,
            reason: '$label remains available in the responsive tab surface',
          );
        }
        final selectedControl = tester.widget<OutlinedButton>(musclesControl);
        expect(
          selectedControl.style?.foregroundColor?.resolve({}),
          selectedForeground,
        );
        expect(
          selectedControl.style?.backgroundColor?.resolve({}),
          selectedTab,
        );

        final ratingBadge = tester.widget<Container>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.child is Text &&
                (widget.child! as Text).data == '80/100',
          ),
        );
        final ratingSurface = ratingBadge.decoration! as BoxDecoration;
        expect(
          ratingSurface.color,
          brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.62),
        );
        expect(ratingSurface.borderRadius, theme.shapeTokens.control);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive ${brightness.name} Database health shows compact path and copy action',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.${TutorialIds.databaseSettings}': true,
        });
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final repository = _SettingsRoutesRepository();

        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: repository,
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const DatabaseSettingsPage(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final strings = AppLocalizations.of(
          tester.element(find.byType(DatabaseSettingsPage)),
        );
        const fullPath =
            '/data/user/0/com.tonos.expressivepreview/databases/'
            'tonos_expressive_preview.db';
        final tables = tester.widget<Text>(
          find.text(strings.databaseHealthTablesValue(85, 94, 27)),
        );
        final path = tester.widget<Text>(
          find.text('tonos_expressive_preview.db'),
        );
        expect(find.text(fullPath), findsNothing);
        expect(path.maxLines, 1);
        expect(path.overflow, TextOverflow.ellipsis);
        final copyButton = find.byTooltip(strings.commonCopy);
        expect(copyButton, findsOneWidget);

        String? copiedPath;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copiedPath =
                  (call.arguments as Map<Object?, Object?>)['text'] as String?;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        await tester.ensureVisible(copyButton);
        await tester.tap(copyButton);
        await tester.pumpAndSettle();
        expect(copiedPath, fullPath);
        expect(find.text(strings.databaseCopied), findsOneWidget);

        expect(tables.maxLines, isNull);
        expect(tables.overflow, isNull);

        await tester.scrollUntilVisible(
          find.text(strings.databaseContentEnvironment),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        final environmentSummary = find.text(
          'Development · Cloudflare R2 test bucket',
        );
        expect(environmentSummary, findsOneWidget);
        expect(tester.widget<Text>(environmentSummary).maxLines, 1);
        const sharedManifestUrl =
            'https://dev.example.test/shared-manifest.json';
        final sharedManifestPreview = find.text(sharedManifestUrl);
        expect(sharedManifestPreview, findsOneWidget);
        expect(tester.widget<Text>(sharedManifestPreview).maxLines, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive ${brightness.name} Database manifest editor uses saved URL and filled field',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.${TutorialIds.databaseSettings}': true,
        });
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final repository = _SettingsRoutesRepository();

        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: repository,
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const DatabaseSettingsPage(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final strings = AppLocalizations.of(
          tester.element(find.byType(DatabaseSettingsPage)),
        );
        await tester.scrollUntilVisible(
          find.byTooltip(strings.databaseOverrideUrl),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        final exerciseManifestPreview = find.text(
          'https://dev.example.test/exercise-manifest.json',
        );
        expect(exerciseManifestPreview, findsOneWidget);
        expect(tester.widget<Text>(exerciseManifestPreview).maxLines, 1);
        final editButton = find.byTooltip(strings.databaseOverrideUrl);
        await tester.ensureVisible(editButton);
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        const expectedUrl = 'https://dev.example.test/exercise-manifest.json';
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller?.text, expectedUrl);
        final localTheme = tester.widget<Theme>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(Theme),
              )
              .first,
        );
        final inputTheme = localTheme.data.inputDecorationTheme;
        expect(inputTheme.filled, isTrue);
        expect(inputTheme.fillColor, theme.surfaceTokens.dialogChoice);
        expect(
          (inputTheme.border as OutlineInputBorder).borderRadius,
          theme.shapeTokens.dialogChoice,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _SettingsRoutesRepository extends AppRepository {
  final _SettingsDatabaseHelper _database = _SettingsDatabaseHelper();

  final ExerciseDefinition definition = ExerciseDefinition(
    id: 7,
    name: 'Bench Press',
    rating: 80,
    equipmentList: [Equipment(1, 'Barbell')],
    bodyParts: [BodyPart(1, 'Chest')],
    muscles: [RankedMuscle(muscle: Muscle(id: 2, name: 'Pectorals'), rank: 1)],
    useManualBodyparts: false,
    multiplyByRating: false,
  );

  final GymProfile _profile = GymProfile(
    id: 1,
    name: 'General',
    createdAt: DateTime.utc(2026),
  );

  @override
  DatabaseHelper get dbHelper => _database;

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => [definition];

  @override
  Future<List<Equipment>> fetchAllEquipment() async => [
    Equipment(1, 'Barbell'),
  ];

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => [BodyPart(1, 'Chest')];

  @override
  Future<List<Muscle>> fetchAllMuscles() async => [
    Muscle(id: 2, name: 'Pectorals'),
  ];

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => [_profile];

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => const [];

  @override
  Future<String?> getAppState(String key) async => null;

  @override
  Future<void> setAppState(String key, String? value) async {}

  @override
  Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) async =>
      const [];

  @override
  Future<bool> getUseManualMuscles(int defId) async => false;

  @override
  Future<Map<BodyPart, double>> computeMuscleCalculatedBodyparts(
    int defId,
  ) async => {BodyPart(1, 'Chest'): 1};

  @override
  Future<List<ExerciseBodyPartPercent>> fetchBodyPartPercentsManual(
    int defId,
  ) async => const [];

  @override
  Future<bool> getUseManualBodyparts(int defId) async => false;

  @override
  Future<List<ExerciseMediaItem>> fetchExerciseMedia(int defId) async => [
    ExerciseMediaItem(
      id: 31,
      exerciseDefId: defId,
      mediaType: 'link',
      remoteUrl: 'https://example.test/guide',
      title: 'Technique reference',
      sortOrder: 0,
    ),
  ];

  @override
  Future<bool> getMultiplyByRating(int defId) async => false;

  @override
  Future<ContentCacheUsage> getContentCacheUsage() async =>
      const ContentCacheUsage(fileCount: 0, totalBytes: 0);

  @override
  Future<ContentManifestStatus?> getContentManifestStatus(
    String namespace,
  ) async => null;

  @override
  Future<bool> isWifiOnlyMediaDownloadEnabled() async => false;

  @override
  Future<DatabaseHealthSnapshot> getDatabaseHealthSnapshot() async =>
      DatabaseHealthSnapshot(
        path:
            '/data/user/0/com.tonos.expressivepreview/databases/'
            'tonos_expressive_preview.db',
        schemaVersion: 1,
        targetSchemaVersion: 1,
        journalMode: 'delete',
        databaseBytes: 4096,
        walBytes: 0,
        shmBytes: 0,
        pageCount: 1,
        pageSize: 4096,
        tableCount: 85,
        indexCount: 94,
        triggerCount: 27,
        foodCount: 0,
        foodFtsCount: 0,
        checkedAt: DateTime.utc(2026),
      );

  @override
  Future<ContentEnvironmentConfig> loadContentEnvironments() async =>
      const ContentEnvironmentConfig(
        defaultEnvironmentId: 'development',
        environments: [
          ContentEnvironment(
            id: 'development',
            label: 'Development',
            description: 'Cloudflare R2 development bucket used for testing exercise media before release.',
            exerciseMediaManifestUrl:
                'https://dev.example.test/exercise-manifest.json',
            sharedMediaManifestUrl:
                'https://dev.example.test/shared-manifest.json',
            allowedManifestHosts: ['dev.example.test'],
          ),
          ContentEnvironment(
            id: 'production',
            label: 'Production',
            description: 'Production R2/CDN slot.',
            exerciseMediaManifestUrl:
                'https://prod.example.test/exercise-manifest.json',
            sharedMediaManifestUrl:
                'https://prod.example.test/shared-manifest.json',
            allowedManifestHosts: ['prod.example.test'],
            isProduction: true,
          ),
        ],
      );
}

class _SettingsDatabaseHelper implements DatabaseHelper {
  final _profile = GymProfile(
    id: 1,
    name: 'General',
    createdAt: DateTime.utc(2026),
  );

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => [_profile];

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
