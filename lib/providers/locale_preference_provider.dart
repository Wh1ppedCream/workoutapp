import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguagePreference { system, english, canadianFrench }

class LocalePreferenceProvider extends ChangeNotifier {
  static const preferenceKey = 'app_language_preference';

  AppLanguagePreference _preference = AppLanguagePreference.system;
  bool _loaded = false;
  late final Future<void> ready;

  LocalePreferenceProvider() {
    ready = _load();
  }

  AppLanguagePreference get preference => _preference;
  bool get loaded => _loaded;

  /// A null locale lets Flutter follow the device language. Unsupported device
  /// languages fall back to the English ARB declared by the app.
  Locale? get locale => switch (_preference) {
    AppLanguagePreference.system => null,
    AppLanguagePreference.english => const Locale('en'),
    AppLanguagePreference.canadianFrench => const Locale('fr', 'CA'),
  };

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(preferenceKey);
    _preference = AppLanguagePreference.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => AppLanguagePreference.system,
    );
    _loaded = true;
    notifyListeners();
  }

  Future<void> setPreference(AppLanguagePreference preference) async {
    if (_preference == preference && _loaded) return;
    _preference = preference;
    _loaded = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(preferenceKey, preference.name);
  }
}
