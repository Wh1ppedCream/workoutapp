// file: lib/screens/profile/settings/profile_page.dart

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../services/tutorial_state_store.dart';
import '../../../widgets/guided_tutorial_overlay.dart';
import '../../../widgets/settings_tiles.dart';
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

      await GuidedTutorialOverlay.show(
        context,
        steps: [
          GuidedTutorialStep(
            targetKey: _accountSettingsTutorialKey,
            icon: Icons.person_outline,
            title: 'Account settings',
            body:
                'Update your personal info, display preferences, weight units, onboarding, bottom tabs, and guided tutorials from here.',
          ),
          GuidedTutorialStep(
            targetKey: _trainingSettingsTutorialKey,
            icon: Icons.fitness_center,
            title: 'Training settings',
            body:
                'Control gym profiles, generation rules, bodypart rankings, progress settings, and other training defaults.',
          ),
          GuidedTutorialStep(
            targetKey: _dataSettingsTutorialKey,
            icon: Icons.storage_outlined,
            title: 'Data tools',
            body:
                'Database settings are where you export, import, check, and maintain your local workout data.',
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
    return SettingsPageScaffold(
      title: 'Profile',
      subtitle:
          'Personalize Tonos, manage training defaults, and keep your data healthy.',
      icon: Icons.person,
      heroAccentColor: SettingsAccent.account,
      showBackButton: false,
      children: [
        KeyedSubtree(
          key: _accountSettingsTutorialKey,
          child: SettingsSection(
            title: 'Account',
            subtitle: 'Your identity and app-level appearance.',
            accentColor: SettingsAccent.account,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                icon: Icons.badge_outlined,
                iconColor: SettingsAccent.account,
                title: 'User Information',
                subtitle: 'Name, body details, and activity profile.',
                onTap:
                    () => _open(context, const UserInformationSettingsPage()),
              ),
              SettingsActionTile(
                icon: Icons.palette_outlined,
                iconColor: SettingsAccent.appearance,
                title: 'UI & Appearance',
                subtitle: 'Theme, onboarding, and bottom tab setup.',
                onTap: () => _open(context, const UIAppearanceSettingsPage()),
              ),
              SettingsActionTile(
                icon: Icons.school_outlined,
                iconColor: SettingsAccent.appearance,
                title: 'Guided Tutorials',
                subtitle: 'Replay walkthroughs and reset guided help.',
                onTap: () => _open(context, const TutorialsSettingsPage()),
              ),
            ]),
          ),
        ),
        KeyedSubtree(
          key: _trainingSettingsTutorialKey,
          child: SettingsSection(
            title: 'Training',
            subtitle: 'Exercise defaults and progress-related controls.',
            accentColor: SettingsAccent.training,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                icon: Icons.fitness_center,
                iconColor: SettingsAccent.training,
                title: 'Gym & Workout Settings',
                subtitle:
                    'Workout generation, rankings, flows, and equipment logic.',
                onTap: () => _open(context, const GymExerciseSettingsPage()),
              ),
              SettingsActionTile(
                icon: Icons.monitor_outlined,
                iconColor: SettingsAccent.progress,
                title: 'Progress Settings',
                subtitle: 'Measurement and trend tracking setup.',
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
            title: 'Data',
            subtitle: 'Database tools, exports, imports, and maintenance.',
            accentColor: SettingsAccent.data,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                icon: Icons.storage_outlined,
                iconColor: SettingsAccent.data,
                title: 'Database Settings',
                subtitle:
                    'Import, export, health checks, and maintenance tools.',
                onTap: () => _open(context, const DatabaseSettingsPage()),
              ),
            ]),
          ),
        ),
        SettingsSection(
          title: 'Nutrition',
          subtitle: 'Nutrition settings are paused while this area is rebuilt.',
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

    return Opacity(
      opacity: 0.48,
      child: SettingsActionTile(
        icon: Icons.restaurant_menu,
        iconColor: scheme.onSurfaceVariant,
        title: 'Diet & Nutrition Settings',
        subtitle: 'Nutrition goals and preferences will return later.',
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Text(
            'Later',
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
