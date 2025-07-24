// lib/providers/nav_bar_config.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

enum TabItem {
  dashboard,
  train,
  history,              // now “Workout Log”
  nutrition,
  profile,
  measurementsTrends,   // M&T
  nutritionLog,         // N.Log
  combinedHistory,      // History (Combined)
  formAndPosing         // F&P
}

extension TabItemExtension on TabItem {
  /// Full page titles & settings‐page labels
  String get title {
    switch (this) {
      case TabItem.dashboard:
        return 'Dashboard';
      case TabItem.train:
        return 'Train';
      case TabItem.history:
        return 'Workout Log';
      case TabItem.nutrition:
        return 'Nutrition';
      case TabItem.profile:
        return 'Profile';
      case TabItem.measurementsTrends:
        return 'Measurements and Trends';
      case TabItem.nutritionLog:
        return 'Nutrition Log';
      case TabItem.combinedHistory:
        return 'Combined History';
      case TabItem.formAndPosing:
        return 'Form and Posing';
      
    }
  }

  /// Under-icon label for the bottom bar
  String get bottomLabel {
    switch (this) {
      /*SHORTENED LABELS IF NEEDED
      case TabItem.history:
       return 'W.Log';              // short form for nav bar
 case TabItem.measurementsTrends:
       return 'M&T';
      case TabItem.nutritionLog:
        return 'N.Log';
      case TabItem.combinedHistory:
        return 'History';
      case TabItem.formAndPosing:
        return 'F&P';
      */
      default:
        return title;
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
      case TabItem.measurementsTrends:
        return Icons.straighten;
      case TabItem.nutritionLog:
        return Icons.receipt_long;
      case TabItem.combinedHistory:
        return Icons.timeline;
      case TabItem.formAndPosing:
        return Icons.self_improvement;
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
  Set<TabItem> _enabled = TabItem.values.toSet()
    ..remove(TabItem.history)
    ..remove(TabItem.measurementsTrends)
    ..remove(TabItem.nutritionLog)
    ..remove(TabItem.combinedHistory)
    ..remove(TabItem.formAndPosing);


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
      // restore user’s saved order...
      _order = savedOrder
        .map((s) => TabItem.values.firstWhere((e) => e.toString() == s))
        .toList();
      // …then append any new tabs that weren’t in their prefs
      for (final tab in TabItem.values) {
        if (!_order.contains(tab)) {
          _order.add(tab);
        }
      }
    }

    final savedEnabled = prefs.getStringList(_keyEnabled);
    if (savedEnabled != null) {
      // restore user’s saved enabled set…
      _enabled = savedEnabled
        .map((s) => TabItem.values.firstWhere((e) => e.toString() == s))
        .toSet();
      // …and make sure profile can never be turned off
      _enabled.add(TabItem.profile);
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> update({
    required List<TabItem> newOrder,
    required Set<TabItem> newEnabled,
  }) async {
    // never allow profile to be disabled
    newEnabled.add(TabItem.profile);
    // make sure profile is always on
    newEnabled.add(TabItem.profile);
    _order = newOrder;
    _enabled = newEnabled;
   notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyOrder, _order.map((e) => e.toString()).toList());
    await prefs.setStringList(_keyEnabled, _enabled.map((e) => e.toString()).toList());
  }
}
