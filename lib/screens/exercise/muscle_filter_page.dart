// File: lib/screens/exercise/muscle_filter_page.dart

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
import '../../theme/widgets/tonos_expressive_motion.dart';
import '../../utils/localized_body_part_name.dart';
import '../../utils/tutorial_launcher.dart';
import '../../widgets/body_heatmap.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/localized_catalog_entity_name.dart';
import '../../widgets/shared_entity_media_thumbnail.dart';
import 'definitions_by_bodypart_page.dart';
import 'definitions_by_muscle_page.dart';

/// Browse the exercise library by bodypart or individual muscle.
class MuscleFilterPage extends StatefulWidget {
  final int initialTabIndex;
  final bool expressiveCatalogPresentation;

  const MuscleFilterPage({
    super.key,
    this.initialTabIndex = 0,
    this.expressiveCatalogPresentation = false,
  });

  @override
  State<MuscleFilterPage> createState() => _MuscleFilterPageState();
}

class _MuscleFilterPageState extends State<MuscleFilterPage>
    with SingleTickerProviderStateMixin {
  AppRepository get _repo => context.read<AppRepository>();
  final _searchTutorialKey = GlobalKey(debugLabel: 'target_anatomy_search');
  final _listTutorialKey = GlobalKey(debugLabel: 'target_anatomy_list');
  final _searchController = TextEditingController();
  late final TabController _tabController;
  late int _activeTabIndex;
  late Future<_FilterData> _dataFuture;
  Locale? _loadedLocale;
  String _query = '';
  bool _tutorialQueued = false;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex <= 0 ? 0 : 1;
    _tabController = TabController(
      length: 2,
      initialIndex: _activeTabIndex,
      vsync: this,
    )..addListener(_handleTabChanged);
  }

  void _handleTabChanged() {
    if (_activeTabIndex == _tabController.index) return;
    final clearQuery =
        widget.expressiveCatalogPresentation &&
        context.usesExpressivePresentation;
    if (clearQuery) _searchController.clear();
    setState(() {
      _activeTabIndex = _tabController.index;
      if (clearQuery) _query = '';
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_loadedLocale == locale) return;
    _loadedLocale = locale;
    _dataFuture = _loadData(locale);
  }

  Future<_FilterData> _loadData(Locale locale) async {
    final bodyPartsFuture = _repo.fetchAllBodyParts();
    final musclesFuture = _repo.fetchAllMuscles();
    final definitionsFuture = _repo.lookupDefsDetailed();

    final bodyParts = await bodyPartsFuture;
    final muscles = await musclesFuture;
    final definitions = await definitionsFuture;
    final muscleNames = await _localizedMuscleNames(muscles, locale);

    final bodyPartCounts = <int, int>{};
    final muscleCounts = <int, int>{};

    for (final def in definitions) {
      for (final bodyPart in def.bodyParts) {
        bodyPartCounts.update(
          bodyPart.id,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
      for (final ranked in def.muscles) {
        muscleCounts.update(
          ranked.muscle.id,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    return _FilterData(
      bodyParts: bodyParts,
      muscles: muscles,
      muscleDisplayNames: muscleNames,
      bodyPartExerciseCounts: bodyPartCounts,
      muscleExerciseCounts: muscleCounts,
    );
  }

  Future<Map<int, String>> _localizedMuscleNames(
    List<Muscle> muscles,
    Locale locale,
  ) async {
    try {
      final names = await CatalogEntityLocalizer.instance.resolveNames(
        muscles.map(
          (muscle) => CatalogEntityDisplayName(
            catalogId: muscle.catalogId,
            canonicalName: muscle.name,
          ),
        ),
        locale,
      );
      return {
        for (var index = 0; index < muscles.length; index++)
          muscles[index].id: names[index],
      };
    } catch (_) {
      return {for (final muscle in muscles) muscle.id: muscle.name};
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
        tutorialId: TutorialIds.targetAnatomy,
        steps: [
          GuidedTutorialStep(
            targetKey: _searchTutorialKey,
            icon: Icons.search,
            title: strings.anatomyTutorialSearchTitle,
            body: strings.anatomyTutorialSearchBody,
          ),
          GuidedTutorialStep(
            targetKey: _listTutorialKey,
            icon: Icons.accessibility_new,
            title: strings.anatomyTutorialListsTitle,
            body: strings.anatomyTutorialListsBody,
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
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final expressive =
        widget.expressiveCatalogPresentation &&
        context.usesExpressivePresentation;
    final destinationTokens = expressive
        ? AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.catalog,
            Theme.of(context).brightness,
          )
        : null;
    final scheme = Theme.of(context).colorScheme;
    final toolbarSurface = expressive
        ? Color.lerp(destinationTokens!.surfaceAccent, scheme.surface, 0.7)!
        : null;
    final searchSurface = expressive
        ? Color.lerp(destinationTokens!.surfaceAccent, scheme.surface, 0.86)!
        : null;
    final tabLabelStyle = Theme.of(context).textTheme.labelLarge
        ?.copyWith(fontWeight: FontWeight.w700);
    var tabHeight = 48.0;
    if (expressive) {
      final labelWidth = ((MediaQuery.sizeOf(context).width - 40) / 2 - 24)
          .clamp(1.0, double.infinity)
          .toDouble();
      for (final label in [strings.anatomyBodyParts, strings.anatomyMuscles]) {
        final painter = TextPainter(
          text: TextSpan(text: label, style: tabLabelStyle),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: labelWidth);
        tabHeight = (painter.height + 16)
            .clamp(tabHeight, double.infinity)
            .toDouble();
        painter.dispose();
      }
    }
    final focusTabs = TabBar(
      controller: _tabController,
      dividerColor: expressive ? Colors.transparent : null,
      labelPadding: expressive
          ? const EdgeInsets.symmetric(horizontal: 8)
          : null,
      indicatorSize: expressive ? TabBarIndicatorSize.tab : null,
      indicator: expressive
          ? BoxDecoration(
              color: destinationTokens?.actionPrimary,
              borderRadius: BorderRadius.circular(16),
            )
          : null,
      labelColor: expressive ? destinationTokens?.onActionPrimary : null,
      unselectedLabelColor: expressive
          ? destinationTokens?.onSurfaceAccent
          : null,
      labelStyle: expressive ? tabLabelStyle : null,
      unselectedLabelStyle: expressive
          ? Theme.of(context).textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w600)
          : null,
      tabs: expressive
          ? [
              Tab(
                height: tabHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Text(
                    strings.anatomyBodyParts,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Tab(
                height: tabHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Text(
                    strings.anatomyMuscles,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]
          : [
              Tab(text: strings.anatomyBodyParts),
              Tab(text: strings.anatomyMuscles),
            ],
    );
    final searchField = KeyedSubtree(
      key: _searchTutorialKey,
      child: TextField(
        controller: _searchController,
        style: expressive
            ? Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: scheme.onSurface)
            : null,
        decoration: InputDecoration(
          labelText: expressive || isSpanish
              ? null
              : strings.anatomySearchLabel,
          label: !expressive && isSpanish
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(strings.anatomySearchLabel),
                )
              : null,
          hintText: expressive
              ? _activeTabIndex == 0
                    ? strings.anatomySearchBodyParts
                    : strings.mappingSearchMuscles
              : null,
          hintStyle: expressive
              ? TextStyle(color: scheme.onSurfaceVariant)
              : null,
          prefixIcon: const Icon(Icons.search),
          prefixIconColor: expressive ? scheme.onSurfaceVariant : null,
          suffixIcon: expressive && _query.isNotEmpty
              ? IconButton(
                  tooltip: strings.catalogClearSearch,
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded),
                  color: scheme.onSurfaceVariant,
                )
              : null,
          filled: expressive,
          fillColor: searchSurface,
          contentPadding: expressive
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(expressive ? 16 : 4),
          ),
          enabledBorder: expressive
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                )
              : null,
          focusedBorder: expressive
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: destinationTokens!.outlineAccent.withValues(
                      alpha: 0.75,
                    ),
                    width: 1.5,
                  ),
                )
              : null,
        ),
        onChanged: (value) => setState(() => _query = value),
      ),
    );
    final route = Scaffold(
      backgroundColor: expressive ? destinationTokens?.pageCanvas : null,
      appBar: AppBar(
        centerTitle: expressive ? false : null,
        elevation: expressive ? 0 : null,
        scrolledUnderElevation: expressive ? 0 : null,
        backgroundColor: expressive ? destinationTokens?.pageCanvas : null,
        foregroundColor: expressive ? scheme.onSurface : null,
        title: expressive
            ? Text(strings.catalogTargetAnatomyTitle)
            : isSpanish
            ? FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(strings.anatomyLibraryTitle),
              )
            : Text(strings.anatomyLibraryTitle),
        bottom: expressive ? null : focusTabs,
      ),
      body: FutureBuilder<_FilterData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(strings.anatomyLoadFailed));
          }

          final data = snapshot.data!;
          final query = _query.trim().toLowerCase();
          final bodyParts = data.bodyParts
              .where(
                (part) =>
                    query.isEmpty ||
                    part.name.toLowerCase().contains(query) ||
                    localizedBodyPartName(
                      context,
                      part.name,
                    ).toLowerCase().contains(query),
              )
              .toList();
          final muscles = data.muscles
              .where(
                (muscle) =>
                    query.isEmpty ||
                    muscle.name.toLowerCase().contains(query) ||
                    (data.muscleDisplayNames[muscle.id] ?? '')
                        .toLowerCase()
                        .contains(query),
              )
              .toList();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _queueTutorial();
          });

          return Column(
            children: [
              if (expressive)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: toolbarSurface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: focusTabs,
                        ),
                      ),
                      const SizedBox(height: 8),
                      searchField,
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: searchField,
                ),
              Expanded(
                child: KeyedSubtree(
                  key: _listTutorialKey,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      if (expressive && bodyParts.isEmpty)
                        _buildSearchEmptyState(strings.anatomyNoBodyParts)
                      else
                        _FocusList<BodyPart>(
                          emptyText: strings.anatomyNoBodyParts,
                          expressive: expressive,
                          items: bodyParts,
                          titleFor: (part) =>
                              localizedBodyPartName(context, part.name),
                          subtitleFor: (part) {
                            final count =
                                data.bodyPartExerciseCounts[part.id] ?? 0;
                            return _exerciseCountLabel(count);
                          },
                          leadingFor: (part) => SharedEntityMediaThumbnail(
                            entityType: SharedMediaEntityType.bodypart,
                            entityId: part.id,
                            size: 54,
                            borderRadius: expressive
                                ? BorderRadius.circular(16)
                                : const BorderRadius.all(Radius.circular(14)),
                            padding: expressive
                                ? const EdgeInsets.all(2)
                                : EdgeInsets.zero,
                            backgroundColor: expressive
                                ? Color.lerp(
                                    destinationTokens!.surfaceAccent,
                                    scheme.surface,
                                    0.78,
                                  )
                                : null,
                            borderColor: expressive
                                ? destinationTokens!.outlineAccent.withValues(
                                    alpha: 0.30,
                                  )
                                : null,
                            fallbackBuilder: (context, contentSize) =>
                                SingleBodyPartHeatmap(
                                  bodyPartName: part.name,
                                  size: contentSize,
                                  padding: expressive ? 2 : 3,
                                  backgroundColor: Colors.transparent,
                                  borderRadius: expressive
                                      ? BorderRadius.circular(14)
                                      : BorderRadius.zero,
                                ),
                          ),
                          onTap: (part) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AppExpressiveDestinationTheme(
                                  family:
                                      AppExpressiveDestinationFamily.catalog,
                                  child: DefinitionsByBodyPartPage(
                                    bodyPart: part,
                                    expressiveCatalogPresentation: expressive,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      if (expressive && muscles.isEmpty)
                        _buildSearchEmptyState(strings.anatomyNoMuscles)
                      else
                        _FocusList<Muscle>(
                          emptyText: strings.anatomyNoMuscles,
                          expressive: expressive,
                          items: muscles,
                          titleFor: (muscle) => muscle.name,
                          titleWidgetFor: (context, muscle) =>
                              LocalizedCatalogEntityName(
                                entity: CatalogEntityDisplayName(
                                  catalogId: muscle.catalogId,
                                  canonicalName: muscle.name,
                                ),
                                maxLines: expressive ? null : 2,
                                overflow: expressive
                                    ? null
                                    : TextOverflow.ellipsis,
                              ),
                          subtitleFor: (muscle) {
                            final count =
                                data.muscleExerciseCounts[muscle.id] ?? 0;
                            return _exerciseCountLabel(count);
                          },
                          leadingFor: (muscle) => SharedEntityMediaThumbnail(
                            entityType: SharedMediaEntityType.muscle,
                            entityId: muscle.id,
                            size: expressive ? 54 : 44,
                            padding: expressive
                                ? const EdgeInsets.all(3)
                                : const EdgeInsets.all(3),
                            borderRadius: expressive
                                ? BorderRadius.circular(16)
                                : BorderRadius.circular(22),
                            borderColor: expressive
                                ? destinationTokens!.outlineAccent.withValues(
                                    alpha: 0.30,
                                  )
                                : null,
                            fallbackBuilder: (context, contentSize) => Icon(
                              Icons.fitness_center,
                              size: expressive
                                  ? contentSize * 0.58
                                  : contentSize * 0.48,
                              color: expressive
                                  ? scheme.onSurfaceVariant
                                  : Theme.of(context).colorScheme.onPrimary,
                            ),
                            backgroundColor: expressive
                                ? Color.lerp(
                                    destinationTokens!.surfaceAccent,
                                    scheme.surface,
                                    0.78,
                                  )
                                : Theme.of(context).colorScheme.primary,
                          ),
                          onTap: (muscle) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AppExpressiveDestinationTheme(
                                  family:
                                      AppExpressiveDestinationFamily.catalog,
                                  child: DefinitionsByMusclePage(
                                    muscle: muscle,
                                    expressiveCatalogPresentation: expressive,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    return expressive
        ? AppExpressiveDestinationTheme(
            family: AppExpressiveDestinationFamily.catalog,
            child: route,
          )
        : route;
  }

  String _exerciseCountLabel(int count) {
    return AppLocalizations.of(context).anatomyExerciseCount(count);
  }

  Widget _buildSearchEmptyState(String message) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - 48)
                .clamp(0.0, double.infinity)
                .toDouble(),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 32,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (_query.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close_rounded),
                    label: Text(
                      AppLocalizations.of(context).catalogClearSearch,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusList<T> extends StatelessWidget {
  final List<T> items;
  final String emptyText;
  final bool expressive;
  final String Function(T item) titleFor;
  final Widget Function(BuildContext context, T item)? titleWidgetFor;
  final String Function(T item) subtitleFor;
  final IconData? icon;
  final Widget Function(T item)? leadingFor;
  final ValueChanged<T> onTap;

  const _FocusList({
    required this.items,
    required this.emptyText,
    required this.expressive,
    required this.titleFor,
    this.titleWidgetFor,
    required this.subtitleFor,
    required this.onTap,
    this.icon,
    this.leadingFor,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(emptyText));
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final destination =
        theme.extension<AppExpressiveDestinationTokens>() ??
        AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.catalog,
          theme.brightness,
        );
    final dark = theme.brightness == Brightness.dark;
    final rowSurface = Color.lerp(
      dark ? destination.surfaceAccent : destination.surfaceTertiary,
      scheme.surface,
      dark ? 0.45 : 0.60,
    )!;
    final rowForeground = dark
        ? destination.onSurfaceAccent
        : destination.onSurfaceTertiary;

    return ListView.separated(
      padding: expressive
          ? const EdgeInsets.fromLTRB(12, 4, 12, 16)
          : const EdgeInsets.only(bottom: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          expressive ? const SizedBox(height: 6) : const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        final tile = ListTile(
          tileColor: expressive ? rowSurface : null,
          shape: expressive
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: expressive ? 12 : 16,
          ),
          minTileHeight: expressive ? 68 : null,
          minVerticalPadding: expressive ? 6 : null,
          horizontalTitleGap: expressive ? 12 : null,
          leading:
              leadingFor?.call(item) ??
              CircleAvatar(child: Icon(icon ?? Icons.chevron_right, size: 20)),
          title: DefaultTextStyle.merge(
            style: expressive
                ? theme.textTheme.titleMedium?.copyWith(
                    color: rowForeground,
                    fontWeight: FontWeight.w700,
                  )
                : null,
            child:
                titleWidgetFor?.call(context, item) ??
                Text(
                  titleFor(item),
                  maxLines: expressive ? null : 2,
                  overflow: expressive ? null : TextOverflow.ellipsis,
                  style: expressive
                      ? theme.textTheme.titleMedium?.copyWith(
                          color: rowForeground,
                          fontWeight: FontWeight.w700,
                        )
                      : null,
                ),
          ),
          subtitle: Text(
            subtitleFor(item),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: expressive
                ? theme.textTheme.bodySmall?.copyWith(
                    color: rowForeground.withValues(alpha: 0.82),
                  )
                : null,
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: expressive ? rowForeground.withValues(alpha: 0.72) : null,
          ),
          onTap: () => onTap(item),
        );
        if (!expressive) return tile;
        return TonosExpressivePressResponse(
          enabled: true,
          pressedScale: TonosExpressiveMotionTiers.supportingScale,
          pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
          child: tile,
        );
      },
    );
  }
}

class _FilterData {
  final List<BodyPart> bodyParts;
  final List<Muscle> muscles;
  final Map<int, String> muscleDisplayNames;
  final Map<int, int> bodyPartExerciseCounts;
  final Map<int, int> muscleExerciseCounts;

  const _FilterData({
    required this.bodyParts,
    required this.muscles,
    required this.muscleDisplayNames,
    required this.bodyPartExerciseCounts,
    required this.muscleExerciseCounts,
  });
}
