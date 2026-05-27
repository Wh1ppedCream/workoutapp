// file: lib/widgets/presets_loaded.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/selected_profile.dart';
import '../repositories/app_repository.dart';
import '../utils/async_pool.dart';
import 'body_heatmap.dart';
import 'preset_bar.dart';

/// Fetches & displays presets for the current profile.
/// Handles loading, empty, and error states, then renders a scrollable list of [PresetBar]s.
class PresetsLoaded extends StatefulWidget {
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

  const PresetsLoaded({
    super.key,
    this.scale = 1.0,
    this.refreshToken = 0,
    this.presetIds,
    this.excludedPresetIds,
    this.emptyMessage = 'No plans found.',
    this.physics,
    this.padding,
    this.shrinkWrap = true,
    required this.onRefresh,
  });

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

  final _repo = AppRepository();
  int? _loadedProfileId;
  int? _loadedRefreshToken;
  Future<List<_PresetListItem>>? _presetsFuture;
  List<_PresetListItem>? _lastRows;

  static const _palette = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
  ];

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
    final defIds =
        <int>{
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

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
      return const Center(child: Text('No profile selected.'));
    }

    return FutureBuilder<List<_PresetListItem>>(
      future: _presetsFuture,
      initialData: _lastRows,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done && !snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError && !snap.hasData) {
          return Padding(
            padding: EdgeInsets.all(16 * widget.scale),
            child: const Text('Error loading plans'),
          );
        }

        final loadedRows = snap.data ?? const <_PresetListItem>[];
        if (snap.connectionState == ConnectionState.done && snap.hasData) {
          _lastRows = loadedRows;
        }
        final rows =
            loadedRows.where((row) {
              final included =
                  widget.presetIds == null ||
                  widget.presetIds!.contains(row.presetId);
              final excluded =
                  widget.excludedPresetIds?.contains(row.presetId) ?? false;
              return included && !excluded;
            }).toList();
        if (rows.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(16 * widget.scale),
            child: Text(widget.emptyMessage),
          );
        }

        return ListView.builder(
          padding:
              widget.padding ??
              EdgeInsets.symmetric(vertical: 6 * widget.scale),
          physics: widget.physics,
          itemCount: rows.length,
          shrinkWrap: widget.shrinkWrap,
          itemBuilder: (ctx2, i) {
            final row = rows[i];
            final color = _palette[row.listIndex % _palette.length];

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
                onRefresh: _refreshPresets,
              ),
            );
          },
        );
      },
    );
  }
}
