import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/gym_models.dart';
import 'package:env_test/models/preset_models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/auto_preset_flow_screen.dart';
import 'package:env_test/screens/profile/settings/workout_progress_flows_page.dart';
import 'package:env_test/services/active_plan_store.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Expressive flow copy, states, chips, and status groups are clear',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 1200));
      final repository = _FlowRepository(
        appFlow: _emptyFlow,
        profileFlow: _flowWithNodes(2),
        planRows: _planRows,
        planFlows: {101: _emptyFlow, 102: _flowWithNodes(3), 103: _emptyFlow},
        activePlanIds: {101, 103},
      );

      await _pumpFlows(tester, repository, ExpressiveThemeDefinition.light());
      final strings = AppLocalizations.of(
        tester.element(find.byType(WorkoutProgressFlowsPage)),
      );

      expect(
        find.text('Configure how workout results trigger progression actions.'),
        findsOneWidget,
      );
      expect(
        find.text(
          "New gym profiles start with app defaults, and new plans start with gym defaults. Changes to one flow don't affect the others.",
        ),
        findsOneWidget,
      );
      expect(find.byType(SettingsLegendChip), findsNothing);
      expect(find.text(strings.flowTapToConfigure), findsNWidgets(3));
      expect(find.text(strings.flowSummary(2, 0, 0)), findsOneWidget);
      expect(find.text(strings.flowSummary(3, 0, 0)), findsOneWidget);
      expect(find.text('3 plans available'), findsOneWidget);
      expect(find.text(strings.trainActivePlans), findsOneWidget);
      expect(find.text(strings.trainArchivedPlans), findsOneWidget);
      expect(find.text(strings.flowNoSavedYet), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).borderRadius ==
                  ExpressiveTrainShapes.focusHero,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Expressive plan groups omit empty subgroup headings', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 1200));

    for (final activePlanIds in <Set<int>>[
      {101, 102, 103},
      <int>{},
    ]) {
      final repository = _FlowRepository(
        appFlow: _emptyFlow,
        profileFlow: _emptyFlow,
        planRows: _planRows,
        planFlows: const {},
        activePlanIds: activePlanIds,
      );
      await _pumpFlows(tester, repository, ExpressiveThemeDefinition.dark());
      final strings = AppLocalizations.of(
        tester.element(find.byType(WorkoutProgressFlowsPage)),
      );
      expect(
        find.text(strings.trainActivePlans),
        activePlanIds.isEmpty ? findsNothing : findsOneWidget,
      );
      expect(
        find.text(strings.trainArchivedPlans),
        activePlanIds.isEmpty ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Classic and Neo retain legacy copy and informational chips', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 1000));

    for (final theme in <ThemeData>[
      ClassicThemeDefinition.light(),
      NeoBrutalismThemeDefinition.light(),
    ]) {
      final repository = _FlowRepository(
        appFlow: _emptyFlow,
        profileFlow: _emptyFlow,
      );
      await _pumpFlows(tester, repository, theme);
      final strings = AppLocalizations.of(
        tester.element(find.byType(WorkoutProgressFlowsPage)),
      );
      expect(find.text(strings.flowPageSubtitle), findsOneWidget);
      expect(find.text(strings.flowHowCopiedBody), findsOneWidget);
      expect(find.byType(SettingsLegendChip), findsNWidgets(3));
      expect(find.text(strings.flowNoSavedYet), findsNWidgets(2));
      expect(find.text(strings.flowTapToConfigure), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('all flow rows still navigate and accordions still toggle', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    final repository = _FlowRepository(
      appFlow: _emptyFlow,
      profileFlow: _emptyFlow,
      planRows: _planRows,
      planFlows: const {},
      activePlanIds: {101, 103},
    );
    await _pumpFlows(tester, repository, ExpressiveThemeDefinition.light());

    Future<void> openRow(String label) async {
      final row = find.text(label);
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(find.byType(AutoPresetFlowScreen), findsOneWidget, reason: label);
      Navigator.of(tester.element(find.byType(AutoPresetFlowScreen))).pop();
      await tester.pumpAndSettle();
    }

    await openRow('App default flow');
    await openRow('Gym default flow');
    await openRow('Plan 101');

    final appHeading = find.text('App-wide defaults');
    await tester.ensureVisible(appHeading);
    await tester.tap(appHeading);
    await tester.pumpAndSettle();
    expect(find.text('App default flow'), findsNothing);
    await tester.tap(appHeading);
    await tester.pumpAndSettle();
    expect(find.text('App default flow'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('flow page fits compact widths and larger text scales', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final width in <double>[320, 390, 430]) {
      for (final scale in <double>[1, 1.5, 2]) {
        SharedPreferences.setMockInitialValues({});
        await tester.binding.setSurfaceSize(Size(width, 900));
        final repository = _FlowRepository(
          appFlow: _emptyFlow,
          profileFlow: _flowWithNodes(2),
          planRows: _planRows,
          planFlows: {101: _emptyFlow, 102: _flowWithNodes(3), 103: _emptyFlow},
          activePlanIds: {101, 103},
        );
        await _pumpFlows(
          tester,
          repository,
          ExpressiveThemeDefinition.dark(),
          textScale: scale,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: '${width}dp at ${scale}x text',
        );
      }
    }
  });
}

final _emptyFlow = FlowDefinition(nodes: <String>[], edges: <FlowEdge>[]);

FlowDefinition _flowWithNodes(int count) => FlowDefinition(
  nodes: List<String>.generate(count, (index) => 'Step ${index + 1}'),
  edges: const <FlowEdge>[],
);

final _planRows = <Map<String, dynamic>>[
  {'id': 101, 'name': 'Plan 101'},
  {'id': 102, 'name': 'Plan 102'},
  {'id': 103, 'name': 'Plan 103'},
];

Future<void> _pumpFlows(
  WidgetTester tester,
  _FlowRepository repository,
  ThemeData theme, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    Provider<AppRepository>.value(
      value: repository,
      child: Provider<ActivePlanStore>.value(
        value: ActivePlanStore(repository: repository),
        child: MaterialApp(
          theme: theme,
          themeAnimationDuration: Duration.zero,
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const WorkoutProgressFlowsPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FlowRepository extends AppRepository {
  _FlowRepository({
    required this.appFlow,
    required this.profileFlow,
    this.planRows = const <Map<String, dynamic>>[],
    this.planFlows = const <int, FlowDefinition>{},
    this.activePlanIds = const <int>{},
  });

  final FlowDefinition appFlow;
  final FlowDefinition profileFlow;
  final List<Map<String, dynamic>> planRows;
  final Map<int, FlowDefinition> planFlows;
  final Set<int> activePlanIds;

  @override
  Future<FlowDefinition> fetchDefaultFlowDefinition(
    String scope, {
    int? profileId,
  }) async => scope == 'app' ? appFlow : profileFlow;

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => <GymProfile>[
    GymProfile(id: 1, name: 'Home gym', createdAt: DateTime(2020)),
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchAllPresetsRaw({
    int? profileId,
  }) async => planRows;

  @override
  Future<FlowDefinition> fetchFlowDefinition(int presetId) async =>
      planFlows[presetId] ?? _emptyFlow;

  @override
  Future<Set<int>> loadActivePlans(int profileId) async => activePlanIds;

  @override
  Future<List<FlowMethod>> fetchDefaultFlowMethods(
    String scope, {
    int? profileId,
  }) async => const <FlowMethod>[];

  @override
  Future<List<FlowMethod>> fetchFlowMethods(int presetId) async =>
      const <FlowMethod>[];
}
