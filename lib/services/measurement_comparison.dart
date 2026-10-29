import '../models/measurement_models.dart';
import '../models/unit_preference.dart';
import '../utils/weight_unit_formatter.dart';
import 'height_unit.dart';

/// Read-only comparisons; never rewrites a recorded value or its unit.
abstract final class MeasurementComparison {
  static String _unit(String value) => value.trim().toLowerCase();

  static WeightUnit? _massUnit(String unit) => switch (_unit(unit)) {
    'kg' || 'kgs' || 'kilogram' || 'kilograms' => WeightUnit.kilograms,
    'lb' || 'lbs' || 'pound' || 'pounds' => WeightUnit.pounds,
    _ => null,
  };

  static double _stable(double value) =>
      double.parse(value.toStringAsPrecision(12));

  static double? valueInUnit(
    MeasurementType type,
    Measurement entry,
    String targetUnit,
  ) {
    if (type == MeasurementType.BodyWeight || type == MeasurementType.Custom) {
      final source = _massUnit(entry.unit);
      final target = _massUnit(targetUnit);
      if (source != null && target != null) {
        final kilograms = _stable(
          source == WeightUnit.kilograms
              ? entry.value
              : WeightUnitFormatter.fromPounds(
                  entry.value,
                  WeightUnit.kilograms,
                ),
        );
        return target == WeightUnit.kilograms
            ? kilograms
            : _stable(
                WeightUnitFormatter.toPounds(kilograms, WeightUnit.kilograms),
              );
      }
    }
    if (type != MeasurementType.BodyWeight) {
      final source = HeightUnit.tryParse(entry.unit);
      final target = HeightUnit.tryParse(targetUnit);
      if (source != null && target != null) {
        final rawCentimeters = entry.value * source.centimetersPerUnit;
        if (type == MeasurementType.Custom) {
          return _stable(rawCentimeters / target.centimetersPerUnit);
        }
        // Avoid false spikes after decimal feet have been saved and restored.
        final centimeters = double.parse(rawCentimeters.toStringAsFixed(6));
        return HeightUnit.centimeters.convert(centimeters, target);
      }
    }
    // A custom unit such as bpm is comparable to itself, never to an unrelated
    // unit such as %. Unknown legacy units also remain readable in their group.
    return _unit(entry.unit) == _unit(targetUnit) ? entry.value : null;
  }

  static List<Measurement> chartEntries(
    MeasurementType type,
    List<Measurement> entries,
  ) {
    if (entries.isEmpty) return entries;
    final unit = entries.last.unit;
    return entries
        .where((entry) => valueInUnit(type, entry, unit) != null)
        .toList();
  }

  static double? delta(
    MeasurementType type,
    Measurement? latest,
    Measurement? previous,
  ) {
    if (latest == null || previous == null) return null;
    final current = valueInUnit(type, latest, latest.unit);
    final prior = valueInUnit(type, previous, latest.unit);
    if (current == null || prior == null) return null;
    final difference = current - prior;
    return type != MeasurementType.Custom && difference.abs() < 1e-9
        ? 0
        : difference;
  }
}
