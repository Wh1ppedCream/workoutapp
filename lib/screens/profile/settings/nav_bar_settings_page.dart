import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/nav_bar_config.dart';
import '../../../widgets/settings_tiles.dart';

class NavBarSettingsPage extends StatefulWidget {
  const NavBarSettingsPage({super.key});

  @override
  State<NavBarSettingsPage> createState() => _NavBarSettingsPageState();
}

class _NavBarSettingsPageState extends State<NavBarSettingsPage> {
  late List<TabItem> _activeTabs;
  late List<TabItem> _inactiveTabs;

  @override
  void initState() {
    super.initState();
    final config = context.read<NavBarConfig>();
    _activeTabs =
        config.order.where((tab) => config.enabledTabs.contains(tab)).toList();
    _inactiveTabs =
        config.order.where((tab) => !config.enabledTabs.contains(tab)).toList();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final tab = _activeTabs.removeAt(oldIndex);
      _activeTabs.insert(newIndex, tab);
    });
  }

  void _toggleTab(TabItem tab, bool enable) {
    setState(() {
      if (enable) {
        _inactiveTabs.remove(tab);
        _activeTabs.add(tab);
      } else {
        if (tab == TabItem.profile) return;
        _activeTabs.remove(tab);
        _inactiveTabs.add(tab);
      }
    });
  }

  void _save() {
    if (_activeTabs.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please keep at least two active tabs.')),
      );
      return;
    }

    final newOrder = [..._activeTabs, ..._inactiveTabs];
    final newEnabled = _activeTabs.toSet();
    context.read<NavBarConfig>().update(
      newOrder: newOrder,
      newEnabled: newEnabled,
    );
    setState(() {
      _activeTabs = newOrder.where((tab) => newEnabled.contains(tab)).toList();
      _inactiveTabs =
          newOrder.where((tab) => !newEnabled.contains(tab)).toList();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bottom tabs saved')));
  }

  @override
  Widget build(BuildContext context) {
    final inactiveDisplay =
        _inactiveTabs.where((tab) => tab != TabItem.profile).toList();

    return SettingsPageScaffold(
      title: 'Edit Bottom Tabs',
      subtitle:
          'Choose what appears in the bottom bar and reorder active tabs.',
      icon: Icons.space_dashboard_outlined,
      heroAccentColor: SettingsAccent.data,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Tabs'),
          ),
        ),
      ),
      children: [
        SettingsSection(
          title: 'Active Tabs',
          subtitle: 'Drag to reorder. Profile stays available.',
          accentColor: SettingsAccent.data,
          children: [
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: _onReorder,
              itemCount: _activeTabs.length,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) {
                return Material(
                  color: Colors.transparent,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 1,
                      end: 1.02,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              itemBuilder: (context, index) {
                final tab = _activeTabs[index];
                return _NavTabTile(
                  key: ValueKey('active-${tab.name}'),
                  tab: tab,
                  isActive: true,
                  isLocked: tab == TabItem.profile,
                  dragIndex: index,
                  onToggle: (value) => _toggleTab(tab, value),
                );
              },
            ),
          ],
        ),
        SettingsSection(
          title: 'Inactive Tabs',
          subtitle: 'Turn these on whenever you want them back.',
          accentColor: SettingsAccent.muted,
          children:
              inactiveDisplay.isEmpty
                  ? const [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No inactive tabs.'),
                    ),
                  ]
                  : settingsTilesWithDividers(context, [
                    for (final tab in inactiveDisplay)
                      _NavTabTile(
                        key: ValueKey('inactive-${tab.name}'),
                        tab: tab,
                        isActive: false,
                        onToggle: (value) => _toggleTab(tab, value),
                      ),
                  ]),
        ),
        const SizedBox(height: 72),
      ],
    );
  }
}

class _NavTabTile extends StatelessWidget {
  final TabItem tab;
  final bool isActive;
  final bool isLocked;
  final int? dragIndex;
  final ValueChanged<bool> onToggle;

  const _NavTabTile({
    super.key,
    required this.tab,
    required this.isActive,
    this.isLocked = false,
    this.dragIndex,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      leading:
          dragIndex == null
              ? _IconBadge(icon: tab.icon)
              : ReorderableDragStartListener(
                index: dragIndex!,
                child: _IconBadge(
                  icon: tab.icon,
                  trailingIcon: Icons.drag_handle,
                ),
              ),
      title: Text(
        tab.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        isLocked
            ? 'Always shown'
            : isActive
            ? 'Visible in bottom navigation'
            : 'Hidden from bottom navigation',
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(value: isActive, onChanged: isLocked ? null : onToggle),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final IconData? trailingIcon;

  const _IconBadge({required this.icon, this.trailingIcon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 48,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: scheme.primary, size: 22),
          ),
          if (trailingIcon != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Icon(
                trailingIcon,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
