import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

/// Shared production navigation presentation used by the app and Theme Lab.
///
/// Callers own the tab data and selected-index behavior; this widget owns the
/// Material navigation surface so previews cannot drift into a second recipe.
class TonosBottomNavigationBar extends StatelessWidget {
  const TonosBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  }) : assert(items.length > 0);

  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    if (!usesInkRecipe) {
      return BottomNavigationBar(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
      );
    }

    return _NeoBottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}

/// The Neo rail is intentionally a single navigation surface. The selected
/// fill and underline sit behind the ordinary Material bar so its semantics,
/// focus handling, ripples, and touch targets remain production-owned.
class _NeoBottomNavigationBar extends StatelessWidget {
  const _NeoBottomNavigationBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final effects = context.effectTokens;
    final colorScheme = context.cs;
    final radius = shapes.trainTab;
    final shadow = BoxShadow(
      color: effects.cardShadow,
      blurRadius: effects.cardShadowBlur,
      offset: effects.cardShadowOffset,
    );
    final selectedIndex = currentIndex.clamp(0, items.length - 1).toInt();
    final backgroundColor =
        theme.bottomNavigationBarTheme.backgroundColor ??
        colorScheme.primaryContainer;
    final selectedColor = colorScheme.secondaryContainer;
    final ink = surfaces.subtleOutline;
    final foregroundColor = colorScheme.onSecondaryContainer;

    final navigation = Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: IgnorePointer(
              child: _NeoNavigationSelection(
                itemCount: items.length,
                selectedIndex: selectedIndex,
                selectedColor: selectedColor,
                underlineColor: ink,
              ),
            ),
          ),
        ),
        BottomNavigationBar(
          items: items,
          currentIndex: selectedIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: foregroundColor,
          unselectedItemColor: colorScheme.onPrimaryContainer,
          selectedIconTheme: IconThemeData(color: foregroundColor),
          unselectedIconTheme: IconThemeData(
            color: colorScheme.onPrimaryContainer,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
      ],
    );

    return Padding(
      padding:
          _hasVisibleShadow(shadow)
              ? EdgeInsets.only(
                right: shadow.offset.dx.clamp(0.0, double.infinity).toDouble(),
                bottom: shadow.offset.dy.clamp(0.0, double.infinity).toDouble(),
              )
              : EdgeInsets.zero,
      child: DecoratedBox(
        key: const ValueKey('tonos-bottom-navigation-frame'),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: ink, width: shapes.outlineWidth),
          borderRadius: radius,
          boxShadow: _hasVisibleShadow(shadow) ? [shadow] : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(shapes.outlineWidth),
          child: ClipRRect(
            borderRadius: radius,
            child: SafeArea(top: false, child: navigation),
          ),
        ),
      ),
    );
  }
}

class _NeoNavigationSelection extends StatelessWidget {
  const _NeoNavigationSelection({
    required this.itemCount,
    required this.selectedIndex,
    required this.selectedColor,
    required this.underlineColor,
  });

  final int itemCount;
  final int selectedIndex;
  final Color selectedColor;
  final Color underlineColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < itemCount; index++)
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (index == selectedIndex)
                  ColoredBox(
                    key: const ValueKey(
                      'tonos-bottom-navigation-selected-segment',
                    ),
                    color: selectedColor,
                  ),
                if (index == selectedIndex)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ColoredBox(
                      key: const ValueKey(
                        'tonos-bottom-navigation-selected-underline',
                      ),
                      color: underlineColor,
                      child: const SizedBox(height: 4),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

bool _hasVisibleShadow(BoxShadow shadow) {
  return shadow.color.a > 0 &&
      (shadow.blurRadius > 0 ||
          shadow.spreadRadius != 0 ||
          shadow.offset != Offset.zero);
}
