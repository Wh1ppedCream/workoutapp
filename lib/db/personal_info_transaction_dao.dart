import 'package:sqflite/sqflite.dart';

import '../models/models.dart';
import '../utils/weight_unit_formatter.dart';
import 'personal_info_dao.dart';

/// Saves profile details and a changed body-weight reading as one operation.
class PersonalInfoTransactionDao {
  const PersonalInfoTransactionDao._();

  static Future<void> save(
    Database db, {
    required PersonalInfo info,
    double? bodyWeightValue,
    WeightUnit bodyWeightUnit = WeightUnit.pounds,
    String? measurementNote,
    DateTime? measuredAt,
  }) {
    return db.transaction((txn) async {
      await PersonalInfoDao(txn).upsert(info);

      if (bodyWeightValue == null || bodyWeightValue <= 0) return;

      await txn.insert('measurement_definitions', {
        'name': MeasurementType.BodyWeight.name,
        'type': MeasurementType.BodyWeight.name,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      final definitions = await txn.query(
        'measurement_definitions',
        columns: ['id'],
        where: 'type = ?',
        whereArgs: [MeasurementType.BodyWeight.name],
        orderBy: 'id',
        limit: 1,
      );
      if (definitions.isEmpty) {
        throw StateError('Body-weight measurement definition is unavailable.');
      }

      final definitionId = definitions.first['id'] as int;
      final latest = await txn.query(
        'measurements',
        columns: ['value', 'unit'],
        where: 'def_id = ?',
        whereArgs: [definitionId],
        orderBy: 'measured_at_ms DESC, id DESC',
        limit: 1,
      );
      final bodyWeightLbs = WeightUnitFormatter.toPounds(
        bodyWeightValue,
        bodyWeightUnit,
      );
      if (latest.isNotEmpty) {
        final latestValue = (latest.first['value'] as num?)?.toDouble();
        final latestUnit = _weightUnitFromStoredValue(
          latest.first['unit'] as String?,
        );
        if (latestValue != null && latestUnit != null) {
          final latestLbs = WeightUnitFormatter.toPounds(
            latestValue,
            latestUnit,
          );
          final latestDisplay = WeightUnitFormatter.formatInputWeight(
            latestLbs,
            bodyWeightUnit,
          );
          final enteredDisplay = WeightUnitFormatter.formatInputWeight(
            bodyWeightLbs,
            bodyWeightUnit,
          );
          if (latestDisplay == enteredDisplay) return;
        }
      }

      final recordedAt = measuredAt ?? DateTime.now();
      await txn.insert('measurements', {
        'def_id': definitionId,
        'timestamp': TemporalSemantics.legacyUtcIso8601(recordedAt),
        'measured_at_ms': TemporalSemantics.utcEpochMilliseconds(recordedAt),
        'measured_on':
            LocalCalendarDay.fromDateTime(recordedAt.toLocal()).storageKey,
        'value': bodyWeightValue,
        'unit': bodyWeightUnit.shortLabel,
        'note': measurementNote,
      });
    });
  }

  static WeightUnit? _weightUnitFromStoredValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'lb':
      case 'lbs':
      case 'pound':
      case 'pounds':
        return WeightUnit.pounds;
      case 'kg':
      case 'kgs':
      case 'kilogram':
      case 'kilograms':
        return WeightUnit.kilograms;
      default:
        return null;
    }
  }
}
