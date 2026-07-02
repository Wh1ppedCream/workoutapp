enum WeightUnit { pounds, kilograms }

extension WeightUnitLabels on WeightUnit {
  String get storageValue {
    switch (this) {
      case WeightUnit.pounds:
        return 'pounds';
      case WeightUnit.kilograms:
        return 'kilograms';
    }
  }

  String get label {
    switch (this) {
      case WeightUnit.pounds:
        return 'Pounds';
      case WeightUnit.kilograms:
        return 'Kilograms';
    }
  }

  String get shortLabel {
    switch (this) {
      case WeightUnit.pounds:
        return 'lbs';
      case WeightUnit.kilograms:
        return 'kg';
    }
  }

  static WeightUnit fromStorageValue(String? value) {
    return WeightUnit.values.firstWhere(
      (unit) => unit.storageValue == value,
      orElse: () => WeightUnit.pounds,
    );
  }
}
