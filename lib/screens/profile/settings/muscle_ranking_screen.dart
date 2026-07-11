// File: lib/screens/profile/settings/muscle_ranking_screen.dart

import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../repositories/app_repository.dart';
import '../../../widgets/settings_tiles.dart';

class MuscleRankingScreen extends StatefulWidget {
  const MuscleRankingScreen({super.key});

  @override
  State<MuscleRankingScreen> createState() => _MuscleRankingScreenState();
}

class _MuscleRankingScreenState extends State<MuscleRankingScreen> {
  final _repo = AppRepository();
  List<Muscle> _muscles = [];
  Map<int, int> _ranks = {};
  bool _isLoading = true;
  bool _isSaving = false;
  bool _dirty = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final muscles = await _repo.fetchAllMusclesFull();
      final rows = await _repo.getAllMuscleRanks();
      if (!mounted) return;
      setState(() {
        _muscles = muscles;
        _ranks = {for (var r in rows) r.muscleId: r.rank};
        _sortByRank();
        _isLoading = false;
        _dirty = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _sortByRank() {
    _muscles.sort((a, b) => (_ranks[a.id] ?? 0).compareTo(_ranks[b.id] ?? 0));
  }

  void _applyRankOrder() {
    for (var i = 0; i < _muscles.length; i++) {
      _ranks[_muscles[i].id] = i + 1;
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final muscle = _muscles.removeAt(oldIndex);
      _muscles.insert(newIndex, muscle);
      _applyRankOrder();
      _dirty = true;
    });
  }

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);
    try {
      for (var entry in _ranks.entries) {
        await _repo.setMuscleRank(entry.key, entry.value);
      }
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _dirty = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Muscle rankings saved')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Muscle Rankings'),
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBar:
          _dirty
              ? SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveAll,
                  icon:
                      _isSaving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Rankings'),
                ),
              )
              : null,
      body: SafeArea(child: _buildBody(scheme)),
    );
  }

  Widget _buildBody(ColorScheme scheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error loading muscles: $_error'));
    }
    if (_muscles.isEmpty) {
      return const Center(child: Text('No muscles defined'));
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: SettingsHeroCard(
            title: 'Muscle Rankings',
            subtitle:
                'Drag muscles into the order you want generated training to prefer.',
            icon: Icons.fitness_center,
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: _muscles.length,
            onReorder: _onReorder,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemBuilder: (context, index) {
              final muscle = _muscles[index];
              final rank = _ranks[muscle.id] ?? index + 1;
              return _MuscleRankingTile(
                key: ValueKey(muscle.id),
                index: index,
                name: muscle.name,
                rank: rank,
                onRankSubmitted: (value) {
                  setState(() {
                    _ranks[muscle.id] = int.tryParse(value) ?? rank;
                    _sortByRank();
                    _dirty = true;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MuscleRankingTile extends StatelessWidget {
  final int index;
  final String name;
  final int rank;
  final ValueChanged<String> onRankSubmitted;

  const _MuscleRankingTile({
    super.key,
    required this.index,
    required this.name,
    required this.rank,
    required this.onRankSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_handle, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primary.withValues(alpha: 0.16),
            child: Icon(Icons.fitness_center, color: scheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 58,
            child: TextFormField(
              key: ValueKey('rank-$rank'),
              initialValue: rank.toString(),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Rank',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onFieldSubmitted: onRankSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
