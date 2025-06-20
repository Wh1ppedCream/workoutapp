// File: lib/main.dart

import 'package:flutter/material.dart';
import 'screens/history_screen.dart';
import 'screens/train_page.dart';          
import 'screens/nutrition_page.dart';
import 'screens/profile_page.dart';   
import 'models/active_session.dart';
import 'package:provider/provider.dart';  // For ChangeNotifierProvider

void main() {
runApp(
    ChangeNotifierProvider(
      create: (_) => ActiveSession(),
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
      home: const MainScreen(),  // Use bottom navigation
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
    );
  }
}
