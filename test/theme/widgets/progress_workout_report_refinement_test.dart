import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/utils/localized_formatters.dart';
import 'package:env_test/utils/weight_unit_formatter.dart';
import 'package:env_test/widgets/workout_metric_chart_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Progress range rail groups options and keeps selection and report data in sync',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      addTearDown(units.dispose);
      await units.ready;
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(420, 1400));

      final today = DateUtils.dateOnly(DateTime.now());
      final repository = _ReportRepository(today: today);
      await tester.pumpWidget(
        _progressHost(repository: repository, units: units, textScale: 1.5),
      );
      await tester.pumpAndSettle();
      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      final rangeLabels = [
        strings.workoutReportRangeOneWeekShort,
        strings.workoutReportRangeOneMonthShort,
        strings.workoutReportRangeThreeMonthsShort,
        strings.workoutReportRangeSixMonthsShort,
        strings.workoutReportRangeOneYearShort,
        strings.workoutReportRangeAll,
      ];
      Finder rangeOptions() => find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            rangeLabels.contains(widget.properties.label),
      );

      expect(rangeOptions(), findsNWidgets(6));
      final optionRects = tester
          .widgetList<Semantics>(rangeOptions())
          .map((option) => tester.getRect(find.byWidget(option)))
          .toList();
      expect(optionRects.map((rect) => rect.top.round()).toSet(), hasLength(2));
      expect(
        optionRects.map((rect) => rect.left.round()).toSet(),
        hasLength(3),
      );

      final initialSelection = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.selected == true &&
            widget.properties.label == strings.workoutReportRangeAll,
      );
      expect(initialSelection, findsOneWidget);

      await tester.ensureVisible(
        find.text(strings.workoutReportRangeOneMonthShort),
      );
      await tester.tap(find.text(strings.workoutReportRangeOneMonthShort));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.selected == true &&
              widget.properties.label ==
                  strings.workoutReportRangeOneMonthShort,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.selected == true &&
              widget.properties.label == strings.workoutReportRangeAll,
        ),
        findsNothing,
      );
      expect(
        repository.requestedStarts.last,
        DateTime(today.year, today.month - 1, today.day),
      );
      expect(
        find.text(
          strings.workoutReportChartTitle(
            strings.workoutReportWorkouts,
            strings.workoutReportRangeOneMonth,
          ),
        ),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.text(strings.workoutReportAdditionalDetails),
      );
      await tester.tap(find.text(strings.workoutReportAdditionalDetails));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label ==
                  '${strings.recordVolumeBest}, '
                      '${WeightUnitFormatter.formatCompactVolumeValue(1450, units.weightUnit, locale: const Locale('en'))}, ${units.weightUnit.shortLabel}',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 1)),
  );

  testWidgets(
    'Progress Additional Details preserve values and units across narrow and scaled layouts',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      addTearDown(units.dispose);
      await units.ready;
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final today = DateUtils.dateOnly(DateTime.now());
      final repository = _ReportRepository(today: today);
      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      final insights = <String, ({String detail, String label, String value})>{
        '${strings.workoutReportAveragePer(strings.workoutReportWeek)}, '
            '2.0, ${strings.workoutReportWorkoutsLowercase}': (
          value: '2.0',
          detail: strings.workoutReportWorkoutsLowercase,
          label: strings.workoutReportAveragePer(strings.workoutReportWeek),
        ),
        '${strings.workoutReportLongestStreak}, 1, ${strings.workoutReportDay}':
            (
              value: '1',
              detail: strings.workoutReportDay,
              label: strings.workoutReportLongestStreak,
            ),
        '${strings.workoutReportMostActive}, '
            '${LocalizedFormatters.weekdayLong(today, const Locale('en'))}': (
          value: LocalizedFormatters.weekdayLong(today, const Locale('en')),
          detail: '',
          label: strings.workoutReportMostActive,
        ),
        '${strings.recordVolumeBest}, '
            '${WeightUnitFormatter.formatCompactVolumeValue(1450, units.weightUnit, locale: const Locale('en'))}, '
            '${units.weightUnit.shortLabel}': (
          value: WeightUnitFormatter.formatCompactVolumeValue(
            1450,
            units.weightUnit,
            locale: const Locale('en'),
          ),
          detail: units.weightUnit.shortLabel,
          label: strings.recordVolumeBest,
        ),
      };

      for (final layout in [
        (width: 420.0, height: 1500.0, scale: 1.0, twoColumns: true),
        (width: 320.0, height: 1500.0, scale: 1.0, twoColumns: false),
        (width: 320.0, height: 1500.0, scale: 1.5, twoColumns: false),
        (width: 320.0, height: 1500.0, scale: 2.0, twoColumns: false),
        (width: 420.0, height: 1500.0, scale: 1.5, twoColumns: false),
        (width: 420.0, height: 1500.0, scale: 2.0, twoColumns: false),
        (width: 600.0, height: 1000.0, scale: 1.3, twoColumns: false),
        (width: 800.0, height: 390.0, scale: 1.0, twoColumns: true),
        (width: 1024.0, height: 768.0, scale: 2.0, twoColumns: false),
      ]) {
        await tester.binding.setSurfaceSize(Size(layout.width, layout.height));
        await tester.pumpWidget(
          _progressHost(
            repository: repository,
            units: units,
            textScale: layout.scale,
            key: ValueKey('progress-${layout.width}-${layout.scale}'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text(strings.workoutReportAdditionalDetails),
        );
        await tester.tap(find.text(strings.workoutReportAdditionalDetails));
        await tester.pumpAndSettle();

        final grid = find.byKey(
          ValueKey(
            layout.twoColumns
                ? 'workout-report-insight-grid-two-columns'
                : 'workout-report-insight-grid-one-column',
          ),
        );
        expect(grid, findsOneWidget, reason: 'layout=$layout');
        final tiles = find.descendant(
          of: grid,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                insights.containsKey(widget.properties.label),
          ),
        );
        expect(tiles, findsNWidgets(4), reason: 'layout=$layout');

        for (final expected in insights.keys) {
          final parts = insights[expected]!;
          final tile = find.descendant(
            of: grid,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics && widget.properties.label == expected,
            ),
          );
          expect(tile, findsOneWidget, reason: 'layout=$layout');
          final texts = find
              .descendant(of: tile, matching: find.byType(Text))
              .evaluate()
              .map((element) => element.widget as Text)
              .toList();
          expect(
            texts,
            hasLength(2),
            reason: 'insight=$expected layout=$layout',
          );
          final pairedValue = texts.singleWhere(
            (text) =>
                text.textSpan?.toPlainText() ==
                (parts.detail.isEmpty
                    ? parts.value
                    : '${parts.value} ${parts.detail}'),
          );
          final explanatoryLabel = texts.singleWhere(
            (text) => text.data == parts.label,
          );
          final pairedBounds = tester.getRect(find.byWidget(pairedValue));
          final labelBounds = tester.getRect(find.byWidget(explanatoryLabel));
          expect(
            pairedBounds.top,
            lessThan(labelBounds.top),
            reason: 'insight=$expected layout=$layout',
          );
          expect(
            pairedValue.maxLines,
            2,
            reason: 'insight=$expected layout=$layout',
          );
          expect(
            pairedValue.overflow,
            TextOverflow.ellipsis,
            reason: 'insight=$expected layout=$layout',
          );
          final valueAndDetail = pairedValue.textSpan! as TextSpan;
          final runs = valueAndDetail.children!.cast<TextSpan>();
          expect(runs, hasLength(parts.detail.isEmpty ? 1 : 2));
          expect(
            runs.first.text,
            parts.value,
            reason: 'insight=$expected layout=$layout',
          );
          if (parts.detail.isNotEmpty) {
            expect(runs.last.text, ' ${parts.detail}');
            expect(
              runs.first.style!.fontSize,
              greaterThan(runs.last.style!.fontSize!),
              reason: 'insight=$expected layout=$layout',
            );
          }
          expect(
            explanatoryLabel.maxLines,
            2,
            reason: 'insight=$expected layout=$layout',
          );
          expect(
            explanatoryLabel.overflow,
            TextOverflow.ellipsis,
            reason: 'insight=$expected layout=$layout',
          );
        }
        expect(tester.takeException(), isNull, reason: 'layout=$layout');
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Widget _progressHost({
  required _ReportRepository repository,
  required UnitPreferenceProvider units,
  required double textScale,
  Key? key,
}) {
  return MultiProvider(
    providers: [
      Provider<AppRepository>.value(value: repository),
      ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
    ],
    child: MaterialApp(
      key: key,
      theme: ExpressiveThemeDefinition.light(),
      locale: const Locale('en'),
      localizationsDelegates: tonosLocalizationDelegates,
      supportedLocales: const [Locale('en')],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const AppExpressiveDestinationTheme(
        family: AppExpressiveDestinationFamily.progress,
        child: Scaffold(
          body: SingleChildScrollView(child: WorkoutMetricChartCard()),
        ),
      ),
    ),
  );
}

class _ReportRepository extends AppRepository {
  final DateTime today;
  final requestedStarts = <DateTime?>[];

  _ReportRepository({required this.today});

  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async {
    requestedStarts.add(start);
    return [
      WorkoutReportSession(
        id: 1,
        date: DateTime(today.year, today.month, today.day, 9),
        durationSeconds: 1800,
        totalVolume: 200,
        exerciseCount: 2,
        setCount: 6,
      ),
      WorkoutReportSession(
        id: 2,
        date: DateTime(today.year, today.month, today.day, 17),
        durationSeconds: 2400,
        totalVolume: 1250,
        exerciseCount: 3,
        setCount: 9,
      ),
    ];
  }
}
