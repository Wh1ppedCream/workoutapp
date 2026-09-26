import 'package:flutter/material.dart';

/// Theme recipes for the custom preset-generation flow.
@immutable
class AppGenerationTokens extends ThemeExtension<AppGenerationTokens> {
  const AppGenerationTokens({
    required this.accent,
    required this.introGradientStart,
    required this.introGradientEnd,
    required this.introBorder,
    required this.introIconFill,
    required this.introShape,
    required this.introIconShape,
    required this.summarySurface,
    required this.summaryBorder,
    required this.summaryPillShape,
    required this.sectionSurface,
    required this.sectionBorder,
    required this.sectionIconFill,
    required this.sectionShape,
    required this.sectionIconShape,
    required this.fieldLabel,
    required this.fieldBorder,
    required this.fieldFill,
    required this.fieldShape,
    required this.secondaryText,
    required this.choiceSelectedSurface,
    required this.choiceUnselectedSurface,
    required this.choiceSelectedBorder,
    required this.choiceUnselectedBorder,
    required this.choiceShape,
    required this.actionBarSurface,
    required this.actionBarBorder,
    required this.badge,
    required this.onBadge,
    required this.badgeShape,
  });

  /// Builds the existing scheme-driven recipe used by Classic and fallbacks.
  factory AppGenerationTokens.fromColorScheme(ColorScheme scheme) {
    return AppGenerationTokens(
      accent: scheme.primary,
      introGradientStart: scheme.primaryContainer.withValues(alpha: 0.46),
      introGradientEnd: scheme.surfaceContainerHighest.withValues(alpha: 0.58),
      introBorder: scheme.primary.withValues(alpha: 0.18),
      introIconFill: scheme.primary.withValues(alpha: 0.18),
      introShape: BorderRadius.circular(26),
      introIconShape: BorderRadius.circular(18),
      summarySurface: scheme.surface.withValues(alpha: 0.66),
      summaryBorder: scheme.outlineVariant.withValues(alpha: 0.4),
      summaryPillShape: BorderRadius.circular(16),
      sectionSurface: scheme.surfaceContainerHighest.withValues(alpha: 0.36),
      sectionBorder: scheme.outlineVariant.withValues(alpha: 0.45),
      sectionIconFill: scheme.primary.withValues(alpha: 0.14),
      sectionShape: BorderRadius.circular(24),
      sectionIconShape: BorderRadius.circular(16),
      fieldLabel: scheme.onSurfaceVariant,
      fieldBorder: scheme.outlineVariant.withValues(alpha: 0.78),
      fieldFill: scheme.surface.withValues(alpha: 0.54),
      fieldShape: BorderRadius.circular(18),
      secondaryText: scheme.onSurfaceVariant,
      choiceSelectedSurface: scheme.primaryContainer.withValues(alpha: 0.24),
      choiceUnselectedSurface: scheme.surface.withValues(alpha: 0.38),
      choiceSelectedBorder: scheme.primary.withValues(alpha: 0.72),
      choiceUnselectedBorder: scheme.outlineVariant.withValues(alpha: 0.58),
      choiceShape: BorderRadius.circular(18),
      actionBarSurface: scheme.surface.withValues(alpha: 0.96),
      actionBarBorder: scheme.outlineVariant.withValues(alpha: 0.6),
      badge: scheme.error,
      onBadge: scheme.onError,
      badgeShape: BorderRadius.circular(999),
    );
  }

  /// Classic keeps the historical scheme-derived generation recipe.
  factory AppGenerationTokens.classic(ColorScheme scheme) {
    return AppGenerationTokens.fromColorScheme(scheme);
  }

  final Color accent;
  final Color introGradientStart;
  final Color introGradientEnd;
  final Color introBorder;
  final Color introIconFill;
  final BorderRadius introShape;
  final BorderRadius introIconShape;
  final Color summarySurface;
  final Color summaryBorder;
  final BorderRadius summaryPillShape;
  final Color sectionSurface;
  final Color sectionBorder;
  final Color sectionIconFill;
  final BorderRadius sectionShape;
  final BorderRadius sectionIconShape;
  final Color fieldLabel;
  final Color fieldBorder;
  final Color fieldFill;
  final BorderRadius fieldShape;
  final Color secondaryText;
  final Color choiceSelectedSurface;
  final Color choiceUnselectedSurface;
  final Color choiceSelectedBorder;
  final Color choiceUnselectedBorder;
  final BorderRadius choiceShape;
  final Color actionBarSurface;
  final Color actionBarBorder;
  final Color badge;
  final Color onBadge;
  final BorderRadius badgeShape;

  @override
  AppGenerationTokens copyWith({
    Color? accent,
    Color? introGradientStart,
    Color? introGradientEnd,
    Color? introBorder,
    Color? introIconFill,
    BorderRadius? introShape,
    BorderRadius? introIconShape,
    Color? summarySurface,
    Color? summaryBorder,
    BorderRadius? summaryPillShape,
    Color? sectionSurface,
    Color? sectionBorder,
    Color? sectionIconFill,
    BorderRadius? sectionShape,
    BorderRadius? sectionIconShape,
    Color? fieldLabel,
    Color? fieldBorder,
    Color? fieldFill,
    BorderRadius? fieldShape,
    Color? secondaryText,
    Color? choiceSelectedSurface,
    Color? choiceUnselectedSurface,
    Color? choiceSelectedBorder,
    Color? choiceUnselectedBorder,
    BorderRadius? choiceShape,
    Color? actionBarSurface,
    Color? actionBarBorder,
    Color? badge,
    Color? onBadge,
    BorderRadius? badgeShape,
  }) {
    return AppGenerationTokens(
      accent: accent ?? this.accent,
      introGradientStart: introGradientStart ?? this.introGradientStart,
      introGradientEnd: introGradientEnd ?? this.introGradientEnd,
      introBorder: introBorder ?? this.introBorder,
      introIconFill: introIconFill ?? this.introIconFill,
      introShape: introShape ?? this.introShape,
      introIconShape: introIconShape ?? this.introIconShape,
      summarySurface: summarySurface ?? this.summarySurface,
      summaryBorder: summaryBorder ?? this.summaryBorder,
      summaryPillShape: summaryPillShape ?? this.summaryPillShape,
      sectionSurface: sectionSurface ?? this.sectionSurface,
      sectionBorder: sectionBorder ?? this.sectionBorder,
      sectionIconFill: sectionIconFill ?? this.sectionIconFill,
      sectionShape: sectionShape ?? this.sectionShape,
      sectionIconShape: sectionIconShape ?? this.sectionIconShape,
      fieldLabel: fieldLabel ?? this.fieldLabel,
      fieldBorder: fieldBorder ?? this.fieldBorder,
      fieldFill: fieldFill ?? this.fieldFill,
      fieldShape: fieldShape ?? this.fieldShape,
      secondaryText: secondaryText ?? this.secondaryText,
      choiceSelectedSurface:
          choiceSelectedSurface ?? this.choiceSelectedSurface,
      choiceUnselectedSurface:
          choiceUnselectedSurface ?? this.choiceUnselectedSurface,
      choiceSelectedBorder: choiceSelectedBorder ?? this.choiceSelectedBorder,
      choiceUnselectedBorder:
          choiceUnselectedBorder ?? this.choiceUnselectedBorder,
      choiceShape: choiceShape ?? this.choiceShape,
      actionBarSurface: actionBarSurface ?? this.actionBarSurface,
      actionBarBorder: actionBarBorder ?? this.actionBarBorder,
      badge: badge ?? this.badge,
      onBadge: onBadge ?? this.onBadge,
      badgeShape: badgeShape ?? this.badgeShape,
    );
  }

  @override
  AppGenerationTokens lerp(
    covariant ThemeExtension<AppGenerationTokens>? other,
    double t,
  ) {
    if (other is! AppGenerationTokens) return this;
    return AppGenerationTokens(
      accent: Color.lerp(accent, other.accent, t)!,
      introGradientStart:
          Color.lerp(introGradientStart, other.introGradientStart, t)!,
      introGradientEnd:
          Color.lerp(introGradientEnd, other.introGradientEnd, t)!,
      introBorder: Color.lerp(introBorder, other.introBorder, t)!,
      introIconFill: Color.lerp(introIconFill, other.introIconFill, t)!,
      introShape: BorderRadius.lerp(introShape, other.introShape, t)!,
      introIconShape:
          BorderRadius.lerp(introIconShape, other.introIconShape, t)!,
      summarySurface: Color.lerp(summarySurface, other.summarySurface, t)!,
      summaryBorder: Color.lerp(summaryBorder, other.summaryBorder, t)!,
      summaryPillShape:
          BorderRadius.lerp(summaryPillShape, other.summaryPillShape, t)!,
      sectionSurface: Color.lerp(sectionSurface, other.sectionSurface, t)!,
      sectionBorder: Color.lerp(sectionBorder, other.sectionBorder, t)!,
      sectionIconFill: Color.lerp(sectionIconFill, other.sectionIconFill, t)!,
      sectionShape: BorderRadius.lerp(sectionShape, other.sectionShape, t)!,
      sectionIconShape:
          BorderRadius.lerp(sectionIconShape, other.sectionIconShape, t)!,
      fieldLabel: Color.lerp(fieldLabel, other.fieldLabel, t)!,
      fieldBorder: Color.lerp(fieldBorder, other.fieldBorder, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      fieldShape: BorderRadius.lerp(fieldShape, other.fieldShape, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      choiceSelectedSurface:
          Color.lerp(choiceSelectedSurface, other.choiceSelectedSurface, t)!,
      choiceUnselectedSurface:
          Color.lerp(
            choiceUnselectedSurface,
            other.choiceUnselectedSurface,
            t,
          )!,
      choiceSelectedBorder:
          Color.lerp(choiceSelectedBorder, other.choiceSelectedBorder, t)!,
      choiceUnselectedBorder:
          Color.lerp(choiceUnselectedBorder, other.choiceUnselectedBorder, t)!,
      choiceShape: BorderRadius.lerp(choiceShape, other.choiceShape, t)!,
      actionBarSurface:
          Color.lerp(actionBarSurface, other.actionBarSurface, t)!,
      actionBarBorder: Color.lerp(actionBarBorder, other.actionBarBorder, t)!,
      badge: Color.lerp(badge, other.badge, t)!,
      onBadge: Color.lerp(onBadge, other.onBadge, t)!,
      badgeShape: BorderRadius.lerp(badgeShape, other.badgeShape, t)!,
    );
  }
}
