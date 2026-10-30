part of '../app_repository.dart';

/// Instance APIs for the preset domain.
mixin _PresetRepositoryMethods on _RepositoryDependencies {
  Future<int> createPreset(
    String name, {
    int? profileId,
    bool isDraft = false,
  }) => _dbHelper.createPreset(name, profileId: profileId, isDraft: isDraft);

  Future<int> createPresetAtomic({
    required String name,
    required int? profileId,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
    bool activate = false,
    bool uniqueName = false,
    bool isDraft = false,
  }) => _dbHelper.createPresetAtomic(
    name: name,
    profileId: profileId,
    exercises: exercises,
    autoSettings: autoSettings,
    activate: activate,
    uniqueName: uniqueName,
    isDraft: isDraft,
  );

  Future<void> replacePresetAtomic({
    required int presetId,
    required String? name,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
    bool publishDraft = false,
  }) => _dbHelper.replacePresetAtomic(
    presetId: presetId,
    name: name,
    exercises: exercises,
    autoSettings: autoSettings,
    publishDraft: publishDraft,
  );

  Future<Map<String, dynamic>?> fetchDraftPresetForProfile(int profileId) =>
      _dbHelper.fetchDraftPresetForProfile(profileId);

  Future<void> deleteDraftPresetsForProfile(int profileId) =>
      _dbHelper.deleteDraftPresetsForProfile(profileId);

  Future<void> savePresetAutoConfigurationAtomic({
    required int presetId,
    required PresetAutoConfigurationWrite configuration,
  }) => _dbHelper.savePresetAutoConfigurationAtomic(
    presetId: presetId,
    configuration: configuration,
  );

  Future<int> findOrCreatePreset(String name, {int? profileId}) =>
      _dbHelper.findOrCreatePreset(name, profileId: profileId);

  Future<List<Map<String, dynamic>>> fetchAllPresetsRaw({int? profileId}) =>
      _dbHelper.fetchAllPresetsRaw(profileId: profileId);

  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({
    int? profileId,
  }) => _dbHelper.fetchPresetSummariesRaw(profileId: profileId);

  Future<List<Map<String, dynamic>>> fetchPresetFocusSetCountsRaw({
    required List<int> presetIds,
  }) => _dbHelper.fetchPresetFocusSetCountsRaw(presetIds: presetIds);

  Future<PresetDefinition?> fetchPresetById(int presetId) =>
      _dbHelper.fetchPresetById(presetId);

  Future<void> updatePresetName(int presetId, String name) =>
      _dbHelper.updatePresetName(presetId, name);

  Future<void> deletePreset(int presetId) => _dbHelper.deletePreset(presetId);

  Future<int> addExerciseToPreset(
    int presetId,
    int? exerciseDefId,
    String type,
    int orderIndex,
  ) => _dbHelper.addExerciseToPreset(presetId, exerciseDefId, type, orderIndex);

  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) =>
      _dbHelper.fetchPresetExercises(presetId);

  Future<void> deletePresetExercises(int presetId) =>
      _dbHelper.deletePresetExercises(presetId);

  Future<void> savePresetWeightSets(
    int presetExerciseId,
    List<ExerciseSet> parents,
    Map<int, List<ExerciseSet>> children,
  ) => _dbHelper.savePresetWeightSets(presetExerciseId, parents, children);

  Future<List<Map<String, dynamic>>> fetchPresetSets(int presetExerciseId) =>
      _dbHelper.fetchPresetSets(presetExerciseId);

  Future<void> savePresetCardio(
    int presetExerciseId,
    String cardioName,
    String? note,
    int plannedMinutes,
    int elapsedSeconds,
  ) => _dbHelper.savePresetCardio(
    presetExerciseId,
    cardioName,
    note,
    plannedMinutes,
    elapsedSeconds,
  );

  Future<Map<String, dynamic>?> fetchPresetCardio(int presetExerciseId) =>
      _dbHelper.fetchPresetCardio(presetExerciseId);

  Future<void> savePresetStretch(
    int presetExerciseId,
    List<Map<String, dynamic>> items,
  ) => _dbHelper.savePresetStretch(presetExerciseId, items);

  Future<List<Map<String, dynamic>>> fetchPresetStretchItems(
    int presetExerciseId,
  ) => _dbHelper.fetchPresetStretchItems(presetExerciseId);

  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) =>
      _dbHelper.fetchPresetAutoSettings(presetId);

  Future<void> upsertPresetAutoSettings({
    required int presetId,
    required bool isAutomatic,
    required double globalIncrement,
    required bool skipFirstSet,
    required bool weightCheck,
    required bool repCheck,
    required bool volumeCheck,
    required bool adjustAllSets,
    required bool useManualSelect,
    String? manualSelectionJson,
    String? successCountMode,
  }) => _dbHelper.upsertPresetAutoSettings(
    presetId: presetId,
    isAutomatic: isAutomatic,
    globalIncrement: globalIncrement,
    skipFirstSet: skipFirstSet,
    weightCheck: weightCheck,
    repCheck: repCheck,
    volumeCheck: volumeCheck,
    adjustAllSets: adjustAllSets,
    useManualSelect: useManualSelect,
    manualSelectionJson: manualSelectionJson,
    successCountMode: successCountMode,
  );

  Future<void> deletePresetAutoSettings(int presetId) =>
      _dbHelper.deletePresetAutoSettings(presetId);

  Future<Map<String, dynamic>?> fetchPresetExerciseAuto(int presetExerciseId) =>
      _dbHelper.fetchPresetExerciseAuto(presetExerciseId);

  Future<void> upsertPresetExerciseAuto({
    required int presetExerciseId,
    double? incrementAmount,
    required int lastSetIndex,
    String? lastNode,
  }) => _dbHelper.upsertPresetExerciseAuto(
    presetExerciseId: presetExerciseId,
    incrementAmount: incrementAmount,
    lastSetIndex: lastSetIndex,
    lastNode: lastNode,
  );

  Future<void> deletePresetExerciseAuto(int presetExerciseId) =>
      _dbHelper.deletePresetExerciseAuto(presetExerciseId);

  Future<Map<String, dynamic>?> fetchPresetSetAuto(int presetSetId) =>
      _dbHelper.fetchPresetSetAuto(presetSetId);

  Future<void> upsertPresetSetAuto({
    required int presetSetId,
    double? incrementAmount,
  }) => _dbHelper.upsertPresetSetAuto(
    presetSetId: presetSetId,
    incrementAmount: incrementAmount,
  );

  Future<void> deletePresetSetAuto(int presetSetId) =>
      _dbHelper.deletePresetSetAuto(presetSetId);

  Future<void> updatePresetSetWeight(int presetSetId, double weight) =>
      _dbHelper.updatePresetSetWeight(presetSetId, weight);

  Future<void> updatePresetSetReps(int presetSetId, int reps) =>
      _dbHelper.updatePresetSetReps(presetSetId, reps);

  Future<int> addPresetSet({
    required int presetExerciseId,
    required double weight,
    required int reps,
    required int orderIndex,
    int? parentSetId,
  }) => _dbHelper.addPresetSet(
    presetExerciseId: presetExerciseId,
    weight: weight,
    reps: reps,
    orderIndex: orderIndex,
    parentSetId: parentSetId,
  );

  Future<int> deletePresetSet(int presetSetId) =>
      _dbHelper.deletePresetSet(presetSetId);

  Future<void> applyPresetProgressionBatch(
    PresetProgressionBatch progression,
  ) => _dbHelper.applyPresetProgressionBatch(progression);

  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() =>
      _dbHelper.loadPendingWorkoutProgressions();

  Future<void> recordPendingWorkoutProgressionFailure(int sessionId) =>
      _dbHelper.recordPendingWorkoutProgressionFailure(sessionId);

  Future<void> completePendingWorkoutProgression({
    required int sessionId,
    required PresetProgressionBatch progression,
  }) => _dbHelper.completePendingWorkoutProgression(
    sessionId: sessionId,
    progression: progression,
  );

  /// Flow‐chart JSON for a preset.
  Future<FlowDefinition> fetchFlowDefinition(int presetId) async {
    final jsonStr = await _dbHelper.fetchFlowDefinition(presetId);
    return FlowDefinition.fromJson(jsonStr);
  }

  Future<void> upsertFlowDefinition(int presetId, FlowDefinition def) =>
      _dbHelper.upsertFlowDefinition(presetId, def.toJson());

  Future<List<FlowMethod>> fetchFlowMethods(int presetId) async {
    final rows = await _dbHelper.fetchFlowMethods(presetId);
    return _flowMethodsFromRows(rows);
  }

  Future<FlowMethod> upsertFlowMethod({
    required int presetId,
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
  }) async {
    final id = await _dbHelper.upsertFlowMethod(
      presetId: presetId,
      name: name,
      type: type.toShortString(),
      params: params,
    );
    return _flowMethodFromValues(
      id: id,
      presetId: presetId,
      name: name,
      type: type,
      params: params,
    );
  }

  Future<void> deleteFlowMethod(int methodId) =>
      _dbHelper.deleteFlowMethod(methodId);

  Future<FlowMethod> saveFlowMethodAtomic({
    required int presetId,
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
    int? previousMethodId,
    String? previousName,
  }) async {
    if (previousName == null || previousName == name) {
      return _repository.upsertFlowMethod(
        presetId: presetId,
        name: name,
        type: type,
        params: params,
      );
    }
    final id = await _dbHelper.saveFlowMethodAtomic(
      presetId: presetId,
      name: name,
      type: type.toShortString(),
      params: params,
      previousMethodId: previousMethodId,
      previousName: previousName,
    );
    return _flowMethodFromValues(
      id: id,
      presetId: presetId,
      name: name,
      type: type,
      params: params,
    );
  }

  Future<bool> getUseManualBodyparts(int defId) =>
      _dbHelper.getUseManualBodyparts(defId);

  Future<bool> getUseManualMuscles(int defId) =>
      _dbHelper.getUseManualMuscles(defId);

  Future<bool> getMultiplyByRating(int defId) =>
      _dbHelper.getMultiplyByRating(defId);

  Future<String> fetchDefaultFlow(String scope, {int? profileId}) =>
      _dbHelper.fetchDefaultFlow(scope, profileId: profileId);

  Future<void> upsertDefaultFlow(
    String scope, {
    int? profileId,
    required String flowJson,
  }) => _dbHelper.upsertDefaultFlow(
    scope,
    profileId: profileId,
    flowJson: flowJson,
  );

  Future<void> deleteDefaultFlow(String scope, {int? profileId}) =>
      _dbHelper.deleteDefaultFlow(scope, profileId: profileId);

  Future<List<FlowMethod>> fetchDefaultFlowMethods(
    String scope, {
    int? profileId,
  }) async {
    final rows = await _dbHelper.fetchDefaultFlowMethods(
      scope,
      profileId: profileId,
    );
    return _defaultFlowMethodsFromRows(rows, profileId: profileId);
  }

  /// Upsert one default flow‐method and return its real id.
  Future<FlowMethod> upsertDefaultFlowMethod({
    required String scope,
    int? profileId,
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
  }) async {
    final id = await _dbHelper.upsertDefaultFlowMethod(
      scope,
      profileId: profileId,
      name: name,
      type: type.toShortString(),
      params: params,
    );
    return FlowMethod(
      id: id, // ✅ real row id
      // this model uses `presetId`; for defaults we stash the profileId or -1
      presetId: profileId ?? -1,
      name: name,
      type: type,
      params: params,
    );
  }

  /// Copies a new app-wide rule into existing profile defaults. Existing
  /// profile rules with the same name stay untouched.
  Future<int> copyAppDefaultRuleToExistingProfiles({
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
  }) => _dbHelper.copyAppDefaultRuleToExistingProfiles(
    name: name,
    type: type.toShortString(),
    params: params,
  );

  /// Copies a new profile-default rule into that profile's existing plans.
  /// Existing plan rules with the same name stay untouched.
  Future<int> copyProfileDefaultRuleToExistingPlans({
    required int profileId,
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
  }) => _dbHelper.copyProfileDefaultRuleToExistingPlans(
    profileId: profileId,
    name: name,
    type: type.toShortString(),
    params: params,
  );

  List<FlowMethod> _flowMethodsFromRows(List<Map<String, dynamic>> rows) {
    return rows.map(FlowMethod.fromMap).toList();
  }

  List<FlowMethod> _defaultFlowMethodsFromRows(
    List<Map<String, dynamic>> rows, {
    int? profileId,
  }) {
    return rows.map((row) {
      return FlowMethod(
        id: (row['id'] as int?) ?? row.hashCode,
        presetId: profileId ?? -1,
        name: row['name'] as String,
        type: MethodTypeX.fromString(row['type'] as String),
        params: _decodeFlowMethodParams(row['params']),
      );
    }).toList();
  }

  Map<String, dynamic> _decodeFlowMethodParams(Object? rawParams) {
    if (rawParams is Map<String, dynamic>) {
      return rawParams;
    }
    if (rawParams is String && rawParams.trim().isNotEmpty) {
      return jsonDecode(rawParams) as Map<String, dynamic>;
    }
    return <String, dynamic>{};
  }

  FlowMethod _flowMethodFromValues({
    required int id,
    required int presetId,
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
  }) {
    return FlowMethod(
      id: id,
      presetId: presetId,
      name: name,
      type: type,
      params: params,
    );
  }

  Future<void> deleteDefaultFlowMethod({
    required String scope,
    int? profileId,
    required String name,
  }) => _dbHelper.deleteDefaultFlowMethod(
    scope,
    profileId: profileId,
    name: name,
  );

  Future<FlowMethod> saveDefaultFlowMethodAtomic({
    required String scope,
    int? profileId,
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
    String? previousName,
  }) async {
    if (previousName == null || previousName == name) {
      return _repository.upsertDefaultFlowMethod(
        scope: scope,
        profileId: profileId,
        name: name,
        type: type,
        params: params,
      );
    }
    final id = await _dbHelper.saveDefaultFlowMethodAtomic(
      scope,
      profileId: profileId,
      name: name,
      type: type.toShortString(),
      params: params,
      previousName: previousName,
    );
    return FlowMethod(
      id: id,
      presetId: profileId ?? -1,
      name: name,
      type: type,
      params: params,
    );
  }

  Future<void> renameFlowMethodReferences({
    required int presetId,
    required String oldName,
    required String newName,
  }) => _dbHelper.renameFlowMethodReferences(
    presetId: presetId,
    oldName: oldName,
    newName: newName,
  );

  Future<void> deleteFlowMethodAndReferences(FlowMethod method) =>
      _dbHelper.deleteFlowMethodAndReferences(
        presetId: method.presetId,
        methodId: method.id,
        methodName: method.name,
      );

  Future<void> renameDefaultFlowMethodReferences({
    required String scope,
    int? profileId,
    required String oldName,
    required String newName,
  }) => _dbHelper.renameDefaultFlowMethodReferences(
    scope,
    profileId: profileId,
    oldName: oldName,
    newName: newName,
  );

  Future<void> deleteDefaultFlowMethodAndReferences({
    required String scope,
    int? profileId,
    required String name,
  }) => _dbHelper.deleteDefaultFlowMethodAndReferences(
    scope,
    profileId: profileId,
    name: name,
  );

  Future<FlowDefinition> fetchDefaultFlowDefinition(
    String scope, {
    int? profileId,
  }) => _dbHelper.fetchDefaultFlowDefinition(scope, profileId: profileId);
}
