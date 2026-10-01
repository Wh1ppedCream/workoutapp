import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/theme_extensions.dart';
import '../theme/tokens/app_expressive_train_tokens.dart';
import '../theme/widgets/tonos_expressive_motion.dart';

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
  static double preferredHeight(
    BuildContext context, {
    String? overviewLabel,
    String? plansLabel,
  }) {
    if (context.usesClassicPresentation) return 44;

    final theme = Theme.of(context);
    if (context.usesExpressivePresentation) {
      final textStyle = theme.textTheme.labelLarge;
      final textScaler = MediaQuery.textScalerOf(context);
      final labels = <String>[
        overviewLabel ?? 'Overview',
        plansLabel ?? 'Plans',
      ];
      final availableWidth = (MediaQuery.sizeOf(context).width - 32)
          .clamp(0.0, 320.0)
          .toDouble();
      final labelWidth = ((availableWidth - 8) / 2)
          .clamp(1.0, 156.0)
          .toDouble();
      final textHeight = labels.fold<double>(
        0,
        (tallest, label) => math.max(
          tallest,
          _measureLabelHeight(
            context,
            label,
            textStyle ?? DefaultTextStyle.of(context).style,
            textScaler,
            labelWidth,
          ),
        ),
      );
      return math.max(56.0, textHeight + 8).toDouble();
    }
    if (!theme.usesNeoPresentation) {
      final textScale = MediaQuery.textScalerOf(context).scale(1);
      final fontSize = theme.textTheme.labelLarge?.fontSize ?? 14;
      final lineHeight = theme.textTheme.labelLarge?.height ?? 1.43;
      final lineCount = textScale > 1.15 ? 2 : 1;
      final contentHeight = fontSize * lineHeight * textScale * lineCount + 16;
      return contentHeight.clamp(48.0, 88.0).toDouble();
    }

    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final fontSize = theme.textTheme.bodyMedium?.fontSize ?? 14;
    final lineHeight = theme.textTheme.bodyMedium?.height ?? 1.4;
    final lineCount = textScale > 1.15 ? 2 : 1;
    final contentHeight = fontSize * lineHeight * textScale * lineCount + 20;
    return contentHeight.clamp(48.0, 88.0).toDouble();
  }

  static double toolbarHeight(
    BuildContext context, {
    String? overviewLabel,
    String? plansLabel,
  }) {
    return context.usesNeoPresentation || context.usesExpressivePresentation
        ? preferredHeight(
                context,
                overviewLabel: overviewLabel,
                plansLabel: plansLabel,
              ) +
              8
        : kToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    if (context.usesExpressivePresentation) {
      return _buildExpressive(context);
    }
    if (!context.usesNeoPresentation && !context.usesClassicPresentation) {
      return _buildMaterialFallback(context);
    }

    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final effects = context.effectTokens;
    final usesInkRecipe = context.usesNeoPresentation;
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
        color: usesInkRecipe
            ? context.cs.secondaryContainer
            : surfaces.panelRaised.withValues(
                alpha: surfaces.trainTabSurfaceOpacity,
              ),
        borderRadius: tabRadius,
        border: usesInkRecipe
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

  Widget _buildExpressive(BuildContext context) {
    final tokens = Theme.of(context).extension<AppExpressiveTrainTokens>()!;
    final direction = Directionality.of(context);
    final trackShape = _mirrorBorderRadius(
      ExpressiveTrainShapes.selector,
      direction,
    );
    final selectedShape = _mirrorBorderRadius(
      ExpressiveTrainShapes.selectedSelector,
      direction,
    );
    final travelShape = _mirrorBorderRadius(
      ExpressiveTrainShapes.selector,
      direction,
    );
    final selected = selectedIndex.clamp(0, 1).toInt();
    return Container(
      key: const ValueKey('tonos-train-tabs-frame'),
      height: preferredHeight(
        context,
        overviewLabel: overviewLabel,
        plansLabel: plansLabel,
      ),
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tokens.selectorTrack,
        borderRadius: trackShape,
      ),
      child: TonosExpressiveSelectionIndicator(
        selectedIndex: selected,
        itemCount: 2,
        color: tokens.selectorActive,
        borderRadius: selectedShape,
        travelBorderRadius: travelShape,
        travelWidthFraction: 0.78,
        selectedWidthFraction: 0.94,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TonosTrainTabButton(
              key: overviewKey,
              label: overviewLabel,
              selected: selected == 0,
              onTap: () => onChanged(0),
            ),
            _TonosTrainTabButton(
              key: plansKey,
              label: plansLabel,
              selected: selected == 1,
              onTap: () => onChanged(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialFallback(BuildContext context) {
    final selected = selectedIndex.clamp(0, 1).toInt();
    return Container(
      key: const ValueKey('tonos-train-tabs-frame'),
      height: preferredHeight(context),
      constraints: const BoxConstraints(maxWidth: 320),
      alignment: Alignment.center,
      child: SegmentedButton<int>(
        segments: [
          ButtonSegment<int>(
            value: 0,
            label: KeyedSubtree(
              key: overviewKey,
              child: Text(
                overviewLabel,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ButtonSegment<int>(
            value: 1,
            label: KeyedSubtree(
              key: plansKey,
              child: Text(
                plansLabel,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        selected: {selected},
        showSelectedIcon: false,
        onSelectionChanged: (selection) => onChanged(selection.single),
      ),
    );
  }
}

double _measureLabelHeight(
  BuildContext context,
  String label,
  TextStyle style,
  TextScaler textScaler,
  double maxWidth,
) {
  double measure(TextStyle measuredStyle) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: measuredStyle),
      textAlign: TextAlign.center,
      textDirection: Directionality.of(context),
      locale: Localizations.maybeLocaleOf(context),
      textScaler: textScaler,
    );
    try {
      painter.layout(maxWidth: maxWidth);
      return painter.height;
    } finally {
      painter.dispose();
    }
  }

  return math.max(
    measure(style.copyWith(fontWeight: FontWeight.w500)),
    measure(style.copyWith(fontWeight: FontWeight.w600)),
  );
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
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressiveRecipe = context.usesExpressivePresentation;
    final textTheme = Theme.of(context).textTheme;
    final expressiveTokens = usesExpressiveRecipe
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()
        : null;
    final buttonRadius = usesInkRecipe || usesExpressiveRecipe
        ? shapes.trainTabButton
        : shapes.pill;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: buttonRadius,
      side: usesInkRecipe
          ? BorderSide(
              color: context.surfaceTokens.subtleOutline,
              width: shapes.outlineWidth,
            )
          : BorderSide.none,
    );
    Widget button = Material(
      color: usesExpressiveRecipe
          ? Colors.transparent
          : selected
          ? colorScheme.primaryContainer
          : usesInkRecipe
          ? colorScheme.secondaryContainer
          : Colors.transparent,
      shape: buttonShape,
      clipBehavior: usesInkRecipe || usesExpressiveRecipe
          ? Clip.antiAlias
          : Clip.none,
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
                style:
                    (usesExpressiveRecipe
                            ? textTheme.labelLarge
                            : textTheme.bodyMedium)
                        ?.copyWith(
                          fontWeight: usesExpressiveRecipe
                              ? selected
                                    ? FontWeight.w600
                                    : FontWeight.w500
                              : FontWeight.w700,
                          color: selected
                              ? usesExpressiveRecipe
                                    ? expressiveTokens!.selectorActiveForeground
                                    : colorScheme.onPrimaryContainer
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
    if (usesExpressiveRecipe) {
      button = TonosExpressivePressResponse(
        enabled: true,
        borderRadius: buttonRadius,
        pressedBorderRadius: ExpressiveTrainShapes.selectedSelector,
        pressedScale: TonosExpressiveMotionTiers.supportingScale,
        pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
        child: button,
      );
    }

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

BorderRadius _mirrorBorderRadius(BorderRadius radius, TextDirection direction) {
  if (direction != TextDirection.rtl) return radius;
  return BorderRadius.only(
    topLeft: radius.topRight,
    topRight: radius.topLeft,
    bottomLeft: radius.bottomRight,
    bottomRight: radius.bottomLeft,
  );
}
