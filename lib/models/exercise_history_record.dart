import 'session_record_badge_models.dart';
import 'temporal_semantics.dart';
import 'workout_models.dart';

/// One hydrated history entry, preserving its recorded day and stable cursor.
class HistoryRecord {
  HistoryRecord({
    required this.date,
    required this.calendarDay,
    required this.sessionId,
    required this.exerciseId,
    required this.sessionCompletedAtMilliseconds,
    required List<ExerciseSet> sets,
    required this.badges,
  }) : sets = List.unmodifiable(sets);

  final DateTime date;
  final LocalCalendarDay calendarDay;
  final int sessionId;
  final int exerciseId;
  final int sessionCompletedAtMilliseconds;
  final List<ExerciseSet> sets;
  final WorkoutExerciseRecordBadges badges;

  DateTime get displayDateTime => calendarDay.atLocalTime(date);
}
