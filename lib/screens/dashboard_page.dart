// File: lib/screens/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/active_session.dart';
import '../providers/dashboard_config.dart';
import '../providers/nutrition_profile.dart';
import '../screens/exercise/full_history_screen.dart';
import '../screens/exercise/session_detail_screen.dart';
import '../widgets/data_records_section.dart';
import '../widgets/dashboard_sections.dart';
import '../widgets/exercise_progress_section.dart';
import '../widgets/health_trends_section.dart';
import '../widgets/nutrition_dash.dart';
import '../widgets/workout_history_calendar.dart';
import '../widgets/workout_metric_chart_card.dart';
import '../widgets/workout_dashboard.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isEditing = false;
  int _historyRefreshToken = 0;
  int? _seenCompletedSessionVersion;

  void _refreshHistoryWidgets() {
    if (!mounted) return;
    setState(() => _historyRefreshToken++);
  }

  void _openHistorySession(WorkoutReportSession reportSession) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (_) => SessionDetailScreen(
                  WorkoutSession(
                    id: reportSession.id,
                    date: reportSession.date,
                    duration: reportSession.durationSeconds,
                  ),
                ),
          ),
        )
        .then((_) => _refreshHistoryWidgets());
  }

  void _openFullHistory() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const FullHistoryScreen()))
        .then((_) => _refreshHistoryWidgets());
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

    return Scaffold(
      body: SafeArea(
        child:
            _isEditing
                ? _buildEditableDashboardList(visibleIds)
                : _buildDashboardScrollView(visibleIds),
      ),
    );
  }

  Widget _buildDashboardScrollView(List<String> visibleIds) {
    return ListView(
      key: const PageStorageKey('dashboard_scroll'),
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 28),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DashboardHero(
            isEditing: false,
            onEdit: () => setState(() => _isEditing = true),
          ),
        ),
        const SizedBox(height: 18),
        if (visibleIds.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildEmptyDashboard(),
          )
        else
          for (final id in visibleIds) ...[
            _buildDashboardSection(id),
            const SizedBox(height: 18),
          ],
      ],
    );
  }

  Widget _buildEditableDashboardList(List<String> visibleIds) {
    return ReorderableListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      buildDefaultDragHandles: false,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardHero(
            isEditing: true,
            onEdit: () => setState(() => _isEditing = false),
          ),
          const SizedBox(height: 14),
          Text(
            'Drag sections into the order that works best for you.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: _buildDashboardEditorFooter(),
      ),
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        context.read<DashboardConfig>().reorder(oldIndex, newIndex);
      },
      children: [
        for (var i = 0; i < visibleIds.length; i++)
          _buildEditableTile(visibleIds[i], i),
      ],
    );
  }

  Widget _buildEditableTile(String id, int index) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final details = dashboardSectionDetails(id);
    return Container(
      key: ValueKey(id),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: details.color.withValues(alpha: 0.48)),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: details.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(details.icon, color: details.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Hide section',
            icon: Icon(Icons.visibility_off_outlined, color: scheme.error),
            onPressed:
                () => context.read<DashboardConfig>().toggleVisibility(id),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildDashboardEditorFooter() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final config = context.watch<DashboardConfig>();
    final hiddenCount =
        config.widgetOrder.where((id) => !config.isVisible(id)).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hiddenCount == 0
                ? 'All sections are shown'
                : '$hiddenCount section(s) hidden',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: hiddenCount == 0 ? null : _showAddWidgetDialog,
            icon: const Icon(Icons.add),
            label: const Text('Show hidden sections'),
          ),
          TextButton.icon(
            onPressed: () => context.read<DashboardConfig>().restoreDefaults(),
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text('Reset dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDashboard() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 34,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text('Your dashboard is empty', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Add back any section whenever you are ready.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Customize dashboard'),
          ),
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
      builder:
          (_) => AlertDialog(
            title: const Text('Show hidden sections'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final id in hiddenIds)
                    ListTile(
                      leading: Icon(
                        dashboardSectionDetails(id).icon,
                        color: dashboardSectionDetails(id).color,
                      ),
                      title: Text(_labelFor(id)),
                      subtitle: Text(dashboardSectionDetails(id).description),
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
      case 'quickActions':
        return DashboardQuickActions(onChanged: _refreshHistoryWidgets);
      case 'weeklyFocus':
        return DashboardWeeklyFocusCard(
          refreshToken: _historyRefreshToken,
          onChanged: _refreshHistoryWidgets,
        );
      case 'workoutMetrics':
        return WorkoutMetricChartCard(refreshToken: _historyRefreshToken);
      case 'exerciseProgress':
        return ExerciseProgressSection(refreshToken: _historyRefreshToken);
      // TODO(nutrition): Add the remaining nutrition Dashboard widgets after
      // the nutrition tracking flows and calculations are fully rebuilt.
      case 'nutritionDash':
        return Consumer<NutritionProfile>(
          builder: (context, profile, _) {
            return NutritionDash(
              caloriesConsumed: (profile.totals?.kcal ?? 0).round(),
              calorieGoal: (profile.activeGoal?.kcalTarget ?? 0).round(),
              proteinConsumed: (profile.totals?.proteinG ?? 0).round(),
              proteinTarget: (profile.activeGoal?.proteinG ?? 0).round(),
              carbConsumed: (profile.totals?.carbsG ?? 0).round(),
              carbTarget: (profile.activeGoal?.carbsG ?? 0).round(),
              fatConsumed: (profile.totals?.fatG ?? 0).round(),
              fatTarget: (profile.activeGoal?.fatG ?? 0).round(),
              scale: 0.7,
            );
          },
        );
      case 'dataRecords':
        return const DataRecordsSection(padding: EdgeInsets.zero);
      case 'healthTrends':
        return HealthTrendsSection(refreshToken: _historyRefreshToken);
      case 'training':
        return WorkoutDashboard(onSessionComplete: _refreshHistoryWidgets);
      case 'historySummary':
        return WorkoutHistoryCalendar(
          refreshToken: _historyRefreshToken,
          onSessionTap: _openHistorySession,
          onOpenFullHistory: _openFullHistory,
        );
      case 'recentWorkouts':
        return DashboardRecentWorkoutsCard(
          refreshToken: _historyRefreshToken,
          onChanged: _refreshHistoryWidgets,
        );
      case 'activePlans':
        return DashboardPlanCollectionCard(
          archived: false,
          refreshToken: _historyRefreshToken,
          onChanged: _refreshHistoryWidgets,
        );
      case 'archivedPlans':
        return DashboardPlanCollectionCard(
          archived: true,
          refreshToken: _historyRefreshToken,
          onChanged: _refreshHistoryWidgets,
        );
      case 'premadePlans':
        return DashboardPremadePlansCard(onChanged: _refreshHistoryWidgets);
      case 'planTools':
        return DashboardPlanToolsCard(onChanged: _refreshHistoryWidgets);
      case 'exerciseCatalog':
        return DashboardExerciseCatalogCard(refreshToken: _historyRefreshToken);
      case 'targetAnatomy':
        return DashboardTargetAnatomyCard(refreshToken: _historyRefreshToken);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDashboardSection(String id) {
    final tile = _buildDashboardTile(id);
    final section =
        id == 'exerciseProgress' ||
                id == 'workoutMetrics' ||
                id == 'historySummary' ||
                id == 'healthTrends'
            ? tile
            : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: tile,
            );
    return KeyedSubtree(
      key: ValueKey<String>('dashboard_section_$id'),
      child: section,
    );
  }

  String _labelFor(String id) {
    return dashboardSectionDetails(id).title;
  }
}
