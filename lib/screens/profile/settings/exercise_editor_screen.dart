// file: lib/screens/profile/settings/exercise_editor_screen.dart
// Advanced editor for shared exercise definition data.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/safe_failure_localizations.dart';
import '../../../models/models.dart';
import '../../../repositories/app_repository.dart';
import '../../../services/safe_failure.dart';
import '../../../widgets/settings_tiles.dart';
import '../../../widgets/safe_error_view.dart';
import '../../exercise/exercise_catalog_page.dart';
import 'exercise_analytics_screen.dart';

/// Exercise Editor Screen: allows viewing and editing an exercise definition.
///
/// TODO: Revisit this screen's information hierarchy and editing controls once
/// the wider settings UI has settled, then refine the editor's visual design.
class ExerciseEditorScreen extends StatefulWidget {
  const ExerciseEditorScreen({super.key});

  @override
  State<ExerciseEditorScreen> createState() => _ExerciseEditorScreenState();
}

class _CustomExerciseDraft {
  final String name;
  final int? primaryEquipmentId;

  const _CustomExerciseDraft({
    required this.name,
    required this.primaryEquipmentId,
  });
}

class _ExerciseEditorScreenState extends State<ExerciseEditorScreen>
    with SingleTickerProviderStateMixin {
  AppRepository get _repo => context.read<AppRepository>();
  late final TabController _tabController;
  int _activeTabIndex = 0;
  bool _isEditing = false;
  bool _isSaving = false;

  // Definitions
  List<Equipment> _allEquipment = [];
  ExerciseDefinition? _selectedDef;
  int _definitionLoadRequest = 0;
  bool _isLoadingDefinitions = true;
  bool _isLoadingDetails = false;
  SafeFailure? _loadFailure;
  bool _hasPendingChanges = false;

  // Tab data
  List<Map<String, Object>> _muscleEntries =
      []; // { 'id': int, 'name': String, 'percent': double }

  bool _useManualBody = false;

  // just below `bool _useManualBody = false;`
  bool _useManualMuscles = false;

  // new:
  List<Map<String, Object>> _equipmentEntries =
      []; // { 'id': int, 'name': String }

  List<Map<String, Object>> _bodyAutoEntries = []; // muscle‐calculated values
  List<Map<String, Object>> _bodyManualEntries = []; // manual overrides

  // Notes & media metadata. Remote URLs are durable; local cache paths are optional.
  List<ExerciseMediaItem> _mediaItems = [];

  // Retained for the legacy form kept during this screen's staged migration.
  int _rating = 0;
  bool _multiplyByRating = false;

  late final TextEditingController _setupController;
  late final TextEditingController _executionController;
  late final TextEditingController _tipsController;
  late final TextEditingController _nameController;
  late final TextEditingController _ratingController;
  int? _primaryEquipmentId;

  AppLocalizations get _strings => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupController = TextEditingController();
    _executionController = TextEditingController();
    _tipsController = TextEditingController();
    _nameController = TextEditingController();
    _ratingController = TextEditingController();
    _loadExerciseList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _setupController.dispose();
    _executionController.dispose();
    _tipsController.dispose();
    _nameController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  /// Load all definitions and select the first one
  Future<void> _loadExerciseList() async {
    setState(() {
      _isLoadingDefinitions = true;
      _loadFailure = null;
    });
    try {
      final defsFuture = _repo.lookupDefsDetailed();
      final equipmentFuture = _repo.fetchAllEquipment();
      await defsFuture;
      final equipment = await equipmentFuture;
      if (!mounted) return;
      setState(() {
        _allEquipment = equipment;
        _selectedDef = null;
        _isEditing = false;
        _hasPendingChanges = false;
        _isLoadingDefinitions = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingDefinitions = false;
        _loadFailure = SafeFailure.classify(error);
      });
    }
  }

  /// Handle selecting an exercise definition
  Future<void> _onExerciseSelected(ExerciseDefinition def) async {
    setState(() {
      _selectedDef = def;
      _isEditing = false;
      _hasPendingChanges = false;
      _isLoadingDetails = true;
      _activeTabIndex = 0;
    });
    _tabController.index = 0;
    await _loadDefinitionDetails(def);
  }

  /// Populate muscles, bodyparts, equipment for the selected definition
  Future<void> _loadDefinitionDetails(ExerciseDefinition def) async {
    final request = ++_definitionLoadRequest;
    final defId = def.id;

    try {
      // Start independent reads together so changing exercises does not wait on
      // a long serial chain of database queries.
      final results = await Future.wait<Object>([
        _repo.computeMusclePercents(defId),
        _repo.getUseManualMuscles(defId),
        _repo.computeMuscleCalculatedBodyparts(defId),
        _repo.fetchBodyPartPercentsManual(defId),
        _repo.getUseManualBodyparts(defId),
        _repo.fetchExerciseMedia(defId),
        _repo.getMultiplyByRating(defId),
      ]);

      final musclePercents = results[0] as List<ExerciseMusclePercent>;
      final useManualMuscles = results[1] as bool;
      final autoBpMap = results[2] as Map<BodyPart, double>;
      final manualList = results[3] as List<ExerciseBodyPartPercent>;
      final useManualBody = results[4] as bool;
      final mediaItems = results[5] as List<ExerciseMediaItem>;
      final multiplyByRating = results[6] as bool;

      final manualMap = {for (var e in manualList) e.bodyPartId: e.percent};

      if (!mounted ||
          request != _definitionLoadRequest ||
          _selectedDef?.id != defId) {
        return;
      }

      // Now update all UI state in one batch:
      setState(() {
        // — Toggles
        _useManualBody = useManualBody;
        _useManualMuscles = useManualMuscles;
        _multiplyByRating = multiplyByRating;

        // — Muscles Tab
        _muscleEntries =
            def.muscles.map((rm) {
              final override = musclePercents.firstWhere(
                (e) => e.muscleId == rm.muscle.id,
                orElse:
                    () => ExerciseMusclePercent(
                      exerciseDefId: defId,
                      muscleId: rm.muscle.id,
                      percent: 0.0,
                    ),
              );
              return {
                'id': rm.muscle.id,
                'name': rm.muscle.name,
                'percent': override.percent,
              };
            }).toList();
        // --- Muscle-Calculated Bodyparts ---
        _bodyAutoEntries =
            autoBpMap.entries.map((e) {
              return {'id': e.key.id, 'name': e.key.name, 'count': e.value};
            }).toList();

        // --- Manual-Assigned Bodyparts ---
        _bodyManualEntries =
            def.bodyParts.map((bp) {
              // seed with override if present, else default 1 set per set
              final autoMap = {
                for (var e in autoBpMap.entries) e.key.id: e.value,
              };
              final count = manualMap[bp.id] ?? autoMap[bp.id] ?? 0.0;
              return {'id': bp.id, 'name': bp.name, 'count': count};
            }).toList();

        // Equipment (unchanged)
        _equipmentEntries =
            def.equipmentList.map((e) => {'id': e.id, 'name': e.name}).toList();
        _rating = def.rating;
        _mediaItems = mediaItems;
        _primaryEquipmentId = def.equipmentId;
      });
      // after your setState block…
      _nameController.text = def.name;
      _ratingController.text = def.rating.toString();
      _setupController.text = def.setupNotes;
      _executionController.text = def.executionNotes;
      _tipsController.text = def.tipsNotes;
      if (mounted && request == _definitionLoadRequest) {
        setState(() => _isLoadingDetails = false);
      }
    } catch (error) {
      if (!mounted ||
          request != _definitionLoadRequest ||
          _selectedDef?.id != defId) {
        return;
      }
      setState(() => _isLoadingDetails = false);
      ScaffoldMessenger.of(context).showSnackBar(
        safeFailureSnackBar(
          context,
          error: error,
          summary: _strings.exerciseEditorLoadFailed,
        ),
      );
    }
  }

  void _startEditing() {
    if (_selectedDef == null || _isSaving) return;
    setState(() {
      _isEditing = true;
      _hasPendingChanges = false;
    });
  }

  void _markChanged() {
    if (_isEditing && !_hasPendingChanges) {
      setState(() => _hasPendingChanges = true);
    }
  }

  Future<void> _saveDefinition() async {
    final def = _selectedDef;
    if (def == null || !_isEditing || _isSaving) return;

    final name = _nameController.text.trim();
    final rating = int.tryParse(_ratingController.text.trim());
    if (name.isEmpty) {
      _showMessage('Enter an exercise name before saving.');
      return;
    }
    if (rating == null || rating < 0 || rating > 100) {
      _showMessage('Exercise rating must be a whole number from 0 to 100.');
      return;
    }
    if (_muscleEntries.isEmpty || _bodyManualEntries.isEmpty) {
      _showMessage(
        'Add at least one target muscle and one body part before saving.',
      );
      return;
    }

    final equipmentIds =
        _equipmentEntries.map((entry) => entry['id'] as int).toSet();
    if (_primaryEquipmentId != null) equipmentIds.add(_primaryEquipmentId!);
    final equipmentById = <int, Equipment>{
      for (final equipment in _allEquipment) equipment.id: equipment,
      for (final equipment in def.equipmentList) equipment.id: equipment,
    };
    final equipmentList = <Equipment>[
      for (final id in equipmentIds)
        equipmentById[id] ?? Equipment(id, 'Equipment $id'),
    ];

    setState(() => _isSaving = true);
    try {
      await _repo.saveExerciseDefinitionAtomic(
        ExerciseDefinitionWrite(
          definition: ExerciseDefinition(
            id: def.id,
            catalogId: def.catalogId,
            name: name,
            equipmentId: _primaryEquipmentId,
            rating: rating,
            equipmentList: equipmentList,
            bodyParts:
                _bodyManualEntries
                    .map(
                      (entry) =>
                          BodyPart(entry['id'] as int, entry['name'] as String),
                    )
                    .toList(),
            muscles: [
              for (var index = 0; index < _muscleEntries.length; index++)
                RankedMuscle(
                  muscle: Muscle(
                    id: _muscleEntries[index]['id'] as int,
                    name: _muscleEntries[index]['name'] as String,
                  ),
                  rank: index + 1,
                ),
            ],
            useManualBodyparts: _useManualBody,
            multiplyByRating: _multiplyByRating,
            setupNotes: _setupController.text.trim(),
            executionNotes: _executionController.text.trim(),
            tipsNotes: _tipsController.text.trim(),
            starterLoadProfile: def.starterLoadProfile,
          ),
          useManualMuscles: _useManualMuscles,
          muscleIds: _muscleEntries.map((entry) => entry['id'] as int).toList(),
          musclePercents: {
            for (final entry in _muscleEntries)
              entry['id'] as int: entry['percent'] as double,
          },
          equipmentIds: equipmentIds,
          bodyPartPercents: {
            for (final entry in _bodyManualEntries)
              entry['id'] as int: entry['count'] as double,
          },
          mediaItems: _mediaItems,
        ),
      );

      final refreshedDefinition = await _repo.fetchDefinitionById(def.id);
      if (!mounted || refreshedDefinition == null) return;
      setState(() {
        _selectedDef = refreshedDefinition;
        _isEditing = false;
        _hasPendingChanges = false;
        _isLoadingDetails = true;
      });
      await _loadDefinitionDetails(refreshedDefinition);
      if (mounted) _showMessage('Exercise definition saved.');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          safeFailureSnackBar(
            context,
            error: error,
            summary: _strings.safeFailureSaveTitle,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _cancelEditing() async {
    final def = _selectedDef;
    if (def == null) return;
    if (_hasPendingChanges && !await _confirmDiscard()) return;

    final refreshedDefinition = await _repo.fetchDefinitionById(def.id);
    if (!mounted || refreshedDefinition == null) return;
    setState(() {
      _selectedDef = refreshedDefinition;
      _isEditing = false;
      _hasPendingChanges = false;
      _isLoadingDetails = true;
    });
    await _loadDefinitionDetails(refreshedDefinition);
  }

  Future<bool> _confirmDiscard() async {
    if (!_isEditing || !_hasPendingChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(_strings.exerciseEditorDiscardTitle),
            content: Text(_strings.exerciseEditorDiscardBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(_strings.exerciseEditorKeepEditing),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(_strings.exerciseEditorDiscard),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  Future<void> _handleBack() async {
    if (!await _confirmDiscard() || !mounted) return;
    if (_hasPendingChanges) {
      setState(() => _hasPendingChanges = false);
    }
    Navigator.maybePop(context);
  }

  /// Let the user pick one or more new BodyParts to stage.
  Future<void> _openAddBodypartDialog() async {
    final allBps = await _repo.fetchAllBodyPartsFull(); // List<BodyPart>
    if (!mounted) return;
    final existing = _bodyManualEntries.map((e) => e['id'] as int).toSet();
    final available = allBps.where((bp) => !existing.contains(bp.id)).toList();
    final selectedIds = <int>{};

    final result = await showDialog<Set<int>>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(_strings.exerciseEditorAddBodyparts),
            content: SizedBox(
              width: double.maxFinite,
              child: StatefulBuilder(
                builder: (ctx2, setState2) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: available.length,
                    itemBuilder: (_, i) {
                      final bp = available[i];
                      final checked = selectedIds.contains(bp.id);
                      return CheckboxListTile(
                        title: Text(bp.name),
                        value: checked,
                        onChanged:
                            (on) => setState2(() {
                              if (on == true) {
                                selectedIds.add(bp.id);
                              } else {
                                selectedIds.remove(bp.id);
                              }
                            }),
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(_strings.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(selectedIds),
                child: Text(_strings.commonAdd),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        for (var id in result) {
          final bp = allBps.firstWhere((b) => b.id == id);
          _bodyManualEntries.add({'id': bp.id, 'name': bp.name, 'count': 1.0});
        }
        _hasPendingChanges = true;
      });
    }
  }

  /// Show a dialog of all muscles *not* yet on this exercise,
  /// let the user pick many, and then add them (with 0% default) to the UI list.
  Future<void> _openAddMuscleDialog() async {
    // 1) grab every muscle in the DB
    final allMuscles = await _repo.fetchAllMusclesFull();
    // 2) filter out the ones already staged
    final existingIds = _muscleEntries.map((e) => e['id'] as int).toSet();
    final available =
        allMuscles.where((m) => !existingIds.contains(m.id)).toList();

    // 3) track selections
    final selectedIds = <int>{};

    // 4) show dialog
    if (!mounted) return;
    final result = await showDialog<Set<int>>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(_strings.exerciseEditorAddMuscles),
            content: SizedBox(
              width: double.maxFinite,
              // need StatefulBuilder to update the checkboxes
              child: StatefulBuilder(
                builder: (ctx2, setDialogState) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: available.length,
                    itemBuilder: (ctx3, i) {
                      final m = available[i];
                      final checked = selectedIds.contains(m.id);
                      return CheckboxListTile(
                        title: Text(m.name),
                        value: checked,
                        onChanged: (on) {
                          setDialogState(() {
                            if (on == true) {
                              selectedIds.add(m.id);
                            } else {
                              selectedIds.remove(m.id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text(_strings.commonCancel),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: Text(_strings.commonAdd),
                onPressed: () => Navigator.of(ctx).pop(selectedIds),
              ),
            ],
          ),
    );

    // 5) merge them into the UI list
    if (result != null && result.isNotEmpty) {
      setState(() {
        for (final id in result) {
          final m = allMuscles.firstWhere((muscle) => muscle.id == id);
          _muscleEntries.add(<String, Object>{
            'id': m.id,
            'name': m.name,
            'percent': 0.0,
          });
        }
        _hasPendingChanges = true;
      });
    }
  }

  /// Let the user pick one or more new equipment items to stage.
  Future<void> _openAddEquipmentDialog() async {
    final allEq = await _repo.fetchAllEquipment(); // List<Equipment>
    final existing = _equipmentEntries.map((e) => e['id'] as int).toSet();
    final available = allEq.where((e) => !existing.contains(e.id)).toList();
    final selectedIds = <int>{};

    if (!mounted) return;
    final result = await showDialog<Set<int>>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(_strings.exerciseEditorAddEquipment),
            content: SizedBox(
              width: double.maxFinite,
              child: StatefulBuilder(
                builder: (ctx2, setState2) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: available.length,
                    itemBuilder: (_, i) {
                      final eq = available[i];
                      final checked = selectedIds.contains(eq.id);
                      return CheckboxListTile(
                        title: Text(eq.name),
                        value: checked,
                        onChanged:
                            (on) => setState2(() {
                              if (on == true) {
                                selectedIds.add(eq.id);
                              } else {
                                selectedIds.remove(eq.id);
                              }
                            }),
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(_strings.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(selectedIds),
                child: Text(_strings.commonAdd),
              ),
            ],
          ),
    );

    if (result != null) {
      setState(() {
        for (var id in result) {
          final eq = allEq.firstWhere((e) => e.id == id);
          _equipmentEntries.add({'id': eq.id, 'name': eq.name});
        }
        _hasPendingChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDefinitions) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_loadFailure != null) {
      return Scaffold(
        body: SafeErrorView(
          title: _strings.exerciseEditorLoadFailed,
          failure: _loadFailure!,
          onRetry: _loadExerciseList,
        ),
      );
    }
    final navigator = Navigator.of(context);
    return PopScope<Object?>(
      canPop: !_isEditing || !_hasPendingChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !_isEditing || !_hasPendingChanges) return;
        if (!await _confirmDiscard() || !mounted) return;
        setState(() => _hasPendingChanges = false);
        navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: _strings.commonBack,
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back),
          ),
          title: const SizedBox.shrink(),
          actions: [
            IconButton(
              tooltip: _strings.exerciseEditorChoose,
              icon: const Icon(Icons.search),
              onPressed: _isEditing || _isSaving ? null : _openCatalogPicker,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed:
                  _isSaving
                      ? null
                      : (_selectedDef != null && !_isEditing)
                      ? _startEditing
                      : null,
              tooltip: _strings.exerciseEditorEdit,
            ),
            IconButton(
              tooltip: _strings.exerciseEditorCreate,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _isEditing || _isSaving ? null : _createCustomExercise,
            ),
          ],
        ),
        bottomNavigationBar:
            _isEditing && _selectedDef != null
                ? SafeArea(
                  minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : _cancelEditing,
                          child: Text(_strings.commonCancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isSaving ? null : _saveDefinition,
                          icon: const Icon(Icons.save_outlined),
                          label: Text(
                            _isSaving
                                ? _strings.exerciseEditorSaving
                                : _strings.exerciseEditorSaveChanges,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : null,
        body: _selectedDef == null ? _buildPickerLanding() : _buildEditor(),
      ),
    );
  }

  Widget _buildEditor() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 112),
      children: [
        _buildEditorHeader(),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(18),
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) => setState(() => _activeTabIndex = index),
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: SettingsAccent.advanced.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(14),
            ),
            labelColor: SettingsAccent.advanced,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            tabs: [
              Tab(text: _strings.exerciseEditorMuscles),
              Tab(text: _strings.exerciseEditorBodyparts),
              Tab(text: _strings.exerciseEditorEquipment),
              Tab(text: _strings.exerciseEditorGuide),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child:
              _isLoadingDetails
                  ? const Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : _buildCurrentTab(),
        ),
      ],
    );
  }

  Widget _buildCurrentTab() {
    switch (_activeTabIndex) {
      case 0:
        return _buildMusclesTab();
      case 1:
        return _buildBodypartsTab();
      case 2:
        return _buildEquipmentTab();
      case 3:
        return _buildNotesMediaTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _openCatalogPicker() async {
    if (_isEditing) {
      _showMessage('Save or cancel changes before selecting another exercise.');
      return;
    }
    final selected = await Navigator.of(context).push<ExerciseDefinition>(
      MaterialPageRoute(
        builder: (_) => ExerciseCatalogPage(onExercisePicked: (_) {}),
      ),
    );
    if (!mounted || selected == null) return;
    await _onExerciseSelected(selected);
  }

  Future<void> _createCustomExercise() async {
    if (_isEditing || _isSaving) return;

    var exerciseName = '';
    var selectedEquipmentId = 0;
    final draft = await showDialog<_CustomExerciseDraft>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              final mediaQuery = MediaQuery.of(context);
              final usableHeight =
                  mediaQuery.size.height - mediaQuery.viewInsets.bottom;
              return AlertDialog(
                title: Text(_strings.exerciseEditorCreateCustomTitle),
                content: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: usableHeight * 0.48),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_strings.exerciseEditorCreateCustomBody),
                        const SizedBox(height: 14),
                        TextFormField(
                          textCapitalization: TextCapitalization.words,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: _strings.exerciseEditorExerciseName,
                          ),
                          onChanged: (value) => exerciseName = value,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: selectedEquipmentId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: _strings.exerciseEditorEquipment,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: Text(
                                _strings.exerciseEditorNoEquipmentChoice,
                              ),
                            ),
                            ..._allEquipment.map(
                              (equipment) => DropdownMenuItem(
                                value: equipment.id,
                                child: Text(equipment.name),
                              ),
                            ),
                          ],
                          onChanged:
                              (value) => setDialogState(
                                () => selectedEquipmentId = value ?? 0,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(_strings.commonCancel),
                  ),
                  FilledButton(
                    onPressed: () {
                      final name = exerciseName.trim();
                      if (name.isEmpty) return;
                      Navigator.of(context).pop(
                        _CustomExerciseDraft(
                          name: name,
                          primaryEquipmentId:
                              selectedEquipmentId == 0
                                  ? null
                                  : selectedEquipmentId,
                        ),
                      );
                    },
                    child: Text(_strings.healthCreate),
                  ),
                ],
              );
            },
          ),
    );
    if (!mounted || draft == null) return;

    setState(() => _isSaving = true);
    try {
      String equipmentName = '';
      for (final equipment in _allEquipment) {
        if (equipment.id == draft.primaryEquipmentId) {
          equipmentName = equipment.name;
          break;
        }
      }
      final definitionId = await _repo.findOrCreateExerciseDefinition(
        draft.name,
        equipmentName,
      );
      final definition = await _repo.fetchDefinitionById(definitionId);
      if (!mounted || definition == null) return;
      await _onExerciseSelected(definition);
      if (!mounted) return;
      setState(() {
        _isEditing = true;
        _hasPendingChanges = false;
      });
      _showMessage(_strings.exerciseEditorOpenedMessage);
    } catch (error) {
      _showMessage(
        _strings.exerciseEditorCreateFailed(
          safeFailureMessage(_strings, error),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildPickerLanding() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        _buildTitleCard(),
        const SizedBox(height: 16),
        SettingsInfoCard(
          icon: Icons.info_outline,
          title: _strings.exerciseEditorWhatChangesTitle,
          body: _strings.exerciseEditorWhatChangesBody,
          iconColor: SettingsAccent.advanced,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _isSaving ? null : _openCatalogPicker,
          icon: const Icon(Icons.search),
          label: Text(_strings.exerciseEditorChooseCatalog),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _isSaving ? null : _createCustomExercise,
          icon: const Icon(Icons.add),
          label: Text(_strings.exerciseEditorCreateCustomTitle),
        ),
      ],
    );
  }

  Widget _buildTitleCard() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SettingsAccent.advanced.withValues(alpha: 0.26),
            scheme.surfaceContainerHighest.withValues(alpha: 0.54),
          ],
        ),
        border: Border.all(
          color: SettingsAccent.advanced.withValues(alpha: 0.42),
        ),
      ),
      child: Text(
        _strings.exerciseEditorTitle,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildEditorHeader() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = _selectedDef!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          _buildTitleCard(),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: SettingsAccent.advanced.withValues(alpha: 0.42),
              ),
            ),
            child:
                _isEditing
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: _strings.exerciseEditorExerciseName,
                              isDense: true,
                            ),
                            onChanged: (_) => _markChanged(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 88,
                          child: TextField(
                            controller: _ratingController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: _strings.exerciseEditorRating,
                              suffixText: '/100',
                              isDense: true,
                            ),
                            onChanged: (_) => _markChanged(),
                          ),
                        ),
                      ],
                    )
                    : Row(
                      children: [
                        Expanded(
                          child: Text(
                            selected.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: SettingsAccent.advanced.withValues(
                              alpha: 0.16,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${selected.rating}/100',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: SettingsAccent.advanced,
                              fontWeight: FontWeight.w900,
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

  Widget _buildAllocationShortcut({
    required String title,
    required String body,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _openAllocation,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: SettingsAccent.advanced.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.tune, color: SettingsAccent.advanced),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isEditing
                          ? 'Save or cancel definition changes first.'
                          : body,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAllocation() async {
    final definition = _selectedDef;
    if (definition == null) return;
    if (_isEditing) {
      _showMessage(_strings.exerciseEditorSaveBeforeAllocation);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciseAnalyticsScreen(initialDefinition: definition),
      ),
    );
    if (!mounted || _selectedDef?.id != definition.id) return;
    await _loadDefinitionDetails(definition);
  }

  Future<bool> _confirmRemove(String itemName, String itemType) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(_strings.exerciseEditorRemoveItemTitle(itemType)),
            content: Text(_strings.exerciseEditorRemoveItemBody(itemName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(_strings.exerciseEditorKeep),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(_strings.commonRemove),
              ),
            ],
          ),
    );
    return shouldRemove ?? false;
  }

  Widget _buildMusclesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsInfoCard(
          icon: Icons.fitness_center,
          title: _strings.exerciseEditorMuscleOrderTitle,
          body: _strings.exerciseEditorMuscleOrderBody,
          iconColor: SettingsAccent.training,
        ),
        const SizedBox(height: 14),
        _buildAllocationShortcut(
          title: _strings.exerciseEditorExactSetCredit,
          body: _strings.exerciseEditorExactSetCreditBody,
        ),
        if (_isEditing) ...[
          const SizedBox(height: 12),
          SettingsSection(
            title: _strings.exerciseEditorSetCreditScaling,
            subtitle: _strings.exerciseEditorSetCreditScalingBody,
            accentColor: SettingsAccent.advanced,
            children: [
              SettingsSwitchTile(
                icon: Icons.tune,
                iconColor: SettingsAccent.advanced,
                title: _strings.exerciseEditorScaleCreditByRating,
                subtitle: _strings.exerciseEditorScaleCreditByRatingBody,
                value: _multiplyByRating,
                onChanged: (value) {
                  setState(() {
                    _multiplyByRating = value;
                    _hasPendingChanges = true;
                  });
                },
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        SettingsSection(
          title: _strings.exerciseEditorTargetMuscles,
          subtitle:
              _isEditing
                  ? _strings.exerciseEditorOrderMusclesHint
                  : _strings.exerciseEditorMusclesAssociated(
                    _muscleEntries.length,
                  ),
          accentColor: SettingsAccent.training,
          children: [
            if (_muscleEntries.isEmpty)
              Padding(
                padding: EdgeInsets.all(18),
                child: Text(_strings.exerciseEditorNoTargetMuscles),
              )
            else
              for (var index = 0; index < _muscleEntries.length; index++)
                _buildMuscleTile(index),
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.all(12),
                child: OutlinedButton.icon(
                  onPressed: _openAddMuscleDialog,
                  icon: const Icon(Icons.add),
                  label: Text(_strings.exerciseEditorAddTargetMuscles),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMuscleTile(int index) {
    final entry = _muscleEntries[index];
    final name = entry['name'] as String;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: SettingsAccent.training.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Text(
          '${index + 1}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      title: Text(name),
      trailing:
          !_isEditing
              ? null
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: _strings.exerciseEditorMoveUp,
                    onPressed:
                        index == 0
                            ? null
                            : () => setState(() {
                              final previous = _muscleEntries[index - 1];
                              _muscleEntries[index - 1] = entry;
                              _muscleEntries[index] = previous;
                              _hasPendingChanges = true;
                            }),
                    icon: const Icon(Icons.keyboard_arrow_up),
                  ),
                  IconButton(
                    tooltip: _strings.exerciseEditorMoveDown,
                    onPressed:
                        index == _muscleEntries.length - 1
                            ? null
                            : () => setState(() {
                              final next = _muscleEntries[index + 1];
                              _muscleEntries[index + 1] = entry;
                              _muscleEntries[index] = next;
                              _hasPendingChanges = true;
                            }),
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                  IconButton(
                    tooltip: _strings.exerciseEditorRemoveMuscle,
                    onPressed: () async {
                      if (!await _confirmRemove(
                        name,
                        _strings.exerciseEditorMuscleItem,
                      )) {
                        return;
                      }
                      setState(() {
                        _muscleEntries.removeAt(index);
                        _hasPendingChanges = true;
                      });
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
    );
  }

  /// Mirrors the old _buildMusclesTab list, but showing “sets” instead of “%”.
  Widget _buildBodypartsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsInfoCard(
          icon: Icons.accessibility_new,
          title: _strings.exerciseEditorAssociatedBodyparts,
          body: _strings.exerciseEditorAssociatedBodypartsBody,
          iconColor: SettingsAccent.training,
        ),
        const SizedBox(height: 14),
        _buildAllocationShortcut(
          title: _strings.exerciseEditorExactBodypartCredit,
          body: _strings.exerciseEditorExactBodypartCreditBody,
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: _strings.exerciseEditorAssociatedBodyparts,
          subtitle:
              _isEditing
                  ? _strings.exerciseEditorBodypartsHint
                  : _strings.exerciseEditorBodypartsAssociated(
                    _bodyManualEntries.length,
                  ),
          accentColor: SettingsAccent.training,
          children: [
            if (_bodyManualEntries.isEmpty)
              Padding(
                padding: EdgeInsets.all(18),
                child: Text(_strings.exerciseEditorNoBodyparts),
              )
            else
              for (var index = 0; index < _bodyManualEntries.length; index++)
                _buildBodyPartTile(index),
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.all(12),
                child: OutlinedButton.icon(
                  onPressed: _openAddBodypartDialog,
                  icon: const Icon(Icons.add),
                  label: Text(_strings.exerciseEditorAddBodyparts),
                ),
              ),
          ],
        ),
        if (_bodyAutoEntries.isNotEmpty) ...[
          const SizedBox(height: 16),
          SettingsSection(
            title: _strings.exerciseEditorAutomaticPreview,
            subtitle: _strings.exerciseEditorAutomaticPreviewBody,
            accentColor: SettingsAccent.progress,
            children: [
              for (final entry in _bodyAutoEntries)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 3,
                  ),
                  leading: const Icon(Icons.auto_graph),
                  title: Text(entry['name'] as String),
                  trailing: Text((entry['count'] as double).toStringAsFixed(2)),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBodyPartTile(int index) {
    final entry = _bodyManualEntries[index];
    final name = entry['name'] as String;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: SettingsAccent.training.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.accessibility_new,
          color: SettingsAccent.training,
        ),
      ),
      title: Text(name),
      trailing:
          !_isEditing
              ? null
              : IconButton(
                tooltip: _strings.exerciseEditorRemoveBodypart,
                onPressed: () async {
                  if (!await _confirmRemove(
                    name,
                    _strings.exerciseEditorBodypartItem,
                  )) {
                    return;
                  }
                  setState(() {
                    _bodyManualEntries.removeAt(index);
                    _hasPendingChanges = true;
                  });
                },
                icon: const Icon(Icons.delete_outline),
              ),
    );
  }

  // ignore: unused_element
  Widget _buildManualBodyparts() {
    return ListView.builder(
      itemCount: _bodyManualEntries.length,
      itemBuilder: (_, i) {
        final entry = _bodyManualEntries[i];
        final name = entry['name'] as String;
        final count = entry['count'] as double;

        return ListTile(
          leading:
              _isEditing
                  ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text(
                                _strings.exerciseEditorRemoveItemTitle(
                                  _strings.exerciseEditorBodypartItem,
                                ),
                              ),
                              content: Text(
                                _strings.exerciseEditorRemoveItemBody(name),
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: Text(_strings.commonCancel),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: Text(_strings.commonRemove),
                                ),
                              ],
                            ),
                      );
                      if (confirm != true) return;
                      setState(() {
                        _bodyManualEntries.removeAt(i);
                      });
                    },
                  )
                  : null,
          title: Text(name),
          trailing: SizedBox(
            width: 80,
            child: TextFormField(
              // this key changes whenever `count` changes,
              // forcing Flutter to rebuild the field with the new initialValue
              key: ValueKey('${entry['id']}_$count'),
              enabled: _isEditing && _useManualBody,
              initialValue: count.toString(),
              decoration: InputDecoration(
                suffixText: _strings.sessionMetricSets,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              // AFTER  ─ copies it on every keystroke / focus change
              onChanged: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null) {
                  entry['count'] = parsed; // just mutate—no setState
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEquipmentTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsInfoCard(
          icon: Icons.precision_manufacturing_outlined,
          title: _strings.exerciseEditorAvailableEquipment,
          body: _strings.exerciseEditorAvailableEquipmentBody,
          iconColor: SettingsAccent.training,
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: _strings.exerciseEditorEquipment,
          subtitle:
              _isEditing
                  ? _strings.exerciseEditorEquipmentHint
                  : _strings.exerciseEditorEquipmentAssociated(
                    _equipmentEntries.length,
                  ),
          accentColor: SettingsAccent.training,
          children: [
            if (_equipmentEntries.isEmpty)
              Padding(
                padding: EdgeInsets.all(18),
                child: Text(_strings.exerciseEditorNoEquipment),
              )
            else
              for (var index = 0; index < _equipmentEntries.length; index++)
                _buildEquipmentTile(index),
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.all(12),
                child: OutlinedButton.icon(
                  onPressed: _openAddEquipmentDialog,
                  icon: const Icon(Icons.add),
                  label: Text(_strings.exerciseEditorAddEquipment),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildEquipmentTile(int index) {
    final entry = _equipmentEntries[index];
    final equipmentId = entry['id'] as int;
    final equipmentName = entry['name'] as String;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: SettingsAccent.training.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(
          Icons.precision_manufacturing_outlined,
          color: SettingsAccent.training,
        ),
      ),
      title: Text(equipmentName),
      trailing:
          !_isEditing
              ? null
              : IconButton(
                tooltip: _strings.exerciseEditorRemoveEquipment,
                onPressed: () async {
                  if (!await _confirmRemove(
                    equipmentName,
                    _strings.exerciseEditorEquipmentItem,
                  )) {
                    return;
                  }
                  setState(() {
                    _equipmentEntries.removeAt(index);
                    if (_primaryEquipmentId == equipmentId) {
                      _primaryEquipmentId = null;
                    }
                    _hasPendingChanges = true;
                  });
                },
                icon: const Icon(Icons.delete_outline),
              ),
    );
  }

  String? _trimToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  IconData _mediaIcon(String mediaType) {
    switch (mediaType) {
      case 'image':
        return Icons.image_outlined;
      case 'video':
        return Icons.play_circle_outline;
      default:
        return Icons.link;
    }
  }

  String _mediaLabel(ExerciseMediaItem item) {
    final title = _trimToNull(item.title);
    if (title != null) return title;
    final uri = Uri.tryParse(item.remoteUrl);
    final host = uri?.host;
    if (host != null && host.isNotEmpty) return host;
    return item.remoteUrl;
  }

  Future<ExerciseMediaItem?> _showMediaEditor({
    ExerciseMediaItem? initial,
  }) async {
    if (!mounted) return null;

    var remoteUrlValue = initial?.remoteUrl ?? '';
    var titleValue = initial?.title ?? '';
    var thumbnailUrlValue = initial?.thumbnailUrl ?? '';
    var mediaType = initial?.mediaType ?? 'image';

    final result = await showDialog<ExerciseMediaItem>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setDialogState) {
            return AlertDialog(
              title: Text(
                initial == null
                    ? _strings.exerciseEditorAddMedia
                    : _strings.exerciseEditorEditMedia,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: mediaType,
                      items: [
                        DropdownMenuItem(
                          value: 'image',
                          child: Text(_strings.exerciseEditorMediaImage),
                        ),
                        DropdownMenuItem(
                          value: 'video',
                          child: Text(_strings.exerciseEditorMediaVideo),
                        ),
                        DropdownMenuItem(
                          value: 'link',
                          child: Text(_strings.exerciseEditorMediaLink),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => mediaType = value);
                      },
                      decoration: InputDecoration(
                        labelText: _strings.exerciseEditorMediaType,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: titleValue,
                      decoration: InputDecoration(
                        labelText: _strings.exerciseEditorMediaTitle,
                        hintText: _strings.exerciseEditorMediaTitleHint,
                      ),
                      onChanged: (value) => titleValue = value,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: remoteUrlValue,
                      decoration: InputDecoration(
                        labelText: _strings.exerciseEditorMediaRemoteUrl,
                        hintText: 'https://...',
                      ),
                      onChanged: (value) => remoteUrlValue = value,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: thumbnailUrlValue,
                      decoration: InputDecoration(
                        labelText: _strings.exerciseEditorMediaThumbnailUrl,
                        hintText: _strings.exerciseEditorMediaThumbnailHint,
                      ),
                      onChanged: (value) => thumbnailUrlValue = value,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(_strings.commonCancel),
                ),
                TextButton(
                  onPressed: () {
                    final remoteUrl = _trimToNull(remoteUrlValue);
                    if (remoteUrl == null) return;
                    Navigator.of(ctx).pop(
                      ExerciseMediaItem(
                        id: initial?.id,
                        exerciseDefId:
                            initial?.exerciseDefId ?? _selectedDef?.id ?? -1,
                        mediaType: mediaType,
                        remoteUrl: remoteUrl,
                        thumbnailUrl: _trimToNull(thumbnailUrlValue),
                        localCachePath: initial?.localCachePath,
                        localThumbnailPath: initial?.localThumbnailPath,
                        title: _trimToNull(titleValue),
                        sortOrder: initial?.sortOrder ?? _mediaItems.length,
                      ),
                    );
                  },
                  child: Text(_strings.commonSave),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  Future<void> _openAddMediaDialog() async {
    if (_selectedDef == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.exerciseEditorSelectBeforeMedia)),
      );
      return;
    }

    final created = await _showMediaEditor();
    if (created == null) return;

    setState(() {
      _mediaItems.add(
        created.copyWith(
          exerciseDefId: _selectedDef!.id,
          sortOrder: _mediaItems.length,
        ),
      );
      _hasPendingChanges = true;
    });
  }

  Future<void> _editMediaItem(int index) async {
    final updated = await _showMediaEditor(initial: _mediaItems[index]);
    if (updated == null) return;

    setState(() {
      _mediaItems[index] = updated.copyWith(
        exerciseDefId: _selectedDef?.id ?? updated.exerciseDefId,
        sortOrder: index,
      );
      _hasPendingChanges = true;
    });
  }

  Widget _buildNotesMediaTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsInfoCard(
          icon: Icons.menu_book_outlined,
          title: _strings.exerciseEditorFormGuide,
          body: _strings.exerciseEditorFormGuideBody,
          iconColor: SettingsAccent.advanced,
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: _strings.exerciseEditorGuidance,
          subtitle:
              _isEditing
                  ? _strings.exerciseEditorGuidanceEditing
                  : _strings.exerciseEditorGuidanceReadOnly,
          accentColor: SettingsAccent.advanced,
          children: [
            _buildGuideField(
              controller: _setupController,
              label: _strings.exerciseEditorSetUp,
              hint: _strings.exerciseEditorSetUpHint,
            ),
            _buildGuideField(
              controller: _executionController,
              label: _strings.exerciseEditorHowToPerform,
              hint: _strings.exerciseEditorHowToPerformHint,
            ),
            _buildGuideField(
              controller: _tipsController,
              label: _strings.exerciseEditorCoachingTips,
              hint: _strings.exerciseEditorCoachingTipsHint,
            ),
          ],
        ),
        SettingsInfoCard(
          icon: Icons.cloud_sync_outlined,
          title: _strings.exerciseEditorReferenceMedia,
          body: _strings.exerciseEditorReferenceMediaBody,
          iconColor: SettingsAccent.data,
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: _strings.exerciseEditorMediaLinks,
          subtitle:
              _isEditing
                  ? _strings.exerciseEditorMediaLinksEditing
                  : _strings.exerciseEditorMediaLinksCount(_mediaItems.length),
          accentColor: SettingsAccent.data,
          children: [
            if (_mediaItems.isEmpty)
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(_strings.exerciseEditorNoReferenceMedia),
              )
            else
              for (var index = 0; index < _mediaItems.length; index++)
                _buildMediaTile(index),
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.all(12),
                child: OutlinedButton.icon(
                  onPressed: _openAddMediaDialog,
                  icon: const Icon(Icons.add),
                  label: Text(_strings.exerciseEditorAddMediaLink),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuideField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: TextField(
        controller: controller,
        readOnly: !_isEditing,
        minLines: 3,
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label, hintText: hint),
        onChanged: _isEditing ? (_) => _markChanged() : null,
      ),
    );
  }

  Widget _buildMediaTile(int index) {
    final item = _mediaItems[index];
    return SettingsActionTile(
      icon: _mediaIcon(item.mediaType),
      iconColor: SettingsAccent.data,
      title: _mediaLabel(item),
      subtitle: _strings.exerciseEditorMediaReference(
        _localizedMediaType(item.mediaType),
      ),
      onTap: _isEditing ? () => _editMediaItem(index) : null,
      trailing:
          _isEditing
              ? IconButton(
                tooltip: _strings.exerciseEditorRemoveMedia,
                onPressed: () async {
                  if (!await _confirmRemove(
                    _mediaLabel(item),
                    _strings.exerciseEditorMediaLinkItem,
                  )) {
                    return;
                  }
                  setState(() {
                    _mediaItems.removeAt(index);
                    _hasPendingChanges = true;
                  });
                },
                icon: const Icon(Icons.delete_outline),
              )
              : Text(
                item.mediaType.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium,
              ),
    );
  }

  String _localizedMediaType(String mediaType) {
    switch (mediaType) {
      case 'image':
        return _strings.exerciseEditorMediaImage;
      case 'video':
        return _strings.exerciseEditorMediaVideo;
      default:
        return _strings.exerciseEditorMediaLink;
    }
  }

  // ignore: unused_element
  Widget _buildLegacyNotesMediaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── RATING EDITOR ──────────────────────
          Row(
            children: [
              Text(
                '${AppLocalizations.of(context).exerciseEditorRating}:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: TextFormField(
                  key: ValueKey(_rating),
                  enabled: _isEditing,
                  initialValue: _rating.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(suffixText: '/100'),
                  onFieldSubmitted: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null && parsed >= 0 && parsed <= 100) {
                      setState(() => _rating = parsed);
                    }
                  },
                ),
              ),
            ],
          ),

          // ─── MULTIPLY CHECKBOX (UI‐ONLY) ────────
          Row(
            children: [
              Checkbox(
                value: _multiplyByRating,
                onChanged:
                    _isEditing
                        ? (v) => setState(() => _multiplyByRating = v!)
                        : null,
              ),
              Expanded(child: Text(_strings.exerciseEditorScaleCreditByRating)),
            ],
          ),

          const Divider(height: 32),
          Text(
            _strings.exerciseEditorSetUp,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          TextField(
            enabled: _isEditing,
            controller: _setupController,
            maxLines: null, // ← allow multiple lines
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Text(
            _strings.exerciseEditorHowToPerform,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          TextField(
            enabled: _isEditing,
            controller: _executionController,
            maxLines: null, // ← allow multiple lines
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Text(
            _strings.exerciseEditorCoachingTips,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          TextField(
            enabled: _isEditing,
            controller: _tipsController,
            maxLines: null, // ← allow multiple lines
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),

          const SizedBox(height: 24),
          Text(
            _strings.exerciseEditorReferenceMedia,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.15,
            ),
            itemCount: _mediaItems.length + (_isEditing ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isEditing && index == _mediaItems.length) {
                return GestureDetector(
                  onTap: _openAddMediaDialog,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add),
                  ),
                );
              }
              final media = _mediaItems[index];
              return Stack(
                children: [
                  InkWell(
                    onTap: _isEditing ? () => _editMediaItem(index) : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _mediaIcon(media.mediaType),
                            size: 28,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _mediaLabel(media),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            media.mediaType.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          if ((media.localCachePath ??
                                  media.localThumbnailPath) !=
                              null)
                            Text(
                              AppLocalizations.of(
                                context,
                              ).exerciseEditorCachedLocally,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _mediaItems.removeAt(index);
                          });
                        },
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
