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
    'workoutDashboard',
    'historySummary', 
    'sessionList',
  ];

  // initialize immediately so we can read them before prefs load
  List<String> _widgetOrder;
  Set<String> _hiddenWidgets;

  DashboardConfig()
      : _widgetOrder = List.from([
        'quickBar',
        'nutritionDash',
        'workoutDashboard',
          'historySummary', 
          'sessionList',
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
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    _widgetOrder   = List<String>.from(data['order']);
    _hiddenWidgets = Set<String>.from(data['hidden']);
    
    // ─── Ensure all newly-added defaults appear ─────────────────
    for (var id in defaultOrder) {
      if (!_widgetOrder.contains(id)) {
        _widgetOrder.add(id);
      }
    }
  } 
  // else: keep the initial defaults you set in the constructor
  notifyListeners();
}


  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'order': _widgetOrder,
      'hidden': _hiddenWidgets.toList(),
    };
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

  void reorder(int oldIndex, int newIndex) {
    final id = _widgetOrder.removeAt(oldIndex);
    _widgetOrder.insert(newIndex, id);
    _save();
    notifyListeners();
  }
}