// File: lib/screens/exercise/train_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/active_session.dart';
import '../../models/preset_models.dart';
import '../../providers/preset_session.dart';
import '../../providers/selected_profile.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/preset_bar.dart';
import '../../widgets/generic_bar.dart';
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


  int? _lastProfileId;
@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // whenever SelectedProfile.currentProfile changes, ensure our defaults
    final sel = context.watch<SelectedProfile>();
    final pid = sel.currentProfile?.id;
    if (pid != null && pid != _lastProfileId) {
      _lastProfileId = pid;
      _ensureDefaults(pid);
    }
  }


  Future<void> _ensureDefaults(int? profileId) async {
    if (profileId == null) return;

  // 1. See if this profile already has any presets
  final existing = await _repo.fetchAllPresetsRaw(profileId: profileId);
  if (existing.isNotEmpty) return;  // nothing to do

    await _repo.findOrCreatePreset('Preset 1', profileId: profileId);
    await _repo.findOrCreatePreset('Preset 2', profileId: profileId);
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
            child: Text(
              'Gym Profiles',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          // ← Replace this block:
          // ...List.generate(selected.profiles.length, (i) {
          //   final profile = selected.profiles[i];
          //   final color = _palette[i % _palette.length];
          //   return PresetBar( … );
          // }),

          // → With this:
          ...selected.profiles
    .asMap()
    .entries
    .map((entry) {
      final i = entry.key;
      final profile = entry.value;
      final color = _palette[i % _palette.length];
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),    // light background
          border: Border.all(color: color, width: 1), // colored border
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Radio<int>(
            value: profile.id!,
            groupValue: selected.currentProfile?.id,
            onChanged: (newId) {
              if (newId == null) return;
              selected.selectProfile(profile);
              Navigator.of(context).pop();
              setState(() {});
            },
          ),
          title: Text(profile.name),
          trailing: PopupMenuButton<String>(
            onSelected: (action) {
              Navigator.of(context).pop();
              if (action == 'edit') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GymProfileScreen(profile: profile),
                  ),
                );
              } else if (action == 'delete') {
                selected.deleteProfile(profile.id!);
                setState(() {});
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ),
      );
    })
    ,
          const Divider(),

          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New Profile'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GymProfileScreen()),
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
                    if (snap.hasError) {
      return Text('Error: ${snap.error}');
    }
                    final presets = snap.data!;
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: presets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final p = presets[i];
                        final color = _palette[i % _palette.length];
                        return FutureBuilder<Map<String, dynamic>?>(
  future: _repo.fetchPresetAutoSettings(p.id),
  builder: (ctx2, autoSnap) {
    final isAuto = autoSnap.connectionState == ConnectionState.done
        && (autoSnap.data?['is_automatic'] as int? ?? 0) == 1;

    return PresetBar(
  presetId:   p.id,
  label:      p.name,
  color:      color,
  index:      i,
  isAutomatic: isAuto,
  onRefresh:  () => setState(() {}),
);

  },
);

                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 8),
              GenericBar(
  label: 'Generate Custom Presets',
  color: Colors.purple,
  onTap: null, // or supply a callback if you want it tappable
),
              const SizedBox(height: 8),
              GenericBar(
  label: 'Manually Add Preset',
  color: Colors.purple,
  onTap: () async {
    final profileId = sel.currentProfile?.id;
    // 1) Fetch existing presets for this profile
    final existing = await _repo.fetchAllPresetsRaw(profileId: profileId);
    // 2) Derive a unique name
    final nextNum = existing.length + 1;
    final name = nextNum == 1 ? 'New Preset' : 'New Preset $nextNum';
    // 3) Create it
    final newId = await _repo.createPreset(name, profileId: profileId);
    // 4) Open in edit mode
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
