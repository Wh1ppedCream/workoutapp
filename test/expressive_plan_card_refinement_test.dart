import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';
import 'package:env_test/theme/widgets/workout_thumbnail_frame.dart';
import 'package:env_test/widgets/body_heatmap.dart';
import 'package:env_test/widgets/generic_bar.dart';
import 'package:env_test/widgets/preset_bar.dart';

void main() {
  testWidgets(
    'Expressive plan card and identity frame share a shape and preserve heatmap contrast',
    (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const rowScale = 0.92;
      const identityColor = Color(0xff168cf0);
      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        for (final index in <int>[0, 1]) {
          final presetId = 300 + index;
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 380,
                    child: PresetBar(
                      presetId: presetId,
                      label: 'Refinement plan $index',
                      color: identityColor,
                      index: index,
                      scale: rowScale,
                      useExpressiveTrainPresentation: true,
                      onRefresh: () {},
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          final cardFinder = find.byKey(
            ValueKey<String>('expressive-plan-card-$presetId'),
          );
          final identityFinder = find.byKey(
            ValueKey<String>('expressive-plan-identity-$presetId'),
          );
          final frameFinder = find.byKey(
            ValueKey<String>('expressive-plan-heatmap-frame-$presetId'),
          );
          final menuBubbleFinder = find.byKey(
            ValueKey<String>('expressive-plan-menu-bubble-$presetId'),
          );
          expect(cardFinder, findsOneWidget);
          expect(identityFinder, findsOneWidget);
          expect(frameFinder, findsOneWidget);
          expect(menuBubbleFinder, findsOneWidget);
          expect(find.text('Refinement plan $index'), findsOneWidget);

          final card = tester.widget<Material>(cardFinder);
          final outerRadius =
              (card.shape! as RoundedRectangleBorder).borderRadius
                  as BorderRadius;
          final identity = tester.widget<Container>(identityFinder);
          final innerRadius =
              (identity.decoration! as BoxDecoration).borderRadius!
                  as BorderRadius;
          final identitySize = tester.getSize(identityFinder);
          expect(identitySize.width, closeTo(rowScale * 72, 0.01));
          expect(identitySize.height, closeTo(rowScale * 70, 0.01));

          expect(innerRadius, outerRadius);
          expect(identity.decoration is BoxDecoration, isTrue);
          expect((identity.decoration! as BoxDecoration).color, identityColor);

          final context = tester.element(frameFinder);
          final surfaces = context.surfaceTokens;
          final frame = tester.widget<WorkoutThumbnailFrame>(frameFinder);
          final heatmap = tester.widget<BodyHeatmap>(
            find.descendant(
              of: frameFinder,
              matching: find.byType(BodyHeatmap),
            ),
          );
          expect(frame.backgroundColor, surfaces.mediaPlaceholder);
          expect(
            heatmap.lowColor,
            tonosHeatmapLowForSurface(context, frame.backgroundColor!),
          );
          expect(
            heatmap.highColor,
            tonosHeatmapHighForSurface(context, frame.backgroundColor!),
          );

          final themeMenuFill = Theme.of(context)
              .colorScheme
              .surfaceContainerHigh;
          final menuBubble = tester.widget<Container>(menuBubbleFinder);
          expect(
            (menuBubble.decoration! as BoxDecoration).color,
            themeMenuFill,
          );
          final menu = tester.widget<PopupMenuButton<String>>(
            find.byType(PopupMenuButton<String>),
          );
          expect(menu.color, themeMenuFill);
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets('shared PresetBar default remains the GenericBar recipe', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ExpressiveThemeDefinition.light(),
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PresetBar(
            presetId: 391,
            label: 'Shared default',
            color: const Color(0xff4285f4),
            index: 0,
            onRefresh: () {},
          ),
        ),
      ),
    );

    expect(find.byType(GenericBar), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('expressive-plan-card-391')),
      findsNothing,
    );
    expect(find.byType(TonosExpressiveReveal), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
