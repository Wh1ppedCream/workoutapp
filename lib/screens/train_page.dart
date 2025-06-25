// File: lib/screens/train_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'session_screen.dart';
import '../models/active_session.dart';
import '../widgets/preset_bar.dart';
import 'preset_detail_screen.dart';
import '../models/preset_session.dart';
import '../repositories/app_repository.dart';
import '../repositories/app_repository_presets.dart';

class TrainPage extends StatefulWidget {
  const TrainPage({super.key});

  @override
  State<TrainPage> createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final drawerWidth = MediaQuery.of(context).size.width * 0.75;

    return Consumer<ActiveSession>(
      builder: (_, session, __) => Stack(
        children: [
          Scaffold(
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
                          PresetBar(
                            label: 'Push',
                            color: Colors.blue,
                            index: 0,
                            onTap: () async {
                              final navigator = Navigator.of(context);
                              final repo = AppRepository();
                              final presetId = await repo.findOrCreatePreset('Push');
                              if (!mounted) return;
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider(
                                    create: (_) => PresetSession(presetId),
                                    child: const PresetDetailScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          PresetBar(
                            label: 'Pull',
                            color: Colors.orange,
                            index: 1,
                            onTap: () async {
                              final navigator = Navigator.of(context);
                              final repo = AppRepository();
                              final presetId = await repo.findOrCreatePreset('Pull');
                              if (!mounted) return;
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider(
                                    create: (_) => PresetSession(presetId),
                                    child: const PresetDetailScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          PresetBar(
                            label: 'Legs',
                            color: Colors.green,
                            index: 2,
                            onTap: () async {
                              final navigator = Navigator.of(context);
                              final repo = AppRepository();
                              final presetId = await repo.findOrCreatePreset('Legs');
                              if (!mounted) return;
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider(
                                    create: (_) => PresetSession(presetId),
                                    child: const PresetDetailScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 24),
                          const _PresetBar(label: 'Generate Custom Presets'),
                          const SizedBox(height: 8),
                          const _PresetBar(label: 'Manually Add Preset'),
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
                          context.read<ActiveSession>().start();
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
    return Material(
      color: color.withAlpha(25),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // TODO: implement preset tap navigation (wrap in Provider & navigate to PresetDetailScreen)
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
