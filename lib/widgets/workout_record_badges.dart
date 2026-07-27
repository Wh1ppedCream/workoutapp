import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/session_record_badge_models.dart';

const _monthlyRecordColor = Color(0xFF81C784);
const _allTimeRecordColor = Color(0xFFFFC857);

/// Compact first-completion badge shared by workout record lists.
class FirstRecordBadge extends StatelessWidget {
  const FirstRecordBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Text(
        AppLocalizations.of(context).recordFirst,
        maxLines: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Compact history-backed badge for one completed weighted parent set.
class WorkoutRecordBadgeChip extends StatelessWidget {
  final WorkoutRecordBadge badge;
  final bool compact;

  const WorkoutRecordBadgeChip({
    super.key,
    required this.badge,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        badge.tier == WorkoutRecordBadgeTier.allTime
            ? _allTimeRecordColor
            : _monthlyRecordColor;
    final strings = AppLocalizations.of(context);
    return Container(
      padding:
          compact
              ? const EdgeInsets.symmetric(horizontal: 4, vertical: 0)
              : const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(compact ? 5 : 7),
        border: Border.all(color: color.withValues(alpha: 0.62)),
      ),
      child: Text(
        badge.type == WorkoutRecordBadgeType.repBest
            ? strings.recordRepBest(badge.reps ?? 0)
            : strings.recordVolumeBest,
        style: TextStyle(
          color: color,
          fontSize: compact ? 7.5 : 9,
          height: compact ? 1 : null,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Explains green monthly and gold all-time record badges when needed.
class WorkoutRecordBadgeLegend extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const WorkoutRecordBadgeLegend({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 6),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final textStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _LegendItem(
            color: _monthlyRecordColor,
            label: strings.recordMonthly,
            style: textStyle?.copyWith(color: _monthlyRecordColor),
          ),
          const SizedBox(width: 18),
          _LegendItem(
            color: _allTimeRecordColor,
            label: strings.recordAllTime,
            style: textStyle?.copyWith(color: _allTimeRecordColor),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final TextStyle? style;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: style),
      ],
    );
  }
}
