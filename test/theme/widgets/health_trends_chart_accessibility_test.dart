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
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/tokens/app_progress_colors.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';
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
      final semantics = tester.ensureSemantics();
      SharedPreferences.setMockInitialValues({});
      final theme = ExpressiveThemeDefinition.light();
      await tester.pumpWidget(_healthApp(units, entryCount: 3, theme: theme));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(HealthTrendsSection));
      expect(context.usesExpressivePresentation, isTrue);
      final cardColor = theme
          .extension<AppExpressiveTrainTokens>()!
          .activePlansSurface;
      final shapes = theme.shapeTokens;
      final trendTile = tester.widget<Container>(
        find.byKey(AppTestKeys.measurementTrend(1)),
      );
      expect(
        (trendTile.decoration! as BoxDecoration).borderRadius,
        shapes.healthTrendCard,
      );
      expect((trendTile.decoration! as BoxDecoration).border, isNull);
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
      final logButton = find.byKey(AppTestKeys.measurementTrendAdd(1));
      expect(tester.getSize(logButton).width, greaterThanOrEqualTo(44));
      final cardSemanticsNode = tester.getSemantics(
        find.byKey(AppTestKeys.measurementTrend(1)),
      );
      final cardSemantics = cardSemanticsNode.getSemanticsData();
      final logSemanticsFinder = find.byKey(
        const ValueKey('measurement-trend-1-log-semantics'),
      );
      final logSemanticsNode = tester.getSemantics(logSemanticsFinder);
      final logSemantics = logSemanticsNode.getSemanticsData();
      expect(cardSemantics.hasAction(SemanticsAction.tap), isTrue);
      expect(cardSemantics.label, contains('Body weight'));
      expect(logSemantics.label, 'Log Body weight');
      expect(logSemantics.hasAction(SemanticsAction.tap), isTrue);
      expect(logSemanticsNode.id, isNot(cardSemanticsNode.id));
      expect(find.semantics.byLabel('Log Body weight'), findsOneWidget);
      expect(
        tester.getSemantics(logButton).getSemanticsData().label,
        'Log Body weight',
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
      await tester.pump();
    },
  );

  testWidgets('Profile Health Trends use the page health card override', (
    tester,
  ) async {
    final units = await _readyUnits();
    addTearDown(units.dispose);
    SharedPreferences.setMockInitialValues({});
    const healthCard = Color(0xFFFFD54F);

    await tester.pumpWidget(
      _healthApp(
        units,
        entryCount: 3,
        theme: ExpressiveThemeDefinition.light(),
        fullPage: true,
        destinationFamily: AppExpressiveDestinationFamily.profile,
        healthCardOverride: healthCard,
      ),
    );
    await tester.pumpAndSettle();

    final tileMaterial = tester.widget<Material>(
      find
          .ancestor(
            of: find.byKey(AppTestKeys.measurementTrend(1)),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(tileMaterial.color, healthCard);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      _healthApp(
        units,
        entryCount: 0,
        metricCount: 0,
        theme: ExpressiveThemeDefinition.light(),
        fullPage: true,
        destinationFamily: AppExpressiveDestinationFamily.profile,
        healthCardOverride: healthCard,
      ),
    );
    await tester.pumpAndSettle();

    final messageMaterial = tester.widget<Material>(
      find
          .ancestor(
            of: find.text('No measurements yet'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(messageMaterial.color, healthCard);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Progress Health Trends use the destination accent and keep the alternate lane',
    (tester) async {
      final units = await _readyUnits();
      addTearDown(units.dispose);
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final brightness in Brightness.values) {
        SharedPreferences.setMockInitialValues({});
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final destination = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.progress,
          brightness,
        );
        final trainTokens = theme.extension<AppExpressiveTrainTokens>()!;

        await tester.pumpWidget(
          _healthApp(
            units,
            entryCount: 3,
            metricCount: 2,
            theme: theme,
            fullPage: true,
            destinationFamily: AppExpressiveDestinationFamily.progress,
            healthCardOverride: destination.surfaceAccent,
          ),
        );
        await tester.pumpAndSettle();

        Material tileMaterial(int id) => tester.widget<Material>(
          find
              .ancestor(
                of: find.byKey(AppTestKeys.measurementTrend(id)),
                matching: find.byType(Material),
              )
              .first,
        );

        expect(
          tileMaterial(1).color,
          destination.surfaceAccent,
          reason: 'Base Health Trends lane in $brightness mode',
        );
        expect(
          tileMaterial(2).color,
          trainTokens.creationSurface,
          reason: 'Alternate Health Trends lane in $brightness mode',
        );
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets('Progress health detail keeps the Progress destination scope', (
    tester,
  ) async {
    final units = await _readyUnits();
    addTearDown(units.dispose);
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.measurement_trend_detail_v1': true,
    });
    final destination = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.progress,
      Brightness.light,
    );

    await tester.pumpWidget(
      _healthApp(
        units,
        entryCount: 3,
        theme: ExpressiveThemeDefinition.light(),
        destinationFamily: AppExpressiveDestinationFamily.progress,
        healthCardOverride: destination.surfaceAccent,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AppTestKeys.measurementTrend(1)));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final detailContext = tester.element(
      find.byType(MeasurementTrendDetailPage),
    );
    expect(
      Theme.of(detailContext)
          .extension<AppExpressiveDestinationTokens>()
          ?.family,
      AppExpressiveDestinationFamily.progress,
    );
    expect(
      Theme.of(detailContext).progressColors.healthCard,
      destination.surfaceAccent,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Progress Expressive detail uses family surfaces and matching foregrounds',
    (tester) async {
      final units = await _readyUnits();
      addTearDown(units.dispose);
      await tester.binding.setSurfaceSize(const Size(390, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final brightness in Brightness.values) {
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.measurement_trend_detail_v1': true,
        });
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final destination = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.progress,
          brightness,
        );

        await tester.pumpWidget(
          _healthApp(
            units,
            entryCount: 3,
            measurementType: MeasurementType.BodyWeight,
            theme: theme,
            destinationFamily: AppExpressiveDestinationFamily.progress,
            healthCardOverride: destination.surfaceAccent,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(AppTestKeys.measurementTrend(1)));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final detailContext = tester.element(
          find.byType(MeasurementTrendDetailPage),
        );
        expect(
          Theme.of(detailContext)
              .extension<AppExpressiveDestinationTokens>()
              ?.family,
          AppExpressiveDestinationFamily.progress,
        );

        final summaryValue = find.byKey(
          const ValueKey('measurement-trend-summary-latest'),
        );
        final summaryMaterial = tester.widget<Material>(
          find
              .ancestor(of: summaryValue, matching: find.byType(Material))
              .first,
        );
        expect(summaryMaterial.color, destination.surfacePrimary);
        final summaryForeground = tester
            .widget<Text>(summaryValue)
            .style
            ?.color;
        expect(summaryForeground, destination.onSurfacePrimary);
        _expectReadable(summaryForeground!, destination.surfacePrimary);
        final changeValue = find.byKey(
          const ValueKey('measurement-trend-summary-change'),
        );
        final changeForeground = tester.widget<Text>(changeValue).style?.color;
        final expectedIncrease = Theme.of(tester.element(changeValue))
            .progressColors
            .healthIncrease;
        expect(changeForeground, expectedIncrease);
        _expectReadable(changeForeground!, destination.surfacePrimary);
        final recordsValue = find.byKey(
          const ValueKey('measurement-trend-summary-records'),
        );
        expect(tester.widget<Text>(recordsValue).data, '3');
        expect(
          tester.widget<Text>(recordsValue).style?.color,
          destination.onSurfacePrimary,
        );
        final recordsStat = find
            .ancestor(of: recordsValue, matching: find.byType(Column))
            .first;
        expect(
          tester
              .widgetList<Text>(
                find.descendant(of: recordsStat, matching: find.byType(Text)),
              )
              .map((text) => text.data)
              .whereType<String>(),
          [
            AppLocalizations.of(tester.element(recordsValue)).healthRecords,
            '3',
          ],
          reason: 'Expressive records count has no measurement unit detail.',
        );

        final entriesHeading = tester.widget<Text>(
          find.text(AppLocalizations.of(detailContext).healthEntries),
        );
        expect(entriesHeading.style?.fontSize, 20);
        expect(
          entriesHeading.style?.fontWeight?.value,
          greaterThanOrEqualTo(600),
        );

        final chart = find.byKey(
          const ValueKey('measurement-trend-chart-semantics'),
        );
        final chartContainer = tester.widget<Container>(
          find.descendant(of: chart, matching: find.byType(Container)).first,
        );
        final chartSurface =
            (chartContainer.decoration! as BoxDecoration).color!;
        final expectedChartSurface = brightness == Brightness.light
            ? Color.lerp(
                destination.surfaceSecondary,
                destination.pageCanvas,
                0.28,
              )
            : destination.surfaceSecondary;
        expect(chartSurface, expectedChartSurface);
        expect(
          chartContainer.padding,
          const EdgeInsets.fromLTRB(18, 13, 18, 16),
        );
        expect(tester.getSize(chart).height, 225);
        final chartData = tester.widget<LineChart>(find.byType(LineChart)).data;
        expect(chartData.lineBarsData.single.isCurved, isFalse);
        expect(chartData.minX, lessThan(0));
        expect(chartData.maxX, greaterThan(2));
        expect(chartData.titlesData.bottomTitles.sideTitles.reservedSize, 34);
        final yTick = find.byKey(
          const ValueKey('measurement-trend-chart-y-tick-0'),
        );
        final yTickText = tester.widget<Text>(yTick);
        final yTickForeground =
            yTickText.style?.color ??
            Theme.of(tester.element(yTick)).colorScheme.onSurface;
        expect(yTickForeground, destination.onSurfaceSecondary);
        _expectReadable(yTickForeground, chartSurface);

        final historyKey = const ValueKey('measurement-trend-entry-100');
        final historyCard = tester.widget<Card>(find.byKey(historyKey));
        final historySurface = Color.alphaBlend(
          destination.surfaceAccent.withValues(alpha: 0.42),
          destination.pageCanvas,
        );
        expect(historyCard.color, historySurface);
        final historyTitle = tester.widget<Text>(
          find.descendant(
            of: find.byKey(historyKey),
            matching: find.text('70 kg'),
          ),
        );
        expect(historyTitle.style?.color, destination.onSurfaceAccent);
        _expectReadable(destination.onSurfaceAccent, historySurface);
        final historySubtitle = tester.widget<Text>(
          find
              .descendant(
                of: find.byKey(historyKey),
                matching: find.byType(Text),
              )
              .last,
        );
        expect(
          historySubtitle.style?.color,
          destination.onSurfaceAccent.withValues(alpha: 0.82),
        );

        expect(
          {
            summaryMaterial.color,
            chartSurface,
            historySurface,
            destination.pageCanvas,
          }.length,
          4,
          reason: 'Each detail section keeps its Progress surface role.',
        );

        await tester.tap(
          find.byKey(const ValueKey('measurement-trend-detail-add')),
        );
        await tester.pumpAndSettle();
        final dialog = tester.widget<AlertDialog>(
          find.byKey(const ValueKey('measurement-trend-entry-dialog')),
        );
        final expectedDialogSurface = brightness == Brightness.light
            ? Color.lerp(
                destination.pageCanvas,
                destination.surfaceTertiary,
                0.30,
              )!
            : destination.surfaceTertiary;
        expect(dialog.backgroundColor, expectedDialogSurface);
        expect(dialog.titleTextStyle?.color, destination.supportingForeground);
        expect(
          dialog.contentTextStyle?.color,
          destination.supportingForeground.withValues(alpha: 0.82),
        );
        _expectReadable(
          destination.supportingForeground,
          expectedDialogSurface,
        );
        final dialogShape = dialog.shape! as RoundedRectangleBorder;
        expect(dialogShape.side.width, 1);
        expect(
          dialogShape.side.color,
          destination.outlineAccent.withValues(alpha: 0.48),
        );
        final valueField = tester.widget<TextField>(
          find.byKey(AppTestKeys.measurementEntryValue),
        );
        expect(valueField.style?.color, destination.supportingForeground);
        expect(
          valueField.decoration?.fillColor,
          Color.alphaBlend(
            destination.surfaceSelected.withValues(alpha: 0.30),
            expectedDialogSurface,
          ),
        );
        _expectReadable(
          destination.supportingForeground,
          Color.alphaBlend(
            destination.surfaceSelected.withValues(alpha: 0.30),
            expectedDialogSurface,
          ),
        );
        final saveButton = find.byKey(AppTestKeys.measurementEntrySave);
        final dialogTheme = Theme.of(tester.element(saveButton));
        expect(dialogTheme.colorScheme.primary, destination.actionPrimary);
        expect(dialogTheme.colorScheme.onPrimary, destination.onActionPrimary);
        expect(dialogTheme.colorScheme.outline, destination.outlineAccent);
        final dateButton = tester.widget<OutlinedButton>(
          find.byKey(const ValueKey('measurement-entry-date')),
        );
        expect(
          dateButton.style!.foregroundColor!.resolve(const <WidgetState>{}),
          destination.actionPrimary,
        );
        expect(
          dateButton.style!.side!.resolve(const <WidgetState>{})!.color,
          destination.outlineAccent.withValues(alpha: 0.72),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets('Classic and Neo detail routes retain their existing surfaces', (
    tester,
  ) async {
    final units = await _readyUnits();
    addTearDown(units.dispose);
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final family in [
      AppThemeFamily.classic,
      AppThemeFamily.neoBrutalism,
    ]) {
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.measurement_trend_detail_v1': true,
      });
      final theme = AppThemeFactory.light(family);
      await tester.pumpWidget(
        _healthApp(
          units,
          entryCount: 3,
          measurementType: MeasurementType.BodyWeight,
          theme: theme,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(AppTestKeys.measurementTrend(1)));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      final summaryValue = find.byKey(
        const ValueKey('measurement-trend-summary-latest'),
      );
      final summaryContainer = tester.widget<Container>(
        find.ancestor(of: summaryValue, matching: find.byType(Container)).first,
      );
      final summaryBox = summaryContainer.decoration! as BoxDecoration;
      final expectedSummarySurface = family == AppThemeFamily.neoBrutalism
          ? theme.surfaceTokens.catalogSelection
          : theme.progressColors.healthCard;
      expect(
        summaryBox.color,
        expectedSummarySurface,
        reason: '$family summary',
      );

      final chart = find.byKey(
        const ValueKey('measurement-trend-chart-semantics'),
      );
      final chartContainer = tester.widget<Container>(
        find.descendant(of: chart, matching: find.byType(Container)).first,
      );
      expect(tester.getSize(chart).height, 250);
      final chartLine = tester
          .widget<LineChart>(find.byType(LineChart))
          .data
          .lineBarsData
          .single;
      expect(
        chartLine.isCurved,
        isTrue,
        reason: '$family keeps its chart line.',
      );
      final expectedChartSurface = family == AppThemeFamily.neoBrutalism
          ? theme.surfaceTokens.card
          : theme.progressColors.healthCard;
      expect(
        (chartContainer.decoration! as BoxDecoration).color,
        expectedChartSurface,
        reason: '$family chart',
      );
      expect(
        tester
            .widget<Card>(
              find.byKey(const ValueKey('measurement-trend-entry-100')),
            )
            .color,
        isNull,
        reason: '$family keeps the standard history Card surface',
      );
      final historyTile = tester.widget<ListTile>(
        find.descendant(
          of: find.byKey(const ValueKey('measurement-trend-entry-100')),
          matching: find.byType(ListTile),
        ),
      );
      expect(
        historyTile.tileColor,
        family == AppThemeFamily.neoBrutalism
            ? theme.surfaceTokens.catalogSelection
            : theme.progressColors.healthCard,
        reason: '$family keeps the existing history tile surface',
      );
      await tester.tap(
        find.byKey(const ValueKey('measurement-trend-detail-add')),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AlertDialog>(
              find.byKey(const ValueKey('measurement-trend-entry-dialog')),
            )
            .backgroundColor,
        isNull,
        reason: '$family keeps the Material dialog surface',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets(
    'Expressive health detail route keeps destination and health card theme',
    (tester) async {
      final units = await _readyUnits();
      addTearDown(units.dispose);
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.measurement_trend_detail_v1': true,
      });
      const healthCard = Color(0xFFFFD54F);

      await tester.pumpWidget(
        _healthApp(
          units,
          entryCount: 3,
          measurementType: MeasurementType.BodyWeight,
          theme: ExpressiveThemeDefinition.light(),
          destinationFamily: AppExpressiveDestinationFamily.profile,
          healthCardOverride: healthCard,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(AppTestKeys.measurementTrend(1)));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      final detailContext = tester.element(
        find.byType(MeasurementTrendDetailPage),
      );
      expect(
        Theme.of(detailContext)
            .extension<AppExpressiveDestinationTokens>()
            ?.family,
        AppExpressiveDestinationFamily.profile,
      );
      expect(Theme.of(detailContext).progressColors.healthCard, healthCard);
      final chartSurface = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(
                const ValueKey('measurement-trend-chart-semantics'),
              ),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((chartSurface.decoration! as BoxDecoration).color, healthCard);

      final summaryValue = find.byKey(
        const ValueKey('measurement-trend-summary-latest'),
      );
      final summaryContainer = tester.widget<Container>(
        find.ancestor(of: summaryValue, matching: find.byType(Container)).first,
      );
      expect((summaryContainer.decoration! as BoxDecoration).color, healthCard);
      expect(
        tester.widget<Text>(summaryValue).style?.color,
        Theme.of(detailContext).colorScheme.onSurface,
      );

      final historyCard = tester.widget<Card>(
        find.byKey(const ValueKey('measurement-trend-entry-100')),
      );
      expect(historyCard.color, isNull);
      final historyTile = tester.widget<ListTile>(
        find.descendant(
          of: find.byKey(const ValueKey('measurement-trend-entry-100')),
          matching: find.byType(ListTile),
        ),
      );
      expect(historyTile.tileColor, healthCard);

      await tester.tap(
        find.byKey(const ValueKey('measurement-trend-detail-add')),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AlertDialog>(
              find.byKey(const ValueKey('measurement-trend-entry-dialog')),
            )
            .backgroundColor,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Expressive Health gives empty metric and entry states an action',
    (tester) async {
      final units = await _readyUnits();
      addTearDown(units.dispose);
      await tester.binding.setSurfaceSize(const Size(320, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        _healthApp(
          units,
          entryCount: 0,
          metricCount: 0,
          theme: ExpressiveThemeDefinition.light(),
          textScale: 1.5,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No measurements yet'), findsOneWidget);
      expect(
        find.text('Create a metric to start tracking progress.'),
        findsOneWidget,
      );
      expect(find.text('Metric'), findsOneWidget);
      expect(find.text('Create metric'), findsOneWidget);
      expect(
        tester.widgetList<TextButton>(find.byType(TextButton)),
        everyElement(
          predicate<TextButton>((button) => button.onPressed != null),
        ),
      );
      final theme = ExpressiveThemeDefinition.light();
      expect(
        tester
            .widgetList<Material>(find.byType(Material))
            .any(
              (material) =>
                  material.color ==
                  theme
                      .extension<AppExpressiveTrainTokens>()!
                      .activePlansSurface,
            ),
        isTrue,
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(_healthApp(units, entryCount: 0, theme: theme));
      await tester.pumpAndSettle();
      expect(find.text('Tap + to log'), findsOneWidget);
      final emptySparkline = find.byKey(
        const ValueKey('measurement-sparkline-1-semantics'),
      );
      expect(emptySparkline, findsOneWidget);
      expect(
        tester.getSemantics(emptySparkline).getSemanticsData().label,
        contains('Log entries to build a trend.'),
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

  testWidgets('Expressive Health rail keeps the next card peeking', (
    tester,
  ) async {
    final units = await _readyUnits();
    addTearDown(units.dispose);
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      _healthApp(
        units,
        entryCount: 3,
        metricCount: 3,
        theme: ExpressiveThemeDefinition.light(),
        disableAnimations: true,
      ),
    );
    await tester.pumpAndSettle();

    final first = tester.getRect(find.byKey(AppTestKeys.measurementTrend(1)));
    final second = tester.getRect(find.byKey(AppTestKeys.measurementTrend(2)));
    expect(first.left, greaterThanOrEqualTo(0));
    expect(second.left, lessThan(320));
    expect(second.right, greaterThan(320));
    expect(find.text('Metric'), findsOneWidget);

    final reveals = find.byType(TonosExpressiveReveal);
    expect(reveals, findsWidgets);
    for (final reveal in reveals.evaluate()) {
      final opacityFinder = find.descendant(
        of: find.byWidget(reveal.widget),
        matching: find.byType(Opacity),
      );
      expect(
        tester
            .widgetList<Opacity>(opacityFinder)
            .map((widget) => widget.opacity),
        everyElement(1.0),
      );
    }
    final pressResponses = find.byType(TonosExpressivePressResponse);
    for (final pressResponse in pressResponses.evaluate()) {
      final transforms = tester.widgetList<Transform>(
        find.descendant(
          of: find.byWidget(pressResponse.widget),
          matching: find.byType(Transform),
        ),
      );
      expect(
        transforms.map((transform) => transform.transform.getMaxScaleOnAxis()),
        everyElement(1.0),
      );
    }
    expect(tester.takeException(), isNull);
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
    'compact health trend keeps one empty sparkline action and summary values',
    (tester) async {
      final units = await _readyUnits();
      addTearDown(units.dispose);
      await tester.binding.setSurfaceSize(const Size(320, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(_healthApp(units, entryCount: 3, fullPage: true));
      await tester.pumpAndSettle();

      final trend = find.byKey(AppTestKeys.measurementTrend(1));
      final sparkline = find.byKey(
        const ValueKey('measurement-sparkline-1-semantics'),
      );
      expect(
        find.descendant(
          of: trend,
          matching: find.byKey(AppTestKeys.measurementTrendAdd(1)),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sparkline, matching: find.byType(IconButton)),
        findsNothing,
      );

      await tester.tap(trend);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('measurement-trend-summary-latest')),
            )
            .data,
        contains('72'),
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('measurement-trend-summary-change')),
            )
            .data,
        contains('+1'),
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('measurement-trend-summary-records')),
            )
            .data,
        '3',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'empty detail summary and chart retain an intentional empty state',
    (tester) async {
      final units = await _readyUnits();
      addTearDown(units.dispose);
      await tester.binding.setSurfaceSize(const Size(320, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.measurement_trend_detail_v1': true,
      });
      final destination = AppExpressiveDestinationTokens.forFamily(
        AppExpressiveDestinationFamily.progress,
        Brightness.light,
      );

      await tester.pumpWidget(
        _healthApp(
          units,
          entryCount: 0,
          measurementType: MeasurementType.Height,
          fullPage: true,
          theme: ExpressiveThemeDefinition.light(),
          destinationFamily: AppExpressiveDestinationFamily.progress,
          healthCardOverride: destination.surfaceAccent,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(AppTestKeys.measurementTrend(1)));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('measurement-trend-summary-latest')),
            )
            .data,
        'No entry',
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('measurement-trend-summary-change')),
            )
            .data,
        '—',
      );
      final recordsValue = find.byKey(
        const ValueKey('measurement-trend-summary-records'),
      );
      expect(tester.widget<Text>(recordsValue).data, '0');
      final summaryStrings = AppLocalizations.of(
        tester.element(
          find.byKey(const ValueKey('measurement-trend-summary-latest')),
        ),
      );
      final recordsStat = find
          .ancestor(of: recordsValue, matching: find.byType(Column))
          .first;
      expect(
        tester
            .widgetList<Text>(
              find.descendant(of: recordsStat, matching: find.byType(Text)),
            )
            .map((text) => text.data)
            .whereType<String>(),
        [summaryStrings.healthRecords, '0'],
        reason: 'Expressive records count has no measurement unit detail.',
      );
      expect(find.text(summaryStrings.healthChange), findsOneWidget);
      expect(find.text(summaryStrings.healthNeedTwoEntries), findsOneWidget);
      expect(find.text(summaryStrings.healthRecords), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
      expect(find.text(summaryStrings.healthNotTrackedYet), findsOneWidget);
      expect(
        find.byKey(const ValueKey('measurement-trend-chart-empty')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('measurement-trend-chart-empty')),
          matching: find.byType(FilledButton),
        ),
        findsNothing,
        reason: 'The empty chart does not add a duplicate log action.',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'same-day detail ticks are suppressed while all points stay accessible',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final units = await _readyUnits();
      addTearDown(units.dispose);
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.measurement_trend_detail_v1': true,
      });
      final entries = [
        for (var index = 0; index < 3; index++)
          Measurement(
            id: 100 + index,
            defId: 1,
            timestamp: DateTime(2026, 1, 10, 8 + index),
            value: 70 + index.toDouble(),
            unit: 'kg',
          ),
      ];

      await tester.pumpWidget(
        _healthApp(units, entryCount: entries.length, measurements: entries),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('measurement-trend-1')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      final chart = find.byKey(
        const ValueKey('measurement-trend-chart-semantics'),
      );
      final lineChart = find.descendant(
        of: chart,
        matching: find.byType(LineChart),
      );
      expect(
        tester.widget<LineChart>(lineChart).data.lineBarsData.single.spots,
        hasLength(3),
      );
      expect(
        find.byKey(const ValueKey('measurement-trend-chart-tick-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('measurement-trend-chart-tick-1')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('measurement-trend-chart-tick-2')),
        findsNothing,
      );

      var data = tester.getSemantics(chart).getSemanticsData();
      expect(data.label, contains('3 entries'));
      expect(data.value, contains('72'));
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
      expect(
        tester.getSemantics(chart).getSemanticsData().value,
        contains('70'),
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
      await tester.pump();
    },
  );

  testWidgets('detail Y ticks stay distinct for close and large values', (
    tester,
  ) async {
    final units = await _readyUnits();
    addTearDown(units.dispose);
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final values in [
      <double>[52.2, 52.4, 52.6],
      <double>[125000, 125500, 126000],
    ]) {
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.measurement_trend_detail_v1': true,
      });
      final entries = [
        for (var index = 0; index < values.length; index++)
          Measurement(
            id: 100 + index,
            defId: 1,
            timestamp: DateTime(2026, 1, 10 + index, 8),
            value: values[index],
            unit: 'kg',
          ),
      ];
      await tester.pumpWidget(
        _healthApp(units, entryCount: entries.length, measurements: entries),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('measurement-trend-1')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      final labels = <String>[];
      for (var index = 0; index < 8; index++) {
        final tick = find.byKey(
          ValueKey('measurement-trend-chart-y-tick-$index'),
        );
        if (tick.evaluate().isNotEmpty) {
          final text = tester.widgetList<Text>(tick).first.data;
          if (text != null) labels.add(text);
        }
      }
      expect(labels.length, greaterThanOrEqualTo(2));
      expect(labels.toSet(), hasLength(labels.length));
      expect(labels, everyElement(isNotEmpty));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('two-point detail chart renders both points and axis labels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final units = await _readyUnits();
    addTearDown(units.dispose);
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.measurement_trend_detail_v1': true,
    });
    final entries = [
      Measurement(
        id: 100,
        defId: 1,
        timestamp: DateTime(2026, 1, 10, 8),
        value: 52.2,
        unit: 'kg',
      ),
      Measurement(
        id: 101,
        defId: 1,
        timestamp: DateTime(2026, 1, 12, 8),
        value: 54.4,
        unit: 'kg',
      ),
    ];

    await tester.pumpWidget(
      _healthApp(units, entryCount: entries.length, measurements: entries),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('measurement-trend-1')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final lineChart = find.descendant(
      of: find.byKey(const ValueKey('measurement-trend-chart-semantics')),
      matching: find.byType(LineChart),
    );
    final data = tester.widget<LineChart>(lineChart).data;
    expect(data.lineBarsData.single.spots, hasLength(2));
    expect(data.lineBarsData.single.spots.first.y, 52.2);
    expect(data.lineBarsData.single.spots.last.y, 54.4);
    expect(
      find.byKey(const ValueKey('measurement-trend-chart-tick-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('measurement-trend-chart-tick-1')),
      findsOneWidget,
    );
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey('measurement-trend-chart-semantics')),
          )
          .getSemanticsData()
          .label,
      contains('2 entries'),
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
    await tester.pump();
  });

  testWidgets('entry row edit preserves modal fields and repository callback', (
    tester,
  ) async {
    final units = await _readyUnits();
    addTearDown(units.dispose);
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.measurement_trend_detail_v1': true,
    });
    final originalTimestamp = DateTime(2026, 1, 10, 8);
    final original = Measurement(
      id: 100,
      defId: 1,
      timestamp: originalTimestamp,
      value: 70,
      unit: 'kg',
      context: MeasurementContext.wakeUp,
    );
    final repository = _MeasurementRepository(
      entryCount: 1,
      measurements: [original],
      measurementType: MeasurementType.BodyWeight,
    );

    await tester.pumpWidget(
      _healthApp(units, entryCount: 1, repository: repository),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('measurement-trend-1')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final entryRow = find.byKey(const ValueKey('measurement-trend-entry-100'));
    expect(entryRow, findsOneWidget);
    await tester.tap(entryRow);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('measurement-trend-entry-dialog')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(AppTestKeys.measurementEntryValue))
          .controller!
          .text,
      '70',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(AppTestKeys.measurementEntryUnit))
          .controller!
          .text,
      'kg',
    );
    final variation = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(variation.initialValue, 'WakeUp');
    await tester.enterText(
      find.byKey(AppTestKeys.measurementEntryValue),
      '71.5',
    );
    await tester.enterText(find.byKey(AppTestKeys.measurementEntryUnit), 'lb');
    final noteField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == 'Note',
    );
    await tester.enterText(noteField, 'after training');
    await tester.tap(find.byKey(AppTestKeys.measurementEntrySave));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final updated = repository.updatedMeasurement;
    expect(updated, isNotNull);
    expect(updated!.id, original.id);
    expect(updated.timestamp, originalTimestamp);
    expect(updated.value, 71.5);
    expect(updated.unit, 'lb');
    expect(updated.note, 'after training');
    expect(updated.context, MeasurementContext.wakeUp);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'detail and entry modal avoid overflow across compact, tablet, and landscape layouts',
    (tester) async {
      final units = await _readyUnits();
      addTearDown(units.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final theme = ExpressiveThemeDefinition.light();
      final destination = AppExpressiveDestinationTokens.forFamily(
        AppExpressiveDestinationFamily.progress,
        Brightness.light,
      );

      for (final layout in [
        (
          size: const Size(320, 900),
          scale: 2.0,
          viewInsets: const EdgeInsets.only(bottom: 300),
        ),
        (size: const Size(390, 1100), scale: 1.5, viewInsets: EdgeInsets.zero),
        (size: const Size(600, 1000), scale: 1.3, viewInsets: EdgeInsets.zero),
        (
          size: const Size(800, 390),
          scale: 1.5,
          viewInsets: const EdgeInsets.only(bottom: 160),
        ),
        (
          size: const Size(1024, 768),
          scale: 2.0,
          viewInsets: const EdgeInsets.only(bottom: 220),
        ),
      ]) {
        await tester.binding.setSurfaceSize(layout.size);
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.measurement_trend_detail_v1': true,
        });
        final entries = [
          Measurement(
            id: 100,
            defId: 1,
            timestamp: DateTime(2026, 1, 10, 8),
            value: 70,
            unit: 'kg',
          ),
          Measurement(
            id: 101,
            defId: 1,
            timestamp: DateTime(2026, 1, 11, 8),
            value: 71,
            unit: 'kg',
          ),
        ];
        await tester.pumpWidget(
          _healthApp(
            units,
            entryCount: entries.length,
            measurements: entries,
            measurementType: MeasurementType.BodyWeight,
            theme: theme,
            destinationFamily: AppExpressiveDestinationFamily.progress,
            healthCardOverride: destination.surfaceAccent,
            textScale: layout.scale,
            viewInsets: layout.viewInsets,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'overview at $layout');
        await tester.tap(find.byKey(const ValueKey('measurement-trend-1')));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'detail at $layout');

        await tester.tap(find.byTooltip('Log entry').first);
        await tester.pumpAndSettle();
        final valueField = find.byKey(AppTestKeys.measurementEntryValue);
        expect(valueField, findsOneWidget);
        await tester.ensureVisible(valueField);
        expect(valueField.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'modal at $layout');
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

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
  int metricCount = 1,
  List<Measurement>? measurements,
  MeasurementType measurementType = MeasurementType.Custom,
  _MeasurementRepository? repository,
  ThemeData? theme,
  double textScale = 1,
  bool disableAnimations = false,
  bool fullPage = false,
  AppExpressiveDestinationFamily? destinationFamily,
  Color? healthCardOverride,
  EdgeInsets viewInsets = EdgeInsets.zero,
}) {
  final trendsSection = HealthTrendsSection(fullPage: fullPage);
  final trendsPage = Scaffold(
    body: fullPage ? trendsSection : ListView(children: [trendsSection]),
  );
  final home = destinationFamily == null
      ? trendsPage
      : AppExpressiveDestinationTheme(
          family: destinationFamily,
          child: Builder(
            builder: (context) {
              final pageTheme = Theme.of(context);
              final progressColors = pageTheme.progressColors.copyWith(
                healthCard: healthCardOverride,
              );
              return Theme(
                data: pageTheme.copyWith(
                  extensions: [
                    for (final extension in pageTheme.extensions.values)
                      if (extension is! AppProgressColors) extension,
                    progressColors,
                  ],
                ),
                child: trendsPage,
              );
            },
          ),
        );
  return MultiProvider(
    providers: [
      Provider<AppRepository>.value(
        value:
            repository ??
            _MeasurementRepository(
              entryCount: entryCount,
              metricCount: metricCount,
              measurements: measurements,
              measurementType: measurementType,
            ),
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
          viewInsets: viewInsets,
        ),
        child: child!,
      ),
      home: home,
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
  _MeasurementRepository({
    required this.entryCount,
    this.metricCount = 1,
    this.measurements,
    this.measurementType = MeasurementType.Custom,
  });

  final int entryCount;
  final int metricCount;
  final List<Measurement>? measurements;
  final MeasurementType measurementType;
  Measurement? updatedMeasurement;

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
      for (var index = 1; index <= metricCount; index++)
        MeasurementDefinition(
          id: index,
          name: index == 1 ? 'Body weight' : 'Metric $index',
          type: index == 1 ? measurementType : MeasurementType.Custom,
        ),
    ];
  }

  @override
  Future<List<Measurement>> fetchClassMeasurementsForDefinition(
    int defId,
  ) async {
    if (measurements != null && defId == 1) {
      return List<Measurement>.of(measurements!);
    }
    return [
      for (var index = 0; index < entryCount; index++)
        Measurement(
          id: defId * 100 + index,
          defId: defId,
          timestamp: DateTime(2026, 1, 10 + index, 8),
          value: 70 + index.toDouble(),
          unit: 'kg',
        ),
    ];
  }

  @override
  Future<void> updateMeasurement({
    required int measurementId,
    required DateTime timestamp,
    required double value,
    required String unit,
    String? note,
    MeasurementContext? context,
  }) async {
    updatedMeasurement = Measurement(
      id: measurementId,
      defId: 1,
      timestamp: timestamp,
      value: value,
      unit: unit,
      note: note,
      context: context,
    );
  }
}

void _expectReadable(Color foreground, Color background) {
  final visibleForeground = Color.alphaBlend(foreground, background);
  final foregroundLuminance = visibleForeground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  expect(
    (lighter + 0.05) / (darker + 0.05),
    greaterThanOrEqualTo(4.5),
    reason: 'Foreground $foreground should be readable on $background.',
  );
}
