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
}
