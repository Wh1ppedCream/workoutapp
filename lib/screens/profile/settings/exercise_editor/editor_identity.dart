part of '../exercise_editor_screen.dart';

extension _EditorIdentity on _ExerciseEditorScreenState {
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
                onTap: (index) =>
                    _updateEditorState(() => _activeTabIndex = index),
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
                    _updateEditorState(() => _activeTabIndex = index);
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
}
