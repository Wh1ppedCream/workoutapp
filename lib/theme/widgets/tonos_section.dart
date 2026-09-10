import 'package:flutter/material.dart';

import 'tonos_surface.dart';

/// Semantic containers for titled feature sections.
enum TonosSectionVariant { panel, panelRaised, card }

/// A theme-driven section shell with an optional heading and supporting text.
class TonosSection extends StatelessWidget {
  const TonosSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.variant = TonosSectionVariant.panel,
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget child;
  final TonosSectionVariant variant;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heading = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ],
    );

    return TonosSurface(
      variant: switch (variant) {
        TonosSectionVariant.panel => TonosSurfaceVariant.panel,
        TonosSectionVariant.panelRaised => TonosSurfaceVariant.panelRaised,
        TonosSectionVariant.card => TonosSurfaceVariant.card,
      },
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [heading, const SizedBox(height: 12), child],
      ),
    );
  }
}
