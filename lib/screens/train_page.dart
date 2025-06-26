// File: lib/screens/train_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/active_session.dart';
import '../models/preset_models.dart';
import '../models/preset_session.dart';
import '../models/selected_profile.dart';
import '../repositories/app_repository.dart';
import '../repositories/app_repository_presets.dart';
import '../repositories/profile_repository.dart';
import '../widgets/preset_bar.dart';
import 'gym_profile_screen.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Ensure default presets exist for the selected profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileId = context.read<SelectedProfile>().currentProfile?.id;
      _ensureDefaults(profileId);
    });
  }

  Future<void> _ensureDefaults(int? profileId) async {
    await _repo.findOrCreatePreset('Push', profileId: profileId);
    await _repo.findOrCreatePreset('Pull', profileId: profileId);
    await _repo.findOrCreatePreset('Legs', profileId: profileId);
    setState(() {});
  }

  /// Deletes a preset and refreshes the list.
  Future<void> _deletePreset(int presetId) async {
    await _repo.deletePreset(presetId);
    setState(() {});
  }

  /// Opens the preset detail screen.
  void _openPreset(int presetId, {bool edit = false}) {
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute(
        builder: (outerCtx) => MultiProvider(
          providers: [
            ChangeNotifierProvider<ActiveSession>.value(
              value: outerCtx.read<ActiveSession>(),
            ),
            ChangeNotifierProvider(
              create: (_) => PresetSession(presetId),
            ),
          ],
          child: PresetDetailScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth = MediaQuery.of(context).size.width * 0.75;

    return Consumer2<ActiveSession, SelectedProfile>(
      builder: (_, session, sel, __) => Scaffold(
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
          child: Consumer<SelectedProfile>(
            builder: (ctx, selected, _) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.lightGreen),
                    child: Text('Gym Profiles',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  ...List.generate(
                    selected.profiles.length,
                    (i) {
                      final profile = selected.profiles[i];
                      final color = _palette[i % _palette.length];
                      return PresetBar(
                        label: profile.name,
                        color: color,
                        index: i,
                        onTap: () {
                          selected.selectProfile(profile);
                          Navigator.of(context).pop();
                          setState(() {});
                        },
                        onMenuSelected: (action) {
                          if (action == 'edit') {
                            final navigator = Navigator.of(context);
                            navigator.pop();
                            navigator.push(
                              MaterialPageRoute(
                                builder: (_) => GymProfileScreen(
                                  profile: profile,
                                ),
                              ),
                            );
                          } else if (action == 'delete') {
                            selected.deleteProfile(profile.id!);
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('New Profile'),
                    onTap: () {
                      final navigator = Navigator.of(context);

    
                      navigator.pop();
                      navigator.push(
                        MaterialPageRoute(
                          builder: (_) => const GymProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Exercise Presets',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<PresetDefinition>>(
                  future: _repo
                      .fetchAllPresetsRaw(profileId: sel.currentProfile?.id)
                      .then((raw) => raw
                          .map((r) => PresetDefinition(
                                id: r['id'] as int,
                                name: r['name'] as String,
                                createdAt: DateTime.parse(
                                    r['created_at'] as String),
                              ))
                          .toList()),
                  builder: (ctx, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final presets = snap.data!;
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
              const Divider(height: 1),
              const SizedBox(height: 8),
              PresetBar(
                label: 'Generate Custom Presets',
                color: Colors.purple,
                index: 0,
              ),
              const SizedBox(height: 8),
              PresetBar(
                label: 'Manually Add Preset',
                color: Colors.purple,
                index: 0,
                onTap: () async {
                  final newId = await _repo.createPreset(
                    'New Preset',
                    profileId: sel.currentProfile?.id,
                  );
                  _openPreset(newId, edit: true);
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    session.start();
                    final navigator = Navigator.of(context);
    navigator.push(
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
