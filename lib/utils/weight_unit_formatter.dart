import '../models/unit_preference.dart';

class WeightUnitFormatter {
  static const double kgPerLb = 0.45359237;
  static const double _kgWeightDisplayIncrement = 1.0;

  static double fromPounds(double pounds, WeightUnit unit) {
    switch (unit) {
      case WeightUnit.pounds:
        return pounds;
      case WeightUnit.kilograms:
        return pounds * kgPerLb;
    }
  }

  static double toPounds(double displayWeight, WeightUnit unit) {
    switch (unit) {
      case WeightUnit.pounds:
        return displayWeight;
      case WeightUnit.kilograms:
        return displayWeight / kgPerLb;
    }
  }

  static String formatWeight(
    double pounds,
    WeightUnit unit, {
    bool includeUnit = true,
  }) {
    final value = _displayWeightValue(pounds, unit);
    final text = _formatNumber(value, unit == WeightUnit.kilograms ? 1 : 0);
    return includeUnit ? '$text ${unit.shortLabel}' : text;
  }

  static String formatInputWeight(double pounds, WeightUnit unit) {
    final value = _displayWeightValue(pounds, unit);
    return _formatNumber(value, unit == WeightUnit.kilograms ? 1 : 0);
  }

  static double _displayWeightValue(double pounds, WeightUnit unit) {
    final value = fromPounds(pounds, unit);
    return switch (unit) {
      WeightUnit.pounds => value.roundToDouble(),
      WeightUnit.kilograms =>
        _roundToIncrement(value, _kgWeightDisplayIncrement),
    };
  }

  static double _roundToIncrement(double value, double increment) {
    if (increment <= 0) return value;
    return (value / increment).roundToDouble() * increment;
  }

  static String formatVolume(double pounds, WeightUnit unit) {
    final value = fromPounds(pounds, unit);
    final abs = value.abs();
    if (abs >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M ${unit.shortLabel}';
    }
    if (abs >= 1000) {
      final digits = abs >= 10000 ? 0 : 1;
      return '${(value / 1000).toStringAsFixed(digits)}k ${unit.shortLabel}';
    }
    return '${value.round()} ${unit.shortLabel}';
  }

  static String formatCompactVolumeValue(double pounds, WeightUnit unit) {
    final value = fromPounds(pounds, unit);
    final abs = value.abs();
    if (abs >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (abs >= 1000) {
      final digits = abs >= 10000 ? 0 : 1;
      return '${(value / 1000).toStringAsFixed(digits)}k';
    }
    return value.round().toString();
  }

  static String _formatNumber(double value, int maxDecimals) {
    if (maxDecimals == 0 || value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(maxDecimals);
  }
}
