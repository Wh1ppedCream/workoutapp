// lib/providers/nav_bar_config.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

enum TabItem { dashboard, train, history, nutrition, profile }

extension TabItemExtension on TabItem {
  String get title {
    switch (this) {
      case TabItem.dashboard:
        return 'Dashboard';
      case TabItem.train:
        return 'Train';
      case TabItem.history:
        return 'History';
      case TabItem.nutrition:
        return 'Nutrition';
      case TabItem.profile:
        return 'Profile';
    }
  }

  IconData get icon {
    switch (this) {
      case TabItem.dashboard:
        return Icons.dashboard;
      case TabItem.train:
        return Icons.fitness_center;
      case TabItem.history:
        return Icons.history;
      case TabItem.nutrition:
        return Icons.restaurant;
      case TabItem.profile:
        return Icons.person;
    }
  }
}

class NavBarConfig extends ChangeNotifier {
  static const _keyOrder = 'navBarOrder';
  static const _keyEnabled = 'navBarEnabled';

  // User-defined order of all tabs
  List<TabItem> _order = TabItem.values;

  // Which tabs are enabled (visible)
  // Tabs enabled by default: hide history on first install
  Set<TabItem> _enabled = TabItem.values.where((tab) => tab != TabItem.history).toSet();

  bool _loaded = false;

  /// Public getters
  List<TabItem> get order => List.unmodifiable(_order);
  Set<TabItem> get enabledTabs => Set.unmodifiable(_enabled);
  bool get loaded => _loaded;

  /// Tabs to display in the bottom bar
  List<TabItem> get items => _order.where((tab) => _enabled.contains(tab)).toList();

  NavBarConfig() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedOrder = prefs.getStringList(_keyOrder);
    if (savedOrder != null) {
      _order = savedOrder
        .map((s) => TabItem.values.firstWhere((e) => e.toString() == s))
        .toList();
    }

    final savedEnabled = prefs.getStringList(_keyEnabled);
    if (savedEnabled != null) {
      _enabled = savedEnabled
        .map((s) => TabItem.values.firstWhere((e) => e.toString() == s))
        .toSet();
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> update({
    required List<TabItem> newOrder,
    required Set<TabItem> newEnabled,
  }) async {
    _order = newOrder;
    _enabled = newEnabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyOrder, _order.map((e) => e.toString()).toList());
    await prefs.setStringList(_keyEnabled, _enabled.map((e) => e.toString()).toList());
  }
}
