import 'package:env_test/db/database_helper.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/exercise_editor_screen.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_dialog.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Expressive muscle picker is bounded, centered, searchable, and applies only Add',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _ExerciseEditorInteractionRepository();
      await _pumpExerciseEditor(tester, repository);
      final strings = AppLocalizations.of(
        tester.element(find.byType(ExerciseEditorScreen)),
      );
      await _createCustomExercise(tester, strings);

      final compactMuscleRow = find.byKey(
        const ValueKey('exercise-editor-muscle-row-1'),
      );
      await tester.ensureVisible(compactMuscleRow);
      expect(compactMuscleRow, findsOneWidget);
      expect(
        tester.getSize(compactMuscleRow).height,
        lessThanOrEqualTo(72),
        reason: 'Normal-width editing keeps rank, name, and actions compact.',
      );
      for (final tooltip in [
        strings.exerciseEditorMoveUp,
        strings.exerciseEditorMoveDown,
        strings.exerciseEditorRemoveMuscle,
      ]) {
        final action = find.descendant(
          of: compactMuscleRow,
          matching: find.byWidgetPredicate(
            (widget) => widget is IconButton && widget.tooltip == tooltip,
          ),
        );
        expect(action, findsOneWidget);
        expect(tester.getSize(action), const Size(48, 48));
        final onPressed = tester.widget<IconButton>(action).onPressed;
        expect(
          onPressed,
          tooltip == strings.exerciseEditorRemoveMuscle ? isNotNull : isNull,
        );
      }

      final addMuscles = find.text(strings.exerciseEditorAddTargetMuscles);
      final editorList = find.byType(ListView).first;
      await tester.dragUntilVisible(
        addMuscles,
        editorList,
        const Offset(0, -400),
      );
      await tester.ensureVisible(addMuscles);
      await tester.pumpAndSettle();
      expect(addMuscles.hitTestable(), findsOneWidget);
      await tester.tap(addMuscles);
      await tester.pumpAndSettle();
      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      final dialogSurface = find
          .descendant(of: dialog, matching: find.byType(Material))
          .first;
      final dialogSurfaceRect = tester.getRect(dialogSurface);
      expect(dialogSurfaceRect.width, lessThanOrEqualTo(560));
      expect(dialogSurfaceRect.height, lessThan(844));
      expect(
        (dialogSurfaceRect.center - const Offset(195, 422)).distance,
        lessThan(28),
        reason: 'The picker remains centered in the available viewport.',
      );
      expect(
        find.byType(TonosDialogFrame),
        findsOneWidget,
        reason: 'The picker keeps the shared dialog presentation boundary.',
      );
      final selectionList = find.descendant(
        of: dialog,
        matching: find.byType(ListView),
      );
      final selectionListRect = tester.getRect(selectionList.first);
      expect(
        selectionListRect.height % 44,
        closeTo(0, 0.001),
        reason: 'The clipped viewport ends between compact selection rows.',
      );
      expect(
        selectionListRect.bottom,
        lessThan(
          tester
              .getRect(
                find.descendant(
                  of: dialog,
                  matching: find.text(strings.commonCancel),
                ),
              )
              .top,
        ),
        reason: 'The scrollable rows remain separate from dialog actions.',
      );

      final latissimus = find.widgetWithText(
        CheckboxListTile,
        'Latissimus dorsi',
      );
      await tester.ensureVisible(latissimus);
      await tester.tap(latissimus);
      await tester.pumpAndSettle();

      final search = find.descendant(
        of: dialog,
        matching: find.byType(TextField),
      );
      await tester.enterText(search, 'triceps');
      await tester.pumpAndSettle();
      expect(find.text('Latissimus dorsi'), findsNothing);
      final triceps = find.widgetWithText(CheckboxListTile, 'Triceps');
      await tester.ensureVisible(triceps);
      await tester.tap(triceps);
      await tester.pumpAndSettle();

      await tester.enterText(search, 'latissimus');
      await tester.pumpAndSettle();
      expect(
        tester.widget<CheckboxListTile>(latissimus).value,
        isTrue,
        reason: 'Filtering the list preserves its staged selection.',
      );
      await tester.enterText(search, 'triceps');
      await tester.pumpAndSettle();
      expect(tester.widget<CheckboxListTile>(triceps).value, isTrue);

      await tester.tap(
        find.descendant(of: dialog, matching: find.text(strings.commonCancel)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Latissimus dorsi'), findsNothing);
      expect(find.text('Triceps'), findsNothing);

      await tester.dragUntilVisible(
        addMuscles,
        editorList,
        const Offset(0, -400),
      );
      await tester.ensureVisible(addMuscles);
      expect(addMuscles.hitTestable(), findsOneWidget);
      await tester.tap(addMuscles);
      await tester.pumpAndSettle();
      final addDialog = find.byType(AlertDialog);
      final addSearch = find.descendant(
        of: addDialog,
        matching: find.byType(TextField),
      );
      final addLatissimus = find.widgetWithText(
        CheckboxListTile,
        'Latissimus dorsi',
      );
      await tester.ensureVisible(addLatissimus);
      await tester.tap(addLatissimus);
      await tester.pumpAndSettle();
      await tester.enterText(addSearch, 'triceps');
      await tester.pumpAndSettle();
      final addTriceps = find.widgetWithText(CheckboxListTile, 'Triceps');
      await tester.ensureVisible(addTriceps);
      await tester.tap(addTriceps);
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.commonAdd));
      await tester.pumpAndSettle();

      expect(find.text('Pectorals'), findsOneWidget);
      expect(find.text('Latissimus dorsi'), findsOneWidget);
      expect(find.text('Triceps'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Expressive equipment choice stays anchored and bounded at normal and narrow widths',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final size in [const Size(390, 844), const Size(320, 568)]) {
        await tester.binding.setSurfaceSize(size);
        final repository = _ExerciseEditorInteractionRepository();
        await _pumpExerciseEditor(tester, repository);
        final strings = AppLocalizations.of(
          tester.element(find.byType(ExerciseEditorScreen)),
        );
        final create = find.text(strings.exerciseEditorCreateCustomTitle);
        final landingList = find.byType(ListView).first;
        final landingScrollable = find.descendant(
          of: landingList,
          matching: find.byType(Scrollable),
        );
        await tester.scrollUntilVisible(
          create,
          120,
          scrollable: landingScrollable.first,
        );
        await tester.ensureVisible(create);
        await tester.tap(create);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).first, 'Cable Press');
        final anchor = find.byKey(
          const ValueKey('exercise-editor-equipment-choice'),
        );
        await tester.ensureVisible(anchor);
        await tester.tap(
          find.descendant(of: anchor, matching: find.byType(InputDecorator)),
        );
        await tester.pumpAndSettle();

        final option = find.byKey(
          const ValueKey('exercise-editor-equipment-1'),
        );
        expect(option.hitTestable(), findsOneWidget);
        final optionRect = tester.getRect(option);
        expect(optionRect.left, greaterThanOrEqualTo(0));
        expect(optionRect.right, lessThanOrEqualTo(size.width));
        expect(optionRect.top, greaterThanOrEqualTo(0));
        expect(optionRect.bottom, lessThanOrEqualTo(size.height));
        expect(optionRect.height, lessThan(size.height / 2));
        await tester.tap(option);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          find.descendant(of: anchor, matching: find.text('Cable machine')),
          findsOneWidget,
        );
        await tester.tap(find.text(strings.healthCreate));
        await tester.pumpAndSettle();
        expect(repository.createdEquipmentName, 'Cable machine');
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Expressive editor keeps pending edits on Keep Editing, discards on Cancel, and saves valid Rating',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _ExerciseEditorInteractionRepository();
      await _pumpExerciseEditor(tester, repository);
      final strings = AppLocalizations.of(
        tester.element(find.byType(ExerciseEditorScreen)),
      );
      await _createCustomExercise(tester, strings);

      final name = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == strings.exerciseEditorExerciseName,
      );
      await tester.enterText(name, 'Pending Press');
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('exercise-editor-save-fab')),
        findsOneWidget,
        reason: 'The save action appears after an edit is made.',
      );
      await tester.tap(find.byTooltip(strings.commonCancel));
      await tester.pumpAndSettle();
      expect(find.text(strings.exerciseEditorDiscardTitle), findsOneWidget);
      await tester.tap(find.text(strings.exerciseEditorKeepEditing));
      await tester.pumpAndSettle();
      expect(name, findsOneWidget);
      expect(tester.widget<TextField>(name).controller!.text, 'Pending Press');

      await tester.tap(find.byTooltip(strings.commonCancel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.exerciseEditorDiscard));
      await tester.pumpAndSettle();
      expect(find.text('Custom Press'), findsOneWidget);
      expect(repository.savedWrites, isEmpty);

      final edit = find.text(strings.exerciseEditorEdit);
      expect(edit, findsOneWidget);
      await tester.tap(edit);
      await tester.pumpAndSettle();
      final rating = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == strings.exerciseEditorRating,
      );
      await tester.enterText(rating, '91');
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.exerciseEditorSaveChanges));
      await tester.pumpAndSettle();

      expect(repository.savedWrites, hasLength(1));
      expect(repository.savedWrites.single.definition.rating, 91);
      expect(name, findsNothing, reason: 'A successful save exits edit mode.');
      expect(find.text('Custom Press'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _pumpExerciseEditor(
  WidgetTester tester,
  _ExerciseEditorInteractionRepository repository,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    MultiProvider(
      providers: [Provider<AppRepository>.value(value: repository)],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF345B50)),
          extensions: const [
            AppThemeIdentity(family: AppThemeFamilyIdentity.expressivePreview),
          ],
        ),
        themeAnimationDuration: Duration.zero,
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ExerciseEditorScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _createCustomExercise(
  WidgetTester tester,
  AppLocalizations strings,
) async {
  await tester.tap(find.text(strings.exerciseEditorCreateCustomTitle));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).first, 'Custom Press');
  await tester.tap(find.text(strings.healthCreate));
  await tester.pumpAndSettle();
  expect(find.text('Custom Press'), findsOneWidget);
  expect(find.byType(SettingsSaveBar), findsNothing);
  expect(
    find.byKey(const ValueKey('exercise-editor-save-fab')),
    findsNothing,
    reason: 'A clean editing draft does not show the save action.',
  );
}

class _ExerciseEditorInteractionRepository extends AppRepository {
  _ExerciseEditorInteractionRepository()
    : super(db: _ExerciseEditorInteractionDatabase());

  final BodyPart _chest = BodyPart(1, 'Chest');
  final BodyPart _back = BodyPart(2, 'Back');
  final Muscle _pectorals = Muscle(id: 1, name: 'Pectorals');
  final Muscle _latissimus = Muscle(id: 2, name: 'Latissimus dorsi');
  final Muscle _triceps = Muscle(id: 3, name: 'Triceps');
  final Equipment _cable = Equipment(1, 'Cable machine');

  ExerciseDefinition? _definition;
  String? createdEquipmentName;
  final List<ExerciseDefinitionWrite> savedWrites = [];

  ExerciseDefinition _makeDefinition(String name) => ExerciseDefinition(
    id: 1,
    name: name,
    rating: 80,
    bodyParts: [_chest],
    muscles: [RankedMuscle(muscle: _pectorals, rank: 1)],
    useManualBodyparts: false,
    multiplyByRating: false,
  );

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => const [];

  @override
  Future<List<Equipment>> fetchAllEquipment() async => [_cable];

  @override
  Future<List<BodyPart>> fetchAllBodyPartsFull() async => [_chest, _back];

  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => [
    _pectorals,
    _latissimus,
    _triceps,
  ];

  @override
  Future<int> findOrCreateExerciseDefinition(
    String name,
    String equipmentName,
  ) async {
    createdEquipmentName = equipmentName;
    _definition = _makeDefinition(name);
    return _definition!.id;
  }

  @override
  Future<ExerciseDefinition?> fetchDefinitionById(int defId) async =>
      _definition;

  @override
  Future<void> saveExerciseDefinitionAtomic(
    ExerciseDefinitionWrite write,
  ) async {
    savedWrites.add(write);
    _definition = write.definition;
  }

  @override
  Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) async =>
      const [];

  @override
  Future<bool> getUseManualMuscles(int defId) async => false;

  @override
  Future<Map<BodyPart, double>> computeMuscleCalculatedBodyparts(
    int defId,
  ) async => {_chest: 1};

  @override
  Future<List<ExerciseBodyPartPercent>> fetchBodyPartPercentsManual(
    int defId,
  ) async => const [];

  @override
  Future<bool> getUseManualBodyparts(int defId) async => false;

  @override
  Future<List<ExerciseMediaItem>> fetchExerciseMedia(int defId) async =>
      const [];

  @override
  Future<bool> getMultiplyByRating(int defId) async => false;
}

class _ExerciseEditorInteractionDatabase implements DatabaseHelper {
  @override
  Future<List<GymProfile>> fetchAllProfiles() async => const [];

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
