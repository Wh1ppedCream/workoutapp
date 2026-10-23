import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/gym_models.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/widgets/drawers.dart';

void main() {
  final profile = GymProfile(
    id: 1,
    name: 'A long equipment profile name that should remain readable',
    createdAt: DateTime.utc(2026),
  );

  for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
    testWidgets('Expressive $brightness profile drawer uses tonal actions', (
      tester,
    ) async {
      dynamic selected;
      dynamic edited;
      dynamic deleted;
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            endDrawer: ProfileDrawer(
              profiles: [profile],
              selected: profile,
              onSelect: (value) => selected = value,
              onEdit: (value) => edited = value,
              onDelete: (value) => deleted = value,
            ),
          ),
        ),
      );

      tester.state<ScaffoldState>(find.byType(Scaffold)).openEndDrawer();
      await tester.pumpAndSettle();

      final drawer = tester.widget<Drawer>(find.byType(Drawer));
      expect(
        drawer.backgroundColor,
        brightness == Brightness.dark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surfaceContainerLow,
      );
      expect(drawer.surfaceTintColor, Colors.transparent);
      expect(find.byType(ModalBarrier), findsWidgets);

      final tileFinder = find.byType(ProfileTile);
      expect(tileFinder, findsOneWidget);
      final tile = tester.widget<ProfileTile>(tileFinder);
      expect(tile.color, ProfileIdentityPalette.colors.first);
      expect(tile.selectionColor, theme.colorScheme.primary);
      final tileDecoration =
          tester
                  .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration!
              as BoxDecoration;
      expect(
        (tileDecoration.border! as Border).top.color,
        theme.colorScheme.primary,
      );
      expect(find.text(profile.name), findsOneWidget);
      expect(
        find.text(
          AppLocalizations.of(tester.element(tileFinder))
              .drawerProfileActive(profile.name),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(profile.name));
      expect(selected, same(profile));

      final menuButton = tester.widget<PopupMenuButton<String>>(
        find.byType(PopupMenuButton<String>),
      );
      expect(menuButton.color, theme.colorScheme.surfaceContainerHigh);
      expect(menuButton.shape, isA<RoundedRectangleBorder>());
      expect(menuButton.constraints?.minWidth, greaterThanOrEqualTo(48));
      expect(menuButton.constraints?.minHeight, greaterThanOrEqualTo(48));
      expect(menuButton.position, isNull);
      expect(menuButton.offset, Offset.zero);
      expect(menuButton.onSelected, isNotNull);
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(
        tester
            .widgetList<PopupMenuItem<String>>(
              find.byType(PopupMenuItem<String>),
            )
            .map((item) => item.height),
        everyElement(44),
      );
      expect(
        tester.getRect(find.byType(PopupMenuItem<String>).last).bottom,
        lessThanOrEqualTo(
          tester.view.physicalSize.height / tester.view.devicePixelRatio,
        ),
      );
      final deleteLabel = find.text(
        AppLocalizations.of(tester.element(find.byType(ProfileTile)))
            .commonDelete,
      );
      expect(
        tester.widget<Text>(deleteLabel).style?.color,
        theme.colorScheme.error,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(deleteLabel);
      await tester.pumpAndSettle();
      expect(deleted, same(profile));
      expect(edited, isNull);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      expect(edited, same(profile));
    });
  }

  for (final family in <AppThemeFamily>[
    AppThemeFamily.classic,
    AppThemeFamily.neoBrutalism,
  ]) {
    testWidgets('$family drawer retains legacy selection and menu styling', (
      tester,
    ) async {
      final theme = AppThemeFactory.light(family);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            endDrawer: ProfileDrawer(
              profiles: [profile],
              selected: profile,
              onSelect: (_) {},
              onEdit: (_) {},
              onDelete: (_) {},
            ),
          ),
        ),
      );

      tester.state<ScaffoldState>(find.byType(Scaffold)).openEndDrawer();
      await tester.pumpAndSettle();
      final tile = tester.widget<ProfileTile>(find.byType(ProfileTile));
      expect(tile.selectionColor, ProfileIdentityPalette.colors.first);

      final menuButton = tester.widget<PopupMenuButton<String>>(
        find.byType(PopupMenuButton<String>),
      );
      expect(menuButton.shape, isNull);
      expect(menuButton.color, isNull);
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
