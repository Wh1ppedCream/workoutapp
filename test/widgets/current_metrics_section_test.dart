import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/widgets/current_metrics_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows an honest empty state when nothing has been recorded', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(repository: _MetricsRepository()));
    await tester.pumpAndSettle();

    expect(find.text('No measurements yet'), findsOneWidget);
    expect(
      find.text('Create a metric to start tracking progress.'),
      findsOneWidget,
    );
    expect(find.text('26.0 %'), findsNothing);
    expect(find.text('27 in'), findsNothing);
    expect(find.text('36 in'), findsNothing);
  });

  testWidgets('shows the latest saved value for each recorded metric', (
    tester,
  ) async {
    final recordedAt = DateTime(2026, 8, 13, 9, 30);
    final repository = _MetricsRepository(
      definitions: [
        MeasurementDefinition(
          id: 1,
          name: 'Body weight',
          type: MeasurementType.BodyWeight,
        ),
        MeasurementDefinition(
          id: 2,
          name: 'Waist',
          type: MeasurementType.Waist,
        ),
      ],
      entriesByDefinition: {
        1: [
          Measurement(
            id: 1,
            defId: 1,
            timestamp: recordedAt.subtract(const Duration(days: 4)),
            value: 178,
            unit: 'lbs',
          ),
          Measurement(
            id: 2,
            defId: 1,
            timestamp: recordedAt,
            value: 180,
            unit: 'lbs',
          ),
        ],
        2: [
          Measurement(
            id: 3,
            defId: 2,
            timestamp: recordedAt.subtract(const Duration(days: 1)),
            value: 31.5,
            unit: 'in',
          ),
        ],
      },
    );

    await tester.pumpWidget(_testApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('180 lbs'), findsOneWidget);
    expect(find.text('31.5 in'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
    expect(find.text('Waist'), findsOneWidget);
    expect(find.text('178 lbs'), findsNothing);
  });
}

Widget _testApp({required AppRepository repository}) {
  return Provider<AppRepository>.value(
    value: repository,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: CurrentMetricsSection()),
    ),
  );
}

class _MetricsRepository extends AppRepository {
  _MetricsRepository({
    this.definitions = const [],
    this.entriesByDefinition = const {},
  });

  final List<MeasurementDefinition> definitions;
  final Map<int, List<Measurement>> entriesByDefinition;

  @override
  Future<void> ensureDefaultMeasurementDefinitions() async {}

  @override
  Future<List<MeasurementDefinition>> fetchClassMeasurementDefinitions() async {
    return definitions;
  }

  @override
  Future<List<Measurement>> fetchClassMeasurementsForDefinition(
    int defId,
  ) async {
    return List<Measurement>.from(entriesByDefinition[defId] ?? const []);
  }
}
