// File: lib/widgets/exercise_card.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import 'weight_card.dart';
import 'cardio_card.dart';
import 'stretch_card.dart';

enum CardType { weight, cardio, stretch }

class ExerciseCard extends StatelessWidget {
  final WorkoutExercise           exercise;
  final CardType                  cardType;
  final bool                      readOnlyMode;
  final Set<int>?                 initialCompletedParents;
  final Map<int, Set<int>>?       initialCompletedChildren;
  final VoidCallback?             onDeleteExercise;
  final VoidCallback?             onSetAdded;
  final VoidCallback?             onSetDeleted;
  final VoidCallback?             onValueChanged;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    this.cardType = CardType.weight,
    this.readOnlyMode = false,
    this.initialCompletedParents,
    this.initialCompletedChildren,
    this.onDeleteExercise,
    this.onSetAdded,
    this.onSetDeleted,
    this.onValueChanged,
  }) : super(key: key);

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
        );
      case CardType.cardio:
        return CardioCard(
          exercise: exercise as CardioExercise,
          readOnlyMode: readOnlyMode,
          onDeleteExercise: onDeleteExercise,
          onValueChanged: onValueChanged,
        );
      case CardType.stretch:
        return StretchCard(
          exercise: exercise as StretchExercise,
          readOnlyMode: readOnlyMode,
          onDeleteExercise: onDeleteExercise,
          onValueChanged: onValueChanged,
        );
    }
  }
}
