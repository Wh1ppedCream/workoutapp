// file: lib/providers/dashboard_config.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardConfig extends ChangeNotifier {
  static const _prefsKey = 'dashboard_config';

  static const List<String> defaultOrder = <String>[
    'quickActions',
    'training',
    'nutritionDash',
    'dataRecords',
    'weeklyFocus',
    'workoutMetrics',
    'exerciseProgress',
    'historySummary',
    'healthTrends',
    'recentWorkouts',
    'activePlans',
    'archivedPlans',
    'premadePlans',
    'planTools',
    'exerciseCatalog',
    'targetAnatomy',
  ];

  /// Extra home-tab modules stay available without making a fresh Dashboard
  /// overwhelming. Users can show them from Customize Dashboard at any time.
  static const Set<String> defaultHiddenWidgets = <String>{
    'workoutMetrics',
    'activePlans',
    'archivedPlans',
    'premadePlans',
    'planTools',
    'exerciseCatalog',
    'targetAnatomy',
  };

  static const Map<String, String> _legacyWidgetIds = <String, String>{
    'quickBar': 'quickActions',
    'workoutDashboard': 'training',
    'sessionList': 'recentWorkouts',
  };

  List<String> _widgetOrder = List<String>.from(defaultOrder);
  Set<String> _hiddenWidgets = Set<String>.from(defaultHiddenWidgets);

  DashboardConfig() {
    _load();
  }

  List<String> get widgetOrder => List<String>.unmodifiable(_widgetOrder);

  bool isVisible(String id) => !_hiddenWidgets.contains(id);

  bool isSupported(String id) => defaultOrder.contains(id);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      try {
        final decoded = json.decode(jsonStr);
        if (decoded is! Map) throw const FormatException('Invalid layout');
        final data = Map<String, dynamic>.from(decoded);
        final normalized = normalizeLayout(
          rawOrder: data['order'],
          rawHidden: data['hidden'],
        );
        _widgetOrder = normalized.order;
        _hiddenWidgets = normalized.hidden;

        if (jsonStr != _encode()) {
          await _save(prefs);
        }
      } catch (_) {
        _widgetOrder = List<String>.from(defaultOrder);
        _hiddenWidgets = Set<String>.from(defaultHiddenWidgets);
      }
    }
    // else: keep the initial defaults you set in the constructor
    notifyListeners();
  }

  /// Makes stored layouts safe to use after dashboard sections change.
  ///
  /// Older configurations are migrated rather than discarded so a person's
  /// chosen ordering remains useful after an app update.
  @visibleForTesting
  static DashboardLayout normalizeLayout({
    Object? rawOrder,
    Object? rawHidden,
  }) {
    final order = <String>[];
    if (rawOrder is Iterable) {
      for (final rawId in rawOrder) {
        final id = _legacyWidgetIds[rawId.toString()] ?? rawId.toString();
        if (defaultOrder.contains(id) && !order.contains(id)) {
          order.add(id);
        }
      }
    }
    final hidden = <String>{};
    if (rawHidden is Iterable) {
      for (final rawId in rawHidden) {
        final id = _legacyWidgetIds[rawId.toString()] ?? rawId.toString();
        if (defaultOrder.contains(id)) hidden.add(id);
      }
    }
    for (final id in defaultOrder) {
      if (order.contains(id)) continue;
      order.add(id);
      if (defaultHiddenWidgets.contains(id)) {
        hidden.add(id);
      }
    }
    return DashboardLayout(order: order, hidden: hidden);
  }

  Future<void> _save([SharedPreferences? preferences]) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _encode());
  }

  String _encode() => json.encode(<String, Object>{
    'order': _widgetOrder,
    'hidden': _hiddenWidgets.toList()..sort(),
  });

  Future<void> toggleVisibility(String id) async {
    if (!isSupported(id)) return;
    if (_hiddenWidgets.contains(id)) {
      _hiddenWidgets.remove(id);
    } else {
      _hiddenWidgets.add(id);
    }
    await _save();
    notifyListeners();
  }

  Future<void> restoreDefaults() async {
    _widgetOrder = List<String>.from(defaultOrder);
    _hiddenWidgets = Set<String>.from(defaultHiddenWidgets);
    await _save();
    notifyListeners();
  }

  Future<void> reorder(int oldVisibleIndex, int newVisibleIndex) async {
    // 1. Build the visible‐only list
    final visible =
        _widgetOrder.where((id) => !_hiddenWidgets.contains(id)).toList();
    if (oldVisibleIndex < 0 ||
        oldVisibleIndex >= visible.length ||
        newVisibleIndex < 0) {
      return;
    }

    final movingId = visible.removeAt(oldVisibleIndex);
    _widgetOrder.remove(movingId);

    final insertAt = newVisibleIndex.clamp(0, visible.length).toInt();
    if (insertAt >= visible.length) {
      _widgetOrder.add(movingId);
    } else {
      final pivotId = visible[insertAt];
      _widgetOrder.insert(_widgetOrder.indexOf(pivotId), movingId);
    }

    await _save();
    notifyListeners();
  }
}

@immutable
class DashboardLayout {
  final List<String> order;
  final Set<String> hidden;

  const DashboardLayout({required this.order, required this.hidden});
}
