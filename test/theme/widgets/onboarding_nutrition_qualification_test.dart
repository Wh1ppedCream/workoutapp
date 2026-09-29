import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/screens/onboarding_flow.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

SemanticsData? _findSemanticsDataWithFlag(
  SemanticsNode node,
  SemanticsFlag flag,
) {
  final data = node.getSemanticsData();
  if (data.hasFlag(flag)) return data;

  SemanticsData? match;
  node.visitChildren((child) {
    match ??= _findSemanticsDataWithFlag(child, flag);
    return true;
  });
  return match;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets(
        '$mode weight-history switch keeps Material state ownership',
        (tester) async {
          await _withSemantics(tester, () async {
            final strings = await _loadStrings();
            final changes = <bool>[];
            var value = false;
            final title = strings.onboardingPreviouslyHeavier;

            await _pumpHost(
              tester,
              theme: theme,
              body: StatefulBuilder(
                builder: (context, setState) {
                  return OnboardingStyleHarness.card(
                    icon: Icons.monitor_weight_outlined,
                    title: strings.onboardingWeightHistoryTitle,
                    subtitle: strings.onboardingWeightHistorySubtitle,
                    children: [
                      OnboardingStyleHarness.switchCard(
                        title: title,
                        value: value,
                        onChanged: (next) {
                          changes.add(next);
                          setState(() => value = next);
                        },
                      ),
                    ],
                  );
                },
              ),
              size: const Size(390, 844),
            );

            final titleFinder = find.text(title);
            final switchFinder = find.byType(Switch);
            expect(switchFinder, findsOneWidget);
            expect(tester.widget<Switch>(switchFinder).value, isFalse);
            _expectSwitchCardSurface(tester, theme, titleFinder);
            _expectTextContrast(
              tester,
              titleFinder,
              _effectivePanelBackground(
                tester,
                titleFinder,
                strings.onboardingWeightHistoryTitle,
                theme,
              ),
              expectedForeground: _switchForeground(tester, theme, titleFinder),
            );

            final switchSemantics = tester.getSemantics(switchFinder);
            expect(
              switchSemantics.hasFlag(SemanticsFlag.hasToggledState),
              isTrue,
            );
            expect(switchSemantics.hasFlag(SemanticsFlag.isToggled), isFalse);
            expect(
              switchSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
              isTrue,
            );

            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pumpAndSettle();
            expect(FocusManager.instance.primaryFocus?.hasFocus, isTrue);
            await tester.sendKeyEvent(LogicalKeyboardKey.space);
            await tester.pumpAndSettle();

            expect(changes, <bool>[true]);
            expect(tester.widget<Switch>(switchFinder).value, isTrue);
            expect(
              tester
                  .getSemantics(switchFinder)
                  .hasFlag(SemanticsFlag.isToggled),
              isTrue,
            );
            expect(tester.takeException(), isNull);
          });
        },
      );

      testWidgets(
        '$mode body-fat tiles preserve selection and media contrast',
        (tester) async {
          await _withSemantics(tester, () async {
            final strings = await _loadStrings();
            final changes = <String>[];
            var selectedLabel = '15-20%';
            final firstLabel = '15-20%';
            final secondLabel = '20-25%';

            await _pumpHost(
              tester,
              theme: theme,
              body: _bodyFatHost(
                strings: strings,
                selectedLabel: () => selectedLabel,
                onSelected: (label, setState) {
                  changes.add(label);
                  setState(() => selectedLabel = label);
                },
              ),
              size: const Size(390, 844),
            );
            await tester.pumpAndSettle();

            final firstFinder = find.text(firstLabel);
            final secondFinder = find.text(secondLabel);
            expect(firstFinder, findsOneWidget);
            expect(secondFinder, findsOneWidget);
            _expectBodyFatTile(tester, theme, firstFinder, selected: true);
            _expectBodyFatTile(tester, theme, secondFinder, selected: false);

            final overlayFinder =
                find
                    .ancestor(
                      of: secondFinder,
                      matching: find.byType(Container),
                    )
                    .first;
            final overlayColor = tester.widget<Container>(overlayFinder).color!;
            expect(overlayColor, Colors.black.withValues(alpha: 0.58));
            expect(_resolvedTextColor(tester, secondFinder), Colors.white);
            final worstCaseOverlay = Color.alphaBlend(
              overlayColor,
              Colors.white,
            );
            expect(
              _contrastRatio(Colors.white, worstCaseOverlay),
              greaterThanOrEqualTo(4.5),
            );

            final fallbackIcon = find.byIcon(Icons.image_not_supported);
            expect(fallbackIcon, findsOneWidget);
            final fallbackContainer =
                find
                    .ancestor(
                      of: fallbackIcon,
                      matching: find.byType(Container),
                    )
                    .first;
            expect(
              tester.widget<Container>(fallbackContainer).color,
              theme.colorScheme.surfaceContainerHighest,
            );
            final fallbackIconColor =
                tester.widget<Icon>(fallbackIcon).color ??
                theme.iconTheme.color ??
                theme.colorScheme.onSurface;
            final fallbackBackground =
                tester.widget<Container>(fallbackContainer).color!;
            expect(
              _contrastRatio(
                Color.alphaBlend(fallbackIconColor, fallbackBackground),
                fallbackBackground,
              ),
              greaterThanOrEqualTo(3),
              reason: 'The missing-image indicator must remain visible.',
            );

            final tileInkWell =
                find
                    .ancestor(of: secondFinder, matching: find.byType(InkWell))
                    .first;
            final tileSemantics = tester.getSemantics(tileInkWell);
            expect(
              tileSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
              isTrue,
            );
            expect(tileSemantics.label, contains(secondLabel));

            final secondTile =
                find
                    .ancestor(
                      of: secondFinder,
                      matching: find.byType(AnimatedContainer),
                    )
                    .first;
            final context = tester.element(secondFinder);
            expect(
              tester.widget<AnimatedContainer>(secondTile).duration,
              context.tutorialTokens.selectionDuration,
            );
            await tester.ensureVisible(secondFinder);
            await tester.tap(secondFinder);
            await tester.pumpAndSettle();
            expect(changes, <String>[secondLabel]);
            _expectBodyFatTile(tester, theme, firstFinder, selected: false);
            _expectBodyFatTile(tester, theme, secondFinder, selected: true);
            expect(tester.takeException(), isNull);

            await _pumpHost(
              tester,
              theme: theme,
              body: _bodyFatHost(
                strings: strings,
                selectedLabel: () => firstLabel,
                onSelected: (_, __) {},
              ),
              size: const Size(390, 844),
              disableAnimations: true,
            );
            final reducedMotionTile =
                find
                    .ancestor(
                      of: find.text(firstLabel),
                      matching: find.byType(AnimatedContainer),
                    )
                    .first;
            expect(
              tester.widget<AnimatedContainer>(reducedMotionTile).duration,
              Duration.zero,
            );
            expect(tester.takeException(), isNull);
          });
        },
      );

      testWidgets('$mode goal metrics render with owned ink and large text', (
        tester,
      ) async {
        const locale = Locale('fr');
        final strings = await _loadStrings(locale);
        const metricValue = '2,025 kcal';
        final metricLabel = strings.onboardingInitialDailyBudget;
        const secondMetricValue = 'Oct 27';
        final secondMetricLabel = strings.onboardingProjectedEndDate;
        const weightValue = '140 lbs';
        final rateValue = strings.onboardingBodyWeightPerWeek('0.5');
        const weeklyValue = '-0.7 lbs / 0.5%';
        const monthlyValue = '-2.8 lbs / 2.0%';
        final rateFocusNode = FocusNode(
          debugLabel: 'qualification-goal-rate-slider',
        );
        addTearDown(rateFocusNode.dispose);
        final largeTextContent = _goalCard(
          strings: strings,
          metricValue: metricValue,
          metricLabel: metricLabel,
          secondMetricValue: secondMetricValue,
          secondMetricLabel: secondMetricLabel,
          weeklyValue: weeklyValue,
          monthlyValue: monthlyValue,
          rateFocusNode: rateFocusNode,
        );

        await _pumpHost(
          tester,
          theme: theme,
          body: largeTextContent,
          size: const Size(320, 760),
          textScale: 2,
          locale: locale,
        );

        final cardTitle = strings.onboardingGoalPaceTitle;
        final initialValueFinder = find.text(metricValue);
        final initialLabelFinder = find.text(metricLabel);
        final dateValueFinder = find.text(secondMetricValue);
        final dateLabelFinder = find.text(secondMetricLabel);
        final weightTitleFinder = find.text(strings.onboardingTargetWeight);
        final weightValueFinder = find.text(weightValue);
        final rateTitleFinder = find.text(strings.onboardingTargetGoalRate);
        final rateValueFinder = find.text(rateValue);
        final weeklyFinder = find.text(weeklyValue);
        final weeklyLabelFinder = find.text(strings.onboardingPerWeek);
        final monthlyFinder = find.text(monthlyValue);
        final monthlyLabelFinder = find.text(strings.onboardingPerMonth);

        final metricBackground = _expectOwnedSurface(
          tester,
          theme,
          initialValueFinder,
          cardTitle,
          expectedShape:
              family == AppThemeFamily.neoBrutalism
                  ? tester.element(initialValueFinder).shapeTokens.settingsInput
                  : tester
                      .element(initialValueFinder)
                      .tutorialTokens
                      .sectionShape,
          neoSurface: theme.surfaceTokens.dialogChoice,
          classicColor: theme.colorScheme.primary.withValues(alpha: 0.14),
          neo: family == AppThemeFamily.neoBrutalism,
          classicBorder: null,
        );
        final metricValueColor = _resolvedTextColor(tester, initialValueFinder);
        final metricLabelColor = _resolvedTextColor(tester, initialLabelFinder);
        _expectTextContrast(
          tester,
          initialValueFinder,
          metricBackground,
          expectedForeground:
              family == AppThemeFamily.neoBrutalism
                  ? tonosForegroundForSurface(
                    tester.element(initialValueFinder),
                    theme.surfaceTokens.dialogChoice,
                  )
                  : theme.colorScheme.onSurface,
          resolvedForeground: metricValueColor,
        );
        _expectTextContrast(
          tester,
          initialLabelFinder,
          metricBackground,
          expectedForeground:
              family == AppThemeFamily.neoBrutalism
                  ? tonosSecondaryForegroundForSurface(
                    tester.element(initialLabelFinder),
                    theme.surfaceTokens.dialogChoice,
                  )
                  : theme.colorScheme.onSurfaceVariant,
          resolvedForeground: metricLabelColor,
        );
        expect(dateValueFinder, findsOneWidget);
        expect(dateLabelFinder, findsOneWidget);

        final sliderBackground = _expectOwnedSurface(
          tester,
          theme,
          weightTitleFinder,
          cardTitle,
          expectedShape:
              family == AppThemeFamily.neoBrutalism
                  ? tester.element(weightTitleFinder).shapeTokens.settingsInput
                  : tester
                      .element(weightTitleFinder)
                      .tutorialTokens
                      .sectionShape,
          neoSurface: theme.surfaceTokens.settingsSection,
          classicColor: theme.colorScheme.surface.withValues(alpha: 0.52),
          neo: family == AppThemeFamily.neoBrutalism,
          classicBorder: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
            width: 1,
          ),
        );
        for (final finder in [weightTitleFinder, weightValueFinder]) {
          _expectTextContrast(
            tester,
            finder,
            sliderBackground,
            expectedForeground:
                family == AppThemeFamily.neoBrutalism
                    ? tonosForegroundForSurface(
                      tester.element(finder),
                      theme.surfaceTokens.settingsSection,
                    )
                    : finder == weightTitleFinder
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.primary,
          );
        }
        expect(rateTitleFinder, findsOneWidget);
        expect(rateValueFinder, findsOneWidget);
        final ratePanelFinder =
            find
                .ancestor(of: rateTitleFinder, matching: find.byType(Container))
                .first;
        final rateSliderFinder =
            find
                .descendant(of: ratePanelFinder, matching: find.byType(Slider))
                .first;
        expect(rateSliderFinder, findsOneWidget);
        expect(tester.widget<Slider>(rateSliderFinder).onChanged, isNotNull);
        await tester.ensureVisible(rateSliderFinder);
        await tester.pumpAndSettle();
        final rateSemantics = _findSemanticsDataWithFlag(
          tester.getSemantics(rateSliderFinder),
          SemanticsFlag.isSlider,
        );
        expect(rateSemantics, isNotNull);
        expect(rateSemantics!.hasAction(SemanticsAction.increase), isTrue);
        expect(rateSemantics.hasAction(SemanticsAction.decrease), isTrue);
        final initialRate = tester.widget<Slider>(rateSliderFinder).value;
        await tester.drag(rateSliderFinder, const Offset(36, 0));
        await tester.pumpAndSettle();
        final valueBeforeKeyboard =
            tester.widget<Slider>(rateSliderFinder).value;
        expect(valueBeforeKeyboard, greaterThan(initialRate));
        rateFocusNode.requestFocus();
        await tester.pumpAndSettle();
        expect(rateFocusNode.hasPrimaryFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        final valueAfterKeyboard =
            tester.widget<Slider>(rateSliderFinder).value;
        expect(valueAfterKeyboard, greaterThan(valueBeforeKeyboard));
        final updatedRateValueFinder = find.text(
          strings.onboardingBodyWeightPerWeek(
            valueAfterKeyboard.toStringAsFixed(1),
          ),
        );
        expect(updatedRateValueFinder, findsOneWidget);
        _expectSliderHeader(
          tester,
          strings.onboardingTargetGoalRate,
          stacked: true,
        );
        _expectTextContrast(
          tester,
          updatedRateValueFinder,
          sliderBackground,
          expectedForeground:
              family == AppThemeFamily.neoBrutalism
                  ? tonosForegroundForSurface(
                    tester.element(updatedRateValueFinder),
                    theme.surfaceTokens.settingsSection,
                  )
                  : theme.colorScheme.primary,
        );

        final weeklyBackground = _expectOwnedSurface(
          tester,
          theme,
          weeklyFinder,
          cardTitle,
          expectedShape:
              family == AppThemeFamily.neoBrutalism
                  ? tester.element(weeklyFinder).shapeTokens.settingsInput
                  : tester.element(weeklyFinder).tutorialTokens.inputShape,
          neoSurface: theme.surfaceTokens.dialogChoice,
          classicColor: theme.colorScheme.surface.withValues(alpha: 0.52),
          neo: family == AppThemeFamily.neoBrutalism,
          classicBorder: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
            width: 1,
          ),
        );
        for (final finder in [weeklyFinder, weeklyLabelFinder]) {
          _expectTextContrast(
            tester,
            finder,
            weeklyBackground,
            expectedForeground:
                family == AppThemeFamily.neoBrutalism
                    ? finder == weeklyFinder
                        ? tonosForegroundForSurface(
                          tester.element(finder),
                          theme.surfaceTokens.dialogChoice,
                        )
                        : tonosSecondaryForegroundForSurface(
                          tester.element(finder),
                          theme.surfaceTokens.dialogChoice,
                        )
                    : finder == weeklyFinder
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
          );
        }
        expect(monthlyFinder, findsOneWidget);
        expect(monthlyLabelFinder, findsOneWidget);

        for (final finder in [
          initialValueFinder,
          initialLabelFinder,
          dateValueFinder,
          dateLabelFinder,
          weightTitleFinder,
          weightValueFinder,
          rateTitleFinder,
          updatedRateValueFinder,
          weeklyFinder,
          weeklyLabelFinder,
          monthlyFinder,
          monthlyLabelFinder,
        ]) {
          expect(
            tester.renderObject<RenderParagraph>(finder).size.height,
            greaterThan(0),
          );
        }
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        '$mode representative goal values keep slider headers horizontal',
        (tester) async {
          final strings = await _loadStrings();
          await _pumpHost(
            tester,
            theme: theme,
            body: _goalCard(
              strings: strings,
              metricValue: '2,025 kcal',
              metricLabel: strings.onboardingInitialDailyBudget,
              secondMetricValue: 'Oct 27',
              secondMetricLabel: strings.onboardingProjectedEndDate,
              weeklyValue: '-0.7 lbs / 0.5%',
              monthlyValue: '-2.8 lbs / 2.0%',
            ),
            size: const Size(390, 844),
            textScale: 1.15,
          );

          _expectSliderHeader(
            tester,
            strings.onboardingTargetWeight,
            stacked: false,
          );
          _expectSliderHeader(
            tester,
            strings.onboardingTargetGoalRate,
            stacked: false,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Future<AppLocalizations> _loadStrings([Locale locale = const Locale('en')]) =>
    AppLocalizations.delegate.load(locale);

Future<void> _withSemantics(
  WidgetTester tester,
  Future<void> Function() body,
) async {
  final handle = tester.ensureSemantics();
  try {
    await body();
  } finally {
    handle.dispose();
  }
}

Future<void> _pumpHost(
  WidgetTester tester, {
  required ThemeData theme,
  required Widget body,
  required Size size,
  Locale locale = const Locale('en'),
  double textScale = 1,
  bool disableAnimations = false,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: locale,
      localizationsDelegates: tonosLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        );
        return MediaQuery(data: mediaQuery, child: child!);
      },
      home: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(child: SizedBox(width: size.width, child: body)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Widget _bodyFatHost({
  required AppLocalizations strings,
  required String Function() selectedLabel,
  required void Function(String label, StateSetter setState) onSelected,
}) => StatefulBuilder(
  builder: (context, setState) {
    const labels = ['15-20%', '20-25%'];
    const assetPaths = [
      'assets/bodyfat/15-20_bf.png',
      'assets/bodyfat/qualification_missing.png',
    ];
    return OnboardingStyleHarness.card(
      icon: Icons.image_search,
      title: strings.onboardingBodyFatEstimateTitle,
      subtitle: strings.onboardingBodyFatEstimateSubtitle,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: labels.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            final label = labels[index];
            return OnboardingStyleHarness.bodyFatTile(
              label: label,
              assetPath: assetPaths[index],
              isSelected: selectedLabel() == label,
              onTap: () => onSelected(label, setState),
            );
          },
        ),
      ],
    );
  },
);

Widget _goalCard({
  required AppLocalizations strings,
  required String metricValue,
  required String metricLabel,
  required String secondMetricValue,
  required String secondMetricLabel,
  required String weeklyValue,
  required String monthlyValue,
  FocusNode? rateFocusNode,
}) {
  var currentWeight = 140.0;
  var currentRate = 0.5;

  return StatefulBuilder(
    builder:
        (context, setState) => OnboardingStyleHarness.card(
          icon: Icons.flag_outlined,
          title: strings.onboardingGoalPaceTitle,
          subtitle: strings.onboardingGoalPaceSubtitle,
          children: [
            Row(
              children: [
                Expanded(
                  child: OnboardingStyleHarness.metricPreviewCard(
                    icon: Icons.local_fire_department_outlined,
                    value: metricValue,
                    label: metricLabel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OnboardingStyleHarness.metricPreviewCard(
                    icon: Icons.event,
                    value: secondMetricValue,
                    label: secondMetricLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _goalSliderPanel(
              title: strings.onboardingTargetWeight,
              valueLabel: '${currentWeight.round()} lbs',
              value: currentWeight,
              min: 100,
              max: 250,
              onChanged: (value) => setState(() => currentWeight = value),
            ),
            const SizedBox(height: 16),
            _goalSliderPanel(
              title: strings.onboardingTargetGoalRate,
              valueLabel: strings.onboardingBodyWeightPerWeek(
                currentRate.toStringAsFixed(1),
              ),
              value: currentRate,
              min: 0.1,
              max: 1,
              divisions: 9,
              focusNode: rateFocusNode,
              onChanged: (value) => setState(() => currentRate = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OnboardingStyleHarness.miniStat(
                    label: strings.onboardingPerWeek,
                    value: weeklyValue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OnboardingStyleHarness.miniStat(
                    label: strings.onboardingPerMonth,
                    value: monthlyValue,
                  ),
                ),
              ],
            ),
          ],
        ),
  );
}

Widget _goalSliderPanel({
  required String title,
  required String valueLabel,
  required double value,
  required double min,
  required double max,
  int? divisions,
  FocusNode? focusNode,
  required ValueChanged<double> onChanged,
}) => OnboardingStyleHarness.sliderPanel(
  title: title,
  valueLabel: valueLabel,
  child: Slider(
    value: value,
    min: min,
    max: max,
    divisions: divisions,
    focusNode: focusNode,
    onChanged: onChanged,
  ),
);

void _expectSliderHeader(
  WidgetTester tester,
  String title, {
  required bool stacked,
}) {
  final headerFinder =
      find
          .ancestor(of: find.text(title), matching: find.byType(LayoutBuilder))
          .first;
  expect(
    find.descendant(of: headerFinder, matching: find.byType(Row)),
    stacked ? findsNothing : findsOneWidget,
  );
  expect(
    find.descendant(of: headerFinder, matching: find.byType(Column)),
    stacked ? findsOneWidget : findsNothing,
  );
}

void _expectSwitchCardSurface(
  WidgetTester tester,
  ThemeData theme,
  Finder titleFinder,
) {
  final context = tester.element(titleFinder);
  final neo = context.usesNeoPresentation;
  final surface =
      neo ? context.surfaceTokens.settingsInput : theme.colorScheme.surface;
  final cardFinder =
      find.ancestor(of: titleFinder, matching: find.byType(Container)).first;
  final decoration =
      tester.widget<Container>(cardFinder).decoration! as BoxDecoration;
  expect(
    decoration.color,
    neo ? surface : theme.colorScheme.surface.withValues(alpha: 0.5),
  );
  expect(
    decoration.borderRadius,
    neo
        ? context.shapeTokens.settingsInput
        : context.tutorialTokens.sectionShape,
  );
  expect(
    decoration.border!.top.color,
    neo
        ? tonosOutlineForSurface(context, surface)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
  );
}

Color _switchForeground(
  WidgetTester tester,
  ThemeData theme,
  Finder titleFinder,
) {
  final context = tester.element(titleFinder);
  return context.usesNeoPresentation
      ? tonosForegroundForSurface(context, context.surfaceTokens.settingsInput)
      : theme.colorScheme.onSurface;
}

void _expectBodyFatTile(
  WidgetTester tester,
  ThemeData theme,
  Finder labelFinder, {
  required bool selected,
}) {
  final context = tester.element(labelFinder);
  final tileFinder =
      find
          .ancestor(of: labelFinder, matching: find.byType(AnimatedContainer))
          .first;
  final tile = tester.widget<AnimatedContainer>(tileFinder);
  final decoration = tile.decoration! as BoxDecoration;
  expect(decoration.borderRadius, context.tutorialTokens.inputShape);
  expect(decoration.border!.top.width, selected ? 2.4 : 1);
  expect(
    decoration.border!.top.color,
    selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
  );
  expect(_resolvedTextColor(tester, labelFinder), Colors.white);
}

Color _expectOwnedSurface(
  WidgetTester tester,
  ThemeData theme,
  Finder childFinder,
  String cardTitle, {
  required BorderRadiusGeometry expectedShape,
  required Color neoSurface,
  required Color classicColor,
  required bool neo,
  required BorderSide? classicBorder,
}) {
  final containerFinder =
      find.ancestor(of: childFinder, matching: find.byType(Container)).first;
  final decoration =
      tester.widget<Container>(containerFinder).decoration! as BoxDecoration;
  final childContext = tester.element(childFinder);
  expect(decoration.color, neo ? neoSurface : classicColor);
  expect(decoration.borderRadius, expectedShape);
  if (neo) {
    expect(
      decoration.border!.top,
      BorderSide(
        color: tonosOutlineForSurface(childContext, neoSurface),
        width: childContext.shapeTokens.outlineWidth,
      ),
    );
  } else {
    expect(decoration.border?.top, classicBorder);
  }
  return _effectivePanelBackground(tester, childFinder, cardTitle, theme);
}

Color _effectivePanelBackground(
  WidgetTester tester,
  Finder childFinder,
  String cardTitle,
  ThemeData theme,
) {
  final panelFinder =
      find.ancestor(of: childFinder, matching: find.byType(Container)).first;
  final panelDecoration =
      tester.widget<Container>(panelFinder).decoration! as BoxDecoration;
  final panelColor = panelDecoration.color!;

  final cardScroll =
      find
          .ancestor(
            of: find.text(cardTitle),
            matching: find.byType(SingleChildScrollView),
          )
          .first;
  final cardContainer =
      find.descendant(of: cardScroll, matching: find.byType(Container)).first;
  final cardDecoration =
      tester.widget<Container>(cardContainer).decoration! as BoxDecoration;
  final cardColor = cardDecoration.color!;
  final cardOverScaffold = Color.alphaBlend(
    cardColor,
    theme.colorScheme.surface,
  );
  return Color.alphaBlend(panelColor, cardOverScaffold);
}

void _expectTextContrast(
  WidgetTester tester,
  Finder finder,
  Color background, {
  required Color expectedForeground,
  Color? resolvedForeground,
}) {
  final actual = resolvedForeground ?? _resolvedTextColor(tester, finder);
  expect(actual, expectedForeground);
  expect(
    _contrastRatio(Color.alphaBlend(actual, background), background),
    greaterThanOrEqualTo(4.5),
  );
}

Color _resolvedTextColor(WidgetTester tester, Finder finder) {
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  final style = paragraph.text.style;
  final color = style?.color ?? style?.foreground?.color;
  expect(color, isNotNull);
  expect(paragraph.size.height, greaterThan(0));
  return color!;
}

double _contrastRatio(Color foreground, Color background) {
  final lighter = foreground.computeLuminance();
  final darker = background.computeLuminance();
  return (lighter > darker ? lighter + 0.05 : darker + 0.05) /
      (lighter < darker ? lighter + 0.05 : darker + 0.05);
}
