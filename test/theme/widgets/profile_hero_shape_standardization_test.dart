import 'package:env_test/screens/profile/settings/analytics_destination_surfaces.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'approved User Information hero geometry is asymmetric and explicit',
    () {
      expect(
        ExpressiveTrainShapes.focusHero.topLeft,
        const Radius.circular(36),
      );
      expect(
        ExpressiveTrainShapes.focusHero.topRight,
        const Radius.circular(16),
      );
      expect(
        ExpressiveTrainShapes.focusHero.bottomLeft,
        const Radius.circular(16),
      );
      expect(
        ExpressiveTrainShapes.focusHero.bottomRight,
        const Radius.circular(36),
      );
    },
  );

  testWidgets('opted-in Profile scaffold heroes use that shape in both modes', (
    tester,
  ) async {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          themeAnimationDuration: Duration.zero,
          home: AppExpressiveDestinationTheme(
            family: AppExpressiveDestinationFamily.profile,
            child: const SettingsPageScaffold(
              title: 'Workout Progress Flows',
              subtitle: 'A long subtitle that wraps while preserving the card.',
              icon: Icons.account_tree_outlined,
              useExpressiveProfileHeroShape: true,
              showBackButton: false,
              children: [],
            ),
          ),
        ),
      );

      final hero = _containersWithShape(ExpressiveTrainShapes.focusHero);
      expect(hero, findsOneWidget);
      expect(
        (tester.widget<Container>(hero).decoration! as BoxDecoration).border,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('analytics destination headers share the Expressive hero shape', (
    tester,
  ) async {
    for (final brightness in Brightness.values) {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF644080),
          brightness: brightness,
        ),
        extensions: const [
          AppThemeIdentity(family: AppThemeFamilyIdentity.expressivePreview),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          themeAnimationDuration: Duration.zero,
          home: AppExpressiveDestinationTheme(
            family: AppExpressiveDestinationFamily.analytics,
            child: const Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: AnalyticsRouteHeader(
                  title: 'Analytics Settings',
                  subtitle: 'Configure the training data tools.',
                  icon: Icons.analytics_outlined,
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        _containersWithShape(ExpressiveTrainShapes.focusHero),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Classic and Neo retain their existing scaffold hero shapes', (
    tester,
  ) async {
    for (final theme in [
      ClassicThemeDefinition.light(),
      ClassicThemeDefinition.dark(),
      NeoBrutalismThemeDefinition.light(),
      NeoBrutalismThemeDefinition.dark(),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          themeAnimationDuration: Duration.zero,
          home: const SettingsPageScaffold(
            title: 'Unmodified default',
            icon: Icons.settings_outlined,
            useExpressiveProfileHeroShape: true,
            showBackButton: false,
            children: [],
          ),
        ),
      );
      final titleCard = find.descendant(
        of: find.byType(SettingsHeroCard),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.padding == const EdgeInsets.all(18) &&
              widget.decoration is BoxDecoration,
        ),
      );
      expect(
        titleCard,
        findsOneWidget,
        reason: 'Classic/Neo ${theme.brightness.name} hero exists',
      );
      expect(
        (tester.widget<Container>(titleCard).decoration! as BoxDecoration)
            .borderRadius,
        theme.shapeTokens.hero,
        reason: 'Classic/Neo ${theme.brightness.name} retains its shape',
      );
      expect(
        _containersWithShape(ExpressiveTrainShapes.focusHero),
        findsNothing,
      );
    }
  });

  testWidgets('Profile and analytics hero shapes survive responsive layouts', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const sizes = <Size>[
      Size(320, 900),
      Size(360, 900),
      Size(390, 900),
      Size(430, 900),
      Size(600, 900),
      Size(800, 900),
      Size(800, 360),
    ];

    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      for (final size in sizes) {
        for (final scale in const [1.0, 1.5, 2.0]) {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: AppExpressiveDestinationTheme(
                family: AppExpressiveDestinationFamily.profile,
                child: SettingsPageScaffold(
                  title: 'Long Profile Hero Title for Responsive Coverage',
                  subtitle: 'A supporting description that wraps naturally at compact width and large text.',
                  icon: Icons.account_tree_outlined,
                  useExpressiveProfileHeroShape: true,
                  showBackButton: false,
                  children: const [],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            _containersWithShape(ExpressiveTrainShapes.focusHero),
            findsOneWidget,
            reason:
                'Profile ${size.width}x${size.height} at ${scale}x $brightness',
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${size.width}x${size.height} at ${scale}x $brightness',
          );

          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: AppExpressiveDestinationTheme(
                family: AppExpressiveDestinationFamily.analytics,
                child: const Scaffold(
                  body: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: AnalyticsRouteHeader(
                      title:
                          'Long Analytics Header Title for Responsive Coverage',
                      subtitle: 'A second supporting description with enough words to wrap without clipping.',
                      icon: Icons.analytics_outlined,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            _containersWithShape(ExpressiveTrainShapes.focusHero),
            findsOneWidget,
            reason:
                'Analytics ${size.width}x${size.height} at ${scale}x $brightness',
          );
          expect(
            tester.takeException(),
            isNull,
            reason:
                'Analytics ${size.width}x${size.height} at ${scale}x $brightness',
          );
        }
      }
    }
  });
}

Finder _containersWithShape(BorderRadiusGeometry shape) =>
    find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).borderRadius == shape,
    );
