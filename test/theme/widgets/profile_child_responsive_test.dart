import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/preset_models.dart';
import 'package:env_test/screens/profile/settings/flow_methods_page.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/theme/widgets/tonos_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'Expressive add-set rule options wrap at compact large text and keep dialog actions above the keyboard',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final flowMethod = FlowMethod(
        id: 1,
        presetId: 1,
        name: 'Add set',
        type: MethodType.addSet,
        params: const {'weight': 45.0, 'reps': 8},
      );

      for (final (width, height, scale, keyboardInset, locale)
          in <(double, double, double, double, Locale)>[
            (320, 720, 1, 0, const Locale('en')),
            (320, 720, 1.5, 280, const Locale('en')),
            (320, 720, 2, 280, const Locale('bn')),
            (390, 844, 1, 0, const Locale('en')),
            (390, 844, 1.5, 280, const Locale('en')),
            (1024, 900, 2, 280, const Locale('en')),
          ]) {
        final size = Size(width, height);
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(
          MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            locale: locale,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
                viewInsets: EdgeInsets.only(bottom: keyboardInset),
              ),
              child: child!,
            ),
            home: AppExpressiveDestinationTheme(
              family: AppExpressiveDestinationFamily.profile,
              child: Scaffold(
                body: Builder(
                  builder: (context) => Center(
                    child: TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => TonosDialogFrame(
                          child: AddPresetMethodDialog(
                            presetId: 1,
                            existing: flowMethod,
                          ),
                        ),
                      ),
                      child: const Text('Open rule'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open rule'));
        await tester.pumpAndSettle();

        final dialog = find.byType(AlertDialog).last;
        final strings = AppLocalizations.of(tester.element(dialog));
        expect(
          find.descendant(of: dialog, matching: find.byType(Radio<AddSetMode>)),
          findsNWidgets(2),
          reason: '$locale / $width dp / $scale×',
        );
        expect(
          find.descendant(of: dialog, matching: find.byType(Wrap)),
          findsOneWidget,
          reason:
              'Expressive set choices wrap at $locale / $width dp / $scale×',
        );
        expect(
          tester.takeException(),
          isNull,
          reason: '$locale / $width dp / $scale×',
        );

        if (width == 390 && scale == 1) {
          final explicit = tester.getCenter(find.text(strings.flowExplicit));
          final copy = tester.getCenter(find.text(strings.rulesCopy));
          expect((explicit.dy - copy.dy).abs(), lessThan(56));
        }

        if (keyboardInset > 0) {
          final saveAction = find.descendant(
            of: dialog,
            matching: find.text(strings.commonSave),
          );
          expect(saveAction, findsOneWidget);
          expect(
            tester.getRect(saveAction).bottom,
            lessThanOrEqualTo(size.height - keyboardInset),
            reason:
                'Save remains above the simulated keyboard at $locale / $width dp / $scale×',
          );
        }
        Navigator.of(tester.element(dialog)).pop();
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets('Classic and Neo adapt rule options only below their fit width', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final flowMethod = FlowMethod(
      id: 1,
      presetId: 1,
      name: 'Add set',
      type: MethodType.addSet,
      params: const {'weight': 45.0, 'reps': 8},
    );

    for (final family in <AppThemeFamily>[
      AppThemeFamily.classic,
      AppThemeFamily.neoBrutalism,
    ]) {
      for (final (width, scale) in <(double, double)>[
        (320, 1),
        (320, 2),
        (390, 1),
        (412, 1),
        (600, 1),
        (600, 2),
      ]) {
        await tester.binding.setSurfaceSize(Size(width, 720));
        await tester.pumpWidget(
          MaterialApp(
            theme: AppThemeFactory.light(family),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => TonosDialogFrame(
                        child: AddPresetMethodDialog(
                          presetId: 1,
                          existing: flowMethod,
                        ),
                      ),
                    ),
                    child: const Text('Open rule'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open rule'));
        await tester.pumpAndSettle();

        final dialog = find.byType(AlertDialog).last;
        final optionOverflowBars = tester
            .widgetList<OverflowBar>(
              find.descendant(of: dialog, matching: find.byType(OverflowBar)),
            )
            .where(
              (bar) =>
                  tester
                      .widgetList<Radio<AddSetMode>>(
                        find.descendant(
                          of: find.byWidget(bar),
                          matching: find.byType(Radio<AddSetMode>),
                        ),
                      )
                      .length ==
                  2,
            );
        expect(
          optionOverflowBars.length,
          1,
          reason:
              '${family.code} uses measured option layout at $width dp / $scale×',
        );
        final strings = AppLocalizations.of(tester.element(dialog));
        final explicit = tester.getCenter(find.text(strings.flowExplicit));
        final copy = tester.getCenter(find.text(strings.rulesCopy));
        expect(
          (explicit.dy - copy.dy).abs(),
          width <= 390 ? greaterThan(24) : lessThan(24),
          reason:
              '${family.code} options adapt at $width dp / $scale× text scale',
        );
        expect(
          tester.takeException(),
          isNull,
          reason: '${family.code} / $width dp / $scale×',
        );
        Navigator.of(tester.element(dialog)).pop();
        await tester.pumpAndSettle();
      }
    }
  });
}
