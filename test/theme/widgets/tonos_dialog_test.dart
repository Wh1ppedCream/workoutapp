import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_dialog.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('dialog shadow follows visible modal in $brightness', (
      tester,
    ) async {
      final theme =
          brightness == Brightness.dark
              ? AppThemeFactory.dark(AppThemeFamily.neoBrutalism)
              : AppThemeFactory.light(AppThemeFamily.neoBrutalism);
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => TextButton(
                    onPressed: () async {
                      result = await showDialog<String>(
                        context: context,
                        builder:
                            (_) => TonosChoiceDialog<String>(
                              title: 'Weight Units',
                              values: const ['Pounds', 'Kilograms'],
                              selected: 'Pounds',
                              label: (value) => value,
                              subtitle:
                                  (value) => value == 'Pounds' ? 'lbs' : 'kg',
                            ),
                      );
                    },
                    child: const Text('Open'),
                  ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final materialFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Material && widget.shape is TonosDialogShadowBorder,
      );
      expect(materialFinder, findsOneWidget);
      final material = tester.widget<Material>(materialFinder);
      final shape = material.shape! as TonosDialogShadowBorder;
      final rect = Offset.zero & tester.getSize(materialFinder);
      expect(rect.width, lessThan(tester.view.physicalSize.width));
      expect(rect.height, lessThan(tester.view.physicalSize.height));
      expect(shape.offset, const Offset(4, 4));
      expect(shape.shadowPath(rect).contains(rect.center), isFalse);
      expect(
        shape.shadowPath(rect).contains(Offset(rect.right + 2, rect.center.dy)),
        isTrue,
      );
      expect(shape.getOuterPath(rect).contains(rect.center), isTrue);
      final choices =
          tester
              .widgetList<RadioListTile<String>>(
                find.byType(RadioListTile<String>),
              )
              .toList();
      expect(choices.first.tileColor, theme.colorScheme.primary);
      expect((choices.first.shape! as RoundedRectangleBorder).side.width, 3);
      expect((choices.last.shape! as RoundedRectangleBorder).side.width, 2);
      await tester.tap(find.text('Kilograms'));
      await tester.pumpAndSettle();
      expect(result, 'Kilograms');
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Neo dialog actions use readable dark foreground', (
    tester,
  ) async {
    final theme = AppThemeFactory.dark(AppThemeFamily.neoBrutalism);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TonosDialogFrame(
            child: AlertDialog(
              title: const Text('Cancel workout?'),
              actions: [
                TextButton(onPressed: () {}, child: const Text('Keep Workout')),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Cancel Workout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    for (final label in ['Keep Workout', 'Cancel Workout']) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
      expect(paragraph.text.style?.color, const Color(0xFF161616));
    }
  });

  testWidgets('Neo dark dialog keeps dropdowns and pickers readable', (
    tester,
  ) async {
    final theme = AppThemeFactory.dark(AppThemeFamily.neoBrutalism);
    late ThemeData dialogTheme;
    late Color dialogChoiceSurface;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TonosDialogFrame(
            styleFormControls: true,
            styleDarkNeoPickerSurfaces: true,
            child: Builder(
              builder: (context) {
                dialogTheme = Theme.of(context);
                dialogChoiceSurface = context.surfaceTokens.dialogChoice;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    final dialogSurface = theme.dialogTheme.backgroundColor!;
    expect(dialogTheme.colorScheme.surface, dialogSurface);
    expect(dialogTheme.colorScheme.surfaceContainerHigh, dialogSurface);
    expect(dialogTheme.colorScheme.surfaceContainerHighest, dialogSurface);
    expect(dialogTheme.canvasColor, dialogSurface);
    expect(dialogTheme.popupMenuTheme.color, dialogSurface);
    final dialogLuminance = dialogSurface.computeLuminance();
    final foregroundLuminance =
        dialogTheme.colorScheme.onSurface.computeLuminance();
    expect(
      (dialogLuminance + 0.05) / (foregroundLuminance + 0.05),
      greaterThanOrEqualTo(4.5),
    );
    final secondaryForeground = Color.alphaBlend(
      dialogTheme.colorScheme.onSurfaceVariant,
      dialogSurface,
    );
    final secondaryLuminance = secondaryForeground.computeLuminance();
    expect(
      (dialogLuminance + 0.05) / (secondaryLuminance + 0.05),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      dialogTheme.outlinedButtonTheme.style?.backgroundColor?.resolve(
        const <WidgetState>{},
      ),
      dialogChoiceSurface,
    );
  });

  testWidgets('Neo dark picker surfaces require an explicit opt-in', (
    tester,
  ) async {
    final theme = AppThemeFactory.dark(AppThemeFamily.neoBrutalism);
    late ThemeData dialogTheme;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TonosDialogFrame(
            styleFormControls: true,
            child: Builder(
              builder: (context) {
                dialogTheme = Theme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    expect(dialogTheme.colorScheme.surface, theme.colorScheme.surface);
    expect(
      dialogTheme.colorScheme.surfaceContainerHigh,
      theme.colorScheme.surfaceContainerHigh,
    );
    expect(dialogTheme.canvasColor, theme.canvasColor);
    expect(dialogTheme.popupMenuTheme.color, theme.popupMenuTheme.color);
    expect(
      dialogTheme.outlinedButtonTheme.style?.backgroundColor?.resolve(
        const <WidgetState>{},
      ),
      theme.outlinedButtonTheme.style?.backgroundColor?.resolve(
        const <WidgetState>{},
      ),
    );
  });

  testWidgets('opted-in Neo dark theme reaches dropdown and picker routes', (
    tester,
  ) async {
    final theme = AppThemeFactory.dark(AppThemeFamily.neoBrutalism);
    final dialogSurface = theme.dialogTheme.backgroundColor!;
    late Color dialogForeground;
    ThemeData? datePickerTheme;
    ThemeData? timePickerTheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TonosDialogFrame(
            styleDarkNeoPickerSurfaces: true,
            child: Builder(
              builder: (context) {
                dialogForeground = Theme.of(context).colorScheme.onSurface;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: 'wake',
                      items: const [
                        DropdownMenuItem(value: 'wake', child: Text('Wake-up')),
                        DropdownMenuItem(
                          value: 'bedtime',
                          child: Text('Bedtime'),
                        ),
                      ],
                      onChanged: (_) {},
                    ),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          initialDate: DateTime(2025, 6, 15),
                          builder: (pickerContext, child) {
                            datePickerTheme = Theme.of(pickerContext);
                            return child!;
                          },
                        );
                        if (date == null || !context.mounted) return;
                        await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 9, minute: 30),
                          builder: (pickerContext, child) {
                            timePickerTheme = Theme.of(pickerContext);
                            return child!;
                          },
                        );
                      },
                      child: const Text('Choose date'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Bedtime'), findsOneWidget);
    // DropdownButton paints its menu surface with Theme.canvasColor rather
    // than the color of its transparent Material.
    final menuTheme = Theme.of(tester.element(find.text('Bedtime')));
    expect(menuTheme.canvasColor, dialogSurface);
    expect(menuTheme.colorScheme.surface, dialogSurface);
    final bedtimeParagraph = tester.renderObject<RenderParagraph>(
      find.text('Bedtime'),
    );
    expect(bedtimeParagraph.text.style?.color, dialogForeground);
    await tester.tap(find.text('Bedtime'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choose date'));
    await tester.pumpAndSettle();
    expect(datePickerTheme?.colorScheme.surface, dialogSurface);
    expect(datePickerTheme?.canvasColor, dialogSurface);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(timePickerTheme?.colorScheme.surface, dialogSurface);
    expect(timePickerTheme?.canvasColor, dialogSurface);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Neo light dialog keeps its established picker colors', (
    tester,
  ) async {
    final theme = AppThemeFactory.light(AppThemeFamily.neoBrutalism);
    late ThemeData dialogTheme;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TonosDialogFrame(
            styleFormControls: true,
            styleDarkNeoPickerSurfaces: true,
            child: Builder(
              builder: (context) {
                dialogTheme = Theme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    expect(dialogTheme.colorScheme.surface, theme.colorScheme.surface);
    expect(
      dialogTheme.colorScheme.surfaceContainerHigh,
      theme.colorScheme.surfaceContainerHigh,
    );
    expect(dialogTheme.canvasColor, theme.canvasColor);
    expect(dialogTheme.popupMenuTheme.color, theme.popupMenuTheme.color);
  });

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'dialog dropdown uses readable popup colors for $family $brightness',
        (tester) async {
          final theme =
              brightness == Brightness.dark
                  ? AppThemeFactory.dark(family)
                  : AppThemeFactory.light(family);

          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: Builder(
                  builder:
                      (context) => TextButton(
                        onPressed:
                            () => showDialog<void>(
                              context: context,
                              builder:
                                  (_) => TonosDialogFrame(
                                    styleFormControls: true,
                                    child: AlertDialog(
                                      content:
                                          TonosDialogDropdownButton<String>(
                                            value: 'weight',
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'weight',
                                                child: Text('Weight'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'reps',
                                                child: Text('Reps'),
                                              ),
                                            ],
                                            onChanged: (_) {},
                                          ),
                                    ),
                                  ),
                            ),
                        child: const Text('Open'),
                      ),
                ),
              ),
            ),
          );

          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          final dialogContext = tester.element(
            find.byType(TonosDialogDropdownButton<String>),
          );
          final button = tester.widget<DropdownButton<String>>(
            find.byType(DropdownButton<String>),
          );
          final usesOutlinedDialog = family == AppThemeFamily.neoBrutalism;
          final dialogSurface =
              theme.dialogTheme.backgroundColor ??
              dialogContext.surfaceTokens.dialog;
          final foreground =
              usesOutlinedDialog
                  ? tonosForegroundForSurface(dialogContext, dialogSurface)
                  : null;
          final popupForeground =
              foreground ??
              Theme.of(dialogContext).textTheme.titleMedium?.color;

          expect(button.style?.color, foreground);
          expect(button.iconEnabledColor, foreground);
          expect(
            button.dropdownColor,
            usesOutlinedDialog ? dialogSurface : null,
          );

          await tester.tap(find.byType(DropdownButton<String>));
          await tester.pumpAndSettle();
          expect(find.text('Reps'), findsOneWidget);
          final itemParagraph = tester.renderObject<RenderParagraph>(
            find.text('Reps'),
          );
          expect(itemParagraph.text.style?.color, popupForeground);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('effects off and Classic retain unshadowed dialog shapes', (
    tester,
  ) async {
    final neo = AppThemeFactory.dark(AppThemeFamily.neoBrutalism);
    final noEffects = neo.copyWith(
      extensions: [
        ...neo.extensions.values.where(
          (extension) => extension.runtimeType != neo.effectTokens.runtimeType,
        ),
        neo.effectTokens.copyWith(
          cardShadow: Colors.transparent,
          dialogShadowOffset: Offset.zero,
        ),
      ],
    );
    for (final theme in [
      AppThemeFactory.dark(AppThemeFamily.classic),
      noEffects,
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: TonosDialogFrame(
              child: AlertDialog(title: Text('Weight Units')),
            ),
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Material && widget.shape is TonosDialogShadowBorder,
        ),
        findsNothing,
      );
    }
  });
}
