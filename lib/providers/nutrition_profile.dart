// File: lib/providers/nutrition_profile.dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../repositories/app_repository.dart';
import '../repositories/food_catalog_repository.dart';
import '../models/gym_models.dart';
import '../models/nutrition_models.dart';
import '../services/safe_failure.dart';
import 'selected_profile.dart';

/// Diary mutations reject with [SafeFailure]. Callers must await/catch them
/// before showing success; the subsequent refresh is reconciliation, not a
/// retry of the write.
class NutritionProfile extends ChangeNotifier {
  final AppRepository _repo;
  late final FoodCatalogRepository _catalog;
  final int? initialProfileId;
  NutritionProfile? _parentScope;
  SelectedProfile? _boundSelectedProfile;
  VoidCallback? _selectedProfileListener;
  Future<void>? _boundProfileSyncFuture;
  late final Future<void> ready;

  // Profile state (still backed by gym_profiles in DB)
  List<GymProfile> profiles = [];
  GymProfile? current;

  // Day scope (clamped to local day)
  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime day;

  // Data for the day
  DayTotals? totals;
  NutritionGoal? activeGoal;

  // Store rich rows internally...
  List<DiaryEntryWithItem> _meals = [];

  // ...but keep a back-compat view that returns plain DiaryEntry.
  List<DiaryEntryWithItem> get mealsWithItems => _meals;
  List<DiaryEntry> get meals => _meals.map((r) => r.entry).toList();

  bool isLoading = false;
  SafeFailure? error;

  // Prevents out-of-order updates when multiple reloads race.
  int _reloadSeq = 0;
  int _profileVersion = 0;
  int _favoritesSeq = 0;

  // Prevent notifyListeners after dispose()
  bool _disposed = false;
  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  // Lightweight cache of favorites for snappy UI toggles
  final Set<int> favoriteFoodIds = {};
  // Prevent duplicate favorite ops racing
  final Set<(int, int)> _favoriteOpsInFlight = {};

  // Auto-advance “today” at midnight
  Timer? _midnightTimer;

  // Debounced coalescer for bursty updates
  Timer? _reloadDebounce;

  NutritionProfile({
    required AppRepository repository,
    DateTime? initialDay,
    this.initialProfileId,
  }) : _repo = repository,
       day = _dayOnly(initialDay ?? DateTime.now()) {
    _catalog = _repo.foodCatalog;
    ready = _init();
  }

  // Convenience
  int? get profileId => current?.id;
  bool get isToday => day.isAtSameMomentAs(_dayOnly(DateTime.now()));
  int get reloadSequence => _reloadSeq;

  /// Historical records own their date without changing the root summary or
  /// another records route. Writes still refresh the caller's current day.
  NutritionProfile createDayScope(DateTime date) => NutritionProfile(
    repository: _repo,
    initialDay: date,
    initialProfileId: profileId,
  ).._parentScope = this;

  /// Binds this nutrition provider to the composition-root [SelectedProfile]
  /// so profile selection, creation, renames, deletions, and empty-DB seeding
  /// share one authoritative profile state.
  void bindSelectedProfile(SelectedProfile selectedProfile) {
    if (_disposed || identical(_boundSelectedProfile, selectedProfile)) return;
    final previous = _boundSelectedProfile;
    final previousListener = _selectedProfileListener;
    if (previous != null && previousListener != null) {
      previous.removeListener(previousListener);
    }
    _boundSelectedProfile = selectedProfile;
    _selectedProfileListener = _handleSelectedProfileChanged;
    selectedProfile.addListener(_selectedProfileListener!);
    if (profiles.isNotEmpty || current != null) {
      _handleSelectedProfileChanged();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _reloadSeq++; // invalidate any in-flight reloads
    _favoritesSeq++;
    final bound = _boundSelectedProfile;
    final listener = _selectedProfileListener;
    if (bound != null && listener != null) {
      bound.removeListener(listener);
    }
    _boundSelectedProfile = null;
    _selectedProfileListener = null;
    _midnightTimer?.cancel();
    _reloadDebounce?.cancel();
    super.dispose();
    _parentScope?._requestReload();
  }

  Future<void> _init() async {
    try {
      // Seed core nutrient catalog on first run (idempotent).
      await _repo.seedNutrientsIfEmpty();
      if (_disposed) return;

      final parent = _parentScope;
      if (parent != null) {
        await parent.ready;
        if (_disposed) return;
        profiles = List.of(parent.profiles);
        current = parent.current;
      }

      await _loadProfilesIfNeeded();
      if (_disposed) return;

      // Warm favorites cache (best-effort; errors are non-fatal)
      await _refreshFavoritesSafe();
      if (_disposed) return;

      await reloadDay(); // loads totals/goal/meals for [day]
      if (_disposed) return;
      _scheduleMidnightTick();
    } catch (e) {
      error = SafeFailure.classify(e);
      _safeNotify();
    }
  }

  void _setLoading(bool v) {
    isLoading = v;
    _safeNotify();
  }

  void _handleSelectedProfileChanged() {
    final bound = _boundSelectedProfile;
    if (_disposed || bound == null) return;
    final previousId = current?.id;
    final previousName = current?.name;
    final previousCount = profiles.length;
    profiles = List.of(bound.profiles);
    current =
        bound.currentProfile ?? (profiles.isEmpty ? null : profiles.first);
    if (current?.id != previousId) {
      _boundProfileSyncFuture = _reloadForSelectedProfileChange();
    } else if (current?.name != previousName ||
        profiles.length != previousCount) {
      _safeNotify();
    }
  }

  Future<void> _reloadForSelectedProfileChange() async {
    if (_disposed) return;
    _invalidateProfileReads();
    final version = _profileVersion;
    if (current == null) {
      isLoading = false;
      totals = null;
      activeGoal = null;
      _meals = [];
      favoriteFoodIds.clear();
      _safeNotify();
      return;
    }
    await _refreshFavoritesSafe();
    if (_disposed || version != _profileVersion) return;
    await reloadDay();
  }

  void _invalidateProfileReads() {
    _profileVersion++;
    _reloadSeq++;
    _favoritesSeq++;
    favoriteFoodIds.clear();
    totals = null;
    activeGoal = null;
    _meals = [];
    error = null;
  }

  Future<void> _loadProfilesIfNeeded() async {
    final bound = _boundSelectedProfile;
    if (bound != null) {
      await bound.ready;
      if (_disposed) return;
      profiles = List.of(bound.profiles);
      if (initialProfileId != null && profiles.isNotEmpty) {
        current = profiles.firstWhere(
          (profile) => profile.id == initialProfileId,
          orElse: () => bound.currentProfile ?? profiles.first,
        );
      } else {
        current =
            bound.currentProfile ?? (profiles.isEmpty ? null : profiles.first);
      }
      return;
    }
    if (profiles.isNotEmpty && current != null) return;

    profiles = await _repo.fetchAllProfiles();
    if (_disposed) return;
    if (profiles.isEmpty) {
      final id = await _repo.createProfile('General');
      profiles = await _repo.fetchAllProfiles();
      current = profiles.firstWhere(
        (p) => p.id == id,
        orElse: () => profiles.first,
      );
    } else {
      current = profiles.firstWhere(
        (profile) => profile.id == initialProfileId,
        orElse: () => profiles.first,
      );
    }
  }

  /// Force refresh the profile list (e.g., after external edits).
  Future<void> refreshProfiles() async {
    final bound = _boundSelectedProfile;
    if (bound != null) {
      await bound.loadProfiles();
      final pending = _boundProfileSyncFuture;
      if (pending != null) {
        await pending;
      }
      return;
    }
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
      await _reloadForSelectedProfileChange();
    }
  }

  /// Reloads profile, favorites, and day nutrition state after the underlying
  /// SQLite database is replaced (for example, after backup import).
  Future<void> reloadFromDatabase() async {
    if (_disposed) return;
    _invalidateProfileReads();
    _boundProfileSyncFuture = null;
    final bound = _boundSelectedProfile;
    if (bound != null) {
      profiles = List.of(bound.profiles);
      current =
          bound.currentProfile ?? (profiles.isEmpty ? null : profiles.first);
    } else {
      profiles = await _repo.fetchAllProfiles();
      if (_disposed) return;
      final oldId = current?.id ?? initialProfileId;
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
    }
    await _reloadForSelectedProfileChange();
  }

  Future<void> selectProfile(GymProfile profile) async {
    final bound = _boundSelectedProfile;
    if (bound != null) {
      if (current?.id == profile.id && bound.currentProfile?.id == profile.id) {
        return;
      }
      await bound.selectProfile(profile);
      final pending = _boundProfileSyncFuture;
      if (pending != null) {
        await pending;
      }
      return;
    }
    if (current?.id == profile.id) return;
    current = profile;
    await _reloadForSelectedProfileChange();
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
    final bound = _boundSelectedProfile;
    if (bound != null) {
      await bound.createProfile(name);
      final pending = _boundProfileSyncFuture;
      if (pending != null) {
        await pending;
      }
      return;
    }
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

      final rows = List<DiaryEntryWithItem>.of(
        results[2] as List<DiaryEntryWithItem>,
      );
      rows.sort((a, b) => _compareMeals(a.entry, b.entry)); // reuse your sorter
      _meals = rows;

      _safeNotify();
    } catch (e) {
      if (_disposed || seq != _reloadSeq) return;
      error = SafeFailure.classify(e);
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
    _parentScope?._requestReload(delay: delay);
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(delay, () {
      if (_disposed) return;
      reloadDay();
    });
  }

  // Preserve the mutation failure for its caller even when a later day reload
  // succeeds. A failed write must never look like a successful Future<void>.
  Future<void> _runAndReload(Future<void> Function() action) async {
    if (profileId == null || _disposed) {
      throw const SafeFailure(
        kind: SafeFailureKind.validation,
        retryable: false,
      );
    }
    try {
      error = null;
      await action();
    } catch (e, stack) {
      final failure = SafeFailure.classify(e);
      error = failure;
      _safeNotify();
      Error.throwWithStackTrace(failure, stack);
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

  /// Batch-add multiple foods with a single reload. Items commit individually;
  /// on failure, callers must reconcile rather than blindly replay the batch.
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

  Future<bool> setGoals(NutritionGoal goal) async {
    if (profileId == null) return false;
    try {
      error = null;
      goal.validateTargets();
      await _repo.setGoals(goal);
      return true;
    } catch (e) {
      if (_disposed) return false;
      error = SafeFailure.classify(e);
      _safeNotify();
      return false;
    } finally {
      if (!_disposed) {
        _requestReload();
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Favorites
  // ─────────────────────────────────────────────────────────────────────

  Future<void> _refreshFavoritesSafe() async {
    final requestedProfileId = profileId;
    final version = _profileVersion;
    final seq = ++_favoritesSeq;
    if (_disposed || requestedProfileId == null) return;
    try {
      // Grab a reasonably large page; adjust if you expect more.
      final favs = await _repo.listFavorites(requestedProfileId, limit: 500);
      if (_disposed ||
          requestedProfileId != profileId ||
          version != _profileVersion ||
          seq != _favoritesSeq) {
        return;
      }
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
    final requestedProfileId = profileId;
    final version = _profileVersion;
    if (_disposed || requestedProfileId == null) return;
    final operation = (requestedProfileId, foodId);
    if (!_favoriteOpsInFlight.add(operation)) return;

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
        await _repo.removeFavorite(requestedProfileId, foodId);
      } else {
        await _repo.addFavorite(requestedProfileId, foodId);
      }
    } catch (e) {
      if (_disposed ||
          requestedProfileId != profileId ||
          version != _profileVersion) {
        return;
      }
      // Roll back
      if (wasFav) {
        favoriteFoodIds.add(foodId);
      } else {
        favoriteFoodIds.remove(foodId);
      }
      error = SafeFailure.classify(e);
      _safeNotify();
    } finally {
      _favoriteOpsInFlight.remove(operation);
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
