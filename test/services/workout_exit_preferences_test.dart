import 'package:env_test/services/workout_exit_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const preferences = WorkoutExitPreferences();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('asks by default and persists explicit choices', () async {
    expect(await preferences.load(), WorkoutExitBehavior.askEveryTime);

    await preferences.save(WorkoutExitBehavior.saveCompleted);
    expect(await preferences.load(), WorkoutExitBehavior.saveCompleted);

    await preferences.save(WorkoutExitBehavior.discard);
    expect(await preferences.load(), WorkoutExitBehavior.discard);
  });

  test('ask every time clears a remembered choice', () async {
    await preferences.save(WorkoutExitBehavior.saveCompleted);
    await preferences.save(WorkoutExitBehavior.askEveryTime);

    expect(await preferences.load(), WorkoutExitBehavior.askEveryTime);
  });
}
