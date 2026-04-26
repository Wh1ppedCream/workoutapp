// file: lib/widgets/presets_loaded.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/selected_profile.dart';
import '../repositories/app_repository.dart';
import 'preset_bar.dart';

/// Fetches & displays presets for the current profile.
/// Handles loading, empty, and error states, then renders a scrollable list of [PresetBar]s.
class PresetsLoaded extends StatefulWidget {
  /// Uniform scale factor for paddings and font sizes.
  final double scale;

  /// Called after a rename/delete to reload the list.
  final VoidCallback onRefresh;
  final int refreshToken;

  const PresetsLoaded({
    super.key,
    this.scale = 1.0,
    this.refreshToken = 0,
    required this.onRefresh,
  });

  @override
  State<PresetsLoaded> createState() => _PresetsLoadedState();
}

class _PresetListItem {
  final int presetId;
  final String name;
  final bool isAutomatic;

  const _PresetListItem({
    required this.presetId,
    required this.name,
    required this.isAutomatic,
  });
}

class _PresetsLoadedState extends State<PresetsLoaded>
    with AutomaticKeepAliveClientMixin<PresetsLoaded> {
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
    final rows = await _repo.fetchAllPresetsRaw(profileId: profileId);
    return Future.wait(
      rows.map((row) async {
        final presetId = row['id'] as int;
        final autoSettings = await _repo.fetchPresetAutoSettings(presetId);
        final isAutomatic =
            (autoSettings?['is_automatic'] as int? ?? 0) == 1;
        return _PresetListItem(
          presetId: presetId,
          name: row['name'] as String,
          isAutomatic: isAutomatic,
        );
      }),
    );
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
            child: const Text('Error loading presets'),
          );
        }

        final rows = snap.data ?? const <_PresetListItem>[];
        if (snap.connectionState == ConnectionState.done && snap.hasData) {
          _lastRows = rows;
        }
        if (rows.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(16 * widget.scale),
            child: const Text('No presets found.'),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 6 * widget.scale),
          itemCount: rows.length,
          shrinkWrap: true,
          itemBuilder: (ctx2, i) {
            final row = rows[i];
            final color = _palette[i % _palette.length];

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6 * widget.scale),
              child: PresetBar(
                presetId: row.presetId,
                label: row.name,
                color: color,
                index: i,
                isAutomatic: row.isAutomatic,
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
