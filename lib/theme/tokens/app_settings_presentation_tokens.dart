import 'package:flutter/material.dart';

/// Shared decoration controls for the settings presentation primitives.
///
/// These values keep gradients, accent fills, and borders in the theme layer
/// while allowing settings widgets to preserve their public APIs.
@immutable
class AppSettingsPresentationTokens
    extends ThemeExtension<AppSettingsPresentationTokens> {
  const AppSettingsPresentationTokens({
    this.heroUsesGradient = true,
    this.heroUsesHardShadow = false,
    this.sectionUsesAccentForControls = true,
    this.sectionHeaderUsesLabel = false,
    this.sectionHeaderFill = Colors.transparent,
    this.sectionHeaderForeground = Colors.transparent,
    this.saveActionUsesHardShadow = false,
    this.heroAccentFillOpacity = 0.26,
    this.heroBorderOpacity = 0.42,
    this.heroIconFillOpacity = 0.18,
    this.sectionAccentBorderOpacity = 0.46,
    this.sectionNeutralBorderOpacity = 0.55,
    this.iconFillOpacity = 0.16,
    this.infoBorderOpacity = 0.55,
    this.saveBarBorderOpacity = 1,
  });

  /// The unchanged settings decoration recipe used by Classic.
  static const classic = AppSettingsPresentationTokens();

  final bool heroUsesGradient;
  final bool heroUsesHardShadow;
  final bool sectionUsesAccentForControls;
  final bool sectionHeaderUsesLabel;
  final Color sectionHeaderFill;
  final Color sectionHeaderForeground;
  final bool saveActionUsesHardShadow;
  final double heroAccentFillOpacity;
  final double heroBorderOpacity;
  final double heroIconFillOpacity;
  final double sectionAccentBorderOpacity;
  final double sectionNeutralBorderOpacity;
  final double iconFillOpacity;
  final double infoBorderOpacity;
  final double saveBarBorderOpacity;

  @override
  AppSettingsPresentationTokens copyWith({
    bool? heroUsesGradient,
    bool? heroUsesHardShadow,
    bool? sectionUsesAccentForControls,
    bool? sectionHeaderUsesLabel,
    Color? sectionHeaderFill,
    Color? sectionHeaderForeground,
    bool? saveActionUsesHardShadow,
    double? heroAccentFillOpacity,
    double? heroBorderOpacity,
    double? heroIconFillOpacity,
    double? sectionAccentBorderOpacity,
    double? sectionNeutralBorderOpacity,
    double? iconFillOpacity,
    double? infoBorderOpacity,
    double? saveBarBorderOpacity,
  }) {
    return AppSettingsPresentationTokens(
      heroUsesGradient: heroUsesGradient ?? this.heroUsesGradient,
      heroUsesHardShadow: heroUsesHardShadow ?? this.heroUsesHardShadow,
      sectionUsesAccentForControls:
          sectionUsesAccentForControls ?? this.sectionUsesAccentForControls,
      sectionHeaderUsesLabel:
          sectionHeaderUsesLabel ?? this.sectionHeaderUsesLabel,
      sectionHeaderFill: sectionHeaderFill ?? this.sectionHeaderFill,
      sectionHeaderForeground:
          sectionHeaderForeground ?? this.sectionHeaderForeground,
      saveActionUsesHardShadow:
          saveActionUsesHardShadow ?? this.saveActionUsesHardShadow,
      heroAccentFillOpacity:
          heroAccentFillOpacity ?? this.heroAccentFillOpacity,
      heroBorderOpacity: heroBorderOpacity ?? this.heroBorderOpacity,
      heroIconFillOpacity: heroIconFillOpacity ?? this.heroIconFillOpacity,
      sectionAccentBorderOpacity:
          sectionAccentBorderOpacity ?? this.sectionAccentBorderOpacity,
      sectionNeutralBorderOpacity:
          sectionNeutralBorderOpacity ?? this.sectionNeutralBorderOpacity,
      iconFillOpacity: iconFillOpacity ?? this.iconFillOpacity,
      infoBorderOpacity: infoBorderOpacity ?? this.infoBorderOpacity,
      saveBarBorderOpacity: saveBarBorderOpacity ?? this.saveBarBorderOpacity,
    );
  }

  @override
  AppSettingsPresentationTokens lerp(
    covariant ThemeExtension<AppSettingsPresentationTokens>? other,
    double t,
  ) {
    if (other is! AppSettingsPresentationTokens) return this;
    // Policy booleans switch at the midpoint; numeric opacities interpolate.
    return AppSettingsPresentationTokens(
      heroUsesGradient: t < 0.5 ? heroUsesGradient : other.heroUsesGradient,
      heroUsesHardShadow:
          t < 0.5 ? heroUsesHardShadow : other.heroUsesHardShadow,
      sectionUsesAccentForControls:
          t < 0.5
              ? sectionUsesAccentForControls
              : other.sectionUsesAccentForControls,
      sectionHeaderUsesLabel:
          t < 0.5 ? sectionHeaderUsesLabel : other.sectionHeaderUsesLabel,
      sectionHeaderFill:
          Color.lerp(sectionHeaderFill, other.sectionHeaderFill, t)!,
      sectionHeaderForeground:
          Color.lerp(
            sectionHeaderForeground,
            other.sectionHeaderForeground,
            t,
          )!,
      saveActionUsesHardShadow:
          t < 0.5 ? saveActionUsesHardShadow : other.saveActionUsesHardShadow,
      heroAccentFillOpacity: _lerpDouble(
        heroAccentFillOpacity,
        other.heroAccentFillOpacity,
        t,
      ),
      heroBorderOpacity: _lerpDouble(
        heroBorderOpacity,
        other.heroBorderOpacity,
        t,
      ),
      heroIconFillOpacity: _lerpDouble(
        heroIconFillOpacity,
        other.heroIconFillOpacity,
        t,
      ),
      sectionAccentBorderOpacity: _lerpDouble(
        sectionAccentBorderOpacity,
        other.sectionAccentBorderOpacity,
        t,
      ),
      sectionNeutralBorderOpacity: _lerpDouble(
        sectionNeutralBorderOpacity,
        other.sectionNeutralBorderOpacity,
        t,
      ),
      iconFillOpacity: _lerpDouble(iconFillOpacity, other.iconFillOpacity, t),
      infoBorderOpacity: _lerpDouble(
        infoBorderOpacity,
        other.infoBorderOpacity,
        t,
      ),
      saveBarBorderOpacity: _lerpDouble(
        saveBarBorderOpacity,
        other.saveBarBorderOpacity,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettingsPresentationTokens &&
        other.heroUsesGradient == heroUsesGradient &&
        other.heroUsesHardShadow == heroUsesHardShadow &&
        other.sectionUsesAccentForControls == sectionUsesAccentForControls &&
        other.sectionHeaderUsesLabel == sectionHeaderUsesLabel &&
        other.sectionHeaderFill == sectionHeaderFill &&
        other.sectionHeaderForeground == sectionHeaderForeground &&
        other.saveActionUsesHardShadow == saveActionUsesHardShadow &&
        other.heroAccentFillOpacity == heroAccentFillOpacity &&
        other.heroBorderOpacity == heroBorderOpacity &&
        other.heroIconFillOpacity == heroIconFillOpacity &&
        other.sectionAccentBorderOpacity == sectionAccentBorderOpacity &&
        other.sectionNeutralBorderOpacity == sectionNeutralBorderOpacity &&
        other.iconFillOpacity == iconFillOpacity &&
        other.infoBorderOpacity == infoBorderOpacity &&
        other.saveBarBorderOpacity == saveBarBorderOpacity;
  }

  @override
  int get hashCode => Object.hash(
    heroUsesGradient,
    heroUsesHardShadow,
    sectionUsesAccentForControls,
    sectionHeaderUsesLabel,
    sectionHeaderFill,
    sectionHeaderForeground,
    saveActionUsesHardShadow,
    heroAccentFillOpacity,
    heroBorderOpacity,
    heroIconFillOpacity,
    sectionAccentBorderOpacity,
    sectionNeutralBorderOpacity,
    iconFillOpacity,
    infoBorderOpacity,
    saveBarBorderOpacity,
  );
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
