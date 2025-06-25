// File: lib/screens/train_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/active_session.dart';
import '../models/preset_models.dart';
import '../models/preset_session.dart';
import '../repositories/app_repository.dart';
import '../repositories/app_repository_presets.dart';
import '../widgets/preset_bar.dart';
import 'preset_detail_screen.dart';
import 'session_screen.dart';

class TrainPage extends StatefulWidget {
  const TrainPage({super.key});

  @override
  State<TrainPage> createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  static const _palette = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
  ];

  final _repo = AppRepository();
  late Future<List<PresetDefinition>> _presetsFuture;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _ensureDefaults();
    _loadPresets();
  }

  /// Make sure our three defaults exist at least once.
  Future<void> _ensureDefaults() async {
    await _repo.findOrCreatePreset('Push');
    await _repo.findOrCreatePreset('Pull');
    await _repo.findOrCreatePreset('Legs');
  }

  /// Reloads the future for all presets.
  void _loadPresets() {
    _presetsFuture = _repo
        .fetchAllPresetsRaw()
        .then((raw) => raw.map((r) {
              return PresetDefinition(
                id: r['id'] as int,
                name: r['name'] as String,
                createdAt: DateTime.parse(r['created_at'] as String),
              );
            }).toList());
  }

  /// Convenience: calls setState(&_loadPresets).
  void _refresh() => setState(_loadPresets);

  /// Navigate into the detail screen for [presetId].
  void _openPreset(int presetId, {bool edit = false}) {
    final navigator = Navigator.of(context);

    navigator.push(
      MaterialPageRoute(
        builder: (outerCtx) => MultiProvider(
          providers: [
            // Re-use the same ActiveSession
            ChangeNotifierProvider<ActiveSession>.value(
              value: outerCtx.read<ActiveSession>(),
            ),
            // New PresetSession
            ChangeNotifierProvider(
              create: (_) => PresetSession(presetId),
            ),
          ],
          child: PresetDetailScreen(
            // if you add a 'startEditing' flag to the screen, you can pass edit:true here
          ),
        ),
      ),
    );
  }

  /// Delete a preset and refresh the list.
  Future<void> _deletePreset(int presetId) async {
    await _repo.deletePreset(presetId);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth = MediaQuery.of(context).size.width * 0.75;
    int presetCount = 0;

    return Consumer<ActiveSession>(
      builder: (_, session, __) => Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          width: drawerWidth,
          child: ListView(
            padding: EdgeInsets.zero,
            children: const [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.deepPurple),
                child: Text('To be added',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
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
                child: Text('Gym Profiles',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
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
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
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
              // --- Presets list header ---
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Exercise Presets',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              // --- Dynamic presets + static last two bars ---
              Expanded(
                child: FutureBuilder<List<PresetDefinition>>(
                  future: _presetsFuture,
                  builder: (ctx, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final presets = snap.data!;
                    presetCount = presets.length;
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: presets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final p = presets[i];
                        final color = _palette[i % _palette.length];
                        return PresetBar(
                          label: p.name,
                          color: color,
                          index: i,
                          onTap: () => _openPreset(p.id),
                          onMenuSelected: (action) {
                            if (action == 'edit') {
                              _openPreset(p.id, edit: true);
                            } else if (action == 'delete') {
                              _deletePreset(p.id);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // ← INSERT THIS DIVIDER
              const Divider(height: 1),
              const SizedBox(height: 8),

              // “Generate Custom Presets” (no-op for now)
              PresetBar(
                label: 'Generate Custom Presets',
                color: Colors.purple,
                index: 0,
              ),
              const SizedBox(height: 8),

              // “Manually Add Preset”
              PresetBar(
                label: 'Manually Add Preset',
                color: Colors.purple,
                index: presetCount,
                onTap: () async {
                  final newId = await _repo.createPreset('New Preset');
                  _refresh();
                  _openPreset(newId, edit: true);
                },
              ),

              const SizedBox(height: 16),

              // --- New Session button ---
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    session.start();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SessionScreen(),
                      ),
                    );
                  },
                  child: const Text('New Session'),
                ),
              ),
            ],
          ),
        ),
      
      
      ),
    );
  }
}
