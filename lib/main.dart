// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/active_session.dart';
import 'providers/selected_profile.dart';
import 'providers/dashboard_config.dart';
import 'providers/theme_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/nav_bar_config.dart';
import 'providers/nutrition_profile.dart';

import 'screens/dashboard_page.dart';
import 'screens/exercise/history_screen.dart';
import 'screens/exercise/train_page.dart';          
import 'screens/nutrition/nutrition_page.dart';
import 'screens/profile/settings/profile_page.dart';
import 'screens/onboarding_flow.dart'; // New import for onboarding
import 'screens/measurement_trends_page.dart';
import 'screens/nutrition_log_page.dart';
import 'screens/combined_history_page.dart';
import 'screens/form_posing_page.dart';

import 'widgets/ongoing_session_fab.dart';

import '../theme/app_colors.dart';

import 'repositories/app_repository.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NutritionProfile()),
        Provider<AppRepository>(create: (_) => AppRepository()),
        ChangeNotifierProvider(create: (_) => OnboardingConfig()..init()),
        ChangeNotifierProvider(create: (_) => ActiveSession()),
        ChangeNotifierProvider(create: (_) => SelectedProfile()),
        ChangeNotifierProvider(create: (_) => DashboardConfig()),
       ChangeNotifierProvider(create: (_) => ThemeProvider()),
       ChangeNotifierProvider(create: (_) => NavBarConfig()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, OnboardingConfig>(
      builder: (context, themeProv, onboardingConf, _) {
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

  sheetBackground: Colors.white,              // light-mode bottom sheets
  buttonBg: Colors.deepPurple,                // light-mode button bg
  buttonText: Colors.white,                   // light-mode button text
  flowChartBackground: Color.fromARGB(255, 255, 255, 255),     // blackish
      flowChartGrid:       Color.fromARGB(102, 43, 42, 42),     // 40%-opaque white

// ── new flow-chart defaults ───────────────────
  flowNodeBg:              Color(0xFFFFFFFF),
  flowNodeBorder:          Color.fromARGB(255, 93, 188, 226),
  flowNodeText:            Color(0xFF333333),
  flowArrowSuccess:        Color(0xFF2E7D32),
  flowArrowFailure:        Color(0xFFC62828),
  flowArrowLoopback:       Color(0xFF757575),

  metricAddBorderColor: Colors.deepPurple, // light-mode border color
  metricAddIconColor: Colors.deepPurpleAccent, // light-mode icon color

  genericBarAccent: Color(0xFF6200EE),  // your current light-mode border/text color

  presetBadgeBg: Color.fromARGB(255, 78, 218, 65), // light-mode badge background
  presetBadgeText: Colors.white,    // light-mode badge text color

  mealPlanPantryLogBg:  Color(0xFFFFF9C4), // yellow.shade100
  mealPlanAddMealBg:    Color(0xFFC8E6C9), // green.shade100
  mealPlanPlanMealBg:   Color(0xFFBBDEFB), // blue.shade100
  mealPlanDivider:      Color(0xFFBDBDBD), // grey.shade400

   healthTrendBorder: Color(0xFFE0E0E0), // grey.shade300
  healthTrendIcon:   Color(0xFF757575), // grey.shade600 (matches your existing grey icon)
  healthTrendLine:   Colors.purple, // purple line for health trends

  nutritionCalorieBar: Color.fromARGB(255, 67, 160, 71), // calorie bar color
  nutritionProteinBar: Color.fromARGB(255, 30, 136, 229), // protein bar color
  nutritionCarbBar: Color.fromARGB(255, 255, 140, 0), // carb bar color
  nutritionFatBar: Color.fromARGB(255, 229, 57, 53), // fat bar color

  nutritionCalorieCircle: Color.fromARGB(255, 67, 160, 71), // calorie circle color
  nutritionProteinCircle: Colors.purple, // protein circle color
  nutritionCarbCircle: Color.fromARGB(255, 30, 136, 229), // carb circle color
  nutritionFatCircle: Color.fromARGB(255, 255, 140, 0), // fat circle color

  nutritionTextDetailsBorder: Color.fromARGB(255, 223, 223, 223), // border color for text details

  nutritionPageIndicatorActive:   Colors.purple,
nutritionPageIndicatorInactive: Color(0xFFBDBDBD), // grey.shade400

workoutStartBg:   Color(0xFF4CAF50), // light green
  workoutStartText: Colors.white,

  dataRecordsTodayBg:         Color(0x33388E3C), // green.shade600 @20% opacity
  dataRecordsTodayBorder:     Color(0xFF388E3C), // green.shade600
  dataRecordsTodayText:       Color(0xFF388E3C),
  dataRecordsDefaultBorder:   Color(0xFFBDBDBD), // grey.shade400
  dataRecordsChevron:         Color(0xFF757575), // grey.shade600

  pastSessionsProgress:  Color(0xFF6200EE), // e.g. your primary
  pastSessionsIcon:      Color(0xFF6200EE),
  pastSessionsDivider:   Color(0xFFBDBDBD), // grey.shade400

  historySummaryProgress:      Color(0xFF6200EE),
historySummaryHeatmapLow:    Color.fromARGB(255, 224, 224, 224),
historySummaryHeatmapHigh:   Color(0xFF1565C0), // blue.shade800


infoCardBackground: Color(0xFFFFFFFF),
  infoCardValueText:  Color(0xFF000000),
  infoCardLabelText:  Color(0xFF757575), // grey.shade600
  infoCardShadow:     Color(0x22000000), // black12




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

  sheetBackground: Color(0xFF303030), // dark grey for bottom sheets
  buttonBg: Colors.deepPurple, // darker purple for buttons
  buttonText: Colors.white, // white text for contrast
  flowChartBackground: Color(0xFF121212),     // blackish
      flowChartGrid:       Color(0x66FFFFFF),     // 40%-opaque white

  // ── new flow-chart defaults ───────────────────
  flowNodeBg:              Color(0xFF1E1E1E),
  flowNodeBorder:          Color.fromARGB(255, 34, 55, 245),
  flowNodeText:            Color(0xFFE0E0E0),
  flowArrowSuccess:        Color(0xFF66BB6A),
  flowArrowFailure:        Color(0xFFEF5350),
  flowArrowLoopback:       Color(0xFF757575),

  metricAddBorderColor: Colors.deepPurpleAccent, // dark-mode border color
  metricAddIconColor: Colors.deepPurple, // dark-mode icon color

  genericBarAccent: Color(0xFFBB86FC),  // your chosen dark-mode accent

  presetBadgeBg: Color.fromARGB(255, 78, 218, 65), // dark-mode badge background
  presetBadgeText: Colors.blueGrey,    // dark-mode badge text color

  mealPlanPantryLogBg:  Color(0xFF4E4E1A), // dark yellow
  mealPlanAddMealBg:    Color(0xFF2E4E2E), // dark green
  mealPlanPlanMealBg:   Color(0xFF1A2E4E), // dark blue
  mealPlanDivider:      Color(0xFF616161), // grey.shade700

  healthTrendBorder: Color(0xFF616161), // grey.shade700
  healthTrendIcon:   Color(0xFFBDBDBD), // grey.shade400
  healthTrendLine:   Colors.purple, // purple line for health trends

  nutritionCalorieBar: Color.fromARGB(255, 102, 187, 106), // dark green for calorie bar
  nutritionProteinBar: Color.fromARGB(255, 66, 165, 245), // dark blue for protein bar
  nutritionCarbBar: Color.fromARGB(255, 255, 167, 38), // dark orange for carb bar
  nutritionFatBar: Color.fromARGB(255, 239, 83, 80), // dark red for fat bar

  nutritionCalorieCircle: Color.fromARGB(255, 102, 187, 106), // dark green for calorie circle
  nutritionProteinCircle: Color.fromARGB(255, 181, 60, 202), // dark purple for protein circle
  nutritionCarbCircle: Color.fromARGB(255, 66, 165, 245), // dark blue for carb circle
  nutritionFatCircle: Color.fromARGB(255, 255, 167, 38), // dark orange for fat circle

  nutritionTextDetailsBorder: Color.fromARGB(255, 100, 100, 100), // dark grey for text details border

  nutritionPageIndicatorActive:   Colors.purple,
nutritionPageIndicatorInactive: Color(0xFF757575), // grey.shade600

workoutStartBg:   Color(0xFF81C784), // lighter green for dark
  workoutStartText: Colors.black,

  dataRecordsTodayBg:         Color(0x2281C784), // green.shade300 @20% opacity
  dataRecordsTodayBorder:     Color(0xFF81C784), // green.shade300
  dataRecordsTodayText:       Color(0xFF81C784),
  dataRecordsDefaultBorder:   Color(0xFF616161), // grey.shade700
  dataRecordsChevron:         Color(0xFFBDBDBD), // grey.shade400

  pastSessionsProgress:  Color(0xFFBB86FC),
  pastSessionsIcon:      Color(0xFFBB86FC),
  pastSessionsDivider:   Color(0xFF616161), // grey.shade700

  historySummaryProgress:      Color(0xFFBB86FC),
historySummaryHeatmapLow:    Color.fromARGB(255, 161, 161, 161),
historySummaryHeatmapHigh:   Color(0xFF1565C0), // blue.shade800

infoCardBackground: Color(0xFF222222),
  infoCardValueText:  Color(0xFFE0E0E0), // grey.shade300
  infoCardLabelText:  Color(0xFFBDBDBD), // grey.shade400
  infoCardShadow:     Color(0x66000000), // black40


              // add other dark-mode overrides here…
            ),
          ],
        );

        return MaterialApp(
          title: 'Fitness Tracker',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProv.mode,


      home: (onboardingConf.alwaysShow || !onboardingConf.completed)
      ? const OnboardingFlow()
      : const MainScreen(),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navConfig = context.watch<NavBarConfig>();

    // 1) While loading, show a spinner
    if (!navConfig.loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2) Grab the *current* list of tabs & pages
    final tabs = navConfig.items;
    final pages = tabs.map((tab) {
      switch (tab) {
        case TabItem.dashboard:
          return const DashboardPage();
        case TabItem.train:
          return const TrainPage();
        case TabItem.history:
          return const HistoryScreen();
        case TabItem.nutrition:
          return const NutritionPage();
        case TabItem.profile:
          return const ProfilePage();
        case TabItem.measurementsTrends:
          return const MeasurementsTrendsPage();
        case TabItem.nutritionLog:
          return const NutritionLogPage();
        case TabItem.combinedHistory:
          return const CombinedHistoryPage();
        case TabItem.formAndPosing:
          return const FormPosingPage();
      }
    }).toList();

    // 3) If the current index is now too big, clamp it
    if (_selectedIndex >= pages.length) {
      _selectedIndex = pages.length - 1;
    }

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        items: [
          for (final tab in tabs)
            BottomNavigationBarItem(
              icon: Icon(tab.icon),
              label: tab.bottomLabel,     // ← use short label
            )
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
