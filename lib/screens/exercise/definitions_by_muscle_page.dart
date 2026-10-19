// File: lib/screens/exercise/definitions_by_muscle_page.dart

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
import '../../widgets/exercise_definition_info_tile.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/localized_catalog_entity_name.dart';
import '../../widgets/recommended_sets_editor_dialog.dart';
import '../../widgets/set_stat_chip.dart';
import '../../theme/widgets/tonos_theme_ready.dart';
import 'definitions_by_bodypart_page.dart';

/// Muscle detail page for the exercise focus library.
///
/// Shows linked exercises, associated bodyparts, recent seven-day set units,
/// and editable recommended set bounds for one muscle.
class DefinitionsByMusclePage extends StatefulWidget {
  final Muscle muscle;
  final BodyPart? sourceBodyPart;
  final bool expressiveCatalogPresentation;
  final bool expressiveAnalyticsPresentation;

  const DefinitionsByMusclePage({
    super.key,
    required this.muscle,
    this.sourceBodyPart,
    this.expressiveCatalogPresentation = false,
    this.expressiveAnalyticsPresentation = false,
  });

  @override
  State<DefinitionsByMusclePage> createState() =>
      _DefinitionsByMusclePageState();
}

class _DefinitionsByMusclePageState extends State<DefinitionsByMusclePage> {
  AppRepository get _repo => context.read<AppRepository>();
  final _headerTutorialKey = GlobalKey(debugLabel: 'muscle_detail_header');
  final _exerciseListTutorialKey = GlobalKey(
    debugLabel: 'muscle_detail_exercise_list',
  );
  late Future<_MusclePageData> _dataFuture;
  bool _tutorialQueued = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  /// Loads all page data together so recommendations, links, and exercise
  /// rankings are rendered from a consistent snapshot.
  Future<_MusclePageData> _loadData() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));

    final definitionsFuture = _repo.lookupDefsDetailed();
    final bodyPartsFuture = _repo.fetchAllBodyParts();
    final linksFuture = _repo.fetchBodyPartsForMuscle(widget.muscle.id);
    final recentSetsFuture = _repo.fetchSetsPerMuscle(start: start, end: now);
    final boundsFuture = _repo.fetchMuscleVolumeBounds(widget.muscle.id);

    final definitions =
        (await definitionsFuture)
            .where(
              (def) => def.muscles.any(
                (ranked) => ranked.muscle.id == widget.muscle.id,
              ),
            )
            .toList()
          ..sort(_compareDefinitionsByMuscleRank);
    final bodyParts = await bodyPartsFuture;
    final links = await linksFuture;
    final recentSets = await recentSetsFuture;
    final bounds = await boundsFuture;

    final bodyPartById = {
      for (final bodyPart in bodyParts) bodyPart.id: bodyPart,
    };
    final linkedBodyParts =
        links
            .map((link) => bodyPartById[link.bodyPartId])
            .whereType<BodyPart>()
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return _MusclePageData(
      definitions: definitions,
      bodyParts: linkedBodyParts,
      recentSetUnits: recentSets[widget.muscle.id] ?? 0.0,
      volumeBounds: bounds,
    );
  }

  int _compareDefinitionsByMuscleRank(
    ExerciseDefinition a,
    ExerciseDefinition b,
  ) {
    final aRank = _rankForMuscle(a);
    final bRank = _rankForMuscle(b);
    final rankCompare = aRank.compareTo(bRank);
    if (rankCompare != 0) return rankCompare;
    return a.name.compareTo(b.name);
  }

  int _rankForMuscle(ExerciseDefinition definition) {
    for (final ranked in definition.muscles) {
      if (ranked.muscle.id == widget.muscle.id) return ranked.rank;
    }
    return 999;
  }

  Future<void> _editRecommendedSets(_MusclePageData data) async {
    final displayName = await _localizedMuscleName();
    if (!mounted) return;
    final updatedBounds = await showRecommendedSetsEditorDialog(
      context,
      targetName: displayName,
      targetId: widget.muscle.id,
      currentBounds: data.volumeBounds,
    );
    if (updatedBounds == null) return;

    try {
      await _repo.setMuscleVolumeBounds(widget.muscle.id, updatedBounds);
      if (!mounted) return;

      setState(() {
        _dataFuture = _loadData();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .anatomyRecommendedSetsUpdated(displayName),
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

  Future<String> _localizedMuscleName() async {
    try {
      return await CatalogEntityLocalizer.instance.resolveName(
        CatalogEntityDisplayName(
          catalogId: widget.muscle.catalogId,
          canonicalName: widget.muscle.name,
        ),
        Localizations.localeOf(context),
      );
    } catch (_) {
      return widget.muscle.name;
    }
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
        tutorialId: TutorialIds.muscleDetail,
        steps: [
          GuidedTutorialStep(
            targetKey: _headerTutorialKey,
            icon: Icons.fitness_center,
            title: strings.anatomyTutorialMuscleDetailTitle,
            body: strings.anatomyTutorialMuscleDetailBody,
          ),
          GuidedTutorialStep(
            targetKey: _exerciseListTutorialKey,
            icon: Icons.list_alt,
            title: strings.anatomyTutorialLinkedExercisesTitle,
            body: strings.anatomyTutorialMuscleExercisesBody,
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
    final compactCatalogDetail =
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
        backgroundColor: compactCatalogDetail
            ? destinationTokens?.pageCanvas
            : null,
        surfaceTintColor: compactCatalogDetail ? Colors.transparent : null,
        scrolledUnderElevation: compactCatalogDetail ? 0 : null,
        title: LocalizedCatalogEntityNamesBuilder(
          entities: [
            CatalogEntityDisplayName(
              catalogId: widget.muscle.catalogId,
              canonicalName: widget.muscle.name,
            ),
          ],
          builder: (context, names) => Text(
            compactCatalogDetail
                ? names.single
                : strings.anatomyTargetExercises(names.single),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: FutureBuilder<_MusclePageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(strings.anatomyMuscleLoadFailed));
          }

          final data = snapshot.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _queueTutorial();
          });
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: data.definitions.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return KeyedSubtree(
                  key: _headerTutorialKey,
                  child: _MuscleHeader(
                    muscle: widget.muscle,
                    sourceBodyPart: widget.sourceBodyPart,
                    data: data,
                    expressive: expressive,
                    compactCatalogDetail: compactCatalogDetail,
                    onEditRecommended: () => _editRecommendedSets(data),
                    onBodyPartTap: (bodyPart) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) {
                            final page = DefinitionsByBodyPartPage(
                              bodyPart: bodyPart,
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

              final definition = data.definitions[index - 1];
              return KeyedSubtree(
                key: index == 1 ? _exerciseListTutorialKey : null,
                child: _ExerciseDefinitionTile(
                  definition: definition,
                  muscleId: widget.muscle.id,
                  expressive: expressive,
                  expressiveFamily: expressiveFamily,
                  compactCatalogDetail: compactCatalogDetail,
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
}

class _MuscleHeader extends StatelessWidget {
  final Muscle muscle;
  final BodyPart? sourceBodyPart;
  final _MusclePageData data;
  final bool expressive;
  final bool compactCatalogDetail;
  final VoidCallback onEditRecommended;
  final ValueChanged<BodyPart> onBodyPartTap;

  const _MuscleHeader({
    required this.muscle,
    required this.sourceBodyPart,
    required this.data,
    required this.expressive,
    required this.compactCatalogDetail,
    required this.onEditRecommended,
    required this.onBodyPartTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final destinationTokens = theme.extension<AppExpressiveDestinationTokens>();
    final quietSurface = destinationTokens == null
        ? theme.colorScheme.surfaceContainerLow
        : Color.alphaBlend(
            destinationTokens.surfaceAccent.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.18 : 0.07,
            ),
            destinationTokens.pageCanvas,
          );
    final heroSurface = compactCatalogDetail
        ? theme.brightness == Brightness.dark
              ? const Color(0xFF30243E)
              : const Color(0xFFE9DDF1)
        : quietSurface;
    return Padding(
      padding: compactCatalogDetail
          ? const EdgeInsets.fromLTRB(16, 8, 16, 6)
          : const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TonosThemeReadyCard(
            color: compactCatalogDetail
                ? heroSurface
                : expressive
                ? destinationTokens?.surfaceAccent ??
                      theme.colorScheme.surfaceContainerLow
                : null,
            elevation: expressive ? 0 : null,
            margin: compactCatalogDetail ? EdgeInsets.zero : null,
            shape: compactCatalogDetail
                ? const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  )
                : expressive
                ? const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(28),
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(28),
                    ),
                  )
                : null,
            child: Padding(
              padding: EdgeInsets.all(compactCatalogDetail ? 14 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      expressive
                          ? CircleAvatar(
                              radius: compactCatalogDetail ? 20 : 26,
                              backgroundColor: compactCatalogDetail
                                  ? Color.alphaBlend(
                                      destinationTokens!.surfaceSelected
                                          .withValues(alpha: 0.25),
                                      quietSurface,
                                    )
                                  : destinationTokens?.surfaceAccent,
                              child: Icon(
                                Icons.fitness_center,
                                color: compactCatalogDetail
                                    ? destinationTokens?.actionPrimary
                                    : destinationTokens?.onSurfaceAccent,
                                size: compactCatalogDetail ? 20 : 25,
                              ),
                            )
                          : CircleAvatar(
                              radius: 26,
                              child: LocalizedCatalogEntityNamesBuilder(
                                entities: [
                                  CatalogEntityDisplayName(
                                    catalogId: muscle.catalogId,
                                    canonicalName: muscle.name,
                                  ),
                                ],
                                builder: (context, names) => Text(
                                  _initialFor(names.single),
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                            ),
                      SizedBox(width: compactCatalogDetail ? 10 : 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LocalizedCatalogEntityName(
                              entity: CatalogEntityDisplayName(
                                catalogId: muscle.catalogId,
                                canonicalName: muscle.name,
                              ),
                              maxLines: compactCatalogDetail
                                  ? null
                                  : expressive
                                  ? 2
                                  : 1,
                              overflow: expressive
                                  ? null
                                  : TextOverflow.ellipsis,
                              style:
                                  (compactCatalogDetail
                                          ? theme.textTheme.titleMedium
                                          : theme.textTheme.titleLarge)
                                      ?.copyWith(
                                        color: compactCatalogDetail
                                            ? theme.colorScheme.onSurface
                                            : expressive
                                            ? destinationTokens?.onSurfaceAccent
                                            : null,
                                        fontWeight: expressive
                                            ? FontWeight.w700
                                            : null,
                                      ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)
                                  .anatomyLinkedExerciseCount(
                                    data.definitions.length,
                                  ),
                              style: compactCatalogDetail
                                  ? theme.textTheme.bodySmall?.copyWith(
                                      color: destinationTokens
                                          ?.supportingForeground,
                                    )
                                  : expressive
                                  ? theme.textTheme.bodyMedium?.copyWith(
                                      color: destinationTokens?.onSurfaceAccent,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (sourceBodyPart != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context).anatomyOpenedFrom(
                        localizedBodyPartName(context, sourceBodyPart!.name),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: compactCatalogDetail
                            ? destinationTokens?.supportingForeground
                            : expressive
                            ? destinationTokens?.onSurfaceAccent
                            : null,
                      ),
                    ),
                  ],
                  SizedBox(height: compactCatalogDetail ? 12 : 16),
                  if (expressive)
                    _MuscleExpressiveMetricBays(
                      recentLabel: compactCatalogDetail
                          ? AppLocalizations.of(context)
                                .anatomyDoneSevenDaysCompact
                          : AppLocalizations.of(context)
                                .anatomySetsLastSevenDays,
                      compact: compactCatalogDetail,
                      recentValue: AppLocalizations.of(context).anatomySetUnits(
                        LocalizedFormatters.number(
                          data.recentSetUnits,
                          Localizations.localeOf(context),
                          minimumFractionDigits: 1,
                          maximumFractionDigits: 1,
                        ),
                      ),
                      recommendedLabel: compactCatalogDetail
                          ? AppLocalizations.of(context)
                                .anatomyRecommendedWeeklyCompact
                          : AppLocalizations.of(context).anatomyRecommended,
                      recommendedValue: _rangeLabel(
                        AppLocalizations.of(context),
                        data.volumeBounds,
                        Localizations.localeOf(context),
                      ),
                      onEdit: onEditRecommended,
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SetStatChip(
                          label: AppLocalizations.of(context)
                              .anatomySetsLastSevenDays,
                          value: AppLocalizations.of(context).anatomySetUnits(
                            LocalizedFormatters.number(
                              data.recentSetUnits,
                              Localizations.localeOf(context),
                              minimumFractionDigits: 1,
                              maximumFractionDigits: 1,
                            ),
                          ),
                        ),
                        SetStatChip(
                          label: AppLocalizations.of(context)
                              .anatomyRecommended,
                          value: _rangeLabel(
                            AppLocalizations.of(context),
                            data.volumeBounds,
                            Localizations.localeOf(context),
                          ),
                          onEdit: onEditRecommended,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: compactCatalogDetail ? 12 : 16),
          if (!compactCatalogDetail || data.bodyParts.isNotEmpty)
            Text(
              AppLocalizations.of(context).anatomyRelatedBodyParts,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: expressive ? FontWeight.w700 : null,
                color: expressive
                    ? destinationTokens?.actionPrimary ??
                          theme.colorScheme.primary
                    : null,
              ),
            ),
          if (!compactCatalogDetail || data.bodyParts.isNotEmpty)
            SizedBox(height: compactCatalogDetail ? 4 : 8),
          if (data.bodyParts.isEmpty && !compactCatalogDetail)
            Text(
              AppLocalizations.of(context).anatomyNoBodyPartLinks,
              style: compactCatalogDetail
                  ? theme.textTheme.bodySmall?.copyWith(
                      color: destinationTokens?.supportingForeground,
                    )
                  : theme.textTheme.bodyMedium,
            )
          else if (data.bodyParts.isNotEmpty)
            Wrap(
              spacing: compactCatalogDetail ? 6 : 8,
              runSpacing: compactCatalogDetail ? 4 : 8,
              children: data.bodyParts
                  .map(
                    (bodyPart) => ActionChip(
                      backgroundColor: compactCatalogDetail
                          ? quietSurface
                          : null,
                      labelPadding: compactCatalogDetail
                          ? const EdgeInsets.symmetric(horizontal: 8)
                          : null,
                      padding: compactCatalogDetail ? EdgeInsets.zero : null,
                      shape: compactCatalogDetail
                          ? RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )
                          : null,
                      materialTapTargetSize: compactCatalogDetail
                          ? MaterialTapTargetSize.padded
                          : null,
                      side: compactCatalogDetail
                          ? BorderSide(
                              color: destinationTokens!.outlineAccent
                                  .withValues(alpha: 0.18),
                            )
                          : null,
                      label: Text(
                        localizedBodyPartName(context, bodyPart.name),
                        maxLines: expressive ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: compactCatalogDetail
                            ? theme.textTheme.labelMedium?.copyWith(
                                color: destinationTokens?.supportingForeground,
                              )
                            : null,
                      ),
                      avatar: Icon(
                        Icons.accessibility_new,
                        size: compactCatalogDetail ? 16 : 18,
                        color: compactCatalogDetail
                            ? destinationTokens?.supportingForeground
                            : null,
                      ),
                      onPressed: () => onBodyPartTap(bodyPart),
                    ),
                  )
                  .toList(),
            ),
          Divider(
            height: compactCatalogDetail ? 20 : 32,
            color: compactCatalogDetail
                ? theme.colorScheme.outlineVariant
                : null,
          ),
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
          if (data.definitions.isEmpty) ...[
            const SizedBox(height: 12),
            LocalizedCatalogEntityNamesBuilder(
              entities: [
                CatalogEntityDisplayName(
                  catalogId: muscle.catalogId,
                  canonicalName: muscle.name,
                ),
              ],
              builder: (context, names) => Text(
                AppLocalizations.of(context)
                    .anatomyNoExercisesFor(names.single),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _initialFor(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
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

class _MuscleExpressiveMetricBays extends StatelessWidget {
  const _MuscleExpressiveMetricBays({
    required this.recentLabel,
    required this.recentValue,
    required this.recommendedLabel,
    required this.recommendedValue,
    required this.compact,
    required this.onEdit,
  });

  final String recentLabel;
  final String recentValue;
  final String recommendedLabel;
  final String recommendedValue;
  final bool compact;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final first = _MuscleExpressiveMetricBay(
      label: recentLabel,
      value: recentValue,
      compact: compact,
    );
    final second = _MuscleExpressiveMetricBay(
      label: recommendedLabel,
      value: recommendedValue,
      compact: compact,
      onEdit: onEdit,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!compact) {
          final tokens = Theme.of(context)
              .extension<AppExpressiveDestinationTokens>()!;
          final stacked =
              constraints.maxWidth < 330 ||
              MediaQuery.textScalerOf(context).scale(16) > 19;
          return Container(
            decoration: BoxDecoration(
              color: tokens.surfaceSelected,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(8),
                bottomLeft: Radius.circular(18),
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
        }
        final stacked =
            constraints.maxWidth < 290 ||
            MediaQuery.textScalerOf(context).scale(16) > 22;
        return stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [first, const SizedBox(height: 8), second],
              )
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: first),
                    const SizedBox(width: 8),
                    Expanded(child: second),
                  ],
                ),
              );
      },
    );
  }
}

class _MuscleExpressiveMetricBay extends StatelessWidget {
  const _MuscleExpressiveMetricBay({
    required this.label,
    required this.value,
    required this.compact,
    this.onEdit,
  });

  final String label;
  final String value;
  final bool compact;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppExpressiveDestinationTokens>()!;
    if (!compact) {
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
                if (onEdit != null) ...[
                  const SizedBox(width: 4),
                  IconTheme.merge(
                    data: IconThemeData(color: tokens.onSurfaceSelected),
                    child: RecommendedSetsEditButton(onPressed: onEdit!),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }
    final dark = theme.brightness == Brightness.dark;
    final heroSurface = dark
        ? const Color(0xFF30243E)
        : const Color(0xFFE9DDF1);
    final radius = BorderRadius.circular(14);
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: tokens.supportingForeground,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.edit_outlined,
                  color: tokens.actionPrimary,
                  size: 16,
                ),
              ],
            ],
          ),
        ],
      ),
    );
    return Material(
      color: Color.alphaBlend(
        tokens.surfaceSelected.withValues(alpha: dark ? 0.22 : 0.30),
        heroSurface,
      ),
      borderRadius: radius,
      child: onEdit == null
          ? content
          : Tooltip(
              message: AppLocalizations.of(context).recommendedSetsEdit,
              child: InkWell(
                onTap: onEdit,
                borderRadius: radius,
                child: Semantics(
                  button: true,
                  label: AppLocalizations.of(context).recommendedSetsEdit,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: content,
                  ),
                ),
              ),
            ),
    );
  }
}

class _ExerciseDefinitionTile extends StatelessWidget {
  final ExerciseDefinition definition;
  final int muscleId;
  final bool expressive;
  final AppExpressiveDestinationFamily? expressiveFamily;
  final bool compactCatalogDetail;

  const _ExerciseDefinitionTile({
    required this.definition,
    required this.muscleId,
    required this.expressive,
    required this.expressiveFamily,
    required this.compactCatalogDetail,
  });

  @override
  Widget build(BuildContext context) {
    final rank = _rankForMuscle(definition);
    return ExerciseDefinitionInfoTile(
      definition: definition,
      subtitle: _ExerciseMetadata(
        definition: definition,
        muscleRank: rank,
        expressive: expressive,
        compactCatalogDetail: compactCatalogDetail,
      ),
      expressiveDestinationFamily: expressive ? expressiveFamily : null,
      compactExpressivePresentation: compactCatalogDetail,
    );
  }

  int _rankForMuscle(ExerciseDefinition definition) {
    for (final ranked in definition.muscles) {
      if (ranked.muscle.id == muscleId) return ranked.rank;
    }
    return 999;
  }
}

class _ExerciseMetadata extends StatelessWidget {
  final ExerciseDefinition definition;
  final int muscleRank;
  final bool expressive;
  final bool compactCatalogDetail;

  const _ExerciseMetadata({
    required this.definition,
    required this.muscleRank,
    required this.expressive,
    required this.compactCatalogDetail,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final destinationTokens = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    final equipmentEntities = definition.equipmentList
        .where((item) => item.name.trim().isNotEmpty)
        .map(
          (item) => CatalogEntityDisplayName(
            catalogId: item.catalogId,
            canonicalName: item.name,
          ),
        )
        .toList(growable: false);
    Widget equipmentText(String label) {
      final text = Text(
        label,
        maxLines: compactCatalogDetail
            ? 2
            : expressive
            ? null
            : 1,
        overflow: compactCatalogDetail || !expressive
            ? TextOverflow.ellipsis
            : null,
        style: expressive
            ? Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: destinationTokens?.supportingForeground)
            : TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
      );
      return compactCatalogDetail ? Tooltip(message: label, child: text) : text;
    }

    final equipmentLabel = equipmentEntities.isEmpty
        ? equipmentText(AppLocalizations.of(context).anatomyNoEquipment)
        : LocalizedCatalogEntityNamesBuilder(
            entities: equipmentEntities,
            builder: (context, names) => equipmentText(names.join(', ')),
          );
    final bodyParts = definition.bodyParts.isEmpty
        ? AppLocalizations.of(context).anatomyNoBodyPartsListed
        : definition.bodyParts
              .map((bodyPart) => localizedBodyPartName(context, bodyPart.name))
              .join(', ');

    if (compactCatalogDetail) {
      final strings = AppLocalizations.of(context);
      final rankLabel =
          '${strings.rankingsRank} ${LocalizedFormatters.number(muscleRank, Localizations.localeOf(context), maximumFractionDigits: 0)}';
      return Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            equipmentLabel,
            const SizedBox(height: 3),
            Text(
              rankLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: destinationTokens?.actionPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Tooltip(
              message: bodyParts,
              child: Text(
                bodyParts,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: destinationTokens?.supportingForeground),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          equipmentLabel,
          const SizedBox(height: 3),
          Text(
            AppLocalizations.of(context)
                .anatomyRankForMuscle(muscleRank, bodyParts),
            maxLines: expressive ? null : 1,
            overflow: expressive ? null : TextOverflow.ellipsis,
            style: TextStyle(
              color: expressive
                  ? destinationTokens?.supportingForeground
                  : context.usesNeoPresentation
                  ? context.semanticColors.positive
                  : Colors.green.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MusclePageData {
  final List<ExerciseDefinition> definitions;
  final List<BodyPart> bodyParts;
  final double recentSetUnits;
  final VolumeBoundaries? volumeBounds;

  const _MusclePageData({
    required this.definitions,
    required this.bodyParts,
    required this.recentSetUnits,
    required this.volumeBounds,
  });
}
