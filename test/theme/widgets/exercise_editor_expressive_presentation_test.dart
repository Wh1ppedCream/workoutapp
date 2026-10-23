import 'package:env_test/db/database_helper.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/exercise_catalog_page.dart';
import 'package:env_test/screens/profile/settings/analytics_destination_surfaces.dart';
import 'package:env_test/screens/profile/settings/exercise_editor_screen.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Exercise Editor uses Analytics roles in Expressive and preserves Classic/Neo tabs',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final cases = <(AppThemeFamily?, Brightness, bool)>[
        for (final family in AppThemeFamily.values)
          for (final brightness in Brightness.values)
            (family, brightness, family == AppThemeFamily.expressive),
        for (final brightness in Brightness.values) (null, brightness, true),
      ];

      for (final (family, brightness, expressive) in cases) {
        final repository = _EditorPresentationRepository();
        final theme = family == null
            ? ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF345B50),
                  brightness: brightness,
                ),
                extensions: const [
                  AppThemeIdentity(
                    family: AppThemeFamilyIdentity.expressivePreview,
                  ),
                ],
              )
            : brightness == Brightness.light
            ? AppThemeFactory.light(family)
            : AppThemeFactory.dark(family);
        final mode = expressive
            ? 'Expressive ${brightness.name}'
            : '${family!.code} ${brightness.name}';

        await tester.pumpWidget(
          MultiProvider(
            providers: [Provider<AppRepository>.value(value: repository)],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: ExerciseEditorScreen(key: ValueKey(mode)),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final titleCardShape = expressive
            ? const BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(26),
              )
            : theme.shapeTokens.settingsTitleCard;
        final titleCardPadding = expressive
            ? const EdgeInsets.fromLTRB(20, 18, 20, 19)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 15);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.padding == titleCardPadding &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).borderRadius ==
                    titleCardShape,
          ),
          findsOneWidget,
          reason: '$mode title card geometry',
        );
        final strings = AppLocalizations.of(
          tester.element(find.byType(ExerciseEditorScreen)),
        );
        final createCustomButton = find.widgetWithText(
          OutlinedButton,
          strings.exerciseEditorCreateCustomTitle,
        );
        if (expressive) {
          final button = tester.widget<OutlinedButton>(createCustomButton);
          expect(
            button.style?.foregroundColor?.resolve({}),
            brightness == Brightness.dark
                ? const Color(0xFFCBE9D9)
                : const Color(0xFF164F49),
            reason: '$mode create action uses a legible hero foreground',
          );
        }
        await tester.tap(createCustomButton);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget, reason: mode);
        expect(find.byType(TextFormField), findsOneWidget, reason: mode);
        await tester.enterText(
          find.byType(TextFormField).first,
          'Custom Press',
        );
        await tester.tap(find.text(strings.healthCreate));
        await tester.pumpAndSettle();

        expect(find.text('Custom Press'), findsOneWidget, reason: mode);
        expect(
          find.byType(SettingsSaveBar),
          expressive ? findsNothing : findsOneWidget,
          reason: '$mode keeps its family-specific editing actions',
        );
        expect(
          find.byType(TabBar),
          expressive ? findsNothing : findsOneWidget,
          reason: '$mode uses its responsive tab control',
        );
        final editorContext = tester.element(find.byType(ExerciseEditorScreen));
        final scheme = Theme.of(editorContext).colorScheme;
        final surfaces = editorContext.surfaceTokens;
        final tabContainerFinder = find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration,
        );
        final tabSurface = find
            .ancestor(
              of: expressive
                  ? find.widgetWithText(
                      OutlinedButton,
                      strings.exerciseEditorMuscles,
                    )
                  : find.byType(TabBar),
              matching: tabContainerFinder,
            )
            .first;
        final tabContainer = tester.widget<Container>(tabSurface);
        final tabDecoration = tabContainer.decoration! as BoxDecoration;
        final tabBar = expressive
            ? null
            : tester.widget<TabBar>(find.byType(TabBar));

        if (expressive) {
          final tabSurfaceColor = brightness == Brightness.dark
              ? const Color(0xFF293432)
              : const Color(0xFFF5E9DC);
          final selectedTabColor = brightness == Brightness.dark
              ? const Color(0xFF573A2B)
              : const Color(0xFFFFD5B8);
          final selectedTabForeground = brightness == Brightness.dark
              ? const Color(0xFFFFE9D8)
              : const Color(0xFF45291D);
          expect(tabDecoration.color, tabSurfaceColor, reason: mode);
          expect(
            (tabDecoration.border! as Border).top.color,
            (brightness == Brightness.dark
                    ? const Color(0xFF183F3C)
                    : const Color(0xFF164F49))
                .withValues(alpha: 0.24),
            reason: mode,
          );
          Color? compactTabColor(String label, {required bool foreground}) {
            final button = tester.widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, label),
            );
            return (foreground
                    ? button.style?.foregroundColor
                    : button.style?.backgroundColor)
                ?.resolve({});
          }

          expect(
            compactTabColor(strings.exerciseEditorMuscles, foreground: false),
            selectedTabColor,
            reason: '$mode selected compact tab uses its identity surface',
          );
          expect(
            compactTabColor(strings.exerciseEditorMuscles, foreground: true),
            selectedTabForeground,
            reason: '$mode selected compact tab uses its identity foreground',
          );

          final analyticsRoles = tester
              .widgetList<AnalyticsZone>(find.byType(AnalyticsZone))
              .map((zone) => zone.role)
              .toSet();
          expect(
            analyticsRoles,
            isEmpty,
            reason: '$mode keeps the hero free of a duplicate surface',
          );
          expect(
            find.ancestor(
              of: find.text(strings.exerciseEditorExactSetCredit),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Material && widget.color == selectedTabColor,
              ),
            ),
            findsOneWidget,
            reason:
                '$mode allocation shortcut uses the selected muscle identity',
          );
          final saveAction = find.byKey(
            const ValueKey('exercise-editor-save-fab'),
          );
          expect(saveAction, findsNothing, reason: '$mode clean draft');

          final tabs = <(String, Color, Color, String?, Color?)>[
            (
              strings.exerciseEditorBodyparts,
              brightness == Brightness.dark
                  ? const Color(0xFF443854)
                  : const Color(0xFFE1D3F5),
              brightness == Brightness.dark
                  ? const Color(0xFFF0E4FF)
                  : const Color(0xFF342445),
              strings.exerciseEditorAddBodyparts,
              brightness == Brightness.dark
                  ? const Color(0xFFF0E4FF)
                  : const Color(0xFF342445),
            ),
            (
              strings.exerciseEditorEquipment,
              brightness == Brightness.dark
                  ? const Color(0xFF183F3C)
                  : const Color(0xFF164F49),
              Colors.white,
              strings.exerciseEditorAddEquipment,
              brightness == Brightness.dark
                  ? const Color(0xFFD6F3EB)
                  : const Color(0xFF164F49),
            ),
            (
              strings.exerciseEditorGuide,
              brightness == Brightness.dark
                  ? const Color(0xFF24483E)
                  : const Color(0xFFCBE9D9),
              brightness == Brightness.dark
                  ? const Color(0xFFE0F6EA)
                  : const Color(0xFF1B4035),
              null,
              null,
            ),
          ];
          final muscleAddAction = find.widgetWithText(
            OutlinedButton,
            strings.exerciseEditorAddTargetMuscles,
          );
          expect(muscleAddAction, findsOneWidget, reason: mode);
          final muscleAddButton = tester.widget<OutlinedButton>(
            muscleAddAction,
          );
          expect(muscleAddButton.onPressed, isNotNull, reason: mode);
          expect(
            muscleAddButton.style?.foregroundColor?.resolve({}),
            brightness == Brightness.dark
                ? const Color(0xFFFFE9D8)
                : const Color(0xFF45291D),
            reason: '$mode active muscle Add action is legible',
          );

          for (final (label, surface, foreground, addLabel, addForeground)
              in tabs) {
            final tabButton = find.widgetWithText(OutlinedButton, label);
            expect(
              tabButton,
              findsOneWidget,
              reason: '$mode $label destination',
            );
            await tester.tap(tabButton);
            await tester.pumpAndSettle();
            expect(
              compactTabColor(label, foreground: false),
              surface,
              reason: '$mode $label tab gets its identity surface',
            );
            expect(
              compactTabColor(label, foreground: true),
              foreground,
              reason: '$mode $label tab foreground matches its identity',
            );
            final selectedSemantics = find.ancestor(
              of: tabButton,
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Semantics && widget.properties.selected != null,
              ),
            );
            expect(
              selectedSemantics,
              findsWidgets,
              reason: '$mode $label semantics',
            );
            expect(
              tester
                  .widget<Semantics>(selectedSemantics.first)
                  .properties
                  .selected,
              isTrue,
              reason: '$mode $label is selected',
            );
            if (addLabel != null && addForeground != null) {
              final addAction = find.widgetWithText(OutlinedButton, addLabel);
              expect(addAction, findsOneWidget, reason: '$mode $label Add');
              final addButton = tester.widget<OutlinedButton>(addAction);
              expect(addButton.onPressed, isNotNull, reason: '$mode $label');
              expect(
                addButton.style?.foregroundColor?.resolve({}),
                addForeground,
                reason: '$mode $label Add action uses its identity foreground',
              );
            }
          }

          await tester.tap(find.byTooltip(strings.commonCancel));
          await tester.pumpAndSettle();
          expect(find.text(strings.exerciseEditorChoose), findsOneWidget);
          expect(find.text(strings.exerciseEditorEdit), findsOneWidget);
          if (expressive) {
            final hero = tester.getRect(
              find.byKey(
                const ValueKey('exercise-editor-expressive-title-hero'),
              ),
            );
            final choose = tester.getRect(
              find.byKey(const ValueKey('exercise-editor-choose-action')),
            );
            final edit = tester.getRect(
              find.byKey(const ValueKey('exercise-editor-edit-action')),
            );
            expect(choose.top, greaterThanOrEqualTo(hero.bottom));
            expect(choose.top, closeTo(edit.top, 0.5));
            expect(choose.left, lessThan(edit.left));
          }
          expect(
            find.text(strings.exerciseEditorCreateCustomTitle),
            findsNothing,
          );
          expect(find.byType(AnalyticsZone), findsNothing);
        } else {
          final classicNeoTabBar = tabBar!;
          final neo = family == AppThemeFamily.neoBrutalism;
          final expectedSurface = neo
              ? surfaces.settingsSection
              : scheme.surfaceContainerHighest.withValues(alpha: 0.34);
          expect(tabDecoration.color, expectedSurface, reason: mode);
          expect(
            classicNeoTabBar.labelColor,
            neo
                ? tonosForegroundForSurface(editorContext, expectedSurface)
                : SettingsAccent.advanced,
            reason: mode,
          );
          expect(
            (classicNeoTabBar.indicator! as BoxDecoration).color,
            neo
                ? surfaces.dialogChoice
                : SettingsAccent.advanced.withValues(alpha: 0.20),
            reason: mode,
          );
          expect(
            tester
                .widgetList<AnalyticsZone>(find.byType(AnalyticsZone))
                .map((zone) => zone.role),
            everyElement(AnalyticsSurfaceRole.primary),
            reason: '$mode retains its existing unzoned tab content',
          );
        }

        expect(tester.takeException(), isNull, reason: mode);
      }
    },
  );

  testWidgets(
    'Expressive Exercise Editor custom form stays usable at 320dp with keyboard inset and 2x text',
    (tester) async {
      const size = Size(320, 900);
      const keyboardInset = 280.0;
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _EditorPresentationRepository();
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF345B50)),
        extensions: const [
          AppThemeIdentity(family: AppThemeFamilyIdentity.expressivePreview),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [Provider<AppRepository>.value(value: repository)],
          child: MaterialApp(
            theme: theme,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2),
                viewInsets: const EdgeInsets.only(bottom: keyboardInset),
              ),
              child: child!,
            ),
            home: const ExerciseEditorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final strings = AppLocalizations.of(
        tester.element(find.byType(ExerciseEditorScreen)),
      );
      final createCustom = find.text(strings.exerciseEditorCreateCustomTitle);
      final landingList = find.byType(ListView).first;
      final landingScrollable = find.descendant(
        of: landingList,
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        createCustom,
        120,
        scrollable: landingScrollable.first,
      );
      await tester.ensureVisible(createCustom);
      expect(createCustom.hitTestable(), findsOneWidget);
      await tester.tap(createCustom);
      await tester.pumpAndSettle();
      final nameField = find.byType(TextFormField).first;
      await tester.ensureVisible(nameField);
      await tester.tap(nameField);
      await tester.enterText(nameField, 'Compact Custom Exercise');
      await tester.pumpAndSettle();
      expect(nameField.hitTestable(), findsOneWidget);

      final create = find.widgetWithText(FilledButton, strings.healthCreate);
      await tester.ensureVisible(create);
      expect(create.hitTestable(), findsOneWidget);
      expect(
        tester.getRect(create).bottom,
        lessThanOrEqualTo(size.height - keyboardInset),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Exercise Editor opts only Expressive picker routes into Catalog presentation',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.exercise_catalog_v1': true,
      });
      final cases = <(AppThemeFamily?, Brightness, bool)>[
        for (final family in AppThemeFamily.values)
          for (final brightness in Brightness.values)
            (family, brightness, family == AppThemeFamily.expressive),
        for (final brightness in Brightness.values) (null, brightness, true),
      ];

      for (final (family, brightness, expressive) in cases) {
        final repository = _EditorPresentationRepository();
        final profile = SelectedProfile(repository: repository)
          ..currentProfile = GymProfile(
            id: 1,
            name: 'Test Gym',
            createdAt: DateTime.utc(2026),
          );
        addTearDown(profile.dispose);
        final theme = family == null
            ? ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF345B50),
                  brightness: brightness,
                ),
                extensions: const [
                  AppThemeIdentity(
                    family: AppThemeFamilyIdentity.expressivePreview,
                  ),
                ],
              )
            : brightness == Brightness.light
            ? AppThemeFactory.light(family)
            : AppThemeFactory.dark(family);
        final mode = expressive
            ? 'Expressive ${brightness.name}'
            : '${family!.code} ${brightness.name}';

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<SelectedProfile>.value(value: profile),
            ],
            child: MaterialApp(
              key: ValueKey('exercise-picker-$mode'),
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const ExerciseEditorScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: '$mode Exercise Editor startup',
        );
        final editor = find.byType(ExerciseEditorScreen);
        expect(editor, findsOneWidget, reason: '$mode Exercise Editor mounts');
        final strings = AppLocalizations.of(tester.element(editor));
        final chooseCatalog = find.widgetWithText(
          FilledButton,
          strings.exerciseEditorChooseCatalog,
        );
        await tester.ensureVisible(chooseCatalog);
        await tester.tap(chooseCatalog);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final picker = tester.widget<ExerciseCatalogPage>(
          find.byType(ExerciseCatalogPage),
        );
        expect(
          picker.expressiveCatalogPresentation,
          expressive,
          reason: '$mode picker presentation stays caller-scoped',
        );
        final catalogTokens = Theme.of(
          tester.element(find.byType(ExerciseCatalogPage)),
        ).extension<AppExpressiveDestinationTokens>();
        expect(
          catalogTokens?.family,
          expressive ? AppExpressiveDestinationFamily.catalog : null,
          reason: '$mode picker receives the Catalog theme scope',
        );
        expect(
          find.byKey(const ValueKey('expressive-catalog-results')),
          expressive ? findsOneWidget : findsNothing,
          reason: '$mode receives only its intended Catalog recipe',
        );
        expect(tester.takeException(), isNull, reason: mode);
      }
    },
  );
}

class _EditorPresentationRepository extends AppRepository {
  _EditorPresentationRepository() : super(db: _EditorPresentationDatabase());

  final BodyPart _chest = BodyPart(1, 'Chest');
  final Muscle _pectorals = Muscle(id: 2, name: 'Pectorals');

  late final ExerciseDefinition _definition = ExerciseDefinition(
    id: 1,
    name: 'Custom Press',
    rating: 80,
    bodyParts: [_chest],
    muscles: [RankedMuscle(muscle: _pectorals, rank: 1)],
    useManualBodyparts: false,
    multiplyByRating: false,
  );

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => const [];

  @override
  Future<List<Equipment>> fetchAllEquipment() async => const [];

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => [
    GymProfile(id: 1, name: 'Test Gym', createdAt: DateTime.utc(2026)),
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => const [];

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => const [];

  @override
  Future<List<Muscle>> fetchAllMuscles() async => const [];

  @override
  Future<String?> getAppState(String key) async => '1';

  @override
  Future<void> setAppState(String key, String? value) async {}

  @override
  Future<int> findOrCreateExerciseDefinition(
    String name,
    String equipmentName,
  ) async => 1;

  @override
  Future<ExerciseDefinition?> fetchDefinitionById(int defId) async =>
      _definition;

  @override
  Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) async =>
      const [];

  @override
  Future<bool> getUseManualMuscles(int defId) async => false;

  @override
  Future<Map<BodyPart, double>> computeMuscleCalculatedBodyparts(
    int defId,
  ) async => {_chest: 1};

  @override
  Future<List<ExerciseBodyPartPercent>> fetchBodyPartPercentsManual(
    int defId,
  ) async => const [];

  @override
  Future<bool> getUseManualBodyparts(int defId) async => false;

  @override
  Future<List<ExerciseMediaItem>> fetchExerciseMedia(int defId) async =>
      const [];

  @override
  Future<bool> getMultiplyByRating(int defId) async => false;
}

class _EditorPresentationDatabase implements DatabaseHelper {
  @override
  Future<List<GymProfile>> fetchAllProfiles() async => [
    GymProfile(id: 1, name: 'Test Gym', createdAt: DateTime.utc(2026)),
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
