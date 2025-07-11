// File: lib/screens/food_customization_page.dart

import 'package:flutter/material.dart';

/// A page for adding or editing a food item.
/// Contains fields for name, brand, images, macros, and optional breakdowns.
class FoodCustomizationPage extends StatefulWidget {
  const FoodCustomizationPage({super.key});

  @override
  State<FoodCustomizationPage> createState() => _FoodCustomizationPageState();
}

class _FoodCustomizationPageState extends State<FoodCustomizationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the top‐level fields
  final _nameController    = TextEditingController();
  final _brandController   = TextEditingController();
  final _calController     = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbController    = TextEditingController();
  final _fatController     = TextEditingController();

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
    super.dispose();
  }

  bool get _hasCarbs   => (_carbController.text.isNotEmpty && double.tryParse(_carbController.text)! > 0);
  bool get _hasFats    => (_fatController.text.isNotEmpty  && double.tryParse(_fatController.text)! > 0);
  bool get _hasProtein => (_proteinController.text.isNotEmpty && double.tryParse(_proteinController.text)! > 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Food'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 1. Name & Brand
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              /// 2. Images
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
                            // TODO: pick a photo of the food
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

              /// 3. Macro inputs (with inline breakdowns)
TextFormField(
  controller: _calController,
  decoration: const InputDecoration(
    labelText: 'Calories (kcal)',
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.number,
),
const SizedBox(height: 12),

// — Protein & Breakdown —
TextFormField(
  controller: _proteinController,
  decoration: const InputDecoration(
    labelText: 'Protein (g)',
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.number,
  onChanged: (_) => setState(() {}),
),
if (_hasProtein) ...[
  const SizedBox(height: 8),
  ExpansionTile(
    title: const Text('Protein Breakdown'),
    children: [
      _buildSubField('Cysteine (g)'),
      _buildSubField('Histidine (g)'),
      _buildSubField('Isoleucine (g)'),
      _buildSubField('Leucine (g)'),
      _buildSubField('Lysine (g)'),
      _buildSubField('Methionine (g)'),
      _buildSubField('Phenylalanine (g)'),
      _buildSubField('Threonine (g)'),
      _buildSubField('Tyrosine (g)'),
      _buildSubField('Valine (g)'),
    ],
  ),
],
const SizedBox(height: 12),

// — Carbs & Breakdown —
TextFormField(
  controller: _carbController,
  decoration: const InputDecoration(
    labelText: 'Carbs (g)',
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.number,
  onChanged: (_) => setState(() {}),
),
if (_hasCarbs) ...[
  const SizedBox(height: 8),
  ExpansionTile(
    title: const Text('Carb Breakdown'),
    children: [
      _buildSubField('Fiber (g)'),
      _buildSubField('Net Carbs (g)'),
      _buildSubField('Starch (g)'),
      _buildSubField('Sugars (g)'),
      _buildSubField('Added Sugars (g)'),
    ],
  ),
],
const SizedBox(height: 12),

// — Fats & Breakdown —
TextFormField(
  controller: _fatController,
  decoration: const InputDecoration(
    labelText: 'Fats (g)',
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.number,
  onChanged: (_) => setState(() {}),
),
if (_hasFats) ...[
  const SizedBox(height: 8),
  ExpansionTile(
    title: const Text('Fat Breakdown'),
    children: [
      _buildSubField('Monounsaturated (g)'),
      _buildSubField('Polyunsaturated (g)'),
      _buildSubField('Omega-3 (g)'),
      _buildSubField(' • ALA (g)'),
      _buildSubField(' • DHA (g)'),
      _buildSubField(' • EPA (g)'),
      _buildSubField('Omega-6 (g)'),
      _buildSubField('Saturated (g)'),
      _buildSubField('Trans (g)'),
    ],
  ),
],
const SizedBox(height: 20),



              /// 5. Save / Cancel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: save or update the food entry
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
