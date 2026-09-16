import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_data_visualization_tokens.dart';
import 'package:env_test/theme/tokens/app_effect_tokens.dart';
import 'package:env_test/theme/tokens/app_flow_tokens.dart';
import 'package:env_test/theme/tokens/app_generation_tokens.dart';
import 'package:env_test/theme/tokens/app_media_tokens.dart';
import 'package:env_test/theme/tokens/app_motion_tokens.dart';
import 'package:env_test/theme/tokens/app_nutrition_tokens.dart';
import 'package:env_test/theme/tokens/app_progress_colors.dart';
import 'package:env_test/theme/tokens/app_semantic_colors.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';
import 'package:env_test/theme/tokens/app_surface_tokens.dart';
import 'package:env_test/theme/tokens/app_tutorial_tokens.dart';

ThemeData _replaceExtension(
  ThemeData base,
  ThemeExtension<dynamic> replacement,
) {
  return base.copyWith(
    extensions: [
      for (final extension in base.extensions.values)
        extension.runtimeType == replacement.runtimeType
            ? replacement
            : extension,
    ],
  );
}

void _expectCompleteExtensionSet(ThemeData theme) {
  expect(theme.extension<AppDataVisualizationTokens>(), isNotNull);
  expect(theme.extension<AppEffectTokens>(), isNotNull);
  expect(theme.extension<AppFlowTokens>(), isNotNull);
  expect(theme.extension<AppGenerationTokens>(), isNotNull);
  expect(theme.extension<AppMediaTokens>(), isNotNull);
  expect(theme.extension<AppMotionTokens>(), isNotNull);
  expect(theme.extension<AppNutritionTokens>(), isNotNull);
  expect(theme.extension<AppProgressColors>(), isNotNull);
  expect(theme.extension<AppSemanticColors>(), isNotNull);
  expect(theme.extension<AppShapeTokens>(), isNotNull);
  expect(theme.extension<AppSurfaceTokens>(), isNotNull);
  expect(theme.extension<AppTutorialTokens>(), isNotNull);
}

void main() {
  test('replacing one registered extension preserves the complete set', () {
    final base = AppThemeFactory.light(AppThemeFamily.classic);
    final replacements = <ThemeExtension<dynamic>>[
      base.dataVisualizationTokens.copyWith(primarySeries: Colors.pink),
      base.effectTokens.copyWith(cardElevation: 77),
      base.flowTokens.copyWith(action: Colors.pink),
      base.generationTokens.copyWith(accent: Colors.pink),
      base.mediaTokens.copyWith(previewShape: BorderRadius.zero),
      base.motionTokens.copyWith(standard: const Duration(seconds: 7)),
      base.nutritionTokens.copyWith(pantryLogSurface: Colors.pink),
      base.progressColors.copyWith(accent: Colors.pink),
      base.semanticColors.copyWith(positive: Colors.pink),
      base.shapeTokens.copyWith(card: BorderRadius.zero),
      base.surfaceTokens.copyWith(card: Colors.pink),
      base.tutorialTokens.copyWith(cardShape: BorderRadius.zero),
    ];

    for (final replacement in replacements) {
      final updated = _replaceExtension(base, replacement);

      expect(updated.extensions, hasLength(base.extensions.length));
      _expectCompleteExtensionSet(updated);
      expect(
        updated.extensions.values.singleWhere(
          (extension) => extension.runtimeType == replacement.runtimeType,
        ),
        same(replacement),
      );
    }
  });

  testWidgets('system reduced motion resolves the active reduced recipe', (
    tester,
  ) async {
    final base = AppThemeFactory.light(AppThemeFamily.classic);
    final theme = base.copyWith(
      extensions: [
        ...base.extensions.values.where(
          (extension) => extension is! AppMotionTokens,
        ),
        base.motionTokens.copyWith(
          pageTransition: const Duration(seconds: 2),
          reduced: Duration.zero,
        ),
      ],
    );
    late Duration resolved;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: Builder(
                builder: (context) {
                  resolved = appMotionDuration(
                    context,
                    context.motionTokens.pageTransition,
                  );
                  return child!;
                },
              ),
            ),
        home: const SizedBox.shrink(),
      ),
    );

    expect(resolved, Duration.zero);
  });
}
