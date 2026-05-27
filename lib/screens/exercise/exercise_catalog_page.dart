// File: lib/screens/exercise/exercise_catalog_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/selected_profile.dart';
import '../../repositories/app_repository.dart';
import '../../theme/theme_extensions.dart';
import '../../widgets/body_heatmap.dart';
import '../../widgets/exercise_detail_sheet.dart';

/// Catalog of exercise definitions with profile-aware equipment filtering.
///
/// This page is used both as a normal browser and as a picker by flows such as
/// Swap Exercise. When [onExercisePicked] is provided, tapping a definition
/// returns it to the caller instead of only opening details.
class ExerciseCatalogPage extends StatefulWidget {
  final void Function(ExerciseDefinition)? onExercisePicked;
  const ExerciseCatalogPage({super.key, this.onExercisePicked});

  @override
  State<ExerciseCatalogPage> createState() => _ExerciseCatalogPageState();
}

class _ExerciseCatalogPageState extends State<ExerciseCatalogPage> {
  final _repo = AppRepository();
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
  String _filterEquipment = 'All';
  String _filterArea = 'All';
  String _filterMuscle = 'All';

  // Dropdown options
  List<GymProfile> _profiles = [];
  List<String> _equipmentOptions = ['All'];
  List<String> _areaOptions = ['All'];
  List<String> _muscleOptions = ['All'];
  List<String>? _allEquipmentNames;
  final Map<int, List<String>> _equipmentNamesByProfileId = {};

  ExerciseDefinition? _selectedDef;

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
      _areaOptions = ['All', ...areas.map((b) => b.name)];
      _muscleOptions = ['All', ...muscles.map((m) => m.name)];
      _equipmentOptions = ['All', ...initialEquipment];
      _displayedDefs = List.from(_allDefs); // show all until they hit “Save”
      _isLoading = false;
    });
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
      final allowed = allowedList.toSet();
      filtered =
          filtered.where((d) {
            return d.equipmentList.every((eq) => allowed.contains(eq.name));
          }).toList();
      nextEquipmentOptions = ['All', ...allowedList];
    } else {
      // Profile off: use global equipment list
      final allEq = await _allEquipment();
      if (generation != _filterGeneration || !mounted) return;
      nextEquipmentOptions = ['All', ...allEq];
    }
    final equipmentFilter =
        nextEquipmentOptions.contains(_filterEquipment)
            ? _filterEquipment
            : 'All';

    // 2) Single-equipment any-of filter
    if (equipmentFilter != 'All') {
      filtered =
          filtered
              .where(
                (d) => d.equipmentList.any((eq) => eq.name == equipmentFilter),
              )
              .toList();
    }

    // 3) Area of Focus filter
    if (_filterArea != 'All') {
      filtered =
          filtered
              .where((d) => d.bodyParts.any((bp) => bp.name == _filterArea))
              .toList();
    }

    // 4) Specific Muscle filter
    if (_filterMuscle != 'All') {
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
                  title: const Text('Selected Filters'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SwitchListTile(
                          title: const Text('Use Workspace Profile'),
                          value: useProfile,
                          onChanged:
                              (v) => setDialogState(() => useProfile = v),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Workspace Profile',
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
                          decoration: const InputDecoration(
                            labelText: 'Equipment',
                          ),
                          value: eq,
                          items:
                              _equipmentOptions
                                  .map(
                                    (name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(
                                        name,
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
                          decoration: const InputDecoration(
                            labelText: 'Area of Focus',
                          ),
                          value: area,
                          items:
                              _areaOptions
                                  .map(
                                    (name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(
                                        name,
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
                          decoration: const InputDecoration(
                            labelText: 'Specific Muscle',
                          ),
                          value: muscle,
                          items:
                              _muscleOptions
                                  .map(
                                    (name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(
                                        name,
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
                      child: const Text('Cancel'),
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
                      child: const Text('Save'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Catalog'), centerTitle: true),
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
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Exercises',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _openFilterDialog,
                      child: const FittedBox(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter_list),
                            SizedBox(width: 6),
                            Text('Filters'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _displayedDefs.isEmpty
                      ? const Center(child: Text('No exercises match filters.'))
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
                                    : () => setState(() => _selectedDef = def),
                            onHeatmapTap: () => _openExerciseDetails(def),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          widget.onExercisePicked != null && _selectedDef != null
              ? FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  final picked = _selectedDef!;
                  widget.onExercisePicked!(picked);
                  Navigator.of(context).pop(picked);
                },
              )
              : null,
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
    final bodyPartUnits = {
      for (final bodyPart in definition.bodyParts) bodyPart.name: 1.0,
    };
    final heatmapFrequencyMap = bodyPartFrequencyMapFromNames(bodyPartUnits);

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
              _ExerciseInfoHeatmapButton(
                frequencyMap: heatmapFrequencyMap,
                fallbackBodyParts: definition.bodyParts,
                onTap: onHeatmapTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseInfoHeatmapButton extends StatelessWidget {
  final Map<String, double> frequencyMap;
  final List<BodyPart> fallbackBodyParts;
  final VoidCallback onTap;

  const _ExerciseInfoHeatmapButton({
    required this.frequencyMap,
    required this.fallbackBodyParts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final hasHeatmap = frequencyMap.isNotEmpty;

    return Semantics(
      button: true,
      label: 'Open exercise information',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child:
              hasHeatmap
                  ? BodyHeatmap(
                    frequencyMap: frequencyMap,
                    lowColor: colors.historySummaryHeatmapLow!,
                    highColor: colors.historySummaryHeatmapHigh!,
                    width: 54,
                    height: 54,
                  )
                  : Icon(
                    fallbackBodyParts.isEmpty
                        ? Icons.info_outline
                        : Icons.accessibility_new,
                    color: theme.colorScheme.primary,
                  ),
        ),
      ),
    );
  }
}
