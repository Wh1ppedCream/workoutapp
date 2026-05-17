import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/active_session.dart';
import '../../providers/preset_session.dart';
import '../../providers/selected_profile.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/body_heatmap.dart';
import '../../widgets/drawers.dart';
import '../../widgets/presets_loaded.dart';
import 'gym_profile_screen.dart';
import 'preset_detail_screen.dart';
import 'preset_generation_qa.dart';
import 'session_screen.dart';

class TrainPage extends StatefulWidget {
  const TrainPage({super.key});

  @override
  State<TrainPage> createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  final _repo = AppRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<String> _overviewBodyParts = <String>{};

  int _selectedTab = 0;
  int _presetsRefreshToken = 0;
  int? _lastProfileId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profileId = context.watch<SelectedProfile>().currentProfile?.id;
    if (_lastProfileId != profileId) {
      _lastProfileId = profileId;
      unawaited(_ensureDefaults(profileId));
      _presetsRefreshToken++;
    }
  }

  Future<void> _ensureDefaults(int? profileId) async {
    if (profileId == null) return;
    final existing = await _repo.fetchAllPresetsRaw(profileId: profileId);
    if (existing.isNotEmpty) return;
    await _repo.findOrCreatePreset('Preset 1', profileId: profileId);
    await _repo.findOrCreatePreset('Preset 2', profileId: profileId);
    if (!mounted) return;
    setState(() => _presetsRefreshToken++);
  }

  Future<void> _openPreset(int presetId) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (outerCtx) => MultiProvider(
              providers: [
                ChangeNotifierProvider<ActiveSession>.value(
                  value: outerCtx.read<ActiveSession>(),
                ),
                ChangeNotifierProvider(create: (_) => PresetSession(presetId)),
              ],
              child: const PresetDetailScreen(),
            ),
      ),
    );
    if (!mounted) return;
    setState(() => _presetsRefreshToken++);
  }

  Future<void> _openCustomPresetGenerator(SelectedProfile sel) async {
    final profileId = sel.currentProfile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gym profile first.')),
      );
      return;
    }

    final generatedPresetId = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => PresetGenerationQaScreen(profileId: profileId),
      ),
    );
    if (generatedPresetId == null || !mounted) return;
    await _openPreset(generatedPresetId);
  }

  Future<void> _createManualPreset(SelectedProfile sel) async {
    final profileId = sel.currentProfile?.id;
    final existing = await _repo.fetchAllPresetsRaw(profileId: profileId);
    final nextNum = existing.length + 1;
    final name = nextNum == 1 ? 'New Preset' : 'New Preset $nextNum';
    final newId = await _repo.createPreset(name, profileId: profileId);
    if (!mounted) return;
    setState(() => _presetsRefreshToken++);
    await _openPreset(newId);
  }

  Future<void> _startWorkout() async {
    context.read<ActiveSession>().start();
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SessionScreen()));
  }

  void _showOptimizePlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Optimize Workout will move here next. Train2 still has the current optimized flow.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedProfile>(
      builder: (context, sel, _) {
        return Scaffold(
          key: _scaffoldKey,
          endDrawer: ProfileDrawer(
            profiles: sel.profiles,
            selected: sel.currentProfile,
            onSelect: (profile) {
              unawaited(sel.selectProfile(profile));
              Navigator.of(context).pop();
              setState(() => _presetsRefreshToken++);
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
              final profileId = sel.currentProfile?.id;
              if (profileId == null) return;
              unawaited(sel.deleteProfile(profileId));
              setState(() => _presetsRefreshToken++);
            },
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: _TrainTabs(
              selectedIndex: _selectedTab,
              onChanged: (index) => setState(() => _selectedTab = index),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  tooltip: 'Gym profiles',
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  icon: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.lightGreen,
                    child: Text(
                      _profileInitial(sel.currentProfile?.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _OverviewTab(
                  selectedBodyParts: _overviewBodyParts,
                  onBodyPartsChanged: (next) {
                    setState(() {
                      _overviewBodyParts
                        ..clear()
                        ..addAll(next);
                    });
                  },
                  profileName: sel.currentProfile?.name,
                ),
                _PlansTab(
                  refreshToken: _presetsRefreshToken,
                  onRefresh: () => setState(() => _presetsRefreshToken++),
                  onGeneratePreset: () => _openCustomPresetGenerator(sel),
                  onCreatePreset: () => _createManualPreset(sel),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              _selectedTab == 0
                  ? _SplitWorkoutBar(
                    onStartWorkout: _startWorkout,
                    onOptimizeWorkout: _showOptimizePlaceholder,
                  )
                  : null,
        );
      },
    );
  }

  String _profileInitial(String? name) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return 'P';
    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _TrainTabs extends StatelessWidget {
  const _TrainTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Overview',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabButton(
            label: 'Plans',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: selected ? colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color:
                    selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.selectedBodyParts,
    required this.onBodyPartsChanged,
    required this.profileName,
  });

  final Set<String> selectedBodyParts;
  final ValueChanged<Set<String>> onBodyPartsChanged;
  final String? profileName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
      children: [
        _EditableHeatmapCard(
          selectedBodyParts: selectedBodyParts,
          onBodyPartsChanged: onBodyPartsChanged,
        ),
        const SizedBox(height: 16),
        _SelectedPresetsCard(profileName: profileName),
      ],
    );
  }
}

class _EditableHeatmapCard extends StatelessWidget {
  const _EditableHeatmapCard({
    required this.selectedBodyParts,
    required this.onBodyPartsChanged,
  });

  final Set<String> selectedBodyParts;
  final ValueChanged<Set<String>> onBodyPartsChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyPartNames = bodyPartNameToSvgIds.keys.toList(growable: false);
    final frequencyMap = _bodyPartHeatmapMap(selectedBodyParts);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Focus',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap bodyparts to sketch what you want the next workout to emphasize.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final useWideLayout = constraints.maxWidth >= 430;
                final heatmap = SizedBox(
                  height: useWideLayout ? 210 : 250,
                  child: BodyHeatmap(
                    frequencyMap: frequencyMap,
                    highColor: Colors.blue,
                  ),
                );
                final chips = _BodyPartChips(
                  bodyPartNames: bodyPartNames,
                  selectedBodyParts: selectedBodyParts,
                  onBodyPartsChanged: onBodyPartsChanged,
                );
                if (!useWideLayout) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: heatmap),
                      const SizedBox(height: 16),
                      chips,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: heatmap),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: chips),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyPartChips extends StatelessWidget {
  const _BodyPartChips({
    required this.bodyPartNames,
    required this.selectedBodyParts,
    required this.onBodyPartsChanged,
  });

  final List<String> bodyPartNames;
  final Set<String> selectedBodyParts;
  final ValueChanged<Set<String>> onBodyPartsChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final bodyPart in bodyPartNames)
          FilterChip(
            label: Text(bodyPart),
            selected: selectedBodyParts.contains(bodyPart),
            onSelected: (_) {
              final next = Set<String>.of(selectedBodyParts);
              if (!next.add(bodyPart)) next.remove(bodyPart);
              onBodyPartsChanged(next);
            },
          ),
      ],
    );
  }
}

class _SelectedPresetsCard extends StatelessWidget {
  const _SelectedPresetsCard({required this.profileName});

  final String? profileName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Presets',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profileName == null
                  ? 'No gym profile selected.'
                  : 'Profile: $profileName',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'Preset selection controls will live here, so the Start Workout button can launch a curated session from this overview.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlansTab extends StatelessWidget {
  const _PlansTab({
    required this.refreshToken,
    required this.onRefresh,
    required this.onGeneratePreset,
    required this.onCreatePreset,
  });

  final int refreshToken;
  final VoidCallback onRefresh;
  final VoidCallback onGeneratePreset;
  final VoidCallback onCreatePreset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Presets',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: PresetsLoaded(
            scale: 1,
            refreshToken: refreshToken,
            onRefresh: onRefresh,
          ),
        ),
        const _PremadePlansCard(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGeneratePreset,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Custom Presets'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCreatePreset,
                  icon: const Icon(Icons.add),
                  label: const Text('Manually Add Preset'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremadePlansCard extends StatelessWidget {
  const _PremadePlansCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.view_list_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premade Plans',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plan library coming next.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplitWorkoutBar extends StatelessWidget {
  const _SplitWorkoutBar({
    required this.onStartWorkout,
    required this.onOptimizeWorkout,
  });

  final VoidCallback onStartWorkout;
  final VoidCallback onOptimizeWorkout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Material(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: onStartWorkout,
                  child: Center(
                    child: Text(
                      'Start Workout',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: double.infinity,
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.16),
              ),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: onOptimizeWorkout,
                  child: Center(
                    child: Text(
                      'Optimize',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Map<String, double> _bodyPartHeatmapMap(Set<String> selectedBodyParts) {
  final map = <String, double>{};
  for (final bodyPart in selectedBodyParts) {
    final svgIds = bodyPartNameToSvgIds[bodyPart];
    if (svgIds == null) continue;
    for (final svgId in svgIds) {
      map[svgId] = 1;
    }
  }
  return map;
}
