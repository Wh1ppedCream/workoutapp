import 'package:sqflite/sqflite.dart';

import '../models/nutrition_models.dart';
import 'nutrition_dao.dart';

/// Owns persistence orchestration for the existing food editor payload.
abstract final class FoodCustomizationDao {
  static Future<void> update(Database db, Map payload) async {
    final nutrition = NutritionDao(db);
    // 1) ID is required for updates
    final foodId = (payload['food_id'] as num?)?.toInt();
    if (foodId == null) {
      throw ArgumentError('food_id is required for updates');
    }

    // 2) Update basic shell (name/brand)
    final name = (payload['name'] as String?)?.trim();
    final brand = (payload['brand'] as String?)?.trim();
    await nutrition.updateFoodBasics(foodId, name: name, brand: brand);

    // 2b) Optional: density (g/ml)
    final densRaw = payload['density_g_per_ml'];
    if (densRaw != null) {
      final dens = (densRaw is num)
          ? densRaw.toDouble()
          : double.tryParse('$densRaw');
      if (dens != null) {
        await db.update(
          'foods',
          {
            'density_g_per_ml': dens > 0 ? dens : null,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [foodId],
        );
      }
    }

    // 2c) Optional: barcode(s)
    final bc = payload['barcodes'] ?? payload['barcode'];
    if (bc != null) {
      final list = (bc is List) ? bc : [bc];
      for (final v in list) {
        final s = '$v'.trim();
        if (s.isNotEmpty) {
          await nutrition.addBarcode(foodId, s);
        }
      }
    }

    // 3) Replace per-100g values using your flexible label mapper
    await nutrition.savePer100gFromLabelPayload(
      foodId,
      Map<String, dynamic>.from(payload),
    );

    // 4) Replace portions
    final List portionsJson = (payload['portions'] as List?) ?? const [];
    if (portionsJson.isNotEmpty) {
      final portions = <FoodPortion>[];
      for (final p in portionsJson) {
        final m = Map<String, dynamic>.from(p as Map);
        final rawDefault = m['is_default'];
        final isDefault = rawDefault is bool
            ? rawDefault
            : (rawDefault is num ? rawDefault.toInt() == 1 : false);

        portions.add(
          FoodPortion(
            id: null, // replacePortions wipes & re-inserts
            foodId: foodId,
            measureName: m['measure_name'] as String,
            gramWeight: (m['gram_weight'] as num?)?.toDouble(),
            mlVolume: (m['ml_volume'] as num?)?.toDouble(),
            isDefault: isDefault,
            listKind: m['list_kind'] as String?, // 'basis' | 'usual'
            sortOrder: m['sort_order'] as int?,
            amount: (m['amount'] as num?)?.toDouble(),
            unit: m['unit'] as String?,
            label: m['label'] as String?,
          ),
        );
      }
      await nutrition.replacePortions(foodId, portions);
    }
  }
}
