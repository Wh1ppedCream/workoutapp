// File: lib/screens/exercise/gym_profile_screen.dart

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../l10n/safe_failure_localizations.dart';
import '../../models/content_models.dart';
import '../../models/gym_models.dart';
import '../../providers/selected_profile.dart';
import '../../repositories/app_repository.dart';
import '../../services/catalog_entity_localizer.dart';
import '../../services/tutorial_state_store.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/expressive_planning_tokens.dart';
import '../../theme/widgets/tonos_dialog.dart';
import '../../utils/tutorial_launcher.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/localized_catalog_entity_name.dart';
import '../../widgets/shared_entity_media_thumbnail.dart';
import '../../widgets/settings_tiles.dart';

/// Profile edits returned to onboarding before the real profile is created.
class GymProfileDraft {
  final String name;
  final Set<String> equipmentNames;

  const GymProfileDraft({required this.name, required this.equipmentNames});
}

/// Creates or edits a workout space and the equipment available in that space.
class GymProfileScreen extends StatefulWidget {
  final GymProfile? profile;
  final String? initialName;
  final Set<String> initialEquipmentNames;
  final bool returnDraftOnly;
  final String? title;

  const GymProfileScreen({
    super.key,
    this.profile,
    this.initialName,
    this.initialEquipmentNames = const <String>{},
    this.returnDraftOnly = false,
    this.title,
  });

  @override
  State<GymProfileScreen> createState() => _GymProfileScreenState();
}

class _GymProfileScreenState extends State<GymProfileScreen> {
  AppRepository get _repo => context.read<AppRepository>();

  final _formKey = GlobalKey<FormState>();
  final _profileTutorialKey = GlobalKey(debugLabel: 'gym_profile_profile');
  final _searchTutorialKey = GlobalKey(debugLabel: 'gym_profile_search');
  final _equipmentTutorialKey = GlobalKey(debugLabel: 'gym_profile_equipment');
  final _saveTutorialKey = GlobalKey(debugLabel: 'gym_profile_save');
  late final TextEditingController _nameController;
  late final TextEditingController _searchController;
  List<_EquipmentOption> _allEquipment = [];
  Set<int> _selectedEquipmentIds = {};
  Set<int> _originalEquipmentIds = {};
  Set<String> _expandedCategoryKeys = {};
  late String _originalName;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _tutorialQueued = false;
  bool _initialEquipmentLoadStarted = false;
  String _searchQuery = '';

  bool get _isEditing => widget.profile != null || widget.returnDraftOnly;
  bool get _hasUnsavedChanges {
    if (_isSaving) return false;
    final nameChanged = _nameController.text.trim() != _originalName.trim();
    final equipmentChanged =
        !_isLoading &&
        !_sameIntSet(_selectedEquipmentIds, _originalEquipmentIds);
    return nameChanged || equipmentChanged;
  }

  @override
  void initState() {
    super.initState();
    _originalName = widget.profile?.name ?? widget.initialName ?? '';
    _nameController = TextEditingController(text: _originalName);
    _searchController = TextEditingController();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialEquipmentLoadStarted) return;
    _initialEquipmentLoadStarted = true;
    unawaited(_loadEquipment());
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
  }

  Future<void> _loadEquipment() async {
    final repo = _repo;
    final strings = AppLocalizations.of(context);
    final all = await repo.fetchAllEquipment();
    final assigned = <Map<String, dynamic>>[];
    if (widget.profile?.id != null) {
      assigned.addAll(await repo.fetchEquipmentForProfile(widget.profile!.id!));
    }

    final equipment = all.map((item) {
      return _EquipmentOption(
        id: item.id,
        name: item.name,
        catalogId: item.catalogId,
      );
    }).toList();

    if (!mounted) return;
    final assignedIds = assigned.isNotEmpty
        ? assigned.map((e) => e['id'] as int).toSet()
        : equipment
              .where((item) => widget.initialEquipmentNames.contains(item.name))
              .map((item) => item.id)
              .toSet();
    setState(() {
      _allEquipment = equipment;
      _selectedEquipmentIds = assignedIds;
      _originalEquipmentIds = Set<int>.from(assignedIds);
      _expandedCategoryKeys = _buildEquipmentGroups(
        equipment,
        strings,
      ).map((group) => group.category.key).toSet();
      _isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
  }

  List<_EquipmentGroup> _visibleEquipmentGroups() {
    final filtered = _searchQuery.isEmpty
        ? _allEquipment
        : _allEquipment
              .where((item) => item.name.toLowerCase().contains(_searchQuery))
              .toList();
    return _buildEquipmentGroups(filtered, AppLocalizations.of(context));
  }

  void _toggleEquipment(int id, bool selected) {
    setState(() {
      if (selected) {
        _selectedEquipmentIds.add(id);
      } else {
        _selectedEquipmentIds.remove(id);
      }
    });
  }

  void _toggleCategory(_EquipmentGroup group) {
    final ids = group.items.map((item) => item.id).toSet();
    final allSelected = ids.every(_selectedEquipmentIds.contains);
    setState(() {
      if (allSelected) {
        _selectedEquipmentIds.removeAll(ids);
      } else {
        _selectedEquipmentIds.addAll(ids);
      }
    });
  }

  void _toggleExpanded(String categoryKey) {
    setState(() {
      if (_expandedCategoryKeys.contains(categoryKey)) {
        _expandedCategoryKeys.remove(categoryKey);
      } else {
        _expandedCategoryKeys.add(categoryKey);
      }
    });
  }

  void _resetEquipmentSelection() {
    setState(() {
      _selectedEquipmentIds = Set<int>.from(_originalEquipmentIds);
    });
  }

  void _selectAllEquipment() {
    setState(() {
      _selectedEquipmentIds = _allEquipment.map((item) => item.id).toSet();
    });
  }

  void _queueTutorial() {
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  Future<void> _showTutorial() async {
    final strings = AppLocalizations.of(context);
    try {
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.gymProfileEditor,
        steps: [
          GuidedTutorialStep(
            targetKey: _profileTutorialKey,
            icon: Icons.home_work_outlined,
            title: strings.gymProfileTutorialSpaceTitle,
            body: strings.gymProfileTutorialSpaceBody,
          ),
          GuidedTutorialStep(
            targetKey: _searchTutorialKey,
            icon: Icons.search,
            title: strings.gymProfileTutorialFindTitle,
            body: strings.gymProfileTutorialFindBody,
          ),
          GuidedTutorialStep(
            targetKey: _equipmentTutorialKey,
            icon: Icons.inventory_2_outlined,
            title: strings.gymProfileTutorialAvailableTitle,
            body: strings.gymProfileTutorialAvailableBody,
          ),
          GuidedTutorialStep(
            targetKey: _saveTutorialKey,
            icon: Icons.save_outlined,
            title: strings.gymProfileTutorialSaveTitle,
            body: strings.gymProfileTutorialSaveBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  void _leavePage() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> _attemptClose() async {
    if (!_hasUnsavedChanges) {
      _leavePage();
      return;
    }

    final action = await showDialog<_UnsavedGymProfileAction>(
      context: context,
      builder: (dialogContext) => TonosDialogFrame(
        child: AlertDialog(
          title: Text(AppLocalizations.of(context).gymProfileSaveChangesTitle),
          content: Text(AppLocalizations.of(context).gymProfileSaveChangesBody),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext)
                      .pop(_UnsavedGymProfileAction.keepEditing),
              child: Text(AppLocalizations.of(context).gymProfileKeepEditing),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext)
                      .pop(_UnsavedGymProfileAction.discard),
              child: Text(AppLocalizations.of(context).gymProfileDiscard),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext)
                      .pop(_UnsavedGymProfileAction.save),
              child: Text(AppLocalizations.of(context).commonSave),
            ),
          ],
        ),
      ),
    );

    if (!mounted ||
        action == null ||
        action == _UnsavedGymProfileAction.keepEditing) {
      return;
    }

    if (action == _UnsavedGymProfileAction.discard) {
      _leavePage();
      return;
    }

    await _save();
  }

  Future<bool> _save() async {
    final strings = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final formState = _formKey.currentState;
    if (formState != null && !formState.validate()) return false;
    if (name.isEmpty) return false;
    setState(() => _isSaving = true);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (widget.returnDraftOnly) {
      if (_selectedEquipmentIds.isEmpty) {
        setState(() => _isSaving = false);
        messenger.showSnackBar(
          SnackBar(content: Text(strings.gymProfileSelectEquipment)),
        );
        return false;
      }

      final selectedNames = _allEquipment
          .where((item) => _selectedEquipmentIds.contains(item.id))
          .map((item) => item.name)
          .toSet();

      if (!mounted) return true;
      setState(() {
        _originalName = name;
        _originalEquipmentIds = Set<int>.from(_selectedEquipmentIds);
        _isSaving = false;
      });
      navigator.pop(GymProfileDraft(name: name, equipmentNames: selectedNames));
      return true;
    }

    final selectedProv = context.read<SelectedProfile>();

    try {
      final profileId = await _repo.saveGymProfileAtomic(
        existingProfile: widget.profile,
        name: name,
        equipmentIds: _selectedEquipmentIds,
      );
      await selectedProv.loadProfiles(preferredProfileId: profileId);

      if (!mounted) return true;
      setState(() {
        _originalName = name;
        _originalEquipmentIds = Set<int>.from(_selectedEquipmentIds);
        _isSaving = false;
      });
      if (navigator.canPop()) {
        navigator.pop();
      }
      return true;
    } catch (error) {
      if (!mounted) return false;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            strings.gymProfileSaveFailed(safeFailureMessage(strings, error)),
          ),
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final groups = _visibleEquipmentGroups();
    final planning = AppExpressivePlanningTokens.maybeOf(context);

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _attemptClose();
      },
      child: Scaffold(
        backgroundColor: planning?.pageCanvas,
        appBar: AppBar(
          leading: BackButton(onPressed: _attemptClose),
          title: Text(
            widget.title ??
                (_isEditing
                    ? strings.gymProfileEditTitle
                    : strings.gymProfileNewTitle),
          ),
          backgroundColor: planning?.planSupportSurface,
          foregroundColor: planning?.planSupportForeground,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  children: [
                    KeyedSubtree(
                      key: _profileTutorialKey,
                      child: _ProfileSetupCard(
                        formKey: _formKey,
                        controller: _nameController,
                        selectedCount: _selectedEquipmentIds.length,
                        totalCount: _allEquipment.length,
                      ),
                    ),
                    const SizedBox(height: 14),
                    KeyedSubtree(
                      key: _searchTutorialKey,
                      child: _EquipmentSearchField(
                        controller: _searchController,
                      ),
                    ),
                    const SizedBox(height: 16),
                    KeyedSubtree(
                      key: _equipmentTutorialKey,
                      child: _EquipmentSectionHeader(
                        onReset: _isLoading ? null : _resetEquipmentSelection,
                        onSelectAll: _isLoading ? null : _selectAllEquipment,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.gymProfileEquipmentHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            planning?.onPage ??
                            theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_isLoading)
                      const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (groups.isEmpty)
                      _EmptyEquipmentSearch(
                        query: _searchController.text.trim(),
                      )
                    else
                      ...groups.map((group) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _EquipmentCategorySection(
                            group: group,
                            selectedEquipmentIds: _selectedEquipmentIds,
                            isExpanded: _expandedCategoryKeys.contains(
                              group.category.key,
                            ),
                            onToggleExpanded: () =>
                                _toggleExpanded(group.category.key),
                            onToggleCategory: () => _toggleCategory(group),
                            onToggleEquipment: _toggleEquipment,
                          ),
                        );
                      }),
                  ],
                ),
              ),
              KeyedSubtree(
                key: _saveTutorialKey,
                child: _SaveProfileBar(
                  isLoading: _isLoading,
                  isSaving: _isSaving,
                  onCancel: _attemptClose,
                  onSave: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSetupCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final int selectedCount;
  final int totalCount;

  const _ProfileSetupCard({
    required this.formKey,
    required this.controller,
    required this.selectedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppLocalizations.of(context);
    final neo = context.usesNeoPresentation;
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final cardSurface =
        planning?.configurationSurface ??
        (neo
            ? surfaces.settingsSection
            : scheme.surfaceContainerHighest.withValues(alpha: 0.42));
    final cardForeground =
        planning?.configurationForeground ??
        (neo
            ? tonosForegroundForSurface(context, cardSurface)
            : scheme.onSurface);
    final cardSecondary =
        planning?.configurationForeground ??
        (neo
            ? tonosSecondaryForegroundForSurface(context, cardSurface)
            : scheme.onSurfaceVariant);
    final cardOutline =
        planning?.outline ??
        (neo
            ? tonosOutlineForSurface(context, cardSurface)
            : scheme.outlineVariant.withValues(alpha: 0.55));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: planning != null
            ? const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(28),
              )
            : neo
            ? shapes.settingsPanel
            : BorderRadius.circular(24),
        border: Border.all(
          color: cardOutline,
          width: neo ? shapes.outlineWidth : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                      planning?.planFocalSurface ??
                      (neo
                          ? surfaces.dialogChoice
                          : scheme.primaryContainer.withValues(alpha: 0.75)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center,
                  color:
                      planning?.planFocalForeground ??
                      (neo ? cardForeground : scheme.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.gymProfileSpace,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: neo ? cardForeground : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings.gymProfileEquipmentSelected(
                        selectedCount,
                        totalCount,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cardSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              textInputAction: TextInputAction.done,
              decoration: planning != null
                  ? InputDecoration(
                      labelText: strings.gymProfileName,
                      hintText: strings.gymProfileNameHint,
                      filled: true,
                      fillColor: planning.configurationSurface,
                      labelStyle: TextStyle(
                        color: planning.configurationForeground,
                      ),
                      hintStyle: TextStyle(
                        color: planning.configurationForeground.withValues(
                          alpha: 0.72,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: planning.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: planning.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: planning.actionPrimary,
                          width: 2,
                        ),
                      ),
                    )
                  : neo
                  ? settingsFieldDecoration(
                      context,
                      label: strings.gymProfileName,
                      hint: strings.gymProfileNameHint,
                    )
                  : InputDecoration(
                      labelText: strings.gymProfileName,
                      hintText: strings.gymProfileNameHint,
                      filled: true,
                      fillColor: scheme.surface.withValues(alpha: 0.45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
              style: planning == null
                  ? settingsInputTextStyle(context)
                  : TextStyle(color: planning.configurationForeground),
              validator: (value) => value == null || value.trim().isEmpty
                  ? strings.gymProfileNameRequired
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentSearchField extends StatelessWidget {
  final TextEditingController controller;

  const _EquipmentSearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);
    final neo = context.usesNeoPresentation;
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final fieldSurface =
        planning?.equipmentSurface ??
        (neo
            ? surfaces.settingsInput
            : scheme.surfaceContainerHighest.withValues(alpha: 0.48));
    final fieldForeground =
        planning?.equipmentForeground ??
        (neo
            ? tonosForegroundForSurface(context, fieldSurface)
            : scheme.onSurface);
    final fieldOutline =
        planning?.outline ??
        (neo
            ? tonosOutlineForSurface(context, fieldSurface)
            : Colors.transparent);
    final fieldShape = planning != null
        ? BorderRadius.circular(16)
        : neo
        ? shapes.settingsPicker
        : const BorderRadius.all(Radius.circular(999));

    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.filter_list,
          color: planning != null
              ? fieldForeground
              : neo
              ? fieldForeground
              : null,
        ),
        hintText: strings.gymProfileFilterEquipment,
        filled: true,
        fillColor: fieldSurface,
        hintStyle: planning != null
            ? TextStyle(color: fieldForeground.withValues(alpha: 0.72))
            : neo
            ? TextStyle(color: fieldForeground.withValues(alpha: 0.62))
            : null,
        border: OutlineInputBorder(
          borderRadius: fieldShape,
          borderSide: planning != null
              ? BorderSide(color: fieldOutline)
              : neo
              ? BorderSide(color: fieldOutline, width: shapes.outlineWidth)
              : BorderSide.none,
        ),
        enabledBorder: planning != null
            ? OutlineInputBorder(
                borderRadius: fieldShape,
                borderSide: BorderSide(color: fieldOutline),
              )
            : neo
            ? OutlineInputBorder(
                borderRadius: fieldShape,
                borderSide: BorderSide(
                  color: fieldOutline,
                  width: shapes.outlineWidth,
                ),
              )
            : null,
        focusedBorder: planning != null
            ? OutlineInputBorder(
                borderRadius: fieldShape,
                borderSide: BorderSide(color: planning.actionPrimary, width: 2),
              )
            : neo
            ? OutlineInputBorder(
                borderRadius: fieldShape,
                borderSide: BorderSide(
                  color: context.semanticColors.focusRing,
                  width: shapes.focusRingWidth,
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

class _EquipmentSectionHeader extends StatelessWidget {
  final VoidCallback? onReset;
  final VoidCallback? onSelectAll;

  const _EquipmentSectionHeader({
    required this.onReset,
    required this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    final title = Text(
      strings.gymProfileEquipment,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleLarge?.copyWith(
        color: planning?.onPage,
        fontWeight: FontWeight.w900,
      ),
    );
    final resetButton = TextButton(
      onPressed: onReset,
      style: TextButton.styleFrom(
        foregroundColor: planning?.actionPrimary,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      child: Text(strings.commonReset),
    );
    final selectAllButton = FilledButton.tonal(
      onPressed: onSelectAll,
      style: FilledButton.styleFrom(
        backgroundColor: planning?.actionSecondary,
        foregroundColor: planning?.actionSecondaryForeground,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(strings.gymProfileSelectAll),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (planning != null && constraints.maxWidth < 400) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 4,
                  runSpacing: 4,
                  children: [resetButton, selectAllButton],
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            resetButton,
            const SizedBox(width: 4),
            selectAllButton,
          ],
        );
      },
    );
  }
}

class _EquipmentCategorySection extends StatelessWidget {
  final _EquipmentGroup group;
  final Set<int> selectedEquipmentIds;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onToggleCategory;
  final void Function(int id, bool selected) onToggleEquipment;

  const _EquipmentCategorySection({
    required this.group,
    required this.selectedEquipmentIds,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onToggleCategory,
    required this.onToggleEquipment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppLocalizations.of(context);
    final neo = context.usesNeoPresentation;
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final sectionSurface =
        planning?.equipmentSurface ??
        (neo
            ? surfaces.settingsSection
            : scheme.surfaceContainerHighest.withValues(alpha: 0.28));
    final sectionForeground =
        planning?.equipmentForeground ??
        (neo
            ? tonosForegroundForSurface(context, sectionSurface)
            : scheme.onSurface);
    final sectionSecondary =
        planning?.equipmentForeground ??
        (neo
            ? tonosSecondaryForegroundForSurface(context, sectionSurface)
            : scheme.onSurfaceVariant);
    final sectionOutline =
        planning?.outline ??
        (neo
            ? tonosOutlineForSurface(context, sectionSurface)
            : scheme.outlineVariant.withValues(alpha: 0.55));
    final selectedCount = group.items
        .where((item) => selectedEquipmentIds.contains(item.id))
        .length;
    final allSelected =
        selectedCount == group.items.length && group.items.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: sectionSurface,
        borderRadius: planning != null
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(28),
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(16),
              )
            : neo
            ? shapes.settingsPanel
            : BorderRadius.circular(22),
        border: Border.all(
          color: sectionOutline,
          width: neo ? shapes.outlineWidth : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            onTap: onToggleExpanded,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        group.category.icon,
                        color: planning != null
                            ? planning.actionPrimary
                            : neo
                            ? sectionForeground
                            : scheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          group.category.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: planning != null
                                ? sectionForeground
                                : neo
                                ? sectionForeground
                                : null,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: sectionSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final selectedCountLabel = Text(
                        strings.gymProfileSelectedCount(
                          selectedCount,
                          group.items.length,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: sectionSecondary,
                        ),
                      );
                      final selectAllButton = TextButton(
                        onPressed: onToggleCategory,
                        style: planning != null
                            ? TextButton.styleFrom(
                                foregroundColor: planning.actionPrimary,
                              )
                            : neo
                            ? TextButton.styleFrom(
                                foregroundColor: sectionForeground,
                              )
                            : null,
                        child: Text(
                          allSelected
                              ? strings.gymProfileClear
                              : strings.gymProfileSelectAll,
                        ),
                      );
                      if (planning != null && constraints.maxWidth < 400) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            selectedCountLabel,
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: selectAllButton,
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: selectedCountLabel),
                          selectAllButton,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                Divider(height: 1, color: sectionOutline),
                ...group.items.map((item) {
                  final selected = selectedEquipmentIds.contains(item.id);
                  return _EquipmentTile(
                    item: item,
                    selected: selected,
                    onChanged: (value) =>
                        onToggleEquipment(item.id, value ?? false),
                  );
                }),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: appMotionDuration(context, context.motionTokens.quick),
          ),
        ],
      ),
    );
  }
}

class _EquipmentTile extends StatelessWidget {
  final _EquipmentOption item;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  const _EquipmentTile({
    required this.item,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppLocalizations.of(context);
    final neo = context.usesNeoPresentation;
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final tileSurface = planning != null
        ? (selected ? planning.selectedSurface : planning.planSupportSurface)
        : neo
        ? surfaces.dialogChoice
        : scheme.surface;
    final tileForeground = planning != null
        ? (selected
              ? planning.actionPrimaryForeground
              : planning.planSupportForeground)
        : neo
        ? tonosForegroundForSurface(context, tileSurface)
        : scheme.onSurface;
    final tileSecondary = planning != null
        ? (selected
              ? planning.actionPrimaryForeground.withValues(alpha: 0.82)
              : planning.planSupportForeground.withValues(alpha: 0.82))
        : neo
        ? tonosSecondaryForegroundForSurface(context, tileSurface)
        : scheme.onSurfaceVariant;

    return InkWell(
      onTap: () => onChanged(!selected),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Row(
          children: [
            SharedEntityMediaThumbnail(
              entityType: SharedMediaEntityType.equipment,
              entityId: item.id,
              size: 42,
              borderRadius: BorderRadius.circular(planning == null ? 11 : 14),
              padding: EdgeInsets.zero,
              imageScale: 1.13,
              backgroundColor: selected
                  ? (planning != null
                        ? planning.selectedSurface
                        : neo
                        ? surfaces.settingsInput
                        : scheme.primary.withValues(alpha: 0.18))
                  : (planning != null
                        ? planning.planSupportSurface
                        : neo
                        ? surfaces.settingsSection
                        : scheme.surface.withValues(alpha: 0.34)),
              borderColor: selected
                  ? (planning != null
                        ? planning.outline
                        : neo
                        ? tonosOutlineForSurface(
                            context,
                            surfaces.settingsInput,
                          )
                        : scheme.primary.withValues(alpha: 0.6))
                  : (planning != null
                        ? planning.outline
                        : neo
                        ? tonosOutlineForSurface(
                            context,
                            surfaces.settingsSection,
                          )
                        : scheme.outlineVariant.withValues(alpha: 0.34)),
              fallbackBuilder: (context, contentSize) => Icon(
                _equipmentIconFor(item.name),
                color: planning != null
                    ? (selected
                          ? planning.actionPrimaryForeground
                          : tileSecondary)
                    : selected
                    ? (neo ? tileForeground : scheme.primary)
                    : tileSecondary,
                size: contentSize * 0.6,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LocalizedCatalogEntityName(
                    entity: CatalogEntityDisplayName(
                      catalogId: item.catalogId,
                      canonicalName: item.name,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color:
                          planning?.equipmentForeground ??
                          (neo ? tileForeground : null),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _equipmentSubtitleFor(item.name, strings),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: planning?.equipmentForeground ?? tileSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: selected,
              onChanged: onChanged,
              fillColor: planning != null
                  ? WidgetStatePropertyAll<Color?>(
                      selected
                          ? planning.actionPrimary
                          : planning.planSupportSurface,
                    )
                  : neo
                  ? WidgetStatePropertyAll<Color?>(tileForeground)
                  : null,
              checkColor: planning != null
                  ? planning.actionPrimaryForeground
                  : neo
                  ? surfaces.dialogChoice
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveProfileBar extends StatelessWidget {
  final bool isLoading;
  final bool isSaving;
  final VoidCallback onCancel;
  final Future<bool> Function() onSave;

  const _SaveProfileBar({
    required this.isLoading,
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);
    final neo = context.usesNeoPresentation;
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color:
            planning?.planSupportSurface ??
            (neo
                ? surfaces.settingsSaveBar
                : scheme.surface.withValues(alpha: 0.96)),
        border: Border(
          top: BorderSide(
            color:
                planning?.outline ??
                (neo
                    ? tonosOutlineForSurface(context, surfaces.settingsSaveBar)
                    : scheme.outlineVariant),
            width: neo ? shapes.outlineWidth : 1,
          ),
        ),
        borderRadius: planning != null
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : neo
            ? shapes.actionBar
            : BorderRadius.zero,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isSaving ? null : onCancel,
              style: planning == null
                  ? null
                  : OutlinedButton.styleFrom(
                      foregroundColor: planning.actionSecondaryForeground,
                      backgroundColor: planning.actionSecondary,
                      side: BorderSide(color: planning.outline),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                    ),
              child: Text(strings.commonCancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: isSaving || isLoading ? null : () => onSave(),
              style: planning == null
                  ? null
                  : FilledButton.styleFrom(
                      backgroundColor: planning.actionPrimary,
                      foregroundColor: planning.actionPrimaryForeground,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                    ),
              child: Text(
                isSaving ? strings.gymProfileSaving : strings.gymProfileSave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyEquipmentSearch extends StatelessWidget {
  final String query;

  const _EmptyEquipmentSearch({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppLocalizations.of(context);
    final neo = context.usesNeoPresentation;
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final emptySurface =
        planning?.configurationSurface ??
        (neo
            ? surfaces.panel
            : scheme.surfaceContainerHighest.withValues(alpha: 0.32));
    final emptyForeground =
        planning?.configurationForeground ??
        (neo
            ? tonosForegroundForSurface(context, emptySurface)
            : scheme.onSurface);
    final emptySecondary =
        planning?.configurationForeground ??
        (neo
            ? tonosSecondaryForegroundForSurface(context, emptySurface)
            : scheme.onSurfaceVariant);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: emptySurface,
        borderRadius: planning != null
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(28),
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(16),
              )
            : BorderRadius.circular(20),
        border: planning != null
            ? Border.all(color: planning.outline)
            : neo
            ? Border.all(
                color: tonosOutlineForSurface(context, emptySurface),
                width: context.shapeTokens.outlineWidth,
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(Icons.search_off, color: emptySecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strings.gymProfileNoEquipmentMatch(query),
              style: neo
                  ? theme.textTheme.bodyMedium?.copyWith(color: emptyForeground)
                  : theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentOption {
  final int id;
  final String name;
  final String? catalogId;

  const _EquipmentOption({
    required this.id,
    required this.name,
    this.catalogId,
  });
}

enum _UnsavedGymProfileAction { keepEditing, discard, save }

bool _sameIntSet(Set<int> a, Set<int> b) {
  if (a.length != b.length) return false;
  for (final value in a) {
    if (!b.contains(value)) return false;
  }
  return true;
}

class _EquipmentCategory {
  final String key;
  final String label;
  final IconData icon;
  final int order;

  const _EquipmentCategory({
    required this.key,
    required this.label,
    required this.icon,
    required this.order,
  });
}

class _EquipmentGroup {
  final _EquipmentCategory category;
  final List<_EquipmentOption> items;

  const _EquipmentGroup({required this.category, required this.items});
}

List<_EquipmentGroup> _buildEquipmentGroups(
  List<_EquipmentOption> equipment,
  AppLocalizations strings,
) {
  final groups = <String, _MutableEquipmentGroup>{};
  for (final item in equipment) {
    final category = _categoryForEquipment(item.name, strings);
    groups
        .putIfAbsent(
          category.key,
          () => _MutableEquipmentGroup(category: category),
        )
        .items
        .add(item);
  }

  final ordered = groups.values.toList()
    ..sort((a, b) => a.category.order.compareTo(b.category.order));
  return [
    for (final group in ordered)
      _EquipmentGroup(category: group.category, items: group.items),
  ];
}

class _MutableEquipmentGroup {
  final _EquipmentCategory category;
  final List<_EquipmentOption> items = [];

  _MutableEquipmentGroup({required this.category});
}

_EquipmentCategory _categoryForEquipment(
  String name,
  AppLocalizations strings,
) {
  final lower = name.toLowerCase();
  if (lower == 'none' || lower.contains('bodyweight')) {
    return _EquipmentCategory(
      key: 'basics',
      label: strings.equipmentCategoryBasics,
      icon: Icons.accessibility_new,
      order: 0,
    );
  }
  if (lower.contains('barbell') ||
      lower.contains('dumbbell') ||
      lower.contains('kettlebell') ||
      lower.contains('plates') ||
      lower.contains('medicine ball')) {
    return _EquipmentCategory(
      key: 'free_weights',
      label: strings.equipmentCategoryFreeWeights,
      icon: Icons.fitness_center,
      order: 1,
    );
  }
  if (lower.contains('bench') ||
      lower.contains('rack') ||
      lower.contains('dip') ||
      lower.contains('pull-up') ||
      lower.contains('ring') ||
      lower.contains('developer')) {
    return _EquipmentCategory(
      key: 'benches_racks',
      label: strings.equipmentCategoryBenchesRacks,
      icon: Icons.event_seat,
      order: 2,
    );
  }
  if (lower.contains('attachment') ||
      lower.contains('cuff') ||
      lower.contains('handle') ||
      lower.contains('rope') ||
      lower.contains('straight bar') ||
      lower.contains('landmine') ||
      lower.contains('band')) {
    return _EquipmentCategory(
      key: 'attachments',
      label: strings.equipmentCategoryCableAttachments,
      icon: Icons.cable,
      order: 3,
    );
  }
  if (lower.contains('machine') ||
      lower.contains('smith') ||
      lower.contains('press') ||
      lower.contains('curl') ||
      lower.contains('extension') ||
      lower.contains('raise') ||
      lower.contains('pulldown') ||
      lower.contains('squat')) {
    return _EquipmentCategory(
      key: 'machines',
      label: strings.equipmentCategoryMachines,
      icon: Icons.precision_manufacturing,
      order: 4,
    );
  }
  return _EquipmentCategory(
    key: 'other',
    label: strings.equipmentCategoryOther,
    icon: Icons.category,
    order: 5,
  );
}

IconData _equipmentIconFor(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('bench') || lower.contains('seat')) {
    return Icons.event_seat;
  }
  if (lower.contains('machine') || lower.contains('smith')) {
    return Icons.precision_manufacturing;
  }
  if (lower.contains('cable') || lower.contains('attachment')) {
    return Icons.cable;
  }
  if (lower.contains('bodyweight') || lower == 'none') {
    return Icons.accessibility_new;
  }
  if (lower.contains('band')) return Icons.linear_scale;
  if (lower.contains('ring')) return Icons.radio_button_unchecked;
  if (lower.contains('rack') || lower.contains('pull-up')) {
    return Icons.view_week;
  }
  return Icons.fitness_center;
}

String _equipmentSubtitleFor(String name, AppLocalizations strings) {
  final lower = name.toLowerCase();
  if (lower == 'none') return strings.equipmentNoRequirement;
  if (lower.contains('bodyweight')) return strings.equipmentBodyweightSupport;
  if (lower.contains('machine')) return strings.equipmentMachineBased;
  if (lower.contains('attachment') || lower.contains('cable')) {
    return strings.equipmentCableAccessory;
  }
  if (lower.contains('bench') ||
      lower.contains('rack') ||
      lower.contains('pull-up') ||
      lower.contains('ring')) {
    return strings.equipmentBenchRackSetup;
  }
  if (lower.contains('barbell') ||
      lower.contains('dumbbell') ||
      lower.contains('kettlebell') ||
      lower.contains('plates')) {
    return strings.equipmentFreeWeightTraining;
  }
  return strings.equipmentAvailable;
}
