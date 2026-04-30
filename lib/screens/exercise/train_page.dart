// File: lib/screens/exercise/train_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/definition_models.dart';
import '../../models/training_plan_models.dart';
import '../../providers/active_session.dart';
import '../../providers/preset_session.dart';
import '../../providers/selected_profile.dart';
import '../../repositories/app_repository.dart';
import '../../services/preset_generation_service.dart';

import '../../widgets/generic_bar.dart';
import '../../widgets/presets_loaded.dart';
import '../../widgets/drawers.dart';
import '../../widgets/bodypart_focus_chips.dart';

import 'gym_profile_screen.dart';
import 'preset_detail_screen.dart';
import 'session_screen.dart';
import 'preset_generation_qa.dart';
import '../../widgets/history_content.dart';

import 'exercise_catalog_page.dart';
import 'muscle_filter_page.dart';
import '../profile/settings/gym_exercise_settings_page.dart';

class _OptimizedWorkoutSettingsResult {
  final int minutes;
  final int maxSets;
  final Set<int> preferredBodypartIds;
  final Set<int> blacklistedBodypartIds;

  const _OptimizedWorkoutSettingsResult({
    required this.minutes,
    required this.maxSets,
    required this.preferredBodypartIds,
    required this.blacklistedBodypartIds,
  });
}

class TrainPage extends StatefulWidget {
  const TrainPage({super.key});

  @override
  State<TrainPage> createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  static const _optimizedSessionMinutesKey = 'train.optimized_session_minutes';
  static const _optimizedMaxSetsKey = 'train.optimized_max_sets_per_exercise';

  final _repo = AppRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _lastProfileId;
  int _selectedTab = 0; // 0 = Train, 1 = History
  int _presetsRefreshToken = 0;
  int _historyRefreshToken = 0;
  int? _seenCompletedSessionVersion;
  bool _isStartingOptimized = false;
  int _optimizedSessionMinutes = SessionSpec.defaultSessionDurationMinutes;
  int _optimizedMaxSetsPerExercise = SessionSpec.defaultMaxSetsPerExercise;
  Set<int> _optimizedPreferredBodypartIds = <int>{};
  Set<int> _optimizedBlacklistedBodypartIds = <int>{};

  @override
  void initState() {
    super.initState();
    _loadOptimizedWorkoutSettings();
  }

  Future<void> _loadOptimizedWorkoutSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMinutes = prefs.getInt(_optimizedSessionMinutesKey);
    final savedMaxSets = prefs.getInt(_optimizedMaxSetsKey);
    if (!mounted) return;
    setState(() {
      if (savedMinutes != null && savedMinutes > 0) {
        _optimizedSessionMinutes = savedMinutes;
      }
      if (savedMaxSets != null &&
          savedMaxSets >= SessionSpec.defaultMinSetsPerExercise &&
          savedMaxSets <= SessionSpec.maxAllowedSetsPerExercise) {
        _optimizedMaxSetsPerExercise = savedMaxSets;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sel = context.watch<SelectedProfile>();
    final pid = sel.currentProfile?.id;
    if (pid != null && pid != _lastProfileId) {
      _lastProfileId = pid;
      _ensureDefaults(pid);
    }
  }

  Future<void> _ensureDefaults(int? profileId) async {
    if (profileId == null) return;
    final existing = await _repo.fetchAllPresetsRaw(profileId: profileId);
    if (existing.isNotEmpty) return;
    await _repo.findOrCreatePreset('Preset 1', profileId: profileId);
    await _repo.findOrCreatePreset('Preset 2', profileId: profileId);
    if (!mounted) return;
    setState(() => _presetsRefreshToken++);
  }

  Future<void> _openPreset(int presetId, {bool edit = false}) {
    return Navigator.of(context).push(
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
  }

  SessionSpec _buildOptimizedSpec(
    int profileId, {
    required int sessionMinutes,
  }) {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    const minSets = SessionSpec.defaultMinSetsPerExercise;
    return SessionSpec(
      profileId: profileId,
      name: 'Optimized workout $date $time',
      focusBodypartIds: const [],
      preferredBodypartIds: _optimizedPreferredBodypartIds.toList(),
      blacklistedBodypartIds: _optimizedBlacklistedBodypartIds.toList(),
      maxExercises: SessionSpec.maxExercisesForDuration(
        sessionDurationMinutes: sessionMinutes,
        minSetsPerExercise: minSets,
      ),
      minSetsPerExercise: minSets,
      maxSetsPerExercise: _optimizedMaxSetsPerExercise,
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

    var draftMinutes = _optimizedSessionMinutes.toString();
    var draftMaxSets = _optimizedMaxSetsPerExercise.toString();
    final draftPreferred = {..._optimizedPreferredBodypartIds};
    final draftBlacklisted = {..._optimizedBlacklistedBodypartIds};

    final settings = await showDialog<_OptimizedWorkoutSettingsResult>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                title: const Text('Optimized workout settings'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Used to budget 3 minutes per set plus 5 minutes to start each exercise.',
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Bodypart picks apply only to the next optimized workout you start.',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: draftMinutes,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => draftMinutes = value,
                          decoration: const InputDecoration(
                            labelText: 'Workout duration',
                            suffixText: 'min',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: draftMaxSets,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => draftMaxSets = value,
                          decoration: const InputDecoration(
                            labelText: 'Up to sets per exercise',
                            suffixText: 'sets',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bodypart focus',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap once to prefer a bodypart, tap again to avoid it, and tap a third time to clear it.',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        BodypartFocusChips(
                          bodyParts: bodyParts,
                          preferredBodypartIds: draftPreferred,
                          blacklistedBodypartIds: draftBlacklisted,
                          emptyText: 'Bodyparts could not be loaded.',
                          onChanged:
                              (selection) => setDialogState(() {
                                draftPreferred
                                  ..clear()
                                  ..addAll(selection.preferredBodypartIds);
                                draftBlacklisted
                                  ..clear()
                                  ..addAll(selection.blacklistedBodypartIds);
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      final minutes = int.tryParse(draftMinutes.trim());
                      final maxSets = int.tryParse(draftMaxSets.trim());
                      if (minutes == null ||
                          minutes <= 0 ||
                          maxSets == null ||
                          maxSets < SessionSpec.defaultMinSetsPerExercise ||
                          maxSets > SessionSpec.maxAllowedSetsPerExercise) {
                        return;
                      }
                      Navigator.of(dialogContext).pop(
                        _OptimizedWorkoutSettingsResult(
                          minutes: minutes,
                          maxSets: maxSets,
                          preferredBodypartIds: {...draftPreferred},
                          blacklistedBodypartIds: {...draftBlacklisted},
                        ),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          ),
    );
    if (!mounted || settings == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_optimizedSessionMinutesKey, settings.minutes);
    await prefs.setInt(_optimizedMaxSetsKey, settings.maxSets);
    if (!mounted) return;
    setState(() {
      _optimizedSessionMinutes = settings.minutes;
      _optimizedMaxSetsPerExercise = settings.maxSets;
      _optimizedPreferredBodypartIds = settings.preferredBodypartIds;
      _optimizedBlacklistedBodypartIds = settings.blacklistedBodypartIds;
    });
  }

  Future<void> _openCustomPresetGenerator(SelectedProfile sel) async {
    final profileId = sel.currentProfile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gym profile first.')),
      );
      return;
    }

    final presetId = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => PresetGenerationQaScreen(profileId: profileId),
      ),
    );
    if (!mounted || presetId == null) return;

    setState(() => _presetsRefreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preset generated. Opening it now.')),
    );
    await _openPreset(presetId);
    if (!mounted) return;
    setState(() => _presetsRefreshToken++);
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

  Future<void> _startOptimizedWorkout(SelectedProfile sel) async {
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
        sessionMinutes: _optimizedSessionMinutes,
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
        active.addExercise(preset.exercises[i], preset.cardTypes[i]);
      }

      // Optimized workouts are one-off sessions, not saved presets.
      await _repo.deletePreset(presetId);
      temporaryPresetId = null;
      active.start();

      if (!mounted) return;
      setState(() {
        _presetsRefreshToken++;
        _optimizedPreferredBodypartIds.clear();
        _optimizedBlacklistedBodypartIds.clear();
      });
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SessionScreen()));
      if (!mounted) return;
      setState(() => _historyRefreshToken++);
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
      _historyRefreshToken++;
    }

    return Consumer<SelectedProfile>(
      builder: (_, sel, __) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: MainDrawer(
            headerTitle: 'Training Menu',
            items: [
              DrawerItem(
                title: 'Exercise Catalog',
                builder: (_) => const ExerciseCatalogPage(),
              ),
              DrawerItem(
                title: 'Muscle Filter',
                builder: (_) => const MuscleFilterPage(),
              ),
              DrawerItem(
                title: 'Gym & Workout Settings',
                builder: (_) => const GymExerciseSettingsPage(),
              ),
            ],
          ),
          endDrawer: ProfileDrawer(
            profiles: sel.profiles,
            selected: sel.currentProfile,
            onSelect: (profile) {
              sel.selectProfile(profile);
              Navigator.of(context).pop();
              setState(() {
                _presetsRefreshToken++;
                _historyRefreshToken++;
              });
            },
            onEdit: (profile) {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GymProfileScreen(profile: profile),
                ),
              );
            },
            onDeleteAll: () {
              sel.deleteProfile(sel.currentProfile!.id!);
              setState(() {
                _presetsRefreshToken++;
                _historyRefreshToken++;
              });
            },
          ),

          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            title: Center(
              child: Container(
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(20),
                  borderWidth: 0,
                  borderColor: Colors.transparent,
                  selectedBorderColor: Colors.transparent,
                  fillColor: Theme.of(context).colorScheme.primary,
                  selectedColor: Theme.of(context).colorScheme.onPrimary,
                  constraints: const BoxConstraints(
                    minWidth: 100,
                    minHeight: 32,
                  ),
                  isSelected: [_selectedTab == 0, _selectedTab == 1],
                  onPressed: (idx) {
                    setState(() {
                      _selectedTab = idx;
                      if (idx == 1) {
                        _historyRefreshToken++;
                      }
                    });
                  },
                  children: const [Text('Train'), Text('History')],
                ),
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.lightGreen,
                  child: Text(
                    'P',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),

          body: SafeArea(
            child: IndexedStack(
              index: _selectedTab,
              children: [_buildTrainContent(sel), _buildHistoryContent()],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrainContent(SelectedProfile sel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Exercise Presets',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PresetsLoaded(
              scale: 1.0,
              refreshToken: _presetsRefreshToken,
              onRefresh: () => setState(() {}),
            ),
          ),
        ),
        const Divider(height: 1),

        const SizedBox(height: 8),
        GenericBar(
          label: 'Generate Custom Presets',
          color: Colors.purple,
          onTap: () => _openCustomPresetGenerator(sel),
        ),
        const SizedBox(height: 8),
        GenericBar(
          label: 'Manually Add Preset',
          color: Colors.purple,
          onTap: () async {
            final profileId = sel.currentProfile?.id;
            final existing = await _repo.fetchAllPresetsRaw(
              profileId: profileId,
            );
            final nextNum = existing.length + 1;
            final name = nextNum == 1 ? 'New Preset' : 'New Preset $nextNum';
            final newId = await _repo.createPreset(name, profileId: profileId);
            _openPreset(newId, edit: true);
            if (!mounted) return;
            setState(() => _presetsRefreshToken++);
          },
        ),

        const SizedBox(height: 8),

        GenericBar(
          label:
              _isStartingOptimized
                  ? 'Building Optimized Workout...'
                  : 'Start Optimized Workout',
          color: Colors.green,
          onTap:
              _isStartingOptimized ? null : () => _startOptimizedWorkout(sel),
          trailing:
              _isStartingOptimized
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : IconButton(
                    tooltip: 'Optimized workout settings',
                    icon: const Icon(Icons.settings_outlined),
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    color: Colors.green,
                    onPressed: _openOptimizedWorkoutSettings,
                  ),
        ),

        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              context.read<ActiveSession>().start();
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(builder: (_) => const SessionScreen()),
                  )
                  .then((_) {
                    if (!mounted) return;
                    setState(() => _historyRefreshToken++);
                  });
            },
            child: const Text('New Session'),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryContent() {
    return HistoryContent(
      refreshToken: _historyRefreshToken,
      onReload: () => setState(() {}),
    );
  }
}
