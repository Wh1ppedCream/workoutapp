// File: lib/providers/onboarding_provider.dart

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/preference_writer.dart';
import '../utils/serial_async_queue.dart';

class OnboardingConfig extends ChangeNotifier {
  // Legacy key retained so older installs that had replay enabled migrate
  // into the new "show once, then turn off" behavior.
  static const _kAlwaysShow = 'always_show_onboarding';
  static const _kCompleted = 'onboarding_completed';

  bool _initialized = false;
  bool _completed = false;
  bool _disposed = false;
  Future<void>? _initializing;
  final _mutations = SerialAsyncQueue();

  bool get initialized => _initialized;
  bool get completed => _completed;
  bool get showOnboarding => !_completed;

  Future<void> init() => _initializing ??= _load();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (_disposed) return;
    final legacyAlwaysShow = prefs.getBool(_kAlwaysShow) ?? false;
    _completed = prefs.getBool(_kCompleted) ?? false;
    if (legacyAlwaysShow) {
      _completed = false;
      try {
        await writePreferences(prefs, {
          _kAlwaysShow: false,
          _kCompleted: false,
        });
      } catch (_) {
        // Replay remains available this launch; finishing setup retries storage.
      }
    }
    if (_disposed) return;
    _initialized = true;
    notifyListeners();
  }

  Future<void> setShowOnboarding(bool value) => _mutations.run(() async {
    if (_disposed) return;
    await init();
    if (_disposed) return;
    final prefs = await SharedPreferences.getInstance();
    await writePreferences(prefs, {_kCompleted: !value, _kAlwaysShow: false});
    if (_disposed) return;
    _completed = !value;
    notifyListeners();
  });

  Future<void> markCompleted() => setShowOnboarding(false);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
