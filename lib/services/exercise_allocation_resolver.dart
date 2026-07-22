import 'package:sqflite/sqflite.dart';

import '../db/analytics_dao.dart';
import '../db/definition_dao.dart';
import '../db/exercise_allocation_dao.dart';
import '../db/db_query_utils.dart';
import '../models/models.dart';

/// Resolves effective exercise anatomy values for every analytics consumer.
///
/// The automatic branch deliberately mirrors Tonos' existing rank and
/// body-part normalization logic. This lets the new source layers be added
/// without changing an untouched user's calculations.
class ExerciseAllocationResolver {
  static const List<double> _rankedMuscleCredits = <double>[
    1.0,
    0.85,
    0.60,
    0.35,
    0.25,
    0.15,
    0.10,
  ];

  static double defaultCreditForRank(int rank) {
    if (rank <= 0 || rank > _rankedMuscleCredits.length) return 0.0;
    return _rankedMuscleCredits[rank - 1];
  }

  static Future<ResolvedExerciseAllocation> resolve(
    Database db,
    int exerciseDefinitionId,
  ) async {
    final definition = await DefinitionDao.getExerciseDefinitionById(
      db,
      exerciseDefinitionId,
    );
    if (definition == null) {
      return ResolvedExerciseAllocation(
        exerciseDefinitionId: exerciseDefinitionId,
        muscleCredits: const <int, double>{},
        bodyPartCredits: const <int, double>{},
        derivedBodyPartCredits: const <int, double>{},
        muscleHistoryCredits: const <int, double>{},
        bodyPartHistoryCredits: const <int, double>{},
        muscleSource: ExerciseAllocationSource.automatic,
        bodyPartSource: ExerciseAllocationSource.automatic,
      );
    }

    final personalDimensions =
        await ExerciseAllocationDao.fetchPersonalDimensions(
          db,
          exerciseDefinitionId,
        );
    final legacyMuscleRows = await AnalyticsDao.getPercentsForExercise(
      db,
      exerciseDefinitionId,
    );
    final legacyBodyRows = await AnalyticsDao.getPercentsForExerciseBodyPart(
      db,
      exerciseDefinitionId,
    );
    final legacyFlags = await db.query(
      'exercise_definitions',
      columns: ['use_manual_muscles', 'use_manual_bodyparts'],
      where: 'id = ?',
      whereArgs: [exerciseDefinitionId],
      limit: 1,
    );
    final legacyFlagRow = legacyFlags.isEmpty ? null : legacyFlags.first;
    final usesLegacyManualMuscles = legacyFlagRow?['use_manual_muscles'] == 1;
    final usesLegacyManualBodyParts =
        legacyFlagRow?['use_manual_bodyparts'] == 1;

    final defaultMuscles = <int, double>{
      for (final ranked in definition.muscles)
        ranked.muscle.id: defaultCreditForRank(ranked.rank),
    };
    final creatorMuscles = await ExerciseAllocationDao.fetchCredits(
      db,
      table: 'exercise_allocation_creator_default',
      exerciseDefinitionId: exerciseDefinitionId,
      dimension: ExerciseAllocationDimension.muscle,
    );
    final personalMuscles = await ExerciseAllocationDao.fetchCredits(
      db,
      table: 'exercise_allocation_user_override',
      exerciseDefinitionId: exerciseDefinitionId,
      dimension: ExerciseAllocationDimension.muscle,
    );

    final legacyMuscles = <int, double>{
      ...defaultMuscles,
      for (final row in legacyMuscleRows) row.muscleId: row.percent,
    };
    final (muscleCredits, muscleSource) = _pickCredits(
      automatic: defaultMuscles,
      legacy: legacyMuscles,
      creator: creatorMuscles,
      personal: personalMuscles,
      usePersonal: personalDimensions.contains(
        ExerciseAllocationDimension.muscle,
      ),
      useLegacy: legacyMuscleRows.isNotEmpty,
    );

    final derivedBodyParts = await _deriveBodyPartCredits(
      db,
      definition,
      muscleCredits,
    );
    final creatorBodyParts = await ExerciseAllocationDao.fetchCredits(
      db,
      table: 'exercise_allocation_creator_default',
      exerciseDefinitionId: exerciseDefinitionId,
      dimension: ExerciseAllocationDimension.bodyPart,
    );
    final personalBodyParts = await ExerciseAllocationDao.fetchCredits(
      db,
      table: 'exercise_allocation_user_override',
      exerciseDefinitionId: exerciseDefinitionId,
      dimension: ExerciseAllocationDimension.bodyPart,
    );
    final definitionBodyPartIds =
        definition.bodyParts.map((bodyPart) => bodyPart.id).toSet();
    final legacyBodyParts = <int, double>{
      for (final row in legacyBodyRows)
        if (definitionBodyPartIds.contains(row.bodyPartId))
          row.bodyPartId: row.percent,
    };
    final (bodyPartCredits, bodyPartSource) = _pickCredits(
      automatic: derivedBodyParts,
      legacy: legacyBodyParts,
      creator: creatorBodyParts,
      personal: personalBodyParts,
      usePersonal: personalDimensions.contains(
        ExerciseAllocationDimension.bodyPart,
      ),
      useLegacy: usesLegacyManualBodyParts,
    );

    final muscleHistoryCredits =
        muscleSource == ExerciseAllocationSource.personalOverride ||
                muscleSource == ExerciseAllocationSource.creatorDefault
            ? muscleCredits
            : usesLegacyManualMuscles
            ? <int, double>{
              for (final ranked in definition.muscles) ranked.muscle.id: 1.0,
              for (final row in legacyMuscleRows) row.muscleId: row.percent,
            }
            : muscleCredits;
    final bodyPartHistoryCredits =
        bodyPartSource == ExerciseAllocationSource.personalOverride ||
                bodyPartSource == ExerciseAllocationSource.creatorDefault
            ? bodyPartCredits
            : usesLegacyManualBodyParts
            ? <int, double>{
              for (final bodyPart in definition.bodyParts) bodyPart.id: 1.0,
              for (final row in legacyBodyRows) row.bodyPartId: row.percent,
            }
            : bodyPartCredits;

    return ResolvedExerciseAllocation(
      exerciseDefinitionId: exerciseDefinitionId,
      muscleCredits: muscleCredits,
      bodyPartCredits: bodyPartCredits,
      derivedBodyPartCredits: derivedBodyParts,
      muscleHistoryCredits: muscleHistoryCredits,
      bodyPartHistoryCredits: bodyPartHistoryCredits,
      muscleSource: muscleSource,
      bodyPartSource: bodyPartSource,
    );
  }

  static (Map<int, double>, ExerciseAllocationSource) _pickCredits({
    required Map<int, double> automatic,
    required Map<int, double> legacy,
    required Map<int, double> creator,
    required Map<int, double> personal,
    required bool usePersonal,
    required bool useLegacy,
  }) {
    if (usePersonal && personal.isNotEmpty) {
      return (
        <int, double>{...automatic, ...personal},
        ExerciseAllocationSource.personalOverride,
      );
    }
    if (creator.isNotEmpty) {
      return (
        <int, double>{...automatic, ...creator},
        ExerciseAllocationSource.creatorDefault,
      );
    }
    if (useLegacy) {
      return (Map<int, double>.from(legacy), ExerciseAllocationSource.legacy);
    }
    return (
      Map<int, double>.from(automatic),
      ExerciseAllocationSource.automatic,
    );
  }

  static Future<Map<int, double>> _deriveBodyPartCredits(
    Database db,
    ExerciseDefinition definition,
    Map<int, double> muscleCredits,
  ) async {
    final muscleIds =
        definition.muscles.map((ranked) => ranked.muscle.id).toSet().toList();
    if (muscleIds.isEmpty) return <int, double>{};

    final rows = await db.rawQuery('''
      SELECT muscle_id, bodypart_id
      FROM muscle_bodypart
      WHERE muscle_id IN (${sqlitePlaceholders(muscleIds.length)})
      ''', muscleIds);
    final totals = <int, double>{};
    for (final row in rows) {
      final credit = muscleCredits[row['muscle_id'] as int] ?? 0.0;
      if (credit <= 0) continue;
      final bodyPartId = row['bodypart_id'] as int;
      totals[bodyPartId] = (totals[bodyPartId] ?? 0.0) + credit;
    }
    if (totals.isEmpty) return totals;
    final strongest = totals.values.reduce((a, b) => a > b ? a : b);
    if (strongest <= 0) return totals;
    return <int, double>{
      for (final entry in totals.entries) entry.key: entry.value / strongest,
    };
  }
}
