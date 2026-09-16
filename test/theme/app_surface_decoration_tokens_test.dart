import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/tokens/app_settings_presentation_tokens.dart';
import 'package:env_test/theme/tokens/app_surface_decoration_tokens.dart';

void main() {
  test('Classic factory registers the shared N2 extensions', () {
    final light = AppThemeFactory.light(AppThemeFamily.classic);
    final dark = AppThemeFactory.dark(AppThemeFamily.classic);

    expect(
      light.extension<AppSurfaceDecorationTokens>(),
      AppSurfaceDecorationTokens.classic,
    );
    expect(
      dark.extension<AppSurfaceDecorationTokens>(),
      AppSurfaceDecorationTokens.classic,
    );
    expect(
      light.extension<AppSettingsPresentationTokens>(),
      AppSettingsPresentationTokens.classic,
    );
    expect(
      dark.extension<AppSettingsPresentationTokens>(),
      AppSettingsPresentationTokens.classic,
    );
  });

  test(
    'Classic surface decoration preserves existing TonosSurface behavior',
    () {
      final classic = AppSurfaceDecorationTokens.classic;

      expect(
        classic.forRole(AppSurfaceDecorationRole.panel),
        AppSurfaceDecoration.flat,
      );
      expect(
        classic.forRole(AppSurfaceDecorationRole.card).depth,
        AppSurfaceDepth.materialElevation,
      );
      expect(
        classic.forRole(AppSurfaceDecorationRole.compactCard).depth,
        AppSurfaceDepth.explicitShadow,
      );
      expect(
        classic.forRole(AppSurfaceDecorationRole.input),
        AppSurfaceDecoration.outlinedOnly,
      );
      expect(
        classic.forRole(AppSurfaceDecorationRole.sheet).depth,
        AppSurfaceDepth.materialElevation,
      );
      expect(classic.forRole(AppSurfaceDecorationRole.media).outlined, isFalse);
    },
  );

  test(
    'surface decoration interpolation changes discrete policies at midpoint',
    () {
      const flat = AppSurfaceDecoration.flat;
      const outlined = AppSurfaceDecoration.outlinedCompactShadow;

      expect(AppSurfaceDecoration.lerp(flat, outlined, 0.49), flat);
      expect(AppSurfaceDecoration.lerp(flat, outlined, 0.5), outlined);
    },
  );

  test(
    'surface decoration tokens support copy and interpolation endpoints',
    () {
      final classic = AppSurfaceDecorationTokens.classic;
      final other = classic.copyWith(
        panel: AppSurfaceDecoration.outlinedOnly,
        sheet: AppSurfaceDecoration.outlinedCompactShadow,
      );

      expect(classic.copyWith(), classic);
      expect(classic.lerp(null, 0.5), classic);
      expect(classic.lerp(other, 0).panel, classic.panel);
      expect(classic.lerp(other, 1).panel, other.panel);
      expect(classic.lerp(other, 1).sheet, other.sheet);
    },
  );

  test('settings Classic defaults preserve the extracted visual constants', () {
    const classic = AppSettingsPresentationTokens.classic;

    expect(classic.heroUsesGradient, isTrue);
    expect(classic.heroUsesHardShadow, isFalse);
    expect(classic.sectionHeaderUsesLabel, isFalse);
    expect(classic.sectionHeaderFill, Colors.transparent);
    expect(classic.sectionHeaderForeground, Colors.transparent);
    expect(classic.saveActionUsesHardShadow, isFalse);
    expect(classic.heroAccentFillOpacity, 0.26);
    expect(classic.heroBorderOpacity, 0.42);
    expect(classic.heroIconFillOpacity, 0.18);
    expect(classic.sectionAccentBorderOpacity, 0.46);
    expect(classic.sectionNeutralBorderOpacity, 0.55);
    expect(classic.iconFillOpacity, 0.16);
    expect(classic.infoBorderOpacity, 0.55);
    expect(classic.saveBarBorderOpacity, 1);
  });

  test('settings presentation interpolation retains continuous values', () {
    const classic = AppSettingsPresentationTokens.classic;
    final other = classic.copyWith(
      heroUsesGradient: false,
      heroUsesHardShadow: true,
      heroBorderOpacity: 1,
    );

    final middle = classic.lerp(other, 0.5);
    expect(middle.heroUsesGradient, isFalse);
    expect(middle.heroUsesHardShadow, isTrue);
    expect(middle.sectionUsesAccentForControls, isTrue);
    expect(middle.heroBorderOpacity, closeTo(0.71, 0.001));
    expect(classic.copyWith(), classic);
    expect(classic.lerp(null, 0.5), classic);
    expect(classic.lerp(other, 0).heroUsesGradient, isTrue);
    expect(classic.lerp(other, 1).heroUsesGradient, isFalse);
  });
}
