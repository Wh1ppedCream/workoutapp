// lib/screens/profile/settings/ui_appearance_settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/models.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/unit_preference_provider.dart';
import '../../../widgets/settings_tiles.dart';
import 'nav_bar_settings_page.dart';

class UIAppearanceSettingsPage extends StatelessWidget {
  const UIAppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;
    final onboarding = context.watch<OnboardingConfig>();
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;

    return SettingsPageScaffold(
      title: 'UI & Appearance',
      subtitle: 'Control the way Tonos looks and how the bottom tabs behave.',
      icon: Icons.palette_outlined,
      children: [
        SettingsSection(
          title: 'Display',
          subtitle: 'Quick visual preferences.',
          children: settingsTilesWithDividers(context, [
            SettingsSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Use the darker app theme.',
              value: themeMode == ThemeMode.dark,
              onChanged:
                  (on) => context.read<ThemeProvider>().setMode(
                    on ? ThemeMode.dark : ThemeMode.light,
                  ),
            ),
            SettingsSwitchTile(
              icon: Icons.auto_awesome_outlined,
              title: 'Replay Onboarding',
              subtitle:
                  'Turn this on to open setup again. It turns off after completion.',
              value: onboarding.showOnboarding,
              onChanged: context.read<OnboardingConfig>().setShowOnboarding,
            ),
            SettingsActionTile(
              icon: Icons.monitor_weight_outlined,
              title: 'Weight Units',
              subtitle:
                  'Show workout weights and volume in ${weightUnit.shortLabel}.',
              trailing: Text(
                weightUnit.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              onTap: () => _showWeightUnitDialog(context, weightUnit),
            ),
          ]),
        ),
        SettingsSection(
          title: 'Navigation',
          subtitle: 'Choose which bottom tabs show up and in what order.',
          children: [
            SettingsActionTile(
              icon: Icons.space_dashboard_outlined,
              title: 'Edit Bottom Tabs',
              subtitle: 'Reorder active tabs or hide unused ones.',
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NavBarSettingsPage(),
                    ),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showWeightUnitDialog(
    BuildContext context,
    WeightUnit selectedUnit,
  ) async {
    final nextUnit = await showDialog<WeightUnit>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Weight Units'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final unit in WeightUnit.values)
                RadioListTile<WeightUnit>(
                  value: unit,
                  groupValue: selectedUnit,
                  title: Text(unit.label),
                  subtitle: Text(unit.shortLabel),
                  onChanged: (value) => Navigator.of(dialogContext).pop(value),
                ),
            ],
          ),
        );
      },
    );
    if (nextUnit == null || !context.mounted) return;
    await context.read<UnitPreferenceProvider>().setWeightUnit(nextUnit);
  }
}
