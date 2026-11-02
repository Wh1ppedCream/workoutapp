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
import 'exercise_editor/exercise_editor_controller.dart';

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
  late final ExerciseEditorController _controller;
  bool _isCreating = false;
  bool get _isSaving => _isCreating || _controller.saving;

  // Definitions
  List<Equipment> get _allEquipment => _controller.equipment;
  ExerciseDefinition? get _selectedDef => _controller.definition;
  bool get _isLoadingDefinitions => _controller.loadingCatalog;
  bool get _isLoadingDetails => _controller.loadingDetails;
  SafeFailure? get _loadFailure => _controller.catalogFailure;
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
    _controller = ExerciseEditorController(_repo)
      ..addListener(_onControllerChanged);
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
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _tabController.dispose();
    _setupController.dispose();
    _executionController.dispose();
    _tipsController.dispose();
    _nameController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadExerciseList() async {
    if (await _controller.loadCatalog() && mounted) {
      setState(() {
        _isEditing = false;
        _hasPendingChanges = false;
      });
    }
  }

  Future<void> _onExerciseSelected(ExerciseDefinition def) async {
    setState(() {
      _isEditing = false;
      _hasPendingChanges = false;
      _activeTabIndex = 0;
    });
    _tabController.index = 0;
    await _loadDefinitionDetails(def);
  }

  Future<void> _loadDefinitionDetails(ExerciseDefinition def) async {
    try {
      final details = await _controller.loadDefinition(def);
      if (details != null && mounted) _applyDefinitionDetails(details);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        safeFailureSnackBar(
          context,
          error: error,
          summary: _strings.exerciseEditorLoadFailed,
        ),
      );
    }
  }

  void _applyDefinitionDetails(ExerciseEditorDetails details) {
    final def = details.definition;
    final manualMap = {
      for (final entry in details.manualBodyparts)
        entry.bodyPartId: entry.percent,
    };
    final automaticMap = {
      for (final entry in details.automaticBodyparts.entries)
        entry.key.id: entry.value,
    };
    setState(() {
      _useManualBody = details.useManualBodyparts;
      _useManualMuscles = details.useManualMuscles;
      _multiplyByRating = details.multiplyByRating;
      _muscleEntries = def.muscles.map((ranked) {
        final percent = details.musclePercents.firstWhere(
          (entry) => entry.muscleId == ranked.muscle.id,
          orElse: () => ExerciseMusclePercent(
            exerciseDefId: def.id,
            muscleId: ranked.muscle.id,
            percent: 0,
          ),
        );
        return <String, Object?>{
          'id': ranked.muscle.id,
          'name': ranked.muscle.name,
          'catalogId': ranked.muscle.catalogId,
          'percent': percent.percent,
        };
      }).toList();
      _bodyAutoEntries = details.automaticBodyparts.entries
          .map(
            (entry) => <String, Object>{
              'id': entry.key.id,
              'name': entry.key.name,
              'count': entry.value,
            },
          )
          .toList();
      _bodyManualEntries = def.bodyParts
          .map(
            (part) => <String, Object>{
              'id': part.id,
              'name': part.name,
              'count': manualMap[part.id] ?? automaticMap[part.id] ?? 0.0,
            },
          )
          .toList();
      _equipmentEntries = def.equipmentList
          .map(
            (equipment) => <String, Object?>{
              'id': equipment.id,
              'name': equipment.name,
              'catalogId': equipment.catalogId,
            },
          )
          .toList();
      _mediaItems = details.media.toList();
      _primaryEquipmentId = def.equipmentId;
    });
    _nameController.text = def.name;
    _ratingController.text = def.rating.toString();
    _setupController.text = def.setupNotes;
    _executionController.text = def.executionNotes;
    _tipsController.text = def.tipsNotes;
  }

  void _startEditing() {
    if (_selectedDef == null || _isSaving || _isLoadingDetails) return;
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

    try {
      final details = await _controller.save(
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

      if (!mounted || details == null) return;
      setState(() {
        _isEditing = false;
        _hasPendingChanges = false;
      });
      _applyDefinitionDetails(details);
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
    }
  }

  Future<void> _cancelEditing() async {
    if (_selectedDef == null || _isSaving) return;
    if (_hasPendingChanges && !await _confirmDiscard()) return;
    if (!mounted) return;
    try {
      final details = await _controller.reloadSelection();
      if (!mounted || details == null) return;
      setState(() {
        _isEditing = false;
        _hasPendingChanges = false;
      });
      _applyDefinitionDetails(details);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        safeFailureSnackBar(
          context,
          error: error,
          summary: _strings.exerciseEditorLoadFailed,
        ),
      );
    }
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
