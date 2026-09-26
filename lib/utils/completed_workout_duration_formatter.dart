import '../l10n/generated/app_localizations.dart';

/// Formats persisted completed-workout durations from their canonical seconds.
///
/// Short workouts retain seconds; hour-scale totals intentionally omit seconds
/// to keep summary surfaces compact.
String formatCompletedWorkoutDuration(
  AppLocalizations strings,
  int durationSeconds,
) {
  final seconds = durationSeconds < 0 ? 0 : durationSeconds;
  final hours = seconds ~/ Duration.secondsPerHour;
  final minutes =
      (seconds % Duration.secondsPerHour) ~/ Duration.secondsPerMinute;
  final remainingSeconds = seconds % Duration.secondsPerMinute;

  if (hours > 0) {
    return strings.durationHoursMinutes(hours, minutes);
  }
  if (minutes > 0) {
    return strings.durationMinutesSeconds(minutes, remainingSeconds);
  }
  return strings.durationSeconds(remainingSeconds);
}
