import 'package:flutter/material.dart';

/// Tonos-specific state, feedback, and domain-action roles outside ColorScheme.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    this.editingActive = Colors.green,
    this.editingInactive = Colors.grey,
    this.workoutCompleted = Colors.green,
    this.workoutExerciseCompleted = Colors.green,
    this.workoutSetCompleted = Colors.green,
    this.workoutAddChangeSet = Colors.blueAccent,
    this.swapCancel = Colors.redAccent,
    this.swapConfirm = Colors.green,
    this.onSwapConfirm = Colors.white,
    this.swapMatch = Colors.green,
    this.trainProfileAvatar = Colors.lightGreen,
    this.onTrainProfileAvatar = Colors.white,
    this.trainOptimizedAction = Colors.green,
    required this.positive,
    required this.onPositive,
    required this.warning,
    required this.databaseHealthy,
    required this.databaseWarning,
    required this.onWarning,
    required this.negative,
    required this.onNegative,
    required this.info,
    required this.onInfo,
    required this.strongContent,
    required this.mutedContent,
    required this.measurementContainer,
    required this.onMeasurementContainer,
    required this.nutritionContainer,
    required this.onNutritionContainer,
    required this.workoutContainer,
    required this.onWorkoutContainer,
    required this.primaryAction,
    required this.onPrimaryAction,
    required this.automaticPlanBadge,
    required this.onAutomaticPlanBadge,
    required this.workoutAction,
    required this.onWorkoutAction,
    required this.startWorkoutAction,
    required this.onStartWorkoutAction,
    required this.completionAccent,
    required this.drawerHeaderForeground,
    required this.ongoingSessionAction,
    required this.ongoingSessionExit,
    required this.focusRing,
    required this.disabledContent,
    required this.disabledContainer,
  });

  final Color positive;
  final Color editingActive;
  final Color editingInactive;
  final Color workoutCompleted;
  final Color workoutExerciseCompleted;
  final Color workoutSetCompleted;
  final Color workoutAddChangeSet;
  final Color swapCancel;
  final Color swapConfirm;
  final Color onSwapConfirm;
  final Color swapMatch;
  final Color trainProfileAvatar;
  final Color onTrainProfileAvatar;
  final Color trainOptimizedAction;
  final Color onPositive;
  final Color warning;
  final Color databaseHealthy;
  final Color databaseWarning;
  final Color onWarning;
  final Color negative;
  final Color onNegative;
  final Color info;
  final Color onInfo;
  final Color strongContent;
  final Color mutedContent;
  final Color measurementContainer;
  final Color onMeasurementContainer;
  final Color nutritionContainer;
  final Color onNutritionContainer;
  final Color workoutContainer;
  final Color onWorkoutContainer;
  final Color primaryAction;
  final Color onPrimaryAction;
  final Color automaticPlanBadge;
  final Color onAutomaticPlanBadge;
  final Color workoutAction;
  final Color onWorkoutAction;
  final Color startWorkoutAction;
  final Color onStartWorkoutAction;
  final Color completionAccent;
  final Color drawerHeaderForeground;
  final Color ongoingSessionAction;
  final Color ongoingSessionExit;
  final Color focusRing;
  final Color disabledContent;
  final Color disabledContainer;

  /// Builds the complete fallback used when a theme omitted this extension.
  factory AppSemanticColors.fromColorScheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return AppSemanticColors(
      positive: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
      onPositive: isDark ? Colors.black : Colors.white,
      warning: isDark ? const Color(0xFFFFB74D) : const Color(0xFFF57C00),
      databaseHealthy: Colors.green,
      databaseWarning: Colors.orange,
      onWarning: Colors.black,
      negative: isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828),
      onNegative: isDark ? Colors.black : Colors.white,
      info: isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0),
      onInfo: isDark ? Colors.black : Colors.white,
      strongContent: isDark ? const Color(0xFFE0E0E0) : Colors.black,
      mutedContent: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF757575),
      measurementContainer:
          isDark ? const Color(0xFF004D40) : const Color(0xFFB2DFDB),
      onMeasurementContainer:
          isDark ? const Color(0xFFE0F2F1) : const Color(0xFF00695C),
      nutritionContainer:
          isDark ? const Color(0xFFF57C00) : const Color(0xFFFFE0B2),
      onNutritionContainer:
          isDark ? const Color(0xFFFFF3E0) : const Color(0xFFEF6C00),
      workoutContainer:
          isDark ? const Color(0xFF2E7D32) : const Color(0xFFC8E6C9),
      onWorkoutContainer:
          isDark ? const Color(0xFFE8F5E9) : const Color(0xFF2E7D32),
      primaryAction: isDark ? const Color(0xFF3700B3) : const Color(0xFF6200EE),
      onPrimaryAction: isDark ? Colors.black : Colors.white,
      automaticPlanBadge: const Color(0xFF4EDA41),
      onAutomaticPlanBadge: isDark ? Colors.blueGrey : Colors.white,
      workoutAction: isDark ? const Color(0xFF81C784) : const Color(0xFF4CAF50),
      onWorkoutAction: isDark ? Colors.black : Colors.white,
      startWorkoutAction: const Color(0xFF388E3C),
      onStartWorkoutAction: Colors.white,
      completionAccent: const Color(0xFF7CFF8B),
      drawerHeaderForeground: Colors.white,
      ongoingSessionAction: Colors.green,
      ongoingSessionExit: Colors.red,
      focusRing: scheme.primary,
      disabledContent: scheme.onSurface.withValues(alpha: 0.38),
      disabledContainer: scheme.onSurface.withValues(alpha: 0.12),
    );
  }

  @override
  AppSemanticColors copyWith({
    Color? editingActive,
    Color? editingInactive,
    Color? workoutCompleted,
    Color? workoutExerciseCompleted,
    Color? workoutSetCompleted,
    Color? workoutAddChangeSet,
    Color? swapCancel,
    Color? swapConfirm,
    Color? onSwapConfirm,
    Color? swapMatch,
    Color? trainProfileAvatar,
    Color? onTrainProfileAvatar,
    Color? trainOptimizedAction,
    Color? positive,
    Color? onPositive,
    Color? warning,
    Color? databaseHealthy,
    Color? databaseWarning,
    Color? onWarning,
    Color? negative,
    Color? onNegative,
    Color? info,
    Color? onInfo,
    Color? strongContent,
    Color? mutedContent,
    Color? measurementContainer,
    Color? onMeasurementContainer,
    Color? nutritionContainer,
    Color? onNutritionContainer,
    Color? workoutContainer,
    Color? onWorkoutContainer,
    Color? primaryAction,
    Color? onPrimaryAction,
    Color? automaticPlanBadge,
    Color? onAutomaticPlanBadge,
    Color? workoutAction,
    Color? onWorkoutAction,
    Color? startWorkoutAction,
    Color? onStartWorkoutAction,
    Color? completionAccent,
    Color? drawerHeaderForeground,
    Color? ongoingSessionAction,
    Color? ongoingSessionExit,
    Color? focusRing,
    Color? disabledContent,
    Color? disabledContainer,
  }) {
    return AppSemanticColors(
      positive: positive ?? this.positive,
      editingActive: editingActive ?? this.editingActive,
      editingInactive: editingInactive ?? this.editingInactive,
      workoutCompleted: workoutCompleted ?? this.workoutCompleted,
      workoutExerciseCompleted:
          workoutExerciseCompleted ?? this.workoutExerciseCompleted,
      workoutSetCompleted: workoutSetCompleted ?? this.workoutSetCompleted,
      workoutAddChangeSet: workoutAddChangeSet ?? this.workoutAddChangeSet,
      swapCancel: swapCancel ?? this.swapCancel,
      swapConfirm: swapConfirm ?? this.swapConfirm,
      onSwapConfirm: onSwapConfirm ?? this.onSwapConfirm,
      swapMatch: swapMatch ?? this.swapMatch,
      trainProfileAvatar: trainProfileAvatar ?? this.trainProfileAvatar,
      onTrainProfileAvatar: onTrainProfileAvatar ?? this.onTrainProfileAvatar,
      trainOptimizedAction: trainOptimizedAction ?? this.trainOptimizedAction,
      onPositive: onPositive ?? this.onPositive,
      warning: warning ?? this.warning,
      databaseHealthy: databaseHealthy ?? this.databaseHealthy,
      databaseWarning: databaseWarning ?? this.databaseWarning,
      onWarning: onWarning ?? this.onWarning,
      negative: negative ?? this.negative,
      onNegative: onNegative ?? this.onNegative,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      strongContent: strongContent ?? this.strongContent,
      mutedContent: mutedContent ?? this.mutedContent,
      measurementContainer: measurementContainer ?? this.measurementContainer,
      onMeasurementContainer:
          onMeasurementContainer ?? this.onMeasurementContainer,
      nutritionContainer: nutritionContainer ?? this.nutritionContainer,
      onNutritionContainer: onNutritionContainer ?? this.onNutritionContainer,
      workoutContainer: workoutContainer ?? this.workoutContainer,
      onWorkoutContainer: onWorkoutContainer ?? this.onWorkoutContainer,
      primaryAction: primaryAction ?? this.primaryAction,
      onPrimaryAction: onPrimaryAction ?? this.onPrimaryAction,
      automaticPlanBadge: automaticPlanBadge ?? this.automaticPlanBadge,
      onAutomaticPlanBadge: onAutomaticPlanBadge ?? this.onAutomaticPlanBadge,
      workoutAction: workoutAction ?? this.workoutAction,
      onWorkoutAction: onWorkoutAction ?? this.onWorkoutAction,
      startWorkoutAction: startWorkoutAction ?? this.startWorkoutAction,
      onStartWorkoutAction: onStartWorkoutAction ?? this.onStartWorkoutAction,
      completionAccent: completionAccent ?? this.completionAccent,
      drawerHeaderForeground:
          drawerHeaderForeground ?? this.drawerHeaderForeground,
      ongoingSessionAction: ongoingSessionAction ?? this.ongoingSessionAction,
      ongoingSessionExit: ongoingSessionExit ?? this.ongoingSessionExit,
      focusRing: focusRing ?? this.focusRing,
      disabledContent: disabledContent ?? this.disabledContent,
      disabledContainer: disabledContainer ?? this.disabledContainer,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) {
      return this;
    }
    return AppSemanticColors(
      positive: Color.lerp(positive, other.positive, t)!,
      editingActive: Color.lerp(editingActive, other.editingActive, t)!,
      editingInactive: Color.lerp(editingInactive, other.editingInactive, t)!,
      workoutCompleted:
          Color.lerp(workoutCompleted, other.workoutCompleted, t)!,
      workoutExerciseCompleted:
          Color.lerp(
            workoutExerciseCompleted,
            other.workoutExerciseCompleted,
            t,
          )!,
      workoutSetCompleted:
          Color.lerp(workoutSetCompleted, other.workoutSetCompleted, t)!,
      workoutAddChangeSet:
          Color.lerp(workoutAddChangeSet, other.workoutAddChangeSet, t)!,
      onPositive: Color.lerp(onPositive, other.onPositive, t)!,
      swapCancel: Color.lerp(swapCancel, other.swapCancel, t)!,
      swapConfirm: Color.lerp(swapConfirm, other.swapConfirm, t)!,
      onSwapConfirm: Color.lerp(onSwapConfirm, other.onSwapConfirm, t)!,
      swapMatch: Color.lerp(swapMatch, other.swapMatch, t)!,
      trainProfileAvatar:
          Color.lerp(trainProfileAvatar, other.trainProfileAvatar, t)!,
      onTrainProfileAvatar:
          Color.lerp(onTrainProfileAvatar, other.onTrainProfileAvatar, t)!,
      trainOptimizedAction:
          Color.lerp(trainOptimizedAction, other.trainOptimizedAction, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      databaseHealthy: Color.lerp(databaseHealthy, other.databaseHealthy, t)!,
      databaseWarning: Color.lerp(databaseWarning, other.databaseWarning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      onNegative: Color.lerp(onNegative, other.onNegative, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      strongContent: Color.lerp(strongContent, other.strongContent, t)!,
      mutedContent: Color.lerp(mutedContent, other.mutedContent, t)!,
      measurementContainer:
          Color.lerp(measurementContainer, other.measurementContainer, t)!,
      onMeasurementContainer:
          Color.lerp(onMeasurementContainer, other.onMeasurementContainer, t)!,
      nutritionContainer:
          Color.lerp(nutritionContainer, other.nutritionContainer, t)!,
      onNutritionContainer:
          Color.lerp(onNutritionContainer, other.onNutritionContainer, t)!,
      workoutContainer:
          Color.lerp(workoutContainer, other.workoutContainer, t)!,
      onWorkoutContainer:
          Color.lerp(onWorkoutContainer, other.onWorkoutContainer, t)!,
      primaryAction: Color.lerp(primaryAction, other.primaryAction, t)!,
      onPrimaryAction: Color.lerp(onPrimaryAction, other.onPrimaryAction, t)!,
      automaticPlanBadge:
          Color.lerp(automaticPlanBadge, other.automaticPlanBadge, t)!,
      onAutomaticPlanBadge:
          Color.lerp(onAutomaticPlanBadge, other.onAutomaticPlanBadge, t)!,
      workoutAction: Color.lerp(workoutAction, other.workoutAction, t)!,
      onWorkoutAction: Color.lerp(onWorkoutAction, other.onWorkoutAction, t)!,
      startWorkoutAction:
          Color.lerp(startWorkoutAction, other.startWorkoutAction, t)!,
      onStartWorkoutAction:
          Color.lerp(onStartWorkoutAction, other.onStartWorkoutAction, t)!,
      completionAccent:
          Color.lerp(completionAccent, other.completionAccent, t)!,
      drawerHeaderForeground:
          Color.lerp(drawerHeaderForeground, other.drawerHeaderForeground, t)!,
      ongoingSessionAction:
          Color.lerp(ongoingSessionAction, other.ongoingSessionAction, t)!,
      ongoingSessionExit:
          Color.lerp(ongoingSessionExit, other.ongoingSessionExit, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      disabledContent: Color.lerp(disabledContent, other.disabledContent, t)!,
      disabledContainer:
          Color.lerp(disabledContainer, other.disabledContainer, t)!,
    );
  }
}
