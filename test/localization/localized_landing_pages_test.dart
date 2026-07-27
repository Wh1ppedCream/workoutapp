import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/catalog_page.dart';
import 'package:env_test/screens/profile/settings/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.catalog_home_v1': true,
      'guided_tutorial_completed.profile_home_v1': true,
    });
  });

  testWidgets('Profile landing page uses Canadian French copy', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_localizedApp(home: const ProfilePage()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Compte'), findsOneWidget);
    expect(find.text('Entraînement'), findsOneWidget);
    expect(find.text('Données'), findsOneWidget);
  });

  testWidgets('Catalog landing page uses Canadian French copy', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _CatalogRepository();
    final activeSession = ActiveSession(repository: repository);
    addTearDown(activeSession.dispose);
    await activeSession.ready;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppRepository>.value(value: repository),
          ChangeNotifierProvider<ActiveSession>.value(value: activeSession),
        ],
        child: _localizedApp(home: const CatalogPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Catalogue d\u2019exercices'), findsOneWidget);
    expect(find.text('Anatomie ciblée'), findsOneWidget);
    expect(find.text('Parties du corps'), findsOneWidget);
    expect(find.text('Muscles'), findsOneWidget);
  });
}

Widget _localizedApp({required Widget home}) {
  return MaterialApp(
    locale: const Locale('fr', 'CA'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

class _CatalogRepository extends AppRepository {
  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> fetchMostUsedExerciseDefinitionsRaw({
    int limit = 5,
  }) async => const [];

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailedByIds(
    List<int> definitionIds,
  ) async => const [];

  @override
  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async => const {};

  @override
  Future<Map<int, double>> fetchSetsPerMuscle({
    required DateTime start,
    required DateTime end,
  }) async => const {};

  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => const [];
}
