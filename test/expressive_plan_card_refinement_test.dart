import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_data_visualization_tokens.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';
import 'package:env_test/theme/widgets/workout_thumbnail_frame.dart';
import 'package:env_test/widgets/body_heatmap.dart';
import 'package:env_test/widgets/generic_bar.dart';
import 'package:env_test/widgets/preset_bar.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'Expressive plan card and identity frame share a shape and preserve heatmap contrast',
    (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const rowScale = 0.92;
      const identityColors = <Color>[Colors.blue, Colors.orange, Colors.green];
      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        for (
          var colorIndex = 0;
          colorIndex < identityColors.length;
          colorIndex++
        ) {
          final identityColor = identityColors[colorIndex];
          for (final isActive in <bool>[true, false]) {
            final index = colorIndex;
            final presetId = 300 + colorIndex * 2 + (isActive ? 0 : 1);
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
                        label: 'Refinement plan $colorIndex',
                        color: identityColor,
                        index: index,
                        isActivePlan: isActive,
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
            expect(find.text('Refinement plan $colorIndex'), findsOneWidget);

            final card = tester.widget<Material>(cardFinder);
            expect(
              card.color,
              Color.alphaBlend(
                identityColor.withValues(alpha: isActive ? 0.16 : 0.13),
                theme.colorScheme.surfaceContainerLow,
              ),
              reason: 'the existing plan-card body fill remains unchanged',
            );
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
            expect(
              (identity.decoration! as BoxDecoration).color,
              identityColor,
            );

            final context = tester.element(frameFinder);
            final surfaces = context.surfaceTokens;
            final frame = tester.widget<WorkoutThumbnailFrame>(frameFinder);
            final heatmap = tester.widget<BodyHeatmap>(
              find.descendant(
                of: frameFinder,
                matching: find.byType(BodyHeatmap),
              ),
            );
            final expectedHeatmapSurface = Color.alphaBlend(
              identityColor.withValues(alpha: 0.12),
              surfaces.mediaPlaceholder,
            );
            expect(frame.backgroundColor, expectedHeatmapSurface);
            expect(
              frame.backgroundColor,
              isNot(surfaces.mediaPlaceholder),
              reason:
                  'plan identity adds a subtle tint to the neutral media tone',
            );
            expect(
              0.12,
              lessThan(isActive ? 0.16 : 0.13),
              reason: 'heatmap tint stays weaker than the plan-card wash',
            );
            expect(
              (identity.decoration! as BoxDecoration).color,
              identityColor,
              reason: 'the leading plan identity block keeps its full accent',
            );
            expect(
              heatmap.lowColor,
              tonosHeatmapLowForSurface(context, frame.backgroundColor!),
            );
            expect(
              heatmap.highColor,
              tonosHeatmapHighForSurface(context, frame.backgroundColor!),
            );
            final dataColors = theme.extension<AppDataVisualizationTokens>()!;
            expect(heatmap.lowColor, dataColors.heatmapLow);
            expect(heatmap.highColor, dataColors.heatmapHigh);

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
            expect(menu.color, isNotNull);
            expect(tester.takeException(), isNull);
          }
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

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive ${brightness.name} archived plan actions and delete confirmation stay cohesive',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final repository = _PresetBarRepository();
        var refreshCount = 0;
        const presetId = 401;
        final menuButton = find.byKey(
          const ValueKey<String>('expressive-plan-actions-$presetId'),
        );
        final app = Provider<AppRepository>.value(
          value: repository,
          child: MaterialApp(
            theme: theme,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    right: 0,
                    bottom: 0,
                    width: 350,
                    child: PresetBar(
                      presetId: presetId,
                      label: 'Archived plan name',
                      color: Colors.teal,
                      index: 1,
                      isActivePlan: false,
                      onRefresh: () => refreshCount++,
                      useExpressiveTrainPresentation: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pumpWidget(app);
        await tester.pumpAndSettle();
        final strings = AppLocalizations.of(
          tester.element(find.byType(PresetBar)),
        );
        final colors = theme.colorScheme;
        final menu = tester.widget<PopupMenuButton<String>>(menuButton);
        final menuSurface = menu.color!;
        expect(menu.surfaceTintColor, Colors.transparent);
        expect(menu.shape, isA<RoundedRectangleBorder>());

        await tester.tap(menuButton);
        await tester.pumpAndSettle();
        PopupMenuItem<String> menuItem(String value) => tester.widget(
          find.byWidgetPredicate(
            (widget) =>
                widget is PopupMenuItem<String> && widget.value == value,
          ),
        );

        expect(menuItem('activate').enabled, isFalse);
        expect(menuItem('delete').enabled, isTrue);
        expect(menuItem('rename').enabled, isTrue);
        expect(
          tester
              .widgetList<PopupMenuItem<String>>(
                find.byType(PopupMenuItem<String>),
              )
              .map((item) => item.value),
          ['activate', 'rename', 'delete'],
        );
        final deleteItemRect = tester.getRect(
          find.byWidgetPredicate(
            (widget) =>
                widget is PopupMenuItem<String> && widget.value == 'delete',
          ),
        );
        expect(deleteItemRect.left, greaterThanOrEqualTo(0));
        expect(deleteItemRect.right, lessThanOrEqualTo(390));
        expect(deleteItemRect.top, greaterThanOrEqualTo(0));
        expect(deleteItemRect.bottom, lessThanOrEqualTo(844));
        final deleteText = tester.widget<Text>(
          find.descendant(
            of: find.byWidgetPredicate(
              (widget) =>
                  widget is PopupMenuItem<String> && widget.value == 'delete',
            ),
            matching: find.text(strings.commonDelete),
          ),
        );
        final renameText = tester.widget<Text>(
          find.descendant(
            of: find.byWidgetPredicate(
              (widget) =>
                  widget is PopupMenuItem<String> && widget.value == 'rename',
            ),
            matching: find.text(strings.commonRename),
          ),
        );
        expect(deleteText.style?.color, colors.error);
        expect(
          _contrast(deleteText.style!.color!, menuSurface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(renameText.style!.color!, menuSurface),
          greaterThanOrEqualTo(4.5),
        );
        final disabledText = tester.widget<Text>(
          find.text(strings.planActivate),
        );
        expect(
          _contrast(disabledText.style!.color!, menuSurface),
          greaterThanOrEqualTo(3),
        );
        for (final item in ['activate', 'rename', 'delete']) {
          expect(
            tester
                .getSize(
                  find.byWidgetPredicate(
                    (widget) =>
                        widget is PopupMenuItem<String> && widget.value == item,
                  ),
                )
                .height,
            greaterThanOrEqualTo(48),
          );
        }

        await tester.tap(find.text(strings.commonDelete));
        await tester.pump();
        expect(find.byType(AlertDialog), findsNothing);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        expect(find.byType(PopupMenuItem<String>), findsNothing);
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          find.text(strings.presetBarDeleteTitle('Archived plan name')),
          findsOneWidget,
        );
        expect(find.text(strings.presetBarDeleteBody), findsOneWidget);
        expect(repository.deleteCalls, 0);
        final deleteAction = find.widgetWithText(
          FilledButton,
          strings.commonDelete,
        );
        final cancelAction = find.widgetWithText(
          OutlinedButton,
          strings.commonCancel,
        );
        expect(tester.getSize(deleteAction).height, greaterThanOrEqualTo(48));
        expect(tester.getSize(cancelAction).height, greaterThanOrEqualTo(48));
        final deleteStyle = tester.widget<FilledButton>(deleteAction).style!;
        expect(
          _contrast(
            deleteStyle.foregroundColor!.resolve({})!,
            deleteStyle.backgroundColor!.resolve({})!,
          ),
          greaterThanOrEqualTo(4.5),
        );

        await tester.tap(find.text(strings.commonCancel));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(repository.deleteCalls, 0);

        await tester.tap(menuButton);
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.commonDelete));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.commonDelete));
        await tester.pumpAndSettle();
        expect(repository.deleteCalls, 1);
        expect(refreshCount, 1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Expressive ${brightness.name} plan menu still activates and renames',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final repository = _PresetBarRepository();
        final activeValues = <bool>[];
        var refreshCount = 0;
        const presetId = 402;
        final menuButton = find.byKey(
          const ValueKey<String>('expressive-plan-actions-$presetId'),
        );

        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: repository,
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 350,
                    child: PresetBar(
                      presetId: presetId,
                      label: 'Plan to update',
                      color: Colors.teal,
                      index: 1,
                      isActivePlan: true,
                      onSetActivePlan: (active) async {
                        activeValues.add(active);
                      },
                      onRefresh: () => refreshCount++,
                      useExpressiveTrainPresentation: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final strings = AppLocalizations.of(
          tester.element(find.byType(PresetBar)),
        );

        await tester.tap(menuButton);
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.planArchive));
        await tester.pumpAndSettle();
        expect(activeValues, [false]);

        await tester.tap(menuButton);
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.commonRename));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Updated plan');
        await tester.tap(find.text(strings.commonRename));
        await tester.pumpAndSettle();
        expect(repository.updatedNames, [(presetId, 'Updated plan')]);
        expect(refreshCount, 1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Expressive ${brightness.name} long plan confirmation keeps actions reachable with large text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = _PresetBarRepository();
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        const planName =
            'Upper Body Strength and Conditioning with Additional Accessory Exercises';
        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: repository,
            child: MaterialApp(
              theme: theme,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.8)),
                child: child!,
              ),
              home: Scaffold(
                body: PresetBar(
                  presetId: 403,
                  label: planName,
                  color: Colors.teal,
                  index: 1,
                  isActivePlan: false,
                  onSetActivePlan: (_) async {},
                  onRefresh: () {},
                  useExpressiveTrainPresentation: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final strings = AppLocalizations.of(
          tester.element(find.byType(PresetBar)),
        );
        await tester.tap(
          find.byKey(const ValueKey('expressive-plan-actions-403')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.commonDelete));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(
          find.text(strings.presetBarDeleteTitle(planName)),
          findsOneWidget,
        );
        final cancel = find.widgetWithText(
          OutlinedButton,
          strings.commonCancel,
        );
        final delete = find.widgetWithText(FilledButton, strings.commonDelete);
        for (final action in [cancel, delete]) {
          expect(tester.getRect(action).bottom, lessThanOrEqualTo(568));
          expect(tester.getSize(action).height, greaterThanOrEqualTo(48));
        }
        await tester.ensureVisible(find.text(strings.presetBarDeleteBody));
        await tester.pumpAndSettle();
        await tester.tap(cancel);
        await tester.pumpAndSettle();
        expect(repository.deleteCalls, 0);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

double _contrast(Color foreground, Color background) {
  final textLuminance = foreground.computeLuminance();
  final surfaceLuminance = background.computeLuminance();
  final lighter = textLuminance > surfaceLuminance
      ? textLuminance
      : surfaceLuminance;
  final darker = textLuminance < surfaceLuminance
      ? textLuminance
      : surfaceLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

class _PresetBarRepository extends AppRepository {
  int deleteCalls = 0;
  final List<(int, String)> updatedNames = <(int, String)>[];

  @override
  Future<void> deletePreset(int presetId) async {
    deleteCalls++;
  }

  @override
  Future<void> updatePresetName(int presetId, String name) async {
    updatedNames.add((presetId, name));
  }
}
