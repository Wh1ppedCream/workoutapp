import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/widgets/past_sessions_list.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode past-session filter label resolves Material ink', (
        tester,
      ) async {
        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: _EmptySessionRepository(),
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(body: PastSessionsList(height: 240)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(PastSessionsList));
        final labelFinder = find.text(
          AppLocalizations.of(context).pastSessionsShow,
        );
        final label = tester.widget<Text>(labelFinder);
        final labelContext = tester.element(labelFinder);
        final inherited = DefaultTextStyle.of(labelContext).style;
        final rendered =
            tester.renderObject<RenderParagraph>(labelFinder).text.style;

        expect(label.style?.color, theme.colorScheme.onSurface);
        expect(rendered, inherited.merge(label.style));
        expect(rendered?.color, theme.colorScheme.onSurface);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

class _EmptySessionRepository extends AppRepository {
  @override
  Future<List<WorkoutSession>> fetchSessionsInRange(
    DateTime start,
    DateTime end,
  ) async => const [];
}
