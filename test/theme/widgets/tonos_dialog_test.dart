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
