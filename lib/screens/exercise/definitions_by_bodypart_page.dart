// File: lib/screens/exercise/definitions_by_bodypart_page.dart

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../services/catalog_entity_localizer.dart';
import '../../services/tutorial_state_store.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../theme/widgets/app_expressive_destination_theme.dart';
import '../../utils/localized_body_part_name.dart';
import '../../utils/localized_formatters.dart';
import '../../utils/tutorial_launcher.dart';
import '../../widgets/body_heatmap.dart';
import '../../widgets/exercise_definition_info_tile.dart';
import '../../widgets/localized_catalog_entity_name.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/recommended_sets_editor_dialog.dart';
import '../../widgets/set_stat_chip.dart';
import '../../theme/widgets/tonos_theme_ready.dart';
import 'definitions_by_muscle_page.dart';

/// Bodypart detail page for the exercise focus library.
///
/// Shows linked exercises, associated muscles, recent seven-day set units, and
/// editable recommended set bounds for one bodypart.
class DefinitionsByBodyPartPage extends StatefulWidget {
  final BodyPart bodyPart;
  final bool expressiveCatalogPresentation;
  final bool expressiveAnalyticsPresentation;

  const DefinitionsByBodyPartPage({
    super.key,
    required this.bodyPart,
    this.expressiveCatalogPresentation = false,
    this.expressiveAnalyticsPresentation = false,
  });

  @override
  State<DefinitionsByBodyPartPage> createState() =>
      _DefinitionsByBodyPartPageState();
}

class _DefinitionsByBodyPartPageState extends State<DefinitionsByBodyPartPage> {
  AppRepository get _repo => context.read<AppRepository>();
  final _headerTutorialKey = GlobalKey(debugLabel: 'bodypart_detail_header');
  final _exerciseListTutorialKey = GlobalKey(
    debugLabel: 'bodypart_detail_exercise_list',
  );
  late Future<_BodyPartPageData> _dataFuture;
  bool _tutorialQueued = false;
  final _exerciseSearchController = TextEditingController();
  String _exerciseQuery = '';

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  @override
  void dispose() {
    _exerciseSearchController.dispose();
    super.dispose();
  }

  void _clearExerciseSearch() {
    _exerciseSearchController.clear();
    setState(() => _exerciseQuery = '');
  }

  /// Loads all page data together so the header and exercise list stay
  /// consistent with the same snapshot of definitions and set totals.
  Future<_BodyPartPageData> _loadData() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));

    final definitionsFuture = _repo.lookupDefsDetailed();
    final musclesFuture = _repo.fetchAllMuscles();
    final linksFuture = _repo.fetchMusclesForBodyPart(widget.bodyPart.id);
    final recentSetsFuture = _repo.fetchAllBodyPartSetsOverTimeRange(
      start: start,
      end: now,
    );
    final boundsFuture = _repo.fetchBodyPartVolumeBounds(widget.bodyPart.id);

    final definitions = (await definitionsFuture)
        .where(
          (def) => def.bodyParts.any((part) => part.id == widget.bodyPart.id),
        )
        .toList();
    final muscles = await musclesFuture;
    final links = await linksFuture;
    final recentSets = await recentSetsFuture;
    final bounds = await boundsFuture;

    final muscleById = {for (final muscle in muscles) muscle.id: muscle};
    final linkedMuscles =
        links
            .map((link) => muscleById[link.muscleId])
            .whereType<Muscle>()
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    definitions.sort((a, b) => a.name.compareTo(b.name));

    return _BodyPartPageData(
      definitions: definitions,
      muscles: linkedMuscles,
      recentSetUnits: _setUnitsForBodyPart(recentSets, widget.bodyPart.id),
      volumeBounds: bounds,
    );
  }

  double _setUnitsForBodyPart(Map<BodyPart, double> rows, int bodyPartId) {
    return rows.entries
        .where((entry) => entry.key.id == bodyPartId)
        .fold<double>(0.0, (sum, entry) => sum + entry.value);
  }

  void _queueTutorial() {
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  Future<void> _showTutorial() async {
    try {
      final strings = AppLocalizations.of(context);
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.bodypartDetail,
        steps: [
          GuidedTutorialStep(
            targetKey: _headerTutorialKey,
            icon: Icons.accessibility_new,
            title: strings.anatomyTutorialDetailTitle,
            body: strings.anatomyTutorialBodypartDetailBody,
          ),
          GuidedTutorialStep(
            targetKey: _exerciseListTutorialKey,
            icon: Icons.fitness_center,
            title: strings.anatomyTutorialLinkedExercisesTitle,
            body: strings.anatomyTutorialBodypartExercisesBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final expressiveFamily = widget.expressiveAnalyticsPresentation
        ? AppExpressiveDestinationFamily.analytics
        : widget.expressiveCatalogPresentation
        ? AppExpressiveDestinationFamily.catalog
        : null;
    final expressive =
        expressiveFamily != null && context.usesExpressivePresentation;
    final expressiveCatalogDetail =
        expressive &&
        expressiveFamily == AppExpressiveDestinationFamily.catalog;
    final destinationTokens = expressive
        ? AppExpressiveDestinationTokens.forFamily(
            expressiveFamily,
            Theme.of(context).brightness,
          )
        : null;
    final page = Scaffold(
      backgroundColor: expressive ? destinationTokens?.pageCanvas : null,
      appBar: AppBar(
        backgroundColor: expressiveCatalogDetail
            ? destinationTokens?.pageCanvas
            : null,
        surfaceTintColor: expressiveCatalogDetail ? Colors.transparent : null,
        scrolledUnderElevation: expressiveCatalogDetail ? 0 : null,
        title: Text(
          expressiveCatalogDetail
              ? localizedBodyPartName(context, widget.bodyPart.name)
              : strings.anatomyTargetExercises(
                  localizedBodyPartName(context, widget.bodyPart.name),
                ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: expressiveCatalogDetail
              ? Theme.of(context).textTheme.titleMedium
              : null,
        ),
      ),
      body: FutureBuilder<_BodyPartPageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(strings.anatomyBodypartLoadFailed));
          }

          final data = snapshot.data!;
          final query = _exerciseQuery.trim().toLowerCase();
          final visibleDefinitions = expressiveCatalogDetail && query.isNotEmpty
              ? data.definitions
                    .where(
                      (definition) =>
                          definition.name.toLowerCase().contains(query),
                    )
                    .toList(growable: false)
              : data.definitions;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _queueTutorial();
          });
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: visibleDefinitions.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return KeyedSubtree(
                  key: _headerTutorialKey,
                  child: _BodyPartHeader(
                    bodyPart: widget.bodyPart,
                    data: data,
                    expressive: expressive,
                    compactCatalogDetail: expressiveCatalogDetail,
                    exerciseSearch: expressiveCatalogDetail
                        ? _BodypartExerciseSearch(
                            controller: _exerciseSearchController,
                            noMatches:
                                data.definitions.isNotEmpty &&
                                visibleDefinitions.isEmpty,
                            onChanged: (value) =>
                                setState(() => _exerciseQuery = value),
                            onClear: _clearExerciseSearch,
                          )
                        : null,
                    onEditRecommended: () => _editRecommendedSets(data),
                    onMuscleTap: (muscle) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) {
                            final page = DefinitionsByMusclePage(
                              muscle: muscle,
                              sourceBodyPart: widget.bodyPart,
                              expressiveCatalogPresentation:
                                  expressive &&
                                  expressiveFamily ==
                                      AppExpressiveDestinationFamily.catalog,
                              expressiveAnalyticsPresentation:
                                  expressive &&
                                  expressiveFamily ==
                                      AppExpressiveDestinationFamily.analytics,
                            );
                            return expressive
                                ? AppExpressiveDestinationTheme(
                                    family: expressiveFamily,
                                    child: page,
                                  )
                                : page;
                          },
                        ),
                      );
                    },
                  ),
                );
              }

              final definition = visibleDefinitions[index - 1];
              return KeyedSubtree(
                key: index == 1 ? _exerciseListTutorialKey : null,
                child: _ExerciseDefinitionTile(
                  definition: definition,
                  expressive: expressive,
                  expressiveFamily: expressiveFamily,
                  compactCatalogDetail: expressiveCatalogDetail,
                ),
              );
            },
          );
        },
      ),
    );
    return expressive
        ? AppExpressiveDestinationTheme(family: expressiveFamily, child: page)
        : page;
  }

  Future<void> _editRecommendedSets(_BodyPartPageData data) async {
    final updatedBounds = await showRecommendedSetsEditorDialog(
      context,
      targetName: localizedBodyPartName(context, widget.bodyPart.name),
      targetId: widget.bodyPart.id,
      currentBounds: data.volumeBounds,
    );
    if (updatedBounds == null) return;

    try {
      await _repo.setBodyPartVolumeBounds(widget.bodyPart.id, updatedBounds);
      if (!mounted) return;

      setState(() {
        _dataFuture = _loadData();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).anatomyRecommendedSetsUpdated(
              localizedBodyPartName(context, widget.bodyPart.name),
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).anatomySaveFailed)),
      );
    }
  }
}

class _BodyPartHeader extends StatelessWidget {
  final BodyPart bodyPart;
  final _BodyPartPageData data;
  final bool expressive;
  final bool compactCatalogDetail;
  final Widget? exerciseSearch;
  final VoidCallback onEditRecommended;
  final ValueChanged<Muscle> onMuscleTap;

  const _BodyPartHeader({
    required this.bodyPart,
    required this.data,
    required this.expressive,
    required this.compactCatalogDetail,
    this.exerciseSearch,
    required this.onEditRecommended,
    required this.onMuscleTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final destinationTokens = theme.extension<AppExpressiveDestinationTokens>();
    final heroSurface = expressive && destinationTokens != null
        ? compactCatalogDetail
              ? theme.brightness == Brightness.dark
                    ? const Color(0xFF30243E)
                    : const Color(0xFFE9DDF1)
              : destinationTokens.surfaceTertiary
        : null;
    final associatedChipSurface = compactCatalogDetail
        ? Color.alphaBlend(
            destinationTokens!.surfaceAccent.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.18 : 0.07,
            ),
            destinationTokens.pageCanvas,
          )
        : null;
    return Padding(
      padding: compactCatalogDetail
          ? const EdgeInsets.fromLTRB(16, 8, 16, 8)
          : const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TonosThemeReadyCard(
            color: expressive
                ? heroSurface ?? theme.colorScheme.surfaceContainerLow
                : null,
            elevation: expressive ? 0 : null,
            shape: expressive
                ? compactCatalogDetail
                      ? const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                        )
                      : const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(28),
                            bottomLeft: Radius.circular(12),
                          ),
                        )
                : null,
            child: Padding(
              padding: EdgeInsets.all(compactCatalogDetail ? 14 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedBodyPartName(context, bodyPart.name),
                    maxLines: expressive
                        ? (compactCatalogDetail ? null : 2)
                        : 1,
                    overflow: expressive && compactCatalogDetail
                        ? null
                        : TextOverflow.ellipsis,
                    style:
                        (expressive
                                ? compactCatalogDetail
                                      ? theme.textTheme.titleMedium
                                      : theme.textTheme.titleLarge
                                : theme.textTheme.titleLarge)
                            ?.copyWith(
                              color: expressive
                                  ? compactCatalogDetail
                                        ? destinationTokens
                                              ?.supportingForeground
                                        : destinationTokens?.onSurfaceTertiary
                                  : null,
                              fontWeight: expressive ? FontWeight.w700 : null,
                            ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)
                        .anatomyLinkedExerciseCount(data.definitions.length),
                    style: expressive
                        ? theme.textTheme.bodyMedium?.copyWith(
                            color: compactCatalogDetail
                                ? destinationTokens?.supportingForeground
                                : destinationTokens?.onSurfaceTertiary,
                          )
                        : null,
                  ),
                  SizedBox(height: compactCatalogDetail ? 10 : 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      final gap = compactCatalogDetail || maxWidth < 330
                          ? 10.0
                          : 16.0;
                      final heatmapBox = compactCatalogDetail
                          ? (maxWidth * 0.42).clamp(112.0, 144.0).toDouble()
                          : (maxWidth * 0.56).clamp(134.0, 178.0).toDouble();
                      final heatmapSize = compactCatalogDetail
                          ? heatmapBox
                          : heatmapBox.clamp(128.0, 178.0).toDouble();

                      final heatmap = SizedBox(
                        width: heatmapBox,
                        height: heatmapBox,
                        child: Center(
                          child: SingleBodyPartHeatmap(
                            bodyPartName: bodyPart.name,
                            size: heatmapSize,
                            padding: 2,
                            lowColor:
                                compactCatalogDetail &&
                                    theme.brightness == Brightness.light
                                ? const Color(0xFF888A93)
                                : null,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      );
                      final strings = AppLocalizations.of(context);
                      final recentValue = strings.anatomySetUnits(
                        LocalizedFormatters.number(
                          data.recentSetUnits,
                          Localizations.localeOf(context),
                          minimumFractionDigits: 1,
                          maximumFractionDigits: 1,
                        ),
                      );
                      final recommendedValue = _rangeLabel(
                        strings,
                        data.volumeBounds,
                        Localizations.localeOf(context),
                      );
                      if (compactCatalogDetail) {
                        final metrics = _BodyPartExpressiveMetricBays(
                          recentLabel: strings.anatomyDoneSevenDaysCompact,
                          recentValue: recentValue,
                          recommendedLabel:
                              strings.anatomyRecommendedWeeklyCompact,
                          recommendedValue: recommendedValue,
                          onEdit: onEditRecommended,
                        );
                        final availableMetricWidth =
                            maxWidth - heatmapBox - gap;
                        final stack =
                            availableMetricWidth < 156 ||
                            MediaQuery.textScalerOf(context).scale(16) > 22;
                        if (stack) {
                          return Column(
                            children: [
                              heatmap,
                              const SizedBox(height: 12),
                              metrics,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            heatmap,
                            SizedBox(width: gap),
                            Expanded(child: metrics),
                          ],
                        );
                      }
                      if (expressive) {
                        final metrics = _BodyPartExpressiveMetricBays(
                          recentLabel: strings.anatomyDoneLastSevenDays,
                          recentValue: recentValue,
                          recommendedLabel: strings.anatomyRecommended,
                          recommendedValue: recommendedValue,
                          onEdit: onEditRecommended,
                          compactCatalogDetail: false,
                        );
                        final stack =
                            maxWidth < 380 ||
                            MediaQuery.textScalerOf(context).scale(16) > 19;
                        if (stack) {
                          return Column(
                            children: [
                              heatmap,
                              const SizedBox(height: 12),
                              metrics,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            heatmap,
                            SizedBox(width: gap),
                            Expanded(child: metrics),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          heatmap,
                          SizedBox(width: gap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SetStatChip(
                                  label: strings.anatomyDoneLastSevenDays,
                                  value: recentValue,
                                ),
                                const SizedBox(height: 10),
                                SetStatChip(
                                  label: strings.anatomyRecommended,
                                  value: recommendedValue,
                                  onEdit: onEditRecommended,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: compactCatalogDetail ? 10 : 16),
          Text(
            AppLocalizations.of(context).anatomyAssociatedMuscles,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: expressive ? FontWeight.w700 : null,
              color: expressive
                  ? destinationTokens?.actionPrimary ??
                        theme.colorScheme.primary
                  : null,
            ),
          ),
          SizedBox(height: compactCatalogDetail ? 4 : 8),
          if (data.muscles.isEmpty)
            Text(
              AppLocalizations.of(context).anatomyNoMuscleLinks,
              style: theme.textTheme.bodyMedium,
            )
          else
            Wrap(
              spacing: compactCatalogDetail ? 6 : 8,
              runSpacing: compactCatalogDetail ? 2 : 8,
              children: data.muscles
                  .map(
                    (muscle) => ActionChip(
                      backgroundColor: compactCatalogDetail
                          ? associatedChipSurface
                          : null,
                      side: compactCatalogDetail
                          ? BorderSide(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.55),
                            )
                          : null,
                      labelPadding: compactCatalogDetail
                          ? const EdgeInsets.symmetric(horizontal: 6)
                          : null,
                      labelStyle: compactCatalogDetail
                          ? theme.textTheme.labelMedium?.copyWith(
                              color: destinationTokens?.supportingForeground,
                            )
                          : null,
                      label: LocalizedCatalogEntityName(
                        entity: CatalogEntityDisplayName(
                          catalogId: muscle.catalogId,
                          canonicalName: muscle.name,
                        ),
                        maxLines: expressive ? null : 1,
                        overflow: expressive ? null : TextOverflow.ellipsis,
                      ),
                      avatar: Icon(
                        Icons.fitness_center,
                        size: compactCatalogDetail ? 16 : 18,
                      ),
                      onPressed: () => onMuscleTap(muscle),
                    ),
                  )
                  .toList(),
            ),
          Divider(height: compactCatalogDetail ? 16 : 32),
          Text(
            AppLocalizations.of(context).anatomyExercises,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: expressive ? FontWeight.w700 : null,
              color: expressive
                  ? destinationTokens?.actionPrimary ??
                        theme.colorScheme.primary
                  : null,
            ),
          ),
          if (exerciseSearch != null) ...[
            const SizedBox(height: 8),
            exerciseSearch!,
          ],
          if (data.definitions.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).anatomyNoExercisesFor(
                localizedBodyPartName(context, bodyPart.name),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _rangeLabel(
    AppLocalizations strings,
    VolumeBoundaries? bounds,
    Locale locale,
  ) {
    if (bounds == null) return strings.anatomyNotSet;
    final min = LocalizedFormatters.number(
      bounds.minEffective,
      locale,
      maximumFractionDigits: 0,
    );
    final max = LocalizedFormatters.number(
      bounds.maxRecoverable,
      locale,
      maximumFractionDigits: 0,
    );
    return strings.anatomySetRange(min, max);
  }
}

class _BodyPartExpressiveMetricBays extends StatelessWidget {
  const _BodyPartExpressiveMetricBays({
    required this.recentLabel,
    required this.recentValue,
    required this.recommendedLabel,
    required this.recommendedValue,
    required this.onEdit,
    this.compactCatalogDetail = true,
  });

  final String recentLabel;
  final String recentValue;
  final String recommendedLabel;
  final String recommendedValue;
  final VoidCallback onEdit;
  final bool compactCatalogDetail;

  @override
  Widget build(BuildContext context) {
    if (!compactCatalogDetail) {
      final tokens = Theme.of(context)
          .extension<AppExpressiveDestinationTokens>()!;
      final first = _BodyPartExpressiveMetricBay(
        label: recentLabel,
        value: recentValue,
        compactCatalogDetail: false,
      );
      final second = _BodyPartExpressiveMetricBay(
        label: recommendedLabel,
        value: recommendedValue,
        onEdit: onEdit,
        compactCatalogDetail: false,
      );
      return LayoutBuilder(
        builder: (context, constraints) {
          final stacked =
              MediaQuery.textScalerOf(context).scale(16) > 19 ||
              constraints.maxWidth < 310;
          return Container(
            decoration: BoxDecoration(
              color: tokens.surfaceSelected,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(8),
              ),
              border: Border.all(
                color: tokens.outlineAccent.withValues(alpha: 0.35),
              ),
            ),
            child: stacked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      first,
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: tokens.outlineAccent.withValues(alpha: 0.25),
                      ),
                      second,
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: first),
                      Container(
                        width: 1,
                        height: 48,
                        color: tokens.outlineAccent.withValues(alpha: 0.25),
                      ),
                      Expanded(child: second),
                    ],
                  ),
          );
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BodyPartExpressiveMetricBay(label: recentLabel, value: recentValue),
        const SizedBox(height: 6),
        _BodyPartExpressiveMetricBay(
          label: recommendedLabel,
          value: recommendedValue,
          onEdit: onEdit,
        ),
      ],
    );
  }
}

class _BodyPartExpressiveMetricBay extends StatelessWidget {
  const _BodyPartExpressiveMetricBay({
    required this.label,
    required this.value,
    this.onEdit,
    this.compactCatalogDetail = true,
  });

  final String label;
  final String value;
  final VoidCallback? onEdit;
  final bool compactCatalogDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppExpressiveDestinationTokens>()!;
    if (!compactCatalogDetail) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 2,
              style: theme.textTheme.labelSmall?.copyWith(
                color: tokens.onSurfaceSelected,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 2,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: tokens.onSurfaceSelected,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconTheme.merge(
                    data: IconThemeData(color: tokens.onSurfaceSelected),
                    child: RecommendedSetsEditButton(onPressed: onEdit!),
                  ),
              ],
            ),
          ],
        ),
      );
    }
    final heroSurface = theme.brightness == Brightness.dark
        ? const Color(0xFF30243E)
        : const Color(0xFFE9DDF1);
    final surface = Color.alphaBlend(
      tokens.surfaceSelected.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.22 : 0.30,
      ),
      heroSurface,
    );
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tokens.supportingForeground,
                  ),
                ),
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: tokens.actionPrimary,
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: tokens.supportingForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(14),
      child: onEdit == null
          ? content
          : Semantics(
              button: true,
              label: AppLocalizations.of(context).recommendedSetsEdit,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onEdit,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: content,
                ),
              ),
            ),
    );
  }
}

class _BodypartExerciseSearch extends StatelessWidget {
  const _BodypartExerciseSearch({
    required this.controller,
    required this.noMatches,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool noMatches;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<AppExpressiveDestinationTokens>()!;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('bodypart-exercise-search'),
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: strings.catalogSearchExercises,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: strings.catalogClearSearch,
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHigh,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: tokens.outlineAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
        if (noMatches) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tokens.surfaceSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.catalogNoSearchMatches,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: tokens.onSurfaceSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.catalogNoSearchMatchesBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.onSurfaceSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded),
                    label: Text(strings.catalogClearSearch),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ExerciseDefinitionTile extends StatelessWidget {
  final ExerciseDefinition definition;
  final bool expressive;
  final AppExpressiveDestinationFamily? expressiveFamily;
  final bool compactCatalogDetail;

  const _ExerciseDefinitionTile({
    required this.definition,
    required this.expressive,
    required this.expressiveFamily,
    required this.compactCatalogDetail,
  });

  @override
  Widget build(BuildContext context) {
    return ExerciseDefinitionInfoTile(
      definition: definition,
      subtitle: _ExerciseMetadata(
        definition: definition,
        expressive: expressive,
        compactCatalogDetail: compactCatalogDetail,
      ),
      expressiveDestinationFamily: expressive ? expressiveFamily : null,
      compactExpressivePresentation: compactCatalogDetail,
      bodypartExercisePreview: compactCatalogDetail,
    );
  }
}

class _ExerciseMetadata extends StatelessWidget {
  final ExerciseDefinition definition;
  final bool expressive;
  final bool compactCatalogDetail;

  const _ExerciseMetadata({
    required this.definition,
    required this.expressive,
    required this.compactCatalogDetail,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final destinationTokens = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final equipmentStyle = compactCatalogDetail
        ? theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: destinationTokens?.supportingForeground,
            fontWeight: FontWeight.w400,
          )
        : TextStyle(
            color: expressive
                ? destinationTokens?.actionPrimary
                : colors.primary,
            fontWeight: FontWeight.w600,
          );
    final muscleStyle = compactCatalogDetail
        ? theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: destinationTokens?.supportingForeground,
            fontWeight: FontWeight.w400,
          )
        : expressive
        ? TextStyle(
            color: destinationTokens?.supportingForeground,
            fontWeight: FontWeight.w500,
          )
        : TextStyle(
            color: context.usesNeoPresentation
                ? context.semanticColors.positive
                : Colors.green.shade600,
            fontWeight: FontWeight.w500,
          );
    final equipmentEntities = definition.equipmentList
        .where((item) => item.name.trim().isNotEmpty)
        .map(
          (item) => CatalogEntityDisplayName(
            catalogId: item.catalogId,
            canonicalName: item.name,
          ),
        )
        .toList(growable: false);
    final equipmentLabel = equipmentEntities.isEmpty
        ? Text(strings.anatomyNoEquipment, style: equipmentStyle)
        : LocalizedCatalogEntityNamesBuilder(
            entities: equipmentEntities,
            builder: (context, names) {
              final text = Text(
                compactCatalogDetail
                    ? _previewSummary(context, names, 2)
                    : names.join(', '),
                maxLines: compactCatalogDetail ? 1 : null,
                overflow: compactCatalogDetail ? TextOverflow.ellipsis : null,
                style: equipmentStyle,
              );
              return compactCatalogDetail
                  ? Tooltip(message: names.join(', '), child: text)
                  : text;
            },
          );

    var muscles = definition.muscles;
    if (compactCatalogDetail) {
      // Rank the preview using a copy, retaining source order for equal ranks.
      // The complete definition and its stored associations stay unchanged.
      final ranked = muscles.indexed.toList()
        ..sort((a, b) {
          final rank = a.$2.rank.compareTo(b.$2.rank);
          return rank != 0 ? rank : a.$1.compareTo(b.$1);
        });
      muscles = ranked.map((entry) => entry.$2).toList(growable: false);
    }
    final muscleEntities = (compactCatalogDetail ? muscles : muscles.take(3))
        .where(
          (ranked) =>
              !compactCatalogDetail || ranked.muscle.name.trim().isNotEmpty,
        )
        .map(
          (ranked) => CatalogEntityDisplayName(
            catalogId: ranked.muscle.catalogId,
            canonicalName: ranked.muscle.name,
          ),
        )
        .toList(growable: false);
    final muscleLabel = muscleEntities.isEmpty
        ? Text(
            strings.anatomyNoMusclesListed,
            maxLines: expressive ? null : 1,
            overflow: expressive ? null : TextOverflow.ellipsis,
            style: muscleStyle,
          )
        : LocalizedCatalogEntityNamesBuilder(
            entities: muscleEntities,
            builder: (context, names) {
              final text = Text(
                compactCatalogDetail
                    ? _previewSummary(context, names, 3)
                    : names.join(', '),
                maxLines: compactCatalogDetail ? 1 : null,
                overflow: compactCatalogDetail ? TextOverflow.ellipsis : null,
                style: muscleStyle,
              );
              return compactCatalogDetail
                  ? Tooltip(message: names.join(', '), child: text)
                  : text;
            },
          );

    return Padding(
      padding: EdgeInsets.only(top: compactCatalogDetail ? 0 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          equipmentLabel,
          SizedBox(height: compactCatalogDetail ? 4 : 3),
          muscleLabel,
        ],
      ),
    );
  }

  String _previewSummary(BuildContext context, List<String> names, int limit) {
    final summary = names.take(limit).join(' · ');
    final remaining = names.length - limit;
    return remaining > 0
        ? '$summary  +${AppLocalizations.of(context).generateMoreNames(remaining)}'
        : summary;
  }
}

class _BodyPartPageData {
  final List<ExerciseDefinition> definitions;
  final List<Muscle> muscles;
  final double recentSetUnits;
  final VolumeBoundaries? volumeBounds;

  const _BodyPartPageData({
    required this.definitions,
    required this.muscles,
    required this.recentSetUnits,
    required this.volumeBounds,
  });
}
