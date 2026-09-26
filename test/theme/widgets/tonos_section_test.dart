import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/widgets/tonos_section.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';

void main() {
  testWidgets('renders a semantic section shell with heading content', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const TonosSection(
          title: 'Workout summary',
          subtitle: 'Representative feature section',
          leading: Icon(Icons.fitness_center),
          child: Text('Three sets completed'),
        ),
      ),
    );

    expect(find.byType(TonosSurface), findsOneWidget);
    expect(find.text('Workout summary'), findsOneWidget);
    expect(find.text('Representative feature section'), findsOneWidget);
    expect(find.text('Three sets completed'), findsOneWidget);
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}
