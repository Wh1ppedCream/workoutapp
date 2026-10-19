import 'package:env_test/screens/onboarding_flow.dart';
import 'package:env_test/theme/expressive_planning_tokens.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Expressive onboarding card uses paired planning roles in '
        '${brightness.name} mode', (tester) async {
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: OnboardingStyleHarness.card(
            icon: Icons.favorite,
            title: 'Welcome',
            subtitle: 'Set up Tonos',
            children: const [Text('Card content')],
          ),
        ),
      );

      final tokens = AppExpressivePlanningTokens.maybeOf(
        tester.element(find.text('Welcome')),
      )!;
      final card = tester.widget<Container>(find.byType(Container).first);
      final cardDecoration = card.decoration! as BoxDecoration;
      expect(cardDecoration.color, tokens.planSupportSurface);
      expect(cardDecoration.borderRadius, tokens.supportShape);

      final icon = tester.widget<Container>(find.byType(Container).at(1));
      final iconDecoration = icon.decoration! as BoxDecoration;
      expect(iconDecoration.color, tokens.planFocalSurface);
      expect(iconDecoration.borderRadius, isNotNull);
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Set up Tonos'), findsOneWidget);
    });
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive onboarding choices and callouts use paired planning roles '
      'in ${brightness.name} mode',
      (tester) async {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    OnboardingStyleHarness.intentTile(
                      icon: Icons.fitness_center,
                      title: 'Exercise',
                      body: 'Track workouts',
                      value: true,
                      onChanged: (_) {},
                    ),
                    OnboardingStyleHarness.switchCard(
                      title: 'Use exercise data',
                      value: true,
                      onChanged: (_) {},
                    ),
                    OnboardingStyleHarness.choiceGroup(
                      title: 'Focus',
                      options: const ['Strength', 'Conditioning'],
                      value: 'Strength',
                      onChanged: (_) {},
                    ),
                    OnboardingStyleHarness.gymSpaceTile(
                      title: 'Custom space',
                      subtitle: 'Choose equipment',
                      selected: false,
                      onTap: () {},
                    ),
                    OnboardingStyleHarness.workoutPlanSetupTile(
                      title: 'Choose plans',
                      subtitle: 'Start from a template',
                      selected: true,
                      onTap: () {},
                    ),
                    OnboardingStyleHarness.infoCallout(
                      icon: Icons.info_outline,
                      text: 'Your plans are saved to this profile.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final tokens = AppExpressivePlanningTokens.maybeOf(
          tester.element(find.text('Choose plans')),
        )!;
        final selectedForeground = brightness == Brightness.dark
            ? tokens.planAccentForeground
            : tokens.planFocalForeground;

        _expectTile(
          tester,
          'Exercise',
          tokens.selectedSurface,
          tokens.rowShape,
        );
        _expectTile(
          tester,
          'Custom space',
          tokens.planSupportSurface,
          tokens.rowShape,
        );
        _expectTile(
          tester,
          'Choose plans',
          tokens.selectedSurface,
          tokens.rowShape,
        );
        expect(
          tester.widget<Text>(find.text('Choose plans')).style?.color,
          selectedForeground,
        );

        final selectedChip = tester.widget<ChoiceChip>(
          find.ancestor(
            of: find.text('Strength'),
            matching: find.byType(ChoiceChip),
          ),
        );
        expect(selectedChip.selectedColor, tokens.selectedSurface);
        expect(selectedChip.backgroundColor, tokens.selectedSurface);
        expect(
          selectedChip.shape,
          RoundedRectangleBorder(borderRadius: tokens.rowShape),
        );
        final selectedChipLabel = tester.widget<Text>(find.text('Strength'));
        expect(selectedChipLabel.style?.color, selectedForeground);

        final switchContext = tester.element(find.text('Use exercise data'));
        final switchPanel = find
            .ancestor(
              of: find.text('Use exercise data'),
              matching: find.byType(Container),
            )
            .first;
        final switchDecoration =
            tester.widget<Container>(switchPanel).decoration! as BoxDecoration;
        expect(switchDecoration.color, tokens.planSupportSurface);
        expect(switchDecoration.borderRadius, tokens.rowShape);
        expect(switchContext, isNotNull);

        final calloutFinder = find
            .ancestor(
              of: find.text('Your plans are saved to this profile.'),
              matching: find.byType(Container),
            )
            .first;
        final calloutDecoration =
            tester.widget<Container>(calloutFinder).decoration!
                as BoxDecoration;
        expect(calloutDecoration.color, tokens.configurationSurface);
        expect(calloutDecoration.borderRadius, tokens.supportShape);
        expect(calloutDecoration.border!.top.color, tokens.outline);
      },
    );

    testWidgets(
      'Expressive equipment summary and skip confirmation use paired surfaces '
      'in ${brightness.name} mode',
      (tester) async {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final tokens = brightness == Brightness.light
            ? AppExpressivePlanningTokens.light
            : AppExpressivePlanningTokens.dark;
        var cancelled = false;
        var confirmed = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    OnboardingStyleHarness.equipmentSummary(
                      heading: 'Included equipment',
                      count: '2',
                      description: 'Supported equipment summary.',
                      content: [
                        Chip(
                          label: const Text('Dumbbell'),
                          backgroundColor: tokens.actionSecondary,
                          labelStyle: TextStyle(
                            color: tokens.actionSecondaryForeground,
                          ),
                        ),
                      ],
                    ),
                    OnboardingStyleHarness.skipSetupDialog(
                      title: 'Skip setup?',
                      body: 'Continue to the app home page.',
                      cancelLabel: 'Cancel',
                      confirmLabel: 'Continue',
                      onCancel: () => cancelled = true,
                      onConfirm: () => confirmed = true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final panel = tester.widget<Container>(
          find.byKey(const Key('onboarding-included-equipment')),
        );
        final panelDecoration = panel.decoration! as BoxDecoration;
        expect(panelDecoration.color, tokens.equipmentSurface);
        expect(panelDecoration.borderRadius, tokens.supportShape);
        expect(panelDecoration.border!.top.color, tokens.outline);
        expect(
          tester.widget<Text>(find.text('Included equipment')).style?.color,
          tokens.equipmentForeground,
        );

        final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
        expect(dialog.backgroundColor, tokens.planFocalSurface);
        expect(
          dialog.shape,
          RoundedRectangleBorder(borderRadius: tokens.supportShape),
        );
        expect(dialog.titleTextStyle?.color, tokens.planFocalForeground);
        final cancelButton = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'Cancel'),
        );
        expect(
          cancelButton.style?.foregroundColor?.resolve({}),
          tokens.planFocalForeground,
        );
        final confirmButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Continue'),
        );
        expect(
          confirmButton.style?.backgroundColor?.resolve({}),
          tokens.actionSecondary,
        );
        expect(
          confirmButton.style?.foregroundColor?.resolve({}),
          tokens.actionSecondaryForeground,
        );

        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
        expect(cancelled, isTrue);
        expect(confirmed, isTrue);
      },
    );
  }
}

void _expectTile(
  WidgetTester tester,
  String title,
  Color surface,
  BorderRadius shape,
) {
  final tile = find
      .ancestor(of: find.text(title), matching: find.byType(AnimatedContainer))
      .first;
  final decoration =
      tester.widget<AnimatedContainer>(tile).decoration! as BoxDecoration;
  expect(decoration.color, surface);
  expect(decoration.borderRadius, shape);
}
