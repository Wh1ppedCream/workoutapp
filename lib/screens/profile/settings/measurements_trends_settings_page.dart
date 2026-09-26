// lib/screens/profile/settings/measurements_trends_settings_page.dart

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/app_test_keys.dart';
import '../../../widgets/settings_tiles.dart';
import '../../nutrition/measured_items_page.dart';

class MeasurementsTrendsSettingsPage extends StatelessWidget {
  const MeasurementsTrendsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SettingsPageScaffold(
      title: strings.progressSettingsTitle,
      subtitle: strings.progressSettingsSubtitle,
      icon: Icons.monitor_outlined,
      heroAccentColor: SettingsAccent.progress,
      children: [
        SettingsSection(
          title: strings.progressMeasurements,
          subtitle: strings.progressMeasurementsSubtitle,
          accentColor: SettingsAccent.progress,
          children: [
            KeyedSubtree(
              key: AppTestKeys.progressMeasurementLibrary,
              child: SettingsActionTile(
                icon: Icons.straighten,
                iconColor: SettingsAccent.progress,
                title: strings.progressMeasurementLibrary,
                subtitle: strings.progressMeasurementLibrarySubtitle,
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MeasuredItemsPage(),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
