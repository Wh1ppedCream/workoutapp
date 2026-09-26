import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

/// Shared Overview/Plans selector used by the Train route and its preview.
///
/// Callers own the selected index and labels. This widget owns the family-aware
/// outline, selected surface, marker, and hard-shadow recipe.
class TonosTrainTabs extends StatelessWidget {
  const TonosTrainTabs({
    super.key,
    required this.overviewLabel,
    required this.plansLabel,
    required this.selectedIndex,
    required this.onChanged,
    this.overviewKey,
    this.plansKey,
  });

  final String overviewLabel;
  final String plansLabel;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Key? overviewKey;
  final Key? plansKey;

  /// Keeps the ordinary selector compact while allowing large text to reflow.
  /// The extra AppBar room is supplied separately so the Neo hard shadow is
  /// not clipped by the toolbar's title bounds.
  static double preferredHeight(BuildContext context) {
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    if (!usesInkRecipe) return 44;

    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final fontSize = theme.textTheme.bodyMedium?.fontSize ?? 14;
    final lineHeight = theme.textTheme.bodyMedium?.height ?? 1.4;
    final lineCount = textScale > 1.15 ? 2 : 1;
    final contentHeight = fontSize * lineHeight * textScale * lineCount + 20;
    return contentHeight.clamp(48.0, 88.0).toDouble();
  }

  static double toolbarHeight(BuildContext context) {
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    return usesInkRecipe ? preferredHeight(context) + 8 : kToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final effects = context.effectTokens;
    final decorations = context.surfaceDecorationTokens;
    final usesInkRecipe = decorations.panel.outlined;
    final tabRadius = usesInkRecipe ? shapes.trainTab : shapes.pill;

    final shadow = BoxShadow(
      color: effects.cardShadow,
      blurRadius: effects.cardShadowBlur,
      // The compact selector needs a lighter footprint than a raised panel.
      offset: effects.cardShadowOffset,
    );

    return Container(
      key: const ValueKey('tonos-train-tabs-frame'),
      height: preferredHeight(context),
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:
            usesInkRecipe
                ? context.cs.secondaryContainer
                : surfaces.panelRaised.withValues(
                  alpha: surfaces.trainTabSurfaceOpacity,
                ),
        borderRadius: tabRadius,
        border:
            usesInkRecipe
                ? Border.all(
                  color: surfaces.subtleOutline,
                  // The selector is a structural frame, not a focus ring.
                  // Match the 2px outlines used by the panels below it.
                  width: shapes.outlineWidth,
                )
                : null,
        boxShadow: usesInkRecipe && _hasVisibleShadow(shadow) ? [shadow] : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TonosTrainTabButton(
            key: overviewKey,
            label: overviewLabel,
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          if (usesInkRecipe) const SizedBox(width: 4),
          _TonosTrainTabButton(
            key: plansKey,
            label: plansLabel,
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TonosTrainTabButton extends StatelessWidget {
  const _TonosTrainTabButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.cs;
    final shapes = context.shapeTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final textTheme = Theme.of(context).textTheme;
    final buttonRadius = usesInkRecipe ? shapes.trainTabButton : shapes.pill;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: buttonRadius,
      side:
          usesInkRecipe
              ? BorderSide(
                color: context.surfaceTokens.subtleOutline,
                width: shapes.outlineWidth,
              )
              : BorderSide.none,
    );
    final button = Material(
      color:
          selected
              ? colorScheme.primaryContainer
              : usesInkRecipe
              ? colorScheme.secondaryContainer
              : Colors.transparent,
      shape: buttonShape,
      clipBehavior: usesInkRecipe ? Clip.antiAlias : Clip.none,
      child: InkWell(
        customBorder: buttonShape,
        excludeFromSemantics: true,
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Text(
                label,
                maxLines: usesInkRecipe ? 2 : null,
                textAlign: TextAlign.center,
                overflow: usesInkRecipe ? TextOverflow.ellipsis : null,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      selected
                          ? colorScheme.onPrimaryContainer
                          : usesInkRecipe
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (usesInkRecipe && selected)
              Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  child: ColoredBox(
                    color: context.surfaceTokens.subtleOutline,
                    child: const SizedBox(width: double.infinity, height: 4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Expanded(
      child: Semantics(
        container: true,
        excludeSemantics: true,
        button: true,
        selected: selected,
        label: label,
        onTap: onTap,
        child: button,
      ),
    );
  }
}

bool _hasVisibleShadow(BoxShadow shadow) {
  return shadow.color.a > 0 &&
      (shadow.blurRadius > 0 ||
          shadow.spreadRadius != 0 ||
          shadow.offset != Offset.zero);
}
