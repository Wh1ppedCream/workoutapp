import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/preset_models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/auto_preset_flow_screen.dart';
import 'package:env_test/theme/expressive_theme.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Expressive flow control panels in ${brightness.name} mode', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      await tester.pumpWidget(
        Provider<AppRepository>.value(
          value: _FlowThemeRepository(),
          child: MaterialApp(
            theme: theme,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AutoPresetFlowScreen.appDefaults(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final pageContext = tester.element(find.byType(AutoPresetFlowScreen));
      final strings = AppLocalizations.of(pageContext);
      final panels = _flowControlDeck();
      expect(panels, findsOneWidget);

      await expectLater(
        panels,
        matchesGoldenFile(
          '../../goldens/expressive_flow_editor/controls_${brightness.name}_collapsed.png',
        ),
      );

      await tester.tap(find.text(strings.flowAddBranchTitle));
      await tester.tap(find.text(strings.flowAttachActionTitle));
      await tester.pumpAndSettle();
      expect(find.text(strings.flowSuccess), findsOneWidget);
      expect(find.text(strings.flowMiss), findsOneWidget);

      await expectLater(
        panels,
        matchesGoldenFile(
          '../../goldens/expressive_flow_editor/controls_${brightness.name}_expanded.png',
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}

Finder _flowControlDeck() => find.byWidgetPredicate(
  (widget) =>
      widget is Column &&
      widget.children.length == 3 &&
      widget.children.first.runtimeType.toString().contains(
        'FlowControlCard',
      ) &&
      widget.children[1] is SizedBox &&
      widget.children.last.runtimeType.toString().contains('FlowControlCard'),
  description: 'the two flow-control panels and their separating gap',
);

class _FlowThemeRepository extends AppRepository {
  @override
  Future<FlowDefinition> fetchFlowDefinition(int presetId) async =>
      FlowDefinition(
        nodes: const ['1st attempt', 'success1'],
        edges: [
          FlowEdge(from: '1st attempt', outcome: 'success', to: 'success1'),
        ],
      );

  @override
  Future<List<FlowMethod>> fetchFlowMethods(int presetId) async =>
      fetchDefaultFlowMethods('plan');

  @override
  Future<FlowDefinition> fetchDefaultFlowDefinition(
    String scope, {
    int? profileId,
  }) async => FlowDefinition(
    nodes: const ['1st attempt', 'success1'],
    edges: [FlowEdge(from: '1st attempt', outcome: 'success', to: 'success1')],
  );

  @override
  Future<List<FlowMethod>> fetchDefaultFlowMethods(
    String scope, {
    int? profileId,
  }) async => [
    FlowMethod(
      id: 1,
      presetId: 0,
      name: 'Scale Load',
      type: MethodType.weight,
      params: const {'sign': '+', 'factor': 1.0},
    ),
  ];
}
