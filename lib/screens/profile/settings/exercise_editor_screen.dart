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

class _CustomExerciseDraft {
  final String name;
  final int? primaryEquipmentId;

  const _CustomExerciseDraft({
    required this.name,
    required this.primaryEquipmentId,
  });
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

  Future<bool> _confirmDiscard() async {
    if (!_isEditing || !_hasPendingChanges) return true;
    final result = await showTonosDialog<bool>(
      context: context,
      builder: (context) => TonosDialogFrame(
        child: AlertDialog(
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

  double _selectionDialogListHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    final usableHeight = math.max(
      0.0,
      media.size.height - media.viewInsets.bottom - media.padding.vertical - 24,
    );
    const compactSelectionRowHeight = 44.0;
    final availableHeight = (usableHeight * 0.46 - 124)
        .clamp(compactSelectionRowHeight, 360.0)
        .toDouble();
    return math.max(
      compactSelectionRowHeight,
      (availableHeight / compactSelectionRowHeight).floor() *
          compactSelectionRowHeight,
    );
  }

  Widget _selectionDialogAddButton({required VoidCallback? onPressed}) =>
      _usesExpressive
      ? FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: Text(_strings.commonAdd),
        )
      : TextButton(onPressed: onPressed, child: Text(_strings.commonAdd));

  Widget _editorInlineAddAction({
    required String label,
    required int identityIndex,
    required VoidCallback onPressed,
  }) {
    if (!_usesExpressive) {
      return SettingsInlineActionButton(
        onPressed: onPressed,
        icon: Icons.add,
        label: label,
      );
    }
    final foreground = _expressiveIdentityHeadingColor(identityIndex);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: BorderSide(color: foreground.withValues(alpha: 0.72)),
        ),
      ),
    );
  }

  /// Let the user pick one or more new BodyParts to stage.
  Future<void> _openAddBodypartDialog() async {
    final allBps = await _repo.fetchAllBodyPartsFull(); // List<BodyPart>
    if (!mounted) return;
    final existing = _bodyManualEntries.map((e) => e['id'] as int).toSet();
    final available = allBps.where((bp) => !existing.contains(bp.id)).toList();
    final selectedIds = <int>{};
    final selectedCount = ValueNotifier<int>(0);
    var query = '';

    final result = await showTonosDialog<Set<int>>(
      context: context,
      builder: (ctx) => TonosDialogFrame(
        child: AlertDialog(
          scrollable: _usesExpressive,
          insetPadding: _usesExpressive
              ? const EdgeInsets.symmetric(horizontal: 18, vertical: 10)
              : null,
          title: Text(_strings.exerciseEditorAddBodyparts),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (ctx2, setState2) {
                final filtered = _usesExpressive
                    ? available
                          .where(
                            (bp) => localizedBodyPartName(ctx2, bp.name)
                                .toLowerCase()
                                .contains(query.trim().toLowerCase()),
                          )
                          .toList()
                    : available;
                final listHeight = _selectionDialogListHeight(ctx2);
                Widget checkboxTile(BodyPart bp) {
                  final checked = selectedIds.contains(bp.id);
                  final tile = CheckboxListTile(
                    title: Text(localizedBodyPartName(ctx2, bp.name)),
                    value: checked,
                    selected: _usesExpressive && checked,
                    activeColor: _usesExpressive ? _expressiveHeroColor : null,
                    dense: _usesExpressive,
                    visualDensity: _usesExpressive
                        ? VisualDensity.compact
                        : null,
                    minVerticalPadding: _usesExpressive ? 2 : null,
                    controlAffinity: _usesExpressive
                        ? ListTileControlAffinity.leading
                        : null,
                    contentPadding: _usesExpressive
                        ? const EdgeInsets.symmetric(horizontal: 8)
                        : null,
                    onChanged: (on) => setState2(() {
                      if (on == true) {
                        selectedIds.add(bp.id);
                      } else {
                        selectedIds.remove(bp.id);
                      }
                      selectedCount.value = selectedIds.length;
                    }),
                  );
                  return _usesExpressive
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Material(
                            color: checked
                                ? _expressiveIdentitySurface(1)
                                      .withValues(alpha: 0.2)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: tile,
                          ),
                        )
                      : tile;
                }

                if (!_usesExpressive) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (_, index) => checkboxTile(filtered[index]),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: MaterialLocalizations.of(ctx2)
                            .searchFieldLabel,
                      ),
                      onChanged: (value) => setState2(() => query = value),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 6),
                        child: Text(
                          _strings.exerciseEditorSelectedCount(
                            selectedIds.length,
                          ),
                          style: _usesExpressive
                              ? Theme.of(ctx2).textTheme.labelMedium
                              : Theme.of(ctx2).textTheme.labelLarge,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: listHeight,
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          return checkboxTile(filtered[i]);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(_strings.commonCancel),
            ),
            ValueListenableBuilder<int>(
              valueListenable: selectedCount,
              builder: (context, count, _) => _selectionDialogAddButton(
                onPressed: _usesExpressive && count == 0
                    ? null
                    : () => Navigator.of(ctx).pop(selectedIds),
              ),
            ),
          ],
        ),
      ),
    );
    selectedCount.dispose();

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
    if (!mounted) return;
    // 2) filter out the ones already staged
    final existingIds = _muscleEntries.map((e) => e['id'] as int).toSet();
    final available = allMuscles
        .where((m) => !existingIds.contains(m.id))
        .toList();
    final displayNames = <int, String>{};
    if (_usesExpressive) {
      final locale = Localizations.localeOf(context);
      for (final muscle in available) {
        try {
          displayNames[muscle.id] = await CatalogEntityLocalizer.instance
              .resolveName(
                CatalogEntityDisplayName(
                  catalogId: muscle.catalogId,
                  canonicalName: muscle.name,
                ),
                locale,
              );
        } catch (_) {
          displayNames[muscle.id] = muscle.name;
        }
      }
    }

    // 3) track selections
    final selectedIds = <int>{};
    final selectedCount = ValueNotifier<int>(0);
    var query = '';

    // 4) show dialog
    if (!mounted) return;
    final result = await showTonosDialog<Set<int>>(
      context: context,
      builder: (ctx) => TonosDialogFrame(
        child: AlertDialog(
          scrollable: _usesExpressive,
          insetPadding: _usesExpressive
              ? const EdgeInsets.symmetric(horizontal: 18, vertical: 10)
              : null,
          title: Text(_strings.exerciseEditorAddMuscles),
          content: SizedBox(
            width: double.maxFinite,
            // need StatefulBuilder to update the checkboxes
            child: StatefulBuilder(
              builder: (ctx2, setDialogState) {
                final filtered = _usesExpressive
                    ? available.where((m) {
                        final normalizedQuery = query.trim().toLowerCase();
                        return (displayNames[m.id] ?? m.name)
                                .toLowerCase()
                                .contains(normalizedQuery) ||
                            m.name.toLowerCase().contains(normalizedQuery);
                      }).toList()
                    : available;
                final listHeight = _selectionDialogListHeight(ctx2);
                Widget checkboxTile(Muscle m) {
                  final checked = selectedIds.contains(m.id);
                  final tile = CheckboxListTile(
                    title: LocalizedCatalogEntityName(
                      entity: CatalogEntityDisplayName(
                        catalogId: m.catalogId,
                        canonicalName: m.name,
                      ),
                    ),
                    value: checked,
                    selected: _usesExpressive && checked,
                    activeColor: _usesExpressive ? _expressiveHeroColor : null,
                    dense: _usesExpressive,
                    visualDensity: _usesExpressive
                        ? VisualDensity.compact
                        : null,
                    minVerticalPadding: _usesExpressive ? 2 : null,
                    controlAffinity: _usesExpressive
                        ? ListTileControlAffinity.leading
                        : null,
                    contentPadding: _usesExpressive
                        ? const EdgeInsets.symmetric(horizontal: 8)
                        : null,
                    onChanged: (on) => setDialogState(() {
                      if (on == true) {
                        selectedIds.add(m.id);
                      } else {
                        selectedIds.remove(m.id);
                      }
                      selectedCount.value = selectedIds.length;
                    }),
                  );
                  return _usesExpressive
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Material(
                            color: checked
                                ? _expressiveIdentitySurface(0)
                                      .withValues(alpha: 0.2)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: tile,
                          ),
                        )
                      : tile;
                }

                if (!_usesExpressive) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (_, index) => checkboxTile(filtered[index]),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: MaterialLocalizations.of(ctx2)
                            .searchFieldLabel,
                      ),
                      onChanged: (value) => setDialogState(() => query = value),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 6),
                        child: Text(
                          _strings.exerciseEditorSelectedCount(
                            selectedIds.length,
                          ),
                          style: _usesExpressive
                              ? Theme.of(ctx2).textTheme.labelMedium
                              : Theme.of(ctx2).textTheme.labelLarge,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: listHeight,
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (ctx3, i) {
                          return checkboxTile(filtered[i]);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text(_strings.commonCancel),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ValueListenableBuilder<int>(
              valueListenable: selectedCount,
              builder: (context, count, _) => _selectionDialogAddButton(
                onPressed: _usesExpressive && count == 0
                    ? null
                    : () => Navigator.of(ctx).pop(selectedIds),
              ),
            ),
          ],
        ),
      ),
    );
    selectedCount.dispose();

    // 5) merge them into the UI list
    if (result != null && result.isNotEmpty) {
      setState(() {
        for (final id in result) {
          final m = allMuscles.firstWhere((muscle) => muscle.id == id);
          _muscleEntries.add(<String, Object?>{
            'id': m.id,
            'name': m.name,
            'catalogId': m.catalogId,
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
    if (!mounted) return;
    final existing = _equipmentEntries.map((e) => e['id'] as int).toSet();
    final available = allEq.where((e) => !existing.contains(e.id)).toList();
    final displayNames = <int, String>{};
    if (_usesExpressive) {
      final locale = Localizations.localeOf(context);
      for (final equipment in available) {
        try {
          displayNames[equipment.id] = await CatalogEntityLocalizer.instance
              .resolveName(
                CatalogEntityDisplayName(
                  catalogId: equipment.catalogId,
                  canonicalName: equipment.name,
                ),
                locale,
              );
        } catch (_) {
          displayNames[equipment.id] = equipment.name;
        }
      }
    }
    final selectedIds = <int>{};
    final selectedCount = ValueNotifier<int>(0);
    var query = '';

    if (!mounted) return;
    final result = await showTonosDialog<Set<int>>(
      context: context,
      builder: (ctx) => TonosDialogFrame(
        child: AlertDialog(
          scrollable: _usesExpressive,
          insetPadding: _usesExpressive
              ? const EdgeInsets.symmetric(horizontal: 18, vertical: 10)
              : null,
          title: Text(_strings.exerciseEditorAddEquipment),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (ctx2, setState2) {
                final filtered = _usesExpressive
                    ? available.where((eq) {
                        final normalizedQuery = query.trim().toLowerCase();
                        return (displayNames[eq.id] ?? eq.name)
                                .toLowerCase()
                                .contains(normalizedQuery) ||
                            eq.name.toLowerCase().contains(normalizedQuery);
                      }).toList()
                    : available;
                final listHeight = _selectionDialogListHeight(ctx2);
                Widget checkboxTile(Equipment eq) {
                  final checked = selectedIds.contains(eq.id);
                  final tile = CheckboxListTile(
                    title: LocalizedCatalogEntityName(
                      entity: CatalogEntityDisplayName(
                        catalogId: eq.catalogId,
                        canonicalName: eq.name,
                      ),
                    ),
                    value: checked,
                    selected: _usesExpressive && checked,
                    activeColor: _usesExpressive ? _expressiveHeroColor : null,
                    dense: _usesExpressive,
                    visualDensity: _usesExpressive
                        ? VisualDensity.compact
                        : null,
                    minVerticalPadding: _usesExpressive ? 2 : null,
                    controlAffinity: _usesExpressive
                        ? ListTileControlAffinity.leading
                        : null,
                    contentPadding: _usesExpressive
                        ? const EdgeInsets.symmetric(horizontal: 8)
                        : null,
                    onChanged: (on) => setState2(() {
                      if (on == true) {
                        selectedIds.add(eq.id);
                      } else {
                        selectedIds.remove(eq.id);
                      }
                      selectedCount.value = selectedIds.length;
                    }),
                  );
                  return _usesExpressive
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Material(
                            color: checked
                                ? _expressiveIdentitySurface(2)
                                      .withValues(alpha: 0.2)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: tile,
                          ),
                        )
                      : tile;
                }

                if (!_usesExpressive) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (_, index) => checkboxTile(filtered[index]),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: MaterialLocalizations.of(ctx2)
                            .searchFieldLabel,
                      ),
                      onChanged: (value) => setState2(() => query = value),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 6),
                        child: Text(
                          _strings.exerciseEditorSelectedCount(
                            selectedIds.length,
                          ),
                          style: _usesExpressive
                              ? Theme.of(ctx2).textTheme.labelMedium
                              : Theme.of(ctx2).textTheme.labelLarge,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: listHeight,
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          return checkboxTile(filtered[i]);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(_strings.commonCancel),
            ),
            ValueListenableBuilder<int>(
              valueListenable: selectedCount,
              builder: (context, count, _) => _selectionDialogAddButton(
                onPressed: _usesExpressive && count == 0
                    ? null
                    : () => Navigator.of(ctx).pop(selectedIds),
              ),
            ),
          ],
        ),
      ),
    );
    selectedCount.dispose();

    if (result != null) {
      setState(() {
        for (var id in result) {
          final eq = allEq.firstWhere((e) => e.id == id);
          _equipmentEntries.add({
            'id': eq.id,
            'name': eq.name,
            'catalogId': eq.catalogId,
          });
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

  Widget _buildEditor() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final neo = context.usesNeoPresentation;
    final expressive = _usesExpressive;
    final destination = analyticsDestinationTokens(context);
    final tabSurface = expressive
        ? (theme.brightness == Brightness.dark
              ? const Color(0xFF293432)
              : const Color(0xFFF5E9DC))
        : destination?.surfacePrimary ??
              (neo
                  ? surfaces.settingsSection
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.34));
    final tabForeground = expressive
        ? scheme.onSurface
        : destination?.onSurfacePrimary ??
              (neo
                  ? tonosForegroundForSurface(context, tabSurface)
                  : scheme.onSurface);
    final tabSecondary = expressive
        ? scheme.onSurfaceVariant
        : destination?.onSurfacePrimary.withValues(alpha: 0.82) ??
              (neo
                  ? tonosSecondaryForegroundForSurface(context, tabSurface)
                  : scheme.onSurfaceVariant);
    final tabLabelStyle = theme.textTheme.labelLarge?.copyWith(fontSize: 14);
    return ListView(
      padding: const EdgeInsets.only(bottom: 112),
      children: [
        if (expressive)
          _buildEditorHeader()
        else
          AnalyticsZone(
            role: AnalyticsSurfaceRole.primary,
            padding: const EdgeInsets.all(6),
            child: _buildEditorHeader(),
          ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          decoration: BoxDecoration(
            color: tabSurface,
            borderRadius: shapes.profileTile,
            border: expressive
                ? Border.all(
                    color: _expressiveHeroColor.withValues(alpha: 0.24),
                    width: shapes.outlineWidth,
                  )
                : destination != null
                ? Border.all(
                    color: destination.outlineAccent,
                    width: shapes.outlineWidth,
                  )
                : neo
                ? Border.all(
                    color: tonosOutlineForSurface(context, tabSurface),
                    width: shapes.outlineWidth,
                  )
                : null,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              final compactTabs =
                  expressive &&
                  (constraints.maxWidth < 360 || textScale >= 1.3);
              if (compactTabs) {
                return _buildCompactEditorTabs(constraints.maxWidth);
              }
              return TabBar(
                controller: _tabController,
                onTap: (index) => setState(() => _activeTabIndex = index),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                labelStyle: tabLabelStyle,
                unselectedLabelStyle: tabLabelStyle,
                indicator: BoxDecoration(
                  color: expressive
                      ? _expressiveIdentitySurface(_activeTabIndex)
                      : destination?.surfaceSelected ??
                            (neo
                                ? surfaces.dialogChoice
                                : SettingsAccent.advanced.withValues(
                                    alpha: 0.20,
                                  )),
                  borderRadius: shapes.settingsTabIndicator,
                ),
                labelColor: expressive
                    ? _expressiveIdentityForeground(_activeTabIndex)
                    : destination?.onSurfaceSelected ??
                          (neo ? tabForeground : SettingsAccent.advanced),
                unselectedLabelColor: tabSecondary,
                tabs: [
                  _editorTab(
                    Icons.fitness_center,
                    _strings.exerciseEditorMuscles,
                    0,
                    tabSecondary,
                  ),
                  _editorTab(
                    Icons.accessibility_new,
                    _strings.exerciseEditorBodyparts,
                    1,
                    tabSecondary,
                  ),
                  _editorTab(
                    Icons.precision_manufacturing_outlined,
                    _strings.exerciseEditorEquipment,
                    2,
                    tabSecondary,
                  ),
                  _editorTab(
                    Icons.menu_book_outlined,
                    _strings.exerciseEditorGuide,
                    3,
                    tabSecondary,
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: _isLoadingDetails
              ? const Padding(
                  padding: EdgeInsets.only(top: 64),
                  child: Center(child: CircularProgressIndicator()),
                )
              : destination == null || _usesExpressive
              ? _buildCurrentTab()
              : AnalyticsZone(
                  role: switch (_activeTabIndex) {
                    0 => AnalyticsSurfaceRole.secondary,
                    1 => AnalyticsSurfaceRole.tertiary,
                    2 => AnalyticsSurfaceRole.accent,
                    _ => AnalyticsSurfaceRole.selected,
                  },
                  padding: const EdgeInsets.all(14),
                  borderRadius: 26,
                  outlined: true,
                  child: _buildCurrentTab(),
                ),
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

  Widget _editorTab(
    IconData icon,
    String label,
    int index,
    Color unselectedForeground,
  ) => Tab(
    height: _usesExpressive ? 64 : null,
    child: _usesExpressive
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(height: 3),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _activeTabIndex == index
                        ? _expressiveIdentityForeground(index)
                        : unselectedForeground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          )
        : Text(label),
  );

  Widget _buildCompactEditorTabs(double maxWidth) {
    final labels = [
      _strings.exerciseEditorMuscles,
      _strings.exerciseEditorBodyparts,
      _strings.exerciseEditorEquipment,
      _strings.exerciseEditorGuide,
    ];
    final icons = [
      Icons.fitness_center,
      Icons.accessibility_new,
      Icons.precision_manufacturing_outlined,
      Icons.menu_book_outlined,
    ];
    final width = (maxWidth - 24) / 2;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var index = 0; index < labels.length; index++)
            Semantics(
              selected: _activeTabIndex == index,
              child: SizedBox(
                width: width,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _tabController.animateTo(index);
                    setState(() => _activeTabIndex = index);
                  },
                  icon: Icon(icons[index]),
                  label: Text(labels[index], textAlign: TextAlign.start),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    foregroundColor: _activeTabIndex == index
                        ? _expressiveIdentityForeground(index)
                        : Theme.of(context).colorScheme.onSurface,
                    backgroundColor: _activeTabIndex == index
                        ? _expressiveIdentitySurface(index)
                        : Colors.transparent,
                    minimumSize: const Size(48, 56),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    side: BorderSide(
                      color: _activeTabIndex == index
                          ? _expressiveIdentityForeground(index)
                                .withValues(alpha: 0.24)
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
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

  Future<void> _createCustomExercise() async {
    if (_isEditing || _isSaving) return;

    var exerciseName = '';
    var selectedEquipmentId = 0;
    final formKey = GlobalKey<FormState>();
    final draft = await showTonosDialog<_CustomExerciseDraft>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final mediaQuery = MediaQuery.of(context);
          final usableHeight =
              mediaQuery.size.height - mediaQuery.viewInsets.bottom;
          return TonosDialogFrame(
            styleFormControls: true,
            styleDarkNeoPickerSurfaces: true,
            child: AlertDialog(
              title: Text(_strings.exerciseEditorCreateCustomTitle),
              content: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: usableHeight * 0.48),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_strings.exerciseEditorCreateCustomBody),
                      const SizedBox(height: 14),
                      Form(
                        key: formKey,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          autofocus: true,
                          decoration: _usesExpressive
                              ? settingsFieldDecoration(
                                  context,
                                  label: _strings.exerciseEditorExerciseName,
                                ).copyWith(
                                  filled: true,
                                  fillColor:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF202927)
                                      : const Color(0xFFFFFCF8),
                                )
                              : InputDecoration(
                                  labelText:
                                      _strings.exerciseEditorExerciseName,
                                ),
                          validator: (value) => _trimToNull(value) == null
                              ? _strings.gymProfileNameRequired
                              : null,
                          onChanged: (value) => exerciseName = value,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCustomEquipmentChoice(
                        dialogContext: context,
                        selectedEquipmentId: selectedEquipmentId,
                        onChanged: (value) =>
                            setDialogState(() => selectedEquipmentId = value),
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
                    if (formKey.currentState?.validate() != true) return;
                    final name = exerciseName.trim();
                    Navigator.of(context).pop(
                      _CustomExerciseDraft(
                        name: name,
                        primaryEquipmentId: selectedEquipmentId == 0
                            ? null
                            : selectedEquipmentId,
                      ),
                    );
                  },
                  child: Text(_strings.healthCreate),
                ),
              ],
            ),
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

  Widget _buildCustomEquipmentChoice({
    required BuildContext dialogContext,
    required int selectedEquipmentId,
    required ValueChanged<int> onChanged,
  }) {
    if (!_usesExpressive) {
      return DropdownButtonFormField<int>(
        initialValue: selectedEquipmentId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: _strings.exerciseEditorEquipment,
        ),
        items: [
          DropdownMenuItem(
            value: 0,
            child: Text(_strings.exerciseEditorNoEquipmentChoice),
          ),
          ..._allEquipment.map(
            (equipment) => DropdownMenuItem(
              value: equipment.id,
              child: LocalizedCatalogEntityName(
                entity: CatalogEntityDisplayName(
                  catalogId: equipment.catalogId,
                  canonicalName: equipment.name,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (value) => onChanged(value ?? 0),
      );
    }

    final media = MediaQuery.of(dialogContext);
    final screenSize = media.size;
    final width = math
        .max(
          0.0,
          math.min(512.0, screenSize.width - media.padding.horizontal - 128),
        )
        .toDouble();
    final availableHeight = math.max(
      0.0,
      screenSize.height -
          media.padding.vertical -
          media.viewInsets.vertical -
          24,
    );
    final menuMaxHeight = math
        .min(availableHeight, screenSize.height * 0.48)
        .toDouble();
    final tokens = analyticsDestinationTokens(dialogContext);
    Equipment? selectedEquipment;
    for (final equipment in _allEquipment) {
      if (equipment.id == selectedEquipmentId) {
        selectedEquipment = equipment;
        break;
      }
    }
    final selectedLabel = selectedEquipment == null
        ? _strings.exerciseEditorNoEquipmentChoice
        : selectedEquipment.name;

    return MenuAnchor(
      key: const ValueKey('exercise-editor-equipment-choice'),
      useRootOverlay: true,
      consumeOutsideTap: true,
      crossAxisUnconstrained: false,
      style: MenuStyle(
        alignment: AlignmentDirectional.bottomStart,
        backgroundColor: WidgetStatePropertyAll(
          tokens?.surfaceAccent ?? Theme.of(context).colorScheme.surface,
        ),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(2),
        side: WidgetStatePropertyAll(
          BorderSide(
            color:
                tokens?.outlineAccent ??
                Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
        minimumSize: WidgetStatePropertyAll(Size(width, 0)),
        maximumSize: WidgetStatePropertyAll(Size(width, menuMaxHeight)),
      ),
      menuChildren: [
        MenuItemButton(
          key: const ValueKey('exercise-editor-equipment-none'),
          style: _equipmentMenuItemStyle(
            selected: selectedEquipmentId == 0,
            tokens: tokens,
          ),
          leadingIcon: selectedEquipmentId == 0
              ? const Icon(Icons.check)
              : const SizedBox(width: 24),
          onPressed: () => onChanged(0),
          child: SizedBox(
            width: math.max(0.0, width - 56).toDouble(),
            child: Text(
              _strings.exerciseEditorNoEquipmentChoice,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        for (final equipment in _allEquipment)
          MenuItemButton(
            key: ValueKey('exercise-editor-equipment-${equipment.id}'),
            style: _equipmentMenuItemStyle(
              selected: selectedEquipmentId == equipment.id,
              tokens: tokens,
            ),
            leadingIcon: selectedEquipmentId == equipment.id
                ? const Icon(Icons.check)
                : const SizedBox(width: 24),
            onPressed: () => onChanged(equipment.id),
            child: SizedBox(
              width: math.max(0.0, width - 56).toDouble(),
              child: LocalizedCatalogEntityName(
                entity: CatalogEntityDisplayName(
                  catalogId: equipment.catalogId,
                  canonicalName: equipment.name,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
      builder: (context, controller, child) => PopScope<Object?>(
        canPop: !controller.isOpen,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && controller.isOpen) controller.close();
        },
        child: Semantics(
          button: true,
          enabled: true,
          expanded: controller.isOpen,
          label: _strings.exerciseEditorEquipment,
          value: selectedLabel,
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: ExcludeSemantics(
            child: SizedBox(
              width: width,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () =>
                    controller.isOpen ? controller.close() : controller.open(),
                child: InputDecorator(
                  decoration:
                      settingsFieldDecoration(
                        context,
                        label: _strings.exerciseEditorEquipment,
                      ).copyWith(
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF202927)
                            : const Color(0xFFFFFCF8),
                        suffixIcon: Icon(
                          Icons.arrow_drop_down,
                          color:
                              tokens?.onSurfaceAccent ??
                              Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                  isFocused: controller.isOpen,
                  isEmpty: false,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: DefaultTextStyle.merge(
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color:
                            tokens?.onSurfaceAccent ??
                            Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: selectedEquipment == null
                          ? Text(_strings.exerciseEditorNoEquipmentChoice)
                          : LocalizedCatalogEntityName(
                              entity: CatalogEntityDisplayName(
                                catalogId: selectedEquipment.catalogId,
                                canonicalName: selectedEquipment.name,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _equipmentMenuItemStyle({
    required bool selected,
    required AppExpressiveDestinationTokens? tokens,
  }) => ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    backgroundColor: WidgetStatePropertyAll(
      selected
          ? tokens?.surfaceSelected ?? _expressiveIdentitySurface(1)
          : Colors.transparent,
    ),
    foregroundColor: WidgetStatePropertyAll(
      selected
          ? tokens?.onSurfaceSelected ?? _expressiveIdentityForeground(1)
          : tokens?.onSurfaceAccent ?? Theme.of(context).colorScheme.onSurface,
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildPickerLanding() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        _buildTitleCard(),
        const SizedBox(height: 16),
        _buildEditorInfoCard(
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
          style: _usesExpressive
              ? FilledButton.styleFrom(
                  backgroundColor: _expressiveHeroColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _isSaving ? null : _createCustomExercise,
          icon: const Icon(Icons.add),
          label: Text(_strings.exerciseEditorCreateCustomTitle),
          style: _usesExpressive
              ? OutlinedButton.styleFrom(
                  foregroundColor: _expressiveHeroForeground,
                  minimumSize: const Size.fromHeight(50),
                  side: BorderSide(color: _expressiveHeroForeground),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildTitleCard() {
    final theme = Theme.of(context);
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    if (_usesExpressive) {
      return Container(
        key: const ValueKey('exercise-editor-expressive-title-hero'),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 19),
        decoration: BoxDecoration(
          color: _expressiveHeroColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(26),
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.edit_note, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _strings.exerciseEditorTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _strings.exerciseEditorHeroDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: context.usesExpressivePresentation
            ? ExpressiveTrainShapes.focusHero
            : shapes.settingsTitleCard,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SettingsAccent.advanced.withValues(alpha: 0.26),
            surfaces.settingsHero,
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

  Widget _buildEditorInfoCard({
    required IconData icon,
    required String title,
    required String body,
    required Color iconColor,
  }) {
    if (!_usesExpressive) {
      return SettingsInfoCard(
        icon: icon,
        title: title,
        body: body,
        iconColor: iconColor,
      );
    }
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final identity = _expressiveIdentitySurface(_activeTabIndex);
    final surface = dark ? const Color(0xFF252F2D) : const Color(0xFFFFFAF4);
    final foreground = theme.colorScheme.onSurface;
    final secondary = theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(
          color: identity.withValues(alpha: dark ? 0.62 : 0.9),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: identity.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: _expressiveIdentityHeadingColor(_activeTabIndex),
              size: 21,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(color: secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpressiveSelectedActions() {
    final foreground = _expressiveHeroForeground;
    final style = OutlinedButton.styleFrom(
      foregroundColor: foreground,
      side: BorderSide(color: foreground.withValues(alpha: 0.62)),
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
    final chooseButton = OutlinedButton.icon(
      key: const ValueKey('exercise-editor-choose-action'),
      onPressed: _isSaving ? null : _openCatalogPicker,
      icon: const Icon(Icons.search),
      label: Text(_strings.exerciseEditorChoose, textAlign: TextAlign.center),
      style: style,
    );
    final editButton = OutlinedButton.icon(
      key: const ValueKey('exercise-editor-edit-action'),
      onPressed: _isSaving ? null : _startEditing,
      icon: const Icon(Icons.edit_outlined),
      label: Text(_strings.exerciseEditorEdit, textAlign: TextAlign.center),
      style: style,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackActions =
            constraints.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.15;
        if (stackActions) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [chooseButton, const SizedBox(height: 8), editButton],
          );
        }
        return Row(
          children: [
            Expanded(child: chooseButton),
            const SizedBox(width: 8),
            Expanded(child: editButton),
          ],
        );
      },
    );
  }

  Widget _buildEditorHeader() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final neo = context.usesNeoPresentation;
    final expressive = _usesExpressive;
    final destination = analyticsDestinationTokens(context);
    final headerSurface = expressive
        ? _expressivePeachColor
        : destination?.surfaceSecondary ??
              (neo
                  ? surfaces.settingsSection
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.34));
    final headerForeground = expressive
        ? _expressivePeachForeground
        : destination?.onSurfaceSecondary ??
              (neo
                  ? tonosForegroundForSurface(context, headerSurface)
                  : scheme.onSurface);
    final selected = _selectedDef!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          _buildTitleCard(),
          if (expressive && !_isEditing) ...[
            const SizedBox(height: 8),
            _buildExpressiveSelectedActions(),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: headerSurface,
              borderRadius: shapes.profileTile,
              border: Border.all(
                color: expressive
                    ? _expressivePeachForeground.withValues(alpha: 0.16)
                    : destination?.outlineAccent ??
                          (neo
                              ? tonosOutlineForSurface(context, headerSurface)
                              : SettingsAccent.advanced.withValues(
                                  alpha: 0.42,
                                )),
                width: shapes.outlineWidth,
              ),
            ),
            child: _isEditing
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final stackRating =
                          constraints.maxWidth < 430 ||
                          MediaQuery.textScalerOf(context).scale(1) > 1.15;
                      final nameField = TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: settingsInputTextStyle(context),
                        decoration: settingsFieldDecoration(
                          context,
                          label: _strings.exerciseEditorExerciseName,
                          isDense: true,
                        ),
                        onChanged: (_) => _markChanged(),
                      );
                      final ratingField = SizedBox(
                        width: stackRating ? double.infinity : 132,
                        child: TextField(
                          controller: _ratingController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                            signed: false,
                          ),
                          style: settingsInputTextStyle(context),
                          decoration: settingsFieldDecoration(
                            context,
                            label: _strings.exerciseEditorRating,
                            suffixText: '/100',
                            isDense: true,
                          ),
                          onChanged: (_) => _markChanged(),
                        ),
                      );
                      if (stackRating) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            nameField,
                            const SizedBox(height: 10),
                            ratingField,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: nameField),
                          const SizedBox(width: 12),
                          ratingField,
                        ],
                      );
                    },
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          selected.name,
                          maxLines: expressive ? null : 1,
                          overflow: expressive ? null : TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: headerForeground,
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
                          color: expressive
                              ? (theme.brightness == Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.white.withValues(alpha: 0.62))
                              : destination?.surfaceSelected ??
                                    (neo
                                        ? surfaces.dialogChoice
                                        : SettingsAccent.advanced.withValues(
                                            alpha: 0.16,
                                          )),
                          borderRadius: shapes.control,
                        ),
                        child: Text(
                          '${selected.rating}/100',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: expressive
                                ? headerForeground
                                : destination?.onSurfaceSelected ??
                                      (neo
                                          ? headerForeground
                                          : SettingsAccent.advanced),
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
    final shapes = context.shapeTokens;
    final neo = context.usesNeoPresentation;
    final destination = analyticsDestinationTokens(context);
    final surface = _usesExpressive
        ? _expressiveIdentitySurface(_activeTabIndex)
        : destination?.surfaceAccent ??
              (neo
                  ? context.surfaceTokens.settingsSection
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.34));
    final foreground = _usesExpressive
        ? _expressiveIdentityForeground(_activeTabIndex)
        : destination?.onSurfaceAccent ??
              (neo
                  ? tonosForegroundForSurface(context, surface)
                  : scheme.onSurface);
    final secondary = _usesExpressive
        ? foreground.withValues(alpha: 0.82)
        : destination?.onSurfaceAccent.withValues(alpha: 0.78) ??
              (neo
                  ? tonosSecondaryForegroundForSurface(context, surface)
                  : scheme.onSurfaceVariant);
    return Material(
      color: surface,
      borderRadius: shapes.settingsPanel,
      child: InkWell(
        borderRadius: shapes.settingsPanel,
        onTap: _openAllocation,
        child: Padding(
          padding: EdgeInsets.all(_usesExpressive ? 10 : 14),
          child: Row(
            children: [
              Container(
                width: _usesExpressive ? 36 : 42,
                height: _usesExpressive ? 36 : 42,
                decoration: BoxDecoration(
                  color: _usesExpressive
                      ? foreground.withValues(alpha: 0.12)
                      : destination?.surfaceSelected ??
                            SettingsAccent.advanced.withValues(alpha: 0.16),
                  borderRadius: shapes.settingsAction,
                ),
                child: Icon(
                  Icons.tune,
                  color: _usesExpressive
                      ? foreground
                      : destination?.onSurfaceSelected ??
                            SettingsAccent.advanced,
                ),
              ),
              SizedBox(width: _usesExpressive ? 9 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isEditing
                          ? 'Save or cancel definition changes first.'
                          : body,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: secondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: secondary),
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
    final shouldRemove = await showTonosDialog<bool>(
      context: context,
      builder: (context) => TonosDialogFrame(
        child: AlertDialog(
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
      ),
    );
    return shouldRemove ?? false;
  }

  Widget _buildMusclesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditorInfoCard(
          icon: Icons.fitness_center,
          title: _strings.exerciseEditorMuscleOrderTitle,
          body: _strings.exerciseEditorMuscleOrderBody,
          iconColor: SettingsAccent.training,
        ),
        SizedBox(height: _usesExpressive ? 8 : 14),
        _buildAllocationShortcut(
          title: _strings.exerciseEditorExactSetCredit,
          body: _strings.exerciseEditorExactSetCreditBody,
        ),
        if (_isEditing) ...[
          const SizedBox(height: 12),
          SettingsSection(
            title: _strings.exerciseEditorSetCreditScaling,
            subtitle: _strings.exerciseEditorSetCreditScalingBody,
            accentColor: _usesExpressive
                ? _expressiveIdentitySurface(0)
                : SettingsAccent.advanced,
            titleColor: _usesExpressive
                ? _expressiveIdentityHeadingColor(0)
                : null,
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
        SizedBox(height: _usesExpressive ? 10 : 16),
        SettingsSection(
          title: _strings.exerciseEditorTargetMuscles,
          subtitle: _isEditing
              ? _strings.exerciseEditorOrderMusclesHint
              : _strings.exerciseEditorMusclesAssociated(_muscleEntries.length),
          accentColor: _usesExpressive
              ? _expressiveIdentitySurface(0)
              : SettingsAccent.training,
          titleColor: _usesExpressive
              ? _expressiveIdentityHeadingColor(0)
              : null,
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
              _editorInlineAddAction(
                onPressed: _openAddMuscleDialog,
                label: _strings.exerciseEditorAddTargetMuscles,
                identityIndex: 0,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMuscleTile(int index) {
    final entry = _muscleEntries[index];
    final name = entry['name'] as String;
    final catalogId = entry['catalogId'] as String?;
    final leading = Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _usesExpressive
            ? _expressiveIdentitySurface(0).withValues(alpha: 0.72)
            : SettingsAccent.training.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Text(
        '${index + 1}',
        style: TextStyle(
          color: _usesExpressive ? _expressiveIdentityForeground(0) : null,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
    final title = LocalizedCatalogEntityName(
      entity: CatalogEntityDisplayName(
        catalogId: catalogId,
        canonicalName: name,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    if (_usesExpressive && _isEditing) {
      Future<void> removeMuscle() async {
        var displayName = name;
        try {
          displayName = await CatalogEntityLocalizer.instance.resolveName(
            CatalogEntityDisplayName(catalogId: catalogId, canonicalName: name),
            Localizations.localeOf(context),
          );
        } catch (_) {
          displayName = name;
        }
        if (!mounted ||
            !await _confirmRemove(
              displayName,
              _strings.exerciseEditorMuscleItem,
            )) {
          return;
        }
        setState(() {
          _muscleEntries.removeAt(index);
          _hasPendingChanges = true;
        });
      }

      Widget actionButton({
        required String tooltip,
        required IconData icon,
        required VoidCallback? onPressed,
      }) => SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, size: 21),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          visualDensity: VisualDensity.compact,
        ),
      );

      final actions = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionButton(
            tooltip: _strings.exerciseEditorMoveUp,
            icon: Icons.keyboard_arrow_up,
            onPressed: index == 0
                ? null
                : () => setState(() {
                    final previous = _muscleEntries[index - 1];
                    _muscleEntries[index - 1] = entry;
                    _muscleEntries[index] = previous;
                    _hasPendingChanges = true;
                  }),
          ),
          actionButton(
            tooltip: _strings.exerciseEditorMoveDown,
            icon: Icons.keyboard_arrow_down,
            onPressed: index == _muscleEntries.length - 1
                ? null
                : () => setState(() {
                    final next = _muscleEntries[index + 1];
                    _muscleEntries[index + 1] = entry;
                    _muscleEntries[index] = next;
                    _hasPendingChanges = true;
                  }),
          ),
          actionButton(
            tooltip: _strings.exerciseEditorRemoveMuscle,
            icon: Icons.delete_outline,
            onPressed: removeMuscle,
          ),
        ],
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final oneLine = constraints.maxWidth >= 350 && textScale < 1.3;
          final rowContent = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 36, height: 36, child: Center(child: leading)),
              const SizedBox(width: 8),
              Expanded(child: title),
              actions,
            ],
          );
          return Padding(
            key: ValueKey('exercise-editor-muscle-row-${entry['id']}'),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: oneLine
                ? ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: rowContent,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 36,
                            height: 38,
                            child: Center(child: leading),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: title),
                        ],
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: actions,
                      ),
                    ],
                  ),
          );
        },
      );
    }

    final actionItems = <Widget>[
      IconButton(
        tooltip: _strings.exerciseEditorMoveUp,
        onPressed: index == 0
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
        onPressed: index == _muscleEntries.length - 1
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
          var displayName = name;
          try {
            displayName = await CatalogEntityLocalizer.instance.resolveName(
              CatalogEntityDisplayName(
                catalogId: catalogId,
                canonicalName: name,
              ),
              Localizations.localeOf(context),
            );
          } catch (_) {
            displayName = name;
          }
          if (!mounted) return;
          if (!await _confirmRemove(
            displayName,
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
    ];
    final actions = Row(mainAxisSize: MainAxisSize.min, children: actionItems);
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: _usesExpressive ? 0 : 4,
      ),
      minTileHeight: _usesExpressive ? 48 : null,
      visualDensity: _usesExpressive ? VisualDensity.compact : null,
      leading: leading,
      title: title,
      trailing: _isEditing ? actions : null,
    );
  }

  /// Mirrors the old _buildMusclesTab list, but showing “sets” instead of “%”.
  Widget _buildBodypartsTab() {
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditorInfoCard(
          icon: Icons.accessibility_new,
          title: _strings.exerciseEditorAssociatedBodyparts,
          body: _strings.exerciseEditorAssociatedBodypartsBody,
          iconColor: SettingsAccent.training,
        ),
        SizedBox(height: _usesExpressive ? 8 : 14),
        _buildAllocationShortcut(
          title: _strings.exerciseEditorExactBodypartCredit,
          body: _strings.exerciseEditorExactBodypartCreditBody,
        ),
        SizedBox(height: _usesExpressive ? 10 : 16),
        SettingsSection(
          title: _strings.exerciseEditorAssociatedBodyparts,
          subtitle: _isEditing
              ? _strings.exerciseEditorBodypartsHint
              : _strings.exerciseEditorBodypartsAssociated(
                  _bodyManualEntries.length,
                ),
          accentColor: _usesExpressive
              ? _expressiveIdentitySurface(1)
              : SettingsAccent.training,
          titleColor: _usesExpressive
              ? _expressiveIdentityHeadingColor(1)
              : null,
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
              _editorInlineAddAction(
                onPressed: _openAddBodypartDialog,
                label: _strings.exerciseEditorAddBodyparts,
                identityIndex: 1,
              ),
          ],
        ),
        if (_bodyAutoEntries.isNotEmpty) ...[
          SizedBox(height: _usesExpressive ? 10 : 16),
          SettingsSection(
            title: _strings.exerciseEditorAutomaticPreview,
            subtitle: _strings.exerciseEditorAutomaticPreviewBody,
            accentColor: _usesExpressive
                ? _expressiveIdentitySurface(1)
                : SettingsAccent.progress,
            titleColor: _usesExpressive
                ? _expressiveIdentityHeadingColor(1)
                : null,
            children: [
              for (final entry in _bodyAutoEntries)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 0,
                  ),
                  minTileHeight: _usesExpressive ? 48 : null,
                  visualDensity: _usesExpressive ? VisualDensity.compact : null,
                  leading: const Icon(Icons.auto_graph),
                  title: Text(
                    localizedBodyPartName(context, entry['name'] as String),
                  ),
                  trailing: Text(
                    LocalizedFormatters.number(
                      entry['count'] as double,
                      locale,
                      minimumFractionDigits: 2,
                      maximumFractionDigits: 2,
                    ),
                  ),
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
    final displayName = localizedBodyPartName(context, name);
    final shapes = context.shapeTokens;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: _usesExpressive ? 0 : 4,
      ),
      minTileHeight: _usesExpressive ? 52 : null,
      visualDensity: _usesExpressive ? VisualDensity.compact : null,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _usesExpressive
              ? _expressiveIdentitySurface(1).withValues(alpha: 0.72)
              : SettingsAccent.training.withValues(alpha: 0.14),
          borderRadius: shapes.control,
        ),
        child: Icon(
          Icons.accessibility_new,
          color: _usesExpressive
              ? _expressiveIdentityHeadingColor(1)
              : SettingsAccent.training,
        ),
      ),
      title: Text(displayName),
      trailing: !_isEditing
          ? null
          : IconButton(
              tooltip: _strings.exerciseEditorRemoveBodypart,
              onPressed: () async {
                if (!await _confirmRemove(
                  displayName,
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

  Widget _buildEquipmentTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditorInfoCard(
          icon: Icons.precision_manufacturing_outlined,
          title: _strings.exerciseEditorAvailableEquipment,
          body: _strings.exerciseEditorAvailableEquipmentBody,
          iconColor: SettingsAccent.training,
        ),
        SizedBox(height: _usesExpressive ? 10 : 16),
        SettingsSection(
          title: _strings.exerciseEditorEquipment,
          subtitle: _isEditing
              ? _strings.exerciseEditorEquipmentHint
              : _strings.exerciseEditorEquipmentAssociated(
                  _equipmentEntries.length,
                ),
          accentColor: _usesExpressive
              ? _expressiveIdentitySurface(2)
              : SettingsAccent.training,
          titleColor: _usesExpressive
              ? _expressiveIdentityHeadingColor(2)
              : null,
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
              _editorInlineAddAction(
                onPressed: _openAddEquipmentDialog,
                label: _strings.exerciseEditorAddEquipment,
                identityIndex: 2,
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
    final catalogId = entry['catalogId'] as String?;
    final shapes = context.shapeTokens;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: _usesExpressive ? 0 : 4,
      ),
      minTileHeight: _usesExpressive ? 52 : null,
      visualDensity: _usesExpressive ? VisualDensity.compact : null,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: SettingsAccent.training.withValues(alpha: 0.14),
          borderRadius: shapes.settingsIcon,
        ),
        child: const Icon(
          Icons.precision_manufacturing_outlined,
          color: SettingsAccent.training,
        ),
      ),
      title: LocalizedCatalogEntityName(
        entity: CatalogEntityDisplayName(
          catalogId: catalogId,
          canonicalName: equipmentName,
        ),
      ),
      trailing: !_isEditing
          ? null
          : IconButton(
              tooltip: _strings.exerciseEditorRemoveEquipment,
              onPressed: () async {
                var displayName = equipmentName;
                try {
                  displayName = await CatalogEntityLocalizer.instance
                      .resolveName(
                        CatalogEntityDisplayName(
                          catalogId: catalogId,
                          canonicalName: equipmentName,
                        ),
                        Localizations.localeOf(context),
                      );
                } catch (_) {
                  displayName = equipmentName;
                }
                if (!mounted) return;
                if (!await _confirmRemove(
                  displayName,
                  _strings.exerciseEditorEquipmentItem,
                )) {
                  return;
                }
                if (!mounted) return;
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
    final formKey = GlobalKey<FormState>();

    final result = await showTonosDialog<ExerciseMediaItem>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setDialogState) {
            return TonosDialogFrame(
              styleFormControls: true,
              styleDarkNeoPickerSurfaces: true,
              child: AlertDialog(
                title: Text(
                  initial == null
                      ? _strings.exerciseEditorAddMedia
                      : _strings.exerciseEditorEditMedia,
                ),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: mediaType,
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
                        TonosFormField(
                          initialValue: titleValue,
                          labelText: _strings.exerciseEditorMediaTitle,
                          hintText: _strings.exerciseEditorMediaTitleHint,
                          onChanged: (value) => titleValue = value,
                        ),
                        const SizedBox(height: 12),
                        TonosFormField(
                          initialValue: remoteUrlValue,
                          labelText: _strings.exerciseEditorMediaRemoteUrl,
                          hintText: 'https://...',
                          onChanged: (value) => remoteUrlValue = value,
                          validator: (value) => _trimToNull(value) == null
                              ? _strings.exerciseEditorMediaUrlRequired
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TonosFormField(
                          initialValue: thumbnailUrlValue,
                          labelText: _strings.exerciseEditorMediaThumbnailUrl,
                          hintText: _strings.exerciseEditorMediaThumbnailHint,
                          onChanged: (value) => thumbnailUrlValue = value,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(_strings.commonCancel),
                  ),
                  TextButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() != true) return;
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
              ),
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
        _buildEditorInfoCard(
          icon: Icons.menu_book_outlined,
          title: _strings.exerciseEditorFormGuide,
          body: _strings.exerciseEditorFormGuideBody,
          iconColor: SettingsAccent.advanced,
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: _strings.exerciseEditorGuidance,
          subtitle: _isEditing
              ? _strings.exerciseEditorGuidanceEditing
              : _strings.exerciseEditorGuidanceReadOnly,
          accentColor: _usesExpressive
              ? _expressiveIdentitySurface(3)
              : SettingsAccent.advanced,
          titleColor: _usesExpressive
              ? _expressiveIdentityHeadingColor(3)
              : null,
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
        _buildEditorInfoCard(
          icon: Icons.cloud_sync_outlined,
          title: _strings.exerciseEditorReferenceMedia,
          body: _strings.exerciseEditorReferenceMediaBody,
          iconColor: SettingsAccent.data,
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: _strings.exerciseEditorMediaLinks,
          subtitle: _isEditing
              ? _strings.exerciseEditorMediaLinksEditing
              : _strings.exerciseEditorMediaLinksCount(_mediaItems.length),
          accentColor: _usesExpressive
              ? _expressiveIdentitySurface(3)
              : SettingsAccent.data,
          titleColor: _usesExpressive
              ? _expressiveIdentityHeadingColor(3)
              : null,
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
              _editorInlineAddAction(
                onPressed: _openAddMediaDialog,
                label: _strings.exerciseEditorAddMediaLink,
                identityIndex: 3,
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
    final theme = Theme.of(context);
    if (_usesExpressive && !_isEditing) {
      final value = controller.text.trim();
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF202927)
                    : const Color(0xFFFFFCF8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.32,
                  ),
                ),
              ),
              child: Text(
                value.isEmpty ? hint : value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: value.isEmpty
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final decoration = settingsFieldDecoration(
      context,
      label: _usesExpressive ? '' : label,
      hint: hint,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _usesExpressive ? 12 : 14,
        _usesExpressive ? 8 : 12,
        _usesExpressive ? 12 : 14,
        4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_usesExpressive) ...[
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Semantics(
            label: _usesExpressive ? label : null,
            child: TextField(
              controller: controller,
              readOnly: !_isEditing,
              minLines: 3,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              style: _usesExpressive ? theme.textTheme.bodyMedium : null,
              decoration: _usesExpressive
                  ? InputDecoration(
                      hintText: hint,
                      filled: true,
                      fillColor: theme.brightness == Brightness.dark
                          ? const Color(0xFF202927)
                          : const Color(0xFFFFFCF8),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.32,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.32,
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: _expressiveHeroColor,
                          width: 1.5,
                        ),
                      ),
                    )
                  : decoration,
              onChanged: _isEditing ? (_) => _markChanged() : null,
            ),
          ),
        ],
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
      compact: _usesExpressive,
      compactVerticalPadding: 3,
      trailing: _isEditing
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
}
