// file: lib/screens/profile/settings/profile_page.dart

import 'package:flutter/material.dart';

import '../../../widgets/settings_tiles.dart';
import 'database_settings_page.dart';
import 'diet_nutrition_settings_page.dart';
import 'gym_exercise_settings_page.dart';
import 'measurements_trends_settings_page.dart';
import 'ui_appearance_settings_page.dart';
import 'user_information_settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Profile',
      subtitle:
          'Personalize Tonos, manage training defaults, and keep your data healthy.',
      icon: Icons.person,
      showAppBar: false,
      children: [
        SettingsSection(
          title: 'Account',
          subtitle: 'Your identity and app-level appearance.',
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.badge_outlined,
              title: 'User Information',
              subtitle: 'Name, body details, and activity profile.',
              onTap: () => _open(context, const UserInformationSettingsPage()),
            ),
            SettingsActionTile(
              icon: Icons.palette_outlined,
              title: 'UI & Appearance',
              subtitle: 'Theme, onboarding, and bottom tab setup.',
              onTap: () => _open(context, const UIAppearanceSettingsPage()),
            ),
          ]),
        ),
        SettingsSection(
          title: 'Training',
          subtitle: 'Exercise defaults and progress-related controls.',
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.fitness_center,
              title: 'Gym & Workout Settings',
              subtitle:
                  'Workout generation, rankings, flows, and equipment logic.',
              onTap: () => _open(context, const GymExerciseSettingsPage()),
            ),
            SettingsActionTile(
              icon: Icons.monitor_outlined,
              title: 'Progress Settings',
              subtitle: 'Measurement and trend tracking setup.',
              onTap: () => _open(context, const MeasurementsTrendsSettingsPage()),
            ),
          ]),
        ),
        SettingsSection(
          title: 'Data & Nutrition',
          subtitle: 'Data tools and nutrition configuration.',
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.restaurant_menu,
              title: 'Diet & Nutrition Settings',
              subtitle: 'Nutrition goals and related preferences.',
              onTap: () => _open(context, const DietNutritionSettingsPage()),
            ),
            SettingsActionTile(
              icon: Icons.storage_outlined,
              title: 'Database Settings',
              subtitle: 'Import, export, health checks, and maintenance tools.',
              onTap: () => _open(context, const DatabaseSettingsPage()),
            ),
          ]),
        ),
      ],
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}
