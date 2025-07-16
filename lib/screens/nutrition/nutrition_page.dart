// File: lib/screens/nutrition_page.dart

// ignore_for_file: unused_local_variable, unused_element_parameter

import 'package:flutter/material.dart';
import '../../widgets/speed_dial_fab.dart';
import '../../widgets/nutrition_dash.dart';
import '../../widgets/health_trends_section.dart';
import '../../widgets/data_records_section.dart';
import '../../widgets/current_metrics_section.dart';




class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: replace with repo call or provider for today's date & stats
    final today = DateTime.now();
    final caloriesConsumed = 1200; // TODO
    final calorieGoal = 2000;      // TODO

    // TODO: wire in your real daily goals later
final proteinTarget = 100; // grams
final carbTarget    = 200; // grams
final fatTarget     =  70; // grams


    // TODO: replace with real macro values
    final proteinGrams = 80;
    final carbGrams = 150;
    final fatGrams = 60;

    // TODO: fetch actual meal entries for today
    final meals = [
      {'name': 'Breakfast', 'cal': 400, 'time': '8:00 AM'},
      {'name': 'Lunch',     'cal': 500, 'time': '12:30 PM'},
      {'name': 'Snack',     'cal': 300, 'time': '3:30 PM'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Dashboard')),
      body: SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
          // 1️⃣ Daily summary: date + two-line numeric tally
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),

// ─── Daily summary: date + two-line numeric tally ─────────────────
NutritionDash(
  caloriesConsumed: caloriesConsumed,
  calorieGoal: calorieGoal,
  proteinConsumed: proteinGrams,
  proteinTarget: proteinTarget,
  carbConsumed: carbGrams,
  carbTarget: carbTarget,
  fatConsumed: fatGrams,
  fatTarget: fatTarget,
),




    ],
  ),
),






const Divider(height: 25),

// ─── Health Trends ───────────────────────────────────


 const HealthTrendsSection(),



// ─── Data & Records ───────────────────────────────────
const DataRecordsSection(),

          // ─── Current Metrics ──────────────────────────────────
           CurrentMetricsSection(),
        ],
      ),
      ),
      // 4️⃣ Add new meal
       floatingActionButton: const SpeedDialFab(),

    );
  }
}


