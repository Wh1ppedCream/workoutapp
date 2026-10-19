import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/screens/exercise/optimized_workout_settings_page.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/expressive_planning_tokens.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_field.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? AppThemeFactory.light(family)
          : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode optimized settings retain numeric field recipes', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(430, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: TickerMode(
              enabled: false,
              child: OptimizedWorkoutSettingsPage(
                initialMinutes: 45,
                initialMinSets: 2,
                initialMaxSets: 4,
                initialRepWeightMode: RepWeightGenerationMode.mixed,
                initialTargetRepCount: 8,
                initialStarterWeightIntensity: StarterWeightIntensity.medium,
                initialPreferredBodypartIds: const <int>{},
                initialBlacklistedBodypartIds: const <int>{},
                bodyParts: const <BodyPart>[],
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(TonosFormField), findsNWidgets(4));
        final strings = AppLocalizations.of(
          tester.element(find.byType(OptimizedWorkoutSettingsPage)),
        );
        final labels = [
          strings.optimizedWorkoutDuration,
          strings.optimizedMinimumSets,
          strings.optimizedMaximumSets,
          strings.optimizedTargetReps,
        ];
        final suffixes = [
          strings.unitMinutesShort,
          strings.unitSets,
          strings.unitSets,
          strings.unitReps,
        ];
        final actions = [
          TextInputAction.next,
          TextInputAction.next,
          TextInputAction.done,
          TextInputAction.next,
        ];
        final fields = tester.widgetList<TextField>(find.byType(TextField));

        expect(fields, hasLength(4));
        for (var index = 0; index < fields.length; index++) {
          expect(fields.elementAt(index).decoration?.labelText, labels[index]);
          expect(
            fields.elementAt(index).decoration?.suffixText,
            suffixes[index],
          );
          expect(
            fields.elementAt(index).decoration?.border,
            const OutlineInputBorder(),
          );
          expect(fields.elementAt(index).keyboardType, TextInputType.number);
          expect(fields.elementAt(index).textInputAction, actions[index]);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final brightness in Brightness.values) {
    final theme = brightness == Brightness.light
        ? ExpressiveThemeDefinition.light()
        : ExpressiveThemeDefinition.dark();
    testWidgets(
      'Expressive ${brightness.name} settings styling and save result',
      (tester) async {
        tester.view.physicalSize = const Size(320, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        OptimizedWorkoutSettingsResult? submitted;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    submitted = await Navigator.of(context)
                        .push<OptimizedWorkoutSettingsResult>(
                          MaterialPageRoute(
                            builder: (_) => TickerMode(
                              enabled: false,
                              child: OptimizedWorkoutSettingsPage(
                                initialMinutes: 45,
                                initialMinSets: 2,
                                initialMaxSets: 4,
                                initialRepWeightMode:
                                    RepWeightGenerationMode.mixed,
                                initialTargetRepCount: 8,
                                initialStarterWeightIntensity:
                                    StarterWeightIntensity.medium,
                                initialPreferredBodypartIds: const <int>{},
                                initialBlacklistedBodypartIds: const <int>{},
                                bodyParts: [
                                  BodyPart(1, 'Chest'),
                                  BodyPart(2, 'Upper Back'),
                                ],
                              ),
                            ),
                          ),
                        );
                  },
                  child: const Text('Open settings'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open settings'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));

        final pageContext = tester.element(
          find.byType(OptimizedWorkoutSettingsPage),
        );
        final strings = AppLocalizations.of(pageContext);
        final planning = AppExpressivePlanningTokens.maybeOf(pageContext)!;
        final scaffold = tester.widget<Scaffold>(
          find.descendant(
            of: find.byType(OptimizedWorkoutSettingsPage),
            matching: find.byType(Scaffold),
          ),
        );
        expect(scaffold.backgroundColor, planning.pageCanvas);
        expect(scaffold.appBar, isA<AppBar>());
        final appBar = scaffold.appBar! as AppBar;
        expect(appBar.backgroundColor, planning.pageCanvas);
        expect(appBar.foregroundColor, planning.onPage);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.byTooltip(strings.commonReset), findsOneWidget);
        expect(scaffold.bottomNavigationBar, isNull);
        expect(
          scaffold.floatingActionButtonLocation,
          FloatingActionButtonLocation.endFloat,
        );
        final startButton = tester.widget<FloatingActionButton>(
          find.widgetWithText(FloatingActionButton, strings.commonStartNow),
        );
        final saveButton = tester.widget<FloatingActionButton>(
          find.widgetWithText(FloatingActionButton, strings.commonSave),
        );
        expect(
          tester.widget<Text>(find.text(strings.commonStartNow)).style?.color,
          planning.actionPrimaryForeground,
        );
        expect(
          tester.widget<Text>(find.text(strings.commonSave)).style?.color,
          planning.configurationForeground,
        );
        expect(startButton.backgroundColor, planning.actionPrimary);
        expect(
          saveButton.backgroundColor,
          brightness == Brightness.dark
              ? Color.lerp(
                  planning.configurationSurface,
                  planning.actionPrimary,
                  0.16,
                )
              : planning.configurationSurface,
        );
        expect(saveButton.foregroundColor, planning.configurationForeground);
        expect(
          (saveButton.shape as RoundedRectangleBorder).side.color,
          planning.outline.withValues(
            alpha: brightness == Brightness.dark ? 0.78 : 0.42,
          ),
        );
        final budgetCard = tester.widget<Card>(find.byType(Card).first);
        expect(budgetCard.color, planning.planFocalSurface);
        expect(budgetCard.shape, isA<RoundedRectangleBorder>());
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
        final repsHeading = find.text(strings.optimizedRepsWeightsTitle);
        await tester.ensureVisible(repsHeading);
        final repsCard = tester.widget<Card>(
          find.ancestor(of: repsHeading, matching: find.byType(Card)).first,
        );
        expect(
          repsCard.color,
          brightness == Brightness.dark
              ? Color.lerp(
                  planning.planSupportSurface,
                  planning.planFocalSurface,
                  0.18,
                )
              : planning.planSupportSurface,
        );
        expect(repsCard.shape, isA<RoundedRectangleBorder>());
        expect(repsCard.shape, budgetCard.shape);
        final firstChoice = tester.widget<ChoiceChip>(
          find.byType(ChoiceChip).first,
        );
        expect(firstChoice.selected, isTrue);
        expect(firstChoice.selectedColor, planning.selectedSurface);
        expect(find.byType(TonosFormField), findsNWidgets(4));
        final budgetCardFinder = find.byType(Card).first;
        final budgetFields = find.descendant(
          of: budgetCardFinder,
          matching: find.byType(EditableText),
        );
        expect(budgetFields, findsNWidgets(3));
        final fieldTheme = Theme.of(tester.element(budgetFields.first));
        expect(fieldTheme.inputDecorationTheme.filled, isTrue);
        expect(
          fieldTheme.inputDecorationTheme.fillColor,
          planning.configurationSurface,
        );
        expect(
          fieldTheme.inputDecorationTheme.suffixStyle?.color,
          planning.configurationForeground,
        );
        for (final field in tester.widgetList<EditableText>(budgetFields)) {
          expect(field.style.color, planning.configurationForeground);
        }
        for (final label in [
          strings.optimizedWorkoutDuration,
          strings.optimizedMinimumSets,
          strings.optimizedMaximumSets,
          strings.optimizedTargetReps,
        ]) {
          expect(find.text(label), findsOneWidget);
        }
        final focusHeading = find.text(strings.optimizedBodypartFocusTitle);
        await tester.drag(find.byType(ListView), const Offset(0, -2000));
        await tester.pumpAndSettle();
        await tester.ensureVisible(focusHeading);
        final focusCardFinder = find
            .ancestor(of: focusHeading, matching: find.byType(Card))
            .first;
        final focusCard = tester.widget<Card>(focusCardFinder);
        expect(focusCard.color, planning.configurationSurface);
        expect(focusCard.shape, isA<RoundedRectangleBorder>());
        expect(find.text('Preferred'), findsOneWidget);
        expect(find.text('Avoided'), findsOneWidget);
        expect(find.text('Neutral'), findsOneWidget);

        final focusChips = find.descendant(
          of: focusCardFinder,
          matching: find.byType(RawChip),
        );
        final focusChip = tester.widget<RawChip>(focusChips.first);
        final neutralSurface = brightness == Brightness.light
            ? Color.lerp(
                planning.configurationSurface,
                planning.planSupportSurface,
                0.28,
              )
            : Color.alphaBlend(
                planning.planFocalSurface.withValues(alpha: 0.22),
                planning.configurationSurface,
              );
        expect(focusChip.backgroundColor, neutralSurface);
        expect(
          focusChip.side?.color,
          brightness == Brightness.light
              ? planning.outline.withValues(alpha: 0.72)
              : planning.outline,
        );
        expect(
          focusChip.avatar,
          isA<Icon>()
              .having(
                (icon) => icon.icon,
                'neutral-state icon',
                Icons.radio_button_unchecked,
              )
              .having((icon) => icon.size, 'indicator size', 16),
        );
        final firstFocusChip = focusChips.first;
        await tester.ensureVisible(firstFocusChip);
        await tester.tap(firstFocusChip);
        await tester.pumpAndSettle();
        var updatedFocusChip = tester.widget<RawChip>(firstFocusChip);
        expect(updatedFocusChip.selected, isTrue);
        expect(updatedFocusChip.selectedColor, planning.actionPrimary);
        expect(updatedFocusChip.showCheckmark, isTrue);
        expect(
          (updatedFocusChip.avatar! as Icon).icon,
          Icons.add_circle_outline,
        );
        expect((updatedFocusChip.avatar! as Icon).size, 16);
        await tester.tap(firstFocusChip);
        await tester.pumpAndSettle();
        updatedFocusChip = tester.widget<RawChip>(firstFocusChip);
        expect(updatedFocusChip.showCheckmark, isFalse);
        expect((updatedFocusChip.avatar! as Icon).icon, Icons.block);
        final avoidedColor = pageContext.semanticColors.negative;
        expect((updatedFocusChip.avatar! as Icon).color, avoidedColor);
        expect(updatedFocusChip.side?.color, avoidedColor);
        expect(updatedFocusChip.labelStyle?.color, avoidedColor);
        expect((updatedFocusChip.avatar! as Icon).size, 16);
        expect(updatedFocusChip.selectedColor, isNot(planning.actionPrimary));
        await tester.tap(firstFocusChip);
        await tester.pumpAndSettle();
        expect(tester.widget<RawChip>(firstFocusChip).selected, isFalse);

        await tester.tap(
          find.widgetWithText(FloatingActionButton, strings.commonSave),
        );
        await tester.pumpAndSettle();
        expect(submitted?.action, OptimizedWorkoutSettingsAction.save);
        expect(submitted?.minutes, 45);
        expect(submitted?.minSets, 2);
        expect(submitted?.maxSets, 4);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Optimized settings stay reachable responsively', (tester) async {
    const layouts = <({Size size, double scale, double keyboardInset})>[
      (size: Size(320, 900), scale: 2, keyboardInset: 300),
      (size: Size(390, 844), scale: 1, keyboardInset: 0),
      (size: Size(600, 1000), scale: 1.5, keyboardInset: 0),
      (size: Size(800, 390), scale: 1.5, keyboardInset: 0),
      (size: Size(1024, 768), scale: 2, keyboardInset: 0),
    ];
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.resetViewInsets);

    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      for (final layout in layouts) {
        await tester.binding.setSurfaceSize(layout.size);
        tester.view.viewInsets = FakeViewPadding();
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.${TutorialIds.optimizedWorkoutSettings}':
              true,
        });
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(layout.scale)),
              child: child!,
            ),
            home: TickerMode(
              enabled: false,
              child: OptimizedWorkoutSettingsPage(
                initialMinutes: 45,
                initialMinSets: 2,
                initialMaxSets: 4,
                initialRepWeightMode: RepWeightGenerationMode.mixed,
                initialTargetRepCount: 8,
                initialStarterWeightIntensity: StarterWeightIntensity.medium,
                initialPreferredBodypartIds: const <int>{},
                initialBlacklistedBodypartIds: const <int>{},
                bodyParts: [
                  BodyPart(1, 'Chest'),
                  BodyPart(2, 'Upper Back'),
                  BodyPart(3, 'Shoulders'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));

        final pageContext = tester.element(
          find.byType(OptimizedWorkoutSettingsPage),
        );
        final strings = AppLocalizations.of(pageContext);
        final routeTitle = find.text(strings.trainOptimizedSettings);
        expect(routeTitle, findsOneWidget, reason: '$brightness $layout');
        final resetAction = find.byTooltip(strings.commonReset);
        expect(resetAction, findsOneWidget, reason: '$brightness $layout');
        expect(
          tester.getRect(routeTitle).overlaps(tester.getRect(resetAction)),
          isFalse,
          reason: '$brightness $layout',
        );
        final durationField = find.byType(EditableText).first;
        await tester.ensureVisible(durationField);
        if (layout.keyboardInset > 0) {
          await tester.showKeyboard(durationField);
          tester.view.viewInsets = FakeViewPadding(
            bottom: layout.keyboardInset * tester.view.devicePixelRatio,
          );
          await tester.pumpAndSettle();
          await tester.ensureVisible(durationField);
          await tester.enterText(durationField, '50');
          await tester.pumpAndSettle();
        }

        final scrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.text(strings.optimizedBodypartFocusTitle),
          300,
          scrollable: scrollable,
        );
        final lastFocusChip = find.byType(RawChip).last;
        await tester.scrollUntilVisible(
          lastFocusChip,
          160,
          scrollable: scrollable,
        );
        await tester.pumpAndSettle();
        expect(lastFocusChip.hitTestable(), findsOneWidget);

        final start = find.widgetWithText(
          FloatingActionButton,
          strings.commonStartNow,
        );
        final save = find.widgetWithText(
          FloatingActionButton,
          strings.commonSave,
        );
        expect(
          start.hitTestable(),
          findsOneWidget,
          reason: '$brightness $layout',
        );
        expect(
          save.hitTestable(),
          findsOneWidget,
          reason: '$brightness $layout',
        );
        expect(
          tester.getRect(start).overlaps(tester.getRect(save)),
          isFalse,
          reason: '$brightness $layout',
        );
        final startRect = tester.getRect(start);
        final saveRect = tester.getRect(save);
        if (layout.size.width >= 380) {
          expect(
            (startRect.center.dy - saveRect.center.dy).abs(),
            lessThan(1),
            reason:
                'wide layout keeps actions side by side: $brightness $layout',
          );
        } else {
          expect(
            saveRect.top,
            greaterThanOrEqualTo(startRect.bottom),
            reason: 'narrow layout stacks actions: $brightness $layout',
          );
        }
        expect(
          saveRect.bottom,
          lessThanOrEqualTo(layout.size.height - layout.keyboardInset),
          reason: '$brightness $layout',
        );
        expect(tester.takeException(), isNull, reason: '$brightness $layout');
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });
}
