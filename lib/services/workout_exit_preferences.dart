import 'package:shared_preferences/shared_preferences.dart';

/// Controls what the ongoing-workout Exit action does.
enum WorkoutExitBehavior {
  askEveryTime,
  discard,
  saveCompleted,
}

class WorkoutExitPreferences {
  static const _key = 'workout_exit_behavior';

  const WorkoutExitPreferences();

  Future<WorkoutExitBehavior> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    return WorkoutExitBehavior.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => WorkoutExitBehavior.askEveryTime,
    );
  }

  Future<void> save(WorkoutExitBehavior behavior) async {
    final prefs = await SharedPreferences.getInstance();
    if (behavior == WorkoutExitBehavior.askEveryTime) {
      await prefs.remove(_key);
      return;
    }
    await prefs.setString(_key, behavior.name);
  }
}
