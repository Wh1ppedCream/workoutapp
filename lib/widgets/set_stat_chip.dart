import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';
import 'recommended_sets_editor_dialog.dart';

class SetStatChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onEdit;

  const SetStatChip({
    super.key,
    required this.label,
    required this.value,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final neo = context.surfaceDecorationTokens.panel.outlined;
    final foreground =
        neo
            ? tonosForegroundForSurface(context, surfaces.metricChip)
            : theme.colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surfaces.metricChip,
        borderRadius: shapes.metric,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: neo ? foreground : null,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: neo ? foreground : null,
                  ),
                ),
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 2),
                RecommendedSetsEditButton(onPressed: onEdit!),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
