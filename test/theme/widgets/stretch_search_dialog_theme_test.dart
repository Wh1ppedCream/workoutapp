import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/stretch_search_dialog.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode Stretch Search dropdowns remain readable', (
        tester,
      ) async {
        final repository = _StretchRepository();
        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: repository,
            child: MaterialApp(
              theme: theme,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder:
                      (context) => Center(
                        child: TextButton(
                          onPressed: () => StretchSearchDialog.show(context),
                          child: const Text('Open search'),
                        ),
                      ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open search'));
        await tester.pumpAndSettle();
        expect(find.text('Body Part'), findsOneWidget);

        await tester.tap(find.byType(DropdownButtonFormField<int>).first);
        await tester.pumpAndSettle();
        _expectReadableOption(
          tester,
          'Upper Body',
          theme,
          family: family,
          brightness: brightness,
        );
        await tester.tap(find.text('Upper Body'));
        await tester.pumpAndSettle();

        expect(find.text('Stretch'), findsOneWidget);
        await tester.tap(find.byType(DropdownButtonFormField<int>).last);
        await tester.pumpAndSettle();
        _expectReadableOption(
          tester,
          'Cat-Cow',
          theme,
          family: family,
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}

void _expectReadableOption(
  WidgetTester tester,
  String label,
  ThemeData appTheme, {
  required AppThemeFamily family,
  required Brightness brightness,
}) {
  final option = find.text(label);
  expect(option, findsOneWidget);

  final optionContext = tester.element(option);
  final popupTheme = Theme.of(optionContext);
  final popupForeground =
      tester.renderObject<RenderParagraph>(option).text.style?.color ??
      popupTheme.textTheme.titleMedium?.color ??
      popupTheme.colorScheme.onSurface;
  final popupMaterialFinder = find.ancestor(
    of: option,
    matching: find.byType(Material),
  );
  final popupMaterial = tester.widget<Material>(popupMaterialFinder.first);
  final popupSurface = popupMaterial.color ?? popupTheme.canvasColor;
  final darkNeo =
      family == AppThemeFamily.neoBrutalism && brightness == Brightness.dark;

  if (darkNeo) {
    expect(
      popupSurface,
      appTheme.dialogTheme.backgroundColor ?? appTheme.surfaceTokens.dialog,
    );
  }
  expect(
    _contrastRatio(popupForeground, popupSurface),
    greaterThanOrEqualTo(4.5),
  );
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = math.max(foregroundLuminance, backgroundLuminance);
  final darker = math.min(foregroundLuminance, backgroundLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}

class _StretchRepository extends AppRepository {
  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => [
    BodyPart(1, 'Upper Body'),
  ];

  @override
  Future<List<StretchDefinition>> fetchStretches({int? bodypartId}) async => [
    StretchDefinition(
      id: 1,
      name: 'Cat-Cow',
      description: 'Gentle spine mobility.',
      bodyParts: [BodyPart(1, 'Upper Body')],
    ),
  ];
}
