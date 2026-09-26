// lib/screens/profile/settings/ui_appearance_settings_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/models.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/app_localization_extensions.dart';
import '../../../providers/locale_preference_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/unit_preference_provider.dart';
import '../../../services/tutorial_state_store.dart';
import '../../../theme/app_theme_family.dart';
import '../../../theme/app_theme_factory.dart';
import '../../../theme/widgets/tonos_dialog.dart';
import '../../../utils/app_test_keys.dart';
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
    final themeProvider = context.watch<ThemeProvider>();
    final themeMode = themeProvider.mode;
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
              if (themeProvider.availableFamilies.length > 1)
                SettingsActionTile(
                  key: AppTestKeys.uiAppearanceThemeFamily,
                  icon: Icons.palette_outlined,
                  iconColor: SettingsAccent.appearance,
                  title: strings.themeFamilyTitle,
                  subtitle: strings.themeFamilySubtitle,
                  trailing: SettingsValueText(
                    value: _themeFamilyLabel(strings, themeProvider.family),
                  ),
                  onTap:
                      () => _showThemeFamilyDialog(
                        context,
                        themeProvider.family,
                        themeProvider.availableFamilies,
                      ),
                ),
              SettingsSwitchTile(
                icon: Icons.dark_mode_outlined,
                iconColor: SettingsAccent.appearance,
                title: strings.darkModeTitle,
                subtitle: strings.darkModeSubtitle,
                value: themeMode == ThemeMode.dark,
                onChanged:
                    (on) => unawaited(
                      _setThemeMode(on ? ThemeMode.dark : ThemeMode.light),
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
                trailing: SettingsValueText(
                  value: _weightUnitLabel(strings, weightUnit),
                ),
                onTap: () => _showWeightUnitDialog(context, weightUnit),
              ),
              KeyedSubtree(
                key: AppTestKeys.uiAppearanceLanguage,
                child: SettingsActionTile(
                  icon: Icons.language_outlined,
                  iconColor: SettingsAccent.appearance,
                  title: strings.languageTitle,
                  subtitle: strings.languageSubtitle,
                  trailing: SettingsValueText(
                    value: _languageLabel(strings, language),
                  ),
                  onTap: () => _showLanguageDialog(context, language),
                ),
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
              KeyedSubtree(
                key: AppTestKeys.uiAppearanceNavigation,
                child: SettingsActionTile(
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    try {
      await context.read<ThemeProvider>().setMode(mode);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).safeFailureSaveTitle),
        ),
      );
    }
  }

  Future<void> _showThemeFamilyDialog(
    BuildContext context,
    AppThemeFamily selectedFamily,
    List<AppThemeFamily> availableFamilies,
  ) async {
    final strings = AppLocalizations.of(context);
    final nextFamily = await showDialog<AppThemeFamily>(
      context: context,
      builder:
          (dialogContext) => TonosChoiceDialog<AppThemeFamily>(
            title: strings.themeFamilyTitle,
            values: availableFamilies,
            selected: selectedFamily,
            label: (family) => _themeFamilyLabel(strings, family),
            subtitle: (family) => _themeFamilyDescription(strings, family),
            choicePreview:
                (family) => _ThemeFamilyPreview(
                  family: family,
                  brightness: Theme.of(context).brightness,
                ),
            choiceKey:
                (family) =>
                    AppTestKeys.uiAppearanceThemeFamilyOption(family.code),
          ),
    );
    if (nextFamily == null || !context.mounted) return;
    await _setThemeFamily(nextFamily);
  }

  Future<void> _setThemeFamily(AppThemeFamily family) async {
    try {
      await context.read<ThemeProvider>().setFamily(family);
    } catch (_) {
      if (!mounted) return;
      final strings = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(strings.safeFailureSaveTitle),
            action: SnackBarAction(
              label: strings.commonRetry,
              onPressed: () => unawaited(_setThemeFamily(family)),
            ),
          ),
        );
    }
  }

  Future<void> _showWeightUnitDialog(
    BuildContext context,
    WeightUnit selectedUnit,
  ) async {
    final strings = AppLocalizations.of(context);
    final nextUnit = await showDialog<WeightUnit>(
      context: context,
      builder:
          (dialogContext) => TonosChoiceDialog<WeightUnit>(
            title: strings.weightUnitsTitle,
            values: WeightUnit.values,
            selected: selectedUnit,
            label: (unit) => _weightUnitLabel(strings, unit),
            subtitle: (unit) => unit.shortLabel,
          ),
    );
    if (nextUnit == null || !context.mounted) return;
    await context.read<UnitPreferenceProvider>().setWeightUnit(nextUnit);
  }

  String _weightUnitLabel(AppLocalizations strings, WeightUnit unit) {
    return unit.localizedLabel(strings);
  }

  String _themeFamilyLabel(AppLocalizations strings, AppThemeFamily family) =>
      switch (family) {
        AppThemeFamily.classic => strings.themeFamilyClassic,
        AppThemeFamily.neoBrutalism => strings.themeFamilyNeoBrutalism,
      };

  String _themeFamilyDescription(
    AppLocalizations strings,
    AppThemeFamily family,
  ) => switch (family) {
    AppThemeFamily.classic => strings.themeFamilyClassicDescription,
    AppThemeFamily.neoBrutalism => strings.themeFamilyNeoBrutalismDescription,
  };

  String _languageLabel(
    AppLocalizations strings,
    AppLanguagePreference preference,
  ) => switch (preference) {
    AppLanguagePreference.system => strings.systemDefaultLanguage,
    AppLanguagePreference.english => strings.englishLanguage,
    AppLanguagePreference.canadianFrench => strings.canadianFrenchLanguage,
    AppLanguagePreference.bengaliBangladesh =>
      strings.bengaliBangladeshLanguage,
    AppLanguagePreference.simplifiedChinese =>
      strings.simplifiedChineseLanguage,
    AppLanguagePreference.hindi => strings.hindiLanguage,
    AppLanguagePreference.spanish => strings.spanishLanguage,
  };

  Future<void> _showLanguageDialog(
    BuildContext context,
    AppLanguagePreference selectedLanguage,
  ) async {
    final strings = AppLocalizations.of(context);
    final nextLanguage = await showDialog<AppLanguagePreference>(
      context: context,
      builder: (dialogContext) {
        return TonosDialogFrame(
          child: AlertDialog(
            title: Text(strings.languageTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final language in AppLanguagePreference.values)
                  RadioListTile<AppLanguagePreference>(
                    value: language,
                    groupValue: selectedLanguage,
                    title: Text(_languageLabel(strings, language)),
                    onChanged:
                        (value) => Navigator.of(dialogContext).pop(value),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (nextLanguage == null || !context.mounted) return;
    await context.read<LocalePreferenceProvider>().setPreference(nextLanguage);
  }
}

class _ThemeFamilyPreview extends StatelessWidget {
  const _ThemeFamilyPreview({required this.family, required this.brightness});

  final AppThemeFamily family;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final theme =
        brightness == Brightness.dark
            ? AppThemeFactory.dark(family)
            : AppThemeFactory.light(family);
    final scheme = theme.colorScheme;
    final isNeo = family == AppThemeFamily.neoBrutalism;
    final panel = isNeo ? scheme.primary : scheme.surfaceContainerHighest;
    final foreground = isNeo ? scheme.onPrimary : scheme.onSurface;
    final accent = isNeo ? scheme.secondary : scheme.primary;

    return ExcludeSemantics(
      child: SizedBox(
        width: 52,
        height: 36,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: panel,
            border: Border.all(color: foreground, width: isNeo ? 1.5 : 1),
            borderRadius: isNeo ? BorderRadius.zero : BorderRadius.circular(6),
            boxShadow:
                isNeo
                    ? const [
                      BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                    ]
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 26,
                    height: 4,
                    child: ColoredBox(color: foreground),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 5,
                      child: ColoredBox(color: accent),
                    ),
                    SizedBox(
                      width: 10,
                      height: 5,
                      child: ColoredBox(
                        color: foreground.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
