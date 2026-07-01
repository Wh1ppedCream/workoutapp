import '../models/models.dart';

enum GeneratedWeightRoundingDirection { nearest, down, up }

/// Rounds generated workout weights onto equipment-friendly increments.
///
/// This is intentionally separate from the recommendation math: generators can
/// estimate with history/bodyweight/starter formulas first, then pass the final
/// number through this utility so workout cards do not show awkward decimal
/// loads.
class GeneratedWeightRounding {
  const GeneratedWeightRounding._();

  static double roundForExercise({
    required ExerciseDefinition definition,
    required double weight,
    GeneratedWeightRoundingDirection direction =
        GeneratedWeightRoundingDirection.nearest,
    double? incrementOverride,
    double minimumWeight = 0,
    double? maximumWeight,
  }) {
    if (weight <= 0) return 0;

    var clamped = weight;
    if (maximumWeight != null) {
      clamped = clamped > maximumWeight ? maximumWeight : clamped;
    }

    final increment =
        (incrementOverride != null && incrementOverride > 0)
            ? incrementOverride
            : incrementForExercise(definition);
    if (increment <= 0) return clamped;

    final rounded = switch (direction) {
      GeneratedWeightRoundingDirection.down =>
        (clamped / increment).floor() * increment,
      GeneratedWeightRoundingDirection.up =>
        (clamped / increment).ceil() * increment,
      GeneratedWeightRoundingDirection.nearest =>
        (clamped / increment).round() * increment,
    };

    var result = rounded.toDouble();
    if (result <= 0 && clamped > 0) {
      result = increment;
    }
    if (result > 0 && minimumWeight > 0 && result < minimumWeight) {
      result = minimumWeight;
    }
    return result;
  }

  static double incrementForExercise(ExerciseDefinition definition) {
    final combined = _combinedDefinitionText(definition);

    if (combined.contains('cable') ||
        combined.contains('lat pulldown') ||
        combined.contains('pulldown machine')) {
      return 10;
    }
    if (combined.contains('machine') ||
        combined.contains('leg press') ||
        combined.contains('smith')) {
      return 10;
    }
    if (combined.contains('barbell') ||
        combined.contains('dumbbell') ||
        combined.contains('kettlebell') ||
        combined.contains('medicine ball') ||
        combined.contains('weight plate')) {
      return 5;
    }
    return 5;
  }

  static double minimumForExercise(ExerciseDefinition definition) {
    final combined = _combinedDefinitionText(definition);
    if (combined.contains('bodyweight') ||
        combined.contains('no equipment') ||
        combined.contains('none')) {
      return 0;
    }
    if (combined.contains('barbell') || combined.contains('smith')) {
      return 45;
    }
    if (combined.contains('cable') ||
        combined.contains('lat pulldown') ||
        combined.contains('pulldown machine') ||
        combined.contains('machine')) {
      return 10;
    }
    if (combined.contains('dumbbell') ||
        combined.contains('kettlebell') ||
        combined.contains('medicine ball') ||
        combined.contains('weight plate')) {
      return 5;
    }
    return 0;
  }

  static String _combinedDefinitionText(ExerciseDefinition definition) {
    return [
      definition.name,
      ...definition.equipmentList.map((equipment) => equipment.name),
    ].map(_normalize).join(' ');
  }

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }
}
