import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/data_records_section.dart';

void main() {
  testWidgets('date-cell outlines stay visible in all four theme modes', (
    tester,
  ) async {
    for (final family in AppThemeFamily.values) {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        final lightTheme = AppThemeFactory.light(family);
        final darkTheme = AppThemeFactory.dark(family);
        final theme = brightness == Brightness.light ? lightTheme : darkTheme;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Theme(
              data: theme,
              child: const Scaffold(body: DataRecordsSection()),
            ),
          ),
        );

        final dateCells = find.byWidgetPredicate((widget) {
          if (widget is! Container) return false;
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.shape == BoxShape.circle;
        });
        expect(dateCells, findsNWidgets(28));

        final outlinedNeoDark =
            theme.surfaceDecorationTokens.panel.outlined &&
            brightness == Brightness.dark;
        final expectedDayBorder =
            outlinedNeoDark
                ? theme.surfaceTokens.neutralOutline
                : theme.surfaceTokens.divider;
        final todayBorder = theme.dataVisualizationTokens.recordTodayBorder;
        final todayFill = theme.dataVisualizationTokens.recordTodayContainer;
        var todayCellCount = 0;

        for (final cell in tester.widgetList<Container>(dateCells)) {
          final decoration = cell.decoration! as BoxDecoration;
          if (decoration.color == todayFill) {
            todayCellCount++;
            expect(decoration.border!.top.color, todayBorder);
          } else {
            expect(decoration.border!.top.color, expectedDayBorder);
          }
        }
        expect(todayCellCount, 1);

        if (outlinedNeoDark) {
          expect(
            _contrastRatio(expectedDayBorder, theme.scaffoldBackgroundColor),
            greaterThanOrEqualTo(3),
          );
        }
      }
    }
  });
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter =
      firstLuminance > secondLuminance ? firstLuminance : secondLuminance;
  final darker =
      firstLuminance > secondLuminance ? secondLuminance : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
