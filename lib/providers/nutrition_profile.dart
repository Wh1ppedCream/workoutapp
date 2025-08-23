// File: lib/providers/nutrition_profile.dart
import 'package:flutter/foundation.dart';

import '../repositories/app_repository.dart';
import '../models/gym_models.dart';
import '../models/nutrition_models.dart';

class NutritionProfile extends ChangeNotifier {
  final AppRepository _repo;

  // Profile state (still backed by gym_profiles in DB)
  List<GymProfile> profiles = [];
  GymProfile? current;

  // Day scope (clamped to local day)
  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime day = _dayOnly(DateTime.now());

  // Data for the day
  DayTotals? totals;
  NutritionGoal? activeGoal;
  List<DiaryEntry> meals = [];

  bool isLoading = false;
  String? error;

  // Prevents out-of-order updates when multiple reloads race.
  int _reloadSeq = 0;

  // Prevent notifyListeners after dispose()
  bool _disposed = false;
  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  NutritionProfile({AppRepository? repository})
      : _repo = repository ?? AppRepository() {
    _init();
  }

  // Convenience
  int? get profileId => current?.id;
  bool get isToday => day.isAtSameMomentAs(_dayOnly(DateTime.now()));

  @override
  void dispose() {
    _disposed = true;
    _reloadSeq++; // invalidate any in-flight reloads
    super.dispose();
  }

  Future<void> _init() async {
    _setLoading(true);
    try {
      // Seed core nutrient catalog on first run (idempotent).
      await _repo.seedNutrientsIfEmpty();

      await _loadProfilesIfNeeded();
      await reloadDay(); // loads totals/goal/meals for [day]
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
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
      current = profiles.firstWhere((p) => p.id == id, orElse: () => profiles.first);
    } else {
      current = profiles.first;
    }
  }

  /// Force refresh the profile list (e.g., after external edits).
  Future<void> refreshProfiles() async {
    profiles = await _repo.fetchAllProfiles();

    if (profiles.isEmpty) {
      current = null;
    } else if (current != null) {
      current = profiles.firstWhere(
        (p) => p.id == current!.id,
        orElse: () => profiles.first,
      );
    } else {
      current = profiles.first;
    }
    _safeNotify();
  }

  Future<void> selectProfile(GymProfile profile) async {
    if (current?.id == profile.id) return;
    current = profile;
    await reloadDay();
  }

  Future<void> selectProfileById(int profileId) async {
    if (profiles.isEmpty) await _loadProfilesIfNeeded();
    final p = profiles.firstWhere((p) => p.id == profileId, orElse: () => profiles.first);
    await selectProfile(p);
  }

  /// Creates a profile and selects it.
  Future<void> createAndSelectProfile(String name) async {
    final id = await _repo.createProfile(name);
    await refreshProfiles();
    if (profiles.isNotEmpty) {
      final p = profiles.firstWhere((p) => p.id == id, orElse: () => profiles.first);
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
        _repo.getDiaryEntriesForDate(profileId!, day),
      ]);

      // If a newer reload started or we got disposed, drop these results.
      if (_disposed || seq != _reloadSeq) return;

      totals     = results[0] as DayTotals;
      activeGoal = results[1] as NutritionGoal?;
      meals      = results[2] as List<DiaryEntry>;
      _safeNotify();
    } catch (e) {
      if (_disposed || seq != _reloadSeq) return;
      error = e.toString();
      _safeNotify();
    } finally {
      if (_disposed || seq != _reloadSeq) return;
      _setLoading(false);
    }
  }

  // ── Small helper to run an action and then reload safely ─────────────
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
      if (_disposed) return;
      await reloadDay();
    }
  }

  // ── Logging helpers (accept new fields) ─────────────────────────────

  Future<void> addFood({
    required MealType meal,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    double? gramsOverride,
    double? loggedGrams,        // pass through to DAO
    DateTime? loggedAt,         // pass through to DAO
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

  Future<void> updateEntry(DiaryEntry e) async {
    await _runAndReload(() => _repo.updateDiaryEntry(e));
  }

  Future<void> deleteEntry(int entryId) async {
    await _runAndReload(() => _repo.deleteDiaryEntry(entryId, profileId: profileId!, date: day));
  }

  Future<void> setGoals(NutritionGoal goal) async {
    await _runAndReload(() => _repo.setGoals(goal));
  }
}
