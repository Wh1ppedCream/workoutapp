import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/app_repository.dart';

/// Persists which plans should appear in the Train overview and Active Plans.
class ActivePlanStore {
  const ActivePlanStore._();

  static final AppRepository _repository = AppRepository();
  static AppRepository? _repositoryOverride;

  static AppRepository get _activeRepository =>
      _repositoryOverride ?? _repository;

  @visibleForTesting
  static void useRepositoryForTesting(AppRepository? repository) {
    _repositoryOverride = repository;
  }

  static Future<Set<int>> load(int? profileId) async {
    if (profileId == null) return const <int>{};
    final prefs = await SharedPreferences.getInstance();
    final legacyKey = _key(profileId);
    final legacyIds = prefs.getStringList(legacyKey);
    if (legacyIds != null) {
      final migrated =
          legacyIds.map((id) => int.tryParse(id)).whereType<int>().toSet();
      await _activeRepository.replaceActivePlans(profileId, migrated);
      await prefs.remove(legacyKey);
    }
    return _activeRepository.loadActivePlans(profileId);
  }

  static Future<void> save(int profileId, Set<int> ids) async {
    await _activeRepository.replaceActivePlans(profileId, ids);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(profileId));
  }

  static Future<void> add(int profileId, int planId) async {
    await load(profileId);
    await _activeRepository.addActivePlan(profileId, planId);
  }

  static Future<void> remove(int profileId, int planId) async {
    await load(profileId);
    await _activeRepository.removeActivePlan(profileId, planId);
  }

  static String _key(int profileId) =>
      'train.active_presets.profile.$profileId';
}
