// File: lib/screens/profile/settings/volume_boundaries_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../repositories/app_repository.dart';
import '../../../widgets/settings_tiles.dart';

class VolumeBoundariesScreen extends StatefulWidget {
  const VolumeBoundariesScreen({super.key});

  @override
  State<VolumeBoundariesScreen> createState() => _VolumeBoundariesScreenState();
}

class _VolumeBoundariesScreenState extends State<VolumeBoundariesScreen>
    with SingleTickerProviderStateMixin {
  AppRepository get _repo => context.read<AppRepository>();
  late final TabController _tabCtrl;

  List<BodyPart> _bodyParts = [];
  List<Muscle> _muscles = [];
  bool _isLoadingLookups = true;
  String? _lookupError;

  BodyPart? _selectedBodyPart;
  Muscle? _selectedMuscle;

  final _bodyPartCtrls = List.generate(4, (_) => TextEditingController());
  final _muscleCtrls = List.generate(4, (_) => TextEditingController());

  bool _isLoadingBodyPart = false;
  bool _isLoadingMuscle = false;
  bool _isSavingBodyPart = false;
  bool _isSavingMuscle = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadLookups();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    for (var controller in _bodyPartCtrls) {
      controller.dispose();
    }
    for (var controller in _muscleCtrls) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadLookups() async {
    try {
      final bodyParts = await _repo.fetchAllBodyPartsFull();
      final muscles = await _repo.fetchAllMusclesFull();
      if (!mounted) return;
      setState(() {
        _bodyParts = bodyParts;
        _muscles = muscles;
        _selectedBodyPart = bodyParts.isNotEmpty ? bodyParts.first : null;
        _selectedMuscle = muscles.isNotEmpty ? muscles.first : null;
        _lookupError = null;
      });
      if (_selectedBodyPart != null) {
        await _loadBodyPartBounds(_selectedBodyPart!.id);
      }
      if (_selectedMuscle != null) {
        await _loadMuscleBounds(_selectedMuscle!.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lookupError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingLookups = false);
      }
    }
  }

  Future<void> _loadBodyPartBounds(int id) async {
    setState(() {
      _isLoadingBodyPart = true;
      for (var controller in _bodyPartCtrls) {
        controller.clear();
      }
    });
    try {
      final bounds = await _repo.fetchBodyPartVolumeBounds(id);
      if (!mounted) return;
      if (bounds != null) {
        setState(() => _setControllerText(_bodyPartCtrls, bounds));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).volumeLoadBodyPartFailed(e.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingBodyPart = false);
      }
    }
  }

  Future<void> _loadMuscleBounds(int id) async {
    setState(() {
      _isLoadingMuscle = true;
      for (var controller in _muscleCtrls) {
        controller.clear();
      }
    });
    try {
      final bounds = await _repo.fetchMuscleVolumeBounds(id);
      if (!mounted) return;
      if (bounds != null) {
        setState(() => _setControllerText(_muscleCtrls, bounds));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).volumeLoadMuscleFailed(e.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingMuscle = false);
      }
    }
  }

  void _setControllerText(
    List<TextEditingController> controllers,
    VolumeBoundaries bounds,
  ) {
    controllers[0].text = bounds.maintenance.toString();
    controllers[1].text = bounds.minEffective.toString();
    controllers[2].text = bounds.maxAdaptive.toString();
    controllers[3].text = bounds.maxRecoverable.toString();
  }

  List<double>? _parseBounds(List<TextEditingController> controllers) {
    final values =
        controllers.map((controller) {
          return double.tryParse(controller.text.trim());
        }).toList();
    return values.any((value) => value == null) ? null : values.cast<double>();
  }

  Future<void> _saveBodyPart() async {
    if (_selectedBodyPart == null) return;
    final values = _parseBounds(_bodyPartCtrls);
    if (values == null) {
      _showInvalidNumbers();
      return;
    }

    setState(() => _isSavingBodyPart = true);
    try {
      final bounds = VolumeBoundaries(
        id: _selectedBodyPart!.id,
        maintenance: values[0],
        minEffective: values[1],
        maxAdaptive: values[2],
        maxRecoverable: values[3],
      );
      await _repo.setBodyPartVolumeBounds(_selectedBodyPart!.id, bounds);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).volumeBodyPartSaved),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).rankingsSaveError(e.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingBodyPart = false);
      }
    }
  }

  Future<void> _saveMuscle() async {
    if (_selectedMuscle == null) return;
    final values = _parseBounds(_muscleCtrls);
    if (values == null) {
      _showInvalidNumbers();
      return;
    }

    setState(() => _isSavingMuscle = true);
    try {
      final bounds = VolumeBoundaries(
        id: _selectedMuscle!.id,
        maintenance: values[0],
        minEffective: values[1],
        maxAdaptive: values[2],
        maxRecoverable: values[3],
      );
      await _repo.setMuscleVolumeBounds(_selectedMuscle!.id, bounds);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).volumeMuscleSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).rankingsSaveError(e.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingMuscle = false);
      }
    }
  }

  void _showInvalidNumbers() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).volumeInvalidNumbers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settingsVolumeBoundaries),
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: strings.volumeBodyParts),
            Tab(text: strings.volumeMuscles),
          ],
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final strings = AppLocalizations.of(context);
    if (_isLoadingLookups) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_lookupError != null) {
      return Center(
        child: Text(
          strings.rankingsLoadError(
            strings.settingsVolumeBoundaries,
            _lookupError!,
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabCtrl,
      children: [
        _BoundaryTab<BodyPart>(
          title: strings.volumeBodyPartTitle,
          subtitle: strings.volumeBodyPartSubtitle,
          icon: Icons.accessibility_new,
          selected: _selectedBodyPart,
          items: _bodyParts,
          itemName: (bodyPart) => bodyPart.name,
          onChanged: (bodyPart) {
            if (bodyPart == null) return;
            setState(() => _selectedBodyPart = bodyPart);
            _loadBodyPartBounds(bodyPart.id);
          },
          controllers: _bodyPartCtrls,
          isLoading: _isLoadingBodyPart,
          isSaving: _isSavingBodyPart,
          onSave: _saveBodyPart,
        ),
        _BoundaryTab<Muscle>(
          title: strings.volumeMuscleTitle,
          subtitle: strings.volumeMuscleSubtitle,
          icon: Icons.fitness_center,
          selected: _selectedMuscle,
          items: _muscles,
          itemName: (muscle) => muscle.name,
          onChanged: (muscle) {
            if (muscle == null) return;
            setState(() => _selectedMuscle = muscle);
            _loadMuscleBounds(muscle.id);
          },
          controllers: _muscleCtrls,
          isLoading: _isLoadingMuscle,
          isSaving: _isSavingMuscle,
          onSave: _saveMuscle,
        ),
      ],
    );
  }
}

class _BoundaryTab<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final T? selected;
  final List<T> items;
  final String Function(T item) itemName;
  final ValueChanged<T?> onChanged;
  final List<TextEditingController> controllers;
  final bool isLoading;
  final bool isSaving;
  final VoidCallback onSave;

  const _BoundaryTab({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.items,
    required this.itemName,
    required this.onChanged,
    required this.controllers,
    required this.isLoading,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final boundaryLabels = [
      strings.volumeMaintenance,
      strings.volumeMinEffective,
      strings.volumeMaxAdaptive,
      strings.volumeMaxRecoverable,
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        SettingsHeroCard(title: title, subtitle: subtitle, icon: icon),
        const SizedBox(height: 16),
        SettingsSection(
          title: strings.volumeSelection,
          accentColor: SettingsAccent.training,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: DropdownButtonFormField<T>(
                isExpanded: true,
                value: selected,
                decoration: InputDecoration(
                  labelText: title,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items:
                    items
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(itemName(item)),
                          ),
                        )
                        .toList(),
                onChanged: isLoading || isSaving ? null : onChanged,
              ),
            ),
          ],
        ),
        SettingsSection(
          title: strings.volumeRecommendedRange,
          subtitle: strings.volumeRecommendedRangeSubtitle,
          accentColor: SettingsAccent.progress,
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    for (var i = 0; i < controllers.length; i++) ...[
                      TextFormField(
                        controller: controllers[i],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: boundaryLabels[i],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      if (i != controllers.length - 1)
                        const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isSaving ? null : onSave,
                        icon:
                            isSaving
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.save),
                        label: Text(
                          isSaving
                              ? strings.nutritionSaving
                              : strings.volumeSaveBoundaries,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
