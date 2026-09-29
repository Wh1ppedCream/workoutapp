import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/content_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/dashboard_section_palette.dart';
import 'package:env_test/widgets/dashboard_sections.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.dark
              ? AppThemeFactory.dark(family)
              : AppThemeFactory.light(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode dashboard section widgets resolve existing recipes', (
        tester,
      ) async {
        final repository = _DashboardSectionsRepository();
        final session = ActiveSession(
          repository: repository,
          retryDelay: (_) async {},
        );
        addTearDown(session.dispose);
        await session.ready;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ActiveSession>.value(value: session),
              Provider<AppRepository>.value(value: repository),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      DashboardHero(isEditing: false, onEdit: () {}),
                      DashboardQuickActions(onChanged: () {}),
                      DashboardRecentWorkoutsCard(
                        refreshToken: 0,
                        onChanged: () {},
                      ),
                      const DashboardExerciseCatalogCard(refreshToken: 0),
                      const DashboardTargetAnatomyCard(refreshToken: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final surfaces = theme.surfaceTokens;
        final shapes = theme.shapeTokens;
        final scheme = theme.colorScheme;
        final hero = tester.widget<Container>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.padding ==
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        );
        final heroDecoration = hero.decoration! as BoxDecoration;
        final heroGradient = heroDecoration.gradient! as LinearGradient;
        expect(heroDecoration.borderRadius, shapes.dashboardHero);
        expect(heroGradient.colors, [
          dashboardHeroAccent.withValues(alpha: 0.25),
          surfaces.dashboardHero,
        ]);
        expect(
          heroDecoration.border!.top.color,
          dashboardHeroAccent.withValues(alpha: 0.44),
        );
        expect(heroDecoration.border!.top.width, 1);

        final heroIcon = tester.widget<Container>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.constraints ==
                    const BoxConstraints.tightFor(width: 42, height: 42),
          ),
        );
        final heroIconDecoration = heroIcon.decoration! as BoxDecoration;
        expect(heroIconDecoration.shape, BoxShape.circle);
        expect(
          heroIconDecoration.color,
          dashboardHeroAccent.withValues(alpha: 0.18),
        );

        final quickActions = tester.widget<Container>(
          find.byWidgetPredicate((widget) {
            if (widget is! Container ||
                widget.padding != const EdgeInsets.all(16)) {
              return false;
            }
            final decoration = widget.decoration;
            return decoration is BoxDecoration &&
                decoration.color == surfaces.dashboardSection;
          }),
        );
        final quickActionsDecoration =
            quickActions.decoration! as BoxDecoration;
        expect(quickActionsDecoration.borderRadius, shapes.dashboardSection);
        expect(quickActionsDecoration.border!.top.color, scheme.outlineVariant);

        final expectedActionFills = <Color>{
          dashboardMeasurementActionAccent.withValues(alpha: 0.13),
          dashboardTrainingActionAccent.withValues(alpha: 0.13),
        };
        final actionMaterials = tester.widgetList<Material>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Material &&
                expectedActionFills.contains(widget.color),
          ),
        );
        expect(actionMaterials, hasLength(expectedActionFills.length));
        expect(
          actionMaterials.map((material) => material.borderRadius),
          everyElement(shapes.dashboardAction),
        );

        final recentWorkouts = tester.widget<Container>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.padding == const EdgeInsets.fromLTRB(16, 14, 16, 8),
          ),
        );
        final recentDecoration = recentWorkouts.decoration! as BoxDecoration;
        expect(recentDecoration.color, surfaces.dashboardSection);
        expect(recentDecoration.borderRadius, shapes.dashboardSection);
        expect(recentDecoration.border!.top.color, scheme.outlineVariant);

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is InkWell && widget.borderRadius == shapes.dashboardRow,
          ),
          findsAtLeastNWidgets(3),
        );

        final workoutIconFinder = find.byWidgetPredicate((widget) {
          if (widget is! Container ||
              widget.constraints !=
                  const BoxConstraints.tightFor(width: 38, height: 38)) {
            return false;
          }
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.color == scheme.primary.withValues(alpha: 0.14);
        });
        final workoutIcon = tester.widget<Container>(workoutIconFinder);
        final workoutIconDecoration = workoutIcon.decoration! as BoxDecoration;
        final rowInk = find.ancestor(
          of: workoutIconFinder,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is InkWell && widget.borderRadius == shapes.dashboardRow,
          ),
        );
        final rowMaterial = find.ancestor(
          of: rowInk.first,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Material && widget.color == Colors.transparent,
          ),
        );
        expect(rowInk, findsOneWidget);
        expect(rowMaterial, findsOneWidget);
        expect(tester.widget<Material>(rowMaterial).color, Colors.transparent);
        expect(
          workoutIconDecoration.borderRadius,
          const BorderRadius.all(Radius.circular(12)),
        );

        final exerciseUsage = tester.widget<Container>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.margin == const EdgeInsets.only(top: 8) &&
                widget.padding ==
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          ),
        );
        final usageDecoration = exerciseUsage.decoration! as BoxDecoration;
        expect(usageDecoration.color, surfaces.dashboardUsage);
        expect(usageDecoration.borderRadius, shapes.dashboardUsage);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}

class _DashboardSectionsRepository extends AppRepository {
  static final _definition = ExerciseDefinition(
    id: 43,
    name: 'Barbell Squat',
    useManualBodyparts: false,
    multiplyByRating: false,
  );

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];

  @override
  Future<List<WorkoutSession>> fetchWorkoutSessions() async => [
    WorkoutSession(id: 5, date: DateTime.now(), duration: 120),
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchMostUsedExerciseDefinitionsRaw({
    int limit = 5,
  }) async => [
    {'definition_id': _definition.id, 'use_count': 3},
  ];

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailedByIds(
    List<int> definitionIds,
  ) async => definitionIds.contains(_definition.id) ? [_definition] : [];

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

  @override
  Future<void> ensureExerciseMediaManifestReady() async {}

  @override
  Future<ExerciseMediaItem?> fetchPrimaryExerciseMedia(int defId) async => null;

  @override
  Stream<ContentMediaCacheChange> get mediaCacheChanges => const Stream.empty();
}
