import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/widgets/weight_card.dart';

class _TrackingRepository extends AppRepository {
  int findCalls = 0;
  int findOrCreateCalls = 0;
  int fetchByIdCalls = 0;
  bool shouldFind = true;

  @override
  Future<int> findExerciseDefinitionId(
    String name,
    String equipmentName,
  ) async {
    findCalls++;
    if (!shouldFind) {
      throw Exception('Definition not found');
    }
    return 42;
  }

  @override
  Future<int> findOrCreateExerciseDefinition(
    String name,
    String equipmentName,
  ) async {
    findOrCreateCalls++;
    return 42;
  }

  @override
  Future<ExerciseDefinition?> fetchDefinitionById(int defId) async {
    fetchByIdCalls++;
    return ExerciseDefinition(
      id: defId,
      name: 'Bench Press',
      useManualBodyparts: false,
      multiplyByRating: false,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _TrackingRepository repository;
  late UnitPreferenceProvider units;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = _TrackingRepository();
    units = UnitPreferenceProvider();
    await units.ready;
  });

  tearDown(() => units.dispose());

  Future<void> pumpCard(WidgetTester tester, {int? definitionId}) async {
    final exercise = WeightExercise(
      name: 'Bench Press',
      equipment: 'Barbell',
      sets: [ExerciseSet(weight: 100, reps: 5)],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppRepository>.value(value: repository),
          ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
        ],
        child: MaterialApp(
          theme: AppThemeFactory.light(AppThemeFamily.classic),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: WeightCard(
              exercise: exercise,
              definitionId: definitionId,
              previewWeightUnit: WeightUnit.pounds,
              onDetails: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets(
    'thumbnail button uses read-only lookup and never calls findOrCreateExerciseDefinition',
    (tester) async {
      await pumpCard(tester);

      expect(repository.findCalls, 1);
      expect(repository.findOrCreateCalls, 0);
      expect(repository.fetchByIdCalls, 1);
    },
  );

  testWidgets(
    'thumbnail button gracefully handles missing definition without writing to db',
    (tester) async {
      repository.shouldFind = false;
      await pumpCard(tester);

      expect(repository.findCalls, 1);
      expect(repository.findOrCreateCalls, 0);
      expect(repository.fetchByIdCalls, 0);
    },
  );

  testWidgets(
    'thumbnail button with explicit definitionId skips lookup entirely',
    (tester) async {
      await pumpCard(tester, definitionId: 99);

      expect(repository.findCalls, 0);
      expect(repository.findOrCreateCalls, 0);
      expect(repository.fetchByIdCalls, 1);
    },
  );
}
