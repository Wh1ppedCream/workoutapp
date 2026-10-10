import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/gym_models.dart';
import 'package:env_test/models/preset_models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/flow_methods_page.dart';
import 'package:env_test/screens/profile/settings/profile_expressive_selection.dart';
import 'package:env_test/services/active_plan_store.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Expressive App-wide rules keep readable content in both modes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      final tokens = AppExpressiveDestinationTokens.forFamily(
        AppExpressiveDestinationFamily.profile,
        brightness,
      );
      await _pumpRules(
        tester,
        _RulesRepository(appMethods: [_oneAppRule]),
        theme,
      );

      final strings = AppLocalizations.of(
        tester.element(find.byType(FlowMethodsPage)),
      );
      expect(find.text(strings.rulesHowDefaultsTitle), findsOneWidget);
      expect(find.text(strings.rulesHowDefaultsBodyExpressive), findsOneWidget);
      expect(find.byType(SettingsLegendChip), findsNothing);

      final appTitle = tester.widget<Text>(
        find.text(strings.rulesAppDefaultsTitle),
      );
      expect(appTitle.style?.color, tokens.onSurfacePrimary);
      expect(
        _contrastRatio(tokens.onSurfacePrimary, tokens.surfacePrimary),
        greaterThanOrEqualTo(4.5),
      );
      final appCard = find
          .ancestor(
            of: find.text(strings.rulesAppDefaultsTitle),
            matching: find.byType(ExpansionTile),
          )
          .first;
      expect(appRuleCountFinder(appCard, strings, 1), findsOneWidget);

      final infoBody = tester.widget<Text>(
        find.text(strings.rulesHowDefaultsBodyExpressive),
      );
      final infoContext = tester.element(
        find.text(strings.rulesHowDefaultsBodyExpressive),
      );
      expect(
        infoBody.style?.color,
        Theme.of(infoContext).colorScheme.onSurfaceVariant,
      );
      expect(
        _contrastRatio(
          infoBody.style!.color!,
          Theme.of(infoContext).surfaceTokens.settingsSection,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('scope chips stay in Classic and Neo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final theme in <ThemeData>[
      ClassicThemeDefinition.light(),
      NeoBrutalismThemeDefinition.light(),
    ]) {
      await _pumpRules(tester, _RulesRepository(), theme);
      expect(find.byType(SettingsLegendChip), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'Expressive type and operator choices remain nested in rule dialog',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(390, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pumpRules(
        tester,
        _RulesRepository(),
        ExpressiveThemeDefinition.light(),
      );

      final strings = AppLocalizations.of(
        tester.element(find.byType(FlowMethodsPage)),
      );
      await tester.tap(find.text(strings.rulesAddApp));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(_fieldWithLabel(strings.rulesRuleTypeLabel));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text(strings.flowMethodReps));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(_fieldWithLabel(strings.rulesOperationLabel), findsOneWidget);

      await tester.tap(_fieldWithLabel(strings.rulesOperationLabel));
      await tester.pumpAndSettle();
      expect(find.text('+'), findsNWidgets(2));
      expect(find.text('-'), findsOneWidget);
      await tester.tap(find.text('-'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(_fieldWithLabel(strings.rulesOperationLabel));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(strings.rulesAddAppDefault), findsOneWidget);
      await tester.tap(find.text(strings.commonCancel));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Classic and Neo keep rule selectors as dropdowns', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final theme in <ThemeData>[
      ClassicThemeDefinition.light(),
      NeoBrutalismThemeDefinition.light(),
    ]) {
      await _pumpRules(tester, _RulesRepository(), theme);
      final strings = AppLocalizations.of(
        tester.element(find.byType(FlowMethodsPage)),
      );
      await tester.tap(find.text(strings.rulesAddApp));
      await tester.pumpAndSettle();
      expect(
        find.byType(ProfileExpressiveChoiceButton<MethodType>),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(DropdownButton<MethodType>),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(DropdownButton<String>),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(strings.commonCancel));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('app rule create, edit, and delete update accessible counts', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _RulesRepository(profiles: const []);
    await _pumpRules(tester, repository, ExpressiveThemeDefinition.light());

    final strings = AppLocalizations.of(
      tester.element(find.byType(FlowMethodsPage)),
    );
    final appCard = find
        .ancestor(
          of: find.text(strings.rulesAppDefaultsTitle),
          matching: find.byType(ExpansionTile),
        )
        .first;
    Finder appRuleCount(int count) =>
        appRuleCountFinder(appCard, strings, count);

    expect(appRuleCount(0), findsOneWidget);
    await tester.tap(find.text(strings.rulesAddApp));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Progress rule');
    await tester.tap(find.text(strings.commonSave));
    await tester.pumpAndSettle();
    expect(find.text('Progress rule'), findsOneWidget);
    expect(appRuleCount(1), findsOneWidget);

    await tester.tap(find.byTooltip(strings.rulesOptionsTooltip));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.commonEdit));
    await tester.pumpAndSettle();
    await tester.tap(_fieldWithLabel(strings.rulesRuleTypeLabel));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.flowMethodReps));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.commonSave));
    await tester.pumpAndSettle();
    expect(find.text(strings.flowMethodReps), findsOneWidget);
    expect(appRuleCount(1), findsOneWidget);

    await tester.tap(find.byTooltip(strings.rulesOptionsTooltip));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.commonDelete));
    await tester.pumpAndSettle();
    expect(find.text('Progress rule'), findsNothing);
    expect(find.text(strings.rulesNoAppDefaults), findsOneWidget);
    expect(appRuleCount(0), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'rules page and Add Rule actions remain usable at narrow widths with keyboard inset',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final width in <double>[320, 390, 430]) {
        await tester.binding.setSurfaceSize(Size(width, 900));
        await _pumpRules(
          tester,
          _RulesRepository(profiles: const []),
          ExpressiveThemeDefinition.light(),
          textScale: 2,
          keyboardInset: 300,
        );
        final strings = AppLocalizations.of(
          tester.element(find.byType(FlowMethodsPage)),
        );
        final addRule = find.text(strings.rulesAddApp);
        await tester.scrollUntilVisible(
          addRule,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(addRule);
        await tester.pumpAndSettle();
        expect(addRule.hitTestable(), findsOneWidget, reason: '$width dp');
        await tester.tap(addRule);
        await tester.pumpAndSettle();

        final nameField = find.byType(TextField).first;
        await tester.ensureVisible(nameField);
        await tester.tap(nameField);
        await tester.enterText(nameField, 'Responsive rule');
        await tester.pumpAndSettle();

        final save = find.text(strings.commonSave);
        final cancel = find.text(strings.commonCancel);
        await tester.ensureVisible(save);
        expect(save.hitTestable(), findsOneWidget, reason: '$width dp Save');
        expect(
          cancel.hitTestable(),
          findsOneWidget,
          reason: '$width dp Cancel',
        );
        expect(tester.takeException(), isNull, reason: '$width dp');

        await tester.tap(cancel);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing, reason: '$width dp');
        expect(tester.takeException(), isNull, reason: '$width dp');
      }
    },
  );

  testWidgets(
    'rule plans group by active status and show the zero-plan state',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(390, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repository = _RulesRepository(
        plans: const [
          {'id': 101, 'name': 'Active plan'},
          {'id': 102, 'name': 'Archived plan'},
        ],
        activePlanIds: const {101},
      );
      await _pumpRules(
        tester,
        repository,
        ExpressiveThemeDefinition.light(),
        withActivePlanStore: true,
      );
      var strings = AppLocalizations.of(
        tester.element(find.byType(FlowMethodsPage)),
      );
      expect(find.text(strings.trainActivePlans), findsOneWidget);
      expect(find.text(strings.trainArchivedPlans), findsOneWidget);
      expect(find.text('Active plan'), findsOneWidget);
      expect(find.text('Archived plan'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text(strings.trainActivePlans)).dy,
        lessThan(tester.getTopLeft(find.text('Active plan')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Active plan')).dy,
        lessThan(tester.getTopLeft(find.text(strings.trainArchivedPlans)).dy),
      );
      expect(
        tester.getTopLeft(find.text(strings.trainArchivedPlans)).dy,
        lessThan(tester.getTopLeft(find.text('Archived plan')).dy),
      );

      await _pumpRules(
        tester,
        _RulesRepository(plans: const []),
        ExpressiveThemeDefinition.light(),
        withActivePlanStore: true,
      );
      strings = AppLocalizations.of(
        tester.element(find.byType(FlowMethodsPage)),
      );
      expect(find.text(strings.rulesNoPlans), findsOneWidget);
      expect(find.text(strings.trainActivePlans), findsNothing);
      expect(find.text(strings.trainArchivedPlans), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

Finder appRuleCountFinder(
  Finder appCard,
  AppLocalizations strings,
  int count,
) => find.descendant(
  of: appCard,
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is Semantics &&
        widget.properties.label == strings.rulesCountSemantics(count),
  ),
);

Finder _fieldWithLabel(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);

double _contrastRatio(Color foreground, Color background) {
  final luminances = [
    foreground.computeLuminance(),
    background.computeLuminance(),
  ]..sort((a, b) => b.compareTo(a));
  return (luminances.first + 0.05) / (luminances.last + 0.05);
}

Future<void> _pumpRules(
  WidgetTester tester,
  _RulesRepository repository,
  ThemeData theme, {
  bool withActivePlanStore = false,
  double textScale = 1,
  double keyboardInset = 0,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  Widget app = MaterialApp(
    theme: theme,
    themeAnimationDuration: Duration.zero,
    localizationsDelegates: tonosLocalizationDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        viewInsets: EdgeInsets.only(bottom: keyboardInset),
      ),
      child: child!,
    ),
    home: const FlowMethodsPage(),
  );
  if (withActivePlanStore) {
    app = Provider<ActivePlanStore>.value(
      value: ActivePlanStore(repository: repository),
      child: app,
    );
  }
  await tester.pumpWidget(
    Provider<AppRepository>.value(value: repository, child: app),
  );
  await tester.pumpAndSettle();
}

class _RulesRepository extends AppRepository {
  _RulesRepository({
    this.plans = const [],
    this.activePlanIds = const {},
    List<FlowMethod> appMethods = const [],
    List<GymProfile>? profiles,
  }) : _appMethods = List.of(appMethods),
       profiles =
           profiles ??
           [GymProfile(id: 1, name: 'Home gym', createdAt: DateTime(2020))];

  final List<Map<String, dynamic>> plans;
  final Set<int> activePlanIds;
  final List<GymProfile> profiles;
  final List<FlowMethod> _appMethods;
  int _nextMethodId = 2;

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => profiles;

  @override
  Future<List<FlowMethod>> fetchDefaultFlowMethods(
    String scope, {
    int? profileId,
  }) async => scope == 'app' ? List.of(_appMethods) : const [];

  @override
  Future<List<Map<String, dynamic>>> fetchAllPresetsRaw({
    int? profileId,
  }) async => plans;

  @override
  Future<List<FlowMethod>> fetchFlowMethods(int presetId) async => const [];

  @override
  Future<FlowDefinition> fetchDefaultFlowDefinition(
    String scope, {
    int? profileId,
  }) async => FlowDefinition(nodes: const [], edges: const []);

  @override
  Future<FlowDefinition> fetchFlowDefinition(int presetId) async =>
      FlowDefinition(nodes: const [], edges: const []);

  @override
  Future<Set<int>> loadActivePlans(int profileId) async => activePlanIds;

  @override
  Future<FlowMethod> upsertDefaultFlowMethod({
    required String scope,
    int? profileId,
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
  }) async {
    final existingIndex = _appMethods.indexWhere(
      (method) => method.name == name,
    );
    final method = FlowMethod(
      id: existingIndex < 0 ? _nextMethodId++ : _appMethods[existingIndex].id,
      presetId: profileId ?? -1,
      name: name,
      type: type,
      params: Map.of(params),
    );
    if (existingIndex < 0) {
      _appMethods.add(method);
    } else {
      _appMethods[existingIndex] = method;
    }
    return method;
  }

  @override
  Future<void> deleteDefaultFlowMethodAndReferences({
    required String scope,
    int? profileId,
    required String name,
  }) async {
    _appMethods.removeWhere((method) => method.name == name);
  }
}

final _oneAppRule = FlowMethod(
  id: 1,
  presetId: -1,
  name: 'Add weight',
  type: MethodType.weight,
  params: const {'sign': '+', 'factor': 1.0},
);
