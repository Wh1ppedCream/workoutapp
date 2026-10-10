import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/analytics_destination_surfaces.dart';
import 'package:env_test/screens/profile/settings/exercise_editor_screen.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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
            (family, brightness, false),
        for (final brightness in Brightness.values) (null, brightness, true),
      ];

      for (final (family, brightness, expressive) in cases) {
        final repository = _EditorPresentationRepository();
        final theme = expressive
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
            ? AppThemeFactory.light(family!)
            : AppThemeFactory.dark(family!);
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
            ? ExpressiveTrainShapes.focusHero
            : theme.shapeTokens.settingsTitleCard;
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.padding ==
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 15) &&
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
        await tester.tap(find.text(strings.exerciseEditorCreateCustomTitle));
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
        expect(find.byType(TabBar), findsOneWidget, reason: mode);
        final editorContext = tester.element(find.byType(ExerciseEditorScreen));
        final scheme = Theme.of(editorContext).colorScheme;
        final surfaces = editorContext.surfaceTokens;
        final tabContainerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.child is TabBar &&
              widget.decoration is BoxDecoration,
        );
        final tabContainer = tester.widget<Container>(tabContainerFinder);
        final tabDecoration = tabContainer.decoration! as BoxDecoration;
        final tabBar = tester.widget<TabBar>(find.byType(TabBar));

        if (expressive) {
          final tokens = AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.analytics,
            brightness,
          );
          expect(tabDecoration.color, tokens.surfacePrimary, reason: mode);
          expect(
            (tabDecoration.border! as Border).top.color,
            tokens.outlineAccent,
            reason: mode,
          );
          expect(tabBar.labelColor, tokens.onSurfaceSelected, reason: mode);
          expect(
            tabBar.unselectedLabelColor,
            tokens.onSurfacePrimary.withValues(alpha: 0.82),
            reason: mode,
          );
          expect(
            (tabBar.indicator! as BoxDecoration).color,
            tokens.surfaceSelected,
            reason: mode,
          );

          final analyticsRoles = tester
              .widgetList<AnalyticsZone>(find.byType(AnalyticsZone))
              .map((zone) => zone.role)
              .toSet();
          expect(
            analyticsRoles,
            containsAll({
              AnalyticsSurfaceRole.primary,
              AnalyticsSurfaceRole.secondary,
            }),
            reason: mode,
          );
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Material && widget.color == tokens.surfaceAccent,
            ),
            findsOneWidget,
            reason: '$mode allocation shortcut uses its accent role',
          );
          expect(find.byType(SettingsSaveBar), findsOneWidget, reason: mode);
          expect(
            Theme.of(tester.element(find.byType(SettingsSaveBar)))
                .colorScheme
                .primary,
            tokens.actionPrimary,
            reason: '$mode save action keeps the Analytics action color',
          );

          final tabs = <(String, AnalyticsSurfaceRole)>[
            (strings.exerciseEditorBodyparts, AnalyticsSurfaceRole.tertiary),
            (strings.exerciseEditorEquipment, AnalyticsSurfaceRole.accent),
            (strings.exerciseEditorGuide, AnalyticsSurfaceRole.selected),
          ];
          for (final (label, role) in tabs) {
            await tester.tap(find.text(label));
            await tester.pumpAndSettle();
            expect(
              tester
                  .widgetList<AnalyticsZone>(find.byType(AnalyticsZone))
                  .any((zone) => zone.role == role),
              isTrue,
              reason: '$mode $label tab gets its semantic surface role',
            );
          }
        } else {
          final neo = family == AppThemeFamily.neoBrutalism;
          final expectedSurface = neo
              ? surfaces.settingsSection
              : scheme.surfaceContainerHighest.withValues(alpha: 0.34);
          expect(tabDecoration.color, expectedSurface, reason: mode);
          expect(
            tabBar.labelColor,
            neo
                ? tonosForegroundForSurface(editorContext, expectedSurface)
                : SettingsAccent.advanced,
            reason: mode,
          );
          expect(
            (tabBar.indicator! as BoxDecoration).color,
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
      await tester.tap(find.byTooltip(strings.exerciseEditorCreate));
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
}

class _EditorPresentationRepository extends AppRepository {
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
