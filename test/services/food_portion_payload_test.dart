import 'package:env_test/services/food_portion_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final entry in <String, double>{
    'gram (g)': 1,
    'milligram (mg)': 0.001,
    'microgram (µg)': 0.000001,
    'kilogram (kg)': 1000,
    'ounce (oz)': 28.349523125,
    'pound (lb)': 453.59237,
  }.entries) {
    test('${entry.key} portions retain the correct gram conversion', () {
      final rows = buildFoodPortionPayload(
        basis: [FoodPortionDraft(unit: entry.key, amount: 1)],
        usual: const [],
      );
      expect(rows.single['gram_weight'], entry.value);
      expect(rows.single['is_default'], isTrue);
    });
  }
  for (final entry in <String, double>{
    'milliliter (mL)': 1,
    'liter (L)': 1000,
    'teaspoon (tsp)': 5,
    'tablespoon (tbsp)': 15,
    'cup': 240,
    'fluid ounce (fl oz)': 29.5735295625,
  }.entries) {
    test('${entry.key} portions convert volume and apply density', () {
      final rows = buildFoodPortionPayload(
        basis: [FoodPortionDraft(unit: entry.key, amount: 1)],
        usual: const [],
        densityGPerMl: 1.25,
      );
      expect(rows.single['ml_volume'], entry.value);
      expect(rows.single['gram_weight'], entry.value * 1.25);
    });
  }
  test('explicit weight and volume are not replaced by derived amounts', () {
    final row = buildFoodPortionPayload(
      basis: const [
        FoodPortionDraft(
          unit: 'cup',
          amount: 1,
          grams: 125.00125,
          milliliters: 220,
        ),
      ],
      usual: const [],
      densityGPerMl: 2,
    ).single;
    expect(row['gram_weight'], 125.00125);
    expect(row['ml_volume'], 220.0);
  });
  test('selection, group order, names and labels survive serialization', () {
    final rows = buildFoodPortionPayload(
      basis: const [FoodPortionDraft(unit: 'g', amount: 100)],
      usual: const [
        FoodPortionDraft(
          unit: 'g',
          amount: 0.0000001,
          measureName: 'Tiny scoop',
          label: 'My scoop',
        ),
      ],
      defaultGroup: 'usual',
    );
    expect(rows[0]['is_default'], isFalse);
    expect(rows[1], {
      'measure_name': 'Tiny scoop',
      'gram_weight': 0.0000001,
      'ml_volume': null,
      'is_default': true,
      'list_kind': 'usual',
      'sort_order': 0,
      'amount': 0.0000001,
      'unit': 'g',
      'label': 'My scoop',
    });
  });
  test('blank selected rows fall back to the first usable default', () {
    final rows = buildFoodPortionPayload(
      basis: const [FoodPortionDraft(unit: 'g', amount: 50)],
      usual: const [FoodPortionDraft(unit: 'cup')],
      defaultGroup: 'usual',
    );
    expect(rows, hasLength(1));
    expect(rows.single['is_default'], isTrue);
    expect(rows.single['measure_name'], '50 g');
  });
  test('empty input retains the established 100 g default', () {
    final row = buildFoodPortionPayload(
      basis: const [],
      usual: const [],
    ).single;
    expect(row['gram_weight'], 100.0);
    expect(row['measure_name'], '100 g');
    expect(row['is_default'], isTrue);
  });
  test('missing amounts use explicit grams or milliliters for the name', () {
    final rows = buildFoodPortionPayload(
      basis: const [
        FoodPortionDraft(unit: 'g', grams: 0.0000001),
        FoodPortionDraft(unit: 'mL', milliliters: 125.125),
      ],
      usual: const [],
      basisDefaultIndex: 99,
    );
    expect(rows.first['measure_name'], '0.0000001 g');
    expect(rows.last['measure_name'], '125.125 mL');
    expect(rows.last['is_default'], isTrue);
  });
}
