// train_page.dart

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
    final drawerWidth = MediaQuery.of(context).size.width * 0.75;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        width: drawerWidth,
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'To be added',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ListTile(title: Text('Option A')),
            ListTile(title: Text('Option B')),
            ListTile(title: Text('Option C')),
          ],
        ),
      ),
      endDrawer: Drawer(
        width: drawerWidth,
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightGreen),
              child: Text(
                'Gym Profiles',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ListTile(title: Text('General')),
            ListTile(title: Text('Commercial Gym')),
            ListTile(title: Text('Home Gym')),
          ],
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
              child: Text(
                'P',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Exercise Presets',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(height: 24),
                    const _PresetBar(label: 'Push'),
                    const SizedBox(height: 8),
                    const _PresetBar(label: 'Pull'),
                    const SizedBox(height: 8),
                    const _PresetBar(label: 'Legs'),
                    const SizedBox(height: 16),
                    const Divider(height: 24),
                    const _PresetBar(label: 'Generate Custom Presets'),
                  ],
                ),
              ),
            ),
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
      ),
    );
  }
}

/// Reusable bar widget
class _PresetBar extends StatelessWidget {
  final String label;
  const _PresetBar({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // TODO: handle preset tap
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}