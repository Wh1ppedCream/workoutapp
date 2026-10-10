import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/analytics_setting_screen.dart';
import 'package:env_test/screens/profile/settings/bodypart_muscle_mapping_screen.dart';
import 'package:env_test/screens/profile/settings/bodypart_ranking_screen.dart';
import 'package:env_test/screens/profile/settings/exercise_analytics_screen.dart';
import 'package:env_test/screens/profile/settings/exercise_editor_screen.dart';
import 'package:env_test/screens/profile/settings/muscle_ranking_screen.dart';
import 'package:env_test/screens/profile/settings/volume_boundaries_screen.dart';
import 'package:env_test/screens/profile/settings/analytics_destination_surfaces.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Expressive Analytics header wraps fully at compact text scales', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const title = 'Recommended weekly volume boundaries for every muscle group';
    const subtitle =
        'Review the full training range and recovery guidance before changing these values.';

    for (final brightness in Brightness.values) {
      for (final scale in const [1.5, 2.0]) {
        final theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF345B50),
            brightness: brightness,
          ),
          extensions: const [
            AppThemeIdentity(family: AppThemeFamilyIdentity.expressivePreview),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: const Scaffold(
                  body: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: AnalyticsRouteHeader(
                      title: title,
                      subtitle: subtitle,
                      icon: Icons.track_changes,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final titleFinder = find.text(title);
        final subtitleFinder = find.text(subtitle);
        expect(titleFinder, findsOneWidget, reason: '$brightness $scale×');
        expect(subtitleFinder, findsOneWidget, reason: '$brightness $scale×');
        for (final finder in [titleFinder, subtitleFinder]) {
          await tester.ensureVisible(finder);
          await tester.pumpAndSettle();
          final text = tester.widget<Text>(finder);
          expect(text.maxLines, isNull, reason: '$brightness $scale×');
          expect(text.overflow, isNull, reason: '$brightness $scale×');
          expect(
            tester.getRect(finder).bottom,
            lessThanOrEqualTo(900),
            reason: '$brightness $scale× content stays in the viewport',
          );
        }
        expect(
          tester.takeException(),
          isNull,
          reason: '$brightness $scale× must not overflow',
        );
      }
    }
  });

  testWidgets(
    'Analytics child routes retain controls and scoped palette at compact scale',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final bodyPart = BodyPart(1, 'Chest');
      final muscle = Muscle(id: 2, name: 'Pectoralis major');
      final definition = ExerciseDefinition(
        id: 3,
        name: 'Cable Press',
        bodyParts: [bodyPart],
        muscles: [RankedMuscle(muscle: muscle, rank: 1)],
        useManualBodyparts: false,
        multiplyByRating: false,
      );
      final repository = _AnalyticsRoutesRepository(
        bodyPart,
        muscle,
        definition,
      );
      const responsiveLayouts =
          <({Size size, double textScale, double keyboardInset})>[
            (size: Size(320, 900), textScale: 1, keyboardInset: 0),
            (size: Size(320, 900), textScale: 1.5, keyboardInset: 0),
            (size: Size(320, 900), textScale: 2, keyboardInset: 260),
            (size: Size(390, 844), textScale: 1.5, keyboardInset: 0),
            (size: Size(600, 1000), textScale: 1.5, keyboardInset: 0),
            (size: Size(800, 390), textScale: 1.5, keyboardInset: 0),
            (size: Size(1024, 768), textScale: 2, keyboardInset: 0),
          ];
      final cases =
          <
            ({
              AppThemeFamily? family,
              Brightness brightness,
              bool expressive,
              Size size,
              double textScale,
              double keyboardInset,
            })
          >[
            for (final family in AppThemeFamily.values)
              for (final brightness in Brightness.values)
                (
                  family: family,
                  brightness: brightness,
                  expressive: false,
                  size: const Size(390, 844),
                  textScale: 1,
                  keyboardInset: 0,
                ),
            for (final brightness in Brightness.values)
              for (final layout in responsiveLayouts)
                (
                  family: null,
                  brightness: brightness,
                  expressive: true,
                  size: layout.size,
                  textScale: layout.textScale,
                  keyboardInset: layout.keyboardInset,
                ),
          ];

      for (final configuration in cases) {
        final family = configuration.family;
        final brightness = configuration.brightness;
        final expressive = configuration.expressive;
        await tester.binding.setSurfaceSize(configuration.size);
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
            ? 'expressive ${brightness.name} ${configuration.size.width}dp '
                  '${configuration.textScale}x'
            : '${family!.code} ${brightness.name}';

        Future<void> mount(Widget page) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [Provider<AppRepository>.value(value: repository)],
              child: MaterialApp(
                key: UniqueKey(),
                theme: theme,
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(configuration.textScale),
                    viewInsets: EdgeInsets.only(
                      bottom: configuration.keyboardInset,
                    ),
                  ),
                  child: child!,
                ),
                home: page,
              ),
            ),
          );
          await tester.pumpAndSettle();
        }

        await mount(const BodyPartRankingScreen());
        final rankingList = expressive
            ? find.byType(SliverReorderableList, skipOffstage: false)
            : find.byType(ReorderableListView);
        expect(rankingList, findsOneWidget, reason: mode);
        final bodyPartField = find.byType(
          TextFormField,
          skipOffstage: expressive ? false : true,
        );
        expect(bodyPartField, findsOneWidget, reason: mode);
        await tester.ensureVisible(bodyPartField);
        await tester.pumpAndSettle();
        final visibleBodyPartField = find.byType(TextFormField).first;
        expect(visibleBodyPartField, findsOneWidget, reason: mode);
        final bodyPartStrings = AppLocalizations.of(
          tester.element(find.byType(BodyPartRankingScreen)),
        );
        await tester.enterText(visibleBodyPartField, '2');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(
          find.text(bodyPartStrings.rankingsSave),
          findsOneWidget,
          reason: mode,
        );
        await tester.tap(find.text(bodyPartStrings.rankingsSave));
        await tester.pumpAndSettle();
        expect(
          repository.bodyPartSaveCalls,
          greaterThanOrEqualTo(1),
          reason: mode,
        );
        expect(repository.savedBodyPartRanks, {
          bodyPart.id: 2,
        }, reason: '$mode saves the edited Body Part rank value');
        _expectAnalyticsScope(tester, expressive, brightness, mode);
        expect(tester.takeException(), isNull, reason: '$mode body part rank');

        await mount(const MuscleRankingScreen());
        final muscleRankingList = expressive
            ? find.byType(SliverReorderableList, skipOffstage: false)
            : find.byType(ReorderableListView);
        expect(muscleRankingList, findsOneWidget, reason: mode);
        final muscleRankingField = find.byType(
          TextFormField,
          skipOffstage: expressive ? false : true,
        );
        expect(muscleRankingField, findsOneWidget, reason: mode);
        await tester.ensureVisible(muscleRankingField);
        await tester.pumpAndSettle();
        final visibleMuscleField = find.byType(TextFormField).first;
        expect(visibleMuscleField, findsOneWidget, reason: mode);
        final muscleStrings = AppLocalizations.of(
          tester.element(find.byType(MuscleRankingScreen)),
        );
        await tester.enterText(visibleMuscleField, '2');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(
          find.text(muscleStrings.rankingsSave),
          findsOneWidget,
          reason: mode,
        );
        await tester.tap(find.text(muscleStrings.rankingsSave));
        await tester.pumpAndSettle();
        expect(
          repository.muscleSaveCalls,
          greaterThanOrEqualTo(1),
          reason: mode,
        );
        _expectAnalyticsScope(tester, expressive, brightness, mode);
        expect(tester.takeException(), isNull, reason: '$mode muscle rank');

        await mount(const VolumeBoundariesScreen());
        // Earlier ranking saves leave a SnackBar in the shared messenger.
        ScaffoldMessenger.of(
          tester.element(find.byType(VolumeBoundariesScreen)),
        ).clearSnackBars();
        await tester.pumpAndSettle();
        final volumeStrings = AppLocalizations.of(
          tester.element(find.byType(VolumeBoundariesScreen)),
        );
        expect(find.byType(TabBar), findsOneWidget, reason: mode);
        final volumePicker = expressive
            ? find.byKey(const ValueKey('volume-choice-body-part'))
            : find.byType(DropdownButtonFormField<BodyPart>);
        for (
          var attempt = 0;
          expressive && attempt < 8 && volumePicker.evaluate().isEmpty;
          attempt++
        ) {
          await tester.drag(find.byType(ListView).last, const Offset(0, -180));
          await tester.pumpAndSettle();
        }
        expect(volumePicker, findsOneWidget, reason: mode);
        final volumeFields = find.byType(TextFormField);
        for (
          var attempt = 0;
          expressive && attempt < 8 && volumeFields.evaluate().isEmpty;
          attempt++
        ) {
          await tester.drag(find.byType(ListView).last, const Offset(0, -180));
          await tester.pumpAndSettle();
        }
        expect(volumeFields, findsNWidgets(4), reason: mode);
        if (expressive) {
          final firstBoundary = volumeFields.first;
          await tester.ensureVisible(firstBoundary);
          await tester.pumpAndSettle();
          await tester.tap(firstBoundary);
          await tester.enterText(firstBoundary, '5');
          await tester.pumpAndSettle();
          final saveBoundaries = find.text(volumeStrings.volumeSaveBoundaries);
          await tester.ensureVisible(saveBoundaries);
          await tester.pumpAndSettle();
          expect(saveBoundaries.hitTestable(), findsOneWidget, reason: mode);
          expect(
            tester.getRect(saveBoundaries).bottom,
            lessThanOrEqualTo(
              configuration.size.height - configuration.keyboardInset,
            ),
            reason: '$mode volume save remains above the keyboard inset',
          );
        }
        _expectAnalyticsScope(tester, expressive, brightness, mode);
        expect(tester.takeException(), isNull, reason: '$mode volume bounds');

        await mount(const BodyPartMuscleMappingScreen());
        final strings = AppLocalizations.of(
          tester.element(find.byType(BodyPartMuscleMappingScreen)),
        );
        final mappingPicker = find.byType(DropdownButtonFormField<BodyPart>);
        for (
          var attempt = 0;
          expressive && attempt < 8 && mappingPicker.evaluate().isEmpty;
          attempt++
        ) {
          await tester.drag(find.byType(ListView).last, const Offset(0, -180));
          await tester.pumpAndSettle();
        }
        expect(mappingPicker, findsOneWidget, reason: mode);
        await tester.ensureVisible(mappingPicker);
        await tester.pumpAndSettle();
        if (!expressive) {
          expect(find.byType(CheckboxListTile), findsNothing, reason: mode);
          await tester.tap(find.text(strings.commonEdit));
          await tester.pumpAndSettle();
          expect(find.byType(CheckboxListTile), findsOneWidget, reason: mode);
          expect(find.text(strings.commonSave), findsOneWidget, reason: mode);
        } else {
          final edit = find.text(strings.commonEdit);
          expect(edit.hitTestable(), findsOneWidget, reason: mode);
          await tester.tap(edit);
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.byType(CheckboxListTile),
            180,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(find.byType(CheckboxListTile), findsOneWidget, reason: mode);
          final save = find.text(strings.commonSave);
          expect(save.hitTestable(), findsOneWidget, reason: mode);
          expect(
            tester.getRect(save).bottom,
            lessThanOrEqualTo(configuration.size.height),
            reason: '$mode mapping save remains within the visible viewport',
          );
        }
        _expectAnalyticsScope(tester, expressive, brightness, mode);
        expect(tester.takeException(), isNull, reason: '$mode body mapping');

        await mount(const AnalyticsSettingsScreen());
        expect(
          find.byType(AnalyticsSettingsScreen),
          findsOneWidget,
          reason: mode,
        );
        expect(find.byType(Scaffold), findsOneWidget, reason: mode);
        _expectAnalyticsScope(tester, expressive, brightness, mode);
        final hubStrings = AppLocalizations.of(
          tester.element(find.byType(AnalyticsSettingsScreen)),
        );
        expect(
          find.text(hubStrings.settingsWorkoutTitle),
          findsOneWidget,
          reason: '$mode Workout Settings title appears once',
        );
        if (expressive) {
          expect(find.byType(AppBar), findsNothing, reason: mode);
          expect(
            find.byTooltip(hubStrings.commonBack),
            findsOneWidget,
            reason: '$mode compact in-page back navigation',
          );
          final exerciseEditor = find.text(hubStrings.settingsExerciseEditor);
          await tester.scrollUntilVisible(
            exerciseEditor,
            160,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(
            exerciseEditor.hitTestable(),
            findsOneWidget,
            reason: '$mode final Exercise Editor row remains reachable',
          );
          expect(
            tester.getRect(exerciseEditor).bottom,
            lessThanOrEqualTo(configuration.size.height),
            reason: '$mode final row remains within the viewport',
          );
        }
        expect(tester.takeException(), isNull, reason: '$mode analytics hub');

        await mount(ExerciseAnalyticsScreen(initialDefinition: definition));
        expect(
          find.byType(ExerciseAnalyticsScreen),
          findsOneWidget,
          reason: mode,
        );
        if (expressive) {
          for (
            var attempt = 0;
            attempt < 10 &&
                find
                    .byType(TextFormField, skipOffstage: false)
                    .evaluate()
                    .isEmpty;
            attempt++
          ) {
            // At large text scales the route header can extend below the
            // viewport before the nested allocation list is laid out.
            await tester.dragFrom(
              Offset(
                configuration.size.width / 2,
                configuration.size.height / 2,
              ),
              const Offset(0, -240),
            );
            await tester.pumpAndSettle();
          }
          final allCreditFields = find.byType(
            TextFormField,
            skipOffstage: false,
          );
          expect(allCreditFields, findsAtLeastNWidgets(1), reason: mode);
          final creditField = allCreditFields.first;
          await tester.ensureVisible(creditField);
          await tester.pumpAndSettle();
          expect(find.byType(TextFormField), findsOneWidget, reason: mode);
          final visibleCreditField = find.byType(TextFormField).first;
          await tester.tap(visibleCreditField);
          await tester.enterText(visibleCreditField, '1.25');
          await tester.pumpAndSettle();
          final save = find.text(
            AppLocalizations.of(
              tester.element(find.byType(ExerciseAnalyticsScreen)),
            ).allocationSaveChanges,
          );
          expect(save.hitTestable(), findsOneWidget, reason: mode);
          expect(
            tester.getRect(save).bottom,
            lessThanOrEqualTo(
              configuration.size.height - configuration.keyboardInset,
            ),
            reason: '$mode allocation save remains above keyboard inset',
          );
        }
        _expectAnalyticsScope(tester, expressive, brightness, mode);
        expect(
          tester.takeException(),
          isNull,
          reason: '$mode allocation route',
        );

        await mount(const ExerciseEditorScreen());
        expect(find.byType(ExerciseEditorScreen), findsOneWidget, reason: mode);
        final editorStrings = AppLocalizations.of(
          tester.element(find.byType(ExerciseEditorScreen)),
        );
        expect(
          find.byTooltip(editorStrings.exerciseEditorChoose),
          findsOneWidget,
          reason: mode,
        );
        _expectAnalyticsScope(tester, expressive, brightness, mode);
        expect(tester.takeException(), isNull, reason: '$mode editor route');
      }
    },
  );
}

void _expectAnalyticsScope(
  WidgetTester tester,
  bool expressive,
  Brightness brightness,
  String mode,
) {
  final scaffold = tester.element(find.byType(Scaffold).first);
  final tokens = Theme.of(scaffold).extension<AppExpressiveDestinationTokens>();
  if (!expressive) {
    expect(tokens, isNull, reason: mode);
    return;
  }
  expect(
    tokens?.family,
    AppExpressiveDestinationFamily.analytics,
    reason: mode,
  );
  expect(
    tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
    AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.analytics,
      brightness,
    ).pageCanvas,
    reason: mode,
  );
}

class _AnalyticsRoutesRepository extends AppRepository {
  _AnalyticsRoutesRepository(this.bodyPart, this.muscle, this.definition);

  final BodyPart bodyPart;
  final Muscle muscle;
  final ExerciseDefinition definition;
  int bodyPartSaveCalls = 0;
  int muscleSaveCalls = 0;
  final Map<int, int> savedBodyPartRanks = {};

  @override
  Future<List<BodyPart>> fetchAllBodyPartsFull() async => [bodyPart];

  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => [muscle];

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => [bodyPart];

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => [definition];

  @override
  Future<List<Equipment>> fetchAllEquipment() async => const [];

  @override
  Future<ResolvedExerciseAllocation> resolveExerciseAllocation(
    int defId,
  ) async => ResolvedExerciseAllocation(
    exerciseDefinitionId: defId,
    muscleCredits: {muscle.id: 1.0},
    bodyPartCredits: {bodyPart.id: 1.0},
    derivedBodyPartCredits: {bodyPart.id: 1.0},
    muscleHistoryCredits: const {},
    bodyPartHistoryCredits: const {},
    muscleSource: ExerciseAllocationSource.automatic,
    bodyPartSource: ExerciseAllocationSource.automatic,
  );

  @override
  Future<List<BodyPartRanking>> getAllBodyPartRanks() async => [
    BodyPartRanking(bodyPartId: bodyPart.id, rank: 1),
  ];

  @override
  Future<List<MuscleRanking>> getAllMuscleRanks() async => [
    MuscleRanking(muscleId: muscle.id, rank: 1),
  ];

  @override
  Future<List<MuscleBodyPart>> fetchMusclesForBodyPart(int bodypartId) async =>
      [MuscleBodyPart(muscleId: muscle.id, bodyPartId: bodypartId)];

  @override
  Future<int> setBodyPartRank(int bodypartId, int rank) async {
    bodyPartSaveCalls++;
    savedBodyPartRanks[bodypartId] = rank;
    return bodyPartSaveCalls;
  }

  @override
  Future<int> setMuscleRank(int muscleId, int rank) async {
    muscleSaveCalls++;
    return muscleSaveCalls;
  }

  @override
  Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) async =>
      VolumeBoundaries(
        id: bodyPartId,
        maintenance: 4,
        minEffective: 6,
        maxAdaptive: 12,
        maxRecoverable: 20,
      );

  @override
  Future<VolumeBoundaries?> fetchMuscleVolumeBounds(int muscleId) async =>
      VolumeBoundaries(
        id: muscleId,
        maintenance: 3,
        minEffective: 5,
        maxAdaptive: 10,
        maxRecoverable: 18,
      );
}
