import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/tokens/app_nutrition_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';

void main() {
  group('AppExpressiveDestinationTokens', () {
    for (final brightness in Brightness.values) {
      test('$brightness foregrounds contrast with their surfaces', () {
        for (final family in AppExpressiveDestinationFamily.values) {
          final tokens = AppExpressiveDestinationTokens.forFamily(
            family,
            brightness,
          );
          expect(
            _contrastRatio(tokens.surfacePrimary, tokens.onSurfacePrimary),
            greaterThanOrEqualTo(4.5),
            reason: '$family primary surface',
          );
          expect(
            _contrastRatio(tokens.surfaceSecondary, tokens.onSurfaceSecondary),
            greaterThanOrEqualTo(4.5),
            reason: '$family secondary surface',
          );
          expect(
            _contrastRatio(tokens.surfaceTertiary, tokens.onSurfaceTertiary),
            greaterThanOrEqualTo(4.5),
            reason: '$family tertiary surface',
          );
          expect(
            _contrastRatio(tokens.surfaceAccent, tokens.onSurfaceAccent),
            greaterThanOrEqualTo(4.5),
            reason: '$family accent surface',
          );
          expect(
            _contrastRatio(tokens.surfaceSelected, tokens.onSurfaceSelected),
            greaterThanOrEqualTo(4.5),
            reason: '$family selected surface',
          );
          expect(
            _contrastRatio(tokens.actionPrimary, tokens.onActionPrimary),
            greaterThanOrEqualTo(4.5),
            reason: '$family primary action',
          );
          expect(
            _contrastRatio(tokens.pageCanvas, tokens.supportingForeground),
            greaterThanOrEqualTo(4.5),
            reason: '$family supporting foreground on canvas',
          );
        }
      });
    }

    test('destination families use distinct surface combinations', () {
      for (final brightness in Brightness.values) {
        final palettes = AppExpressiveDestinationFamily.values
            .map(
              (family) =>
                  AppExpressiveDestinationTokens.forFamily(family, brightness),
            )
            .toList();

        expect(palettes.map((tokens) => tokens.family).toSet(), hasLength(7));
        expect(
          palettes
              .map(
                (tokens) => (
                  tokens.surfaceSecondary,
                  tokens.surfaceTertiary,
                  tokens.surfaceAccent,
                ),
              )
              .toSet(),
          hasLength(7),
          reason: 'each destination gets a distinct chromatic combination',
        );
      }
    });
  });

  group('AppExpressiveDestinationTheme', () {
    testWidgets(
      'installs the requested palette for explicit Expressive identity',
      (tester) async {
        final scheme = ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: scheme,
              extensions: const [
                AppThemeIdentity(
                  family: AppThemeFamilyIdentity.expressivePreview,
                ),
              ],
            ),
            home: const AppExpressiveDestinationTheme(
              family: AppExpressiveDestinationFamily.catalog,
              child: _PaletteProbe(),
            ),
          ),
        );

        expect(find.text('catalog'), findsOneWidget);
        final scopedTheme = Theme.of(tester.element(find.text('catalog')));
        expect(scopedTheme.colorScheme.primary, scheme.primary);
        expect(
          scopedTheme.extension<AppExpressiveDestinationTokens>()?.family,
          AppExpressiveDestinationFamily.catalog,
        );
        expect(
          scopedTheme.appThemeFamilyIdentity,
          AppThemeFamilyIdentity.expressivePreview,
        );
      },
    );

    testWidgets('nutrition wrapper installs its destination nutrition roles', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          home: const AppExpressiveDestinationTheme(
            family: AppExpressiveDestinationFamily.nutrition,
            child: _PaletteProbe(),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.text('nutrition')));
      expect(
        theme.extension<AppExpressiveDestinationTokens>()?.family,
        AppExpressiveDestinationFamily.nutrition,
      );
      expect(
        theme.nutritionTokens.pantryLogSurface,
        AppNutritionTokens.expressive(Brightness.light).pantryLogSurface,
      );
      expect(
        theme.nutritionTokens.addMealSurface,
        isNot(AppNutritionTokens.classic(Brightness.light).addMealSurface),
      );
    });

    testWidgets('nutrition roles stay scoped to nutrition destinations', (
      tester,
    ) async {
      final baseTheme = ExpressiveThemeDefinition.light();
      await tester.pumpWidget(
        MaterialApp(
          theme: baseTheme,
          home: const AppExpressiveDestinationTheme(
            family: AppExpressiveDestinationFamily.dashboard,
            child: _PaletteProbe(),
          ),
        ),
      );

      final scoped = Theme.of(tester.element(find.text('dashboard')));
      expect(
        scoped.nutritionTokens.pantryLogSurface,
        AppNutritionTokens.fromColorScheme(scoped.colorScheme).pantryLogSurface,
      );
      expect(
        scoped.nutritionTokens.pantryLogSurface,
        isNot(AppNutritionTokens.expressive(Brightness.light).pantryLogSurface),
      );
      expect(
        baseTheme.nutritionTokens.addMealSurface,
        AppNutritionTokens.fromColorScheme(baseTheme.colorScheme)
            .addMealSurface,
      );
    });

    for (final identity in <AppThemeFamilyIdentity?>[
      AppThemeFamilyIdentity.classic,
      AppThemeFamilyIdentity.neoBrutalism,
      null,
    ]) {
      testWidgets('leaves child unchanged for identity $identity', (
        tester,
      ) async {
        final extensions = identity == null
            ? const <ThemeExtension<dynamic>>[]
            : <ThemeExtension<dynamic>>[AppThemeIdentity(family: identity)];
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: extensions),
            home: const AppExpressiveDestinationTheme(
              family: AppExpressiveDestinationFamily.analytics,
              child: _PaletteProbe(),
            ),
          ),
        );

        expect(find.text('none'), findsOneWidget);
        expect(
          Theme.of(tester.element(find.text('none')))
              .extension<AppExpressiveDestinationTokens>(),
          isNull,
        );
        expect(
          Theme.of(tester.element(find.text('none'))).appThemeFamilyIdentity,
          identity,
        );
        expect(
          Theme.of(tester.element(find.text('none'))).dialogTheme,
          ThemeData(extensions: extensions).dialogTheme,
        );
      });
    }

    for (final brightness in Brightness.values) {
      for (final family in AppExpressiveDestinationFamily.values) {
        testWidgets('$family dialog theme uses matched $brightness roles', (
          tester,
        ) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                brightness: brightness,
                extensions: const [
                  AppThemeIdentity(
                    family: AppThemeFamilyIdentity.expressivePreview,
                  ),
                ],
              ),
              home: AppExpressiveDestinationTheme(
                family: family,
                child: const _PaletteProbe(),
              ),
            ),
          );

          final theme = Theme.of(tester.element(find.text(family.name)));
          final tokens = AppExpressiveDestinationTokens.forFamily(
            family,
            brightness,
          );
          expect(theme.dialogTheme.backgroundColor, tokens.surfaceTertiary);
          expect(
            theme.dialogTheme.titleTextStyle?.color,
            tokens.onSurfaceTertiary,
          );
          expect(
            theme.dialogTheme.contentTextStyle?.color,
            tokens.onSurfaceTertiary,
          );
          final shape = theme.dialogTheme.shape;
          expect(shape, isA<RoundedRectangleBorder>());
          expect(
            (shape! as RoundedRectangleBorder).side.color,
            tokens.outlineAccent,
          );
        });
      }
    }
  });
}

class _PaletteProbe extends StatelessWidget {
  const _PaletteProbe();

  @override
  Widget build(BuildContext context) {
    final family = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>()
        ?.family;
    return Text(family?.name ?? 'none');
  }
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = _luminance(first);
  final secondLuminance = _luminance(second);
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

double _luminance(Color color) {
  final argb = color.toARGB32();
  final red = ((argb >> 16) & 0xFF) / 255;
  final green = ((argb >> 8) & 0xFF) / 255;
  final blue = (argb & 0xFF) / 255;

  double linearize(double channel) => channel <= 0.04045
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * linearize(red) +
      0.7152 * linearize(green) +
      0.0722 * linearize(blue);
}
