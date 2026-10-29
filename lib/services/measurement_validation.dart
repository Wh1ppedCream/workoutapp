import '../models/measurement_models.dart';
import 'height_unit.dart';

/// Domain validation for measurements. Keep this independent of Flutter so the
/// UI, repository, imports, and database boundary can share the same rules.
enum MeasurementValidationError {
  missingName,
  invalidName,
  duplicateName,
  invalidUnit,
  unsupportedUnit,
  invalidValue,
  implausibleValue,
  invalidContext,
}

class MeasurementValidationException implements Exception {
  final MeasurementValidationError error;

  const MeasurementValidationException(this.error);

  @override
  String toString() => 'MeasurementValidationException($error)';
}

abstract final class MeasurementValidation {
  static const _maxDefinitionNameLength = 48;
  static const _maxUnitLength = 16;

  static String normalizeDefinitionName(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  static String normalizeUnit(String value) => value.trim().toLowerCase();

  static ({double min, double max}) bodyWeightRange(String unit) =>
      _isKilograms(normalizeUnit(unit))
      ? (min: 20, max: 500)
      : (min: 44, max: 1100);

  static void validateDefinition({required String name, required String unit}) {
    validateDefinitionName(name);
    validateCustomUnit(unit);
  }

  static void validateDefinitionName(String name) {
    if (name.isEmpty) {
      throw const MeasurementValidationException(
        MeasurementValidationError.missingName,
      );
    }
    if (name.length > _maxDefinitionNameLength ||
        !RegExp(r'^[^\n\r\t]+$').hasMatch(name)) {
      throw const MeasurementValidationException(
        MeasurementValidationError.invalidName,
      );
    }
  }

  static void validateCustomUnit(String unit) {
    if (unit.isEmpty ||
        unit.length > _maxUnitLength ||
        RegExp(r'\s|[\n\r\t]').hasMatch(unit)) {
      throw const MeasurementValidationException(
        MeasurementValidationError.invalidUnit,
      );
    }
  }

  static void validateEntry({
    required MeasurementType type,
    required double value,
    required String unit,
    MeasurementContext? context,
  }) {
    final normalizedUnit = normalizeUnit(unit);
    if (!value.isFinite || value <= 0) {
      throw const MeasurementValidationException(
        MeasurementValidationError.invalidValue,
      );
    }

    switch (type) {
      case MeasurementType.BodyWeight:
        _requireUnit(normalizedUnit, const {
          'kg',
          'kgs',
          'kilogram',
          'kilograms',
          'lb',
          'lbs',
          'pound',
          'pounds',
        });
        final range = bodyWeightRange(normalizedUnit);
        _requireRange(value, range.min, range.max);
        _requireContext(context, const {
          MeasurementContext.wakeUp,
          MeasurementContext.bedtime,
          MeasurementContext.overall,
        });
      case MeasurementType.Height:
        final heightUnit = HeightUnit.tryParse(normalizedUnit);
        if (heightUnit == null) {
          throw const MeasurementValidationException(
            MeasurementValidationError.unsupportedUnit,
          );
        }
        // One physical range preserves heights accepted by the previous
        // centimeter/inch limits, independent of the selected input unit.
        _requireRange(
          heightUnit.convert(value, HeightUnit.centimeters),
          78.74 - 1e-7,
          272 + 1e-7,
        );
        _requireContext(context, const {});
      case MeasurementType.Forearm:
      case MeasurementType.Arm:
      case MeasurementType.Neck:
      case MeasurementType.Shoulder:
      case MeasurementType.Chest:
      case MeasurementType.Waist:
      case MeasurementType.Hip:
      case MeasurementType.Thigh:
      case MeasurementType.Calf:
        final lengthUnit = HeightUnit.tryParse(normalizedUnit);
        if (lengthUnit == null || lengthUnit == HeightUnit.feet) {
          throw const MeasurementValidationException(
            MeasurementValidationError.unsupportedUnit,
          );
        }
        _requireRange(
          lengthUnit.convert(value, HeightUnit.centimeters),
          2 - 1e-7,
          254 + 1e-7,
        );
        _requireContext(context, const {
          MeasurementContext.withPump,
          MeasurementContext.withoutPump,
        });
      case MeasurementType.Custom:
        validateCustomUnit(normalizedUnit);
        _requireRange(value, 0.000001, 1000000000);
        _requireContext(context, const {});
    }
  }

  static MeasurementContext? legacyContextFor({
    required MeasurementType type,
    required String? note,
  }) {
    final normalizedNote = note?.trim();
    if (type == MeasurementType.BodyWeight) {
      return switch (normalizedNote) {
        'WakeUp' => MeasurementContext.wakeUp,
        'BedTime' => MeasurementContext.bedtime,
        'Overall' => MeasurementContext.overall,
        _ => null,
      };
    }
    if (_bodyPartTypes.contains(type)) {
      return switch (normalizedNote) {
        'With pump' => MeasurementContext.withPump,
        'Without pump' => MeasurementContext.withoutPump,
        _ => null,
      };
    }
    return null;
  }

  static const _bodyPartTypes = <MeasurementType>{
    MeasurementType.Forearm,
    MeasurementType.Arm,
    MeasurementType.Neck,
    MeasurementType.Shoulder,
    MeasurementType.Chest,
    MeasurementType.Waist,
    MeasurementType.Hip,
    MeasurementType.Thigh,
    MeasurementType.Calf,
  };

  static void _requireUnit(String unit, Set<String> supported) {
    if (!supported.contains(unit)) {
      throw const MeasurementValidationException(
        MeasurementValidationError.unsupportedUnit,
      );
    }
  }

  static bool _isKilograms(String unit) =>
      unit == 'kg' ||
      unit == 'kgs' ||
      unit == 'kilogram' ||
      unit == 'kilograms';

  static void _requireRange(double value, double min, double max) {
    if (value < min || value > max) {
      throw const MeasurementValidationException(
        MeasurementValidationError.implausibleValue,
      );
    }
  }

  static void _requireContext(
    MeasurementContext? context,
    Set<MeasurementContext> supported,
  ) {
    if (context != null && !supported.contains(context)) {
      throw const MeasurementValidationException(
        MeasurementValidationError.invalidContext,
      );
    }
  }
}
