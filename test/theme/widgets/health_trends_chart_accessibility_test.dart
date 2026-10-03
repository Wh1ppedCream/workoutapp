import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/measurement_trends_page.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/theme/tokens/app_progress_colors.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/health_trends_section.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sparkline announces value, date, count, and sparse state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final units = await _readyUnits();
    addTearDown(units.dispose);

    for (final count in [0, 1, 3]) {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_healthApp(units, entryCount: count));
      await tester.pumpAndSettle();

      final finder = find.byKey(
        const ValueKey('measurement-sparkline-1-semantics'),
      );
      final label = tester.getSemantics(finder).getSemanticsData().label;
      if (count == 0) {
        expect(label, contains('No entries yet'));
        expect(label, contains('Log entries to build a trend'));
        expect(label, contains('No entry'));
      } else {
        expect(label, contains(count == 1 ? '1 entry' : '$count entries'));
        expect(label, contains('kg'));
        expect(label, contains('2026'));
      }
      if (count == 1) {
        expect(label, contains('Log one more entry to draw a trend'));
      }

      await tester.pumpWidget(const SizedBox.shrink());
    }
    semantics.dispose();
    await tester.pump();
  });

  testWidgets(
    'Expressive identity styles Health Trends without recoloring data',
    (tester) async {
      final units = await _readyUnits();
      addTearDown(units.dispose);
      SharedPreferences.setMockInitialValues({});
      final theme = ExpressiveThemeDefinition.light();
      await tester.pumpWidget(_healthApp(units, entryCount: 3, theme: theme));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(HealthTrendsSection));
      expect(context.usesExpressivePresentation, isTrue);
      final cardColor = theme.extension<AppProgressColors>()!.healthCard;
      final shapes = theme.shapeTokens;
      final trendTile = tester.widget<Container>(
        find.byKey(AppTestKeys.measurementTrend(1)),
      );
      expect(
        (trendTile.decoration! as BoxDecoration).borderRadius,
        shapes.healthTrendCard,
      );
      expect(
        tester
            .widgetList<Material>(find.byType(Material))
            .any(
              (material) =>
                  material.color == cardColor &&
                  material.borderRadius == shapes.healthTrendCard,
            ),
        isTrue,
      );

      final createMetric = tester.widget<TextButton>(
        find.byType(TextButton).first,
      );
      final expressiveTokens = theme.extension<AppExpressiveTrainTokens>()!;
      expect(
        createMetric.style!.backgroundColor!.resolve(const {}),
        expressiveTokens.actionSecondary,
      );
      expect(
        createMetric.style!.foregroundColor!.resolve(const {}),
        expressiveTokens.actionSecondaryForeground,
      );

      final sparkline = tester.widget<LineChart>(find.byType(LineChart).first);
      expect(
        sparkline.data.lineBarsData.single.color,
        theme.dataVisualizationTokens.tertiarySeries,
      );
      expect(
        find.byKey(const ValueKey('measurement-sparkline-1-semantics')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Progress page canvas is Expressive-only', (tester) async {
    final units = await _readyUnits();
    addTearDown(units.dispose);
    final cases = <(ThemeData, Color?)>[
      (AppThemeFactory.light(AppThemeFamily.classic), null),
      (AppThemeFactory.light(AppThemeFamily.neoBrutalism), null),
      (ExpressiveThemeDefinition.light(), const Color(0xFFFFF4E9)),
    ];

    for (final (theme, expectedBackground) in cases) {
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.progress_home_v1': true,
      });
      final repository = _MeasurementRepository(entryCount: 0);
      final activeSession = ActiveSession(
        repository: repository,
        retryDelay: (_) async {},
      );
      addTearDown(activeSession.dispose);
      await activeSession.ready;
      await tester.pumpWidget(
        _progressApp(
          units: units,
          repository: repository,
          activeSession: activeSession,
          theme: theme,
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementsTrendsPage), findsOneWidget);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
        expectedBackground,
        reason: '${theme.appThemeFamilyIdentity}',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('detail chart supports semantic point navigation', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final units = await _readyUnits();
    addTearDown(units.dispose);
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.measurement_trend_detail_v1': true,
    });
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_healthApp(units, entryCount: 3));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('measurement-trend-1')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final chart = find.byKey(
      const ValueKey('measurement-trend-chart-semantics'),
    );
    var data = tester.getSemantics(chart).getSemanticsData();
    expect(data.label, contains('3 entries'));
    expect(data.label, contains('kg'));
    expect(data.label, contains('2026'));
    expect(data.value, contains('72'));
    expect(data.value, contains('kg'));
    expect(data.hasAction(SemanticsAction.increase), isFalse);
    expect(data.hasAction(SemanticsAction.decrease), isTrue);
    expect(data.increasedValue, isEmpty);
    expect(data.decreasedValue, contains('71'));

    tester.semantics.decrease(
      find.semantics.byAction(SemanticsAction.decrease),
    );
    await tester.pumpAndSettle();
    data = tester.getSemantics(chart).getSemanticsData();
    expect(data.value, contains('71'));
    expect(data.increasedValue, contains('72'));
    expect(data.decreasedValue, contains('70'));
    expect(data.hasAction(SemanticsAction.increase), isTrue);
    expect(data.hasAction(SemanticsAction.decrease), isTrue);

    tester.semantics.increase(
      find.semantics.byAction(SemanticsAction.increase),
    );
    await tester.pumpAndSettle();
    data = tester.getSemantics(chart).getSemanticsData();
    expect(data.value, contains('72'));
    expect(data.increasedValue, isEmpty);
    expect(data.hasAction(SemanticsAction.increase), isFalse);
    expect(data.hasAction(SemanticsAction.decrease), isTrue);

    tester.semantics.decrease(
      find.semantics.byAction(SemanticsAction.decrease),
    );
    await tester.pumpAndSettle();
    data = tester.getSemantics(chart).getSemanticsData();
    expect(data.value, contains('71'));

    tester.semantics.decrease(
      find.semantics.byAction(SemanticsAction.decrease),
    );
    await tester.pumpAndSettle();
    data = tester.getSemantics(chart).getSemanticsData();
    expect(data.value, contains('70'));
    expect(data.decreasedValue, isEmpty);
    expect(data.hasAction(SemanticsAction.decrease), isFalse);
    expect(data.hasAction(SemanticsAction.increase), isTrue);
    tester.semantics.increase(
      find.semantics.byAction(SemanticsAction.increase),
    );
    await tester.pumpAndSettle();
    expect(tester.getSemantics(chart).getSemanticsData().value, contains('71'));
    expect(tester.takeException(), isNull);
    semantics.dispose();
    await tester.pump();
  });

  testWidgets('one-entry detail chart exposes no point adjustment actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final units = await _readyUnits();
    addTearDown(units.dispose);
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.measurement_trend_detail_v1': true,
    });
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_healthApp(units, entryCount: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('measurement-trend-1')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final chart = find.byKey(
      const ValueKey('measurement-trend-chart-semantics'),
    );
    final data = tester.getSemantics(chart).getSemanticsData();
    expect(data.value, contains('70'));
    expect(data.value, contains('kg'));
    expect(data.hasAction(SemanticsAction.increase), isFalse);
    expect(data.hasAction(SemanticsAction.decrease), isFalse);
    expect(data.increasedValue, isEmpty);
    expect(data.decreasedValue, isEmpty);
    expect(tester.takeException(), isNull);
    semantics.dispose();
    await tester.pump();
  });

  testWidgets(
    'health trend chart and tiles adapt at narrow large text scales',
    (tester) async {
      final units = await _readyUnits();
      addTearDown(units.dispose);
      await tester.binding.setSurfaceSize(const Size(320, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final scale in [1.0, 1.15, 1.5, 2.0]) {
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.measurement_trend_detail_v1': true,
        });
        await tester.pumpWidget(
          _healthApp(units, entryCount: 3, textScale: scale),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'tile at $scale×');

        await tester.tap(find.byKey(const ValueKey('measurement-trend-1')));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('measurement-trend-chart-semantics')),
          findsOneWidget,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'detail chart at $scale×',
        );
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets('fl_chart changes snap when reduced motion is enabled', (
    tester,
  ) async {
    final units = await _readyUnits();
    addTearDown(units.dispose);
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.measurement_trend_detail_v1': true,
    });
    await tester.pumpWidget(
      _healthApp(units, entryCount: 3, disableAnimations: true),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('measurement-trend-1')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final charts = tester.widgetList<LineChart>(find.byType(LineChart));
    expect(charts, isNotEmpty);
    final chartContext = tester.element(find.byType(LineChart).first);
    expect(MediaQuery.disableAnimationsOf(chartContext), isTrue);
    expect(
      charts.map((chart) => chart.duration),
      everyElement(Duration.zero),
      reason:
          'Rendered chart durations: ${charts.map((chart) => chart.duration)}',
    );
    expect(tester.takeException(), isNull);
  });
}

Future<UnitPreferenceProvider> _readyUnits() async {
  SharedPreferences.setMockInitialValues({});
  final units = UnitPreferenceProvider();
  await units.ready;
  return units;
}

Widget _healthApp(
  UnitPreferenceProvider units, {
  required int entryCount,
  ThemeData? theme,
  double textScale = 1,
  bool disableAnimations = false,
}) {
  return MultiProvider(
    providers: [
      Provider<AppRepository>.value(
        value: _MeasurementRepository(entryCount: entryCount),
      ),
      ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
    ],
    child: MaterialApp(
      theme: theme,
      localizationsDelegates: tonosLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: child!,
      ),
      home: const Scaffold(body: HealthTrendsSection()),
    ),
  );
}

Widget _progressApp({
  required UnitPreferenceProvider units,
  required AppRepository repository,
  required ActiveSession activeSession,
  required ThemeData theme,
}) {
  return MultiProvider(
    providers: [
      Provider<AppRepository>.value(value: repository),
      ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
      ChangeNotifierProvider<ActiveSession>.value(value: activeSession),
    ],
    child: MaterialApp(
      theme: theme,
      localizationsDelegates: tonosLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MeasurementsTrendsPage(),
    ),
  );
}

class _MeasurementRepository extends AppRepository {
  _MeasurementRepository({required this.entryCount});

  final int entryCount;

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];

  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> fetchMostUsedExerciseDefinitionsRaw({
    int limit = 5,
  }) async => const [];

  @override
  Future<void> ensureDefaultMeasurementDefinitions() async {}

  @override
  Future<List<MeasurementDefinition>> fetchClassMeasurementDefinitions() async {
    return [
      MeasurementDefinition(
        id: 1,
        name: 'Body weight',
        type: MeasurementType.Custom,
      ),
    ];
  }

  @override
  Future<List<Measurement>> fetchClassMeasurementsForDefinition(
    int defId,
  ) async {
    return [
      for (var index = 0; index < entryCount; index++)
        Measurement(
          id: index + 1,
          defId: defId,
          timestamp: DateTime(2026, 1, 10 + index, 8),
          value: 70 + index.toDouble(),
          unit: 'kg',
        ),
    ];
  }
}
