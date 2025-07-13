// File: lib/widgets/preset_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/app_repository.dart';
import '../providers/active_session.dart';
import '../providers/preset_session.dart';
import '../screens/exercise/preset_detail_screen.dart';
import 'generic_bar.dart';

/// A colored bar that *knows* how to open, rename, & delete its own preset.
class PresetBar extends StatelessWidget {
  final int presetId;
  final String label;
  final Color color;
  final int index;
  final bool isAutomatic;
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
    required this.onRefresh,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final title = label.trim().isNotEmpty ? label : 'Preset ${index + 1}';

    return GenericBar(
      label: title,
      color: color,
      onTap: () => _openDetail(context),
      scale: scale,  // <-- pass down scale
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAutomatic) _AutomaticBadge(scale: scale),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: color,
              size: 24 * scale,        // scale the icon
            ),
            onSelected: (action) => _handleMenu(context, action),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit',   child: Text('Edit')),
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
      MaterialPageRoute(builder: (ctx) => MultiProvider(
        providers: [
          ChangeNotifierProvider<ActiveSession>.value(
            value: ctx.read<ActiveSession>(),
          ),
          ChangeNotifierProvider(
            create: (_) => PresetSession(presetId),
          ),
        ],
        child: const PresetDetailScreen(),
      )),
    );
  }

  Future<void> _handleMenu(BuildContext context, String action) async {
    final repo = AppRepository();

    if (action == 'edit') {
      _openDetail(context);

    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dCtx) => AlertDialog(
          title: const Text('Delete Preset'),
          content: const Text('Are you sure you want to delete this preset?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(dCtx, true),  child: const Text('Delete')),
          ],
        ),
      );
      if (confirm == true) {
        await repo.deletePreset(presetId);
        onRefresh();
      }

    } else if (action == 'rename') {
      final newName = await showDialog<String>(
        context: context,
        builder: (dCtx) {
          final ctl = TextEditingController(text: label);
          return AlertDialog(
            title: const Text('Rename Preset'),
            content: TextField(
              controller: ctl,
              decoration: const InputDecoration(labelText: 'Preset Name'),
              autofocus: true,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dCtx),             child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(dCtx, ctl.text.trim()), child: const Text('Rename')),
            ],
          );
        },
      );
      if (newName != null && newName.isNotEmpty && newName != label) {
        await repo.updatePresetName(presetId, newName);
        onRefresh();
      }
    }
  }
}

class _AutomaticBadge extends StatelessWidget {
  final double scale;
  const _AutomaticBadge({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8 * scale),
      child: CircleAvatar(
        radius: 8 * scale,
        backgroundColor: Colors.green,
        child: Text(
          'A',
          style: TextStyle(
            fontSize: 12 * scale,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
