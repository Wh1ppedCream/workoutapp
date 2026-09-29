import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/utils/localized_formatters.dart';
import 'package:env_test/widgets/workout_history_calendar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode Workout History calendar preserves owned recipes', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        final units = UnitPreferenceProvider();
        await units.ready;
        addTearDown(units.dispose);
        await tester.binding.setSurfaceSize(const Size(390, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final today = DateUtils.dateOnly(DateTime.now());
        final weekStartDay = 1 + ((today.day - 1) ~/ 7) * 7;
        final companionDay =
            today.day > weekStartDay
                ? today.day - 1
                : today.day < DateTime(today.year, today.month + 1, 0).day
                ? today.day + 1
                : weekStartDay;
        final earlierDay = DateTime(today.year, today.month, companionDay);
        final sessions = <WorkoutReportSession>[
          _session(1, DateTime(today.year, today.month, today.day, 12)),
          _session(2, DateTime(today.year, today.month, today.day, 13)),
          _session(
            3,
            DateTime(earlierDay.year, earlierDay.month, earlierDay.day, 12),
          ),
          _session(4, DateTime(today.year, today.month - 1, 1, 12)),
        ];
        final repository = _CalendarRepository(sessions);
        WorkoutReportSession? tappedSession;
        var openedFullHistory = false;
        const locale = Locale('en');

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              locale: locale,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: WorkoutHistoryCalendar(
                    onSessionTap: (session) => tappedSession = session,
                    onOpenFullHistory: () => openedFullHistory = true,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final strings = AppLocalizations.of(
          tester.element(find.byType(WorkoutHistoryCalendar)),
        );
        final outlined = theme.surfaceDecorationTokens.panel.outlined;
        final surfaces = theme.surfaceTokens;
        final shapes = theme.shapeTokens;

        final monthTitle = find.text(
          LocalizedFormatters.monthYear(today, locale).toUpperCase(),
        );
        expect(monthTitle, findsOneWidget);
        final monthTitleStyle = tester.widget<Text>(monthTitle).style;
        expect(monthTitleStyle?.fontSize, greaterThan(0));
        expect(monthTitleStyle?.fontWeight, FontWeight.w900);
        expect(monthTitleStyle?.letterSpacing, 0.5);

        final sunday = today.subtract(
          Duration(days: today.weekday % DateTime.daysPerWeek),
        );
        final weekdayLabels = List.generate(
          DateTime.daysPerWeek,
          (index) => LocalizedFormatters.weekdayNarrow(
            sunday.add(Duration(days: index)),
            locale,
          ),
        );
        final weekdayTexts =
            tester
                .widgetList<Text>(find.byType(Text))
                .where(
                  (text) =>
                      weekdayLabels.contains(text.data) &&
                      text.style?.fontWeight == FontWeight.w800,
                )
                .toList();
        expect(weekdayTexts, hasLength(DateTime.daysPerWeek));
        for (final weekday in weekdayTexts) {
          expect(weekday.style?.fontSize, greaterThan(0));
          expect(weekday.style?.color, theme.colorScheme.onSurfaceVariant);
        }

        _expectModeTab(tester, label: 'M', selected: true, theme: theme);
        _expectModeTab(tester, label: '3M', selected: false, theme: theme);
        final rail = tester.widget<Container>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).color ==
                    surfaces.calendarModeSelector,
          ),
        );
        final railDecoration = rail.decoration! as BoxDecoration;
        expect(
          railDecoration.borderRadius,
          outlined ? shapes.control : shapes.pill,
        );
        expect(railDecoration.border != null, outlined);
        if (outlined) {
          final railBorder = railDecoration.border! as Border;
          expect(
            railBorder.top.color,
            tonosOutlineForSurface(
              tester.element(find.text('M').first),
              surfaces.calendarModeSelector,
            ),
          );
          expect(railBorder.top.width, shapes.outlineWidth);
        }
        final selectedDay = _dayButton(today, locale);
        expect(selectedDay, findsOneWidget);
        final selectedDayFill = _dayFill(tester, selectedDay);
        expect(
          selectedDayFill.color,
          outlined ? surfaces.settingsHero : theme.colorScheme.primary,
        );
        expect(selectedDayFill.shape, BoxShape.circle);
        expect(selectedDayFill.border != null, outlined);
        if (outlined) {
          final selectedBorder = selectedDayFill.border! as Border;
          expect(
            selectedBorder.top.color,
            tonosOutlineForSurface(
              tester.element(selectedDay),
              surfaces.settingsHero,
            ),
          );
          expect(selectedBorder.top.width, shapes.outlineWidth);
        }
        final selectedBadge = _badgeIn(tester, selectedDay);
        expect(selectedBadge, findsOneWidget);
        final selectedBadgeContainer = tester.widget<Container>(selectedBadge);
        expect(
          (selectedBadgeContainer.decoration! as BoxDecoration).color,
          theme.colorScheme.onPrimary,
        );
        expect(
          (selectedBadgeContainer.decoration! as BoxDecoration).shape,
          BoxShape.circle,
        );
        final badgeText = tester.widget<Text>(
          find.descendant(of: selectedBadge, matching: find.byType(Text)),
        );
        expect(badgeText.style?.color, theme.colorScheme.primary);
        expect(badgeText.style?.fontSize, 9);
        expect(badgeText.style?.height, 1);
        expect(badgeText.style?.fontWeight, FontWeight.w900);
        final selectedDayText = tester.widget<Text>(
          _buttonLabelText(selectedDay),
        );
        expect(selectedDayText.style?.fontSize, greaterThan(0));
        expect(selectedDayText.style?.fontWeight, FontWeight.w900);
        expect(
          selectedDayText.style?.color,
          outlined
              ? tonosForegroundForSurface(
                tester.element(selectedDay),
                surfaces.settingsHero,
              )
              : theme.colorScheme.onPrimary,
        );

        final sessionCount = find.text(strings.logbookWorkoutCount(2));
        expect(sessionCount, findsOneWidget);
        final summaryPanel = find.ancestor(
          of: sessionCount,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).borderRadius ==
                    shapes.historySelectedPeriod,
          ),
        );
        expect(summaryPanel, findsOneWidget);
        final summaryDecoration =
            tester.widget<Container>(summaryPanel).decoration! as BoxDecoration;
        expect(
          summaryDecoration.color,
          outlined ? surfaces.catalogSelection : surfaces.historySelectedPeriod,
        );
        final summaryTexts =
            tester
                .widgetList<Text>(
                  find.descendant(
                    of: summaryPanel,
                    matching: find.byType(Text),
                  ),
                )
                .toList();
        expect(summaryTexts.first.style?.fontWeight, FontWeight.w900);
        expect(summaryTexts.first.style?.fontSize, greaterThan(0));
        expect(
          summaryTexts.first.style?.color,
          outlined
              ? tonosForegroundForSurface(
                tester.element(summaryPanel),
                surfaces.catalogSelection,
              )
              : theme.colorScheme.onSurface,
        );
        expect(
          summaryTexts[1].style?.color,
          outlined
              ? tonosSecondaryForegroundForSurface(
                tester.element(summaryPanel),
                surfaces.catalogSelection,
              )
              : theme.colorScheme.onSurfaceVariant,
        );
        expect(summaryTexts[1].style?.fontSize, greaterThan(0));

        final workoutMetricLabel = find.text(strings.logbookWorkouts);
        final workoutMetric = find.ancestor(
          of: workoutMetricLabel,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is TonosSurface &&
                widget.variant ==
                    (outlined
                        ? TonosSurfaceVariant.panel
                        : TonosSurfaceVariant.compactCard) &&
                widget.color == (outlined ? surfaces.workoutMetricRange : null),
          ),
        );
        expect(workoutMetric, findsOneWidget);
        final metricCard = tester.widget<TonosSurface>(workoutMetric);
        expect(
          metricCard.variant,
          outlined
              ? TonosSurfaceVariant.panel
              : TonosSurfaceVariant.compactCard,
        );
        expect(metricCard.color, outlined ? surfaces.workoutMetricRange : null);
        final metricTexts = tester.widgetList<Text>(
          find.descendant(of: workoutMetric, matching: find.byType(Text)),
        );
        expect(metricTexts.first.style?.fontSize, 13);
        expect(
          metricTexts.first.style?.color,
          outlined
              ? tonosForegroundForSurface(
                tester.element(workoutMetric),
                surfaces.workoutMetricRange,
              )
              : theme.semanticColors.strongContent,
        );
        expect(metricTexts.last.style?.fontSize, 9);
        expect(
          metricTexts.last.style?.color,
          outlined
              ? tonosSecondaryForegroundForSurface(
                tester.element(workoutMetric),
                surfaces.workoutMetricRange,
              )
              : theme.semanticColors.mutedContent,
        );

        final sessionTile = find.byKey(AppTestKeys.historySession(1));
        expect(sessionTile, findsOneWidget);
        final sessionTitle = tester.widget<Text>(
          find.descendant(of: sessionTile, matching: find.byType(Text)).first,
        );
        expect(sessionTitle.style?.fontWeight, FontWeight.w800);
        expect(sessionTitle.style?.color, isNull);
        await tester.ensureVisible(sessionTile);
        await tester.tap(sessionTile);
        expect(tappedSession?.id, 1);

        final fullHistoryButton = findTonosTooltip(
          strings.logbookViewAllSessions,
        );
        await tester.ensureVisible(fullHistoryButton);
        await tester.tap(fullHistoryButton);
        expect(openedFullHistory, isTrue);

        var emptyDayOfMonth = 1;
        while (emptyDayOfMonth == today.day ||
            emptyDayOfMonth == earlierDay.day) {
          emptyDayOfMonth++;
        }
        final emptyDayDate = DateTime(today.year, today.month, emptyDayOfMonth);
        final emptyDay = _dayButton(emptyDayDate, locale);
        expect(emptyDay, findsOneWidget);
        final emptyDecoration = _dayFill(tester, emptyDay);
        expect(emptyDecoration.color, surfaces.calendarDayEmpty);
        expect(emptyDecoration.shape, BoxShape.circle);

        final offMonthDate = _adjacentMonthDate(today);
        if (offMonthDate != null) {
          final offMonthButton = _dayButton(offMonthDate, locale);
          expect(offMonthButton, findsOneWidget);
          final offMonthText = tester.widget<Text>(
            find.descendant(of: offMonthButton, matching: find.byType(Text)),
          );
          expect(
            offMonthText.style?.color,
            outlined
                ? tonosForegroundForSurface(
                  tester.element(offMonthButton),
                  surfaces.calendarDayEmpty,
                )
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
          );
        }

        final activeDay = _dayButton(earlierDay, locale);
        final activeDecoration = _dayFill(tester, activeDay);
        Color activityFill(double intensity) =>
            outlined
                ? Color.lerp(
                  surfaces.calendarDayEmpty,
                  surfaces.catalogSelection,
                  0.45 + intensity * 0.55,
                )!
                : theme.colorScheme.primary.withValues(
                  alpha: 0.22 + intensity * 0.48,
                );
        final expectedActivityFill = activityFill(0.5);
        expect(activeDecoration.color, expectedActivityFill);

        await tester.tap(emptyDay);
        await tester.pumpAndSettle();
        final todayAfterSelection = _dayFill(tester, _dayButton(today, locale));
        expect(todayAfterSelection.color, activityFill(1));
        if (!outlined) {
          expect(todayAfterSelection.border, isNotNull);
          expect((todayAfterSelection.border! as Border).top.width, 1.4);
        }

        for (final label in ['3M', 'Y', '4Y']) {
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
          _expectModeTab(tester, label: label, selected: true, theme: theme);
          expect(
            find.text(strings.logbookWorkoutCount(label == '4Y' ? 4 : 3)),
            findsOneWidget,
          );
          if (label == '3M') {
            final dividerColor = theme.colorScheme.outlineVariant.withValues(
              alpha: 0.22,
            );
            final dividers = find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.constraints?.maxWidth == 1 &&
                  widget.constraints?.maxHeight == 132 &&
                  widget.color == dividerColor,
            );
            expect(dividers, findsNWidgets(2));

            final selectedWeekLabel = strings.logbookMonthWeek(
              LocalizedFormatters.month(today, locale),
              ((weekStartDay - 1) ~/ 7) + 1,
            );
            final selectedWeek = _semanticButton(selectedWeekLabel);
            expect(selectedWeek, findsOneWidget);
            final selectedWeekDecoration = _dayFill(tester, selectedWeek);
            expect(selectedWeekDecoration.shape, BoxShape.circle);
            expect(
              selectedWeekDecoration.color,
              outlined ? surfaces.settingsHero : theme.colorScheme.primary,
            );
            expect(selectedWeekDecoration.border != null, outlined);
            if (outlined) {
              final selectedWeekBorder =
                  selectedWeekDecoration.border! as Border;
              expect(
                selectedWeekBorder.top.color,
                tonosOutlineForSurface(
                  tester.element(selectedWeek),
                  surfaces.settingsHero,
                ),
              );
              expect(selectedWeekBorder.top.width, shapes.outlineWidth);
            }
            final selectedWeekText = tester.widget<Text>(
              _buttonLabelText(selectedWeek),
            );
            expect(selectedWeekText.style?.fontSize, greaterThan(0));
            expect(selectedWeekText.style?.fontWeight, FontWeight.w900);
            final selectedWeekBadge = _badgeIn(tester, selectedWeek, size: 15);
            expect(selectedWeekBadge, findsOneWidget);
            final selectedWeekBadgeText = tester.widget<Text>(
              find.descendant(
                of: selectedWeekBadge,
                matching: find.byType(Text),
              ),
            );
            expect(selectedWeekBadgeText.style?.fontSize, 8);
            expect(selectedWeekBadgeText.style?.height, 1);
            expect(selectedWeekBadgeText.style?.fontWeight, FontWeight.w900);

            final monthPanelTitle = find.text(
              LocalizedFormatters.month(today, locale),
            );
            expect(monthPanelTitle, findsOneWidget);
            final monthPanelTitleStyle =
                tester.widget<Text>(monthPanelTitle).style;
            expect(monthPanelTitleStyle?.fontSize, greaterThan(0));
            expect(monthPanelTitleStyle?.fontWeight, FontWeight.w900);

            final previousMonth = DateTime(today.year, today.month - 1);
            final activeWeek = _semanticButton(
              strings.logbookMonthWeek(
                LocalizedFormatters.month(previousMonth, locale),
                1,
              ),
            );
            expect(activeWeek, findsOneWidget);
            expect(_dayFill(tester, activeWeek).color, activityFill(1 / 3));
            final activeWeekText = tester.widget<Text>(
              find.descendant(of: activeWeek, matching: find.byType(Text)),
            );
            expect(
              activeWeekText.style?.color,
              outlined
                  ? tonosForegroundForSurface(
                    tester.element(activeWeek),
                    activityFill(1 / 3),
                  )
                  : theme.colorScheme.onSurface,
            );
          }
          if (label == 'Y') {
            final selectedMonthLabel = LocalizedFormatters.monthYear(
              DateTime(today.year, today.month),
              locale,
            );
            final selectedMonth = _semanticButton(selectedMonthLabel);
            expect(selectedMonth, findsOneWidget);
            final monthButtonText = tester.widget<Text>(
              _buttonLabelText(selectedMonth),
            );
            expect(monthButtonText.style?.fontSize, greaterThan(0));
            expect(monthButtonText.style?.fontWeight, FontWeight.w900);
          }
          if (label == '4Y') {
            final selectedYearLabel = LocalizedFormatters.year(
              today.year,
              locale,
            );
            final selectedYear = _semanticButton(selectedYearLabel);
            expect(selectedYear, findsOneWidget);
            final yearButtonText = tester.widget<Text>(
              _buttonLabelText(selectedYear),
            );
            expect(yearButtonText.style?.fontSize, greaterThan(0));
            expect(yearButtonText.style?.fontWeight, FontWeight.w900);
          }
        }
        expect(tester.takeException(), isNull);

        repository.failSessions = true;
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              locale: locale,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: WorkoutHistoryCalendar(key: const ValueKey('failed')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final errorLabel = find.text(strings.logbookCalendarLoadFailed);
        expect(errorLabel, findsOneWidget);
        final errorText = tester.widget<Text>(errorLabel);
        if (outlined) {
          expect(
            errorText.style?.color,
            tonosForegroundForSurface(
              tester.element(errorLabel),
              surfaces.exerciseProgressSelector,
            ),
          );
        } else {
          expect(errorText.style, isNull);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}

Finder _dayButton(DateTime day, Locale locale) {
  final label = LocalizedFormatters.longDate(day, locale);
  return _semanticButton(label);
}

Finder _semanticButton(String label) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Semantics &&
        widget.properties.button == true &&
        widget.properties.label == label,
    description: 'calendar day button $label',
  );
}

Finder _buttonLabelText(Finder button) => find.descendant(
  of: button,
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.style?.fontWeight == FontWeight.w900 &&
        (widget.style?.fontSize ?? 0) > 9,
  ),
);

DateTime? _adjacentMonthDate(DateTime day) {
  final firstOfMonth = DateTime(day.year, day.month);
  final precedingDays = firstOfMonth.weekday % DateTime.daysPerWeek;
  if (precedingDays > 0) {
    return firstOfMonth.subtract(const Duration(days: 1));
  }

  final lastOfMonth = DateTime(day.year, day.month + 1, 0);
  final trailingDays = DateTime.daysPerWeek - 1 - (lastOfMonth.weekday % 7);
  if (trailingDays > 0) {
    return lastOfMonth.add(const Duration(days: 1));
  }

  return null;
}

BoxDecoration _dayFill(WidgetTester tester, Finder day) {
  final fill = find.descendant(
    of: day,
    matching: find.byType(AnimatedContainer),
  );
  return tester.widget<AnimatedContainer>(fill).decoration! as BoxDecoration;
}

Finder _badgeIn(WidgetTester tester, Finder day, {double size = 17}) =>
    find.descendant(
      of: day,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.maxWidth == size &&
            widget.constraints?.maxHeight == size,
      ),
    );

void _expectModeTab(
  WidgetTester tester, {
  required String label,
  required bool selected,
  required ThemeData theme,
}) {
  final tabText = find.text(label).first;
  final tabContainer = find.ancestor(
    of: tabText,
    matching: find.byType(AnimatedContainer),
  );
  expect(tabContainer, findsOneWidget);
  final decoration =
      tester.widget<AnimatedContainer>(tabContainer).decoration!
          as BoxDecoration;
  final outlined = theme.surfaceDecorationTokens.panel.outlined;
  expect(
    decoration.color,
    selected
        ? outlined
            ? theme.surfaceTokens.settingsHero
            : theme.colorScheme.primary
        : Colors.transparent,
  );
  expect(
    decoration.borderRadius,
    outlined ? theme.shapeTokens.control : theme.shapeTokens.pill,
  );
  if (outlined && selected) {
    final border = decoration.border! as Border;
    expect(
      border.top.color,
      tonosOutlineForSurface(
        tester.element(tabText),
        theme.surfaceTokens.settingsHero,
      ),
    );
    expect(border.top.width, theme.shapeTokens.outlineWidth);
  }
  final expectedForeground =
      outlined
          ? tonosForegroundForSurface(
            tester.element(tabText),
            selected
                ? theme.surfaceTokens.settingsHero
                : theme.surfaceTokens.calendarModeSelector,
          )
          : selected
          ? theme.colorScheme.onPrimary
          : theme.colorScheme.onSurface;
  expect(tester.widget<Text>(tabText).style?.color, expectedForeground);
  expect(tester.widget<Text>(tabText).style?.fontSize, greaterThan(0));
  expect(tester.widget<Text>(tabText).style?.fontWeight, FontWeight.w900);
}

WorkoutReportSession _session(int id, DateTime date) => WorkoutReportSession(
  id: id,
  date: date,
  durationSeconds: 1800,
  totalVolume: 120 + id.toDouble(),
  exerciseCount: 2,
  setCount: 6,
);

class _CalendarRepository extends AppRepository {
  _CalendarRepository(this.sessions);

  final List<WorkoutReportSession> sessions;
  bool failSessions = false;

  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async {
    if (failSessions) throw StateError('Failed to load workout sessions.');
    return sessions;
  }

  @override
  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async => const <BodyPart, double>{};
}
