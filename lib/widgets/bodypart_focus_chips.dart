import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/definition_models.dart';
import '../theme/expressive_planning_tokens.dart';
import '../theme/theme_extensions.dart';
import '../utils/localized_body_part_name.dart';

/// Immutable selection state returned by [BodypartFocusChips].
class BodypartFocusSelection {
  final Set<int> preferredBodypartIds;
  final Set<int> blacklistedBodypartIds;

  const BodypartFocusSelection({
    required this.preferredBodypartIds,
    required this.blacklistedBodypartIds,
  });
}

/// Reusable tri-state bodypart picker.
///
/// Tapping a chip cycles through neutral -> preferred -> avoided -> neutral.
/// The widget does not own state; callers pass the current sets in and receive a
/// full replacement selection through [onChanged].
class BodypartFocusChips extends StatelessWidget {
  final List<BodyPart> bodyParts;
  final Set<int> preferredBodypartIds;
  final Set<int> blacklistedBodypartIds;
  final ValueChanged<BodypartFocusSelection> onChanged;
  final String emptyText;
  final AppExpressivePlanningTokens? expressiveTokens;
  final OutlinedBorder? expressiveShape;
  final bool showExpressiveStateIndicators;
  final Color? expressiveNeutralSurface;
  final Color? expressiveNeutralOutline;
  final double expressiveAvoidedSurfaceOpacity;
  final double expressiveIndicatorSize;
  final bool expressiveAvoidedUsesProhibitionIcon;

  const BodypartFocusChips({
    super.key,
    required this.bodyParts,
    required this.preferredBodypartIds,
    required this.blacklistedBodypartIds,
    required this.onChanged,
    this.emptyText = 'Bodyparts could not be loaded.',
    this.expressiveTokens,
    this.expressiveShape,
    this.showExpressiveStateIndicators = false,
    this.expressiveNeutralSurface,
    this.expressiveNeutralOutline,
    this.expressiveAvoidedSurfaceOpacity = 0.14,
    this.expressiveIndicatorSize = 18,
    this.expressiveAvoidedUsesProhibitionIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    if (bodyParts.isEmpty) {
      return Text(emptyText, style: const TextStyle(fontSize: 12));
    }

    final neo = context.usesNeoPresentation;
    final surfaces = context.surfaceTokens;
    final semanticColors = context.semanticColors;
    final expressive = expressiveTokens;
    final defaultExpressiveSurface = expressive == null
        ? null
        : Color.alphaBlend(
            expressive.planFocalSurface.withValues(alpha: 0.22),
            expressive.configurationSurface,
          );
    final chipSurface = expressive == null
        ? surfaces.dialogChoice
        : expressiveNeutralSurface ?? defaultExpressiveSurface!;
    final chipForeground =
        expressive?.configurationForeground ??
        (neo ? tonosForegroundForSurface(context, chipSurface) : null);
    final chipOutline = expressive != null
        ? expressiveNeutralOutline ?? expressive.outline
        : neo
        ? tonosOutlineForSurface(context, chipSurface)
        : Theme.of(context).dividerColor;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: bodyParts.map((bodyPart) {
        final isPreferred = preferredBodypartIds.contains(bodyPart.id);
        final isAvoided = blacklistedBodypartIds.contains(bodyPart.id);
        final isSelected = isPreferred || isAvoided;
        final preferredColor =
            expressive?.actionPrimary ??
            (neo ? semanticColors.positive : Colors.green.shade300);
        final avoidedColor = neo || expressive != null
            ? semanticColors.negative
            : Colors.red.shade300;
        final avoidedSurface = expressive == null
            ? avoidedColor
            : Color.alphaBlend(
                avoidedColor.withValues(alpha: expressiveAvoidedSurfaceOpacity),
                chipSurface,
              );
        final color = isPreferred
            ? preferredColor
            : isAvoided
            ? avoidedSurface
            : null;
        final statusForeground = isPreferred
            ? expressive?.actionPrimaryForeground ?? semanticColors.onPositive
            : isAvoided
            ? expressive != null
                  ? avoidedColor
                  : semanticColors.onNegative
            : chipForeground ?? Theme.of(context).colorScheme.onSurface;
        final statusOutline = color == null ? chipOutline : statusForeground;

        final chip = RawChip(
          label: Text(localizedBodyPartName(context, bodyPart.name)),
          selected: isSelected,
          showCheckmark: !(expressiveAvoidedUsesProhibitionIcon && isAvoided),
          backgroundColor: neo || expressive != null ? chipSurface : null,
          selectedColor: neo || expressive != null
              ? color
              : color?.withAlpha(61),
          side: BorderSide(
            color: neo || expressive != null
                ? statusOutline
                : color ?? chipOutline,
          ),
          shape: expressive == null ? null : expressiveShape,
          labelStyle: neo || expressive != null
              ? TextStyle(
                  color: isSelected ? statusForeground : chipForeground,
                  fontWeight: FontWeight.w700,
                )
              : color == null
              ? null
              : TextStyle(color: color, fontWeight: FontWeight.w700),
          avatar: expressive != null
              ? Icon(
                  isPreferred
                      ? showExpressiveStateIndicators
                            ? Icons.add_circle_outline
                            : Icons.check_circle
                      : isAvoided
                      ? expressiveAvoidedUsesProhibitionIcon
                            ? Icons.block
                            : showExpressiveStateIndicators
                            ? Icons.remove_circle_outline
                            : Icons.block
                      : Icons.radio_button_unchecked,
                  color: statusForeground,
                  size: expressiveIndicatorSize,
                )
              : color == null
              ? null
              : Icon(
                  isPreferred ? Icons.add_circle_outline : Icons.block,
                  color: neo ? statusForeground : color,
                  size: 18,
                ),
          onPressed: () => _cycleBodyPart(bodyPart.id),
        );
        if (expressive == null) return chip;

        final label = localizedBodyPartName(context, bodyPart.name);
        final strings = AppLocalizations.of(context);
        final status = isPreferred
            ? strings.generateFocusPreferred
            : isAvoided
            ? strings.generateFocusAvoided
            : strings.generateFocusNeutral;
        return Semantics(
          label: '$label, $status',
          selected: isSelected,
          child: chip,
        );
      }).toList(),
    );
  }

  void _cycleBodyPart(int bodyPartId) {
    final preferred = {...preferredBodypartIds};
    final blacklisted = {...blacklistedBodypartIds};
    final isPreferred = preferred.contains(bodyPartId);
    final isAvoided = blacklisted.contains(bodyPartId);

    if (!isPreferred && !isAvoided) {
      preferred.add(bodyPartId);
    } else if (isPreferred) {
      preferred.remove(bodyPartId);
      blacklisted.add(bodyPartId);
    } else {
      blacklisted.remove(bodyPartId);
    }

    onChanged(
      BodypartFocusSelection(
        preferredBodypartIds: preferred,
        blacklistedBodypartIds: blacklisted,
      ),
    );
  }
}
