import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/widgets/workout_metric_chart_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'inactive reduced-motion Expressive disclosure is static and retains state',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      addTearDown(units.dispose);
      await units.ready;
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(393, 1000));

      var progressIsActive = false;
      var reduceMotion = true;

      Widget host() => _host(
        units: units,
        progressIsActive: progressIsActive,
        reduceMotion: reduceMotion,
      );

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AnimatedCrossFade, skipOffstage: false), findsNothing);

      reduceMotion = false;
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      final inactiveNormalMotion = tester.widget<AnimatedCrossFade>(
        find.byType(AnimatedCrossFade, skipOffstage: false),
      );
      expect(inactiveNormalMotion.duration, const Duration(milliseconds: 180));
      expect(tester.takeException(), isNull);

      progressIsActive = true;
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final additionalDetails = find.text('Détails supplémentaires');
      await tester.ensureVisible(additionalDetails);
      await tester.tap(additionalDetails);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('workout-report-insight-grid-one-column')),
        findsOneWidget,
      );
      final expandedCrossFade = tester.widget<AnimatedCrossFade>(
        find.byType(AnimatedCrossFade),
      );
      expect(expandedCrossFade.duration, const Duration(milliseconds: 180));
      expect(tester.takeException(), isNull);

      progressIsActive = false;
      reduceMotion = true;
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AnimatedCrossFade, skipOffstage: false), findsNothing);
      expect(
        find.byKey(
          const ValueKey('workout-report-insight-grid-one-column'),
          skipOffstage: false,
        ),
        findsOneWidget,
      );

      progressIsActive = true;
      reduceMotion = false;
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('workout-report-insight-grid-one-column')),
        findsOneWidget,
      );
      await tester.ensureVisible(additionalDetails);
      await tester.tap(additionalDetails);
      await tester.pump();

      final collapsingCrossFade = tester.widget<AnimatedCrossFade>(
        find.byType(AnimatedCrossFade),
      );
      expect(collapsingCrossFade.duration, const Duration(milliseconds: 180));
      expect(collapsingCrossFade.crossFadeState, CrossFadeState.showFirst);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _host({
  required UnitPreferenceProvider units,
  required bool progressIsActive,
  required bool reduceMotion,
}) {
  return MultiProvider(
    providers: [
      Provider<AppRepository>.value(value: _PreviewWorkoutReportRepository()),
      ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
    ],
    child: MaterialApp(
      theme: ExpressiveThemeDefinition.light(),
      locale: const Locale('fr', 'CA'),
      localizationsDelegates: tonosLocalizationDelegates,
      supportedLocales: const [Locale('en'), Locale('fr', 'CA')],
      home: Builder(
        builder: (context) {
          final media = MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(2),
            disableAnimations: reduceMotion,
          );
          return MediaQuery(
            data: media,
            child: IndexedStack(
              index: progressIsActive ? 1 : 0,
              children: [
                const SizedBox.expand(),
                TickerMode(
                  enabled: progressIsActive,
                  child: const Scaffold(
                    body: SingleChildScrollView(
                      child: WorkoutMetricChartCard(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _PreviewWorkoutReportRepository extends AppRepository {
  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async => [
    WorkoutReportSession(
      id: 1,
      date: DateTime(2026, 1, 15),
      durationSeconds: 3600,
      totalVolume: 200,
      exerciseCount: 4,
      setCount: 12,
    ),
    WorkoutReportSession(
      id: 2,
      date: DateTime(2026, 1, 16),
      durationSeconds: 2640,
      totalVolume: 1234567890,
      exerciseCount: 5,
      setCount: 15,
    ),
  ];
}
