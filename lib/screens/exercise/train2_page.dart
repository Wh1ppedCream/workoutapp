// File: lib/screens/exercise/train2_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/active_session.dart';
import '../../providers/preset_session.dart';
import '../../providers/selected_profile.dart';
import '../../repositories/app_repository.dart';
import '../../services/preset_generation_service.dart';
import '../../utils/workout_exercise_clone.dart';

import '../../widgets/generic_bar.dart';
import '../../widgets/presets_loaded.dart';
import '../../widgets/drawers.dart';
import '../../widgets/bodypart_focus_chips.dart';
import '../../widgets/exercise_card.dart';

import 'gym_profile_screen.dart';
import 'preset_detail_screen.dart';
import 'session_screen.dart';
import 'preset_generation_qa.dart';
import '../../widgets/history_content.dart';

import 'exercise_catalog_page.dart';
import 'muscle_filter_page.dart';
import '../profile/settings/gym_exercise_settings_page.dart';

/// Result returned by the optimized-workout settings dialog.
///
/// Preferred/blacklisted bodyparts are intentionally transient: they affect the
/// next optimized session only and are not persisted like duration/set limits.
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

/// Legacy training hub.
///
/// This page owns the Train/History tab switch, preset list refreshes, and the
/// "Start Optimized Workout" entry point. It delegates actual generation to
/// [PresetGenerationService] and keeps only lightweight UI preferences locally.
class Train2Page extends StatefulWidget {
  const Train2Page({super.key});

  @override
  State<Train2Page> createState() => _Train2PageState();
}

class _Train2PageState extends State<Train2Page> {
  static const _optimizedSessionMinutesKey = 'train.optimized_session_minutes';
  static const _optimizedMaxSetsKey = 'train.optimized_max_sets_per_exercise';

  AppRepository get _repo => context.read<AppRepository>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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

  /// Loads durable optimized-workout defaults. Bodypart focus choices are not
  /// loaded here because they apply only to the next generated session.
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

  Future<void> _openPreset(int presetId, {bool edit = false}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (outerCtx) => MultiProvider(
              providers: [
                ChangeNotifierProvider<ActiveSession>.value(
                  value: outerCtx.read<ActiveSession>(),
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
  }

  /// Builds the generation spec used by Start Optimized Workout.
  ///
  /// Optimized sessions use recent history and avoid the most recent dominant
  /// bodypart, but they do not create a saved preset.
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
      useGeneratedRepWeights: true,
      repWeightMode: RepWeightGenerationMode.mixed,
      targetRepCount: SessionSpec.defaultTargetRepCount,
      starterWeightIntensity: StarterWeightIntensity.medium,
      historyWindow: const Duration(days: 7),
      avoidMostRecentBodyPart: true,
      now: now,
    );
  }

  Future<void> _openOptimizedWorkoutSettings() async {
    final strings = AppLocalizations.of(context);
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
                title: Text(strings.trainOptimizedSettingsTitle),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(strings.trainOptimizedSettingsBudgetBody),
                        const SizedBox(height: 4),
                        Text(
                          strings.trainOptimizedSettingsFocusBody,
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: draftMinutes,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => draftMinutes = value,
                          decoration: InputDecoration(
                            labelText: strings.trainWorkoutDuration,
                            suffixText: strings.trainMinutesShort,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: draftMaxSets,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => draftMaxSets = value,
                          decoration: InputDecoration(
                            labelText: strings.trainSetsPerExercise,
                            suffixText: strings.trainSetsShort,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          strings.trainBodypartFocus,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.trainBodypartFocusHelp,
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        BodypartFocusChips(
                          bodyParts: bodyParts,
                          preferredBodypartIds: draftPreferred,
                          blacklistedBodypartIds: draftBlacklisted,
                          emptyText: strings.trainBodypartsLoadFailed,
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
                    child: Text(strings.commonCancel),
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
                    child: Text(strings.commonSave),
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
        SnackBar(
          content: Text(AppLocalizations.of(context).trainSelectProfileFirst),
        ),
      );
      return;
    }

    final presetIds = await Navigator.of(context).push<List<int>>(
      MaterialPageRoute(
        builder: (_) => PresetGenerationQaScreen(profileId: profileId),
      ),
    );
    if (!mounted || presetIds == null || presetIds.isEmpty) return;

    setState(() => _presetsRefreshToken++);
    if (presetIds.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).trainPlanGenerated),
        ),
      );
      await _openPreset(presetIds.first);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).trainPlansGenerated(presetIds.length),
          ),
        ),
      );
    }
    if (!mounted) return;
    setState(() => _presetsRefreshToken++);
  }

  Future<void> _showOptimizedWorkoutRestWarning() {
    return showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(AppLocalizations.of(context).trainRestTitle),
            content: Text(AppLocalizations.of(context).trainRestBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(AppLocalizations.of(context).commonOkay),
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
        SnackBar(
          content: Text(AppLocalizations.of(context).trainSelectProfileFirst),
        ),
      );
      return;
    }

    final active = context.read<ActiveSession>();
    await active.ready;
    if (!mounted) return;
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

      final generationResult = await generator.generatePresetWithDetails(spec);
      final presetId = generationResult.presetId;
      temporaryPresetId = presetId;
      final preset = PresetSession(presetId, repository: _repo);
      await preset.ready;

      if (!mounted) return;
      if (preset.exercises.isEmpty) {
        await _repo.deletePreset(presetId);
        temporaryPresetId = null;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).trainNoEligibleExercises,
            ),
          ),
        );
        return;
      }

      final workoutExercises = <WorkoutExercise>[];
      final workoutCardTypes = <CardType>[];
      for (var i = 0; i < preset.exercises.length; i++) {
        // TODO(cardio/stretch): add cardio and stretch back to legacy plan
        // starts after those cards are fixed and updated.
        if (preset.cardTypes[i] != CardType.weight) continue;
        workoutExercises.add(cloneWorkoutExercise(preset.exercises[i]));
        workoutCardTypes.add(preset.cardTypes[i]);
      }

      final started = await active.startWithExercises(
        workoutExercises: workoutExercises,
        workoutCardTypes: workoutCardTypes,
      );
      // Optimized workouts are one-off sessions, not saved presets.
      await _repo.deletePreset(presetId);
      temporaryPresetId = null;

      if (!started) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).trainActiveWorkoutKept),
          ),
        );
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SessionScreen()));
        return;
      }

      if (!mounted) return;
      setState(() {
        _presetsRefreshToken++;
        _optimizedPreferredBodypartIds.clear();
        _optimizedBlacklistedBodypartIds.clear();
      });
      _showOptimizedWeightEstimateNotice(generationResult);
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SessionScreen()));
      if (!mounted) return;
      setState(() => _historyRefreshToken++);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).trainOptimizedStartFailed(e.toString()),
          ),
        ),
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

  void _showOptimizedWeightEstimateNotice(PresetGenerationResult result) {
    if (!mounted) return;
    final estimatedCount = result.exercisesWithStarterWeightEstimates.length;
    final unavailableCount =
        result.exercisesWithUnavailableStarterWeights.length;
    if (estimatedCount == 0 && unavailableCount == 0) return;

    final message =
        unavailableCount > 0
            ? AppLocalizations.of(
              context,
            ).trainOptimizedManualWeights(unavailableCount)
            : AppLocalizations.of(
              context,
            ).trainOptimizedStarterWeights(estimatedCount);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
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
            headerTitle: strings.trainMenuTitle,
            items: [
              DrawerItem(
                title: strings.trainExerciseCatalog,
                builder: (_) => const ExerciseCatalogPage(),
              ),
              DrawerItem(
                title: strings.trainMuscleFilter,
                builder: (_) => const MuscleFilterPage(),
              ),
              DrawerItem(
                title: strings.trainGymSettings,
                builder: (_) => const GymExerciseSettingsPage(),
              ),
            ],
          ),
          endDrawer: ProfileDrawer(
            profiles: sel.profiles,
            selected: sel.currentProfile,
            onSelect: (profile) async {
              final navigator = Navigator.of(context);
              await sel.selectProfile(profile);
              if (!mounted) return;
              if (navigator.canPop()) {
                unawaited(navigator.maybePop());
              }
              setState(() {
                _presetsRefreshToken++;
                _historyRefreshToken++;
              });
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
            onDelete: (profile) async {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                unawaited(navigator.maybePop());
              }
              final profileId = profile.id;
              if (profileId == null) return;
              await sel.deleteProfile(profileId);
              if (!mounted) return;
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
                  children: [
                    Text(strings.trainTab),
                    Text(strings.trainHistoryTab),
                  ],
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
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            strings.trainExercisePresets,
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
          label: AppLocalizations.of(context).trainGeneratePlans,
          color: Colors.purple,
          onTap: () => _openCustomPresetGenerator(sel),
        ),
        const SizedBox(height: 8),
        GenericBar(
          label: AppLocalizations.of(context).trainAddPlan,
          color: Colors.purple,
          onTap: () async {
            final strings = AppLocalizations.of(context);
            final profileId = sel.currentProfile?.id;
            final existing = await _repo.fetchAllPresetsRaw(
              profileId: profileId,
            );
            final nextNum = existing.length + 1;
            final name =
                nextNum == 1
                    ? strings.trainNewPlanFirst
                    : strings.trainNewPlan(nextNum);
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
                  ? AppLocalizations.of(context).trainBuildingOptimized
                  : AppLocalizations.of(context).trainStartOptimized,
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
                    tooltip:
                        AppLocalizations.of(
                          context,
                        ).trainOptimizedSettingsTitle,
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
            onPressed: () async {
              final navigator = Navigator.of(context);
              await context.read<ActiveSession>().start();
              if (!mounted) return;
              await navigator.push(
                MaterialPageRoute(builder: (_) => const SessionScreen()),
              );
              if (!mounted) return;
              setState(() => _historyRefreshToken++);
            },
            child: Text(AppLocalizations.of(context).trainNewSession),
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
