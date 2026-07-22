/// Where a resolved exercise allocation came from.
///
/// `legacy` is intentionally retained for installations that contain the
/// older percent rows and manual flags. It lets us preserve their results
/// without treating data written by old editor screens as a deliberate
/// personal override.
enum ExerciseAllocationSource {
  automatic,
  creatorDefault,
  personalOverride,
  legacy,
}

extension ExerciseAllocationSourceLabel on ExerciseAllocationSource {
  String get label => switch (this) {
    ExerciseAllocationSource.automatic => 'Automatic calculation',
    ExerciseAllocationSource.creatorDefault => 'Tonos default',
    ExerciseAllocationSource.personalOverride => 'Your custom allocation',
    ExerciseAllocationSource.legacy => 'Existing allocation',
  };
}

enum ExerciseAllocationDimension { muscle, bodyPart }

extension ExerciseAllocationDimensionStorage on ExerciseAllocationDimension {
  String get storageName => switch (this) {
    ExerciseAllocationDimension.muscle => 'muscle',
    ExerciseAllocationDimension.bodyPart => 'bodypart',
  };
}

/// The single source of truth for all derived anatomy values for one exercise.
///
/// Credits are contribution units for one completed set, not medical
/// percentages. The extra history maps preserve the legacy manual-toggle
/// behavior until a creator or personal allocation explicitly replaces it.
class ResolvedExerciseAllocation {
  final int exerciseDefinitionId;
  final Map<int, double> muscleCredits;
  final Map<int, double> bodyPartCredits;
  final Map<int, double> derivedBodyPartCredits;
  final Map<int, double> muscleHistoryCredits;
  final Map<int, double> bodyPartHistoryCredits;
  final ExerciseAllocationSource muscleSource;
  final ExerciseAllocationSource bodyPartSource;

  const ResolvedExerciseAllocation({
    required this.exerciseDefinitionId,
    required this.muscleCredits,
    required this.bodyPartCredits,
    required this.derivedBodyPartCredits,
    required this.muscleHistoryCredits,
    required this.bodyPartHistoryCredits,
    required this.muscleSource,
    required this.bodyPartSource,
  });

  ExerciseAllocationSource sourceFor(ExerciseAllocationDimension dimension) =>
      switch (dimension) {
        ExerciseAllocationDimension.muscle => muscleSource,
        ExerciseAllocationDimension.bodyPart => bodyPartSource,
      };
}
