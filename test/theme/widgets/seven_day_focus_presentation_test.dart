import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/widgets/focused_sets_list.dart';
import 'package:env_test/widgets/seven_day_focus_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Weekly Overview reflows and keeps the details action reachable',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var detailsTaps = 0;
      final hits = [
        FocusedSetHit(bodyPart: BodyPart(1, 'Quads'), units: 6),
        FocusedSetHit(bodyPart: BodyPart(2, 'Chest'), units: 6),
        FocusedSetHit(bodyPart: BodyPart(3, 'Upper Back'), units: 3),
        FocusedSetHit(bodyPart: BodyPart(4, 'Calves'), units: 2),
      ];

      Future<void> pumpAt({
        required double width,
        required double textScale,
        required AppThemeFamily family,
        required Brightness brightness,
      }) async {
        await tester.binding.setSurfaceSize(Size(width, 1200));
        final theme =
            brightness == Brightness.dark
                ? AppThemeFactory.dark(family)
                : AppThemeFactory.light(family);
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(textScale)),
                  child: child!,
                ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: SevenDayFocusPresentation(
                  heatmapFrequencyMap: const <String, double>{
                    'Quads': 1,
                    'Chest': 0.7,
                    'Upper Back': 0.5,
                  },
                  hits: hits,
                  onFocusedSetsTap: () => detailsTaps++,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await pumpAt(
        width: 420,
        textScale: 1,
        family: AppThemeFamily.neoBrutalism,
        brightness: Brightness.light,
      );
      expect(find.byType(SevenDayFocusPresentation), findsOneWidget);
      expect(
        find.byKey(const ValueKey('seven-day-focus-side-by-side')),
        findsOneWidget,
      );
      expect(find.text('Quads'), findsOneWidget);

      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(strings.sevenDayFocusMore));
      expect(detailsTaps, 1);

      await pumpAt(
        width: 320,
        textScale: 2,
        family: AppThemeFamily.neoBrutalism,
        brightness: Brightness.dark,
      );
      expect(find.byType(SevenDayFocusPresentation), findsOneWidget);
      expect(
        find.byKey(const ValueKey('seven-day-focus-stacked')),
        findsOneWidget,
      );
      expect(find.text('Quads'), findsOneWidget);

      await pumpAt(
        width: 320,
        textScale: 2,
        family: AppThemeFamily.classic,
        brightness: Brightness.light,
      );
      expect(find.byType(SevenDayFocusPresentation), findsOneWidget);
      expect(tester.takeException(), isNull);

      await pumpAt(
        width: 420,
        textScale: 1,
        family: AppThemeFamily.classic,
        brightness: Brightness.dark,
      );
      expect(
        find.byKey(const ValueKey('seven-day-focus-side-by-side')),
        findsOneWidget,
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('seven-day-focus-side-by-side')))
            .height,
        198,
      );
      expect(
        find.descendant(
          of: find.byType(SevenDayFocusPresentation),
          matching: find.byType(Card),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
