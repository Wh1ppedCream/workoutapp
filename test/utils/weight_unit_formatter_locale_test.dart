import 'package:env_test/models/unit_preference.dart';
import 'package:env_test/utils/weight_unit_formatter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'localizes display separators without changing canonical input text',
    () {
      expect(
        WeightUnitFormatter.formatVolume(
          1234.5,
          WeightUnit.pounds,
          locale: const Locale('fr'),
        ),
        '1,2k lbs',
      );
      expect(
        WeightUnitFormatter.formatVolume(
          1000,
          WeightUnit.pounds,
          locale: const Locale('fr'),
        ),
        '1,0k lbs',
      );
      expect(
        WeightUnitFormatter.formatWeight(
          150,
          WeightUnit.kilograms,
          locale: const Locale('fr'),
        ),
        '68 kg',
      );
      expect(
        WeightUnitFormatter.formatInputWeight(1234.5, WeightUnit.pounds),
        '1235',
      );
    },
  );
}
