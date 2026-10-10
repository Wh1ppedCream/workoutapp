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
                                bodyParts: const <BodyPart>[],
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
        if (brightness == Brightness.dark) {
          for (final label in [strings.commonCancel, strings.commonReset]) {
            final labelFinder = find.text(label);
            expect(labelFinder, findsOneWidget);
            expect(
              tester.widget<Text>(labelFinder).style?.color,
              planning.planFocalForeground,
            );
            final surfaceFinder = find
                .ancestor(of: labelFinder, matching: find.byType(Material))
                .first;
            expect(
              tester.widget<Material>(surfaceFinder).color,
              planning.planFocalSurface,
            );
          }
        }
        final cards = tester.widgetList<Card>(find.byType(Card)).toList();
        expect(cards, hasLength(2));
        expect(cards[0].color, planning.planFocalSurface);
        expect(cards[1].color, planning.planSupportSurface);
        expect(
          cards.every((card) => card.shape is RoundedRectangleBorder),
          isTrue,
        );
        final firstChoice = tester.widget<ChoiceChip>(
          find.byType(ChoiceChip).first,
        );
        expect(firstChoice.selected, isTrue);
        expect(firstChoice.selectedColor, planning.selectedSurface);
        expect(find.byType(TonosFormField), findsNWidgets(4));
        if (brightness == Brightness.light) {
          final budgetCard = find.byType(Card).first;
          final budgetFields = find.descendant(
            of: budgetCard,
            matching: find.byType(EditableText),
          );
          expect(budgetFields, findsNWidgets(3));
          final fieldTheme = Theme.of(tester.element(budgetFields.first));
          expect(
            fieldTheme.inputDecorationTheme.labelStyle?.color,
            planning.planFocalForeground,
          );
          expect(
            fieldTheme.inputDecorationTheme.floatingLabelStyle?.color,
            planning.planFocalForeground,
          );
          expect(
            fieldTheme.inputDecorationTheme.suffixStyle?.color,
            planning.planFocalForeground,
          );
          for (final field in tester.widgetList<EditableText>(budgetFields)) {
            expect(field.style.color, planning.planFocalForeground);
          }
        }

        final focusHeading = find.text(strings.optimizedBodypartFocusTitle);
        await tester.drag(find.byType(ListView), const Offset(0, -2000));
        await tester.pumpAndSettle();
        final focusCard = tester.widget<Card>(
          find.ancestor(of: focusHeading, matching: find.byType(Card)).first,
        );
        expect(focusCard.color, planning.configurationSurface);
        expect(focusCard.shape, isA<RoundedRectangleBorder>());

        await tester.tap(find.widgetWithText(FilledButton, strings.commonSave));
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
                bodyParts: const <BodyPart>[],
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

        final start = find.widgetWithText(FilledButton, strings.commonStartNow);
        final save = find.widgetWithText(FilledButton, strings.commonSave);
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
        expect(
          tester.getRect(save).bottom,
          lessThanOrEqualTo(layout.size.height - layout.keyboardInset),
          reason: '$brightness $layout',
        );
        expect(tester.takeException(), isNull, reason: '$brightness $layout');
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });
}
