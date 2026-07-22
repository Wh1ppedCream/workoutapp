import '../models/models.dart';

/// Shared eligibility checks for exercises and gym-profile equipment.
///
/// An exercise can be used with a profile only when every item in its
/// [ExerciseDefinition.equipmentList] is available in that profile. The
/// singular `equipmentId` remains a legacy primary/display field and is never
/// used to decide profile eligibility.
abstract final class ExerciseEquipmentCompatibility {
  static bool fitsProfileIds(
    ExerciseDefinition definition,
    Iterable<int> profileEquipmentIds,
  ) {
    final availableIds = profileEquipmentIds.toSet();
    return definition.equipmentList
        .map((equipment) => equipment.id)
        .toSet()
        .every(availableIds.contains);
  }

  static bool fitsProfileNames(
    ExerciseDefinition definition,
    Iterable<String> profileEquipmentNames,
  ) {
    final availableNames = normalizeNames(profileEquipmentNames);
    return requiredEquipmentNames(definition).every(availableNames.contains);
  }

  static bool usesEquipmentName(
    ExerciseDefinition definition,
    String equipmentName,
  ) {
    final normalizedName = normalizeName(equipmentName);
    return normalizedName.isNotEmpty &&
        requiredEquipmentNames(definition).contains(normalizedName);
  }

  static Set<String> requiredEquipmentNames(ExerciseDefinition definition) {
    final names = <String>{};
    for (final equipment in definition.equipmentList) {
      final name = normalizeName(equipment.name);
      if (name.isNotEmpty) names.add(name);
    }
    return names;
  }

  static Set<String> normalizeNames(Iterable<String> names) {
    final normalizedNames = <String>{};
    for (final name in names) {
      final normalizedName = normalizeName(name);
      if (normalizedName.isNotEmpty) normalizedNames.add(normalizedName);
    }
    return normalizedNames;
  }

  static String normalizeName(String name) => name.trim().toLowerCase();
}
