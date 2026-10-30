part of '../exercise_progress_section.dart';

class _ExerciseProgressSectionData {
  final List<_ExerciseTrendTile> tiles;

  const _ExerciseProgressSectionData({required this.tiles});
}

class _ExerciseTrendTile {
  final ExerciseDefinition definition;
  final List<_ExerciseProgressPoint> points;

  const _ExerciseTrendTile({required this.definition, required this.points});

  _ExerciseProgressPoint? get latestPoint =>
      points.isEmpty ? null : points.last;
}

class _ExerciseProgressPoint {
  final int sessionId;
  final DateTime completedAt;
  final LocalCalendarDay calendarDay;
  final double? actualOneRm;
  final double estimatedOneRm;

  const _ExerciseProgressPoint({
    required this.sessionId,
    required this.completedAt,
    required this.calendarDay,
    required this.actualOneRm,
    required this.estimatedOneRm,
  });

  DateTime get displayDateTime => calendarDay.atLocalTime(completedAt);

  factory _ExerciseProgressPoint.fromRow(Map<String, dynamic> row) {
    return _ExerciseProgressPoint(
      sessionId: row['session_id'] as int,
      completedAt: TemporalSemantics.readLocalDateTime(
        epochMilliseconds: row['completed_at_ms'],
        legacyIso: row['session_date'],
      ),
      calendarDay: TemporalSemantics.readCalendarDay(
        calendarDay: row['training_day'],
        legacyIso: row['session_date'],
        epochMilliseconds: row['completed_at_ms'],
      ),
      actualOneRm: (row['actual_one_rm'] as num?)?.toDouble(),
      estimatedOneRm: ((row['estimated_one_rm'] as num?) ?? 0).toDouble(),
    );
  }
}
