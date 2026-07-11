import 'package:env_test/models/unit_preference.dart';
import 'package:env_test/utils/weight_unit_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeightUnitFormatter', () {
    test('converts pounds to rounded kilograms for display', () {
      expect(
        WeightUnitFormatter.formatInputWeight(150, WeightUnit.kilograms),
        '68',
      );
      expect(
        WeightUnitFormatter.formatWeight(150, WeightUnit.kilograms),
        '68 kg',
      );
    });

    test('keeps pounds rounded to whole working loads', () {
      expect(
        WeightUnitFormatter.formatInputWeight(152.6, WeightUnit.pounds),
        '153',
      );
      expect(
        WeightUnitFormatter.formatVolume(1000, WeightUnit.pounds),
        '1.0k lbs',
      );
    });

    test('formats kilogram volume from stored pounds', () {
      expect(
        WeightUnitFormatter.formatVolume(2205, WeightUnit.kilograms),
        '1.0k kg',
      );
    });

    test('rounds user-entered kilogram values back to stored pounds', () {
      expect(
        WeightUnitFormatter.toPounds(68, WeightUnit.kilograms),
        closeTo(149.9, 0.2),
      );
    });
  });
}
