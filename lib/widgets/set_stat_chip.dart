import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
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
