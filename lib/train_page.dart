// File: lib/train_page.dart

import 'package:flutter/material.dart';
import 'session_screen.dart';

class TrainPage extends StatefulWidget {
  const TrainPage({super.key});

  @override
  _TrainPageState createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // Left drawer (hamburger)
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: const [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.deepPurple),
                child: Text('To be added', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              ListTile(title: Text('Option A')),
              ListTile(title: Text('Option B')),
              ListTile(title: Text('Option C')),
            ],
          ),
        ),
      ),

      // Right drawer (P avatar)
      endDrawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: const [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.lightGreen),
                child: Text('Gym Profiles', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              ListTile(title: Text('General')),
              ListTile(title: Text('Commercial Gym')),
              ListTile(title: Text('Home Gym')),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Train'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.lightGreen,
              child: Text('P', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          // Presets header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Exercise Presets', style: Theme.of(context).textTheme.titleLarge),
          ),
          const Divider(height: 24),

          // Preset bars
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: const [
                _PresetBar(label: 'Push'),
                SizedBox(height: 8),
                _PresetBar(label: 'Pull'),
                SizedBox(height: 8),
                _PresetBar(label: 'Legs'),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 24),

          // Generate Custom Presets
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const _PresetBar(label: 'Generate Custom Presets'),
          ),

          const Spacer(),

          // New Session button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SessionScreen()),
                  );
                },
                child: const Text('New Session'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable bar widget
class _PresetBar extends StatelessWidget {
  final String label;
  const _PresetBar({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return InkWell(
      onTap: () {
        // TODO: handle preset tap
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 16, color: color, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
