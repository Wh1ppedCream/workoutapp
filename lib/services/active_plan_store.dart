import 'package:shared_preferences/shared_preferences.dart';

/// Persists which plans should appear in the Train overview and Active Plans.
class ActivePlanStore {
  const ActivePlanStore._();

  static Future<Set<int>> load(int? profileId) async {
    if (profileId == null) return const <int>{};
    final prefs = await SharedPreferences.getInstance();
    final rawIds = prefs.getStringList(_key(profileId));
    if (rawIds == null) return const <int>{};
    return rawIds.map((id) => int.tryParse(id)).whereType<int>().toSet();
  }

  static Future<void> save(int profileId, Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key(profileId),
      ids.map((id) => id.toString()).toList(),
    );
  }

  static Future<void> add(int profileId, int planId) async {
    final ids = await load(profileId);
    if (ids.contains(planId)) return;
    await save(profileId, {...ids, planId});
  }

  static Future<void> remove(int profileId, int planId) async {
    final ids = await load(profileId);
    if (!ids.contains(planId)) return;
    await save(profileId, {...ids}..remove(planId));
  }

  static String _key(int profileId) =>
      'train.active_presets.profile.$profileId';
}
