// file: lib/screens/profile/settings/exercise_editor_screen.dart
// Advanced editor for shared exercise definition data.

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../theme/widgets/tonos_overlay_routes.dart';

import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/safe_failure_localizations.dart';
import '../../../models/models.dart';
import '../../../repositories/app_repository.dart';
import '../../../services/catalog_entity_localizer.dart';
import '../../../services/safe_failure.dart';
import '../../../theme/theme_extensions.dart';
import '../../../theme/tokens/app_expressive_train_tokens.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/widgets/tonos_dialog.dart';
import '../../../theme/widgets/tonos_field.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import '../../../utils/localized_body_part_name.dart';
import '../../../utils/localized_formatters.dart';
import '../../../widgets/localized_catalog_entity_name.dart';
import '../../../widgets/settings_tiles.dart';
import '../../../widgets/safe_error_view.dart';
import 'analytics_destination_surfaces.dart';
import '../../exercise/exercise_catalog_page.dart';
import 'exercise_analytics_screen.dart';

part 'exercise_editor/custom_exercise_draft.dart';
part 'exercise_editor/selection_dialogs.dart';
part 'exercise_editor/editor_identity.dart';
part 'exercise_editor/allocation_tabs.dart';
part 'exercise_editor/media_editor.dart';

/// Exercise Editor Screen: allows viewing and editing an exercise definition.
class ExerciseEditorScreen extends StatelessWidget {
  const ExerciseEditorScreen({super.key});

  @override
  Widget build(BuildContext context) => AppExpressiveDestinationTheme(
    family: AppExpressiveDestinationFamily.analytics,
    child: const _ExerciseEditorBody(),
  );
}

class _ExerciseEditorBody extends StatefulWidget {
  const _ExerciseEditorBody();

  @override
  State<_ExerciseEditorBody> createState() => _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends State<_ExerciseEditorBody>
    with SingleTickerProviderStateMixin {
  static const _expressiveTeal = Color(0xFF164F49);
  static const _expressiveTealDark = Color(0xFF183F3C);
  static const _expressivePeach = Color(0xFFFFD5B8);
  static const _expressivePeachDark = Color(0xFF573A2B);
  static const _expressiveLavender = Color(0xFFE1D3F5);
  static const _expressiveLavenderDark = Color(0xFF443854);
  static const _expressiveMint = Color(0xFFCBE9D9);
  static const _expressiveMintDark = Color(0xFF24483E);

  bool get _usesExpressive => context.usesExpressivePresentation;

  Color get _expressiveHeroColor =>
      Theme.of(context).brightness == Brightness.dark
      ? _expressiveTealDark
      : _expressiveTeal;

  Color get _expressiveHeroForeground =>
      Theme.of(context).brightness == Brightness.dark
      ? _expressiveMint
      : _expressiveTeal;

  Color get _expressivePeachColor =>
      Theme.of(context).brightness == Brightness.dark
      ? _expressivePeachDark
      : _expressivePeach;

  Color get _expressivePeachForeground =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFFFE9D8)
      : const Color(0xFF45291D);

  Color _expressiveIdentitySurface(int index) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (index) {
      0 => _expressivePeachColor,
      1 => dark ? _expressiveLavenderDark : _expressiveLavender,
      2 => _expressiveHeroColor,
      _ => dark ? _expressiveMintDark : _expressiveMint,
    };
  }

  Color _expressiveIdentityForeground(int index) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (index) {
      0 => _expressivePeachForeground,
      1 => dark ? const Color(0xFFF0E4FF) : const Color(0xFF342445),
      2 => Colors.white,
      _ => dark ? const Color(0xFFE0F6EA) : const Color(0xFF1B4035),
    };
  }

  Color _expressiveIdentityHeadingColor(int index) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (index) {
      0 => _expressivePeachForeground,
      1 => dark ? const Color(0xFFF0E4FF) : const Color(0xFF342445),
      2 => dark ? const Color(0xFFD6F3EB) : _expressiveTeal,
      _ => dark ? const Color(0xFFD8F7E9) : const Color(0xFF1B4035),
    };
  }

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
  List<Map<String, Object?>> _muscleEntries = []; // { 'id': int, 'name': String, 'catalogId': String?, 'percent': double }

  bool _useManualBody = false;

  // just below `bool _useManualBody = false;`
  bool _useManualMuscles = false;

  // new:
  List<Map<String, Object?>> _equipmentEntries =
      []; // { 'id': int, 'name': String, 'catalogId': String? }

  List<Map<String, Object>> _bodyAutoEntries = []; // muscle‐calculated values
  List<Map<String, Object>> _bodyManualEntries = []; // manual overrides

  // Notes & media metadata. Remote URLs are durable; local cache paths are optional.
  List<ExerciseMediaItem> _mediaItems = [];

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
        _muscleEntries = def.muscles.map((rm) {
          final override = musclePercents.firstWhere(
            (e) => e.muscleId == rm.muscle.id,
            orElse: () => ExerciseMusclePercent(
              exerciseDefId: defId,
              muscleId: rm.muscle.id,
              percent: 0.0,
            ),
          );
          return {
            'id': rm.muscle.id,
            'name': rm.muscle.name,
            'catalogId': rm.muscle.catalogId,
            'percent': override.percent,
          };
        }).toList();
        // --- Muscle-Calculated Bodyparts ---
        _bodyAutoEntries = autoBpMap.entries.map((e) {
          return {'id': e.key.id, 'name': e.key.name, 'count': e.value};
        }).toList();

        // --- Manual-Assigned Bodyparts ---
        _bodyManualEntries = def.bodyParts.map((bp) {
          // seed with override if present, else default 1 set per set
          final autoMap = {for (var e in autoBpMap.entries) e.key.id: e.value};
          final count = manualMap[bp.id] ?? autoMap[bp.id] ?? 0.0;
          return {'id': bp.id, 'name': bp.name, 'count': count};
        }).toList();

        // Keep the canonical name for saves while retaining the stable ID for
        // localized display.
        _equipmentEntries = def.equipmentList
            .map(
              (e) => <String, Object?>{
                'id': e.id,
                'name': e.name,
                'catalogId': e.catalogId,
              },
            )
            .toList();
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

  // Presentation parts route rebuilds through State's protected API.
  void _updateEditorState(VoidCallback update) => setState(update);

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

    final equipmentIds = _equipmentEntries
        .map((entry) => entry['id'] as int)
        .toSet();
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
            bodyParts: _bodyManualEntries
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
                    catalogId: _muscleEntries[index]['catalogId'] as String?,
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

  Future<void> _handleBack() async {
    if (!await _confirmDiscard() || !mounted) return;
    if (_hasPendingChanges) {
      setState(() => _hasPendingChanges = false);
    }
    Navigator.maybePop(context);
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
    final destination = analyticsDestinationTokens(context);
    final theme = Theme.of(context);
    final saveBar = SettingsSaveBar(
      label: _isSaving
          ? _strings.exerciseEditorSaving
          : _strings.exerciseEditorSaveChanges,
      onPressed: _isSaving ? null : _saveDefinition,
      cancelLabel: _strings.commonCancel,
      onCancel: _isSaving ? null : _cancelEditing,
      saveIcon: const Icon(Icons.save_outlined),
      decorated: !_usesExpressive,
      padding: EdgeInsets.fromLTRB(16, 10, 16, _usesExpressive ? 10 : 16),
    );
    return PopScope<Object?>(
      canPop: !_isEditing || !_hasPendingChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !_isEditing || !_hasPendingChanges) return;
        if (!await _confirmDiscard() || !mounted) return;
        setState(() => _hasPendingChanges = false);
        navigator.pop();
      },
      child: AppExpressiveDestinationTheme(
        family: AppExpressiveDestinationFamily.analytics,
        child: Scaffold(
          backgroundColor: destination?.pageCanvas,
          appBar: AppBar(
            leading: IconButton(
              tooltip: _usesExpressive && _isEditing
                  ? _strings.commonCancel
                  : _strings.commonBack,
              onPressed: _usesExpressive && _isEditing
                  ? _cancelEditing
                  : _handleBack,
              icon: const Icon(Icons.arrow_back),
            ),
            title: const SizedBox.shrink(),
            backgroundColor: _usesExpressive
                ? destination?.pageCanvas
                : destination?.surfacePrimary,
            scrolledUnderElevation: _usesExpressive ? 0 : null,
            surfaceTintColor: _usesExpressive ? Colors.transparent : null,
            shadowColor: _usesExpressive ? Colors.transparent : null,
            foregroundColor: _usesExpressive
                ? theme.colorScheme.onSurface
                : destination?.onSurfacePrimary,
            actions: _usesExpressive
                ? const []
                : [
                    IconButton(
                      tooltip: _strings.exerciseEditorChoose,
                      icon: const Icon(Icons.search),
                      onPressed: _isEditing || _isSaving
                          ? null
                          : _openCatalogPicker,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: _isSaving
                          ? null
                          : (_selectedDef != null && !_isEditing)
                          ? _startEditing
                          : null,
                      tooltip: _strings.exerciseEditorEdit,
                    ),
                    IconButton(
                      tooltip: _strings.exerciseEditorCreate,
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _isEditing || _isSaving
                          ? null
                          : _createCustomExercise,
                    ),
                  ],
          ),
          bottomNavigationBar:
              _isEditing && _selectedDef != null && !_usesExpressive
              ? destination == null
                    ? saveBar
                    : Theme(
                        data: theme.copyWith(
                          colorScheme: theme.colorScheme.copyWith(
                            primary: destination.actionPrimary,
                            onPrimary: destination.onActionPrimary,
                          ),
                        ),
                        child: AnalyticsZone(
                          role: AnalyticsSurfaceRole.accent,
                          padding: EdgeInsets.zero,
                          borderRadius: 0,
                          outlined: true,
                          child: saveBar,
                        ),
                      )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton:
              _usesExpressive &&
                  _isEditing &&
                  _selectedDef != null &&
                  _hasPendingChanges
              ? SafeArea(
                  child: Theme(
                    data: theme.copyWith(
                      colorScheme: theme.colorScheme.copyWith(
                        primary: _expressiveHeroColor,
                        onPrimary: Colors.white,
                      ),
                    ),
                    child: FloatingActionButton.extended(
                      key: const ValueKey('exercise-editor-save-fab'),
                      heroTag: null,
                      tooltip: _isSaving
                          ? _strings.exerciseEditorSaving
                          : _strings.exerciseEditorSaveChanges,
                      onPressed: _isSaving || !_hasPendingChanges
                          ? null
                          : _saveDefinition,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _isSaving
                            ? _strings.exerciseEditorSaving
                            : _strings.exerciseEditorSaveChanges,
                      ),
                      shape: const StadiumBorder(),
                    ),
                  ),
                )
              : null,
          body: _selectedDef == null ? _buildPickerLanding() : _buildEditor(),
        ),
      ),
    );
  }

  Future<void> _openCatalogPicker() async {
    if (_isEditing) {
      _showMessage('Save or cancel changes before selecting another exercise.');
      return;
    }
    final useExpressivePicker = context.usesExpressivePresentation;
    final selected = await Navigator.of(context).push<ExerciseDefinition>(
      MaterialPageRoute(
        builder: (_) => AppExpressiveDestinationTheme(
          family: AppExpressiveDestinationFamily.catalog,
          child: ExerciseCatalogPage(
            onExercisePicked: (_) {},
            expressiveCatalogPresentation: useExpressivePicker,
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    await _onExerciseSelected(selected);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
}
