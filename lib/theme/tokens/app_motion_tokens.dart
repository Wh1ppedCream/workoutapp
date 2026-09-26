import 'package:flutter/material.dart';

/// Motion recipes, including a complete reduced-motion contract.
@immutable
class AppMotionTokens extends ThemeExtension<AppMotionTokens> {
  const AppMotionTokens({
    required this.instant,
    required this.standard,
    required this.emphasized,
    required this.page,
    required this.quick,
    this.pageTransition = const Duration(milliseconds: 240),
    this.exerciseDetailSelection = const Duration(milliseconds: 160),
    required this.reduced,
    required this.standardCurve,
    required this.emphasizedCurve,
    required this.reducedCurve,
  });

  static const AppMotionTokens classic = AppMotionTokens(
    instant: Duration.zero,
    standard: Duration(milliseconds: 200),
    emphasized: Duration(milliseconds: 300),
    page: Duration(milliseconds: 300),
    quick: Duration(milliseconds: 180),
    pageTransition: Duration(milliseconds: 240),
    exerciseDetailSelection: Duration(milliseconds: 160),
    reduced: Duration.zero,
    standardCurve: Curves.easeInOut,
    emphasizedCurve: Curves.easeOut,
    reducedCurve: Curves.linear,
  );

  final Duration instant;
  final Duration standard;
  final Duration emphasized;
  final Duration page;
  final Duration quick;
  final Duration pageTransition;
  final Duration exerciseDetailSelection;
  final Duration reduced;
  final Curve standardCurve;
  final Curve emphasizedCurve;
  final Curve reducedCurve;

  @override
  AppMotionTokens copyWith({
    Duration? instant,
    Duration? standard,
    Duration? emphasized,
    Duration? page,
    Duration? quick,
    Duration? pageTransition,
    Duration? exerciseDetailSelection,
    Duration? reduced,
    Curve? standardCurve,
    Curve? emphasizedCurve,
    Curve? reducedCurve,
  }) {
    return AppMotionTokens(
      instant: instant ?? this.instant,
      standard: standard ?? this.standard,
      emphasized: emphasized ?? this.emphasized,
      page: page ?? this.page,
      quick: quick ?? this.quick,
      pageTransition: pageTransition ?? this.pageTransition,
      exerciseDetailSelection:
          exerciseDetailSelection ?? this.exerciseDetailSelection,
      reduced: reduced ?? this.reduced,
      standardCurve: standardCurve ?? this.standardCurve,
      emphasizedCurve: emphasizedCurve ?? this.emphasizedCurve,
      reducedCurve: reducedCurve ?? this.reducedCurve,
    );
  }

  @override
  AppMotionTokens lerp(
    covariant ThemeExtension<AppMotionTokens>? other,
    double t,
  ) {
    if (other is! AppMotionTokens) {
      return this;
    }
    return AppMotionTokens(
      instant: _lerpDuration(instant, other.instant, t),
      standard: _lerpDuration(standard, other.standard, t),
      emphasized: _lerpDuration(emphasized, other.emphasized, t),
      page: _lerpDuration(page, other.page, t),
      quick: _lerpDuration(quick, other.quick, t),
      pageTransition: _lerpDuration(pageTransition, other.pageTransition, t),
      exerciseDetailSelection: _lerpDuration(
        exerciseDetailSelection,
        other.exerciseDetailSelection,
        t,
      ),
      reduced: _lerpDuration(reduced, other.reduced, t),
      standardCurve: _lerpCurve(standardCurve, other.standardCurve, t),
      emphasizedCurve: _lerpCurve(emphasizedCurve, other.emphasizedCurve, t),
      reducedCurve: _lerpCurve(reducedCurve, other.reducedCurve, t),
    );
  }
}

Duration _lerpDuration(Duration a, Duration b, double t) {
  final microseconds =
      a.inMicroseconds + (b.inMicroseconds - a.inMicroseconds) * t;
  return Duration(microseconds: microseconds.round());
}

Curve _lerpCurve(Curve a, Curve b, double t) => t < 0.5 ? a : b;
