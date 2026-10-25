import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/content_models.dart';
import 'package:env_test/models/definition_models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/content_repository.dart';
import 'package:env_test/screens/exercise/gym_profile_screen.dart';
import 'package:env_test/theme/expressive_planning_tokens.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/widgets/shared_entity_media_thumbnail.dart';

void main() {
  for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
    testWidgets('Expressive $brightness equipment layout stays usable', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.gym_profile_editor_v1': true,
      });
      await tester.binding.setSurfaceSize(const Size(411, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: _GymProfileRepository()),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            theme: theme,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const GymProfileScreen(
              initialName: 'Home gym',
              initialEquipmentNames: {'Barbell'},
              returnDraftOnly: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      final strings = AppLocalizations.of(
        tester.element(find.byType(GymProfileScreen)),
      );
      final reset = find.widgetWithText(TextButton, strings.commonReset);
      final selectAll = find.widgetWithText(
        FilledButton,
        strings.gymProfileSelectAll,
      );
      expect(reset, findsOneWidget);
      expect(selectAll, findsOneWidget);
      expect(tester.widget<TextButton>(reset).onPressed, isNotNull);
      expect(tester.widget<FilledButton>(selectAll).onPressed, isNotNull);
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsNothing);
      final heading = find.text(strings.gymProfileEquipment);
      expect(tester.getRect(heading).right, lessThanOrEqualTo(395));
      expect(
        tester.getCenter(heading).dy,
        closeTo(tester.getCenter(reset).dy, 1),
      );
      expect(
        tester.getCenter(reset).dy,
        closeTo(tester.getCenter(selectAll).dy, 1),
      );

      await tester.tap(selectAll);
      await tester.pumpAndSettle();
      expect(tester.widget<TextButton>(reset).onPressed, isNotNull);
      expect(tester.widget<FilledButton>(selectAll).onPressed, isNotNull);
      expect(fab, findsOneWidget);
      final planning = brightness == Brightness.light
          ? AppExpressivePlanningTokens.light
          : AppExpressivePlanningTokens.dark;
      expect(
        tester.widget<FloatingActionButton>(fab).shape,
        RoundedRectangleBorder(borderRadius: planning.rowShape),
      );

      await tester.tap(reset);
      await tester.pumpAndSettle();
      expect(tester.widget<TextButton>(reset).onPressed, isNotNull);
      expect(tester.widget<FilledButton>(selectAll).onPressed, isNotNull);
      expect(fab, findsNothing);

      final nameField = find.byType(TextFormField);
      await tester.enterText(nameField, 'Home gym updated');
      await tester.pumpAndSettle();
      expect(fab, findsOneWidget);
      final list = tester.widget<ListView>(find.byType(ListView));
      expect((list.padding! as EdgeInsets).bottom, greaterThanOrEqualTo(100));
      tester.view.viewInsets = FakeViewPadding(
        bottom: 260 * tester.view.devicePixelRatio,
      );
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.getBottomRight(fab).dy, lessThanOrEqualTo(900 - 260));
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(strings.gymProfileSaveChangesTitle), findsOneWidget);
      await tester.tap(find.text(strings.gymProfileKeepEditing));
      await tester.pumpAndSettle();
      await tester.enterText(nameField, 'Home gym');
      await tester.pumpAndSettle();
      expect(fab, findsNothing);
      tester.testTextInput.hide();

      final nameInput = tester
          .widgetList<InputDecorator>(find.byType(InputDecorator))
          .singleWhere(
            (decorator) =>
                decorator.decoration.hintText == strings.gymProfileNameHint,
          );
      expect(nameInput.decoration.labelText, isNull);
      expect(find.text(strings.gymProfileName), findsOneWidget);

      expect(
        find.widgetWithText(OutlinedButton, strings.commonCancel),
        findsNothing,
      );
      expect(find.text(strings.equipmentFreeWeightTraining), findsNothing);

      final categoryLabel = find.text(strings.equipmentCategoryFreeWeights);
      final categoryContainer = tester.widget<Container>(
        find
            .ancestor(
              of: categoryLabel,
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Container &&
                    widget.decoration is BoxDecoration &&
                    (widget.decoration! as BoxDecoration).border != null,
              ),
            )
            .first,
      );
      final categorySurface =
          (categoryContainer.decoration! as BoxDecoration).color;
      final categoryInk = tester.widget<Material>(
        find.ancestor(of: categoryLabel, matching: find.byType(Material)).first,
      );
      expect(categoryInk.type, MaterialType.transparency);
      expect(categoryContainer.clipBehavior, Clip.antiAlias);
      expect(
        categorySurface,
        Color.alphaBlend(
          (brightness == Brightness.light
                  ? AppExpressivePlanningTokens.light
                  : AppExpressivePlanningTokens.dark)
              .configurationSurface
              .withValues(alpha: brightness == Brightness.light ? 0.38 : 0.8),
          (brightness == Brightness.light
                  ? AppExpressivePlanningTokens.light
                  : AppExpressivePlanningTokens.dark)
              .pageCanvas,
        ),
      );

      final search = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == strings.gymProfileFilterEquipment,
      );
      expect(
        tester.widget<TextField>(search).decoration!.prefixIcon,
        isA<Icon>(),
      );
      expect(
        (tester.widget<TextField>(search).decoration!.prefixIcon! as Icon).icon,
        Icons.filter_list,
      );
      await tester.enterText(search, 'Assisted');
      await tester.pumpAndSettle();
      final longLabel = find.text('Assisted Dip/Pull-Up Machine');
      await tester.ensureVisible(longLabel);
      await tester.pumpAndSettle();
      final thumbnail = find.byType(SharedEntityMediaThumbnail);
      final checkbox = find.byType(Checkbox);
      expect(tester.getSize(thumbnail), const Size(42, 42));
      expect(
        tester.getCenter(checkbox).dy,
        closeTo(tester.getCenter(thumbnail).dy, 1),
      );
      expect(tester.getSize(checkbox).height, greaterThanOrEqualTo(48));
      expect(tester.widget<Text>(longLabel).maxLines, isNull);
      expect(tester.widget<Text>(longLabel).overflow, isNull);
      expect(fab, findsNothing);
      final category = find.text(strings.equipmentCategoryBenchesRacks);
      final section = find
          .ancestor(
            of: category,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration! as BoxDecoration).border != null,
            ),
          )
          .first;
      final expandedHeight = tester.getSize(section).height;
      await tester.tap(category);
      await tester.pumpAndSettle();
      expect(tester.getSize(section).height, lessThan(expandedHeight));
      await tester.tap(category);
      await tester.pumpAndSettle();
      expect(tester.getSize(section).height, closeTo(expandedHeight, 1));
      expect(tester.takeException(), isNull);
    });
  }
}

class _GymProfileRepository extends AppRepository {
  @override
  Future<List<Equipment>> fetchAllEquipment() async => [
    Equipment(1, 'Barbell'),
    Equipment(2, 'Dumbbell'),
    Equipment(3, 'Cable Attachment'),
    Equipment(4, 'Kettlebell'),
    Equipment(5, 'Adjustable Bench'),
    Equipment(6, 'Assisted Dip/Pull-Up Machine'),
    Equipment(7, 'Glute-Ham Developer'),
  ];

  @override
  Future<void> ensureSharedMediaManifestReady() async {}

  @override
  Stream<ContentMediaCacheChange> get mediaCacheChanges =>
      const Stream<ContentMediaCacheChange>.empty();

  @override
  Future<SharedMediaItem?> fetchPrimarySharedMedia(
    SharedMediaEntityType entityType,
    int entityId,
  ) async => null;
}
