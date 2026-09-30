import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/theme_extensions.dart';
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
    final scheme = theme.colorScheme;
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
          final minimumWidth = _minimumDestinationWidth;
          final visibleItemCount = math.min(
            widget.items.length,
            math.max(
              1,
              (viewportWidth / _preferredVisibleDestinationWidth).floor(),
            ),
          );
          final availableWidthPerItem = viewportWidth / visibleItemCount;
          final widestLabel = widget.items.fold<double>(0, (widest, item) {
            final label = item.label ?? item.tooltip ?? '';
            final labelWidth = math.max(
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
            return math.max(widest, labelWidth);
          });
          final preferredLabelWidth = (widestLabel + 16)
              .clamp(minimumWidth, 192.0)
              .toDouble();
          final destinationWidth = math
              .max(
                math.max(minimumWidth, availableWidthPerItem),
                preferredLabelWidth,
              )
              .toDouble();
          final contentWidth = destinationWidth * widget.items.length;
          final hasOverflow = contentWidth > viewportWidth;
          final labelHeight = widget.items.fold<double>(
            0,
            (tallest, item) => math.max(
              tallest,
              _labelHeight(
                item.label ?? item.tooltip ?? '',
                labelStyle,
                destinationWidth,
                textScaler,
                textDirection,
                locale,
              ),
            ),
          );
          final barHeight = math
              .max(_minimumBarHeight, 4 + 32 + labelHeight + 4)
              .toDouble();
          final destinations = _buildDestinations(
            context,
            destinationWidth: destinationWidth,
            contentWidth: contentWidth,
            barHeight: barHeight,
            selectedIconColor: scheme.onSecondaryContainer,
            selectedLabelColor: scheme.onSurface,
            unselectedColor: scheme.onSurfaceVariant,
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

          return Material(
            color: scheme.surfaceContainerLow,
            child: SizedBox(height: barHeight, child: navigationContent),
          );
        },
      ),
    );
  }

  Widget _buildDestinations(
    BuildContext context, {
    required double destinationWidth,
    required double contentWidth,
    required double barHeight,
    required Color selectedIconColor,
    required Color selectedLabelColor,
    required Color unselectedColor,
    required TextStyle labelStyle,
  }) {
    final theme = Theme.of(context);
    final shapes = context.shapeTokens;
    final topologyKey = _navigationTopology(widget.items);
    final placeholders = Row(
      children: [
        for (var index = 0; index < widget.items.length; index++)
          SizedBox(width: destinationWidth, height: 32),
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
              color: theme.colorScheme.secondaryContainer,
              borderRadius: shapes.trainTabButton,
              topologyKey: topologyKey,
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
                  destinationWidth: destinationWidth,
                  barHeight: barHeight,
                  selectedIconColor: selectedIconColor,
                  selectedLabelColor: selectedLabelColor,
                  unselectedColor: unselectedColor,
                  labelStyle: labelStyle,
                  cornerRadius: shapes.trainTabButton,
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
    required double barHeight,
    required Color selectedIconColor,
    required Color selectedLabelColor,
    required Color unselectedColor,
    required TextStyle labelStyle,
    required BorderRadius cornerRadius,
  }) {
    final item = widget.items[index];
    final selected = index == _selectedIndex;
    final iconColor = selected ? selectedIconColor : unselectedColor;
    final labelColor = selected ? selectedLabelColor : unselectedColor;
    final label = item.label ?? item.tooltip ?? '';
    final icon = selected ? item.activeIcon : null;

    return SizedBox(
      width: destinationWidth,
      height: barHeight,
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
            child: SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 32,
                      child: Center(
                        child: IconTheme.merge(
                          data: IconThemeData(color: iconColor, size: 24),
                          child: icon ?? item.icon,
                        ),
                      ),
                    ),
                    if (label.isNotEmpty)
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: labelStyle.copyWith(
                          color: labelColor,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
