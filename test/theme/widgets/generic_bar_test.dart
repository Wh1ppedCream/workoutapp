import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/widgets/generic_bar.dart';

void main() {
  testWidgets('Neo plan bars retain content with an identity rail', (
    tester,
  ) async {
    final theme = AppThemeFactory.light(AppThemeFamily.neoBrutalism);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: ListView(
            children: [
              GenericBar(
                label: 'Full Body',
                color: const Color(0xFFFF92BF),
                fillColor: const Color(0xFF64DDE0),
                foregroundColor: const Color(0xFF161616),
                markerColor: const Color(0xFFFF92BF),
                trailing: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Full Body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
