// File: lib/profile_page.dart
import 'package:flutter/material.dart';
import '../../nutrition/measured_items_page.dart';
import 'app_settings_page.dart';
import 'analytics_setting_screen.dart';

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
        ],
      ),
    );
  }
}