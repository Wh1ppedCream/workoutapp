import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import 'app_theme_family.dart';
import 'theme_extensions.dart';

/// Shared presentation for the development-only floating theme controls.
///
/// Classic keeps its existing Material elevation. Neo uses the same hard
/// outline and zero-blur offset shadow as the rest of its controls.
class DebugThemeActionButton extends StatelessWidget {
  const DebugThemeActionButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final iconButton = IconButton(
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      padding: EdgeInsets.zero,
      iconSize: 20,
      color: theme.colorScheme.onSurface,
      icon: Icon(icon, semanticLabel: semanticLabel),
      onPressed: onPressed,
    );

    final Widget control;
    if (!usesInkRecipe) {
      control = Material(
        color: theme.colorScheme.surface,
        shape: const CircleBorder(),
        elevation: 4,
        child: iconButton,
      );
    } else {
      final shapes = context.shapeTokens;
      final effects = context.effectTokens;
      control = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: effects.cardShadow,
              blurRadius: effects.cardShadowBlur,
              offset: effects.cardShadowOffset,
            ),
          ],
        ),
        child: Material(
          color: theme.colorScheme.surface,
          shape: CircleBorder(
            side: BorderSide(
              color: tonosOutlineForSurface(
                context,
                context.cs.surface,
                neutral: true,
              ),
              width: shapes.outlineWidth,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: iconButton,
        ),
      );
    }

    return TextFieldTapRegion(child: control);
  }
}

/// Development-only family switcher used for N4 real-route review.
///
/// This control is only mounted from the debug theme controls. It reads the
/// provider's capability-filtered family list and cycles through it, persisting
/// changes through [ThemeProvider.setFamily]; it never writes preferences
/// directly.
class DebugThemeFamilyControl extends StatelessWidget {
  const DebugThemeFamilyControl({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    final families = provider.availableFamilies;
    if (families.length < 2) return const SizedBox.shrink();

    final nextFamily =
        families[(families.indexOf(provider.family) + 1) % families.length];
    // This control lives in MaterialApp.builder, above the Navigator/Overlay.
    // Use a direct action, so no tooltip or popup needs an Overlay ancestor.
    return DebugThemeActionButton(
      key: const ValueKey('debug-theme-family-control'),
      icon: Icons.palette_outlined,
      semanticLabel:
          'Debug: ${_familyLabel(provider.family)} theme. Switch to ${_familyLabel(nextFamily)}',
      onPressed: () => unawaited(_setFamily(context, nextFamily)),
    );
  }

  Future<void> _setFamily(BuildContext context, AppThemeFamily family) async {
    try {
      await context.read<ThemeProvider>().setFamily(family);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'debug theme family control',
        ),
      );
    }
  }

  String _familyLabel(AppThemeFamily family) => switch (family) {
    AppThemeFamily.classic => 'Classic',
    AppThemeFamily.neoBrutalism => 'Neo-Brutalism',
  };
}
