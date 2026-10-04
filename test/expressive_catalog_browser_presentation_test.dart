import 'package:env_test/db/database_helper.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/exercise_catalog_page.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Expressive browser opts into tonal dense search and rows', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.exercise_catalog_v1': true,
    });
    final repository = _CatalogBrowserRepository();
    final profile = SelectedProfile(repository: repository)
      ..currentProfile = _CatalogBrowserDatabase.profiles.first;
    addTearDown(profile.dispose);

    await tester.pumpWidget(
      _catalogApp(repository, profile, expressive: true, scale: 1),
    );
    await _settleCatalog(tester);

    final theme = ExpressiveThemeDefinition.light();
    final firstName = find.text('Goblet Squat');
    expect(firstName, findsOneWidget);
    final rowMaterial = find
        .ancestor(of: firstName, matching: find.byType(Material))
        .first;
    final row = tester.widget<Material>(rowMaterial);
    expect(row.color, theme.colorScheme.surfaceContainerLow);
    expect(
      (row.shape as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(14),
    );

    final filterTooltip = AppLocalizations.of(
      tester.element(find.byType(ExerciseCatalogPage)),
    ).catalogFilters;
    expect(find.byTooltip(filterTooltip), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);

    final search = find.byType(TextField).first;
    await tester.enterText(search, 'bench');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Goblet Squat'), findsNothing);

    await tester.tap(find.byTooltip(filterTooltip));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(
      find.text(
        AppLocalizations.of(tester.element(find.byType(AlertDialog)))
            .catalogSelectedFilters,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final scale in <double>[1, 1.15, 1.5, 2]) {
    testWidgets('Expressive browser stays within 320 dp at text scale $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.exercise_catalog_v1': true,
      });
      final repository = _CatalogBrowserRepository();
      final profile = SelectedProfile(repository: repository)
        ..currentProfile = _CatalogBrowserDatabase.profiles.first;
      addTearDown(profile.dispose);

      await tester.pumpWidget(
        _catalogApp(repository, profile, expressive: true, scale: scale),
      );
      await _settleCatalog(tester);
      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.byTooltip(
          AppLocalizations.of(tester.element(find.byType(ExerciseCatalogPage)))
              .catalogFilters,
        ),
        findsOneWidget,
      );
      expect(find.text('Goblet Squat'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('picker callers remain on the existing presentation by default', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.exercise_catalog_v1': true,
    });
    final repository = _CatalogBrowserRepository();
    final profile = SelectedProfile(repository: repository)
      ..currentProfile = _CatalogBrowserDatabase.profiles.first;
    addTearDown(profile.dispose);

    await tester.pumpWidget(
      _catalogApp(repository, profile, expressive: false, scale: 1),
    );
    await _settleCatalog(tester);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(
      find.byTooltip(
        AppLocalizations.of(tester.element(find.byType(ExerciseCatalogPage)))
            .catalogFilters,
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}

Widget _catalogApp(
  AppRepository repository,
  SelectedProfile profile, {
  required bool expressive,
  required double scale,
}) {
  final theme = ExpressiveThemeDefinition.light();
  return MultiProvider(
    providers: [
      Provider<AppRepository>.value(value: repository),
      ChangeNotifierProvider<SelectedProfile>.value(value: profile),
    ],
    child: MaterialApp(
      theme: theme,
      themeAnimationDuration: Duration.zero,
      localizationsDelegates: tonosLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: ExerciseCatalogPage(expressiveCatalogPresentation: expressive),
    ),
  );
}

Future<void> _settleCatalog(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
}

class _CatalogBrowserRepository extends AppRepository {
  _CatalogBrowserRepository() : super(db: _CatalogBrowserDatabase());

  @override
  Future<String?> getAppState(String key) async => '1';

  @override
  Future<void> setAppState(String key, String? value) async {}

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => [
    ExerciseDefinition(
      id: 1,
      name: 'Goblet Squat',
      equipmentList: [_CatalogBrowserDatabase.equipment.first],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
    ExerciseDefinition(
      id: 2,
      name: 'Bench Press',
      equipmentList: [_CatalogBrowserDatabase.equipment.last],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
  ];
}

class _CatalogBrowserDatabase implements DatabaseHelper {
  static final profiles = [
    GymProfile(id: 1, name: 'Home Gym', createdAt: DateTime.utc(2026)),
  ];
  static final equipment = [Equipment(1, 'Dumbbell'), Equipment(2, 'Barbell')];

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => profiles;

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => [
    {'id': 1, 'name': 'Dumbbell', 'catalog_id': null},
    {'id': 2, 'name': 'Barbell', 'catalog_id': null},
  ];

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => [
    BodyPart(1, 'Legs'),
    BodyPart(2, 'Chest'),
  ];

  @override
  Future<List<Muscle>> fetchAllMuscles() async => [
    Muscle(id: 1, name: 'Quadriceps'),
    Muscle(id: 2, name: 'Pectorals'),
  ];

  @override
  Future<List<Equipment>> fetchAllEquipment() async => equipment;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
