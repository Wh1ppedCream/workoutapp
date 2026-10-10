import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/utils/localized_formatters.dart';
import 'package:env_test/widgets/workout_history_calendar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_support.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
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

        // Fix the reference date so the theme matrix is independent of the clock.
        final today = DateTime(2026, 10, 28);
        final earlierDay = today.subtract(const Duration(days: 1));
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
                    referenceDate: today,
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
        final weekdayTexts = tester
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
        final selectedModeSemantics = find.ancestor(
          of: find.text('M').first,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && widget.properties.selected == true,
          ),
        );
        expect(
          selectedModeSemantics,
          theme.usesExpressivePresentation ? findsOneWidget : findsNothing,
        );
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
        expect(
          tester.widget<Semantics>(selectedDay).properties.selected,
          theme.usesExpressivePresentation ? isTrue : isNull,
        );
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
        final summaryTexts = tester
            .widgetList<Text>(
              find.descendant(of: summaryPanel, matching: find.byType(Text)),
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
        final laterSessionTile = find.byKey(AppTestKeys.historySession(2));
        expect(laterSessionTile, findsOneWidget);
        expect(
          tester.getTopLeft(laterSessionTile).dy,
          lessThan(tester.getTopLeft(sessionTile).dy),
          reason: 'Sessions in the selected period should be newest first.',
        );
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
        Color activityFill(double intensity) => outlined
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
              4,
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
            final monthPanelTitleStyle = tester
                .widget<Text>(monthPanelTitle)
                .style;
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
            final selectedMonthDecoration = _dayFill(tester, selectedMonth);
            expect(selectedMonthDecoration.shape, BoxShape.circle);
            expect(
              selectedMonthDecoration.color,
              outlined ? surfaces.settingsHero : theme.colorScheme.primary,
            );
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
            final selectedYearDecoration = _dayFill(tester, selectedYear);
            expect(selectedYearDecoration.shape, BoxShape.circle);
            expect(
              selectedYearDecoration.color,
              outlined ? surfaces.settingsHero : theme.colorScheme.primary,
            );
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
                body: WorkoutHistoryCalendar(
                  key: const ValueKey('failed'),
                  referenceDate: today,
                ),
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

  testWidgets(
    'Expressive calendar exposes selected semantics and newest-first sessions',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final today = DateTime(2026, 10, 28);
      const locale = Locale('en');
      final repository = _CalendarRepository([
        _session(1, DateTime(today.year, today.month, today.day, 12)),
        _session(2, DateTime(today.year, today.month, today.day, 13)),
      ]);
      final theme = ExpressiveThemeDefinition.light();
      var openedFullHistory = false;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: theme,
            locale: locale,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: WorkoutHistoryCalendar(
                  referenceDate: today,
                  onOpenFullHistory: () => openedFullHistory = true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      Finder modeSelection(String label, bool selected) => find.ancestor(
        of: find.text(label).first,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.selected == selected,
        ),
      );

      expect(modeSelection('M', true), findsOneWidget);
      expect(modeSelection('3M', false), findsOneWidget);
      final selectedDay = _dayButton(today, locale);
      expect(selectedDay, findsOneWidget);
      expect(tester.widget<Semantics>(selectedDay).properties.selected, isTrue);
      final expressiveTokens = theme.extension<AppExpressiveTrainTokens>()!;
      final focusForeground = expressiveTokens.focusForeground;
      final focusSurface = expressiveTokens.focusSurface;
      final destinationTokens = theme
          .extension<AppExpressiveDestinationTokens>();
      final countBadgeBackground =
          destinationTokens?.surfacePrimary ?? focusSurface;
      final countBadgeForeground =
          destinationTokens?.onSurfacePrimary ?? focusForeground;
      final modeRail = find.ancestor(
        of: find.text('M').first,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).borderRadius ==
                  ExpressiveTrainShapes.selector,
        ),
      );
      expect(modeRail, findsOneWidget);
      final railDecoration =
          tester.widget<Container>(modeRail).decoration! as BoxDecoration;
      expect(
        railDecoration.color,
        Color.lerp(
          expressiveTokens.selectorTrack,
          const Color(0xFFDCE5EF),
          0.58,
        ),
      );
      final selectedModeContainer = find.ancestor(
        of: find.text('M').first,
        matching: find.byType(AnimatedContainer),
      );
      final selectedModeBorder =
          (tester.widget<AnimatedContainer>(selectedModeContainer).decoration!
                      as BoxDecoration)
                  .border!
              as Border;
      expect(
        selectedModeBorder.top.color,
        focusForeground.withValues(alpha: 0.5),
      );
      expect(_dayFill(tester, selectedDay).shape, BoxShape.circle);
      final selectedDayBorder = _dayFill(tester, selectedDay).border! as Border;
      expect(selectedDayBorder.top.width, 2);
      expect(
        selectedDayBorder.top.color,
        destinationTokens?.onSurfaceSelected ?? focusForeground,
      );
      final selectedDayNumber = LocalizedFormatters.number(
        today.day,
        locale,
        maximumFractionDigits: 0,
      );
      final selectedDayText = tester.widget<Text>(
        find.descendant(
          of: selectedDay,
          matching: find.text(selectedDayNumber),
        ),
      );
      expect(selectedDayText.style?.color, focusForeground);

      final strings = AppLocalizations.of(
        tester.element(find.byType(WorkoutHistoryCalendar)),
      );
      final initialBadge = _badgeIn(tester, selectedDay, size: 15);
      expect(initialBadge, findsOneWidget);
      _expectBadgeAtTopRightPerimeter(
        tester,
        initialBadge,
        selectedDay,
        size: 15,
        overlap: 2,
        background: countBadgeBackground,
        foreground: countBadgeForeground,
      );
      _expectExpressiveSummaryOrder(
        tester,
        countLabel: strings.logbookWorkoutCount(2),
        sessionId: 2,
        strings: strings,
      );

      final alternateDate = DateTime(today.year, today.month, today.day - 2);
      final alternateDay = _dayButton(alternateDate, locale);
      expect(alternateDay, findsOneWidget);
      await tester.tap(alternateDay);
      await tester.pumpAndSettle();
      final todayDecoration = _dayFill(tester, selectedDay);
      final todayBorder = todayDecoration.border! as Border;
      expect(todayBorder.top.width, 1);
      expect(
        todayBorder.top.color,
        (destinationTokens?.outlineAccent ??
                expressiveTokens.actionSecondaryForeground)
            .withValues(alpha: 0.45),
      );
      expect(
        tester.widget<Semantics>(selectedDay).properties.selected,
        isFalse,
      );
      final alternateDecoration = _dayFill(tester, alternateDay);
      final alternateBorder = alternateDecoration.border! as Border;
      expect(alternateBorder.top.width, 2);

      await tester.tap(selectedDay);
      await tester.pumpAndSettle();
      final todaySelectedBorder =
          _dayFill(tester, selectedDay).border! as Border;
      expect(todaySelectedBorder.top.width, 2);
      expect(
        todaySelectedBorder.top.color,
        destinationTokens?.onSurfaceSelected ?? focusForeground,
      );

      final newerSession = find.byKey(AppTestKeys.historySession(2));
      final olderSession = find.byKey(AppTestKeys.historySession(1));
      expect(newerSession, findsOneWidget);
      expect(olderSession, findsOneWidget);
      expect(
        tester.getTopLeft(newerSession).dy,
        lessThan(tester.getTopLeft(olderSession).dy),
        reason: 'The selected period should list its newest session first.',
      );
      for (final rowText in tester.widgetList<Text>(
        find.descendant(of: newerSession, matching: find.byType(Text)),
      )) {
        expect(rowText.style?.color, focusForeground);
      }
      final fullHistoryAction = find.byTooltip(strings.logbookViewAllSessions);
      final fullHistoryButton = find.ancestor(
        of: fullHistoryAction,
        matching: find.byType(IconButton),
      );
      expect(fullHistoryAction, findsOneWidget);
      expect(tester.widget<IconButton>(fullHistoryButton).tooltip, isNotEmpty);
      expect(tester.widget<IconButton>(fullHistoryButton).onPressed, isNotNull);
      expect(tester.widget<IconButton>(fullHistoryButton).iconSize, 20);
      final fullHistoryButtonSize = tester.getSize(fullHistoryButton);
      expect(fullHistoryButtonSize.width, greaterThanOrEqualTo(48));
      expect(fullHistoryButtonSize.height, greaterThanOrEqualTo(48));
      expect(
        tester.widget<IconButton>(fullHistoryButton).color,
        focusForeground,
      );

      await tester.tap(find.text('3M'));
      await tester.pumpAndSettle();
      expect(modeSelection('M', false), findsOneWidget);
      expect(modeSelection('3M', true), findsOneWidget);
      final selectedWeek = _semanticButton(
        strings.logbookMonthWeek(LocalizedFormatters.month(today, locale), 4),
      );
      _expectExpressivePeriodButton(
        tester,
        selectedWeek,
        selectedColor: focusSurface,
        foregroundColor: focusForeground,
      );
      final weekBadge = _badgeIn(tester, selectedWeek, size: 13);
      expect(weekBadge, findsOneWidget);
      _expectBadgeAtTopRightPerimeter(
        tester,
        weekBadge,
        selectedWeek,
        size: 13,
        overlap: 1,
        background: countBadgeBackground,
        foreground: countBadgeForeground,
      );
      _expectExpressiveSummaryOrder(
        tester,
        countLabel: strings.logbookWorkoutCount(2),
        sessionId: 2,
        strings: strings,
      );

      await tester.tap(find.text('Y'));
      await tester.pumpAndSettle();
      final selectedMonth = _semanticButton(
        LocalizedFormatters.monthYear(today, locale),
      );
      _expectExpressivePeriodButton(
        tester,
        selectedMonth,
        selectedColor: focusSurface,
        foregroundColor: focusForeground,
      );
      final monthBadge = _badgeIn(tester, selectedMonth, size: 15);
      expect(monthBadge, findsOneWidget);
      _expectBadgeAtTopRightPerimeter(
        tester,
        monthBadge,
        selectedMonth,
        size: 15,
        overlap: 2,
        background: countBadgeBackground,
        foreground: countBadgeForeground,
      );
      _expectExpressiveSummaryOrder(
        tester,
        countLabel: strings.logbookWorkoutCount(2),
        sessionId: 2,
        strings: strings,
      );

      await tester.tap(find.text('4Y'));
      await tester.pumpAndSettle();
      final selectedYear = _semanticButton(
        LocalizedFormatters.year(today.year, locale),
      );
      _expectExpressivePeriodButton(
        tester,
        selectedYear,
        selectedColor: focusSurface,
        foregroundColor: focusForeground,
      );
      final yearBadge = _badgeIn(tester, selectedYear, size: 13);
      expect(yearBadge, findsOneWidget);
      _expectBadgeAtTopRightPerimeter(
        tester,
        yearBadge,
        selectedYear,
        size: 13,
        overlap: 1,
        background: countBadgeBackground,
        foreground: countBadgeForeground,
      );
      _expectExpressiveSummaryOrder(
        tester,
        countLabel: strings.logbookWorkoutCount(2),
        sessionId: 2,
        strings: strings,
      );

      await tester.ensureVisible(fullHistoryButton);
      await tester.pumpAndSettle();
      await tester.tap(fullHistoryButton);
      expect(openedFullHistory, isTrue);
      expect(tester.takeException(), isNull);
    },
    semanticsEnabled: true,
  );

  testWidgets(
    'Expressive selected period scrolls 15 same-day sessions at 320dp',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(320, 1800));

      final today = DateTime(2026, 10, 28);
      const locale = Locale('en');
      final repository = _CalendarRepository(
        List<WorkoutReportSession>.generate(
          15,
          (index) => _session(
            index + 1,
            DateTime(today.year, today.month, today.day, 6 + index),
          ),
        ),
      );

      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        for (final scale in [1.0, 1.15, 1.5, 2.0]) {
          var openedFullHistory = false;
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
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                    disableAnimations: true,
                  ),
                  child: child!,
                ),
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: WorkoutHistoryCalendar(
                      key: ValueKey('dense-$brightness-$scale'),
                      referenceDate: today,
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
          final expressiveTokens = theme.extension<AppExpressiveTrainTokens>()!;
          final modeRail = find.ancestor(
            of: find.text('M').first,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration! as BoxDecoration).borderRadius ==
                      ExpressiveTrainShapes.selector,
            ),
          );
          expect(modeRail, findsOneWidget);
          final expectedRailColor = brightness == Brightness.light
              ? Color.lerp(
                  expressiveTokens.selectorTrack,
                  const Color(0xFFDCE5EF),
                  0.58,
                )
              : Color.lerp(
                  expressiveTokens.selectorTrack,
                  theme.surfaceTokens.card,
                  0.12,
                );
          expect(
            (tester.widget<Container>(modeRail).decoration! as BoxDecoration)
                .color,
            expectedRailColor,
          );
          final selectedModeContainer = find.ancestor(
            of: find.text('M').first,
            matching: find.byType(AnimatedContainer),
          );
          final selectedModeBorder =
              (tester
                              .widget<AnimatedContainer>(selectedModeContainer)
                              .decoration!
                          as BoxDecoration)
                      .border!
                  as Border;
          expect(
            selectedModeBorder.top.color,
            expressiveTokens.focusForeground.withValues(
              alpha: brightness == Brightness.dark ? 0.42 : 0.5,
            ),
          );
          for (var id = 1; id <= 15; id++) {
            expect(find.byKey(AppTestKeys.historySession(id)), findsOneWidget);
          }

          final selectedDay = _dayButton(today, locale);
          final dayBadge = _badgeIn(tester, selectedDay, size: 15);
          expect(dayBadge, findsOneWidget);
          final destinationTokens = theme
              .extension<AppExpressiveDestinationTokens>();
          _expectBadgeAtTopRightPerimeter(
            tester,
            dayBadge,
            selectedDay,
            size: 15,
            overlap: 2,
            background:
                destinationTokens?.surfacePrimary ??
                expressiveTokens.focusSurface,
            foreground:
                destinationTokens?.onSurfacePrimary ??
                expressiveTokens.focusForeground,
          );

          final newestRow = find.byKey(AppTestKeys.historySession(15));
          final oldestRow = find.byKey(AppTestKeys.historySession(1));
          expect(
            tester.getTopLeft(newestRow).dy,
            lessThan(tester.getTopLeft(oldestRow).dy),
            reason: 'The selected period should remain newest-first.',
          );

          await tester.ensureVisible(find.text('4Y'));
          await tester.tap(find.text('4Y'));
          await tester.pumpAndSettle();
          final selectedYear = _semanticButton(
            LocalizedFormatters.year(today.year, locale),
          );
          expect(selectedYear, findsOneWidget);
          expect(
            tester.widget<Semantics>(selectedYear).properties.selected,
            isTrue,
          );
          await tester.ensureVisible(oldestRow);
          await tester.pumpAndSettle();
          expect(oldestRow.hitTestable(), findsOneWidget);

          final fullHistoryAction = find.byTooltip(
            strings.logbookViewAllSessions,
          );
          expect(fullHistoryAction, findsOneWidget);
          final fullHistoryButton = find.ancestor(
            of: fullHistoryAction,
            matching: find.byType(IconButton),
          );
          expect(
            tester.widget<IconButton>(fullHistoryButton).onPressed,
            isNotNull,
          );
          await tester.ensureVisible(fullHistoryButton);
          await tester.pumpAndSettle();
          await tester.tap(fullHistoryButton);
          expect(openedFullHistory, isTrue);
          expect(
            tester.takeException(),
            isNull,
            reason: '${brightness.name}, text scale $scale',
          );
        }
      }
    },
    semanticsEnabled: true,
  );

  testWidgets(
    'Expressive 4Y selector compacts responsively into rounded rows',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final today = DateTime(2026, 10, 28);
      const locale = Locale('en');
      final repository = _CalendarRepository([
        _session(1, DateTime(today.year, today.month, today.day, 12)),
        _session(2, DateTime(today.year, today.month, today.day, 13)),
      ]);

      for (final layout in <({double width, double scale, int columns})>[
        (width: 390, scale: 1, columns: 4),
        (width: 320, scale: 1, columns: 2),
        (width: 390, scale: 2, columns: 2),
      ]) {
        await tester.binding.setSurfaceSize(Size(layout.width, 1100));
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: ExpressiveThemeDefinition.light(),
              locale: locale,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(layout.scale),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: WorkoutHistoryCalendar(
                    key: ValueKey('four-year-${layout.width}-${layout.scale}'),
                    referenceDate: today,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('4Y'));
        await tester.pumpAndSettle();

        final years = List.generate(
          4,
          (index) => today.year - 3 + index,
        ).map((year) => LocalizedFormatters.year(year, locale)).toList();
        final yearButtons = years.map(_semanticButton).toList();
        for (var index = 0; index < yearButtons.length; index++) {
          final button = yearButtons[index];
          expect(button, findsOneWidget);
          final decoration = _dayFill(tester, button);
          expect(decoration.shape, BoxShape.rectangle);
          expect(decoration.borderRadius, ExpressiveTrainShapes.compactControl);
          expect(
            tester
                .renderObject<RenderParagraph>(
                  find.descendant(
                    of: button,
                    matching: find.text(years[index]),
                  ),
                )
                .didExceedMaxLines,
            isFalse,
          );
        }
        final firstRowY = tester.getTopLeft(yearButtons.first).dy;
        expect(tester.getTopLeft(yearButtons[1]).dy, closeTo(firstRowY, 1));
        if (layout.columns == 4) {
          expect(tester.getTopLeft(yearButtons[2]).dy, closeTo(firstRowY, 1));
          expect(tester.getTopLeft(yearButtons[3]).dy, closeTo(firstRowY, 1));
        } else {
          expect(tester.getTopLeft(yearButtons[2]).dy, greaterThan(firstRowY));
          expect(
            tester.getTopLeft(yearButtons[3]).dy,
            closeTo(tester.getTopLeft(yearButtons[2]).dy, 1),
          );
        }
        expect(tester.takeException(), isNull);
      }
    },
    semanticsEnabled: true,
  );

  testWidgets('Expressive empty selected period remains clear at 320dp', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final units = UnitPreferenceProvider();
    await units.ready;
    addTearDown(units.dispose);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 1800));

    final today = DateTime(2026, 10, 28);
    const locale = Locale('en');
    final repository = _CalendarRepository(const <WorkoutReportSession>[]);

    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      for (final scale in [1.0, 1.15, 1.5, 2.0]) {
        var openedFullHistory = false;
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
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: WorkoutHistoryCalendar(
                    key: ValueKey('empty-$brightness-$scale'),
                    referenceDate: today,
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
        final noWorkouts = find.text(strings.logbookNoWorkouts);
        expect(noWorkouts, findsOneWidget);
        final summaryCard = find.ancestor(
          of: noWorkouts,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).borderRadius ==
                    ExpressiveTrainShapes.focusHero,
          ),
        );
        expect(summaryCard, findsOneWidget);
        expect(
          find.text(LocalizedFormatters.weekdayShortDate(today, locale)),
          findsOneWidget,
        );

        expect(find.text('0'), findsOneWidget);
        expect(find.text(strings.logbookWorkouts), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget.key is ValueKey<String> &&
                (widget.key! as ValueKey<String>).value.startsWith(
                  'history-session-',
                ),
          ),
          findsNothing,
        );

        final fullHistoryAction = find.descendant(
          of: summaryCard,
          matching: find.byTooltip(strings.logbookViewAllSessions),
        );
        expect(fullHistoryAction, findsOneWidget);
        final fullHistoryButton = find.ancestor(
          of: fullHistoryAction,
          matching: find.byType(IconButton),
        );
        expect(
          tester.widget<IconButton>(fullHistoryButton).onPressed,
          isNotNull,
        );
        expect(
          tester.getTopLeft(find.text(strings.logbookWorkouts)).dy,
          greaterThan(tester.getBottomLeft(fullHistoryButton).dy),
          reason: 'The empty period heading should precede aggregate metrics.',
        );
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget.key is ValueKey<String> &&
                (widget.key! as ValueKey<String>).value.startsWith(
                  'history-session-',
                ),
          ),
          findsNothing,
        );
        await tester.ensureVisible(fullHistoryButton);
        await tester.pumpAndSettle();
        await tester.tap(fullHistoryButton);
        expect(openedFullHistory, isTrue);
        expect(
          tester.takeException(),
          isNull,
          reason: '${brightness.name}, text scale $scale',
        );
      }
    }
  }, semanticsEnabled: true);

  testWidgets(
    'Expressive calendar remains usable across width and text-scale classes',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const viewports = <({double width, double height})>[
        (width: 320, height: 1800),
        (width: 360, height: 1800),
        (width: 390, height: 1800),
        (width: 412, height: 1800),
        (width: 430, height: 1800),
        (width: 600, height: 1800),
        (width: 800, height: 1800),
        (width: 1024, height: 1800),
        (width: 800, height: 390),
      ];

      final today = DateTime(2026, 10, 28);
      const locale = Locale('en');
      final repository = _CalendarRepository([
        _session(1, DateTime(today.year, today.month, today.day, 12)),
      ]);

      for (final viewport in viewports) {
        await tester.binding.setSurfaceSize(
          Size(viewport.width, viewport.height),
        );
        for (final brightness in Brightness.values) {
          final theme = brightness == Brightness.light
              ? ExpressiveThemeDefinition.light()
              : ExpressiveThemeDefinition.dark();
          for (final scale in [1.0, 1.3, 1.5, 2.0]) {
            var openedFullHistory = false;
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
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(scale),
                      disableAnimations: true,
                    ),
                    child: child!,
                  ),
                  home: Scaffold(
                    body: SingleChildScrollView(
                      child: WorkoutHistoryCalendar(
                        key: ValueKey(
                          'responsive-${viewport.width}-${viewport.height}-$brightness-$scale',
                        ),
                        referenceDate: today,
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
            expect(
              find.text(
                LocalizedFormatters.monthYear(today, locale).toUpperCase(),
              ),
              findsOneWidget,
            );
            expect(_dayButton(today, locale), findsOneWidget);
            expect(find.byKey(AppTestKeys.historySession(1)), findsOneWidget);
            final fullHistoryAction = find.byTooltip(
              strings.logbookViewAllSessions,
            );
            expect(fullHistoryAction, findsOneWidget);
            final fullHistoryButton = find.ancestor(
              of: fullHistoryAction,
              matching: find.byType(IconButton),
            );
            expect(fullHistoryButton, findsOneWidget);
            expect(
              tester.widget<IconButton>(fullHistoryButton).onPressed,
              isNotNull,
            );

            await tester.ensureVisible(find.text('3M'));
            await tester.tap(find.text('3M'));
            await tester.pumpAndSettle();
            expect(
              _semanticButton(
                strings.logbookMonthWeek(
                  LocalizedFormatters.month(today, locale),
                  4,
                ),
              ),
              findsOneWidget,
            );
            await tester.ensureVisible(find.text('Y'));
            await tester.tap(find.text('Y'));
            await tester.pumpAndSettle();
            expect(
              _semanticButton(LocalizedFormatters.monthYear(today, locale)),
              findsOneWidget,
            );
            await tester.ensureVisible(find.text('4Y'));
            await tester.tap(find.text('4Y'));
            await tester.pumpAndSettle();
            final yearLabel = LocalizedFormatters.year(today.year, locale);
            expect(_semanticButton(yearLabel), findsOneWidget);
            if (scale >= 1.5) {
              final sessionRow = find.byKey(AppTestKeys.historySession(1));
              final summaryFinder = find
                  .descendant(of: sessionRow, matching: find.byType(Text))
                  .last;
              final summary = tester.widget<Text>(summaryFinder);
              expect(summary.data, contains('2 exercises'));
              expect(summary.data, contains('6 sets'));
              final summaryParagraph = tester.renderObject<RenderParagraph>(
                summaryFinder,
              );
              expect(summaryParagraph.didExceedMaxLines, isFalse);
              expect(
                tester.getSize(summaryFinder).height,
                greaterThan(0),
                reason:
                    'The full session summary should remain present at '
                    '${viewport.width}dp, text scale $scale.',
              );
            }
            if (scale >= 1.5) {
              final yearGrid = tester.widget<GridView>(find.byType(GridView));
              expect(
                (yearGrid.gridDelegate
                        as SliverGridDelegateWithFixedCrossAxisCount)
                    .crossAxisCount,
                2,
              );
              final yearText = find.descendant(
                of: _semanticButton(yearLabel),
                matching: find.text(yearLabel),
              );
              expect(yearText, findsOneWidget);
              expect(
                tester
                    .renderObject<RenderParagraph>(yearText)
                    .didExceedMaxLines,
                isFalse,
              );
            }
            expect(
              tester.takeException(),
              isNull,
              reason:
                  '${viewport.width}×${viewport.height}dp, '
                  '${brightness.name}, text scale $scale',
            );
            expect(openedFullHistory, isFalse);
          }
        }
      }
    },
    semanticsEnabled: true,
  );

  testWidgets('days 22 through month-end select the fourth period', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final units = UnitPreferenceProvider();
    await units.ready;
    addTearDown(units.dispose);
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final theme = AppThemeFactory.light(AppThemeFamily.classic);
    final repository = _CalendarRepository(const <WorkoutReportSession>[]);
    const locale = Locale('en');
    final dates = <({int month, int day, int expectedWeek})>[
      (month: 10, day: 21, expectedWeek: 3),
      (month: 10, day: 22, expectedWeek: 4),
      (month: 10, day: 28, expectedWeek: 4),
      (month: 9, day: 29, expectedWeek: 4),
      (month: 9, day: 30, expectedWeek: 4),
      (month: 10, day: 31, expectedWeek: 4),
    ];

    for (final dateCase in dates) {
      final today = DateTime(2026, dateCase.month, dateCase.day);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: theme,
            locale: locale,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: WorkoutHistoryCalendar(
                key: ValueKey<DateTime>(today),
                referenceDate: today,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('3M'));
      await tester.pumpAndSettle();

      final strings = AppLocalizations.of(
        tester.element(find.byType(WorkoutHistoryCalendar)),
      );
      final selectedPeriod = _semanticButton(
        strings.logbookMonthWeek(
          LocalizedFormatters.month(today, locale),
          dateCase.expectedWeek,
        ),
      );
      expect(selectedPeriod, findsOneWidget);
      expect(find.text(strings.logbookWeekShort(5)), findsNothing);
      expect(
        _dayFill(tester, selectedPeriod).color,
        theme.colorScheme.primary,
        reason: 'The selected month period should match the fixed date.',
      );
    }
  });
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

void _expectExpressivePeriodButton(
  WidgetTester tester,
  Finder button, {
  required Color selectedColor,
  required Color foregroundColor,
}) {
  expect(button, findsOneWidget);
  expect(tester.widget<Semantics>(button).properties.selected, isTrue);

  final decoration = _dayFill(tester, button);
  expect(decoration.shape, BoxShape.rectangle);
  expect(decoration.borderRadius, ExpressiveTrainShapes.compactControl);
  expect(decoration.color, selectedColor);

  final label = tester.widget<Text>(_buttonLabelText(button));
  expect(label.style?.color, foregroundColor);
}

void _expectExpressiveSummaryOrder(
  WidgetTester tester, {
  required String countLabel,
  required int sessionId,
  required AppLocalizations strings,
}) {
  final session = find.byKey(AppTestKeys.historySession(sessionId));
  expect(session, findsOneWidget);
  final summary = find.ancestor(
    of: session,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).borderRadius ==
              ExpressiveTrainShapes.focusHero,
    ),
  );
  expect(summary, findsOneWidget);
  final heading = find
      .descendant(of: summary, matching: find.byType(Text))
      .first;
  expect(heading, findsOneWidget);
  expect(find.text(countLabel), findsNothing);
  final fullHistoryAction = find.descendant(
    of: summary,
    matching: find.byTooltip(strings.logbookViewAllSessions),
  );
  expect(fullHistoryAction, findsOneWidget);
  final fullHistoryButton = find.ancestor(
    of: fullHistoryAction,
    matching: find.byType(IconButton),
  );
  expect(tester.widget<IconButton>(fullHistoryButton).onPressed, isNotNull);
  final periodAction = tester.widget<IconButton>(fullHistoryButton);
  expect(periodAction.alignment, Alignment.topCenter);
  expect(periodAction.padding, EdgeInsets.zero);
  expect(
    tester.getTopLeft(fullHistoryButton).dy,
    closeTo(tester.getTopLeft(heading).dy, 0.5),
  );
  expect(
    find.descendant(
      of: summary,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Padding &&
            widget.padding == const EdgeInsets.only(top: 4),
      ),
    ),
    findsOneWidget,
    reason: 'Keep the anatomy and metric block close to its period heading.',
  );

  final metricLabel = find.text(strings.logbookWorkouts);
  final metrics = find.ancestor(
    of: metricLabel,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).borderRadius ==
              ExpressiveTrainShapes.focusInset,
    ),
  );
  expect(metrics, findsOneWidget);
  expect(
    tester.getTopLeft(metrics).dy,
    greaterThan(tester.getBottomLeft(fullHistoryButton).dy),
    reason: 'The heading and full-history action should precede metrics.',
  );
  expect(
    tester.getTopLeft(session).dy,
    greaterThan(tester.getBottomLeft(metrics).dy),
    reason: 'Session rows should follow the aggregate metrics.',
  );
}

void _expectBadgeAtTopRightPerimeter(
  WidgetTester tester,
  Finder badge,
  Finder button, {
  required double size,
  required double overlap,
  required Color background,
  required Color foreground,
}) {
  final badgeRect = tester.getRect(badge);
  final buttonRect = tester.getRect(button);
  expect(badgeRect.width, size);
  expect(badgeRect.height, size);
  expect(badgeRect.left, greaterThanOrEqualTo(buttonRect.left));
  expect(badgeRect.top, closeTo(buttonRect.top - overlap, 0.5));
  expect(badgeRect.right, closeTo(buttonRect.right + overlap, 0.5));
  expect(badgeRect.bottom, lessThanOrEqualTo(buttonRect.bottom));
  expect(
    (tester.widget<Container>(badge).decoration! as BoxDecoration).color,
    background,
  );
  final badgeText = find.descendant(of: badge, matching: find.byType(Text));
  expect(tester.widget<Text>(badgeText).style?.color, foreground);
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
  final expectedForeground = outlined
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
