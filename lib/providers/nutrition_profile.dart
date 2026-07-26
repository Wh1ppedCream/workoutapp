// File: lib/providers/nutrition_profile.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../repositories/app_repository.dart';
import '../repositories/food_catalog_repository.dart';
import '../models/gym_models.dart';
import '../models/nutrition_models.dart';

class NutritionProfile extends ChangeNotifier {
  final AppRepository _repo;
  late final FoodCatalogRepository _catalog;

  // Profile state (still backed by gym_profiles in DB)
  List<GymProfile> profiles = [];
  GymProfile? current;

  // Day scope (clamped to local day)
  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime day = _dayOnly(DateTime.now());

  // Data for the day
  DayTotals? totals;
  NutritionGoal? activeGoal;

  // Store rich rows internally...
  List<DiaryEntryWithItem> _meals = [];

  // ...but keep a back-compat view that returns plain DiaryEntry.
  List<DiaryEntryWithItem> get mealsWithItems => _meals;
  List<DiaryEntry> get meals => _meals.map((r) => r.entry).toList();

  bool isLoading = false;
  String? error;

  // Prevents out-of-order updates when multiple reloads race.
  int _reloadSeq = 0;

  // Prevent notifyListeners after dispose()
  bool _disposed = false;
  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  // Lightweight cache of favorites for snappy UI toggles
  final Set<int> favoriteFoodIds = {};
  // Prevent duplicate favorite ops racing
  final Set<int> _favoriteOpsInFlight = {};

  // Auto-advance “today” at midnight
  Timer? _midnightTimer;

  // Debounced coalescer for bursty updates
  Timer? _reloadDebounce;

  NutritionProfile({required AppRepository repository}) : _repo = repository {
    _catalog = _repo.foodCatalog;
    _init();
  }

  // Convenience
  int? get profileId => current?.id;
  bool get isToday => day.isAtSameMomentAs(_dayOnly(DateTime.now()));

  @override
  void dispose() {
    _disposed = true;
    _reloadSeq++; // invalidate any in-flight reloads
    _midnightTimer?.cancel();
    _reloadDebounce?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      // Seed core nutrient catalog on first run (idempotent).
      await _repo.seedNutrientsIfEmpty();

      await _loadProfilesIfNeeded();

      // Warm favorites cache (best-effort; errors are non-fatal)
      await _refreshFavoritesSafe();

      await reloadDay(); // loads totals/goal/meals for [day]
      _scheduleMidnightTick();
    } catch (e) {
      error = e.toString();
      _safeNotify();
    }
  }

  void _setLoading(bool v) {
    isLoading = v;
    _safeNotify();
  }

  Future<void> _loadProfilesIfNeeded() async {
    if (profiles.isNotEmpty && current != null) return;

    profiles = await _repo.fetchAllProfiles();
    if (profiles.isEmpty) {
      final id = await _repo.createProfile('General');
      profiles = await _repo.fetchAllProfiles();
      current = profiles.firstWhere(
        (p) => p.id == id,
        orElse: () => profiles.first,
      );
    } else {
      current = profiles.first;
    }
  }

  /// Force refresh the profile list (e.g., after external edits).
  Future<void> refreshProfiles() async {
    final oldId = current?.id;

    profiles = await _repo.fetchAllProfiles();

    if (profiles.isEmpty) {
      current = null;
    } else if (oldId != null) {
      current = profiles.firstWhere(
        (p) => p.id == oldId,
        orElse: () => profiles.first,
      );
    } else {
      current = profiles.first;
    }

    _safeNotify();

    // If the active profile changed, refresh related state.
    if (current?.id != oldId) {
      await _refreshFavoritesSafe();
      await reloadDay();
    }
  }

  Future<void> selectProfile(GymProfile profile) async {
    if (current?.id == profile.id) return;
    current = profile;
    await _refreshFavoritesSafe();
    await reloadDay();
  }

  Future<void> selectProfileById(int profileId) async {
    if (profiles.isEmpty) await _loadProfilesIfNeeded();
    final p = profiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => profiles.first,
    );
    await selectProfile(p);
  }

  /// Creates a profile and selects it.
  Future<void> createAndSelectProfile(String name) async {
    final id = await _repo.createProfile(name);
    await refreshProfiles();
    if (profiles.isNotEmpty) {
      final p = profiles.firstWhere(
        (p) => p.id == id,
        orElse: () => profiles.first,
      );
      await selectProfile(p);
    }
  }

  Future<void> setDay(DateTime d) async {
    final nd = _dayOnly(d.toLocal()); // clamp to local day
    if (nd.isAtSameMomentAs(day)) return; // avoid redundant reloads
    day = nd;
    await reloadDay();
  }

  Future<void> goToday() => setDay(DateTime.now());
  Future<void> nextDay() => setDay(day.add(const Duration(days: 1)));
  Future<void> prevDay() => setDay(day.subtract(const Duration(days: 1)));

  // ---------- Sorting helpers: stable meal → time → id ----------
  int _mealOrder(MealType m) => m.index; // customize if needed
  int _safeId(DiaryEntry e) => e.id ?? 0;

  int _compareMeals(DiaryEntry a, DiaryEntry b) {
    final c0 = _mealOrder(a.mealType).compareTo(_mealOrder(b.mealType));
    if (c0 != 0) return c0;

    // Normalize to local for stable ordering
    final at = (a.loggedAt ?? DateTime.fromMillisecondsSinceEpoch(0)).toLocal();
    final bt = (b.loggedAt ?? DateTime.fromMillisecondsSinceEpoch(0)).toLocal();
    final c1 = at.compareTo(bt);
    if (c1 != 0) return c1;

    return _safeId(a).compareTo(_safeId(b));
  }

  Future<void> reloadDay() async {
    if (profileId == null) return;

    final seq = ++_reloadSeq; // capture my turn
    _setLoading(true);
    error = null;

    try {
      // Fetch in parallel for snappier UI.
      final results = await Future.wait([
        _repo.getDayTotals(profileId!, day),
        _repo.getActiveGoals(profileId!, day),
        _repo.getDiaryEntriesWithItemsForDate(profileId!, day),
      ]);

      // If a newer reload started or we got disposed, drop these results.
      if (_disposed || seq != _reloadSeq) return;

      totals = results[0] as DayTotals;
      activeGoal = results[1] as NutritionGoal?;

      final rows = results[2] as List<DiaryEntryWithItem>;
      rows.sort((a, b) => _compareMeals(a.entry, b.entry)); // reuse your sorter
      _meals = rows;

      _safeNotify();
    } catch (e) {
      if (_disposed || seq != _reloadSeq) return;
      error = e.toString();
      _safeNotify();
    } finally {
      if (!_disposed && seq == _reloadSeq) {
        _setLoading(false);
      }
    }
  }

  // Debounced reload helper: coalesce bursty writes into one refresh.
  void _requestReload({Duration delay = const Duration(milliseconds: 80)}) {
    if (_disposed) return;
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(delay, () {
      if (_disposed) return;
      reloadDay();
    });
  }

  // Small helper to run an action and then reload safely
  Future<void> _runAndReload(Future<void> Function() action) async {
    if (profileId == null) return;
    try {
      error = null;
      await action();
    } catch (e) {
      if (_disposed) return;
      error = e.toString();
      _safeNotify();
    } finally {
      if (!_disposed) {
        _requestReload(); // debounced instead of immediate await reloadDay()
      }
    }
  }

  // ── Search & preview helpers ─────────────────────────────────────────────

  /// Search foods by name/brand/etc. (uses FTS if available).
  Future<List<Food>> searchFoods(String query, {int limit = 50}) =>
      _catalog.searchFoods(query, limit: limit);

  /// Fetch all portions for a selected food (default first, if present).
  Future<List<FoodPortion>> portionsFor(int foodId) =>
      _catalog.getPortionsForFood(foodId);

  /// Preview macros/micros for a portion selection before logging.
  Future<Map<String, double>> previewPortion({
    required int foodId,
    required int portionId,
    double quantity = 1.0,
  }) => _catalog.calcForPortion(
    foodId: foodId,
    portionId: portionId,
    quantity: quantity,
  );

  /// Macro snapshot per 100g with legacy-safe keys.
  Future<Map<String, double>> macroPer100g(int foodId) =>
      _catalog.getMacroPer100gLegacySafe(foodId);

  // ── Logging helpers (accept new fields) ─────────────────────────────

  Future<void> addFood({
    required MealType meal,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    double? gramsOverride,
    double? loggedGrams, // pass through to DAO
    DateTime? loggedAt, // pass through to DAO
    String? notes,
  }) async {
    await _runAndReload(() async {
      await _repo.addDiaryFood(
        profileId: profileId!,
        date: day,
        mealType: meal,
        foodId: foodId,
        portionId: portionId,
        quantity: quantity,
        gramsOverride: gramsOverride,
        loggedGrams: loggedGrams,
        loggedAt: loggedAt,
        notes: notes,
      );
    });
  }

  /// Adds a food, choosing a sensible portion if none is provided.
  /// - Picks the default portion if present; otherwise first portion; otherwise none.
  Future<void> addFoodSmart({
    required MealType meal,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    double? gramsOverride,
    double? loggedGrams,
    DateTime? loggedAt,
    String? notes,
  }) async {
    var pid = portionId;
    if (pid == null) {
      final portions = await _catalog.getPortionsForFood(foodId);
      FoodPortion? def;
      try {
        def = portions.firstWhere((p) => p.isDefault == true);
      } catch (_) {
        def = portions.isNotEmpty ? portions.first : null;
      }
      pid = def?.id;
    }
    await addFood(
      meal: meal,
      foodId: foodId,
      portionId: pid,
      quantity: quantity,
      gramsOverride: gramsOverride,
      loggedGrams: loggedGrams,
      loggedAt: loggedAt,
      notes: notes,
    );
  }

  /// Adds a food choosing a sensible portion (default/first) and a sensible
  /// timestamp (now if today, noon otherwise) if not provided.
  Future<void> addFoodSmartWithDefaultTime({
    required MealType meal,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    double? gramsOverride,
    double? loggedGrams,
    DateTime? loggedAt,
    String? notes,
  }) {
    final stamp = loggedAt ?? _defaultLogTimeForDay(day);
    return addFoodSmart(
      meal: meal,
      foodId: foodId,
      portionId: portionId,
      quantity: quantity,
      gramsOverride: gramsOverride,
      loggedGrams: loggedGrams,
      loggedAt: stamp,
      notes: notes,
    );
  }

  /// Log a food with smart defaults for both portion and time.
  Future<void> logFoodAuto({
    required MealType meal,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    double? gramsOverride,
    double? loggedGrams,
    DateTime? loggedAt,
    String? notes,
  }) {
    final stamp = loggedAt ?? _defaultLogTimeForDay(day);
    return addFoodSmart(
      meal: meal,
      foodId: foodId,
      portionId: portionId,
      quantity: quantity,
      gramsOverride: gramsOverride,
      loggedGrams: loggedGrams,
      loggedAt: stamp,
      notes: notes,
    );
  }

  /// Batch-add multiple foods with a single reload.
  Future<void> addFoodsBatch(
    List<
      ({
        MealType meal,
        int foodId,
        int? portionId,
        double quantity,
        double? gramsOverride,
        double? loggedGrams,
        DateTime? loggedAt,
        String? notes,
      })
    >
    items,
  ) async {
    await _runAndReload(() async {
      for (final i in items) {
        await _repo.addDiaryFood(
          profileId: profileId!,
          date: day,
          mealType: i.meal,
          foodId: i.foodId,
          portionId: i.portionId,
          quantity: i.quantity,
          gramsOverride: i.gramsOverride,
          loggedGrams: i.loggedGrams,
          loggedAt: i.loggedAt,
          notes: i.notes,
        );
      }
    });
  }

  Future<void> addRecipe({
    required MealType meal,
    required int recipeId,
    double quantity = 1.0,
    DateTime? loggedAt, // NEW
    String? notes,
  }) async {
    await _runAndReload(() async {
      await _repo.addDiaryRecipe(
        profileId: profileId!,
        date: day,
        mealType: meal,
        recipeId: recipeId,
        quantity: quantity,
        loggedAt: loggedAt,
        notes: notes,
      );
    });
  }

  /// Convenience: add a recipe with a sensible default timestamp (parity with foods).
  Future<void> addRecipeWithDefaultTime({
    required MealType meal,
    required int recipeId,
    double quantity = 1.0,
    DateTime? loggedAt,
    String? notes,
  }) {
    final stamp = loggedAt ?? _defaultLogTimeForDay(day);
    return addRecipe(
      meal: meal,
      recipeId: recipeId,
      quantity: quantity,
      loggedAt: stamp,
      notes: notes,
    );
  }

  Future<void> updateEntry(DiaryEntry e) async {
    await _runAndReload(() => _repo.updateDiaryEntry(e));
  }

  Future<void> deleteEntry(int entryId) async {
    await _runAndReload(
      () => _repo.deleteDiaryEntry(entryId, profileId: profileId!, date: day),
    );
  }

  Future<void> setGoals(NutritionGoal goal) async {
    await _runAndReload(() => _repo.setGoals(goal));
  }

  // ─────────────────────────────────────────────────────────────────────
  // Favorites
  // ─────────────────────────────────────────────────────────────────────

  Future<void> _refreshFavoritesSafe() async {
    if (profileId == null) return;
    try {
      // Grab a reasonably large page; adjust if you expect more.
      final favs = await _repo.listFavorites(profileId!, limit: 500);
      favoriteFoodIds
        ..clear()
        ..addAll(favs.map((f) => f.id!));
      _safeNotify();
    } catch (_) {
      // Non-fatal
    }
  }

  /// Public refresh for favorites without reloading the whole day.
  Future<void> refreshFavorites() => _refreshFavoritesSafe();

  bool isFavorite(int foodId) => favoriteFoodIds.contains(foodId);

  Future<void> toggleFavorite(int foodId) async {
    if (profileId == null) return;
    if (_favoriteOpsInFlight.contains(foodId)) return;
    _favoriteOpsInFlight.add(foodId);

    final wasFav = favoriteFoodIds.contains(foodId);

    // Optimistic update
    if (wasFav) {
      favoriteFoodIds.remove(foodId);
    } else {
      favoriteFoodIds.add(foodId);
    }
    _safeNotify();

    try {
      if (wasFav) {
        await _repo.removeFavorite(profileId!, foodId);
      } else {
        await _repo.addFavorite(profileId!, foodId);
      }
    } catch (e) {
      // Roll back
      if (wasFav) {
        favoriteFoodIds.add(foodId);
      } else {
        favoriteFoodIds.remove(foodId);
      }
      error = e.toString();
      _safeNotify();
    } finally {
      _favoriteOpsInFlight.remove(foodId);
    }
  }

  /// Typed accessors for favorites/recents (useful in picker UIs).
  Future<List<Food>> favoriteFoods({int limit = 100}) async {
    if (profileId == null) return const [];
    return _repo.listFavorites(profileId!, limit: limit);
  }

  Future<List<Food>> recentFoods({int limit = 20}) async {
    if (profileId == null) return const [];
    return _repo.getRecentFoods(profileId!, limit: limit);
  }

  Future<List<Recipe>> recentRecipes({int limit = 20}) async {
    if (profileId == null) return const [];
    return _repo.getRecentRecipes(profileId!, limit: limit);
  }

  // ─────────────────────────────────────────────────────────────────────
  // Tags
  // ─────────────────────────────────────────────────────────────────────

  Future<void> addTag({required int entryId, required String tag}) async {
    await _runAndReload(() => _repo.addDiaryTag(entryId, tag));
  }

  Future<void> removeTag({required int entryId, required String tag}) async {
    await _runAndReload(() => _repo.removeDiaryTag(entryId, tag));
  }

  /// Fetch entries anywhere in (optional) range that have [tag].
  Future<List<DiaryEntry>> entriesByTag({
    required String tag,
    DateTime? start,
    DateTime? end,
    int limit = 200,
  }) async {
    if (profileId == null) return const [];
    return _repo.getEntriesByTag(
      profileId: profileId!,
      tag: tag,
      start: start,
      end: end,
      limit: limit,
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Barcode quick-log
  // ─────────────────────────────────────────────────────────────────────

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  Future<void> addFoodByBarcode({
    required MealType meal,
    required String barcode,
    int? portionId,
    double quantity = 1.0,
    DateTime? loggedAt,
    String? notes,
  }) async {
    final normalized = _digitsOnly(barcode);
    final food = await _catalog.getFoodByBarcode(normalized);
    if (food == null) {
      // Surface a clear, user-friendly message; UI can catch and display.
      throw StateError('No food found for barcode: $barcode');
    }
    await addFood(
      meal: meal,
      foodId: food.id!,
      portionId: portionId,
      quantity: quantity,
      loggedAt: loggedAt,
      notes: notes,
    );
  }

  /// Barcode quick-log that also chooses a default portion if caller didn't specify one.
  Future<void> addFoodByBarcodeSmart({
    required MealType meal,
    required String barcode,
    int? portionId,
    double quantity = 1.0,
    DateTime? loggedAt,
    String? notes,
  }) async {
    final normalized = _digitsOnly(barcode);
    final food = await _catalog.getFoodByBarcode(normalized);
    if (food == null) {
      throw StateError('No food found for barcode: $barcode');
    }
    await addFoodSmart(
      meal: meal,
      foodId: food.id!,
      portionId: portionId,
      quantity: quantity,
      loggedAt: loggedAt,
      notes: notes,
    );
  }

  /// Barcode quick-log with a sensible default timestamp when none provided.
  Future<void> addFoodByBarcodeWithDefaultTime({
    required MealType meal,
    required String barcode,
    int? portionId,
    double quantity = 1.0,
    DateTime? loggedAt,
    String? notes,
  }) {
    final stamp = loggedAt ?? _defaultLogTimeForDay(day);
    return addFoodByBarcodeSmart(
      meal: meal,
      barcode: barcode,
      portionId: portionId,
      quantity: quantity,
      loggedAt: stamp,
      notes: notes,
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Day micros & cache maintenance
  // ─────────────────────────────────────────────────────────────────────

  /// Returns selected micronutrients for the current [day] keyed by code.
  /// Example codes: 'IRON_MG', 'SODIUM_MG', 'FIBER_G', etc.
  Future<Map<String, double>> getDayMicros(List<String> codes) async {
    if (profileId == null) return const {};
    return _repo.getDayMicros(profileId!, day, codes);
  }

  /// Force a rebuild of [day] totals cache (useful after big imports/edits).
  Future<void> recalcTodayTotals() async {
    if (profileId == null) return;
    await _repo.recalcDayTotals(profileId!, day);
    await reloadDay();
  }

  /// Force maintenance + fresh read for the current day (cache + optional FTS rebuild).
  Future<void> refreshTodayHard() async {
    if (profileId == null) return;
    await _repo.recalcDayTotals(profileId!, day);
    await _repo.rebuildFoodFts(); // no-op if FTS not present
    await reloadDay();
  }

  /// Rebuild cache for a range of local days (inclusive).
  Future<void> recalcRange(DateTime start, DateTime end) async {
    if (profileId == null) return;
    var s = DateTime(start.year, start.month, start.day);
    var e = DateTime(end.year, end.month, end.day);
    if (s.isAfter(e)) {
      final t = s;
      s = e;
      e = t;
    }
    for (var d = s; !d.isAfter(e); d = d.add(const Duration(days: 1))) {
      await _repo.recalcDayTotals(profileId!, d);
    }
    if (!day.isBefore(s) && !day.isAfter(e)) {
      await reloadDay();
    }
  }

  /// Clear a previously surfaced error without forcing a reload.
  void clearError() {
    if (error != null) {
      error = null;
      _safeNotify();
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Derived/grouped views
  // ─────────────────────────────────────────────────────────────────────

  /// Convenience map for UI sectioning by meal type.
  Map<MealType, List<DiaryEntry>> get mealsByType {
    final map = {for (final m in MealType.values) m: <DiaryEntry>[]};
    for (final e in meals) {
      map[e.mealType]!.add(e);
    }
    return map;
  }

  // ─────────────────────────────────────────────────────────────────────
  // Ergonomic defaults for time & progress
  // ─────────────────────────────────────────────────────────────────────

  DateTime _defaultLogTimeForDay(DateTime localDay) {
    final today = _dayOnly(DateTime.now());
    return localDay.isAtSameMomentAs(today)
        ? DateTime.now()
        : DateTime(localDay.year, localDay.month, localDay.day, 12); // noon
  }

  /// Add a food but auto-fill loggedAt if not supplied so sorting feels natural.
  Future<void> addFoodWithDefaultTime({
    required MealType meal,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    double? gramsOverride,
    double? loggedGrams,
    DateTime? loggedAt,
    String? notes,
  }) {
    final stamp = loggedAt ?? _defaultLogTimeForDay(day);
    return addFood(
      meal: meal,
      foodId: foodId,
      portionId: portionId,
      quantity: quantity,
      gramsOverride: gramsOverride,
      loggedGrams: loggedGrams,
      loggedAt: stamp,
      notes: notes,
    );
  }

  /// Explicitly refresh the current day only (helpful after silent updates).
  Future<void> reloadIfToday() async {
    if (isToday) await reloadDay();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Midnight auto-advance
  // ─────────────────────────────────────────────────────────────────────

  void _scheduleMidnightTick() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final delay = nextMidnight.difference(now);

    _midnightTimer = Timer(delay, () async {
      _midnightTimer = null;
      if (_disposed) return;

      final today = _dayOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));

      // If the view was on "today" before midnight, switch to new day.
      if (day.isAtSameMomentAs(yesterday)) {
        day = today;
        await reloadDay();
      }

      if (!_disposed) {
        _scheduleMidnightTick(); // reschedule for the following midnight
      }
    });
  }

  // Fast-path wrappers so UI code can “quick log” with sensible defaults.
  Future<void> quickLogFood({
    required MealType meal,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    String? notes,
  }) {
    return addFoodSmartWithDefaultTime(
      meal: meal,
      foodId: foodId,
      portionId: portionId,
      quantity: quantity,
      notes: notes,
    );
  }

  Future<void> quickLogRecipe({
    required MealType meal,
    required int recipeId,
    double quantity = 1.0,
    String? notes,
  }) {
    return addRecipeWithDefaultTime(
      meal: meal,
      recipeId: recipeId,
      quantity: quantity,
      notes: notes,
    );
  }
}
