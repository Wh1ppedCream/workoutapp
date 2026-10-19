import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/preset_generation_qa.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Generate Plans back button follows the pushed route', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.${TutorialIds.generatePlans}': true,
    });
    await tester.pumpWidget(
      Provider<AppRepository>.value(
        value: _GenerationRepository(),
        child: MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                key: const ValueKey('open-generate-plans'),
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const PresetGenerationQaScreen(profileId: 1),
                  ),
                ),
                child: const Text('Open Generate Plans'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsNothing);
    await tester.tap(find.byKey(const ValueKey('open-generate-plans')));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('open-generate-plans')), findsOneWidget);
  });

  testWidgets('Expressive preset generation keeps form and action reachable', (
    tester,
  ) async {
    const layouts = <({Size size, double scale, double keyboardInset})>[
      (size: Size(320, 900), scale: 1, keyboardInset: 0),
      (size: Size(320, 900), scale: 2, keyboardInset: 280),
      (size: Size(390, 844), scale: 1.5, keyboardInset: 0),
      (size: Size(600, 1000), scale: 1, keyboardInset: 0),
      (size: Size(800, 390), scale: 1.5, keyboardInset: 0),
      (size: Size(1024, 768), scale: 2, keyboardInset: 0),
    ];
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<void> expectAboveGenerate(Finder control, String description) async {
      await tester.ensureVisible(control);
      await tester.pumpAndSettle();
      expect(
        tester.getRect(control).bottom,
        lessThanOrEqualTo(
          tester.getRect(find.byType(FloatingActionButton)).top,
        ),
        reason: '$description should scroll clear of Generate',
      );
    }

    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      for (final layout in layouts) {
        await tester.binding.setSurfaceSize(layout.size);
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.${TutorialIds.generatePlans}': true,
        });
        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: _GenerationRepository(),
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(layout.scale),
                  viewInsets: EdgeInsets.only(bottom: layout.keyboardInset),
                ),
                child: child!,
              ),
              home: const PresetGenerationQaScreen(profileId: 1),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pageContext = tester.element(
          find.byType(PresetGenerationQaScreen),
        );
        final strings = AppLocalizations.of(pageContext);
        expect(find.text(strings.generateIntroTitle), findsOneWidget);
        expect(find.text(strings.generatePlanCountPill(1)), findsOneWidget);
        expect(find.text(strings.generateButton(1)), findsOneWidget);
        final workoutSetup = find.text(strings.generateWorkoutSetupTitle);
        await tester.ensureVisible(workoutSetup);
        await tester.tap(workoutSetup);
        await tester.pumpAndSettle();

        final onePlanField = find.byWidgetPredicate(
          (widget) => widget is TextFormField && widget.controller?.text == '1',
        );
        expect(find.text(strings.generatePlanUnit(1)), findsOneWidget);
        await tester.ensureVisible(onePlanField);
        await tester.enterText(onePlanField, '2');
        await tester.pumpAndSettle();
        expect(find.text(strings.generatePlanUnit(2)), findsOneWidget);
        expect(find.text(strings.generatePlanCountPill(2)), findsOneWidget);
        expect(find.text(strings.generateButton(2)), findsOneWidget);
        expect(
          find.text(
            strings.generateSetupSummary(
              '2',
              '60',
              SessionSpec.defaultMaxSetsPerExercise.toString(),
            ),
          ),
          findsOneWidget,
        );
        final twoPlanField = find.byWidgetPredicate(
          (widget) => widget is TextFormField && widget.controller?.text == '2',
        );
        await tester.enterText(twoPlanField, '1');
        await tester.pumpAndSettle();

        final repsAndWeights = find.text(strings.generateRepsWeightsTitle);
        await tester.ensureVisible(repsAndWeights);
        await tester.tap(repsAndWeights);
        await tester.pumpAndSettle();

        final detailedReachabilityLayout =
            layout.size.width == 320 ||
            (layout.size.width == 390 && layout.scale >= 1.5);
        if (detailedReachabilityLayout) {
          final focus = find.text(strings.generateTrainingFocusTitle);
          await tester.ensureVisible(focus);
          await tester.tap(focus);
          await tester.pumpAndSettle();
          final focusExpansion = tester.widget<ExpansionTile>(
            find
                .ancestor(of: focus, matching: find.byType(ExpansionTile))
                .first,
          );
          final expandedHeaderColor = ListTileTheme.of(tester.element(focus))
              .tileColor;
          expect(
            expandedHeaderColor,
            isNot(focusExpansion.backgroundColor),
            reason: 'Expanded heading and contents use distinct tonal roles',
          );
          expect(focusExpansion.backgroundColor, isNotNull);
          expect(
            focusExpansion.collapsedBackgroundColor,
            focusExpansion.backgroundColor,
          );
          expect(
            focusExpansion.tilePadding,
            const EdgeInsets.fromLTRB(16, 7, 16, 7),
          );
          expect(
            focusExpansion.childrenPadding,
            const EdgeInsets.fromLTRB(16, 5, 16, 10),
          );
          expect(
            find.text(
              '${strings.generateFocusPreferred} (+) · ${strings.generateFocusAvoided} (−) · ${strings.generateFocusNeutral} (↺)',
            ),
            findsOneWidget,
          );
          expect(
            tester
                .widget<Text>(find.text(strings.optimizedBodypartFocusTitle))
                .textAlign,
            TextAlign.start,
          );
          expect(
            tester
                .widget<Text>(find.text(strings.optimizedWeightIntensity))
                .textAlign,
            TextAlign.start,
          );
          expect(
            find.text(
              '${strings.generateFocusCountsSummary(0, 0)}\n${strings.generateRecentTrainingOffSummary}',
            ),
            findsOneWidget,
          );

          final useRecentTraining = find.byKey(
            const ValueKey('generate-use-recent-training'),
          );
          final recentTrainingCheckbox = find.descendant(
            of: useRecentTraining,
            matching: find.byType(Checkbox),
          );
          expect(recentTrainingCheckbox, findsOneWidget);
          expect(
            (tester.getRect(recentTrainingCheckbox).center.dy -
                    tester
                        .getRect(find.text(strings.generateUseRecentTraining))
                        .center
                        .dy)
                .abs(),
            lessThanOrEqualTo(1),
            reason: 'Recent-training checkbox should align with its heading',
          );
          await tester.ensureVisible(useRecentTraining);
          await tester.tap(useRecentTraining);
          await tester.pumpAndSettle();
          expect(
            find.text(
              '${strings.generateFocusCountsSummary(0, 0)}\n${strings.generateRecentTrainingOnSummary}',
            ),
            findsOneWidget,
          );
          await tester.tap(useRecentTraining);
          await tester.pumpAndSettle();

          final focusChips = find.byType(RawChip);
          final preferredChip = focusChips.first;
          expect(
            find.descendant(
              of: preferredChip,
              matching: find.byIcon(Icons.radio_button_unchecked),
            ),
            findsOneWidget,
          );
          await tester.ensureVisible(preferredChip);
          await tester.tap(preferredChip);
          await tester.pumpAndSettle();
          expect(
            find.descendant(
              of: preferredChip,
              matching: find.byIcon(Icons.add_circle_outline),
            ),
            findsOneWidget,
          );
          await tester.ensureVisible(preferredChip);
          await tester.tap(preferredChip);
          await tester.pumpAndSettle();
          expect(
            find.descendant(
              of: preferredChip,
              matching: find.byIcon(Icons.remove_circle_outline),
            ),
            findsOneWidget,
          );
          final secondPreferredChip = find.byType(RawChip).at(1);
          await tester.ensureVisible(secondPreferredChip);
          await tester.tap(secondPreferredChip);
          await tester.pumpAndSettle();

          expect(
            find.text(
              '${strings.generateFocusCountsSummary(1, 1)}\n${strings.generateRecentTrainingOffSummary}',
            ),
            findsOneWidget,
          );
          await expectAboveGenerate(
            find.byType(RawChip).last,
            'Last body part chip at $layout',
          );

          await expectAboveGenerate(
            find.byType(TextFormField).last,
            'Final reps and weights field at $layout',
          );
          await expectAboveGenerate(
            find.text(strings.intensityHard),
            'Final reps and weights option at $layout',
          );

          final setAllocation = find.text(strings.generateSetAllocationTitle);
          await tester.ensureVisible(setAllocation);
          await tester.tap(setAllocation);
          await tester.pumpAndSettle();
          final bodypartRankings = find.text(
            strings.generateBodypartRankingsTitle,
          );
          await tester.ensureVisible(bodypartRankings);
          await tester.tap(bodypartRankings);
          await tester.pumpAndSettle();
          await expectAboveGenerate(
            find.text(strings.generateRankBodyparts),
            'Set allocation rank action at $layout',
          );
          final muscleRankings = find.text(strings.generateMuscleRankingsTitle);
          await tester.ensureVisible(muscleRankings);
          await tester.tap(muscleRankings);
          await tester.pumpAndSettle();
          await expectAboveGenerate(
            find.text(strings.generateRankMuscles),
            'Final set allocation action at $layout',
          );
        }

        expect(find.byType(TextFormField), findsNWidgets(4));
        final initialException = tester.takeException();
        expect(initialException, isNull, reason: '$brightness $layout');

        if (layout.keyboardInset > 0) {
          final sessionLength = find.byWidgetPredicate(
            (widget) =>
                widget is TextFormField && widget.controller?.text == '60',
          );
          await tester.ensureVisible(sessionLength);
          await tester.tap(sessionLength);
          await tester.enterText(sessionLength, '50');
          await tester.pumpAndSettle();
        }

        final generate = find.byType(FloatingActionButton);
        final trailingField = find.byType(TextFormField).last;
        await tester.ensureVisible(trailingField);
        await tester.pumpAndSettle();
        expect(generate.hitTestable(), findsOneWidget, reason: '$layout');
        expect(
          tester.getRect(generate).bottom,
          lessThanOrEqualTo(layout.size.height - layout.keyboardInset),
          reason: '$layout',
        );
        expect(
          tester.getRect(trailingField).bottom,
          lessThanOrEqualTo(tester.getRect(generate).top),
          reason:
              'Trailing form control should scroll clear of Generate: $layout',
        );
        expect(tester.takeException(), isNull, reason: '$brightness $layout');
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });
}

class _GenerationRepository extends AppRepository {
  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => <BodyPart>[
    BodyPart(1, 'Chest'),
    BodyPart(2, 'Back'),
    BodyPart(3, 'Legs'),
  ];
}
