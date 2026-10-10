import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/bodypart_muscle_mapping_screen.dart';
import 'package:env_test/screens/profile/settings/volume_boundaries_screen.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Analytics value fields preserve dropdown behavior in all families',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final configurations =
          <({AppThemeFamily? family, Brightness brightness})>[
            for (final family in AppThemeFamily.values)
              for (final brightness in Brightness.values)
                (family: family, brightness: brightness),
            for (final brightness in Brightness.values)
              (family: null, brightness: brightness),
          ];
      for (final configuration in configurations) {
        final brightness = configuration.brightness;
        final expressive = configuration.family == null;
        final repository = _AnalyticsSelectorRepository();
        final theme = expressive
            ? ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF345B50),
                  brightness: brightness,
                ),
                extensions: const [
                  AppThemeIdentity(
                    family: AppThemeFamilyIdentity.expressivePreview,
                  ),
                ],
              )
            : brightness == Brightness.light
            ? AppThemeFactory.light(configuration.family!)
            : AppThemeFactory.dark(configuration.family!);
        final mode = expressive
            ? 'expressive ${brightness.name}'
            : '${configuration.family!.code} ${brightness.name}';

        Future<void> mount(Widget page) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [Provider<AppRepository>.value(value: repository)],
              child: MaterialApp(
                key: UniqueKey(),
                theme: theme,
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: page,
              ),
            ),
          );
          await tester.pumpAndSettle();
        }

        await mount(const VolumeBoundariesScreen());
        final volumeStrings = AppLocalizations.of(
          tester.element(find.byType(VolumeBoundariesScreen)),
        );
        final bodyPartChoice = find.byKey(
          const ValueKey('volume-choice-body-part'),
        );
        if (expressive) {
          expect(bodyPartChoice, findsOneWidget, reason: mode);
          expect(
            find.byType(DropdownButtonFormField<BodyPart>),
            findsNothing,
            reason: '$mode: Expressive selector uses its anchored menu',
          );
          await tester.tap(bodyPartChoice);
          await tester.pumpAndSettle();
          expect(find.byType(MenuAnchor), findsOneWidget, reason: mode);
          expect(
            find.byType(TonosChoiceDialog<BodyPart?>),
            findsNothing,
            reason: '$mode: body-part choice is anchored, not modal',
          );
          final chestOption = find.text(volumeStrings.bodyPartChest);
          final chestMenuItem = find.ancestor(
            of: chestOption,
            matching: find.byType(MenuItemButton),
          );
          expect(chestMenuItem, findsOneWidget, reason: mode);
          expect(
            tester
                .widgetList<Semantics>(
                  find.ancestor(
                    of: chestMenuItem,
                    matching: find.byType(Semantics),
                  ),
                )
                .any((semantics) => semantics.properties.selected == true),
            isTrue,
            reason: '$mode: current body part is announced as selected',
          );
          final triggerRect = tester.getRect(bodyPartChoice);
          final optionRect = tester.getRect(chestMenuItem);
          expect(
            optionRect.left,
            greaterThanOrEqualTo(triggerRect.left - 8),
            reason: '$mode: menu stays aligned to its trigger',
          );
          expect(
            optionRect.right,
            lessThanOrEqualTo(triggerRect.right + 8),
            reason: '$mode: menu width follows its trigger',
          );
          await tester.tap(find.text(volumeStrings.bodyPartShoulders));
          await tester.pumpAndSettle();
          expect(find.text(volumeStrings.bodyPartShoulders), findsOneWidget);
          expect(find.byType(MenuItemButton), findsNothing, reason: mode);
          expect(repository.bodyPartBoundsLoads.last, 2);

          await tester.tap(bodyPartChoice);
          await tester.pumpAndSettle();
          final laterBodyPart = find.text('Additional body part 14');
          expect(laterBodyPart.hitTestable(), findsNothing, reason: mode);
          final bodyPartMenuScrollable = find.ancestor(
            of: find.text(volumeStrings.bodyPartShoulders),
            matching: find.byType(Scrollable),
          );
          expect(bodyPartMenuScrollable, findsOneWidget, reason: mode);
          await tester.drag(bodyPartMenuScrollable, const Offset(0, -480));
          await tester.pumpAndSettle();
          expect(laterBodyPart.hitTestable(), findsOneWidget, reason: mode);
          await tester.tap(laterBodyPart);
          await tester.pumpAndSettle();
          expect(find.text('Additional body part 14'), findsOneWidget);
          expect(repository.bodyPartBoundsLoads.last, 16);
        } else {
          final bodyPartDropdown = find.byType(
            DropdownButtonFormField<BodyPart>,
          );
          expect(bodyPartDropdown, findsOneWidget, reason: mode);
          await tester.tap(bodyPartDropdown);
          await tester.pumpAndSettle();
          expect(
            find.byType(TonosChoiceDialog<BodyPart?>),
            findsNothing,
            reason: '$mode: body-part field is not a modal picker',
          );
          await tester.tap(find.text(volumeStrings.bodyPartShoulders));
          await tester.pumpAndSettle();
          expect(find.text(volumeStrings.bodyPartShoulders), findsOneWidget);
          expect(repository.bodyPartBoundsLoads.last, 2);
        }

        await tester.tap(find.text(volumeStrings.volumeMuscles));
        await tester.pumpAndSettle();
        final muscleChoice = find.byKey(const ValueKey('volume-choice-muscle'));
        if (expressive) {
          expect(muscleChoice, findsOneWidget, reason: mode);
          expect(
            find.byType(DropdownButtonFormField<Muscle>),
            findsNothing,
            reason: '$mode: Expressive selector uses its anchored menu',
          );
          await tester.tap(muscleChoice);
          await tester.pumpAndSettle();
          expect(find.byType(MenuAnchor), findsOneWidget, reason: mode);
          expect(
            find.byType(TonosChoiceDialog<Muscle?>),
            findsNothing,
            reason: '$mode: muscle choice is anchored, not modal',
          );
          final pecOption = find.text('Pectoralis major');
          final pecMenuItem = find.ancestor(
            of: pecOption,
            matching: find.byType(MenuItemButton),
          );
          expect(pecMenuItem, findsOneWidget, reason: mode);
          expect(
            tester
                .widgetList<Semantics>(
                  find.ancestor(
                    of: pecMenuItem,
                    matching: find.byType(Semantics),
                  ),
                )
                .any((semantics) => semantics.properties.selected == true),
            isTrue,
            reason: '$mode: current muscle is announced as selected',
          );
          final triggerRect = tester.getRect(muscleChoice);
          final optionRect = tester.getRect(pecMenuItem);
          expect(
            optionRect.left,
            greaterThanOrEqualTo(triggerRect.left - 8),
            reason: '$mode: menu stays aligned to its trigger',
          );
          expect(
            optionRect.right,
            lessThanOrEqualTo(triggerRect.right + 8),
            reason: '$mode: menu width follows its trigger',
          );
          await tester.tap(find.text('Latissimus dorsi'));
          await tester.pumpAndSettle();
          expect(find.text('Latissimus dorsi'), findsOneWidget);
          expect(find.byType(MenuItemButton), findsNothing, reason: mode);
          expect(repository.muscleBoundsLoads.last, 2);

          await tester.tap(muscleChoice);
          await tester.pumpAndSettle();
          final latOption = find.text('Latissimus dorsi');
          final latMenuItem = find.ancestor(
            of: latOption,
            matching: find.byType(MenuItemButton),
          );
          expect(latMenuItem, findsOneWidget, reason: mode);
          expect(
            tester
                .widgetList<Semantics>(
                  find.ancestor(
                    of: latMenuItem,
                    matching: find.byType(Semantics),
                  ),
                )
                .any((semantics) => semantics.properties.selected == true),
            isTrue,
            reason: '$mode: newly chosen muscle remains selected',
          );
          expect(find.text('Pectoralis major'), findsOneWidget);
          await tester.tapAt(const Offset(2, 2));
          await tester.pumpAndSettle();
          expect(find.byType(MenuItemButton), findsNothing);
          expect(find.byType(VolumeBoundariesScreen), findsOneWidget);

          await tester.tap(muscleChoice);
          await tester.pumpAndSettle();
          expect(find.text('Pectoralis major'), findsOneWidget);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.byType(MenuItemButton), findsNothing);
          expect(find.byType(VolumeBoundariesScreen), findsOneWidget);

          await tester.tap(muscleChoice);
          await tester.pumpAndSettle();
          final laterMuscle = find.text('Additional muscle 14');
          expect(laterMuscle.hitTestable(), findsNothing, reason: mode);
          final muscleMenuScrollable = find.ancestor(
            of: find.text('Latissimus dorsi'),
            matching: find.byType(Scrollable),
          );
          expect(muscleMenuScrollable, findsOneWidget, reason: mode);
          await tester.drag(muscleMenuScrollable, const Offset(0, -480));
          await tester.pumpAndSettle();
          expect(laterMuscle.hitTestable(), findsOneWidget, reason: mode);
          await tester.tap(laterMuscle);
          await tester.pumpAndSettle();
          expect(find.text('Additional muscle 14'), findsOneWidget);
          expect(repository.muscleBoundsLoads.last, 16);
        } else {
          final muscleDropdown = find.byType(DropdownButtonFormField<Muscle>);
          expect(muscleDropdown, findsOneWidget, reason: mode);
          await tester.tap(muscleDropdown);
          await tester.pumpAndSettle();
          expect(
            find.byType(TonosChoiceDialog<Muscle?>),
            findsNothing,
            reason: '$mode: muscle field is not a modal picker',
          );
          await tester.tap(find.text('Latissimus dorsi'));
          await tester.pumpAndSettle();
          expect(find.text('Latissimus dorsi'), findsOneWidget);
          expect(repository.muscleBoundsLoads.last, 2);

          await tester.tap(muscleDropdown);
          await tester.pumpAndSettle();
          expect(find.text('Pectoralis major'), findsOneWidget);
          await tester.tapAt(const Offset(2, 2));
          await tester.pumpAndSettle();
          expect(find.text('Pectoralis major'), findsNothing);
          expect(find.byType(VolumeBoundariesScreen), findsOneWidget);

          await tester.tap(muscleDropdown);
          await tester.pumpAndSettle();
          expect(find.text('Pectoralis major'), findsOneWidget);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.text('Pectoralis major'), findsNothing);
          expect(find.byType(VolumeBoundariesScreen), findsOneWidget);
        }

        await mount(const BodyPartMuscleMappingScreen());
        final mappingDropdown = find.byType(DropdownButtonFormField<BodyPart>);
        expect(mappingDropdown, findsOneWidget, reason: mode);
        await tester.tap(mappingDropdown);
        await tester.pumpAndSettle();
        expect(
          find.byType(TonosChoiceDialog<BodyPart?>),
          findsNothing,
          reason: '$mode: mapping field is not a modal picker',
        );
        await tester.tap(
          find.text(
            AppLocalizations.of(
              tester.element(find.byType(BodyPartMuscleMappingScreen)),
            ).bodyPartShoulders,
          ),
        );
        await tester.pumpAndSettle();
        expect(repository.mappingLoads.last, 2);
        expect(tester.takeException(), isNull, reason: mode);
      }
    },
  );
}

class _AnalyticsSelectorRepository extends AppRepository {
  final chest = BodyPart(1, 'Chest');
  final shoulders = BodyPart(2, 'Shoulders');
  final additionalBodyParts = List<BodyPart>.generate(
    14,
    (index) => BodyPart(index + 3, 'Additional body part ${index + 1}'),
  );
  final pec = Muscle(id: 1, name: 'Pectoralis major');
  final lat = Muscle(id: 2, name: 'Latissimus dorsi');
  final additionalMuscles = List<Muscle>.generate(
    14,
    (index) => Muscle(id: index + 3, name: 'Additional muscle ${index + 1}'),
  );
  final bodyPartBoundsLoads = <int>[];
  final muscleBoundsLoads = <int>[];
  final mappingLoads = <int>[];

  @override
  Future<List<BodyPart>> fetchAllBodyPartsFull() async => [
    chest,
    shoulders,
    ...additionalBodyParts,
  ];

  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => [
    pec,
    lat,
    ...additionalMuscles,
  ];

  @override
  Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) async {
    bodyPartBoundsLoads.add(bodyPartId);
    return VolumeBoundaries(
      id: bodyPartId,
      maintenance: 4,
      minEffective: 6,
      maxAdaptive: 12,
      maxRecoverable: 20,
    );
  }

  @override
  Future<VolumeBoundaries?> fetchMuscleVolumeBounds(int muscleId) async {
    muscleBoundsLoads.add(muscleId);
    return VolumeBoundaries(
      id: muscleId,
      maintenance: 4,
      minEffective: 6,
      maxAdaptive: 12,
      maxRecoverable: 20,
    );
  }

  @override
  Future<List<MuscleBodyPart>> fetchMusclesForBodyPart(int bodyPartId) async {
    mappingLoads.add(bodyPartId);
    return [MuscleBodyPart(muscleId: pec.id, bodyPartId: bodyPartId)];
  }
}
