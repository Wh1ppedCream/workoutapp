// File: lib/widgets/speed_dial_fab.dart
// for logging food intake and measurements

import 'package:flutter/material.dart';
import '../screens/nutrition/food_logging_page.dart';
import '../screens/nutrition/measured_items_page.dart';

/// A toggleable FAB that expands into food and measurement actions.
///
/// Pass [onFoodLogged] / [onMeasurementLogged] to react after a successful log.
class SpeedDialFab extends StatefulWidget {
  final Future<void> Function()? onFoodLogged;
  final Future<void> Function()? onMeasurementLogged;

  const SpeedDialFab({super.key, this.onFoodLogged, this.onMeasurementLogged});

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
              onPressed: () async {
                _toggle();
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const FoodLoggingPage()),
                );
                if (!mounted) return;
                if (changed == true) {
                  await widget.onFoodLogged?.call();
                }
              },
            ),
            const SizedBox(height: 8),
            FloatingActionButton.extended(
              heroTag: 'log_measurement',
              icon: const Icon(Icons.straighten),
              label: const Text('Log Measurement'),
              onPressed: () async {
                _toggle();
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const MeasuredItemsPage()),
                );
                if (!mounted) return;
                if (changed == true) {
                  await widget.onMeasurementLogged?.call();
                }
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
