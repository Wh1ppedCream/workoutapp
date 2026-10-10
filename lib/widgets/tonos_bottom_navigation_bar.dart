import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/theme_extensions.dart';
import '../theme/tokens/app_expressive_train_tokens.dart';
import '../theme/widgets/tonos_expressive_motion.dart';

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
    final materialNavigation = BottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
    );

    if (context.usesNeoPresentation) {
      return _withCurrentFamilyLocaleScaling(
        context,
        _NeoBottomNavigationBar(
          items: items,
          currentIndex: currentIndex,
          onTap: onTap,
        ),
      );
    }

    if (context.usesExpressivePresentation) {
      return _ExpressiveBottomNavigationBar(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
      );
    }

    if (context.usesClassicPresentation) {
      return _withCurrentFamilyLocaleScaling(context, materialNavigation);
    }

    // An identity-less ThemeData keeps the ordinary Material component.
    return materialNavigation;
  }
}

class _ExpressiveBottomNavigationBar extends StatefulWidget {
  const _ExpressiveBottomNavigationBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<_ExpressiveBottomNavigationBar> createState() =>
      _ExpressiveBottomNavigationBarState();
}

class _ExpressiveBottomNavigationBarState
    extends State<_ExpressiveBottomNavigationBar> {
  static const double _minimumBarHeight = 56;
  static const double _minimumDestinationWidth = 48;
  static const double _preferredVisibleDestinationWidth = 64;

  final ScrollController _scrollController = ScrollController();
  ({double width, TextScaler scaler, TextDirection direction, Locale? locale})?
  _layoutSignature;
  late List<GlobalKey> _destinationKeys;

  int get _selectedIndex =>
      widget.currentIndex.clamp(0, widget.items.length - 1).toInt();

  @override
  void initState() {
    super.initState();
    _destinationKeys = List<GlobalKey>.generate(
      widget.items.length,
      (index) => GlobalKey(debugLabel: 'tonos-expressive-nav-$index'),
    );
    _scheduleSelectedDestinationVisibility();
  }

  @override
  void didUpdateWidget(covariant _ExpressiveBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _destinationKeys = List<GlobalKey>.generate(
        widget.items.length,
        (index) => GlobalKey(debugLabel: 'tonos-expressive-nav-$index'),
      );
    }
    if (oldWidget.currentIndex != widget.currentIndex ||
        _navigationTopology(oldWidget.items) !=
            _navigationTopology(widget.items)) {
      _scheduleSelectedDestinationVisibility();
    }
  }

  void _scheduleSelectedDestinationVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.items.isEmpty) return;
      final selectedContext = _destinationKeys[_selectedIndex].currentContext;
      if (selectedContext == null) return;
      Scrollable.ensureVisible(
        selectedContext,
        alignment: 0.5,
        duration: Duration.zero,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final tokens = theme.extension<AppExpressiveTrainTokens>()!;
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);
    final locale = Localizations.maybeLocaleOf(context);
    final labelStyle =
        theme.textTheme.labelSmall ?? DefaultTextStyle.of(context).style;

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final layoutSignature = (
            width: viewportWidth,
            scaler: textScaler,
            direction: textDirection,
            locale: locale,
          );
          if (_layoutSignature != layoutSignature) {
            _layoutSignature = layoutSignature;
            _scheduleSelectedDestinationVisibility();
          }
          final compactFiveDestinations =
              widget.items.length <= 5 && viewportWidth <= 360;
          // At large text scales, a vertical destination list gives each full
          // label the available width while keeping every item tappable.
          final compactStacked =
              compactFiveDestinations &&
              widget.items.length > 3 &&
              textScaler.scale(1) > 1.15;
          final compactColumnCount = compactStacked ? 1 : widget.items.length;
          final minimumWidth = _minimumDestinationWidth;
          final itemLabelWidths = widget.items
              .map((item) {
                final label = item.label ?? item.tooltip ?? '';
                return math.max(
                  _labelIntrinsicWidth(
                    label,
                    labelStyle.copyWith(fontWeight: FontWeight.w500),
                    textScaler,
                    textDirection,
                    locale,
                  ),
                  _labelIntrinsicWidth(
                    label,
                    labelStyle.copyWith(fontWeight: FontWeight.w600),
                    textScaler,
                    textDirection,
                    locale,
                  ),
                );
              })
              .toList(growable: false);
          final visibleItemCount = math.min(
            widget.items.length,
            compactFiveDestinations
                ? widget.items.length
                : math.max(
                    1,
                    (viewportWidth / _preferredVisibleDestinationWidth).floor(),
                  ),
          );
          final availableWidthPerItem =
              viewportWidth /
              (compactStacked ? compactColumnCount : visibleItemCount);
          final widestLabel = itemLabelWidths.fold<double>(0, math.max);
          final preferredLabelWidth = (widestLabel + 16)
              .clamp(minimumWidth, 192.0)
              .toDouble();
          final uniformDestinationWidth = compactFiveDestinations
              ? availableWidthPerItem
              : math
                    .max(
                      math.max(minimumWidth, availableWidthPerItem),
                      preferredLabelWidth,
                    )
                    .toDouble();
          final destinationWidths = List<double>.filled(
            widget.items.length,
            uniformDestinationWidth,
          );
          final contentWidth = compactStacked
              ? viewportWidth
              : uniformDestinationWidth * widget.items.length;
          final hasOverflow = contentWidth > viewportWidth;
          final labelHeight = widget.items.fold<double>(
            0,
            (tallest, item) => math.max(
              tallest,
              _labelHeight(
                item.label ?? item.tooltip ?? '',
                labelStyle,
                (destinationWidths[widget.items.indexOf(item)] -
                        (compactStacked ? 68 : 0))
                    .clamp(0.0, double.infinity)
                    .toDouble(),
                textScaler,
                textDirection,
                locale,
              ),
            ),
          );
          final rowHeight = math
              .max(
                _minimumBarHeight,
                compactStacked ? labelHeight + 8 : 4 + 32 + labelHeight + 4,
              )
              .toDouble();
          final rowCount =
              (widget.items.length + compactColumnCount - 1) ~/
              compactColumnCount;
          final barHeight = math
              .max(
                _minimumBarHeight,
                compactStacked
                    ? rowHeight * rowCount + 4 * (rowCount - 1)
                    : rowHeight,
              )
              .toDouble();
          final destinations = _buildDestinations(
            context,
            destinationWidths: destinationWidths,
            contentWidth: contentWidth,
            barHeight: barHeight,
            compactStacked: compactStacked,
            compactColumnCount: compactColumnCount,
            rowHeight: rowHeight,
            selectedIconColor: tokens.navigationSelectedForeground,
            // Horizontal selection sits behind the icon only, while the
            // compact stacked selection fills the full icon-and-label row.
            // Use the matching foreground role for each selected surface.
            selectedLabelColor: compactStacked
                ? tokens.navigationSelectedForeground
                : tokens.navigationLabel,
            unselectedColor: tokens.navigationLabel,
            labelStyle: labelStyle,
          );

          final navigationContent = hasOverflow
              ? Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 2,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: destinations,
                  ),
                )
              : destinations;

          return DecoratedBox(
            key: const ValueKey('tonos-expressive-navigation-frame'),
            decoration: BoxDecoration(
              color: tokens.navigationSurface,
              borderRadius: _mirrorBorderRadius(
                ExpressiveTrainShapes.navigation,
                textDirection,
              ),
            ),
            child: SizedBox(height: barHeight, child: navigationContent),
          );
        },
      ),
    );
  }

  Widget _buildDestinations(
    BuildContext context, {
    required List<double> destinationWidths,
    required double contentWidth,
    required double barHeight,
    required bool compactStacked,
    required int compactColumnCount,
    required double rowHeight,
    required Color selectedIconColor,
    required Color selectedLabelColor,
    required Color unselectedColor,
    required TextStyle labelStyle,
  }) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppExpressiveTrainTokens>()!;
    final direction = Directionality.of(context);
    final topologyKey = _navigationTopology(widget.items);
    if (compactStacked) {
      final rows = <Widget>[];
      for (var index = 0; index < widget.items.length; index++) {
        rows.add(
          SizedBox(
            height: rowHeight,
            child: _buildDestination(
              context,
              index,
              destinationWidth: destinationWidths[index],
              destinationHeight: rowHeight,
              inlineSelection: true,
              horizontalLayout: true,
              selectedIconColor: selectedIconColor,
              selectedLabelColor: selectedLabelColor,
              unselectedColor: unselectedColor,
              labelStyle: labelStyle,
              cornerRadius: _mirrorBorderRadius(
                ExpressiveTrainShapes.selectedSelector,
                direction,
              ),
            ),
          ),
        );
        if (index < widget.items.length - 1) {
          rows.add(const SizedBox(height: 4));
        }
      }

      return SizedBox(
        width: contentWidth,
        height: barHeight,
        child: Column(mainAxisSize: MainAxisSize.min, children: rows),
      );
    }

    final placeholders = Row(
      children: [
        for (var index = 0; index < widget.items.length; index++)
          SizedBox(width: destinationWidths[index], height: 32),
      ],
    );

    return SizedBox(
      width: contentWidth,
      height: barHeight,
      child: Stack(
        children: [
          Positioned(
            top: 4,
            left: 0,
            right: 0,
            height: 32,
            child: TonosExpressiveSelectionIndicator(
              selectedIndex: _selectedIndex,
              itemCount: widget.items.length,
              color: tokens.navigationSelected,
              borderRadius: _mirrorBorderRadius(
                ExpressiveTrainShapes.selectedSelector,
                direction,
              ),
              topologyKey: topologyKey,
              travelBorderRadius: _mirrorBorderRadius(
                ExpressiveTrainShapes.selector,
                direction,
              ),
              travelWidthFraction: 0.78,
              selectedWidthFraction: 0.94,
              child: placeholders,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < widget.items.length; index++)
                _buildDestination(
                  context,
                  index,
                  destinationWidth: destinationWidths[index],
                  destinationHeight: barHeight,
                  inlineSelection: false,
                  horizontalLayout: false,
                  selectedIconColor: selectedIconColor,
                  selectedLabelColor: selectedLabelColor,
                  unselectedColor: unselectedColor,
                  labelStyle: labelStyle,
                  cornerRadius: _mirrorBorderRadius(
                    ExpressiveTrainShapes.selectedSelector,
                    direction,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDestination(
    BuildContext context,
    int index, {
    required double destinationWidth,
    required double destinationHeight,
    required bool inlineSelection,
    required bool horizontalLayout,
    required Color selectedIconColor,
    required Color selectedLabelColor,
    required Color unselectedColor,
    required TextStyle labelStyle,
    required BorderRadius cornerRadius,
  }) {
    final item = widget.items[index];
    final selected = index == _selectedIndex;
    final tokens = Theme.of(context).extension<AppExpressiveTrainTokens>()!;
    final iconColor = selected ? selectedIconColor : unselectedColor;
    final labelColor = selected ? selectedLabelColor : unselectedColor;
    final label = item.label ?? item.tooltip ?? '';
    final icon = selected ? item.activeIcon : null;
    final iconWidget = IconTheme.merge(
      data: IconThemeData(color: iconColor, size: selected ? 26 : 24),
      child: icon ?? item.icon,
    );
    final labelWidget = Text(
      label,
      textAlign: horizontalLayout ? TextAlign.start : TextAlign.center,
      softWrap: true,
      style: labelStyle.copyWith(
        color: labelColor,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
    final content = horizontalLayout
        ? Row(
            children: [
              SizedBox(width: 40, child: Center(child: iconWidget)),
              const SizedBox(width: 12),
              Expanded(child: labelWidget),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 32, child: Center(child: iconWidget)),
              if (label.isNotEmpty) labelWidget,
            ],
          );
    Widget destinationContent = SizedBox.expand(
      child: Padding(
        padding: horizontalLayout
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
            : const EdgeInsets.symmetric(vertical: 2),
        child: content,
      ),
    );
    if (context.usesExpressivePresentation) {
      destinationContent = TonosExpressivePressResponse(
        enabled: true,
        borderRadius: cornerRadius,
        pressedBorderRadius: ExpressiveTrainShapes.selectedSelector,
        pressedScale: TonosExpressiveMotionTiers.supportingScale,
        pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
        child: destinationContent,
      );
    }
    if (inlineSelection) {
      destinationContent = AnimatedContainer(
        key: ValueKey('tonos-expressive-navigation-inline-selection-$index'),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? tokens.navigationSelected : Colors.transparent,
          borderRadius: cornerRadius,
        ),
        child: destinationContent,
      );
    }

    return SizedBox(
      width: destinationWidth,
      height: destinationHeight,
      child: Semantics(
        container: true,
        excludeSemantics: true,
        button: true,
        selected: selected,
        label: label,
        onTap: () => widget.onTap(index),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: _destinationKeys[index],
            excludeFromSemantics: true,
            customBorder: RoundedRectangleBorder(borderRadius: cornerRadius),
            onTap: () => widget.onTap(index),
            child: destinationContent,
          ),
        ),
      ),
    );
  }
}

double _labelIntrinsicWidth(
  String label,
  TextStyle style,
  TextScaler textScaler,
  TextDirection textDirection,
  Locale? locale,
) {
  if (label.isEmpty) return 0;
  final painter = TextPainter(
    text: TextSpan(text: label, style: style),
    textDirection: textDirection,
    locale: locale,
    textScaler: textScaler,
    maxLines: 1,
  );
  try {
    painter.layout();
    return painter.maxIntrinsicWidth;
  } finally {
    painter.dispose();
  }
}

double _labelHeight(
  String label,
  TextStyle style,
  double maxWidth,
  TextScaler textScaler,
  TextDirection textDirection,
  Locale? locale,
) {
  if (label.isEmpty) return 0;
  double measure(TextStyle measuredStyle) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: measuredStyle),
      textAlign: TextAlign.center,
      textDirection: textDirection,
      locale: locale,
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

String _navigationTopology(List<BottomNavigationBarItem> items) {
  return items
      .map(
        (item) =>
            '${item.label ?? ''}\u001f${item.tooltip ?? ''}\u001f'
            '${item.icon.runtimeType}\u001f${item.activeIcon.runtimeType}',
      )
      .join('\u001e');
}

Widget _withCurrentFamilyLocaleScaling(BuildContext context, Widget child) {
  return Localizations.localeOf(context).languageCode == 'en'
      ? child
      : MediaQuery.withNoTextScaling(child: child);
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
      padding: _hasVisibleShadow(shadow)
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

BorderRadius _mirrorBorderRadius(BorderRadius radius, TextDirection direction) {
  if (direction != TextDirection.rtl) return radius;
  return BorderRadius.only(
    topLeft: radius.topRight,
    topRight: radius.topLeft,
    bottomLeft: radius.bottomRight,
    bottomRight: radius.bottomLeft,
  );
}
