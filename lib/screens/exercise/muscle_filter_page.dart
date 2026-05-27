// File: lib/screens/exercise/muscle_filter_page.dart

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/body_heatmap.dart';
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
  final _repo = AppRepository();
  late Future<_FilterData> _dataFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_FilterData> _loadData() async {
    final bodyPartsFuture = _repo.fetchAllBodyParts();
    final musclesFuture = _repo.fetchAllMuscles();
    final definitionsFuture = _repo.lookupDefsDetailed();

    final bodyParts = await bodyPartsFuture;
    final muscles = await musclesFuture;
    final definitions = await definitionsFuture;

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
      bodyPartExerciseCounts: bodyPartCounts,
      muscleExerciseCounts: muscleCounts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex <= 0 ? 0 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exercise Focus Library'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Bodyparts'), Tab(text: 'Muscles')],
          ),
        ),
        body: FutureBuilder<_FilterData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Unable to load filters: ${snapshot.error}'),
              );
            }

            final data = snapshot.data!;
            final query = _query.trim().toLowerCase();
            final bodyParts =
                data.bodyParts
                    .where(
                      (part) =>
                          query.isEmpty ||
                          part.name.toLowerCase().contains(query),
                    )
                    .toList();
            final muscles =
                data.muscles
                    .where(
                      (muscle) =>
                          query.isEmpty ||
                          muscle.name.toLowerCase().contains(query),
                    )
                    .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search bodyparts or muscles',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _FocusList<BodyPart>(
                        emptyText: 'No bodyparts match your search.',
                        items: bodyParts,
                        titleFor: (part) => part.name,
                        subtitleFor: (part) {
                          final count =
                              data.bodyPartExerciseCounts[part.id] ?? 0;
                          return _exerciseCountLabel(count);
                        },
                        leadingFor:
                            (part) => SingleBodyPartHeatmap(
                              bodyPartName: part.name,
                              size: 54,
                            ),
                        onTap: (part) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      DefinitionsByBodyPartPage(bodyPart: part),
                            ),
                          );
                        },
                      ),
                      _FocusList<Muscle>(
                        emptyText: 'No muscles match your search.',
                        items: muscles,
                        titleFor: (muscle) => muscle.name,
                        subtitleFor: (muscle) {
                          final count =
                              data.muscleExerciseCounts[muscle.id] ?? 0;
                          return _exerciseCountLabel(count);
                        },
                        icon: Icons.fitness_center,
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
              ],
            );
          },
        ),
      ),
    );
  }

  String _exerciseCountLabel(int count) {
    if (count == 1) return '1 exercise';
    return '$count exercises';
  }
}

class _FocusList<T> extends StatelessWidget {
  final List<T> items;
  final String emptyText;
  final String Function(T item) titleFor;
  final String Function(T item) subtitleFor;
  final IconData? icon;
  final Widget Function(T item)? leadingFor;
  final ValueChanged<T> onTap;

  const _FocusList({
    required this.items,
    required this.emptyText,
    required this.titleFor,
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
          title: Text(
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
  final Map<int, int> bodyPartExerciseCounts;
  final Map<int, int> muscleExerciseCounts;

  const _FilterData({
    required this.bodyParts,
    required this.muscles,
    required this.bodyPartExerciseCounts,
    required this.muscleExerciseCounts,
  });
}
