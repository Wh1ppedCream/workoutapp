// new_measurement_item_page.dart

import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models.dart';

/// Page for creating a new measurement (weight, height, or specific body part).
class NewMeasurementItemPage extends StatefulWidget {
  const NewMeasurementItemPage({super.key});

  @override
  State<NewMeasurementItemPage> createState() =>
      _NewMeasurementItemPageState();
}

class _NewMeasurementItemPageState extends State<NewMeasurementItemPage> {
  bool _usePresets = true;
  MeasurementType? _selectedType;
  String? _bodyweightVariation;
  bool _heightIsFeet = true;
  bool _pump = false;
  String _selectedWeightUnit = 'lbs';

  final TextEditingController _valController1 = TextEditingController();
  final TextEditingController _valController2 = TextEditingController();

  @override
  void dispose() {
    _valController1.dispose();
    _valController2.dispose();
    super.dispose();
  }

  void _resetSubControls() {
    _bodyweightVariation = null;
    _heightIsFeet = true;
    _pump = false;
    _valController1.clear();
    _valController2.clear();
    _selectedWeightUnit = 'lbs';
  }

  bool get _canSave {
    if (!_usePresets || _selectedType == null) return false;
    switch (_selectedType!) {
      case MeasurementType.BodyWeight:
        return _bodyweightVariation != null &&
            _valController1.text.isNotEmpty;
      case MeasurementType.Height:
        return _heightIsFeet
            ? _valController1.text.isNotEmpty &&
                _valController2.text.isNotEmpty
            : _valController1.text.isNotEmpty;
      default:
        // Any other enum value is a body part
        return _valController1.text.isNotEmpty;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveMeasurement() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    final type = _selectedType!;
    final queryName = type.name; // matches measurement_definitions.name
    final defRows = await db.query(
      'measurement_definitions',
      where: 'name = ?',
      whereArgs: [queryName],
    );
    if (defRows.isEmpty) {
      _showError('Definition not found for $queryName');
      return;
    }
    final defId = defRows.first['id'] as int;

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
      _showError('Invalid numeric value');
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

    await dbHelper.insertMeasurement(
      defId,
      DateTime.now(),
      value,
      unit,
      note,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Measurement')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Toggle between Presets / Custom
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _usePresets = true;
                    _resetSubControls();
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _usePresets ? Colors.deepPurple : null,
                  ),
                  child: const Text('Presets'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _usePresets = false;
                    _resetSubControls();
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !_usePresets ? Colors.deepPurple : null,
                  ),
                  child: const Text('Custom'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_usePresets) ...[
            // Preset selector
            DropdownButtonFormField<MeasurementType>(
              decoration: const InputDecoration(labelText: 'Preset Type'),
              value: _selectedType,
              items: MeasurementType.values.map((mt) {
                return DropdownMenuItem<MeasurementType>(
                  value: mt,
                  child: Text(mt.name),
                );
              }).toList(),
              onChanged: (mt) => setState(() {
                _selectedType = mt;
                _resetSubControls();
              }),
            ),
            const SizedBox(height: 16),

            if (_selectedType == MeasurementType.BodyWeight) ...[
              const Text('Variation'),
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
                children: const [
                  Text('WakeUp'),
                  Text('BedTime'),
                  Text('Overall'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _valController1,
                      decoration:
                          const InputDecoration(labelText: 'Weight'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedWeightUnit,
                    onChanged: (u) => setState(() {
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
              const Text('Units'),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: [_heightIsFeet, !_heightIsFeet],
                onPressed: (i) => setState(
                  () => _heightIsFeet = (i == 0),
                ),
                children: const [Text('ft/in'), Text('cm')],
              ),
              const SizedBox(height: 16),
              if (_heightIsFeet)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _valController1,
                        decoration:
                            const InputDecoration(labelText: 'Feet'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _valController2,
                        decoration:
                            const InputDecoration(labelText: 'Inches'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                )
              else
                TextFormField(
                  controller: _valController1,
                  decoration:
                      const InputDecoration(labelText: 'Centimeters'),
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
                _notesFor[_selectedType!.name]!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: [!_pump, _pump],
                onPressed: (i) => setState(
                  () => _pump = (i == 1),
                ),
                children: const [
                  Text('Without pump'),
                  Text('With pump'),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valController1,
                decoration: const InputDecoration(
                  labelText: 'Centimeters',
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _canSave ? _saveMeasurement : null,
            child: const Text('Save New Measurement'),
          ),
        ),
      ),
    );
  }
}

/// Notes for each body part (must match MeasurementType names).
const Map<String, String> _notesFor = {
  'Forearm': 'Go to widest, largest part and measure around',
  'Arm': 'Go to widest part of bicep and measure around',
  'Neck': 'Go to area where measuring rope is straight',
  'Shoulder': 'Keep tape straight, measure around side delt',
  'Chest': 'Under armpit, above nipple line',
  'Waist': 'Around belly button',
  'Hip': 'Around biggest part of glute',
  'Thigh': 'Around widest part of thigh',
  'Calf': 'Around widest part of calf',
};
