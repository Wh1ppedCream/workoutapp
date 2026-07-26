import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/unit_preference.dart';

class UnitPreferenceProvider extends ChangeNotifier {
  static const _weightUnitKey = 'weight_unit_preference';

  WeightUnit _weightUnit = WeightUnit.pounds;
  bool _loaded = false;
  late final Future<void> ready;

  WeightUnit get weightUnit => _weightUnit;
  bool get loaded => _loaded;

  UnitPreferenceProvider() {
    ready = _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _weightUnit = WeightUnitLabels.fromStorageValue(
      prefs.getString(_weightUnitKey),
    );
    _loaded = true;
    notifyListeners();
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    if (_weightUnit == unit && _loaded) return;
    _weightUnit = unit;
    _loaded = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weightUnitKey, unit.storageValue);
  }
}
