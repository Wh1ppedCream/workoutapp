<<<<<<<< HEAD:lib/screens/measured_items_page.dart
//measured_items_page.dart

import 'package:flutter/material.dart';
import '../repositories/app_repository.dart';
import '../models/models.dart';
========
// File: lib/screens/nutrition/measured_items_page.dart

import 'package:flutter/material.dart';
import '../../repositories/app_repository.dart';
import '../../models/models.dart';
>>>>>>>> feature/ui-redesign:lib/screens/nutrition/measured_items_page.dart
import 'new_measurement_item_page.dart';
import 'specific_measurement_page.dart';

class MeasuredItemsPage extends StatefulWidget {
  const MeasuredItemsPage({super.key});
  @override
  State<MeasuredItemsPage> createState() => _MeasuredItemsPageState();
}

class _MeasuredItemsPageState extends State<MeasuredItemsPage> {
  final _repo = AppRepository();
  late Future<List<MeasurementDefinition>> _defsFuture;

  @override
  void initState() {
    super.initState();
    _defsFuture = _repo.fetchUsedClassMeasurementDefinitions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Measured Items')),
      body: FutureBuilder<List<MeasurementDefinition>>(
  future: _defsFuture,
  builder: (ctx, snap) {
    if (snap.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }
    // Safely unwrap data or default to empty list
    final defs = snap.data ?? [];

    // Otherwise, show the list plus the "Track a New Measurement" tile
    return ListView(
      children: [
        for (var def in defs)
          ListTile(
            title: Text(def.name),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SpecificMeasurementPage(definition: def),
              ),
            ),
          ),

        // Spacer for visual separation if defs exist
            if (defs.isNotEmpty) const Divider(),

        const SizedBox(height: 20),
        ListTile(
          tileColor: Colors.deepPurple,
              textColor: Colors.white,
              title: const Text('Track a New Measurement'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NewMeasurementItemPage()),
              ),
        ),
      ],
    );
  },
),

    );
  }
}
