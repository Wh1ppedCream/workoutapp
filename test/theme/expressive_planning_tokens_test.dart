import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_planning_tokens.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('explicit Expressive identity selects brightness roles', (
    tester,
  ) async {
    for (final entry in <(ThemeMode, AppExpressivePlanningTokens)>[
      (ThemeMode.light, AppExpressivePlanningTokens.light),
      (ThemeMode.dark, AppExpressivePlanningTokens.dark),
    ]) {
      AppExpressivePlanningTokens? actual;
      Brightness? actualBrightness;
      await tester.pumpWidget(
        MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          darkTheme: ExpressiveThemeDefinition.dark(),
          themeMode: entry.$1,
          themeAnimationDuration: Duration.zero,
          home: Builder(
            builder: (context) {
              actualBrightness = Theme.of(context).brightness;
              actual = AppExpressivePlanningTokens.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(actual, isNotNull);
      expect(
        actualBrightness,
        entry.$1 == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
      expect(actual!.pageCanvas, entry.$2.pageCanvas);
      expect(actual!.planFocalSurface, entry.$2.planFocalSurface);
      expect(actual!.planFocalForeground, entry.$2.planFocalForeground);
      expect(actual!.planSupportSurface, entry.$2.planSupportSurface);
      expect(actual!.planSupportForeground, entry.$2.planSupportForeground);
      expect(actual!.equipmentSurface, entry.$2.equipmentSurface);
      expect(actual!.equipmentForeground, entry.$2.equipmentForeground);
      expect(actual!.configurationSurface, entry.$2.configurationSurface);
      expect(actual!.configurationForeground, entry.$2.configurationForeground);
      expect(actual!.actionPrimary, entry.$2.actionPrimary);
      expect(actual!.actionPrimaryForeground, entry.$2.actionPrimaryForeground);
      expect(actual!.actionSecondary, entry.$2.actionSecondary);
      expect(
        actual!.actionSecondaryForeground,
        entry.$2.actionSecondaryForeground,
      );
      expect(actual!.selectedSurface, entry.$2.selectedSurface);
      expect(actual!.planAccent, entry.$2.planAccent);
      expect(actual!.planAccentForeground, entry.$2.planAccentForeground);
      expect(actual!.outline, entry.$2.outline);
      expect(actual!.onPage, entry.$2.onPage);
      expect(actual!.focalShape, entry.$2.focalShape);
      expect(actual!.supportShape, entry.$2.supportShape);
      expect(actual!.rowShape, entry.$2.rowShape);
    }
  });

  testWidgets('Classic, Neo, and untagged themes return null', (tester) async {
    final themes = <ThemeData>[
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
      AppThemeFactory.light(AppThemeFamily.neoBrutalism),
      AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
      ThemeData.light(),
      ThemeData.dark(),
    ];

    for (final theme in themes) {
      AppExpressivePlanningTokens? actual;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              actual = AppExpressivePlanningTokens.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(actual, isNull);
    }
  });
}
