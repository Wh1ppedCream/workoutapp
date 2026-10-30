part of '../onboarding_flow.dart';

class _OnboardingPlanOverviewList extends StatefulWidget {
  final AppRepository repository;
  final int? profileId;
  final Set<int> planIds;
  final int refreshToken;
  final VoidCallback onChanged;

  const _OnboardingPlanOverviewList({
    required this.repository,
    required this.profileId,
    required this.planIds,
    required this.refreshToken,
    required this.onChanged,
  });

  @override
  State<_OnboardingPlanOverviewList> createState() =>
      _OnboardingPlanOverviewListState();
}

class _OnboardingPlanOverviewListState
    extends State<_OnboardingPlanOverviewList> {
  Future<List<_OnboardingPlanItem>>? _plansFuture;
  int? _loadedProfileId;
  int? _loadedRefreshToken;
  Set<int> _loadedPlanIds = const <int>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureFuture();
  }

  @override
  void didUpdateWidget(covariant _OnboardingPlanOverviewList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureFuture();
  }

  void _ensureFuture() {
    final profileId = widget.profileId;
    final planIds = Set<int>.from(widget.planIds);
    final shouldReload =
        _plansFuture == null ||
        _loadedProfileId != profileId ||
        _loadedRefreshToken != widget.refreshToken ||
        !_setEquals(_loadedPlanIds, planIds);
    if (!shouldReload) return;

    _loadedProfileId = profileId;
    _loadedRefreshToken = widget.refreshToken;
    _loadedPlanIds = planIds;
    _plansFuture = profileId == null
        ? Future.value(const <_OnboardingPlanItem>[])
        : _loadPlans(profileId, planIds);
  }

  Future<List<_OnboardingPlanItem>> _loadPlans(
    int profileId,
    Set<int> planIds,
  ) async {
    if (planIds.isEmpty) return const <_OnboardingPlanItem>[];
    final rows = await widget.repository.fetchPresetSummariesRaw(
      profileId: profileId,
    );
    final order = {
      for (var index = 0; index < planIds.length; index++)
        planIds.elementAt(index): index,
    };
    final filteredRows =
        rows.where((row) => planIds.contains(row['id'] as int)).toList()..sort(
          (a, b) => (order[a['id'] as int] ?? 0).compareTo(
            order[b['id'] as int] ?? 0,
          ),
        );
    final presetIds = filteredRows.map((row) => row['id'] as int).toList();
    final focusRows = await widget.repository.fetchPresetFocusSetCountsRaw(
      presetIds: presetIds,
    );
    final focusSetCountsByPreset = _groupFocusSetCounts(focusRows);
    final unitsByDefinition = await _loadBodyPartUnitsByDefinition(
      focusSetCountsByPreset,
    );

    return [
      for (var index = 0; index < filteredRows.length; index++)
        _OnboardingPlanItem(
          presetId: filteredRows[index]['id'] as int,
          name: filteredRows[index]['name'] as String,
          isAutomatic: (filteredRows[index]['is_automatic'] as int? ?? 0) == 1,
          listIndex: index,
          focusFrequencyMap: _buildFocusFrequencyMap(
            focusSetCountsByPreset[filteredRows[index]['id'] as int] ??
                const <int, int>{},
            unitsByDefinition,
          ),
        ),
    ];
  }

  Map<int, Map<int, int>> _groupFocusSetCounts(
    List<Map<String, dynamic>> rows,
  ) {
    final grouped = <int, Map<int, int>>{};
    for (final row in rows) {
      final presetId = row['preset_id'] as int;
      final defId = row['def_id'] as int;
      final setCount = ((row['set_count'] as num?) ?? 0).toInt();
      if (setCount <= 0) continue;
      grouped.putIfAbsent(presetId, () => <int, int>{})[defId] = setCount;
    }
    return grouped;
  }

  Future<Map<int, Map<String, double>>> _loadBodyPartUnitsByDefinition(
    Map<int, Map<int, int>> focusSetCountsByPreset,
  ) async {
    final defIds = <int>{
      for (final counts in focusSetCountsByPreset.values) ...counts.keys,
    };
    if (defIds.isEmpty) return const <int, Map<String, double>>{};

    final result = <int, Map<String, double>>{};
    for (final defId in defIds) {
      final units = await widget.repository.computeBodyPartPercents(defId);
      result[defId] = {
        for (final entry in units.entries)
          if (entry.value > 0.0) entry.key.name: entry.value,
      };
    }
    return result;
  }

  Map<String, double> _buildFocusFrequencyMap(
    Map<int, int> setCountsByDefinition,
    Map<int, Map<String, double>> unitsByDefinition,
  ) {
    final bodyPartTotals = <String, double>{};
    setCountsByDefinition.forEach((defId, setCount) {
      final units = unitsByDefinition[defId];
      if (units == null || setCount <= 0) return;
      units.forEach((bodyPartName, unitsPerSet) {
        bodyPartTotals[bodyPartName] =
            (bodyPartTotals[bodyPartName] ?? 0.0) + unitsPerSet * setCount;
      });
    });
    if (bodyPartTotals.isEmpty) return const <String, double>{};

    final maxUnits = bodyPartTotals.values.fold<double>(
      0.0,
      (max, value) => value > max ? value : max,
    );
    if (maxUnits <= 0.0) return const <String, double>{};

    final frequencyMap = <String, double>{};
    bodyPartTotals.forEach((bodyPartName, units) {
      final svgIds = bodyPartNameToSvgIds[bodyPartName] ?? const <String>[];
      final normalized = units / maxUnits;
      for (final svgId in svgIds) {
        frequencyMap[svgId] = normalized;
      }
    });
    return frequencyMap;
  }

  bool _setEquals(Set<int> left, Set<int> right) {
    if (left.length != right.length) return false;
    for (final value in left) {
      if (!right.contains(value)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surface = context.usesNeoPresentation
        ? context.surfaceTokens.settingsSection
        : scheme.surface;
    final strings = AppLocalizations.of(context);
    return FutureBuilder<List<_OnboardingPlanItem>>(
      future: _plansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text(
            strings.onboardingPlanOverviewLoadError,
            style: TextStyle(color: tonosErrorForSurface(context, surface)),
          );
        }

        final plans = snapshot.data ?? const <_OnboardingPlanItem>[];
        if (plans.isEmpty) {
          return Text(
            strings.onboardingNoAddedPlans,
            style: TextStyle(
              color: tonosSecondaryForegroundForSurface(context, surface),
            ),
          );
        }

        return Column(
          children: [
            for (final plan in plans)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PresetBar(
                  presetId: plan.presetId,
                  label: plan.name,
                  color:
                      PlanIdentityPalette.colors[plan.listIndex %
                          PlanIdentityPalette.colors.length],
                  index: plan.listIndex,
                  isAutomatic: plan.isAutomatic,
                  focusFrequencyMap: plan.focusFrequencyMap,
                  onRefresh: () {
                    _ensureFuture();
                    widget.onChanged();
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _WorkoutPlanSetupTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _WorkoutPlanSetupTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final accent = scheme.primary;
    final tileSurface = expressive != null
        ? (selected
              ? expressive.selectedSurface
              : Color.lerp(
                  expressive.planSupportSurface,
                  expressive.pageCanvas,
                  0.55,
                )!)
        : neo
        ? (selected ? surfaces.settingsHero : surfaces.dialogChoice)
        : null;
    final tileForeground = expressive != null
        ? (selected
              ? _expressiveSelectedForeground(context, expressive)
              : expressive.planSupportForeground)
        : neo
        ? tonosForegroundForSurface(context, tileSurface!)
        : scheme.onSurface;
    final tileSecondary = expressive != null
        ? tileForeground.withValues(alpha: 0.82)
        : neo
        ? tonosSecondaryForegroundForSurface(context, tileSurface!)
        : scheme.onSurfaceVariant;
    final tileBorder = expressive != null
        ? expressive.outline.withValues(alpha: selected ? 1 : 0.4)
        : neo
        ? tonosOutlineForSurface(context, tileSurface!)
        : selected
        ? accent
        : scheme.outlineVariant;
    final tileBackground = expressive != null
        ? tileSurface
        : neo
        ? tileSurface
        : selected
        ? accent.withValues(alpha: 0.16)
        : scheme.surface.withValues(alpha: 0.46);
    final tileShape =
        expressive?.rowShape ??
        (neo ? shapes.settingsInput : context.tutorialTokens.tileShape);

    return InkWell(
      onTap: onTap,
      borderRadius: tileShape,
      child: AnimatedContainer(
        duration: _onboardingSelectionMotion(context),
        curve: context.usesExpressivePresentation
            ? TonosExpressiveStateMotion.effects
            : Curves.linear,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tileBackground,
          borderRadius: tileShape,
          border: Border.all(
            color: tileBorder,
            width: expressive != null
                ? (selected ? 1.5 : 1)
                : neo
                ? shapes.outlineWidth
                : selected
                ? 2
                : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: expressive != null
                    ? expressive.actionSecondary
                    : (neo ? tileForeground : accent).withValues(alpha: 0.16),
                borderRadius: expressive != null
                    ? shapes.control
                    : neo
                    ? shapes.control
                    : context.tutorialTokens.compactShape,
              ),
              child: Icon(
                icon,
                color: expressive != null
                    ? expressive.actionSecondaryForeground
                    : neo
                    ? tileForeground
                    : accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: expressive != null || neo ? tileForeground : null,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tileSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: expressive != null
                  ? (selected
                        ? _expressiveSelectedForeground(context, expressive)
                        : tileSecondary)
                  : neo
                  ? tileForeground
                  : selected
                  ? accent
                  : tileSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
