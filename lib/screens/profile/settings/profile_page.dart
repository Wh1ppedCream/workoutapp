// File: lib/screens/profile/settings/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../nutrition/measured_items_page.dart';
import 'app_settings_page.dart';
import 'analytics_setting_screen.dart';
import '../../../providers/theme_provider.dart';
import 'nav_bar_settings_page.dart';

// Adjust this path to wherever you put flow_chart_page.dart:
import 'flow_chart_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      // ← changed Column → ListView
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          SwitchListTile(
  title: const Text('Dark Mode'),
  value: context.watch<ThemeProvider>().mode == ThemeMode.dark,
  onChanged: (on) {
    context.read<ThemeProvider>().setMode(
      on ? ThemeMode.dark : ThemeMode.light
    );
  },
),

          ListTile(
            leading: const Icon(Icons.timeline),
            title: const Text('Measurements'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MeasuredItemsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('User Info'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AppSettingsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Workout Settings'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnalyticsSettingsScreen()),
            ),
          ),
          // ← this was getting clipped when you used Column
          ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: const Text('Flowchart Example'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FlowChartPage()),
            ),
          ),
          ListTile(
  leading: const Icon(Icons.edit),
  title: const Text('Edit Bottom Tabs'),
  onTap: () => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const NavBarSettingsPage()),
  ),
),

        ],
      ),
    );
  }
}