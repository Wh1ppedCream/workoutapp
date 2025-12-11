// file: lib/widgets/presets_loaded.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/selected_profile.dart';
import '../repositories/app_repository.dart';
import 'preset_bar.dart';

/// Fetches & displays presets for the current profile.
/// Handles loading, empty, and error states, then renders a scrollable list of [PresetBar]s.
class PresetsLoaded extends StatelessWidget {
  /// Uniform scale factor for paddings and font sizes.
  final double scale;

  /// Called after a rename/delete to reload the list.
  final VoidCallback onRefresh;

  const PresetsLoaded({
    super.key,
    this.scale = 1.0,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();
    final sel  = context.watch<SelectedProfile>();
    final profileId = sel.currentProfile?.id;

    if (profileId == null) {
      return const Center(child: Text('No profile selected.'));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: repo.fetchAllPresetsRaw(profileId: profileId),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Padding(
            padding: EdgeInsets.all(16 * scale),
            child: const Text('Error loading presets'),
          );
        }

        final rows = snap.data ?? [];
        if (rows.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(16 * scale),
            child: const Text('No presets found.'),
          );
        }

        const palette = [
          Colors.blue,
          Colors.orange,
          Colors.green,
          Colors.purple,
          Colors.teal,
        ];

                // 🔁 Use a ListView that shrink-wraps so it can live inside another scrollable
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 6 * scale),
          itemCount: rows.length,

          // 👇 These two lines fix the "Vertical viewport was given unbounded height" error
          shrinkWrap: true,

          itemBuilder: (ctx2, i) {

            final row      = rows[i];
            final presetId = row['id'] as int;
            final name     = row['name'] as String;
            final color    = palette[i % palette.length];

            return FutureBuilder<Map<String, dynamic>?>(
              future: repo.fetchPresetAutoSettings(presetId),
              builder: (ctx3, autoSnap) {
                final isAuto =
                    autoSnap.connectionState == ConnectionState.done &&
                    (autoSnap.data?['is_automatic'] as int? ?? 0) == 1;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 6 * scale),
                  child: PresetBar(
                    presetId:    presetId,
                    label:       name,
                    color:       color,
                    index:       i,
                    isAutomatic: isAuto,
                    scale:       scale,
                    onRefresh:   onRefresh,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
