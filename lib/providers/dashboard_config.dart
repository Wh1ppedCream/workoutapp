// file: lib/providers/dashboard_config.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardConfig extends ChangeNotifier {
  static const _prefsKey = 'dashboard_config';

  // These IDs must match whatever widget types you define
  final List<String> defaultOrder = [
    'quickBar',
    'nutritionDash',
    'dataRecords',
    'healthTrends',
    'workoutDashboard',
    'historySummary',
    'sessionList',
    'CurrentMetricsSection',
  ];

  // initialize immediately so we can read them before prefs load
  List<String> _widgetOrder;
  Set<String> _hiddenWidgets;

  DashboardConfig()
    : _widgetOrder = List.from([
        'quickBar',
        'nutritionDash',
        'dataRecords',
        'healthTrends',
        'workoutDashboard',
        'historySummary',
        'sessionList',
        'CurrentMetricsSection',
      ]),
      _hiddenWidgets = {} {
    _load();
  }

  List<String> get widgetOrder => List.unmodifiable(_widgetOrder);
  bool isVisible(String id) => !_hiddenWidgets.contains(id);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      try {
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        _widgetOrder = List<String>.from(data['order']);
        _hiddenWidgets = Set<String>.from(data['hidden']);

        // ─── Ensure all newly-added defaults appear ─────────────────
        for (var id in defaultOrder) {
          if (!_widgetOrder.contains(id)) {
            _widgetOrder.add(id);
          }
        }
      } catch (_) {
        // Keep defaults when an older or corrupted value exists.
      }
    }
    // else: keep the initial defaults you set in the constructor
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {'order': _widgetOrder, 'hidden': _hiddenWidgets.toList()};
    await prefs.setString(_prefsKey, json.encode(data));
  }

  void toggleVisibility(String id) {
    if (_hiddenWidgets.contains(id)) {
      _hiddenWidgets.remove(id);
    } else {
      _hiddenWidgets.add(id);
    }
    _save();
    notifyListeners();
  }

  void reorder(int oldVisibleIndex, int newVisibleIndex) {
    // 1. Build the visible‐only list
    final visible =
        _widgetOrder.where((id) => !_hiddenWidgets.contains(id)).toList();

    // 2. Which widget are we actually moving?
    final movingId = visible[oldVisibleIndex];

    // 3. Pull it out of the full order
    _widgetOrder.remove(movingId);

    // 4. Compute its new spot in the *full* list:
    //    If they're dragging to the end of the visible list, just append.
    if (newVisibleIndex >= visible.length - 1) {
      _widgetOrder.add(movingId);
    } else {
      // Otherwise insert it before the pivot visible ID at newVisibleIndex
      final pivotId = visible[newVisibleIndex];
      final pivotFullIndex = _widgetOrder.indexOf(pivotId);
      _widgetOrder.insert(pivotFullIndex, movingId);
    }

    _save();
    notifyListeners();
  }
}
