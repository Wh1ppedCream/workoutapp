// File: lib/widgets/add_exercise_fab.dart

import 'package:flutter/material.dart';
import '../screens/exercise/exercise_catalog_page.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

/// Callback when a weight exercise definition is picked.
typedef WeightPicker = Future<void> Function(ExerciseDefinition definition);

class AddExerciseFab extends StatelessWidget {
  final WeightPicker? onWeightPicked;
  final ValueChanged<bool>? onCatalogSelectionChanged;
  final VoidCallback? onCatalogExerciseAdded;
  final VoidCallback? onCatalogTutorialSkipped;
  final VoidCallback? onCatalogClosed;

  const AddExerciseFab({
    super.key,
    this.onWeightPicked,
    this.onCatalogSelectionChanged,
    this.onCatalogExerciseAdded,
    this.onCatalogTutorialSkipped,
    this.onCatalogClosed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final extras = theme.extension<AppColors>();
    final fabBg = extras?.addExerciseFabBg ?? cs.primary;
    final fabFg = extras?.addExerciseFabIcon ?? cs.onPrimary;

    return FloatingActionButton(
      backgroundColor: fabBg,
      foregroundColor: fabFg,
      onPressed: () => _openExerciseCatalog(context),
      child: const Icon(Icons.add),
    );
  }

  Future<void> _openExerciseCatalog(BuildContext ctx) async {
    // TODO(cardio/stretch): restore the Exercise/Cardio/Stretch chooser after
    // cardio and stretch cards are fixed, updated, and ready for users again.
    await Navigator.of(ctx).push(
      MaterialPageRoute(
        builder:
            (_) => ExerciseCatalogPage(
              showPlanBuilderGuide: onCatalogSelectionChanged != null,
              onPlanBuilderSelectionChanged: onCatalogSelectionChanged,
              onPlanBuilderExerciseAdded: onCatalogExerciseAdded,
              onPlanBuilderGuideSkipped: onCatalogTutorialSkipped,
              onExercisePicked: (def) async {
                await onWeightPicked?.call(def);
              },
            ),
      ),
    );
    onCatalogClosed?.call();
  }
}
