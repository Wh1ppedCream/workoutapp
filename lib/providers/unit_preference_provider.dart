import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/unit_preference.dart';
import '../services/preference_writer.dart';
import '../utils/serial_async_queue.dart';

class UnitPreferenceProvider extends ChangeNotifier {
  static const _weightUnitKey = 'weight_unit_preference';

  WeightUnit _weightUnit = WeightUnit.pounds;
  bool _loaded = false;
  late final Future<void> ready;
  bool _disposed = false;
  final _mutations = SerialAsyncQueue();

  WeightUnit get weightUnit => _weightUnit;
  bool get loaded => _loaded;

  UnitPreferenceProvider() {
    ready = _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (_disposed) return;
    _weightUnit = WeightUnitLabels.fromStorageValue(
      prefs.getString(_weightUnitKey),
    );
    _loaded = true;
    notifyListeners();
  }

  Future<void> setWeightUnit(WeightUnit unit) => _mutations.run(() async {
    if (_disposed) return;
    await ready;
    if (_disposed) return;
    if (_weightUnit == unit && _loaded) return;
    final prefs = await SharedPreferences.getInstance();
    await writePreferences(prefs, {_weightUnitKey: unit.storageValue});
    if (_disposed) return;
    _weightUnit = unit;
    _loaded = true;
    notifyListeners();
  });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
