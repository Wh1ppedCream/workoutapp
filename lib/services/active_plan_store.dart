import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/app_repository.dart';

/// Persists which plans should appear in the Train overview and Active Plans.
class ActivePlanStore {
  const ActivePlanStore({required AppRepository repository})
    : _repository = repository;

  final AppRepository _repository;

  Future<Set<int>> load(int? profileId) async {
    if (profileId == null) return const <int>{};
    final prefs = await SharedPreferences.getInstance();
    final legacyKey = _key(profileId);
    final legacyIds = prefs.getStringList(legacyKey);
    if (legacyIds != null) {
      final migrated =
          legacyIds.map((id) => int.tryParse(id)).whereType<int>().toSet();
      await _repository.replaceActivePlans(profileId, migrated);
      await prefs.remove(legacyKey);
    }
    return _repository.loadActivePlans(profileId);
  }

  Future<void> save(int profileId, Set<int> ids) async {
    await _repository.replaceActivePlans(profileId, ids);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(profileId));
  }

  Future<void> add(int profileId, int planId) async {
    await load(profileId);
    await _repository.addActivePlan(profileId, planId);
  }

  Future<void> remove(int profileId, int planId) async {
    await load(profileId);
    await _repository.removeActivePlan(profileId, planId);
  }

  String _key(int profileId) => 'train.active_presets.profile.$profileId';
}
