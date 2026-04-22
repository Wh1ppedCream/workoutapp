// File: lib/providers/onboarding_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingConfig extends ChangeNotifier {
  static const _kAlwaysShow  = 'always_show_onboarding';
  static const _kCompleted   = 'onboarding_completed';

  bool _alwaysShow = false;
  bool _completed  = false;

  bool get alwaysShow => _alwaysShow;
  bool get completed  => _completed;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _alwaysShow = prefs.getBool(_kAlwaysShow) ?? false;
    _completed  = prefs.getBool(_kCompleted)  ?? false;
    notifyListeners();
  }

  Future<void> setAlwaysShow(bool v) async {
    _alwaysShow = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAlwaysShow, v);
    notifyListeners();
  }

  Future<void> markCompleted() async {
    _completed = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCompleted, true);
    notifyListeners();
  }
}
