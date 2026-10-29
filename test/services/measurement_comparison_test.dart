import 'package:env_test/models/models.dart';
import 'package:env_test/services/measurement_comparison.dart';
import 'package:env_test/services/measurement_validation.dart';
import 'package:flutter_test/flutter_test.dart';

Measurement _entry(double value, String unit, {int id = 1}) => Measurement(
  id: id,
  defId: 1,
  timestamp: DateTime(2026, 1, id),
  value: value,
  unit: unit,
);

void main() {
  test('legacy context is type-aware and trims surrounding whitespace', () {
    expect(
      MeasurementValidation.legacyContextFor(
        type: MeasurementType.BodyWeight,
        note: ' WakeUp ',
      ),
      MeasurementContext.wakeUp,
    );
    expect(
      MeasurementValidation.legacyContextFor(
        type: MeasurementType.Arm,
        note: ' With pump ',
      ),
      MeasurementContext.withPump,
    );
    expect(
      MeasurementValidation.legacyContextFor(
        type: MeasurementType.Custom,
        note: 'WakeUp',
      ),
      isNull,
    );
  });

  test('weight comparisons convert every supported kilogram/pound alias', () {
    for (final kilograms in ['kg', 'kgs', 'kilogram', 'KILOGRAMS']) {
      for (final pounds in ['lb', 'lbs', 'pound', ' POUNDS ']) {
        expect(
          MeasurementComparison.valueInUnit(
            MeasurementType.BodyWeight,
            _entry(140, pounds),
            kilograms,
          ),
          63.5029318,
        );
        expect(
          MeasurementComparison.valueInUnit(
            MeasurementType.BodyWeight,
            _entry(63.5029318, kilograms),
            pounds,
          ),
          140,
        );
        expect(
          MeasurementComparison.delta(
            MeasurementType.BodyWeight,
            _entry(140, pounds),
            _entry(63.5029318, kilograms),
          ),
          0,
        );
      }
    }
  });

  for (final type in MeasurementType.values.where(
    (type) =>
        type != MeasurementType.BodyWeight && type != MeasurementType.Custom,
  )) {
    test('$type compares centimeters and inches as one physical quantity', () {
      expect(
        MeasurementComparison.valueInUnit(type, _entry(10, 'inches'), 'CM'),
        25.4,
      );
      expect(
        MeasurementComparison.valueInUnit(type, _entry(25.4, 'cm'), 'in'),
        10,
      );
      expect(
        MeasurementComparison.delta(type, _entry(10, 'in'), _entry(25.4, 'cm')),
        0,
      );
    });
    if (type != MeasurementType.Height) {
      test(
        '$type accepts equivalent length boundaries and rejects other dimensions',
        () {
          for (final entry in [
            (2.0, 'cm'),
            (2 / 2.54, 'in'),
            (254.0, 'centimeters'),
            (100.0, 'inches'),
          ]) {
            expect(
              () => MeasurementValidation.validateEntry(
                type: type,
                value: entry.$1,
                unit: entry.$2,
              ),
              returnsNormally,
            );
          }
          expect(
            () => MeasurementValidation.validateEntry(
              type: type,
              value: 50,
              unit: 'kg',
            ),
            throwsA(isA<MeasurementValidationException>()),
          );
        },
      );
    }
  }

  test(
    'custom metrics convert known units and retain arbitrary-unit values',
    () {
      expect(
        MeasurementComparison.delta(
          MeasurementType.Custom,
          _entry(140, 'lbs'),
          _entry(63.5029318, 'kg'),
        ),
        0,
      );
      expect(
        MeasurementComparison.delta(
          MeasurementType.Custom,
          _entry(10, 'in'),
          _entry(25.4, 'cm'),
        ),
        0,
      );
      expect(
        MeasurementComparison.delta(
          MeasurementType.Custom,
          _entry(72, 'BPM'),
          _entry(70, ' bpm '),
        ),
        2,
      );
      expect(
        MeasurementComparison.delta(
          MeasurementType.Custom,
          _entry(.000002, 'score'),
          _entry(.000001, 'score'),
        ),
        .000001,
      );
      expect(
        MeasurementComparison.delta(
          MeasurementType.Custom,
          _entry(70, 'bpm'),
          _entry(20, '%'),
        ),
        isNull,
      );
      expect(
        MeasurementComparison.valueInUnit(
          MeasurementType.Custom,
          _entry(1, 'kg'),
          'cm',
        ),
        isNull,
      );
    },
  );

  test('incompatible custom units stay in history but are excluded from the series', () {
    final entries = [
      _entry(60, 'bpm', id: 1),
      _entry(20, '%', id: 2),
      _entry(70, 'bpm', id: 3),
    ];
    final plotted = MeasurementComparison.chartEntries(
      MeasurementType.Custom,
      entries,
    );
    expect(plotted.map((entry) => entry.id), [1, 3]);
    expect(entries.map((entry) => entry.id), [1, 2, 3]);
    expect(entries[1].unit, '%');
  });
}
