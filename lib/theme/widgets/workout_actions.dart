import 'package:material_ui/material_ui.dart';

import '../expressive_planning_tokens.dart';
import '../theme_extensions.dart';
import '../tokens/app_expressive_train_tokens.dart';
import 'tonos_action_depth.dart';
import 'tonos_expressive_motion.dart';

/// Swap actions keep their original Material defaults and vertical padding.
class WorkoutSwapAction extends StatelessWidget {
  const WorkoutSwapAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.cancel = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool cancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    if (cancel) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.swapCancel,
          side: BorderSide(color: colors.swapCancel),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: colors.swapConfirm,
        foregroundColor: colors.onSwapConfirm,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

/// Match indicators share one accent while keeping badge and marker geometry distinct.
class WorkoutMatchBadge extends StatelessWidget {
  const WorkoutMatchBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = context.semanticColors.swapMatch;
    final surfaces = context.surfaceTokens;
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    return Container(
      padding: planning == null
          ? const EdgeInsets.symmetric(horizontal: 7, vertical: 3)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            planning?.actionSecondary ??
            accent.withValues(alpha: surfaces.swapMatchFill),
        borderRadius: context.shapeTokens.pill,
        border: Border.all(
          color: accent.withValues(alpha: surfaces.swapMatchBorder),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: planning?.actionSecondaryForeground ?? accent,
          fontSize: planning == null ? 10 : 11,
          height: planning == null ? 1 : 1.1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class WorkoutMatchMarker extends StatelessWidget {
  const WorkoutMatchMarker({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 6,
    height: 6,
    decoration: BoxDecoration(
      color: context.semanticColors.swapMatch,
      shape: BoxShape.circle,
    ),
  );
}

/// Equipment filtering keeps the sheet's original switch and text presentation.
class WorkoutEquipmentFilter extends StatelessWidget {
  const WorkoutEquipmentFilter({
    super.key,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final usesInkRecipe = context.usesNeoPresentation;
    final filterSurface = surfaces.planFilter;
    final filterForeground = usesInkRecipe
        ? tonosForegroundForSurface(context, filterSurface)
        : null;
    final filterSecondary = usesInkRecipe
        ? tonosSecondaryForegroundForSurface(context, filterSurface)
        : theme.colorScheme.onSurfaceVariant;
    final expressive = context.usesExpressivePresentation;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: expressive ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: filterSurface,
        borderRadius: context.shapeTokens.card,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(
            alpha: surfaces.swapFilterBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: expressive ? FontWeight.w600 : FontWeight.w700,
                color: enabled ? filterForeground : filterSecondary,
              ),
            ),
          ),
          Switch(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}

class WorkoutAddChangeSetAction extends StatelessWidget {
  const WorkoutAddChangeSetAction({
    super.key,
    required this.label,
    required this.onTap,
  });
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!context.usesExpressivePresentation) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: context.semanticColors.workoutAddChangeSet),
          borderRadius: context.shapeTokens.workoutAddChangeSet,
        ),
        child: GestureDetector(onTap: onTap, child: Text(label)),
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: DefaultTextStyle.of(context).style.color,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        side: BorderSide(color: context.semanticColors.workoutAddChangeSet),
        shape: RoundedRectangleBorder(
          borderRadius: context.shapeTokens.workoutAddChangeSet,
        ),
        textStyle: DefaultTextStyle.of(context).style,
      ),
      child: Text(label),
    );
  }
}

/// Save/discard recipes for the completed-work exit dialog.
class WorkoutExitAction extends StatelessWidget {
  const WorkoutExitAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.discard = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool discard;

  @override
  Widget build(BuildContext context) {
    if (discard) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.delete_outline, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: context.cs.error,
          side: BorderSide(
            color: context.cs.error.withValues(
              alpha: context.surfaceTokens.workoutDiscardBorder,
            ),
          ),
        ),
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.save_outlined, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    );
  }
}

/// Finish retains the inherited elevated-button recipe, including disabled styling.
class WorkoutFinishAction extends StatelessWidget {
  const WorkoutFinishAction({
    super.key,
    this.buttonKey,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.expressiveWorkoutPresentation = false,
  });

  final Key? buttonKey;
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool expressiveWorkoutPresentation;

  @override
  Widget build(BuildContext context) {
    final expressiveTokens = expressiveWorkoutPresentation
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()
        : null;
    final restingShape = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(28),
      bottomLeft: const Radius.circular(28),
      bottomRight: const Radius.circular(18),
    );
    Widget button = ElevatedButton(
      key: buttonKey,
      onPressed: busy ? null : onPressed,
      style: expressiveTokens == null
          ? null
          : ElevatedButton.styleFrom(
              backgroundColor: expressiveTokens.actionPrimary,
              foregroundColor: expressiveTokens.actionPrimaryForeground,
              shape: RoundedRectangleBorder(borderRadius: restingShape),
            ),
      child: busy
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: expressiveTokens?.actionPrimaryForeground,
              ),
            )
          : Text(label),
    );
    if (expressiveTokens != null) {
      button = TonosExpressivePressResponse(
        enabled: !busy && onPressed != null,
        allowReleaseOvershoot: false,
        pressedScale: TonosExpressiveMotionTiers.focalScale,
        pressedOffset: TonosExpressiveMotionTiers.focalOffset,
        child: button,
      );
    }
    return tonosWithPrimaryActionDepth(
      context,
      button,
      enabled: !busy && onPressed != null,
    );
  }
}

/// Completion keeps Material's filled styling and the original touch-target height.
class WorkoutDoneAction extends StatelessWidget {
  const WorkoutDoneAction({
    super.key,
    this.buttonKey,
    required this.label,
    required this.onPressed,
  });

  final Key? buttonKey;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => tonosWithPrimaryActionDepth(
    context,
    FilledButton.icon(
      key: buttonKey,
      onPressed: onPressed,
      icon: const Icon(Icons.check_rounded),
      label: Text(label),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    ),
    enabled: onPressed != null,
  );
}
