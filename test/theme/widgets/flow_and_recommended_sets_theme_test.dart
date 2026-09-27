import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/analytics_models.dart';
import 'package:env_test/models/preset_models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/flow_widgets.dart';
import 'package:env_test/widgets/flow_screen_widgets.dart';
import 'package:env_test/widgets/preset_bar.dart';
import 'package:env_test/widgets/recommended_sets_editor_dialog.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode flow controls keep menu foreground and actions', (
        tester,
      ) async {
        String? parent = 'Start';
        String? node = 'Start';
        var selectedMethod = FlowMethod(
          id: 1,
          presetId: 3,
          name: 'Squat',
          type: MethodType.weight,
          params: const {},
        );
        var addedSuccess = 0;
        var addedMethod = 0;
        final methods = [
          selectedMethod,
          FlowMethod(
            id: 2,
            presetId: 3,
            name: 'Hinge',
            type: MethodType.rep,
            params: const {},
          ),
        ];

        await tester.pumpWidget(
          _host(
            theme,
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BranchControls(
                    branchable: const ['Start', 'Finish'],
                    selectedParent: parent,
                    onParentChanged: (value) => parent = value,
                    onAddSuccess: () => addedSuccess++,
                    onAddFailure: () {},
                    existingSuccess: 0,
                    existingFailure: 0,
                  ),
                  MethodControls(
                    methodTargets: const ['Start', 'Next'],
                    selectedNode: node,
                    onNodeChanged: (value) => node = value,
                    availableMethods: methods,
                    selectedMethod: selectedMethod,
                    onMethodChanged: (value) {
                      if (value != null) selectedMethod = value;
                    },
                    canAdd: true,
                    onAddMethod: () => addedMethod++,
                    hasMethods: true,
                    onRemoveMethod: () {},
                    canDeleteNode: true,
                    onRemoveNode: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        final context = tester.element(find.byType(BranchControls));
        final expectedForeground = Theme.of(context).colorScheme.onSurface;
        final expectedPopup = context.surfaceTokens.dialog;
        final dropdowns = find.byWidgetPredicate(
          (widget) => widget is DropdownButton,
        );
        expect(dropdowns, findsNWidgets(3));
        for (final dropdown in tester.widgetList<DropdownButton<dynamic>>(
          dropdowns,
        )) {
          expect(dropdown.style, isNull);
          expect(dropdown.dropdownColor, expectedPopup);
          expect(dropdown.hint, isA<Text>());
          expect((dropdown.hint! as Text).style?.color, expectedForeground);
          for (final item in dropdown.items!) {
            expect(item.child, isA<Text>());
            expect((item.child as Text).style?.color, expectedForeground);
          }
        }

        final strings = AppLocalizations.of(context);
        await tester.tap(find.text(strings.flowAddSuccess));
        expect(addedSuccess, 1);
        await tester.tap(find.text(strings.flowAddMethod));
        expect(addedMethod, 1);

        await tester.tap(dropdowns.first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Finish').last);
        await tester.pumpAndSettle();
        expect(parent, 'Finish');

        await tester.tap(dropdowns.at(2));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Hinge').last);
        await tester.pumpAndSettle();
        expect(selectedMethod.name, 'Hinge');
        expect(tester.takeException(), isNull);
      });

      testWidgets('$mode flow event fields inherit the dialog form recipe', (
        tester,
      ) async {
        await tester.pumpWidget(
          _host(theme, const SizedBox(height: 640, child: FlowChartWidget())),
        );

        final chartContext = tester.element(find.byType(FlowChartWidget));
        final strings = AppLocalizations.of(chartContext);
        await tester.tap(find.byType(NodeSelector).at(1));
        await tester.pumpAndSettle();
        await tester.tap(find.text('success1').last);
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(ElevatedButton, strings.flowAddEvent),
        );
        await tester.pumpAndSettle();

        final dialog = find.byType(AlertDialog);
        expect(dialog, findsOneWidget);
        final dialogContext = tester.element(dialog);
        final dialogTheme = Theme.of(dialogContext);
        final fields =
            tester.widgetList<TextField>(find.byType(TextField)).toList();
        expect(fields, hasLength(2));
        expect(fields[0].decoration?.labelText, strings.flowEventKey);
        expect(fields[1].decoration?.labelText, strings.flowEventDisplayLabel);
        expect(
          fields.every((field) => field.decoration?.border == null),
          isTrue,
        );

        if (dialogContext.surfaceDecorationTokens.panel.outlined) {
          final inputTheme = dialogTheme.inputDecorationTheme;
          final fieldSurface = dialogContext.surfaceTokens.dialogChoice;
          final fieldForeground = tonosForegroundForSurface(
            dialogContext,
            fieldSurface,
          );
          expect(inputTheme.filled, isTrue);
          expect(inputTheme.fillColor, fieldSurface);
          expect(
            inputTheme.labelStyle?.color,
            fieldForeground.withValues(alpha: 0.78),
          );
          expect(inputTheme.floatingLabelStyle?.color, fieldForeground);
          final enabledBorder = inputTheme.enabledBorder! as OutlineInputBorder;
          expect(
            enabledBorder.borderRadius,
            dialogContext.shapeTokens.dialogChoice,
          );
          expect(
            enabledBorder.borderSide.color,
            tonosOutlineForSurface(dialogContext, fieldSurface),
          );
          expect(
            enabledBorder.borderSide.width,
            dialogContext.shapeTokens.outlineWidth,
          );
        } else {
          expect(dialogTheme.inputDecorationTheme, theme.inputDecorationTheme);
        }

        await tester.tap(find.widgetWithText(TextButton, strings.commonCancel));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        '$mode preset rename field and automatic badge keep theme ownership',
        (tester) async {
          const scale = 1.25;
          final repository = _PresetRepository();
          var refreshCount = 0;
          await tester.pumpWidget(
            _host(
              theme,
              Provider<AppRepository>.value(
                value: repository,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: PresetBar(
                      presetId: 42,
                      label: 'Upper Body',
                      color: theme.colorScheme.primary,
                      index: 0,
                      isAutomatic: true,
                      focusFrequencyMap: const <String, double>{},
                      onRefresh: () => refreshCount++,
                      scale: scale,
                    ),
                  ),
                ),
              ),
            ),
          );

          final barContext = tester.element(find.byType(PresetBar));
          final badge = tester.widget<Text>(find.text('A'));
          final badgeCircle = tester.widget<CircleAvatar>(
            find.ancestor(
              of: find.text('A'),
              matching: find.byType(CircleAvatar),
            ),
          );
          expect(
            badgeCircle.backgroundColor,
            barContext.semanticColors.automaticPlanBadge,
          );
          expect(
            badge.style?.color,
            barContext.semanticColors.onAutomaticPlanBadge,
          );
          expect(badge.style?.fontSize, 12 * scale);
          expect(badge.style?.fontWeight, FontWeight.bold);

          final strings = AppLocalizations.of(barContext);
          Future<void> openRenameDialog() async {
            await tester.tap(find.byIcon(Icons.more_vert));
            await tester.pumpAndSettle();
            await tester.tap(find.text(strings.commonRename).last);
            await tester.pumpAndSettle();
          }

          await openRenameDialog();

          final dialog = find.byType(AlertDialog);
          expect(dialog, findsOneWidget);
          final dialogContext = tester.element(dialog);
          final field = tester.widget<TextField>(find.byType(TextField));
          expect(field.controller?.text, 'Upper Body');
          expect(field.decoration?.labelText, strings.planNameLabel);
          expect(field.decoration?.border, isNull);

          if (dialogContext.surfaceDecorationTokens.panel.outlined) {
            final inputTheme = Theme.of(dialogContext).inputDecorationTheme;
            final fieldSurface = dialogContext.surfaceTokens.dialogChoice;
            final fieldForeground = tonosForegroundForSurface(
              dialogContext,
              fieldSurface,
            );
            expect(inputTheme.filled, isTrue);
            expect(inputTheme.fillColor, fieldSurface);
            expect(
              inputTheme.labelStyle?.color,
              fieldForeground.withValues(alpha: 0.78),
            );
            expect(inputTheme.floatingLabelStyle?.color, fieldForeground);
            final enabledBorder =
                inputTheme.enabledBorder! as OutlineInputBorder;
            expect(
              enabledBorder.borderRadius,
              dialogContext.shapeTokens.dialogChoice,
            );
            expect(
              enabledBorder.borderSide.color,
              tonosOutlineForSurface(dialogContext, fieldSurface),
            );
          } else {
            expect(
              Theme.of(dialogContext).inputDecorationTheme,
              theme.inputDecorationTheme,
            );
          }

          await tester.tap(
            find.widgetWithText(TextButton, strings.commonCancel),
          );
          await tester.pumpAndSettle();
          expect(find.byType(AlertDialog), findsNothing);
          expect(repository.renamedPresetId, isNull);
          expect(refreshCount, 0);
          expect(tester.takeException(), isNull);

          await openRenameDialog();
          await tester.enterText(find.byType(TextField), 'Upper Body Revised');
          await tester.tap(
            find.widgetWithText(ElevatedButton, strings.commonRename),
          );
          await tester.pumpAndSettle();
          expect(repository.renamedPresetId, 42);
          expect(repository.renamedName, 'Upper Body Revised');
          expect(refreshCount, 1);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        '$mode recommended-sets dialog retains shared form ownership',
        (tester) async {
          VolumeBoundaries? result;
          final original = VolumeBoundaries(
            id: 42,
            maintenance: 3,
            minEffective: 5,
            maxAdaptive: 14,
            maxRecoverable: 20,
          );
          await tester.pumpWidget(
            _host(
              theme,
              Builder(
                builder: (context) {
                  return Center(
                    child: FilledButton(
                      key: const ValueKey('open-recommended-sets-editor'),
                      onPressed: () async {
                        result = await showRecommendedSetsEditorDialog(
                          context,
                          targetName: 'Quadriceps',
                          targetId: original.id,
                          currentBounds: original,
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  );
                },
              ),
            ),
          );

          await tester.tap(
            find.byKey(const ValueKey('open-recommended-sets-editor')),
          );
          await tester.pumpAndSettle();

          final dialogContext = tester.element(find.byType(AlertDialog));
          final dialogTheme = Theme.of(dialogContext);
          final usesOutlinedRecipe =
              dialogContext.surfaceDecorationTokens.panel.outlined;
          final fields = find.byType(TextField);
          expect(fields, findsNWidgets(2));
          final fieldWidgets = tester.widgetList<TextField>(fields).toList();
          final strings = AppLocalizations.of(dialogContext);
          expect(
            fieldWidgets[0].decoration?.labelText,
            strings.recommendedSetsMinimum,
          );
          expect(
            fieldWidgets[1].decoration?.labelText,
            strings.recommendedSetsMaximum,
          );
          expect(
            fieldWidgets[0].decoration?.suffixText,
            strings.sessionMetricSets,
          );
          expect(
            fieldWidgets[1].decoration?.suffixText,
            strings.sessionMetricSets,
          );

          if (usesOutlinedRecipe) {
            final inputTheme = dialogTheme.inputDecorationTheme;
            final fieldSurface = dialogContext.surfaceTokens.dialogChoice;
            final fieldForeground = tonosForegroundForSurface(
              dialogContext,
              fieldSurface,
            );
            expect(inputTheme.filled, isTrue);
            expect(inputTheme.fillColor, fieldSurface);
            expect(
              inputTheme.labelStyle?.color,
              fieldForeground.withValues(alpha: 0.78),
            );
            expect(inputTheme.floatingLabelStyle?.color, fieldForeground);
            expect(
              inputTheme.hintStyle?.color,
              fieldForeground.withValues(alpha: 0.62),
            );
            expect(inputTheme.suffixStyle?.color, fieldForeground);
            final enabledBorder =
                inputTheme.enabledBorder! as OutlineInputBorder;
            expect(
              enabledBorder.borderRadius,
              dialogContext.shapeTokens.dialogChoice,
            );
            expect(
              enabledBorder.borderSide.color,
              tonosOutlineForSurface(
                dialogContext,
                dialogContext.surfaceTokens.dialogChoice,
              ),
            );
            expect(
              enabledBorder.borderSide.width,
              dialogContext.shapeTokens.outlineWidth,
            );
            final focusedBorder =
                inputTheme.focusedBorder! as OutlineInputBorder;
            expect(
              focusedBorder.borderRadius,
              dialogContext.shapeTokens.dialogChoice,
            );
            expect(
              focusedBorder.borderSide.color,
              dialogContext.semanticColors.focusRing,
            );
            expect(
              focusedBorder.borderSide.width,
              dialogContext.shapeTokens.focusRingWidth,
            );
            final disabledBorder =
                inputTheme.disabledBorder! as OutlineInputBorder;
            expect(
              disabledBorder.borderSide.color,
              fieldForeground.withValues(alpha: 0.38),
            );
          } else {
            expect(
              dialogTheme.inputDecorationTheme,
              theme.inputDecorationTheme,
            );
          }

          await tester.enterText(fields.first, '25');
          await tester.enterText(fields.last, '20');
          await tester.tap(
            find.widgetWithText(FilledButton, strings.commonSave),
          );
          await tester.pumpAndSettle();
          final rangeError = tester.widget<Text>(
            find.text(strings.recommendedSetsRange),
          );
          expect(rangeError.style?.color, dialogTheme.colorScheme.error);

          await tester.enterText(fields.first, '4');
          await tester.enterText(fields.last, '12');
          await tester.tap(
            find.widgetWithText(FilledButton, strings.commonSave),
          );
          await tester.pumpAndSettle();
          expect(result, isNotNull);
          expect(result!.id, original.id);
          expect(result!.maintenance, original.maintenance);
          expect(result!.minEffective, 4);
          expect(result!.maxAdaptive, 12);
          expect(result!.maxRecoverable, 12);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Widget _host(ThemeData theme, Widget child) => MaterialApp(
  theme: theme,
  themeAnimationDuration: Duration.zero,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

class _PresetRepository extends AppRepository {
  int? renamedPresetId;
  String? renamedName;

  @override
  Future<void> updatePresetName(int presetId, String name) async {
    renamedPresetId = presetId;
    renamedName = name;
  }
}
