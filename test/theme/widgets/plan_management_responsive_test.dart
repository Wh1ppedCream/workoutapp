import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/plan_management_page.dart';
import 'package:env_test/services/active_plan_store.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const archivedPlanName = 'Archived Review Plan 2026';

  for (final configuration in <({Size size, double textScale, String label})>[
    (size: const Size(320, 900), textScale: 1, label: '320dp baseline'),
    (size: const Size(320, 900), textScale: 1.5, label: '320dp at 1.5x'),
    (size: const Size(320, 900), textScale: 2, label: '320dp at 2x'),
    (size: const Size(390, 844), textScale: 1, label: 'normal Pixel width'),
    (size: const Size(600, 1000), textScale: 1.5, label: 'tablet portrait'),
    (
      size: const Size(800, 390),
      textScale: 1.5,
      label: 'landscape with large text',
    ),
    (size: const Size(1024, 768), textScale: 2, label: 'large tablet at 2x'),
  ]) {
    testWidgets(
      'Expressive plan labels remain readable at ${configuration.label}',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.${TutorialIds.planManagement}': true,
        });
        await tester.binding.setSurfaceSize(configuration.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repository = _ResponsivePlanRepository();
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              Provider<ActivePlanStore>.value(
                value: ActivePlanStore(repository: repository),
              ),
            ],
            child: MaterialApp(
              theme: ExpressiveThemeDefinition.light(),
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(configuration.textScale),
                ),
                child: child!,
              ),
              home: const PlanManagementPage(profileId: 1),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(0, -10000));
        await tester.pumpAndSettle();
        final planLabel = find.text(archivedPlanName);
        expect(planLabel, findsOneWidget);
        await tester.ensureVisible(planLabel);
        await tester.pumpAndSettle();
        final action = find.text(
          AppLocalizations.of(tester.element(find.byType(PlanManagementPage)))
              .planManagementActivate,
        );
        expect(tester.widget<Text>(planLabel).maxLines, isNull);
        expect(tester.widget<Text>(planLabel).overflow, isNull);
        expect(action, findsOneWidget);
        await tester.ensureVisible(action);

        final labelRect = tester.getRect(planLabel);
        final actionRect = tester.getRect(action);
        expect(labelRect.overlaps(actionRect), isFalse);
        expect(action.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}

class _ResponsivePlanRepository extends AppRepository {
  @override
  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({
    int? profileId,
  }) async => [
    {'id': 1, 'name': 'Visible Plan', 'is_automatic': 0},
    {'id': 2, 'name': 'Archived Review Plan 2026', 'is_automatic': 0},
  ];

  @override
  Future<Set<int>> loadActivePlans(int profileId) async => {1};
}
