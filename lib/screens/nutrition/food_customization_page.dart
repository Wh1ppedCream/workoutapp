// File: lib/screens/nutrition/food_customization_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A page for adding or editing a food item.
/// Updated: unified numeric field layout + parents can hold values
/// and expose a separate "Breakdown" dropdown *under* the field.
/// Now groups Protein/Carbs/Fats inside a single "Macronutrients" card.
class FoodCustomizationPage extends StatefulWidget {
  const FoodCustomizationPage({super.key});

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

  // Lazily created controllers for every leaf/parent field in the tree
  final Map<String, TextEditingController> _controllers = {};

  // TODO: hook up real Image/File objects
  String? _foodImagePath;
  String? _labelImagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _calController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    // Dispose dynamically created controllers
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- Helpers ----------

  String _baseName(String label) {
  final i = label.indexOf(' ('); // strips units like " (g)"
  return i == -1 ? label : label.substring(0, i);
}
String _componentsTitle(String label) => '${_baseName(label)} Components';


  double _toDouble(String s) => double.tryParse(s.trim()) ?? 0.0;

  TextEditingController _controllerFor(String key) {
    return _controllers.putIfAbsent(key, () => TextEditingController());
  }

  List<TextInputFormatter> get _numericFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
      ];

Map<String, dynamic> _collectPayload() {
  final payload = {
    'name': _nameController.text.trim(),
    'brand': _brandController.text.trim(),
    'calories': _toDouble(_calController.text),
    'protein_g': _toDouble(_proteinController.text),
    'carbs_g': _toDouble(_carbController.text),
    'fats_g': _toDouble(_fatController.text),
  };
  for (final entry in _controllers.entries) {
    final v = entry.value.text.trim();
    if (v.isNotEmpty) payload[entry.key] = double.tryParse(v) ?? v;
  }
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
        title: const Text('Customize Food'),
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
