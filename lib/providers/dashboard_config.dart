// file: lib/providers/dashboard_config.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/preference_writer.dart';
import '../utils/serial_async_queue.dart';

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
  late final Future<void> ready;
  bool _disposed = false;
  final _mutations = SerialAsyncQueue();

  DashboardConfig() {
    ready = _load();
  }

  List<String> get widgetOrder => List<String>.unmodifiable(_widgetOrder);

  bool isVisible(String id) => !_hiddenWidgets.contains(id);

  bool isSupported(String id) => defaultOrder.contains(id);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (_disposed) return;
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
      } catch (_) {
        _widgetOrder = List<String>.from(defaultOrder);
        _hiddenWidgets = Set<String>.from(defaultHiddenWidgets);
      }
      final layout = _snapshot();
      if (jsonStr != _encode(layout)) {
        try {
          await writePreferences(prefs, {_prefsKey: _encode(layout)});
        } catch (_) {
          // Keep the valid loaded layout; the next explicit edit retries saving.
        }
      }
    }
    if (!_disposed) notifyListeners();
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

  DashboardLayout _snapshot() => DashboardLayout(
    order: List<String>.of(_widgetOrder),
    hidden: Set<String>.of(_hiddenWidgets),
  );

  String _encode(DashboardLayout layout) => json.encode(<String, Object>{
    'order': layout.order,
    'hidden': layout.hidden.toList()..sort(),
  });

  Future<void> _change(DashboardLayout? Function(DashboardLayout) update) =>
      _mutations.run(() async {
        if (_disposed) return;
        await ready;
        if (_disposed) return;
        final next = update(_snapshot());
        if (next == null) return;
        final prefs = await SharedPreferences.getInstance();
        await writePreferences(prefs, {_prefsKey: _encode(next)});
        if (_disposed) return;
        _widgetOrder = next.order;
        _hiddenWidgets = next.hidden;
        notifyListeners();
      });

  Future<void> toggleVisibility(String id) => _change((layout) {
    if (!isSupported(id)) return null;
    if (!layout.hidden.remove(id)) layout.hidden.add(id);
    return layout;
  });

  Future<void> restoreDefaults() => _change(
    (_) => DashboardLayout(
      order: List<String>.from(defaultOrder),
      hidden: Set<String>.from(defaultHiddenWidgets),
    ),
  );

  Future<void> reorder(
    int oldVisibleIndex,
    int newVisibleIndex, {
    bool includeHidden = false,
  }) => _change((layout) {
    final orderedIds = includeHidden
        ? List<String>.of(layout.order)
        : layout.order.where((id) => !layout.hidden.contains(id)).toList();
    if (oldVisibleIndex < 0 ||
        oldVisibleIndex >= orderedIds.length ||
        newVisibleIndex < 0) {
      return null;
    }
    final movingId = orderedIds.removeAt(oldVisibleIndex);
    layout.order.remove(movingId);
    final insertAt = newVisibleIndex.clamp(0, orderedIds.length);
    if (insertAt >= orderedIds.length) {
      layout.order.add(movingId);
    } else {
      layout.order.insert(layout.order.indexOf(orderedIds[insertAt]), movingId);
    }
    return layout;
  });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

@immutable
class DashboardLayout {
  final List<String> order;
  final Set<String> hidden;

  const DashboardLayout({required this.order, required this.hidden});
}
