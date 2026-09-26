import 'package:flutter/material.dart';

import 'tokens/app_data_visualization_tokens.dart';
import 'tokens/app_effect_tokens.dart';
import 'tokens/app_flow_tokens.dart';
import 'tokens/app_generation_tokens.dart';
import 'tokens/app_media_tokens.dart';
import 'tokens/app_motion_tokens.dart';
import 'tokens/app_nutrition_tokens.dart';
import 'tokens/app_progress_colors.dart';
import 'tokens/app_semantic_colors.dart';
import 'tokens/app_settings_presentation_tokens.dart';
import 'tokens/app_shape_tokens.dart';
import 'tokens/app_surface_decoration_tokens.dart';
import 'tokens/app_surface_tokens.dart';
import 'tokens/app_tutorial_tokens.dart';

/// Complete development recipe for the Neo-Brutalism theme family.
///
/// The family is intentionally defined in one place. Feature widgets consume
/// the ordinary Material theme and Tonos extensions; they do not branch on
/// the family name.
abstract final class NeoBrutalismThemeDefinition {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final ink = isDark ? const Color(0xFFFFF8E7) : const Color(0xFF161616);
    // Colored panels keep near-black edges; neutral controls use a restrained
    // warm-gray outline so their boundaries remain visible on dark surfaces.
    const edgeInk = Color(0xFF161616);
    const neutralInk = Color(0xFF81776B);
    final shadow = isDark ? Colors.black : const Color(0xFF161616);
    const paper = Color(0xFFFFF8E7);
    final canvas = isDark ? const Color(0xFF171717) : paper;
    final surface = isDark ? const Color(0xFF272727) : Colors.white;
    final secondarySurface =
        isDark ? const Color(0xFF333333) : const Color(0xFFF1E9D7);
    final yellow = isDark ? const Color(0xFFFFEA61) : const Color(0xFFFFE34D);
    final green = isDark ? const Color(0xFF8CFF5A) : const Color(0xFF5F9E35);
    final completedSetGreen =
        isDark ? const Color(0xFFB8E67A) : const Color(0xFFA9CD80);
    final completedExerciseGreen =
        isDark ? const Color(0xFFA6D466) : const Color(0xFF96B967);
    final completedSetRowGreen =
        isDark ? const Color(0xFFC5EC91) : const Color(0xFFB9D994);
    final orange = isDark ? const Color(0xFFFF8A3D) : const Color(0xFFFFB36B);
    final pink = isDark ? const Color(0xFFFF6BAE) : const Color(0xFFFF92BF);
    final purple = isDark ? const Color(0xFFD2A8FF) : const Color(0xFFC4A1FF);
    final cyan = isDark ? const Color(0xFF55F0EA) : const Color(0xFF64DDE0);
    final red = isDark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E);
    // Decorative fills can remain vivid, but fine chart strokes and anatomy
    // details need darker light-mode variants on cream and yellow surfaces.
    final chartPurple = isDark ? purple : const Color(0xFF64408F);
    final chartCyan = isDark ? cyan : const Color(0xFF006A72);
    final positiveText = isDark ? green : const Color(0xFF38651F);
    final negativeText = isDark ? red : const Color(0xFF9B284C);
    final exercisePeach =
        isDark ? const Color(0xFFFFC184) : const Color(0xFFFFD2A3);
    final exerciseLavender =
        isDark ? const Color(0xFFE0C9FF) : const Color(0xFFDAC8F1);
    // Proposal role colors stay saturated in dark mode. The page canvas and
    // text still switch with brightness, while dark colored panels get a
    // restrained luminous lift instead of collapsing into charcoal variants.
    final paleYellow =
        isDark ? const Color(0xFFFFE875) : const Color(0xFFFFF0A6);
    final paleGreen = completedSetGreen;
    final paleOrange = orange;
    final palePink = pink;
    final palePurple = purple;
    final paleCyan = cyan;

    final scheme = (isDark
            ? ColorScheme.dark(
              primary: yellow,
              onPrimary: const Color(0xFF161616),
              secondary: purple,
              onSecondary: const Color(0xFF161616),
              tertiary: cyan,
              onTertiary: const Color(0xFF161616),
              error: red,
              onError: const Color(0xFF161616),
              surface: canvas,
              onSurface: ink,
            )
            : ColorScheme.light(
              primary: yellow,
              onPrimary: const Color(0xFF161616),
              secondary: purple,
              onSecondary: const Color(0xFF161616),
              tertiary: cyan,
              onTertiary: const Color(0xFF161616),
              error: red,
              onError: Colors.white,
              surface: canvas,
              onSurface: ink,
            ))
        .copyWith(
          primaryContainer: yellow,
          onPrimaryContainer: const Color(0xFF161616),
          secondaryContainer: palePurple,
          onSecondaryContainer: const Color(0xFF161616),
          tertiaryContainer: paleCyan,
          onTertiaryContainer: const Color(0xFF161616),
          surfaceContainerLowest: canvas,
          surfaceContainerLow: secondarySurface,
          surfaceContainer: secondarySurface,
          surfaceContainerHigh: secondarySurface,
          surfaceContainerHighest: secondarySurface,
          onSurfaceVariant: isDark ? paper : const Color(0xFF38312B),
          outline: ink,
          outlineVariant: ink.withValues(alpha: isDark ? 0.72 : 0.34),
          surfaceTint: Colors.transparent,
        );

    final base = ThemeData.from(colorScheme: scheme, useMaterial3: true);
    final compactRadius = _radius(4);
    final cardRadius = _radius(8);
    final sheetRadius = _radius(12);
    const hardBorder = BorderSide(color: edgeInk, width: 2);
    // Neutral dark controls need a boundary that is visible without becoming
    // a white sticker. Colored panels keep their distinct near-black frame.
    final controlBorder = BorderSide(
      color: isDark ? neutralInk : edgeInk,
      width: 2,
    );
    final focusBorder = BorderSide(
      color: isDark ? purple : const Color(0xFF64408F),
      width: 3,
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: compactRadius,
      side: hardBorder,
    );
    final cardShape = RoundedRectangleBorder(
      borderRadius: cardRadius,
      side: hardBorder,
    );
    final hardShadow = BoxShadow(
      color: shadow,
      blurRadius: 0,
      spreadRadius: 0,
      offset: const Offset(3, 3),
    );

    final semanticColors = _semanticColors(
      scheme,
      ink: ink,
      yellow: yellow,
      green: green,
      completedSetGreen: completedSetGreen,
      completedExerciseGreen: completedExerciseGreen,
      completedSetRowGreen: completedSetRowGreen,
      orange: orange,
      pink: pink,
      purple: purple,
      cyan: cyan,
      red: red,
      paleGreen: paleGreen,
      paleOrange: paleOrange,
      exercisePeach: exercisePeach,
    );
    final surfaceTokens = _surfaceTokens(
      scheme,
      isDark: isDark,
      surface: surface,
      secondarySurface: secondarySurface,
      ink: ink,
      edgeInk: edgeInk,
      neutralInk: neutralInk,
      yellow: yellow,
      paleYellow: paleYellow,
      paleGreen: paleGreen,
      paleOrange: paleOrange,
      palePink: palePink,
      palePurple: palePurple,
      paleCyan: paleCyan,
      exerciseLavender: exerciseLavender,
    );
    final shapeTokens = _shapeTokens();
    final effectTokens = AppEffectTokens(
      cardElevation: 0,
      dialogElevation: 0,
      sheetElevation: 0,
      exerciseDetailSheetElevation: 0,
      swapSheetElevation: 0,
      progressRemoveBadgeShadow: hardShadow,
      feedbackElevation: 0,
      cardShadow: shadow,
      cardShadowBlur: 0,
      cardShadowOffset: const Offset(3, 3),
      completedSetShadowOffset: const Offset(2, 2),
      raisedPanelShadowOffset: const Offset(4, 4),
      primaryActionShadowOffset: const Offset(4, 4),
      dialogShadowOffset: const Offset(4, 4),
      shadowColor: shadow,
      shadowOpacity: 1,
      shadowBlur: 0,
      backdropBlurSigma: 0,
      noEffectsShadowOpacity: 0,
      noEffectsShadowBlur: 0,
      noEffectsBackdropBlurSigma: 0,
    );
    final progressColors = AppProgressColors.fromTheme(base).copyWith(
      accent: purple,
      estimated: ink.withValues(alpha: 0.72),
      estimatedOneRm: positiveText,
      grid: ink.withValues(alpha: 0.24),
      label: ink.withValues(alpha: 0.72),
      exerciseIncrease: positiveText,
      exerciseDecrease: negativeText,
      neutral: ink.withValues(alpha: 0.62),
      workoutIncrease: positiveText,
      workoutDecrease: negativeText,
      healthIncrease: positiveText,
      healthDecrease: negativeText,
      healthCard: paleCyan,
      healthGrid: ink.withValues(alpha: 0.24),
    );
    final tutorialTokens = AppTutorialTokens.classic.copyWith(
      focusShape: cardRadius,
      cardShape: cardRadius,
      iconShape: compactRadius,
      coachShape: sheetRadius,
      coachIconShape: compactRadius,
      inputShape: compactRadius,
      tileShape: cardRadius,
      sectionShape: cardRadius,
      compactShape: compactRadius,
      heroShape: sheetRadius,
      cardShadow: hardShadow,
      coachShadow: hardShadow,
      accentForeground: isDark ? yellow : const Color(0xFF7A5200),
    );
    final mediaTokens = AppMediaTokens(
      editorAddSurface: secondarySurface,
      editorItemSurface: paleCyan,
      editorShape: compactRadius,
      previewShape: cardRadius,
      overlayShape: compactRadius,
      viewerShape: cardRadius,
      overlayOpacity: 1,
      overlayShadow: <BoxShadow>[hardShadow],
    );
    final settingsTokens = AppSettingsPresentationTokens(
      heroUsesGradient: false,
      heroUsesHardShadow: true,
      sectionUsesAccentForControls: false,
      sectionHeaderUsesLabel: true,
      sectionHeaderFill: pink,
      sectionHeaderForeground: Color(0xFF161616),
      saveActionUsesHardShadow: true,
      heroAccentFillOpacity: 1,
      heroBorderOpacity: 1,
      heroIconFillOpacity: 0.2,
      sectionAccentBorderOpacity: 1,
      sectionNeutralBorderOpacity: 1,
      iconFillOpacity: 0.18,
      infoBorderOpacity: 1,
      saveBarBorderOpacity: 1,
    );
    const motionTokens = AppMotionTokens(
      instant: Duration.zero,
      standard: Duration(milliseconds: 140),
      emphasized: Duration(milliseconds: 220),
      page: Duration(milliseconds: 220),
      quick: Duration(milliseconds: 120),
      pageTransition: Duration(milliseconds: 180),
      exerciseDetailSelection: Duration(milliseconds: 120),
      reduced: Duration.zero,
      standardCurve: Curves.easeOut,
      emphasizedCurve: Curves.easeOutCubic,
      reducedCurve: Curves.linear,
    );
    final dataVisualizationTokens = AppDataVisualizationTokens.fromBrightness(
      brightness,
    ).copyWith(
      heatmapLow: isDark ? const Color(0xFF77736B) : const Color(0xFF161616),
      heatmapHigh: chartCyan,
      primarySeries: chartPurple,
      secondarySeries: chartCyan,
      sessionExercises: cyan,
      sessionSets: green,
      sessionDuration: yellow,
      sessionVolume: pink,
      positive: positiveText,
      negative: negativeText,
      neutral: ink.withValues(alpha: 0.55),
      grid: ink.withValues(alpha: 0.24),
      label: ink.withValues(alpha: 0.72),
      selection: purple,
      recordTodayContainer: paleGreen,
      recordTodayBorder: green,
      onRecordTodayContainer: ink,
      recordMonthly: isDark ? green : const Color(0xFF38651F),
      recordAllTime: isDark ? orange : const Color(0xFF865000),
      firstRecord: isDark ? const Color(0xFFFFF8E7) : ink,
      tertiarySeries: orange,
      carbohydrateSeries: orange,
      proteinRing: pink,
      fatRing: yellow,
      paginationActive: purple,
      paginationInactive: ink.withValues(alpha: 0.36),
    );
    final flowTokens = AppFlowTokens.fromColorScheme(scheme).copyWith(
      canvas: surface,
      nodeBackground: secondarySurface,
      nodeBorder: edgeInk,
      nodeText: ink,
      success: green,
      failure: red,
      action: yellow,
      onAction: const Color(0xFF161616),
      loopback: ink.withValues(alpha: 0.7),
      diagramSuccess: green,
      diagramLoopback: purple,
      profileScope: cyan,
      planScope: orange,
      addSetAction: yellow,
    );
    final generationTokens = AppGenerationTokens.fromColorScheme(
      scheme,
    ).copyWith(
      accent: purple,
      introGradientStart: secondarySurface,
      introGradientEnd: secondarySurface,
      introBorder: edgeInk,
      introIconFill: yellow,
      introShape: cardRadius,
      introIconShape: compactRadius,
      summarySurface: surface,
      summaryBorder: edgeInk,
      summaryPillShape: compactRadius,
      sectionSurface: secondarySurface,
      sectionBorder: edgeInk,
      sectionIconFill: cyan,
      sectionShape: cardRadius,
      sectionIconShape: compactRadius,
      fieldLabel: ink,
      fieldBorder: ink,
      fieldFill: surface,
      fieldShape: compactRadius,
      secondaryText: ink.withValues(alpha: 0.72),
      choiceSelectedSurface: yellow,
      choiceUnselectedSurface: surface,
      choiceSelectedBorder: edgeInk,
      choiceUnselectedBorder: ink,
      choiceShape: compactRadius,
      actionBarSurface: yellow,
      actionBarBorder: edgeInk,
      badge: pink,
      onBadge: const Color(0xFF161616),
      badgeShape: compactRadius,
    );
    final nutritionTokens = AppNutritionTokens.fromColorScheme(scheme).copyWith(
      pantryLogSurface: paleYellow,
      addMealSurface: paleGreen,
      planMealSurface: paleCyan,
      textDetailsBorder: edgeInk,
      foodBorder: edgeInk,
      photoPlaceholder: secondarySurface,
      mutedAction: ink.withValues(alpha: 0.62),
      favoriteAction: pink,
      addFoodAction: green,
      densityHelp: ink.withValues(alpha: 0.72),
      selectedLabel: const Color(0xFF161616),
      logGrid: ink.withValues(alpha: 0.18),
      compactShape: compactRadius,
      sectionShape: cardRadius,
      portionShape: compactRadius,
      quantityShape: compactRadius,
    );

    final primaryButtonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) =>
            states.contains(WidgetState.disabled)
                ? ink.withValues(alpha: 0.12)
                : yellow,
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) =>
            states.contains(WidgetState.disabled)
                ? ink.withValues(alpha: 0.38)
                : const Color(0xFF161616),
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (states) =>
            states.contains(WidgetState.focused)
                ? purple.withValues(alpha: 0.34)
                : purple.withValues(alpha: 0.24),
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>(
        (states) =>
            states.contains(WidgetState.focused) ? focusBorder : hardBorder,
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder?>(buttonShape),
      elevation: const WidgetStatePropertyAll<double>(0),
    );
    final secondaryButtonStyle = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll<Color?>(surface),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) =>
            states.contains(WidgetState.disabled)
                ? ink.withValues(alpha: 0.38)
                : ink,
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (states) =>
            states.contains(WidgetState.focused)
                ? purple.withValues(alpha: 0.30)
                : purple.withValues(alpha: 0.18),
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>(
        (states) =>
            states.contains(WidgetState.focused) ? focusBorder : controlBorder,
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder?>(buttonShape),
      elevation: const WidgetStatePropertyAll<double>(0),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: compactRadius,
      borderSide: controlBorder,
    );
    final textButtonStyle = ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) =>
            states.contains(WidgetState.disabled)
                ? ink.withValues(alpha: 0.38)
                : ink,
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (states) =>
            states.contains(WidgetState.focused)
                ? purple.withValues(alpha: 0.30)
                : purple.withValues(alpha: 0.18),
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide.none;
        }
        if (states.contains(WidgetState.focused)) {
          return focusBorder;
        }
        return BorderSide.none;
      }),
      shape: WidgetStateProperty.resolveWith<OutlinedBorder?>(
        (states) => RoundedRectangleBorder(borderRadius: compactRadius),
      ),
      elevation: const WidgetStatePropertyAll<double>(0),
    );
    final neoTextTheme = base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.6,
      ),
      displayMedium: base.textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.4,
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.35,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.25,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w900,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      titleSmall: base.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      labelMedium: base.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      labelSmall: base.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.3),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.3),
      bodySmall: base.textTheme.bodySmall?.copyWith(height: 1.25),
    );

    return base.copyWith(
      scaffoldBackgroundColor: canvas,
      textTheme: neoTextTheme.apply(bodyColor: ink, displayColor: ink),
      cardColor: surface,
      shadowColor: shadow,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(color: edgeInk.withValues(alpha: 0.24), width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        shadowColor: shadow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: cardShape,
      ),
      filledButtonTheme: FilledButtonThemeData(style: primaryButtonStyle),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
      textButtonTheme: TextButtonThemeData(style: textButtonStyle),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: yellow,
        foregroundColor: const Color(0xFF161616),
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        shape: buttonShape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        labelStyle: TextStyle(color: ink.withValues(alpha: 0.72)),
        hintStyle: TextStyle(color: ink.withValues(alpha: 0.62)),
        enabledBorder: inputBorder,
        border: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: compactRadius,
          borderSide: focusBorder,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: compactRadius,
          borderSide: BorderSide(color: red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: compactRadius,
          borderSide: BorderSide(color: red, width: 3),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: compactRadius,
          borderSide: BorderSide(color: ink.withValues(alpha: 0.38), width: 2),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: yellow,
        selectedItemColor: const Color(0xFF64408F),
        unselectedItemColor: const Color(0xFF161616),
        selectedIconTheme: const IconThemeData(color: Color(0xFF64408F)),
        unselectedIconTheme: const IconThemeData(color: Color(0xFF161616)),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: yellow,
        indicatorColor: purple,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: const WidgetStatePropertyAll<TextStyle?>(
          TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF161616)),
        ),
        iconTheme: const WidgetStatePropertyAll<IconThemeData?>(
          IconThemeData(color: Color(0xFF161616)),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: const Color(0xFF161616),
        unselectedLabelColor: ink.withValues(alpha: 0.62),
        indicator: BoxDecoration(
          color: purple,
          border: Border(bottom: BorderSide(color: edgeInk, width: 2)),
        ),
        dividerColor: edgeInk,
        dividerHeight: 2,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palePurple,
        surfaceTintColor: Colors.transparent,
        shadowColor: shadow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: sheetRadius,
          side: hardBorder,
        ),
        titleTextStyle: TextStyle(
          color: const Color(0xFF161616),
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: const TextStyle(color: Color(0xFF161616)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shadowColor: shadow,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          side: hardBorder,
        ),
        showDragHandle: true,
        dragHandleColor: ink,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: shadow,
        shape: RoundedRectangleBorder(
          borderRadius: compactRadius,
          side: hardBorder,
        ),
        textStyle: TextStyle(color: ink),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        actionTextColor: isDark ? const Color(0xFF64408F) : yellow,
        contentTextStyle: TextStyle(color: isDark ? Colors.black : paper),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: compactRadius,
          side: BorderSide(color: yellow, width: 2),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) =>
              states.contains(WidgetState.selected)
                  ? yellow
                  : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll<Color?>(Color(0xFF161616)),
        side: WidgetStateBorderSide.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? hardBorder
                  : controlBorder,
        ),
        shape: RoundedRectangleBorder(borderRadius: compactRadius),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected) ? purple : ink,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (states) =>
              states.contains(WidgetState.selected)
                  ? yellow
                  : isDark
                  ? const Color(0xFFD8CFBE)
                  : secondarySurface,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected) ? purple : surface,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected) ? edgeInk : ink,
        ),
        trackOutlineWidth: const WidgetStatePropertyAll<double?>(2),
      ),
      dividerTheme: const DividerThemeData(
        color: edgeInk,
        thickness: 2,
        space: 2,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: ink,
          borderRadius: compactRadius,
          border: Border.all(color: yellow, width: 2),
          boxShadow: [hardShadow],
        ),
        textStyle: TextStyle(color: isDark ? Colors.black : paper),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: purple,
        linearTrackColor: ink.withValues(alpha: 0.18),
        circularTrackColor: ink.withValues(alpha: 0.18),
        borderRadius: compactRadius,
        stopIndicatorColor: yellow,
      ),
      extensions: <ThemeExtension<dynamic>>[
        semanticColors,
        progressColors,
        tutorialTokens,
        mediaTokens,
        shapeTokens,
        AppSurfaceDecorationTokens(
          panel: AppSurfaceDecoration.outlinedOnly,
          panelRaised: AppSurfaceDecoration.outlinedCompactShadow,
          card: AppSurfaceDecoration.outlinedCompactShadow,
          compactCard: AppSurfaceDecoration.outlinedCompactShadow,
          input: AppSurfaceDecoration.outlinedOnly,
          sheet: AppSurfaceDecoration.outlinedCompactShadow,
          media: AppSurfaceDecoration.outlinedOnly,
          mediaPlaceholder: AppSurfaceDecoration.outlinedOnly,
        ),
        settingsTokens,
        surfaceTokens,
        motionTokens,
        effectTokens,
        dataVisualizationTokens,
        flowTokens,
        generationTokens,
        nutritionTokens,
      ],
    );
  }

  static AppSemanticColors _semanticColors(
    ColorScheme scheme, {
    required Color ink,
    required Color yellow,
    required Color green,
    required Color completedSetGreen,
    required Color completedExerciseGreen,
    required Color completedSetRowGreen,
    required Color orange,
    required Color pink,
    required Color purple,
    required Color cyan,
    required Color red,
    required Color paleGreen,
    required Color paleOrange,
    required Color exercisePeach,
  }) {
    return AppSemanticColors.fromColorScheme(scheme).copyWith(
      editingActive: green,
      editingInactive: ink.withValues(alpha: 0.52),
      workoutCompleted: completedSetGreen,
      workoutExerciseCompleted: completedExerciseGreen,
      workoutSetCompleted: completedSetRowGreen,
      workoutAddChangeSet: cyan,
      swapCancel: pink,
      swapConfirm: green,
      onSwapConfirm: const Color(0xFF161616),
      swapMatch: cyan,
      trainProfileAvatar: green,
      onTrainProfileAvatar: const Color(0xFF161616),
      trainOptimizedAction: purple,
      positive: green,
      onPositive: const Color(0xFF161616),
      warning: orange,
      databaseHealthy: green,
      databaseWarning: orange,
      onWarning: const Color(0xFF161616),
      negative: red,
      onNegative:
          scheme.brightness == Brightness.dark
              ? const Color(0xFF161616)
              : Colors.white,
      info: cyan,
      onInfo: const Color(0xFF161616),
      strongContent: ink,
      mutedContent:
          scheme.brightness == Brightness.dark
              ? const Color(0xFFD8CFBE)
              : ink.withValues(alpha: 0.68),
      measurementContainer: paleGreen,
      onMeasurementContainer: const Color(0xFF161616),
      nutritionContainer: paleOrange,
      onNutritionContainer: const Color(0xFF161616),
      workoutContainer: exercisePeach,
      onWorkoutContainer: const Color(0xFF161616),
      primaryAction: yellow,
      onPrimaryAction: const Color(0xFF161616),
      automaticPlanBadge: cyan,
      onAutomaticPlanBadge: const Color(0xFF161616),
      workoutAction: purple,
      onWorkoutAction: const Color(0xFF161616),
      startWorkoutAction: yellow,
      onStartWorkoutAction: const Color(0xFF161616),
      completionAccent: completedSetGreen,
      drawerHeaderForeground: ink,
      ongoingSessionAction: yellow,
      ongoingSessionExit: pink,
      focusRing: const Color(0xFF64408F),
      disabledContent: ink.withValues(alpha: 0.38),
      disabledContainer: ink.withValues(alpha: 0.12),
    );
  }

  static AppSurfaceTokens _surfaceTokens(
    ColorScheme scheme, {
    required bool isDark,
    required Color surface,
    required Color secondarySurface,
    required Color ink,
    required Color edgeInk,
    required Color neutralInk,
    required Color yellow,
    required Color paleYellow,
    required Color paleGreen,
    required Color paleOrange,
    required Color palePink,
    required Color palePurple,
    required Color paleCyan,
    required Color exerciseLavender,
  }) {
    return AppSurfaceTokens.fromColorScheme(scheme).copyWith(
      panel: secondarySurface,
      panelRaised: surface,
      card: surface,
      planCard: paleCyan,
      presetFocus: paleYellow,
      flowControl: paleCyan,
      planFilter: palePurple,
      planDuration: paleOrange,
      planGroup: palePink,
      metricChip: paleCyan,
      planActionBar: scheme.primary,
      optimizedAction: palePurple,
      subtleOutline: edgeInk,
      neutralOutline: isDark ? neutralInk : edgeInk,
      input: surface,
      sheet: surface,
      dialog: surface,
      media: surface,
      mediaFrame: secondarySurface,
      mediaPlaceholder: secondarySurface,
      mediaOutline: edgeInk,
      catalogSelection: paleCyan,
      catalogUsage: secondarySurface,
      catalogOutline: edgeInk,
      exerciseDetailCard: secondarySurface,
      exerciseDetailTimeframe: palePurple,
      exerciseDetailRecord: paleGreen,
      exerciseDetailMetricList: secondarySurface,
      exerciseDetailState: paleGreen,
      exerciseDetailChart: paleCyan,
      exerciseDetailChartEmpty: secondarySurface,
      exerciseDetailTooltip: surface,
      divider: edgeInk.withValues(alpha: 0.3),
      settingsHero: yellow,
      settingsSection: palePurple,
      settingsInput: paleYellow,
      settingsSaveBar: yellow,
      dialogChoice: paleYellow,
      exerciseProgressHero: palePink,
      exerciseProgressStat: paleYellow,
      exerciseProgressSelector: palePurple,
      exerciseProgressTooltip: surface,
      workoutMetricStat: surface,
      workoutMetricChart: secondarySurface,
      workoutMetricTooltip: surface,
      workoutMetricRange: paleYellow,
      workoutMetricDetails: secondarySurface,
      workoutMetricInsight: secondarySurface,
      dashboardHero: yellow,
      dashboardSection: secondarySurface,
      dashboardEditor: surface,
      dashboardUsage: paleCyan,
      historyPeriodSelector: palePurple,
      calendarModeSelector: paleYellow,
      calendarDayEmpty: secondarySurface,
      historySelectedPeriod: palePurple,
      historyDivider: edgeInk.withValues(alpha: 0.3),
      workoutHandle: ink.withValues(alpha: 0.7),
      sessionSummary: exerciseLavender,
      workoutCardCompleteFill: 1,
      workoutSetCompleteFill: 1,
      useSemanticWorkoutCardFill: true,
      workoutChangeSetOutline: edgeInk,
      completionMetricFill: 1,
      completionMetricBorder: 1,
      completionSetFill: 1,
      completionExerciseFill: 1,
      completionExerciseBorder: 1,
    );
  }

  static AppShapeTokens _shapeTokens() {
    return AppShapeTokens.classic.copyWith(
      trainTab: _radius(6),
      trainTabButton: _radius(3),
      workoutCompletedSet: BorderRadius.zero,
      workoutAddChangeSet: _radius(4),
      mediaThumbnail: _radius(4),
      exerciseDetailSheet: _topRadius(12),
      exerciseDetailCard: _radius(8),
      exerciseDetailIcon: _radius(4),
      exerciseDetailTag: _radius(4),
      exerciseDetailMetric: _radius(4),
      exerciseDetailTimeframe: _radius(4),
      exerciseDetailTimeframeOption: _radius(4),
      exerciseDetailRecord: _radius(8),
      exerciseDetailRecordAction: _radius(4),
      exerciseDetailLoadMore: _radius(4),
      exerciseDetailMetricRep: _radius(4),
      exerciseDetailState: _radius(8),
      exerciseDetailChart: _radius(8),
      exerciseDetailChartTooltip: _radius(4),
      compact: _radius(4),
      control: _radius(4),
      metric: _radius(4),
      recordBadge: _radius(4),
      recordBadgeCompact: _radius(4),
      workoutSection: _radius(8),
      planCard: _radius(8),
      flowControl: _radius(8),
      flowIcon: _radius(4),
      card: _radius(8),
      sheet: _radius(12),
      swapSheet: _topRadius(12),
      settingsAction: _radius(4),
      settingsPanel: _radius(8),
      settingsInput: _radius(4),
      settingsTabIndicator: _radius(4),
      settingsScopeIcon: _radius(4),
      settingsTitleCard: _radius(8),
      settingsField: _radius(4),
      settingsPicker: _radius(8),
      settingsIcon: _radius(4),
      profileTile: _radius(8),
      hero: _radius(8),
      actionBar: _radius(8),
      dialogChoice: _radius(4),
      exerciseProgressHero: _radius(8),
      exerciseProgressStat: _radius(4),
      exerciseProgressSelector: _radius(4),
      exerciseProgressAddTile: _radius(4),
      exerciseProgressTooltip: _radius(4),
      workoutMetricStat: _radius(8),
      workoutMetricChart: _radius(8),
      workoutMetricTooltip: _radius(4),
      workoutMetricRange: _radius(4),
      workoutMetricRangeOption: _radius(4),
      workoutMetricDetails: _radius(4),
      workoutMetricInsight: _radius(4),
      healthTrendCard: _radius(8),
      healthTrendEntry: _radius(4),
      dashboardHero: _radius(8),
      dashboardSection: _radius(8),
      dashboardEditor: _radius(8),
      dashboardAction: _radius(4),
      dashboardUsage: _radius(4),
      dashboardRow: _radius(4),
      dashboardFooter: _radius(8),
      historySelectedPeriod: _radius(4),
      outlineWidth: 2,
      focusRingWidth: 3,
    );
  }
}

BorderRadius _radius(double value) => BorderRadius.all(Radius.circular(value));

BorderRadius _topRadius(double value) =>
    BorderRadius.vertical(top: Radius.circular(value));
