// File: lib/screens/profile/settings/bodypart_ranking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/safe_failure_localizations.dart';
import '../../../models/models.dart';
import '../../../repositories/app_repository.dart';
import '../../../services/safe_failure.dart';
import '../../../widgets/settings_tiles.dart';
import '../../../widgets/safe_error_view.dart';

class BodyPartRankingScreen extends StatefulWidget {
  const BodyPartRankingScreen({super.key});

  @override
  State<BodyPartRankingScreen> createState() => _BodyPartRankingScreenState();
}

class _BodyPartRankingScreenState extends State<BodyPartRankingScreen> {
  AppRepository get _repo => context.read<AppRepository>();
  List<BodyPart> _parts = [];
  Map<int, int> _ranks = {};
  bool _isLoading = true;
  bool _isSaving = false;
  bool _dirty = false;
  SafeFailure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _failure = null;
      });
    }
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
        _failure = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _failure = SafeFailure.classify(e);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).rankingsSaved(AppLocalizations.of(context).anatomyBodyParts),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).rankingsSaveError(
              safeFailureMessage(AppLocalizations.of(context), e),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.rankingsTitle(strings.anatomyBodyParts)),
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBar:
          _dirty
              ? SettingsSaveBar(
                label:
                    _isSaving ? strings.nutritionSaving : strings.rankingsSave,
                onPressed: _isSaving ? null : _saveAll,
                saveIcon:
                    _isSaving
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.save),
                decorated: false,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              )
              : null,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final strings = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failure != null) {
      return SafeErrorView(
        title: strings.safeFailureLoadTitle,
        failure: _failure!,
        onRetry: _load,
      );
    }
    if (_parts.isEmpty) {
      return Center(child: Text(strings.rankingsNoBodyParts));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: SettingsHeroCard(
            title: strings.rankingsTitle(strings.anatomyBodyParts),
            subtitle: strings.rankingsHero(
              strings.anatomyBodyParts.toLowerCase(),
            ),
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
              return SettingsRankingTile(
                key: ValueKey(part.id),
                index: index,
                name: Text(
                  part.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: settingsRankingNameTextStyle(context),
                ),
                rank: rank,
                icon: Icons.accessibility_new,
                rankLabel: strings.rankingsRank,
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
