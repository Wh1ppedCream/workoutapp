//for logging food intake and measurements

// File: lib/widgets/speed_dial_fab.dart

import 'package:flutter/material.dart';
import '../screens/nutrition/food_logging_page.dart';
import '../screens/nutrition/new_measurement_item_page.dart';

/// A toggleable FAB that expands into two actions:
/// • Log Food → FoodLoggingPage  
/// • Log Measurement → NewMeasurementItemPage
class SpeedDialFab extends StatefulWidget {
  const SpeedDialFab({super.key});

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab> {
  bool _open = false;
  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_open) ...[
            FloatingActionButton.extended(
              heroTag: 'log_food',
              icon: const Icon(Icons.restaurant),
              label: const Text('Log Food'),
              onPressed: () {
                _toggle();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FoodLoggingPage()),
                );
              },
            ),
            const SizedBox(height: 8),
            FloatingActionButton.extended(
              heroTag: 'log_measurement',
              icon: const Icon(Icons.straighten),
              label: const Text('Log Measurement'),
              onPressed: () {
                _toggle();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NewMeasurementItemPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
          FloatingActionButton(
            heroTag: 'toggle',
            onPressed: _toggle,
            child: AnimatedRotation(
              turns: _open ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
