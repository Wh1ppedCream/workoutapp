import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/gym_models.dart';
import 'package:env_test/models/preset_models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/flow_methods_page.dart';
import 'package:env_test/screens/profile/settings/workout_progress_flows_page.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Expressive flow empty states keep paired colors in both modes', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 800));

    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      final tokens = AppExpressiveDestinationTokens.forFamily(
        AppExpressiveDestinationFamily.profile,
        brightness,
      );

      for (final route
          in <({Widget page, String Function(AppLocalizations) label})>[
            (
              page: const WorkoutProgressFlowsPage(),
              label: (strings) => strings.flowNoProfiles,
            ),
            (
              page: const FlowMethodsPage(),
              label: (strings) => strings.rulesNoProfiles,
            ),
          ]) {
        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: _EmptyFlowRepository(),
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.5)),
                child: child!,
              ),
              home: route.page,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final strings = AppLocalizations.of(
          tester.element(find.byType(route.page.runtimeType)),
        );
        final message = route.label(strings);
        final messageFinder = find.text(message);
        await tester.scrollUntilVisible(
          messageFinder,
          240,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(messageFinder, findsOneWidget, reason: '$brightness $message');
        final emptyCard = find.ancestor(
          of: messageFinder,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).color ==
                    tokens.surfaceTertiary,
          ),
        );
        expect(emptyCard, findsOneWidget, reason: '$brightness $message');
        expect(
          tester.widget<Text>(messageFinder).style?.color,
          tokens.onSurfaceTertiary,
          reason: '$brightness $message foreground',
        );
        expect(tester.takeException(), isNull, reason: '$brightness $message');
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });
}

class _EmptyFlowRepository extends AppRepository {
  @override
  Future<FlowDefinition> fetchDefaultFlowDefinition(
    String scope, {
    int? profileId,
  }) async => FlowDefinition(nodes: const ['1st attempt'], edges: const []);

  @override
  Future<List<FlowMethod>> fetchDefaultFlowMethods(
    String scope, {
    int? profileId,
  }) async => const [];

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => const [];
}
