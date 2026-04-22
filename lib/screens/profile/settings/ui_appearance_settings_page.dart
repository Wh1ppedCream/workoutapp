// lib/screens/profile/settings/ui_appearance_settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/onboarding_provider.dart';
import 'nav_bar_settings_page.dart';

class UIAppearanceSettingsPage extends StatelessWidget {
  const UIAppearanceSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UI & Appearance')), 
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: context.watch<ThemeProvider>().mode == ThemeMode.dark,
            onChanged: (on) => context.read<ThemeProvider>().setMode(
                on ? ThemeMode.dark : ThemeMode.light),
          ),

          SwitchListTile(
  title: const Text('Show Onboarding on every app launch'),
  value: context.watch<OnboardingConfig>().alwaysShow,
  onChanged: (on) =>
    context.read<OnboardingConfig>().setAlwaysShow(on),
),


          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Bottom Tabs'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NavBarSettingsPage()),
            ),
          ),
        ],
      ),
    );
  }
}