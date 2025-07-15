// file: lib/screens/exercise/history_screen.dart

import 'package:flutter/material.dart';
import 'exercise_catalog_page.dart';
import 'muscle_filter_page.dart';
import '../../widgets/history_summary_widget.dart';
import 'analytics_dashboard_screen.dart';
import '../../widgets/past_sessions_list.dart';


/// Displays the list of past workout sessions and navigation to filters.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          // Filter navigation buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ExerciseCatalogPage()),
                    );
                  },
                  child: const Text('Exercises'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MuscleFilterPage()),
                    );
                  },
                  child: const Text('Muscle'),
                ),
              ],
            ),
          ),
          
          // ─── 7-day Summary ────────────────────────────────
          // ⬇️ History summary panel
              const HistorySummaryWidget(),

          // ─── Analytics Dashboard button ───────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.analytics),
              label: const Text('View 7-Day Analytics'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const AnalyticsDashboardScreen()),
                );
              },
            ),
          ),
              
          
          // Session list
          

          Expanded(
            child: PastSessionsList(onReload: () => setState(() {}))
            
            
          
          ),
        ],
      ),
    );
  }
}
