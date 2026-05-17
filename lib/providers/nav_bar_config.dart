import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TabItem {
  train,
  train2,
  catalog,
  history,
  measurementsTrends,
  profile,
  dashboard,
  nutrition,
  nutritionLog,
  combinedHistory,
  formAndPosing,
}

extension TabItemExtension on TabItem {
  /// Full page titles and settings-page labels.
  String get title {
    switch (this) {
      case TabItem.train:
        return 'Train';
      case TabItem.train2:
        return 'Train2';
      case TabItem.catalog:
        return 'Catalog';
      case TabItem.history:
        return 'Logbook';
      case TabItem.measurementsTrends:
        return 'Progress';
      case TabItem.profile:
        return 'Profile';
      case TabItem.dashboard:
        return 'Dashboard';
      case TabItem.nutrition:
        return 'Nutrition';
      case TabItem.nutritionLog:
        return 'Nutrition Log';
      case TabItem.combinedHistory:
        return 'Combined History';
      case TabItem.formAndPosing:
        return 'Form and Posing';
    }
  }

  /// Under-icon label for the bottom bar.
  String get bottomLabel => title;

  IconData get icon {
    switch (this) {
      case TabItem.train:
        return Icons.fitness_center;
      case TabItem.train2:
        return Icons.fitness_center_outlined;
      case TabItem.catalog:
        return Icons.menu_book;
      case TabItem.history:
        return Icons.history;
      case TabItem.measurementsTrends:
        return Icons.trending_up;
      case TabItem.profile:
        return Icons.person;
      case TabItem.dashboard:
        return Icons.dashboard;
      case TabItem.nutrition:
        return Icons.restaurant;
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

  static const List<TabItem> _defaultOrder = [
    TabItem.train,
    TabItem.catalog,
    TabItem.history,
    TabItem.measurementsTrends,
    TabItem.profile,
    TabItem.train2,
    TabItem.dashboard,
    TabItem.nutrition,
    TabItem.nutritionLog,
    TabItem.combinedHistory,
    TabItem.formAndPosing,
  ];

  static const Set<TabItem> _defaultEnabled = {
    TabItem.train,
    TabItem.catalog,
    TabItem.history,
    TabItem.measurementsTrends,
    TabItem.profile,
  };

  // User-defined order of all tabs.
  List<TabItem> _order = List.of(_defaultOrder);

  // First install defaults: Train, Catalog, Logbook, Progress, Profile.
  Set<TabItem> _enabled = Set.of(_defaultEnabled);

  bool _loaded = false;

  List<TabItem> get order => List.unmodifiable(_order);
  Set<TabItem> get enabledTabs => Set.unmodifiable(_enabled);
  bool get loaded => _loaded;

  /// Tabs to display in the bottom bar.
  List<TabItem> get items =>
      _order.where((tab) => _enabled.contains(tab)).toList();

  NavBarConfig() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedOrder = prefs.getStringList(_keyOrder);
    if (savedOrder != null) {
      _order =
          savedOrder
              .map((s) => TabItem.values.firstWhere((e) => e.toString() == s))
              .toList();

      for (final tab in _defaultOrder) {
        if (!_order.contains(tab)) {
          _order.add(tab);
        }
      }
    }

    final savedEnabled = prefs.getStringList(_keyEnabled);
    if (savedEnabled != null) {
      _enabled =
          savedEnabled
              .map((s) => TabItem.values.firstWhere((e) => e.toString() == s))
              .toSet();
      _enabled.add(TabItem.profile);
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> update({
    required List<TabItem> newOrder,
    required Set<TabItem> newEnabled,
  }) async {
    newEnabled.add(TabItem.profile);
    _order = newOrder;
    _enabled = newEnabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyOrder,
      _order.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      _keyEnabled,
      _enabled.map((e) => e.toString()).toList(),
    );
  }
}
