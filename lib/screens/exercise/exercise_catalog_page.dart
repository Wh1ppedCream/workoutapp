// File: lib/screens/exercise/exercise_catalog_page.dart

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/selected_profile.dart';
import '../../repositories/app_repository.dart';
import '../../services/catalog_entity_localizer.dart';
import '../../services/exercise_content_localizer.dart';
import '../../services/exercise_equipment_compatibility.dart';
import '../../services/tutorial_state_store.dart';
import '../../utils/localized_body_part_name.dart';
import '../../utils/tutorial_launcher.dart';
import '../../widgets/exercise_detail_sheet.dart';
import '../../widgets/exercise_media_thumbnail.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/localized_catalog_entity_name.dart';
import '../../widgets/localized_exercise_name.dart';
import '../../widgets/onboarding_plan_builder_coach.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../theme/widgets/tonos_dialog.dart';
import '../../theme/widgets/tonos_expressive_motion.dart';

/// Catalog of exercise definitions with profile-aware equipment filtering.
///
/// This page is used both as a normal browser and as a picker by flows such as
/// Swap Exercise. When [onExercisePicked] is provided, tapping a definition
/// returns it to the caller instead of only opening details.
class ExerciseCatalogPage extends StatefulWidget {
  final void Function(ExerciseDefinition)? onExercisePicked;

  /// Enables the Expressive browser recipe for the Catalog route only.
  ///
  /// This page is also used by workout, plan, and settings pickers, so the
  /// default keeps those callers on their existing presentation.
  final bool expressiveCatalogPresentation;
  final bool showPlanBuilderGuide;
  final ValueChanged<bool>? onPlanBuilderSelectionChanged;
  final VoidCallback? onPlanBuilderExerciseAdded;
  final VoidCallback? onPlanBuilderGuideSkipped;

  const ExerciseCatalogPage({
    super.key,
    this.onExercisePicked,
    this.expressiveCatalogPresentation = false,
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
  List<Equipment> _equipmentOptions = [];
  List<String> _areaOptions = [_allFilter];
  List<Muscle> _muscleOptions = [];
  List<Equipment>? _allEquipmentItems;
  final Map<int, List<Equipment>> _equipmentItemsByProfileId = {};

  ExerciseDefinition? _selectedDef;
  String? _selectedDisplayName;
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
    final equipmentFuture = _useProfileFilter && initialProfileId != null
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
      _muscleOptions = muscles;
      _equipmentOptions = initialEquipment;
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
      body: AppLocalizations.of(context)
          .catalogGuideAddBody(_selectedDisplayName ?? _selectedDef!.name),
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

  Future<List<Equipment>> _allEquipment() async {
    final cached = _allEquipmentItems;
    if (cached != null) return cached;
    final equipment = await _repo.fetchAllEquipment();
    _allEquipmentItems = equipment;
    return equipment;
  }

  Future<List<Equipment>> _equipmentForProfile(int profileId) async {
    final cached = _equipmentItemsByProfileId[profileId];
    if (cached != null) return cached;
    final eqMaps = await _repo.dbHelper.fetchEquipmentForProfile(profileId);
    final equipment = eqMaps
        .map(
          (e) => Equipment(
            e['id'] as int,
            e['name'] as String,
            e['catalog_id'] as String?,
          ),
        )
        .toList();
    _equipmentItemsByProfileId[profileId] = equipment;
    return equipment;
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
    List<Equipment> nextEquipmentOptions;

    // 1) Workspace profile subset-of filter
    if (_useProfileFilter && _dialogProfileId != null) {
      final allowedEquipment = await _equipmentForProfile(_dialogProfileId!);
      if (generation != _filterGeneration || !mounted) return;
      final allowedList = allowedEquipment
          .map((equipment) => equipment.name)
          .toList();
      filtered = filtered.where((d) {
        return ExerciseEquipmentCompatibility.fitsProfileNames(d, allowedList);
      }).toList();
      nextEquipmentOptions = allowedEquipment;
    } else {
      // Profile off: use global equipment list
      final allEq = await _allEquipment();
      if (generation != _filterGeneration || !mounted) return;
      nextEquipmentOptions = allEq;
    }
    final equipmentNames = nextEquipmentOptions
        .map((equipment) => equipment.name)
        .toSet();
    final equipmentFilter = equipmentNames.contains(_filterEquipment)
        ? _filterEquipment
        : _allFilter;

    // 2) Single-equipment any-of filter
    if (equipmentFilter != _allFilter) {
      filtered = filtered
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
      filtered = filtered
          .where((d) => d.bodyParts.any((bp) => bp.name == _filterArea))
          .toList();
    }

    // 4) Specific Muscle filter
    if (_filterMuscle != _allFilter) {
      filtered = filtered
          .where((d) => d.muscles.any((rm) => rm.muscle.name == _filterMuscle))
          .toList();
    }

    // 5) Search filter
    final q = _searchQuery.toLowerCase();
    filtered = filtered
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
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressive =
        widget.expressiveCatalogPresentation &&
        context.usesExpressivePresentation;
    final destination = usesExpressive
        ? theme.extension<AppExpressiveDestinationTokens>() ??
              AppExpressiveDestinationTokens.forFamily(
                AppExpressiveDestinationFamily.catalog,
                theme.brightness,
              )
        : null;
    final expressiveTokens =
        destination ??
        AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.catalog,
          theme.brightness,
        );
    final isDarkNeo = usesInkRecipe && theme.brightness == Brightness.dark;
    final expressiveFieldSurface = usesExpressive
        ? expressiveTokens.surfaceAccent
        : surfaces.settingsInput;
    final fieldForeground = usesInkRecipe
        ? tonosForegroundForSurface(context, surfaces.settingsInput)
        : usesExpressive
        ? expressiveTokens.onSurfaceAccent
        : null;
    final fieldTextStyle = usesInkRecipe || usesExpressive
        ? (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
            color: fieldForeground,
          )
        : null;
    final filterMenuSurface = usesExpressive
        ? expressiveFieldSurface
        : theme.popupMenuTheme.color ?? theme.colorScheme.surfaceContainer;
    final filterMenuTextStyle = isDarkNeo
        ? (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
            color: tonosForegroundForSurface(context, filterMenuSurface),
          )
        : usesExpressive
        ? fieldTextStyle
        : null;

    Widget filterText(String value, TextStyle? style) {
      return Text(
        value,
        maxLines: usesExpressive ? null : 1,
        overflow: usesExpressive ? null : TextOverflow.ellipsis,
        style: style,
      );
    }

    Widget localizedFilterName(
      CatalogEntityDisplayName entity,
      TextStyle? style,
    ) {
      final child = LocalizedCatalogEntityName(
        entity: entity,
        maxLines: usesExpressive ? null : 1,
        overflow: usesExpressive ? null : TextOverflow.ellipsis,
      );
      return style == null
          ? child
          : DefaultTextStyle.merge(style: style, child: child);
    }

    InputDecoration filterFieldDecoration(String label) => InputDecoration(
      labelText: usesExpressive ? null : label,
      filled: usesExpressive,
      fillColor: usesExpressive ? expressiveFieldSurface : null,
      border: usesExpressive
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            )
          : null,
      enabledBorder: usesExpressive
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            )
          : null,
    );

    // Dialog local copies
    bool useProfile = _useProfileFilter;
    int? chosenProfile = _dialogProfileId;
    String eq = _filterEquipment;
    String area = _filterArea;
    String muscle = _filterMuscle;

    void saveFilters(BuildContext dialogContext) {
      setState(() {
        _useProfileFilter = useProfile;
        _dialogProfileId = chosenProfile;
        _filterEquipment = eq;
        _filterArea = area;
        _filterMuscle = muscle;
      });
      Navigator.of(dialogContext).pop();
      _applyAllFilters();
    }

    Widget expressiveSelector(
      String label,
      Widget child, {
      required Color foreground,
    }) {
      if (!usesExpressive) return child;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 4),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          child,
        ],
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final profileField = DropdownButtonFormField<int>(
            isExpanded: true,
            itemHeight: usesExpressive ? null : kMinInteractiveDimension,
            style: fieldTextStyle,
            iconEnabledColor: fieldForeground,
            dropdownColor: usesExpressive || isDarkNeo
                ? filterMenuSurface
                : null,
            decoration: filterFieldDecoration(strings.catalogWorkspaceProfile),
            initialValue: chosenProfile,
            items: _profiles
                .map(
                  (p) => DropdownMenuItem(
                    value: p.id!,
                    child: filterText(p.name, filterMenuTextStyle),
                  ),
                )
                .toList(),
            selectedItemBuilder: (_) => _profiles
                .map((p) => filterText(p.name, fieldTextStyle))
                .toList(),
            onChanged: useProfile
                ? (value) => setDialogState(() => chosenProfile = value)
                : null,
          );
          final equipmentField = DropdownButtonFormField<String>(
            isExpanded: true,
            itemHeight: usesExpressive ? null : kMinInteractiveDimension,
            style: fieldTextStyle,
            iconEnabledColor: fieldForeground,
            dropdownColor: usesExpressive || isDarkNeo
                ? filterMenuSurface
                : null,
            decoration: filterFieldDecoration(strings.catalogEquipment),
            initialValue: eq,
            items: [
              DropdownMenuItem<String>(
                value: _allFilter,
                child: filterText(strings.commonAll, filterMenuTextStyle),
              ),
              ..._equipmentOptions.map(
                (equipment) => DropdownMenuItem<String>(
                  value: equipment.name,
                  child: localizedFilterName(
                    CatalogEntityDisplayName(
                      catalogId: equipment.catalogId,
                      canonicalName: equipment.name,
                    ),
                    filterMenuTextStyle,
                  ),
                ),
              ),
            ],
            selectedItemBuilder: (_) => [
              filterText(strings.commonAll, fieldTextStyle),
              ..._equipmentOptions.map(
                (equipment) => localizedFilterName(
                  CatalogEntityDisplayName(
                    catalogId: equipment.catalogId,
                    canonicalName: equipment.name,
                  ),
                  fieldTextStyle,
                ),
              ),
            ],
            onChanged: (value) => setDialogState(() => eq = value!),
          );
          final areaField = DropdownButtonFormField<String>(
            isExpanded: true,
            itemHeight: usesExpressive ? null : kMinInteractiveDimension,
            style: fieldTextStyle,
            iconEnabledColor: fieldForeground,
            dropdownColor: usesExpressive || isDarkNeo
                ? filterMenuSurface
                : null,
            decoration: filterFieldDecoration(strings.catalogFocusArea),
            initialValue: area,
            items: _areaOptions
                .map(
                  (name) => DropdownMenuItem(
                    value: name,
                    child: filterText(
                      name == _allFilter
                          ? strings.commonAll
                          : localizedBodyPartName(context, name),
                      filterMenuTextStyle,
                    ),
                  ),
                )
                .toList(),
            selectedItemBuilder: (_) => _areaOptions
                .map(
                  (name) => filterText(
                    name == _allFilter
                        ? strings.commonAll
                        : localizedBodyPartName(context, name),
                    fieldTextStyle,
                  ),
                )
                .toList(),
            onChanged: (value) => setDialogState(() => area = value!),
          );
          final muscleField = DropdownButtonFormField<String>(
            isExpanded: true,
            itemHeight: usesExpressive ? null : kMinInteractiveDimension,
            style: fieldTextStyle,
            iconEnabledColor: fieldForeground,
            dropdownColor: usesExpressive || isDarkNeo
                ? filterMenuSurface
                : null,
            decoration: filterFieldDecoration(strings.catalogSpecificMuscle),
            initialValue: muscle,
            items: [
              DropdownMenuItem<String>(
                value: _allFilter,
                child: filterText(strings.commonAll, filterMenuTextStyle),
              ),
              ..._muscleOptions.map(
                (item) => DropdownMenuItem<String>(
                  value: item.name,
                  child: localizedFilterName(
                    CatalogEntityDisplayName(
                      catalogId: item.catalogId,
                      canonicalName: item.name,
                    ),
                    filterMenuTextStyle,
                  ),
                ),
              ),
            ],
            selectedItemBuilder: (_) => [
              filterText(strings.commonAll, fieldTextStyle),
              ..._muscleOptions.map(
                (item) => localizedFilterName(
                  CatalogEntityDisplayName(
                    catalogId: item.catalogId,
                    canonicalName: item.name,
                  ),
                  fieldTextStyle,
                ),
              ),
            ],
            onChanged: (value) => setDialogState(() => muscle = value!),
          );
          final expressiveFilterContent = SingleChildScrollView(
            key: const ValueKey('expressive-catalog-filter-dialog'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: expressiveTokens.surfaceSecondary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(22),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(strings.catalogUseWorkspaceProfile),
                          value: useProfile,
                          onChanged: (value) =>
                              setDialogState(() => useProfile = value),
                        ),
                        const SizedBox(height: 8),
                        expressiveSelector(
                          strings.catalogWorkspaceProfile,
                          profileField,
                          foreground: expressiveTokens.onSurfaceSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: expressiveTokens.surfaceSelected,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(22),
                      bottomLeft: Radius.circular(22),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        expressiveSelector(
                          strings.catalogEquipment,
                          equipmentField,
                          foreground: expressiveTokens.onSurfaceSelected,
                        ),
                        const SizedBox(height: 10),
                        expressiveSelector(
                          strings.catalogFocusArea,
                          areaField,
                          foreground: expressiveTokens.onSurfaceSelected,
                        ),
                        const SizedBox(height: 10),
                        expressiveSelector(
                          strings.catalogSpecificMuscle,
                          muscleField,
                          foreground: expressiveTokens.onSurfaceSelected,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
          final expressiveTitle = Row(
            children: [
              Material(
                color: expressiveTokens.surfaceSelected,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.tune_rounded,
                    color: expressiveTokens.onSurfaceSelected,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  strings.catalogSelectedFilters,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: expressiveTokens.onSurfaceTertiary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          );
          final expressiveActions = Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(strings.commonCancel),
              ),
              FilledButton(
                onPressed: () => saveFilters(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: expressiveTokens.actionPrimary,
                  foregroundColor: expressiveTokens.onActionPrimary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                ),
                child: Text(strings.commonSave),
              ),
            ],
          );
          return TonosDialogFrame(
            styleFormControls: true,
            child: usesExpressive
                ? Dialog(
                    key: const ValueKey('expressive-catalog-filter-surface'),
                    insetPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    backgroundColor: expressiveTokens.surfaceTertiary,
                    surfaceTintColor: expressiveTokens.surfaceTertiary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 520,
                        maxHeight: MediaQuery.sizeOf(ctx).height * 0.82,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            expressiveTitle,
                            const SizedBox(height: 16),
                            Flexible(child: expressiveFilterContent),
                            const SizedBox(height: 8),
                            expressiveActions,
                          ],
                        ),
                      ),
                    ),
                  )
                : AlertDialog(
                    title: Text(strings.catalogSelectedFilters),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SwitchListTile(
                            title: Text(strings.catalogUseWorkspaceProfile),
                            value: useProfile,
                            onChanged: (value) =>
                                setDialogState(() => useProfile = value),
                          ),
                          const SizedBox(height: 8),
                          profileField,
                          const SizedBox(height: 8),
                          equipmentField,
                          const SizedBox(height: 8),
                          areaField,
                          const SizedBox(height: 8),
                          muscleField,
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(strings.commonCancel),
                      ),
                      ElevatedButton(
                        onPressed: () => saveFilters(ctx),
                        child: Text(strings.commonSave),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  void _openExerciseDetails(ExerciseDefinition def) {
    ExerciseDetailSheet.show(
      context: context,
      definition: def,
      defId: def.id,
      expressiveCatalogPresentation:
          widget.expressiveCatalogPresentation &&
          context.usesExpressivePresentation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final planBuilderGuideStep = _planBuilderGuideStep();
    final strings = AppLocalizations.of(context);
    final usesExpressive =
        widget.expressiveCatalogPresentation &&
        context.usesExpressivePresentation;
    final theme = Theme.of(context);
    final destination = usesExpressive
        ? theme.extension<AppExpressiveDestinationTokens>() ??
              AppExpressiveDestinationTokens.forFamily(
                AppExpressiveDestinationFamily.catalog,
                theme.brightness,
              )
        : null;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: destination?.pageCanvas,
          appBar: AppBar(
            title: Text(strings.catalogPageTitle),
            centerTitle: true,
            backgroundColor: destination?.surfacePrimary,
            foregroundColor: destination?.onSurfacePrimary,
            surfaceTintColor: destination?.surfacePrimary,
          ),
          body: Padding(
            padding: EdgeInsets.all(usesExpressive ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (usesExpressive)
                  _ExpressiveCatalogSearchPanel(
                    key: const ValueKey('expressive-catalog-search-panel'),
                    destination: destination!,
                    searchTutorialKey: _searchTutorialKey,
                    filterTutorialKey: _filterTutorialKey,
                    onSearchChanged: _onSearchChanged,
                    onFilterPressed: _openFilterDialog,
                    searchLabel: strings.catalogSearchExercises,
                    filterLabel: strings.catalogFilters,
                    filterActive:
                        _filterEquipment != _allFilter ||
                        _filterArea != _allFilter ||
                        _filterMuscle != _allFilter,
                  )
                else
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
                                    const Icon(Icons.filter_list),
                                    const SizedBox(width: 6),
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
                SizedBox(height: usesExpressive ? 12 : 14),
                Expanded(
                  child: usesExpressive
                      ? KeyedSubtree(
                          key: const ValueKey('expressive-catalog-results'),
                          child: KeyedSubtree(
                            key: _listTutorialKey,
                            child: _buildCatalogResults(
                              strings,
                              usesExpressive: true,
                              destination: destination,
                            ),
                          ),
                        )
                      : KeyedSubtree(
                          key: _listTutorialKey,
                          child: _buildCatalogResults(
                            strings,
                            usesExpressive: false,
                            destination: null,
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
                    tooltip: strings.commonAdd,
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

  Widget _buildCatalogResults(
    AppLocalizations strings, {
    required bool usesExpressive,
    required AppExpressiveDestinationTokens? destination,
  }) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: destination?.outlineAccent),
      );
    }
    if (_displayedDefs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            strings.catalogNoMatches,
            textAlign: TextAlign.center,
            style: usesExpressive
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: destination!.onSurfaceAccent,
                    fontWeight: FontWeight.w700,
                  )
                : null,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _displayedDefs.length,
      itemBuilder: (_, i) {
        final def = _displayedDefs[i];
        return _ExerciseCatalogBar(
          definition: def,
          expressive: usesExpressive,
          destination: destination,
          selected: widget.onExercisePicked != null && _selectedDef == def,
          onTap: widget.onExercisePicked == null
              ? null
              : () async {
                  setState(() {
                    _selectedDef = def;
                    _selectedDisplayName = def.name;
                  });
                  widget.onPlanBuilderSelectionChanged?.call(true);
                  final displayName = await ExerciseContentLocalizer.instance
                      .resolveName(def, Localizations.localeOf(context));
                  if (!mounted || _selectedDef != def) return;
                  setState(() => _selectedDisplayName = displayName);
                },
          onHeatmapTap: () => _openExerciseDetails(def),
        );
      },
    );
  }
}

class _ExpressiveCatalogSearchPanel extends StatelessWidget {
  const _ExpressiveCatalogSearchPanel({
    super.key,
    required this.destination,
    required this.searchTutorialKey,
    required this.filterTutorialKey,
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.searchLabel,
    required this.filterLabel,
    required this.filterActive,
  });

  final AppExpressiveDestinationTokens destination;
  final Key searchTutorialKey;
  final Key filterTutorialKey;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;
  final String searchLabel;
  final String filterLabel;
  final bool filterActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: destination.surfaceAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: KeyedSubtree(
                key: searchTutorialKey,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: searchLabel,
                    prefixIcon: Icon(
                      Icons.search,
                      color: destination.onSurfaceAccent,
                    ),
                    filled: true,
                    fillColor: destination.surfaceSelected,
                    hintStyle: TextStyle(
                      color: destination.onSurfaceSelected.withValues(
                        alpha: 0.72,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(11),
                        bottomLeft: Radius.circular(11),
                        bottomRight: Radius.circular(16),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(11),
                        bottomLeft: Radius.circular(11),
                        bottomRight: Radius.circular(16),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(11),
                        bottomLeft: Radius.circular(11),
                        bottomRight: Radius.circular(16),
                      ),
                      borderSide: BorderSide(
                        color: destination.outlineAccent,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
            ),
            const SizedBox(width: 8),
            KeyedSubtree(
              key: filterTutorialKey,
              child: IconButton.filled(
                isSelected: filterActive,
                tooltip: filterLabel,
                onPressed: onFilterPressed,
                style: IconButton.styleFrom(
                  backgroundColor: filterActive
                      ? destination.surfaceSecondary
                      : destination.actionPrimary,
                  foregroundColor: filterActive
                      ? destination.onSurfaceSecondary
                      : destination.onActionPrimary,
                  minimumSize: const Size(48, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(11),
                      bottomLeft: Radius.circular(11),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
                icon: const Icon(Icons.filter_list),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCatalogBar extends StatelessWidget {
  final ExerciseDefinition definition;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback onHeatmapTap;
  final bool expressive;
  final AppExpressiveDestinationTokens? destination;

  const _ExerciseCatalogBar({
    required this.definition,
    required this.selected,
    required this.onTap,
    required this.onHeatmapTap,
    required this.expressive,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final effects = context.effectTokens;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressive = expressive && context.usesExpressivePresentation;
    final equipment = definition.equipmentList
        .where((item) => item.name.trim().isNotEmpty)
        .map(
          (item) => CatalogEntityDisplayName(
            catalogId: item.catalogId,
            canonicalName: item.name,
          ),
        )
        .toList(growable: false);

    if (usesInkRecipe) {
      final rowSurface = selected
          ? surfaces.settingsHero
          : surfaces.catalogSelection;
      final rowForeground = tonosForegroundForSurface(context, rowSurface);
      final rowBorder = tonosOutlineForSurface(context, rowSurface);
      final rowShape = RoundedRectangleBorder(
        borderRadius: shapes.exerciseCatalogRow,
        side: BorderSide(
          color: selected ? colorScheme.secondary : rowBorder,
          width: selected
              ? shapes.exerciseCatalogSelectedOutlineWidth
              : shapes.outlineWidth,
        ),
      );

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: shapes.exerciseCatalogRow,
          boxShadow: [
            BoxShadow(
              color: effects.cardShadow,
              blurRadius: effects.cardShadowBlur,
              offset: effects.cardShadowOffset,
            ),
          ],
        ),
        child: Material(
          color: rowSurface,
          shape: rowShape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: _buildContent(
                context,
                theme,
                colorScheme,
                equipment,
                rowForeground,
                rowSurface,
                false,
              ),
            ),
          ),
        ),
      );
    }

    if (usesExpressive) {
      final expressiveDestination =
          destination ??
          AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.catalog,
            theme.brightness,
          );
      final rowSurface = selected
          ? expressiveDestination.surfaceSelected
          : expressiveDestination.surfaceAccent;
      final rowShape = RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(28),
        ),
        side: selected
            ? BorderSide(color: expressiveDestination.outlineAccent, width: 2)
            : BorderSide.none,
      );
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: TonosExpressivePressResponse(
          enabled: true,
          pressedScale: TonosExpressiveMotionTiers.supportingScale,
          pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
          child: Material(
            color: rowSurface,
            shape: rowShape,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: _buildContent(
                  context,
                  theme,
                  colorScheme,
                  equipment,
                  selected
                      ? expressiveDestination.onSurfaceSelected
                      : expressiveDestination.onSurfaceAccent,
                  rowSurface,
                  true,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      color: selected ? surfaces.catalogSelection : null,
      shape: RoundedRectangleBorder(
        borderRadius: shapes.exerciseCatalogRow,
        side: BorderSide(
          color: selected ? colorScheme.primary : surfaces.catalogOutline,
          width: selected
              ? shapes.exerciseCatalogSelectedOutlineWidth
              : shapes.outlineWidth,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: _buildContent(
            context,
            theme,
            colorScheme,
            equipment,
            colorScheme.onSurface,
            null,
            false,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    List<CatalogEntityDisplayName> equipment,
    Color foreground,
    Color? foregroundSurface,
    bool usesExpressive,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocalizedExerciseName(
                definition: definition,
                maxLines: usesExpressive ? null : 2,
                overflow: usesExpressive ? null : TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (equipment.isNotEmpty) ...[
                const SizedBox(height: 3),
                LocalizedCatalogEntityNamesBuilder(
                  entities: equipment,
                  builder: (context, names) => Text(
                    names.join(', '),
                    maxLines: usesExpressive ? null : 1,
                    overflow: usesExpressive ? null : TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: foregroundSurface == null
                          ? colorScheme.onSurfaceVariant
                          : tonosSecondaryForegroundForSurface(
                              context,
                              foregroundSurface,
                            ),
                    ),
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
          framed: usesExpressive,
          heatmapSurface: usesExpressive ? null : foregroundSurface,
        ),
      ],
    );
  }
}

class _ExerciseInfoMediaButton extends StatelessWidget {
  final ExerciseDefinition definition;
  final VoidCallback onTap;
  final bool framed;
  final Color? heatmapSurface;

  const _ExerciseInfoMediaButton({
    required this.definition,
    required this.onTap,
    this.framed = false,
    this.heatmapSurface,
  });

  @override
  Widget build(BuildContext context) {
    final mediaRadius = framed
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(18),
          )
        : Theme.of(context).shapeTokens.exerciseCatalogMedia;
    Widget media = ExerciseMediaThumbnail(
      definition: definition,
      size: 64,
      borderRadius: mediaRadius,
      padding: EdgeInsets.zero,
      framed: false,
      heatmapSurface: heatmapSurface,
      onTap: onTap,
    );
    if (framed) {
      // Preserve the artwork's neutral contrast while joining its shape to
      // the row; the separate media outline is intentionally removed.
      media = Material(
        color: context.surfaceTokens.mediaPlaceholder,
        shape: RoundedRectangleBorder(borderRadius: mediaRadius),
        clipBehavior: Clip.antiAlias,
        child: media,
      );
    }
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).catalogOpenExerciseInfo,
      child: media,
    );
  }
}
