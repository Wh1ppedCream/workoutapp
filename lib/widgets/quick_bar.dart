// File: lib/widgets/quick_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/active_session.dart';
import '../providers/nutrition_profile.dart';
import '../screens/nutrition/new_measurement_item_page.dart';
import '../screens/nutrition/food_logging_page.dart';
import '../screens/exercise/session_screen.dart';
import '../theme/app_colors.dart';

/// A three-section quick-action bar:
/// 1️⃣ +Measurement (navigates to NewMeasurementItemPage)
/// 2️⃣ +Food        (navigates to FoodLoggingPage)
/// 3️⃣ +Workout     (starts a new session and navigates to SessionScreen)
///
/// Each segment picks its color based on the current theme's AppColors override
/// or falls back to the original light-mode values.
class QuickBar extends StatelessWidget {
  final double scale;
  const QuickBar({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final extras = theme.extension<AppColors>();

    // Use overrides if present, otherwise default to original light-mode colors
    final measurementBg = extras?.quickBarMeasurementBg ?? Colors.teal.shade100;
    final measurementText = extras?.quickBarMeasurementText ?? Colors.teal.shade800;

    final foodBg = extras?.quickBarFoodBg ?? Colors.orange.shade100;
    final foodText = extras?.quickBarFoodText ?? Colors.orange.shade800;

    final workoutBg = extras?.quickBarWorkoutBg ?? Colors.green.shade100;
    final workoutText = extras?.quickBarWorkoutText ?? Colors.green.shade800;

    final dividerColor = cs.onSurface.withValues(alpha: 0.12);
    final segmentHeight = 40 * scale;
    final radii = BorderRadius.circular(24 * scale);
    theme.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(borderRadius: radii),
      child: Row(
        children: [
          Expanded(
            child: _segment(
              context,
              backgroundColor: measurementBg,
              textColor: measurementText,
              borderRadius: BorderRadius.horizontal(left: radii.topLeft),
              label: '+ Measurement',
              fontSize: 12 * scale,
              onTap: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const NewMeasurementItemPage()),
                );
                if (changed == true && context.mounted) {
                  await context.read<NutritionProfile>().reloadDay();
                }
              },
            ),
          ),
          _divider(dividerColor, segmentHeight),
          Expanded(
            child: _segment(
              context,
              backgroundColor: foodBg,
              textColor: foodText,
              borderRadius: BorderRadius.zero,
              label: '+ Food',
              fontSize: 14 * scale,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FoodLoggingPage()),
                );
              },
            ),
          ),
          _divider(dividerColor, segmentHeight),
          Expanded(
            child: _segment(
              context,
              backgroundColor: workoutBg,
              textColor: workoutText,
              borderRadius: BorderRadius.horizontal(right: radii.topLeft),
              label: '+ Workout',
              fontSize: 14 * scale,
              onTap: () {
                final session = context.read<ActiveSession>();
                session.start();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SessionScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context, {
    required Color backgroundColor,
    required Color textColor,
    required BorderRadius borderRadius,
    required String label,
    required double fontSize,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall!.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      color: textColor,
    );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          child: SizedBox(
            height: 40 * scale,
            child: Center(child: Text(label, style: textStyle)),
          ),
        ),
      ),
    );
  }

  Widget _divider(Color color, double height) => Container(
        width: 1 * scale,
        height: height,
        color: color,
      );
}
