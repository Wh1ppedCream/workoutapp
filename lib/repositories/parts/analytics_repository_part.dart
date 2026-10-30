part of '../app_repository.dart';

/// Instance APIs for the analytics domain.
mixin _AnalyticsRepositoryMethods on _RepositoryDependencies {
  Future<void> updateRepMax(
    int defId,
    int repCount,
    String timeframe,
    double rmValue,
    double oneErm,
    bool isErm,
  ) => _dbHelper.upsertRepMax(
    defId,
    repCount,
    timeframe,
    rmValue,
    oneErm,
    isErm,
  );

  Future<void> updateVolumeMax(int defId, String timeframe, double vmValue) =>
      _dbHelper.upsertVolumeMax(defId, timeframe, vmValue);

  Future<List<RepMaxRow>> fetchRepMaxes(int defId, String timeframe) =>
      _dbHelper.fetchRepMaxes(defId, timeframe);

  Future<double?> fetchVolumeMax(int defId, String timeframe) =>
      _dbHelper.fetchVolumeMax(defId, timeframe);

  Future<double> calculateTotalVolumeForSessions(List<int> sessionIds) =>
      _dbHelper.calculateTotalVolumeForSessions(sessionIds);

  Future<List<MuscleBodyPart>> fetchBodyPartsForMuscle(int muscleId) =>
      _dbHelper.fetchBodyPartsForMuscle(muscleId);

  Future<List<MuscleBodyPart>> fetchMusclesForBodyPart(int bodypartId) =>
      _dbHelper.fetchMusclesForBodyPart(bodypartId);

  Future<int> setBodyPartRank(int bodypartId, int rank) =>
      _dbHelper.setBodyPartRank(bodypartId, rank);

  Future<BodyPartRanking?> getBodyPartRank(int bodypartId) =>
      _dbHelper.getBodyPartRank(bodypartId);

  Future<List<BodyPartRanking>> getAllBodyPartRanks() =>
      _dbHelper.getAllBodyPartRanks();

  Future<int> deleteBodyPartRank(int bodypartId) =>
      _dbHelper.deleteBodyPartRank(bodypartId);

  Future<int> setMuscleRank(int muscleId, int rank) =>
      _dbHelper.setMuscleRank(muscleId, rank);

  Future<MuscleRanking?> getMuscleRank(int muscleId) =>
      _dbHelper.getMuscleRank(muscleId);

  Future<List<MuscleRanking>> getAllMuscleRanks() =>
      _dbHelper.getAllMuscleRanks();

  Future<int> deleteMuscleRank(int muscleId) =>
      _dbHelper.deleteMuscleRank(muscleId);

  Future<ExerciseMusclePercent?> fetchExerciseMusclePercent(
    int defId,
    int muscleId,
  ) => _dbHelper.fetchExerciseMusclePercent(defId, muscleId);

  Future<List<ExerciseMusclePercent>> fetchPercentsForExercise(int defId) =>
      _dbHelper.fetchPercentsForExercise(defId);

  Future<int> setMuscleVolumeBounds(int muscleId, VolumeBoundaries b) =>
      _dbHelper.setMuscleVolumeBounds(muscleId, b);

  Future<VolumeBoundaries?> fetchMuscleVolumeBounds(int muscleId) =>
      _dbHelper.fetchMuscleVolumeBounds(muscleId);

  Future<List<Map<String, dynamic>>> fetchAllMuscleVolumeBounds() =>
      _dbHelper.fetchAllMuscleVolumeBounds();

  Future<int> removeMuscleVolumeBounds(int muscleId) =>
      _dbHelper.removeMuscleVolumeBounds(muscleId);

  Future<int> setBodyPartVolumeBounds(
    int bodyPartId,
    VolumeBoundaries bounds,
  ) => _dbHelper.setBodyPartVolumeBounds(bodyPartId, bounds);

  Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) =>
      _dbHelper.fetchBodyPartVolumeBounds(bodyPartId);

  Future<List<Map<String, dynamic>>> fetchAllBodyPartVolumeBounds() =>
      _dbHelper.fetchAllBodyPartVolumeBounds();

  Future<int> removeBodyPartVolumeBounds(int bodyPartId) =>
      _dbHelper.removeBodyPartVolumeBounds(bodyPartId);

  Future<List<ExerciseBodyPartPercent>> fetchBodyPartPercentsManual(
    int defId,
  ) => _dbHelper.fetchBodyPartPercentsManual(defId);

  Future<double> getFormulaStep() => _dbHelper.getFormulaStep();

  Future<double> getFormulaMin() => _dbHelper.getFormulaMin();

  Future<double> getFormulaMax() => _dbHelper.getFormulaMax();

  Future<Map<BodyPart, double>> estimateBodyPartSetDistribution(int defId) =>
      _dbHelper.estimateBodyPartSetDistribution(defId);

  Future<Map<BodyPart, double>> computeMuscleCalculatedBodyparts(int defId) =>
      _dbHelper.computeMuscleCalculatedBodyparts(defId);

  Future<Map<int, double>> fetchMuscleSetsForExerciseOverTimeRange({
    required int defId,
    required DateTime start,
    required DateTime end,
  }) => _dbHelper.fetchMuscleSetsForExerciseOverTimeRange(
    defId: defId,
    start: start,
    end: end,
  );

  Future<Map<int, double>> fetchSetsPerMuscle({
    required DateTime start,
    required DateTime end,
  }) => _dbHelper.fetchAllMuscleSetsOverTimeRange(start: start, end: end);

  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) => _dbHelper.fetchAllBodyPartSetsOverTimeRange(start: start, end: end);

  Future<Map<BodyPart, double>> fetchBodyPartSetsForExerciseOverTimeRange({
    required int defId,
    required DateTime start,
    required DateTime end,
  }) => _dbHelper.fetchBodyPartSetsForExerciseOverTimeRange(
    defId: defId,
    start: start,
    end: end,
  );

  Future<int> findExerciseDefinitionId(String name, String equipmentName) =>
      _dbHelper.findExerciseDefinitionId(name, equipmentName);

  Future<int> createProfile(String name) => _dbHelper.createProfile(name);

  Future<int> saveGymProfileAtomic({
    required GymProfile? existingProfile,
    required String name,
    required Set<int> equipmentIds,
  }) => _dbHelper.saveGymProfileAtomic(
    existingProfile: existingProfile,
    name: name,
    equipmentIds: equipmentIds,
  );
}
