import 'package:env_test/db/nutrition_dao.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/preset_session.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/preset_detail_screen.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _PlanRepository extends AppRepository {
  @override
  Future<PresetDefinition?> fetchPresetById(int presetId) async =>
      PresetDefinition(
        id: presetId,
        name: 'Existing plan',
        profileId: 1,
        createdAt: DateTime(2026),
      );
  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async =>
      [];
  @override
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async =>
      null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.plan_detail_v1': true,
    }),
  );

  testWidgets('dirty plan protects the edit toggle and back navigation', (
    tester,
  ) async {
    final repository = _PlanRepository();
    final preset = PresetSession(1, repository: repository);
    final units = UnitPreferenceProvider();
    await preset.ready;
    await units.ready;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppRepository>.value(value: repository),
          ChangeNotifierProvider<PresetSession>(create: (_) => preset),
          ChangeNotifierProvider<UnitPreferenceProvider>(create: (_) => units),
        ],
        child: MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const PresetDetailScreen(startInEditingMode: true),
                  ),
                ),
                child: const Text('Open plan'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open plan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(AppTestKeys.planName), 'Unsaved rename');
    await tester.pumpAndSettle();
    expect(preset.hasChanges, isTrue);
    expect(find.byKey(AppTestKeys.planSave), findsOneWidget);
    await tester.tap(find.byKey(AppTestKeys.planEdit));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(preset.hasChanges, isTrue);
    expect(find.byKey(AppTestKeys.planSave), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      find.byType(AlertDialog),
      findsOneWidget,
      reason: 'Dirty plan must not exit silently after the edit toggle',
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AppTestKeys.planEdit));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(preset.hasChanges, isFalse);
    expect(find.text('Existing plan'), findsOneWidget);
    expect(find.byKey(AppTestKeys.planSave), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(PresetDetailScreen), findsNothing);
  });

  test(
    'nutrition DAO rejects non-finite targets without closing the valid goal',
    () async {
      sqfliteFfiInit();
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      await db.execute('''CREATE TABLE nutrition_goals (
      id INTEGER PRIMARY KEY,
      profile_id INTEGER NOT NULL,
      start_date TEXT NOT NULL,
      end_date TEXT,
      kcal_target REAL, protein_g REAL, fat_g REAL, carbs_g REAL,
      fiber_g REAL, sugar_g REAL, sat_fat_g REAL, sodium_mg REAL
    )''');
      final dao = NutritionDao(db);
      final day = DateTime(2026, 10, 22);
      await dao.setGoals(
        NutritionGoal(profileId: 1, startDate: day, kcalTarget: 2000),
      );
      for (final invalid in [double.nan, double.infinity, -1.0]) {
        await expectLater(
          dao.setGoals(
            NutritionGoal(profileId: 1, startDate: day, kcalTarget: invalid),
          ),
          throwsArgumentError,
        );
      }
      final saved = await dao.getActiveGoals(1, day);
      expect(saved!.kcalTarget, 2000);
      await db.insert('nutrition_goals', {
        'profile_id': 2,
        'start_date': '2026-10-22',
        'kcal_target': double.infinity,
        'protein_g': 0,
        'fat_g': 80.25,
      });
      final legacy = await dao.getActiveGoals(2, day);
      expect(legacy!.kcalTarget, isNull);
      expect(legacy.proteinG, 0);
      expect(legacy.fatG, 80.25);
    },
  );
}
