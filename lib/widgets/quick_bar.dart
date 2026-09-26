// File: lib/widgets/quick_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/active_session.dart';
import '../providers/nutrition_profile.dart';
import '../screens/nutrition/measured_items_page.dart';
import '../screens/nutrition/food_logging_page.dart';
import '../screens/exercise/session_screen.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/tonos_segmented_action_bar.dart';

/// A three-section quick-action bar for measurements, food, and workouts.
///
/// Each segment uses the theme's domain action colors so families can preserve
/// measurement, nutrition, and workout meaning while changing their treatment.
class QuickBar extends StatelessWidget {
  final double scale;
  const QuickBar({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final semantic = context.semanticColors;

    final measurementBg = semantic.measurementContainer;
    final measurementText = semantic.onMeasurementContainer;
    final foodBg = semantic.nutritionContainer;
    final foodText = semantic.onNutritionContainer;
    final workoutBg = semantic.workoutContainer;
    final workoutText = semantic.onWorkoutContainer;

    return TonosSegmentedActionBar(
      scale: scale,
      items: [
        TonosActionBarItem(
          backgroundColor: measurementBg,
          foregroundColor: measurementText,
          label: strings.quickActionMeasurement,
          semanticLabel: strings.nutritionTrackMeasurement,
          fontSize: 12,
          onPressed: () async {
            final changed = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const MeasuredItemsPage()),
            );
            if (changed == true && context.mounted) {
              await context.read<NutritionProfile>().reloadDay();
            }
          },
        ),
        TonosActionBarItem(
          backgroundColor: foodBg,
          foregroundColor: foodText,
          label: strings.quickActionFood,
          semanticLabel: strings.nutritionLogFood,
          fontSize: 14,
          onPressed: () async {
            final changed = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const FoodLoggingPage()),
            );
            if (changed == true && context.mounted) {
              await context.read<NutritionProfile>().reloadDay();
            }
          },
        ),
        TonosActionBarItem(
          backgroundColor: workoutBg,
          foregroundColor: workoutText,
          label: strings.quickActionWorkout,
          semanticLabel: strings.dashboardStartWorkout,
          fontSize: 14,
          onPressed: () async {
            final session = context.read<ActiveSession>();
            final started = await session.start();
            if (!started && !session.isActive) return;
            if (!context.mounted) return;
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SessionScreen()));
          },
        ),
      ],
    );
  }
}
