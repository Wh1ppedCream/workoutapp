import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/theme/theme_lab_page.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_effect_tokens.dart';
import 'package:env_test/theme/tokens/app_media_tokens.dart';
import 'package:env_test/theme/widgets/tonos_action.dart';
import 'package:env_test/theme/widgets/tonos_field.dart';
import 'package:env_test/theme/widgets/tonos_sheet.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';

void main() {
  testWidgets('renders the development gallery and stress controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ThemeLabPage(),
      ),
    );

    expect(find.text('Theme Lab'), findsOneWidget);
    expect(find.text('Theme family'), findsOneWidget);
    expect(find.text('Locale'), findsOneWidget);
    expect(find.text('Reduced motion'), findsOneWidget);
    expect(find.text('Effects enabled'), findsOneWidget);
    expect(find.byType(TonosSurface), findsWidgets);
    expect(find.byType(SegmentedButton<Brightness>), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Tonos actions'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byType(TonosAction), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Tonos fields'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byType(TonosField), findsNWidgets(3));

    await tester.scrollUntilVisible(
      find.text('Tonos sheets'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byType(TonosSheet), findsNWidgets(2));

    await tester.scrollUntilVisible(
      find.text('Material states'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.byKey(const ValueKey('theme-lab-material-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('theme-lab-material-dropdown')),
      findsOneWidget,
    );
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    for (final heading in [
      'Typography',
      'Data visualization',
      'Fitness states',
      'Stress states',
    ]) {
      await tester.scrollUntilVisible(
        find.text(heading),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(heading), findsOneWidget);
    }
  });

  testWidgets('effects switch removes optional preview depth', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ThemeLabPage(),
      ),
    );

    await tester.tap(find.widgetWithText(SwitchListTile, 'Effects enabled'));
    await tester.pump();

    final previewTheme = tester
        .widgetList<Theme>(find.byType(Theme))
        .map((theme) => theme.data)
        .firstWhere((theme) => theme.extension<AppEffectTokens>() != null);
    expect(previewTheme.effectTokens.cardElevation, 0);
    expect(previewTheme.effectTokens.dialogElevation, 0);
    expect(previewTheme.effectTokens.sheetElevation, 0);
    expect(previewTheme.effectTokens.exerciseDetailSheetElevation, 0);
    expect(previewTheme.effectTokens.feedbackElevation, 0);
    expect(previewTheme.extension<AppMediaTokens>()!.overlayShadow, isEmpty);
  });
}
