// file: lib/screens/profile/settings/profile_page.dart
import 'package:flutter/material.dart';
import 'user_information_settings_page.dart';
import 'ui_appearance_settings_page.dart';
import 'database_settings_page.dart';
import 'gym_exercise_settings_page.dart';
import 'diet_nutrition_settings_page.dart';
import 'measurements_trends_settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('User Information'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserInformationSettingsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('UI and Appearance Settings'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UIAppearanceSettingsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Database Settings'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DatabaseSettingsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Gym, Exercise and Workout Settings'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GymExerciseSettingsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Diet and Nutrition Settings'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DietNutritionSettingsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.show_chart),
            title: const Text('Measurements and Trends Settings'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MeasurementsTrendsSettingsPage()),
            ),
          ),
        ],
      ),
    );
  }
}