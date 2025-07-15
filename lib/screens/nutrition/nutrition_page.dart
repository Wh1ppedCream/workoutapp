// File: lib/screens/nutrition_page.dart

// ignore_for_file: unused_local_variable, unused_element_parameter

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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


 HealthTrendsSection(
   caloriesConsumed: caloriesConsumed,
   calorieGoal:      calorieGoal,   // TODO: wire actual remaining or total
   expenditureSpots: const [
    FlSpot(0, 50), FlSpot(1, 60), FlSpot(2, 55),
    FlSpot(3, 70), FlSpot(4, 65), FlSpot(5, 80),
    FlSpot(6, 75),
  ], // TODO: replace with real 7-day spots
   weightSpots: const [
    FlSpot(0, 210), FlSpot(1, 211), FlSpot(2, 211.5),
    FlSpot(3, 212), FlSpot(4, 211.8), FlSpot(5, 212.2),
    FlSpot(6, 211.9),
    ],// TODO: replace with real 7-day weight spots
   weightValue: '211.9 lbs',// TODO: wire actual current weight
 ),




// ─── Data & Records ───────────────────────────────────
const DataRecordsSection(),

          // ─── Current Metrics ──────────────────────────────────
           CurrentMetricsSection(
   lastMeasured:   today,
   bodyFat:        '26.0 %',
   waist:          '27 in',
   hips:           '36 in',
   daysAgo:        0,
 ),
        ],
      ),
      ),
      // 4️⃣ Add new meal
       floatingActionButton: const SpeedDialFab(),

    );
  }
}


