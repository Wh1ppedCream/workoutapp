// File: lib/screens/new_measurement_item_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../models/models.dart';

/// Page for creating a new measurement (weight, height, or specific body part).
class NewMeasurementItemPage extends StatefulWidget {
  const NewMeasurementItemPage({super.key});

  @override
  State<NewMeasurementItemPage> createState() => _NewMeasurementItemPageState();
}

class _NewMeasurementItemPageState extends State<NewMeasurementItemPage> {
  AppRepository get _repo => context.read<AppRepository>();

  bool _usePresets = true;
  MeasurementType? _selectedType;
  String? _bodyweightVariation;
  bool _heightIsFeet = true;
  bool _pump = false;
  String _selectedWeightUnit = 'lbs';
  bool _selectedWeightUnitInitialized = false;

  final TextEditingController _valController1 = TextEditingController();
  final TextEditingController _valController2 = TextEditingController();
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _customUnitController = TextEditingController(
    text: 'in',
  );
  final TextEditingController _customNoteController = TextEditingController();

  @override
  void dispose() {
    _valController1.dispose();
    _valController2.dispose();
    _customNameController.dispose();
    _customUnitController.dispose();
    _customNoteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final unitPrefs = context.watch<UnitPreferenceProvider>();
    if (_selectedWeightUnitInitialized || !unitPrefs.loaded) return;
    _selectedWeightUnit = unitPrefs.weightUnit.shortLabel;
    _selectedWeightUnitInitialized = true;
  }

  String _preferredWeightUnit() {
    return context.read<UnitPreferenceProvider>().weightUnit.shortLabel;
  }

  void _resetSubControls() {
    _bodyweightVariation = null;
    _heightIsFeet = true;
    _pump = false;
    _valController1.clear();
    _valController2.clear();
    _customNameController.clear();
    _customUnitController.text = 'in';
    _customNoteController.clear();
    _selectedWeightUnit = _preferredWeightUnit();
  }

  bool get _canSave {
    if (!_usePresets) {
      return _customNameController.text.trim().isNotEmpty &&
          _customUnitController.text.trim().isNotEmpty &&
          _valController1.text.trim().isNotEmpty;
    }
    if (_selectedType == null) return false;
    switch (_selectedType!) {
      case MeasurementType.BodyWeight:
        return _bodyweightVariation != null && _valController1.text.isNotEmpty;
      case MeasurementType.Height:
        return _heightIsFeet
            ? _valController1.text.isNotEmpty && _valController2.text.isNotEmpty
            : _valController1.text.isNotEmpty;
      default:
        // Any other enum value is a body part
        return _valController1.text.isNotEmpty;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveMeasurement() async {
    final strings = AppLocalizations.of(context);
    if (!_usePresets) {
      final name = _customNameController.text.trim();
      final unit = _customUnitController.text.trim();
      final value = double.tryParse(_valController1.text.trim());
      if (name.isEmpty || unit.isEmpty || value == null) {
        _showError(strings.measurementCustomRequired);
        return;
      }

      final defId = await _repo.insertMeasurementDefinition(
        name: name,
        type: MeasurementType.Custom,
      );
      await _repo.insertMeasurement(
        defId,
        DateTime.now(),
        value,
        unit,
        _customNoteController.text.trim().isEmpty
            ? null
            : _customNoteController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
      return;
    }

    final type = _selectedType!;
    final queryName = type.name;

    // 1) Lookup the definition ID via repo
    await _repo.ensureDefaultMeasurementDefinitions();

    final defId = await _repo.fetchMeasurementDefinitionId(queryName);

    if (defId == null) {
      _showError(strings.measurementDefinitionNotFound(queryName));
      return;
    }

    // 2) Parse the numeric value and decide unit
    double value;
    String unit;
    try {
      if (type == MeasurementType.BodyWeight) {
        value = double.parse(_valController1.text);
        unit = _selectedWeightUnit;
      } else if (type == MeasurementType.Height) {
        if (_heightIsFeet) {
          final ft = int.parse(_valController1.text);
          final inches = int.parse(_valController2.text);
          value = (ft * 12 + inches).toDouble();
          unit = 'in';
        } else {
          value = double.parse(_valController1.text);
          unit = 'cm';
        }
      } else {
        // any other type is a body part, measured in cm
        value = double.parse(_valController1.text);
        unit = 'cm';
      }
    } catch (_) {
      _showError(strings.measurementInvalidValue);
      return;
    }

    String? note;
    if (type == MeasurementType.BodyWeight) {
      note = _bodyweightVariation;
    } else if (type != MeasurementType.BodyWeight &&
        type != MeasurementType.Height) {
      // body part
      note = _pump ? 'With pump' : 'Without pump';
    } else {
      // Height
      note = 'Overall';
    }

    // 4) Insert via repo

    await _repo.insertMeasurement(defId, DateTime.now(), value, unit, note);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.measurementNewTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Toggle between Presets / Custom
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      () => setState(() {
                        _usePresets = true;
                        _resetSubControls();
                      }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _usePresets ? Colors.deepPurple : null,
                  ),
                  child: Text(strings.measurementPresets),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      () => setState(() {
                        _usePresets = false;
                        _resetSubControls();
                      }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_usePresets ? Colors.deepPurple : null,
                  ),
                  child: Text(strings.measurementCustom),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_usePresets) ...[
            // Preset selector
            DropdownButtonFormField<MeasurementType>(
              decoration: InputDecoration(
                labelText: strings.measurementPresetType,
              ),
              value: _selectedType,
              items:
                  MeasurementType.values
                      .where((mt) => mt != MeasurementType.Custom)
                      .map((mt) {
                        return DropdownMenuItem<MeasurementType>(
                          value: mt,
                          child: Text(_measurementTypeLabel(strings, mt)),
                        );
                      })
                      .toList(),
              onChanged:
                  (mt) => setState(() {
                    _selectedType = mt;
                    _resetSubControls();
                  }),
            ),
            const SizedBox(height: 16),

            if (_selectedType == MeasurementType.BodyWeight) ...[
              Text(strings.measurementVariation),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: [
                  _bodyweightVariation == 'WakeUp',
                  _bodyweightVariation == 'BedTime',
                  _bodyweightVariation == 'Overall',
                ],
                onPressed: (i) {
                  const opts = ['WakeUp', 'BedTime', 'Overall'];
                  setState(() => _bodyweightVariation = opts[i]);
                },
                children: [
                  Text(strings.measurementWakeUp),
                  Text(strings.measurementBedtime),
                  Text(strings.measurementOverall),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _valController1,
                      decoration: InputDecoration(
                        labelText: strings.measurementValueWeight,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedWeightUnit,
                    onChanged:
                        (u) => setState(() {
                          if (u != null) _selectedWeightUnit = u;
                        }),
                    items: const [
                      DropdownMenuItem(value: 'lbs', child: Text('lbs')),
                      DropdownMenuItem(value: 'kg', child: Text('kg')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            if (_selectedType == MeasurementType.Height) ...[
              Text(strings.measurementUnits),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: [_heightIsFeet, !_heightIsFeet],
                onPressed: (i) => setState(() => _heightIsFeet = (i == 0)),
                children: const [Text('ft/in'), Text('cm')],
              ),
              const SizedBox(height: 16),
              if (_heightIsFeet)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _valController1,
                        decoration: InputDecoration(
                          labelText: strings.measurementFeet,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _valController2,
                        decoration: InputDecoration(
                          labelText: strings.measurementInches,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                )
              else
                TextFormField(
                  controller: _valController1,
                  decoration: InputDecoration(
                    labelText: strings.measurementCentimeters,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              const SizedBox(height: 16),
            ],

            if (_selectedType != null &&
                _selectedType != MeasurementType.BodyWeight &&
                _selectedType != MeasurementType.Height) ...[
              // Body part selected
              Text(
                _measurementInstruction(strings, _selectedType!),
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: [!_pump, _pump],
                onPressed: (i) => setState(() => _pump = (i == 1)),
                children: [
                  Text(strings.measurementWithoutPump),
                  Text(strings.measurementWithPump),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valController1,
                decoration: InputDecoration(
                  labelText: strings.measurementCentimeters,
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ] else ...[
            TextFormField(
              controller: _customNameController,
              decoration: InputDecoration(
                labelText: strings.measurementName,
                hintText: strings.measurementNameHint,
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _valController1,
                    decoration: InputDecoration(
                      labelText: strings.measurementValue,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _customUnitController,
                    decoration: InputDecoration(
                      labelText: strings.measurementUnit,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customNoteController,
              decoration: InputDecoration(
                labelText: strings.measurementNote,
                hintText: strings.measurementOptional,
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _canSave ? _saveMeasurement : null,
            child: Text(strings.measurementSaveNew),
          ),
        ),
      ),
    );
  }
}

String _measurementInstruction(AppLocalizations strings, MeasurementType type) {
  return switch (type) {
    MeasurementType.Forearm => strings.measurementInstructionsForearm,
    MeasurementType.Arm => strings.measurementInstructionsArm,
    MeasurementType.Neck => strings.measurementInstructionsNeck,
    MeasurementType.Shoulder => strings.measurementInstructionsShoulder,
    MeasurementType.Chest => strings.measurementInstructionsChest,
    MeasurementType.Waist => strings.measurementInstructionsWaist,
    MeasurementType.Hip => strings.measurementInstructionsHip,
    MeasurementType.Thigh => strings.measurementInstructionsThigh,
    MeasurementType.Calf => strings.measurementInstructionsCalf,
    _ => '',
  };
}

String _measurementTypeLabel(AppLocalizations strings, MeasurementType type) {
  return switch (type) {
    MeasurementType.BodyWeight => strings.measurementWeight,
    MeasurementType.Height => strings.measurementHeight,
    MeasurementType.Forearm => strings.measurementForearm,
    MeasurementType.Arm => strings.measurementArm,
    MeasurementType.Neck => strings.measurementNeck,
    MeasurementType.Shoulder => strings.measurementShoulders,
    MeasurementType.Chest => strings.measurementChest,
    MeasurementType.Waist => strings.measurementWaist,
    MeasurementType.Hip => strings.measurementHips,
    MeasurementType.Thigh => strings.measurementThigh,
    MeasurementType.Calf => strings.measurementCalves,
    MeasurementType.Custom => strings.measurementCustom,
  };
}
