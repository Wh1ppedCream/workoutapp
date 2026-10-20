import 'dart:convert';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/providers/dashboard_config.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/dashboard_page.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/widgets/dashboard_sections.dart';
import 'package:env_test/widgets/dashboard_section_palette.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_support.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive Dashboard keeps its focal identity and editor actions at 320dp ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 820));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4E2868),
            brightness: brightness,
          ),
          extensions: const [
            AppThemeIdentity(family: AppThemeFamilyIdentity.expressivePreview),
          ],
        );
        final config = await _pumpEmptyDashboard(tester, theme, textScale: 2);
        final pageContext = tester.element(find.byType(DashboardPage));
        final strings = AppLocalizations.of(pageContext);
        final routeContext = tester.element(find.text(strings.dashboardTitle));
        final tokens = Theme.of(routeContext)
            .extension<AppExpressiveDestinationTokens>()!;

        expect(tokens.family, AppExpressiveDestinationFamily.dashboard);
        expect(find.text(strings.dashboardTitle), findsOneWidget);
        expect(find.text(strings.dashboardEmptyTitle), findsOneWidget);
        final hero = tester.widget<Container>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.padding ==
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        );
        final heroDecoration = hero.decoration! as BoxDecoration;
        expect(heroDecoration.gradient!.colors, [
          tokens.surfacePrimary,
          tokens.surfacePrimary,
        ]);
        expect(tester.takeException(), isNull);

        final customizeButton = find.byTooltip(strings.dashboardCustomize);
        await tester.ensureVisible(customizeButton);
        await tester.tap(customizeButton);
        await tester.pumpAndSettle();
        expect(find.byType(ReorderableListView), findsOneWidget);
        expect(find.text(strings.dashboardEditorHelp), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(config.widgetOrder, DashboardConfig.defaultOrder);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      'Expressive Dashboard shows the full resume action at 320dp and 2x ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 820));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4E2868),
            brightness: brightness,
          ),
          extensions: const [
            AppThemeIdentity(family: AppThemeFamilyIdentity.expressivePreview),
          ],
        );
        late final ActiveSession session;
        await _pumpEmptyDashboard(
          tester,
          theme,
          textScale: 2,
          showResumeAction: true,
          onSessionReady: (value) => session = value,
        );

        final pageContext = tester.element(find.byType(DashboardPage));
        final strings = AppLocalizations.of(pageContext);
        for (final label in [
          strings.dashboardTitle,
          strings.dashboardMeasurement,
          strings.dashboardResumeWorkout,
        ]) {
          final finder = find.text(label);
          expect(finder, findsOneWidget, reason: label);
          final text = tester.widget<Text>(finder);
          expect(text.maxLines, isNull, reason: label);
          expect(text.overflow, isNull, reason: label);
          expect(text.softWrap, isTrue, reason: label);
          expect(
            tester.renderObject<RenderParagraph>(finder).didExceedMaxLines,
            isFalse,
            reason: label,
          );
        }
        expect(
          find.ancestor(
            of: find.text(strings.dashboardTitle),
            matching: find.byType(FittedBox),
          ),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
        await session.discard();
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  for (final brightness in Brightness.values) {
    final theme = brightness == Brightness.light
        ? ExpressiveThemeDefinition.light()
        : ExpressiveThemeDefinition.dark();

    testWidgets(
      'Expressive editor separates hidden widgets, preserves visible drag order and saves ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final config = await _pumpEmptyDashboard(tester, theme);
        final strings = AppLocalizations.of(
          tester.element(find.byType(DashboardPage)),
        );
        await tester.tap(findTonosTooltip(strings.dashboardCustomize));
        await tester.pumpAndSettle();

        final tileFinder = find.byKey(const ValueKey('quickActions'));
        final toggle = find.byKey(
          const ValueKey('dashboard-visibility-quickActions'),
        );
        final details = dashboardSectionDetails(strings, 'quickActions');
        BoxDecoration decoration() =>
            tester.widget<Container>(tileFinder).decoration! as BoxDecoration;
        expect(config.isVisible('quickActions'), isFalse);
        expect(find.text(strings.dashboardVisibleWidgets), findsOneWidget);
        expect(find.text(strings.dashboardHiddenWidgets), findsOneWidget);
        expect(
          tester
              .widget<ReorderableListView>(find.byType(ReorderableListView))
              .itemCount,
          0,
          reason: 'Hidden widgets belong below the reorderable visible list.',
        );
        expect(
          find.byKey(const ValueKey('dashboard-reorder-quickActions')),
          findsNothing,
        );
        final canvas = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.dashboard,
          brightness,
        ).pageCanvas;
        expect(
          decoration().color,
          Color.lerp(
            Color.alphaBlend(theme.surfaceTokens.dashboardEditor, canvas),
            canvas,
            0.32,
          ),
        );
        expect(
          decoration().border!.top.color,
          details.color.withValues(alpha: 0.28),
        );
        expect(
          tester.widget<IconButton>(toggle).tooltip,
          strings.dashboardShowWidget(details.title),
        );
        expect(tester.getSize(toggle).width, greaterThanOrEqualTo(48));
        expect(tester.getSize(toggle).height, greaterThanOrEqualTo(48));
        final addIcon = find.descendant(
          of: toggle,
          matching: find.byIcon(Icons.add_rounded),
        );
        expect(
          tester.widget<Icon>(addIcon).color,
          theme.colorScheme.onSecondaryContainer,
        );

        await _scrollEditorTo(tester, toggle);
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expect(config.isVisible('quickActions'), isTrue);
        expect(config.widgetOrder, DashboardConfig.defaultOrder);
        await _scrollEditorTo(tester, toggle);
        expect(
          tester
              .widget<ReorderableListView>(find.byType(ReorderableListView))
              .itemCount,
          1,
        );
        expect(decoration().color, theme.surfaceTokens.dashboardEditor);
        expect(
          decoration().border!.top.color,
          details.color.withValues(alpha: 0.48),
        );
        expect(
          tester.widget<IconButton>(toggle).tooltip,
          strings.dashboardHideWidget(details.title),
        );
        final redEye = find.descendant(
          of: toggle,
          matching: find.byIcon(Icons.visibility_off_outlined),
        );
        expect(tester.widget<Icon>(redEye).color, theme.colorScheme.error);
        final prefs = await SharedPreferences.getInstance();
        expect(
          (jsonDecode(prefs.getString('dashboard_config')!) as Map)['hidden'],
          isNot(contains('quickActions')),
        );

        await tester.tap(toggle);
        await tester.pumpAndSettle();
        for (final id in ['quickActions', 'training', 'nutritionDash']) {
          await config.toggleVisibility(id);
        }
        await tester.pumpAndSettle();
        final handle = find.byKey(
          const ValueKey('dashboard-reorder-quickActions'),
        );
        await _scrollEditorTo(tester, handle);
        expect(tester.getSize(handle), const Size(56, 56));
        expect(
          tester
              .widget<Icon>(
                find.descendant(
                  of: handle,
                  matching: find.byIcon(Icons.drag_indicator_rounded),
                ),
              )
              .color,
          theme.colorScheme.onSurfaceVariant,
        );
        final dropPosition = tester.getCenter(
          find.byKey(const ValueKey('nutritionDash')),
        );
        final gesture = await tester.startGesture(
          tester.getTopLeft(handle) + const Offset(5, 28),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump();
        await gesture.moveBy(const Offset(0, 20));
        await tester.pump();
        await gesture.moveTo(dropPosition);
        await tester.pump(const Duration(milliseconds: 350));
        expect(
          find.byKey(const ValueKey('dashboard-drag-proxy')),
          findsOneWidget,
        );
        await gesture.up();
        await tester.pumpAndSettle();
        expect(config.widgetOrder.take(2), ['training', 'quickActions']);
        expect(config.isVisible('targetAnatomy'), isFalse);
        for (final id in ['quickActions', 'training', 'nutritionDash']) {
          await config.toggleVisibility(id);
        }
        await tester.pumpAndSettle();
        expect(
          config.widgetOrder.every((id) => !config.isVisible(id)),
          isTrue,
          reason: 'Dragging hidden widgets must not toggle visibility.',
        );

        final done = findTonosTooltip(strings.dashboardDoneCustomizing);
        await _scrollEditorTo(tester, done);
        expect(tester.getSize(done).width, greaterThanOrEqualTo(48));
        expect(tester.getSize(done).height, greaterThanOrEqualTo(48));
        final heroTitle = tester.widget<Text>(
          find.text(strings.dashboardCustomize),
        );
        expect(
          heroTitle.style?.fontSize,
          Theme.of(tester.element(find.byType(DashboardHero)))
              .textTheme
              .titleLarge
              ?.fontSize,
        );
        expect(heroTitle.style?.fontWeight, FontWeight.w800);
        await tester.tap(done);
        await tester.pumpAndSettle();
        expect(find.byType(ReorderableListView), findsNothing);
        expect(find.text(strings.dashboardEmptyTitle), findsOneWidget);
        final restored = DashboardConfig();
        addTearDown(restored.dispose);
        await tester.pumpAndSettle();
        expect(restored.widgetOrder, config.widgetOrder);
        expect(
          restored.widgetOrder.every((id) => !restored.isVisible(id)),
          isTrue,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      'Expressive editor keeps the final controls reachable at 320dp and 2x ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final config = await _pumpEmptyDashboard(
          tester,
          theme,
          textScale: 2,
          withBottomNavigation: true,
        );
        final semantics = tester.ensureSemantics();
        final strings = AppLocalizations.of(
          tester.element(find.byType(DashboardPage)),
        );
        await tester.tap(findTonosTooltip(strings.dashboardCustomize));
        await tester.pumpAndSettle();
        final lastToggle = find.byKey(
          const ValueKey('dashboard-visibility-targetAnatomy'),
        );
        await tester.scrollUntilVisible(
          lastToggle,
          300,
          scrollable: find
              .descendant(
                of: find.byType(ReorderableListView),
                matching: find.byType(Scrollable),
              )
              .first,
          maxScrolls: 80,
        );
        await Scrollable.ensureVisible(
          tester.element(lastToggle),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        final lastHandle = find.byKey(
          const ValueKey('dashboard-reorder-targetAnatomy'),
        );
        expect(lastHandle, findsNothing);
        final navigationTop = tester
            .getTopLeft(find.byKey(const ValueKey('dashboard-test-navigation')))
            .dy;
        for (final control in [lastToggle]) {
          final rect = tester.getRect(control);
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.bottom, lessThanOrEqualTo(navigationTop));
          expect(rect.width, greaterThanOrEqualTo(48));
          expect(rect.height, greaterThanOrEqualTo(48));
        }
        expect(
          tester.getSemantics(lastToggle).label,
          contains(strings.dashboardSectionAnatomyTitle),
        );
        final description = find.text(strings.dashboardSectionAnatomyBody);
        expect(tester.widget<Text>(description).maxLines, isNull);
        expect(
          tester.renderObject<RenderParagraph>(description).didExceedMaxLines,
          isFalse,
        );
        await tester.tap(lastToggle);
        await tester.pumpAndSettle();
        expect(config.isVisible('targetAnatomy'), isTrue);
        expect(config.isVisible('exerciseCatalog'), isFalse);
        await _scrollEditorTo(tester, lastToggle);
        expect(lastHandle, findsOneWidget);
        await tester.tap(lastToggle);
        await tester.pumpAndSettle();
        final footerDone = find.byKey(const ValueKey('dashboard-editor-done'));
        await _scrollEditorTo(tester, footerDone);
        expect(find.text(strings.dashboardAutosave), findsOneWidget);
        expect(find.text(strings.dashboardShowHiddenSections), findsNothing);
        expect(
          find.text(strings.dashboardHiddenWidgetSummary(16)),
          findsOneWidget,
        );
        expect(tester.getSize(footerDone).height, greaterThanOrEqualTo(48));
        await tester.tap(footerDone);
        await tester.pumpAndSettle();
        expect(find.byType(ReorderableListView), findsNothing);
        expect(find.text(strings.dashboardEmptyTitle), findsOneWidget);
        expect(tester.takeException(), isNull);
        semantics.dispose();
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      'Expressive restore confirmation protects layout and fits 320dp at 2x ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final config = await _pumpEmptyDashboard(tester, theme, textScale: 2);
        final strings = AppLocalizations.of(
          tester.element(find.byType(DashboardPage)),
        );
        await tester.tap(findTonosTooltip(strings.dashboardCustomize));
        await tester.pumpAndSettle();
        await config.toggleVisibility('quickActions');
        await config.reorder(0, 2, includeHidden: true);
        await tester.pumpAndSettle();
        final prefs = await SharedPreferences.getInstance();
        final saved = prefs.getString('dashboard_config');
        final order = config.widgetOrder;
        final restore = find.byKey(
          const ValueKey('dashboard-restore-defaults'),
        );
        await _scrollEditorTo(tester, restore);
        await tester.tap(restore);
        await tester.pumpAndSettle();
        final dialog = find.byKey(
          const ValueKey('dashboard-restore-confirmation'),
        );
        expect(dialog, findsOneWidget);
        final destination = Theme.of(tester.element(dialog))
            .extension<AppExpressiveDestinationTokens>()!;
        expect(
          Theme.of(tester.element(dialog)).dialogTheme.backgroundColor,
          destination.surfaceTertiary,
        );
        final cancel = find.text(strings.commonCancel);
        await tester.ensureVisible(cancel);
        await tester.tap(cancel);
        await tester.pumpAndSettle();
        expect(config.widgetOrder, order);
        expect(config.isVisible('quickActions'), isTrue);
        expect(prefs.getString('dashboard_config'), saved);

        await tester.tap(restore);
        await tester.pumpAndSettle();
        final confirm = find.byKey(const ValueKey('dashboard-confirm-restore'));
        await tester.ensureVisible(confirm);
        expect(tester.getSize(confirm).height, greaterThanOrEqualTo(48));
        await tester.tap(confirm);
        await tester.pumpAndSettle();
        expect(dialog, findsNothing);
        expect(find.byType(ReorderableListView), findsOneWidget);
        expect(config.widgetOrder, DashboardConfig.defaultOrder);
        for (final id in config.widgetOrder) {
          expect(
            config.isVisible(id),
            !DashboardConfig.defaultHiddenWidgets.contains(id),
            reason: id,
          );
        }
        final restored = DashboardConfig();
        addTearDown(restored.dispose);
        await tester.pumpAndSettle();
        expect(restored.widgetOrder, DashboardConfig.defaultOrder);
        expect(restored.isVisible('quickActions'), isTrue);
        expect(restored.isVisible('targetAnatomy'), isFalse);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  test(
    'Dashboard editor copy supports singular, plural and localized actions',
    () async {
      for (final locale in AppLocalizations.supportedLocales) {
        final strings = await AppLocalizations.delegate.load(locale);
        for (final count in [0, 1, 7]) {
          expect(strings.dashboardHiddenWidgetSummary(count), isNotEmpty);
          expect(
            strings.dashboardHiddenWidgetSummary(count),
            isNot(contains('(s)')),
          );
        }
        expect(
          strings.dashboardShowWidget('Test widget'),
          contains('Test widget'),
        );
        expect(
          strings.dashboardHideWidget('Test widget'),
          contains('Test widget'),
        );
      }
      final english = await AppLocalizations.delegate.load(const Locale('en'));
      expect(english.dashboardHiddenWidgetSummary(0), 'All widgets are shown');
      expect(english.dashboardHiddenWidgetSummary(1), '1 hidden widget');
      expect(english.dashboardHiddenWidgetSummary(7), '7 hidden widgets');
    },
  );

  testWidgets('Expressive editor saves changes even when leaving before Done', (
    tester,
  ) async {
    final config = await _pumpEmptyDashboard(
      tester,
      ExpressiveThemeDefinition.light(),
    );
    final strings = AppLocalizations.of(
      tester.element(find.byType(DashboardPage)),
    );
    await tester.tap(findTonosTooltip(strings.dashboardCustomize));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('dashboard-visibility-quickActions')),
    );
    await tester.pumpAndSettle();
    await config.reorder(0, 2, includeHidden: true);
    await tester.pumpWidget(const SizedBox.shrink());
    final restored = DashboardConfig();
    addTearDown(restored.dispose);
    await tester.pumpAndSettle();
    expect(restored.widgetOrder, config.widgetOrder);
    expect(restored.isVisible('quickActions'), isTrue);
    expect(restored.isVisible('training'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Expressive Dashboard stacks only compact actions and caps wide content',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4E2868)),
        extensions: const [
          AppThemeIdentity(family: AppThemeFamilyIdentity.expressivePreview),
        ],
      );
      late ActiveSession session;

      tester.view.physicalSize = const Size(320, 820);
      await _pumpEmptyDashboard(
        tester,
        theme,
        textScale: 2,
        showResumeAction: true,
        onSessionReady: (value) => session = value,
      );
      final compactActions = find.byType(DashboardQuickActions);
      expect(compactActions, findsOneWidget);
      expect(
        find.descendant(of: compactActions, matching: find.byType(Row)),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      await session.discard();

      tester.view.physicalSize = const Size(390, 844);
      await _pumpEmptyDashboard(
        tester,
        theme,
        textScale: 1,
        showResumeAction: true,
        onSessionReady: (value) => session = value,
      );
      final standardActions = find.byType(DashboardQuickActions);
      expect(standardActions, findsOneWidget);
      expect(
        find.descendant(of: standardActions, matching: find.byType(Row)),
        findsOneWidget,
      );
      expect(
        tester
            .getRect(find.byKey(const PageStorageKey('dashboard_scroll')))
            .width,
        390,
      );
      expect(tester.takeException(), isNull);
      await session.discard();

      tester.view.physicalSize = const Size(1440, 900);
      await _pumpEmptyDashboard(
        tester,
        theme,
        textScale: 1,
        showResumeAction: true,
        onSessionReady: (value) => session = value,
      );
      expect(
        tester
            .getRect(find.byKey(const PageStorageKey('dashboard_scroll')))
            .width,
        960,
      );
      final pageContext = tester.element(find.byType(DashboardPage));
      final strings = AppLocalizations.of(pageContext);
      await tester.tap(find.byTooltip(strings.dashboardCustomize));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(ReorderableListView)).width, 960);
      expect(tester.takeException(), isNull);
      await session.discard();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? AppThemeFactory.light(family)
          : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode dashboard empty state resolves its surface recipe', (
        tester,
      ) async {
        await _pumpEmptyDashboard(tester, theme);

        final pageContext = tester.element(find.byType(DashboardPage));
        final strings = AppLocalizations.of(pageContext);
        final surface = theme.surfaceTokens.dashboardSection;
        final shape = theme.shapeTokens.dashboardSection;
        final emptyCard = tester.widget<Container>(
          find.byWidgetPredicate((widget) {
            if (widget is! Container ||
                widget.padding != const EdgeInsets.all(24)) {
              return false;
            }
            final decoration = widget.decoration;
            return decoration is BoxDecoration &&
                decoration.color == surface &&
                decoration.borderRadius == shape;
          }),
        );
        final emptyDecoration = emptyCard.decoration! as BoxDecoration;

        expect(
          emptyDecoration.border!.top.color,
          theme.colorScheme.outlineVariant,
        );
        expect(emptyDecoration.border!.top.width, 1);
        expect(find.text(strings.dashboardEmptyTitle), findsOneWidget);
        expect(find.text(strings.dashboardCustomize), findsOneWidget);
        expect(
          tester
              .renderObject<RenderParagraph>(
                find.text(strings.dashboardEmptyBody),
              )
              .text
              .style
              ?.color,
          theme.colorScheme.onSurfaceVariant,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });

      testWidgets('$mode dashboard editor resolves recipes and interactions', (
        tester,
      ) async {
        final config = await _pumpEmptyDashboard(tester, theme);
        final pageContext = tester.element(find.byType(DashboardPage));
        final strings = AppLocalizations.of(pageContext);

        expect(dashboardHeroAccent, const Color(0xFF64B5F6));
        expect(dashboardMeasurementActionAccent, const Color(0xFF4DB6AC));
        expect(dashboardTrainingActionAccent, const Color(0xFF81C784));

        await tester.tap(find.text(strings.dashboardCustomize));
        await tester.pumpAndSettle();

        final footer = tester.widget<Container>(
          find.byWidgetPredicate((widget) {
            if (widget is! Container) return false;
            final decoration = widget.decoration;
            return decoration is BoxDecoration &&
                decoration.color == theme.surfaceTokens.dashboardSection &&
                decoration.borderRadius == theme.shapeTokens.dashboardFooter;
          }),
        );
        final footerDecoration = footer.decoration! as BoxDecoration;
        expect(
          footerDecoration.border!.top.color,
          theme.colorScheme.outlineVariant,
        );
        expect(footerDecoration.border!.top.width, 1);
        expect(find.byType(ReorderableListView), findsOneWidget);
        expect(find.text(strings.dashboardReorderHelp), findsOneWidget);

        final addHiddenButton = find.text(strings.dashboardShowHiddenSections);
        await tester.ensureVisible(addHiddenButton);
        await tester.tap(addHiddenButton);
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.dashboardSectionQuickActionsTitle));
        await tester.pumpAndSettle();

        final tileFinder = find.byKey(const ValueKey('quickActions'));
        final tile = tester.widget<Container>(tileFinder);
        final tileDecoration = tile.decoration! as BoxDecoration;
        final details = dashboardSectionDetails(strings, 'quickActions');
        expect(details.color, const Color(0xFF64B5F6));
        const sectionColors = <String, Color>{
          'quickActions': Color(0xFF64B5F6),
          'training': Color(0xFF81C784),
          'nutritionDash': Color(0xFFFFB74D),
          'dataRecords': Color(0xFF64B5F6),
          'weeklyFocus': Color(0xFF4DB6AC),
          'workoutMetrics': Color(0xFF64B5F6),
          'exerciseProgress': Color(0xFFCE93D8),
          'historySummary': Color(0xFF64B5F6),
          'healthTrends': Color(0xFF81C784),
          'recentWorkouts': Color(0xFFFFB74D),
          'activePlans': Color(0xFF81C784),
          'archivedPlans': Color(0xFF90A4AE),
          'premadePlans': Color(0xFFCE93D8),
          'planTools': Color(0xFFCE93D8),
          'exerciseCatalog': Color(0xFF64B5F6),
          'targetAnatomy': Color(0xFFBA68C8),
        };
        for (final entry in sectionColors.entries) {
          expect(
            dashboardSectionDetails(strings, entry.key).color,
            entry.value,
            reason: 'The ${entry.key} category color stays theme-independent.',
          );
        }
        expect(tileDecoration.color, theme.surfaceTokens.dashboardEditor);
        expect(tileDecoration.borderRadius, theme.shapeTokens.dashboardEditor);
        expect(
          tileDecoration.border!.top.color,
          details.color.withValues(alpha: 0.48),
        );
        expect(tileDecoration.border!.top.width, 1);

        final iconContainer = tester.widget<Container>(
          find.descendant(
            of: tileFinder,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.constraints ==
                      const BoxConstraints.tightFor(width: 38, height: 38),
            ),
          ),
        );
        final iconDecoration = iconContainer.decoration! as BoxDecoration;
        expect(iconDecoration.color, details.color.withValues(alpha: 0.16));
        expect(
          iconDecoration.borderRadius,
          const BorderRadius.all(Radius.circular(12)),
        );
        expect(
          tester
              .widget<Icon>(
                find.descendant(
                  of: tileFinder,
                  matching: find.byIcon(Icons.drag_indicator_rounded),
                ),
              )
              .color,
          theme.colorScheme.onSurfaceVariant,
        );

        final titleFinder = find.text(details.title);
        final title = tester.widget<Text>(titleFinder);
        expect(title.style?.fontWeight, FontWeight.w800);
        expect(title.style?.color, theme.textTheme.titleSmall?.color);
        final descriptionFinder = find.text(details.description);
        expect(
          tester.widget<Text>(descriptionFinder).style?.color,
          theme.colorScheme.onSurfaceVariant,
        );

        final hideButton = findTonosTooltip(strings.dashboardHideSection);
        await tester.ensureVisible(hideButton);
        final hideIconFinder = find.descendant(
          of: tileFinder,
          matching: find.byIcon(Icons.visibility_off_outlined),
        );
        expect(
          tester.widget<Icon>(hideIconFinder).color,
          theme.colorScheme.error,
        );
        await tester.tap(hideButton);
        await tester.pumpAndSettle();
        expect(config.isVisible('quickActions'), isFalse);

        final resetButton = find.text(strings.dashboardReset);
        await tester.ensureVisible(resetButton);
        await tester.tap(resetButton);
        await tester.pumpAndSettle();
        expect(config.isVisible('quickActions'), isTrue);
        expect(config.isVisible('activePlans'), isFalse);

        final editorList = tester.widget<ReorderableListView>(
          find.byType(ReorderableListView),
        );
        editorList.onReorderItem!(0, 1);
        await tester.pumpAndSettle();
        expect(config.widgetOrder.where(config.isVisible).take(2), [
          'training',
          'quickActions',
        ]);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}

Future<void> _scrollEditorTo(WidgetTester tester, Finder target) async {
  final scrollable = find
      .descendant(
        of: find.byType(ReorderableListView),
        matching: find.byType(Scrollable),
      )
      .first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    target,
    300,
    scrollable: scrollable,
    maxScrolls: 80,
  );
  await tester.pumpAndSettle();
}

Future<DashboardConfig> _pumpEmptyDashboard(
  WidgetTester tester,
  ThemeData theme, {
  double textScale = 1,
  bool showResumeAction = false,
  bool withBottomNavigation = false,
  void Function(ActiveSession)? onSessionReady,
}) async {
  final hiddenOrder = DashboardConfig.defaultOrder
      .where((id) => !showResumeAction || id != 'quickActions')
      .toList();
  SharedPreferences.setMockInitialValues(<String, Object>{
    'dashboard_config': jsonEncode(<String, Object>{
      'order': DashboardConfig.defaultOrder,
      'hidden': hiddenOrder,
    }),
  });
  final config = DashboardConfig();
  final repository = _EmptyDashboardRepository();
  final session = ActiveSession(
    repository: repository,
    retryDelay: (_) async {},
  );
  addTearDown(config.dispose);
  addTearDown(session.dispose);
  onSessionReady?.call(session);
  await session.ready;
  if (showResumeAction) await session.start();

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<DashboardConfig>.value(value: config),
          ChangeNotifierProvider<ActiveSession>.value(value: session),
          Provider<AppRepository>.value(value: repository),
        ],
        child: MaterialApp(
          theme: theme,
          themeAnimationDuration: Duration.zero,
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: withBottomNavigation
              ? const Scaffold(
                  body: DashboardPage(),
                  bottomNavigationBar: SizedBox(
                    key: ValueKey('dashboard-test-navigation'),
                    height: 80,
                  ),
                )
              : const DashboardPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return config;
}

class _EmptyDashboardRepository extends AppRepository {
  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];

  @override
  Future<void> saveActiveWorkoutDraft({
    required DateTime startedAt,
    required int? autoPresetId,
    required String payloadJson,
  }) async {}

  @override
  Future<void> clearActiveWorkoutDraft() async {}
}
