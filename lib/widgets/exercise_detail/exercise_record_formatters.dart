part of '../exercise_detail_sheet.dart';

double _estimatedOneRm(ExerciseSet set) {
  if (set.reps <= 1) return set.weight;
  return set.weight * (1 + 0.0333 * set.reps);
}

String _formatSet(
  ExerciseSet set,
  WeightUnit weightUnit, {
  Locale? locale,
  bool omitNonPositiveWeight = false,
  String repsLabel = 'reps',
}) {
  final reps = locale == null
      ? set.reps.toString()
      : LocalizedFormatters.number(set.reps, locale, maximumFractionDigits: 0);
  if (omitNonPositiveWeight &&
      (!set.weight.isFinite || set.weight <= 0 || set.reps <= 0)) {
    return '$reps $repsLabel';
  }
  return '${WeightUnitFormatter.formatWeight(set.weight, weightUnit, locale: locale)} x $reps';
}

String _compactWeight(double value, WeightUnit weightUnit, [Locale? locale]) {
  final displayValue = WeightUnitFormatter.fromPounds(value, weightUnit);
  if (displayValue.abs() >= 1000) {
    final digits = displayValue.abs() >= 10000 ? 0 : 1;
    final text = locale == null
        ? (displayValue / 1000).toStringAsFixed(digits)
        : LocalizedFormatters.number(
            displayValue / 1000,
            locale,
            minimumFractionDigits: digits,
            maximumFractionDigits: digits,
          );
    return '${text}k';
  }
  return _cleanNumber(displayValue, locale);
}

String _cleanNumber(double value, [Locale? locale]) {
  final fractionDigits = value == value.roundToDouble() ? 0 : 1;
  if (locale == null) return value.toStringAsFixed(fractionDigits);
  return LocalizedFormatters.number(
    value,
    locale,
    minimumFractionDigits: fractionDigits,
    maximumFractionDigits: fractionDigits,
  );
}
