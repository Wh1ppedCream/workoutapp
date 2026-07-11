// lib/screens/profile/settings/ui_appearance_settings_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/models.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/unit_preference_provider.dart';
import '../../../services/tutorial_state_store.dart';
import '../../../utils/tutorial_launcher.dart';
import '../../../widgets/guided_tutorial_overlay.dart';
import '../../../widgets/settings_tiles.dart';
import 'nav_bar_settings_page.dart';

class UIAppearanceSettingsPage extends StatefulWidget {
  const UIAppearanceSettingsPage({super.key});

  @override
  State<UIAppearanceSettingsPage> createState() =>
      _UIAppearanceSettingsPageState();
}

class _UIAppearanceSettingsPageState extends State<UIAppearanceSettingsPage> {
  final _displayTutorialKey = GlobalKey(debugLabel: 'ui_settings_display');
  final _navigationTutorialKey = GlobalKey(
    debugLabel: 'ui_settings_navigation',
  );
  bool _tutorialQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
  }

  void _queueTutorial() {
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  Future<void> _showTutorial() async {
    try {
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.uiAppearanceSettings,
        steps: [
          GuidedTutorialStep(
            targetKey: _displayTutorialKey,
            icon: Icons.palette_outlined,
            title: 'Display settings',
            body:
                'Control dark mode, replay onboarding, and switch between pounds and kilograms.',
          ),
          GuidedTutorialStep(
            targetKey: _navigationTutorialKey,
            icon: Icons.space_dashboard_outlined,
            title: 'Bottom tabs',
            body:
                'Edit which bottom tabs are shown and the order they appear in.',
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;
    final onboarding = context.watch<OnboardingConfig>();
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;

    return SettingsPageScaffold(
      title: 'UI & Appearance',
      subtitle: 'Control the way Tonos looks and how the bottom tabs behave.',
      icon: Icons.palette_outlined,
      heroAccentColor: SettingsAccent.appearance,
      children: [
        KeyedSubtree(
          key: _displayTutorialKey,
          child: SettingsSection(
            title: 'Display',
            subtitle: 'Quick visual preferences.',
            accentColor: SettingsAccent.appearance,
            children: settingsTilesWithDividers(context, [
              SettingsSwitchTile(
                icon: Icons.dark_mode_outlined,
                iconColor: SettingsAccent.appearance,
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
                iconColor: SettingsAccent.appearance,
                title: 'Replay Onboarding',
                subtitle:
                    'Turn this on to open setup again. It turns off after completion.',
                value: onboarding.showOnboarding,
                onChanged: context.read<OnboardingConfig>().setShowOnboarding,
              ),
              SettingsActionTile(
                icon: Icons.monitor_weight_outlined,
                iconColor: SettingsAccent.progress,
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
        ),
        KeyedSubtree(
          key: _navigationTutorialKey,
          child: SettingsSection(
            title: 'Navigation',
            subtitle: 'Choose which bottom tabs show up and in what order.',
            accentColor: SettingsAccent.data,
            children: [
              SettingsActionTile(
                icon: Icons.space_dashboard_outlined,
                iconColor: SettingsAccent.data,
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
