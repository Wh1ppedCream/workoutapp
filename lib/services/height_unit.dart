/// Supported height units. Stored measurements retain their original unit;
/// comparisons convert values to the same unit without changing the records.
enum HeightUnit {
  centimeters('cm', 1),
  inches('in', 2.54),
  feet('ft', 30.48);

  const HeightUnit(this.symbol, this.centimetersPerUnit);

  final String symbol;
  final double centimetersPerUnit;

  double convert(double value, HeightUnit target) {
    if (this == target) return value;
    // Suppress floating-point noise so equivalent heights form a flat line.
    return double.parse(
      (value * centimetersPerUnit / target.centimetersPerUnit).toStringAsFixed(
        9,
      ),
    );
  }

  static HeightUnit? tryParse(String unit) =>
      switch (unit.trim().toLowerCase()) {
        'cm' ||
        'centimeter' ||
        'centimeters' ||
        'centimetre' ||
        'centimetres' => centimeters,
        'in' || 'inch' || 'inches' => inches,
        'ft' || 'foot' || 'feet' => feet,
        _ => null,
      };
}
