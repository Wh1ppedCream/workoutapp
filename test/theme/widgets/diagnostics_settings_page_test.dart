import 'dart:convert';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/screens/profile/settings/diagnostics_settings_page.dart';
import 'package:env_test/services/diagnostics_relay_client.dart';
import 'package:env_test/services/diagnostics_service.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PackageInfo.setMockInitialValues(
      appName: 'Tonos test',
      packageName: 'com.tonos.test',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: 'test',
    );
  });

  testWidgets('empty sync history and privacy explanation render safely', (
    tester,
  ) async {
    await _pumpPage(tester);
    final strings = _strings(tester);

    expect(find.text(strings.diagnosticsNoSyncEvents), findsOneWidget);
    expect(find.text(strings.diagnosticsNoSyncEventsBody), findsOneWidget);
    expect(find.text(strings.diagnosticsPrivacyPromiseTitle), findsOneWidget);
    expect(find.text(strings.diagnosticsPrivacyPromiseBody), findsOneWidget);

    final configured =
        DiagnosticsService.instance.anonymousDiagnosticsConfigured;
    final switchControl = tester.widget<Switch>(find.byType(Switch));
    expect(switchControl.value, isFalse);
    expect(switchControl.onChanged, configured ? isNotNull : isNull);
    final diagnosticsRow = tester.widget<SettingsSwitchTile>(
      find.ancestor(
        of: find.text(strings.diagnosticsCrashReporting),
        matching: find.byType(SettingsSwitchTile),
      ),
    );
    expect(diagnosticsRow.onChanged, configured ? isNotNull : isNull);
  });

  testWidgets('sync history shows five newest rows, all rows, then collapses', (
    tester,
  ) async {
    final encodedEvents = _encodedEvents(7);
    SharedPreferences.setMockInitialValues(<String, Object>{
      SyncDiagnosticsStore.eventsKey: encodedEvents,
    });

    await _pumpPage(tester);
    final strings = _strings(tester);

    expect(_visibleEventDurations(tester), <int>[700, 600, 500, 400, 300]);
    expect(find.text(strings.diagnosticsShowAllHistory), findsOneWidget);
    expect(find.text(strings.diagnosticsShowLessHistory), findsNothing);

    await tester.tap(find.text(strings.diagnosticsShowAllHistory));
    await tester.pumpAndSettle();
    expect(_visibleEventDurations(tester), <int>[
      700,
      600,
      500,
      400,
      300,
      200,
      100,
    ]);
    expect(find.text(strings.diagnosticsShowLessHistory), findsOneWidget);

    final hideHistory = find.text(strings.diagnosticsShowLessHistory);
    await tester.ensureVisible(hideHistory);
    await tester.pumpAndSettle();
    await tester.tap(hideHistory);
    await tester.pumpAndSettle();
    expect(_visibleEventDurations(tester), <int>[700, 600, 500, 400, 300]);
    expect(find.text(strings.diagnosticsShowAllHistory), findsOneWidget);
  });

  testWidgets('canceling clear-history confirmation preserves local history', (
    tester,
  ) async {
    final encodedEvents = _encodedEvents(2);
    SharedPreferences.setMockInitialValues(<String, Object>{
      SyncDiagnosticsStore.eventsKey: encodedEvents,
    });

    await _pumpPage(tester);
    final strings = _strings(tester);
    final clearAction = find.text(strings.diagnosticsClearHistory);
    await tester.ensureVisible(clearAction);
    await tester.tap(clearAction);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(strings.diagnosticsClearHistoryBody),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text(strings.commonCancel));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(SyncDiagnosticsStore.eventsKey),
      encodedEvents,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'canceling shared-diagnostics deletion preserves the local receipt',
    (tester) async {
      const receipt = DiagnosticsRelayReceipt(
        receiptId: 'receipt-test-1',
        deletionToken: 'test-deletion-token',
        endpoint: 'https://relay.example.invalid/diagnostics',
      );
      final encodedReceipts = jsonEncode(<Map<String, String>>[
        receipt.toJson(),
      ]);
      SharedPreferences.setMockInitialValues(<String, Object>{
        DiagnosticsRelayReceiptStore.receiptsKey: encodedReceipts,
      });

      await _pumpPage(tester);
      final strings = _strings(tester);
      final deleteAction = find.text(strings.diagnosticsDeleteShared);
      await tester.scrollUntilVisible(
        deleteAction,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(deleteAction);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      final confirmation = strings.diagnosticsDeleteSharedConfirmBody;
      expect(find.text(confirmation), findsOneWidget);
      expect(confirmation, contains('receipt-backed reports'));
      expect(confirmation, contains('does not turn off future sharing'));
      expect(confirmation, contains('local fitness database'));
      expect(confirmation, contains('up to 30 additional days'));
      await tester.tap(find.text(strings.commonCancel));
      await tester.pumpAndSettle();

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString(DiagnosticsRelayReceiptStore.receiptsKey),
        encodedReceipts,
      );
      expect(find.byType(AlertDialog), findsNothing);
    },
  );
}

Future<void> _pumpPage(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: ExpressiveThemeDefinition.light(),
      locale: const Locale('en'),
      localizationsDelegates: tonosLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const DiagnosticsSettingsPage(),
    ),
  );
  // The page calls PackageInfo.fromPlatform during loading; keep the harness
  // bounded instead of waiting for every platform/theme animation to settle.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
}

AppLocalizations _strings(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(DiagnosticsSettingsPage)));

String _encodedEvents(int count) => jsonEncode(<Map<String, Object>>[
  for (var index = 0; index < count; index++)
    <String, Object>{
      'timestamp': DateTime.utc(
        2026,
        10,
        12,
        12,
      ).subtract(Duration(minutes: index)).toIso8601String(),
      'operation': index.isEven ? 'exercise_media' : 'shared_media',
      'source': 'bundled',
      'outcome': index.isEven ? 'succeeded' : 'failed',
      'duration_ms': (count - index) * 100,
      'manifest_version': index + 1,
      'item_count': index + 2,
    },
]);

List<int> _visibleEventDurations(WidgetTester tester) => tester
    .widgetList<Text>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text && widget.data?.contains(' ms • manifest ') == true,
      ),
    )
    .map((text) {
      final match = RegExp(r'• (\d+) ms • manifest ').firstMatch(text.data!);
      expect(match, isNotNull, reason: text.data);
      return int.parse(match!.group(1)!);
    })
    .toList(growable: false);
