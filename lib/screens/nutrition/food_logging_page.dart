// File: lib/screens/nutrition/food_logging_page.dart



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/nutrition_models.dart';
import '../../repositories/app_repository.dart';
import '../../providers/nutrition_profile.dart';

import 'food_customization_page.dart';

class _PlateItem {
  final Food food;
  FoodPortion? portion; // mutable, may be null for virtual 100 g
  double qty;           // mutable
  MealType meal;

  _PlateItem({
    required this.food,
    required this.portion,
    required this.qty,
    required this.meal,
  });
}


class _PlateSummary {
  final int kcal, p, f, c;
  const _PlateSummary(this.kcal, this.p, this.f, this.c);
}



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

  final List<_PlateItem> _plate = [];

  // Cache portions per food to avoid repeated queries
final Map<int, Future<List<FoodPortion>>> _portionCache = {};

// Cache per100g macros per food
final Map<int, Future<Map<String, double>>> _per100Cache = {};

Color _plateBorderColor(_PlateItem it, int index, BuildContext ctx) {
  final cs = Theme.of(ctx).colorScheme;

  // Option A: color by meal
  switch (it.meal) {
    case MealType.breakfast: return cs.primary.withValues(alpha: 0.55);
    case MealType.lunch:     return cs.tertiary.withValues(alpha: 0.55);
    case MealType.dinner:    return cs.secondary.withValues(alpha: 0.55);
    case MealType.snack:     return cs.error.withValues(alpha: 0.45);
  }
}


Future<List<FoodPortion>> _getPortions(int foodId) {
  return _portionCache.putIfAbsent(foodId, () => _repo.getPortionsForFood(foodId));
}

FoodPortion? _matchPortionById(List<FoodPortion> items, FoodPortion? want) {
  final wid = want?.id;
  if (wid == null) return null;
  for (final p in items) {
    if (p.id == wid) return p;
  }
  return null;
}


Future<Map<String, double>> _getPer100(int foodId) {
  // Uses your synonym-safe repo method; swap if you prefer another.
  return _per100Cache.putIfAbsent(foodId, () => _repo.getMacroPer100gLegacySafe(foodId));
}

// grams for ONE unit of the selected portion (fallbacks to 100g)
// TODO: replace the 1.0 g/mL fallback with real density when available.
double _gramsForOne(Food food, FoodPortion? portion) {
  if (portion == null) return 100.0;            // virtual 100 g
  if (portion.gramWeight != null) return portion.gramWeight!;
  if (portion.mlVolume != null) {
    final density = food.densityGPerMl ?? 1.0;  // ← TODO density
    return portion.mlVolume! * density;
  }
  return 100.0;
}

// Per-line totals (kcal / P / F / C) for given quantity
Future<_LineMacros> _calcLine(_PlateItem it) async {
  final per100 = await _getPer100(it.food.id!);
  final gOne = _gramsForOne(it.food, it.portion);
  final gTotal = gOne * (it.qty <= 0 ? 0 : it.qty);

  double pickKeys(List<String> keys) {
  double sum = 0;
  for (final k in keys) {
    final v = per100[k];
    if (v != null) sum += v;
  }
  return sum * (gTotal / 100.0);
}

final kcal = pickKeys(['ENERGY_KCAL', 'KCAL']);
final p    = pickKeys(['PROTEIN', 'PROTEIN_G']);
final f    = pickKeys(['FAT', 'FAT_G']);
final c    = pickKeys(['CARB', 'CARB_G']);

return _LineMacros(kcal: kcal, p: p, f: f, c: c);

}

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
// TODO(density): if gramWeight is missing and only mL is known, we assume 1 g/mL
// when the food has no stored density. Replace with real density when available.
if (grams == null && portion.mlVolume != null) {
  final density = f.densityGPerMl ?? 1.0; // 1 g/mL fallback
  grams = portion.mlVolume! * density;
}

  // 3) fetch nutrients per 100g (code-keyed map)
final per100 = await _repo.getMacroPer100gLegacySafe(f.id!);
double pick(List<String> keys) => keys
    .map((k) => per100[k])
    .whereType<num>()
    .map((n) => n.toDouble())
    .fold(0.0, (a, b) => a + b);

final p100 = pick(['PROTEIN','PROTEIN_G']);
final f100 = pick(['FAT','FAT_G']);
final c100 = pick(['CARB','CARB_G']);


  // 4) scale to the chosen portion (default to 100g if grams unknown)
  final g = (grams ?? 100).toDouble();
  final scale = g / 100.0;

  final int pG = (p100 * scale).round();
final int fG = (f100 * scale).round();
final int cG = (c100 * scale).round();

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
    setState(() {
      _searching = true;
      _previewFuture.clear(); // ← clear cached rows when query changes
    });
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
      appBar: AppBar(
  title: const Text('Food Logging'),
  actions: [
  if (_plate.isNotEmpty)
    Builder(
      builder: (ctx) => FutureBuilder<_PlateSummary>(
        future: _computePlateSummary(),
        builder: (context, snap) {
          final s = snap.data;
          final top = s == null ? '… kcal' : '${s.kcal} kcal';
          final bottom = s == null ? '…P …F …C' : '${s.p}P ${s.f}F ${s.c}C';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => Scaffold.of(ctx).openEndDrawer(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // was 6
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                // Keep content within the toolbar height and scale down if needed.
                child: SizedBox(
                  height: kToolbarHeight - 12, // give a tiny breathing room
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(top, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        Text(bottom, style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
],

),
      endDrawer: Drawer(
  child: SafeArea(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header summary
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: FutureBuilder<_PlateSummary>(
            future: _computePlateSummary(), // you already have this from earlier step
            builder: (context, snap) {
              final s = snap.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s == null ? '— kcal' : '${s.kcal} kcal',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(s == null ? '—P —F —C' : '${s.p}P ${s.f}F ${s.c}C',
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              );
            },
          ),
        ),
        const Divider(height: 1),

        // Plate lines
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            itemCount: _plate.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final it = _plate[i];
final borderColor = _plateBorderColor(it, i, context);

return Card(
  elevation: 0,
  clipBehavior: Clip.antiAlias, // keeps rounded corners crisp
  shape: RoundedRectangleBorder(
    side: BorderSide(color: borderColor, width: 1.25),
    borderRadius: BorderRadius.circular(12),
  ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Name + per-line macros + delete
                      Row(
                        children: [
                          Expanded(
                            child: FutureBuilder<_LineMacros>(
                              future: _calcLine(it),
                              builder: (context, snap) {
                                final m = snap.data;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(it.food.name,
                                        style: Theme.of(context).textTheme.bodyLarge,
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(
                                      m == null
                                          ? '… kcal • …P …F …C'
                                          : '${m.kcalText()} • ${m.macroText()}',
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            onPressed: () => setState(() => _plate.removeAt(i)),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Row 2: Portion dropdown
                      FutureBuilder<List<FoodPortion>>(
                        future: _getPortions(it.food.id!),
                        builder: (context, snap) {
                          final portions = snap.data ?? const <FoodPortion>[];
                          final fallback = FoodPortion(
                            id: null,
                            foodId: it.food.id!,
                            measureName: '100 g',
                            gramWeight: 100,
                            mlVolume: null,
                            isDefault: portions.isEmpty,
                          );
                          final items = portions.isEmpty ? [fallback] : portions;

// Use identical instance from items (by id) or fallbacks
FoodPortion? current = _matchPortionById(items, it.portion)
  ?? items.firstWhere((p) => p.isDefault, orElse: () => items.first);

                          return Row(
                            children: [
                              const Text('Portion:'),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButton<FoodPortion>(
                                  isExpanded: true,
                                  value: current,
                                  items: items.map((p) {
                                    final label =
                                        '${p.measureName}'
                                        '${p.gramWeight != null ? ' • ${p.gramWeight!.round()} g' : ''}'
                                        '${p.mlVolume != null ? ' • ${p.mlVolume!.round()} ml' : ''}';
                                    return DropdownMenuItem(value: p, child: Text(label));
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() {
                                      // Change portion
                                      it.portion = v;

                                      // Merge with any sibling line that now matches (same food & portion)
                                      final j = _plate.indexWhere((other) =>
  !identical(other, it) &&
  other.food.id == it.food.id &&
  other.meal == it.meal && // ← add this line
  (other.portion?.id ?? -1) == (it.portion?.id ?? -1)
);

                                      if (j >= 0) {
                                        it.qty += _plate[j].qty;
                                        _plate.removeAt(j);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // Row 3: Quantity stepper
                      Row(
  children: [
    const Text('Qty:'),
    const SizedBox(width: 8),
    _qtyButton(icon: Icons.remove, onTap: () {
      setState(() => it.qty = (it.qty - 1).clamp(0, 9999).toDouble());
    }),
    SizedBox(
      width: 60, // was 72 to free a bit of space
      child: _QtyEditor(
        qty: it.qty,
        onChanged: (v) => setState(() => it.qty = v < 0 ? 0 : v),
      ),
    ),
    _qtyButton(icon: Icons.add, onTap: () {
      setState(() => it.qty += 1);
    }),
    const SizedBox(width: 8),
    Flexible( // <-- let trailing text shrink instead of overflowing
      child: Text(
        '${_gramsForOne(it.food, it.portion).round()} g / unit',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    ),
  ],
)

                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Footer: Log all
        // Footer: Log all (single full-width button with border)
SafeArea(
  top: false,
  child: Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check),
        label: const Text('Add All to Diary'),
        onPressed: _plate.isEmpty ? null : () async {
          final profile = context.read<NutritionProfile>();
          final pid = profile.current?.id;
          if (pid == null) return;

          for (final it in _plate) {
            final portionId = it.portion?.id;
            // TODO(density): use real density; fallback to 1 g/mL for mL-only
            final gramsOverride = (portionId == null)
                ? _gramsForOne(it.food, it.portion) * it.qty
                : null;

            await profile.addFood(
              meal: it.meal,
              foodId: it.food.id!,
              portionId: portionId,
              quantity: it.qty,
              gramsOverride: gramsOverride,
            );
          }

          if (!mounted) return;
          setState(() => _plate.clear());
          Navigator.of(context).pop(); // close drawer
          Navigator.of(context).pop(true); // leave page
        },
        style: ButtonStyle(
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary, // border color
                width: 1.25,
              ),
            ),
          ),
        ),
      ),
    ),
  ),
)

      ],
    ),
  ),
),

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
  onPressed: _plate.isEmpty ? null : () async {
  final profile = context.read<NutritionProfile>();
  final pid = profile.current?.id;
  if (pid == null) return;

  for (final it in _plate) {
    final portionId = it.portion?.id;
    // TODO(density): replace 1 g/mL fallback when real density is available
    final gramsOverride = (portionId == null)
        ? _gramsForOne(it.food, it.portion) * it.qty
        : null;

    await profile.addFood(
      meal: it.meal,
      foodId: it.food.id!,
      portionId: portionId,
      quantity: it.qty,
      gramsOverride: gramsOverride,
    );
  }

  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Logged ${_plate.length} item${_plate.length == 1 ? "" : "s"}')),
  );
  setState(() => _plate.clear());
  Navigator.of(context).pop(true);
},

  child: Text(_plate.isEmpty ? 'Done' : 'Log ${_plate.length}'),
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
            onTap: () async {
  final result = await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const FoodCustomizationPage()),
  );

  if (result is Map) {
    await _saveCustomFoodFromPayload(result);
    // optionally refresh results list
    _kickoffSearch(_searchCtrl.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom food saved')),
      );
    }
  }
},
          ),
        );
      },
    );
  }

/* ///OLD VERSION
Future<void> _saveCustomFoodFromPayload(Map payload) async {
  // 0) Basic fields
  final name  = (payload['name'] as String?)?.trim();
  if (name == null || name.isEmpty) return;
  final brand = (payload['brand'] as String?)?.trim();

  // 1) Create the food shell
  final foodId = await _repo.createCustomFood(name: name, brand: brand);

  // 2) Save top-level macros/calories by *code*
  double? nums(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse('$v');
  }

  final byCode = <String, double>{};
  final kcal = nums(payload['calories']);   // "Calories (kcal)" field from the form
  final prot = nums(payload['protein_g']);
  final carb = nums(payload['carbs_g']);
  final fat  = nums(payload['fats_g']);

  if (kcal != null) byCode['ENERGY_KCAL'] = kcal; // present in extended seed
  if (prot != null) byCode['PROTEIN_G']   = prot;
  if (carb != null) byCode['CARB_G']      = carb;
  if (fat  != null) byCode['FAT_G']       = fat;

  if (byCode.isNotEmpty) {
    await _repo.savePer100gByCode(foodId, byCode);
  }

  // 3) Save *all other* leaf values by alias (labels from your UI/JSON)
  await _repo.saveExtendedPer100gFromPayload(foodId, payload);

  // 4) Ensure a default "100 g" portion exists (handy for logging right away)
  final portions = await _repo.getPortionsForFood(foodId);
  if (portions.isEmpty) {
    await _repo.addPortion(
      foodId,
      measureName: '100 g',
      gramWeight: 100,
      mlVolume: null,
      isDefault: true,
    );
  }

  // 5) Optionally refresh current list so the new food shows up immediately
  _kickoffSearch(_searchCtrl.text);
}
*/

Future<void> _saveCustomFoodFromPayload(Map payload) async {
  final name  = (payload['name'] as String?)?.trim();
  if (name == null || name.isEmpty) return;
  final brand = (payload['brand'] as String?)?.trim();

  // 1) Create the food shell
  final foodId = await _repo.createCustomFood(name: name, brand: brand);

  // 2) Per-100g nutrients from labels/codes/aliases (wipes & replaces)
  await _repo.savePer100gFromLabelPayload(foodId, Map<String, dynamic>.from(payload));

 

  // 4) Portions (v23). If none provided, ensure at least a default 100 g.
  final List portionsJson = (payload['portions'] as List?) ?? [];
  if (portionsJson.isEmpty) {
    await _repo.replacePortions(foodId, [
      FoodPortion(
        id: null,
        foodId: foodId,
        measureName: '100 g',
        gramWeight: 100,
        mlVolume: null,
        isDefault: true,
        listKind: 'basis',
        sortOrder: 0,
        amount: 100,
        unit: 'g',
        label: null,
      ),
    ]);
  } else {
    final portions = <FoodPortion>[];
    for (final p in portionsJson) {
      final m = Map<String, dynamic>.from(p as Map);
  final rawDefault = m['is_default'];
  final isDefault = rawDefault is bool
      ? rawDefault
      : (rawDefault is num ? rawDefault.toInt() == 1 : false);

      portions.add(FoodPortion(
    id          : null,
    foodId      : foodId,
    measureName : m['measure_name'] as String,
    gramWeight  : (m['gram_weight'] as num?)?.toDouble(),
    mlVolume    : (m['ml_volume'] as num?)?.toDouble(),
    isDefault   : isDefault,
    listKind    : m['list_kind'] as String?,
    sortOrder   : m['sort_order'] as int?,
    amount      : (m['amount'] as num?)?.toDouble(),
    unit        : m['unit'] as String?,
    label       : m['label'] as String?,
  ));
}
    await _repo.replacePortions(foodId, portions);
  }
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
  icon: const Icon(Icons.add_shopping_cart),
  label: const Text('Add to Plate'),
  onPressed: () async {

  

  final keyId = selected?.id ?? -1;
final idx = _plate.indexWhere((x) =>
  x.food.id == food.id &&
  (x.portion?.id ?? -1) == keyId &&
  x.meal == meal,
);
setState(() {
  if (idx >= 0) {
    _plate[idx].qty += qty;
  } else {
    _plate.add(_PlateItem(food: food, portion: selected, qty: qty, meal: meal));
  }
});



  Navigator.pop(ctx);
  if (mounted) {
  }
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

Future<_PlateSummary> _computePlateSummary() async {
  double kcal = 0, p = 0, f = 0, c = 0;

  // cache per-food lookup

  for (final it in _plate) {
    final id = it.food.id!;
    final per100 = await _getPer100(id);

    final grams = _gramsForOne(it.food, it.portion) * (it.qty <= 0 ? 0 : it.qty); // fallback if unresolved
    final scale = grams / 100.0;

    // kcal may be under ENERGY_KCAL or KCAL depending on your helper
    final kcal100 = per100['ENERGY_KCAL'] ?? per100['KCAL'] ?? 0.0;
    final p100    = per100['PROTEIN_G']   ?? per100['PROTEIN'] ?? 0.0;
    final f100    = per100['FAT_G']       ?? per100['FAT']     ?? 0.0;
    final c100    = per100['CARB_G']      ?? per100['CARB']    ?? 0.0;

    kcal += kcal100 * scale;
    p    += p100    * scale;
    f    += f100    * scale;
    c    += c100    * scale;
  }

  return _PlateSummary(kcal.round(), p.round(), f.round(), c.round());
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



class _LineMacros {
  final double kcal, p, f, c;
  const _LineMacros({required this.kcal, required this.p, required this.f, required this.c});
  String macroText() => '${p.round()}P ${f.round()}F ${c.round()}C';
  String kcalText() => '${kcal.round()} kcal';
}

Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 36, height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18),
      ),
    ),
  );
}


class _QtyEditor extends StatefulWidget {
  final double qty;
  final ValueChanged<double> onChanged;
  const _QtyEditor({required this.qty, required this.onChanged});
  @override State<_QtyEditor> createState() => _QtyEditorState();
}
class _QtyEditorState extends State<_QtyEditor> {
  late final TextEditingController _c;
  @override void initState() { super.initState(); _c = TextEditingController(text: _fmt(widget.qty)); }
  @override void didUpdateWidget(covariant _QtyEditor old) {
    super.didUpdateWidget(old);
    if (widget.qty != old.qty && _c.text != _fmt(widget.qty)) _c.text = _fmt(widget.qty);
  }
  String _fmt(double v)=> (v % 1 == 0) ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  @override void dispose(){ _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return TextFormField(
      controller: _c,
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (s){ final v = double.tryParse(s); if (v != null) widget.onChanged(v < 0 ? 0 : v); },
      decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8), border: OutlineInputBorder()),
    );
  }
}
