import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _compileTimeExperimentalTabs = String.fromEnvironment(
  'TONOS_ENABLE_EXPERIMENTAL_TABS',
);

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
  /// Tabs whose product workflows are still under construction.
  bool get isExperimental => switch (this) {
    TabItem.nutritionLog ||
    TabItem.combinedHistory ||
    TabItem.formAndPosing => true,
    _ => false,
  };

  /// Stable persisted identifier. Display text must never be used for storage.
  String get storageKey => switch (this) {
    TabItem.train => 'train',
    TabItem.train2 => 'train2',
    TabItem.catalog => 'catalog',
    TabItem.history => 'history',
    TabItem.measurementsTrends => 'progress',
    TabItem.profile => 'profile',
    TabItem.dashboard => 'dashboard',
    TabItem.nutrition => 'nutrition',
    TabItem.nutritionLog => 'nutrition_log',
    TabItem.combinedHistory => 'combined_history',
    TabItem.formAndPosing => 'form_and_posing',
  };

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

class NavigationBuildPolicyException implements Exception {
  const NavigationBuildPolicyException(this.message);

  final String message;

  @override
  String toString() => 'NavigationBuildPolicyException: $message';
}

/// Controls whether unfinished tab destinations can be exposed by this build.
///
/// Public release builds always deny experimental tabs. Debug builds keep them
/// available for development, while profile builds require an explicit define.
class NavigationBuildPolicy {
  const NavigationBuildPolicy({
    required this.experimentalTabsEnabled,
    required this.isReleaseMode,
  });

  final bool experimentalTabsEnabled;
  final bool isReleaseMode;

  factory NavigationBuildPolicy.fromCompileTime({
    bool? releaseMode,
    bool? debugMode,
  }) {
    final effectiveReleaseMode = releaseMode ?? kReleaseMode;
    final effectiveDebugMode = debugMode ?? kDebugMode;

    return NavigationBuildPolicy(
      experimentalTabsEnabled: _parseExperimentalTabsSetting(
        _compileTimeExperimentalTabs,
        fallback: effectiveDebugMode,
      ),
      isReleaseMode: effectiveReleaseMode,
    );
  }

  bool allows(TabItem tab) =>
      !tab.isExperimental || (!isReleaseMode && experimentalTabsEnabled);

  static bool _parseExperimentalTabsSetting(
    String value, {
    required bool fallback,
  }) {
    switch (value.trim().toLowerCase()) {
      case '':
        return fallback;
      case 'true':
        return true;
      case 'false':
        return false;
      default:
        throw const NavigationBuildPolicyException(
          'TONOS_ENABLE_EXPERIMENTAL_TABS must be true or false.',
        );
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

  NavBarConfig({NavigationBuildPolicy? buildPolicy})
    : _buildPolicy = buildPolicy ?? NavigationBuildPolicy.fromCompileTime() {
    _load();
  }

  final NavigationBuildPolicy _buildPolicy;

  List<TabItem> get order => List.unmodifiable(_availableTabs(_order));
  Set<TabItem> get enabledTabs =>
      Set.unmodifiable(_enabled.where(_buildPolicy.allows).toSet());
  bool get loaded => _loaded;

  /// Tabs to display in the bottom bar.
  List<TabItem> get items =>
      _availableTabs(_order).where(_enabled.contains).toList();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedOrder = prefs.getStringList(_keyOrder);
    if (savedOrder != null) {
      _order = savedOrder.map(_tabFromStorage).whereType<TabItem>().toList();

      for (final tab in _defaultOrder) {
        if (!_order.contains(tab)) {
          _order.add(tab);
        }
      }
    }

    final savedEnabled = prefs.getStringList(_keyEnabled);
    if (savedEnabled != null) {
      _enabled = savedEnabled.map(_tabFromStorage).whereType<TabItem>().toSet();
      _enabled.add(TabItem.profile);
    }

    _loaded = true;
    notifyListeners();
  }

  TabItem? _tabFromStorage(String value) {
    for (final tab in TabItem.values) {
      if (tab.storageKey == value ||
          tab.name == value ||
          tab.toString() == value) {
        return tab;
      }
    }
    return null;
  }

  Future<void> update({
    required List<TabItem> newOrder,
    required Set<TabItem> newEnabled,
  }) async {
    final availableOrder = _availableTabs(newOrder);
    final unavailableOrder = _order.where((tab) => !_buildPolicy.allows(tab));
    _order = _completeOrder([...availableOrder, ...unavailableOrder]);
    _enabled =
        newEnabled.where(_buildPolicy.allows).toSet()..add(TabItem.profile);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyOrder,
      _order.map((e) => e.storageKey).toList(),
    );
    await prefs.setStringList(
      _keyEnabled,
      _enabled.map((e) => e.storageKey).toList(),
    );
  }

  List<TabItem> _availableTabs(Iterable<TabItem> tabs) =>
      tabs.where(_buildPolicy.allows).toList();

  List<TabItem> _completeOrder(Iterable<TabItem> tabs) {
    final complete = <TabItem>[];
    for (final tab in [...tabs, ..._defaultOrder]) {
      if (!complete.contains(tab)) {
        complete.add(tab);
      }
    }
    return complete;
  }
}
