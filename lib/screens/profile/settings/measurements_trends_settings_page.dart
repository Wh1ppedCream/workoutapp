// lib/screens/profile/settings/measurements_trends_settings_page.dart
import 'package:flutter/material.dart';
import '../../nutrition/measured_items_page.dart';

class MeasurementsTrendsSettingsPage extends StatelessWidget {
  const MeasurementsTrendsSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.timeline),
            title: const Text('Measurements'),
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MeasuredItemsPage()),
                ),
          ),
        ],
      ),
    );
  }
}
