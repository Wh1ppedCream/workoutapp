import 'temporal_semantics.dart';

/// A completed exercise's identity and stable cursor, independent of SQL rows.
class ExerciseHistoryEntry {
  const ExerciseHistoryEntry({
    required this.exerciseId,
    required this.sessionId,
    required this.completedAt,
    required this.calendarDay,
    required this.completedAtMilliseconds,
  });

  final int exerciseId;
  final int sessionId;
  final DateTime completedAt;
  final LocalCalendarDay calendarDay;
  final int completedAtMilliseconds;

  factory ExerciseHistoryEntry.fromDatabaseRow(Map<String, Object?> row) {
    final completedAt = TemporalSemantics.readLocalDateTime(
      epochMilliseconds: row['session_completed_at_ms'],
      legacyIso: row['session_date'],
    );
    return ExerciseHistoryEntry(
      exerciseId: row['exercise_id'] as int,
      sessionId: row['session_id'] as int,
      completedAt: completedAt,
      calendarDay: TemporalSemantics.readCalendarDay(
        calendarDay: row['session_training_day'],
        legacyIso: row['session_date'],
        epochMilliseconds: row['session_completed_at_ms'],
      ),
      completedAtMilliseconds:
          TemporalSemantics.tryReadEpochMilliseconds(
            row['session_completed_at_ms'],
          ) ??
          TemporalSemantics.utcEpochMilliseconds(completedAt),
    );
  }
}
