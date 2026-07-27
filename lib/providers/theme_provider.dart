// File: lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _defaultMode = ThemeMode.dark;

  ThemeMode _mode = _defaultMode;
  ThemeMode get mode => _mode;

  ThemeProvider() {
    _loadMode();
  }

  Future<void> _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('theme_mode') ?? _defaultMode.name;
    _mode = ThemeMode.values.firstWhere(
      (m) => m.toString().split('.').last == stored,
      orElse: () => _defaultMode,
    );
    notifyListeners();
  }

  Future<void> setMode(ThemeMode newMode) async {
    _mode = newMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', newMode.toString().split('.').last);
  }
}
