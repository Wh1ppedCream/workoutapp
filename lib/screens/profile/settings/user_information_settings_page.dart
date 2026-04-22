// file: lib/screens/profile/settings/user_information_settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../repositories/app_repository.dart';
import '../../../models/models.dart';

class UserInformationSettingsPage extends StatefulWidget {
  const UserInformationSettingsPage({super.key});

  @override
  State<UserInformationSettingsPage> createState() => _UserInformationSettingsPageState();
}

class _UserInformationSettingsPageState extends State<UserInformationSettingsPage> {
  // Persisted fields (we track dirty on these)
  final _nameController   = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _dobController    = TextEditingController(); // display-only text for picker

  String? _gender;
  String? _bodyFatEstimate;
  String? _weightTrend;
  String? _activityLevel;

  // Non-persisted placeholders (kept blank if unknown; not saved)
  final _userIdController = TextEditingController(); // read-only; left blank
  final _emailController  = TextEditingController();
  final _phoneController  = TextEditingController();

  DateTime? _dob;
  bool _dirty = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // mark dirty when any persisted text field changes (not during initial load)
    for (final c in [_nameController, _heightController, _weightController]) {
      c.addListener(() {
        if (_loading) return;
        setState(() => _dirty = true);
      });
    }
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _dobController.dispose();
    _userIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = context.read<AppRepository>();
    final p = await repo.fetchPersonalInfo();
    if (!mounted) return;

    setState(() {
      _loading = true;

      // Prefill persisted fields
      _nameController.text   = p?.name ?? '';
      _gender                = p?.gender;
      _dob                   = p?.dob;
      _dobController.text    = _formatDate(p?.dob);
      _heightController.text = p?.height ?? '';
      _weightController.text = p?.weight ?? '';
      _bodyFatEstimate       = p?.bodyFatEstimate;
      _weightTrend           = p?.weightTrend;
      _activityLevel         = p?.activityLevel;

      // Non-persisted remain blank unless you hook them up later
      _userIdController.text = '';
      _emailController.text  = '';
      _phoneController.text  = '';

      _dirty   = false;
      _loading = false;
    });
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final da = d.day.toString().padLeft(2, '0');
    return '$y-$m-$da';
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobController.text = _formatDate(picked);
        _dirty = true;
      });
    }
  }

  Future<void> _save() async {
    try {
      final repo = context.read<AppRepository>();
      final info = PersonalInfo(
        name:  _nameController.text.trim().isEmpty  ? null : _nameController.text.trim(),
        gender: _gender,
        dob:    _dob,
        height: _heightController.text.trim().isEmpty ? null : _heightController.text.trim(),
        weight: _weightController.text.trim().isEmpty ? null : _weightController.text.trim(),
        bodyFatEstimate: _bodyFatEstimate,
        weightTrend:     _weightTrend,
        activityLevel:   _activityLevel,
      );
      await repo.savePersonalInfo(info);
      if (!mounted) return;
      setState(() => _dirty = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn’t save: $e')),
      );
    }
  }

  void _markDirty() {
    if (_loading) return;
    setState(() => _dirty = true);
  }

  @override
  Widget build(BuildContext context) {
    final bodyFatOptions = <String>[
      '0-5%', '5-10%', '10-15%', '15-20%',
      '20-25%', '25-30%', '30-35%', '35-40%', '40-45%',
    ];
    final trendOptions = const [
      'Gaining weight', 'Losing weight', 'Maintaining weight', 'Not sure',
    ];
    final activityOptions = const [
      'Low (0-5k)', 'Moderate (5-15k)', 'High (15k+)',
    ];
    final genderOptions = const [
      'Male', 'Female', 'Other', 'Prefer not to say',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('User Information')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // ---------- Persisted fields ----------
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your name',
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String?>(
                    value: _gender,
                    items: genderOptions
                        .map((g) => DropdownMenuItem<String?>(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) { _gender = v; _markDirty(); },
                    decoration: const InputDecoration(labelText: 'Gender'),
                  ),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: _pickDob,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dobController,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          hintText: 'YYYY-MM-DD',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      hintText: 'e.g. 5\'10" or 178 cm',
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Current Weight',
                      hintText: 'e.g. 160 lbs or 72 kg',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String?>(
                    value: _bodyFatEstimate,
                    items: bodyFatOptions
                        .map((o) => DropdownMenuItem<String?>(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) { _bodyFatEstimate = v; _markDirty(); },
                    decoration: const InputDecoration(labelText: 'Body-fat % (estimate)'),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String?>(
                    value: _weightTrend,
                    items: trendOptions
                        .map((o) => DropdownMenuItem<String?>(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) { _weightTrend = v; _markDirty(); },
                    decoration: const InputDecoration(labelText: 'Weight trend'),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String?>(
                    value: _activityLevel,
                    items: activityOptions
                        .map((o) => DropdownMenuItem<String?>(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) { _activityLevel = v; _markDirty(); },
                    decoration: const InputDecoration(labelText: 'Estimated avg steps'),
                  ),
                  const SizedBox(height: 32),

                  // ---------- Non-persisted (kept blank) ----------
                  TextFormField(
                    controller: _userIdController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'User ID'),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 80), // space for bottom bar
                ],
              ),
            ),
      // Slide-up Save bar (only when there are changes to persisted fields)
      bottomNavigationBar: AnimatedSlide(
        offset: _dirty ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 200),
        child: AnimatedOpacity(
          opacity: _dirty ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _dirty ? _save : null,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
