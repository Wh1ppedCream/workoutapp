// File: lib/screens/nutrition/food_customization_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/nutrition_models.dart';


/// A page for adding or editing a food item.
/// Updated: unified numeric field layout + parents can hold values
/// and expose a separate "Breakdown" dropdown *under* the field.
/// Now groups Protein/Carbs/Fats inside a single "Macronutrients" card.
class FoodCustomizationPage extends StatefulWidget {
  const FoodCustomizationPage({
    super.key,
    this.initialFoodId,
    this.initialName,
    this.initialBrand,
    this.initialCalories,
    this.initialProteinG,
    this.initialCarbsG,
    this.initialFatsG,
    this.initialPortions,
    this.initialDensityGPerMl,
  });

  final int? initialFoodId;
  final String? initialName;
  final String? initialBrand;
  final double? initialCalories;
  final double? initialProteinG;
  final double? initialCarbsG;
  final double? initialFatsG;
  final List<FoodPortion>? initialPortions;
  final double? initialDensityGPerMl;

  @override
  State<FoodCustomizationPage> createState() => _FoodCustomizationPageState();
}


class _FoodCustomizationPageState extends State<FoodCustomizationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the top‐level fields
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _calController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbController = TextEditingController();
  final _fatController = TextEditingController();
  final _densityController = TextEditingController(); // g/mL


  // Lazily created controllers for every leaf/parent field in the tree
  final Map<String, TextEditingController> _controllers = {};

  // TODO: hook up real Image/File objects
  String? _foodImagePath;
  String? _labelImagePath;


  // ----- Portion Info state -----
  // Portion lists
final List<PortionEntry> _basisPortions = [PortionEntry(unit: 'gram (g)', amount: 100, grams: 100)];
final List<PortionEntry> _usualPortions = [PortionEntry()];

// One "default" per list (radio group)
int _basisDefaultIndex = 0;
int _usualDefaultIndex = 0;

// Supported units (you can expand later)
static const List<String> _massUnits = [
  'gram (g)', 'milligram (mg)', 'microgram (µg)', 'kilogram (kg)', 'ounce (oz)', 'pound (lb)'
];
static const List<String> _volumeUnits = [
  'milliliter (mL)', 'liter (L)', 'teaspoon (tsp)', 'tablespoon (tbsp)', 'cup', 'fluid ounce (fl oz)'
];
static const List<String> _allUnits = [..._massUnits, ..._volumeUnits];

String _lastDefaultGroup = 'basis'; // add to State


  
  @override
void initState() {
  super.initState();
  _prefillIfEditing();
}

void _prefillIfEditing() {
  final w = widget;

  if (w.initialName != null)  _nameController.text   = w.initialName!;
  if (w.initialBrand != null) _brandController.text  = w.initialBrand!;

  if (w.initialCalories != null)  _calController.text     = _fmtNum(w.initialCalories!);
  if (w.initialProteinG != null)  _proteinController.text = _fmtNum(w.initialProteinG!);
  if (w.initialCarbsG != null)    _carbController.text    = _fmtNum(w.initialCarbsG!);
  if (w.initialFatsG != null)     _fatController.text     = _fmtNum(w.initialFatsG!);

  if (w.initialPortions != null && w.initialPortions!.isNotEmpty) {
    _loadInitialPortions(w.initialPortions!);
  }
  // If you later pass an initial density, prefill here:
final d = widget.initialDensityGPerMl;   // ← remove the cast
  if (d != null) _densityController.text = _fmtNum(d);
}

String? _longUnitFromShort(String? s) {
  switch (s) {
    case 'g':   return 'gram (g)';
    case 'mg':  return 'milligram (mg)';
    case 'µg':  return 'microgram (µg)';
    case 'kg':  return 'kilogram (kg)';
    case 'oz':  return 'ounce (oz)';
    case 'lb':  return 'pound (lb)';
    case 'mL':  return 'milliliter (mL)';
    case 'L':   return 'liter (L)';
    case 'tsp': return 'teaspoon (tsp)';
    case 'tbsp':return 'tablespoon (tbsp)';
    case 'cup': return 'cup';
    case 'fl oz': return 'fluid ounce (fl oz)';
  }
  return s;
}

void _loadInitialPortions(List<FoodPortion> parts) {
  // clear existing default rows
  for (final p in _basisPortions) { p.dispose(); }
  for (final p in _usualPortions) { p.dispose(); }
  _basisPortions.clear();
  _usualPortions.clear();
  _basisDefaultIndex = 0;
  _usualDefaultIndex = 0;

  // sort: list_kind → sort_order → id
  parts.sort((a, b) {
    int rank(String? k) => (k == 'basis') ? 0 : (k == 'usual' ? 1 : 2);
    final r = rank(a.listKind) - rank(b.listKind);
    if (r != 0) return r;
    final sa = a.sortOrder ?? 0;
    final sb = b.sortOrder ?? 0;
    if (sa != sb) return sa - sb;
    return (a.id ?? 0) - (b.id ?? 0);
  });

   bool foundBasisDefault = false;
  bool foundUsualDefault = false;

  for (final p in parts) {
    final entry = PortionEntry(
      unit: _longUnitFromShort(p.unit ?? 'g') ?? 'gram (g)',
      amount: p.amount,
      grams:  p.gramWeight,
      ml:     p.mlVolume,
    );
    final isUsual = p.listKind == 'usual';
    final list = isUsual ? _usualPortions : _basisPortions;
    final idx = list.length;
    list.add(entry);

    if (p.isDefault) {
      if (isUsual) {
        _usualDefaultIndex = idx;
        foundUsualDefault = true;
      } else {
        _basisDefaultIndex = idx;
        foundBasisDefault = true;
      }
    }
  }

  if (_basisPortions.isEmpty) _basisPortions.add(PortionEntry(unit: 'gram (g)', amount: 100, grams: 100));
  if (_usualPortions.isEmpty) _usualPortions.add(PortionEntry());

  // prefer the user-facing default if present
  if (foundUsualDefault) {
    _lastDefaultGroup = 'usual';
  } else if (foundBasisDefault) {
    _lastDefaultGroup = 'basis';
  }

  setState(() {});
}


String _fmtNum(num v) {
  final s = v.toStringAsFixed(2);
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}


  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _calController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    _densityController.dispose();

    // Dispose dynamically created controllers
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final p in _basisPortions) { p.dispose(); }
for (final p in _usualPortions) { p.dispose(); }

    super.dispose();
  }

  // ---------- Helpers ----------

  String _baseName(String label) {
  final i = label.indexOf(' ('); // strips units like " (g)"
  return i == -1 ? label : label.substring(0, i);
}
String _componentsTitle(String label) => '${_baseName(label)} Components';



  TextEditingController _controllerFor(String key) {
    return _controllers.putIfAbsent(key, () => TextEditingController());
  }

  List<TextInputFormatter> get _numericFormatters => [
  FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d*$')),
];


Map<String, dynamic> _collectPayload() {
  double? parseNum(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  final payload = <String, dynamic>{
    'name' : _nameController.text.trim(),
    'brand': _brandController.text.trim(),
  };

  void putNum(String key, TextEditingController c) {
    final v = parseNum(c);
    if (v != null) payload[key] = v;
  }

  // Canonical codes (what your repo maps on), plus friendly aliases for good measure.
putNum('KCAL',      _calController);
putNum('PROTEIN_G', _proteinController);
putNum('CARB_G',    _carbController);
putNum('FAT_G',     _fatController);

// ✅ Add aliases only if the canonical key was actually set
void aliasIfSet(String alias, String canonical) {
  if (payload.containsKey(canonical) && !payload.containsKey(alias)) {
    payload[alias] = payload[canonical];
  }
}

aliasIfSet('calories',  'KCAL');
aliasIfSet('protein_g', 'PROTEIN_G');
aliasIfSet('carbs_g',   'CARB_G');
aliasIfSet('fat_g',     'FAT_G');
// legacy alias some forms still use
aliasIfSet('fats_g',    'FAT_G');

  // Optional density (lets your logging page stop assuming 1.0 g/mL later)
  putNum('density_g_per_ml', _densityController);

  // Dynamic leaves: include valid numbers; avoid overwriting same-named leaves.
// We keep the first occurrence under its leaf label, and stash any duplicates
// under a separate map keyed by full breadcrumb path.
final extendedPaths = <String, double>{};

for (final e in _controllers.entries) {
  final t = e.value.text.trim();
  if (t.isEmpty) continue;

  final v = double.tryParse(t);
  if (v == null) continue;

  final path = e.key;                   // e.g., "Micronutrients > Minerals > Chloride (mg)"
  final last = path.split(' > ').last;  // e.g., "Chloride (mg)"

  if (!payload.containsKey(last)) {
    payload[last] = v;                  // mapper-friendly key
  } else {
    extendedPaths[path] = v;            // preserve duplicate under full path
  }
}

if (extendedPaths.isNotEmpty) {
  payload['__extended_paths__'] = extendedPaths; // harmless to DAO; future-proof
}


  // v23 portion payload
  payload['portions'] = _portionsPayload(
    basisDefaultIndex: _basisDefaultIndex,
    usualDefaultIndex: _usualDefaultIndex,
  );

  // If editing, include the ID so the caller updates instead of inserting.
  final id = widget.initialFoodId;
  if (id != null) payload['food_id'] = id;

  return payload;
}


void _onCancel() => Navigator.of(context).pop();

void _onSave() {
  if (_formKey.currentState!.validate()) {
    Navigator.of(context).pop(_collectPayload());
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialFoodId == null ? 'Customize Food' : 'Edit Food'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  floatingActionButton: SafeArea(
    minimum: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FloatingActionButton.extended(
          heroTag: 'fab-cancel',
          onPressed: _onCancel,
          icon: const Icon(Icons.close),
          label: const Text('Cancel'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        FloatingActionButton.extended(
          heroTag: 'fab-save',
          onPressed: _onSave,
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
      ],
    ),
  ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Name & Brand
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter a name' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // 2. Images
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          color: Colors.grey[200],
                          child: _foodImagePath == null
                              ? const Center(child: Icon(Icons.photo, size: 40, color: Colors.grey))
                              : Image.network(_foodImagePath!, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: pick a photo of the food (ImagePicker -> File -> setState)
                          },
                          child: const Text('Food Photo'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          color: Colors.grey[200],
                          child: _labelImagePath == null
                              ? const Center(child: Icon(Icons.photo, size: 40, color: Colors.grey))
                              : Image.network(_labelImagePath!, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: pick a photo of the nutrition label
                          },
                          child: const Text('Label Photo'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Portion Info
              // After the Images Row:
const SizedBox(height: 20),
_buildPortionCard(),        // <<< NEW
const SizedBox(height: 12),

//TODO: make this density bit properly fit in
const SizedBox(height: 12),
_buildNumberField(label: 'Density (g/mL)', controller: _densityController),

              // 3. Calories (kept separate)
              _buildNumberField(label: 'Calories (kcal)', controller: _calController),
              const SizedBox(height: 12),

              // 4. Macronutrients (Protein, Carbs, Fats) unified in one card
              _buildGroupCard(
                'Macronutrients',
                _macroNodes,
                groupKey: 'Macronutrients',
                controllerOverrides: {
                  'Macronutrients > Protein (g)': _proteinController,
                  'Macronutrients > Carbs (g)': _carbController,
                  'Macronutrients > Fats (g)': _fatController,
                },
                initiallyExpanded: true,
              ),
              const SizedBox(height: 12),

              // 5. Micronutrients & Additional Components
              _buildGroupCard('Micronutrients', _micronutrientNodes, groupKey: 'Micronutrients', initiallyExpanded: false,),
              const SizedBox(height: 12),
              _buildGroupCard('Additional Components', _additionalNodes, groupKey: 'Additional Components', initiallyExpanded: false,),
              const SizedBox(height: 20),

              
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI Builders ----------

  Widget _buildGroupCard(
    String title,
    List<NutrientNode> nodes, {
    required String groupKey,
    Map<String, TextEditingController>? controllerOverrides,
    bool initiallyExpanded = true, // toggle default here
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey('group_$groupKey'),
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: _buildNodeWidgets(
          nodes,
          parentPath: groupKey,
          depth: 0,
          controllerOverrides: controllerOverrides,
        ),
      ),
    ),
  );
}

  /// Returns a uniform numeric field used everywhere
  Widget _buildNumberField({required String label, TextEditingController? controller, String? keyPath, int depth = 0}) {
    final TextEditingController ctrl = controller ?? _controllerFor(keyPath ?? label);
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
      child: TextFormField(
        key: keyPath != null ? PageStorageKey('field_$keyPath') : null, // ✅ unique per field
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: _numericFormatters,
      ),
    );
  }

  /// Builds nodes so that each parent has its own numeric field, with a
  /// separate Breakdown dropdown *under* it (instead of tapping the parent row).
  List<Widget> _buildNodeWidgets(
    List<NutrientNode> nodes, {
    required String parentPath,
    required int depth,
    Map<String, TextEditingController>? controllerOverrides,
  }) {
    final List<Widget> widgets = [];
    for (final node in nodes) {
      final String path = '$parentPath > ${node.label}';
      // Parent/leaf numeric field (uniform layout)
      widgets.add(_buildNumberField(
        label: node.label,
        keyPath: path,
        depth: depth,
        controller: controllerOverrides != null ? controllerOverrides[path] : null,
      ));

      if (node.children.isNotEmpty) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: (depth + 1) * 16.0, right: 8),
            child: _breakdownTile(
              keyPath: path,
              title: _componentsTitle(node.label), // e.g., "Protein Components"
              children: _buildNodeWidgets(
                node.children,
                parentPath: path,
                depth: depth + 1,
                controllerOverrides: controllerOverrides,
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  Widget _breakdownTile({
    required List<Widget> children,
    required String keyPath,
    required String title,
    }) {
  final theme = Theme.of(context);
  return Theme(
    data: theme.copyWith(
      dividerColor: Colors.transparent,
      listTileTheme: const ListTileThemeData(
        dense: true,                     // ← tighter ListTile
        minVerticalPadding: 0,           // ← remove extra vertical padding
        contentPadding: EdgeInsets.zero, // ← no horizontal padding
        visualDensity: VisualDensity(
          horizontal: 0,
          vertical: -3,                  // ← make header shorter (try -2 to -4)
        ),
      ),
      iconTheme: const IconThemeData(size: 18), // ← smaller expand/collapse arrow
    ),
    child: ExpansionTile(
      key: PageStorageKey('breakdown_$keyPath'), // keeps state, avoids collisions
      tilePadding: EdgeInsets.zero, // already zero; keeps it flush
      childrenPadding: EdgeInsets.zero,
      title: Text(title, style: theme.textTheme.bodyMedium),
      children: children,
    ),
  );
}

// Convert "gram (g)" -> "g", "milliliter (mL)" -> "mL", keep others as-is
String _shortUnit(String u) {
  switch (u) {
    case 'gram (g)': return 'g';
    case 'milligram (mg)': return 'mg';
    case 'microgram (µg)': return 'µg';
    case 'kilogram (kg)': return 'kg';
    case 'ounce (oz)': return 'oz';
    case 'pound (lb)': return 'lb';
    case 'milliliter (mL)': return 'mL';
    case 'liter (L)': return 'L';
    case 'teaspoon (tsp)': return 'tsp';
    case 'tablespoon (tbsp)': return 'tbsp';
    case 'cup': return 'cup';
    case 'fluid ounce (fl oz)': return 'fl oz';
  }
  return u;
}

// Compose a clean "measure_name" from unit + amount, e.g. "100 g" or "1 cup"
String _measureNameFrom(PortionEntry e) {
  double? a = double.tryParse(e.amountCtrl.text.trim());
  final unitShort = _shortUnit(e.unit);
  if (a == null) {
    final g  = double.tryParse(e.gramsCtrl.text.trim());
    final ml = double.tryParse(e.mlCtrl.text.trim());
    if (unitShort == 'g'  && g  != null) a = g;
    if (unitShort == 'mL' && ml != null) a = ml;
  }
  if (a == null) return unitShort;      // e.g. "cup"
  return '${_fmtNum(a)} $unitShort';    // e.g. "100 g", "240 mL"
}


// Build JSON-ish payload for both lists, collapsing to what DB needs
List<Map<String, dynamic>> _portionsPayload({
  required int basisDefaultIndex,
  required int usualDefaultIndex,
}) {
  final all = <({PortionEntry row, String list, int index})>[];

  for (var i = 0; i < _basisPortions.length; i++) {
    all.add((row: _basisPortions[i], list: 'basis', index: i));
  }
  for (var i = 0; i < _usualPortions.length; i++) {
    all.add((row: _usualPortions[i], list: 'usual', index: i));
  }

  // Decide single global default based on the *last* group the user touched.
  int? defaultGlobal;
  final basisCount = _basisPortions.length;
  final usualCount = _usualPortions.length;

  int clampBasis(int idx) =>
      basisCount == 0 ? 0 : (idx.clamp(0, basisCount - 1)).toInt();
  int clampUsual(int idx) =>
      usualCount == 0 ? 0 : (idx.clamp(0, usualCount - 1)).toInt();

  if (_lastDefaultGroup == 'basis' && basisCount > 0) {
    defaultGlobal = clampBasis(basisDefaultIndex);
  } else if (_lastDefaultGroup == 'usual' && usualCount > 0) {
    defaultGlobal = basisCount + clampUsual(usualDefaultIndex);
  } else if (basisCount > 0) {
    // fallback if last group is empty
    defaultGlobal = clampBasis(basisDefaultIndex);
  } else if (usualCount > 0) {
    defaultGlobal = basisCount + clampUsual(usualDefaultIndex);
  }

  final out = <Map<String, dynamic>>[];

  for (var i = 0; i < all.length; i++) {
    final r = all[i];

    // Parse current fields
    final amount = double.tryParse(r.row.amountCtrl.text.trim());
    final unitShort = _shortUnit(r.row.unit);
    double? grams = double.tryParse(r.row.gramsCtrl.text.trim());
    double? ml    = double.tryParse(r.row.mlCtrl.text.trim());

    // NEW: map Amount + Unit to grams/mL if user left those fields empty
    if (grams == null && unitShort == 'g'  && amount != null) grams = amount;
    if (ml    == null && unitShort == 'mL' && amount != null) ml    = amount;

    // If we still can't physically map this row, skip it
    if (grams == null && ml == null) continue;

    final measureName = _measureNameFrom(r.row);

    out.add({
      'measure_name': measureName,
      'gram_weight' : grams,
      'ml_volume'   : ml,
      'is_default'  : (defaultGlobal != null && i == defaultGlobal),
      // v23 extras:
      'list_kind'   : r.list,          // 'basis' | 'usual'
      'sort_order'  : r.index,
      'amount'      : amount,
      'unit'        : unitShort,
      'label'       : null,
    });
  }

  // Ensure exactly one default if we have any rows left after filtering
  if (out.isNotEmpty && !out.any((m) => m['is_default'] == true)) {
    out.first['is_default'] = true;
  }

  // If nothing provided at all, inject a safe default "100 g"
  if (out.isEmpty) {
    out.add({
      'measure_name': '100 g',
      'gram_weight' : 100.0,
      'ml_volume'   : null,
      'is_default'  : true,
      'list_kind'   : 'basis',
      'sort_order'  : 0,
      'amount'      : 100.0,
      'unit'        : 'g',
      'label'       : null,
    });
  }

  return out;
}


Widget _buildPortionCard() {
  final theme = Theme.of(context);
  return Card(
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade300),
    ),
    child: Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: const PageStorageKey('group_PortionInfo'),
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: const Text('Portion Info', style: TextStyle(fontWeight: FontWeight.w600)),
        children: [
          // A) Basis for given nutrient values
          _buildPortionList(
            title: 'Portioning basis for the nutritional values',
            list: _basisPortions,
            groupKey: 'basis',
            defaultIndex: _basisDefaultIndex,
            onDefaultChanged: (i) => setState(() {
              _basisDefaultIndex = i;
              _lastDefaultGroup = 'basis';
            }),
            initiallyExpanded: true,
          ),
          const SizedBox(height: 12),

          // B) Usual portion to be consumed by user
          _buildPortionList(
            title: 'Usual portion to be consumed by user',
            list: _usualPortions,
            groupKey: 'usual',
            defaultIndex: _usualDefaultIndex,
            onDefaultChanged: (i) => setState(() {
              _usualDefaultIndex = i;
              _lastDefaultGroup = 'usual';
            }),
            initiallyExpanded: false,
          ),
        ],
      ),
    ),
  );
}


Widget _buildPortionList({
  required String title,
  required List<PortionEntry> list,
  required String groupKey, // 'basis' | 'usual'
  required int defaultIndex,
  required ValueChanged<int> onDefaultChanged,
  bool initiallyExpanded = false, // ← new param
}) {
  final theme = Theme.of(context);
  return Theme(
    data: theme.copyWith(
      dividerColor: Colors.transparent,
      listTileTheme: const ListTileThemeData(
        dense: true,
        visualDensity: VisualDensity(horizontal: 0, vertical: -2),
        contentPadding: EdgeInsets.zero,
      ),
      iconTheme: const IconThemeData(size: 18),
    ),
    child: ExpansionTile(
      key: PageStorageKey('portion_list_$groupKey'),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 4),
      children: [
        ...List.generate(list.length, (i) {
          return _portionRow(
            entry: list[i],
            index: i,
            groupKey: groupKey,
            onDefault: () => onDefaultChanged(i),  // (or switch to Radio<int> later)
            onRemove: list.length > 1
    ? () => setState(() {
          final removedIndex = i;
          list.removeAt(i).dispose();

          final isUsual = groupKey == 'usual';
          final currentDefault = isUsual ? _usualDefaultIndex : _basisDefaultIndex;

          int nextDefault = currentDefault;
          if (currentDefault == removedIndex) {
  nextDefault = ((removedIndex - 1).clamp(0, list.length - 1));
} else if (removedIndex < currentDefault) {
  nextDefault = ((currentDefault - 1).clamp(0, list.length - 1));
}

          if (isUsual) {
            _usualDefaultIndex = nextDefault;
          } else {
            _basisDefaultIndex = nextDefault;
          }
          _lastDefaultGroup = groupKey;
        })
    : null,

          );
        }),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => list.add(PortionEntry())),
            icon: const Icon(Icons.add),
            label: const Text('Add portion'),
          ),
        ),
      ],
    ),
  );
}


Widget _portionRow({
  required PortionEntry entry,
  required int index,
  required String groupKey,
  required VoidCallback onDefault,
  VoidCallback? onRemove,
}) {
  final unitKey   = PageStorageKey('portion_${groupKey}_${index}_unit');
final amountKey = PageStorageKey('portion_${groupKey}_${index}_amount');
final gramsKey  = PageStorageKey('portion_${groupKey}_${index}_grams');
final mlKey     = PageStorageKey('portion_${groupKey}_${index}_ml');

final groupIsUsual = groupKey == 'usual';
final groupDefaultIndex = groupIsUsual ? _usualDefaultIndex : _basisDefaultIndex;


  return Card(
    margin: const EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Column(
        children: [
          // First line: radio + unit + amount
          Row(
            children: [
              Radio<int>(
  value: index,
  groupValue: groupDefaultIndex,
  onChanged: (_) => onDefault(),
  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
),
              const SizedBox(width: 4),
              Expanded(
  flex: 6,
  child: Builder(
    builder: (ctx) {
      // Build units ONCE and reuse for items + selectedItemBuilder
      final units = (() {
        final u = [..._allUnits];
        if (!u.contains(entry.unit)) u.insert(0, entry.unit); // preserve unknown unit at top
        return u;
      })();

      return DropdownButtonFormField<String>(
        key: unitKey,
        value: units.contains(entry.unit) ? entry.unit : units.first,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, size: 18),
        decoration: const InputDecoration(
          labelText: 'Unit',
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        selectedItemBuilder: (ctx) =>
            units.map((u) => Text(u, overflow: TextOverflow.ellipsis)).toList(),
        items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
        onChanged: (v) => entry.unit = v ?? entry.unit,
      );
    },
  ),
),




              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextFormField(
                  key: amountKey,
                  controller: entry.amountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: _numericFormatters,
                  onTapOutside: (_) {}, // keeps focus sane on taps
                ),
              ),
              const SizedBox(width: 4),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove',
                  constraints: const BoxConstraints.tightFor(width: 36, height: 36), // 👈 smaller hitbox
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Second line: grams + mL
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: gramsKey,
                  controller: entry.gramsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Weight (g)',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: _numericFormatters,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  key: mlKey,
                  controller: entry.mlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Volume (mL)',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: _numericFormatters,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
        ],
      ),
    ),
  );
}


}

// ---------- Data Model for Nested Nutrients ----------

class NutrientNode {
  final String label;
  final List<NutrientNode> children;
  const NutrientNode(this.label, [this.children = const []]);
}

// Macronutrients tree (top-level macros with their detailed children)
final List<NutrientNode> _macroNodes = [
  NutrientNode('Protein (g)', _proteinNodes),
  NutrientNode('Carbs (g)', _carbNodes),
  NutrientNode('Fats (g)', _fatNodes),
];

// Protein amino acids
const List<NutrientNode> _proteinNodes = [
  NutrientNode('Alanine (g)'),
  NutrientNode('Arginine (g)'),
  NutrientNode('Asparagine (g)'),
  NutrientNode('Aspartic acid (g)'),
  NutrientNode('Cysteine (g)'),
  NutrientNode('Glutamic acid (g)'),
  NutrientNode('Glutamine (g)'),
  NutrientNode('Glycine (g)'),
  NutrientNode('Histidine (g)'),
  NutrientNode('Isoleucine (g)'),
  NutrientNode('Leucine (g)'),
  NutrientNode('Lysine (g)'),
  NutrientNode('Methionine (g)'),
  NutrientNode('Phenylalanine (g)'),
  NutrientNode('Proline (g)'),
  NutrientNode('Serine (g)'),
  NutrientNode('Threonine (g)'),
  NutrientNode('Tryptophan (g)'),
  NutrientNode('Tyrosine (g)'),
  NutrientNode('Valine (g)'),
];

// Carbohydrates tree
const List<NutrientNode> _carbNodes = [
  NutrientNode('Net Carbs (g)'),
  NutrientNode('Glycemic Index'),
  NutrientNode('Glycemic Load'),
  NutrientNode('Starch (g)', [
    NutrientNode('Polysaccharides (g)', [
      NutrientNode('Amylose (g)'),
      NutrientNode('Amylopectin (g)'),
    ]),
    NutrientNode('Digestibility', [
      NutrientNode('Rapidly Digestible Starch (RDS) (g)'),
      NutrientNode('Slowly Digestible Starch (SDS) (g)'),
      NutrientNode('Resistant Starch (RS) (g)', [
        NutrientNode('RS1 (g)'),
        NutrientNode('RS2 (g)'),
        NutrientNode('RS3 (g)'),
        NutrientNode('RS4 (g)'),
      ]),
    ]),
  ]),
  NutrientNode('Sugars (g)', [
    NutrientNode('Monosaccharides (g)', [
      NutrientNode('Glucose (g)'),
      NutrientNode('Fructose (g)'),
      NutrientNode('Galactose (g)'),
    ]),
    NutrientNode('Disaccharides (g)', [
      NutrientNode('Sucrose (g)'),
      NutrientNode('Lactose (g)'),
      NutrientNode('Maltose (g)'),
    ]),
    NutrientNode('Oligosaccharides (g)', [
      NutrientNode('Raffinose (g)'),
      NutrientNode('Stachyose (g)'),
      NutrientNode('Verbascose (g)'),
    ]),
    NutrientNode('Sugar Alcohols (g)', [
      NutrientNode('Xylitol (g)'),
      NutrientNode('Erythritol (g)'),
      NutrientNode('Sorbitol (g)'),
      NutrientNode('Mannitol (g)'),
      NutrientNode('Isomalt (g)'),
      NutrientNode('Lactitol (g)'),
    ]),
    NutrientNode('Added Sugars (g)', [
      NutrientNode('High-fructose corn syrup (g)'),
      NutrientNode('Cane sugar (g)'),
      NutrientNode('Maple syrup (g)'),
      NutrientNode('Honey (g)'),
      NutrientNode('Agave nectar (g)'),
      NutrientNode('Brown sugar (g)'),
      NutrientNode('Molasses (g)'),
    ]),
  ]),
  NutrientNode('Fiber (g)', [
    NutrientNode('Soluble Fiber (g)', [
      NutrientNode('Pectin (g)'),
      NutrientNode('Beta-glucans (g)'),
      NutrientNode('Inulin (g)'),
      NutrientNode('Psyllium (g)'),
      NutrientNode('Gums (g)'),
    ]),
    NutrientNode('Insoluble (g)', [
      NutrientNode('Cellulose (g)'),
      NutrientNode('Hemicellulose (g)'),
      NutrientNode('Lignin (g)'),
    ]),
    NutrientNode('Functional Fibers (g)', [
      NutrientNode('Resistant Starch (RS1–RS4) (g)'),
      NutrientNode('Fructooligosaccharides (FOS) (g)'),
      NutrientNode('Galactooligosaccharides (GOS) (g)'),
    ]),
  ]),
];

// Fats tree
const List<NutrientNode> _fatNodes = [
  NutrientNode('Saturated Fat (g)', [
    NutrientNode('Palmitic Acid (g)'),
    NutrientNode('Stearic Acid (g)'),
    NutrientNode('Lauric Acid (g)'),
    NutrientNode('Myristic Acid (g)'),
    NutrientNode('Capric Acid (g)'),
    NutrientNode('Caprylic Acid (g)'),
    NutrientNode('Caproic Acid (g)'),
  ]),
  NutrientNode('Trans Fat (g)', [
    NutrientNode('Artificial Trans Fats (g)'),
    NutrientNode('Natural Trans Fats (g)'),
  ]),
  NutrientNode('Unsaturated Fat (g)', [
    NutrientNode('Monounsaturated Fat (g)', [
      NutrientNode('Oleic Acid (g)'),
      NutrientNode('Palmitoleic Acid (g)'),
      NutrientNode('Vaccenic Acid (g)'),
    ]),
    NutrientNode('Polyunsaturated Fat (g)', [
      NutrientNode('Omega-3 Fatty Acids (g)', [
        NutrientNode('ALA (Alpha-Linolenic Acid) (g)'),
        NutrientNode('DHA (Docosahexaenoic Acid) (g)'),
        NutrientNode('EPA (Eicosapentaenoic Acid) (g)'),
      ]),
      NutrientNode('Omega-6 Fatty Acids (g)', [
        NutrientNode('Linoleic Acid (g)'),
        NutrientNode('Arachidonic Acid (g)'),
      ]),
      NutrientNode('Omega-9 Fatty Acids (g)', [
        NutrientNode('Oleic Acid (g)'),
        NutrientNode("Mead's Acid (g)"),
      ]),
    ]),
    NutrientNode('Other Lipid Types', [
      NutrientNode('Phospholipids (e.g., Lecithin) (g)'),
      NutrientNode('Sterols', [
        NutrientNode('Cholesterol (g)'),
        NutrientNode('Phytosterols (g)'),
      ]),
      NutrientNode('Triglycerides (g)'),
    ]),
  ]),
];

// Micronutrients tree
const List<NutrientNode> _micronutrientNodes = [
  NutrientNode('Vitamins', [
    NutrientNode('Vitamin A (Retinol & Beta-Carotene) (mg)'),
    NutrientNode('Vitamin B1 (Thiamine) (mg)'),
    NutrientNode('Vitamin B2 (Riboflavin) (mg)'),
    NutrientNode('Vitamin B3 (Niacin) (mg)'),
    NutrientNode('Vitamin B5 (Pantothenic Acid) (mg)'),
    NutrientNode('Vitamin B6 (Pyridoxine) (mg)'),
    NutrientNode('Vitamin B7 (Biotin) (mcg)'),
    NutrientNode('Vitamin B9 (Folate) (mcg)'),
    NutrientNode('Vitamin B12 (Cobalamin) (mcg)'),
    NutrientNode('Vitamin C (Ascorbic Acid) (mg)'),
    NutrientNode('Vitamin D (mcg)', [
      NutrientNode('D2 (Ergocalciferol) (mcg)'),
      NutrientNode('D3 (Cholecalciferol) (mcg)'),
    ]),
    NutrientNode('Vitamin E (Tocopherols) (mg)'),
    NutrientNode('Vitamin K (mcg)', [
      NutrientNode('K1 (Phylloquinone) (mcg)'),
      NutrientNode('K2 (Menaquinone) (mcg)'),
    ]),
  ]),
  NutrientNode('Minerals', [
    NutrientNode('Boron (mg)'),
    NutrientNode('Copper (mg)'),
    NutrientNode('Chromium (mcg)'),
    NutrientNode('Chloride (mg)'),
    NutrientNode('Choline (mg)'),
    NutrientNode('Fluoride (mg)'),
    NutrientNode('Iodine (mcg)'),
    NutrientNode('Iron (mg)'),
    NutrientNode('Molybdenum (mcg)'),
    NutrientNode('Manganese (mg)'),
    NutrientNode('Phosphorus (mg)'),
    NutrientNode('Selenium (mcg)'),
    NutrientNode('Sulfur (mg)'),
    NutrientNode('Zinc (mg)'),
    NutrientNode('Electrolytes', [
      NutrientNode('Sodium (mg)'),
      NutrientNode('Potassium (mg)'),
      NutrientNode('Chloride (mg)'),
      NutrientNode('Magnesium (mg)'),
      NutrientNode('Calcium (mg)'),
    ]),
  ]),
];

// Additional Components tree
const List<NutrientNode> _additionalNodes = [
  NutrientNode('Cholesterol (mg)'),
  NutrientNode('Water Content (g)'),
  NutrientNode('Alcohol (g)'),
  NutrientNode('Caffeine (mg)'),
  NutrientNode('Phytochemicals', [
    NutrientNode('Lutein (mg)'),
    NutrientNode('Zeaxanthin (mg)'),
  ]),
  NutrientNode('Antioxidants (mg)'),
  NutrientNode('Additives/Preservatives (if processed) (g)'),
  NutrientNode('Artificial Sweeteners', [
    NutrientNode('Aspartame (mg)'),
    NutrientNode('Sucralose (mg)'),
    NutrientNode('Saccharin (mg)'),
    NutrientNode('Acesulfame K (mg)'),
  ]),
  NutrientNode('Food Enzymes', [
    NutrientNode('Amylase (mg)'),
    NutrientNode('Lactase (mg)'),
    NutrientNode('Bromelain (mg)'),
    NutrientNode('Papain (mg)'),
  ]),
  NutrientNode('Prebiotics (g)', [
    NutrientNode('Inulin (g)'),
    NutrientNode('FOS (g)'),
    NutrientNode('GOS (g)'),
  ]),
  NutrientNode('Probiotics (CFU)', [
    NutrientNode('Lactobacillus (CFU)'),
    NutrientNode('Bifidobacterium (CFU)'),
    NutrientNode('Saccharomyces boulardii (CFU)'),
  ]),
  NutrientNode('Anti-Nutrients', [
    NutrientNode('Tannins (mg)'),
    NutrientNode('Oxalates (mg)'),
    NutrientNode('Lectins (mg)'),
    NutrientNode('Phytates (mg)'),
  ]),
  NutrientNode('Contaminants (mcg)', [
    NutrientNode('Lead (mcg)'),
    NutrientNode('Mercury (mcg)'),
    NutrientNode('Arsenic (mcg)'),
  ]),
  NutrientNode('Functional Additives', [
    NutrientNode('Emulsifiers (g)', [
      NutrientNode('Carrageenan (g)'),
      NutrientNode('Xanthan gum (g)'),
    ]),
    NutrientNode('Thickeners (g)', [
      NutrientNode('Guar gum (g)'),
    ]),
    NutrientNode('Colorants (mg)'),
    NutrientNode('Flavorings (mg)'),
  ]),
];


// ----- Portion Info state -----

class PortionEntry {
  PortionEntry({
    this.unit = 'gram (g)',
    double? amount,
    double? grams,
    double? ml,
  })  : amountCtrl = TextEditingController(text: amount?.toString() ?? ''),
        gramsCtrl  = TextEditingController(text: grams?.toString() ?? ''),
        mlCtrl     = TextEditingController(text: ml?.toString() ?? '');

  String unit;
  final TextEditingController amountCtrl;
  final TextEditingController gramsCtrl;
  final TextEditingController mlCtrl;

  void dispose() {
    amountCtrl.dispose();
    gramsCtrl.dispose();
    mlCtrl.dispose();
  }

  Map<String, dynamic> toJson() => {
        'unit': unit,
        'amount': double.tryParse(amountCtrl.text),
        'grams': double.tryParse(gramsCtrl.text),
        'milliliters': double.tryParse(mlCtrl.text),
      };
}

