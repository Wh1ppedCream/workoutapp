import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_surface_decoration_tokens.dart';

void main() {
  test('theme builders register explicit family identity in both modes', () {
    final themes = <(ThemeData, AppThemeFamilyIdentity)>[
      (ClassicThemeDefinition.light(), AppThemeFamilyIdentity.classic),
      (ClassicThemeDefinition.dark(), AppThemeFamilyIdentity.classic),
      (
        NeoBrutalismThemeDefinition.light(),
        AppThemeFamilyIdentity.neoBrutalism,
      ),
      (NeoBrutalismThemeDefinition.dark(), AppThemeFamilyIdentity.neoBrutalism),
    ];

    for (final (theme, family) in themes) {
      expect(theme.appThemeFamilyIdentity, family);
      expect(theme.extension<AppThemeIdentity>()?.family, family);
      expect(
        theme.usesClassicPresentation,
        family == AppThemeFamilyIdentity.classic,
      );
      expect(
        theme.usesNeoPresentation,
        family == AppThemeFamilyIdentity.neoBrutalism,
      );
    }
  });

  testWidgets('explicit family identity survives outline token changes', (
    tester,
  ) async {
    final classic = ClassicThemeDefinition.light();
    final classicWithNeoOutline = _withDecorations(
      classic,
      AppSurfaceDecorationTokens.classic.copyWith(
        panel: AppSurfaceDecoration.outlinedOnly,
      ),
    );
    expect(
      classicWithNeoOutline.surfaceDecorationTokens.panel.outlined,
      isTrue,
    );

    final neo = NeoBrutalismThemeDefinition.light();
    final neoWithoutOutline = _withDecorations(
      neo,
      AppSurfaceDecorationTokens.classic,
    );
    expect(neoWithoutOutline.surfaceDecorationTokens.panel.outlined, isFalse);

    final classicObserved = await _observeTheme(tester, classicWithNeoOutline);
    final classicBaseline = await _observeTheme(tester, classic);
    expect(classicObserved.family, AppThemeFamilyIdentity.classic);
    expect(classicObserved.classic, isTrue);
    expect(classicObserved.neo, isFalse);
    expect(classicObserved.foreground, classicBaseline.foreground);
    expect(classicObserved.primarySeries, classicBaseline.primarySeries);

    final neoObserved = await _observeTheme(tester, neoWithoutOutline);
    final neoBaseline = await _observeTheme(tester, neo);
    expect(neoObserved.family, AppThemeFamilyIdentity.neoBrutalism);
    expect(neoObserved.classic, isFalse);
    expect(neoObserved.neo, isTrue);
    expect(neoObserved.foreground, neoBaseline.foreground);
    expect(neoObserved.primarySeries, neoBaseline.primarySeries);
  });

  testWidgets('generic outlined Material theme keeps ordinary theme colors', (
    tester,
  ) async {
    final generic = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    );
    final genericWithOutline = _withDecorations(
      generic,
      AppSurfaceDecorationTokens.classic.copyWith(
        panel: AppSurfaceDecoration.outlinedOnly,
      ),
    );

    for (final theme in [generic, genericWithOutline]) {
      expect(theme.appThemeFamilyIdentity, isNull);
      expect(theme.usesClassicPresentation, isFalse);
      expect(theme.usesNeoPresentation, isFalse);
    }

    final observed = await _observeTheme(tester, genericWithOutline);
    expect(observed.family, isNull);
    expect(observed.classic, isFalse);
    expect(observed.neo, isFalse);
    expect(observed.foreground, genericWithOutline.colorScheme.onSurface);
    expect(
      observed.secondaryForeground,
      genericWithOutline.colorScheme.onSurfaceVariant,
    );
    expect(
      observed.heatmapLow,
      genericWithOutline.dataVisualizationTokens.heatmapLow,
    );
    expect(
      observed.primarySeries,
      genericWithOutline.dataVisualizationTokens.primarySeries,
    );
    expect(
      observed.secondarySeries,
      genericWithOutline.dataVisualizationTokens.secondarySeries,
    );
  });
}

ThemeData _withDecorations(
  ThemeData theme,
  AppSurfaceDecorationTokens decorations,
) {
  return theme.copyWith(
    extensions: [
      ...theme.extensions.values.where(
        (extension) => extension is! AppSurfaceDecorationTokens,
      ),
      decorations,
    ],
  );
}

Future<
  ({
    AppThemeFamilyIdentity? family,
    bool classic,
    bool neo,
    Color foreground,
    Color secondaryForeground,
    Color heatmapLow,
    Color primarySeries,
    Color secondarySeries,
  })
>
_observeTheme(WidgetTester tester, ThemeData theme) async {
  late ({
    AppThemeFamilyIdentity? family,
    bool classic,
    bool neo,
    Color foreground,
    Color secondaryForeground,
    Color heatmapLow,
    Color primarySeries,
    Color secondarySeries,
  })
  observed;

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      themeAnimationDuration: Duration.zero,
      home: Builder(
        builder: (context) {
          final surface = context.surfaceTokens.settingsHero;
          observed = (
            family: context.appThemeFamilyIdentity,
            classic: context.usesClassicPresentation,
            neo: context.usesNeoPresentation,
            foreground: tonosForegroundForSurface(context, surface),
            secondaryForeground: tonosSecondaryForegroundForSurface(
              context,
              surface,
            ),
            heatmapLow: tonosHeatmapLowForSurface(context, surface),
            primarySeries: tonosPrimarySeriesForSurface(context, surface),
            secondarySeries: tonosSecondarySeriesForSurface(context, surface),
          );
          return const SizedBox.shrink();
        },
      ),
    ),
  );

  return observed;
}
