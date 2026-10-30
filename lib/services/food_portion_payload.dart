import '../utils/editable_number.dart';

/// Parsed editor values, independent of text controllers and widget state.
class FoodPortionDraft {
  const FoodPortionDraft({
    required this.unit,
    this.amount,
    this.grams,
    this.milliliters,
    this.measureName,
    this.label,
  });

  final String unit;
  final double? amount;
  final double? grams;
  final double? milliliters;
  final String? measureName;
  final String? label;
}

/// Converts the two portion groups to the existing persistence payload.
/// Explicit weights/volumes take precedence; unusable rows retain the existing
/// first-valid-default / 100 g fallback behavior.
List<Map<String, dynamic>> buildFoodPortionPayload({
  required List<FoodPortionDraft> basis,
  required List<FoodPortionDraft> usual,
  String defaultGroup = 'basis',
  int basisDefaultIndex = 0,
  int usualDefaultIndex = 0,
  double? densityGPerMl,
}) {
  final selectedGroup = defaultGroup == 'usual' && usual.isNotEmpty
      ? 'usual'
      : basis.isNotEmpty
      ? 'basis'
      : 'usual';
  final selectedRows = selectedGroup == 'basis' ? basis : usual;
  final selectedIndex = selectedRows.isEmpty
      ? -1
      : (selectedGroup == 'basis' ? basisDefaultIndex : usualDefaultIndex)
            .clamp(0, selectedRows.length - 1);
  final rows = <Map<String, dynamic>>[];
  for (final group in [('basis', basis), ('usual', usual)]) {
    for (final entry in group.$2.indexed) {
      final draft = entry.$2;
      final unit = _shortUnit(draft.unit);
      final amount = draft.amount;
      double? grams = draft.grams;
      double? ml = draft.milliliters;
      if (grams == null && amount != null) {
        grams = switch (unit) {
          'g' => amount,
          'mg' => amount / 1000,
          'µg' => amount / 1000000,
          'kg' => amount * 1000,
          'oz' => amount * 28.349523125,
          'lb' => amount * 453.59237,
          _ => null,
        };
      }
      if (ml == null && amount != null) {
        ml = switch (unit) {
          'mL' => amount,
          'L' => amount * 1000,
          'tsp' => amount * 5,
          'tbsp' => amount * 15,
          'cup' => amount * 240,
          'fl oz' => amount * 29.5735295625,
          _ => null,
        };
      }
      if (grams == null && ml != null && densityGPerMl != null) {
        grams = ml * densityGPerMl;
      }
      if (grams == null && ml == null) continue;

      final namedAmount =
          amount ??
          (unit == 'g'
              ? draft.grams
              : unit == 'mL'
              ? draft.milliliters
              : null);
      rows.add({
        'measure_name':
            draft.measureName ??
            (namedAmount == null
                ? unit
                : '${editableNumber(namedAmount)} $unit'),
        'gram_weight': grams,
        'ml_volume': ml,
        'is_default': group.$1 == selectedGroup && entry.$1 == selectedIndex,
        'list_kind': group.$1,
        'sort_order': entry.$1,
        'amount': amount,
        'unit': unit,
        'label': draft.label,
      });
    }
  }
  if (rows.isEmpty) {
    rows.add({
      'measure_name': '100 g',
      'gram_weight': 100.0,
      'ml_volume': null,
      'is_default': true,
      'list_kind': 'basis',
      'sort_order': 0,
      'amount': 100.0,
      'unit': 'g',
      'label': null,
    });
  } else if (!rows.any((row) => row['is_default'] == true)) {
    rows.first['is_default'] = true;
  }
  return rows;
}

String _shortUnit(String unit) => switch (unit) {
  'gram (g)' => 'g',
  'milligram (mg)' => 'mg',
  'microgram (µg)' || 'microgram (mcg)' => 'µg',
  'kilogram (kg)' => 'kg',
  'ounce (oz)' => 'oz',
  'pound (lb)' => 'lb',
  'milliliter (mL)' => 'mL',
  'liter (L)' => 'L',
  'teaspoon (tsp)' => 'tsp',
  'tablespoon (tbsp)' => 'tbsp',
  'fluid ounce (fl oz)' => 'fl oz',
  _ => unit,
};
