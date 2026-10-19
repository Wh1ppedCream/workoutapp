import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';
import 'package:env_test/widgets/exercise_definition_info_tile.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Compact anatomy row stays readable and accessible in ${brightness.name}',
      (tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));

        Future<void> pumpRow({
          required double width,
          required double scale,
          required bool longContent,
        }) async {
          await tester.binding.setSurfaceSize(Size(width, 780));
          await tester.pumpWidget(
            MaterialApp(
              theme: brightness == Brightness.dark
                  ? ExpressiveThemeDefinition.dark()
                  : ExpressiveThemeDefinition.light(),
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Scaffold(
                body: AppExpressiveDestinationTheme(
                  family: AppExpressiveDestinationFamily.catalog,
                  child: Column(
                    children: [
                      ExerciseDefinitionInfoTile(
                        definition: ExerciseDefinition(
                          id: 1,
                          name: longContent
                              ? 'Bicep Curl - Barbell'
                              : 'Bicep Curl',
                          useManualBodyparts: false,
                          multiplyByRating: false,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: longContent
                              ? [
                                  const Text('Barbell'),
                                  const Text(
                                    'Biceps Brachii, Brachialis, Brachioradialis',
                                  ),
                                ]
                              : const [Text('Dumbbell'), Text('Biceps')],
                        ),
                        expressiveCatalogPresentation: true,
                        compactExpressivePresentation: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
        }

        await pumpRow(width: 390, scale: 1, longContent: false);
        expect(find.byType(ListTile), findsNothing);
        expect(
          tester.getSize(find.byType(Card)).height,
          inInclusiveRange(104, 120),
        );
        final infoTarget = tester.getSize(find.byType(IconButton));
        expect(infoTarget.width, greaterThanOrEqualTo(48));
        expect(infoTarget.height, greaterThanOrEqualTo(48));
        expect(
          tester.widget<IconButton>(find.byType(IconButton)).onPressed,
          isNotNull,
        );
        final rowTap = tester.widget<InkWell>(find.byType(InkWell).first);
        expect(rowTap.onTap, isNotNull);
        expect(tester.takeException(), isNull);

        await pumpRow(width: 320, scale: 2, longContent: true);
        expect(tester.getSize(find.byType(Card)).height, greaterThan(128));
        final title = tester.widget<Text>(find.text('Bicep Curl - Barbell'));
        expect(title.maxLines, isNull);
        expect(title.overflow, isNull);
        expect(
          find.text('Biceps Brachii, Brachialis, Brachioradialis'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Compact row option preserves other destination and theme routes',
    (tester) async {
      final cases = [
        (
          theme: ExpressiveThemeDefinition.light(),
          family: AppExpressiveDestinationFamily.catalog,
          compact: false,
        ),
        (
          theme: ExpressiveThemeDefinition.dark(),
          family: AppExpressiveDestinationFamily.analytics,
          compact: true,
        ),
        (
          theme: AppThemeFactory.light(AppThemeFamily.classic),
          family: AppExpressiveDestinationFamily.catalog,
          compact: true,
        ),
        (
          theme: AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
          family: AppExpressiveDestinationFamily.catalog,
          compact: true,
        ),
      ];
      for (final sample in cases) {
        await tester.pumpWidget(
          MaterialApp(
            theme: sample.theme,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AppExpressiveDestinationTheme(
                family: sample.family,
                child: ExerciseDefinitionInfoTile(
                  definition: ExerciseDefinition(
                    id: 1,
                    name: 'Bench Press',
                    useManualBodyparts: false,
                    multiplyByRating: false,
                  ),
                  subtitle: const Text('Barbell'),
                  expressiveDestinationFamily: sample.family,
                  compactExpressivePresentation: sample.compact,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final tile = tester.widget<ListTile>(find.byType(ListTile));
        expect(tile.isThreeLine, isTrue);
        if (sample.family == AppExpressiveDestinationFamily.analytics) {
          expect(find.byType(TonosExpressivePressResponse), findsOneWidget);
          expect(
            tester.widget<IconButton>(find.byType(IconButton)).style,
            isNotNull,
          );
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('Expressive Catalog treatment remains opt-in for this tile', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ExpressiveThemeDefinition.light(),
        themeAnimationDuration: Duration.zero,
        localizationsDelegates: tonosLocalizationDelegates,
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
            expressiveCatalogPresentation: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TonosExpressivePressResponse), findsNothing);
    expect(find.byType(Card), findsOneWidget);
    final infoButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(infoButton.style, isNull);
    expect(tester.takeException(), isNull);
  });

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.dark
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
            localizationsDelegates: tonosLocalizationDelegates,
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

        final inheritedStyle = DefaultTextStyle.of(tester.element(titleFinder))
            .style;
        final renderedStyle = tester
            .renderObject<RenderParagraph>(titleFinder)
            .text
            .style;
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
