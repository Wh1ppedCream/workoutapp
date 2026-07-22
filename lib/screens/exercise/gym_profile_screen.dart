// File: lib/screens/exercise/gym_profile_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/database_helper.dart';
import '../../models/content_models.dart';
import '../../models/gym_models.dart';
import '../../providers/selected_profile.dart';
import '../../services/tutorial_state_store.dart';
import '../../utils/tutorial_launcher.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/shared_entity_media_thumbnail.dart';

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
    _loadEquipment();
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
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final all = await db.query(
      'equipment',
      columns: ['id', 'name'],
      orderBy: 'name',
    );
    final assigned = <Map<String, dynamic>>[];
    if (widget.profile?.id != null) {
      assigned.addAll(
        await dbHelper.fetchEquipmentForProfile(widget.profile!.id!),
      );
    }

    final equipment =
        all.map((row) {
          return _EquipmentOption(
            id: row['id'] as int,
            name: row['name'] as String,
          );
        }).toList();

    if (!mounted) return;
    final assignedIds =
        assigned.isNotEmpty
            ? assigned.map((e) => e['id'] as int).toSet()
            : equipment
                .where(
                  (item) => widget.initialEquipmentNames.contains(item.name),
                )
                .map((item) => item.id)
                .toSet();
    setState(() {
      _allEquipment = equipment;
      _selectedEquipmentIds = assignedIds;
      _originalEquipmentIds = Set<int>.from(assignedIds);
      _expandedCategoryKeys =
          _buildEquipmentGroups(
            equipment,
          ).map((group) => group.category.key).toSet();
      _isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
  }

  List<_EquipmentGroup> _visibleEquipmentGroups() {
    final filtered =
        _searchQuery.isEmpty
            ? _allEquipment
            : _allEquipment
                .where((item) => item.name.toLowerCase().contains(_searchQuery))
                .toList();
    return _buildEquipmentGroups(filtered);
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
    try {
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.gymProfileEditor,
        steps: [
          GuidedTutorialStep(
            targetKey: _profileTutorialKey,
            icon: Icons.home_work_outlined,
            title: 'Workout space',
            body:
                'Name this profile for where you train, like Home Gym, Commercial Gym, or Travel Setup.',
          ),
          GuidedTutorialStep(
            targetKey: _searchTutorialKey,
            icon: Icons.search,
            title: 'Find equipment',
            body:
                'Use search when the equipment list gets long and you want to jump to one item quickly.',
          ),
          GuidedTutorialStep(
            targetKey: _equipmentTutorialKey,
            icon: Icons.inventory_2_outlined,
            title: 'Available equipment',
            body:
                'Select what this workout space has. Generated plans and swaps can use this to avoid unavailable exercises.',
          ),
          GuidedTutorialStep(
            targetKey: _saveTutorialKey,
            icon: Icons.save_outlined,
            title: 'Save profile',
            body:
                'Save stores the profile and equipment. Cancel asks before discarding unsaved changes.',
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
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Save changes?'),
            content: const Text(
              'You have unsaved gym profile changes. Save them before leaving?',
            ),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(
                      dialogContext,
                    ).pop(_UnsavedGymProfileAction.keepEditing),
                child: const Text('Keep Editing'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.of(
                      dialogContext,
                    ).pop(_UnsavedGymProfileAction.discard),
                child: const Text('Discard'),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.of(
                      dialogContext,
                    ).pop(_UnsavedGymProfileAction.save),
                child: const Text('Save'),
              ),
            ],
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
    if (!_formKey.currentState!.validate()) return false;
    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (widget.returnDraftOnly) {
      if (_selectedEquipmentIds.isEmpty) {
        setState(() => _isSaving = false);
        messenger.showSnackBar(
          const SnackBar(content: Text('Select at least one equipment item.')),
        );
        return false;
      }

      final selectedNames =
          _allEquipment
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

    final dbHelper = DatabaseHelper();
    final selectedProv = context.read<SelectedProfile>();

    try {
      final profileId = await dbHelper.saveGymProfileAtomic(
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
        SnackBar(content: Text('Could not save profile: $error')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = _visibleEquipmentGroups();

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _attemptClose();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _attemptClose),
          title: Text(
            widget.title ??
                (_isEditing ? 'Edit Gym Profile' : 'New Gym Profile'),
          ),
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
                      'Pick what this gym has so generated plans only use available equipment.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
                            onToggleExpanded:
                                () => _toggleExpanded(group.category.key),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
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
                  color: scheme.primaryContainer.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workout Space',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$selectedCount of $totalCount equipment options selected',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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
              decoration: InputDecoration(
                labelText: 'Profile name',
                hintText: 'Home gym, Commercial gym, Travel setup...',
                filled: true,
                fillColor: scheme.surface.withValues(alpha: 0.45),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Name required'
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

    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.filter_list),
        hintText: 'Filter equipment by name',
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.48),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
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

    return Row(
      children: [
        Expanded(
          child: Text(
            'Equipment',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(
          onPressed: onReset,
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          child: const Text('Reset'),
        ),
        const SizedBox(width: 4),
        FilledButton.tonal(
          onPressed: onSelectAll,
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: const Text('Select All'),
        ),
      ],
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
    final selectedCount =
        group.items
            .where((item) => selectedEquipmentIds.contains(item.id))
            .length;
    final allSelected =
        selectedCount == group.items.length && group.items.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
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
                        color: scheme.primary,
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
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$selectedCount/${group.items.length} selected',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: onToggleCategory,
                        child: Text(allSelected ? 'Clear' : 'Select all'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                Divider(height: 1, color: scheme.outlineVariant),
                ...group.items.map((item) {
                  final selected = selectedEquipmentIds.contains(item.id);
                  return _EquipmentTile(
                    item: item,
                    selected: selected,
                    onChanged:
                        (value) => onToggleEquipment(item.id, value ?? false),
                  );
                }),
              ],
            ),
            crossFadeState:
                isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
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
              borderRadius: BorderRadius.circular(11),
              padding: EdgeInsets.zero,
              imageScale: 1.13,
              backgroundColor:
                  selected
                      ? scheme.primary.withValues(alpha: 0.18)
                      : scheme.surface.withValues(alpha: 0.34),
              borderColor:
                  selected
                      ? scheme.primary.withValues(alpha: 0.6)
                      : scheme.outlineVariant.withValues(alpha: 0.34),
              fallbackBuilder:
                  (context, contentSize) => Icon(
                    _equipmentIconFor(item.name),
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                    size: contentSize * 0.6,
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _equipmentSubtitleFor(item.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(value: selected, onChanged: onChanged),
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

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isSaving ? null : onCancel,
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: isSaving || isLoading ? null : () => onSave(),
              child: Text(isSaving ? 'Saving...' : 'Save Profile'),
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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.search_off, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No equipment matches "$query".',
              style: theme.textTheme.bodyMedium,
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

  const _EquipmentOption({required this.id, required this.name});
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

List<_EquipmentGroup> _buildEquipmentGroups(List<_EquipmentOption> equipment) {
  final groups = <String, _MutableEquipmentGroup>{};
  for (final item in equipment) {
    final category = _categoryForEquipment(item.name);
    groups
        .putIfAbsent(
          category.key,
          () => _MutableEquipmentGroup(category: category),
        )
        .items
        .add(item);
  }

  final ordered =
      groups.values.toList()
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

_EquipmentCategory _categoryForEquipment(String name) {
  final lower = name.toLowerCase();
  if (lower == 'none' || lower.contains('bodyweight')) {
    return const _EquipmentCategory(
      key: 'basics',
      label: 'Basics',
      icon: Icons.accessibility_new,
      order: 0,
    );
  }
  if (lower.contains('barbell') ||
      lower.contains('dumbbell') ||
      lower.contains('kettlebell') ||
      lower.contains('plates') ||
      lower.contains('medicine ball')) {
    return const _EquipmentCategory(
      key: 'free_weights',
      label: 'Free Weights',
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
    return const _EquipmentCategory(
      key: 'benches_racks',
      label: 'Benches & Racks',
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
    return const _EquipmentCategory(
      key: 'attachments',
      label: 'Cable & Attachments',
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
    return const _EquipmentCategory(
      key: 'machines',
      label: 'Machines',
      icon: Icons.precision_manufacturing,
      order: 4,
    );
  }
  return const _EquipmentCategory(
    key: 'other',
    label: 'Other Equipment',
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

String _equipmentSubtitleFor(String name) {
  final lower = name.toLowerCase();
  if (lower == 'none') return 'No required equipment';
  if (lower.contains('bodyweight')) return 'Bodyweight movement support';
  if (lower.contains('machine')) return 'Machine based movement';
  if (lower.contains('attachment') || lower.contains('cable')) {
    return 'Cable station accessory';
  }
  if (lower.contains('bench') ||
      lower.contains('rack') ||
      lower.contains('pull-up') ||
      lower.contains('ring')) {
    return 'Bench, rack, or station setup';
  }
  if (lower.contains('barbell') ||
      lower.contains('dumbbell') ||
      lower.contains('kettlebell') ||
      lower.contains('plates')) {
    return 'Free weight training';
  }
  return 'Available equipment';
}
