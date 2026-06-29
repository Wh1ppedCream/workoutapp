// File: lib/providers/onboarding_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingConfig extends ChangeNotifier {
  // Legacy key retained so older installs that had replay enabled migrate
  // into the new "show once, then turn off" behavior.
  static const _kAlwaysShow = 'always_show_onboarding';
  static const _kCompleted = 'onboarding_completed';

  bool _initialized = false;
  bool _completed = false;

  bool get initialized => _initialized;
  bool get completed => _completed;
  bool get showOnboarding => !_completed;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final legacyAlwaysShow = prefs.getBool(_kAlwaysShow) ?? false;
    _completed = prefs.getBool(_kCompleted) ?? false;
    if (legacyAlwaysShow) {
      _completed = false;
      await prefs.setBool(_kAlwaysShow, false);
      await prefs.setBool(_kCompleted, false);
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setShowOnboarding(bool value) async {
    _completed = !value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCompleted, _completed);
    await prefs.setBool(_kAlwaysShow, false);
    notifyListeners();
  }

  Future<void> markCompleted() async {
    _completed = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCompleted, true);
    await prefs.setBool(_kAlwaysShow, false);
    notifyListeners();
  }
}
