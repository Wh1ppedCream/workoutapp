import '../models/unit_preference.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'localized_digit_formatter.dart';

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
    Locale? locale,
  }) {
    final value = _displayWeightValue(pounds, unit);
    final text = _formatNumber(
      value,
      unit == WeightUnit.kilograms ? 1 : 0,
      locale,
    );
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
      WeightUnit.kilograms => _roundToIncrement(
        value,
        _kgWeightDisplayIncrement,
      ),
    };
  }

  static double _roundToIncrement(double value, double increment) {
    if (increment <= 0) return value;
    return (value / increment).roundToDouble() * increment;
  }

  static String formatVolume(double pounds, WeightUnit unit, {Locale? locale}) {
    final value = fromPounds(pounds, unit);
    final abs = value.abs();
    if (abs >= 1000000) {
      return '${_formatNumber(value / 1000000, 1, locale, true)}M ${unit.shortLabel}';
    }
    if (abs >= 1000) {
      final digits = abs >= 10000 ? 0 : 1;
      return '${_formatNumber(value / 1000, digits, locale, true)}k ${unit.shortLabel}';
    }
    return '${_formatNumber(value.roundToDouble(), 0, locale)} ${unit.shortLabel}';
  }

  static String formatCompactVolumeValue(
    double pounds,
    WeightUnit unit, {
    Locale? locale,
  }) {
    final value = fromPounds(pounds, unit);
    final abs = value.abs();
    if (abs >= 1000000) {
      return '${_formatNumber(value / 1000000, 1, locale, true)}M';
    }
    if (abs >= 1000) {
      final digits = abs >= 10000 ? 0 : 1;
      return '${_formatNumber(value / 1000, digits, locale, true)}k';
    }
    return _formatNumber(value.roundToDouble(), 0, locale);
  }

  static String _formatNumber(
    double value,
    int maxDecimals, [
    Locale? locale,
    bool forceFractionDigits = false,
  ]) {
    if (!forceFractionDigits &&
        (maxDecimals == 0 || value == value.roundToDouble())) {
      if (locale == null) return value.round().toString();
      return preserveWesternDigits(
        NumberFormat.decimalPattern(
          locale.toLanguageTag(),
        ).format(value.round()),
        locale,
      );
    }
    if (locale == null) return value.toStringAsFixed(maxDecimals);
    final formatter =
        NumberFormat.decimalPattern(locale.toLanguageTag())
          ..minimumFractionDigits = maxDecimals
          ..maximumFractionDigits = maxDecimals;
    return preserveWesternDigits(formatter.format(value), locale);
  }
}
