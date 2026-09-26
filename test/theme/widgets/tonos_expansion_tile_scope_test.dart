import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/widgets/tonos_expansion_tile_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('standard scope only hides expansion dividers', (tester) async {
    for (final theme in _themeMatrix()) {
      final themes = await _resolveScopedTheme(
        tester,
        theme,
        (child) => TonosExpansionTileScope(child: child),
      );
      final scoped = themes.scoped;

      expect(scoped.dividerColor, Colors.transparent);
      expect(scoped.listTileTheme, themes.parent.listTileTheme);
      expect(scoped.iconTheme, themes.parent.iconTheme);
      _expectUnrelatedThemeRolesPreserved(scoped, themes.parent);
    }
  });

  testWidgets('compact scope preserves its density recipe in every mode', (
    tester,
  ) async {
    for (final theme in _themeMatrix()) {
      final themes = await _resolveScopedTheme(
        tester,
        theme,
        (child) => TonosExpansionTileScope.compact(child: child),
      );
      final scoped = themes.scoped;

      expect(scoped.dividerColor, Colors.transparent);
      expect(scoped.listTileTheme.dense, isTrue);
      expect(scoped.listTileTheme.minVerticalPadding, 0);
      expect(scoped.listTileTheme.contentPadding, EdgeInsets.zero);
      expect(
        scoped.listTileTheme.visualDensity,
        const VisualDensity(horizontal: 0, vertical: -2),
      );
      expect(scoped.iconTheme.size, 18);
      expect(scoped.iconTheme.color, themes.parent.iconTheme.color);
      expect(scoped.iconTheme.opacity, themes.parent.iconTheme.opacity);
      _expectUnrelatedThemeRolesPreserved(scoped, themes.parent);
    }
  });

  testWidgets('dense scope preserves its denser recipe in every mode', (
    tester,
  ) async {
    for (final theme in _themeMatrix()) {
      final themes = await _resolveScopedTheme(
        tester,
        theme,
        (child) => TonosExpansionTileScope.dense(child: child),
      );
      final scoped = themes.scoped;

      expect(scoped.dividerColor, Colors.transparent);
      expect(scoped.listTileTheme.dense, isTrue);
      expect(scoped.listTileTheme.minVerticalPadding, 0);
      expect(scoped.listTileTheme.contentPadding, EdgeInsets.zero);
      expect(
        scoped.listTileTheme.visualDensity,
        const VisualDensity(horizontal: 0, vertical: -3),
      );
      expect(scoped.iconTheme.size, 18);
      expect(scoped.iconTheme.color, themes.parent.iconTheme.color);
      expect(scoped.iconTheme.opacity, themes.parent.iconTheme.opacity);
      _expectUnrelatedThemeRolesPreserved(scoped, themes.parent);
    }
  });
  testWidgets('density variants retain inherited tile and icon styling', (
    tester,
  ) async {
    for (final theme in _themeMatrix()) {
      final parent = theme.copyWith(
        listTileTheme: theme.listTileTheme.copyWith(
          selectedColor: Colors.pink,
          iconColor: Colors.orange,
          textColor: Colors.teal,
          tileColor: Colors.amber,
          selectedTileColor: Colors.cyan,
          minLeadingWidth: 47,
          enableFeedback: false,
        ),
        iconTheme: theme.iconTheme.copyWith(
          color: Colors.deepPurple,
          opacity: 0.42,
          size: 25,
        ),
      );
      final wrappers = <Widget Function(Widget child)>[
        (child) => TonosExpansionTileScope.compact(child: child),
        (child) => TonosExpansionTileScope.dense(child: child),
      ];

      for (final wrap in wrappers) {
        final themes = await _resolveScopedTheme(tester, parent, wrap);
        final scopedTile = themes.scoped.listTileTheme;
        final parentTile = themes.parent.listTileTheme;

        expect(scopedTile.selectedColor, parentTile.selectedColor);
        expect(scopedTile.iconColor, parentTile.iconColor);
        expect(scopedTile.textColor, parentTile.textColor);
        expect(scopedTile.tileColor, parentTile.tileColor);
        expect(scopedTile.selectedTileColor, parentTile.selectedTileColor);
        expect(scopedTile.minLeadingWidth, parentTile.minLeadingWidth);
        expect(scopedTile.enableFeedback, parentTile.enableFeedback);
        expect(themes.scoped.iconTheme.color, themes.parent.iconTheme.color);
        expect(
          themes.scoped.iconTheme.opacity,
          themes.parent.iconTheme.opacity,
        );
        expect(themes.scoped.iconTheme.size, 18);
      }
    }
  });
}

List<ThemeData> _themeMatrix() => [
  for (final family in [AppThemeFamily.classic, AppThemeFamily.neoBrutalism])
    for (final brightness in Brightness.values)
      brightness == Brightness.light
          ? AppThemeFactory.light(family)
          : AppThemeFactory.dark(family),
];

Future<({ThemeData parent, ThemeData scoped})> _resolveScopedTheme(
  WidgetTester tester,
  ThemeData parent,
  Widget Function(Widget child) wrap,
) async {
  var resolvedParent = parent;
  var resolvedScoped = parent;
  await tester.pumpWidget(
    MaterialApp(
      theme: parent,
      themeAnimationDuration: Duration.zero,
      home: Builder(
        builder: (parentContext) {
          resolvedParent = Theme.of(parentContext);
          return Scaffold(
            body: wrap(
              Builder(
                builder: (context) {
                  resolvedScoped = Theme.of(context);
                  return const ExpansionTile(title: Text('Section'));
                },
              ),
            ),
          );
        },
      ),
    ),
  );
  await tester.pump();

  expect(find.byType(ExpansionTile), findsOneWidget);
  expect(tester.takeException(), isNull);
  return (parent: resolvedParent, scoped: resolvedScoped);
}

void _expectUnrelatedThemeRolesPreserved(ThemeData resolved, ThemeData parent) {
  expect(resolved.colorScheme, parent.colorScheme);
  expect(resolved.textTheme, parent.textTheme);
  expect(resolved.extensions, parent.extensions);
}
