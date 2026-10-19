// File: lib/widgets/add_exercise_fab.dart

import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../screens/exercise/exercise_catalog_page.dart';
import '../models/models.dart';
import '../theme/theme_extensions.dart';
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../theme/tokens/app_expressive_train_tokens.dart';
import '../theme/widgets/app_expressive_destination_theme.dart';
import '../theme/widgets/tonos_expressive_motion.dart';

/// Callback when a weight exercise definition is picked.
typedef WeightPicker = Future<void> Function(ExerciseDefinition definition);

class AddExerciseFab extends StatelessWidget {
  final WeightPicker? onWeightPicked;
  final ValueChanged<bool>? onCatalogSelectionChanged;
  final VoidCallback? onCatalogExerciseAdded;
  final VoidCallback? onCatalogTutorialSkipped;
  final VoidCallback? onCatalogClosed;
  final bool expressiveWorkoutPresentation;
  final String? semanticLabel;

  const AddExerciseFab({
    super.key,
    this.onWeightPicked,
    this.onCatalogSelectionChanged,
    this.onCatalogExerciseAdded,
    this.onCatalogTutorialSkipped,
    this.onCatalogClosed,
    this.expressiveWorkoutPresentation = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final actionColors = context.semanticColors;
    final strings = AppLocalizations.of(context);
    final label = semanticLabel ?? strings.commonAdd;
    final expressiveTokens = expressiveWorkoutPresentation
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()
        : null;
    final fabShape = BorderRadius.only(
      topLeft: const Radius.circular(22),
      topRight: const Radius.circular(14),
      bottomLeft: const Radius.circular(14),
      bottomRight: const Radius.circular(22),
    );

    Widget fab = FloatingActionButton(
      tooltip: label,
      backgroundColor:
          expressiveTokens?.actionSecondary ?? actionColors.primaryAction,
      foregroundColor:
          expressiveTokens?.actionSecondaryForeground ??
          actionColors.onPrimaryAction,
      shape: expressiveTokens == null
          ? null
          : RoundedRectangleBorder(borderRadius: fabShape),
      onPressed: () => _openExerciseCatalog(context),
      child: const Icon(Icons.add),
    );
    if (expressiveTokens != null) {
      fab = TonosExpressivePressResponse(
        enabled: true,
        allowReleaseOvershoot: false,
        pressedScale: TonosExpressiveMotionTiers.supportingScale,
        pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
        child: fab,
      );
    }

    return Semantics(
      button: true,
      label: label,
      onTap: () => _openExerciseCatalog(context),
      child: ExcludeSemantics(child: fab),
    );
  }

  Future<void> _openExerciseCatalog(BuildContext ctx) async {
    // TODO(cardio/stretch): restore the Exercise/Cardio/Stretch chooser after
    // cardio and stretch cards are fixed, updated, and ready for users again.
    await Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => AppExpressiveDestinationTheme(
          family: AppExpressiveDestinationFamily.catalog,
          child: ExerciseCatalogPage(
            expressiveCatalogPresentation: ctx.usesExpressivePresentation,
            showPlanBuilderGuide: onCatalogSelectionChanged != null,
            onPlanBuilderSelectionChanged: onCatalogSelectionChanged,
            onPlanBuilderExerciseAdded: onCatalogExerciseAdded,
            onPlanBuilderGuideSkipped: onCatalogTutorialSkipped,
            onExercisePicked: (def) async {
              await onWeightPicked?.call(def);
            },
          ),
        ),
      ),
    );
    onCatalogClosed?.call();
  }
}
