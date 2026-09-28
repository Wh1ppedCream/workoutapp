import 'package:env_test/db/database_helper.dart';
import 'package:env_test/db/database_maintenance.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/exercise_catalog_page.dart';
import 'package:env_test/screens/profile/settings/database_settings_page.dart';
import 'package:env_test/screens/profile/settings/exercise_editor_screen.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_dialog.dart';
import 'package:env_test/theme/widgets/tonos_field.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
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
              localizationsDelegates: AppLocalizations.localizationsDelegates,
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

        await tester.tap(find.byTooltip(strings.exerciseEditorChoose));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        expect(find.byType(ExerciseCatalogPage), findsOneWidget);
        await tester.tap(find.text(repository.definition.name));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        expect(find.byTooltip(strings.commonAdd), findsOneWidget);
        await tester.tap(find.byTooltip(strings.commonAdd));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();

        final editorContext = tester.element(find.byType(ExerciseEditorScreen));
        final shapes = editorContext.shapeTokens;
        final surfaces = editorContext.surfaceTokens;
        final usesOutlinedPanels =
            editorContext.surfaceDecorationTokens.panel.outlined;
        final themeData = Theme.of(editorContext);
        final tabSurface =
            usesOutlinedPanels
                ? surfaces.settingsSection
                : themeData.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.34,
                );
        final headerForeground =
            usesOutlinedPanels
                ? tonosForegroundForSurface(
                  editorContext,
                  surfaces.settingsSection,
                )
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
          find.byWidgetPredicate((widget) {
            if (widget is! Container || widget.child is! TabBar) return false;
            return widget.decoration is BoxDecoration;
          }),
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

        await tester.tap(
          find.byWidgetPredicate(
            (widget) =>
                widget is Tab && widget.text == strings.exerciseEditorBodyparts,
          ),
        );
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

        await tester.tap(
          find.byWidgetPredicate(
            (widget) =>
                widget is Tab && widget.text == strings.exerciseEditorEquipment,
          ),
        );
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

        await tester.tap(find.byTooltip(strings.exerciseEditorEdit));
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
                      of: find.byTooltip(strings.exerciseEditorChoose),
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
                      of: find.byTooltip(strings.exerciseEditorCreate),
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
                of: find.byTooltip(strings.exerciseEditorMoveUp).first,
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
        await tester.tap(find.byTooltip(strings.exerciseEditorRemoveMuscle));
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
              localizationsDelegates: AppLocalizations.localizationsDelegates,
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
        final healthDividers =
            tester
                .widgetList<Divider>(
                  find.descendant(
                    of: healthCard,
                    matching: find.byType(Divider),
                  ),
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
        path: 'test.db',
        schemaVersion: 1,
        targetSchemaVersion: 1,
        journalMode: 'delete',
        databaseBytes: 4096,
        walBytes: 0,
        shmBytes: 0,
        pageCount: 1,
        pageSize: 4096,
        tableCount: 1,
        indexCount: 1,
        triggerCount: 1,
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
            exerciseMediaManifestUrl:
                'https://dev.example.test/exercise-manifest.json',
            sharedMediaManifestUrl:
                'https://dev.example.test/shared-manifest.json',
            allowedManifestHosts: ['dev.example.test'],
          ),
          ContentEnvironment(
            id: 'production',
            label: 'Production',
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
