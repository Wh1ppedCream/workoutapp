// File: lib/widgets/exercise_card.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import 'weight_card.dart';

enum CardType { weight, cardio, stretch }

class ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final CardType cardType;
  final bool readOnlyMode;
  final Set<int>? initialCompletedParents;
  final Map<int, Set<int>>? initialCompletedChildren;
  final VoidCallback? onDeleteExercise;
  final VoidCallback? onSetAdded;
  final VoidCallback? onSetDeleted;
  final VoidCallback? onValueChanged;
  final VoidCallback? onDetails;
  final VoidCallback? onSwapExercise;
  final bool forceCollapsed;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.cardType = CardType.weight,
    this.readOnlyMode = false,
    this.initialCompletedParents,
    this.initialCompletedChildren,
    this.onDeleteExercise,
    this.onSetAdded,
    this.onSetDeleted,
    this.onValueChanged,
    this.onDetails,
    this.onSwapExercise,
    this.forceCollapsed = false,
  });

  @override
  Widget build(BuildContext ctx) {
    switch (cardType) {
      case CardType.weight:
        return WeightCard(
          exercise: exercise as WeightExercise,
          readOnlyMode: readOnlyMode,
          initialCompletedParents: initialCompletedParents,
          initialCompletedChildren: initialCompletedChildren,
          onDeleteExercise: onDeleteExercise,
          onSetAdded: onSetAdded,
          onSetDeleted: onSetDeleted,
          onValueChanged: onValueChanged,
          onDetails: onDetails,
          onSwapExercise: onSwapExercise,
          forceCollapsed: forceCollapsed,
        );
      case CardType.cardio:
      case CardType.stretch:
        // TODO(cardio/stretch): fix and update these cards, then add them back
        // into workout sessions and plan editing screens.
        return const SizedBox.shrink();
    }
  }
}
