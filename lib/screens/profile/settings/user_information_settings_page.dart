// file: lib/screens/profile/settings/user_information_settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/models.dart';
import '../../../providers/unit_preference_provider.dart';
import '../../../repositories/app_repository.dart';
import '../../../utils/weight_unit_formatter.dart';
import '../../../widgets/settings_tiles.dart';

class UserInformationSettingsPage extends StatefulWidget {
  const UserInformationSettingsPage({super.key});

  @override
  State<UserInformationSettingsPage> createState() =>
      _UserInformationSettingsPageState();
}

class _UserInformationSettingsPageState
    extends State<UserInformationSettingsPage> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _dobController = TextEditingController();

  String? _gender;
  String? _bodyFatEstimate;
  String? _weightTrend;
  String? _activityLevel;
  DateTime? _dob;
  bool _dirty = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _nameController,
      _heightController,
      _weightController,
    ]) {
      controller.addListener(_markDirty);
    }
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = context.read<AppRepository>();
    final unitPreferences = context.read<UnitPreferenceProvider>();
    await unitPreferences.ready;
    final weightUnit = unitPreferences.weightUnit;
    final personalInfo = await repo.fetchPersonalInfo();
    final latestBodyWeightLbs = await repo.fetchLatestBodyWeightLbs();
    if (!mounted) return;

    setState(() {
      _loading = true;
      _nameController.text = personalInfo?.name ?? '';
      _gender = personalInfo?.gender;
      _dob = personalInfo?.dob;
      _dobController.text = _formatDate(personalInfo?.dob);
      _heightController.text = personalInfo?.height ?? '';
      _weightController.text = _formatStoredWeightForDisplay(
        personalInfo?.weight,
        weightUnit,
        latestBodyWeightLbs: latestBodyWeightLbs,
      );
      _bodyFatEstimate = personalInfo?.bodyFatEstimate;
      _weightTrend = personalInfo?.weightTrend;
      _activityLevel = personalInfo?.activityLevel;
      _dirty = false;
      _loading = false;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;

    setState(() {
      _dob = picked;
      _dobController.text = _formatDate(picked);
      _dirty = true;
    });
  }

  Future<void> _save() async {
    try {
      final repo = context.read<AppRepository>();
      final weightUnit = context.read<UnitPreferenceProvider>().weightUnit;
      final enteredWeight = double.tryParse(_weightController.text.trim());
      final info = PersonalInfo(
        name: _clean(_nameController.text),
        gender: _gender,
        dob: _dob,
        height: _clean(_heightController.text),
        weight: _cleanWeightForStorage(_weightController.text, weightUnit),
        bodyFatEstimate: _bodyFatEstimate,
        weightTrend: _weightTrend,
        activityLevel: _activityLevel,
      );
      await repo.savePersonalInfoWithBodyWeight(
        info: info,
        bodyWeightValue:
            enteredWeight != null && enteredWeight > 0 ? enteredWeight : null,
        bodyWeightUnit: weightUnit,
        measurementNote: 'Profile update',
      );
      if (!mounted) return;
      setState(() => _dirty = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Changes saved')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Couldn't save: $error")));
    }
  }

  String? _clean(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatStoredWeightForDisplay(
    String? storedWeight,
    WeightUnit unit, {
    double? latestBodyWeightLbs,
  }) {
    if (latestBodyWeightLbs != null && latestBodyWeightLbs > 0) {
      return WeightUnitFormatter.formatInputWeight(latestBodyWeightLbs, unit);
    }
    final cleaned = _clean(storedWeight ?? '');
    if (cleaned == null) return '';
    final pounds = double.tryParse(cleaned);
    if (pounds == null) return cleaned;
    return WeightUnitFormatter.formatInputWeight(pounds, unit);
  }

  String? _cleanWeightForStorage(String value, WeightUnit unit) {
    final cleaned = _clean(value);
    if (cleaned == null) return null;
    final displayWeight = double.tryParse(cleaned);
    if (displayWeight == null) return cleaned;
    final pounds = WeightUnitFormatter.toPounds(displayWeight, unit);
    return WeightUnitFormatter.formatInputWeight(pounds, WeightUnit.pounds);
  }

  void _markDirty() {
    if (_loading) return;
    setState(() => _dirty = true);
  }

  @override
  Widget build(BuildContext context) {
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final bodyFatOptions = <String>[
      '0-5%',
      '5-10%',
      '10-15%',
      '15-20%',
      '20-25%',
      '25-30%',
      '30-35%',
      '35-40%',
      '40-45%',
    ];
    const trendOptions = [
      'Gaining weight',
      'Losing weight',
      'Maintaining weight',
      'Not sure',
    ];
    const activityOptions = ['Low (0-5k)', 'Moderate (5-15k)', 'High (15k+)'];
    const genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SettingsPageScaffold(
      title: 'User Information',
      subtitle: 'Keep basic profile details available for app calculations.',
      icon: Icons.badge_outlined,
      heroAccentColor: SettingsAccent.account,
      bottomNavigationBar: _SaveBar(isVisible: _dirty, onSave: _save),
      children: [
        SettingsSection(
          title: 'Identity',
          subtitle: 'Basic personal details.',
          accentColor: SettingsAccent.account,
          children: [
            _FieldPadding(
              child: TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  context,
                  label: 'Name',
                  hint: 'Enter your name',
                  icon: Icons.person_outline,
                ),
              ),
            ),
            _FieldPadding(
              child: DropdownButtonFormField<String?>(
                value: _gender,
                items:
                    genderOptions
                        .map(
                          (gender) => DropdownMenuItem<String?>(
                            value: gender,
                            child: Text(gender),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  _gender = value;
                  _markDirty();
                },
                decoration: _inputDecoration(
                  context,
                  label: 'Gender',
                  icon: Icons.wc_outlined,
                ),
              ),
            ),
            _FieldPadding(
              child: GestureDetector(
                onTap: _pickDob,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dobController,
                    decoration: _inputDecoration(
                      context,
                      label: 'Date of Birth',
                      hint: 'YYYY-MM-DD',
                      icon: Icons.calendar_today,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SettingsSection(
          title: 'Body Metrics',
          subtitle:
              'Optional details used by progress and nutrition estimates.',
          accentColor: SettingsAccent.progress,
          children: [
            _FieldPadding(
              child: TextFormField(
                controller: _heightController,
                decoration: _inputDecoration(
                  context,
                  label: 'Height',
                  hint: 'e.g. 5\'10" or 178 cm',
                  icon: Icons.height,
                ),
              ),
            ),
            _FieldPadding(
              child: TextFormField(
                controller: _weightController,
                decoration: _inputDecoration(
                  context,
                  label: 'Current Weight',
                  hint:
                      weightUnit == WeightUnit.pounds ? 'e.g. 160' : 'e.g. 72',
                  icon: Icons.monitor_weight_outlined,
                  suffixText: weightUnit.shortLabel,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            _FieldPadding(
              child: DropdownButtonFormField<String?>(
                value: _bodyFatEstimate,
                items:
                    bodyFatOptions
                        .map(
                          (option) => DropdownMenuItem<String?>(
                            value: option,
                            child: Text(option),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  _bodyFatEstimate = value;
                  _markDirty();
                },
                decoration: _inputDecoration(
                  context,
                  label: 'Body-fat % estimate',
                  icon: Icons.percent,
                ),
              ),
            ),
          ],
        ),
        SettingsSection(
          title: 'Activity Context',
          subtitle: 'Used later for recommendations and health estimates.',
          accentColor: SettingsAccent.training,
          children: [
            _FieldPadding(
              child: DropdownButtonFormField<String?>(
                value: _weightTrend,
                items:
                    trendOptions
                        .map(
                          (option) => DropdownMenuItem<String?>(
                            value: option,
                            child: Text(option),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  _weightTrend = value;
                  _markDirty();
                },
                decoration: _inputDecoration(
                  context,
                  label: 'Weight trend',
                  icon: Icons.trending_up,
                ),
              ),
            ),
            _FieldPadding(
              child: DropdownButtonFormField<String?>(
                value: _activityLevel,
                items:
                    activityOptions
                        .map(
                          (option) => DropdownMenuItem<String?>(
                            value: option,
                            child: Text(option),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  _activityLevel = value;
                  _markDirty();
                },
                decoration: _inputDecoration(
                  context,
                  label: 'Estimated avg steps',
                  icon: Icons.directions_walk,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 72),
      ],
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    String? hint,
    required IconData icon,
    String? suffixText,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixText: suffixText,
      filled: true,
      fillColor: scheme.surface.withValues(alpha: 0.44),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _FieldPadding extends StatelessWidget {
  final Widget child;

  const _FieldPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: child,
    );
  }
}

class _SaveBar extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onSave;

  const _SaveBar({required this.isVisible, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 200),
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.96),
              border: Border(top: BorderSide(color: scheme.outlineVariant)),
            ),
            child: FilledButton.icon(
              onPressed: isVisible ? onSave : null,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Changes'),
            ),
          ),
        ),
      ),
    );
  }
}
