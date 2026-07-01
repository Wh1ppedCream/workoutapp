import 'dart:math' as math;

import '../models/models.dart';
import '../utils/generated_weight_rounding.dart';

enum StarterWeightRecommendationSource {
  exerciseProfile,
  equipmentFallback,
  bodyweightOnly,
  unavailable,
}

class StarterWeightRecommendation {
  final double weight;
  final double roundedFrom;
  final String unit;
  final StarterWeightRecommendationSource source;
  final StarterWeightConfidence confidence;
  final StarterLoadUnitMode unitMode;
  final String note;

  const StarterWeightRecommendation({
    required this.weight,
    required this.roundedFrom,
    required this.unit,
    required this.source,
    required this.confidence,
    required this.unitMode,
    required this.note,
  });

  bool get isAvailable =>
      source != StarterWeightRecommendationSource.unavailable;

  bool get isBodyweightOnly =>
      source == StarterWeightRecommendationSource.bodyweightOnly;
}

/// Conservative starter weights for generated exercises with no logged history.
///
/// This service intentionally does not replace history-based strength logic. It
/// only answers: "If the user has never logged this exercise, what safe starter
/// load can we prefill so the generated plan is not all zeroes?"
///
/// TODO: Later, consider a first-set calibration flow ("too easy / good / too
/// hard") so these no-history estimates can adapt without interrupting setup.
class StarterWeightRecommendationService {
  static const String displayUnit = 'lbs';

  StarterWeightRecommendation recommend({
    required ExerciseDefinition definition,
    required StarterWeightIntensity intensity,
    required int targetReps,
    double? bodyWeightLbs,
  }) {
    final profile =
        definition.starterLoadProfile ?? _exactProfileFor(definition);
    if (profile != null) {
      final recommendation = _recommendFromProfile(
        definition: definition,
        profile: profile,
        intensity: intensity,
        targetReps: targetReps,
        bodyWeightLbs: bodyWeightLbs,
        source: StarterWeightRecommendationSource.exerciseProfile,
      );
      if (recommendation.source !=
          StarterWeightRecommendationSource.unavailable) {
        return recommendation;
      }
    }

    final fallbackProfile = _fallbackProfileFor(definition);
    if (fallbackProfile == null) {
      return _unavailable(
        definition,
        'No safe starter estimate is available yet.',
      );
    }

    return _recommendFromProfile(
      definition: definition,
      profile: fallbackProfile,
      intensity: intensity,
      targetReps: targetReps,
      bodyWeightLbs: bodyWeightLbs,
      source: StarterWeightRecommendationSource.equipmentFallback,
    );
  }

  StarterWeightRecommendation _recommendFromProfile({
    required ExerciseDefinition definition,
    required StarterLoadProfile profile,
    required StarterWeightIntensity intensity,
    required int targetReps,
    required double? bodyWeightLbs,
    required StarterWeightRecommendationSource source,
  }) {
    if (profile.type == StarterLoadType.bodyweightOnly) {
      return StarterWeightRecommendation(
        weight: 0,
        roundedFrom: 0,
        unit: displayUnit,
        source: StarterWeightRecommendationSource.bodyweightOnly,
        confidence: StarterWeightConfidence.high,
        unitMode: StarterLoadUnitMode.total,
        note: profile.note.isEmpty ? 'Bodyweight movement.' : profile.note,
      );
    }

    final baseValue = _valueForIntensity(profile, intensity);
    if (baseValue == null || baseValue <= 0) {
      return _unavailable(
        definition,
        'Starter profile is missing a usable load value.',
      );
    }

    double rawWeight;
    if (profile.type == StarterLoadType.bodyweightMultiplier) {
      if (bodyWeightLbs == null || bodyWeightLbs <= 0) {
        final fallback = _fixedFallbackProfileFor(definition);
        if (fallback == null) {
          return _unavailable(
            definition,
            'Bodyweight is needed before this starter estimate can be used.',
          );
        }
        return _recommendFromProfile(
          definition: definition,
          profile: fallback,
          intensity: intensity,
          targetReps: targetReps,
          bodyWeightLbs: bodyWeightLbs,
          source: StarterWeightRecommendationSource.equipmentFallback,
        );
      }
      rawWeight = bodyWeightLbs * baseValue;
    } else {
      rawWeight = baseValue;
    }

    rawWeight *= _repAdjustment(targetReps);
    final rounded = _roundStarterWeightDown(definition, rawWeight, profile);
    return StarterWeightRecommendation(
      weight: rounded,
      roundedFrom: rawWeight,
      unit: displayUnit,
      source: source,
      confidence: profile.confidence,
      unitMode: profile.unitMode,
      note: profile.note,
    );
  }

  StarterWeightRecommendation _unavailable(
    ExerciseDefinition definition,
    String note,
  ) {
    return StarterWeightRecommendation(
      weight: 0,
      roundedFrom: 0,
      unit: displayUnit,
      source: StarterWeightRecommendationSource.unavailable,
      confidence: StarterWeightConfidence.low,
      unitMode: StarterLoadUnitMode.total,
      note: note,
    );
  }

  double? _valueForIntensity(
    StarterLoadProfile profile,
    StarterWeightIntensity intensity,
  ) {
    final selected = switch (intensity) {
      StarterWeightIntensity.easy => profile.easyValue,
      StarterWeightIntensity.medium => profile.mediumValue,
      StarterWeightIntensity.hard => profile.hardValue,
    };
    if (selected != null) return selected;
    if (profile.mediumValue != null) {
      return switch (intensity) {
        StarterWeightIntensity.easy => profile.mediumValue! * 0.80,
        StarterWeightIntensity.medium => profile.mediumValue!,
        StarterWeightIntensity.hard => profile.mediumValue! * 1.15,
      };
    }
    return profile.easyValue ?? profile.hardValue;
  }

  double _repAdjustment(int targetReps) {
    final reps = math.max(1, targetReps);
    final adjustment = 1.0 + (8 - reps) * 0.025;
    return adjustment.clamp(0.85, 1.10).toDouble();
  }

  double _roundStarterWeightDown(
    ExerciseDefinition definition,
    double rawWeight,
    StarterLoadProfile profile,
  ) {
    return GeneratedWeightRounding.roundForExercise(
      definition: definition,
      weight: rawWeight,
      direction: GeneratedWeightRoundingDirection.down,
      incrementOverride:
          profile.roundingIncrement <= 0 ? null : profile.roundingIncrement,
      minimumWeight: profile.minimumWeight,
      maximumWeight: profile.maximumWeight,
    );
  }

  StarterLoadProfile? _exactProfileFor(ExerciseDefinition definition) {
    final name = _normalize(definition.name);
    final equipmentNames = _normalizedEquipmentNames(definition);
    if (name.contains('push up') || name.contains('push-up')) {
      return _bodyweightOnly();
    }
    if (name.contains('pull up') ||
        name.contains('pull-up') ||
        name.contains('chin up') ||
        name.contains('chin-up') ||
        name.contains('dip')) {
      return _bodyweightOnly();
    }
    if (name.contains('bench press') && name.contains('barbell')) {
      return const StarterLoadProfile(
        type: StarterLoadType.bodyweightMultiplier,
        easyValue: 0.25,
        mediumValue: 0.35,
        hardValue: 0.45,
        minimumWeight: 45,
        roundingIncrement: 5,
        confidence: StarterWeightConfidence.medium,
        note: 'Conservative barbell pressing starter estimate.',
      );
    }
    if (name.contains('squat') && name.contains('barbell')) {
      return const StarterLoadProfile(
        type: StarterLoadType.bodyweightMultiplier,
        easyValue: 0.30,
        mediumValue: 0.45,
        hardValue: 0.60,
        minimumWeight: 45,
        roundingIncrement: 5,
        confidence: StarterWeightConfidence.medium,
        note: 'Conservative squat starter estimate.',
      );
    }
    if (name.contains('deadlift') && name.contains('barbell')) {
      return const StarterLoadProfile(
        type: StarterLoadType.bodyweightMultiplier,
        easyValue: 0.35,
        mediumValue: 0.50,
        hardValue: 0.65,
        minimumWeight: 45,
        roundingIncrement: 5,
        confidence: StarterWeightConfidence.medium,
        note: 'Conservative hinge starter estimate.',
      );
    }
    if (name.contains('overhead press') && name.contains('barbell')) {
      return const StarterLoadProfile(
        type: StarterLoadType.bodyweightMultiplier,
        easyValue: 0.15,
        mediumValue: 0.25,
        hardValue: 0.35,
        minimumWeight: 45,
        roundingIncrement: 5,
        confidence: StarterWeightConfidence.medium,
      );
    }
    if (name.contains('row') && name.contains('barbell')) {
      return const StarterLoadProfile(
        type: StarterLoadType.bodyweightMultiplier,
        easyValue: 0.25,
        mediumValue: 0.35,
        hardValue: 0.45,
        minimumWeight: 45,
        roundingIncrement: 5,
        confidence: StarterWeightConfidence.medium,
      );
    }
    if (name.contains('lateral raise')) {
      if (equipmentNames.any((equipment) => equipment.contains('cable'))) {
        return const StarterLoadProfile(
          type: StarterLoadType.fixedTotal,
          easyValue: 5,
          mediumValue: 10,
          hardValue: 15,
          roundingIncrement: 5,
          confidence: StarterWeightConfidence.medium,
        );
      }
      return const StarterLoadProfile(
        type: StarterLoadType.fixedPerHand,
        easyValue: 5,
        mediumValue: 10,
        hardValue: 15,
        roundingIncrement: 5,
        unitMode: StarterLoadUnitMode.perHand,
        confidence: StarterWeightConfidence.medium,
      );
    }
    if (name.contains('curl') && name.contains('dumbbell')) {
      return const StarterLoadProfile(
        type: StarterLoadType.fixedPerHand,
        easyValue: 5,
        mediumValue: 10,
        hardValue: 15,
        roundingIncrement: 5,
        unitMode: StarterLoadUnitMode.perHand,
        confidence: StarterWeightConfidence.medium,
      );
    }
    if (name.contains('lat pulldown')) {
      return const StarterLoadProfile(
        type: StarterLoadType.fixedTotal,
        easyValue: 35,
        mediumValue: 50,
        hardValue: 65,
        roundingIncrement: 5,
        confidence: StarterWeightConfidence.low,
      );
    }
    if (name.contains('leg press')) {
      return const StarterLoadProfile(
        type: StarterLoadType.bodyweightMultiplier,
        easyValue: 0.40,
        mediumValue: 0.60,
        hardValue: 0.80,
        minimumWeight: 45,
        roundingIncrement: 5,
        confidence: StarterWeightConfidence.low,
      );
    }
    if (name.contains('calf raise')) {
      return const StarterLoadProfile(
        type: StarterLoadType.fixedTotal,
        easyValue: 25,
        mediumValue: 40,
        hardValue: 55,
        roundingIncrement: 5,
        confidence: StarterWeightConfidence.low,
      );
    }
    return null;
  }

  StarterLoadProfile? _fallbackProfileFor(ExerciseDefinition definition) {
    if (_isBodyweightEquipment(definition)) return _bodyweightOnly();
    return _fixedFallbackProfileFor(definition);
  }

  StarterLoadProfile? _fixedFallbackProfileFor(ExerciseDefinition definition) {
    final equipmentNames = _normalizedEquipmentNames(definition);
    final name = _normalize(definition.name);
    final combined = [...equipmentNames, name].join(' ');

    if (combined.contains('dumbbell')) {
      final compound = _looksCompound(definition);
      return StarterLoadProfile(
        type: StarterLoadType.fixedPerHand,
        easyValue: compound ? 10 : 5,
        mediumValue: compound ? 15 : 10,
        hardValue: compound ? 20 : 15,
        roundingIncrement: 5,
        unitMode: StarterLoadUnitMode.perHand,
        confidence: StarterWeightConfidence.low,
      );
    }
    if (combined.contains('barbell') || combined.contains('smith')) {
      return const StarterLoadProfile(
        type: StarterLoadType.fixedTotal,
        easyValue: 45,
        mediumValue: 55,
        hardValue: 65,
        minimumWeight: 45,
        roundingIncrement: 5,
        confidence: StarterWeightConfidence.low,
      );
    }
    if (combined.contains('cable')) {
      return const StarterLoadProfile(
        type: StarterLoadType.fixedTotal,
        easyValue: 15,
        mediumValue: 25,
        hardValue: 35,
        roundingIncrement: 5,
        confidence: StarterWeightConfidence.low,
      );
    }
    if (combined.contains('machine') ||
        combined.contains('press') ||
        combined.contains('extension') ||
        combined.contains('curl')) {
      return const StarterLoadProfile(
        type: StarterLoadType.fixedTotal,
        easyValue: 20,
        mediumValue: 35,
        hardValue: 50,
        roundingIncrement: 5,
        confidence: StarterWeightConfidence.low,
      );
    }
    if (combined.contains('kettlebell') || combined.contains('medicine ball')) {
      return const StarterLoadProfile(
        type: StarterLoadType.fixedTotal,
        easyValue: 10,
        mediumValue: 15,
        hardValue: 20,
        roundingIncrement: 5,
        confidence: StarterWeightConfidence.low,
      );
    }
    return null;
  }

  StarterLoadProfile _bodyweightOnly() {
    return const StarterLoadProfile(
      type: StarterLoadType.bodyweightOnly,
      easyValue: 0,
      mediumValue: 0,
      hardValue: 0,
      roundingIncrement: 5,
      unitMode: StarterLoadUnitMode.total,
      confidence: StarterWeightConfidence.high,
      note: 'Bodyweight movement.',
    );
  }

  bool _isBodyweightEquipment(ExerciseDefinition definition) {
    final equipmentNames = _normalizedEquipmentNames(definition);
    if (equipmentNames.any((name) => name == 'bodyweight' || name == 'none')) {
      return true;
    }
    final name = _normalize(definition.name);
    return name.contains('push up') ||
        name.contains('pull up') ||
        name.contains('chin up') ||
        name.contains('dip');
  }

  List<String> _normalizedEquipmentNames(ExerciseDefinition definition) {
    return definition.equipmentList
        .map((equipment) => _normalize(equipment.name))
        .toList();
  }

  bool _looksCompound(ExerciseDefinition definition) {
    final bodypartCount = definition.bodyParts.length;
    if (bodypartCount >= 2) return true;
    final name = _normalize(definition.name);
    return name.contains('press') ||
        name.contains('row') ||
        name.contains('squat') ||
        name.contains('deadlift') ||
        name.contains('lunge');
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }
}
