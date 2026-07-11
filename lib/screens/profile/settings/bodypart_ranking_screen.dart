// File: lib/screens/profile/settings/bodypart_ranking_screen.dart

import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../repositories/app_repository.dart';
import '../../../widgets/settings_tiles.dart';

class BodyPartRankingScreen extends StatefulWidget {
  const BodyPartRankingScreen({super.key});

  @override
  State<BodyPartRankingScreen> createState() => _BodyPartRankingScreenState();
}

class _BodyPartRankingScreenState extends State<BodyPartRankingScreen> {
  final _repo = AppRepository();
  List<BodyPart> _parts = [];
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
      final parts = await _repo.fetchAllBodyPartsFull();
      final rows = await _repo.getAllBodyPartRanks();
      if (!mounted) return;
      setState(() {
        _parts = parts;
        _ranks = {for (var r in rows) r.bodyPartId: r.rank};
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
    _parts.sort((a, b) => (_ranks[a.id] ?? 0).compareTo(_ranks[b.id] ?? 0));
  }

  void _applyRankOrder() {
    for (var i = 0; i < _parts.length; i++) {
      _ranks[_parts[i].id] = i + 1;
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final part = _parts.removeAt(oldIndex);
      _parts.insert(newIndex, part);
      _applyRankOrder();
      _dirty = true;
    });
  }

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);
    try {
      for (var entry in _ranks.entries) {
        await _repo.setBodyPartRank(entry.key, entry.value);
      }
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _dirty = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Body part rankings saved')));
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
        title: const Text('Body Part Rankings'),
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
      return Center(child: Text('Error: $_error'));
    }
    if (_parts.isEmpty) {
      return const Center(child: Text('No body parts defined'));
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: SettingsHeroCard(
            title: 'Body Part Rankings',
            subtitle:
                'Drag body parts into the order you want generated training to prefer.',
            icon: Icons.accessibility_new,
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: _parts.length,
            onReorder: _onReorder,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemBuilder: (context, index) {
              final part = _parts[index];
              final rank = _ranks[part.id] ?? index + 1;
              return _RankingTile(
                key: ValueKey(part.id),
                index: index,
                name: part.name,
                rank: rank,
                icon: Icons.accessibility_new,
                onRankSubmitted: (value) {
                  setState(() {
                    _ranks[part.id] = int.tryParse(value) ?? rank;
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

class _RankingTile extends StatelessWidget {
  final int index;
  final String name;
  final int rank;
  final IconData icon;
  final ValueChanged<String> onRankSubmitted;

  const _RankingTile({
    super.key,
    required this.index,
    required this.name,
    required this.rank,
    required this.icon,
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
            child: Icon(icon, color: scheme.primary, size: 18),
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
