import 'package:env_test/models/models.dart';
import 'package:env_test/services/measurement_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('body-weight limits distinguish pounds from kilograms', () {
    expect(MeasurementValidation.bodyWeightRange(' LBS '), (
      min: 44.0,
      max: 1100.0,
    ));
    expect(MeasurementValidation.bodyWeightRange('kilograms'), (
      min: 20.0,
      max: 500.0,
    ));
    for (final value in [44.0, 70.0, 95.0, 1100.0]) {
      expect(
        () => MeasurementValidation.validateEntry(
          type: MeasurementType.BodyWeight,
          value: value,
          unit: 'lbs',
        ),
        returnsNormally,
      );
    }
    expect(
      () => MeasurementValidation.validateEntry(
        type: MeasurementType.BodyWeight,
        value: 25,
        unit: 'lbs',
      ),
      throwsA(
        isA<MeasurementValidationException>().having(
          (error) => error.error,
          'error',
          MeasurementValidationError.implausibleValue,
        ),
      ),
    );
    expect(
      () => MeasurementValidation.validateEntry(
        type: MeasurementType.BodyWeight,
        value: 25,
        unit: 'kg',
      ),
      returnsNormally,
    );
  });

  test('normalizes custom metric names and validates custom units', () {
    expect(
      MeasurementValidation.normalizeDefinitionName('  Left   bicep  '),
      'Left bicep',
    );

    expect(
      () => MeasurementValidation.validateDefinition(
        name: 'Left bicep',
        unit: 'cm',
      ),
      returnsNormally,
    );
    expect(
      () => MeasurementValidation.validateDefinition(
        name: 'Left bicep',
        unit: 'body fat %',
      ),
      throwsA(
        isA<MeasurementValidationException>().having(
          (error) => error.error,
          'error',
          MeasurementValidationError.invalidUnit,
        ),
      ),
    );
  });

  test('enforces type-specific measurement units and plausible ranges', () {
    expect(
      () => MeasurementValidation.validateEntry(
        type: MeasurementType.Height,
        value: 180,
        unit: 'cm',
      ),
      returnsNormally,
    );
    expect(
      () => MeasurementValidation.validateEntry(
        type: MeasurementType.Height,
        value: 180,
        unit: 'kg',
      ),
      throwsA(isA<MeasurementValidationException>()),
    );
    expect(
      () => MeasurementValidation.validateEntry(
        type: MeasurementType.BodyWeight,
        value: -1,
        unit: 'kg',
      ),
      throwsA(isA<MeasurementValidationException>()),
    );
    expect(
      () => MeasurementValidation.validateEntry(
        type: MeasurementType.Waist,
        value: 300,
        unit: 'cm',
      ),
      throwsA(
        isA<MeasurementValidationException>().having(
          (error) => error.error,
          'error',
          MeasurementValidationError.implausibleValue,
        ),
      ),
    );
  });

  test('uses structured context and recognizes legacy context notes', () {
    expect(
      MeasurementValidation.legacyContextFor(
        type: MeasurementType.BodyWeight,
        note: 'WakeUp',
      ),
      MeasurementContext.wakeUp,
    );
    expect(
      MeasurementValidation.legacyContextFor(
        type: MeasurementType.Waist,
        note: 'With pump',
      ),
      MeasurementContext.withPump,
    );
    expect(
      () => MeasurementValidation.validateEntry(
        type: MeasurementType.Height,
        value: 170,
        unit: 'cm',
        context: MeasurementContext.withPump,
      ),
      throwsA(
        isA<MeasurementValidationException>().having(
          (error) => error.error,
          'error',
          MeasurementValidationError.invalidContext,
        ),
      ),
    );
  });
}
