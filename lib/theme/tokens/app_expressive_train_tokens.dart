import 'package:material_ui/material_ui.dart';

/// Presentation-only roles for the preview's amplified Train + shell slice.
///
/// These tokens are attached only to the non-persisted Expressive preview.
/// Domain colors (plan identities, success, heatmap, charts, and warnings) keep
/// their existing owners and are intentionally not represented here.
@immutable
class AppExpressiveTrainTokens
    extends ThemeExtension<AppExpressiveTrainTokens> {
  const AppExpressiveTrainTokens({
    required this.pageCanvas,
    required this.selectorTrack,
    required this.selectorActive,
    required this.selectorActiveForeground,
    required this.focusSurface,
    required this.focusForeground,
    required this.focusInset,
    required this.focusInsetForeground,
    required this.focusWarm,
    required this.focusCool,
    required this.activePlansSurface,
    required this.archivedPlansSurface,
    required this.librarySurface,
    required this.creationSurface,
    required this.actionPrimary,
    required this.actionPrimaryForeground,
    required this.actionSecondary,
    required this.actionSecondaryForeground,
    required this.navigationSurface,
    required this.navigationSelected,
    required this.navigationSelectedForeground,
    required this.navigationLabel,
  });

  final Color pageCanvas;
  final Color selectorTrack;
  final Color selectorActive;
  final Color selectorActiveForeground;
  final Color focusSurface;
  final Color focusForeground;
  final Color focusInset;
  final Color focusInsetForeground;
  final Color focusWarm;
  final Color focusCool;
  final Color activePlansSurface;
  final Color archivedPlansSurface;
  final Color librarySurface;
  final Color creationSurface;
  final Color actionPrimary;
  final Color actionPrimaryForeground;
  final Color actionSecondary;
  final Color actionSecondaryForeground;
  final Color navigationSurface;
  final Color navigationSelected;
  final Color navigationSelectedForeground;
  final Color navigationLabel;

  static const light = AppExpressiveTrainTokens(
    pageCanvas: Color(0xFFFFF4E9),
    selectorTrack: Color(0xFFE8D9F4),
    selectorActive: Color(0xFF54247C),
    selectorActiveForeground: Color(0xFFFFF8FF),
    focusSurface: Color(0xFF47205F),
    focusForeground: Color(0xFFFFF7FF),
    focusInset: Color(0xFF61377A),
    focusInsetForeground: Color(0xFFFFF7FF),
    focusWarm: Color(0xFFFFBE83),
    focusCool: Color(0xFF73DEC8),
    activePlansSurface: Color(0xFFFFE8D7),
    archivedPlansSurface: Color(0xFFE2F1E9),
    librarySurface: Color(0xFFFFE4B7),
    creationSurface: Color(0xFFE1D0FF),
    actionPrimary: Color(0xFF5421A4),
    actionPrimaryForeground: Color(0xFFFFFFFF),
    actionSecondary: Color(0xFFC7EEE2),
    actionSecondaryForeground: Color(0xFF123D35),
    navigationSurface: Color(0xFFE8D9F1),
    navigationSelected: Color(0xFF63339C),
    navigationSelectedForeground: Color(0xFFFFFFFF),
    navigationLabel: Color(0xFF39254A),
  );

  static const dark = AppExpressiveTrainTokens(
    pageCanvas: Color(0xFF19121F),
    selectorTrack: Color(0xFF302439),
    selectorActive: Color(0xFFE4C4FF),
    selectorActiveForeground: Color(0xFF321448),
    focusSurface: Color(0xFF30203C),
    focusForeground: Color(0xFFF8ECFF),
    focusInset: Color(0xFF463050),
    focusInsetForeground: Color(0xFFF8ECFF),
    focusWarm: Color(0xFFFFB983),
    focusCool: Color(0xFF73DDC8),
    activePlansSurface: Color(0xFF33231F),
    archivedPlansSurface: Color(0xFF18332F),
    librarySurface: Color(0xFF45301D),
    creationSurface: Color(0xFF392A4A),
    actionPrimary: Color(0xFFD5B8FF),
    actionPrimaryForeground: Color(0xFF2F1245),
    actionSecondary: Color(0xFF204A43),
    actionSecondaryForeground: Color(0xFFC5F1E4),
    navigationSurface: Color(0xFF261D2F),
    navigationSelected: Color(0xFFD9BCFF),
    navigationSelectedForeground: Color(0xFF321448),
    navigationLabel: Color(0xFFE2D5EA),
  );

  @override
  AppExpressiveTrainTokens copyWith({
    Color? pageCanvas,
    Color? selectorTrack,
    Color? selectorActive,
    Color? selectorActiveForeground,
    Color? focusSurface,
    Color? focusForeground,
    Color? focusInset,
    Color? focusInsetForeground,
    Color? focusWarm,
    Color? focusCool,
    Color? activePlansSurface,
    Color? archivedPlansSurface,
    Color? librarySurface,
    Color? creationSurface,
    Color? actionPrimary,
    Color? actionPrimaryForeground,
    Color? actionSecondary,
    Color? actionSecondaryForeground,
    Color? navigationSurface,
    Color? navigationSelected,
    Color? navigationSelectedForeground,
    Color? navigationLabel,
  }) {
    return AppExpressiveTrainTokens(
      pageCanvas: pageCanvas ?? this.pageCanvas,
      selectorTrack: selectorTrack ?? this.selectorTrack,
      selectorActive: selectorActive ?? this.selectorActive,
      selectorActiveForeground:
          selectorActiveForeground ?? this.selectorActiveForeground,
      focusSurface: focusSurface ?? this.focusSurface,
      focusForeground: focusForeground ?? this.focusForeground,
      focusInset: focusInset ?? this.focusInset,
      focusInsetForeground: focusInsetForeground ?? this.focusInsetForeground,
      focusWarm: focusWarm ?? this.focusWarm,
      focusCool: focusCool ?? this.focusCool,
      activePlansSurface: activePlansSurface ?? this.activePlansSurface,
      archivedPlansSurface: archivedPlansSurface ?? this.archivedPlansSurface,
      librarySurface: librarySurface ?? this.librarySurface,
      creationSurface: creationSurface ?? this.creationSurface,
      actionPrimary: actionPrimary ?? this.actionPrimary,
      actionPrimaryForeground:
          actionPrimaryForeground ?? this.actionPrimaryForeground,
      actionSecondary: actionSecondary ?? this.actionSecondary,
      actionSecondaryForeground:
          actionSecondaryForeground ?? this.actionSecondaryForeground,
      navigationSurface: navigationSurface ?? this.navigationSurface,
      navigationSelected: navigationSelected ?? this.navigationSelected,
      navigationSelectedForeground:
          navigationSelectedForeground ?? this.navigationSelectedForeground,
      navigationLabel: navigationLabel ?? this.navigationLabel,
    );
  }

  @override
  AppExpressiveTrainTokens lerp(
    covariant ThemeExtension<AppExpressiveTrainTokens>? other,
    double t,
  ) {
    if (other is! AppExpressiveTrainTokens) return this;
    return AppExpressiveTrainTokens(
      pageCanvas: Color.lerp(pageCanvas, other.pageCanvas, t)!,
      selectorTrack: Color.lerp(selectorTrack, other.selectorTrack, t)!,
      selectorActive: Color.lerp(selectorActive, other.selectorActive, t)!,
      selectorActiveForeground: Color.lerp(
        selectorActiveForeground,
        other.selectorActiveForeground,
        t,
      )!,
      focusSurface: Color.lerp(focusSurface, other.focusSurface, t)!,
      focusForeground: Color.lerp(focusForeground, other.focusForeground, t)!,
      focusInset: Color.lerp(focusInset, other.focusInset, t)!,
      focusInsetForeground: Color.lerp(
        focusInsetForeground,
        other.focusInsetForeground,
        t,
      )!,
      focusWarm: Color.lerp(focusWarm, other.focusWarm, t)!,
      focusCool: Color.lerp(focusCool, other.focusCool, t)!,
      activePlansSurface: Color.lerp(
        activePlansSurface,
        other.activePlansSurface,
        t,
      )!,
      archivedPlansSurface: Color.lerp(
        archivedPlansSurface,
        other.archivedPlansSurface,
        t,
      )!,
      librarySurface: Color.lerp(librarySurface, other.librarySurface, t)!,
      creationSurface: Color.lerp(creationSurface, other.creationSurface, t)!,
      actionPrimary: Color.lerp(actionPrimary, other.actionPrimary, t)!,
      actionPrimaryForeground: Color.lerp(
        actionPrimaryForeground,
        other.actionPrimaryForeground,
        t,
      )!,
      actionSecondary: Color.lerp(actionSecondary, other.actionSecondary, t)!,
      actionSecondaryForeground: Color.lerp(
        actionSecondaryForeground,
        other.actionSecondaryForeground,
        t,
      )!,
      navigationSurface: Color.lerp(
        navigationSurface,
        other.navigationSurface,
        t,
      )!,
      navigationSelected: Color.lerp(
        navigationSelected,
        other.navigationSelected,
        t,
      )!,
      navigationSelectedForeground: Color.lerp(
        navigationSelectedForeground,
        other.navigationSelectedForeground,
        t,
      )!,
      navigationLabel: Color.lerp(navigationLabel, other.navigationLabel, t)!,
    );
  }
}

/// Shape roles for the amplified Train + shell preview; semantic shapes vary
/// by component role rather than applying one radius to the whole app.
abstract final class ExpressiveTrainShapes {
  static const selector = BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(14),
    bottomLeft: Radius.circular(14),
    bottomRight: Radius.circular(30),
  );
  static const selectedSelector = BorderRadius.only(
    topLeft: Radius.circular(26),
    topRight: Radius.circular(12),
    bottomLeft: Radius.circular(12),
    bottomRight: Radius.circular(26),
  );
  static const focusHero = BorderRadius.only(
    topLeft: Radius.circular(36),
    topRight: Radius.circular(16),
    bottomLeft: Radius.circular(16),
    bottomRight: Radius.circular(36),
  );
  static const focusInset = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(12),
    bottomLeft: Radius.circular(12),
    bottomRight: Radius.circular(24),
  );
  static const focusInsetPressed = BorderRadius.all(Radius.circular(14));
  static const activePlans = BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(28),
    bottomLeft: Radius.circular(28),
    bottomRight: Radius.circular(16),
  );
  static const planRow = BorderRadius.only(
    topLeft: Radius.circular(18),
    topRight: Radius.circular(30),
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(30),
  );
  static const planRowAlternate = BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(18),
    bottomLeft: Radius.circular(30),
    bottomRight: Radius.circular(14),
  );
  static const planRowPressed = BorderRadius.all(Radius.circular(15));
  static const planIdentityBlock = BorderRadius.only(
    topLeft: Radius.circular(14),
    topRight: Radius.circular(22),
    bottomLeft: Radius.circular(22),
    bottomRight: Radius.circular(10),
  );
  static const planIdentityBlockAlternate = BorderRadius.only(
    topLeft: Radius.circular(22),
    topRight: Radius.circular(14),
    bottomLeft: Radius.circular(10),
    bottomRight: Radius.circular(22),
  );
  static const compactControl = BorderRadius.only(
    topLeft: Radius.circular(17),
    topRight: Radius.circular(9),
    bottomLeft: Radius.circular(9),
    bottomRight: Radius.circular(17),
  );
  static const compactControlPressed = BorderRadius.all(Radius.circular(10));
  static const menu = BorderRadius.only(
    topLeft: Radius.circular(26),
    topRight: Radius.circular(12),
    bottomLeft: Radius.circular(12),
    bottomRight: Radius.circular(26),
  );
  static const showMore = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(11),
    bottomLeft: Radius.circular(11),
    bottomRight: Radius.circular(24),
  );
  static const section = BorderRadius.only(
    topLeft: Radius.circular(28),
    topRight: Radius.circular(14),
    bottomLeft: Radius.circular(14),
    bottomRight: Radius.circular(28),
  );
  static const primaryAction = BorderRadius.only(
    topLeft: Radius.circular(32),
    topRight: Radius.circular(18),
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(32),
  );
  static const navigation = BorderRadius.only(
    topLeft: Radius.circular(28),
    topRight: Radius.circular(28),
    bottomLeft: Radius.circular(12),
    bottomRight: Radius.circular(12),
  );
}
