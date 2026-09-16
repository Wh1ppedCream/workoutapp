import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/session_record_badge_models.dart';
import '../theme/theme_extensions.dart';

/// Compact first-completion badge shared by workout record lists.
class FirstRecordBadge extends StatelessWidget {
  final bool compact;
  final Color? foregroundSurface;

  const FirstRecordBadge({
    super.key,
    this.compact = false,
    this.foregroundSurface,
  });

  @override
  Widget build(BuildContext context) {
    final dataVisualization = context.dataVisualizationTokens;
    final shapes = context.shapeTokens;
    final color = dataVisualization.firstRecord;
    final fill = color.withValues(alpha: context.surfaceTokens.firstRecordFill);
    final foreground =
        context.surfaceDecorationTokens.panel.outlined &&
                foregroundSurface != null
            ? tonosForegroundForSurface(
              context,
              fill,
              parentSurface: foregroundSurface,
            )
            : color;
    final preservesClassicDensity =
        context.usesClassicPresentation &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.15;
    return Container(
      padding:
          compact
              ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1)
              : const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: compact ? shapes.recordBadgeCompact : shapes.recordBadge,
        border: Border.all(
          color: color.withValues(
            alpha: context.surfaceTokens.firstRecordBorder,
          ),
        ),
      ),
      child: Text(
        AppLocalizations.of(context).recordFirst,
        maxLines: 1,
        style: TextStyle(
          color: foreground,
          fontSize:
              preservesClassicDensity
                  ? (compact ? 7.5 : 9)
                  : (compact ? 10 : 12),
          height: compact ? 1 : null,
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
  final double? width;
  final TextAlign textAlign;
  final Color? foregroundSurface;

  const WorkoutRecordBadgeChip({
    super.key,
    required this.badge,
    this.compact = false,
    this.width,
    this.textAlign = TextAlign.start,
    this.foregroundSurface,
  });

  @override
  Widget build(BuildContext context) {
    final dataVisualization = context.dataVisualizationTokens;
    final shapes = context.shapeTokens;
    final color =
        badge.tier == WorkoutRecordBadgeTier.allTime
            ? dataVisualization.recordAllTime
            : dataVisualization.recordMonthly;
    final fill = color.withValues(alpha: context.surfaceTokens.recordBadgeFill);
    final foreground =
        context.surfaceDecorationTokens.panel.outlined &&
                foregroundSurface != null
            ? tonosForegroundForSurface(
              context,
              fill,
              parentSurface: foregroundSurface,
            )
            : color;
    final strings = AppLocalizations.of(context);
    final preservesClassicDensity =
        context.usesClassicPresentation &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.15;
    return Container(
      width: width,
      padding:
          compact
              ? const EdgeInsets.symmetric(horizontal: 4, vertical: 0)
              : const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: compact ? shapes.recordBadgeCompact : shapes.recordBadge,
        border: Border.all(
          color: color.withValues(
            alpha: context.surfaceTokens.recordBadgeBorder,
          ),
        ),
      ),
      child: Text(
        badge.type == WorkoutRecordBadgeType.repBest
            ? strings.recordRepBest(badge.reps ?? 0)
            : strings.recordVolumeBest,
        textAlign: textAlign,
        style: TextStyle(
          color: foreground,
          fontSize:
              preservesClassicDensity
                  ? (compact ? 7.5 : 9)
                  : (compact ? 10 : 12),
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
    final dataVisualization = context.dataVisualizationTokens;
    final strings = AppLocalizations.of(context);
    final textStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final preservesClassicDensity =
        context.usesClassicPresentation &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.15;
    final children = [
      _LegendItem(
        color: dataVisualization.recordMonthly,
        label: strings.recordMonthly,
        style: textStyle?.copyWith(color: dataVisualization.recordMonthly),
      ),
      _LegendItem(
        color: dataVisualization.recordAllTime,
        label: strings.recordAllTime,
        style: textStyle?.copyWith(color: dataVisualization.recordAllTime),
      ),
    ];
    return Padding(
      padding: padding,
      child:
          preservesClassicDensity
              ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [children[0], const SizedBox(width: 18), children[1]],
              )
              : Wrap(
                alignment: WrapAlignment.end,
                spacing: 18,
                runSpacing: 6,
                children: children,
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
