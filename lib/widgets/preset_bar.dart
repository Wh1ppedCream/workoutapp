// File: lib/widgets/preset_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/app_repository.dart';
import '../providers/active_session.dart';
import '../providers/preset_session.dart';
import '../screens/exercise/preset_detail_screen.dart';
import 'body_heatmap.dart';
import 'generic_bar.dart';
import '../theme/theme_extensions.dart';

/// A colored bar that *knows* how to open, rename, & delete its own preset.
class PresetBar extends StatelessWidget {
  final int presetId;
  final String label;
  final Color color;
  final int index;
  final bool isAutomatic;
  final Map<String, double> focusFrequencyMap;
  final VoidCallback onRefresh;

  /// Uniform scale factor for padding, font sizes, badge sizes, etc.
  final double scale;

  const PresetBar({
    super.key,
    required this.presetId,
    required this.label,
    required this.color,
    required this.index,
    this.isAutomatic = false,
    this.focusFrequencyMap = const <String, double>{},
    required this.onRefresh,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final title = label.trim().isNotEmpty ? label : 'Preset ${index + 1}';
    // pull theme defaults if needed (but we'll still use the passed‐in color)
    final accent = color;

    return GenericBar(
      label: title,
      // use the same color as before, but via the themed accent slot
      color: accent,
      onTap: () => _openDetail(context),
      scale: scale, // <-- pass down scale
      leading: _PresetFocusBadge(frequencyMap: focusFrequencyMap, scale: scale),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAutomatic) _AutomaticBadge(scale: scale),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: accent,
              size: 24 * scale, // scale the icon
            ),
            onSelected: (action) => _handleMenu(context, action),
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                ],
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (ctx) => MultiProvider(
              providers: [
                ChangeNotifierProvider<ActiveSession>.value(
                  value: ctx.read<ActiveSession>(),
                ),
                ChangeNotifierProvider(create: (_) => PresetSession(presetId)),
              ],
              child: const PresetDetailScreen(),
            ),
      ),
    );
  }

  Future<void> _handleMenu(BuildContext context, String action) async {
    final repo = AppRepository();

    if (action == 'edit') {
      _openDetail(context);
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (dCtx) => AlertDialog(
              title: const Text('Delete Preset'),
              content: const Text(
                'Are you sure you want to delete this preset?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dCtx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dCtx, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
      );
      if (!context.mounted) return;
      if (confirm == true) {
        await repo.deletePreset(presetId);
        onRefresh();
      }
    } else if (action == 'rename') {
      final ctl = TextEditingController(text: label);
      final newName = await showDialog<String>(
        context: context,
        builder: (dCtx) {
          return AlertDialog(
            title: const Text('Rename Preset'),
            content: TextField(
              controller: ctl,
              decoration: const InputDecoration(labelText: 'Preset Name'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dCtx, ctl.text.trim()),
                child: const Text('Rename'),
              ),
            ],
          );
        },
      );
      ctl.dispose();
      if (!context.mounted) return;
      if (newName != null && newName.isNotEmpty && newName != label) {
        await repo.updatePresetName(presetId, newName);
        onRefresh();
      }
    }
  }
}

class _PresetFocusBadge extends StatelessWidget {
  final Map<String, double> frequencyMap;
  final double scale;

  const _PresetFocusBadge({required this.frequencyMap, required this.scale});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = 60 * scale;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(3 * scale),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: BodyHeatmap(
        frequencyMap: frequencyMap,
        lowColor: colors.historySummaryHeatmapLow!,
        highColor: colors.historySummaryHeatmapHigh!,
        width: size - 6 * scale,
        height: size - 6 * scale,
      ),
    );
  }
}

class _AutomaticBadge extends StatelessWidget {
  final double scale;
  const _AutomaticBadge({required this.scale});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.only(right: 8 * scale),
      child: CircleAvatar(
        radius: 8 * scale,
        backgroundColor: colors.presetBadgeBg!,
        child: Text(
          'A',
          style: TextStyle(
            fontSize: 12 * scale,
            color: colors.presetBadgeText!,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
