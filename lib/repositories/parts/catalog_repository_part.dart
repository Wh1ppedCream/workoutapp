part of '../app_repository.dart';

/// Instance APIs for the catalog domain.
mixin _CatalogRepositoryMethods on _RepositoryDependencies {
  Future<List<Map<String, dynamic>>> lookupDefsByBodyPart(int id) =>
      _dbHelper.lookupDefsByBodyPart(id);

  Future<List<ExerciseDefinition>> lookupDefsDetailed() =>
      _dbHelper.lookupDefsDetailed();

  Future<List<ExerciseDefinition>> lookupDefsDetailedByIds(
    List<int> definitionIds,
  ) => _dbHelper.lookupDefsDetailedByIds(definitionIds);

  Future<List<Map<String, dynamic>>> fetchMostUsedExerciseDefinitionsRaw({
    int limit = 5,
  }) => _dbHelper.fetchMostUsedExerciseDefinitionsRaw(limit: limit);

  Future<List<Map<String, dynamic>>> fetchAllExercisesRaw() =>
      _dbHelper.fetchAllExercisesRaw();

  Future<List<ExerciseDefinition>> lookupDefsWithAnyEquipment(
    List<String> equipmentNames,
  ) => _dbHelper.lookupDefsWithAnyEquipment(equipmentNames);

  Future<List<ExerciseDefinition>> lookupDefsOnlyWithEquipment(
    List<String> equipmentNames, {
    bool includeNone = true,
  }) => _dbHelper.lookupDefsOnlyWithEquipment(
    equipmentNames,
    includeNone: includeNone,
  );

  Future<List<ExerciseDefinition>> lookupDefsFiltered({
    List<String>? equipmentNames,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) => _dbHelper.lookupDefsFiltered(
    equipmentNames: equipmentNames,
    bodypartIds: bodypartIds,
    muscleIds: muscleIds,
  );

  Future<List<ExerciseDefinition>> fetchCatalogDefinitions({
    required bool useProfileFilter,
    int? profileId,
    String? equipmentFilter,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) => _dbHelper.fetchCatalogDefinitions(
    useProfileFilter: useProfileFilter,
    profileId: profileId,
    equipmentFilter: equipmentFilter,
    bodypartIds: bodypartIds,
    muscleIds: muscleIds,
  );

  Future<int> addExerciseEquipmentMapping(int defId, int eqId) =>
      _dbHelper.insertExerciseEquipmentMapping(defId, eqId);

  Future<int> deleteExerciseEquipmentMapping(int defId, int eqId) =>
      _dbHelper.deleteExerciseEquipmentMapping(defId, eqId);

  Future<int> findOrCreateExerciseDefinition(
    String name,
    String equipmentName,
  ) => _dbHelper.findOrCreateExerciseDefinition(name, equipmentName);

  Future<Map<String, String?>> fetchDefinitionInfo(int defId) =>
      _dbHelper.fetchDefinitionInfo(defId);

  Future<List<ExerciseDefinition>> searchExerciseDefinitions(String query) =>
      _dbHelper.searchExerciseDefinitions(query);

  Future<ExerciseDefinition?> fetchDefinitionById(int defId) =>
      _dbHelper.getExerciseDefinitionById(defId);

  Future<ExerciseDefinition?> fetchDefinitionByCatalogId(String catalogId) =>
      _dbHelper.getExerciseDefinitionByCatalogId(catalogId);

  Future<List<ExerciseMediaItem>> fetchExerciseMedia(int defId) =>
      _dbHelper.getExerciseMedia(defId);

  Future<ExerciseMediaItem?> fetchPrimaryExerciseMedia(int defId) =>
      content.fetchPrimaryExerciseMedia(defId);

  Future<ContentManifest> syncBundledExerciseMediaManifest() =>
      content.syncBundledExerciseMediaManifest();

  Future<void> ensureExerciseMediaManifestReady() =>
      content.ensureExerciseMediaManifestReady();

  Future<void> ensureSharedMediaManifestReady() =>
      content.ensureSharedMediaManifestReady();

  Future<void> refreshSelectedContentEnvironment() =>
      content.refreshSelectedEnvironment();

  Future<ContentEnvironmentConfig> loadContentEnvironments() =>
      content.loadContentEnvironments();

  Future<ContentManifest> syncRemoteExerciseMediaManifest(Uri manifestUri) =>
      content.syncRemoteExerciseMediaManifest(manifestUri);

  Future<SharedMediaManifest> syncRemoteSharedMediaManifest(Uri manifestUri) =>
      content.syncRemoteSharedMediaManifest(manifestUri);

  Future<File?> cachedExerciseMediaFile(
    ExerciseMediaItem item, {
    required bool thumbnail,
  }) => content.cachedFileFor(item, thumbnail: thumbnail);

  Future<File> cacheExerciseMedia(
    ExerciseMediaItem item, {
    required bool thumbnail,
  }) => content.cacheMedia(item, thumbnail: thumbnail);

  Stream<ContentMediaCacheChange> get mediaCacheChanges =>
      content.mediaCacheChanges;

  Future<void> markExerciseMediaAccessed(ExerciseMediaItem item) =>
      content.markMediaAccessed(item);

  Future<void> reconcileMediaCache() => content.reconcileMediaCache();

  Future<SharedMediaItem?> fetchPrimarySharedMedia(
    SharedMediaEntityType entityType,
    int entityId,
  ) => content.fetchPrimarySharedMedia(entityType, entityId);

  Future<SharedMediaItem?> fetchPrimaryEquipmentMedia(int equipmentId) =>
      _repository.fetchPrimarySharedMedia(
        SharedMediaEntityType.equipment,
        equipmentId,
      );

  Future<SharedMediaItem?> fetchPrimaryBodyPartMedia(int bodyPartId) =>
      _repository.fetchPrimarySharedMedia(
        SharedMediaEntityType.bodypart,
        bodyPartId,
      );

  Future<SharedMediaItem?> fetchPrimaryMuscleMedia(int muscleId) => _repository
      .fetchPrimarySharedMedia(SharedMediaEntityType.muscle, muscleId);

  Future<File?> cachedSharedMediaFile(
    SharedMediaItem item, {
    required bool thumbnail,
  }) => content.cachedSharedMediaFile(item, thumbnail: thumbnail);

  Future<File> cacheSharedMedia(
    SharedMediaItem item, {
    required bool thumbnail,
  }) => content.cacheSharedMedia(item, thumbnail: thumbnail);

  Future<void> markSharedMediaAccessed(SharedMediaItem item) =>
      content.markSharedMediaAccessed(item);

  Future<ContentCacheUsage> getContentCacheUsage() => content.getCacheUsage();

  Future<ContentManifestStatus?> getContentManifestStatus(String namespace) =>
      content.getManifestStatus(namespace);

  Future<void> clearContentCache() => content.clearCache();

  Future<bool> isWifiOnlyMediaDownloadEnabled() =>
      content.isWifiOnlyMediaDownloadEnabled();

  Future<void> setWifiOnlyMediaDownloadEnabled(bool value) =>
      content.setWifiOnlyMediaDownloadEnabled(value);

  Future<void> replaceExerciseMedia(int defId, List<ExerciseMediaItem> items) =>
      _dbHelper.replaceExerciseMedia(defId, items);

  Future<void> deleteMeasurement(int measurementId) =>
      _dbHelper.deleteMeasurement(measurementId);

  Future<List<String>> fetchAllEquipmentNames() =>
      _dbHelper.fetchAllEquipmentNames();

  Future<List<BodyPart>> fetchAllBodyParts() => _dbHelper.fetchAllBodyParts();

  Future<List<Muscle>> fetchAllMuscles() => _dbHelper.fetchAllMuscles();

  Future<List<String>> fetchAllMuscleNames() => _dbHelper.fetchAllMuscleNames();

  Future<List<StretchDefinition>> fetchStretches({int? bodypartId}) =>
      _dbHelper.fetchStretches(bodypartId: bodypartId);

  Future<String?> fetchStretchDefinitionNameById(int stretchId) =>
      _dbHelper.fetchStretchDefinitionNameById(stretchId);

  Future<List<ExerciseDefinition>> fetchExerciseDefinitionsFiltered({
    List<String>? equipmentNames,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) => _dbHelper.lookupDefsFiltered(
    equipmentNames: equipmentNames,
    bodypartIds: bodypartIds,
    muscleIds: muscleIds,
  );

  Future<List<Equipment>> fetchAllEquipment() => _dbHelper.fetchAllEquipment();

  Future<int> createEquipment(String name) => _dbHelper.createEquipment(name);

  Future<void> updateEquipment(int id, String name) =>
      _dbHelper.updateEquipment(id, name);

  Future<void> deleteEquipment(int id) => _dbHelper.deleteEquipment(id);

  Future<List<BodyPart>> fetchAllBodyPartsFull() =>
      _dbHelper.fetchAllBodyPartsFull();

  Future<List<Muscle>> fetchAllMusclesFull() => _dbHelper.fetchAllMusclesFull();

  /// Performs fuzzy search on exercise definition names.
  Future<List<ExerciseDefinition>> fuzzsearchExercises(String term) =>
      _dbHelper.fuzzsearchExercises(term);
}
