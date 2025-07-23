// File: lib/screens/exercise/train_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/active_session.dart';
import '../../providers/preset_session.dart';
import '../../providers/selected_profile.dart';
import '../../repositories/app_repository.dart';

import '../../widgets/generic_bar.dart';
import '../../widgets/presets_loaded.dart';
import '../../widgets/drawers.dart';

import 'gym_profile_screen.dart';
import 'preset_detail_screen.dart';
import 'session_screen.dart';
import 'preset_generation_qa.dart';


import '../../widgets/history_content.dart';

class TrainPage extends StatefulWidget {
  const TrainPage({super.key});

  @override
  State<TrainPage> createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  final _repo = AppRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _lastProfileId;
  int _selectedTab = 0; // 0 = Train, 1 = History

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sel = context.watch<SelectedProfile>();
    final pid = sel.currentProfile?.id;
    if (pid != null && pid != _lastProfileId) {
      _lastProfileId = pid;
      _ensureDefaults(pid);
    }
  }

  Future<void> _ensureDefaults(int? profileId) async {
    if (profileId == null) return;
    final existing = await _repo.fetchAllPresetsRaw(profileId: profileId);
    if (existing.isNotEmpty) return;
    await _repo.findOrCreatePreset('Preset 1', profileId: profileId);
    await _repo.findOrCreatePreset('Preset 2', profileId: profileId);
    setState(() {});
  }

  void _openPreset(int presetId, {bool edit = false}) {
    Navigator.of(context).push(
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
          child: const PresetDetailScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ActiveSession, SelectedProfile>(
      builder: (_, session, sel, __) => Scaffold(
        key: _scaffoldKey,
        drawer: const MainDrawer(),
        endDrawer: ProfileDrawer(
          profiles: sel.profiles,
          selected: sel.currentProfile,
          onSelect: (profile) {
            sel.selectProfile(profile);
            Navigator.of(context).pop();
            setState(() {});
          },
          onEdit: (profile) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GymProfileScreen(profile: profile),
              ),
            );
          },
          onDeleteAll: () {
            sel.deleteProfile(sel.currentProfile!.id!);
            setState(() {});
          },
        ),

        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Center(
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(20),
                borderWidth: 0,
                borderColor: Colors.transparent,
                selectedBorderColor: Colors.transparent,
                fillColor: Theme.of(context).colorScheme.primary,
                selectedColor: Theme.of(context).colorScheme.onPrimary,
                constraints: const BoxConstraints(
                  minWidth: 100,
                  minHeight: 32,
                ),
                isSelected: [
                  _selectedTab == 0,
                  _selectedTab == 1,
                ],
                onPressed: (idx) => setState(() => _selectedTab = idx),
                children: const [
                  Text('Train'),
                  Text('History'),
                ],
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.lightGreen,
                child: Text(
                  'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ],
        ),

        body: SafeArea(
          child: _selectedTab == 0
              ? _buildTrainContent(session, sel)
              : _buildHistoryContent(),
        ),
      ),
    );
  }

  Widget _buildTrainContent(
      ActiveSession session, SelectedProfile sel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Exercise Presets',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PresetsLoaded(
              scale: 1.0,
              onRefresh: () => setState(() {}),
            ),
          ),
        ),
        const Divider(height: 1),

        const SizedBox(height: 8),
        GenericBar(
          label: 'Generate Custom Presets',
          color: Colors.purple,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PresetGenerationQaScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 8),
        GenericBar(
          label: 'Manually Add Preset',
          color: Colors.purple,
          onTap: () async {
            final profileId = sel.currentProfile?.id;
            final existing =
                await _repo.fetchAllPresetsRaw(profileId: profileId);
            final nextNum = existing.length + 1;
            final name = nextNum == 1
                ? 'New Preset'
                : 'New Preset $nextNum';
            final newId =
                await _repo.createPreset(name, profileId: profileId);
            _openPreset(newId, edit: true);
            setState(() {});
          },
        ),
        
        const SizedBox(height: 8),

        GenericBar(
          label: 'Start Optimized Workout',
          color: Colors.green,
          onTap: null,
        ),
        
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              session.start();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SessionScreen()),
              );
            },
            child: const Text('New Session'),
          ),
        ),
      ],
    );
  }

 Widget _buildHistoryContent() {
  return HistoryContent(
    onReload: () => setState(() {}),
  );
}

}
