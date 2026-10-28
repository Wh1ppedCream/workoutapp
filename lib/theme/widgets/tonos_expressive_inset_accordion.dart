import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'tonos_expressive_state_motion.dart';

/// A coordinated inset header and content area. The caller owns the outer
/// surface and content gutters; header/body separation collapses with the body.
class TonosExpressiveInsetAccordion extends StatefulWidget {
  const TonosExpressiveInsetAccordion({
    super.key,
    required this.surface,
    required this.foreground,
    required this.outline,
    required this.borderRadius,
    required this.title,
    required this.children,
    this.leading,
    this.subtitle,
    this.trailingPrefix,
    this.iconColor,
    this.initiallyExpanded = false,
    this.maintainState = false,
    this.tilePadding = const EdgeInsets.symmetric(horizontal: 16),
    this.childrenPadding = EdgeInsets.zero,
    this.headerBodySpacing = 12,
    this.onExpansionChanged,
    this.semanticLabel,
  }) : assert(headerBodySpacing >= 0);

  final Color surface;
  final Color foreground;
  final Color outline;
  final BorderRadius borderRadius;
  final Widget title;
  final Widget? leading;
  final Widget? subtitle;
  final Widget? trailingPrefix;
  final Color? iconColor;
  final bool initiallyExpanded;
  final bool maintainState;
  final EdgeInsets tilePadding;
  final EdgeInsetsGeometry childrenPadding;
  final double headerBodySpacing;
  final ValueChanged<bool>? onExpansionChanged;
  final String? semanticLabel;
  final List<Widget> children;

  @override
  State<TonosExpressiveInsetAccordion> createState() =>
      _TonosExpressiveInsetAccordionState();
}

class _TonosExpressiveInsetAccordionState
    extends State<TonosExpressiveInsetAccordion> {
  final _controller = ExpansibleController();
  CurvedAnimation? _headerAnimation;
  bool _restored = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_restored) {
      final saved = PageStorage.maybeOf(context)?.readState(context) as bool?;
      if (saved ?? widget.initiallyExpanded) _controller.expand();
      _controller.addListener(_onExpansionChanged);
      _restored = true;
    }
  }

  void _onExpansionChanged() {
    PageStorage.maybeOf(context)?.writeState(context, _controller.isExpanded);
    setState(() {});
    widget.onExpansionChanged?.call(_controller.isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final style = TonosExpressiveStateMotion.expansionStyle(
      context,
      settleOnCollapse: true,
    )!;
    return Expansible(
      controller: _controller,
      animationStyle: style,
      maintainState: widget.maintainState,
      headerBuilder: (context, animation) {
        if (_headerAnimation?.parent != animation) {
          _headerAnimation?.dispose();
          _headerAnimation = CurvedAnimation(
            parent: animation,
            curve: style.curve!,
            reverseCurve: style.reverseCurve,
          );
        }
        final progress = _headerAnimation!.value.clamp(0.0, 1.0);
        final inset = 10 * progress;
        final radiusInset = 8 * progress;
        Radius innerCorner(Radius corner) => Radius.elliptical(
          math.max(0, corner.x - radiusInset),
          math.max(0, corner.y - radiusInset),
        );
        final headerRadius = BorderRadius.only(
          topLeft: innerCorner(widget.borderRadius.topLeft),
          topRight: innerCorner(widget.borderRadius.topRight),
          bottomLeft: innerCorner(widget.borderRadius.bottomLeft),
          bottomRight: innerCorner(widget.borderRadius.bottomRight),
        );
        final shape = RoundedRectangleBorder(
          borderRadius: headerRadius,
          side: BorderSide(
            color: widget.outline.withValues(
              alpha: widget.outline.a * .72 * progress,
            ),
            width: progress,
          ),
        );
        final headerSurface = Color.alphaBlend(
          widget.foreground.withValues(alpha: .07 * progress),
          widget.surface,
        );
        return Padding(
          padding: EdgeInsets.fromLTRB(inset, inset, inset, 0),
          child: Semantics(
            expanded: _controller.isExpanded,
            label: widget.semanticLabel,
            child: Material(
              color: headerSurface,
              shape: shape,
              clipBehavior: Clip.antiAlias,
              // The shared expansion controller owns the shape/inset timeline.
              animationDuration: Duration.zero,
              child: ListTile(
                // Ink adds the shape's border dimensions to its layout. The
                // Material paints the outline; Ink only needs its rounded path.
                shape: RoundedRectangleBorder(borderRadius: headerRadius),
                tileColor: Colors.transparent,
                // Keep the content's gutters inside the moving shape.
                contentPadding: widget.tilePadding,
                leading: widget.leading,
                title: widget.title,
                subtitle: widget.subtitle,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.trailingPrefix != null) ...[
                      widget.trailingPrefix!,
                      const SizedBox(width: 4),
                    ],
                    Transform.rotate(
                      angle: math.pi * progress,
                      child: Icon(
                        Icons.expand_more,
                        color: widget.iconColor ?? widget.foreground,
                      ),
                    ),
                  ],
                ),
                onTap: _controller.isExpanded
                    ? _controller.collapse
                    : _controller.expand,
              ),
            ),
          ),
        );
      },
      bodyBuilder: (context, animation) => ExcludeFocus(
        excluding: !_controller.isExpanded,
        child: ExcludeSemantics(
          excluding: !_controller.isExpanded,
          child: IgnorePointer(
            ignoring: !_controller.isExpanded,
            child: Padding(
              padding: widget.childrenPadding.add(
                EdgeInsets.only(top: widget.headerBodySpacing),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.children,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _headerAnimation?.dispose();
    _controller.removeListener(_onExpansionChanged);
    _controller.dispose();
    super.dispose();
  }
}
