import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/premade_training_plans.dart';
import '../../models/models.dart';
import '../../providers/active_session.dart';
import '../../providers/preset_session.dart';
import '../../providers/selected_profile.dart';
import '../../repositories/app_repository.dart';
import '../../services/active_plan_store.dart';
import '../../services/preset_generation_service.dart';
import '../../theme/theme_extensions.dart';
import '../../widgets/body_heatmap.dart';
import '../../widgets/drawers.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/focused_sets_list.dart';
import '../../widgets/generic_bar.dart';
import '../../widgets/presets_loaded.dart';
import 'analytics_dashboard_screen.dart';
import 'gym_profile_screen.dart';
import 'optimized_workout_settings_page.dart';
import 'plan_management_page.dart';
import 'premade_plans_page.dart';
import 'preset_detail_screen.dart';
import 'preset_generation_qa.dart';
import 'session_screen.dart';

class TrainPage extends StatefulWidget {
  const TrainPage({super.key});

  @override
  State<TrainPage> createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  static const _optimizedSessionMinutesKey = 'train.optimized_session_minutes';
  static const _optimizedMinSetsKey =
      'train.optimized_min_sets_per_exercise';
  static const _optimizedMaxSetsKey = 'train.optimized_max_sets_per_exercise';

  final _repo = AppRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedTab = 0;
  int _overviewRefreshToken = 0;
  int _presetsRefreshToken = 0;
  int? _lastProfileId;
  int? _seenCompletedSessionVersion;
  bool _isStartingOptimized = false;
  int _optimizedSessionMinutes = SessionSpec.defaultSessionDurationMinutes;
  int _optimizedMinSetsPerExercise = SessionSpec.preferredMinSetsPerExercise;
  int _optimizedMaxSetsPerExercise = SessionSpec.defaultMaxSetsPerExercise;
  Set<int> _optimizedPreferredBodypartIds = <int>{};
  Set<int> _optimizedBlacklistedBodypartIds = <int>{};

  @override
  void initState() {
    super.initState();
    unawaited(_loadOptimizedWorkoutSettings());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profileId = context.watch<SelectedProfile>().currentProfile?.id;
    if (_lastProfileId != profileId) {
      _lastProfileId = profileId;
      _presetsRefreshToken++;
    }
  }

  Future<void> _openPreset(int presetId) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (outerCtx) => MultiProvider(
              providers: [
                ChangeNotifierProvider<ActiveSession>.value(
                  value: outerCtx.read<ActiveSession>(),
                ),
                ChangeNotifierProvider(create: (_) => PresetSession(presetId)),
              ],
              child: const PresetDetailScreen(),
            ),
      ),
    );
    if (!mounted) return;
    setState(() => _presetsRefreshToken++);
  }

  Future<void> _openCustomPresetGenerator(SelectedProfile sel) async {
    final profileId = sel.currentProfile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gym profile first.')),
      );
      return;
    }

    final generatedPresetId = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => PresetGenerationQaScreen(profileId: profileId),
      ),
    );
    if (generatedPresetId == null || !mounted) return;
    await _openPreset(generatedPresetId);
  }

  Future<void> _createManualPreset(SelectedProfile sel) async {
    final profileId = sel.currentProfile?.id;
    final existing = await _repo.fetchAllPresetsRaw(profileId: profileId);
    final nextNum = existing.length + 1;
    final name = nextNum == 1 ? 'New Plan' : 'New Plan $nextNum';
    final newId = await _repo.createPreset(name, profileId: profileId);
    if (!mounted) return;
    setState(() => _presetsRefreshToken++);
    await _openPreset(newId);
  }

  Future<void> _startWorkout() async {
    context.read<ActiveSession>().start();
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SessionScreen()));
    if (!mounted) return;
    setState(() => _overviewRefreshToken++);
  }

  Future<void> _loadOptimizedWorkoutSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMinutes = prefs.getInt(_optimizedSessionMinutesKey);
    final savedMinSets = prefs.getInt(_optimizedMinSetsKey);
    final savedMaxSets = prefs.getInt(_optimizedMaxSetsKey);
    if (!mounted) return;
    setState(() {
      if (savedMinutes != null && savedMinutes > 0) {
        _optimizedSessionMinutes = savedMinutes;
      }
      if (savedMinSets != null &&
          savedMinSets >= SessionSpec.defaultMinSetsPerExercise &&
          savedMinSets <= SessionSpec.maxAllowedSetsPerExercise) {
        _optimizedMinSetsPerExercise = savedMinSets;
      }
      if (savedMaxSets != null &&
          savedMaxSets >= SessionSpec.defaultMinSetsPerExercise &&
          savedMaxSets <= SessionSpec.maxAllowedSetsPerExercise) {
        _optimizedMaxSetsPerExercise = savedMaxSets;
      }
      if (_optimizedMinSetsPerExercise > _optimizedMaxSetsPerExercise) {
        _optimizedMinSetsPerExercise = _optimizedMaxSetsPerExercise;
      }
    });
  }

  SessionSpec _buildOptimizedSpec(
    int profileId, {
    required int sessionMinutes,
    int? minSetsPerExercise,
    int? maxSetsPerExercise,
    Set<int>? preferredBodypartIds,
    Set<int>? blacklistedBodypartIds,
  }) {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final minSets = minSetsPerExercise ?? _optimizedMinSetsPerExercise;
    return SessionSpec(
      profileId: profileId,
      name: 'Optimized workout $date $time',
      focusBodypartIds: const [],
      preferredBodypartIds:
          (preferredBodypartIds ?? _optimizedPreferredBodypartIds).toList(),
      blacklistedBodypartIds:
          (blacklistedBodypartIds ?? _optimizedBlacklistedBodypartIds).toList(),
      maxExercises: SessionSpec.maxExercisesForDuration(
        sessionDurationMinutes: sessionMinutes,
        minSetsPerExercise: minSets,
      ),
      minSetsPerExercise: minSets,
      maxSetsPerExercise: maxSetsPerExercise ?? _optimizedMaxSetsPerExercise,
      sessionDurationMinutes: sessionMinutes,
      historyWindow: const Duration(days: 7),
      avoidMostRecentBodyPart: true,
      now: now,
    );
  }

  Future<void> _openOptimizedWorkoutSettings() async {
    List<BodyPart> bodyParts = const <BodyPart>[];
    try {
      bodyParts = await _repo.fetchAllBodyParts();
    } catch (e) {
      debugPrint('Failed to load bodyparts for optimized settings: $e');
    }
    if (!mounted) return;

    final settings = await Navigator.of(
      context,
    ).push<OptimizedWorkoutSettingsResult>(
      MaterialPageRoute(
        builder:
            (_) => OptimizedWorkoutSettingsPage(
              initialMinutes: _optimizedSessionMinutes,
              initialMinSets: _optimizedMinSetsPerExercise,
              initialMaxSets: _optimizedMaxSetsPerExercise,
              initialPreferredBodypartIds: _optimizedPreferredBodypartIds,
              initialBlacklistedBodypartIds: _optimizedBlacklistedBodypartIds,
              bodyParts: bodyParts,
            ),
      ),
    );
    if (!mounted || settings == null) return;
    if (settings.action == OptimizedWorkoutSettingsAction.startNow) {
      await _startOptimizedWorkout(
        context.read<SelectedProfile>(),
        settingsOverride: settings,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_optimizedSessionMinutesKey, settings.minutes);
    await prefs.setInt(_optimizedMinSetsKey, settings.minSets);
    await prefs.setInt(_optimizedMaxSetsKey, settings.maxSets);
    if (!mounted) return;
    setState(() {
      _optimizedSessionMinutes = settings.minutes;
      _optimizedMinSetsPerExercise = settings.minSets;
      _optimizedMaxSetsPerExercise = settings.maxSets;
      _optimizedPreferredBodypartIds = settings.preferredBodypartIds;
      _optimizedBlacklistedBodypartIds = settings.blacklistedBodypartIds;
    });
  }

  Future<void> _showOptimizedWorkoutRestWarning() {
    return showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Take some time to rest'),
            content: const Text(
              'Your recent training is already at several bodypart limits, so an optimized workout would push recovery too far.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _startOptimizedWorkout(
    SelectedProfile sel, {
    OptimizedWorkoutSettingsResult? settingsOverride,
  }) async {
    if (_isStartingOptimized) return;

    final profileId = sel.currentProfile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gym profile first.')),
      );
      return;
    }

    final active = context.read<ActiveSession>();
    if (active.isActive) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SessionScreen()));
      return;
    }

    setState(() => _isStartingOptimized = true);
    int? temporaryPresetId;
    try {
      final generator = PresetGenerationService(_repo);
      final spec = _buildOptimizedSpec(
        profileId,
        sessionMinutes: settingsOverride?.minutes ?? _optimizedSessionMinutes,
        minSetsPerExercise: settingsOverride?.minSets,
        maxSetsPerExercise: settingsOverride?.maxSets,
        preferredBodypartIds: settingsOverride?.preferredBodypartIds,
        blacklistedBodypartIds: settingsOverride?.blacklistedBodypartIds,
      );
      final shouldRest = await generator.shouldRestBeforeOptimizedWorkout(spec);
      if (shouldRest) {
        if (!mounted) return;
        await _showOptimizedWorkoutRestWarning();
        return;
      }

      final presetId = await generator.generatePreset(spec);
      temporaryPresetId = presetId;
      final preset = PresetSession(presetId);
      await preset.ready;

      if (!mounted) return;
      if (preset.exercises.isEmpty) {
        await _repo.deletePreset(presetId);
        temporaryPresetId = null;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No eligible exercises were found for this profile.'),
          ),
        );
        return;
      }

      active.exercises.clear();
      active.cardTypes.clear();
      for (var i = 0; i < preset.exercises.length; i++) {
        // TODO(cardio/stretch): add cardio and stretch back to generated
        // sessions after those cards are fixed and updated.
        if (preset.cardTypes[i] != CardType.weight) continue;
        active.addExercise(preset.exercises[i], preset.cardTypes[i]);
      }

      await _repo.deletePreset(presetId);
      temporaryPresetId = null;
      active.start();

      if (!mounted) return;
      setState(() {
        _overviewRefreshToken++;
        _presetsRefreshToken++;
        _optimizedPreferredBodypartIds.clear();
        _optimizedBlacklistedBodypartIds.clear();
      });
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SessionScreen()));
      if (!mounted) return;
      setState(() => _overviewRefreshToken++);
    } catch (e) {
      if (!active.isActive) {
        active.exercises.clear();
        active.cardTypes.clear();
        active.refresh();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start optimized workout: $e')),
      );
    } finally {
      if (temporaryPresetId != null) {
        try {
          await _repo.deletePreset(temporaryPresetId);
          if (mounted) {
            setState(() => _presetsRefreshToken++);
          }
        } catch (e) {
          debugPrint('Failed to delete temporary optimized preset: $e');
        }
      }
      if (mounted) {
        setState(() => _isStartingOptimized = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedSessionVersion = context.select<ActiveSession, int>(
      (session) => session.completedSessionVersion,
    );
    if (_seenCompletedSessionVersion == null) {
      _seenCompletedSessionVersion = completedSessionVersion;
    } else if (_seenCompletedSessionVersion != completedSessionVersion) {
      _seenCompletedSessionVersion = completedSessionVersion;
      _overviewRefreshToken++;
    }

    return Consumer<SelectedProfile>(
      builder: (context, sel, _) {
        return Scaffold(
          key: _scaffoldKey,
          endDrawer: ProfileDrawer(
            profiles: sel.profiles,
            selected: sel.currentProfile,
            onSelect: (profile) {
              final navigator = Navigator.of(context);
              unawaited(sel.selectProfile(profile));
              if (navigator.canPop()) {
                unawaited(navigator.maybePop());
              }
              setState(() => _presetsRefreshToken++);
            },
            onEdit: (profile) {
              final navigator = Navigator.of(context);
              unawaited(() async {
                if (navigator.canPop()) {
                  await navigator.maybePop();
                }
                if (!navigator.mounted) return;
                await navigator.push(
                  MaterialPageRoute(
                    builder: (_) => GymProfileScreen(profile: profile),
                  ),
                );
              }());
            },
            onDelete: (profile) {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                unawaited(navigator.maybePop());
              }
              final profileId = profile.id;
              if (profileId == null) return;
              unawaited(sel.deleteProfile(profileId));
              setState(() => _presetsRefreshToken++);
            },
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: _TrainTabs(
              selectedIndex: _selectedTab,
              onChanged: (index) => setState(() => _selectedTab = index),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  tooltip: 'Gym profiles',
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  icon: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.lightGreen,
                    child: Text(
                      _profileInitial(sel.currentProfile?.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _OverviewTab(
                  refreshToken: _overviewRefreshToken,
                  profileId: sel.currentProfile?.id,
                  presetsRefreshToken: _presetsRefreshToken,
                  onPresetsRefresh: () {
                    setState(() => _presetsRefreshToken++);
                  },
                ),
                _PlansTab(
                  profileId: sel.currentProfile?.id,
                  refreshToken: _presetsRefreshToken,
                  onRefresh: () => setState(() => _presetsRefreshToken++),
                  onGeneratePreset: () => _openCustomPresetGenerator(sel),
                  onCreatePreset: () => _createManualPreset(sel),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              _selectedTab == 0
                  ? _SplitWorkoutBar(
                    onStartWorkout: _startWorkout,
                    onOptimizeWorkout: () => _startOptimizedWorkout(sel),
                    onOptimizeSettings: _openOptimizedWorkoutSettings,
                    isStartingOptimized: _isStartingOptimized,
                  )
                  : null,
        );
      },
    );
  }

  String _profileInitial(String? name) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return 'P';
    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _TrainTabs extends StatelessWidget {
  const _TrainTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Overview',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabButton(
            label: 'Plans',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: selected ? colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color:
                    selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.refreshToken,
    required this.profileId,
    required this.presetsRefreshToken,
    required this.onPresetsRefresh,
  });

  final int refreshToken;
  final int? profileId;
  final int presetsRefreshToken;
  final VoidCallback onPresetsRefresh;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
      children: [
        _SevenDayFocusCard(refreshToken: refreshToken),
        const SizedBox(height: 16),
        _ActivePresetsCard(
          profileId: profileId,
          refreshToken: presetsRefreshToken,
          onRefresh: onPresetsRefresh,
        ),
      ],
    );
  }
}

class _SevenDayFocusData {
  final Map<String, double> heatmapFrequencyMap;
  final List<FocusedSetHit> topBodyParts;

  const _SevenDayFocusData({
    required this.heatmapFrequencyMap,
    required this.topBodyParts,
  });
}

const _emptySevenDayFocusData = _SevenDayFocusData(
  heatmapFrequencyMap: <String, double>{},
  topBodyParts: <FocusedSetHit>[],
);

class _SevenDayFocusCard extends StatefulWidget {
  final int refreshToken;

  const _SevenDayFocusCard({required this.refreshToken});

  @override
  State<_SevenDayFocusCard> createState() => _SevenDayFocusCardState();
}

class _SevenDayFocusCardState extends State<_SevenDayFocusCard> {
  final _repo = AppRepository();
  late Future<_SevenDayFocusData> _dataFuture;

  @override
  void initState() {
    super.initState();
    unawaited(BodyHeatmap.preload());
    _dataFuture = _loadData();
  }

  @override
  void didUpdateWidget(covariant _SevenDayFocusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _dataFuture = _loadData();
    }
  }

  Future<_SevenDayFocusData> _loadData() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final Map<BodyPart, double> bodyPartSets = await _repo
        .fetchAllBodyPartSetsOverTimeRange(start: weekAgo, end: now);
    final hits =
        bodyPartSets.entries
            .where((entry) => entry.value > 0)
            .map(
              (entry) => FocusedSetHit(bodyPart: entry.key, units: entry.value),
            )
            .toList()
          ..sort((a, b) => b.units.compareTo(a.units));

    return _SevenDayFocusData(
      heatmapFrequencyMap: bodyPartFrequencyMapFromNames({
        for (final hit in hits) hit.bodyPart.name: hit.units,
      }),
      topBodyParts: hits,
    );
  }

  void _openAnalyticsDashboard() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<_SevenDayFocusData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Overview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState != ConnectionState.done &&
                    data == null)
                  const SizedBox(
                    height: 176,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError && data == null)
                  const SizedBox(
                    height: 176,
                    child: Center(child: Text('Unable to load 7-day focus')),
                  )
                else
                  _SevenDayFocusLayout(
                    data: data ?? _emptySevenDayFocusData,
                    onFocusedSetsTap: _openAnalyticsDashboard,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SevenDayFocusLayout extends StatelessWidget {
  final _SevenDayFocusData data;
  final VoidCallback onFocusedSetsTap;

  const _SevenDayFocusLayout({
    required this.data,
    required this.onFocusedSetsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final heatmapBox =
            (constraints.maxWidth * 0.43).clamp(118.0, 170.0).toDouble();
        final heatmapSize = (heatmapBox - 6).clamp(112.0, 164.0).toDouble();
        final gap = constraints.maxWidth < 330 ? 10.0 : 14.0;

        return SizedBox(
          height: 198,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: heatmapBox,
                height: 198,
                child: Center(
                  child: BodyHeatmap(
                    frequencyMap: data.heatmapFrequencyMap,
                    lowColor: colors.historySummaryHeatmapLow!,
                    highColor: colors.historySummaryHeatmapHigh!,
                    width: heatmapSize,
                    height: heatmapSize,
                  ),
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onFocusedSetsTap,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FocusedSetsList(
                            hits: data.topBodyParts,
                            maxVisible: 3,
                            emptyMessage:
                                'No completed bodypart set units in the last 7 days.',
                            titleWeight: FontWeight.w800,
                          ),
                          if (data.topBodyParts.length > 3)
                            const _MoreFocusedSetsHint(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MoreFocusedSetsHint extends StatelessWidget {
  const _MoreFocusedSetsHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(Icons.more_horiz, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            'more',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

Future<Set<int>> _loadActivePresetIds(int? profileId) async {
  return ActivePlanStore.load(profileId);
}

class _ActivePresetsCard extends StatefulWidget {
  final int? profileId;
  final int refreshToken;
  final VoidCallback onRefresh;

  const _ActivePresetsCard({
    required this.profileId,
    required this.refreshToken,
    required this.onRefresh,
  });

  @override
  State<_ActivePresetsCard> createState() => _ActivePresetsCardState();
}

class _ActivePresetsCardState extends State<_ActivePresetsCard> {
  Future<Set<int>>? _selectedIdsFuture;

  @override
  void initState() {
    super.initState();
    _selectedIdsFuture = _loadSelectedIds(widget.profileId);
  }

  @override
  void didUpdateWidget(covariant _ActivePresetsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileId != widget.profileId ||
        oldWidget.refreshToken != widget.refreshToken) {
      _selectedIdsFuture = _loadSelectedIds(widget.profileId);
    }
  }

  Future<Set<int>> _loadSelectedIds(int? profileId) async {
    return _loadActivePresetIds(profileId);
  }

  Future<void> _openPlanManagement() async {
    final profileId = widget.profileId;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gym profile first.')),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanManagementPage(profileId: profileId),
      ),
    );
    if (!mounted) return;
    setState(() {
      _selectedIdsFuture = _loadSelectedIds(profileId);
    });
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<Set<int>>(
          future: _selectedIdsFuture,
          builder: (context, snapshot) {
            final selectedIds = snapshot.data ?? const <int>{};
            final isLoading =
                snapshot.connectionState != ConnectionState.done &&
                !snapshot.hasData;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Active Plans',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit active plans',
                      onPressed: isLoading ? null : _openPlanManagement,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (widget.profileId == null)
                  Text(
                    'Select a gym profile to choose active plans.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else if (selectedIds.isEmpty)
                  Text(
                    'Tap the pen to choose which plans show here.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  PresetsLoaded(
                    scale: 0.92,
                    refreshToken: widget.refreshToken,
                    presetIds: selectedIds,
                    planActiveState: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    emptyMessage:
                        'Selected plans are no longer available. Tap the pen to update them.',
                    onRefresh: widget.onRefresh,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlansTab extends StatefulWidget {
  const _PlansTab({
    required this.profileId,
    required this.refreshToken,
    required this.onRefresh,
    required this.onGeneratePreset,
    required this.onCreatePreset,
  });

  final int? profileId;
  final int refreshToken;
  final VoidCallback onRefresh;
  final VoidCallback onGeneratePreset;
  final VoidCallback onCreatePreset;

  @override
  State<_PlansTab> createState() => _PlansTabState();
}

class _PlansTabState extends State<_PlansTab> {
  late Future<Set<int>> _activePresetIdsFuture;
  Set<int>? _lastActivePresetIds;

  @override
  void initState() {
    super.initState();
    _activePresetIdsFuture = _loadActivePresetIds(widget.profileId);
  }

  @override
  void didUpdateWidget(covariant _PlansTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileId != widget.profileId ||
        oldWidget.refreshToken != widget.refreshToken) {
      if (oldWidget.profileId != widget.profileId) {
        _lastActivePresetIds = null;
      }
      _activePresetIdsFuture = _loadActivePresetIds(widget.profileId);
    }
  }

  void _openPremadePlans() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => PremadePlansPage(
                profileId: widget.profileId,
                onPlanAdded: widget.onRefresh,
              ),
        ),
      ),
    );
  }

  Future<void> _openPlanManagement() async {
    final profileId = widget.profileId;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gym profile first.')),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanManagementPage(profileId: profileId),
      ),
    );
    if (!mounted) return;
    setState(() {
      _activePresetIdsFuture = _loadActivePresetIds(profileId);
    });
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Set<int>>(
      future: _activePresetIdsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _lastActivePresetIds = snapshot.data;
        }
        final activeIds = snapshot.data ?? _lastActivePresetIds;
        if (activeIds == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _PresetSectionCard(
              title: 'Active Plans',
              onEdit: _openPlanManagement,
              child: PresetsLoaded(
                scale: 0.96,
                refreshToken: widget.refreshToken,
                presetIds: activeIds,
                planActiveState: true,
                progressiveReveal: true,
                initialVisibleCount: 3,
                revealBatchSize: 5,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                emptyMessage:
                    'No active plans yet. Use the pen on the Overview Active Plans card to choose what stays ready.',
                onRefresh: widget.onRefresh,
              ),
            ),
            const SizedBox(height: 16),
            _PresetSectionCard(
              title: 'Archived Plans',
              onEdit: _openPlanManagement,
              child: PresetsLoaded(
                scale: 0.96,
                refreshToken: widget.refreshToken,
                excludedPresetIds: activeIds,
                planActiveState: false,
                progressiveReveal: true,
                initialVisibleCount: 3,
                revealBatchSize: 5,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                emptyMessage: 'No archived plans.',
                onRefresh: widget.onRefresh,
              ),
            ),
            const SizedBox(height: 16),
            _PremadePlansCard(onOpen: _openPremadePlans),
            const SizedBox(height: 16),
            GenericBar(
              label: 'Generate Custom Plans',
              color: Colors.purple,
              onTap: widget.onGeneratePreset,
            ),
            const SizedBox(height: 8),
            GenericBar(
              label: 'Manually Add Plan',
              color: Colors.purple,
              onTap: widget.onCreatePreset,
            ),
          ],
        );
      },
    );
  }
}

class _PresetSectionCard extends StatelessWidget {
  final String title;
  final VoidCallback? onEdit;
  final Widget child;

  const _PresetSectionCard({
    required this.title,
    this.onEdit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                if (onEdit != null)
                  IconButton(
                    tooltip: 'Manage plans',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _PremadePlansCard extends StatelessWidget {
  final VoidCallback onOpen;

  const _PremadePlansCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  size: 32,
                ),
                const SizedBox(width: 14),
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
              '${premadeTrainingPlans.length} curated routines available to copy into your plans.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: onOpen,
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

class _SplitWorkoutBar extends StatelessWidget {
  const _SplitWorkoutBar({
    required this.onStartWorkout,
    required this.onOptimizeWorkout,
    required this.onOptimizeSettings,
    required this.isStartingOptimized,
  });

  final VoidCallback onStartWorkout;
  final VoidCallback onOptimizeWorkout;
  final VoidCallback onOptimizeSettings;
  final bool isStartingOptimized;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final green = Colors.green.shade700;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Material(
                  color: green,
                  child: InkWell(
                    onTap: onStartWorkout,
                    child: const Center(
                      child: Text(
                        'Start Workout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: double.infinity,
                color: colorScheme.outline.withValues(alpha: 0.18),
              ),
              Expanded(
                flex: 2,
                child: Material(
                  color: colorScheme.primaryContainer,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: InkWell(
                          onTap: isStartingOptimized ? null : onOptimizeWorkout,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 36),
                            child: Center(
                              child:
                                  isStartingOptimized
                                      ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      )
                                      : Text(
                                        'Optimize',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          tooltip: 'Optimized workout settings',
                          onPressed:
                              isStartingOptimized ? null : onOptimizeSettings,
                          icon: const Icon(Icons.settings_outlined),
                          iconSize: 19,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 64,
                          ),
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
