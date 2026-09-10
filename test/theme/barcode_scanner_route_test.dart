import 'dart:async';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/screens/nutrition/barcode_scanner_page.dart';
import 'package:env_test/services/barcode_scanner_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Scanner extends BarcodeScannerSession {
  final events = StreamController<String?>.broadcast(sync: true);
  int starts = 0;
  int stops = 0;
  int disposals = 0;
  Completer<void>? torch;
  @override
  bool hasPermission = true;
  @override
  Stream<String?> get codes => events.stream;
  @override
  Widget buildPreview() => const SizedBox.expand();
  @override
  Future<void> start() async {
    starts++;
  }

  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> switchCamera() async {}
  @override
  Future<void> toggleTorch() async {
    await torch?.future;
  }

  @override
  Future<void> dispose() async {
    disposals++;
    await events.close();
  }
}

Future<void> _open(
  WidgetTester tester,
  _Scanner scanner,
  ValueChanged<String?> result,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder:
            (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result(
                    await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => BarcodeScannerPage(session: scanner),
                      ),
                    ),
                  );
                },
                child: const Text('Open scanner'),
              ),
            ),
      ),
    ),
  );
  await tester.tap(find.text('Open scanner'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ignores empty codes and returns only the first valid code', (
    tester,
  ) async {
    final scanner = _Scanner();
    final results = <String?>[];
    await _open(tester, scanner, results.add);
    expect(scanner.starts, 1);
    scanner.events.add(null);
    scanner.events.add('  ');
    await tester.pump();
    expect(find.byType(BarcodeScannerPage), findsOneWidget);
    scanner.events.add(' 12345 ');
    scanner.events.add('67890');
    await tester.pumpAndSettle();
    expect(results, ['12345']);
    expect(scanner.disposals, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lifecycle pauses and resumes subscriptions', (tester) async {
    final scanner = _Scanner();
    final results = <String?>[];
    await _open(tester, scanner, results.add);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(scanner.stops, 1);
    scanner.events.add('ignored while inactive');
    expect(results, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(scanner.starts, 2);
    scanner.events.add('resumed');
    await tester.pumpAndSettle();
    expect(results, ['resumed']);
  });

  testWidgets(
    'back cancels and late torch completion does not update disposed state',
    (tester) async {
      final scanner = _Scanner()..torch = Completer<void>();
      final results = <String?>[];
      await _open(tester, scanner, results.add);
      await tester.tap(find.byIcon(Icons.flash_off));
      await tester.pageBack();
      // The scanner is still mounted during its reverse route transition.
      scanner.events.add('late detection');
      await tester.pumpAndSettle();
      scanner.torch!.complete();
      await tester.pump();
      expect(results, [null]);
      expect(scanner.disposals, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('permission-pending lifecycle does not restart the camera', (
    tester,
  ) async {
    final scanner = _Scanner()..hasPermission = false;
    await _open(tester, scanner, (_) {});
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(scanner.starts, 1);
    expect(scanner.stops, 0);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(scanner.disposals, 1);
    expect(tester.takeException(), isNull);
  });
}
