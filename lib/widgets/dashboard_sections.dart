import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
import '../screens/nutrition/new_measurement_item_page.dart';
import '../services/active_plan_store.dart';
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
                    isEditing ? 'Customize Dashboard' : 'Dashboard',
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
            tooltip: isEditing ? 'Done customizing' : 'Customize dashboard',
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
            'Quick actions',
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
                  title: 'Measurement',
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
                  title: workoutActive ? 'Resume workout' : 'Start workout',
                  color: const Color(0xFF81C784),
                  onPressed: () async {
                    if (!workoutActive) {
                      await activeSession.start();
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
  final _repo = AppRepository();
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

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final isToday =
        now.year == date.year && now.month == date.month && now.day == date.day;
    return isToday
        ? 'Today, ${DateFormat.jm().format(date)}'
        : DateFormat('EEE, MMM d').format(date);
  }

  String _durationLabel(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes min';
    return '${minutes ~/ 60}h ${minutes % 60}m';
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
                  'Recent workouts',
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
                child: const Text('View all'),
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
                    'Could not load recent workouts.',
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
                    'Finish a workout and it will appear here.',
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
                      dateLabel: _dateLabel(sessions[index].date),
                      durationLabel: _durationLabel(sessions[index].duration),
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
      _activePlanIdsFuture = ActivePlanStore.load(profileId);
    }
  }

  @override
  void didUpdateWidget(covariant DashboardPlanCollectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _activePlanIdsFuture = ActivePlanStore.load(_profileId);
    }
  }

  Future<void> _openPlanManagement() async {
    final profileId = _profileId;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gym profile first.')),
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
    setState(() => _activePlanIdsFuture = ActivePlanStore.load(profileId));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.archived ? 'Archived Plans' : 'Active Plans';
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
                      tooltip: 'Manage plans',
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
                    'Select a gym profile to view its plans.',
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
                            ? 'No archived plans for this profile.'
                            : 'No active plans yet. Use the pen to choose plans.',
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
                    'Premade Plans',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${premadeTrainingPlans.length} ready-to-use routines are available to add.',
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
                label: const Text('Browse Premade Plans'),
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
                ChangeNotifierProvider(create: (_) => PresetSession(presetId)),
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
        const SnackBar(content: Text('Please select a gym profile first.')),
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
      SnackBar(content: Text('Generated ${generatedPresetIds.length} plans.')),
    );
  }

  Future<void> _createManualPlan(BuildContext context) async {
    final profileId = context.read<SelectedProfile>().currentProfile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gym profile first.')),
      );
      return;
    }

    final repo = AppRepository();
    final existing = await repo.fetchAllPresetsRaw(profileId: profileId);
    final nextNumber = existing.length + 1;
    final name = nextNumber == 1 ? 'New Plan' : 'New Plan $nextNumber';
    final presetId = await repo.createPreset(name, profileId: profileId);
    if (!context.mounted) return;
    await _openPlanEditor(context, presetId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardCardTitle(
              icon: Icons.add_task_outlined,
              title: 'Plan Tools',
            ),
            const SizedBox(height: 8),
            Text(
              'Build a plan from your training preferences or start a blank one.',
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
                    label: const Text('Manual'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _generatePlans(context),
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Generate'),
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
  final _repo = AppRepository();
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
                    title: 'Exercise Catalog',
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Most used exercises',
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
                      'Complete workouts to see your most common exercises here.',
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
  final _repo = AppRepository();
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
                  title: 'Target Anatomy',
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
                            title: 'Bodyparts',
                            items: usage?.bodyParts ?? const [],
                            emptyText: 'No bodypart history yet.',
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
                            title: 'Muscles',
                            items: usage?.muscles ?? const [],
                            emptyText: 'No muscle history yet.',
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
                  '${equipment.isEmpty ? 'Exercise' : equipment} - ${usage.useCount} ${usage.useCount == 1 ? 'time' : 'times'}',
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

  const _DashboardFocusPane({
    required this.title,
    required this.items,
    required this.emptyText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${item.units.round()} sets',
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

DashboardSectionDetails dashboardSectionDetails(String id) {
  switch (id) {
    case 'quickActions':
      return const DashboardSectionDetails(
        title: 'Quick actions',
        description: 'Log a measurement or start a workout.',
        icon: Icons.bolt_outlined,
        color: Color(0xFF64B5F6),
      );
    case 'training':
      return const DashboardSectionDetails(
        title: 'Ready to train',
        description: 'Select your gym profile, plans, and start a session.',
        icon: Icons.fitness_center,
        color: Color(0xFF81C784),
      );
    case 'nutritionDash':
      return const DashboardSectionDetails(
        title: 'Nutrition dashboard',
        description: 'Review current calorie and macro targets.',
        icon: Icons.restaurant_outlined,
        color: Color(0xFFFFB74D),
      );
    case 'dataRecords':
      return const DashboardSectionDetails(
        title: 'Data & records',
        description: 'Review and add daily nutrition entries.',
        icon: Icons.calendar_month_outlined,
        color: Color(0xFF64B5F6),
      );
    case 'weeklyFocus':
      return const DashboardSectionDetails(
        title: 'Weekly focus',
        description: 'Review bodypart and muscle work from the last 7 days.',
        icon: Icons.accessibility_new,
        color: Color(0xFF4DB6AC),
      );
    case 'workoutMetrics':
      return const DashboardSectionDetails(
        title: 'Workout report',
        description: 'Compare workout count, time, and volume over time.',
        icon: Icons.show_chart_outlined,
        color: Color(0xFF64B5F6),
      );
    case 'exerciseProgress':
      return const DashboardSectionDetails(
        title: 'Exercise progress',
        description: 'Follow strength trends for your selected exercises.',
        icon: Icons.trending_up_rounded,
        color: Color(0xFFCE93D8),
      );
    case 'historySummary':
      return const DashboardSectionDetails(
        title: 'Training history',
        description: 'Compare workout totals and focus across time ranges.',
        icon: Icons.history_rounded,
        color: Color(0xFF64B5F6),
      );
    case 'healthTrends':
      return const DashboardSectionDetails(
        title: 'Health trends',
        description: 'Track measurements such as bodyweight and sizes.',
        icon: Icons.monitor_heart_outlined,
        color: Color(0xFF81C784),
      );
    case 'recentWorkouts':
      return const DashboardSectionDetails(
        title: 'Recent workouts',
        description: 'Open your latest completed workout sessions.',
        icon: Icons.event_note_outlined,
        color: Color(0xFFFFB74D),
      );
    case 'activePlans':
      return const DashboardSectionDetails(
        title: 'Active plans',
        description: 'Keep the plans you use most often close at hand.',
        icon: Icons.assignment_turned_in_outlined,
        color: Color(0xFF81C784),
      );
    case 'archivedPlans':
      return const DashboardSectionDetails(
        title: 'Archived plans',
        description: 'Browse plans that are not currently active.',
        icon: Icons.inventory_2_outlined,
        color: Color(0xFF90A4AE),
      );
    case 'premadePlans':
      return const DashboardSectionDetails(
        title: 'Premade plans',
        description: 'Browse routines that can be added to this profile.',
        icon: Icons.auto_stories_outlined,
        color: Color(0xFFCE93D8),
      );
    case 'planTools':
      return const DashboardSectionDetails(
        title: 'Plan tools',
        description: 'Generate a balanced plan or create one manually.',
        icon: Icons.add_task_outlined,
        color: Color(0xFFCE93D8),
      );
    case 'exerciseCatalog':
      return const DashboardSectionDetails(
        title: 'Exercise catalog',
        description: 'Open your most used exercises and the full catalog.',
        icon: Icons.menu_book_outlined,
        color: Color(0xFF64B5F6),
      );
    case 'targetAnatomy':
      return const DashboardSectionDetails(
        title: 'Target anatomy',
        description: 'Review the bodyparts and muscles you train most.',
        icon: Icons.bubble_chart_outlined,
        color: Color(0xFFBA68C8),
      );
    default:
      return const DashboardSectionDetails(
        title: 'Dashboard section',
        description: 'A dashboard section.',
        icon: Icons.dashboard_outlined,
        color: Color(0xFF9E9E9E),
      );
  }
}
