// lib/screens/profile/settings/ui_appearance_settings_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/models.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/locale_preference_provider.dart';
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
    final strings = AppLocalizations.of(context);
    try {
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.uiAppearanceSettings,
        steps: [
          GuidedTutorialStep(
            targetKey: _displayTutorialKey,
            icon: Icons.palette_outlined,
            title: strings.displaySettingsTutorialTitle,
            body: strings.displaySettingsTutorialBody,
          ),
          GuidedTutorialStep(
            targetKey: _navigationTutorialKey,
            icon: Icons.space_dashboard_outlined,
            title: strings.bottomTabsTutorialTitle,
            body: strings.bottomTabsTutorialBody,
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
    final language = context.watch<LocalePreferenceProvider>().preference;
    final strings = AppLocalizations.of(context);

    return SettingsPageScaffold(
      title: strings.uiAppearanceTitle,
      subtitle: strings.uiAppearanceSubtitle,
      icon: Icons.palette_outlined,
      heroAccentColor: SettingsAccent.appearance,
      children: [
        KeyedSubtree(
          key: _displayTutorialKey,
          child: SettingsSection(
            title: strings.displaySettingsTitle,
            subtitle: strings.displaySettingsSubtitle,
            accentColor: SettingsAccent.appearance,
            children: settingsTilesWithDividers(context, [
              SettingsSwitchTile(
                icon: Icons.dark_mode_outlined,
                iconColor: SettingsAccent.appearance,
                title: strings.darkModeTitle,
                subtitle: strings.darkModeSubtitle,
                value: themeMode == ThemeMode.dark,
                onChanged:
                    (on) => context.read<ThemeProvider>().setMode(
                      on ? ThemeMode.dark : ThemeMode.light,
                    ),
              ),
              SettingsSwitchTile(
                icon: Icons.auto_awesome_outlined,
                iconColor: SettingsAccent.appearance,
                title: strings.replayOnboardingTitle,
                subtitle: strings.replayOnboardingSubtitle,
                value: onboarding.showOnboarding,
                onChanged: context.read<OnboardingConfig>().setShowOnboarding,
              ),
              SettingsActionTile(
                icon: Icons.monitor_weight_outlined,
                iconColor: SettingsAccent.progress,
                title: strings.weightUnitsTitle,
                subtitle: strings.weightUnitsSubtitle(weightUnit.shortLabel),
                trailing: Text(
                  weightUnit.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                onTap: () => _showWeightUnitDialog(context, weightUnit),
              ),
              SettingsActionTile(
                icon: Icons.language_outlined,
                iconColor: SettingsAccent.appearance,
                title: strings.languageTitle,
                subtitle: strings.languageSubtitle,
                trailing: Text(
                  _languageLabel(strings, language),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                onTap: () => _showLanguageDialog(context, language),
              ),
            ]),
          ),
        ),
        KeyedSubtree(
          key: _navigationTutorialKey,
          child: SettingsSection(
            title: strings.navigationSettingsTitle,
            subtitle: strings.navigationSettingsSubtitle,
            accentColor: SettingsAccent.data,
            children: [
              SettingsActionTile(
                icon: Icons.space_dashboard_outlined,
                iconColor: SettingsAccent.data,
                title: strings.editBottomTabsTitle,
                subtitle: strings.editBottomTabsSubtitle,
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
    final strings = AppLocalizations.of(context);
    final nextUnit = await showDialog<WeightUnit>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.weightUnitsTitle),
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

  String _languageLabel(
    AppLocalizations strings,
    AppLanguagePreference preference,
  ) => switch (preference) {
    AppLanguagePreference.system => strings.systemDefaultLanguage,
    AppLanguagePreference.english => strings.englishLanguage,
    AppLanguagePreference.canadianFrench => strings.canadianFrenchLanguage,
  };

  Future<void> _showLanguageDialog(
    BuildContext context,
    AppLanguagePreference selectedLanguage,
  ) async {
    final strings = AppLocalizations.of(context);
    final nextLanguage = await showDialog<AppLanguagePreference>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.languageTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final language in AppLanguagePreference.values)
                RadioListTile<AppLanguagePreference>(
                  value: language,
                  groupValue: selectedLanguage,
                  title: Text(_languageLabel(strings, language)),
                  onChanged: (value) => Navigator.of(dialogContext).pop(value),
                ),
            ],
          ),
        );
      },
    );
    if (nextLanguage == null || !context.mounted) return;
    await context.read<LocalePreferenceProvider>().setPreference(nextLanguage);
  }
}
