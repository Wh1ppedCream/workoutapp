part of '../exercise_progress_section.dart';

class _ExerciseProgressSectionData {
  final List<_ExerciseTrendTile> tiles;

  const _ExerciseProgressSectionData({required this.tiles});
}

class _ExerciseTrendTile {
  final ExerciseDefinition definition;
  final List<ExerciseOneRmPoint> points;

  const _ExerciseTrendTile({required this.definition, required this.points});

  ExerciseOneRmPoint? get latestPoint => points.isEmpty ? null : points.last;
}
