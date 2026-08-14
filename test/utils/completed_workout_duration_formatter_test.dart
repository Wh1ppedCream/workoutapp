import 'package:env_test/l10n/generated/app_localizations_en.dart';
import 'package:env_test/utils/completed_workout_duration_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final strings = AppLocalizationsEn();

  test('formats completed-workout seconds without rounding short sessions', () {
    expect(formatCompletedWorkoutDuration(strings, -1), '0s');
    expect(formatCompletedWorkoutDuration(strings, 38), '38s');
    expect(formatCompletedWorkoutDuration(strings, 60), '1m 0s');
    expect(formatCompletedWorkoutDuration(strings, 72), '1m 12s');
    expect(formatCompletedWorkoutDuration(strings, 3599), '59m 59s');
    expect(formatCompletedWorkoutDuration(strings, 3600), '1h 0m');
    expect(formatCompletedWorkoutDuration(strings, 3901), '1h 5m');
  });

  test('formats the summed duration once instead of rounding each session', () {
    const sessions = [38, 38];
    final totalSeconds = sessions.fold<int>(0, (sum, value) => sum + value);

    expect(formatCompletedWorkoutDuration(strings, totalSeconds), '1m 16s');
  });
}
