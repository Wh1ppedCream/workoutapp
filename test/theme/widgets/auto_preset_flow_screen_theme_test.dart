import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_support.dart';

import 'package:provider/provider.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/preset_models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/auto_preset_flow_screen.dart';
import 'package:env_test/screens/exercise/flow_editor_expressive_widgets.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/expressive_planning_tokens.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_flow_tokens.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';
import 'package:env_test/theme/widgets/tonos_dialog.dart';
import 'package:env_test/theme/widgets/tonos_field.dart';
import 'package:env_test/widgets/flow_screen_widgets.dart';

import '../../../tools/theme_style_inventory.dart';

void main() {
  testWidgets(
    'Expressive flow choice menu selects and dismisses when tapped outside',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var selected = 'First node';
      await tester.pumpWidget(
        MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 320,
                    child: FlowEditorAnchoredChoiceField<String>(
                      title: 'Branch From',
                      values: const ['First node', 'Second node', 'Third node'],
                      value: selected,
                      label: (value) => value,
                      decoration: const InputDecoration(
                        labelText: 'Branch From',
                        prefixIcon: Icon(Icons.account_tree_outlined),
                      ),
                      textStyle: null,
                      onChanged: (value) => setState(() => selected = value!),
                    ),
                  ),
                  const SizedBox(height: 400),
                  const Text('Outside menu'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final field = find.byType(FlowEditorAnchoredChoiceField<String>);
      await tester.tap(field);
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton), findsNWidgets(3));
      expect(find.byType(TonosChoiceDialog<String>), findsNothing);
      final fieldRect = tester.getRect(field);
      final firstOptionRect = tester.getRect(find.byType(MenuItemButton).first);
      expect(firstOptionRect.left, closeTo(fieldRect.left + 6, 12));
      expect(firstOptionRect.top, greaterThanOrEqualTo(fieldRect.bottom - 1));

      await tester.tap(find.text('Second node'));
      await tester.pumpAndSettle();
      expect(selected, 'Second node');
      expect(find.byType(MenuItemButton), findsNothing);
      expect(find.text('Second node'), findsOneWidget);

      await tester.tap(field);
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton), findsNWidgets(3));
      await tester.tap(find.text('Outside menu'));
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton), findsNothing);

      await tester.tap(field);
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton), findsNWidgets(3));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Expressive manage-actions list sizes to its available options', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var addPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: ExpressiveThemeDefinition.light(),
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: FlowEditorManageActionsList(
              methods: const [],
              typeLabel: (_) => '',
              onDelete: (_) {},
              onAdd: () => addPressed = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final list = find.byType(FlowEditorManageActionsList);
    expect(tester.getSize(list).height, lessThan(100));
    expect(
      find.text(AppLocalizations.of(tester.element(list)).flowAddNewMethod),
      findsOneWidget,
    );
    await tester.tap(
      find.text(AppLocalizations.of(tester.element(list)).flowAddNewMethod),
    );
    expect(addPressed, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive flow-card outline stays above clipped expansion in ${brightness.name} mode',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: _FlowThemeRepository(),
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const AutoPresetFlowScreen.appDefaults(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pageContext = tester.element(find.byType(AutoPresetFlowScreen));
        final strings = AppLocalizations.of(pageContext);
        final tokens = AppExpressivePlanningTokens.maybeOf(pageContext)!;
        final title = find.text(strings.flowAddBranchTitle);
        final tile = find.ancestor(
          of: title,
          matching: find.byType(ExpansionTile),
        );
        _expectFlowOutlineAboveTile(
          tester,
          tile,
          radius: tokens.supportShape,
          color: tokens.outline,
        );
        expect(
          find.widgetWithText(FilledButton, strings.flowSuccess),
          findsNothing,
        );

        await tester.tap(title);
        await tester.pumpAndSettle();
        _expectFlowOutlineAboveTile(
          tester,
          tile,
          radius: tokens.supportShape,
          color: tokens.outline,
        );
        expect(
          find.widgetWithText(FilledButton, strings.flowSuccess),
          findsOneWidget,
        );

        await tester.tap(title);
        await tester.pumpAndSettle();
        _expectFlowOutlineAboveTile(
          tester,
          tile,
          radius: tokens.supportShape,
          color: tokens.outline,
        );
        expect(
          find.widgetWithText(FilledButton, strings.flowSuccess),
          findsNothing,
        );
      },
    );
  }

  test('Expressive flow recipes use chromatic, readable surfaces', () {
    final light = AppFlowTokens.expressive(Brightness.light);
    final dark = AppFlowTokens.expressive(Brightness.dark);

    expect(light.canvas, isNot(const Color(0xFFFFFFFF)));
    expect(dark.canvas, isNot(const Color(0xFF000000)));
    expect(light.nodeText.computeLuminance(), lessThan(0.05));
    expect(dark.nodeText.computeLuminance(), greaterThan(0.7));
    expect(light.nodeBackground, isNot(light.canvas));
    expect(dark.nodeBackground, isNot(dark.canvas));
    expect(light.success, isNot(light.failure));
    expect(dark.success, isNot(dark.failure));
    expect(
      ExpressiveThemeDefinition.light().extension<AppFlowTokens>()?.canvas,
      light.canvas,
    );
    expect(
      ExpressiveThemeDefinition.dark().extension<AppFlowTokens>()?.canvas,
      dark.canvas,
    );

    expect(
      AppFlowTokens.classic(Brightness.light).canvas,
      const Color(0xFFFFFFFF),
    );
    expect(
      AppFlowTokens.classic(Brightness.dark).canvas,
      const Color(0xFF121212),
    );
  });

  testWidgets(
    'Expressive Auto Preset Flow uses planning surfaces and insets its graph',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final theme = ExpressiveThemeDefinition.light();

      await tester.pumpWidget(
        Provider<AppRepository>.value(
          value: _FlowThemeRepository(),
          child: MaterialApp(
            theme: theme,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AutoPresetFlowScreen.appDefaults(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final pageContext = tester.element(find.byType(AutoPresetFlowScreen));
      final planning = AppExpressivePlanningTokens.maybeOf(pageContext)!;
      final flow = pageContext.flowTokens;
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(flow.canvas, AppFlowTokens.expressive(Brightness.light).canvas);
      expect(scaffold.backgroundColor, flow.canvas);
      final chart = tester.widget<FlowChartCanvas>(
        find.byType(FlowChartCanvas),
      );
      expect(chart.dashboard.gridBackgroundParams.backgroundColor, flow.canvas);
      expect(
        tester.getTopLeft(find.byType(FlowChartCanvas)).dx,
        greaterThanOrEqualTo(24),
      );
      expect(
        chart.dashboard.elements,
        everyElement(
          isA<FlowElement>()
              .having(
                (element) => element.backgroundColor,
                'fill',
                flow.nodeBackground,
              )
              .having(
                (element) => element.borderColor,
                'border',
                flow.nodeBorder,
              )
              .having((element) => element.textColor, 'text', flow.nodeText),
        ),
      );
      expect(chart.dashboard.elements.first.position.dx, greaterThan(40));
      final strings = AppLocalizations.of(pageContext);
      expect(find.text(strings.flowAppDefaultSubtitle), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.header == true &&
              widget.properties.label ==
                  '${strings.flowAppDefaultTitle}. '
                      '${strings.flowAppDefaultSubtitle}',
        ),
        findsOneWidget,
      );

      final save = tester.widget<ButtonStyleButton>(
        _buttonWithText<ButtonStyleButton>(strings.commonSave),
      );
      expect(save.style?.backgroundColor?.resolve({}), planning.actionPrimary);
      expect(
        save.style?.foregroundColor?.resolve({}),
        planning.actionPrimaryForeground,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Expressive flow headers preserve each progression context', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final editors = <AutoPresetFlowScreen>[
      const AutoPresetFlowScreen.appDefaults(),
      AutoPresetFlowScreen.profileDefaults(
        profileId: 7,
        profileName: 'Home gym',
      ),
      AutoPresetFlowScreen(presetId: 12),
    ];

    for (final editor in editors) {
      await tester.pumpWidget(
        Provider<AppRepository>.value(
          value: _FlowThemeRepository(),
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: editor,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final pageContext = tester.element(find.byType(AutoPresetFlowScreen));
      final strings = AppLocalizations.of(pageContext);
      final titleFinder = find.text(editor.target.titleFor(strings));
      final subtitleFinder = find.text(editor.target.subtitleFor(strings));
      expect(titleFinder, findsOneWidget);
      expect(subtitleFinder, findsNothing);
      expect(tester.widget<Text>(titleFinder).maxLines, 2);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.header == true &&
              widget.properties.label ==
                  '${editor.target.titleFor(strings)}. '
                      '${editor.target.subtitleFor(strings)}',
        ),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(titleFinder).dy,
        lessThan(tester.getBottomRight(find.byTooltip(strings.commonBack)).dy),
      );
      expect(
        _buttonWithText<ButtonStyleButton>(strings.commonSave).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive flow editor selects nodes and actions in ${brightness.name} mode',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: _FlowThemeRepository(),
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const AutoPresetFlowScreen.appDefaults(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final strings = AppLocalizations.of(
          tester.element(find.byType(AutoPresetFlowScreen)),
        );
        await tester.ensureVisible(find.text(strings.flowAddBranchTitle));
        await tester.tap(find.text(strings.flowAddBranchTitle));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(strings.flowAttachActionTitle));
        await tester.tap(find.text(strings.flowAttachActionTitle));
        await tester.pumpAndSettle();
        expect(find.text(strings.flowBranchSelectGuidance), findsOneWidget);
        expect(find.text(strings.flowActionSelectNodeGuidance), findsOneWidget);
        expect(
          find.byType(FlowEditorAnchoredChoiceField<String>),
          findsNWidgets(2),
        );
        expect(
          find.byType(FlowEditorAnchoredChoiceField<FlowMethod>),
          findsOneWidget,
        );
        expect(find.byType(DropdownButtonFormField<String>), findsNothing);
        expect(find.byTooltip(strings.flowFitToViewTooltip), findsOneWidget);

        final cards = tester.widgetList<ExpansionTile>(
          find.byType(ExpansionTile),
        );
        final supportShape = AppExpressivePlanningTokens.maybeOf(
          tester.element(find.byType(AutoPresetFlowScreen)),
        )!.supportShape;
        expect(cards, everyElement(isA<ExpansionTile>()));
        for (final card in cards) {
          expect(
            card.shape,
            RoundedRectangleBorder(borderRadius: supportShape),
          );
          expect(
            card.collapsedShape,
            RoundedRectangleBorder(borderRadius: supportShape),
          );
          expect((card.subtitle! as Text).maxLines, 2);
          expect((card.subtitle! as Text).overflow, isNull);
        }

        final graph = tester.widget<FlowChartCanvas>(
          find.byType(FlowChartCanvas),
        );
        expect(graph.dashboard.zoomFactor, lessThanOrEqualTo(1.12));
        await tester.tap(find.byTooltip(strings.flowFitToViewTooltip));
        await tester.pumpAndSettle();

        final branchFromField = find
            .byType(FlowEditorAnchoredChoiceField<String>)
            .first;
        await tester.ensureVisible(branchFromField);
        await tester.tap(branchFromField);
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton), findsWidgets);
        expect(find.byType(TonosChoiceDialog<String>), findsNothing);
        await tester.tap(
          find.widgetWithText(MenuItemButton, 'success1').hitTestable(),
        );
        await tester.pumpAndSettle();
        final flow = tester
            .element(find.byType(AutoPresetFlowScreen))
            .flowTokens;
        final parentElement = graph.dashboard.elements.singleWhere(
          (element) => element.text == 'success1',
        );
        expect(parentElement.borderColor, flow.action);
        final successButton = _buttonWithText<FilledButton>(
          strings.flowSuccess,
        );
        expect(tester.widget<FilledButton>(successButton).onPressed, isNotNull);
        await tester.tap(successButton);
        await tester.pumpAndSettle();
        final missButton = _buttonWithText<FilledButton>(strings.flowMiss);
        expect(tester.widget<FilledButton>(missButton).onPressed, isNotNull);
        await tester.tap(missButton);
        await tester.pumpAndSettle();
        expect(graph.dashboard.elements, hasLength(4));
        final addedBranch = graph.dashboard.elements.singleWhere(
          (element) => element.text == 'success2',
        );
        final addedMiss = graph.dashboard.elements.singleWhere(
          (element) => element.text == 'fail1',
        );
        final addedBranchCenter = addedBranch.getHandlerPosition(
          Alignment.center,
        );
        final parentCenterAfterAdd = parentElement.getHandlerPosition(
          Alignment.center,
        );
        expect(addedBranchCenter.dx, closeTo(parentCenterAfterAdd.dx, 0.01));
        expect(
          addedBranchCenter.dy - parentCenterAfterAdd.dy,
          closeTo(200 * graph.dashboard.zoomFactor, 0.01),
        );
        final branchTargets = parentElement.next
            .map(
              (connection) => graph.dashboard.elements
                  .singleWhere(
                    (element) => element.id == connection.destElementId,
                  )
                  .text,
            )
            .toSet();
        expect(branchTargets, contains(addedBranch.text));
        expect(branchTargets, contains(addedMiss.text));
        expect(tester.widget<FilledButton>(successButton).onPressed, isNull);
        expect(tester.widget<FilledButton>(missButton).onPressed, isNull);

        await tester.tap(
          find.byType(FlowEditorAnchoredChoiceField<String>).last,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('success1').first);
        await tester.pumpAndSettle();
        await tester.tap(
          find.byType(FlowEditorAnchoredChoiceField<FlowMethod>),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton), findsWidgets);
        expect(find.byType(TonosChoiceDialog<FlowMethod>), findsNothing);
        await tester.tap(find.text('Scale Load').first);
        await tester.pumpAndSettle();
        final addActionButton = _buttonWithText<FilledButton>(
          strings.flowAddAction,
        );
        await tester.ensureVisible(addActionButton);
        await tester.pumpAndSettle();
        await tester.tap(addActionButton);
        await tester.pumpAndSettle();
        expect(
          graph.dashboard.elements.any(
            (element) => element.text.contains('Scale Load'),
          ),
          isTrue,
        );
        final removeActionButton = _buttonWithText<OutlinedButton>(
          strings.flowRemoveAction,
        );
        expect(
          tester.widget<OutlinedButton>(removeActionButton).onPressed,
          isNotNull,
        );
        await tester.ensureVisible(removeActionButton);
        await tester.pumpAndSettle();
        await tester.tap(removeActionButton);
        await tester.pumpAndSettle();
        expect(
          graph.dashboard.elements
              .singleWhere((element) => element.text == 'success1')
              .text,
          isNot(contains('Scale Load')),
        );

        final methodTargetsField = find
            .byType(FlowEditorAnchoredChoiceField<String>)
            .last;
        await tester.ensureVisible(methodTargetsField);
        await tester.tap(methodTargetsField);
        await tester.pumpAndSettle();
        await tester.tap(find.text('fail1').first);
        await tester.pumpAndSettle();
        final removeNodeButton = _buttonWithText<OutlinedButton>(
          strings.flowRemoveNode,
        );
        expect(
          tester.widget<OutlinedButton>(removeNodeButton).onPressed,
          isNotNull,
        );
        await tester.ensureVisible(removeNodeButton);
        await tester.tap(removeNodeButton);
        await tester.pumpAndSettle();
        expect(
          graph.dashboard.elements.any((element) => element.text == 'fail1'),
          isFalse,
        );

        final controlsViewport = find.byKey(
          const PageStorageKey('expressive-flow-editor-controls'),
        );
        await tester.drag(controlsViewport, const Offset(0, -1200));
        await tester.pumpAndSettle();
        final lastPanel = find.ancestor(
          of: find.text(strings.flowAttachActionTitle),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is CustomPaint &&
                widget.foregroundPainter is FlowControlOutlinePainter,
          ),
        );
        expect(lastPanel, findsOneWidget);
        expect(
          tester.getRect(lastPanel).bottom,
          lessThanOrEqualTo(tester.getRect(controlsViewport).bottom),
        );
        await tester.ensureVisible(addActionButton);
        await tester.pumpAndSettle();
        expect(
          tester.getRect(addActionButton).bottom,
          lessThanOrEqualTo(tester.getRect(controlsViewport).bottom),
        );

        await tester.ensureVisible(find.text(strings.flowAddBranchTitle));
        await tester.tap(find.text(strings.flowAddBranchTitle));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(strings.flowAttachActionTitle));
        await tester.tap(find.text(strings.flowAttachActionTitle));
        await tester.pumpAndSettle();
        final chartRect = tester.getRect(find.byType(FlowChartCanvas));
        expect(chartRect.height, greaterThan(100));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Expressive manage-actions dialog preserves the graph viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      Provider<AppRepository>.value(
        value: _FlowManyMethodsRepository(),
        child: MaterialApp(
          theme: ExpressiveThemeDefinition.dark(),
          themeAnimationDuration: Duration.zero,
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AutoPresetFlowScreen.appDefaults(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final strings = AppLocalizations.of(
      tester.element(find.byType(AutoPresetFlowScreen)),
    );
    final dashboard = tester
        .widget<FlowChartCanvas>(find.byType(FlowChartCanvas))
        .dashboard;
    dashboard.setZoomFactor(0.82);
    final positionBefore = dashboard.elements.first.position;

    await tester.tap(find.byTooltip(strings.flowManageActionsTooltip));
    await tester.pumpAndSettle();
    final dialog = find.byType(AlertDialog);
    final dialogMaterials = find.descendant(
      of: dialog,
      matching: find.byType(Material),
    );
    expect(dialogMaterials, findsWidgets);
    expect(tester.getRect(dialogMaterials.first).height, lessThan(844 * 0.9));
    expect(find.byType(FlowEditorManageActionsList), findsOneWidget);
    expect(
      tester.widget<FlowChartCanvas>(find.byType(FlowChartCanvas)).dashboard,
      same(dashboard),
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(dashboard.zoomFactor, 0.82);
    expect(dashboard.elements.first.position, positionBefore);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Expressive flow workspace stays usable at compact large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      Provider<AppRepository>.value(
        value: _FlowThemeRepository(),
        child: MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          themeAnimationDuration: Duration.zero,
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const AutoPresetFlowScreen.appDefaults(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final strings = AppLocalizations.of(
      tester.element(find.byType(AutoPresetFlowScreen)),
    );
    await tester.ensureVisible(find.text(strings.flowAddBranchTitle));
    await tester.tap(find.text(strings.flowAddBranchTitle));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(strings.flowAttachActionTitle));
    await tester.tap(find.text(strings.flowAttachActionTitle));
    await tester.pumpAndSettle();
    final chartRect = tester.getRect(find.byType(FlowChartCanvas));
    expect(chartRect.width, greaterThan(100));
    expect(chartRect.height, greaterThan(100));
    expect(tester.takeException(), isNull);
  });

  test('Auto Preset Flow style ownership is exact and kind-limited', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'auto-preset-flow-control-recipes',
    );
    const kindCounts = <String, int>{
      'color_transform': 16,
      'decoration': 4,
      // The Expressive card paints its outline above ExpansionTile's Material.
      'geometry': 10,
      'text_style': 3,
    };

    expect(rule.pattern, 'lib/screens/exercise/auto_preset_flow_screen.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(rule.kinds, unorderedEquals(kindCounts.keys));
    expect(rule.rationale, contains('graph editing and persistence review'));

    final findings = report.findings
        .where((finding) => finding.ruleId == rule.id)
        .toList();
    expect(findings, hasLength(33));
    for (final entry in kindCounts.entries) {
      expect(
        findings.where((finding) => finding.kind == entry.key),
        hasLength(entry.value),
      );
    }
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
    expect(
      report.findings.where(
        (finding) =>
            finding.file == rule.pattern && finding.status == 'pending',
      ),
      isEmpty,
    );
  });

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? AppThemeFactory.light(family)
          : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode Auto Preset Flow preserves its style owners', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: _FlowThemeRepository(),
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const AutoPresetFlowScreen.appDefaults(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pageContext = tester.element(find.byType(AutoPresetFlowScreen));
        final strings = AppLocalizations.of(pageContext);
        final scheme = Theme.of(pageContext).colorScheme;
        final surfaces = pageContext.surfaceTokens;
        final shapes = pageContext.shapeTokens;
        final flow = pageContext.flowTokens;
        final neo = family == AppThemeFamily.neoBrutalism;
        final controlSurface = surfaces.settingsInput;
        final controlForeground = neo
            ? tonosForegroundForSurface(pageContext, controlSurface)
            : scheme.onSurface;
        final controlSecondary = neo
            ? tonosSecondaryForegroundForSurface(pageContext, controlSurface)
            : scheme.onSurfaceVariant;
        final accents = [flow.success, scheme.primary];

        final tiles = tester
            .widgetList<ExpansionTile>(find.byType(ExpansionTile))
            .toList();
        expect(tiles, hasLength(2));
        for (var index = 0; index < tiles.length; index++) {
          final tile = tiles[index];
          final accent = accents[index];
          final expectedForeground = neo
              ? tonosForegroundForSurface(pageContext, surfaces.flowControl)
              : scheme.onSurface;
          final expectedSecondary = neo
              ? tonosSecondaryForegroundForSurface(
                  pageContext,
                  surfaces.flowControl,
                )
              : scheme.onSurfaceVariant;

          expect(
            tile.backgroundColor,
            accent.withValues(alpha: surfaces.flowControlExpandedOpacity),
          );
          expect(
            tile.collapsedBackgroundColor,
            accent.withValues(alpha: surfaces.flowControlCollapsedOpacity),
          );
          expect(tile.textColor, neo ? expectedForeground : isNull);
          expect(tile.collapsedTextColor, neo ? expectedForeground : isNull);
          expect(tile.iconColor, neo ? expectedForeground : isNull);
          expect(tile.collapsedIconColor, neo ? expectedForeground : isNull);
          expect(
            (tile.title as Text).style?.color,
            neo
                ? expectedForeground
                : Theme.of(pageContext).textTheme.titleSmall?.color,
          );
          expect((tile.subtitle as Text).style?.color, expectedSecondary);

          final leading = tile.leading! as Container;
          expect(
            (leading.decoration! as BoxDecoration).color,
            accent.withValues(alpha: surfaces.flowControlIconOpacity),
          );
          expect(
            ((leading.child! as Icon).color),
            neo ? expectedForeground : accent,
          );
        }

        final flowCards = tester
            .widgetList<Container>(find.byType(Container))
            .where((container) {
              final decoration = container.decoration;
              return decoration is BoxDecoration &&
                  decoration.color == surfaces.flowControl;
            })
            .toList();
        expect(flowCards, hasLength(2));
        for (var index = 0; index < flowCards.length; index++) {
          final decoration = flowCards[index].decoration! as BoxDecoration;
          expect(decoration.borderRadius, shapes.flowControl);
          expect(
            decoration.border,
            Border.all(
              color: accents[index].withValues(
                alpha: surfaces.flowControlBorderOpacity,
              ),
            ),
          );
          expect(flowCards[index].clipBehavior, Clip.antiAlias);
        }

        await tester.tap(find.text(strings.flowAddBranchTitle));
        await tester.pumpAndSettle();
        final branchField = tester.widget<DropdownButtonFormField<String>>(
          find.byType(DropdownButtonFormField<String>).first,
        );
        final branchDropdown = tester.widget<DropdownButton<String>>(
          find.byType(DropdownButton<String>).first,
        );
        expect(
          branchDropdown.style,
          neo ? _controlTextStyle(controlForeground) : isNull,
        );
        expect(branchDropdown.dropdownColor, neo ? controlSurface : isNull);
        expect(
          branchDropdown.borderRadius,
          neo ? shapes.settingsInput : isNull,
        );
        expect(
          branchDropdown.iconEnabledColor,
          neo ? controlForeground : isNull,
        );
        expect(
          branchDropdown.iconDisabledColor,
          neo ? controlSecondary.withValues(alpha: 0.72) : isNull,
        );
        _expectFlowControlDecoration(
          branchField.decoration,
          neo: neo,
          surface: controlSurface,
          foreground: controlForeground,
          secondary: controlSecondary,
          outline: tonosOutlineForSurface(pageContext, controlSurface),
          focusRing: pageContext.semanticColors.focusRing,
          shapes: shapes,
        );
        expect(
          branchDropdown.items!.every(
            (item) =>
                (item.child as Text).style?.color ==
                (neo ? controlForeground : null),
          ),
          isTrue,
        );

        final successButtonFinder = find.ancestor(
          of: find.text(strings.flowSuccess),
          matching: find.byWidgetPredicate((widget) => widget is FilledButton),
        );
        expect(successButtonFinder, findsOneWidget);
        final successButton = tester.widget<FilledButton>(successButtonFinder);
        expect(successButton.onPressed, isNull);
        _expectBranchButtonStyle(
          successButton.style!,
          fill: flow.success,
          foreground: neo
              ? tonosForegroundForSurface(pageContext, flow.success)
              : flow.onAction,
          neo: neo,
          context: pageContext,
        );

        await tester.tap(find.text(strings.flowAttachActionTitle));
        await tester.pumpAndSettle();
        final dropdowns = find.byType(DropdownButtonFormField<String>);
        expect(dropdowns, findsNWidgets(2));
        final methodDropdown = tester.widget<DropdownButton<FlowMethod>>(
          find.byType(DropdownButton<FlowMethod>),
        );
        expect(methodDropdown.items, hasLength(1));
        expect((methodDropdown.items!.single.child as Text).data, 'Scale Load');
        expect(
          (methodDropdown.items!.single.child as Text).style?.color,
          neo ? controlForeground : isNull,
        );

        final addActionFinder = _buttonWithText<FilledButton>(
          strings.flowAddAction,
        );
        final addAction = tester.widget<FilledButton>(addActionFinder);
        expect(addAction.onPressed, isNull);
        final actionForeground = neo
            ? tonosForegroundForSurface(pageContext, surfaces.dialogChoice)
            : null;
        expect(
          addAction.style!.backgroundColor?.resolve({WidgetState.disabled}),
          neo ? surfaces.dialogChoice.withValues(alpha: 0.42) : isNull,
        );
        expect(
          addAction.style!.foregroundColor?.resolve({WidgetState.disabled}),
          neo ? actionForeground!.withValues(alpha: 0.72) : isNull,
        );
        expect(
          addAction.style!.side?.resolve({})?.color,
          neo
              ? tonosOutlineForSurface(pageContext, surfaces.dialogChoice)
              : isNull,
        );

        final removeAction = tester.widget<OutlinedButton>(
          _buttonWithText<OutlinedButton>(strings.flowRemoveAction),
        );
        expect(removeAction.onPressed, isNull);
        expect(
          removeAction.style!.backgroundColor?.resolve({WidgetState.disabled}),
          neo ? surfaces.dialog.withValues(alpha: 0.72) : isNull,
        );
        expect(
          removeAction.style!.foregroundColor?.resolve({WidgetState.disabled}),
          neo
              ? tonosForegroundForSurface(
                  pageContext,
                  surfaces.dialog,
                ).withValues(alpha: 0.72)
              : isNull,
        );
        expect(
          removeAction.style!.side?.resolve({})?.color,
          neo ? tonosOutlineForSurface(pageContext, surfaces.dialog) : isNull,
        );

        final removeNode = tester.widget<OutlinedButton>(
          _buttonWithText<OutlinedButton>(strings.flowRemoveNode),
        );
        expect(removeNode.onPressed, isNull);
        expect(
          removeNode.style!.foregroundColor?.resolve({}),
          neo ? flow.failure : scheme.error,
        );
        expect(
          removeNode.style!.side?.resolve({})?.color,
          neo
              ? flow.failure
              : scheme.error.withValues(alpha: surfaces.flowErrorBorderOpacity),
        );

        await tester.tap(findTonosTooltip(strings.flowManageActionsTooltip));
        await tester.pumpAndSettle();
        expect(find.byType(TonosDialogFrame), findsOneWidget);
        await tester.tap(find.text(strings.flowAddNewMethod));
        await tester.pumpAndSettle();
        final frame = tester.widget<TonosDialogFrame>(
          find.byType(TonosDialogFrame),
        );
        expect(frame.styleFormControls, isTrue);
        expect(find.byType(TonosField), findsNWidgets(2));
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byWidgetPredicate(
              (widget) => widget is DropdownButton,
            ),
          ),
          findsNWidgets(2),
        );
        final dialogFields = tester.widgetList<TextField>(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextField),
          ),
        );
        expect(dialogFields.map((field) => field.decoration?.labelText), [
          strings.commonName,
          strings.flowFactor,
        ]);
        expect(
          dialogFields.every((field) => field.decoration?.border == null),
          isTrue,
        );

        await tester.tap(find.widgetWithText(TextButton, strings.commonCancel));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Auto Preset Flow adapts across layouts', (tester) async {
    const layouts = <({Size size, double scale, double keyboardInset})>[
      (size: Size(320, 900), scale: 1, keyboardInset: 0),
      (size: Size(320, 900), scale: 2, keyboardInset: 280),
      (size: Size(360, 800), scale: 1, keyboardInset: 0),
      (size: Size(390, 844), scale: 1.15, keyboardInset: 0),
      (size: Size(390, 844), scale: 1.5, keyboardInset: 0),
      (size: Size(430, 932), scale: 1, keyboardInset: 0),
      (size: Size(600, 1000), scale: 1, keyboardInset: 0),
      (size: Size(800, 390), scale: 1.5, keyboardInset: 0),
      (size: Size(1024, 768), scale: 2, keyboardInset: 0),
    ];
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      for (final layout in layouts) {
        await tester.binding.setSurfaceSize(layout.size);
        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: _FlowThemeRepository(),
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(layout.scale),
                  viewInsets: EdgeInsets.only(bottom: layout.keyboardInset),
                ),
                child: child!,
              ),
              home: const AutoPresetFlowScreen.appDefaults(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pageContext = tester.element(find.byType(AutoPresetFlowScreen));
        final strings = AppLocalizations.of(pageContext);
        final chart = find.byType(FlowChartCanvas);
        expect(chart, findsOneWidget, reason: '$brightness $layout');
        final chartRect = tester.getRect(chart);
        expect(chartRect.left, greaterThanOrEqualTo(0));
        expect(chartRect.right, lessThanOrEqualTo(layout.size.width));
        final save = _buttonWithText<ButtonStyleButton>(strings.commonSave);
        expect(
          save.hitTestable(),
          findsOneWidget,
          reason: '$brightness $layout',
        );
        expect(tester.takeException(), isNull, reason: '$brightness $layout');

        if (layout.keyboardInset > 0) {
          await tester.tap(findTonosTooltip(strings.flowManageActionsTooltip));
          await tester.pumpAndSettle();
          expect(find.byType(FlowEditorManageActionsList), findsOneWidget);
          await tester.drag(
            find.byType(FlowEditorManageActionsList),
            const Offset(0, -240),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text(strings.flowAddNewMethod));
          await tester.pumpAndSettle();
          final nameField = find.byWidgetPredicate(
            (widget) =>
                widget is TextField &&
                widget.decoration?.labelText == strings.commonName,
          );
          expect(nameField, findsOneWidget);
          await tester.ensureVisible(nameField);
          await tester.tap(nameField);
          await tester.enterText(nameField, 'Responsive method');
          await tester.pumpAndSettle();
          expect(nameField.hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull, reason: 'dialog at $layout');
        }
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });
}

void _expectFlowOutlineAboveTile(
  WidgetTester tester,
  Finder tile, {
  required BorderRadius radius,
  required Color color,
}) {
  final outlineLayer = find.ancestor(
    of: tile,
    matching: find.byWidgetPredicate((widget) {
      return widget is CustomPaint &&
          widget.foregroundPainter is FlowControlOutlinePainter;
    }),
  );
  expect(outlineLayer, findsOneWidget);
  final tileWidget = tester.widget<ExpansionTile>(tile);
  expect(tileWidget.shape, RoundedRectangleBorder(borderRadius: radius));

  final clippingCard = find.ancestor(
    of: tile,
    matching: find.byWidgetPredicate((widget) {
      if (widget is! Container ||
          widget.clipBehavior != Clip.antiAlias ||
          widget.decoration is! BoxDecoration) {
        return false;
      }
      final decoration = widget.decoration as BoxDecoration;
      return decoration.borderRadius == radius;
    }),
  );
  expect(clippingCard, findsOneWidget);
  expect(
    find.ancestor(of: clippingCard, matching: outlineLayer),
    findsOneWidget,
  );

  final card = tester.widget<Container>(clippingCard);
  expect((card.decoration! as BoxDecoration).border, isNull);
  final painter =
      tester.widget<CustomPaint>(outlineLayer).foregroundPainter!
          as FlowControlOutlinePainter;
  expect(
    painter.shape,
    RoundedRectangleBorder(
      borderRadius: radius,
      side: BorderSide(color: color),
    ),
  );
}

TextStyle _controlTextStyle(Color foreground) =>
    TextStyle(color: foreground, fontWeight: FontWeight.w700);

Finder _buttonWithText<T extends Widget>(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate((widget) => widget is T),
);

void _expectFlowControlDecoration(
  InputDecoration decoration, {
  required bool neo,
  required Color surface,
  required Color foreground,
  required Color secondary,
  required Color outline,
  required Color focusRing,
  required AppShapeTokens shapes,
}) {
  expect(decoration.labelText, isNotEmpty);
  expect(decoration.prefixIcon, isA<Icon>());
  expect((decoration.prefixIcon! as Icon).color, neo ? foreground : isNull);
  expect(decoration.filled, neo ? isTrue : isNull);
  expect(decoration.fillColor, neo ? surface : isNull);
  expect(decoration.labelStyle?.color, neo ? secondary : isNull);
  expect(decoration.floatingLabelStyle?.color, neo ? foreground : isNull);
  if (!neo) return;

  final enabled = decoration.enabledBorder! as OutlineInputBorder;
  final focused = decoration.focusedBorder! as OutlineInputBorder;
  final border = decoration.border! as OutlineInputBorder;
  expect(enabled.borderRadius, shapes.settingsInput);
  expect(enabled.borderSide.color, outline);
  expect(enabled.borderSide.width, shapes.outlineWidth);
  expect(focused.borderRadius, shapes.settingsInput);
  expect(focused.borderSide.color, focusRing);
  expect(focused.borderSide.width, shapes.focusRingWidth);
  expect(border.borderSide.color, outline);
}

void _expectBranchButtonStyle(
  ButtonStyle style, {
  required Color fill,
  required Color foreground,
  required bool neo,
  required BuildContext context,
}) {
  expect(style.backgroundColor?.resolve({}), fill);
  expect(style.foregroundColor?.resolve({}), foreground);
  if (!neo) return;
  expect(
    style.backgroundColor?.resolve({WidgetState.disabled}),
    fill.withValues(alpha: 0.42),
  );
  expect(
    style.foregroundColor?.resolve({WidgetState.disabled}),
    foreground.withValues(alpha: 0.72),
  );
  expect(style.side?.resolve({})?.color, tonosOutlineForSurface(context, fill));
}

class _FlowThemeRepository extends AppRepository {
  @override
  Future<FlowDefinition> fetchFlowDefinition(int presetId) async =>
      FlowDefinition(
        nodes: const ['1st attempt', 'success1'],
        edges: [
          FlowEdge(from: '1st attempt', outcome: 'success', to: 'success1'),
        ],
      );

  @override
  Future<List<FlowMethod>> fetchFlowMethods(int presetId) async =>
      fetchDefaultFlowMethods('plan');

  @override
  Future<FlowDefinition> fetchDefaultFlowDefinition(
    String scope, {
    int? profileId,
  }) async => FlowDefinition(
    nodes: const ['1st attempt', 'success1'],
    edges: [FlowEdge(from: '1st attempt', outcome: 'success', to: 'success1')],
  );

  @override
  Future<List<FlowMethod>> fetchDefaultFlowMethods(
    String scope, {
    int? profileId,
  }) async => [
    FlowMethod(
      id: 1,
      presetId: 0,
      name: 'Scale Load',
      type: MethodType.weight,
      params: const {'sign': '+', 'factor': 1.0},
    ),
  ];
}

class _FlowManyMethodsRepository extends _FlowThemeRepository {
  @override
  Future<List<FlowMethod>> fetchDefaultFlowMethods(
    String scope, {
    int? profileId,
  }) async => List.generate(
    18,
    (index) => FlowMethod(
      id: index + 1,
      presetId: 0,
      name: 'Scale Load ${index + 1}',
      type: MethodType.values[index % MethodType.values.length],
      params: const {'sign': '+', 'factor': 1.0},
    ),
  );
}
