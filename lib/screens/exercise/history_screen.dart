// File: lib/screens/exercise/history_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/history_content.dart';
import '../../widgets/drawers.dart';  

/// Displays the list of past workout sessions and navigation to filters.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar( 
        title: const Text('Workout Log'),
        centerTitle: true,
      ),
      body: HistoryContent(
        onReload: () => setState(() {}),
      ),
    );
  }
}
