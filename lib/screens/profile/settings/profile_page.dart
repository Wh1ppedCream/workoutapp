// file: lib/screens/profile/settings/profile_page.dart

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../services/tutorial_state_store.dart';
import '../../../widgets/guided_tutorial_overlay.dart';
import '../../../widgets/settings_tiles.dart';
import '../../../utils/app_test_keys.dart';
import 'database_settings_page.dart';
import 'gym_exercise_settings_page.dart';
import 'measurements_trends_settings_page.dart';
import 'tutorials_settings_page.dart';
import 'ui_appearance_settings_page.dart';
import 'user_information_settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _accountSettingsTutorialKey = GlobalKey(
    debugLabel: 'profile_account_settings_tutorial',
  );
  final _trainingSettingsTutorialKey = GlobalKey(
    debugLabel: 'profile_training_settings_tutorial',
  );
  final _dataSettingsTutorialKey = GlobalKey(
    debugLabel: 'profile_data_settings_tutorial',
  );
  final _tutorialStore = const TutorialStateStore();

  bool _profileTutorialQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueProfileTutorial();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TickerMode.of(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queueProfileTutorial();
      });
    }
  }

  void _queueProfileTutorial() {
    if (!mounted || _profileTutorialQueued || !TickerMode.of(context)) return;
    _profileTutorialQueued = true;
    unawaited(_showProfileTutorialIfNeeded());
  }

  Future<void> _showProfileTutorialIfNeeded() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 550));
      if (!mounted || !TickerMode.of(context)) return;

      final completed = await _tutorialStore.isCompleted(
        TutorialIds.profileHome,
      );
      if (completed || !mounted) return;
      final strings = AppLocalizations.of(context);

      await GuidedTutorialOverlay.show(
        context,
        steps: [
          GuidedTutorialStep(
            targetKey: _accountSettingsTutorialKey,
            icon: Icons.person_outline,
            title: strings.profileAccountTutorialTitle,
            body: strings.profileAccountTutorialBody,
          ),
          GuidedTutorialStep(
            targetKey: _trainingSettingsTutorialKey,
            icon: Icons.fitness_center,
            title: strings.profileTrainingTutorialTitle,
            body: strings.profileTrainingTutorialBody,
          ),
          GuidedTutorialStep(
            targetKey: _dataSettingsTutorialKey,
            icon: Icons.storage_outlined,
            title: strings.profileDataTutorialTitle,
            body: strings.profileDataTutorialBody,
          ),
        ],
      );
      await _tutorialStore.markCompleted(TutorialIds.profileHome);
    } finally {
      _profileTutorialQueued = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SettingsPageScaffold(
      title: strings.profileTitle,
      subtitle: strings.profileSubtitle,
      icon: Icons.person,
      heroAccentColor: SettingsAccent.account,
      showBackButton: false,
      children: [
        KeyedSubtree(
          key: _accountSettingsTutorialKey,
          child: SettingsSection(
            title: strings.profileAccountSectionTitle,
            subtitle: strings.profileAccountSectionSubtitle,
            accentColor: SettingsAccent.account,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                key: AppTestKeys.profileUserInformation,
                icon: Icons.badge_outlined,
                iconColor: SettingsAccent.account,
                title: strings.profileUserInformationTitle,
                subtitle: strings.profileUserInformationSubtitle,
                onTap:
                    () => _open(context, const UserInformationSettingsPage()),
              ),
              SettingsActionTile(
                icon: Icons.palette_outlined,
                iconColor: SettingsAccent.appearance,
                title: strings.profileUiAppearanceTitle,
                subtitle: strings.profileUiAppearanceSubtitle,
                onTap: () => _open(context, const UIAppearanceSettingsPage()),
              ),
              SettingsActionTile(
                icon: Icons.school_outlined,
                iconColor: SettingsAccent.appearance,
                title: strings.profileGuidedTutorialsTitle,
                subtitle: strings.profileGuidedTutorialsSubtitle,
                onTap: () => _open(context, const TutorialsSettingsPage()),
              ),
            ]),
          ),
        ),
        KeyedSubtree(
          key: _trainingSettingsTutorialKey,
          child: SettingsSection(
            title: strings.profileTrainingSectionTitle,
            subtitle: strings.profileTrainingSectionSubtitle,
            accentColor: SettingsAccent.training,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                icon: Icons.fitness_center,
                iconColor: SettingsAccent.training,
                title: strings.profileGymWorkoutSettingsTitle,
                subtitle: strings.profileGymWorkoutSettingsSubtitle,
                onTap: () => _open(context, const GymExerciseSettingsPage()),
              ),
              SettingsActionTile(
                icon: Icons.monitor_outlined,
                iconColor: SettingsAccent.progress,
                title: strings.profileProgressSettingsTitle,
                subtitle: strings.profileProgressSettingsSubtitle,
                onTap:
                    () =>
                        _open(context, const MeasurementsTrendsSettingsPage()),
              ),
            ]),
          ),
        ),
        KeyedSubtree(
          key: _dataSettingsTutorialKey,
          child: SettingsSection(
            title: strings.profileDataSectionTitle,
            subtitle: strings.profileDataSectionSubtitle,
            accentColor: SettingsAccent.data,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                key: AppTestKeys.profileDatabaseSettings,
                icon: Icons.storage_outlined,
                iconColor: SettingsAccent.data,
                title: strings.profileDatabaseSettingsTitle,
                subtitle: strings.profileDatabaseSettingsSubtitle,
                onTap: () => _open(context, const DatabaseSettingsPage()),
              ),
            ]),
          ),
        ),
        SettingsSection(
          title: strings.profileNutritionSectionTitle,
          subtitle: strings.profileNutritionSectionSubtitle,
          accentColor: SettingsAccent.muted,
          children: settingsTilesWithDividers(context, [
            _disabledNutritionTile(context),
          ]),
        ),
      ],
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Widget _disabledNutritionTile(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);

    return Opacity(
      opacity: 0.48,
      child: SettingsActionTile(
        icon: Icons.restaurant_menu,
        iconColor: scheme.onSurfaceVariant,
        title: strings.profileDietNutritionSettingsTitle,
        subtitle: strings.profileDietNutritionSettingsSubtitle,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Text(
            strings.profileLater,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
