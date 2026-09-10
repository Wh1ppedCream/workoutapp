import 'package:flutter/material.dart';

/// Theme roles for progression-flow controls and diagrams.
@immutable
class AppFlowTokens extends ThemeExtension<AppFlowTokens> {
  const AppFlowTokens({
    required this.canvas,
    required this.nodeBackground,
    required this.nodeBorder,
    required this.nodeText,
    required this.success,
    required this.failure,
    required this.action,
    required this.onAction,
    required this.loopback,
    required this.diagramSuccess,
    required this.diagramLoopback,
    required this.profileScope,
    required this.planScope,
    required this.addSetAction,
  });

  /// Builds a complete fallback from the active Material color scheme.
  factory AppFlowTokens.fromColorScheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return AppFlowTokens(
      canvas: scheme.surface,
      nodeBackground: scheme.surfaceContainerHighest,
      nodeBorder: scheme.primary,
      nodeText: scheme.onSurface,
      success: isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
      failure: isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828),
      action: scheme.primary,
      onAction: scheme.onPrimary,
      loopback: scheme.onSurfaceVariant,
      diagramSuccess: scheme.primary,
      diagramLoopback: scheme.onSurfaceVariant.withValues(alpha: 0.3),
      profileScope: scheme.tertiary,
      planScope: scheme.secondary,
      addSetAction: scheme.tertiary,
    );
  }

  /// Values that preserve the reviewed flow UI for the Classic family.
  factory AppFlowTokens.classic(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppFlowTokens(
      canvas: isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
      nodeBackground:
          isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
      nodeBorder:
          isDark
              ? const Color.fromARGB(255, 34, 55, 245)
              : const Color.fromARGB(255, 93, 188, 226),
      nodeText: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF333333),
      success: isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
      failure: isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828),
      action: Colors.deepPurple,
      onAction: Colors.white,
      loopback: const Color(0xFF757575),
      diagramSuccess: Colors.green,
      diagramLoopback: Colors.yellow.withValues(alpha: 0.3),
      profileScope: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF00796B),
      planScope: isDark ? const Color(0xFFFFB74D) : const Color(0xFFEF6C00),
      addSetAction: const Color(0xFF26A69A),
    );
  }

  final Color canvas;
  final Color nodeBackground;
  final Color nodeBorder;
  final Color nodeText;
  final Color success;
  final Color failure;
  final Color action;
  final Color onAction;
  final Color loopback;
  final Color diagramSuccess;
  final Color diagramLoopback;
  final Color profileScope;
  final Color planScope;
  final Color addSetAction;

  @override
  AppFlowTokens copyWith({
    Color? canvas,
    Color? nodeBackground,
    Color? nodeBorder,
    Color? nodeText,
    Color? success,
    Color? failure,
    Color? action,
    Color? onAction,
    Color? loopback,
    Color? diagramSuccess,
    Color? diagramLoopback,
    Color? profileScope,
    Color? planScope,
    Color? addSetAction,
  }) {
    return AppFlowTokens(
      canvas: canvas ?? this.canvas,
      nodeBackground: nodeBackground ?? this.nodeBackground,
      nodeBorder: nodeBorder ?? this.nodeBorder,
      nodeText: nodeText ?? this.nodeText,
      success: success ?? this.success,
      failure: failure ?? this.failure,
      action: action ?? this.action,
      onAction: onAction ?? this.onAction,
      loopback: loopback ?? this.loopback,
      diagramSuccess: diagramSuccess ?? this.diagramSuccess,
      diagramLoopback: diagramLoopback ?? this.diagramLoopback,
      profileScope: profileScope ?? this.profileScope,
      planScope: planScope ?? this.planScope,
      addSetAction: addSetAction ?? this.addSetAction,
    );
  }

  @override
  AppFlowTokens lerp(covariant ThemeExtension<AppFlowTokens>? other, double t) {
    if (other is! AppFlowTokens) return this;
    return AppFlowTokens(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      nodeBackground: Color.lerp(nodeBackground, other.nodeBackground, t)!,
      nodeBorder: Color.lerp(nodeBorder, other.nodeBorder, t)!,
      nodeText: Color.lerp(nodeText, other.nodeText, t)!,
      success: Color.lerp(success, other.success, t)!,
      failure: Color.lerp(failure, other.failure, t)!,
      action: Color.lerp(action, other.action, t)!,
      onAction: Color.lerp(onAction, other.onAction, t)!,
      loopback: Color.lerp(loopback, other.loopback, t)!,
      diagramSuccess: Color.lerp(diagramSuccess, other.diagramSuccess, t)!,
      diagramLoopback: Color.lerp(diagramLoopback, other.diagramLoopback, t)!,
      profileScope: Color.lerp(profileScope, other.profileScope, t)!,
      planScope: Color.lerp(planScope, other.planScope, t)!,
      addSetAction: Color.lerp(addSetAction, other.addSetAction, t)!,
    );
  }
}
