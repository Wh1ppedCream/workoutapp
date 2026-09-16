import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/theme/widgets/tonos_theme_ready.dart';

void main() {
  for (final family in [AppThemeFamily.classic, AppThemeFamily.neoBrutalism]) {
    testWidgets('theme-ready cards keep their family boundary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeFactory.light(family),
          home: const Scaffold(
            body: TonosThemeReadyCard(
              variant: TonosSurfaceVariant.compactCard,
              child: Text('Theme-ready content'),
            ),
          ),
        ),
      );

      if (family == AppThemeFamily.classic) {
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(TonosSurface), findsNothing);
      } else {
        expect(find.byType(Card), findsNothing);
        expect(find.byType(TonosSurface), findsOneWidget);
        final surface = tester.widget<TonosSurface>(find.byType(TonosSurface));
        expect(surface.variant, TonosSurfaceVariant.compactCard);
      }
      expect(find.text('Theme-ready content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
