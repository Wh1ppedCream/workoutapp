// file: lib/widgets/presets_loaded.dart

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/selected_profile.dart';
import '../repositories/app_repository.dart';
import '../services/active_plan_store.dart';
import '../theme/tokens/app_expressive_train_tokens.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/tonos_expressive_motion.dart';
import '../theme/widgets/tonos_surface.dart';
import '../utils/async_pool.dart';
import 'body_heatmap.dart';
import 'identity_color_palettes.dart';
import 'preset_bar.dart';

/// Fetches & displays presets for the current profile.
/// Handles loading, empty, and error states, then renders a scrollable list of [PresetBar]s.
class PresetsLoaded extends StatefulWidget {
  static const defaultEmptyMessage = 'No plans found.';

  /// Uniform scale factor for paddings and font sizes.
  final double scale;

  /// Called after a rename/delete to reload the list.
  final VoidCallback onRefresh;
  final int refreshToken;
  final Set<int>? presetIds;
  final Set<int>? excludedPresetIds;
  final String emptyMessage;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final bool? planActiveState;
  final bool progressiveReveal;
  final int initialVisibleCount;
  final int revealBatchSize;
  final bool useExpressiveTrainPresentation;
  final bool expressiveMotionEnabled;

  const PresetsLoaded({
    super.key,
    this.scale = 1.0,
    this.refreshToken = 0,
    this.presetIds,
    this.excludedPresetIds,
    this.emptyMessage = defaultEmptyMessage,
    this.physics,
    this.padding,
    this.shrinkWrap = true,
    this.planActiveState,
    this.progressiveReveal = false,
    this.initialVisibleCount = 3,
    this.revealBatchSize = 5,
    this.useExpressiveTrainPresentation = false,
    this.expressiveMotionEnabled = true,
    required this.onRefresh,
  }) : assert(initialVisibleCount > 0),
       assert(revealBatchSize > 0);

  @override
  State<PresetsLoaded> createState() => _PresetsLoadedState();
}

class _PresetListItem {
  final int presetId;
  final String name;
  final bool isAutomatic;
  final Map<String, double> focusFrequencyMap;
  final int listIndex;

  const _PresetListItem({
    required this.presetId,
    required this.name,
    required this.isAutomatic,
    required this.focusFrequencyMap,
    required this.listIndex,
  });
}

class _PresetsLoadedState extends State<PresetsLoaded>
    with AutomaticKeepAliveClientMixin<PresetsLoaded> {
  static const int _bodyPartAnalysisConcurrency = 6;

  AppRepository get _repo => context.read<AppRepository>();
  int? _loadedProfileId;
  int? _loadedRefreshToken;
  Future<List<_PresetListItem>>? _presetsFuture;
  List<_PresetListItem>? _lastRows;
  late int _visibleCount;

  @override
  void initState() {
    super.initState();
    _visibleCount = widget.initialVisibleCount;
  }

  @override
  void didUpdateWidget(covariant PresetsLoaded oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressiveReveal != widget.progressiveReveal ||
        oldWidget.initialVisibleCount != widget.initialVisibleCount ||
        oldWidget.refreshToken != widget.refreshToken ||
        oldWidget.presetIds != widget.presetIds ||
        oldWidget.excludedPresetIds != widget.excludedPresetIds) {
      _visibleCount = widget.initialVisibleCount;
    }
  }

  Future<List<_PresetListItem>> _loadPresets(int profileId) async {
    unawaited(BodyHeatmap.preload());
    final rows = await _repo.fetchPresetSummariesRaw(profileId: profileId);
    final presetIds = rows.map((row) => row['id'] as int).toList();
    final focusRows = await _repo.fetchPresetFocusSetCountsRaw(
      presetIds: presetIds,
    );
    final focusSetCountsByPreset = _groupFocusSetCounts(focusRows);
    final unitsByDefinition = await _loadBodyPartUnitsByDefinition(
      focusSetCountsByPreset,
    );

    final items = <_PresetListItem>[];
    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
      final presetId = row['id'] as int;
      items.add(
        _PresetListItem(
          presetId: presetId,
          name: row['name'] as String,
          isAutomatic: (row['is_automatic'] as int? ?? 0) == 1,
          focusFrequencyMap: _buildFocusFrequencyMap(
            focusSetCountsByPreset[presetId] ?? const <int, int>{},
            unitsByDefinition,
          ),
          listIndex: index,
        ),
      );
    }
    return items;
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
    }.toList();
    if (defIds.isEmpty) return const <int, Map<String, double>>{};

    final entries =
        await mapWithConcurrency<int, MapEntry<int, Map<String, double>>>(
          defIds,
          maxConcurrency: _bodyPartAnalysisConcurrency,
          mapper: (defId, _) async {
            final units = await _repo.computeBodyPartPercents(defId);
            return MapEntry(defId, {
              for (final entry in units.entries)
                if (entry.value > 0.0) entry.key.name: entry.value,
            });
          },
        );
    return Map<int, Map<String, double>>.fromEntries(entries);
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

  void _refreshPresets() {
    widget.onRefresh();
    final profileId = _loadedProfileId;
    if (profileId == null) return;
    setState(() {
      _presetsFuture = _loadPresets(profileId);
    });
  }

  Future<void> _setPlanActive(int profileId, int presetId, bool active) async {
    if (active) {
      await context.read<ActivePlanStore>().add(profileId, presetId);
    } else {
      await context.read<ActivePlanStore>().remove(profileId, presetId);
    }
    if (!mounted) return;
    _refreshPresets();
  }

  @override
  bool get wantKeepAlive => true;

  bool _usesExpressiveTrainPresentation(BuildContext context) =>
      widget.useExpressiveTrainPresentation &&
      context.usesExpressivePresentation;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final strings = AppLocalizations.of(context);
    final sel = context.watch<SelectedProfile>();
    final profileId = sel.currentProfile?.id;

    final profileChanged = _loadedProfileId != profileId;
    if (profileChanged || _loadedRefreshToken != widget.refreshToken) {
      _loadedProfileId = profileId;
      _loadedRefreshToken = widget.refreshToken;
      if (profileChanged) {
        _lastRows = null;
      }
      _presetsFuture = profileId == null ? null : _loadPresets(profileId);
    }

    if (profileId == null) {
      return Center(
        child: _usesExpressiveTrainPresentation(context)
            ? _expressiveStatus(
                context,
                icon: Icons.person_outline,
                message: strings.presetsNoProfile,
              )
            : Text(strings.presetsNoProfile),
      );
    }

    return FutureBuilder<List<_PresetListItem>>(
      future: _presetsFuture,
      initialData: _lastRows,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done && !snap.hasData) {
          return Center(
            child: _usesExpressiveTrainPresentation(context)
                ? _expressiveLoading(context)
                : const CircularProgressIndicator(),
          );
        }
        if (snap.hasError && !snap.hasData) {
          if (_usesExpressiveTrainPresentation(context)) {
            return _expressiveStatus(
              context,
              icon: Icons.error_outline,
              message: strings.presetsLoadError,
            );
          }
          return Padding(
            padding: EdgeInsets.all(16 * widget.scale),
            child: Text(strings.presetsLoadError),
          );
        }

        final loadedRows = snap.data ?? const <_PresetListItem>[];
        if (snap.connectionState == ConnectionState.done && snap.hasData) {
          _lastRows = loadedRows;
        }
        final rows = loadedRows.where((row) {
          final included =
              widget.presetIds == null ||
              widget.presetIds!.contains(row.presetId);
          final excluded =
              widget.excludedPresetIds?.contains(row.presetId) ?? false;
          return included && !excluded;
        }).toList();
        if (rows.isEmpty) {
          final emptyMessage =
              widget.emptyMessage == PresetsLoaded.defaultEmptyMessage
              ? strings.presetsNoPlans
              : widget.emptyMessage;
          if (context.usesNeoPresentation && widget.excludedPresetIds != null) {
            final surfaces = context.surfaceTokens;
            final foreground = tonosForegroundForSurface(
              context,
              surfaces.card,
            );
            return TonosSurface(
              variant: TonosSurfaceVariant.compactCard,
              color: surfaces.card,
              margin: EdgeInsets.symmetric(
                horizontal: 4 * widget.scale,
                vertical: 4 * widget.scale,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 12 * widget.scale,
                vertical: 12 * widget.scale,
              ),
              child: Row(
                children: [
                  Icon(Icons.archive_outlined, color: foreground),
                  SizedBox(width: 8 * widget.scale),
                  Expanded(
                    child: Text(
                      emptyMessage,
                      style: TextStyle(color: foreground),
                    ),
                  ),
                ],
              ),
            );
          }
          if (_usesExpressiveTrainPresentation(context)) {
            return _expressiveStatus(
              context,
              icon: Icons.inbox_outlined,
              message: emptyMessage,
            );
          }
          return Padding(
            padding: EdgeInsets.all(16 * widget.scale),
            child: Text(emptyMessage),
          );
        }

        final visibleLimit =
            widget.progressiveReveal && _visibleCount < rows.length
            ? _visibleCount
            : rows.length;
        final visibleRows = rows.take(visibleLimit).toList(growable: false);
        final remainingCount = rows.length - visibleRows.length;

        return ListView.builder(
          padding:
              widget.padding ??
              EdgeInsets.symmetric(vertical: 6 * widget.scale),
          physics: widget.physics,
          itemCount: visibleRows.length + (remainingCount > 0 ? 1 : 0),
          shrinkWrap: widget.shrinkWrap,
          itemBuilder: (ctx2, i) {
            if (i == visibleRows.length) {
              final revealCount = remainingCount < widget.revealBatchSize
                  ? remainingCount
                  : widget.revealBatchSize;
              return _ShowMorePlansButton(
                scale: widget.scale,
                revealCount: revealCount,
                remainingCount: remainingCount,
                useExpressiveTrainPresentation:
                    widget.useExpressiveTrainPresentation,
                expressiveMotionEnabled: widget.expressiveMotionEnabled,
                onPressed: () => setState(() {
                  _visibleCount += widget.revealBatchSize;
                }),
              );
            }

            final row = visibleRows[i];
            final color = PlanIdentityPalette
                .colors[row.listIndex % PlanIdentityPalette.colors.length];

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6 * widget.scale),
              child: PresetBar(
                presetId: row.presetId,
                label: row.name,
                color: color,
                index: row.listIndex,
                isAutomatic: row.isAutomatic,
                focusFrequencyMap: row.focusFrequencyMap,
                scale: widget.scale,
                isActivePlan: widget.planActiveState,
                useExpressiveTrainPresentation:
                    widget.useExpressiveTrainPresentation,
                expressiveMotionEnabled: widget.expressiveMotionEnabled,
                onSetActivePlan: widget.planActiveState == null
                    ? null
                    : (active) =>
                          _setPlanActive(profileId, row.presetId, active),
                onRefresh: _refreshPresets,
              ),
            );
          },
        );
      },
    );
  }
}

class _ShowMorePlansButton extends StatelessWidget {
  final double scale;
  final int revealCount;
  final int remainingCount;
  final bool useExpressiveTrainPresentation;
  final bool expressiveMotionEnabled;
  final VoidCallback onPressed;

  const _ShowMorePlansButton({
    required this.scale,
    required this.revealCount,
    required this.remainingCount,
    required this.useExpressiveTrainPresentation,
    required this.expressiveMotionEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final strings = AppLocalizations.of(context);
    final countText = revealCount == remainingCount
        ? strings.presetsShowMore(revealCount)
        : strings.presetsShowMoreRemaining(revealCount, remainingCount);
    if (useExpressiveTrainPresentation && context.usesExpressivePresentation) {
      final tokens = theme.extension<AppExpressiveTrainTokens>()!;
      final radius = ExpressiveTrainShapes.showMore;
      final shape = RoundedRectangleBorder(borderRadius: radius);
      return Padding(
        padding: EdgeInsets.only(top: 8 * scale),
        child: TonosExpressivePressResponse(
          enabled: expressiveMotionEnabled,
          borderRadius: radius,
          pressedBorderRadius: ExpressiveTrainShapes.compactControlPressed,
          pressedScale: TonosExpressiveMotionTiers.supportingScale,
          pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
          child: Material(
            color: tokens.creationSurface,
            shape: shape,
            child: InkWell(
              key: const ValueKey<String>('expressive-plan-show-more'),
              onTap: onPressed,
              customBorder: shape,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 11 * scale,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: tokens.actionPrimary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          countText,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: tokens.actionPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 8 * scale),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.keyboard_arrow_down),
        label: Text(countText),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(
            color: theme.colorScheme.primary.withValues(
              alpha: surfaces.planRevealBorderOpacity,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.lerp(
              BorderRadius.zero,
              shapes.card,
              scale,
            )!,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 14 * scale,
            vertical: 12 * scale,
          ),
        ),
      ),
    );
  }
}

Widget _expressiveLoading(BuildContext context) {
  final tokens = Theme.of(context).extension<AppExpressiveTrainTokens>()!;
  return Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 88),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: tokens.focusInset.withValues(alpha: 0.72),
      borderRadius: ExpressiveTrainShapes.focusInset,
    ),
    alignment: Alignment.center,
    child: CircularProgressIndicator(color: tokens.focusWarm),
  );
}

Widget _expressiveStatus(
  BuildContext context, {
  required IconData icon,
  required String message,
}) {
  final theme = Theme.of(context);
  final tokens = theme.extension<AppExpressiveTrainTokens>()!;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: tokens.creationSurface,
      borderRadius: ExpressiveTrainShapes.section,
    ),
    child: Row(
      children: [
        Icon(icon, color: tokens.actionPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
