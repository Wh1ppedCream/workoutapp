/// Declares how every durable database table participates in a database backup.
///
/// Database exports intentionally do not include SharedPreferences, downloaded
/// media files, diagnostics, or files the user saved outside the app. Those are
/// separate lifecycle concerns, not silently omitted database rows.
enum DatabaseBackupDataClass {
  /// Information entered or explicitly customized by the person using Tonos.
  userOwned,

  /// Rows that may contain user choices while also referencing bundled data.
  mixed,

  /// Bundled or cloud-managed metadata recreated by the current app version.
  appOwned,

  /// Deterministic output calculated from authoritative rows.
  derived,

  /// Download, search, or performance metadata with no user value by itself.
  cache,

  /// Short-lived state that is still important for a safe user recovery.
  recovery,
}

enum DatabaseBackupRestoreAction {
  /// Include rows in the portable snapshot and restore them directly.
  restore,

  /// Omit rows and recreate them from authoritative restored data.
  rebuild,

  /// Omit rows and discard any existing local value during full replacement.
  discard,
}

class DatabaseBackupTablePolicy {
  const DatabaseBackupTablePolicy({
    required this.name,
    required this.dataClass,
    required this.restoreAction,
  });

  final String name;
  final DatabaseBackupDataClass dataClass;
  final DatabaseBackupRestoreAction restoreAction;

  bool get isSnapshotTable =>
      restoreAction == DatabaseBackupRestoreAction.restore;
}

/// Versioned table ownership contract for the database-only export format.
///
/// Keep this list exhaustive for all permanent application tables. Temporary
/// migration tables are intentionally not listed because they must never exist
/// after a successful open/upgrade.
const List<DatabaseBackupTablePolicy> kDatabaseBackupTablePolicies = [
  // Completed workout history and durable recovery.
  DatabaseBackupTablePolicy(
    name: 'sessions',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercises',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'sets',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'cardio_details',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'stretch_instances',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'stretch_instance_items',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'active_workout_draft',
    dataClass: DatabaseBackupDataClass.recovery,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'pending_workout_progression',
    dataClass: DatabaseBackupDataClass.recovery,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),

  // Measurements, profiles, plans, and user choices.
  DatabaseBackupTablePolicy(
    name: 'measurement_definitions',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'measurements',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'gym_profiles',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'profile_equipment',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'personal_info',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'flow_defaults',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'flow_default_methods',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'formula_settings',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'preset_definitions',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'preset_exercises',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'preset_sets',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'preset_cardio_details',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'preset_stretch_items',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'preset_flow_methods',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'preset_auto_settings',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'preset_exercise_auto',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'preset_set_auto',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'active_plans',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),

  // Catalog lookups remain in the snapshot because they preserve local IDs for
  // custom definitions and historical rows. The current bundled catalog is
  // synchronized immediately after import.
  DatabaseBackupTablePolicy(
    name: 'equipment',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'bodypart',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'muscles',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercise_definitions',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercise_equipment',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercise_bodypart',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercise_muscle',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'stretch_definitions',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'stretch_bodypart',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'muscle_bodypart',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'bodypart_ranking',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'muscle_ranking',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercise_muscle_percent',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercise_bodypart_percent',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'bodypart_muscle_rankings',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'muscle_volume_boundaries',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'bodypart_volume_boundaries',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercise_allocation_source',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercise_allocation_user_override',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),

  // Nutrition data and its user-facing organization.
  DatabaseBackupTablePolicy(
    name: 'nutrients',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'nutrient_aliases',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'nutrient_groups',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'nutrient_group_members',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'foods',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'food_portions',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'food_barcodes',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'food_nutrients',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'food_nutrient_values',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'recipes',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'recipe_ingredients',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'diary_entries',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'nutrition_goals',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'brands',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'sources',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'categories',
    dataClass: DatabaseBackupDataClass.mixed,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'food_usage_stats',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'favorite_foods',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'diary_entry_tags',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'diary_entry_audit',
    dataClass: DatabaseBackupDataClass.userOwned,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),

  // Legacy stat snapshots remain portable because old backups can contain
  // definitions without completed set history from which to recalculate them.
  DatabaseBackupTablePolicy(
    name: 'exercise_rep_max',
    dataClass: DatabaseBackupDataClass.derived,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercise_volume_max',
    dataClass: DatabaseBackupDataClass.derived,
    restoreAction: DatabaseBackupRestoreAction.restore,
  ),

  // Rebuilt or discarded data. These must not make an export larger or stale.
  DatabaseBackupTablePolicy(
    name: 'recipe_nutrients',
    dataClass: DatabaseBackupDataClass.derived,
    restoreAction: DatabaseBackupRestoreAction.rebuild,
  ),
  DatabaseBackupTablePolicy(
    name: 'day_totals_cache',
    dataClass: DatabaseBackupDataClass.derived,
    restoreAction: DatabaseBackupRestoreAction.rebuild,
  ),
  DatabaseBackupTablePolicy(
    name: 'workout_exercise_record_events',
    dataClass: DatabaseBackupDataClass.derived,
    restoreAction: DatabaseBackupRestoreAction.rebuild,
  ),
  DatabaseBackupTablePolicy(
    name: 'workout_set_record_events',
    dataClass: DatabaseBackupDataClass.derived,
    restoreAction: DatabaseBackupRestoreAction.rebuild,
  ),
  DatabaseBackupTablePolicy(
    name: 'food_search_fts',
    dataClass: DatabaseBackupDataClass.cache,
    restoreAction: DatabaseBackupRestoreAction.rebuild,
  ),
  DatabaseBackupTablePolicy(
    name: 'app_meta',
    dataClass: DatabaseBackupDataClass.appOwned,
    restoreAction: DatabaseBackupRestoreAction.discard,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercise_allocation_creator_default',
    dataClass: DatabaseBackupDataClass.appOwned,
    restoreAction: DatabaseBackupRestoreAction.discard,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercise_catalog_state',
    dataClass: DatabaseBackupDataClass.appOwned,
    restoreAction: DatabaseBackupRestoreAction.discard,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercise_definition_aliases',
    dataClass: DatabaseBackupDataClass.appOwned,
    restoreAction: DatabaseBackupRestoreAction.discard,
  ),
  DatabaseBackupTablePolicy(
    name: 'exercise_media',
    dataClass: DatabaseBackupDataClass.cache,
    restoreAction: DatabaseBackupRestoreAction.discard,
  ),
  DatabaseBackupTablePolicy(
    name: 'content_manifest',
    dataClass: DatabaseBackupDataClass.cache,
    restoreAction: DatabaseBackupRestoreAction.discard,
  ),
  DatabaseBackupTablePolicy(
    name: 'content_license',
    dataClass: DatabaseBackupDataClass.appOwned,
    restoreAction: DatabaseBackupRestoreAction.discard,
  ),
  DatabaseBackupTablePolicy(
    name: 'shared_media',
    dataClass: DatabaseBackupDataClass.cache,
    restoreAction: DatabaseBackupRestoreAction.discard,
  ),
];

const int kDatabaseBackupPolicyVersion = 1;

final Map<String, DatabaseBackupTablePolicy> kDatabaseBackupPolicyByName = {
  for (final policy in kDatabaseBackupTablePolicies) policy.name: policy,
};

final List<String> kDatabaseExportTableNames = kDatabaseBackupTablePolicies
    .where((policy) => policy.isSnapshotTable)
    .map((policy) => policy.name)
    .toList(growable: false);

final List<String> kDatabaseDerivedOrDiscardedTableNames =
    kDatabaseBackupTablePolicies
        .where((policy) => !policy.isSnapshotTable)
        .map((policy) => policy.name)
        .toList(growable: false);
