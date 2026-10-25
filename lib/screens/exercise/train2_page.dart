// File: lib/screens/exercise/train2_page.dart

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../theme/widgets/tonos_overlay_routes.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/safe_failure_localizations.dart';
import '../../providers/active_session.dart';
import '../../providers/preset_session.dart';
import '../../providers/selected_profile.dart';
import '../../repositories/app_repository.dart';
import '../../services/preset_generation_service.dart';
import '../../utils/workout_exercise_clone.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/tokens/app_expressive_train_tokens.dart';
import '../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../theme/widgets/app_expressive_destination_theme.dart';
import '../../theme/widgets/tonos_expressive_motion.dart';
import '../../theme/widgets/tonos_dialog.dart';
import '../../theme/widgets/tonos_field.dart';

import '../../widgets/generic_bar.dart';
import '../../widgets/presets_loaded.dart';
import '../../widgets/drawers.dart';
import '../../widgets/bodypart_focus_chips.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/tonos_train_tabs.dart';

import 'gym_profile_screen.dart';
import 'preset_detail_screen.dart';
import 'plan_management_page.dart';
import 'premade_plans_page.dart';
import 'session_screen.dart';
import 'preset_generation_qa.dart';
import 'train_page.dart' show TrainWorkoutActionBar;
import '../../widgets/history_content.dart';

import 'exercise_catalog_page.dart';
import '../../services/active_plan_store.dart';
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

enum _Train2PlanAction { premade, custom, manual }

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

    final settings = await showTonosDialog<_OptimizedWorkoutSettingsResult>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return TonosDialogFrame(
            styleFormControls: true,
            child: AlertDialog(
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
                      TonosFormField(
                        initialValue: draftMinutes,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => draftMinutes = value,
                        labelText: strings.trainWorkoutDuration,
                        suffixText: strings.trainMinutesShort,
                        border: const OutlineInputBorder(),
                      ),
                      const SizedBox(height: 12),
                      TonosFormField(
                        initialValue: draftMaxSets,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => draftMaxSets = value,
                        labelText: strings.trainSetsPerExercise,
                        suffixText: strings.trainSetsShort,
                        border: const OutlineInputBorder(),
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
                        onChanged: (selection) => setDialogState(() {
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
            ),
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
    return showTonosDialog<void>(
      context: context,
      builder: (dialogContext) => TonosDialogFrame(
        child: AlertDialog(
          title: Text(AppLocalizations.of(context).trainRestTitle),
          content: Text(AppLocalizations.of(context).trainRestBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLocalizations.of(context).commonOkay),
            ),
          ],
        ),
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
        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SessionScreen()));
        return;
      }

      if (!mounted) return;
      setState(() {
        _presetsRefreshToken++;
        _optimizedPreferredBodypartIds.clear();
        _optimizedBlacklistedBodypartIds.clear();
      });
      _showOptimizedWeightEstimateNotice(generationResult);
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const SessionScreen()));
      if (!mounted) return;
      setState(() => _historyRefreshToken++);
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

  Future<void> _openPlanManagement(int? profileId) async {
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
    setState(() => _presetsRefreshToken++);
  }

  Future<void> _openPremadePlans(int? profileId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PremadePlansPage(
          profileId: profileId,
          onPlanAdded: () {
            if (mounted) setState(() => _presetsRefreshToken++);
          },
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _presetsRefreshToken++);
  }

  Future<void> _createManualPreset(SelectedProfile sel) async {
    await sel.ready;
    if (!mounted) return;
    final profileId = sel.currentProfile?.id;
    final existing = await _repo.fetchAllPresetsRaw(profileId: profileId);
    if (!mounted) return;
    final name = AppLocalizations.of(context)
        .trainNewPlanName(existing.length + 1);
    await ActivePlanStore(repository: _repo).load(profileId);
    final presetId = await _repo.createPresetAtomic(
      name: name,
      profileId: profileId,
      exercises: const [],
      activate: true,
      uniqueName: true,
    );
    if (!mounted) return;
    setState(() => _presetsRefreshToken++);
    await _openPreset(presetId);
  }

  Future<void> _showAddPlanActions(SelectedProfile sel) async {
    final strings = AppLocalizations.of(context);
    final action = await showTonosDialog<_Train2PlanAction>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;

        Widget option({
          required String label,
          required IconData icon,
          required _Train2PlanAction action,
        }) {
          return ListTile(
            leading: Icon(icon, color: colors.primary),
            title: Text(label),
            trailing: const Icon(Icons.chevron_right_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            onTap: () => Navigator.of(dialogContext).pop(action),
          );
        }

        return TonosDialogFrame(
          child: AlertDialog(
            title: Text(strings.commonAdd),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                option(
                  label: strings.trainBrowsePremadePlans,
                  icon: Icons.view_carousel_outlined,
                  action: _Train2PlanAction.premade,
                ),
                option(
                  label: strings.trainGenerateCustomPlans,
                  icon: Icons.auto_awesome_outlined,
                  action: _Train2PlanAction.custom,
                ),
                option(
                  label: strings.trainManuallyAddPlan,
                  icon: Icons.edit_note_outlined,
                  action: _Train2PlanAction.manual,
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || action == null) return;

    switch (action) {
      case _Train2PlanAction.premade:
        await _openPremadePlans(sel.currentProfile?.id);
        break;
      case _Train2PlanAction.custom:
        await _openCustomPresetGenerator(sel);
        break;
      case _Train2PlanAction.manual:
        await _createManualPreset(sel);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final shapes = context.shapeTokens;
    final semantic = context.semanticColors;
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
      _historyRefreshToken++;
    }

    return Consumer<SelectedProfile>(
      builder: (context, sel, _) {
        void selectTab(int index) {
          setState(() {
            _selectedTab = index;
            if (index == 1) _historyRefreshToken++;
          });
        }

        final Widget tabSelector = expressiveTokens != null
            ? TonosTrainTabs(
                overviewLabel: strings.trainTab,
                plansLabel: strings.trainHistoryTab,
                selectedIndex: _selectedTab,
                onChanged: selectTab,
                compact: true,
              )
            : Center(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: shapes.trainTab,
                  ),
                  child: ToggleButtons(
                    borderRadius: shapes.trainTab,
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
                    onPressed: selectTab,
                    children: [
                      Text(strings.trainTab),
                      Text(strings.trainHistoryTab),
                    ],
                  ),
                ),
              );

        Widget profileButton = IconButton(
          tooltip: strings.drawerGymProfiles,
          icon: CircleAvatar(
            backgroundColor: semantic.trainProfileAvatar,
            child: Text(
              'P',
              style: TextStyle(
                color: semantic.onTrainProfileAvatar,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        );
        if (expressiveTokens != null) {
          profileButton = TonosExpressivePressResponse(
            enabled: true,
            borderRadius: ExpressiveTrainShapes.compactControl,
            pressedBorderRadius: ExpressiveTrainShapes.compactControlPressed,
            pressedScale: TonosExpressiveMotionTiers.compactScale,
            pressedOffset: TonosExpressiveMotionTiers.compactOffset,
            pressedRotation: TonosExpressiveMotionTiers.compactRotation,
            child: profileButton,
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: expressiveTokens?.pageCanvas,
          drawer: MainDrawer(
            headerTitle: strings.trainMenuTitle,
            items: [
              DrawerItem(
                title: strings.trainExerciseCatalog,
                builder: (_) => AppExpressiveDestinationTheme(
                  family: AppExpressiveDestinationFamily.catalog,
                  child: ExerciseCatalogPage(
                    expressiveCatalogPresentation:
                        context.usesExpressivePresentation,
                  ),
                ),
              ),
              DrawerItem(
                title: strings.trainMuscleFilter,
                builder: (_) => AppExpressiveDestinationTheme(
                  family: AppExpressiveDestinationFamily.catalog,
                  child: MuscleFilterPage(
                    expressiveCatalogPresentation:
                        context.usesExpressivePresentation,
                  ),
                ),
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
            toolbarHeight: expressiveTokens == null
                ? kToolbarHeight
                : TonosTrainTabs.toolbarHeight(
                    context,
                    overviewLabel: strings.trainTab,
                    plansLabel: strings.trainHistoryTab,
                    compact: true,
                  ),
            leading: IconButton(
              tooltip: strings.trainMenuTitle,
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            title: tabSelector,
            centerTitle: true,
            actions: [profileButton],
          ),

          body: SafeArea(
            child: IndexedStack(
              index: _selectedTab,
              children: [_buildTrainContent(sel), _buildHistoryContent()],
            ),
          ),
          bottomNavigationBar: expressiveTokens != null && _selectedTab == 0
              ? TrainWorkoutActionBar(
                  isStartingOptimized: _isStartingOptimized,
                  onStartWorkout: _startNewSession,
                  onOptimizeWorkout: () => _startOptimizedWorkout(sel),
                  onOptimizeSettings: _openOptimizedWorkoutSettings,
                )
              : null,
        );
      },
    );
  }

  Widget _buildTrainContent(SelectedProfile sel) {
    if (context.usesExpressivePresentation) {
      return _buildExpressiveTrainContent(sel);
    }
    final strings = AppLocalizations.of(context);
    final semantic = context.semanticColors;
    final dataVisualization = context.dataVisualizationTokens;
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
          color: dataVisualization.tertiarySeries,
          onTap: () => _openCustomPresetGenerator(sel),
        ),
        const SizedBox(height: 8),
        GenericBar(
          label: AppLocalizations.of(context).trainAddPlan,
          color: dataVisualization.tertiarySeries,
          onTap: () async {
            await sel.ready;
            if (!mounted) return;
            final strings = AppLocalizations.of(context);
            final profileId = sel.currentProfile?.id;
            final existing = await _repo.fetchAllPresetsRaw(
              profileId: profileId,
            );
            final nextNum = existing.length + 1;
            final name = nextNum == 1
                ? strings.trainNewPlanFirst
                : strings.trainNewPlan(nextNum);
            await ActivePlanStore(repository: _repo).load(profileId);
            final newId = await _repo.createPresetAtomic(
              name: name,
              profileId: profileId,
              exercises: const [],
              activate: true,
              uniqueName: true,
            );
            if (!mounted) return;
            _openPreset(newId, edit: true);
            if (!mounted) return;
            setState(() => _presetsRefreshToken++);
          },
        ),

        const SizedBox(height: 8),

        GenericBar(
          label: _isStartingOptimized
              ? AppLocalizations.of(context).trainBuildingOptimized
              : AppLocalizations.of(context).trainStartOptimized,
          color: semantic.trainOptimizedAction,
          onTap: _isStartingOptimized
              ? null
              : () => _startOptimizedWorkout(sel),
          trailing: _isStartingOptimized
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  tooltip: AppLocalizations.of(context)
                      .trainOptimizedSettingsTitle,
                  icon: const Icon(Icons.settings_outlined),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  color: tonosForegroundForSurface(
                    context,
                    semantic.trainOptimizedAction,
                  ),
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

  Widget _buildExpressiveTrainContent(SelectedProfile sel) {
    final motionEnabled =
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    return _Train2ExpressivePlansList(
      profileId: sel.currentProfile?.id,
      refreshToken: _presetsRefreshToken,
      motionEnabled: motionEnabled,
      onManagePlans: () => _openPlanManagement(sel.currentProfile?.id),
      onAddPlan: () => _showAddPlanActions(sel),
      onRefresh: () => setState(() => _presetsRefreshToken++),
    );
  }

  Future<void> _startNewSession() async {
    final navigator = Navigator.of(context);
    await context.read<ActiveSession>().start();
    if (!mounted) return;
    await navigator.push(
      MaterialPageRoute(builder: (_) => const SessionScreen()),
    );
    if (!mounted) return;
    setState(() => _historyRefreshToken++);
  }

  Widget _buildHistoryContent() {
    return HistoryContent(
      refreshToken: _historyRefreshToken,
      onReload: () => setState(() {}),
    );
  }
}

class _Train2ExpressivePlansList extends StatefulWidget {
  const _Train2ExpressivePlansList({
    required this.profileId,
    required this.refreshToken,
    required this.motionEnabled,
    required this.onManagePlans,
    required this.onAddPlan,
    required this.onRefresh,
  });

  final int? profileId;
  final int refreshToken;
  final bool motionEnabled;
  final VoidCallback onManagePlans;
  final VoidCallback onAddPlan;
  final VoidCallback onRefresh;

  @override
  State<_Train2ExpressivePlansList> createState() =>
      _Train2ExpressivePlansListState();
}

class _Train2ExpressivePlansListState
    extends State<_Train2ExpressivePlansList> {
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
  void didUpdateWidget(covariant _Train2ExpressivePlansList oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<AppExpressiveTrainTokens>()!;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: FutureBuilder<Set<int>>(
          future: _activePresetIdsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _lastActivePresetIds = snapshot.data;
            }

            final hasActivePlanState =
                snapshot.hasData || _lastActivePresetIds != null;
            final activeIds =
                snapshot.data ?? _lastActivePresetIds ?? const <int>{};

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: ShapeDecoration(
                    color: tokens.activePlansSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: ExpressiveTrainShapes.activePlans,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsetsDirectional.only(
                          start: 14,
                          end: 4,
                        ),
                        decoration: ShapeDecoration(
                          color: tokens.creationSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: ExpressiveTrainShapes.focusInset,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                strings.trainExercisePresets,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: strings.trainManagePlans,
                              onPressed: widget.onManagePlans,
                              icon: const Icon(Icons.edit_outlined),
                              color: tokens.actionPrimary,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (hasActivePlanState)
                        PresetsLoaded(
                          scale: 0.96,
                          refreshToken: widget.refreshToken,
                          presetIds: activeIds,
                          planActiveState: true,
                          emptyMessage: strings.trainChooseActivePlans,
                          useExpressiveTrainPresentation: true,
                          expressiveMotionEnabled: widget.motionEnabled,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          onRefresh: widget.onRefresh,
                        )
                      else
                        const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      const SizedBox(height: 12),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: FractionallySizedBox(
                            widthFactor: 0.6,
                            child: Semantics(
                              container: true,
                              button: true,
                              child: _Train2ExpressiveAddPlanButton(
                                onPressed: widget.onAddPlan,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Train2ExpressiveAddPlanButton extends StatelessWidget {
  const _Train2ExpressiveAddPlanButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppExpressiveTrainTokens>()!;
    final shape = RoundedRectangleBorder(
      borderRadius: ExpressiveTrainShapes.primaryAction,
    );

    return TonosExpressivePressResponse(
      enabled: true,
      borderRadius: ExpressiveTrainShapes.primaryAction,
      pressedBorderRadius: ExpressiveTrainShapes.selectedSelector,
      pressedScale: TonosExpressiveMotionTiers.supportingScale,
      pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
      child: Material(
        color: tokens.actionSecondary,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: tokens.actionSecondaryForeground,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).commonAdd,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.actionSecondaryForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
