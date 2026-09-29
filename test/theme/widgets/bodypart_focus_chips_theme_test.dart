import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/bodypart_focus_chips.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode bodypart status chips resolve semantic roles', (
        tester,
      ) async {
        await tester.pumpWidget(
          _host(
            theme,
            BodypartFocusChips(
              bodyParts: [
                BodyPart(1, 'Shoulders'),
                BodyPart(2, 'Chest'),
                BodyPart(3, 'Quads'),
              ],
              preferredBodypartIds: {1},
              blacklistedBodypartIds: {2},
              onChanged: _ignoreSelection,
            ),
          ),
        );

        final context = tester.element(find.byType(BodypartFocusChips));
        final isNeo = family == AppThemeFamily.neoBrutalism;
        final preferredColor =
            isNeo ? context.semanticColors.positive : Colors.green.shade300;
        final avoidedColor =
            isNeo ? context.semanticColors.negative : Colors.red.shade300;
        final preferredForeground =
            isNeo ? context.semanticColors.onPositive : preferredColor;
        final avoidedForeground =
            isNeo ? context.semanticColors.onNegative : avoidedColor;
        final surfaces = context.surfaceTokens;
        final chipSurface = surfaces.dialogChoice;
        final chipForeground =
            isNeo ? tonosForegroundForSurface(context, chipSurface) : null;
        final chipOutline =
            isNeo
                ? tonosOutlineForSurface(context, chipSurface)
                : theme.dividerColor;

        final preferred = _chip(tester, 'Shoulders');
        expect(preferred.selected, isTrue);
        expect(
          preferred.selectedColor,
          isNeo ? preferredColor : preferredColor.withAlpha(61),
        );
        expect(
          preferred.side,
          BorderSide(color: isNeo ? preferredForeground : preferredColor),
        );
        expect(
          preferred.labelStyle,
          TextStyle(
            color: isNeo ? preferredForeground : preferredColor,
            fontWeight: FontWeight.w700,
          ),
        );
        expect((preferred.avatar as Icon).color, preferredForeground);
        if (isNeo) {
          expect(
            _contrastRatio(preferredForeground, preferredColor),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            _contrastRatio(preferred.side!.color, preferredColor),
            greaterThanOrEqualTo(3),
          );
        }
        expect((preferred.avatar as Icon).icon, Icons.add_circle_outline);

        final avoided = _chip(tester, 'Chest');
        expect(avoided.selected, isTrue);
        expect(
          avoided.selectedColor,
          isNeo ? avoidedColor : avoidedColor.withAlpha(61),
        );
        expect(
          avoided.side,
          BorderSide(color: isNeo ? avoidedForeground : avoidedColor),
        );
        expect(
          avoided.labelStyle,
          TextStyle(
            color: isNeo ? avoidedForeground : avoidedColor,
            fontWeight: FontWeight.w700,
          ),
        );
        expect((avoided.avatar as Icon).color, avoidedForeground);
        if (isNeo) {
          expect(
            _contrastRatio(avoidedForeground, avoidedColor),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            _contrastRatio(avoided.side!.color, avoidedColor),
            greaterThanOrEqualTo(3),
          );
        }
        expect((avoided.avatar as Icon).icon, Icons.block);

        final neutral = _chip(tester, 'Quads');
        expect(neutral.selected, isFalse);
        expect(neutral.backgroundColor, isNeo ? equals(chipSurface) : isNull);
        expect(neutral.side, BorderSide(color: chipOutline));
        expect(neutral.avatar, isNull);
        expect(
          neutral.labelStyle?.color,
          isNeo ? equals(chipForeground) : isNull,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('$mode bodypart chips retain their tri-state cycle', (
        tester,
      ) async {
        var preferred = <int>{};
        var avoided = <int>{};

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: StatefulBuilder(
                builder:
                    (context, setState) => BodypartFocusChips(
                      bodyParts: [BodyPart(1, 'Shoulders')],
                      preferredBodypartIds: preferred,
                      blacklistedBodypartIds: avoided,
                      onChanged: (selection) {
                        setState(() {
                          preferred = selection.preferredBodypartIds;
                          avoided = selection.blacklistedBodypartIds;
                        });
                      },
                    ),
              ),
            ),
          ),
        );

        final chipFinder = find.widgetWithText(RawChip, 'Shoulders');
        await tester.tap(chipFinder);
        await tester.pump();
        expect(preferred, {1});
        expect(avoided, isEmpty);
        expect(_chip(tester, 'Shoulders').selected, isTrue);

        await tester.tap(chipFinder);
        await tester.pump();
        expect(preferred, isEmpty);
        expect(avoided, {1});
        expect(_chip(tester, 'Shoulders').selected, isTrue);

        await tester.tap(chipFinder);
        await tester.pump();
        expect(preferred, isEmpty);
        expect(avoided, isEmpty);
        expect(_chip(tester, 'Shoulders').selected, isFalse);
        expect(tester.takeException(), isNull);
      });

      testWidgets('$mode empty bodypart message keeps its compact type', (
        tester,
      ) async {
        await tester.pumpWidget(
          _host(
            theme,
            const BodypartFocusChips(
              bodyParts: [],
              preferredBodypartIds: {},
              blacklistedBodypartIds: {},
              onChanged: _ignoreSelection,
              emptyText: 'No targets',
            ),
          ),
        );

        expect(find.text('No targets'), findsOneWidget);
        expect(
          tester.widget<Text>(find.text('No targets')).style,
          const TextStyle(fontSize: 12),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}

RawChip _chip(WidgetTester tester, String label) =>
    tester.widget<RawChip>(find.widgetWithText(RawChip, label));

void _ignoreSelection(BodypartFocusSelection selection) {}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = math.max(firstLuminance, secondLuminance);
  final darker = math.min(firstLuminance, secondLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}

Widget _host(ThemeData theme, Widget child) => MaterialApp(
  theme: theme,
  themeAnimationDuration: Duration.zero,
  localizationsDelegates: tonosLocalizationDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);
