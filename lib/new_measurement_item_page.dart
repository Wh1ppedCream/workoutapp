// File: lib/new_measurement_item_page.dart
import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models.dart';

class NewMeasurementItemPage extends StatefulWidget {
  const NewMeasurementItemPage({Key? key}) : super(key: key);

  @override
  _NewMeasurementItemPageState createState() => _NewMeasurementItemPageState();
}

class _NewMeasurementItemPageState extends State<NewMeasurementItemPage> {
  // Top toggle
  bool _usePresets = true;

  // Preset selection
  String? _selectedType;

  // BodyPart submenu
  String? _selectedBodyPart;

  // Sub‑type toggles
  String? _bodyweightVariation; // WakeUp, BedTime, Overall
  bool _pump = false;           // withoutPump=false, withPump=true
  bool _heightIsFeet = true;    // ft/in vs cm

  // Input controllers
  final TextEditingController _valController1 = TextEditingController();
  final TextEditingController _valController2 = TextEditingController();

  @override
  void dispose() {
    _valController1.dispose();
    _valController2.dispose();
    super.dispose();
  }


  bool get _canSave {
    if (!_usePresets) return false;
    final t = _selectedType;
    if (t == 'Bodyweight') {
      return _bodyweightVariation != null && _valController1.text.isNotEmpty;
    } else if (t == 'Height') {
      if (_heightIsFeet) {
        return _valController1.text.isNotEmpty && _valController2.text.isNotEmpty;
      }
      return _valController1.text.isNotEmpty;
    } else if (t == 'Body Part') {
      return _selectedBodyPart != null && _valController1.text.isNotEmpty;
    }
    return false;
  }

  void _resetState() {
    _bodyweightVariation = null;
    _heightIsFeet = true;
    _selectedBodyPart = null;
    _pump = false;
    _valController1.clear();
    _valController2.clear();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Measurement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Presets / Custom toggle
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() { 
                    _usePresets = true; 
                    _resetState(); 
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _usePresets ? Colors.deepPurple : null,
                  ),
                  child: const Text('Presets'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _usePresets = false;
                    _resetState();
                  }),
                  
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_usePresets ? Colors.deepPurple : null,
                  ),
                  child: const Text('Custom'),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            if (_usePresets) ...[
              // Preset type dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Preset Type'),
                value: _selectedType,
                items: const [
                  'Bodyweight', 'Height', 'Body Part'
                ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => setState(() {
                  _selectedType = v;
                  _resetState();
                }),
              ),
              const SizedBox(height: 16),

              // Dynamic area based on selection
              if (_selectedType == 'Bodyweight') ...[
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
                  children: const [Text('WakeUp'), Text('BedTime'), Text('Overall')],
                ),
                const SizedBox(height: 8),
                if (_bodyweightVariation != null)
                  Text(
                    _bodyweightVariation == 'WakeUp'
                        ? 'Measurement before any food or water.'
                        : _bodyweightVariation == 'BedTime'
                            ? 'Measurement before bed at night.'
                            : 'Measurement at random time.',
                  ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _valController1,
                      decoration: const InputDecoration(labelText: 'Weight'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: 'lbs',
                    onChanged: (_) {},
                    items: const [DropdownMenuItem(value: 'lbs', child: Text('lbs')), DropdownMenuItem(value: 'kg', child: Text('kg'))],
                  ),
                ]),
              ],

              // Height UI
              if (_selectedType == 'Height') ...[
                const Text('Units'),
                const SizedBox(height: 8),
                ToggleButtons(
                  isSelected: [_heightIsFeet, !_heightIsFeet],
                  onPressed: (i) => setState(() => _heightIsFeet = i == 0),
                  children: const [Text('ft/in'), Text('cm')],
                ),
                const SizedBox(height: 16),
                if (_heightIsFeet) ...[
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _valController1,
                        decoration: const InputDecoration(labelText: 'Feet'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _valController2,
                        decoration: const InputDecoration(labelText: 'Inches'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ]),
                ] else
                  TextFormField(
                    controller: _valController1,
                    decoration: const InputDecoration(labelText: 'Centimeters'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
              ],

              // Body Part UI
              if (_selectedType == 'Body Part') ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Body Part'),
                  value: _selectedBodyPart,
                  items: const [
                    'Forearm','Arm','Neck','Shoulder','Chest','Waist','Hip','Thigh','Calf'
                  ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setState(() => _selectedBodyPart = v),
                ),
                const SizedBox(height: 16),
                if (_selectedBodyPart != null) ...[
                  Text(
                    _notesFor[_selectedBodyPart!]!,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  ToggleButtons(
                    isSelected: [!_pump, _pump],
                    onPressed: (i) => setState(() => _pump = i == 1),
                    children: const [Text('Without pump'), Text('With pump')],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _valController1,
                    decoration: const InputDecoration(labelText: 'Centimeters', suffixText: 'cm'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ],
            ],

            const Spacer(),
            // Save button
            ElevatedButton(
              onPressed: _canSave ? () {/* save logic */} : null,
              child: const Text('Save New Measurement'),
            ),
          ],
        ),
      ),
    );
  }
}

const Map<String,String> _notesFor = {
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
