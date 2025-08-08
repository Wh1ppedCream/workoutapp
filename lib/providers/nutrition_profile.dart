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

  // Day scope
  DateTime day = DateTime.now();

  // Data for the day
  DayTotals? totals;
  NutritionGoal? activeGoal;
  List<DiaryEntry> meals = [];

  bool isLoading = false;
  String? error;

  NutritionProfile({AppRepository? repository})
      : _repo = repository ?? AppRepository() {
    _init();
  }

  Future<void> _init() async {
    isLoading = true; notifyListeners();
    try {
      await _repo.dbHelper.seedNutrientsIfEmpty();
      await _loadProfilesIfNeeded();
      await reloadDay(); // loads totals/goal/meals for [day]
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> _loadProfilesIfNeeded() async {
    if (profiles.isNotEmpty && current != null) return;
    profiles = await _repo.fetchAllProfiles();          // reuses your existing table
    if (profiles.isEmpty) {
      final id = await _repo.createProfile('General');
      // optional: prefill equipment like you do elsewhere
      profiles = await _repo.fetchAllProfiles();
      current = profiles.firstWhere((p) => p.id == id);
    } else {
      current = profiles.first;
    }
  }

  Future<void> selectProfile(GymProfile profile) async {
    current = profile;
    await reloadDay();
  }

  Future<void> setDay(DateTime d) async {
    day = DateTime(d.year, d.month, d.day); // clamp to local day
    await reloadDay();
  }

  Future<void> nextDay() => setDay(day.add(const Duration(days: 1)));
  Future<void> prevDay() => setDay(day.subtract(const Duration(days: 1)));

  Future<void> reloadDay() async {
    if (current?.id == null) return;
    isLoading = true; error = null; notifyListeners();
    try {
      totals     = await _repo.getDayTotals(current!.id!, day);
      activeGoal = await _repo.getActiveGoals(current!.id!, day);
      meals      = await _repo.getDiaryEntriesForDate(current!.id!, day);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  // Convenience wrappers for logging so UI can just call and refresh.
  Future<void> addFood({
    required MealType meal,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    double? gramsOverride,
    String? notes,
  }) async {
    if (current?.id == null) return;
    await _repo.addDiaryFood(
      profileId: current!.id!,
      date: day,
      mealType: meal,
      foodId: foodId,
      portionId: portionId,
      quantity: quantity,
      gramsOverride: gramsOverride,
      notes: notes,
    );
    await reloadDay();
  }

  Future<void> addRecipe({
    required MealType meal,
    required int recipeId,
    double quantity = 1.0,
    String? notes,
  }) async {
    if (current?.id == null) return;
    await _repo.addDiaryRecipe(
      profileId: current!.id!,
      date: day,
      mealType: meal,
      recipeId: recipeId,
      quantity: quantity,
      notes: notes,
    );
    await reloadDay();
  }

  Future<void> setGoals(NutritionGoal goal) async {
    await _repo.setGoals(goal);
    await reloadDay();
  }
}
