part of '../app_repository.dart';

/// Instance APIs for the workout domain.
mixin _WorkoutRepositoryMethods on _RepositoryDependencies {
  /// Fetches all sessions as raw maps ordered by completion instant descending.
  Future<List<Map<String, dynamic>>> fetchAllSessions() =>
      _dbHelper.getAllSessionsRaw();

  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async {
    final rows = await _dbHelper.fetchWorkoutReportSessionsRaw(
      start: start,
      end: end,
    );
    return rows
        .map(
          (row) => WorkoutReportSession(
            id: row['session_id'] as int,
            date: TemporalSemantics.readLocalDateTime(
              epochMilliseconds: row['completed_at_ms'],
              legacyIso: row['date'],
            ),
            calendarDayKey: TemporalSemantics.readCalendarDay(
              calendarDay: row['training_day'],
              legacyIso: row['date'],
              epochMilliseconds: row['completed_at_ms'],
            ).storageKey,
            durationSeconds: (row['duration'] as num).toInt(),
            totalVolume: ((row['total_volume'] as num?) ?? 0).toDouble(),
            exerciseCount: ((row['exercise_count'] as num?) ?? 0).toInt(),
            setCount: ((row['set_count'] as num?) ?? 0).toInt(),
          ),
        )
        .toList();
  }

  /// Deletes a session by its ID, cascading to related exercises & sets.
  Future<void> deleteSession(int id) => _dbHelper.deleteSession(id);

  Future<int> completeWorkoutAtomic({
    required DateTime completedAt,
    required int durationSeconds,
    required List<WorkoutExerciseWrite> exercises,
    int? autoPresetId,
  }) => _dbHelper.completeWorkoutAtomic(
    completedAt: completedAt,
    durationSeconds: durationSeconds,
    exercises: exercises,
    autoPresetId: autoPresetId,
  );

  Future<void> replaceSessionExercisesAtomic({
    required int sessionId,
    required List<WorkoutExerciseWrite> exercises,
  }) => _dbHelper.replaceSessionExercisesAtomic(
    sessionId: sessionId,
    exercises: exercises,
  );

  Future<void> saveActiveWorkoutDraft({
    required DateTime startedAt,
    required int? autoPresetId,
    required String payloadJson,
  }) => _dbHelper.saveActiveWorkoutDraft(
    startedAt: startedAt,
    autoPresetId: autoPresetId,
    payloadJson: payloadJson,
  );

  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() =>
      _dbHelper.loadActiveWorkoutDraft();

  Future<void> clearActiveWorkoutDraft() => _dbHelper.clearActiveWorkoutDraft();

  /// Fetches a single session by ID (or null).
  Future<WorkoutSession?> fetchSessionById(int id) =>
      _dbHelper.fetchSessionById(id);

  /// Updates an existing session's completion instant and duration.
  Future<void> updateSession(int id, DateTime d, int dur) =>
      _dbHelper.updateSession(id, d, dur);

  /// Retrieves sessions in the inclusive exact-instant range [start, end].
  Future<List<WorkoutSession>> fetchSessionsInRange(DateTime s, DateTime e) =>
      _dbHelper.fetchSessionsInRange(s, e);

  /// Adds a weight-based exercise to a session.
  Future<int> addExercise(int sid, String name, String eq, int idx) =>
      _dbHelper.addExercise(sid, name, eq, idx);

  /// Fetches exercise rows for a session.
  Future<List<Map<String, dynamic>>> fetchExercises(int sid) =>
      _dbHelper.fetchExercisesRaw(sid);

  /// Calculates record badges for the completed parent sets in a session.
  Future<Map<int, WorkoutExerciseRecordBadges>> fetchSessionRecordBadges(
    int sessionId,
  ) => _dbHelper.fetchSessionRecordBadges(sessionId);

  Future<Map<int, WorkoutExerciseRecordBadges>> fetchExerciseRecordBadges(
    Iterable<int> exerciseIds,
  ) => _dbHelper.fetchExerciseRecordBadges(exerciseIds);

  /// Returns current all-time and calendar-month leaders for one exercise.
  /// This powers leaderboard-style records, not historical award views.
  Future<Map<int, WorkoutExerciseRecordBadges>>
  fetchCurrentExerciseRecordBadges(int definitionId) =>
      _dbHelper.fetchCurrentExerciseRecordBadges(definitionId);

  Future<List<Map<String, dynamic>>> fetchRecentWeightExerciseHistoryRows({
    required int definitionId,
    int? beforeCompletedAtMilliseconds,
    int? beforeExerciseId,
    int limit = 10,
  }) => _dbHelper.fetchRecentWeightExerciseHistoryRows(
    definitionId: definitionId,
    beforeCompletedAtMilliseconds: beforeCompletedAtMilliseconds,
    beforeExerciseId: beforeExerciseId,
    limit: limit,
  );

  Future<List<Map<String, dynamic>>> fetchExerciseOneRmTrendRows({
    required int definitionId,
    int limit = 60,
  }) => _dbHelper.fetchExerciseOneRmTrendRows(
    definitionId: definitionId,
    limit: limit,
  );

  /// Deletes all exercises (and related details) in a session.
  Future<void> deleteExercises(int sid) => _dbHelper.deleteExercises(sid);

  /// Inserts a generic exercise row of any type (weight, cardio, stretch).
  Future<int> addExerciseRow({
    int? exerciseDefId,
    required String type,
    required int orderIndex,
    required int sessionId,
    int? sourcePresetExerciseId,
  }) => _dbHelper.addExerciseRow(
    exerciseDefId: exerciseDefId,
    type: type,
    orderIndex: orderIndex,
    sessionId: sessionId,
    sourcePresetExerciseId: sourcePresetExerciseId,
  );

  /// Fetches a fully-detailed [WorkoutExercise] by its ID.
  Future<WorkoutExercise?> fetchDetailedExercise(int id) =>
      _dbHelper.fetchDetailedExercise(id);

  /// Deletes an exercise instance by its ID.
  Future<void> deleteExercise(int id) => _dbHelper.deleteExercise(id);

  /// Inserts a single set row for an exercise.
  Future<int> addSet(int exerciseId, double weight, int reps, int orderIndex) =>
      _dbHelper.addSet(exerciseId, weight, reps, orderIndex);

  /// Inserts parent and child sets for a weight exercise.
  Future<void> addWeightSets({
    required int exerciseId,
    required List<ExerciseSet> parentSets,
    required Map<int, List<ExerciseSet>> childChangeSets,
  }) => _dbHelper.addWeightSets(
    exerciseId: exerciseId,
    parentSets: parentSets,
    childChangeSets: childChangeSets,
  );

  /// Fetches all sets for an exercise.
  Future<List<Map<String, dynamic>>> fetchSets(int exerciseId) =>
      _dbHelper.fetchSetsRaw(exerciseId);

  /// Update a single weight set’s weight & reps.
  Future<void> updateSet(int setId, double weight, int reps) =>
      _dbHelper.updateSet(setId, weight, reps);

  /// Delete a single set by its ID.
  Future<void> deleteSet(int setId) => _dbHelper.deleteSet(setId);

  /// Reorders sets within an exercise by their IDs.
  Future<void> reorderSets(int exerciseId, List<int> setIds) =>
      _dbHelper.reorderSets(exerciseId, setIds);

  /// Canonical getter (matches DatabaseHelper).
  Future<Map<String, dynamic>?> getCardioDetailsForExercise(int exerciseId) =>
      _dbHelper.getCardioDetailsForExercise(exerciseId);

  /// Fetches cardio details by exercise ID.
  Future<Map<String, dynamic>?> fetchCardioDetails(int exerciseId) =>
      _dbHelper.fetchCardioDetails(exerciseId);

  /// Update cardio details for an exercise.
  Future<void> updateCardioDetails({
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) => _dbHelper.updateCardioDetails(
    exerciseId: exerciseId,
    cardioName: cardioName,
    note: note,
    plannedMinutes: plannedMinutes,
    elapsedSeconds: elapsedSeconds,
  );

  /// Delete cardio details for a specific exercise.
  Future<void> deleteCardioDetails(int exerciseId) =>
      _dbHelper.deleteCardioDetails(exerciseId);

  /// Strongly-typed variant.
  Future<void> saveClassStretchInstance({
    required int exerciseId,
    required List<StretchInstance> instances,
  }) => _dbHelper.saveClassStretchInstance(
    exerciseId: exerciseId,
    instances: instances,
  );

  /// Saves a stretch instance and its items for an exercise.
  Future<void> saveStretchInstance({
    required int exerciseId,
    required List<Map<String, dynamic>> items,
  }) => _dbHelper.saveStretchInstance(exerciseId: exerciseId, items: items);

  /// Fetches stretch items for an exercise.
  Future<List<Map<String, dynamic>>> fetchStretchItems(int id) =>
      _dbHelper.fetchStretchItemsRaw(id);

  /// Updates a single stretch item’s fields.
  Future<int> updateStretchItem({
    required int itemId,
    int? stretchId,
    bool? isCustom,
    String? customName,
    String? customDesc,
    bool? isChecked,
    int? orderIndex,
  }) => _dbHelper.updateStretchItem(
    itemId: itemId,
    stretchId: stretchId,
    isCustom: isCustom,
    customName: customName,
    customDesc: customDesc,
    isChecked: isChecked,
    orderIndex: orderIndex,
  );

  /// Deletes a single stretch item by ID.
  Future<void> deleteStretchItem(int itemId) =>
      _dbHelper.deleteStretchItem(itemId);

  /// Delete an entire stretch instance and its items.
  Future<void> deleteStretchInstance(int exerciseId) =>
      _dbHelper.deleteStretchInstance(exerciseId);

  /// Reorders stretch items by their IDs.
  Future<void> reorderStretchItems(int exerciseId, List<int> itemIds) =>
      _dbHelper.reorderStretchItems(exerciseId, itemIds);

  /// Returns all sessions as WorkoutSession objects, newest first.
  Future<List<WorkoutSession>> fetchWorkoutSessions() =>
      _dbHelper.fetchWorkoutSessions();
}
