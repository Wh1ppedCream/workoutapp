// lib/screens/profile/settings/measurements_trends_settings_page.dart

import 'package:flutter/material.dart';

import '../../../widgets/settings_tiles.dart';
import '../../nutrition/measured_items_page.dart';

class MeasurementsTrendsSettingsPage extends StatelessWidget {
  const MeasurementsTrendsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Progress Settings',
      subtitle: 'Manage body measurements and trend tracking setup.',
      icon: Icons.monitor_outlined,
      heroAccentColor: SettingsAccent.progress,
      children: [
        SettingsSection(
          title: 'Measurements',
          subtitle: 'Configure the body metrics you want to track over time.',
          accentColor: SettingsAccent.progress,
          children: [
            SettingsActionTile(
              icon: Icons.straighten,
              iconColor: SettingsAccent.progress,
              title: 'Measurement Library',
              subtitle:
                  'Manage weight, height, body measurements, and custom metrics.',
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MeasuredItemsPage(),
                    ),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
