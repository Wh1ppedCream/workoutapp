import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_support.dart';
import 'package:provider/provider.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/preset_models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/auto_preset_flow_screen.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';
import 'package:env_test/theme/widgets/tonos_dialog.dart';
import 'package:env_test/theme/widgets/tonos_field.dart';

import '../../../tools/theme_style_inventory.dart';

void main() {
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
      'geometry': 9,
      'text_style': 3,
    };

    expect(rule.pattern, 'lib/screens/exercise/auto_preset_flow_screen.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(rule.kinds, unorderedEquals(kindCounts.keys));
    expect(rule.rationale, contains('graph editing and persistence review'));

    final findings =
        report.findings.where((finding) => finding.ruleId == rule.id).toList();
    expect(findings, hasLength(32));
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
      final theme =
          brightness == Brightness.light
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
        final controlForeground =
            neo
                ? tonosForegroundForSurface(pageContext, controlSurface)
                : scheme.onSurface;
        final controlSecondary =
            neo
                ? tonosSecondaryForegroundForSurface(
                  pageContext,
                  controlSurface,
                )
                : scheme.onSurfaceVariant;
        final accents = [flow.success, scheme.primary];

        final tiles =
            tester
                .widgetList<ExpansionTile>(find.byType(ExpansionTile))
                .toList();
        expect(tiles, hasLength(2));
        for (var index = 0; index < tiles.length; index++) {
          final tile = tiles[index];
          final accent = accents[index];
          final expectedForeground =
              neo
                  ? tonosForegroundForSurface(pageContext, surfaces.flowControl)
                  : scheme.onSurface;
          final expectedSecondary =
              neo
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

        final flowCards =
            tester.widgetList<Container>(find.byType(Container)).where((
              container,
            ) {
              final decoration = container.decoration;
              return decoration is BoxDecoration &&
                  decoration.color == surfaces.flowControl;
            }).toList();
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
          foreground:
              neo
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
        final actionForeground =
            neo
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
