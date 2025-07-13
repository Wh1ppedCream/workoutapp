// File: lib/widgets/quick_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/active_session.dart';
import '../screens/nutrition/new_measurement_item_page.dart';
import '../screens/nutrition/food_logging_page.dart';
import '../screens/exercise/session_screen.dart';

/// A three-section quick-action bar:
/// 1️⃣ +Measurement (navigates to NewMeasurementItemPage)
/// 2️⃣ +Food        (navigates to FoodLoggingPage)
/// 3️⃣ +Workout     (starts a new session and navigates to SessionScreen)
///
/// Each segment has its own color. Pass [scale] to resize.
class QuickBar extends StatelessWidget {
  /// Uniform scale factor for padding, heights, and border radii.
  final double scale;

  const QuickBar({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Colors.grey.shade400;
    final segmentHeight = 40 * scale;
    final borderRadius = BorderRadius.circular(24 * scale);
    final padding = EdgeInsets.symmetric(vertical: 12 * scale);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(borderRadius: borderRadius),
      child: Row(
        children: [
          // +Measurement
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(24 * scale),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(24 * scale),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const NewMeasurementItemPage()),
                  );
                },
                child: Padding(
                  padding: padding,
                  child: SizedBox(
                    height: segmentHeight,
                    child: Center(
                      child: Text(
                        '+ Measurement',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Divider
          Container(
            width: 1 * scale,
            height: segmentHeight,
            color: dividerColor,
          ),

          // +Food
          Expanded(
            child: Container(
              color: Colors.orange.shade100,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const FoodLoggingPage()),
                  );
                },
                child: Padding(
                  padding: padding,
                  child: SizedBox(
                    height: segmentHeight,
                    child: Center(
                      child: Text(
                        '+ Food',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Divider
          Container(
            width: 1 * scale,
            height: segmentHeight,
            color: dividerColor,
          ),

          // +Workout
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(24 * scale),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(24 * scale),
                ),
                onTap: () {
                  final session = context.read<ActiveSession>();
                  session.start();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SessionScreen()),
                  );
                },
                child: Padding(
                  padding: padding,
                  child: SizedBox(
                    height: segmentHeight,
                    child: Center(
                      child: Text(
                        '+ Workout',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
