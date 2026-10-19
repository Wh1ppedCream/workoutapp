import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_planning_tokens.dart';
import 'package:env_test/widgets/bodypart_focus_chips.dart';

void main() {
  testWidgets('explicit Expressive tokens style and label bodypart states', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeFactory.light(AppThemeFamily.classic),
        themeAnimationDuration: Duration.zero,
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BodypartFocusChips(
            bodyParts: [
              BodyPart(1, 'Shoulders'),
              BodyPart(2, 'Chest'),
              BodyPart(3, 'Quads'),
            ],
            preferredBodypartIds: {1},
            blacklistedBodypartIds: {2},
            expressiveTokens: AppExpressivePlanningTokens.light,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final preferred = _chip(tester, 'Shoulders');
    final expectedChipSurface = Color.alphaBlend(
      AppExpressivePlanningTokens.light.planFocalSurface.withValues(
        alpha: 0.22,
      ),
      AppExpressivePlanningTokens.light.configurationSurface,
    );
    expect(preferred.backgroundColor, expectedChipSurface);
    expect(
      preferred.selectedColor,
      AppExpressivePlanningTokens.light.actionPrimary,
    );
    expect(
      preferred.labelStyle?.color,
      AppExpressivePlanningTokens.light.actionPrimaryForeground,
    );
    expect((preferred.avatar as Icon).icon, Icons.check_circle);
    expect(
      find.bySemanticsLabel(
        _localizedLabel(tester, 'Shoulders', (s) => s.generateFocusPreferred),
      ),
      findsOneWidget,
    );

    final avoided = _chip(tester, 'Chest');
    expect((avoided.avatar as Icon).icon, Icons.block);
    expect(
      find.bySemanticsLabel(
        _localizedLabel(tester, 'Chest', (s) => s.generateFocusAvoided),
      ),
      findsOneWidget,
    );

    final neutral = _chip(tester, 'Quads');
    expect(neutral.backgroundColor, expectedChipSurface);
    expect((neutral.avatar as Icon).icon, Icons.radio_button_unchecked);
    expect(neutral.selected, isFalse);
    expect(
      find.bySemanticsLabel(
        _localizedLabel(tester, 'Quads', (s) => s.generateFocusNeutral),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Expressive focus cycles neutral, preferred, avoided, neutral', (
    tester,
  ) async {
    var preferredIds = <int>{};
    var avoidedIds = <int>{};

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeFactory.light(AppThemeFamily.classic),
        themeAnimationDuration: Duration.zero,
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: BodypartFocusChips(
              bodyParts: [BodyPart(1, 'Shoulders')],
              preferredBodypartIds: preferredIds,
              blacklistedBodypartIds: avoidedIds,
              expressiveTokens: AppExpressivePlanningTokens.light,
              onChanged: (selection) => setState(() {
                preferredIds = selection.preferredBodypartIds;
                avoidedIds = selection.blacklistedBodypartIds;
              }),
            ),
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(
        _localizedLabel(tester, 'Shoulders', (s) => s.generateFocusNeutral),
      ),
      findsOneWidget,
    );
    expect(preferredIds, isEmpty);
    expect(avoidedIds, isEmpty);

    await tester.tap(find.text('Shoulders'));
    await tester.pumpAndSettle();
    expect(preferredIds, {1});
    expect(avoidedIds, isEmpty);
    expect(
      (_chip(tester, 'Shoulders').avatar as Icon).icon,
      Icons.check_circle,
    );
    expect(
      find.bySemanticsLabel(
        _localizedLabel(tester, 'Shoulders', (s) => s.generateFocusPreferred),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Shoulders'));
    await tester.pumpAndSettle();
    expect(preferredIds, isEmpty);
    expect(avoidedIds, {1});
    expect((_chip(tester, 'Shoulders').avatar as Icon).icon, Icons.block);
    expect(
      find.bySemanticsLabel(
        _localizedLabel(tester, 'Shoulders', (s) => s.generateFocusAvoided),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Shoulders'));
    await tester.pumpAndSettle();
    expect(preferredIds, isEmpty);
    expect(avoidedIds, isEmpty);
    expect(
      (_chip(tester, 'Shoulders').avatar as Icon).icon,
      Icons.radio_button_unchecked,
    );
    expect(
      find.bySemanticsLabel(
        _localizedLabel(tester, 'Shoulders', (s) => s.generateFocusNeutral),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'preferred and avoided have distinct non-color indicators in light and dark',
    (tester) async {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        final tokens = brightness == Brightness.light
            ? AppExpressivePlanningTokens.light
            : AppExpressivePlanningTokens.dark;
        await tester.pumpWidget(
          MaterialApp(
            theme: brightness == Brightness.light
                ? AppThemeFactory.light(AppThemeFamily.classic)
                : AppThemeFactory.dark(AppThemeFamily.classic),
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: BodypartFocusChips(
                bodyParts: [BodyPart(1, 'Shoulders'), BodyPart(2, 'Chest')],
                preferredBodypartIds: {1},
                blacklistedBodypartIds: {2},
                expressiveTokens: tokens,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(
          (_chip(tester, 'Shoulders').avatar as Icon).icon,
          Icons.check_circle,
        );
        expect((_chip(tester, 'Chest').avatar as Icon).icon, Icons.block);
        expect(
          find.bySemanticsLabel(
            _localizedLabel(
              tester,
              'Shoulders',
              (s) => s.generateFocusPreferred,
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(
            _localizedLabel(tester, 'Chest', (s) => s.generateFocusAvoided),
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );
}

RawChip _chip(WidgetTester tester, String label) =>
    tester.widget<RawChip>(find.widgetWithText(RawChip, label));

String _localizedLabel(
  WidgetTester tester,
  String bodyPart,
  String Function(AppLocalizations) focusStatus,
) =>
    '$bodyPart, ${focusStatus(AppLocalizations.of(tester.element(find.byType(BodypartFocusChips))))}';
