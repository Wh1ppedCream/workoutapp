import 'package:env_test/models/models.dart';
import 'package:env_test/services/height_unit.dart';
import 'package:env_test/services/measurement_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('equivalent heights share the same value in every display unit', () {
    for (final target in HeightUnit.values) {
      final expected = HeightUnit.feet.convert(6, target);
      expect(HeightUnit.inches.convert(72, target), expected);
      expect(HeightUnit.centimeters.convert(182.88, target), expected);
    }
  });

  test('fractional feet and inches retain precision', () {
    expect(HeightUnit.feet.convert(5.5, HeightUnit.inches), 66);
    expect(HeightUnit.inches.convert(71.125, HeightUnit.centimeters), 180.6575);
    expect(HeightUnit.centimeters.convert(180.6575, HeightUnit.inches), 71.125);
    expect(HeightUnit.inches.convert(71.125, HeightUnit.inches), 71.125);
  });

  test('recognizes height unit names without accepting unrelated units', () {
    expect(HeightUnit.tryParse(' FEET '), HeightUnit.feet);
    expect(HeightUnit.tryParse('inches'), HeightUnit.inches);
    expect(HeightUnit.tryParse('centimetres'), HeightUnit.centimeters);
    expect(HeightUnit.tryParse('kg'), isNull);
  });

  test('switching units preserves accepted height boundaries', () {
    for (final original in [
      (31.0, HeightUnit.inches),
      (107.0, HeightUnit.inches),
      (80.0, HeightUnit.centimeters),
      (272.0, HeightUnit.centimeters),
    ]) {
      for (final target in HeightUnit.values) {
        expect(
          () => MeasurementValidation.validateEntry(
            type: MeasurementType.Height,
            value: original.$2.convert(original.$1, target),
            unit: target.symbol,
          ),
          returnsNormally,
          reason: '${original.$1} ${original.$2.symbol} in ${target.symbol}',
        );
      }
    }
  });

  test('height validation accepts standalone feet, inches and centimeters', () {
    for (final input in [
      (6.0, 'ft'),
      (5.5, 'feet'),
      (71.125, 'in'),
      (180.34, 'cm'),
    ]) {
      expect(
        () => MeasurementValidation.validateEntry(
          type: MeasurementType.Height,
          value: input.$1,
          unit: input.$2,
        ),
        returnsNormally,
      );
    }
    for (final value in [0.0, -6.0, 12.0, double.nan, double.infinity]) {
      expect(
        () => MeasurementValidation.validateEntry(
          type: MeasurementType.Height,
          value: value,
          unit: 'ft',
        ),
        throwsA(isA<MeasurementValidationException>()),
      );
    }
  });
}
