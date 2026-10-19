// File: lib/screens/exercise/exercise_catalog_page.dart

import 'dart:async';
import 'dart:math' as math;

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
  final _searchController = TextEditingController();
  final _resultsScrollController = ScrollController();
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
  bool _filtersApplied = false;
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
    _searchController.dispose();
    _resultsScrollController.dispose();
    super.dispose();
  }

  bool get _usesExpressiveCatalog =>
      widget.expressiveCatalogPresentation &&
      context.usesExpressivePresentation;

  bool get _hasActiveFilters =>
      (!_usesExpressiveCatalog || _filtersApplied) &&
      ((_useProfileFilter && _dialogProfileId != null) ||
          _filterEquipment != _allFilter ||
          _filterArea != _allFilter ||
          _filterMuscle != _allFilter);

  int get _activeFilterCount => !_hasActiveFilters
      ? 0
      : (_useProfileFilter && _dialogProfileId != null ? 1 : 0) +
            (_filterEquipment != _allFilter ? 1 : 0) +
            (_filterArea != _allFilter ? 1 : 0) +
            (_filterMuscle != _allFilter ? 1 : 0);

  void _resetResultsToStart() {
    if (!_usesExpressiveCatalog) return;
    if (_resultsScrollController.hasClients &&
        _resultsScrollController.position.pixels != 0) {
      _resultsScrollController.jumpTo(0);
    }
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
    if ((!_usesExpressiveCatalog || _filtersApplied) &&
        _useProfileFilter &&
        _dialogProfileId != null) {
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
    final q = _searchQuery.trim().toLowerCase();
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
    final searchMeaningfullyChanged =
        q.trim().toLowerCase() != _searchQuery.trim().toLowerCase();
    if (searchMeaningfullyChanged) _resetResultsToStart();
    setState(() {
      _searchQuery = q;
    });
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _applyAllFilters(showLoading: false);
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    if (_searchQuery.isNotEmpty || _searchController.text.isNotEmpty) {
      _resetResultsToStart();
    }
    _searchController.clear();
    setState(() => _searchQuery = '');
    unawaited(_applyAllFilters(showLoading: false));
  }

  void _resetFilters() {
    final filtersWereApplied = _hasActiveFilters;
    if (filtersWereApplied) _resetResultsToStart();
    if (_usesExpressiveCatalog) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    _searchDebounce?.cancel();
    setState(() {
      _useProfileFilter = false;
      _filtersApplied = false;
      _dialogProfileId = null;
      _filterEquipment = _allFilter;
      _filterArea = _allFilter;
      _filterMuscle = _allFilter;
    });
    unawaited(_applyAllFilters(showLoading: false));
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
    if (usesExpressive) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    final expressiveTokens =
        destination ??
        AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.catalog,
          theme.brightness,
        );
    final isDarkNeo = usesInkRecipe && theme.brightness == Brightness.dark;
    final expressiveFieldSurface = usesExpressive
        ? theme.colorScheme.surfaceContainerHighest
        : surfaces.settingsInput;
    final fieldForeground = usesInkRecipe
        ? tonosForegroundForSurface(context, surfaces.settingsInput)
        : usesExpressive
        ? theme.colorScheme.onSurface
        : null;
    final fieldTextStyle = usesInkRecipe || usesExpressive
        ? (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
            color: fieldForeground,
          )
        : null;
    final filterMenuSurface = usesExpressive
        ? theme.colorScheme.surfaceContainerHigh
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

    Widget filterMenuOption(
      Widget child, {
      required bool selected,
      bool addBottomPadding = false,
    }) {
      if (!usesExpressive) {
        return filterMenuTextStyle == null
            ? child
            : DefaultTextStyle.merge(style: filterMenuTextStyle, child: child);
      }
      final foreground = selected
          ? expressiveTokens.onSurfaceSelected
          : theme.colorScheme.onSurface;
      final option = Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: selected
            ? BoxDecoration(
                color: expressiveTokens.surfaceSelected,
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: Row(
          children: [
            Expanded(
              child: DefaultTextStyle.merge(
                style: (theme.textTheme.bodyLarge ?? const TextStyle())
                    .copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                child: child,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_rounded, size: 18, color: foreground),
            ],
          ],
        ),
      );
      return addBottomPadding
          ? Padding(padding: const EdgeInsets.only(bottom: 4), child: option)
          : option;
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
      isDense: usesExpressive,
      contentPadding: usesExpressive
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 11)
          : null,
      border: usesExpressive
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 0.8,
              ),
            )
          : null,
      enabledBorder: usesExpressive
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 0.8,
              ),
            )
          : null,
      focusedBorder: usesExpressive
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: expressiveTokens.outlineAccent,
                width: 1.5,
              ),
            )
          : null,
    );

    // Dialog local copies
    bool useProfile = _useProfileFilter;
    int? chosenProfile = _dialogProfileId;
    String eq = _filterEquipment;
    String area = _filterArea;
    String muscle = _filterMuscle;
    List<Equipment> dialogEquipmentOptions = _equipmentOptions;

    void saveFilters(BuildContext dialogContext) {
      final filtersChanged =
          !_filtersApplied ||
          _useProfileFilter != useProfile ||
          _dialogProfileId != chosenProfile ||
          _filterEquipment != eq ||
          _filterArea != area ||
          _filterMuscle != muscle;
      setState(() {
        _useProfileFilter = useProfile;
        _filtersApplied = true;
        _dialogProfileId = chosenProfile;
        _filterEquipment = eq;
        _filterArea = area;
        _filterMuscle = muscle;
      });
      Navigator.of(dialogContext).pop();
      if (filtersChanged) _resetResultsToStart();
      _applyAllFilters();
    }

    Future<void> resetDraftFilters(
      BuildContext dialogContext,
      StateSetter setDialogState,
    ) async {
      setDialogState(() {
        useProfile = false;
        chosenProfile = null;
        eq = _allFilter;
        area = _allFilter;
        muscle = _allFilter;
      });
      final allEquipment = await _allEquipment();
      if (!dialogContext.mounted) return;
      setDialogState(() => dialogEquipmentOptions = allEquipment);
    }

    Future<void> updateProfileFilter(
      BuildContext dialogContext,
      StateSetter setDialogState,
      bool enabled,
    ) async {
      setDialogState(() => useProfile = enabled);
      final nextEquipment = enabled && chosenProfile != null
          ? await _equipmentForProfile(chosenProfile!)
          : await _allEquipment();
      if (!dialogContext.mounted) return;
      setDialogState(() {
        dialogEquipmentOptions = nextEquipment;
        if (!nextEquipment.any((item) => item.name == eq)) {
          eq = _allFilter;
        }
      });
    }

    Future<void> updateChosenProfile(
      BuildContext dialogContext,
      StateSetter setDialogState,
      int? profileId,
    ) async {
      setDialogState(() => chosenProfile = profileId);
      final nextEquipment = profileId == null
          ? await _allEquipment()
          : await _equipmentForProfile(profileId);
      if (!dialogContext.mounted) return;
      setDialogState(() {
        dialogEquipmentOptions = nextEquipment;
        if (!nextEquipment.any((item) => item.name == eq)) {
          eq = _allFilter;
        }
      });
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
            padding: const EdgeInsets.only(left: 2, bottom: 3),
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
          final mediaQuery = MediaQuery.of(ctx);
          final screenSize = mediaQuery.size;
          final availableMenuHeight = math.max(
            0.0,
            screenSize.height -
                mediaQuery.padding.vertical -
                mediaQuery.viewInsets.vertical -
                24,
          );
          final preferredMenuHeight = (56 * 5 * mediaQuery.textScaler.scale(1))
              .clamp(240.0, 440.0)
              .toDouble();
          final filterMenuMaxHeight = usesExpressive
              ? math.min(availableMenuHeight, preferredMenuHeight)
              : null;
          final filterMenuBorderRadius = usesExpressive
              ? BorderRadius.circular(20)
              : null;
          final profileField = DropdownButtonFormField<int>(
            isExpanded: true,
            itemHeight: usesExpressive ? null : kMinInteractiveDimension,
            menuMaxHeight: filterMenuMaxHeight,
            borderRadius: filterMenuBorderRadius,
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
                    child: filterMenuOption(
                      filterText(p.name, null),
                      selected: p.id == chosenProfile,
                    ),
                  ),
                )
                .toList(),
            selectedItemBuilder: (_) => _profiles
                .map((p) => filterText(p.name, fieldTextStyle))
                .toList(),
            onChanged: useProfile
                ? (value) => updateChosenProfile(ctx, setDialogState, value)
                : null,
          );
          final equipmentField = DropdownButtonFormField<String>(
            isExpanded: true,
            itemHeight: usesExpressive ? null : kMinInteractiveDimension,
            menuMaxHeight: filterMenuMaxHeight,
            borderRadius: filterMenuBorderRadius,
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
                child: filterMenuOption(
                  filterText(strings.commonAll, null),
                  selected: eq == _allFilter,
                  addBottomPadding: true,
                ),
              ),
              ...dialogEquipmentOptions.map(
                (equipment) => DropdownMenuItem<String>(
                  value: equipment.name,
                  child: filterMenuOption(
                    localizedFilterName(
                      CatalogEntityDisplayName(
                        catalogId: equipment.catalogId,
                        canonicalName: equipment.name,
                      ),
                      null,
                    ),
                    selected: eq == equipment.name,
                    addBottomPadding: true,
                  ),
                ),
              ),
            ],
            selectedItemBuilder: (_) => [
              filterText(strings.commonAll, fieldTextStyle),
              ...dialogEquipmentOptions.map(
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
            menuMaxHeight: filterMenuMaxHeight,
            borderRadius: filterMenuBorderRadius,
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
                    child: filterMenuOption(
                      filterText(
                        name == _allFilter
                            ? strings.commonAll
                            : localizedBodyPartName(context, name),
                        null,
                      ),
                      selected: area == name,
                      addBottomPadding: true,
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
            menuMaxHeight: filterMenuMaxHeight,
            borderRadius: filterMenuBorderRadius,
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
                child: filterMenuOption(
                  filterText(strings.commonAll, null),
                  selected: muscle == _allFilter,
                  addBottomPadding: true,
                ),
              ),
              ..._muscleOptions.map(
                (item) => DropdownMenuItem<String>(
                  value: item.name,
                  child: filterMenuOption(
                    localizedFilterName(
                      CatalogEntityDisplayName(
                        catalogId: item.catalogId,
                        canonicalName: item.name,
                      ),
                      null,
                    ),
                    selected: muscle == item.name,
                    addBottomPadding: true,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  title: Text(strings.catalogUseWorkspaceProfile),
                  subtitle: Text(
                    usesExpressive
                        ? strings.catalogExpressiveWorkspaceProfileDescription
                        : strings.catalogWorkspaceProfileDescription,
                  ),
                  value: useProfile,
                  onChanged: (value) =>
                      updateProfileFilter(ctx, setDialogState, value),
                ),
                if (useProfile) ...[
                  const SizedBox(height: 4),
                  expressiveSelector(
                    strings.catalogWorkspaceProfile,
                    profileField,
                    foreground: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
                const SizedBox(height: 2),
                Divider(color: theme.colorScheme.outlineVariant, height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.filter_alt_outlined,
                      size: 18,
                      color: expressiveTokens.outlineAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.catalogExpressiveFiltersCombined,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                expressiveSelector(
                  strings.catalogEquipment,
                  equipmentField,
                  foreground: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 6),
                expressiveSelector(
                  strings.catalogBodyPartFilter,
                  areaField,
                  foreground: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 6),
                expressiveSelector(
                  strings.catalogMuscleFilter,
                  muscleField,
                  foreground: theme.colorScheme.onSurfaceVariant,
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
                  strings.catalogFilters,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          );
          final hasDraftFilters =
              useProfile ||
              eq != _allFilter ||
              area != _allFilter ||
              muscle != _allFilter;
          final expressiveActions = Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(strings.commonCancel),
              ),
              if (hasDraftFilters)
                TextButton(
                  key: const ValueKey('expressive-catalog-reset-all'),
                  onPressed: () =>
                      unawaited(resetDraftFilters(ctx, setDialogState)),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                  child: Text(strings.catalogResetAllFilters),
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
                child: Text(strings.catalogApplyFilters),
              ),
            ],
          );
          final usableDialogHeight = math.max(
            0.0,
            screenSize.height -
                mediaQuery.padding.vertical -
                mediaQuery.viewInsets.vertical -
                24,
          );
          final maxDialogHeight = math
              .min(usableDialogHeight, screenSize.height * 0.84)
              .toDouble();
          return TonosDialogFrame(
            styleFormControls: true,
            child: usesExpressive
                ? Dialog(
                    key: const ValueKey('expressive-catalog-filter-surface'),
                    insetPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                        width: 0.8,
                      ),
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
                        maxHeight: maxDialogHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            expressiveTitle,
                            const SizedBox(height: 8),
                            Flexible(child: expressiveFilterContent),
                            const SizedBox(height: 3),
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
      catalogBrowserDetailRefinement:
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
            centerTitle: !usesExpressive,
            backgroundColor: destination?.pageCanvas,
            foregroundColor: destination?.supportingForeground,
            surfaceTintColor: destination?.pageCanvas,
            elevation: usesExpressive ? 0 : null,
            scrolledUnderElevation: usesExpressive ? 0 : null,
            titleTextStyle: usesExpressive
                ? theme.textTheme.titleLarge?.copyWith(
                    color: destination!.supportingForeground,
                    fontWeight: FontWeight.w700,
                  )
                : null,
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
                    searchController: _searchController,
                    clearSearchLabel: strings.catalogClearSearch,
                    onClearSearch: _clearSearch,
                    onSearchChanged: _onSearchChanged,
                    onFilterPressed: _openFilterDialog,
                    searchLabel: strings.catalogSearchExercises,
                    filterLabel: strings.catalogFilters,
                    filterActive: _hasActiveFilters,
                    activeFilterCount: _activeFilterCount,
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
      if (usesExpressive) {
        final hasQuery = _searchQuery.trim().isNotEmpty;
        final hasFilters = _hasActiveFilters;
        if (_allDefs.isEmpty) {
          return _buildExpressiveEmptyState(
            title: strings.catalogNoExercisesAvailable,
            body: strings.catalogNoExercisesAvailableBody,
            onClearSearch: hasQuery ? _clearSearch : null,
            onResetFilters: hasFilters ? _resetFilters : null,
          );
        }

        return _buildExpressiveEmptyState(
          title: hasFilters && hasQuery
              ? strings.catalogNoCombinedMatches
              : hasFilters
              ? strings.catalogNoFilteredMatches
              : strings.catalogNoSearchMatches,
          body: hasQuery && hasFilters
              ? strings.catalogNoCombinedMatchesBody
              : hasQuery
              ? strings.catalogNoSearchMatchesBody
              : strings.catalogNoFilteredMatchesBody,
          onClearSearch: hasQuery ? _clearSearch : null,
          onResetFilters: hasFilters ? _resetFilters : null,
          onEditFilters: hasFilters ? _openFilterDialog : null,
        );
      }
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
      controller: _resultsScrollController,
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

  Widget _buildExpressiveEmptyState({
    required String title,
    required String body,
    VoidCallback? onClearSearch,
    VoidCallback? onResetFilters,
    VoidCallback? onEditFilters,
  }) {
    final tokens =
        Theme.of(context).extension<AppExpressiveDestinationTokens>() ??
        AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.catalog,
          Theme.of(context).brightness,
        );
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.hasBoundedHeight
            ? (constraints.maxHeight - 16)
                  .clamp(0.0, double.infinity)
                  .toDouble()
            : 0.0;
        final clearSearchIsPrimary =
            onClearSearch != null && onResetFilters == null;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Material(
                  color: tokens.surfaceAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 34,
                          color: tokens.onSurfaceAccent,
                        ),
                        const SizedBox(height: 10),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: tokens.onSurfaceAccent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: tokens.onSurfaceAccent.withValues(
                              alpha: 0.84,
                            ),
                          ),
                        ),
                        if (onClearSearch != null ||
                            onResetFilters != null ||
                            onEditFilters != null) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (onClearSearch != null)
                                clearSearchIsPrimary
                                    ? FilledButton.icon(
                                        onPressed: onClearSearch,
                                        icon: const Icon(Icons.close_rounded),
                                        label: Text(
                                          AppLocalizations.of(context)
                                              .catalogClearSearch,
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: tokens.actionPrimary,
                                          foregroundColor:
                                              tokens.onActionPrimary,
                                          minimumSize: const Size(48, 48),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      )
                                    : OutlinedButton.icon(
                                        onPressed: onClearSearch,
                                        icon: const Icon(Icons.close_rounded),
                                        label: Text(
                                          AppLocalizations.of(context)
                                              .catalogClearSearch,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              tokens.onSurfaceAccent,
                                          minimumSize: const Size(48, 48),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                              if (onEditFilters != null)
                                OutlinedButton.icon(
                                  onPressed: onEditFilters,
                                  icon: const Icon(Icons.tune_rounded),
                                  label: Text(
                                    AppLocalizations.of(context)
                                        .catalogEditFilters,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: tokens.onSurfaceAccent,
                                    side: BorderSide(
                                      color: tokens.outlineAccent.withValues(
                                        alpha: 0.72,
                                      ),
                                    ),
                                    minimumSize: const Size(48, 48),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              if (onResetFilters != null)
                                FilledButton.icon(
                                  onPressed: onResetFilters,
                                  icon: const Icon(Icons.restart_alt_rounded),
                                  label: Text(
                                    AppLocalizations.of(context)
                                        .catalogResetFilters,
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: tokens.actionPrimary,
                                    foregroundColor: tokens.onActionPrimary,
                                    minimumSize: const Size(48, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
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
    required this.searchController,
    required this.clearSearchLabel,
    required this.onClearSearch,
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.searchLabel,
    required this.filterLabel,
    required this.filterActive,
    required this.activeFilterCount,
  });

  final AppExpressiveDestinationTokens destination;
  final Key searchTutorialKey;
  final Key filterTutorialKey;
  final TextEditingController searchController;
  final String clearSearchLabel;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;
  final String searchLabel;
  final String filterLabel;
  final bool filterActive;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final toolbarSurface = Color.lerp(
      destination.surfaceAccent,
      theme.colorScheme.surface,
      isDark ? 0.82 : 0.46,
    )!;
    final fieldSurface = Color.lerp(
      destination.surfaceAccent,
      theme.colorScheme.surface,
      isDark ? 0.60 : 0.82,
    )!;
    return Material(
      color: toolbarSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: KeyedSubtree(
                key: searchTutorialKey,
                child: TextField(
                  controller: searchController,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: destination.onSurfaceAccent,
                  ),
                  decoration: InputDecoration(
                    hintText: searchLabel,
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: onClearSearch,
                            tooltip: clearSearchLabel,
                            style: IconButton.styleFrom(
                              foregroundColor: destination.onSurfaceAccent,
                            ),
                            icon: const Icon(Icons.close_rounded),
                          ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: destination.onSurfaceAccent,
                    ),
                    filled: true,
                    fillColor: fieldSurface,
                    hintStyle: TextStyle(
                      color: destination.onSurfaceAccent.withValues(
                        alpha: 0.72,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
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
                      ? destination.surfaceSelected
                      : fieldSurface,
                  foregroundColor: filterActive
                      ? destination.onSurfaceSelected
                      : destination.onSurfaceAccent,
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: Badge(
                  isLabelVisible: activeFilterCount > 0,
                  alignment: AlignmentDirectional.topEnd,
                  offset: const Offset(8, -8),
                  backgroundColor: destination.actionPrimary,
                  textColor: destination.onActionPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 1,
                  ),
                  textStyle: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                  label: Text('$activeFilterCount'),
                  child: const Icon(Icons.filter_list),
                ),
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
    final allEquipmentItems = definition.equipmentList
        .where((item) => item.name.trim().isNotEmpty)
        .toList(growable: false);
    final primaryEquipment = allEquipmentItems
        .where((item) => item.id == definition.equipmentId)
        .toList(growable: false);
    final otherEquipment = allEquipmentItems
        .where((item) => item.id != definition.equipmentId)
        .toList(growable: false);
    final equipmentItems = usesExpressive
        ? [...primaryEquipment, ...otherEquipment]
        : allEquipmentItems;
    final equipment = equipmentItems
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
          : theme.brightness == Brightness.light
          ? Color.lerp(
              const Color(0xFFAFB5ED),
              expressiveDestination.pageCanvas,
              0.04,
            )!
          : Color.lerp(
              expressiveDestination.surfaceAccent,
              colorScheme.surface,
              0.30,
            )!;
      final rowShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
                  vertical: 8,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (equipment.isNotEmpty) ...[
                const SizedBox(height: 3),
                LocalizedCatalogEntityNamesBuilder(
                  entities: equipment,
                  builder: (context, names) {
                    final label = names.join(', ');
                    final text = Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: usesExpressive
                            ? foreground.withValues(alpha: 0.78)
                            : foregroundSurface == null
                            ? colorScheme.onSurfaceVariant
                            : tonosSecondaryForegroundForSurface(
                                context,
                                foregroundSurface,
                              ),
                      ),
                    );
                    return usesExpressive
                        ? Tooltip(message: label, child: text)
                        : text;
                  },
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
        ? BorderRadius.circular(12)
        : Theme.of(context).shapeTokens.exerciseCatalogMedia;
    Widget media = ExerciseMediaThumbnail(
      definition: definition,
      size: framed ? 60 : 64,
      borderRadius: mediaRadius,
      padding: EdgeInsets.zero,
      framed: false,
      heatmapSurface: heatmapSurface,
      onTap: onTap,
    );
    if (framed) {
      // A consistent neutral frame keeps artwork and fallback heatmaps legible
      // without changing their media loading or tap behavior.
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
