import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../data/premade_training_plans.dart';
import '../models/models.dart';
import '../providers/active_session.dart';
import '../providers/preset_session.dart';
import '../providers/selected_profile.dart';
import '../repositories/app_repository.dart';
import '../screens/exercise/analytics_dashboard_screen.dart';
import '../screens/exercise/exercise_catalog_page.dart';
import '../screens/exercise/full_history_screen.dart';
import '../screens/exercise/muscle_filter_page.dart';
import '../screens/exercise/plan_management_page.dart';
import '../screens/exercise/premade_plans_page.dart';
import '../screens/exercise/preset_detail_screen.dart';
import '../screens/exercise/preset_generation_qa.dart';
import '../screens/exercise/session_detail_screen.dart';
import '../screens/exercise/session_screen.dart';
import '../screens/new_measurement_item_page.dart';
import '../services/active_plan_store.dart';
import '../utils/localized_body_part_name.dart';
import '../utils/localized_digit_formatter.dart';
import 'exercise_media_thumbnail.dart';
import 'presets_loaded.dart';
import 'seven_day_focus_card.dart';

class DashboardHero extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onEdit;

  const DashboardHero({
    super.key,
    required this.isEditing,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const accent = Color(0xFF64B5F6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.25),
            scheme.surfaceContainerHighest.withValues(alpha: 0.54),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.44)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dashboard_customize_outlined,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isEditing
                        ? AppLocalizations.of(context).dashboardCustomize
                        : AppLocalizations.of(context).dashboardTitle,
                    maxLines: 1,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip:
                isEditing
                    ? AppLocalizations.of(context).dashboardDoneCustomizing
                    : AppLocalizations.of(context).dashboardCustomize,
            onPressed: onEdit,
            icon: Icon(isEditing ? Icons.check : Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class DashboardQuickActions extends StatelessWidget {
  final VoidCallback onChanged;

  const DashboardQuickActions({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final activeSession = context.watch<ActiveSession>();
    final workoutActive = activeSession.isActive && !activeSession.isRestoring;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).dashboardQuickActions,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DashboardActionButton(
                  icon: Icons.add_chart_outlined,
                  title: AppLocalizations.of(context).dashboardMeasurement,
                  color: const Color(0xFF4DB6AC),
                  onPressed: () async {
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => const NewMeasurementItemPage(),
                      ),
                    );
                    if (changed == true) onChanged();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashboardActionButton(
                  icon:
                      workoutActive
                          ? Icons.play_arrow_rounded
                          : Icons.fitness_center,
                  title:
                      workoutActive
                          ? AppLocalizations.of(context).dashboardResumeWorkout
                          : AppLocalizations.of(context).dashboardStartWorkout,
                  color: const Color(0xFF81C784),
                  onPressed: () async {
                    if (!workoutActive) {
                      final started = await activeSession.start();
                      if (!started) return;
                    }
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SessionScreen()),
                    );
                    onChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onPressed;

  const _DashboardActionButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: 0.13),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardWeeklyFocusCard extends StatelessWidget {
  final int refreshToken;
  final VoidCallback onChanged;

  const DashboardWeeklyFocusCard({
    super.key,
    required this.refreshToken,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SevenDayFocusCard(
      refreshToken: refreshToken,
      onFocusedSetsTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()),
        );
        onChanged();
      },
    );
  }
}

class DashboardRecentWorkoutsCard extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onChanged;

  const DashboardRecentWorkoutsCard({
    super.key,
    required this.refreshToken,
    required this.onChanged,
  });

  @override
  State<DashboardRecentWorkoutsCard> createState() =>
      _DashboardRecentWorkoutsCardState();
}

class _DashboardRecentWorkoutsCardState
    extends State<DashboardRecentWorkoutsCard> {
  AppRepository get _repo => context.read<AppRepository>();
  late Future<List<WorkoutSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _repo.fetchWorkoutSessions();
  }

  @override
  void didUpdateWidget(covariant DashboardRecentWorkoutsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _sessionsFuture = _repo.fetchWorkoutSessions();
    }
  }

  String _dateLabel(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();
    final isToday =
        now.year == date.year && now.month == date.month && now.day == date.day;
    return isToday
        ? AppLocalizations.of(context).dashboardTodayAt(
          preserveWesternDigits(
            DateFormat.jm(locale.toLanguageTag()).format(date),
            locale,
          ),
        )
        : preserveWesternDigits(
          DateFormat('EEE, MMM d', locale.toLanguageTag()).format(date),
          locale,
        );
  }

  String _durationLabel(BuildContext context, int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return AppLocalizations.of(context).durationMinutes(minutes);
    }
    return AppLocalizations.of(
      context,
    ).durationHoursMinutes(minutes ~/ 60, minutes % 60);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).dashboardRecentWorkouts,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FullHistoryScreen(),
                    ),
                  );
                  widget.onChanged();
                },
                child: Text(AppLocalizations.of(context).dashboardViewAll),
              ),
            ],
          ),
          FutureBuilder<List<WorkoutSession>>(
            future: _sessionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    AppLocalizations.of(context).dashboardRecentWorkoutsFailed,
                    style: theme.textTheme.bodySmall,
                  ),
                );
              }
              final sessions = (snapshot.data ?? const <WorkoutSession>[])
                  .take(3)
                  .toList(growable: false);
              if (sessions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                  child: Text(
                    AppLocalizations.of(context).dashboardRecentWorkoutsEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (var index = 0; index < sessions.length; index++) ...[
                    _DashboardWorkoutRow(
                      dateLabel: _dateLabel(context, sessions[index].date),
                      durationLabel: _durationLabel(
                        context,
                        sessions[index].duration,
                      ),
                      onOpen: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => SessionDetailScreen(sessions[index]),
                          ),
                        );
                        widget.onChanged();
                      },
                    ),
                    if (index < sessions.length - 1)
                      Divider(color: scheme.outlineVariant, height: 1),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardWorkoutRow extends StatelessWidget {
  final String dateLabel;
  final String durationLabel;
  final VoidCallback onOpen;

  const _DashboardWorkoutRow({
    required this.dateLabel,
    required this.durationLabel,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 2),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: scheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      durationLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPlanCollectionCard extends StatefulWidget {
  final bool archived;
  final int refreshToken;
  final VoidCallback onChanged;

  const DashboardPlanCollectionCard({
    super.key,
    required this.archived,
    required this.refreshToken,
    required this.onChanged,
  });

  @override
  State<DashboardPlanCollectionCard> createState() =>
      _DashboardPlanCollectionCardState();
}

class _DashboardPlanCollectionCardState
    extends State<DashboardPlanCollectionCard> {
  int? _profileId;
  Future<Set<int>>? _activePlanIdsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profileId = context.watch<SelectedProfile>().currentProfile?.id;
    if (_profileId != profileId || _activePlanIdsFuture == null) {
      _profileId = profileId;
      _activePlanIdsFuture = context.read<ActivePlanStore>().load(profileId);
    }
  }

  @override
  void didUpdateWidget(covariant DashboardPlanCollectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _activePlanIdsFuture = context.read<ActivePlanStore>().load(_profileId);
    }
  }

  Future<void> _openPlanManagement() async {
    final profileId = _profileId;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).trainSelectProfileFirst),
        ),
      );
      return;
    }

    final navigator = Navigator.of(context);
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => PlanManagementPage(profileId: profileId),
      ),
    );
    if (!mounted) return;
    setState(
      () =>
          _activePlanIdsFuture = context.read<ActivePlanStore>().load(
            profileId,
          ),
    );
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final title =
        widget.archived
            ? strings.dashboardArchivedPlans
            : strings.dashboardActivePlans;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<Set<int>>(
          future: _activePlanIdsFuture,
          builder: (context, snapshot) {
            final activeIds = snapshot.data ?? const <int>{};
            final loading =
                snapshot.connectionState != ConnectionState.done &&
                !snapshot.hasData;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: strings.dashboardManagePlans,
                      onPressed: loading ? null : _openPlanManagement,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_profileId == null)
                  Text(
                    strings.dashboardSelectProfilePlans,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  PresetsLoaded(
                    scale: 0.92,
                    refreshToken: widget.refreshToken,
                    presetIds: widget.archived ? null : activeIds,
                    excludedPresetIds: widget.archived ? activeIds : null,
                    planActiveState: !widget.archived,
                    progressiveReveal: true,
                    initialVisibleCount: 3,
                    revealBatchSize: 5,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    emptyMessage:
                        widget.archived
                            ? strings.dashboardNoArchivedPlans
                            : strings.dashboardNoActivePlans,
                    onRefresh: widget.onChanged,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DashboardPremadePlansCard extends StatelessWidget {
  final VoidCallback onChanged;

  const DashboardPremadePlansCard({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final profileId = context.watch<SelectedProfile>().currentProfile?.id;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_stories_outlined,
                  color: theme.colorScheme.primary,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.premadePlansTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              strings.dashboardPremadeCount(premadeTrainingPlans.length),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed:
                    profileId == null
                        ? null
                        : () async {
                          final navigator = Navigator.of(context);
                          await navigator.push(
                            MaterialPageRoute(
                              builder:
                                  (_) => PremadePlansPage(
                                    profileId: profileId,
                                    onPlanAdded: onChanged,
                                  ),
                            ),
                          );
                          onChanged();
                        },
                icon: const Icon(Icons.arrow_forward),
                label: Text(strings.dashboardBrowsePremadePlans),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPlanToolsCard extends StatelessWidget {
  final VoidCallback onChanged;

  const DashboardPlanToolsCard({super.key, required this.onChanged});

  Future<void> _openPlanEditor(BuildContext context, int presetId) async {
    final activeSession = context.read<ActiveSession>();
    final navigator = Navigator.of(context);
    await navigator.push(
      MaterialPageRoute(
        builder:
            (_) => MultiProvider(
              providers: [
                ChangeNotifierProvider<ActiveSession>.value(
                  value: activeSession,
                ),
                ChangeNotifierProvider(
                  create:
                      (context) => PresetSession(
                        presetId,
                        repository: context.read<AppRepository>(),
                      ),
                ),
              ],
              child: const PresetDetailScreen(),
            ),
      ),
    );
    if (!context.mounted) return;
    onChanged();
  }

  Future<void> _generatePlans(BuildContext context) async {
    final profileId = context.read<SelectedProfile>().currentProfile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).trainSelectProfileFirst),
        ),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final generatedPresetIds = await navigator.push<List<int>>(
      MaterialPageRoute(
        builder: (_) => PresetGenerationQaScreen(profileId: profileId),
      ),
    );
    if (!context.mounted ||
        generatedPresetIds == null ||
        generatedPresetIds.isEmpty) {
      return;
    }

    if (generatedPresetIds.length == 1) {
      await _openPlanEditor(context, generatedPresetIds.first);
      return;
    }
    onChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(
            context,
          ).trainPlansGenerated(generatedPresetIds.length),
        ),
      ),
    );
  }

  Future<void> _createManualPlan(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    final profileId = context.read<SelectedProfile>().currentProfile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).trainSelectProfileFirst),
        ),
      );
      return;
    }

    final repo = context.read<AppRepository>();
    final existing = await repo.fetchAllPresetsRaw(profileId: profileId);
    final nextNumber = existing.length + 1;
    final name =
        nextNumber == 1
            ? strings.dashboardNewPlanFirst
            : strings.dashboardNewPlan(nextNumber);
    final presetId = await repo.createPreset(name, profileId: profileId);
    if (!context.mounted) return;
    await _openPlanEditor(context, presetId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardCardTitle(
              icon: Icons.add_task_outlined,
              title: strings.dashboardPlanTools,
            ),
            const SizedBox(height: 8),
            Text(
              strings.dashboardPlanToolsBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _createManualPlan(context),
                    icon: const Icon(Icons.edit_note_outlined),
                    label: Text(strings.dashboardManual),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _generatePlans(context),
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: Text(strings.dashboardGenerate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardExerciseCatalogCard extends StatefulWidget {
  final int refreshToken;

  const DashboardExerciseCatalogCard({super.key, required this.refreshToken});

  @override
  State<DashboardExerciseCatalogCard> createState() =>
      _DashboardExerciseCatalogCardState();
}

class _DashboardExerciseCatalogCardState
    extends State<DashboardExerciseCatalogCard> {
  AppRepository get _repo => context.read<AppRepository>();
  late Future<List<_DashboardExerciseUsage>> _usageFuture;

  @override
  void initState() {
    super.initState();
    _usageFuture = _loadUsage();
  }

  @override
  void didUpdateWidget(covariant DashboardExerciseCatalogCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _usageFuture = _loadUsage();
    }
  }

  Future<List<_DashboardExerciseUsage>> _loadUsage() async {
    final rows = await _repo.fetchMostUsedExerciseDefinitionsRaw(limit: 4);
    final definitionIds =
        rows
            .map((row) => (row['definition_id'] as num?)?.toInt())
            .whereType<int>()
            .toList();
    final definitions = await _repo.lookupDefsDetailedByIds(definitionIds);
    final definitionsById = {
      for (final definition in definitions) definition.id: definition,
    };
    return [
      for (final row in rows)
        if (definitionsById[(row['definition_id'] as num?)?.toInt()] != null)
          _DashboardExerciseUsage(
            definition: definitionsById[(row['definition_id'] as num).toInt()]!,
            useCount: ((row['use_count'] as num?) ?? 0).toInt(),
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return FutureBuilder<List<_DashboardExerciseUsage>>(
      future: _usageFuture,
      builder: (context, snapshot) {
        final usages = snapshot.data ?? const <_DashboardExerciseUsage>[];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ExerciseCatalogPage(),
                  ),
                ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardCardTitle(
                    icon: Icons.menu_book_outlined,
                    title: strings.trainExerciseCatalog,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    strings.dashboardMostUsedExercises,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (snapshot.connectionState != ConnectionState.done &&
                      snapshot.data == null)
                    const Padding(
                      padding: EdgeInsets.all(18),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (usages.isEmpty)
                    Text(
                      strings.dashboardMostUsedExercisesEmpty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    for (final usage in usages)
                      _DashboardExerciseUsageRow(usage: usage),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DashboardTargetAnatomyCard extends StatefulWidget {
  final int refreshToken;

  const DashboardTargetAnatomyCard({super.key, required this.refreshToken});

  @override
  State<DashboardTargetAnatomyCard> createState() =>
      _DashboardTargetAnatomyCardState();
}

class _DashboardTargetAnatomyCardState
    extends State<DashboardTargetAnatomyCard> {
  AppRepository get _repo => context.read<AppRepository>();
  late Future<_DashboardAnatomyUsage> _usageFuture;

  @override
  void initState() {
    super.initState();
    _usageFuture = _loadUsage();
  }

  @override
  void didUpdateWidget(covariant DashboardTargetAnatomyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _usageFuture = _loadUsage();
    }
  }

  Future<_DashboardAnatomyUsage> _loadUsage() async {
    final now = DateTime.now();
    final bodyPartSetsFuture = _repo.fetchAllBodyPartSetsOverTimeRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: now,
    );
    final muscleSetsFuture = _repo.fetchSetsPerMuscle(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: now,
    );
    final musclesFuture = _repo.fetchAllMusclesFull();

    final bodyPartSets = await bodyPartSetsFuture;
    final muscleSets = await muscleSetsFuture;
    final muscles = await musclesFuture;
    final musclesById = {for (final muscle in muscles) muscle.id: muscle};
    final bodyParts =
        bodyPartSets.entries
            .where((entry) => entry.value > 0)
            .map((entry) => _DashboardFocusUsage(entry.key.name, entry.value))
            .toList()
          ..sort((a, b) => b.units.compareTo(a.units));
    final muscleUsage =
        muscleSets.entries
            .where((entry) => entry.value > 0 && musclesById[entry.key] != null)
            .map(
              (entry) => _DashboardFocusUsage(
                musclesById[entry.key]!.name,
                entry.value,
              ),
            )
            .toList()
          ..sort((a, b) => b.units.compareTo(a.units));

    return _DashboardAnatomyUsage(
      bodyParts: bodyParts.take(5).toList(),
      muscles: muscleUsage.take(5).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashboardAnatomyUsage>(
      future: _usageFuture,
      builder: (context, snapshot) {
        final usage = snapshot.data;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardCardTitle(
                  icon: Icons.bubble_chart_outlined,
                  title: AppLocalizations.of(context).dashboardTargetAnatomy,
                ),
                const SizedBox(height: 14),
                if (snapshot.connectionState != ConnectionState.done &&
                    usage == null)
                  const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _DashboardFocusPane(
                            title:
                                AppLocalizations.of(context).dashboardBodyparts,
                            items: usage?.bodyParts ?? const [],
                            emptyText: 'No bodypart history yet.',
                            localizeBuiltInBodyPartNames: true,
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => const MuscleFilterPage(
                                          initialTabIndex: 0,
                                        ),
                                  ),
                                ),
                          ),
                        ),
                        const VerticalDivider(width: 25),
                        Expanded(
                          child: _DashboardFocusPane(
                            title:
                                AppLocalizations.of(context).dashboardMuscles,
                            items: usage?.muscles ?? const [],
                            emptyText: 'No muscle history yet.',
                            localizeBuiltInBodyPartNames: false,
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => const MuscleFilterPage(
                                          initialTabIndex: 1,
                                        ),
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardCardTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _DashboardCardTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardExerciseUsageRow extends StatelessWidget {
  final _DashboardExerciseUsage usage;

  const _DashboardExerciseUsageRow({required this.usage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final equipment = usage.definition.equipmentList
        .map((item) => item.name)
        .where((name) => name.trim().isNotEmpty)
        .join(', ');
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usage.definition.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  strings.dashboardExerciseUsage(
                    equipment.isEmpty
                        ? strings.dashboardExerciseFallback
                        : equipment,
                    usage.useCount,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ExerciseMediaThumbnail(
            definition: usage.definition,
            size: 44,
            borderRadius: BorderRadius.circular(11),
            padding: const EdgeInsets.all(3),
          ),
        ],
      ),
    );
  }
}

class _DashboardFocusPane extends StatelessWidget {
  final String title;
  final List<_DashboardFocusUsage> items;
  final String emptyText;
  final VoidCallback onTap;
  final bool localizeBuiltInBodyPartNames;

  const _DashboardFocusPane({
    required this.title,
    required this.items,
    required this.emptyText,
    required this.onTap,
    required this.localizeBuiltInBodyPartNames,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Text(
                emptyText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              for (final item in items.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          localizeBuiltInBodyPartNames
                              ? localizedBodyPartName(context, item.name)
                              : item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        strings.weeklySetsCount(item.units.round().toString()),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _DashboardExerciseUsage {
  final ExerciseDefinition definition;
  final int useCount;

  const _DashboardExerciseUsage({
    required this.definition,
    required this.useCount,
  });
}

class _DashboardFocusUsage {
  final String name;
  final double units;

  const _DashboardFocusUsage(this.name, this.units);
}

class _DashboardAnatomyUsage {
  final List<_DashboardFocusUsage> bodyParts;
  final List<_DashboardFocusUsage> muscles;

  const _DashboardAnatomyUsage({
    required this.bodyParts,
    required this.muscles,
  });
}

class DashboardSectionDetails {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const DashboardSectionDetails({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

DashboardSectionDetails dashboardSectionDetails(
  AppLocalizations strings,
  String id,
) {
  switch (id) {
    case 'quickActions':
      return DashboardSectionDetails(
        title: strings.dashboardSectionQuickActionsTitle,
        description: strings.dashboardSectionQuickActionsBody,
        icon: Icons.bolt_outlined,
        color: Color(0xFF64B5F6),
      );
    case 'training':
      return DashboardSectionDetails(
        title: strings.dashboardSectionTrainingTitle,
        description: strings.dashboardSectionTrainingBody,
        icon: Icons.fitness_center,
        color: Color(0xFF81C784),
      );
    case 'nutritionDash':
      return DashboardSectionDetails(
        title: strings.dashboardSectionNutritionTitle,
        description: strings.dashboardSectionNutritionBody,
        icon: Icons.restaurant_outlined,
        color: Color(0xFFFFB74D),
      );
    case 'dataRecords':
      return DashboardSectionDetails(
        title: strings.dashboardSectionDataRecordsTitle,
        description: strings.dashboardSectionDataRecordsBody,
        icon: Icons.calendar_month_outlined,
        color: Color(0xFF64B5F6),
      );
    case 'weeklyFocus':
      return DashboardSectionDetails(
        title: strings.dashboardSectionWeeklyFocusTitle,
        description: strings.dashboardSectionWeeklyFocusBody,
        icon: Icons.accessibility_new,
        color: Color(0xFF4DB6AC),
      );
    case 'workoutMetrics':
      return DashboardSectionDetails(
        title: strings.dashboardSectionWorkoutReportTitle,
        description: strings.dashboardSectionWorkoutReportBody,
        icon: Icons.show_chart_outlined,
        color: Color(0xFF64B5F6),
      );
    case 'exerciseProgress':
      return DashboardSectionDetails(
        title: strings.dashboardSectionExerciseProgressTitle,
        description: strings.dashboardSectionExerciseProgressBody,
        icon: Icons.trending_up_rounded,
        color: Color(0xFFCE93D8),
      );
    case 'historySummary':
      return DashboardSectionDetails(
        title: strings.dashboardSectionHistoryTitle,
        description: strings.dashboardSectionHistoryBody,
        icon: Icons.history_rounded,
        color: Color(0xFF64B5F6),
      );
    case 'healthTrends':
      return DashboardSectionDetails(
        title: strings.dashboardSectionHealthTrendsTitle,
        description: strings.dashboardSectionHealthTrendsBody,
        icon: Icons.monitor_heart_outlined,
        color: Color(0xFF81C784),
      );
    case 'recentWorkouts':
      return DashboardSectionDetails(
        title: strings.dashboardSectionRecentWorkoutsTitle,
        description: strings.dashboardSectionRecentWorkoutsBody,
        icon: Icons.event_note_outlined,
        color: Color(0xFFFFB74D),
      );
    case 'activePlans':
      return DashboardSectionDetails(
        title: strings.dashboardSectionActivePlansTitle,
        description: strings.dashboardSectionActivePlansBody,
        icon: Icons.assignment_turned_in_outlined,
        color: Color(0xFF81C784),
      );
    case 'archivedPlans':
      return DashboardSectionDetails(
        title: strings.dashboardSectionArchivedPlansTitle,
        description: strings.dashboardSectionArchivedPlansBody,
        icon: Icons.inventory_2_outlined,
        color: Color(0xFF90A4AE),
      );
    case 'premadePlans':
      return DashboardSectionDetails(
        title: strings.dashboardSectionPremadePlansTitle,
        description: strings.dashboardSectionPremadePlansBody,
        icon: Icons.auto_stories_outlined,
        color: Color(0xFFCE93D8),
      );
    case 'planTools':
      return DashboardSectionDetails(
        title: strings.dashboardSectionPlanToolsTitle,
        description: strings.dashboardSectionPlanToolsBody,
        icon: Icons.add_task_outlined,
        color: Color(0xFFCE93D8),
      );
    case 'exerciseCatalog':
      return DashboardSectionDetails(
        title: strings.dashboardSectionCatalogTitle,
        description: strings.dashboardSectionCatalogBody,
        icon: Icons.menu_book_outlined,
        color: Color(0xFF64B5F6),
      );
    case 'targetAnatomy':
      return DashboardSectionDetails(
        title: strings.dashboardSectionAnatomyTitle,
        description: strings.dashboardSectionAnatomyBody,
        icon: Icons.bubble_chart_outlined,
        color: Color(0xFFBA68C8),
      );
    default:
      return DashboardSectionDetails(
        title: strings.dashboardSectionFallbackTitle,
        description: strings.dashboardSectionFallbackBody,
        icon: Icons.dashboard_outlined,
        color: Color(0xFF9E9E9E),
      );
  }
}
