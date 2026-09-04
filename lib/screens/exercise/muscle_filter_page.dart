// File: lib/screens/exercise/muscle_filter_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../services/catalog_entity_localizer.dart';
import '../../services/tutorial_state_store.dart';
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

  const MuscleFilterPage({super.key, this.initialTabIndex = 0});

  @override
  State<MuscleFilterPage> createState() => _MuscleFilterPageState();
}

class _MuscleFilterPageState extends State<MuscleFilterPage> {
  AppRepository get _repo => context.read<AppRepository>();
  final _searchTutorialKey = GlobalKey(debugLabel: 'target_anatomy_search');
  final _listTutorialKey = GlobalKey(debugLabel: 'target_anatomy_list');
  late Future<_FilterData> _dataFuture;
  Locale? _loadedLocale;
  String _query = '';
  bool _tutorialQueued = false;

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
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex <= 0 ? 0 : 1,
      child: Scaffold(
        appBar: AppBar(
          title:
              isSpanish
                  ? FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(strings.anatomyLibraryTitle),
                  )
                  : Text(strings.anatomyLibraryTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: strings.anatomyBodyParts),
              Tab(text: strings.anatomyMuscles),
            ],
          ),
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
            final bodyParts =
                data.bodyParts
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
            final muscles =
                data.muscles
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: KeyedSubtree(
                    key: _searchTutorialKey,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText:
                            isSpanish ? null : strings.anatomySearchLabel,
                        label:
                            isSpanish
                                ? FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(strings.anatomySearchLabel),
                                )
                                : null,
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                ),
                Expanded(
                  child: KeyedSubtree(
                    key: _listTutorialKey,
                    child: TabBarView(
                      children: [
                        _FocusList<BodyPart>(
                          emptyText: strings.anatomyNoBodyParts,
                          items: bodyParts,
                          titleFor:
                              (part) =>
                                  localizedBodyPartName(context, part.name),
                          subtitleFor: (part) {
                            final count =
                                data.bodyPartExerciseCounts[part.id] ?? 0;
                            return _exerciseCountLabel(count);
                          },
                          leadingFor:
                              (part) => SharedEntityMediaThumbnail(
                                entityType: SharedMediaEntityType.bodypart,
                                entityId: part.id,
                                size: 54,
                                padding: EdgeInsets.zero,
                                fallbackBuilder:
                                    (context, contentSize) =>
                                        SingleBodyPartHeatmap(
                                          bodyPartName: part.name,
                                          size: contentSize,
                                          padding: 3,
                                          backgroundColor: Colors.transparent,
                                          borderRadius: BorderRadius.zero,
                                        ),
                              ),
                          onTap: (part) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => DefinitionsByBodyPartPage(
                                      bodyPart: part,
                                    ),
                              ),
                            );
                          },
                        ),
                        _FocusList<Muscle>(
                          emptyText: strings.anatomyNoMuscles,
                          items: muscles,
                          titleFor: (muscle) => muscle.name,
                          titleWidgetFor:
                              (context, muscle) => LocalizedCatalogEntityName(
                                entity: CatalogEntityDisplayName(
                                  catalogId: muscle.catalogId,
                                  canonicalName: muscle.name,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          subtitleFor: (muscle) {
                            final count =
                                data.muscleExerciseCounts[muscle.id] ?? 0;
                            return _exerciseCountLabel(count);
                          },
                          leadingFor:
                              (muscle) => SharedEntityMediaThumbnail(
                                entityType: SharedMediaEntityType.muscle,
                                entityId: muscle.id,
                                size: 44,
                                borderRadius: BorderRadius.circular(22),
                                fallbackBuilder:
                                    (context, contentSize) => Icon(
                                      Icons.fitness_center,
                                      size: contentSize * 0.48,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                    ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                          onTap: (muscle) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        DefinitionsByMusclePage(muscle: muscle),
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
      ),
    );
  }

  String _exerciseCountLabel(int count) {
    return AppLocalizations.of(context).anatomyExerciseCount(count);
  }
}

class _FocusList<T> extends StatelessWidget {
  final List<T> items;
  final String emptyText;
  final String Function(T item) titleFor;
  final Widget Function(BuildContext context, T item)? titleWidgetFor;
  final String Function(T item) subtitleFor;
  final IconData? icon;
  final Widget Function(T item)? leadingFor;
  final ValueChanged<T> onTap;

  const _FocusList({
    required this.items,
    required this.emptyText,
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

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading:
              leadingFor?.call(item) ??
              CircleAvatar(child: Icon(icon ?? Icons.chevron_right, size: 20)),
          title:
              titleWidgetFor?.call(context, item) ??
              Text(
                titleFor(item),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          subtitle: Text(
            subtitleFor(item),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onTap(item),
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
