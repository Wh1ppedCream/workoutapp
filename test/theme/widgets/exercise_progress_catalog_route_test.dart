import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/db/database_helper.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/exercise_catalog_page.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/widgets/exercise_progress_section.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Expressive Progress exercise picker opens the Expressive Catalog route',
    (tester) async {
      final page = await _openProgressExercisePicker(
        tester,
        ExpressiveThemeDefinition.light(),
      );

      expect(page.expressiveCatalogPresentation, isTrue);
      expect(
        Theme.of(tester.element(find.byType(ExerciseCatalogPage)))
            .extension<AppExpressiveDestinationTokens>()
            ?.family,
        AppExpressiveDestinationFamily.catalog,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Classic Progress picker keeps its non-Expressive behavior', (
    tester,
  ) async {
    final page = await _openProgressExercisePicker(
      tester,
      ClassicThemeDefinition.light(),
    );

    expect(page.expressiveCatalogPresentation, isFalse);
    expect(
      Theme.of(tester.element(find.byType(ExerciseCatalogPage)))
          .extension<AppExpressiveDestinationTokens>(),
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<ExerciseCatalogPage> _openProgressExercisePicker(
  WidgetTester tester,
  ThemeData theme,
) async {
  SharedPreferences.setMockInitialValues({
    'guided_tutorial_completed.exercise_progress_detail_v1': true,
    'guided_tutorial_completed.exercise_catalog_v1': true,
  });

  final repository = _PickerRepository();
  final profile = SelectedProfile(repository: repository);
  final units = UnitPreferenceProvider();
  await units.ready;
  addTearDown(profile.dispose);
  addTearDown(units.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AppRepository>.value(value: repository),
        ChangeNotifierProvider<SelectedProfile>.value(value: profile),
        ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
      ],
      child: MaterialApp(
        theme: theme,
        locale: const Locale('en'),
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppExpressiveDestinationTheme(
          family: AppExpressiveDestinationFamily.progress,
          child: const Scaffold(body: ExerciseProgressSection()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final strings = AppLocalizations.of(
    tester.element(find.byType(ExerciseProgressSection)),
  );
  await tester.tap(find.text(strings.exerciseProgressTrackExercise));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();

  return tester.widget<ExerciseCatalogPage>(find.byType(ExerciseCatalogPage));
}

class _PickerRepository extends AppRepository {
  _PickerRepository() : super(db: _PickerDatabaseHelper());

  @override
  Future<List<Map<String, dynamic>>> fetchMostUsedExerciseDefinitionsRaw({
    int limit = 5,
  }) async => const [];

  @override
  Future<String?> getAppState(String key) async => '1';

  @override
  Future<void> setAppState(String key, String? value) async {}
}

class _PickerDatabaseHelper implements DatabaseHelper {
  static final _profile = [
    GymProfile(id: 1, name: 'Home', createdAt: DateTime.utc(2026)),
  ];

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => _profile;

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => const [];

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => const [];

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => const [];

  @override
  Future<List<Muscle>> fetchAllMuscles() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
