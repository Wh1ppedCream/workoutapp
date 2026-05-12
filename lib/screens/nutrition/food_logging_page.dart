// File: lib/screens/nutrition/food_logging_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/nutrition_models.dart';
import '../../repositories/app_repository.dart';
import '../../providers/nutrition_profile.dart';

import 'food_customization_page.dart';

import 'barcode_scanner_page.dart';


class _PlateItem {
  final Food food;
  FoodPortion? portion; // mutable, may be null for virtual 100 g
  double qty; // mutable
  MealType meal;
  String? note; // mutable, optional
  List<String> tags; // NEW: optional tags for this line

  _PlateItem({
    required this.food,
    required this.portion,
    required this.qty,
    required this.meal,
    this.note,
    List<String>? tags,
  }) : tags = tags ?? <String>[];
}

class _PlateSummary {
  final int kcal, p, f, c;
  const _PlateSummary(this.kcal, this.p, this.f, this.c);
}

class FoodLoggingPage extends StatefulWidget {
  const FoodLoggingPage({super.key, this.repository});
  final AppRepository? repository;

  @override
  State<FoodLoggingPage> createState() => _FoodLoggingPageState();
}

class _FoodLoggingPageState extends State<FoodLoggingPage> {
  // One-time init flags for default meal selection
  bool _didInitScanMeal = false;
  bool _didInitPlannedMeal = false;

  // 0=Scan, 1=Search, 2=Pre-Planned, 3=Custom
  final List<bool> _tabs = [false, true, false, false];

  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _searching = false;
  List<Food> _results = [];

  late final AppRepository _repo = widget.repository ?? AppRepository();

  final Map<int, Future<_MacroPreview>> _previewFuture = {};

  final List<_PlateItem> _plate = [];

  // Cache portions per food to avoid repeated queries
  final Map<int, Future<List<FoodPortion>>> _portionCache = {};

  // Cache per100g macros per food
  final Map<int, Future<Map<String, double>>> _per100Cache = {};

  // Scan tab state
  final _barcodeCtrl = TextEditingController();
  MealType _scanMeal = MealType.breakfast;
  bool _scanBusy = false;

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');
  bool _instantLogOnScan = true;



  // Pre-planned tab state (which meal to log recipes to)
  MealType _plannedMeal = MealType.dinner;

  // Logging guard
  bool _logBusy = false;

  // NEW: plate-level log time override (null = intelligent default)
  DateTime? _plateLogAt;
  String _fmtHM(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  MealType _defaultMealForNow(NutritionProfile p) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final viewingToday =
        p.day.year == today.year && p.day.month == today.month && p.day.day == today.day;
    if (!viewingToday) return MealType.lunch; // neutral default for past/future days
    final h = now.hour;
    if (h < 11) return MealType.breakfast;
    if (h < 17) return MealType.lunch;
    return MealType.dinner;
  }

  DateTime _defaultLogTimeFor(NutritionProfile p) {
    final d = p.day;
    final now = DateTime.now();
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    return isToday ? now : DateTime(d.year, d.month, d.day, 12);
  }

  Color _plateBorderColor(_PlateItem it, int index, BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    // keep as-is per request (alpha API)
    switch (it.meal) {
      case MealType.breakfast:
        return cs.primary.withValues(alpha: 0.55);
      case MealType.lunch:
        return cs.tertiary.withValues(alpha: 0.55);
      case MealType.dinner:
        return cs.secondary.withValues(alpha: 0.55);
      case MealType.snack:
        return cs.error.withValues(alpha: 0.45);
    }
  }

  Future<List<FoodPortion>> _getPortions(int foodId) {
    return _portionCache.putIfAbsent(
      foodId,
      () => context.read<NutritionProfile>().portionsFor(foodId),
    );
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
    return _per100Cache.putIfAbsent(
      foodId,
      () => context.read<NutritionProfile>().macroPer100g(foodId),
    );
  }

  // grams for ONE unit of the selected portion (fallbacks to 100g)
  double _gramsForOne(Food food, FoodPortion? portion) {
    if (portion == null) return 100.0; // virtual 100 g
    if (portion.gramWeight != null) return portion.gramWeight!;
    if (portion.mlVolume != null) {
      final density = food.densityGPerMl ?? 1.0;
      return portion.mlVolume! * density;
    }
    return 100.0;
  }

  double _pick(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v is num) return v.toDouble();
    }
    return 0.0;
  }

  // Per-line totals (kcal / P / F / C) for given quantity
  Future<_LineMacros> _calcLine(_PlateItem it) async {
    final qty = it.qty <= 0 ? 0.0 : it.qty;
    final portionId = it.portion?.id;

    if (portionId != null) {
      final m = await context.read<NutritionProfile>().previewPortion(
            foodId: it.food.id!,
            portionId: portionId,
            quantity: qty,
          );
      final kcal = _pick(m, ['kcal', 'ENERGY_KCAL', 'KCAL']);
      final p = _pick(m, ['protein_g', 'PROTEIN', 'PROTEIN_G']);
      final f = _pick(m, ['fat_g', 'FAT', 'FAT_G']);
      final c = _pick(m, ['carbs_g', 'CARB', 'CARB_G']);
      return _LineMacros(kcal: kcal, p: p, f: f, c: c);
    }

    // Fallback: virtual “100 g” row
    final per100 = await _getPer100(it.food.id!);
    final grams = _gramsForOne(it.food, it.portion) * qty;
    double k(List<String> keys) => keys
        .map((k) => per100[k])
        .whereType<num>()
        .fold<double>(0, (a, b) => a + b.toDouble()) *
        (grams / 100.0);

    return _LineMacros(
      kcal: k(['ENERGY_KCAL', 'KCAL']),
      p: k(['PROTEIN', 'PROTEIN_G']),
      f: k(['FAT', 'FAT_G']),
      c: k(['CARB', 'CARB_G']),
    );
  }

  Future<_MacroPreview> _loadPreview(Food f) async {
  if (f.id == null) return _MacroPreview.empty('—');

  // ✅ Cache provider before any await
  final prof = context.read<NutritionProfile>();

  // choose portion (default → first → 100 g fallback)
  final portions = await prof.portionsFor(f.id!); // (was: context.read(...).portionsFor)
  FoodPortion? portion = portions.isEmpty
      ? null
      : portions.firstWhere(
          (p) => p.isDefault == true,
          orElse: () => portions.first,
        );

  // fallback virtual "100 g"
  portion ??= FoodPortion(
    id: null,
    foodId: f.id!,
    measureName: '100 g',
    gramWeight: 100,
    mlVolume: null,
    isDefault: true,
  );

  // If it's a real portion, compute 1× portion:
  if (portion.id != null) {
    final m = await prof.previewPortion( // (was: context.read(...).previewPortion)
      foodId: f.id!,
      portionId: portion.id!,
      quantity: 1.0,
    );
    final p = _pick(m, ['protein_g', 'PROTEIN', 'PROTEIN_G']).round();
    final s = _pick(m, ['fat_g', 'FAT', 'FAT_G']).round();
    final c = _pick(m, ['carbs_g', 'CARB', 'CARB_G']).round();
    return _MacroPreview(
      proteinG: p,
      fatG: s,
      carbG: c,
      portionLabel: portion.measureName,
    );
  }

  // Fallback: virtual “100 g” math
  final per100 = await prof.macroPer100g(f.id!); // (was: context.read(...).macroPer100g)
  double pick(List<String> keys) =>
      keys.map((k) => per100[k]).whereType<num>().fold<double>(0, (a, b) => a + b.toDouble());
  final p100 = pick(['PROTEIN', 'PROTEIN_G']);
  final f100 = pick(['FAT', 'FAT_G']);
  final c100 = pick(['CARB', 'CARB_G']);
  return _MacroPreview(
    proteinG: p100.round(),
    fatG: f100.round(),
    carbG: c100.round(),
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
    // No-op: suggestions section handles the empty state
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _barcodeCtrl.dispose();
    _previewFuture.clear();
 _portionCache.clear();
 _per100Cache.clear();
    super.dispose();
  }

  int _searchEpoch = 0;

  // UPDATED: short-circuit empty queries so we immediately show suggestions
  void _kickoffSearch(String q0) {
    _debounce?.cancel();
    final myEpoch = ++_searchEpoch;

    final q = q0.trim();
    if (q.isEmpty) {
      setState(() {
        _searching = false;
        _results = const [];
        _previewFuture.clear();
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 250), () async {
      if (!mounted) return;
      setState(() {
        _searching = true;
        _previewFuture.clear();
      });
      try {
        final rows = await context.read<NutritionProfile>().searchFoods(q, limit: 50);
        if (!mounted || myEpoch != _searchEpoch) return; // drop stale result
        setState(() => _results = rows);
      } finally {
        if (mounted && myEpoch == _searchEpoch) {
          setState(() => _searching = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NutritionProfile>();

    // One-time defaults
    if (!_didInitScanMeal) {
      _scanMeal = _defaultMealForNow(p);
      _didInitScanMeal = true;
    }
    if (!_didInitPlannedMeal) {
      _plannedMeal = _defaultMealForNow(p);
      _didInitPlannedMeal = true;
    }

    // Show a slim status bar using provider's current totals/goals
    final kcal = (p.totals?.kcal ?? 0).round();
    final kcalTgt = (p.activeGoal?.kcalTarget ?? 0).round();
    final pro = (p.totals?.proteinG ?? 0).round();
    final proTgt = (p.activeGoal?.proteinG ?? 0).round();
    final fat = (p.totals?.fatG ?? 0).round();
    final fatTgt = (p.activeGoal?.fatG ?? 0).round();
    final carb = (p.totals?.carbsG ?? 0).round();
    final carbTgt = (p.activeGoal?.carbsG ?? 0).round();
    final plateSummaryFuture =
        _plate.isEmpty ? null : _computePlateSummary();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Logging'),
        actions: [
          if (_plate.isNotEmpty)
            Builder(
              builder: (ctx) => FutureBuilder<_PlateSummary>(
                future: plateSummaryFuture,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox(
                          height: kToolbarHeight - 12,
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
                  future: plateSummaryFuture,
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

              // NEW: Plate "log time" picker
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Builder(
                  builder: (ctx) {
                    final prof = context.read<NutritionProfile>();
                    final effective = _plateLogAt ?? _defaultLogTimeFor(prof);
                    return Row(
                      children: [
                        const Icon(Icons.schedule, size: 18),
                        const SizedBox(width: 8),
                        const Text('Log time:'),
                        const SizedBox(width: 8),
                        OutlinedButton(
  onPressed: () async {
    final t0 = TimeOfDay(hour: effective.hour, minute: effective.minute);
    final picked = await showTimePicker(context: ctx, initialTime: t0);

    // ✅ Guard State.context use (setState) after the await:
    if (!mounted) return;

    if (picked != null) {
      final d = prof.day;
      setState(() {
        _plateLogAt = DateTime(d.year, d.month, d.day, picked.hour, picked.minute);
      });
    }
  },
  child: Text(_fmtHM(effective)),
),
                        const Spacer(),
                        if (_plateLogAt != null)
                          TextButton(
                            onPressed: () => setState(() => _plateLogAt = null),
                            child: const Text('Reset'),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),

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
                      clipBehavior: Clip.antiAlias,
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
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
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
                                FoodPortion? current =
                                    _matchPortionById(items, it.portion) ??
                                        items.firstWhere(
                                          (p) => p.isDefault == true,
                                          orElse: () => items.first,
                                        );

                                return Row(
                                  children: [
                                    const Text('Portion:'),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: DropdownButton<FoodPortion>(
                                        isExpanded: true,
                                        value: current,
                                        items: items.map((p) {
                                          final label = '${p.measureName}'
                                              '${p.gramWeight != null ? ' • ${p.gramWeight!.round()} g' : ''}'
                                              '${p.mlVolume != null ? ' • ${p.mlVolume!.round()} ml' : ''}';
                                          return DropdownMenuItem(value: p, child: Text(label));
                                        }).toList(),
                                        onChanged: (v) {
                                          if (v == null) return;
                                          setState(() {
   it.portion = v;
   _mergeIfDuplicate(it);
 });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 8),

                            // Row 2b: Meal chooser (inline) + duplicate merge
                            Wrap(
                              spacing: 6,
                              children: MealType.values.map((m) {
                                final label = m.name[0].toUpperCase() + m.name.substring(1);
                                final selected = it.meal == m;
                                return ChoiceChip(
                                  label: Text(label),
                                  selected: selected,
                                  onSelected: (_) {
                                    setState(() {
   it.meal = m;
   _mergeIfDuplicate(it);
 });
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 8),

                            // Row 3: Quantity stepper
                            Row(
                              children: [
                                const Text('Qty:'),
                                const SizedBox(width: 8),
                                _qtyButton(
                                  icon: Icons.remove,
                                  onTap: () {
                                    setState(() =>
                                        it.qty = (it.qty - 1).clamp(0, 9999).toDouble());
                                  },
                                ),
                                SizedBox(
                                  width: 60,
                                  child: _QtyEditor(
                                    qty: it.qty,
                                    onChanged: (v) => setState(() => it.qty = v < 0 ? 0 : v),
                                  ),
                                ),
                                _qtyButton(
                                  icon: Icons.add,
                                  onTap: () {
                                    setState(() => it.qty += 1);
                                  },
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '${_gramsForOne(it.food, it.portion).round()} g / unit',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ),
                              ],
                            ),

                            // NEW: show tags for this line
                            if (it.tags.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: -6,
                                children: it.tags
                                    .map((t) => Chip(
                                          label: Text('#$t'),
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Footer: Log all
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _logBusy
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(_logBusy ? 'Logging…' : 'Add All to Diary'),
                      onPressed:
                          _plate.isEmpty || _logBusy ? null : () => _logPlateAndClose(context: context),
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
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
                Expanded(child: _StatCard(label: 'Protein', value: '$pro / $proTgt g')),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(label: 'Carbs', value: '$carb / $carbTgt g')),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(label: 'Fat', value: '$fat / $fatTgt g')),
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
                ? _buildScanTab(context)
                : _tabs[1]
                    ? _buildSearchList(context)
                    : _tabs[2]
                        ? _buildPrePlanned(context)
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
                      suffixIcon: (_searchCtrl.text.isEmpty)
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                _kickoffSearch('');
                                FocusScope.of(context).unfocus();
                                setState(() {}); // refresh suffixIcon state
                              },
                            ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (s) {
                      _kickoffSearch(s);
                      setState(() {});
                    },
                    onSubmitted: (s) => _kickoffSearch(s),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
   onPressed: _logBusy
       ? null
       : (_plate.isEmpty
           ? () => Navigator.of(context).maybePop()
           : () => _logPlateAndClose(
                 context: context,
                 closeDrawerToo: false,
                 popPageAfter: false,
               )),
   child: Text(_logBusy ? 'Logging…' : (_plate.isEmpty ? 'Close' : 'Log ${_plate.length}')),
 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrePlanned(BuildContext context) {
    final p = context.watch<NutritionProfile>();

    return FutureBuilder<List<Recipe>>(
      future: p.recentRecipes(limit: 20),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final recipes = snap.data ?? const <Recipe>[];
        if (recipes.isEmpty) {
          return const Center(child: Text('No recent recipes yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: recipes.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              // Meal selector header
              return Wrap(
                spacing: 8,
                children: MealType.values.map((m) {
                  final label = m.name[0].toUpperCase() + m.name.substring(1);
                  return ChoiceChip(
                    label: Text(label),
                    selected: _plannedMeal == m,
                    onSelected: (_) => setState(() => _plannedMeal = m),
                  );
                }).toList(),
              );
            }
            final r = recipes[i - 1];
            return Card(
              child: ListTile(
                title: Text(r.name),
                subtitle: const Text('Recent recipe'),
                trailing: IconButton(
                  tooltip: 'Log 1× now',
                  icon: const Icon(Icons.playlist_add_check),
                  onPressed: () async {
  final messenger = ScaffoldMessenger.of(context);
  final prof = context.read<NutritionProfile>();

  await prof.addRecipeWithDefaultTime(
    meal: _plannedMeal,
    recipeId: r.id!,
    quantity: 1.0,
  );

  if (!mounted) return; // ✅ guard context use after await
  messenger.showSnackBar(
    SnackBar(content: Text('Logged "${r.name}"')),
  );
},

                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchList(BuildContext context) {
    if (_searchCtrl.text.trim().isEmpty) {
      return _buildSuggestions(context);
    }
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
      itemBuilder: (context, i) => _foodResultTile(context, _results[i]),
    );
  }

  Widget _buildScanTab(BuildContext context) {

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Meal selector
        Wrap(
          spacing: 8,
          children: MealType.values.map((m) {
            final label = m.name[0].toUpperCase() + m.name.substring(1);
            return ChoiceChip(
              label: Text(label),
              selected: _scanMeal == m,
              onSelected: (_) => setState(() => _scanMeal = m),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // New: instant-log toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Instant log after scan'),
          subtitle: const Text('If off, you can edit portion/qty before logging'),
          value: _instantLogOnScan,
          onChanged: (v) => setState(() => _instantLogOnScan = v),
        ),
        const SizedBox(height: 8),

        // New: open camera
        ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Open camera scanner'),
          onPressed: _openCameraScanner,
        ),
        const SizedBox(height: 16),

        // Existing manual fallback
        TextField(
          controller: _barcodeCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Enter barcode manually',
            hintText: 'e.g. 012345678905',
            prefixIcon: const Icon(Icons.qr_code),
            suffixIcon: (_barcodeCtrl.text.isEmpty)
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _barcodeCtrl.clear()),
                  ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _handleScanAdd(),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: _scanBusy
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: const Text('Log by barcode'),
          onPressed: (_barcodeCtrl.text.trim().isEmpty || _scanBusy) ? null : _handleScanAdd,
        ),
        const SizedBox(height: 8),
        const Text('Tip: camera scanning available above; manual entry stays as fallback.'),
      ],
    ),
  );
}


// Add this helper somewhere near the scan handlers
Future<void> _processBarcode(String normalized) async {
  final messenger = ScaffoldMessenger.of(context);
  final prof = context.read<NutritionProfile>();

  if (_instantLogOnScan) {
    try {
      await prof.addFoodByBarcodeWithDefaultTime(meal: _scanMeal, barcode: normalized);
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Logged item from barcode')));
    } on StateError catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
    return;
  }

  // Edit-first path
  try {
    final food = await _repo.foodCatalog.getFoodByBarcode(normalized);
    if (!mounted) return;

    if (food != null) {
      await _openAddSheet(context, food);
      return;
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FoodCustomizationPage()),
    );
    if (!mounted) return;

    if (result is Map) {
      final newId = await _saveCustomFoodFromPayloadReturningId(result);
      await _repo.addBarcode(newId, normalized);

      final created = await _repo.getFood(newId);
      if (!mounted) return;

      if (created != null) {
        await _openAddSheet(context, created);
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Custom food saved & barcode linked')),
      );
    }
  } catch (e) {
    if (mounted) messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
  }
}


Future<void> _openCameraScanner() async {
  if (!mounted) return;
  final navigator = Navigator.of(context);

  final code = await navigator.push<String>(
     MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
   );
   if (!mounted || code == null) return;
  
  final normalized = _digitsOnly(code);
  if (normalized.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No valid barcode detected')),
    );
    return;
  }
  await _processBarcode(normalized);
  
}


// CHANGE RETURN TYPE to int and return the created ID
Future<int> _saveCustomFoodFromPayloadReturningId(Map payload) async {
  final name = (payload['name'] as String?)?.trim();
  if (name == null || name.isEmpty) {
    throw StateError('Food must have a name');
  }
  final brand = (payload['brand'] as String?)?.trim();

  // 1) Create the food shell
  final foodId = await _repo.createCustomFood(name: name, brand: brand);

  // persist density if provided
  final dens = (payload['density_g_per_ml'] as num?)?.toDouble();
  if (dens != null) {
    await _repo.upsertFoodWithKeys(
      id: foodId,
      name: name,
      brandName: brand,
      densityGPerMl: dens,
    );
  }

  // 2) Per-100g nutrients from labels/codes/aliases
  await _repo.saveExtendedPer100gFromPayload(foodId, Map<String, dynamic>.from(payload));

  // 3) Portions (or default 100 g)
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

      portions.add(
        FoodPortion(
          id: null,
          foodId: foodId,
          measureName: m['measure_name'] as String,
          gramWeight: (m['gram_weight'] as num?)?.toDouble(),
          mlVolume: (m['ml_volume'] as num?)?.toDouble(),
          isDefault: isDefault,
          listKind: m['list_kind'] as String?,
          sortOrder: m['sort_order'] as int?,
          amount: (m['amount'] as num?)?.toDouble(),
          unit: m['unit'] as String?,
          label: m['label'] as String?,
        ),
      );
    }
    await _repo.replacePortions(foodId, portions);
  }

  return foodId;
}




  Future<void> _handleScanAdd() async {
  final code = _digitsOnly(_barcodeCtrl.text.trim());
  if (code.isEmpty || _scanBusy) return;
  setState(() => _scanBusy = true);
  try {
    await _processBarcode(code);
    if (!mounted) return;
    _barcodeCtrl.clear();
  } finally {
    if (mounted) setState(() => _scanBusy = false);
  }
  }

  Widget _buildSuggestions(BuildContext context) {
    final p = context.watch<NutritionProfile>();
    return FutureBuilder(
      future: Future.wait([
        p.favoriteFoods(limit: 50),
        p.recentFoods(limit: 20),
      ]),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final favs = snap.data![0];
        final recents = snap.data![1];

        Widget section(String title, List<Food> items) {
          if (items.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ...items.take(8).map((f) => _foodResultTile(context, f)),
              ],
            ),
          );
        }

        return ListView(
          children: [
            section('Favorites', favs),
            section('Recent foods', recents),
            if (favs.isEmpty && recents.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Start searching to find foods.')),
              ),
          ],
        );
      },
    );
  }

  Widget _foodResultTile(BuildContext context, Food f) {
    return Card(
      child: ListTile(
        title: Text(f.name),
        subtitle: FutureBuilder<_MacroPreview>(
          future: _previewFuture[f.id!] ??= _loadPreview(f),
          builder: (context, snap) {
            final m = (snap.connectionState == ConnectionState.done && snap.hasData)
                ? snap.data!
                : _MacroPreview.empty('—');
            return Text(_macroLine(m));
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Selector<NutritionProfile, bool>(
  selector: (_, p) => p.isFavorite(f.id!),
  builder: (ctx, isFav, _) => IconButton(
    tooltip: isFav ? 'Unfavorite' : 'Favorite',
    icon: Icon(isFav ? Icons.star : Icons.star_border),
    color: isFav ? Colors.amber : Colors.grey,
    visualDensity: VisualDensity.compact,
    onPressed: () => ctx.read<NutritionProfile>().toggleFavorite(f.id!),
  ),
),
            IconButton(
              tooltip: 'Customize food',
              icon: const Icon(Icons.settings),
              color: Colors.grey,
              visualDensity: VisualDensity.compact,
              onPressed: () => _openCustomizeFood(f),
            ),
            IconButton(
              tooltip: 'Edit & add',
              icon: const Icon(Icons.edit),
              color: Colors.amber,
              visualDensity: VisualDensity.compact,
              onPressed: () => _openAddSheet(context, f),
            ),
            IconButton(
              tooltip: 'Add 1',
              icon: const Icon(Icons.add_circle),
              color: Colors.green,
              visualDensity: VisualDensity.compact,
              onPressed: () => _quickAddOne(f),
            ),
            /* NOT IN USE CURRENTLY
            IconButton(
              tooltip: 'Log 1× now',
              icon: const Icon(Icons.flash_on),
              color: Colors.blue,
              visualDensity: VisualDensity.compact,
              onPressed: () => _logOneNow(f),
            ),
            */
          ],
        ),
        onTap: () => _openAddSheet(context, f),
      ),
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
              final messenger = ScaffoldMessenger.of(context);

              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FoodCustomizationPage()),
              );

              if (result is Map) {
                await _saveCustomFoodFromPayloadReturningId(result);
                _kickoffSearch(_searchCtrl.text);
                if (mounted) {
                  messenger.showSnackBar(
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


  Future<void> _quickAddOne(Food f) async {
  // ✅ Cache provider & compute meal before any await
  final prof = context.read<NutritionProfile>();
  final meal = _defaultMealForNow(prof);

  final portions = await _getPortions(f.id!);
  if (!mounted) return;

  // pick default → first → virtual "100 g"
  FoodPortion? portion;
  if (portions.isEmpty) {
    portion = FoodPortion(
      id: null,
      foodId: f.id!,
      measureName: '100 g',
      gramWeight: 100,
      mlVolume: null,
      isDefault: true,
    );
  } else {
    portion = portions.firstWhere(
      (p) => p.isDefault == true,
      orElse: () => portions.first,
    );
  }

  setState(() {
    final keyId = portion?.id ?? -1;
    final idx = _plate.indexWhere(
      (x) => x.food.id == f.id && (x.portion?.id ?? -1) == keyId && x.meal == meal,
    );
    if (idx >= 0) {
      _plate[idx].qty += 1.0;
    } else {
      _plate.add(_PlateItem(food: f, portion: portion, qty: 1.0, meal: meal));
    }
  });
}


  Future<void> _openAddSheet(BuildContext context, Food food) async {    
    final prof = context.read<NutritionProfile>();
    MealType meal = _defaultMealForNow(prof);

    final portions = await _getPortions(food.id!);

    // ✅ Guard context usage after the async gap
   if (!context.mounted) return;

    // Choose default portion if flagged; otherwise first; fallback to "100 g"
    FoodPortion? selected = portions.firstWhere(
      (p) => p.isDefault == true,
      orElse: () => portions.isNotEmpty
          ? portions.first
          : FoodPortion(
              id: null,
              foodId: food.id!,
              measureName: '100 g',
              gramWeight: 100,
              mlVolume: null,
              isDefault: true,
            ),
    );


    double qty = 1.0;
    String? note;
    String tagsText = ''; // NEW: capture tags input

    await showModalBottomSheet(
    context: context, // ok to pass context here
    isScrollControlled: true,
      builder: (ctx) {
        final navigator = Navigator.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
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
                              ? portions
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(
                                        '${p.measureName}'
                                        '${p.gramWeight != null ? ' • ${p.gramWeight!.toStringAsFixed(0)} g' : ''}'
                                        '${p.mlVolume != null ? ' • ${p.mlVolume!.toStringAsFixed(0)} ml' : ''}',
                                      ),
                                    ),
                                  )
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
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
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

                  const SizedBox(height: 12),

                  // Note
                  TextFormField(
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (s) => note = s.trim().isEmpty ? null : s.trim(),
                  ),

                  const SizedBox(height: 12),

                  // NEW: Tags (comma-separated)
                  TextFormField(
                    minLines: 1,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma-separated, e.g. "post-workout, high-protein")',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (s) => tagsText = s,
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
                            final idx = _plate.indexWhere(
                              (x) =>
                                  x.food.id == food.id &&
                                  (x.portion?.id ?? -1) == keyId &&
                                  x.meal == meal,
                            );

 final newTags = tagsText
     .split(',')
     .map((t) => t.trim().toLowerCase())
     .where((t) => t.isNotEmpty)
     .toSet()
     .toList();

                            setState(() {
                              if (idx >= 0) {
                                _plate[idx].qty += qty;
                                _plate[idx].note ??= note;
                                // merge tags (set union)
                                final merged = {..._plate[idx].tags, ...newTags}.toList();
                                _plate[idx].tags..clear()..addAll(merged);
                              } else {
                                _plate.add(
                                  _PlateItem(
                                    food: food,
                                    portion: selected,
                                    qty: qty,
                                    meal: meal,
                                    note: note,
                                    tags: newTags, // NEW
                                  ),
                                );
                              }
                            });
                            navigator.pop();
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

  Future<void> _openCustomizeFood(Food f) async {
    final navigator = Navigator.of(context);
    final byCode = await _getPer100(f.id!);
    double pick(List<String> keys) =>
        keys.map((k) => byCode[k]).whereType<num>().fold<double>(0, (a, b) => a + b.toDouble());

    final portions = await _getPortions(f.id!);

    final result = await navigator.push(
      MaterialPageRoute(
        builder: (_) => FoodCustomizationPage(
          initialFoodId: f.id!,
          initialName: f.name,
          initialBrand: f.brand,
          initialCalories: (byCode['ENERGY_KCAL'] ?? byCode['KCAL'] ?? 0).toDouble(),
          initialProteinG: pick(['PROTEIN', 'PROTEIN_G']),
          initialCarbsG: pick(['CARB', 'CARB_G']),
          initialFatsG: pick(['FAT', 'FAT_G']),
          initialPortions: portions,
          initialDensityGPerMl: f.densityGPerMl,     // ← add this
        ),
      ),
    );

    if (result is Map && (result['food_id'] is int)) {
      await _updateExistingFoodFromPayload(Map<String, dynamic>.from(result));

      _portionCache.remove(f.id!);
  _per100Cache.remove(f.id!);
  _previewFuture.remove(f.id!);

      if (mounted) _kickoffSearch(_searchCtrl.text);
    }
  }

  Future<void> _updateExistingFoodFromPayload(Map<String, dynamic> payload) async {
    final int foodId = payload['food_id'] as int;
    final String? name = (payload['name'] as String?)?.trim();
    final String? brand = (payload['brand'] as String?)?.trim();

    // 1) Update basics (name/brand)
    await _repo.updateFoodBasics(foodId, name: name, brand: brand);

    // persist density on update as well
    final dens = (payload['density_g_per_ml'] as num?)?.toDouble();
    if (dens != null) {
      final existing = await _repo.getFood(foodId);
    final safeName = name ?? existing?.name ?? '';
    final safeBrand = brand ?? existing?.brand;
    await _repo.upsertFoodWithKeys(
      id: foodId,
      name: safeName,         // don’t blank it out
      brandName: safeBrand,
      densityGPerMl: dens,
    );
    }

    // 2) Replace per-100g nutrients
    await _repo.saveExtendedPer100gFromPayload(foodId, payload);

    // 3) Replace portions if present
    final List portionsJson = (payload['portions'] as List?) ?? const [];
    if (portionsJson.isNotEmpty) {
      final portions = <FoodPortion>[];
      for (final p in portionsJson) {
        final m = Map<String, dynamic>.from(p as Map);
        final rawDefault = m['is_default'];
        final isDefault =
            rawDefault is bool ? rawDefault : (rawDefault is num ? rawDefault.toInt() == 1 : false);

        portions.add(
          FoodPortion(
            id: null,
            foodId: foodId,
            measureName: m['measure_name'] as String,
            gramWeight: (m['gram_weight'] as num?)?.toDouble(),
            mlVolume: (m['ml_volume'] as num?)?.toDouble(),
            isDefault: isDefault,
            listKind: m['list_kind'] as String?,
            sortOrder: m['sort_order'] as int?,
            amount: (m['amount'] as num?)?.toDouble(),
            unit: m['unit'] as String?,
            label: m['label'] as String?,
          ),
        );
      }
      await _repo.replacePortions(foodId, portions);
    }
  }

  Future<_PlateSummary> _computePlateSummary() async {
    final lines = await Future.wait(_plate.map(_calcLine));
    final kcal = lines.fold<double>(0, (a, b) => a + b.kcal);
    final p = lines.fold<double>(0, (a, b) => a + b.p);
    final f = lines.fold<double>(0, (a, b) => a + b.f);
    final c = lines.fold<double>(0, (a, b) => a + b.c);
    return _PlateSummary(kcal.round(), p.round(), f.round(), c.round());
  }

  Future<void> _logPlateAndClose({
    required BuildContext context,
    bool closeDrawerToo = true,
    bool popPageAfter = true,
  }) async {
    if (_logBusy) return;
    setState(() => _logBusy = true);

    final navigator = Navigator.of(context);
final messenger = ScaffoldMessenger.of(context);
final prof = context.read<NutritionProfile>();
final pid = prof.profileId;
 if (pid == null) {
   messenger.showSnackBar(const SnackBar(content: Text('Profile not ready yet.')));
   if (mounted) setState(() => _logBusy = false);
   return;
 }

    // Use plate override if set; otherwise provider default
    final stamp = _plateLogAt ?? _defaultLogTimeFor(prof);

    try {
      // Insert each line, then add its tags (if any)
      for (final it in _plate) {
        final grams = _gramsForOne(it.food, it.portion) * it.qty;
 final isVirtual = it.portion?.id == null;

        final entryId = await _repo.addDiaryFood(
          profileId: pid,
          date: prof.day,
          mealType: it.meal,
          foodId: it.food.id!,
          portionId: it.portion?.id,
          quantity: it.qty,
          gramsOverride: isVirtual ? grams : null, // only needed when no portion exists
          loggedGrams: grams,                      // always record the grams consumed   
          loggedAt: stamp,
          notes: it.note,
        );

        // Attach tags
        if (it.tags.isNotEmpty) {
          for (final tag in it.tags) {
            await _repo.addDiaryTag(entryId, tag);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _plate.clear();
        _plateLogAt = null; // reset to smart default for next session
      });

      // Refresh if we're on today (cheap, provider-coalesced)
      await prof.reloadIfToday();

messenger.showSnackBar(
  const SnackBar(content: Text('Items logged to diary')),
);

      if (closeDrawerToo) navigator.pop();     // close endDrawer
      if (popPageAfter) navigator.pop(true);   // optionally leave page

    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Failed to log: $e')));
    } finally {
      if (mounted) setState(() => _logBusy = false);
    }
  }

  /*
  Future<void> _logOneNow(Food f) async {
    final prof = context.read<NutritionProfile>();
    final meal = _defaultMealForNow(prof);

    // Try to respect default portion if one exists; if not, let provider pick.
    final portions = await _getPortions(f.id!);
    final portion = portions.isEmpty
        ? null
        : portions.firstWhere(
            (p) => p.isDefault == true,
            orElse: () => portions.first,
          );

    try {
      // Use provider helper that picks smart default time
      await prof.quickLogFood(
        meal: meal,
        foodId: f.id!,
        portionId: portion?.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Logged to ${meal.name}: 1× ${portion?.measureName ?? 'default'} of ${f.name}'),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }
  */

void _mergeIfDuplicate(_PlateItem it) {
  final keyId = it.portion?.id ?? -1;
  for (int j = _plate.length - 1; j >= 0; j--) {
    final other = _plate[j];
    if (identical(other, it)) continue;
    if (other.food.id == it.food.id &&
        (other.portion?.id ?? -1) == keyId &&
        other.meal == it.meal) {
      it.qty += other.qty;
      it.note ??= other.note;
      final merged = {...it.tags, ...other.tags}.toList();
      it.tags..clear()..addAll(merged);
      _plate.removeAt(j);
    }
  }
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
        width: 36,
        height: 36,
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
  @override
  State<_QtyEditor> createState() => _QtyEditorState();
}

class _QtyEditorState extends State<_QtyEditor> {
  late final TextEditingController _c;
  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: _fmt(widget.qty));
  }

  @override
  void didUpdateWidget(covariant _QtyEditor old) {
    super.didUpdateWidget(old);
    if (widget.qty != old.qty && _c.text != _fmt(widget.qty)) {
      _c.text = _fmt(widget.qty);
    }
  }

  String _fmt(double v) => (v % 1 == 0) ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _c,
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (s) {
        final v = double.tryParse(s);
        if (v != null) widget.onChanged(v < 0 ? 0 : v);
      },
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        border: OutlineInputBorder(),
      ),
    );
  }
}
