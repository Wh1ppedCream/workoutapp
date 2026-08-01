// File: lib/screens/exercise/exercise_catalog_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/selected_profile.dart';
import '../../repositories/app_repository.dart';
import '../../services/exercise_equipment_compatibility.dart';
import '../../services/tutorial_state_store.dart';
import '../../utils/tutorial_launcher.dart';
import '../../widgets/exercise_detail_sheet.dart';
import '../../widgets/exercise_media_thumbnail.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/onboarding_plan_builder_coach.dart';

/// Catalog of exercise definitions with profile-aware equipment filtering.
///
/// This page is used both as a normal browser and as a picker by flows such as
/// Swap Exercise. When [onExercisePicked] is provided, tapping a definition
/// returns it to the caller instead of only opening details.
class ExerciseCatalogPage extends StatefulWidget {
  final void Function(ExerciseDefinition)? onExercisePicked;
  final bool showPlanBuilderGuide;
  final ValueChanged<bool>? onPlanBuilderSelectionChanged;
  final VoidCallback? onPlanBuilderExerciseAdded;
  final VoidCallback? onPlanBuilderGuideSkipped;

  const ExerciseCatalogPage({
    super.key,
    this.onExercisePicked,
    this.showPlanBuilderGuide = false,
    this.onPlanBuilderSelectionChanged,
    this.onPlanBuilderExerciseAdded,
    this.onPlanBuilderGuideSkipped,
  });

  @override
  State<ExerciseCatalogPage> createState() => _ExerciseCatalogPageState();
}

class _ExerciseCatalogPageState extends State<ExerciseCatalogPage> {
  static const _allFilter = '__all__';
  AppRepository get _repo => context.read<AppRepository>();
  final _searchTutorialKey = GlobalKey(debugLabel: 'exercise_catalog_search');
  final _filterTutorialKey = GlobalKey(debugLabel: 'exercise_catalog_filter');
  final _listTutorialKey = GlobalKey(debugLabel: 'exercise_catalog_list');
  final _catalogAddTutorialKey = GlobalKey(
    debugLabel: 'exercise_catalog_add_selection',
  );
  Timer? _searchDebounce;

  /// Incremented before each async filter pass so stale results cannot replace
  /// newer filter/search choices.
  int _filterGeneration = 0;

  // All loaded definitions (fully detailed)
  List<ExerciseDefinition> _allDefs = [];
  List<ExerciseDefinition> _displayedDefs = [];
  bool _isLoading = true;

  // Search query
  String _searchQuery = '';

  // Filter dialog state
  bool _useProfileFilter = true;
  int? _dialogProfileId;
  String _filterEquipment = _allFilter;
  String _filterArea = _allFilter;
  String _filterMuscle = _allFilter;

  // Dropdown options
  List<GymProfile> _profiles = [];
  List<String> _equipmentOptions = [_allFilter];
  List<String> _areaOptions = [_allFilter];
  List<String> _muscleOptions = [_allFilter];
  List<String>? _allEquipmentNames;
  final Map<int, List<String>> _equipmentNamesByProfileId = {};

  ExerciseDefinition? _selectedDef;
  bool _tutorialQueued = false;
  bool _planBuilderGuideSkipped = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  /// Loads catalog definitions plus the filter option lists needed by the page.
  Future<void> _loadInitialData() async {
    // Capture context-synced values before any awaits.
    final sel = context.read<SelectedProfile>();
    final initialProfileId = sel.currentProfile?.id;
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final definitionsFuture = _repo.lookupDefsDetailed();
    final profilesFuture = _repo.dbHelper.fetchAllProfiles();
    final areasFuture = _repo.fetchAllBodyParts();
    final musclesFuture = _repo.fetchAllMuscles();
    final equipmentFuture =
        _useProfileFilter && initialProfileId != null
            ? _equipmentForProfile(initialProfileId)
            : _allEquipment();

    final definitions = await definitionsFuture;
    _allDefs = definitions;
    _displayedDefs = List.from(_allDefs);
    // Load profiles list
    _profiles = await profilesFuture;
    _dialogProfileId = initialProfileId;

    // Load body-part, muscle, and equipment options
    final areas = await areasFuture;
    final muscles = await musclesFuture;

    // Figure out initial equipment list
    final initialEquipment = await equipmentFuture;
    // only that profile’s gear
    // Equipment names are loaded through the cached future above.

    if (!mounted) return;
    setState(() {
      _areaOptions = [_allFilter, ...areas.map((b) => b.name)];
      _muscleOptions = [_allFilter, ...muscles.map((m) => m.name)];
      _equipmentOptions = [_allFilter, ...initialEquipment];
      _displayedDefs = List.from(_allDefs); // show all until they hit “Save”
      _isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
  }

  void _queueTutorial() {
    if (widget.showPlanBuilderGuide) return;
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  void _skipPlanBuilderGuide() {
    setState(() => _planBuilderGuideSkipped = true);
    widget.onPlanBuilderGuideSkipped?.call();
  }

  InteractiveTutorialStep? _planBuilderGuideStep() {
    if (!widget.showPlanBuilderGuide || _planBuilderGuideSkipped) return null;
    if (_selectedDef == null) {
      return InteractiveTutorialStep(
        targetKey: _listTutorialKey,
        stepNumber: 3,
        totalSteps: 8,
        icon: Icons.touch_app_outlined,
        title: AppLocalizations.of(context).catalogGuideChooseTitle,
        body: AppLocalizations.of(context).catalogGuideChooseBody,
      );
    }
    return InteractiveTutorialStep(
      targetKey: _catalogAddTutorialKey,
      stepNumber: 4,
      totalSteps: 8,
      icon: Icons.add_circle_outline,
      title: AppLocalizations.of(context).catalogGuideAddTitle,
      body: AppLocalizations.of(
        context,
      ).catalogGuideAddBody(_selectedDef!.name),
    );
  }

  Future<void> _showTutorial() async {
    try {
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.exerciseCatalog,
        steps: [
          GuidedTutorialStep(
            targetKey: _searchTutorialKey,
            icon: Icons.search,
            title: AppLocalizations.of(context).catalogGuideSearchTitle,
            body: AppLocalizations.of(context).catalogGuideSearchBody,
          ),
          GuidedTutorialStep(
            targetKey: _filterTutorialKey,
            icon: Icons.filter_list,
            title: AppLocalizations.of(context).catalogFilters,
            body: AppLocalizations.of(context).catalogGuideFiltersBody,
          ),
          GuidedTutorialStep(
            targetKey: _listTutorialKey,
            icon: Icons.accessibility_new,
            title: AppLocalizations.of(context).catalogGuideRowsTitle,
            body: AppLocalizations.of(context).catalogGuideRowsBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  Future<List<String>> _allEquipment() async {
    final cached = _allEquipmentNames;
    if (cached != null) return cached;
    final names = await _repo.fetchAllEquipmentNames();
    _allEquipmentNames = names;
    return names;
  }

  Future<List<String>> _equipmentForProfile(int profileId) async {
    final cached = _equipmentNamesByProfileId[profileId];
    if (cached != null) return cached;
    final eqMaps = await _repo.dbHelper.fetchEquipmentForProfile(profileId);
    final names = eqMaps.map((e) => e['name'] as String).toList();
    _equipmentNamesByProfileId[profileId] = names;
    return names;
  }

  /// Applies profile, equipment, bodypart, muscle, and text filters in one pass.
  Future<void> _applyAllFilters({bool showLoading = true}) async {
    final generation = ++_filterGeneration;
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }
    List<ExerciseDefinition> filtered = List.from(_allDefs);
    List<String> nextEquipmentOptions;

    // 1) Workspace profile subset-of filter
    if (_useProfileFilter && _dialogProfileId != null) {
      final allowedList = await _equipmentForProfile(_dialogProfileId!);
      if (generation != _filterGeneration || !mounted) return;
      filtered =
          filtered.where((d) {
            return ExerciseEquipmentCompatibility.fitsProfileNames(
              d,
              allowedList,
            );
          }).toList();
      nextEquipmentOptions = [_allFilter, ...allowedList];
    } else {
      // Profile off: use global equipment list
      final allEq = await _allEquipment();
      if (generation != _filterGeneration || !mounted) return;
      nextEquipmentOptions = [_allFilter, ...allEq];
    }
    final equipmentFilter =
        nextEquipmentOptions.contains(_filterEquipment)
            ? _filterEquipment
            : _allFilter;

    // 2) Single-equipment any-of filter
    if (equipmentFilter != _allFilter) {
      filtered =
          filtered
              .where(
                (d) => ExerciseEquipmentCompatibility.usesEquipmentName(
                  d,
                  equipmentFilter,
                ),
              )
              .toList();
    }

    // 3) Area of Focus filter
    if (_filterArea != _allFilter) {
      filtered =
          filtered
              .where((d) => d.bodyParts.any((bp) => bp.name == _filterArea))
              .toList();
    }

    // 4) Specific Muscle filter
    if (_filterMuscle != _allFilter) {
      filtered =
          filtered
              .where(
                (d) => d.muscles.any((rm) => rm.muscle.name == _filterMuscle),
              )
              .toList();
    }

    // 5) Search filter
    final q = _searchQuery.toLowerCase();
    filtered =
        filtered
            .where((d) => q.isEmpty || d.name.toLowerCase().contains(q))
            .toList();

    if (generation != _filterGeneration || !mounted) return;
    setState(() {
      _filterEquipment = equipmentFilter;
      _equipmentOptions = nextEquipmentOptions;
      _displayedDefs = filtered;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String q) {
    setState(() {
      _searchQuery = q;
    });
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _applyAllFilters(showLoading: false);
    });
  }

  void _openFilterDialog() {
    final strings = AppLocalizations.of(context);
    // Dialog local copies
    bool useProfile = _useProfileFilter;
    int? chosenProfile = _dialogProfileId;
    String eq = _filterEquipment;
    String area = _filterArea;
    String muscle = _filterMuscle;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setDialogState) => AlertDialog(
                  title: Text(strings.catalogSelectedFilters),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SwitchListTile(
                          title: Text(strings.catalogUseWorkspaceProfile),
                          value: useProfile,
                          onChanged:
                              (v) => setDialogState(() => useProfile = v),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: strings.catalogWorkspaceProfile,
                          ),
                          value: chosenProfile,
                          items:
                              _profiles
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p.id!,
                                      child: Text(
                                        p.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              useProfile
                                  ? (v) =>
                                      setDialogState(() => chosenProfile = v)
                                  : null,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: strings.catalogEquipment,
                          ),
                          value: eq,
                          items:
                              _equipmentOptions
                                  .map(
                                    (name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(
                                        name == _allFilter
                                            ? strings.commonAll
                                            : name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setDialogState(() => eq = v!),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: strings.catalogFocusArea,
                          ),
                          value: area,
                          items:
                              _areaOptions
                                  .map(
                                    (name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(
                                        name == _allFilter
                                            ? strings.commonAll
                                            : name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setDialogState(() => area = v!),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: strings.catalogSpecificMuscle,
                          ),
                          value: muscle,
                          items:
                              _muscleOptions
                                  .map(
                                    (name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(
                                        name == _allFilter
                                            ? strings.commonAll
                                            : name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setDialogState(() => muscle = v!),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(strings.commonCancel),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _useProfileFilter = useProfile;
                          _dialogProfileId = chosenProfile;
                          _filterEquipment = eq;
                          _filterArea = area;
                          _filterMuscle = muscle;
                        });
                        Navigator.of(ctx).pop();
                        _applyAllFilters();
                      },
                      child: Text(strings.commonSave),
                    ),
                  ],
                ),
          ),
    );
  }

  void _openExerciseDetails(ExerciseDefinition def) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExerciseDetailSheet(definition: def, defId: def.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planBuilderGuideStep = _planBuilderGuideStep();
    final strings = AppLocalizations.of(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(strings.catalogPageTitle),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: KeyedSubtree(
                        key: _searchTutorialKey,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: strings.catalogSearchExercises,
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: KeyedSubtree(
                          key: _filterTutorialKey,
                          child: ElevatedButton(
                            onPressed: _openFilterDialog,
                            child: FittedBox(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.filter_list),
                                  SizedBox(width: 6),
                                  Text(strings.catalogFilters),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: KeyedSubtree(
                    key: _listTutorialKey,
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _displayedDefs.isEmpty
                            ? Center(child: Text(strings.catalogNoMatches))
                            : ListView.builder(
                              itemCount: _displayedDefs.length,
                              itemBuilder: (_, i) {
                                final def = _displayedDefs[i];
                                return _ExerciseCatalogBar(
                                  definition: def,
                                  selected:
                                      widget.onExercisePicked != null &&
                                      _selectedDef == def,
                                  onTap:
                                      widget.onExercisePicked == null
                                          ? null
                                          : () {
                                            setState(() => _selectedDef = def);
                                            widget.onPlanBuilderSelectionChanged
                                                ?.call(true);
                                          },
                                  onHeatmapTap: () => _openExerciseDetails(def),
                                );
                              },
                            ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton:
              widget.onExercisePicked != null && _selectedDef != null
                  ? KeyedSubtree(
                    key: _catalogAddTutorialKey,
                    child: FloatingActionButton(
                      child: const Icon(Icons.add),
                      onPressed: () {
                        final picked = _selectedDef!;
                        widget.onPlanBuilderExerciseAdded?.call();
                        widget.onExercisePicked!(picked);
                        Navigator.of(context).pop(picked);
                      },
                    ),
                  )
                  : null,
        ),
        if (planBuilderGuideStep != null)
          InteractiveTutorialOverlay(
            step: planBuilderGuideStep,
            onSkip: _skipPlanBuilderGuide,
          ),
      ],
    );
  }
}

class _ExerciseCatalogBar extends StatelessWidget {
  final ExerciseDefinition definition;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback onHeatmapTap;

  const _ExerciseCatalogBar({
    required this.definition,
    required this.selected,
    required this.onTap,
    required this.onHeatmapTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final equipmentText = definition.equipmentList
        .map((equipment) => equipment.name)
        .where((name) => name.trim().isNotEmpty)
        .join(', ');
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      color:
          selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.45)
              : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      definition.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (equipmentText.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        equipmentText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ExerciseInfoMediaButton(
                definition: definition,
                onTap: onHeatmapTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseInfoMediaButton extends StatelessWidget {
  final ExerciseDefinition definition;
  final VoidCallback onTap;

  const _ExerciseInfoMediaButton({
    required this.definition,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).catalogOpenExerciseInfo,
      child: ExerciseMediaThumbnail(
        definition: definition,
        size: 64,
        borderRadius: BorderRadius.circular(12),
        padding: EdgeInsets.zero,
        framed: false,
        onTap: onTap,
      ),
    );
  }
}
