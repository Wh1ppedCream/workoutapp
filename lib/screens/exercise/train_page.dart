import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/premade_training_plans.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/safe_failure_localizations.dart';
import '../../models/models.dart';
import '../../providers/active_session.dart';
import '../../providers/preset_session.dart';
import '../../providers/selected_profile.dart';
import '../../repositories/app_repository.dart';
import '../../services/active_plan_store.dart';
import '../../services/preset_generation_service.dart';
import '../../services/tutorial_state_store.dart';
import '../../utils/localized_formatters.dart';
import '../../utils/workout_exercise_clone.dart';
import '../../utils/app_test_keys.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/tokens/app_expressive_train_tokens.dart';
import '../../theme/widgets/tonos_action.dart';
import '../../theme/widgets/tonos_dialog.dart';
import '../../theme/widgets/tonos_expressive_motion.dart';
import '../../theme/widgets/tonos_surface.dart';
import '../../widgets/drawers.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/generic_bar.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/presets_loaded.dart';
import '../../widgets/seven_day_focus_card.dart';
import '../../widgets/tonos_train_tabs.dart';
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
  static const _optimizedMinSetsKey = 'train.optimized_min_sets_per_exercise';
  static const _optimizedMaxSetsKey = 'train.optimized_max_sets_per_exercise';
  static const _optimizedRepWeightModeKey = 'train.optimized_rep_weight_mode';
  static const _optimizedTargetRepsKey = 'train.optimized_target_reps';
  static const _optimizedStarterIntensityKey =
      'train.optimized_starter_intensity';

  AppRepository get _repo => context.read<AppRepository>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _trainTabsTutorialKey = GlobalKey(debugLabel: 'train_tabs_tutorial');
  final _gymProfileTutorialKey = GlobalKey(
    debugLabel: 'train_gym_profile_tutorial',
  );
  final _weeklyOverviewTutorialKey = GlobalKey(
    debugLabel: 'train_weekly_overview_tutorial',
  );
  final _activePlansTutorialKey = GlobalKey(
    debugLabel: 'train_active_plans_tutorial',
  );
  final _workoutBarTutorialKey = GlobalKey(
    debugLabel: 'train_workout_bar_tutorial',
  );
  final _tutorialStore = const TutorialStateStore();

  int _selectedTab = 0;
  int _overviewRefreshToken = 0;
  int _presetsRefreshToken = 0;
  int? _lastProfileId;
  int? _seenCompletedSessionVersion;
  bool _isStartingOptimized = false;
  int _optimizedSessionMinutes = SessionSpec.defaultSessionDurationMinutes;
  int _optimizedMinSetsPerExercise = SessionSpec.preferredMinSetsPerExercise;
  int _optimizedMaxSetsPerExercise = SessionSpec.defaultMaxSetsPerExercise;
  RepWeightGenerationMode _optimizedRepWeightMode =
      RepWeightGenerationMode.mixed;
  int _optimizedTargetRepCount = SessionSpec.defaultTargetRepCount;
  StarterWeightIntensity _optimizedStarterWeightIntensity =
      StarterWeightIntensity.medium;
  Set<int> _optimizedPreferredBodypartIds = <int>{};
  Set<int> _optimizedBlacklistedBodypartIds = <int>{};
  bool _trainTutorialQueued = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadOptimizedWorkoutSettings());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTrainTutorial();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profileId = context.watch<SelectedProfile>().currentProfile?.id;
    if (_lastProfileId != profileId) {
      _lastProfileId = profileId;
      _presetsRefreshToken++;
    }
    if (TickerMode.valuesOf(context).enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queueTrainTutorial();
      });
    }
  }

  void _queueTrainTutorial() {
    if (!mounted ||
        _trainTutorialQueued ||
        !TickerMode.valuesOf(context).enabled) {
      return;
    }
    _trainTutorialQueued = true;
    unawaited(_showTrainTutorialIfNeeded());
  }

  Future<void> _showTrainTutorialIfNeeded() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted || !TickerMode.valuesOf(context).enabled) return;

      final completed = await _tutorialStore.isCompleted(TutorialIds.trainHome);
      if (completed || !mounted || _selectedTab != 0) return;
      final strings = AppLocalizations.of(context);

      await GuidedTutorialOverlay.show(
        context,
        steps: [
          GuidedTutorialStep(
            targetKey: _trainTabsTutorialKey,
            icon: Icons.view_week_outlined,
            title: strings.trainTutorialSpacesTitle,
            body: strings.trainTutorialSpacesBody,
          ),
          GuidedTutorialStep(
            targetKey: _weeklyOverviewTutorialKey,
            icon: Icons.accessibility_new,
            title: strings.trainTutorialWeeklyTitle,
            body: strings.trainTutorialWeeklyBody,
          ),
          GuidedTutorialStep(
            targetKey: _activePlansTutorialKey,
            icon: Icons.assignment_outlined,
            title: strings.trainTutorialActivePlansTitle,
            body: strings.trainTutorialActivePlansBody,
          ),
          GuidedTutorialStep(
            targetKey: _workoutBarTutorialKey,
            icon: Icons.play_circle_outline,
            title: strings.trainTutorialStartTitle,
            body: strings.trainTutorialStartBody,
          ),
          GuidedTutorialStep(
            targetKey: _gymProfileTutorialKey,
            icon: Icons.storefront_outlined,
            title: strings.trainTutorialProfilesTitle,
            body: strings.trainTutorialProfilesBody,
          ),
        ],
      );
      await _tutorialStore.markCompleted(TutorialIds.trainHome);
    } finally {
      _trainTutorialQueued = false;
    }
  }

  Future<void> _openPreset(int presetId) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (outerCtx) => MultiProvider(
          providers: [
            ChangeNotifierProvider<ActiveSession>.value(
              value: outerCtx.read<ActiveSession>(),
            ),
            ChangeNotifierProvider(
              create: (context) => PresetSession(
                presetId,
                repository: context.read<AppRepository>(),
              ),
            ),
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
        SnackBar(
          content: Text(AppLocalizations.of(context).trainSelectProfileFirst),
        ),
      );
      return;
    }

    final generatedPresetIds = await Navigator.of(context).push<List<int>>(
      MaterialPageRoute(
        builder: (_) => PresetGenerationQaScreen(profileId: profileId),
      ),
    );
    if (generatedPresetIds == null || generatedPresetIds.isEmpty || !mounted) {
      return;
    }
    setState(() => _presetsRefreshToken++);
    if (generatedPresetIds.length == 1) {
      await _openPreset(generatedPresetIds.first);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)
              .trainGeneratedPlans(generatedPresetIds.length),
        ),
      ),
    );
  }

  Future<void> _createManualPreset(SelectedProfile sel) async {
    try {
      await _createManualPresetImpl(sel);
    } catch (error, stack) {
      assert(() {
        debugPrint('Manual plan creation failed: $error');
        debugPrintStack(stackTrace: stack);
        return true;
      }());
      rethrow;
    }
  }

  Future<void> _createManualPresetImpl(SelectedProfile sel) async {
    final profileId = sel.currentProfile?.id;
    final existing = await _repo.fetchAllPresetsRaw(profileId: profileId);
    final nextNum = existing.length + 1;
    if (!mounted) return;
    final name = AppLocalizations.of(context).trainNewPlanName(nextNum);
    await ActivePlanStore(repository: _repo).load(profileId);
    final newId = await _repo.createPresetAtomic(
      name: name,
      profileId: profileId,
      exercises: const [],
      activate: true,
      uniqueName: true,
    );
    if (!mounted) return;
    setState(() => _presetsRefreshToken++);
    await _openPreset(newId);
  }

  Future<void> _startWorkout() async {
    await context.read<ActiveSession>().start();
    if (!mounted) return;
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SessionScreen()));
    if (!mounted) return;
    setState(() => _overviewRefreshToken++);
  }

  Future<void> _loadOptimizedWorkoutSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMinutes = prefs.getInt(_optimizedSessionMinutesKey);
    final savedMinSets = prefs.getInt(_optimizedMinSetsKey);
    final savedMaxSets = prefs.getInt(_optimizedMaxSetsKey);
    final savedRepWeightMode = prefs.getString(_optimizedRepWeightModeKey);
    final savedTargetReps = prefs.getInt(_optimizedTargetRepsKey);
    final savedStarterIntensity = prefs.getString(
      _optimizedStarterIntensityKey,
    );
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
      _optimizedRepWeightMode =
          _repWeightModeFromName(savedRepWeightMode) ??
          RepWeightGenerationMode.mixed;
      if (savedTargetReps != null && savedTargetReps > 0) {
        _optimizedTargetRepCount = savedTargetReps;
      }
      _optimizedStarterWeightIntensity =
          _starterIntensityFromName(savedStarterIntensity) ??
          StarterWeightIntensity.medium;
    });
  }

  RepWeightGenerationMode? _repWeightModeFromName(String? name) {
    if (name == null) return null;
    for (final mode in RepWeightGenerationMode.values) {
      if (mode.name == name) return mode;
    }
    return null;
  }

  StarterWeightIntensity? _starterIntensityFromName(String? name) {
    if (name == null) return null;
    for (final intensity in StarterWeightIntensity.values) {
      if (intensity.name == name) return intensity;
    }
    return null;
  }

  SessionSpec _buildOptimizedSpec(
    int profileId, {
    required int sessionMinutes,
    int? minSetsPerExercise,
    int? maxSetsPerExercise,
    RepWeightGenerationMode? repWeightMode,
    int? targetRepCount,
    StarterWeightIntensity? starterWeightIntensity,
    Set<int>? preferredBodypartIds,
    Set<int>? blacklistedBodypartIds,
  }) {
    final now = DateTime.now();
    final locale = Localizations.localeOf(context);
    final date = LocalizedFormatters.date(now, locale);
    final time = LocalizedFormatters.time(now, locale);
    final minSets = minSetsPerExercise ?? _optimizedMinSetsPerExercise;
    final strings = AppLocalizations.of(context);
    return SessionSpec(
      profileId: profileId,
      name: strings.trainOptimizedWorkoutName(date, time),
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
      useGeneratedRepWeights: true,
      repWeightMode: repWeightMode ?? _optimizedRepWeightMode,
      targetRepCount: targetRepCount ?? _optimizedTargetRepCount,
      starterWeightIntensity:
          starterWeightIntensity ?? _optimizedStarterWeightIntensity,
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

    final settings = await Navigator.of(context)
        .push<OptimizedWorkoutSettingsResult>(
          MaterialPageRoute(
            builder: (_) => OptimizedWorkoutSettingsPage(
              initialMinutes: _optimizedSessionMinutes,
              initialMinSets: _optimizedMinSetsPerExercise,
              initialMaxSets: _optimizedMaxSetsPerExercise,
              initialRepWeightMode: _optimizedRepWeightMode,
              initialTargetRepCount: _optimizedTargetRepCount,
              initialStarterWeightIntensity: _optimizedStarterWeightIntensity,
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
    await prefs.setString(
      _optimizedRepWeightModeKey,
      settings.repWeightMode.name,
    );
    await prefs.setInt(_optimizedTargetRepsKey, settings.targetRepCount);
    await prefs.setString(
      _optimizedStarterIntensityKey,
      settings.starterWeightIntensity.name,
    );
    if (!mounted) return;
    setState(() {
      _optimizedSessionMinutes = settings.minutes;
      _optimizedMinSetsPerExercise = settings.minSets;
      _optimizedMaxSetsPerExercise = settings.maxSets;
      _optimizedRepWeightMode = settings.repWeightMode;
      _optimizedTargetRepCount = settings.targetRepCount;
      _optimizedStarterWeightIntensity = settings.starterWeightIntensity;
      _optimizedPreferredBodypartIds = settings.preferredBodypartIds;
      _optimizedBlacklistedBodypartIds = settings.blacklistedBodypartIds;
    });
  }

  Future<void> _showOptimizedWorkoutRestWarning() {
    final strings = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => TonosDialogFrame(
        child: AlertDialog(
          title: Text(strings.trainRestTitle),
          content: Text(strings.trainRestBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(strings.commonOkay),
            ),
          ],
        ),
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
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const SessionScreen()));
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
        repWeightMode: settingsOverride?.repWeightMode,
        targetRepCount: settingsOverride?.targetRepCount,
        starterWeightIntensity: settingsOverride?.starterWeightIntensity,
        preferredBodypartIds: settingsOverride?.preferredBodypartIds,
        blacklistedBodypartIds: settingsOverride?.blacklistedBodypartIds,
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
        // TODO(cardio/stretch): add cardio and stretch back to generated
        // sessions after those cards are fixed and updated.
        if (preset.cardTypes[i] != CardType.weight) continue;
        workoutExercises.add(cloneWorkoutExercise(preset.exercises[i]));
        workoutCardTypes.add(preset.cardTypes[i]);
      }

      final started = await active.startWithExercises(
        workoutExercises: workoutExercises,
        workoutCardTypes: workoutCardTypes,
      );
      await _repo.deletePreset(presetId);
      temporaryPresetId = null;

      if (!started) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).trainAnotherWorkoutActive,
            ),
          ),
        );
        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SessionScreen()));
        return;
      }

      if (!mounted) return;
      setState(() {
        _overviewRefreshToken++;
        _presetsRefreshToken++;
        _optimizedPreferredBodypartIds.clear();
        _optimizedBlacklistedBodypartIds.clear();
      });
      _showOptimizedWeightEstimateNotice(generationResult);
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const SessionScreen()));
      if (!mounted) return;
      setState(() => _overviewRefreshToken++);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).trainOptimizedStartFailed(
              safeFailureMessage(AppLocalizations.of(context), e),
            ),
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

    final message = unavailableCount > 0
        ? AppLocalizations.of(context)
              .trainOptimizedManualWeights(unavailableCount)
        : AppLocalizations.of(context)
              .trainOptimizedStarterWeights(estimatedCount);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final expressiveTokens = context.usesExpressivePresentation
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()
        : null;
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
        final avatarForeground = context.semanticColors.onTrainProfileAvatar;
        Widget profileButton = IconButton(
          tooltip: strings.trainGymProfilesTooltip,
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: ProfileIdentityPalette.currentProfileAvatar,
            child: Text(
              _profileInitial(sel.currentProfile?.name),
              style: TextStyle(
                color: avatarForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
        if (expressiveTokens != null) {
          profileButton = TonosExpressivePressResponse(
            enabled: true,
            borderRadius: ExpressiveTrainShapes.compactControl,
            pressedBorderRadius: ExpressiveTrainShapes.compactControlPressed,
            pressedScale: 0.88,
            pressedRotation: 0.035,
            child: profileButton,
          );
        }
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: expressiveTokens?.pageCanvas,
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
            onDelete: (profile) async {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                unawaited(navigator.maybePop());
              }
              final profileId = profile.id;
              if (profileId == null) return;
              await sel.deleteProfile(profileId);
              if (!mounted) return;
              setState(() => _presetsRefreshToken++);
            },
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: TonosTrainTabs.toolbarHeight(
              context,
              overviewLabel: strings.trainOverviewTab,
              plansLabel: strings.trainPlansTab,
            ),
            title: TonosTrainTabs(
              key: _trainTabsTutorialKey,
              overviewKey: AppTestKeys.trainOverviewTab,
              plansKey: AppTestKeys.trainPlansTab,
              overviewLabel: strings.trainOverviewTab,
              plansLabel: strings.trainPlansTab,
              selectedIndex: _selectedTab,
              onChanged: (index) {
                setState(() => _selectedTab = index);
                if (index == 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _queueTrainTutorial();
                  });
                }
              },
            ),
            centerTitle: true,
            actions: [
              Padding(
                key: _gymProfileTutorialKey,
                padding: const EdgeInsets.only(right: 8),
                child: profileButton,
              ),
            ],
          ),
          body: SafeArea(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _TrainTabEntryMotion(
                  active: _selectedTab == 0,
                  motionKey: const ValueKey('expressive-overview-entry'),
                  child: _OverviewTab(
                    isActive: _selectedTab == 0,
                    refreshToken: _overviewRefreshToken,
                    profileId: sel.currentProfile?.id,
                    presetsRefreshToken: _presetsRefreshToken,
                    weeklyOverviewKey: _weeklyOverviewTutorialKey,
                    activePlansKey: _activePlansTutorialKey,
                    onPresetsRefresh: () {
                      setState(() => _presetsRefreshToken++);
                    },
                  ),
                ),
                _TrainTabEntryMotion(
                  active: _selectedTab == 1,
                  motionKey: const ValueKey('expressive-plans-entry'),
                  child: _PlansTab(
                    isActive: _selectedTab == 1,
                    profileId: sel.currentProfile?.id,
                    refreshToken: _presetsRefreshToken,
                    onRefresh: () => setState(() => _presetsRefreshToken++),
                    onGeneratePreset: () => _openCustomPresetGenerator(sel),
                    onCreatePreset: () => _createManualPreset(sel),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _selectedTab == 0
              ? KeyedSubtree(
                  key: _workoutBarTutorialKey,
                  child: _SplitWorkoutBar(
                    onStartWorkout: _startWorkout,
                    onOptimizeWorkout: () => _startOptimizedWorkout(sel),
                    onOptimizeSettings: _openOptimizedWorkoutSettings,
                    isStartingOptimized: _isStartingOptimized,
                  ),
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

/// Adds a brief Expressive arrival to the already-mounted Train tab content.
///
/// The selected tab changes immediately and both tab subtrees remain mounted,
/// so scroll position and in-progress UI state survive tab switches. Only the
/// active subtree gets a small paint-time settle; reduced motion snaps it to
/// its resting pose.
class _TrainTabEntryMotion extends StatefulWidget {
  const _TrainTabEntryMotion({
    required this.active,
    required this.motionKey,
    required this.child,
  });

  final bool active;
  final Key motionKey;
  final Widget child;

  @override
  State<_TrainTabEntryMotion> createState() => _TrainTabEntryMotionState();
}

class _TrainTabEntryMotionState extends State<_TrainTabEntryMotion>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 200);
  static const _entryOffset = Offset(0, 0.018);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
    value: widget.active ? 0 : 1,
  );
  late final Animation<Offset> _position = Tween<Offset>(
    begin: _entryOffset,
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  late final Animation<double> _opacity = Tween<double>(
    begin: 0.9,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  bool _dependenciesInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final canAnimate = _canAnimate(context);
    if (!_dependenciesInitialized) {
      _dependenciesInitialized = true;
      if (widget.active && canAnimate) {
        _controller.forward();
      } else {
        _controller.value = 1;
      }
    } else if (!canAnimate) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _TrainTabEntryMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) {
      if (_canAnimate(context)) {
        _controller.forward(from: 0);
      } else {
        _controller.value = 1;
      }
    }
  }

  static bool _canAnimate(BuildContext context) =>
      TickerMode.valuesOf(context).enabled &&
      !MediaQuery.disableAnimationsOf(context);

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(
      key: widget.motionKey,
      position: _position,
      child: widget.child,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.isActive,
    required this.refreshToken,
    required this.profileId,
    required this.presetsRefreshToken,
    this.weeklyOverviewKey,
    this.activePlansKey,
    required this.onPresetsRefresh,
  });

  final bool isActive;
  final int refreshToken;
  final int? profileId;
  final int presetsRefreshToken;
  final Key? weeklyOverviewKey;
  final Key? activePlansKey;
  final VoidCallback onPresetsRefresh;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
      children: [
        KeyedSubtree(
          key: weeklyOverviewKey,
          child: SevenDayFocusCard(
            refreshToken: refreshToken,
            ambientMotionEnabled: isActive,
            motionEnabled: isActive,
            onFocusedSetsTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AnalyticsDashboardScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        KeyedSubtree(
          key: activePlansKey,
          child: _ActivePresetsCard(
            isActive: isActive,
            profileId: profileId,
            refreshToken: presetsRefreshToken,
            onRefresh: onPresetsRefresh,
          ),
        ),
      ],
    );
  }
}

class _ActivePresetsCard extends StatefulWidget {
  final bool isActive;
  final int? profileId;
  final int refreshToken;
  final VoidCallback onRefresh;

  const _ActivePresetsCard({
    required this.isActive,
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
    return context.read<ActivePlanStore>().load(profileId);
  }

  Future<void> _openPlanManagement() async {
    final profileId = widget.profileId;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).trainSelectProfileFirst),
        ),
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
    final strings = AppLocalizations.of(context);
    final surfaces = context.surfaceTokens;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressiveRecipe = context.usesExpressivePresentation;
    final expressiveTokens = usesExpressiveRecipe
        ? theme.extension<AppExpressiveTrainTokens>()
        : null;
    final surfaceInk = context.cs.onPrimaryContainer;
    final content = _withPanelInkTheme(
      context: context,
      usesInkRecipe: usesInkRecipe,
      foreground: surfaceInk,
      child: FutureBuilder<Set<int>>(
        future: _selectedIdsFuture,
        builder: (context, snapshot) {
          final selectedIds = snapshot.data ?? const <int>{};
          final isLoading =
              snapshot.connectionState != ConnectionState.done &&
              !snapshot.hasData;
          final editButton = IconButton(
            tooltip: strings.trainEditActivePlans,
            style: usesExpressiveRecipe
                ? IconButton.styleFrom(
                    backgroundColor: expressiveTokens!.actionSecondary,
                    foregroundColor: expressiveTokens.actionSecondaryForeground,
                    shape: RoundedRectangleBorder(
                      borderRadius: ExpressiveTrainShapes.compactControl,
                    ),
                  )
                : null,
            onPressed: isLoading ? null : _openPlanManagement,
            icon: const Icon(Icons.edit_outlined),
          );
          final Widget themedEditButton = usesExpressiveRecipe
              ? TonosExpressivePressResponse(
                  enabled: !isLoading && widget.isActive,
                  borderRadius: ExpressiveTrainShapes.compactControl,
                  pressedBorderRadius:
                      ExpressiveTrainShapes.compactControlPressed,
                  pressedScale: 0.84,
                  pressedRotation: -0.055,
                  child: editButton,
                )
              : editButton;
          Widget activePlanList() {
            final list = PresetsLoaded(
              scale: 0.92,
              refreshToken: widget.refreshToken,
              presetIds: selectedIds,
              planActiveState: true,
              useExpressiveTrainPresentation: true,
              expressiveMotionEnabled: widget.isActive,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              emptyMessage: strings.trainSelectedPlansMissing,
              onRefresh: widget.onRefresh,
            );
            if (!usesExpressiveRecipe) return list;
            return AnimatedSize(
              duration: widget.isActive && _expressiveMotionEnabled(context)
                  ? const Duration(milliseconds: 220)
                  : const Duration(milliseconds: 1),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: list,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.trainActivePlans,
                      style:
                          (usesExpressiveRecipe
                                  ? theme.textTheme.headlineSmall
                                  : theme.textTheme.titleLarge)
                              ?.copyWith(
                                fontWeight: usesExpressiveRecipe
                                    ? FontWeight.w800
                                    : FontWeight.w800,
                                color: usesInkRecipe ? surfaceInk : null,
                              ),
                    ),
                  ),
                  themedEditButton,
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
                  strings.trainSelectProfileForPlans,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: usesInkRecipe
                        ? surfaceInk
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else if (selectedIds.isEmpty)
                Text(
                  strings.trainChooseActivePlans,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: usesInkRecipe
                        ? surfaceInk
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                activePlanList(),
            ],
          );
        },
      ),
    );
    if (usesExpressiveRecipe) {
      final expressiveTokens = Theme.of(context)
          .extension<AppExpressiveTrainTokens>()!;
      return _ExpressiveTrainSurface(
        color: expressiveTokens.activePlansSurface,
        borderRadius: ExpressiveTrainShapes.activePlans,
        padding: const EdgeInsets.all(18),
        child: content,
      );
    }
    if (usesInkRecipe) {
      return TonosSurface(
        variant: TonosSurfaceVariant.panelRaised,
        color: surfaces.planGroup,
        padding: const EdgeInsets.all(16),
        child: content,
      );
    }
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: content),
    );
  }
}

class _PlansTab extends StatefulWidget {
  const _PlansTab({
    required this.isActive,
    required this.profileId,
    required this.refreshToken,
    required this.onRefresh,
    required this.onGeneratePreset,
    required this.onCreatePreset,
  });

  final bool isActive;
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
    _activePresetIdsFuture = context.read<ActivePlanStore>().load(
      widget.profileId,
    );
  }

  @override
  void didUpdateWidget(covariant _PlansTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileId != widget.profileId ||
        oldWidget.refreshToken != widget.refreshToken) {
      if (oldWidget.profileId != widget.profileId) {
        _lastActivePresetIds = null;
      }
      _activePresetIdsFuture = context.read<ActivePlanStore>().load(
        widget.profileId,
      );
    }
  }

  void _openPremadePlans() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PremadePlansPage(
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
        SnackBar(
          content: Text(AppLocalizations.of(context).trainSelectProfileFirst),
        ),
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
      _activePresetIdsFuture = context.read<ActivePlanStore>().load(profileId);
    });
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final dataVisualization = context.dataVisualizationTokens;
    return FutureBuilder<Set<int>>(
      future: _activePresetIdsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _lastActivePresetIds = snapshot.data;
        }
        // Keep plan creation available while the persisted active-plan state is
        // loading or unavailable. The cards refresh as soon as the lookup
        // completes instead of trapping the user behind a spinner.
        final activeIds =
            snapshot.data ?? _lastActivePresetIds ?? const <int>{};
        return ListView(
          key: AppTestKeys.trainPlansList,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _PresetSectionCard(
              title: strings.trainActivePlans,
              isActive: widget.isActive,
              onEdit: _openPlanManagement,
              isArchived: false,
              child: PresetsLoaded(
                scale: 0.96,
                refreshToken: widget.refreshToken,
                presetIds: activeIds,
                planActiveState: true,
                useExpressiveTrainPresentation: true,
                expressiveMotionEnabled: widget.isActive,
                progressiveReveal: true,
                initialVisibleCount: 3,
                revealBatchSize: 5,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                emptyMessage: strings.trainNoActivePlans,
                onRefresh: widget.onRefresh,
              ),
            ),
            const SizedBox(height: 16),
            _PresetSectionCard(
              title: strings.trainArchivedPlans,
              isActive: widget.isActive,
              onEdit: _openPlanManagement,
              isArchived: true,
              child: PresetsLoaded(
                scale: 0.96,
                refreshToken: widget.refreshToken,
                excludedPresetIds: activeIds,
                planActiveState: false,
                useExpressiveTrainPresentation: true,
                expressiveMotionEnabled: widget.isActive,
                progressiveReveal: true,
                initialVisibleCount: 3,
                revealBatchSize: 5,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                emptyMessage: strings.trainNoArchivedPlans,
                onRefresh: widget.onRefresh,
              ),
            ),
            const SizedBox(height: 16),
            _PremadePlansCard(onOpen: _openPremadePlans),
            const SizedBox(height: 16),
            if (context.usesExpressivePresentation)
              _ExpressivePlanActions(
                onGenerate: widget.onGeneratePreset,
                onCreateManual: widget.onCreatePreset,
              )
            else ...[
              GenericBar(
                label: strings.trainGenerateCustomPlans,
                color: dataVisualization.tertiarySeries,
                onTap: widget.onGeneratePreset,
              ),
              const SizedBox(height: 8),
              GenericBar(
                key: AppTestKeys.trainCreateManualPlan,
                label: strings.trainManuallyAddPlan,
                color: dataVisualization.tertiarySeries,
                onTap: widget.onCreatePreset,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PresetSectionCard extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback? onEdit;
  final bool isArchived;
  final Widget child;

  const _PresetSectionCard({
    required this.title,
    required this.isActive,
    this.onEdit,
    this.isArchived = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final surfaces = context.surfaceTokens;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressiveRecipe = context.usesExpressivePresentation;
    final expressiveMotionEnabled =
        usesExpressiveRecipe && isActive && _expressiveMotionEnabled(context);
    final surfaceInk = context.cs.onPrimaryContainer;
    final expressiveTokens = usesExpressiveRecipe
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()!
        : null;
    final sectionContent = usesExpressiveRecipe
        ? AnimatedSize(
            duration: expressiveMotionEnabled
                ? const Duration(milliseconds: 220)
                : const Duration(milliseconds: 1),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: child,
          )
        : child;
    final content = _withPanelInkTheme(
      context: context,
      usesInkRecipe: usesInkRecipe,
      foreground: surfaceInk,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style:
                      (usesExpressiveRecipe && !isArchived
                              ? theme.textTheme.headlineSmall
                              : theme.textTheme.titleLarge)
                          ?.copyWith(
                            fontWeight: usesExpressiveRecipe
                                ? (isArchived
                                      ? FontWeight.w600
                                      : FontWeight.w800)
                                : FontWeight.w800,
                            color: usesInkRecipe ? surfaceInk : null,
                          ),
                ),
              ),
              if (onEdit != null)
                usesExpressiveRecipe
                    ? TonosExpressivePressResponse(
                        enabled: isActive,
                        borderRadius: ExpressiveTrainShapes.compactControl,
                        pressedBorderRadius:
                            ExpressiveTrainShapes.compactControlPressed,
                        pressedScale: 0.84,
                        pressedRotation: -0.055,
                        child: IconButton(
                          tooltip: strings.trainManagePlans,
                          style: IconButton.styleFrom(
                            backgroundColor: expressiveTokens!.actionSecondary,
                            foregroundColor:
                                expressiveTokens.actionSecondaryForeground,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  ExpressiveTrainShapes.compactControl,
                            ),
                          ),
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      )
                    : IconButton(
                        tooltip: strings.trainManagePlans,
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                      ),
            ],
          ),
          const SizedBox(height: 8),
          sectionContent,
        ],
      ),
    );
    if (usesExpressiveRecipe) {
      return _ExpressiveTrainSurface(
        color: isArchived
            ? expressiveTokens!.archivedPlansSurface
            : expressiveTokens!.activePlansSurface,
        borderRadius: isArchived
            ? ExpressiveTrainShapes.section
            : ExpressiveTrainShapes.activePlans,
        padding: const EdgeInsets.all(18),
        child: content,
      );
    }
    if (usesInkRecipe) {
      return TonosSurface(
        variant: TonosSurfaceVariant.panelRaised,
        color: surfaces.planGroup,
        padding: const EdgeInsets.all(16),
        child: content,
      );
    }
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: content),
    );
  }
}

class _PremadePlansCard extends StatelessWidget {
  final VoidCallback onOpen;

  const _PremadePlansCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final surfaces = context.surfaceTokens;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressiveRecipe = context.usesExpressivePresentation;
    final surfaceInk = context.cs.onPrimaryContainer;
    final expressiveTokens = usesExpressiveRecipe
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()!
        : null;
    final content = _withPanelInkTheme(
      context: context,
      usesInkRecipe: usesInkRecipe,
      foreground: surfaceInk,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories_outlined,
                color:
                    expressiveTokens?.actionPrimary ??
                    theme.colorScheme.primary,
                size: usesExpressiveRecipe ? 40 : 32,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  strings.trainPremadePlans,
                  style:
                      (usesExpressiveRecipe
                              ? theme.textTheme.headlineSmall
                              : theme.textTheme.titleLarge)
                          ?.copyWith(
                            fontWeight: usesExpressiveRecipe
                                ? FontWeight.w700
                                : FontWeight.w800,
                            color: usesInkRecipe ? surfaceInk : null,
                          ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            strings.trainPremadeDescription(premadeTrainingPlans.length),
            style:
                (usesExpressiveRecipe
                        ? theme.textTheme.bodyLarge
                        : theme.textTheme.bodyMedium)
                    ?.copyWith(
                      color: usesInkRecipe
                          ? surfaceInk
                          : theme.colorScheme.onSurfaceVariant,
                    ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: usesExpressiveRecipe
                ? _ExpressivePlanAction(
                    label: strings.trainBrowsePremadePlans,
                    icon: Icons.arrow_forward,
                    color: expressiveTokens!.actionPrimary,
                    foreground: expressiveTokens.actionPrimaryForeground,
                    onTap: onOpen,
                  )
                : usesInkRecipe
                ? TonosAction(
                    variant: TonosActionVariant.primary,
                    label: strings.trainBrowsePremadePlans,
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: onOpen,
                    expand: true,
                  )
                : FilledButton.tonalIcon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(strings.trainBrowsePremadePlans),
                  ),
          ),
        ],
      ),
    );
    if (usesExpressiveRecipe) {
      return _ExpressiveTrainSurface(
        color: expressiveTokens!.librarySurface,
        borderRadius: ExpressiveTrainShapes.section,
        padding: const EdgeInsets.all(20),
        child: content,
      );
    }
    if (usesInkRecipe) {
      return TonosSurface(
        variant: TonosSurfaceVariant.panelRaised,
        color: surfaces.optimizedAction,
        padding: const EdgeInsets.all(16),
        child: content,
      );
    }
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: content),
    );
  }
}

Widget _withPanelInkTheme({
  required BuildContext context,
  required bool usesInkRecipe,
  required Color foreground,
  required Widget child,
}) {
  if (!usesInkRecipe) return child;

  final theme = Theme.of(context);
  return Theme(
    data: theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        onSurface: foreground,
        onSurfaceVariant: foreground,
      ),
      textTheme: theme.textTheme.apply(
        bodyColor: foreground,
        displayColor: foreground,
      ),
    ),
    child: child,
  );
}

bool _expressiveMotionEnabled(BuildContext context) =>
    TickerMode.valuesOf(context).enabled &&
    !MediaQuery.disableAnimationsOf(context);

Duration _expressiveMotionDuration(BuildContext context) =>
    _expressiveMotionEnabled(context)
    ? const Duration(milliseconds: 220)
    : Duration.zero;

class _ExpressiveTrainSurface extends StatelessWidget {
  const _ExpressiveTrainSurface({
    required this.color,
    required this.borderRadius,
    required this.padding,
    required this.child,
  });

  final Color color;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _expressiveMotionDuration(context),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      child: child,
    );
  }
}

class _ExpressivePlanActions extends StatelessWidget {
  const _ExpressivePlanActions({
    required this.onGenerate,
    required this.onCreateManual,
  });

  final VoidCallback onGenerate;
  final VoidCallback onCreateManual;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<AppExpressiveTrainTokens>()!;
    return _ExpressiveTrainSurface(
      color: tokens.creationSurface,
      borderRadius: ExpressiveTrainShapes.section,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _ExpressivePlanAction(
            label: strings.trainGenerateCustomPlans,
            icon: Icons.auto_awesome_outlined,
            color: tokens.actionPrimary,
            foreground: tokens.actionPrimaryForeground,
            onTap: onGenerate,
          ),
          const SizedBox(height: 10),
          _ExpressivePlanAction(
            key: AppTestKeys.trainCreateManualPlan,
            label: strings.trainManuallyAddPlan,
            icon: Icons.edit_note_outlined,
            color: tokens.actionSecondary,
            foreground: tokens.actionSecondaryForeground,
            onTap: onCreateManual,
            secondary: true,
          ),
        ],
      ),
    );
  }
}

class _ExpressivePlanAction extends StatelessWidget {
  const _ExpressivePlanAction({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.foreground,
    required this.onTap,
    this.secondary = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final radius = secondary
        ? ExpressiveTrainShapes.focusInset
        : ExpressiveTrainShapes.primaryAction;
    final shape = RoundedRectangleBorder(borderRadius: radius);
    return TonosExpressivePressResponse(
      enabled: true,
      borderRadius: radius,
      pressedBorderRadius: ExpressiveTrainShapes.selectedSelector,
      pressedScale: 0.95,
      pressedOffset: const Offset(0, 1.5),
      child: Material(
        color: color,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: foreground),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: foreground),
                ],
              ),
            ),
          ),
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
    final colorScheme = context.cs;
    final semantic = context.semanticColors;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final effects = context.effectTokens;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressiveRecipe = context.usesExpressivePresentation;
    final textTheme = Theme.of(context).textTheme;
    final strings = AppLocalizations.of(context);
    final expressiveTokens = usesExpressiveRecipe
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()!
        : null;
    final startWorkoutAction = usesExpressiveRecipe
        ? expressiveTokens!.actionPrimary
        : semantic.startWorkoutAction;
    final onStartWorkoutAction = usesExpressiveRecipe
        ? expressiveTokens!.actionPrimaryForeground
        : semantic.onStartWorkoutAction;
    final optimizeAction = usesInkRecipe
        ? surfaces.optimizedAction
        : usesExpressiveRecipe
        ? expressiveTokens!.actionSecondary
        : colorScheme.primaryContainer;
    final onOptimizeAction = usesExpressiveRecipe
        ? expressiveTokens!.actionSecondaryForeground
        : usesInkRecipe
        ? colorScheme.onSecondaryContainer
        : colorScheme.onPrimaryContainer;
    final optimizeIconColor = usesExpressiveRecipe
        ? expressiveTokens!.actionSecondaryForeground
        : colorScheme.onPrimaryContainer;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);
    final locale = Localizations.maybeLocaleOf(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final usesClassicPresentation = context.usesClassicPresentation;
    final screenWidth = MediaQuery.sizeOf(context).width;
    // This action bar serves all languages. Its layout follows available phone
    // width and text scaling in Neo. Classic retains its compact baseline at
    // ordinary text sizes, then reflows only when accessibility text needs it.
    final useVerticalLayout = usesClassicPresentation
        ? textScale > 1.15 && (languageCode != 'en' || screenWidth < 380)
        : textScale > 1.15 || screenWidth < 380;
    final startStyle =
        textTheme.titleMedium?.copyWith(
          color: onStartWorkoutAction,
          fontWeight: usesExpressiveRecipe ? FontWeight.w600 : FontWeight.w800,
        ) ??
        TextStyle(color: onStartWorkoutAction);
    final optimizeStyle =
        textTheme.bodyMedium?.copyWith(
          color: onOptimizeAction,
          fontWeight: usesExpressiveRecipe ? FontWeight.w600 : FontWeight.w800,
        ) ??
        TextStyle(color: onOptimizeAction);

    double measuredHeight(String label, TextStyle style, double maxWidth) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textAlign: TextAlign.center,
        textDirection: textDirection,
        locale: locale,
        textScaler: textScaler,
      )..layout(maxWidth: maxWidth.clamp(1.0, double.infinity).toDouble());
      return painter.height;
    }

    final expressiveStartHeight = usesExpressiveRecipe
        ? measuredHeight(
            strings.trainStartWorkout,
            startStyle,
            screenWidth - 64,
          )
        : 0.0;
    final expressiveOptimizeHeight = usesExpressiveRecipe
        ? measuredHeight(strings.trainOptimize, optimizeStyle, screenWidth - 96)
        : 0.0;
    final expressiveStartSegmentHeight = math
        .max(59.5, expressiveStartHeight + 8)
        .toDouble();
    final expressiveOptimizeSegmentHeight = math
        .max(59.5, expressiveOptimizeHeight + 8)
        .toDouble();
    final actionBarHeight = usesExpressiveRecipe && useVerticalLayout
        ? expressiveStartSegmentHeight + expressiveOptimizeSegmentHeight + 1.0
        : textScale > 1.5
        ? 152.0
        : 120.0;

    BorderRadius startRadius({required bool vertical, required bool pressed}) {
      final radius = Radius.circular(pressed ? 14 : 22);
      return vertical
          ? BorderRadius.only(topLeft: radius, topRight: radius)
          : textDirection == TextDirection.rtl
          ? BorderRadius.only(topRight: radius, bottomRight: radius)
          : BorderRadius.only(topLeft: radius, bottomLeft: radius);
    }

    BorderRadius optimizeRadius({required bool vertical}) {
      final radius = const Radius.circular(22);
      return vertical
          ? BorderRadius.only(bottomLeft: radius, bottomRight: radius)
          : textDirection == TextDirection.rtl
          ? BorderRadius.only(topLeft: radius, bottomLeft: radius)
          : BorderRadius.only(topRight: radius, bottomRight: radius);
    }

    Widget startAction({required bool vertical}) {
      final visual = Material(
        color: startWorkoutAction,
        child: InkWell(
          key: AppTestKeys.trainStartWorkout,
          onTap: onStartWorkout,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: vertical ? 16 : 0),
              child: Text(
                strings.trainStartWorkout,
                maxLines: vertical && !usesExpressiveRecipe ? 2 : null,
                textAlign: TextAlign.center,
                style: startStyle,
              ),
            ),
          ),
        ),
      );
      if (!usesExpressiveRecipe) return visual;
      return TonosExpressivePressResponse(
        enabled: true,
        borderRadius: startRadius(vertical: vertical, pressed: false),
        pressedBorderRadius: startRadius(vertical: vertical, pressed: true),
        pressedScale: 0.945,
        pressedOffset: const Offset(0, 1.5),
        child: visual,
      );
    }

    Widget optimizeSegment({required bool vertical}) {
      final material = Material(
        color: optimizeAction,
        child: vertical
            ? Row(
                children: [
                  Expanded(
                    child: _optimizeTouchResponse(
                      expressive: usesExpressiveRecipe,
                      enabled: !isStartingOptimized,
                      child: InkWell(
                        onTap: isStartingOptimized ? null : onOptimizeWorkout,
                        child: Center(
                          child: isStartingOptimized
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: onOptimizeAction,
                                  ),
                                )
                              : Text(
                                  strings.trainOptimize,
                                  maxLines: usesExpressiveRecipe ? null : 2,
                                  textAlign: TextAlign.center,
                                  style: usesExpressiveRecipe
                                      ? optimizeStyle
                                      : textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w800,
                                        ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  _optimizeSettingsButton(
                    expressive: usesExpressiveRecipe,
                    enabled: !isStartingOptimized,
                    onPressed: onOptimizeSettings,
                    tooltip: strings.trainOptimizedSettings,
                    color: optimizeIconColor,
                    tokens: expressiveTokens,
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned.fill(
                    child: InkWell(
                      onTap: isStartingOptimized ? null : onOptimizeWorkout,
                      child: _optimizeTouchResponse(
                        expressive: usesExpressiveRecipe,
                        enabled: !isStartingOptimized,
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: usesExpressiveRecipe ? 48 : 36,
                          ),
                          child: Center(
                            child: isStartingOptimized
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: usesExpressiveRecipe
                                          ? onOptimizeAction
                                          : colorScheme.onPrimaryContainer,
                                    ),
                                  )
                                : Text(
                                    strings.trainOptimize,
                                    textAlign: TextAlign.center,
                                    style: usesExpressiveRecipe
                                        ? optimizeStyle
                                        : textTheme.bodyMedium?.copyWith(
                                            color: onOptimizeAction,
                                            fontWeight: FontWeight.w800,
                                          ),
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
                    child: _optimizeSettingsButton(
                      expressive: usesExpressiveRecipe,
                      enabled: !isStartingOptimized,
                      onPressed: onOptimizeSettings,
                      tooltip: strings.trainOptimizedSettings,
                      color: optimizeIconColor,
                      tokens: expressiveTokens,
                      compact: true,
                    ),
                  ),
                ],
              ),
      );
      if (!usesExpressiveRecipe) return material;
      return ClipRRect(
        borderRadius: optimizeRadius(vertical: vertical),
        clipBehavior: Clip.antiAlias,
        child: material,
      );
    }

    final Widget actionContent;
    if (useVerticalLayout && usesExpressiveRecipe) {
      actionContent = Column(
        children: [
          SizedBox(
            height: expressiveStartSegmentHeight,
            child: startAction(vertical: true),
          ),
          Container(
            height: 1,
            color: colorScheme.outline.withValues(
              alpha: surfaces.splitWorkoutDividerOpacity,
            ),
          ),
          SizedBox(
            height: expressiveOptimizeSegmentHeight,
            child: optimizeSegment(vertical: true),
          ),
        ],
      );
    } else if (useVerticalLayout) {
      actionContent = Column(
        children: [
          Expanded(child: startAction(vertical: true)),
          Container(
            height: 1,
            color: colorScheme.outline.withValues(
              alpha: surfaces.splitWorkoutDividerOpacity,
            ),
          ),
          Expanded(child: optimizeSegment(vertical: true)),
        ],
      );
    } else {
      actionContent = Row(
        children: [
          Expanded(flex: 3, child: startAction(vertical: false)),
          Container(
            width: 1,
            height: double.infinity,
            color: colorScheme.outline.withValues(
              alpha: surfaces.splitWorkoutDividerOpacity,
            ),
          ),
          Expanded(flex: 2, child: optimizeSegment(vertical: false)),
        ],
      );
    }

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: usesExpressiveRecipe
              ? ExpressiveTrainShapes.primaryAction
              : shapes.sheet,
          border: usesInkRecipe
              ? Border.all(
                  color: surfaces.subtleOutline,
                  width: shapes.outlineWidth,
                )
              : null,
          boxShadow: usesInkRecipe
              ? [
                  BoxShadow(
                    color: effects.cardShadow,
                    blurRadius: effects.cardShadowBlur,
                    offset: effects.primaryActionShadowOffset,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: usesExpressiveRecipe
              ? ExpressiveTrainShapes.primaryAction
              : shapes.sheet,
          clipBehavior: usesExpressiveRecipe ? Clip.none : Clip.antiAlias,
          elevation: effects.sheetElevation,
          child: usesExpressiveRecipe
              ? ClipRRect(
                  borderRadius: ExpressiveTrainShapes.primaryAction,
                  child: SizedBox(
                    height: useVerticalLayout ? actionBarHeight : 64,
                    child: actionContent,
                  ),
                )
              : SizedBox(
                  height: useVerticalLayout ? actionBarHeight : 64,
                  child: actionContent,
                ),
        ),
      ),
    );
  }

  Widget _optimizeTouchResponse({
    required bool expressive,
    required bool enabled,
    required Widget child,
  }) {
    if (!expressive) return child;
    return TonosExpressivePressResponse(
      enabled: enabled,
      borderRadius: ExpressiveTrainShapes.primaryAction,
      pressedBorderRadius: ExpressiveTrainShapes.compactControlPressed,
      pressedScale: 0.955,
      pressedOffset: const Offset(0, 1),
      child: child,
    );
  }

  Widget _optimizeSettingsButton({
    required bool expressive,
    required bool enabled,
    required VoidCallback onPressed,
    required String tooltip,
    required Color color,
    required AppExpressiveTrainTokens? tokens,
    bool compact = false,
  }) {
    final button = IconButton(
      tooltip: tooltip,
      onPressed: enabled ? onPressed : null,
      icon: const Icon(Icons.settings_outlined),
      iconSize: compact ? 19 : null,
      visualDensity: compact ? VisualDensity.compact : null,
      padding: compact ? EdgeInsets.zero : null,
      constraints: compact
          ? const BoxConstraints(minWidth: 48, minHeight: 64)
          : null,
      color: color,
      style: expressive
          ? IconButton.styleFrom(
              backgroundColor: tokens!.actionSecondary.withValues(alpha: 0.88),
              foregroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: ExpressiveTrainShapes.compactControl,
              ),
            )
          : null,
    );
    if (!expressive) return button;
    return TonosExpressivePressResponse(
      enabled: enabled,
      borderRadius: ExpressiveTrainShapes.compactControl,
      pressedBorderRadius: ExpressiveTrainShapes.compactControlPressed,
      pressedScale: 0.84,
      pressedRotation: 0.08,
      child: button,
    );
  }
}
