import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/widgets/exercise_definition_info_tile.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.dark
              ? AppThemeFactory.dark(family)
              : AppThemeFactory.light(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode title emphasis preserves inherited ListTile style', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ExerciseDefinitionInfoTile(
                definition: ExerciseDefinition(
                  id: 1,
                  name: 'Bench Press',
                  useManualBodyparts: false,
                  multiplyByRating: false,
                ),
                subtitle: const Text('Barbell'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final titleFinder = find.text('Bench Press');
        expect(titleFinder, findsOneWidget);
        final title = tester.widget<Text>(titleFinder);
        expect(title.style, const TextStyle(fontWeight: FontWeight.w700));

        final inheritedStyle =
            DefaultTextStyle.of(tester.element(titleFinder)).style;
        final renderedStyle =
            tester.renderObject<RenderParagraph>(titleFinder).text.style;
        expect(renderedStyle, inheritedStyle.merge(title.style));
        expect(renderedStyle?.fontWeight, FontWeight.w700);
        expect(renderedStyle?.fontSize, inheritedStyle.fontSize);
        expect(renderedStyle?.color, inheritedStyle.color);

        final isNeo = family == AppThemeFamily.neoBrutalism;
        expect(
          find.byType(TonosSurface),
          isNeo ? findsOneWidget : findsNothing,
        );
        expect(find.byType(Card), isNeo ? findsNothing : findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
