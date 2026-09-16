import 'package:flutter/material.dart';

/// Onboarding and tutorial presentation only. Readiness retries and completion
/// persistence are behavior-owned and intentionally excluded.
@immutable
class AppTutorialTokens extends ThemeExtension<AppTutorialTokens> {
  const AppTutorialTokens({
    this.focusShape = const BorderRadius.all(Radius.circular(22)),
    this.cardShape = const BorderRadius.all(Radius.circular(26)),
    this.iconShape = const BorderRadius.all(Radius.circular(15)),
    this.coachShape = const BorderRadius.all(Radius.circular(20)),
    this.coachIconShape = const BorderRadius.all(Radius.circular(12)),
    this.inputShape = const BorderRadius.all(Radius.circular(18)),
    this.tileShape = const BorderRadius.all(Radius.circular(22)),
    this.sectionShape = const BorderRadius.all(Radius.circular(20)),
    this.compactShape = const BorderRadius.all(Radius.circular(16)),
    this.heroShape = const BorderRadius.all(Radius.circular(30)),
    this.pillShape = const BorderRadius.all(Radius.circular(999)),
    this.scrim = const Color(0xAD000000),
    this.measuringScrim = const Color(0x66000000),
    this.confirmationScrim = const Color(0xB3000000),
    this.coachScrim = const Color.fromRGBO(0, 0, 0, 0.42),
    this.focusShadowOpacity = 0.36,
    this.focusShadowBlur = 22,
    this.focusShadowSpread = 2,
    this.focusShadowOffset = Offset.zero,
    this.cardShadow = const BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.28),
      blurRadius: 28,
      offset: Offset(0, 14),
    ),
    this.coachShadow = const BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.28),
      blurRadius: 22,
      offset: Offset(0, 10),
    ),
    this.pageDuration = const Duration(milliseconds: 300),
    this.selectionDuration = const Duration(milliseconds: 180),
    this.guidedScrollDuration = const Duration(milliseconds: 260),
    this.coachDuration = const Duration(milliseconds: 220),
    this.effectsEnabled = true,
  });

  static const classic = AppTutorialTokens();
  final BorderRadius focusShape;
  final BorderRadius cardShape;
  final BorderRadius iconShape;
  final BorderRadius coachShape;
  final BorderRadius coachIconShape;
  final BorderRadius inputShape;
  final BorderRadius tileShape;
  final BorderRadius sectionShape;
  final BorderRadius compactShape;
  final BorderRadius heroShape;
  final BorderRadius pillShape;
  final Color scrim;
  final Color measuringScrim;
  final Color confirmationScrim;
  final Color coachScrim;
  final double focusShadowOpacity;
  final double focusShadowBlur;
  final double focusShadowSpread;
  final Offset focusShadowOffset;
  final BoxShadow cardShadow;
  final BoxShadow coachShadow;
  final Duration pageDuration;
  final Duration selectionDuration;
  final Duration guidedScrollDuration;
  final Duration coachDuration;
  final bool effectsEnabled;

  @override
  AppTutorialTokens copyWith({
    BorderRadius? focusShape,
    BorderRadius? cardShape,
    BorderRadius? iconShape,
    BorderRadius? coachShape,
    BorderRadius? coachIconShape,
    BorderRadius? inputShape,
    BorderRadius? tileShape,
    BorderRadius? sectionShape,
    BorderRadius? compactShape,
    BorderRadius? heroShape,
    BorderRadius? pillShape,
    Color? scrim,
    Color? measuringScrim,
    Color? confirmationScrim,
    Color? coachScrim,
    double? focusShadowOpacity,
    double? focusShadowBlur,
    double? focusShadowSpread,
    Offset? focusShadowOffset,
    BoxShadow? cardShadow,
    BoxShadow? coachShadow,
    Duration? pageDuration,
    Duration? selectionDuration,
    Duration? guidedScrollDuration,
    Duration? coachDuration,
    bool? effectsEnabled,
  }) => AppTutorialTokens(
    focusShape: focusShape ?? this.focusShape,
    cardShape: cardShape ?? this.cardShape,
    iconShape: iconShape ?? this.iconShape,
    coachShape: coachShape ?? this.coachShape,
    coachIconShape: coachIconShape ?? this.coachIconShape,
    inputShape: inputShape ?? this.inputShape,
    tileShape: tileShape ?? this.tileShape,
    sectionShape: sectionShape ?? this.sectionShape,
    compactShape: compactShape ?? this.compactShape,
    heroShape: heroShape ?? this.heroShape,
    pillShape: pillShape ?? this.pillShape,
    scrim: scrim ?? this.scrim,
    measuringScrim: measuringScrim ?? this.measuringScrim,
    confirmationScrim: confirmationScrim ?? this.confirmationScrim,
    coachScrim: coachScrim ?? this.coachScrim,
    focusShadowOpacity: focusShadowOpacity ?? this.focusShadowOpacity,
    focusShadowBlur: focusShadowBlur ?? this.focusShadowBlur,
    focusShadowSpread: focusShadowSpread ?? this.focusShadowSpread,
    focusShadowOffset: focusShadowOffset ?? this.focusShadowOffset,
    cardShadow: cardShadow ?? this.cardShadow,
    coachShadow: coachShadow ?? this.coachShadow,
    pageDuration: pageDuration ?? this.pageDuration,
    selectionDuration: selectionDuration ?? this.selectionDuration,
    guidedScrollDuration: guidedScrollDuration ?? this.guidedScrollDuration,
    coachDuration: coachDuration ?? this.coachDuration,
    effectsEnabled: effectsEnabled ?? this.effectsEnabled,
  );

  @override
  AppTutorialTokens lerp(covariant AppTutorialTokens? other, double t) {
    if (other == null) return this;
    return AppTutorialTokens(
      focusShape: BorderRadius.lerp(focusShape, other.focusShape, t)!,
      cardShape: BorderRadius.lerp(cardShape, other.cardShape, t)!,
      iconShape: BorderRadius.lerp(iconShape, other.iconShape, t)!,
      coachShape: BorderRadius.lerp(coachShape, other.coachShape, t)!,
      coachIconShape:
          BorderRadius.lerp(coachIconShape, other.coachIconShape, t)!,
      inputShape: BorderRadius.lerp(inputShape, other.inputShape, t)!,
      tileShape: BorderRadius.lerp(tileShape, other.tileShape, t)!,
      sectionShape: BorderRadius.lerp(sectionShape, other.sectionShape, t)!,
      compactShape: BorderRadius.lerp(compactShape, other.compactShape, t)!,
      heroShape: BorderRadius.lerp(heroShape, other.heroShape, t)!,
      pillShape: BorderRadius.lerp(pillShape, other.pillShape, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      measuringScrim: Color.lerp(measuringScrim, other.measuringScrim, t)!,
      confirmationScrim:
          Color.lerp(confirmationScrim, other.confirmationScrim, t)!,
      coachScrim: Color.lerp(coachScrim, other.coachScrim, t)!,
      focusShadowOpacity:
          focusShadowOpacity +
          (other.focusShadowOpacity - focusShadowOpacity) * t,
      focusShadowBlur:
          focusShadowBlur + (other.focusShadowBlur - focusShadowBlur) * t,
      focusShadowSpread:
          focusShadowSpread + (other.focusShadowSpread - focusShadowSpread) * t,
      focusShadowOffset:
          Offset.lerp(focusShadowOffset, other.focusShadowOffset, t)!,
      cardShadow: BoxShadow.lerp(cardShadow, other.cardShadow, t)!,
      coachShadow: BoxShadow.lerp(coachShadow, other.coachShadow, t)!,
      pageDuration: Duration(
        microseconds:
            (pageDuration.inMicroseconds +
                    (other.pageDuration.inMicroseconds -
                            pageDuration.inMicroseconds) *
                        t)
                .round(),
      ),
      selectionDuration: Duration(
        microseconds:
            (selectionDuration.inMicroseconds +
                    (other.selectionDuration.inMicroseconds -
                            selectionDuration.inMicroseconds) *
                        t)
                .round(),
      ),
      guidedScrollDuration: Duration(
        microseconds:
            (guidedScrollDuration.inMicroseconds +
                    (other.guidedScrollDuration.inMicroseconds -
                            guidedScrollDuration.inMicroseconds) *
                        t)
                .round(),
      ),
      coachDuration: Duration(
        microseconds:
            (coachDuration.inMicroseconds +
                    (other.coachDuration.inMicroseconds -
                            coachDuration.inMicroseconds) *
                        t)
                .round(),
      ),
      effectsEnabled: t < 0.5 ? effectsEnabled : other.effectsEnabled,
    );
  }
}

/// System reduced motion suppresses animation, never target readiness checks.
Duration tutorialMotion(BuildContext context, Duration duration) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
