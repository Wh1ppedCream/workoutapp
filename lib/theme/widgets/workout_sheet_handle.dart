import 'package:flutter/material.dart';

import '../theme_extensions.dart';

/// The completion sheet's decorative handle; dragging belongs to its parent.
class WorkoutSheetHandle extends StatelessWidget {
  const WorkoutSheetHandle({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 4,
    decoration: BoxDecoration(
      color: context.surfaceTokens.workoutHandle,
      borderRadius: context.shapeTokens.pill,
    ),
  );
}
