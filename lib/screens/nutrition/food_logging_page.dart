// File: lib/screens/nutrition/food_logging_page.dart



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/nutrition_models.dart';
import '../../repositories/app_repository.dart';
import '../../providers/nutrition_profile.dart';

import 'food_customization_page.dart';

class FoodLoggingPage extends StatefulWidget {
  const FoodLoggingPage({super.key});

  @override
  State<FoodLoggingPage> createState() => _FoodLoggingPageState();
}

class _FoodLoggingPageState extends State<FoodLoggingPage> {
  // 0=Scan, 1=Search, 2=Pre-Planned, 3=Custom
  final List<bool> _tabs = [false, true, false, false];

  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _searching = false;
  List<Food> _results = [];

  

  AppRepository get _repo => AppRepository();

  final Map<int, Future<_MacroPreview>> _previewFuture = {};

Future<_MacroPreview> _loadPreview(Food f) async {
  if (f.id == null) return _MacroPreview.empty('—');

  // 1) choose portion (default → first → 100 g fallback)
  final portions = await _repo.getPortionsForFood(f.id!);
  FoodPortion? portion;
  if (portions.isEmpty) {
    portion = null;                              // we'll fallback to 100 g below
  } else {
    portion = portions.firstWhere(
      (p) => p.isDefault,
      orElse: () => portions.first,             // safe; list not empty here
    );
  }

  // fallback virtual "100 g"
  portion ??= FoodPortion(
    id: null,
    foodId: f.id!,
    measureName: '100 g',
    gramWeight: 100,
    mlVolume: null,
    isDefault: true,
  );

  // 2) resolve grams for 1 portion
  double? grams = portion.gramWeight;
  if (grams == null && portion.mlVolume != null && f.densityGPerMl != null) {
    grams = portion.mlVolume! * f.densityGPerMl!;
  }

  // 3) fetch nutrients per 100g
  // 3) fetch nutrients per 100g (code-keyed map)
final per100 = await _repo.getFoodNutrientsPer100gByCode(f.id!);
final double? p100 = per100['PROTEIN'];
final double? f100 = per100['FAT'];
final double? c100 = per100['CARB'];
  // 4) scale to the chosen portion (default to 100g if grams unknown)
  final g = (grams ?? 100).toDouble();
  final scale = g / 100.0;

  int? pG = p100 == null ? null : (p100 * scale).round();
  int? fG = f100 == null ? null : (f100 * scale).round();
  int? cG = c100 == null ? null : (c100 * scale).round();

  return _MacroPreview(
    proteinG: pG,
    fatG: fG,
    carbG: cG,
    portionLabel: portion.measureName,
  );
}

String _fmtInt(int? v) => v == null ? '--' : v.toString();

/// Compose like: "23P 8F 0C • 1 cutlet"
String _macroLine(_MacroPreview m) =>
    '${_fmtInt(m.proteinG)}P ${_fmtInt(m.fatG)}F ${_fmtInt(m.carbG)}C • ${m.portionLabel}';


  @override
  void initState() {
    super.initState();
    _kickoffSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }
  

  void _kickoffSearch(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      setState(() => _searching = true);
      try {
        final rows = await _repo.searchFoods(q, limit: 50);
        if (!mounted) return;
        setState(() => _results = rows);
      } finally {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NutritionProfile>();

    // Show a slim status bar using provider's current totals/goals
    final kcal    = (p.totals?.kcal     ?? 0).round();
    final kcalTgt = (p.activeGoal?.kcalTarget ?? 0).round();
    final pro     = (p.totals?.proteinG ?? 0).round();
    final proTgt  = (p.activeGoal?.proteinG ?? 0).round();
    final fat     = (p.totals?.fatG     ?? 0).round();
    final fatTgt  = (p.activeGoal?.fatG ?? 0).round();
    final carb    = (p.totals?.carbsG   ?? 0).round();
    final carbTgt = (p.activeGoal?.carbsG ?? 0).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Food Logging')),
      body: Column(
        children: [
          // ─── Top stats row (live from provider) ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: _StatCard(label: 'Calories', value: '$kcal / $kcalTgt kcal')),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(label: 'Protein',  value: '$pro / $proTgt g')),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(label: 'Carbs',    value: '$carb / $carbTgt g')),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(label: 'Fat',      value: '$fat / $fatTgt g')),
              ],
            ),
          ),

          // ─── Tabs ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ToggleButtons(
              isSelected: _tabs,
              onPressed: (i) => setState(() {
                for (var idx = 0; idx < _tabs.length; idx++) {
                  _tabs[idx] = idx == i;
                }
              }),
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: Theme.of(context).primaryColor,
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Scan')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Search')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Pre-Planned')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Custom')),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ─── Content ───────────────────────────────────────────────────────
          Expanded(
            child: _tabs[0]
                ? const Center(child: Text('Scan interface coming soon'))
                : _tabs[1]
                    ? _buildSearchList(context)
                    : _tabs[2]
                        ? const Center(child: Text('Pre-Planned meals coming soon'))
                        : _buildCustomList(context),
          ),

          // ─── Bottom search & add row (search filter + close) ──────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search for a food...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: _kickoffSearch,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchList(BuildContext context) {
    if (_searching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return const Center(child: Text('No foods found.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final f = _results[i];
        return Card(
          child: ListTile(
            title: Text(f.name),
            subtitle: FutureBuilder<_MacroPreview>(
              future: _previewFuture[f.id!] ??= _loadPreview(f),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Text('—'); // tiny placeholder while loading
                }
                final m = snap.data!;
                return Text(_macroLine(m));
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _openAddSheet(context, f),
            ),
            onTap: () => _openAddSheet(context, f),
          ),
        );
      },
    );
  }

  Widget _buildCustomList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        return Card(
          child: ListTile(
            title: const Text('Add New Food Item'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FoodCustomizationPage()),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openAddSheet(BuildContext context, Food food) async {
    final portions = await _repo.getPortionsForFood(food.id!);

    // Choose default portion if flagged; otherwise first; fallback to "100 g" grams-only.
    FoodPortion? selected = portions.firstWhere(
      (p) => p.isDefault,
      orElse: () => portions.isNotEmpty ? portions.first : FoodPortion(
        id: null,
        foodId: food.id!,
        measureName: '100 g',
        gramWeight: 100,
        mlVolume: null,
        isDefault: true,
      ),
    );

    MealType meal = MealType.breakfast;
    double qty = 1.0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16, right: 16, top: 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setB) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(food.name, style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 8),

                  // Meal chips
                  Wrap(
                    spacing: 8,
                    children: MealType.values.map((m) {
                      final selectedChip = m == meal;
                      final label = m.name[0].toUpperCase() + m.name.substring(1);
                      return ChoiceChip(
                        label: Text(label),
                        selected: selectedChip,
                        onSelected: (_) => setB(() => meal = m),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // Portion dropdown
                  Row(
                    children: [
                      const Text('Portion:'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<FoodPortion>(
                          isExpanded: true,
                          value: selected,
                          items: portions.isNotEmpty
                              ? portions.map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text('${p.measureName}'
                                      '${p.gramWeight != null ? ' • ${p.gramWeight!.toStringAsFixed(0)} g' : ''}'
                                      '${p.mlVolume != null ? ' • ${p.mlVolume!.toStringAsFixed(0)} ml' : ''}'),
                                ))
                                  .toList()
                              : [
                                  DropdownMenuItem(
                                    value: selected,
                                    child: const Text('100 g'),
                                  )
                                ],
                          onChanged: (v) => setB(() => selected = v),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Quantity
                  Row(
                    children: [
                      const Text('Qty:'),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          initialValue: qty.toStringAsFixed(1),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (s) => setB(() => qty = double.tryParse(s) ?? 1.0),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(selected?.measureName ?? ''),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Add to Diary'),
                          onPressed: () async {
                            final profile = context.read<NutritionProfile>();
                            if (profile.current?.id == null) return;

                            final portionId = selected?.id; // may be null for the "100 g" fallback
                            await profile.addFood(
                              meal: meal,
                              foodId: food.id!,
                              portionId: portionId,
                              quantity: qty,
                              gramsOverride: (portionId == null && selected?.gramWeight != null)
                                  ? selected!.gramWeight! * qty
                                  : null,
                            );

                            if (!mounted || !(ctx.mounted)) return;   // guard both contexts
  Navigator.pop(ctx);                       // close sheet
  Navigator.pop(context, true);             // notify caller

                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );

  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}


class _MacroPreview {
  final int? proteinG;
  final int? fatG;
  final int? carbG;
  final String portionLabel;
  _MacroPreview({this.proteinG, this.fatG, this.carbG, required this.portionLabel});
  factory _MacroPreview.empty(String label) =>
      _MacroPreview(proteinG: null, fatG: null, carbG: null, portionLabel: label);
}