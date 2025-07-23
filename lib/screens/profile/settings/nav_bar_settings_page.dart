// lib/screens/profile/nav_bar_settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/nav_bar_config.dart';

class NavBarSettingsPage extends StatefulWidget {
  const NavBarSettingsPage({super.key});

  @override
  State<NavBarSettingsPage> createState() => _NavBarSettingsPageState();
}

class _NavBarSettingsPageState extends State<NavBarSettingsPage> {
  late List<TabItem> _order;
  late Set<TabItem> _enabled;

  @override
  void initState() {
    super.initState();
    final cfg = context.read<NavBarConfig>();
    // Use the public getters instead of private fields
    _order = List.from(cfg.order);
    _enabled = Set.from(cfg.enabledTabs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Bottom Tabs')),
      body: ReorderableListView.builder(
        itemCount: _order.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _order.removeAt(oldIndex);
            _order.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final tab = _order[index];
          return ListTile(
            key: ValueKey(tab),
            leading: Icon(tab.icon),
            title: Text(tab.title),
            trailing: Switch(
              value: _enabled.contains(tab),
              onChanged: (on) {
                setState(() {
                  if (on) {
                    _enabled.add(tab);
                  } else {
                    _enabled.remove(tab);
                  }
                });
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            context.read<NavBarConfig>().update(
              newOrder: _order,
              newEnabled: _enabled,
            );
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
