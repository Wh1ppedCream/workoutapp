// File: lib/screens/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/active_session.dart';
import '../providers/dashboard_config.dart';
import '../widgets/current_metrics_section.dart';
import '../widgets/data_records_section.dart';
import '../widgets/health_trends_section.dart';
import '../widgets/history_summary_widget.dart';
import '../widgets/nutrition_dash.dart';
import '../widgets/past_sessions_list.dart';
import '../widgets/quick_bar.dart';
import '../widgets/workout_dashboard.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isEditing = false;
  bool _hasShownHint = false;
  int _historyRefreshToken = 0;
  int? _seenCompletedSessionVersion;

  void _refreshHistoryWidgets() {
    setState(() => _historyRefreshToken++);
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<DashboardConfig>();
    final completedSessionVersion = context.select<ActiveSession, int>(
      (session) => session.completedSessionVersion,
    );
    final visibleIds = config.widgetOrder.where(config.isVisible).toList();

    if (_seenCompletedSessionVersion == null) {
      _seenCompletedSessionVersion = completedSessionVersion;
    } else if (_seenCompletedSessionVersion != completedSessionVersion) {
      _seenCompletedSessionVersion = completedSessionVersion;
      _historyRefreshToken++;
    }

    if (_isEditing && !_hasShownHint) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Drag the handle to reorder, tap the trash icon to remove widgets, or tap + to add back.',
            ),
          ),
        );
      });
      _hasShownHint = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: _isEditing
          ? _buildEditableDashboardList(visibleIds)
          : _buildDashboardScrollView(visibleIds),
    );
  }

  Widget _buildDashboardScrollView(List<String> visibleIds) {
    return SingleChildScrollView(
      key: const PageStorageKey('dashboard_scroll'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < visibleIds.length; i++)
            _buildEditableTile(visibleIds[i], i, false),
        ],
      ),
    );
  }

  Widget _buildEditableDashboardList(List<String> visibleIds) {
    return ReorderableListView(
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        context.read<DashboardConfig>().reorder(oldIndex, newIndex);
      },
      children: [
        for (var i = 0; i < visibleIds.length; i++)
          _buildEditableTile(visibleIds[i], i, true),
        Card(
          key: const ValueKey('add_widget'),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: InkWell(
            onTap: _showAddWidgetDialog,
            child: const SizedBox(
              height: 100,
              child: Center(child: Icon(Icons.add_box, size: 40)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableTile(String id, int index, bool isEditing) {
    final config = context.read<DashboardConfig>();
    final visibleCount = config.widgetOrder.where(config.isVisible).length;
    final tileContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDashboardTile(id),
        if (index < visibleCount - 1)
          const Divider(height: 1, thickness: 1),
      ],
    );

    if (!isEditing) {
      return Container(
        key: ValueKey(id),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: tileContent,
      );
    }

    return Card(
      key: ValueKey(id),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Center(
                    child: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _labelFor(id),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Remove widget',
                      onPressed: () =>
                          context.read<DashboardConfig>().toggleVisibility(id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          tileContent,
        ],
      ),
    );
  }

  Future<void> _showAddWidgetDialog() async {
    final config = context.read<DashboardConfig>();
    final hiddenIds =
        config.widgetOrder.where((id) => !config.isVisible(id)).toList();
    if (hiddenIds.isEmpty) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Widgets'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final id in hiddenIds)
                ListTile(
                  title: Text(_labelFor(id)),
                  onTap: () {
                    context.read<DashboardConfig>().toggleVisibility(id);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTile(String id) {
    switch (id) {
      case 'quickBar':
        return const QuickBar();
      case 'nutritionDash':
        return Padding(
          padding: const EdgeInsets.all(8),
          child: NutritionDash(
            caloriesConsumed: 500,
            calorieGoal: 2000,
            proteinConsumed: 20,
            proteinTarget: 100,
            carbConsumed: 50,
            carbTarget: 200,
            fatConsumed: 10,
            fatTarget: 70,
            scale: 0.7,
          ),
        );
      case 'dataRecords':
        return const DataRecordsSection();
      case 'healthTrends':
        return const HealthTrendsSection();
      case 'workoutDashboard':
        return WorkoutDashboard(
          scale: 0.7,
          onSessionComplete: _refreshHistoryWidgets,
        );
      case 'historySummary':
        return HistorySummaryWidget(refreshToken: _historyRefreshToken);
      case 'sessionList':
        return PastSessionsList(
          key: const ValueKey('sessionList'),
          height: 320,
          refreshToken: _historyRefreshToken,
          onReload: _refreshHistoryWidgets,
        );
      case 'CurrentMetricsSection':
        return const CurrentMetricsSection();
      default:
        return const SizedBox.shrink();
    }
  }

  String _labelFor(String id) {
    switch (id) {
      case 'quickBar':
        return 'Quick Actions';
      case 'nutritionDash':
        return 'Nutrition Dashboard';
      case 'dataRecords':
        return 'Data & Records';
      case 'healthTrends':
        return 'Health Trends';
      case 'workoutDashboard':
        return 'Workout Dashboard';
      case 'historySummary':
        return 'History Summary';
      case 'sessionList':
        return 'Past Sessions List';
      case 'CurrentMetricsSection':
        return 'Current Metrics';
      default:
        return id;
    }
  }
}
