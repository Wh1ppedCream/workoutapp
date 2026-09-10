import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/screens/nutrition/food_customization_page.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_nutrition_tokens.dart';

void main() {
  for (final save in [true, false]) {
    testWidgets(
      'food editor ${save ? 'saves edited payload' : 'cancels without payload'}',
      (tester) async {
        Map<String, dynamic>? result;
        var returned = false;
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            theme: ClassicThemeDefinition.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: TextButton(
                      onPressed: () async {
                        result = await Navigator.of(
                          context,
                        ).push<Map<String, dynamic>>(
                          MaterialPageRoute(
                            builder:
                                (_) => const FoodCustomizationPage(
                                  initialFoodId: 42,
                                  initialName: 'Original',
                                  initialBrand: 'Test brand',
                                  initialCalories: 123,
                                  initialProteinG: 10,
                                  initialCarbsG: 5,
                                  initialFatsG: 7,
                                ),
                          ),
                        );
                        returned = true;
                      },
                      child: const Text('Open editor'),
                    ),
                  ),
            ),
          ),
        );
        await tester.tap(find.text('Open editor'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).first, 'Edited food');
        final strings = AppLocalizations.of(
          tester.element(find.byType(FoodCustomizationPage)),
        );
        final action = find.text(
          save ? strings.commonSave : strings.commonCancel,
        );
        await tester.ensureVisible(action);
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(returned, isTrue);
        if (save) {
          expect(result, containsPair('food_id', 42));
          expect(result, containsPair('name', 'Edited food'));
          expect(result, containsPair('brand', 'Test brand'));
          expect(result, containsPair('KCAL', 123));
          expect(result, containsPair('PROTEIN_G', 10));
          expect(result, containsPair('CARB_G', 5));
          expect(result, containsPair('FAT_G', 7));
          expect(result!['portions'], isA<List>());
        } else {
          expect(result, isNull);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
  test('editor media recipes retain Classic and support overrides', () {
    final base = ClassicThemeDefinition.light().mediaTokens;
    expect(base.editorAddSurface, const Color(0xFFEEEEEE));
    expect(base.editorItemSurface, const Color(0xFFE0E0E0));
    expect(base.editorShape, BorderRadius.circular(12));
    final target = base.copyWith(
      editorAddSurface: Colors.red,
      editorItemSurface: Colors.blue,
      editorShape: BorderRadius.circular(20),
    );
    expect(target.editorAddSurface, Colors.red);
    expect(target.editorItemSurface, Colors.blue);
    expect(target.editorShape, BorderRadius.circular(20));
    final mid = base.lerp(target, 0.5);
    expect(
      mid.editorAddSurface,
      Color.lerp(base.editorAddSurface, Colors.red, 0.5),
    );
    expect(
      mid.editorItemSurface,
      Color.lerp(base.editorItemSurface, Colors.blue, 0.5),
    );
    expect(mid.editorShape, BorderRadius.circular(16));
  });
  test('Classic food recipes retain their original values in both modes', () {
    for (final theme in [
      ClassicThemeDefinition.light(),
      ClassicThemeDefinition.dark(),
    ]) {
      final tokens = theme.nutritionTokens;
      expect(tokens.foodBorder, const Color(0xFFE0E0E0));
      expect(tokens.photoPlaceholder, const Color(0xFFEEEEEE));
      expect(tokens.mutedAction, const Color(0xFF9E9E9E));
      expect(tokens.favoriteAction, const Color(0xFFFFC107));
      expect(tokens.addFoodAction, const Color(0xFF4CAF50));
      expect(tokens.densityHelp, Colors.black54);
      expect(tokens.selectedLabel, Colors.white);
      expect(tokens.logGrid, const Color(0xFFEEEEEE));
      expect(tokens.compactShape, const BorderRadius.all(Radius.circular(8)));
      expect(tokens.sectionShape, const BorderRadius.all(Radius.circular(12)));
      expect(tokens.portionShape, const BorderRadius.all(Radius.circular(10)));
      expect(tokens.quantityShape, const BorderRadius.all(Radius.circular(6)));
    }
  });

  test('food recipes copy and interpolate without dropping fields', () {
    final base = AppNutritionTokens.classic(Brightness.light);
    final target = base.copyWith(
      foodBorder: Colors.pink,
      photoPlaceholder: Colors.pink,
      mutedAction: Colors.pink,
      favoriteAction: Colors.pink,
      addFoodAction: Colors.pink,
      densityHelp: Colors.pink,
      selectedLabel: Colors.pink,
      logGrid: Colors.pink,
      compactShape: BorderRadius.circular(19),
      sectionShape: BorderRadius.circular(19),
      portionShape: BorderRadius.circular(19),
      quantityShape: BorderRadius.circular(19),
    );
    final mid = base.lerp(target, 0.5);
    expect(base.copyWith().foodBorder, base.foodBorder);
    expect(target.foodBorder, Colors.pink);
    expect(mid.foodBorder, Color.lerp(base.foodBorder, target.foodBorder, 0.5));
    expect(base.copyWith().photoPlaceholder, base.photoPlaceholder);
    expect(target.photoPlaceholder, Colors.pink);
    expect(
      mid.photoPlaceholder,
      Color.lerp(base.photoPlaceholder, target.photoPlaceholder, 0.5),
    );
    expect(base.copyWith().mutedAction, base.mutedAction);
    expect(target.mutedAction, Colors.pink);
    expect(
      mid.mutedAction,
      Color.lerp(base.mutedAction, target.mutedAction, 0.5),
    );
    expect(base.copyWith().favoriteAction, base.favoriteAction);
    expect(target.favoriteAction, Colors.pink);
    expect(
      mid.favoriteAction,
      Color.lerp(base.favoriteAction, target.favoriteAction, 0.5),
    );
    expect(base.copyWith().addFoodAction, base.addFoodAction);
    expect(target.addFoodAction, Colors.pink);
    expect(
      mid.addFoodAction,
      Color.lerp(base.addFoodAction, target.addFoodAction, 0.5),
    );
    expect(base.copyWith().densityHelp, base.densityHelp);
    expect(target.densityHelp, Colors.pink);
    expect(
      mid.densityHelp,
      Color.lerp(base.densityHelp, target.densityHelp, 0.5),
    );
    expect(base.copyWith().selectedLabel, base.selectedLabel);
    expect(target.selectedLabel, Colors.pink);
    expect(
      mid.selectedLabel,
      Color.lerp(base.selectedLabel, target.selectedLabel, 0.5),
    );
    expect(base.copyWith().logGrid, base.logGrid);
    expect(target.logGrid, Colors.pink);
    expect(mid.logGrid, Color.lerp(base.logGrid, target.logGrid, 0.5));
    expect(base.copyWith().compactShape, base.compactShape);
    expect(target.compactShape, BorderRadius.circular(19));
    expect(
      mid.compactShape,
      BorderRadius.lerp(base.compactShape, target.compactShape, 0.5),
    );
    expect(base.copyWith().sectionShape, base.sectionShape);
    expect(target.sectionShape, BorderRadius.circular(19));
    expect(
      mid.sectionShape,
      BorderRadius.lerp(base.sectionShape, target.sectionShape, 0.5),
    );
    expect(base.copyWith().portionShape, base.portionShape);
    expect(target.portionShape, BorderRadius.circular(19));
    expect(
      mid.portionShape,
      BorderRadius.lerp(base.portionShape, target.portionShape, 0.5),
    );
    expect(base.copyWith().quantityShape, base.quantityShape);
    expect(target.quantityShape, BorderRadius.circular(19));
    expect(
      mid.quantityShape,
      BorderRadius.lerp(base.quantityShape, target.quantityShape, 0.5),
    );
  });

  testWidgets(
    'food editor keeps unsaved text while injected presentation updates',
    (tester) async {
      final base = ClassicThemeDefinition.light();
      Widget host(Color placeholder) => MaterialApp(
        theme: base.copyWith(
          extensions: [
            ...base.extensions.values.where(
              (value) => value is! AppNutritionTokens,
            ),
            base.nutritionTokens.copyWith(photoPlaceholder: placeholder),
          ],
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FoodCustomizationPage(initialName: 'Original'),
      );
      await tester.pumpWidget(host(Colors.orange));
      await tester.pumpAndSettle();
      final name = find.byType(TextFormField).first;
      await tester.enterText(name, 'Unsaved food');
      await tester.pumpWidget(host(Colors.teal));
      await tester.pumpAndSettle();
      expect(find.text('Unsaved food'), findsOneWidget);
      expect(
        tester
            .widgetList<Container>(find.byType(Container))
            .where((c) => c.color == Colors.teal)
            .length,
        2,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
