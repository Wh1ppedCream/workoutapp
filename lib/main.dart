// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/active_session.dart';
import 'screens/dashboard_page.dart';
import 'screens/exercise/history_screen.dart';
import 'screens/exercise/train_page.dart';          
import 'screens/nutrition/nutrition_page.dart';
import 'screens/profile/settings/profile_page.dart';
import 'widgets/ongoing_session_fab.dart';
import 'providers/selected_profile.dart';
import 'providers/dashboard_config.dart';
import 'screens/onboarding_flow.dart'; // New import for onboarding

import 'providers/theme_provider.dart';
import '../theme/app_colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActiveSession()),
        ChangeNotifierProvider(create: (_) => SelectedProfile()),
        ChangeNotifierProvider(create: (_) => DashboardConfig()),
       ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProv, _) {
        // Light theme with default AppColors
        final lightTheme = ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ).copyWith(
          extensions: <ThemeExtension<dynamic>>[
            const AppColors(
  quickBarMeasurementBg: Color(0xFFB2DFDB),       // light mode teal.shade100
  quickBarMeasurementText: Color(0xFF004D40),     // light mode teal.shade800
  quickBarFoodBg: Color(0xFFFFE0B2),              // light mode orange.shade100
  quickBarFoodText: Color(0xFFEF6C00),            // light mode orange.shade800
  quickBarWorkoutBg: Color(0xFFC8E6C9),           // light mode green.shade100
  quickBarWorkoutText: Color(0xFF2E7D32),         // light mode green.shade800


  addExerciseFabBg: Color(0xFF6200EE),         // light-mode FAB bg
  addExerciseFabIcon: Colors.white,            // light-mode FAB icon
  dialogBackground: Colors.white,             // light-mode dialogs
              // add other light-mode overrides here…
            ),
          ],
        );

        // Dark theme that builds on the seed-based dark colorScheme,
        // then overrides just the QuickBar containers & text
        final darkBase = ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: Colors.deepPurple,
          ),
        );
        final darkTheme = darkBase.copyWith(
          extensions: <ThemeExtension<dynamic>>[
            const AppColors(
  quickBarMeasurementBg: Color(0xFF004D40),       // dark mode teal.shade700
  quickBarMeasurementText: Color(0xFFE0F2F1),     // teal.shade50
  quickBarFoodBg: Color(0xFFF57C00),              // orange.shade700
  quickBarFoodText: Color(0xFFFFF3E0),            // orange.shade50
  quickBarWorkoutBg: Color(0xFF2E7D32),           // green.shade700
  quickBarWorkoutText: Color(0xFFE8F5E9),         // green.shade50


  addExerciseFabBg: Color(0xFF3700B3),    // a darker purple
  addExerciseFabIcon: Colors.black,
  dialogBackground: Color(0xFF202020),
              // add other dark-mode overrides here…
            ),
          ],
        );

        return MaterialApp(
          title: 'Fitness Tracker',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProv.mode,


  // TODO: Replace with conditional logic to show onboarding only once
      home: const OnboardingFlow(),
      // TODO: After onboarding completes, navigate to MainScreen
      routes: {
            '/main': (_) => const MainScreen(),
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of pages for bottom navigation
  static final List<Widget> _pages = <Widget>[
    const DashboardPage(),
    const TrainPage(),        // Train tab
    const HistoryScreen(),    // History tab
    const NutritionPage(),    // Nutrition tab
    const ProfilePage(),      // Profile tab
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        
        // File: lib/main.dart
        // Customize colors for legibility
        /*
        backgroundColor: Colors.white,            // white background
        selectedItemColor: Colors.deepPurple,     // active icon/text color
        unselectedItemColor: Colors.black54,      // inactive icon/text color
        */

        backgroundColor: Theme.of(context).colorScheme.surface,

        selectedItemColor: Theme.of(context).colorScheme.primary,

        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Train',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    
      floatingActionButton: Consumer<ActiveSession>(
    builder: (_, session, __) =>
      session.isActive ? const OngoingSessionFab() : const SizedBox.shrink(),
  ),

    );
  }
}
