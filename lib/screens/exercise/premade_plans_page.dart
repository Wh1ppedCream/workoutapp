import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../data/premade_training_plans.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/safe_failure_localizations.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../services/active_plan_store.dart';
import '../../services/catalog_entity_localizer.dart';
import '../../services/exercise_equipment_compatibility.dart';
import '../../services/exercise_content_localizer.dart';
import '../../services/premade_plan_localizer.dart';
import '../../services/tutorial_state_store.dart';
import '../../theme/expressive_planning_tokens.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/widgets/tonos_expressive_motion.dart';
import '../../utils/async_pool.dart';
import '../../utils/localized_formatters.dart';
import '../../utils/tutorial_launcher.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/localized_catalog_entity_name.dart';

class PremadePlansPage extends StatefulWidget {
  final int? profileId;
  final VoidCallback onPlanAdded;
  final ValueChanged<int>? onPlanCreated;
  final bool onboardingMode;

  const PremadePlansPage({
    super.key,
    required this.profileId,
    required this.onPlanAdded,
    this.onPlanCreated,
    this.onboardingMode = false,
  });

  @override
  State<PremadePlansPage> createState() => _PremadePlansPageState();
}

class _PremadePlansPageState extends State<PremadePlansPage> {
  static const _replacementBuildConcurrency = 4;
  static const _homemadeSourceName = 'Homemade';
  static const _homemadePlanGroups = [
    'Full Body',
    'Push Pull Legs',
    'Upper Lower',
    'Body Part (Bro) Split',
  ];

  AppRepository get _repo => context.read<AppRepository>();
  final _durationTutorialKey = GlobalKey(debugLabel: 'premade_duration');
  final _equipmentFilterTutorialKey = GlobalKey(
    debugLabel: 'premade_equipment_filter',
  );
  final _planListTutorialKey = GlobalKey(debugLabel: 'premade_plan_list');
  final _addingPlanIds = <String>{};
  final _onboardingCreatedPlanIds = <int>[];
  Future<_PremadePlanAdaptationData>? _adaptationFuture;
  Future<Map<String, LocalizedPremadePlan>>? _localizedPlansFuture;
  String? _localizedLocaleKey;
  int? _adaptationProfileId;
  int? _adaptationDurationMinutes;
  bool? _adaptationFilterValue;
  bool? _adaptationExpressive;
  bool _isDiscardingOnboardingPlans = false;
  bool _filterForProfileEquipment = true;
  var _selectedDurationMinutes = 60;
  bool _tutorialQueued = false;

  AppLocalizations get _strings => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    final localeKey = _localeKeyFor(locale);
    if (_localizedLocaleKey == localeKey && _localizedPlansFuture != null) {
      return;
    }
    _localizedLocaleKey = localeKey;
    _localizedPlansFuture = _loadLocalizedPlans(locale);
  }

  Future<Map<String, LocalizedPremadePlan>> _loadLocalizedPlans(
    Locale locale,
  ) async {
    final strings = AppLocalizations.of(context);
    final localizedPlans = await Future.wait(
      premadeTrainingPlans.map(
        (plan) => PremadePlanLocalizer.instance.resolve(
          plan,
          locale,
          oneHourDurationLabel:
              AppExpressivePlanningTokens.maybeOf(context) == null
              ? strings.premadeOneHour
              : strings.premadeExpressiveOneHour,
          oneHourDescriptionBuilder: (duration, planName) =>
              strings.premadeOneHourDescription(duration, planName),
        ),
      ),
    );
    return {
      for (var i = 0; i < premadeTrainingPlans.length; i++)
        premadeTrainingPlans[i].id: localizedPlans[i],
    };
  }

  Map<String, LocalizedPremadePlan> _canonicalLocalizedPlans() {
    return {
      for (final plan in premadeTrainingPlans)
        plan.id: LocalizedPremadePlan.fromPlan(plan),
    };
  }

  static String _localeKeyFor(Locale locale) =>
      '${locale.languageCode}|${locale.scriptCode}|${locale.countryCode}';

  void _queueTutorial() {
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  Future<void> _showTutorial() async {
    try {
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.premadePlans,
        steps: [
          GuidedTutorialStep(
            targetKey: _durationTutorialKey,
            icon: Icons.schedule,
            title: _strings.premadeTutorialLengthTitle,
            body: _strings.premadeTutorialLengthBody,
          ),
          GuidedTutorialStep(
            targetKey: _equipmentFilterTutorialKey,
            icon: Icons.tune,
            title: _strings.premadeTutorialEquipmentTitle,
            body: _strings.premadeTutorialEquipmentBody,
          ),
          GuidedTutorialStep(
            targetKey: _planListTutorialKey,
            icon: Icons.library_books_outlined,
            title: _strings.premadeTutorialLibraryTitle,
            body: _strings.premadeTutorialLibraryBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  Future<void> _addPlan(
    PremadeTrainingPlan plan,
    List<PremadeTrainingExercise> exercises,
  ) async {
    final profileId = widget.profileId;
    if (profileId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_strings.premadeSelectProfile)));
      return;
    }

    setState(() => _addingPlanIds.add(plan.id));
    try {
      final presetName = await _uniqueAddedPlanName(plan.name, profileId);
      final writes = <WorkoutExerciseWrite>[];
      for (final exercise in exercises) {
        final definition = await _findPremadeExerciseDefinition(exercise);
        final defId =
            definition?.id ??
            await _repo.findOrCreateExerciseDefinition(
              exercise.name,
              exercise.equipment,
            );
        writes.add(
          WorkoutExerciseWrite(
            exercise: WeightExercise(
              name: exercise.name,
              equipment: exercise.equipment,
              sets: List<ExerciseSet>.generate(
                exercise.sets,
                (_) =>
                    ExerciseSet(weight: exercise.weight, reps: exercise.reps),
              ),
            ),
            type: 'weight',
            definitionId: defId,
          ),
        );
      }
      final presetId = await _repo.createPresetAtomic(
        name: presetName,
        profileId: profileId,
        exercises: writes,
        activate: true,
      );

      if (!mounted) return;
      widget.onPlanAdded();
      widget.onPlanCreated?.call(presetId);
      if (widget.onboardingMode) {
        setState(() => _onboardingCreatedPlanIds.add(presetId));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.premadePlanAdded(presetName))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _strings.premadePlanAddFailed(
              plan.name,
              safeFailureMessage(_strings, error),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _addingPlanIds.remove(plan.id));
      }
    }
  }

  Future<_PremadePlanAdaptationData> _ensureAdaptationData({
    required bool expressive,
  }) {
    if (_adaptationFuture == null ||
        _adaptationProfileId != widget.profileId ||
        _adaptationDurationMinutes != _selectedDurationMinutes ||
        _adaptationFilterValue != _filterForProfileEquipment ||
        _adaptationExpressive != expressive) {
      _adaptationProfileId = widget.profileId;
      _adaptationDurationMinutes = _selectedDurationMinutes;
      _adaptationFilterValue = _filterForProfileEquipment;
      _adaptationExpressive = expressive;
      _adaptationFuture = _loadAdaptationData(expressive: expressive);
    }
    return _adaptationFuture!;
  }

  Future<_PremadePlanAdaptationData> _loadAdaptationData({
    required bool expressive,
  }) async {
    final profileEquipmentNames = await _loadProfileEquipmentNames();
    final normalizedProfileEquipmentNames = _normalizeEquipmentNames(
      profileEquipmentNames,
    );
    if (!_filterForProfileEquipment || widget.profileId == null) {
      return _PremadePlanAdaptationData(
        profileEquipmentNames: profileEquipmentNames,
        adaptations: const <String, _PremadePlanAdaptation>{},
        compatiblePlanIds: const <String>{},
      );
    }

    final plans = premadeTrainingPlans
        .where((plan) => plan.durationMinutes == _selectedDurationMinutes)
        .toList();
    if (expressive) {
      final compatible = await mapWithConcurrency<PremadeTrainingPlan, bool>(
        plans,
        maxConcurrency: _replacementBuildConcurrency,
        mapper: (plan, _) =>
            _planFitsProfile(plan, normalizedProfileEquipmentNames),
      );
      return _PremadePlanAdaptationData(
        profileEquipmentNames: profileEquipmentNames,
        adaptations: const <String, _PremadePlanAdaptation>{},
        compatiblePlanIds: {
          for (var index = 0; index < plans.length; index++)
            if (compatible[index]) plans[index].id,
        },
      );
    }

    final candidates = await _loadProfileCandidateEntries(
      normalizedProfileEquipmentNames,
    );
    if (candidates.isEmpty) {
      return _PremadePlanAdaptationData(
        profileEquipmentNames: profileEquipmentNames,
        adaptations: const <String, _PremadePlanAdaptation>{},
        compatiblePlanIds: const <String>{},
      );
    }

    final replacementCache = <String, PremadeTrainingExercise?>{};
    final definitionCache = <String, Future<ExerciseDefinition?>>{};
    final adaptations = <String, _PremadePlanAdaptation>{};
    for (final plan in plans) {
      var replacementCount = 0;
      final adaptedExercises = <PremadeTrainingExercise>[];

      for (final exercise in plan.exercises) {
        final cacheKey = _premadeExerciseCacheKey(exercise);
        final definition = await definitionCache.putIfAbsent(
          cacheKey,
          () => _findPremadeExerciseDefinition(exercise),
        );
        if (_premadeExerciseFitsProfile(
          exercise,
          normalizedProfileEquipmentNames,
          definition: definition,
        )) {
          adaptedExercises.add(exercise);
          continue;
        }

        final replacement = replacementCache.containsKey(cacheKey)
            ? replacementCache[cacheKey]
            : await _findReplacementExercise(exercise, candidates);
        replacementCache[cacheKey] = replacement;

        if (replacement == null) {
          adaptedExercises.add(exercise);
        } else {
          adaptedExercises.add(replacement);
          replacementCount++;
        }
      }

      if (replacementCount > 0) {
        adaptations[plan.id] = _PremadePlanAdaptation(
          exercises: List<PremadeTrainingExercise>.unmodifiable(
            adaptedExercises,
          ),
          replacementCount: replacementCount,
        );
      }
    }

    return _PremadePlanAdaptationData(
      profileEquipmentNames: profileEquipmentNames,
      adaptations: adaptations,
      compatiblePlanIds: const <String>{},
    );
  }

  Future<bool> _planFitsProfile(
    PremadeTrainingPlan plan,
    Set<String> normalizedProfileEquipmentNames,
  ) async {
    for (final exercise in plan.exercises) {
      final definition = await _findPremadeExerciseDefinition(exercise);
      if (!_premadeExerciseFitsProfile(
        exercise,
        normalizedProfileEquipmentNames,
        definition: definition,
      )) {
        return false;
      }
    }
    return true;
  }

  Future<Set<String>> _loadProfileEquipmentNames() async {
    final profileId = widget.profileId;
    if (profileId == null) return const <String>{};
    final rows = await _repo.fetchEquipmentForProfile(profileId);
    return {
      for (final row in rows)
        if ((row['name'] as String?)?.trim().isNotEmpty ?? false)
          (row['name'] as String).trim(),
    };
  }

  Set<String> _normalizeEquipmentNames(Iterable<String> equipmentNames) {
    return {
      for (final name in equipmentNames)
        if (name.trim().isNotEmpty) name.trim().toLowerCase(),
    };
  }

  Future<List<_PremadeExerciseMatchEntry>> _loadProfileCandidateEntries(
    Set<String> normalizedProfileEquipmentNames,
  ) async {
    final definitions = await _repo.lookupDefsDetailed();
    final entries =
        await mapWithConcurrency<
          ExerciseDefinition,
          _PremadeExerciseMatchEntry?
        >(
          definitions,
          maxConcurrency: _replacementBuildConcurrency,
          mapper: (definition, _) async {
            if (!_definitionFitsProfile(
              definition,
              normalizedProfileEquipmentNames,
            )) {
              return null;
            }
            return _buildMatchEntry(definition);
          },
        );

    return [
      for (final entry in entries)
        if (entry != null) entry,
    ];
  }

  Future<PremadeTrainingExercise?> _findReplacementExercise(
    PremadeTrainingExercise exercise,
    List<_PremadeExerciseMatchEntry> candidates,
  ) async {
    final current = await _buildPremadeExerciseEntry(exercise);
    if (current == null) return null;

    _PremadeExerciseMatchEntry? bestCandidate;
    var bestScore = 0.0;
    for (final candidate in candidates) {
      if (candidate.definition.id == current.definition.id) continue;
      final score = _similarityScore(current, candidate);
      if (score > bestScore) {
        bestScore = score;
        bestCandidate = candidate;
      }
    }

    if (bestCandidate == null || bestScore <= 0.05) return null;
    final equipment = _primaryEquipmentName(bestCandidate.definition);

    return PremadeTrainingExercise(
      name: bestCandidate.definition.name,
      catalogId: bestCandidate.definition.catalogId,
      equipment: equipment,
      sets: exercise.sets,
      reps: exercise.reps,
      weight: exercise.weight,
    );
  }

  Future<_PremadeExerciseMatchEntry?> _buildPremadeExerciseEntry(
    PremadeTrainingExercise exercise,
  ) async {
    final definition = await _findPremadeExerciseDefinition(exercise);
    if (definition == null) return null;
    return _buildMatchEntry(definition);
  }

  Future<ExerciseDefinition?> _findPremadeExerciseDefinition(
    PremadeTrainingExercise exercise,
  ) async {
    final catalogId = exercise.catalogId;
    if (catalogId != null && catalogId.isNotEmpty) {
      final definition = await _repo.fetchDefinitionByCatalogId(catalogId);
      if (definition != null) return definition;
    }

    try {
      final id = await _repo.findExerciseDefinitionId(
        exercise.name,
        exercise.equipment,
      );
      return await _repo.fetchDefinitionById(id);
    } catch (_) {
      // Fall through to name search. Some definitions store extra equipment in
      // the join table, while the strict ID lookup checks only the primary
      // equipment column.
    }

    final searchResults = await _repo.searchExerciseDefinitions(exercise.name);
    if (searchResults.isEmpty) return null;
    final detailedResults = await _repo.lookupDefsDetailedByIds(
      searchResults.map((definition) => definition.id).toSet().toList(),
    );
    final targetName = exercise.name.trim().toLowerCase();
    final targetEquipment = exercise.equipment.trim().toLowerCase();

    for (final definition in detailedResults) {
      final names = ExerciseEquipmentCompatibility.requiredEquipmentNames(
        definition,
      );
      if (definition.name.trim().toLowerCase() == targetName &&
          names.contains(targetEquipment)) {
        return definition;
      }
    }

    for (final definition in detailedResults) {
      if (definition.name.trim().toLowerCase() == targetName) {
        return definition;
      }
    }

    return detailedResults.first;
  }

  Future<_PremadeExerciseMatchEntry> _buildMatchEntry(
    ExerciseDefinition definition,
  ) async {
    final bodyPartUnits = await _repo.computeBodyPartPercents(definition.id);
    final muscleRows = await _repo.computeMusclePercents(definition.id);
    return _PremadeExerciseMatchEntry(
      definition: definition,
      bodyPartUnitsById: {
        for (final entry in bodyPartUnits.entries)
          if (entry.value > 0.0) entry.key.id: entry.value,
      },
      muscleUnitsById: {
        for (final row in muscleRows)
          if (row.percent > 0.0) row.muscleId: row.percent,
      },
    );
  }

  double _similarityScore(
    _PremadeExerciseMatchEntry current,
    _PremadeExerciseMatchEntry candidate,
  ) {
    final bodyPartScore = _cosineSimilarity(
      current.bodyPartUnitsById,
      candidate.bodyPartUnitsById,
    );
    final muscleScore = _cosineSimilarity(
      current.muscleUnitsById,
      candidate.muscleUnitsById,
    );
    return bodyPartScore * 0.60 + muscleScore * 0.40;
  }

  double _cosineSimilarity(Map<int, double> a, Map<int, double> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;

    var dot = 0.0;
    var aMagnitude = 0.0;
    var bMagnitude = 0.0;
    for (final entry in a.entries) {
      aMagnitude += entry.value * entry.value;
      dot += entry.value * (b[entry.key] ?? 0.0);
    }
    for (final value in b.values) {
      bMagnitude += value * value;
    }

    if (aMagnitude == 0.0 || bMagnitude == 0.0) return 0.0;
    return dot / (math.sqrt(aMagnitude) * math.sqrt(bMagnitude));
  }

  bool _premadeExerciseFitsProfile(
    PremadeTrainingExercise exercise,
    Set<String> profileEquipmentNames, {
    ExerciseDefinition? definition,
  }) {
    if (definition != null) {
      return _definitionFitsProfile(definition, profileEquipmentNames);
    }
    // Keep static-plan entries without a matching definition compatible with
    // their existing one-equipment fallback behavior.
    return _profileContainsEquipment(profileEquipmentNames, exercise.equipment);
  }

  bool _definitionFitsProfile(
    ExerciseDefinition definition,
    Set<String> profileEquipmentNames,
  ) => ExerciseEquipmentCompatibility.fitsProfileNames(
    definition,
    profileEquipmentNames,
  );

  String _premadeExerciseCacheKey(PremadeTrainingExercise exercise) =>
      '${exercise.name.trim().toLowerCase()}|'
      '${exercise.equipment.trim().toLowerCase()}';

  bool _profileContainsEquipment(
    Set<String> profileEquipmentNames,
    String equipmentName,
  ) {
    final equipment = equipmentName.trim().toLowerCase();
    if (equipment.isEmpty) return true;
    if (profileEquipmentNames.contains(equipment)) return true;
    if (equipment == 'bodyweight' || equipment == 'none') {
      return profileEquipmentNames.contains('bodyweight') ||
          profileEquipmentNames.contains('none');
    }
    return false;
  }

  String _primaryEquipmentName(ExerciseDefinition definition) {
    for (final equipment in definition.equipmentList) {
      final name = equipment.name.trim();
      if (name.isNotEmpty) return name;
    }
    return 'Bodyweight';
  }

  Future<void> _discardOnboardingPlans() async {
    if (_isDiscardingOnboardingPlans) return;
    final activePlanStore = context.read<ActivePlanStore>();
    final repository = _repo;
    setState(() => _isDiscardingOnboardingPlans = true);
    try {
      final profileId = widget.profileId;
      for (final presetId in List<int>.from(_onboardingCreatedPlanIds)) {
        if (profileId != null) {
          await activePlanStore.remove(profileId, presetId);
        }
        await repository.deletePreset(presetId);
      }
      if (!mounted) return;
      Navigator.of(context).pop<List<int>>(const <int>[]);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _strings.premadeDiscardFailed(safeFailureMessage(_strings, error)),
          ),
        ),
      );
      setState(() => _isDiscardingOnboardingPlans = false);
    }
  }

  void _finishOnboardingPlanSelection() {
    if (_onboardingCreatedPlanIds.isEmpty) return;
    Navigator.of(context)
        .pop<List<int>>(List<int>.unmodifiable(_onboardingCreatedPlanIds));
  }

  Future<String> _uniqueAddedPlanName(String baseName, int profileId) async {
    final existingRows = await _repo.fetchAllPresetsRaw(profileId: profileId);
    final existingNames = {
      for (final row in existingRows) (row['name'] as String).trim(),
    };
    if (!existingNames.contains(baseName)) return baseName;

    var copyNumber = 2;
    while (existingNames.contains('$baseName ($copyNumber)')) {
      copyNumber++;
    }
    return '$baseName ($copyNumber)';
  }

  Map<String, List<PremadeTrainingPlan>> _plansBySource() {
    final grouped = <String, List<PremadeTrainingPlan>>{};
    final filteredPlans = premadeTrainingPlans.where(
      (plan) => plan.durationMinutes == _selectedDurationMinutes,
    );
    for (final plan in filteredPlans) {
      grouped
          .putIfAbsent(plan.sourceName, () => <PremadeTrainingPlan>[])
          .add(plan);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final groupedPlans = _plansBySource();
    final homemadePlans =
        groupedPlans.remove(_homemadeSourceName) ??
        const <PremadeTrainingPlan>[];
    final adaptationFuture = _ensureAdaptationData(
      expressive: expressive != null,
    );
    final localizedPlansFuture = _localizedPlansFuture ??= _loadLocalizedPlans(
      Localizations.localeOf(context),
    );
    final content = Scaffold(
      backgroundColor: expressive?.pageCanvas,
      appBar: AppBar(
        toolbarHeight: expressive == null ? null : 76,
        titleSpacing: expressive == null ? NavigationToolbar.kMiddleSpacing : 0,
        title: Text(
          strings.premadePlansTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: expressive?.pageCanvas,
        foregroundColor: expressive?.onPage,
        actions: expressive == null
            ? null
            : [
                KeyedSubtree(
                  key: _durationTutorialKey,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          strings.optimizedWorkoutDuration,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: expressive.configurationForeground,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -4),
                          child: _PremadeDurationSwitch(
                            durationMinutes: _selectedDurationMinutes,
                            onChanged: (durationMinutes) {
                              setState(() {
                                _selectedDurationMinutes = durationMinutes;
                                _adaptationFuture = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
      ),
      bottomNavigationBar: widget.onboardingMode
          ? OnboardingPlanActionBar(
              addedCount: _onboardingCreatedPlanIds.length,
              isBusy: _isDiscardingOnboardingPlans,
              onCancel: _discardOnboardingPlans,
              onSave: _onboardingCreatedPlanIds.isEmpty
                  ? null
                  : _finishOnboardingPlanSelection,
            )
          : null,
      body: FutureBuilder<_PremadePlanAdaptationData>(
        future: adaptationFuture,
        builder: (context, snapshot) {
          return FutureBuilder<Map<String, LocalizedPremadePlan>>(
            key: ValueKey(_localizedLocaleKey),
            future: localizedPlansFuture,
            builder: (context, localizationSnapshot) {
              final localizedPlans =
                  localizationSnapshot.data ?? _canonicalLocalizedPlans();
              final loadedAdaptationData =
                  snapshot.data ?? _PremadePlanAdaptationData.empty;
              final adaptationData = _filterForProfileEquipment
                  ? loadedAdaptationData
                  : _PremadePlanAdaptationData(
                      profileEquipmentNames:
                          loadedAdaptationData.profileEquipmentNames,
                      adaptations: const <String, _PremadePlanAdaptation>{},
                      compatiblePlanIds: const <String>{},
                    );
              final isPreparingFilter =
                  _filterForProfileEquipment &&
                  widget.profileId != null &&
                  snapshot.connectionState != ConnectionState.done;
              final allDurationPlans = premadeTrainingPlans
                  .where(
                    (plan) => plan.durationMinutes == _selectedDurationMinutes,
                  )
                  .toList();
              final visiblePlanIds =
                  expressive != null &&
                      _filterForProfileEquipment &&
                      widget.profileId != null &&
                      !isPreparingFilter
                  ? adaptationData.compatiblePlanIds
                  : null;
              final visiblePlanCount = visiblePlanIds == null
                  ? allDurationPlans.length
                  : allDurationPlans
                        .where((plan) => visiblePlanIds.contains(plan.id))
                        .length;
              final showNoMatchingPlans =
                  visiblePlanIds != null && visiblePlanCount == 0;
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  widget.onboardingMode ? 112 : 24,
                ),
                children: [
                  KeyedSubtree(
                    key: expressive == null ? _durationTutorialKey : null,
                    child: _PremadeDurationHeader(
                      durationMinutes: _selectedDurationMinutes,
                      onChanged: (durationMinutes) {
                        setState(() {
                          _selectedDurationMinutes = durationMinutes;
                          _adaptationFuture = null;
                        });
                      },
                      child: Text(
                        expressive == null
                            ? strings.premadeDescription
                            : strings.premadeExpressiveDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  KeyedSubtree(
                    key: _equipmentFilterTutorialKey,
                    child: _PremadeProfileEquipmentFilterCard(
                      value: _filterForProfileEquipment,
                      enabled: widget.profileId != null,
                      isLoading: isPreparingFilter,
                      hasProfileEquipment:
                          adaptationData.profileEquipmentNames.isNotEmpty,
                      replacementCount: adaptationData.totalReplacementCount,
                      onChanged: (value) {
                        setState(() {
                          _filterForProfileEquipment = value;
                          _adaptationFuture = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (showNoMatchingPlans)
                    _PremadeEquipmentEmptyState(
                      message: adaptationData.profileEquipmentNames.isEmpty
                          ? strings.premadeExpressiveEquipmentMissing
                          : strings.premadeExpressiveEquipmentNoMatches,
                      expressive: expressive,
                    )
                  else ...[
                    KeyedSubtree(
                      key: _planListTutorialKey,
                      child: _PremadeSourceSection(
                        sourceName: _homemadeSourceName,
                        isFeatured: true,
                        plans: homemadePlans,
                        visiblePlanIds: visiblePlanIds,
                        isFiltering: visiblePlanIds != null,
                        planGroupNames: _homemadePlanGroups,
                        initiallyExpanded: true,
                        addingPlanIds: _addingPlanIds,
                        adaptationData: adaptationData,
                        localizedPlans: localizedPlans,
                        isPreparingFilter: isPreparingFilter,
                        onAddPlan: _addPlan,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final entry in groupedPlans.entries) ...[
                      _PremadeSourceSection(
                        sourceName: entry.key,
                        isFeatured: false,
                        plans: entry.value,
                        visiblePlanIds: visiblePlanIds,
                        isFiltering: visiblePlanIds != null,
                        initiallyExpanded: false,
                        addingPlanIds: _addingPlanIds,
                        adaptationData: adaptationData,
                        localizedPlans: localizedPlans,
                        isPreparingFilter: isPreparingFilter,
                        onAddPlan: _addPlan,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ],
              );
            },
          );
        },
      ),
    );

    if (!widget.onboardingMode) return content;
    return PopScope<List<int>>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _discardOnboardingPlans();
      },
      child: content,
    );
  }
}

class OnboardingPlanActionBar extends StatelessWidget {
  final int addedCount;
  final bool isBusy;
  final VoidCallback onCancel;
  final VoidCallback? onSave;

  const OnboardingPlanActionBar({
    super.key,
    required this.addedCount,
    required this.isBusy,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final surfaces = context.surfaceTokens;
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final actionForeground = neo
        ? tonosForegroundForSurface(context, surfaces.planActionBar)
        : null;
    final actionDisabledForeground = neo
        ? actionForeground!.withValues(alpha: 0.45)
        : null;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: expressive?.actionSecondary ?? surfaces.planActionBar,
          border: Border(
            top: BorderSide(
              color:
                  expressive?.outline ??
                  Theme.of(context).colorScheme.outlineVariant
                      .withValues(alpha: 0.6),
            ),
          ),
          borderRadius: expressive?.supportShape,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isBusy ? null : onCancel,
                style: expressive == null
                    ? null
                    : OutlinedButton.styleFrom(
                        foregroundColor: expressive.actionSecondaryForeground,
                        side: BorderSide(color: expressive.outline),
                      ),
                child: Text(
                  isBusy ? strings.premadeDiscarding : strings.commonCancel,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                style: expressive != null
                    ? FilledButton.styleFrom(
                        backgroundColor: expressive.actionPrimary,
                        foregroundColor: expressive.actionPrimaryForeground,
                      )
                    : neo
                    ? FilledButton.styleFrom(
                        foregroundColor: actionForeground,
                        disabledForegroundColor: actionDisabledForeground,
                      )
                    : null,
                onPressed: isBusy ? null : onSave,
                icon: _PlanCountBadge(count: addedCount),
                label: Text(strings.premadeReviewPlans),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCountBadge extends StatelessWidget {
  final int count;

  const _PlanCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shapes = context.shapeTokens;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.save_outlined),
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: scheme.error,
                borderRadius: shapes.pill,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: TextStyle(
                  color: scheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PremadePlanAdaptationData {
  final Set<String> profileEquipmentNames;
  final Map<String, _PremadePlanAdaptation> adaptations;
  final Set<String> compatiblePlanIds;

  const _PremadePlanAdaptationData({
    required this.profileEquipmentNames,
    required this.adaptations,
    required this.compatiblePlanIds,
  });

  static const empty = _PremadePlanAdaptationData(
    profileEquipmentNames: <String>{},
    adaptations: <String, _PremadePlanAdaptation>{},
    compatiblePlanIds: <String>{},
  );

  int get totalReplacementCount => adaptations.values.fold<int>(
    0,
    (sum, adaptation) => sum + adaptation.replacementCount,
  );

  List<PremadeTrainingExercise> exercisesFor(PremadeTrainingPlan plan) {
    return adaptations[plan.id]?.exercises ?? plan.exercises;
  }

  int replacementCountFor(PremadeTrainingPlan plan) {
    return adaptations[plan.id]?.replacementCount ?? 0;
  }
}

class _PremadePlanAdaptation {
  final List<PremadeTrainingExercise> exercises;
  final int replacementCount;

  const _PremadePlanAdaptation({
    required this.exercises,
    required this.replacementCount,
  });
}

class _PremadeExerciseMatchEntry {
  final ExerciseDefinition definition;
  final Map<int, double> bodyPartUnitsById;
  final Map<int, double> muscleUnitsById;

  const _PremadeExerciseMatchEntry({
    required this.definition,
    required this.bodyPartUnitsById,
    required this.muscleUnitsById,
  });
}

class _PremadeProfileEquipmentFilterCard extends StatelessWidget {
  final bool value;
  final bool enabled;
  final bool isLoading;
  final bool hasProfileEquipment;
  final int replacementCount;
  final ValueChanged<bool> onChanged;

  const _PremadeProfileEquipmentFilterCard({
    required this.value,
    required this.enabled,
    required this.isLoading,
    required this.hasProfileEquipment,
    required this.replacementCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = context.surfaceTokens;
    final strings = AppLocalizations.of(context);
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final filterSurface = expressive == null
        ? surfaces.planFilter
        : theme.brightness == Brightness.dark
        ? expressive.configurationSurface
        : Color.lerp(expressive.equipmentSurface, expressive.pageCanvas, 0.14)!;
    final filterForeground =
        (expressive == null
            ? null
            : theme.brightness == Brightness.dark
            ? expressive.configurationForeground
            : expressive.equipmentForeground) ??
        (neo ? tonosForegroundForSurface(context, surfaces.planFilter) : null);
    final filterSecondary =
        filterForeground ??
        (neo
            ? tonosSecondaryForegroundForSurface(context, surfaces.planFilter)
            : scheme.onSurfaceVariant);
    final subtitle = !enabled
        ? expressive == null
              ? strings.premadeEquipmentSelectProfile
              : strings.premadeExpressiveEquipmentSelectProfile
        : !value
        ? expressive == null
              ? strings.premadeEquipmentExact
              : strings.premadeExpressiveEquipmentAll
        : isLoading
        ? expressive == null
              ? strings.premadeEquipmentChecking
              : strings.premadeExpressiveEquipmentChecking
        : !hasProfileEquipment
        ? expressive == null
              ? strings.premadeEquipmentMissing
              : strings.premadeExpressiveEquipmentMissing
        : expressive != null
        ? strings.premadeExpressiveEquipmentCompatible
        : replacementCount > 0
        ? strings.premadeEquipmentReplacements(replacementCount)
        : strings.premadeEquipmentFits;

    return Card(
      color: filterSurface,
      elevation: expressive == null ? null : 0,
      shape: expressive == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: expressive.supportShape,
              side: BorderSide(
                color: expressive.outline.withValues(alpha: 0.42),
              ),
            ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactExpressive =
                expressive != null &&
                (constraints.maxWidth < 340 ||
                    MediaQuery.textScalerOf(context).scale(14) > 18);
            final control = isLoading
                ? expressive == null
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                : Switch(
                    value: value,
                    onChanged: enabled ? onChanged : null,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expressive == null
                      ? strings.swapFilterProfileEquipment
                      : strings.premadeEquipmentFilterLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: filterForeground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: filterSecondary,
                  ),
                ),
              ],
            );
            return Row(
              children: [
                Icon(
                  Icons.tune,
                  color: expressive != null
                      ? filterForeground
                      : neo
                      ? filterForeground
                      : scheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: compactExpressive
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            copy,
                            Align(
                              alignment: Alignment.centerRight,
                              child: control,
                            ),
                          ],
                        )
                      : copy,
                ),
                if (!compactExpressive) control,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PremadeEquipmentEmptyState extends StatelessWidget {
  final String message;
  final AppExpressivePlanningTokens? expressive;

  const _PremadeEquipmentEmptyState({
    required this.message,
    required this.expressive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expressiveTokens = expressive;
    return Card(
      color: expressiveTokens?.configurationSurface,
      elevation: expressiveTokens == null ? null : 0,
      shape: expressiveTokens == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: expressiveTokens.supportShape,
              side: BorderSide(
                color: expressiveTokens.outline.withValues(alpha: 0.24),
              ),
            ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              color:
                  expressiveTokens?.configurationForeground ??
                  theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      expressiveTokens?.configurationForeground ??
                      theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremadeDurationHeader extends StatelessWidget {
  final int durationMinutes;
  final ValueChanged<int> onChanged;
  final Widget child;

  const _PremadeDurationHeader({
    required this.durationMinutes,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final switcher = _PremadeDurationSwitch(
      durationMinutes: durationMinutes,
      onChanged: onChanged,
    );
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    if (expressive != null) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              child,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: switcher),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: child),
            const SizedBox(width: 14),
            switcher,
          ],
        );
      },
    );
  }
}

class _PremadeDurationSwitch extends StatelessWidget {
  final int durationMinutes;
  final ValueChanged<int> onChanged;

  const _PremadeDurationSwitch({
    required this.durationMinutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final strings = AppLocalizations.of(context);
    final shapes = context.shapeTokens;
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final durationForeground =
        expressive?.configurationForeground ??
        (neo
            ? tonosForegroundForSurface(context, surfaces.planDuration)
            : null);
    final isTwoHour = durationMinutes == 120;
    if (expressive != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: SegmentedButton<int>(
          segments: [
            ButtonSegment<int>(
              value: 60,
              label: Text(strings.premadeExpressiveOneHour),
            ),
            ButtonSegment<int>(
              value: 120,
              label: Text(strings.premadeExpressiveTwoHours),
            ),
          ],
          selected: {durationMinutes},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => onChanged(selection.first),
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.padded,
            minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? expressive.actionPrimaryForeground
                  : expressive.configurationForeground;
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? expressive.actionPrimary
                  : expressive.configurationSurface;
            }),
            side: WidgetStateProperty.resolveWith((states) {
              return BorderSide(
                color: states.contains(WidgetState.selected)
                    ? expressive.actionPrimary
                    : expressive.outline.withValues(alpha: 0.45),
              );
            }),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: expressive.rowShape),
            ),
          ),
        ),
      );
    }
    final activeStyle = theme.textTheme.labelLarge?.copyWith(
      color:
          expressive?.selectedSurface ??
          (neo ? durationForeground : theme.colorScheme.primary),
      fontWeight: FontWeight.w800,
    );
    final inactiveStyle = theme.textTheme.labelLarge?.copyWith(
      color: neo ? durationForeground : theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: expressive?.configurationSurface ?? surfaces.planDuration,
        borderRadius: expressive?.rowShape ?? shapes.planCard,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactExpressive =
                expressive != null &&
                (constraints.maxWidth < 280 ||
                    MediaQuery.textScalerOf(context).scale(14) > 18);
            final oneHour = Text(
              strings.premadeOneHour,
              textAlign: TextAlign.end,
              softWrap: compactExpressive,
              maxLines: compactExpressive ? 2 : null,
              style: isTwoHour ? inactiveStyle : activeStyle,
            );
            final twoHours = Text(
              strings.premadeTwoHours,
              textAlign: TextAlign.start,
              softWrap: compactExpressive,
              maxLines: compactExpressive ? 2 : null,
              style: isTwoHour ? activeStyle : inactiveStyle,
            );
            final durationSwitch = Switch(
              value: isTwoHour,
              onChanged: (value) => onChanged(value ? 120 : 60),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
            if (compactExpressive) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: oneHour),
                  durationSwitch,
                  Flexible(child: twoHours),
                ],
              );
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [oneHour, durationSwitch, twoHours],
            );
          },
        ),
      ),
    );
  }
}

class _PremadeSourceSection extends StatelessWidget {
  final String sourceName;
  final bool isFeatured;
  final List<PremadeTrainingPlan> plans;
  final Set<String>? visiblePlanIds;
  final bool isFiltering;
  final List<String> planGroupNames;
  final bool initiallyExpanded;
  final Set<String> addingPlanIds;
  final _PremadePlanAdaptationData adaptationData;
  final Map<String, LocalizedPremadePlan> localizedPlans;
  final bool isPreparingFilter;
  final Future<void> Function(
    PremadeTrainingPlan plan,
    List<PremadeTrainingExercise> exercises,
  )
  onAddPlan;

  const _PremadeSourceSection({
    required this.sourceName,
    required this.isFeatured,
    required this.plans,
    required this.visiblePlanIds,
    required this.isFiltering,
    this.planGroupNames = const <String>[],
    required this.initiallyExpanded,
    required this.addingPlanIds,
    required this.adaptationData,
    required this.localizedPlans,
    required this.isPreparingFilter,
    required this.onAddPlan,
  });

  Map<String, List<PremadeTrainingPlan>> _plansByGroup() {
    final grouped = <String, List<PremadeTrainingPlan>>{};
    for (final plan in plans) {
      final localizedPlan =
          localizedPlans[plan.id] ?? LocalizedPremadePlan.fromPlan(plan);
      final groupPlans = grouped.putIfAbsent(
        localizedPlan.groupName,
        () => <PremadeTrainingPlan>[],
      );
      if (visiblePlanIds == null || visiblePlanIds!.contains(plan.id)) {
        groupPlans.add(plan);
      }
    }
    return grouped;
  }

  List<String> _orderedGroupNames(
    Map<String, List<PremadeTrainingPlan>> grouped,
  ) {
    final ordered = <String>[];
    for (final groupName in planGroupNames) {
      final localizedGroupName = _localizedGroupName(groupName);
      if (!ordered.contains(localizedGroupName)) {
        ordered.add(localizedGroupName);
      }
    }
    for (final groupName in grouped.keys) {
      if (!ordered.contains(groupName)) ordered.add(groupName);
    }
    return ordered;
  }

  String _localizedGroupName(String canonicalGroupName) {
    for (final plan in plans) {
      if (plan.planGroupName != canonicalGroupName) continue;
      return (localizedPlans[plan.id] ?? LocalizedPremadePlan.fromPlan(plan))
          .groupName;
    }
    return canonicalGroupName;
  }

  String _localizedSourceName(BuildContext context) {
    if (isFeatured && AppExpressivePlanningTokens.maybeOf(context) != null) {
      return AppLocalizations.of(context).premadeBuiltinPlansTitle;
    }
    if (plans.isEmpty) return sourceName;
    final firstPlan = plans.first;
    return (localizedPlans[firstPlan.id] ??
            LocalizedPremadePlan.fromPlan(firstPlan))
        .sourceName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final grouped = _plansByGroup();
    final orderedGroupNames = _orderedGroupNames(grouped);
    final planCount = grouped.values.fold<int>(
      0,
      (total, plansInGroup) => total + plansInGroup.length,
    );
    final sourceSurface = isFeatured
        ? expressive?.planFocalSurface
        : expressive?.planSupportSurface;
    final sourceForeground = isFeatured
        ? expressive?.planFocalForeground
        : expressive?.planSupportForeground;

    final groupCard = Card(
      color: sourceSurface,
      elevation: expressive == null ? null : 0,
      shape: expressive == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: isFeatured
                  ? expressive.focalShape
                  : expressive.supportShape,
              side: BorderSide(
                color: expressive.outline.withValues(alpha: 0.5),
              ),
            ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: expressive == null ? 4 : 0,
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          expressive == null ? 12 : 10,
          0,
          expressive == null ? 12 : 10,
          expressive == null ? 12 : 8,
        ),
        iconColor: sourceForeground,
        collapsedIconColor: sourceForeground,
        title: Text(
          _localizedSourceName(context),
          style: theme.textTheme.titleLarge?.copyWith(
            color: sourceForeground,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          expressive == null
              ? strings.premadePlansAvailable(planCount)
              : strings.premadeExpressivePlansAvailable(planCount),
          style: theme.textTheme.labelMedium?.copyWith(
            color: sourceForeground ?? theme.colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          for (final groupName in orderedGroupNames)
            _PremadePlanGroupTile(
              groupName: groupName,
              plans: grouped[groupName] ?? const <PremadeTrainingPlan>[],
              isFiltering: isFiltering,
              addingPlanIds: addingPlanIds,
              adaptationData: adaptationData,
              localizedPlans: localizedPlans,
              isPreparingFilter: isPreparingFilter,
              isFeatured: isFeatured,
              onAddPlan: onAddPlan,
            ),
        ],
      ),
    );
    return expressive == null || isFeatured
        ? groupCard
        : TonosExpressivePressResponse(
            enabled: true,
            pressedScale: TonosExpressiveMotionTiers.supportingScale,
            pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
            child: groupCard,
          );
  }
}

class _PremadePlanGroupTile extends StatelessWidget {
  final String groupName;
  final List<PremadeTrainingPlan> plans;
  final bool isFiltering;
  final Set<String> addingPlanIds;
  final _PremadePlanAdaptationData adaptationData;
  final Map<String, LocalizedPremadePlan> localizedPlans;
  final bool isPreparingFilter;
  final bool isFeatured;
  final Future<void> Function(
    PremadeTrainingPlan plan,
    List<PremadeTrainingExercise> exercises,
  )
  onAddPlan;

  const _PremadePlanGroupTile({
    required this.groupName,
    required this.plans,
    required this.isFiltering,
    required this.addingPlanIds,
    required this.adaptationData,
    required this.localizedPlans,
    required this.isPreparingFilter,
    required this.isFeatured,
    required this.onAddPlan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final strings = AppLocalizations.of(context);
    final planCount = plans.length;
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final groupSurface = isFeatured
        ? expressive?.configurationSurface
        : expressive?.equipmentSurface;
    final groupForeground =
        (isFeatured
            ? expressive?.configurationForeground
            : expressive?.equipmentForeground) ??
        (neo ? tonosForegroundForSurface(context, surfaces.planGroup) : null);
    final groupSecondary =
        (isFeatured
            ? expressive?.configurationForeground
            : expressive?.equipmentForeground) ??
        (neo
            ? tonosSecondaryForegroundForSurface(context, surfaces.planGroup)
            : theme.colorScheme.onSurfaceVariant);
    final countLabel = plans.isEmpty && !isFiltering
        ? strings.premadeNoTemplates
        : expressive == null
        ? strings.premadePlansCount(planCount)
        : strings.premadeExpressivePlansCount(planCount);
    final categoryHeaderTarget = isFeatured
        ? expressive?.planSupportSurface
        : expressive?.configurationSurface;
    final categoryTitle = LayoutBuilder(
      builder: (context, constraints) {
        final stackCount =
            constraints.maxWidth < 230 ||
            MediaQuery.textScalerOf(context).scale(14) > 18;
        final name = Text(
          groupName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            color: groupForeground,
            fontWeight: FontWeight.w900,
          ),
        );
        final count = _PremadeCountBadge(label: countLabel);
        if (stackCount) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [name, const SizedBox(height: 4), count],
          );
        }
        return Row(
          children: [
            Expanded(child: name),
            const SizedBox(width: 8),
            count,
          ],
        );
      },
    );
    final planCard = Card(
      margin: EdgeInsets.only(bottom: expressive == null ? 10 : 6),
      color: groupSurface ?? surfaces.planGroup,
      elevation: expressive == null ? null : 0,
      shape: expressive == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: expressive.supportShape,
              side: BorderSide(
                color: expressive.outline.withValues(alpha: 0.42),
              ),
            ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.symmetric(
          horizontal: expressive == null ? 14 : 8,
          vertical: expressive == null ? 2 : 0,
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          expressive == null ? 10 : 8,
          0,
          expressive == null ? 10 : 8,
          expressive == null ? 10 : 8,
        ),
        iconColor: groupForeground,
        collapsedIconColor: groupForeground,
        title: expressive == null
            ? Text(
                groupName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: neo ? groupForeground : null,
                  fontWeight: FontWeight.w800,
                ),
              )
            : DecoratedBox(
                key: ValueKey('premade-category-header-$groupName'),
                decoration: BoxDecoration(
                  color: Color.lerp(groupSurface, categoryHeaderTarget, 0.18),
                  borderRadius: expressive.rowShape,
                  border: Border.all(
                    color: expressive.outline.withValues(alpha: 0.34),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: categoryTitle,
                ),
              ),
        subtitle: expressive == null
            ? Text(
                countLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: groupSecondary,
                ),
              )
            : null,
        children: [
          if (plans.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isFiltering
                      ? strings.premadeExpressiveEquipmentNoMatches
                      : strings.premadeTemplatesLater,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: groupSecondary,
                  ),
                ),
              ),
            )
          else
            for (final plan in plans) ...[
              _PremadePlanCard(
                key: ValueKey(plan.id),
                plan: plan,
                localizedPlan:
                    localizedPlans[plan.id] ??
                    LocalizedPremadePlan.fromPlan(plan),
                exercises: adaptationData.exercisesFor(plan),
                replacementCount: adaptationData.replacementCountFor(plan),
                isAdding: addingPlanIds.contains(plan.id),
                isPreparing: isPreparingFilter,
                isFeatured: isFeatured,
                parentSurface: groupSurface,
                onAdd: () {
                  onAddPlan(plan, adaptationData.exercisesFor(plan));
                },
              ),
              if (plan != plans.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
    return expressive == null
        ? planCard
        : TonosExpressivePressResponse(
            enabled: true,
            pressedScale: TonosExpressiveMotionTiers.supportingScale,
            pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
            child: planCard,
          );
  }
}

class _PremadeCountBadge extends StatelessWidget {
  final String label;

  const _PremadeCountBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    if (expressive == null) return Text(label);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: expressive.planAccent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: expressive.planAccentForeground,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PremadePlanCard extends StatefulWidget {
  final PremadeTrainingPlan plan;
  final LocalizedPremadePlan localizedPlan;
  final List<PremadeTrainingExercise> exercises;
  final int replacementCount;
  final bool isAdding;
  final bool isPreparing;
  final bool isFeatured;
  final Color? parentSurface;
  final VoidCallback onAdd;

  const _PremadePlanCard({
    super.key,
    required this.plan,
    required this.localizedPlan,
    required this.exercises,
    required this.replacementCount,
    required this.isAdding,
    required this.isPreparing,
    required this.isFeatured,
    required this.parentSurface,
    required this.onAdd,
  });

  @override
  State<_PremadePlanCard> createState() => _PremadePlanCardState();
}

class _PremadePlanCardState extends State<_PremadePlanCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  bool _exerciseChangedAt(int index) {
    final originalExercises = widget.plan.exercises;
    if (index >= originalExercises.length) return false;
    final original = originalExercises[index];
    final current = widget.exercises[index];
    return original.name != current.name ||
        original.equipment != current.equipment;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motion = context.motionTokens;
    final strings = AppLocalizations.of(context);
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final planSurface = expressive == null
        ? null
        : Color.lerp(
            widget.parentSurface ?? expressive.configurationSurface,
            widget.isFeatured
                ? expressive.planSupportSurface
                : expressive.configurationSurface,
            theme.brightness == Brightness.dark ? 0.18 : 0.22,
          );
    final exercises = widget.exercises;
    final totalSets = exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets,
    );
    final durationLabel = widget.plan.durationMinutes == 60
        ? strings.premadeExpressiveOneHour
        : strings.premadeExpressiveTwoHours;
    final description = expressive == null
        ? widget.localizedPlan.description.trim()
        : strings.premadePlanQuickDescription(
            durationLabel,
            widget.localizedPlan.name,
          );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: expressive == null ? 8 : 6),
        if (description.isNotEmpty) ...[
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  expressive?.configurationForeground ??
                  theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: expressive == null ? 12 : 8),
          if (expressive != null)
            Divider(
              height: 16,
              thickness: 1,
              color: expressive.outline.withValues(alpha: 0.24),
            ),
        ],
        for (var i = 0; i < exercises.length; i++)
          _PremadeExerciseRow(
            exercise: exercises[i],
            wasSwapped: _exerciseChangedAt(i),
          ),
      ],
    );
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.localizedPlan.name,
          style: theme.textTheme.titleMedium?.copyWith(
            color: expressive?.configurationForeground,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          [
            strings.premadeExerciseCount(exercises.length),
            strings.premadeSetCount(totalSets),
            if (widget.replacementCount > 0)
              strings.premadeSwappedCount(widget.replacementCount),
          ].join(' - '),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
    final addButton = FilledButton.tonalIcon(
      style: expressive == null
          ? null
          : FilledButton.styleFrom(
              backgroundColor: expressive.actionPrimary,
              foregroundColor: expressive.actionPrimaryForeground,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
      onPressed: widget.isAdding || widget.isPreparing ? null : widget.onAdd,
      icon: widget.isAdding || widget.isPreparing
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add),
      label: Text(
        widget.isAdding
            ? strings.premadeAdding
            : widget.isPreparing
            ? strings.premadeChecking
            : strings.commonAdd,
      ),
    );

    final planCard = Card(
      color: planSurface,
      elevation: expressive == null ? null : 0,
      shape: expressive == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: expressive.rowShape,
              side: BorderSide(
                color: expressive.outline.withValues(alpha: 0.32),
              ),
            ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _toggleExpanded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(expressive == null ? 16 : 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final titleWithIcon = Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color:
                            expressive?.configurationForeground ??
                            theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: titleBlock),
                    ],
                  );

                  if (constraints.maxWidth < (expressive == null ? 330 : 280) ||
                      (expressive != null &&
                          MediaQuery.textScalerOf(context).scale(14) > 20)) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleWithIcon,
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: addButton,
                        ),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: titleWithIcon),
                      const SizedBox(width: 12),
                      addButton,
                    ],
                  );
                },
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: EdgeInsets.fromLTRB(
                  expressive == null ? 16 : 12,
                  0,
                  expressive == null ? 16 : 12,
                  expressive == null ? 16 : 12,
                ),
                child: details,
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: appMotionDuration(context, motion.quick),
              firstCurve: Curves.easeOutCubic,
              secondCurve: Curves.easeOutCubic,
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
    return expressive == null
        ? planCard
        : TonosExpressivePressResponse(
            enabled: true,
            pressedScale: TonosExpressiveMotionTiers.supportingScale,
            pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
            child: planCard,
          );
  }
}

class _PremadeExerciseRow extends StatefulWidget {
  final PremadeTrainingExercise exercise;
  final bool wasSwapped;

  const _PremadeExerciseRow({required this.exercise, required this.wasSwapped});

  @override
  State<_PremadeExerciseRow> createState() => _PremadeExerciseRowState();
}

class _PremadeExerciseRowState extends State<_PremadeExerciseRow> {
  Future<String>? _nameFuture;
  String? _localeKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    final localeKey = _localeKeyFor(locale);
    if (_localeKey == localeKey) return;
    _localeKey = localeKey;
    _nameFuture = ExerciseContentLocalizer.instance.resolveNameForCatalogId(
      catalogId: widget.exercise.catalogId,
      fallbackName: widget.exercise.name,
      locale: locale,
    );
  }

  @override
  void didUpdateWidget(covariant _PremadeExerciseRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.catalogId != widget.exercise.catalogId ||
        oldWidget.exercise.name != widget.exercise.name) {
      final locale = Localizations.localeOf(context);
      _localeKey = _localeKeyFor(locale);
      _nameFuture = ExerciseContentLocalizer.instance.resolveNameForCatalogId(
        catalogId: widget.exercise.catalogId,
        fallbackName: widget.exercise.name,
        locale: locale,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return FutureBuilder<String>(
      key: ValueKey(_localeKey),
      future: _nameFuture,
      initialData: widget.exercise.name,
      builder: (context, snapshot) => _buildRow(
        context,
        theme,
        strings,
        snapshot.data ?? widget.exercise.name,
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    ThemeData theme,
    AppLocalizations strings,
    String displayName,
  ) {
    final locale = Localizations.localeOf(context);
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final setAndRepDetails =
        '${strings.catalogSetUnits(widget.exercise.sets)} × '
        '${LocalizedFormatters.number(widget.exercise.reps, locale, maximumFractionDigits: 0)} '
        '${strings.unitReps}';
    final equipment = <CatalogEntityDisplayName>[
      if (widget.exercise.equipment.trim().isNotEmpty)
        CatalogEntityDisplayName(
          catalogId: widget.exercise.equipmentCatalogId,
          canonicalName: widget.exercise.equipment,
        ),
    ];

    return LocalizedCatalogEntityNamesBuilder(
      entities: equipment,
      builder: (context, equipmentNames) {
        final swapBadge = DecoratedBox(
          decoration: BoxDecoration(
            color:
                expressive?.planAccent ??
                theme.colorScheme.primaryContainer.withValues(
                  alpha: surfaces.planSwapBadgeOpacity,
                ),
            borderRadius: shapes.pill,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              strings.premadeProfileSwap,
              style: theme.textTheme.labelSmall?.copyWith(
                color:
                    expressive?.planAccentForeground ??
                    theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );

        if (expressive != null) {
          final normalizedName = displayName.trim().toLowerCase();
          final distinctEquipmentNames = equipmentNames.where((name) {
            final normalizedEquipment = name.trim().toLowerCase();
            return normalizedEquipment.isNotEmpty &&
                !normalizedName.contains(normalizedEquipment);
          });
          final supportingDetails = [
            if (distinctEquipmentNames.isNotEmpty)
              distinctEquipmentNames.join(', '),
            setAndRepDetails,
          ].join(' · ');

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.fitness_center,
                    size: 18,
                    color: expressive.configurationForeground,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: expressive.configurationForeground,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (widget.wasSwapped) ...[
                            const SizedBox(width: 8),
                            swapBadge,
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        supportingDetails,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: expressive.configurationForeground.withValues(
                            alpha: 0.82,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.fitness_center,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: displayName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (equipmentNames.isNotEmpty)
                            TextSpan(
                              text: ' - ${equipmentNames.join(', ')}',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          TextSpan(
                            text:
                                ' - ${LocalizedFormatters.number(widget.exercise.sets, locale, maximumFractionDigits: 0)}'
                                ' x ${LocalizedFormatters.number(widget.exercise.reps, locale, maximumFractionDigits: 0)}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.wasSwapped) swapBadge,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _localeKeyFor(Locale locale) =>
      '${locale.languageCode}|${locale.scriptCode}|${locale.countryCode}';
}
