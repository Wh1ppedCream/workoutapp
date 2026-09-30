import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/session_screen.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/widgets/exercise_card.dart';
import 'package:env_test/widgets/weight_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'SessionScreen opts in Classic and Expressive while leaving Neo unchanged',
    (tester) async {
      final cases = <({ThemeData theme, bool animates})>[
        (theme: AppThemeFactory.light(AppThemeFamily.classic), animates: true),
        (theme: ExpressiveThemeDefinition.light(), animates: true),
        (
          theme: AppThemeFactory.light(AppThemeFamily.neoBrutalism),
          animates: false,
        ),
      ];

      for (final testCase in cases) {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'guided_tutorial_completed.${TutorialIds.firstWorkoutSession}': true,
        });
        final repository = _EmptyRepository();
        final session = ActiveSession(
          repository: repository,
          retryDelay: (_) async {},
        );
        final unitPreferences = UnitPreferenceProvider();
        addTearDown(session.dispose);
        addTearDown(unitPreferences.dispose);
        await Future.wait<void>([session.ready, unitPreferences.ready]);
        session
          ..exercises.add(_exercise())
          ..cardTypes.add(CardType.weight);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ActiveSession>.value(value: session),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: unitPreferences,
              ),
              Provider<AppRepository>.value(value: repository),
            ],
            child: MaterialApp(
              theme: testCase.theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SessionScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 421));
        await tester.pumpAndSettle();

        final card = tester.widget<WeightCard>(find.byType(WeightCard));
        expect(card.animateExpansion, testCase.animates);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets(
    'Expressive set expansion keeps the shared Classic 180 ms transition',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.firstWorkoutSession}': true,
      });
      final repository = _EmptyRepository();
      final session = ActiveSession(
        repository: repository,
        retryDelay: (_) async {},
      );
      final unitPreferences = UnitPreferenceProvider();
      addTearDown(session.dispose);
      addTearDown(unitPreferences.dispose);
      await Future.wait<void>([session.ready, unitPreferences.ready]);
      session
        ..exercises.add(_exercise())
        ..cardTypes.add(CardType.weight);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ActiveSession>.value(value: session),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(
              value: unitPreferences,
            ),
            Provider<AppRepository>.value(value: repository),
          ],
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SessionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 421));
      await tester.pumpAndSettle();

      final cardFinder = find.byType(WeightCard);
      final strings = AppLocalizations.of(tester.element(cardFinder));
      final expandedHeight = tester.getSize(cardFinder).height;
      await tester.tap(find.byTooltip(strings.weightCollapseSets));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final halfwayHeight = tester.getSize(cardFinder).height;
      await tester.pump(const Duration(milliseconds: 120));
      final collapsedHeight = tester.getSize(cardFinder).height;

      expect(halfwayHeight, lessThan(expandedHeight));
      expect(halfwayHeight, greaterThan(collapsedHeight));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Expressive preserves reduced-motion completion and menu interactions',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final exercise = _exercise();

      await tester.pumpWidget(
        _expressiveWeightCardHost(exercise, disableAnimations: true),
      );
      await tester.pumpAndSettle();

      final card = find.byType(WeightCard);
      final strings = AppLocalizations.of(tester.element(card));
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(2));
      expect(tester.getSize(checkboxes.first), const Size(48, 48));
      expect(find.byType(TextFormField), findsNWidgets(4));

      final menuTooltip = MaterialLocalizations.of(tester.element(card))
          .showMenuTooltip;
      await tester.tap(find.byTooltip(menuTooltip));
      await tester.pumpAndSettle();
      expect(find.text(strings.weightMakeChangeSet), findsOneWidget);
      await tester.tapAt(const Offset(390, 880));
      await tester.pumpAndSettle();
      expect(find.text(strings.weightMakeChangeSet), findsNothing);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();
      expect(exercise.completedParents, {0});
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.byTooltip(strings.weightCollapseSets), findsOneWidget);

      await tester.tap(find.byType(Checkbox).last);
      await tester.pump();
      expect(exercise.completedParents, {0, 1});
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byTooltip(strings.weightExpandSets), findsOneWidget);

      await tester.tap(find.byTooltip(strings.weightExpandSets));
      await tester.pump();
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(
        tester
            .widgetList<Checkbox>(find.byType(Checkbox))
            .map((checkbox) => checkbox.value),
        everyElement(isTrue),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

WeightExercise _exercise() => WeightExercise(
  name: 'Squat',
  equipment: 'Barbell',
  sets: [ExerciseSet(weight: 100, reps: 5), ExerciseSet(weight: 95, reps: 8)],
);

Widget _expressiveWeightCardHost(
  WeightExercise exercise, {
  bool disableAnimations = false,
}) => MaterialApp(
  theme: ExpressiveThemeDefinition.light(),
  themeAnimationDuration: Duration.zero,
  locale: const Locale('en'),
  localizationsDelegates: tonosLocalizationDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(disableAnimations: disableAnimations),
      child: Scaffold(
        body: SingleChildScrollView(
          child: WeightCard(
            exercise: exercise,
            previewWeightUnit: WeightUnit.pounds,
            animateExpansion: true,
          ),
        ),
      ),
    ),
  ),
);

class _EmptyRepository extends AppRepository {
  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];

  @override
  Future<int> findOrCreateExerciseDefinition(
    String name,
    String equipmentName,
  ) async => 1;

  @override
  Future<ExerciseDefinition?> fetchDefinitionById(int definitionId) async =>
      null;
}
