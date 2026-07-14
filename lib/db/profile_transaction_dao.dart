import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

/// Atomic writes for gym profiles and editable exercise-definition graphs.
class ProfileTransactionDao {
  static Future<int> saveGymProfile(
    Database db, {
    required GymProfile? existingProfile,
    required String name,
    required Set<int> equipmentIds,
  }) {
    return db.transaction((txn) async {
      final profileId = existingProfile?.id;
      final savedProfileId =
          profileId ?? await txn.insert('gym_profiles', {'name': name});
      if (profileId != null) {
        await txn.update(
          'gym_profiles',
          {'name': name},
          where: 'id = ?',
          whereArgs: [profileId],
        );
      } else {
        await _copyAppDefaultProgression(txn, savedProfileId);
      }
      await txn.delete(
        'profile_equipment',
        where: 'profile_id = ?',
        whereArgs: [savedProfileId],
      );
      for (final equipmentId in equipmentIds) {
        await txn.insert('profile_equipment', {
          'profile_id': savedProfileId,
          'equipment_id': equipmentId,
        });
      }
      return savedProfileId;
    });
  }

  /// Copies app-wide progression templates once, when a profile is created.
  /// Later edits remain scoped to their saved profile or plan snapshot.
  static Future<void> _copyAppDefaultProgression(
    Transaction txn,
    int profileId,
  ) async {
    const appScopeWhere = 'scope = ? AND profile_id IS NULL';
    const appScopeArgs = <Object?>['app'];
    final flowRows = await txn.query(
      'flow_defaults',
      columns: ['flow_json'],
      where: appScopeWhere,
      whereArgs: appScopeArgs,
      limit: 1,
    );
    final methodRows = await txn.query(
      'flow_default_methods',
      where: appScopeWhere,
      whereArgs: appScopeArgs,
    );
    if (flowRows.isEmpty && methodRows.isEmpty) return;

    await txn.insert('flow_defaults', {
      'scope': 'profile',
      'profile_id': profileId,
      'flow_json':
          flowRows.isEmpty
              ? '{}'
              : flowRows.first['flow_json'] as String? ?? '{}',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    for (final method in methodRows) {
      await txn.insert('flow_default_methods', {
        'scope': 'profile',
        'profile_id': profileId,
        'name': method['name'],
        'type': method['type'],
        'params': method['params'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> saveExerciseDefinition(
    Database db,
    ExerciseDefinitionWrite write,
  ) async {
    await db.transaction((txn) async {
      final definition = write.definition;
      await txn.update(
        'exercise_definitions',
        {
          'name': definition.name,
          'equipment_id': definition.equipmentId,
          'rating': definition.rating,
          'use_manual_bodyparts': definition.useManualBodyparts ? 1 : 0,
          'use_manual_muscles': write.useManualMuscles ? 1 : 0,
          'multiply_by_rating': definition.multiplyByRating ? 1 : 0,
          'setup_notes': definition.setupNotes,
          'execution_notes': definition.executionNotes,
          'tips_notes': definition.tipsNotes,
          'starter_load_type':
              definition.starterLoadProfile == null
                  ? null
                  : starterLoadTypeToString(
                    definition.starterLoadProfile!.type,
                  ),
          'starter_easy_value': definition.starterLoadProfile?.easyValue,
          'starter_medium_value': definition.starterLoadProfile?.mediumValue,
          'starter_hard_value': definition.starterLoadProfile?.hardValue,
          'starter_minimum_weight':
              definition.starterLoadProfile?.minimumWeight ?? 0.0,
          'starter_maximum_weight':
              definition.starterLoadProfile?.maximumWeight,
          'starter_rounding_increment':
              definition.starterLoadProfile?.roundingIncrement ?? 5.0,
          'starter_unit_mode': starterLoadUnitModeToString(
            definition.starterLoadProfile?.unitMode ??
                StarterLoadUnitMode.total,
          ),
          'starter_confidence': starterWeightConfidenceToString(
            definition.starterLoadProfile?.confidence ??
                StarterWeightConfidence.medium,
          ),
          'starter_note': definition.starterLoadProfile?.note ?? '',
        },
        where: 'id = ?',
        whereArgs: [definition.id],
      );

      await txn.delete(
        'exercise_muscle',
        where: 'exercise_id = ?',
        whereArgs: [definition.id],
      );
      await txn.delete(
        'exercise_muscle_percent',
        where: 'exercise_def_id = ?',
        whereArgs: [definition.id],
      );
      for (var index = 0; index < write.muscleIds.length; index++) {
        final muscleId = write.muscleIds[index];
        await txn.insert('exercise_muscle', {
          'exercise_id': definition.id,
          'muscle_id': muscleId,
          'rank': index + 1,
        });
        await txn.insert('exercise_muscle_percent', {
          'exercise_def_id': definition.id,
          'muscle_id': muscleId,
          'percent': write.musclePercents[muscleId] ?? 0.0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await txn.delete(
        'exercise_equipment',
        where: 'exercise_id = ?',
        whereArgs: [definition.id],
      );
      for (final equipmentId in write.equipmentIds) {
        await txn.insert('exercise_equipment', {
          'exercise_id': definition.id,
          'equipment_id': equipmentId,
        });
      }

      await txn.delete(
        'exercise_bodypart',
        where: 'exercise_id = ?',
        whereArgs: [definition.id],
      );
      await txn.delete(
        'exercise_bodypart_percent',
        where: 'exercise_def_id = ?',
        whereArgs: [definition.id],
      );
      for (final entry in write.bodyPartPercents.entries) {
        await txn.insert('exercise_bodypart', {
          'exercise_id': definition.id,
          'bodypart_id': entry.key,
        });
        await txn.insert(
          'exercise_bodypart_percent',
          {
            'exercise_def_id': definition.id,
            'bodypart_id': entry.key,
            'percent': entry.value,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await txn.delete(
        'exercise_media',
        where: 'exercise_def_id = ?',
        whereArgs: [definition.id],
      );
      final now = DateTime.now().toUtc().toIso8601String();
      for (var index = 0; index < write.mediaItems.length; index++) {
        final item = write.mediaItems[index];
        await txn.insert('exercise_media', {
          'exercise_def_id': definition.id,
          'asset_id': item.assetId,
          'media_type': item.mediaType,
          'remote_url': item.remoteUrl,
          'thumbnail_url': item.thumbnailUrl,
          'local_cache_path': item.localCachePath,
          'local_thumbnail_path': item.localThumbnailPath,
          'title': item.title,
          'sort_order': index,
          'version': item.version,
          'bytes': item.bytes,
          'width': item.width,
          'height': item.height,
          'sha256': item.sha256,
          'license_id': item.licenseId,
          'last_accessed_at': item.lastAccessedAt?.toIso8601String(),
          'downloaded_at': item.downloadedAt?.toIso8601String(),
          'created_at': now,
          'updated_at': now,
        });
      }
    });
  }
}
