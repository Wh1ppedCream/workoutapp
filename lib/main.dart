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

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActiveSession()),
        ChangeNotifierProvider(create: (_) => SelectedProfile()),
        ChangeNotifierProvider(create: (_) => DashboardConfig()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'Fitness Tracker',
  theme: ThemeData.from(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  ),
  // old code: home: const MainScreen(),
  // TODO: Replace with conditional logic to show onboarding only once
      home: const OnboardingFlow(),
      // TODO: After onboarding completes, navigate to MainScreen
      routes: {
        '/main': (_) => const MainScreen(),
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
        backgroundColor: Colors.white,            // white background
        selectedItemColor: Colors.deepPurple,     // active icon/text color
        unselectedItemColor: Colors.black54,      // inactive icon/text color
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
