import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/widgets/active_session_durability_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('restore failures stay visible and can be retried', (
    tester,
  ) async {
    final repository = _RestoreFailureRepository(failuresRemaining: 3);
    final session = ActiveSession(
      repository: repository,
      retryDelay: (_) async {},
    );
    addTearDown(session.dispose);
    await session.ready;

    await tester.pumpWidget(
      ChangeNotifierProvider<ActiveSession>.value(
        value: session,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ActiveSessionDurabilityBanner(
            child: Scaffold(body: SizedBox.expand()),
          ),
        ),
      ),
    );

    expect(
      find.text(
        'Tonos could not check for a saved workout. Retry before starting '
        'another workout.',
      ),
      findsOneWidget,
    );

    repository.failuresRemaining = 0;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsNothing);
    expect(session.durabilityIssue, isNull);
  });
}

class _RestoreFailureRepository extends AppRepository {
  _RestoreFailureRepository({required this.failuresRemaining});

  int failuresRemaining;

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async {
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw StateError('storage unavailable');
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];
}
