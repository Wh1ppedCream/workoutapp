import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/widgets/exercise_progress_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Exercise Progress sizes hero and selector content at 320 and 420 pixels',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'exercise_progress_tile_ids_v1': <String>['2'],
      });
      final repository = _ExerciseProgressRepository();
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Future<double> pumpAt({
        required double width,
        required double textScale,
        AppThemeFamily family = AppThemeFamily.neoBrutalism,
        Brightness brightness = Brightness.light,
      }) async {
        await tester.binding.setSurfaceSize(Size(width, 2200));
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme:
                  brightness == Brightness.dark
                      ? AppThemeFactory.dark(family)
                      : AppThemeFactory.light(family),
              locale: const Locale('fr'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder:
                  (context, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(textScale)),
                    child: child!,
                  ),
              home: const Scaffold(
                body: SingleChildScrollView(child: ExerciseProgressSection()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final strings = await AppLocalizations.delegate.load(
          const Locale('fr'),
        );
        expect(find.text(strings.exerciseProgressOneRepMax), findsOneWidget);
        expect(
          find.text(strings.exerciseProgressEstimatedOneRepMax),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        return tester
            .getSize(
              find.byKey(const ValueKey('exercise-progress-selector-strip')),
            )
            .height;
      }

      final narrowHeight = await pumpAt(width: 320, textScale: 1);
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-stacked')),
        findsOneWidget,
      );

      final wideHeight = await pumpAt(width: 420, textScale: 1);
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-side-by-side')),
        findsOneWidget,
      );
      expect(wideHeight, greaterThan(0));

      final largeTextHeight = await pumpAt(width: 420, textScale: 2);
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-stacked')),
        findsOneWidget,
      );
      expect(largeTextHeight, greaterThan(wideHeight));

      await pumpAt(width: 320, textScale: 2);
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-stacked')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      expect(narrowHeight, greaterThan(0));

      await pumpAt(
        width: 320,
        textScale: 2,
        family: AppThemeFamily.classic,
        brightness: Brightness.dark,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Exercise Progress exposes localized selector and remove semantics separately',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'exercise_progress_tile_ids_v1': <String>['1', '2', '3'],
      });
      final repository = _ExerciseProgressRepository();
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.binding.setSurfaceSize(const Size(320, 1600));
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: SingleChildScrollView(child: ExerciseProgressSection()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      final selectorStrip = find.byKey(
        const ValueKey('exercise-progress-selector-strip'),
      );
      await tester.drag(selectorStrip, const Offset(-1000, 0));
      await tester.pumpAndSettle();
      final editFinder = find.bySemanticsLabel(strings.commonEdit);
      await tester.ensureVisible(editFinder);
      await tester.tap(editFinder);
      await tester.pumpAndSettle();

      const localizedName =
          'Very long barbell pressing exercise name for layout testing';
      const selectorName =
          'Very long incline dumbbell press exercise name for layout testing';
      final heroRemoveLabel = strings.exerciseProgressRemoveExerciseLabel(
        localizedName,
      );
      final selectorRemoveLabel = strings.exerciseProgressRemoveExerciseLabel(
        selectorName,
      );
      final selectorWidgetFinder = find.byKey(
        const ValueKey('exercise-progress-selector-3'),
      );
      expect(selectorWidgetFinder, findsOneWidget);
      await tester.ensureVisible(selectorWidgetFinder);
      await tester.pumpAndSettle();
      final selectorNameTextFinder = find.text(selectorName);
      expect(selectorNameTextFinder, findsOneWidget);
      final selectorFinder = find.bySemanticsLabel(selectorName);
      final selectorRemoveFinder = find.bySemanticsLabel(selectorRemoveLabel);
      expect(selectorFinder, findsOneWidget);
      expect(selectorRemoveFinder, findsOneWidget);
      expect(selectorStrip, findsOneWidget);
      expect(
        find.byKey(const ValueKey('exercise-progress-selector-values-stacked')),
        findsWidgets,
      );

      final selectorNameText = tester.widget<Text>(selectorNameTextFinder);
      expect(selectorNameText.maxLines, isNull);
      expect(selectorNameText.overflow, isNull);

      await tester.tap(selectorFinder);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(selectorRemoveLabel), findsNothing);
      expect(find.bySemanticsLabel(selectorName), findsOneWidget);

      await tester.drag(selectorStrip, const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.bySemanticsLabel(strings.commonEdit));
      await tester.pumpAndSettle();
      final heroRemoveFinder = find.bySemanticsLabel(selectorRemoveLabel);
      expect(heroRemoveFinder, findsOneWidget);

      await tester.tap(heroRemoveFinder);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(selectorRemoveLabel), findsNothing);
      expect(find.bySemanticsLabel(selectorName), findsNothing);
      expect(find.bySemanticsLabel(heroRemoveLabel), findsWidgets);
      expect(tester.takeException(), isNull);
    },
    semanticsEnabled: true,
  );
}

class _ExerciseProgressRepository extends AppRepository {
  final _definitions = <ExerciseDefinition>[
    ExerciseDefinition(
      id: 1,
      name: 'Very long barbell pressing exercise name for layout testing',
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
    ExerciseDefinition(
      id: 2,
      name: 'Very long Romanian deadlift exercise name for layout testing',
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
    ExerciseDefinition(
      id: 3,
      name: 'Very long incline dumbbell press exercise name for layout testing',
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchMostUsedExerciseDefinitionsRaw({
    int limit = 5,
  }) async => <Map<String, dynamic>>[
    <String, dynamic>{'definition_id': 1},
  ];

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailedByIds(
    List<int> definitionIds,
  ) async => [
    for (final definition in _definitions)
      if (definitionIds.contains(definition.id)) definition,
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchExerciseOneRmTrendRows({
    required int definitionId,
    int limit = 60,
  }) async => [
    <String, dynamic>{
      'session_id': definitionId * 10 + 1,
      'session_date': '2026-01-01T00:00:00.000Z',
      'completed_at_ms': DateTime.utc(2026, 1, 1).millisecondsSinceEpoch,
      'training_day': '2026-01-01',
      'actual_one_rm': 1000000,
      'estimated_one_rm': 1000001,
    },
    <String, dynamic>{
      'session_id': definitionId * 10 + 2,
      'session_date': '2026-01-02T00:00:00.000Z',
      'completed_at_ms': DateTime.utc(2026, 1, 2).millisecondsSinceEpoch,
      'training_day': '2026-01-02',
      'actual_one_rm': 9999999,
      'estimated_one_rm': 10000000,
    },
  ];
}
