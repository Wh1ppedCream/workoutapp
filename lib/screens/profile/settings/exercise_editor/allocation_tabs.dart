part of '../exercise_editor_screen.dart';

extension _AllocationTabs on _ExerciseEditorScreenState {
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
                  _updateEditorState(() {
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
        _updateEditorState(() {
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
                : () => _updateEditorState(() {
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
                : () => _updateEditorState(() {
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
            : () => _updateEditorState(() {
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
            : () => _updateEditorState(() {
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
          _updateEditorState(() {
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
                _updateEditorState(() {
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
                _updateEditorState(() {
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
}
