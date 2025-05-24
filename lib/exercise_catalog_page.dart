// File: lib/exercise_catalog_page.dart

import 'package:flutter/material.dart';

class ExerciseCatalogPage extends StatefulWidget {
  const ExerciseCatalogPage({Key? key}) : super(key: key);
  @override
  _ExerciseCatalogPageState createState() => _ExerciseCatalogPageState();
}

class _ExerciseCatalogPageState extends State<ExerciseCatalogPage> {
  String _filterEquipment = 'All';
  String _filterArea = 'All';
  String _filterMuscle = 'All';

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        var selectedEquipment = _filterEquipment;
        var selectedArea = _filterArea;
        var selectedMuscle = _filterMuscle;
        return AlertDialog(
          title: const Text('Selected Filters'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Equipment dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Equipment'),
                value: selectedEquipment,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                ],
                onChanged: (v) {
                  if (v != null) selectedEquipment = v;
                },
              ),
              const SizedBox(height: 8),
              // Area of Focus dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Area of Focus'),
                value: selectedArea,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                ],
                onChanged: (v) {
                  if (v != null) selectedArea = v;
                },
              ),
              const SizedBox(height: 8),
              // Specific Muscle dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Specific Muscle'),
                value: selectedMuscle,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                ],
                onChanged: (v) {
                  if (v != null) selectedMuscle = v;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: apply filters to list
                setState(() {
                  _filterEquipment = selectedEquipment;
                  _filterArea = selectedArea;
                  _filterMuscle = selectedMuscle;
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Catalog'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search bar
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search exercises',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (q) {
                // TODO: filter search results
              },
            ),
            const SizedBox(height: 12),

            // Filters button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _openFilterDialog,
                icon: const Icon(Icons.filter_list),
                label: const Text('Filters'),
              ),
            ),
            const SizedBox(height: 16),

            // Previously Done
            const Text('Previously Done', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              flex: 1,
              child: ListView(
                children: const [
                  // TODO: replace with real list
                  ListTile(title: Text('Barbell Curl')),
                  ListTile(title: Text('Squat')),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // All Exercises
            const Text('All Exercises', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: ListView(
                children: const [
                  // TODO: replace with full exercise list
                  ListTile(title: Text('Bench Press')),
                  ListTile(title: Text('Deadlift')),
                  ListTile(title: Text('Overhead Press')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
