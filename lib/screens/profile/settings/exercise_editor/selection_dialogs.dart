part of '../exercise_editor_screen.dart';

extension _SelectionDialogs on _ExerciseEditorScreenState {
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
      _updateEditorState(() {
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
      _updateEditorState(() {
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
      _updateEditorState(() {
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

    _updateEditorState(() => _isSaving = true);
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
      _updateEditorState(() {
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
      if (mounted) _updateEditorState(() => _isSaving = false);
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
}
