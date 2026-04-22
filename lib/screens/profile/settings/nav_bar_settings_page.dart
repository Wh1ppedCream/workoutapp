import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/nav_bar_config.dart';

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
    final cfg = context.read<NavBarConfig>();
    _activeTabs = cfg.order.where((tab) => cfg.enabledTabs.contains(tab)).toList();
    _inactiveTabs = cfg.order.where((tab) => !cfg.enabledTabs.contains(tab)).toList();
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
        // Prevent disabling the profile tab
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
    context.read<NavBarConfig>().update(newOrder: newOrder, newEnabled: newEnabled);
    setState(() {
      _activeTabs = newOrder.where((tab) => newEnabled.contains(tab)).toList();
      _inactiveTabs = newOrder.where((tab) => !newEnabled.contains(tab)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _activeTabs.length + _inactiveTabs.length;
    final activeFlex = total > 0 ? _activeTabs.length : 1;
    final inactiveFlex = total > 0 ? _inactiveTabs.length : 1;
    // Exclude profile from inactive display
    final inactiveDisplay = _inactiveTabs.where((tab) => tab != TabItem.profile).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Bottom Tabs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active Tabs', style: Theme.of(context).textTheme.titleMedium),
            Expanded(
              flex: activeFlex,
              child: ReorderableListView.builder(
                onReorder: _onReorder,
                itemCount: _activeTabs.length,
                buildDefaultDragHandles: false,
                itemBuilder: (context, index) {
                  final tab = _activeTabs[index];
                  return ListTile(
                    key: ValueKey(tab),
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                    title: Row(
                      children: [
                        Icon(tab.icon),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tab.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    trailing: tab == TabItem.profile
                        // profile is always on, switch disabled
                        ? const Switch(value: true, onChanged: null)
                        : Switch(
                            value: true,
                            onChanged: (value) => _toggleTab(tab, value),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Inactive Tabs', style: Theme.of(context).textTheme.titleMedium),
            Expanded(
              flex: inactiveFlex,
              child: ListView.builder(
                itemCount: inactiveDisplay.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final tab = inactiveDisplay[index];
                  return ListTile(
                    key: ValueKey(tab),
                    leading: Icon(tab.icon),
                    title: Text(
                      tab.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Switch(
                      value: false,
                      onChanged: (value) => _toggleTab(tab, value),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ),
    );
  }
}
