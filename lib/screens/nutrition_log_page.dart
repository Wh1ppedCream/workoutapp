// lib/screens/nutrition_log_page.dart
import 'package:flutter/material.dart';

class NutritionLogPage extends StatelessWidget {
  const NutritionLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Log')),
      body: const Center(child: Text('Nutrition Log content')),
    );
  }
}
