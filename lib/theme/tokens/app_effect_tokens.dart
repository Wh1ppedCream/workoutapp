import 'package:flutter/material.dart';

/// Depth and optional rendering effects, with explicit no-effects fallbacks.
@immutable
class AppEffectTokens extends ThemeExtension<AppEffectTokens> {
  const AppEffectTokens({
    required this.cardElevation,
    required this.dialogElevation,
    required this.sheetElevation,
    this.exerciseDetailSheetElevation = 12,
    this.swapSheetElevation = 12,
    this.progressRemoveBadgeShadow = const BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.24),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    required this.feedbackElevation,
    required this.cardShadow,
    required this.cardShadowBlur,
    required this.cardShadowOffset,
    this.completedSetShadowOffset = const Offset(0, 2),
    this.raisedPanelShadowOffset = const Offset(0, 2),
    this.primaryActionShadowOffset = const Offset(0, 2),
    this.dialogShadowOffset = const Offset(0, 2),
    required this.shadowColor,
    required this.shadowOpacity,
    required this.shadowBlur,
    required this.backdropBlurSigma,
    required this.noEffectsShadowOpacity,
    required this.noEffectsShadowBlur,
    required this.noEffectsBackdropBlurSigma,
  });

  static AppEffectTokens classic(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppEffectTokens(
      cardElevation: 0,
      dialogElevation: 24,
      sheetElevation: 8,
      exerciseDetailSheetElevation: 12,
      swapSheetElevation: 12,
      progressRemoveBadgeShadow: const BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.24),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
      feedbackElevation: 6,
      cardShadow: isDark ? const Color(0x66000000) : const Color(0x22000000),
      cardShadowBlur: 4,
      cardShadowOffset: const Offset(0, 2),
      completedSetShadowOffset: const Offset(0, 2),
      shadowColor: Colors.black,
      shadowOpacity: isDark ? 0.30 : 0.13,
      shadowBlur: 12,
      backdropBlurSigma: 0,
      noEffectsShadowOpacity: 0,
      noEffectsShadowBlur: 0,
      noEffectsBackdropBlurSigma: 0,
    );
  }

  final double cardElevation;
  final double dialogElevation;
  final double sheetElevation;
  final double exerciseDetailSheetElevation;
  final double swapSheetElevation;
  final BoxShadow progressRemoveBadgeShadow;
  final double feedbackElevation;
  final Color cardShadow;
  final double cardShadowBlur;
  final Offset cardShadowOffset;
  final Offset completedSetShadowOffset;
  final Offset raisedPanelShadowOffset;
  final Offset primaryActionShadowOffset;
  final Offset dialogShadowOffset;
  final Color shadowColor;
  final double shadowOpacity;
  final double shadowBlur;
  final double backdropBlurSigma;
  final double noEffectsShadowOpacity;
  final double noEffectsShadowBlur;
  final double noEffectsBackdropBlurSigma;

  @override
  AppEffectTokens copyWith({
    double? cardElevation,
    double? dialogElevation,
    double? sheetElevation,
    double? exerciseDetailSheetElevation,
    double? swapSheetElevation,
    BoxShadow? progressRemoveBadgeShadow,
    double? feedbackElevation,
    Color? cardShadow,
    double? cardShadowBlur,
    Offset? cardShadowOffset,
    Offset? completedSetShadowOffset,
    Offset? raisedPanelShadowOffset,
    Offset? primaryActionShadowOffset,
    Offset? dialogShadowOffset,
    Color? shadowColor,
    double? shadowOpacity,
    double? shadowBlur,
    double? backdropBlurSigma,
    double? noEffectsShadowOpacity,
    double? noEffectsShadowBlur,
    double? noEffectsBackdropBlurSigma,
  }) {
    return AppEffectTokens(
      cardElevation: cardElevation ?? this.cardElevation,
      dialogElevation: dialogElevation ?? this.dialogElevation,
      sheetElevation: sheetElevation ?? this.sheetElevation,
      exerciseDetailSheetElevation:
          exerciseDetailSheetElevation ?? this.exerciseDetailSheetElevation,
      swapSheetElevation: swapSheetElevation ?? this.swapSheetElevation,
      progressRemoveBadgeShadow:
          progressRemoveBadgeShadow ?? this.progressRemoveBadgeShadow,
      feedbackElevation: feedbackElevation ?? this.feedbackElevation,
      cardShadow: cardShadow ?? this.cardShadow,
      cardShadowBlur: cardShadowBlur ?? this.cardShadowBlur,
      cardShadowOffset: cardShadowOffset ?? this.cardShadowOffset,
      completedSetShadowOffset:
          completedSetShadowOffset ?? this.completedSetShadowOffset,
      raisedPanelShadowOffset:
          raisedPanelShadowOffset ?? this.raisedPanelShadowOffset,
      primaryActionShadowOffset:
          primaryActionShadowOffset ?? this.primaryActionShadowOffset,
      dialogShadowOffset: dialogShadowOffset ?? this.dialogShadowOffset,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowOpacity: shadowOpacity ?? this.shadowOpacity,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      backdropBlurSigma: backdropBlurSigma ?? this.backdropBlurSigma,
      noEffectsShadowOpacity:
          noEffectsShadowOpacity ?? this.noEffectsShadowOpacity,
      noEffectsShadowBlur: noEffectsShadowBlur ?? this.noEffectsShadowBlur,
      noEffectsBackdropBlurSigma:
          noEffectsBackdropBlurSigma ?? this.noEffectsBackdropBlurSigma,
    );
  }

  @override
  AppEffectTokens lerp(
    covariant ThemeExtension<AppEffectTokens>? other,
    double t,
  ) {
    if (other is! AppEffectTokens) {
      return this;
    }
    return AppEffectTokens(
      cardElevation: _lerpDouble(cardElevation, other.cardElevation, t),
      dialogElevation: _lerpDouble(dialogElevation, other.dialogElevation, t),
      sheetElevation: _lerpDouble(sheetElevation, other.sheetElevation, t),
      exerciseDetailSheetElevation: _lerpDouble(
        exerciseDetailSheetElevation,
        other.exerciseDetailSheetElevation,
        t,
      ),
      swapSheetElevation: _lerpDouble(
        swapSheetElevation,
        other.swapSheetElevation,
        t,
      ),
      progressRemoveBadgeShadow:
          BoxShadow.lerp(
            progressRemoveBadgeShadow,
            other.progressRemoveBadgeShadow,
            t,
          )!,
      feedbackElevation: _lerpDouble(
        feedbackElevation,
        other.feedbackElevation,
        t,
      ),
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      cardShadowBlur: _lerpDouble(cardShadowBlur, other.cardShadowBlur, t),
      cardShadowOffset:
          Offset.lerp(cardShadowOffset, other.cardShadowOffset, t)!,
      completedSetShadowOffset:
          Offset.lerp(
            completedSetShadowOffset,
            other.completedSetShadowOffset,
            t,
          )!,
      raisedPanelShadowOffset:
          Offset.lerp(
            raisedPanelShadowOffset,
            other.raisedPanelShadowOffset,
            t,
          )!,
      primaryActionShadowOffset:
          Offset.lerp(
            primaryActionShadowOffset,
            other.primaryActionShadowOffset,
            t,
          )!,
      dialogShadowOffset:
          Offset.lerp(dialogShadowOffset, other.dialogShadowOffset, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      shadowOpacity: _lerpDouble(shadowOpacity, other.shadowOpacity, t),
      shadowBlur: _lerpDouble(shadowBlur, other.shadowBlur, t),
      backdropBlurSigma: _lerpDouble(
        backdropBlurSigma,
        other.backdropBlurSigma,
        t,
      ),
      noEffectsShadowOpacity: _lerpDouble(
        noEffectsShadowOpacity,
        other.noEffectsShadowOpacity,
        t,
      ),
      noEffectsShadowBlur: _lerpDouble(
        noEffectsShadowBlur,
        other.noEffectsShadowBlur,
        t,
      ),
      noEffectsBackdropBlurSigma: _lerpDouble(
        noEffectsBackdropBlurSigma,
        other.noEffectsBackdropBlurSigma,
        t,
      ),
    );
  }
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
