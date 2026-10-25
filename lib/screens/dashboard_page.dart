// File: lib/screens/dashboard_page.dart

import 'package:material_ui/material_ui.dart';

import '../theme/widgets/tonos_overlay_routes.dart';

import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/active_session.dart';
import '../providers/dashboard_config.dart';
import '../providers/nutrition_profile.dart';
import '../screens/exercise/full_history_screen.dart';
import '../screens/exercise/session_detail_screen.dart';
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/app_expressive_destination_theme.dart';
import '../theme/widgets/tonos_dialog.dart';
import '../theme/widgets/tonos_expressive_state_motion.dart';
import '../theme/widgets/tonos_expressive_navigation_motion.dart';
import '../widgets/data_records_section.dart';
import '../widgets/dashboard_sections.dart';
import '../widgets/dashboard_section_palette.dart';
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
  final Set<String> _arrivingWidgets = {};
  final Map<String, int> _reorderEpochs = {};

  void _toggleWidget(String id) {
    _arrivingWidgets.add(id);
    context.read<DashboardConfig>().toggleVisibility(id);
  }

  void _refreshHistoryWidgets() {
    if (!mounted) return;
    setState(() => _historyRefreshToken++);
  }

  void _openHistorySession(WorkoutReportSession reportSession) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AppExpressiveDestinationTheme(
              family: AppExpressiveDestinationFamily.logbook,
              child: SessionDetailScreen(
                WorkoutSession(
                  id: reportSession.id,
                  date: reportSession.date,
                  calendarDayKey: reportSession.calendarDayKey,
                  duration: reportSession.durationSeconds,
                ),
              ),
            ),
          ),
        )
        .then((_) => _refreshHistoryWidgets());
  }

  void _openFullHistory() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AppExpressiveDestinationTheme(
              family: AppExpressiveDestinationFamily.logbook,
              child: const FullHistoryScreen(),
            ),
          ),
        )
        .then((_) => _refreshHistoryWidgets());
  }

  Widget _withExpressiveDestinationTheme(
    AppExpressiveDestinationFamily family,
    Widget child,
  ) {
    if (!context.usesExpressivePresentation) return child;
    return AppExpressiveDestinationTheme(family: family, child: child);
  }

  Widget _buildHealthTrendsTile() {
    final healthTrends = HealthTrendsSection(
      refreshToken: _historyRefreshToken,
    );
    if (!context.usesExpressivePresentation) return healthTrends;

    return _withExpressiveDestinationTheme(
      AppExpressiveDestinationFamily.nutrition,
      healthTrends,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppExpressiveDestinationTheme(
      family: AppExpressiveDestinationFamily.dashboard,
      child: Builder(builder: _buildDashboard),
    );
  }

  Widget _buildDashboard(BuildContext context) {
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

    final destinationTokens = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    final expressiveDashboard =
        destinationTokens?.family == AppExpressiveDestinationFamily.dashboard;
    return Scaffold(
      backgroundColor: destinationTokens?.pageCanvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: expressiveDashboard ? 960 : double.infinity,
            ),
            child: _isEditing
                ? _buildEditableDashboardList(visibleIds)
                : _buildDashboardScrollView(visibleIds),
          ),
        ),
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
    final expressive = context.usesExpressivePresentation;
    final config = context.read<DashboardConfig>();
    final strings = AppLocalizations.of(context);
    final hiddenIds = config.widgetOrder
        .where((id) => !config.isVisible(id))
        .toList();
    return ReorderableListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      buildDefaultDragHandles: false,
      proxyDecorator: expressive
          ? (child, index, animation) => AnimatedBuilder(
              animation: animation,
              child: child,
              builder: (context, child) => Material(
                key: const ValueKey('dashboard-drag-proxy'),
                color: Colors.transparent,
                borderRadius: context.shapeTokens.dashboardEditor,
                elevation: TonosExpressiveStateMotion.enabled(context)
                    ? 3 * Curves.easeOut.transform(animation.value)
                    : 3,
                shadowColor: Theme.of(context).colorScheme.shadow
                    .withValues(alpha: 0.35),
                child: child,
              ),
            )
          : null,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardHero(
            isEditing: true,
            onEdit: () => setState(() => _isEditing = false),
          ),
          const SizedBox(height: 14),
          Text(
            expressive
                ? AppLocalizations.of(context).dashboardEditorHelp
                : AppLocalizations.of(context).dashboardReorderHelp,
            style:
                (expressive
                        ? Theme.of(context).textTheme.bodySmall
                        : Theme.of(context).textTheme.bodyMedium)
                    ?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
          ),
          const SizedBox(height: 12),
          if (expressive) ...[
            _buildEditorGroupHeading(
              strings.dashboardVisibleWidgets,
              visibleIds.length,
              key: const ValueKey('dashboard-visible-group'),
            ),
            if (visibleIds.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  strings.dashboardNoVisibleWidgets,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ],
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: TonosExpressiveResize(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (expressive && hiddenIds.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildEditorGroupHeading(
                  strings.dashboardHiddenWidgets,
                  hiddenIds.length,
                  key: const ValueKey('dashboard-hidden-group'),
                ),
                Text(
                  strings.dashboardHiddenWidgetsHelp,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                for (final id in hiddenIds) _buildEditableTile(id, null),
                const SizedBox(height: 12),
              ],
              _buildDashboardEditorFooter(),
            ],
          ),
        ),
      ),
      onReorderItem: (oldIndex, newIndex) {
        if (expressive &&
            oldIndex != newIndex &&
            oldIndex < visibleIds.length) {
          final id = visibleIds[oldIndex];
          _reorderEpochs[id] = (_reorderEpochs[id] ?? 0) + 1;
        }
        config.reorder(oldIndex, newIndex);
      },
      children: [
        for (var i = 0; i < visibleIds.length; i++)
          _buildEditableTile(visibleIds[i], i),
      ],
    );
  }

  Widget _buildEditorGroupHeading(String title, int count, {required Key key}) {
    final theme = Theme.of(context);
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          TonosExpressiveChangePulse(
            value: count,
            scale: 1.045,
            child: Text(
              MaterialLocalizations.of(context).formatDecimal(count),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTile(String id, int? index) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final strings = AppLocalizations.of(context);
    final details = dashboardSectionDetails(strings, id);
    final expressive = context.usesExpressivePresentation;
    final visible = context.read<DashboardConfig>().isVisible(id);
    final hidden = expressive && !visible;
    final visibilityAction = visible
        ? strings.dashboardHideWidget(details.title)
        : strings.dashboardShowWidget(details.title);
    final title = Text(
      details.title,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
    );
    final canvas = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.dashboard,
      theme.brightness,
    ).pageCanvas;
    final dragHandle = index == null
        ? null
        : ReorderableDragStartListener(
            index: index,
            child: expressive
                ? SizedBox(
                    key: ValueKey('dashboard-reorder-$id'),
                    width: 56,
                    height: 56,
                    child: ColoredBox(
                      color: Colors.transparent,
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: scheme.onSurfaceVariant,
                        size: 26,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(14),
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
          );
    final visibilityButton = IconButton(
      key: ValueKey('dashboard-visibility-$id'),
      tooltip: expressive ? visibilityAction : strings.dashboardHideSection,
      constraints: expressive
          ? const BoxConstraints(minWidth: 48, minHeight: 48)
          : null,
      style: hidden
          ? IconButton.styleFrom(
              backgroundColor: scheme.secondaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: shapes.dashboardAction,
              ),
            )
          : null,
      icon: Icon(
        hidden ? Icons.add_rounded : Icons.visibility_off_outlined,
        color: hidden ? scheme.onSecondaryContainer : scheme.error,
      ),
      onPressed: () => _toggleWidget(id),
    );
    final tile = Container(
      key: ValueKey(id),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: hidden
            ? Color.lerp(
                Color.alphaBlend(surfaces.dashboardEditor, canvas),
                canvas,
                0.32,
              )
            : surfaces.dashboardEditor,
        borderRadius: shapes.dashboardEditor,
        border: Border.all(
          color: details.color.withValues(alpha: hidden ? 0.28 : 0.48),
        ),
      ),
      child: Row(
        children: [
          if (dragHandle == null)
            const SizedBox(width: 16)
          else if (expressive)
            Tooltip(
              message: strings.dashboardReorderWidget(details.title),
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: dragHandle,
              ),
            )
          else
            dragHandle,
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
                  title,
                  const SizedBox(height: 2),
                  Text(
                    details.description,
                    maxLines: expressive ? null : 2,
                    overflow: expressive ? null : TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expressive)
            Semantics(
              label: visibilityAction,
              button: true,
              toggled: visible,
              onTap: () => _toggleWidget(id),
              excludeSemantics: true,
              child: visibilityButton,
            )
          else
            visibilityButton,
          const SizedBox(width: 4),
        ],
      ),
    );
    return !expressive
        ? tile
        : TonosExpressiveChangePulse(
            key: ValueKey('dashboard-feedback-$id'),
            value: _reorderEpochs[id] ?? 0,
            animateOnMount: _arrivingWidgets.remove(id),
            scale: 1,
            offset: const Offset(0, 3),
            child: tile,
          );
  }

  Widget _buildDashboardEditorFooter() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final config = context.watch<DashboardConfig>();
    final hiddenCount = config.widgetOrder
        .where((id) => !config.isVisible(id))
        .length;
    final strings = AppLocalizations.of(context);
    if (context.usesExpressivePresentation) {
      final destination = AppExpressiveDestinationTokens.forFamily(
        AppExpressiveDestinationFamily.dashboard,
        theme.brightness,
      );
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaces.dashboardSection,
          borderRadius: shapes.dashboardFooter,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.dashboardHiddenWidgetSummary(hiddenCount),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              strings.dashboardAutosave,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('dashboard-editor-done'),
              onPressed: () => setState(() => _isEditing = false),
              style: FilledButton.styleFrom(
                backgroundColor: destination.actionPrimary,
                foregroundColor: destination.onActionPrimary,
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: shapes.dashboardAction,
                ),
              ),
              icon: const Icon(Icons.check_rounded),
              label: Text(strings.commonDone),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              key: const ValueKey('dashboard-restore-defaults'),
              onPressed: _confirmRestoreDashboardDefaults,
              style: TextButton.styleFrom(
                foregroundColor: destination.supportingForeground,
                minimumSize: const Size(48, 48),
              ),
              icon: const Icon(Icons.restart_alt, size: 18),
              label: Text(strings.dashboardRestoreDefaultLayout),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaces.dashboardSection,
        borderRadius: shapes.dashboardFooter,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hiddenCount == 0
                ? strings.dashboardAllSectionsShown
                : strings.dashboardHiddenSectionCount(hiddenCount),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: hiddenCount == 0 ? null : _showAddWidgetDialog,
            icon: const Icon(Icons.add),
            label: Text(strings.dashboardShowHiddenSections),
          ),
          TextButton.icon(
            onPressed: () => context.read<DashboardConfig>().restoreDefaults(),
            icon: const Icon(Icons.restart_alt, size: 18),
            label: Text(strings.dashboardReset),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRestoreDashboardDefaults() async {
    final strings = AppLocalizations.of(context);
    final config = context.read<DashboardConfig>();
    final confirmed = await showTonosDialog<bool>(
      context: context,
      builder: (_) => AppExpressiveDestinationTheme(
        family: AppExpressiveDestinationFamily.dashboard,
        child: Builder(
          builder: (dialogContext) {
            final destination = Theme.of(dialogContext)
                .extension<AppExpressiveDestinationTokens>()!;
            return AlertDialog(
              key: const ValueKey('dashboard-restore-confirmation'),
              scrollable: true,
              title: Text(strings.dashboardRestoreDefaultLayoutTitle),
              content: Text(strings.dashboardRestoreDefaultLayoutBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: destination.onSurfaceTertiary,
                    minimumSize: const Size(48, 48),
                  ),
                  child: Text(strings.commonCancel),
                ),
                FilledButton(
                  key: const ValueKey('dashboard-confirm-restore'),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: destination.actionPrimary,
                    foregroundColor: destination.onActionPrimary,
                    minimumSize: const Size(48, 48),
                  ),
                  child: Text(strings.dashboardRestoreLayout),
                ),
              ],
            );
          },
        ),
      ),
    );
    if (confirmed == true && mounted) await config.restoreDefaults();
  }

  Widget _buildEmptyDashboard() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaces.dashboardSection,
        borderRadius: shapes.dashboardSection,
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
          Text(strings.dashboardEmptyTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            strings.dashboardEmptyBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit_outlined),
            label: Text(strings.dashboardCustomize),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddWidgetDialog() async {
    final config = context.read<DashboardConfig>();
    final hiddenIds = config.widgetOrder
        .where((id) => !config.isVisible(id))
        .toList();
    if (hiddenIds.isEmpty) return;
    final strings = AppLocalizations.of(context);
    await showTonosDialog(
      context: context,
      builder: (_) => TonosDialogFrame(
        child: AlertDialog(
          title: Text(strings.dashboardShowHiddenSections),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final id in hiddenIds)
                  ListTile(
                    leading: Icon(
                      dashboardSectionDetails(strings, id).icon,
                      color: dashboardSectionDetails(strings, id).color,
                    ),
                    title: Text(dashboardSectionDetails(strings, id).title),
                    subtitle: Text(
                      dashboardSectionDetails(strings, id).description,
                    ),
                    onTap: () {
                      context.read<DashboardConfig>().toggleVisibility(id);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
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
        return _withExpressiveDestinationTheme(
          AppExpressiveDestinationFamily.progress,
          WorkoutMetricChartCard(refreshToken: _historyRefreshToken),
        );
      case 'exerciseProgress':
        return _withExpressiveDestinationTheme(
          AppExpressiveDestinationFamily.progress,
          ExerciseProgressSection(refreshToken: _historyRefreshToken),
        );
      // TODO(nutrition): Add the remaining nutrition Dashboard widgets after
      // the nutrition tracking flows and calculations are fully rebuilt.
      case 'nutritionDash':
        return _withExpressiveDestinationTheme(
          AppExpressiveDestinationFamily.nutrition,
          Consumer<NutritionProfile>(
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
                scale: context.usesExpressivePresentation ? 1 : 0.7,
              );
            },
          ),
        );
      case 'dataRecords':
        return _withExpressiveDestinationTheme(
          AppExpressiveDestinationFamily.nutrition,
          DataRecordsSection(
            padding: context.usesExpressivePresentation
                ? const EdgeInsets.symmetric(vertical: 8)
                : EdgeInsets.zero,
          ),
        );
      case 'healthTrends':
        return _buildHealthTrendsTile();
      case 'training':
        return WorkoutDashboard(onSessionComplete: _refreshHistoryWidgets);
      case 'historySummary':
        return _withExpressiveDestinationTheme(
          AppExpressiveDestinationFamily.logbook,
          WorkoutHistoryCalendar(
            refreshToken: _historyRefreshToken,
            onSessionTap: _openHistorySession,
            onOpenFullHistory: _openFullHistory,
          ),
        );
      case 'recentWorkouts':
        return _withExpressiveDestinationTheme(
          AppExpressiveDestinationFamily.logbook,
          DashboardRecentWorkoutsCard(
            refreshToken: _historyRefreshToken,
            onChanged: _refreshHistoryWidgets,
          ),
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
    final Widget section;
    if (id == 'exerciseProgress' ||
        id == 'workoutMetrics' ||
        id == 'historySummary' ||
        id == 'healthTrends') {
      section = tile;
    } else if (context.usesExpressivePresentation &&
        const {
          'weeklyFocus',
          'training',
          'activePlans',
          'archivedPlans',
          'premadePlans',
          'planTools',
        }.contains(id)) {
      // Match Train's 880px content width and 16px inner list inset.
      section = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: tile,
          ),
        ),
      );
    } else if (id == 'nutritionDash' && context.usesExpressivePresentation) {
      // NutritionPage gives this shared carousel the same outer spacing.
      section = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: tile,
      );
    } else {
      section = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: tile,
      );
    }
    return KeyedSubtree(
      key: ValueKey<String>('dashboard_section_$id'),
      child: section,
    );
  }
}
