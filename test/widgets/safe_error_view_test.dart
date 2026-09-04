import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/services/safe_failure.dart';
import 'package:env_test/widgets/safe_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('retryable failures expose safe guidance and one retry action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var retryCount = 0;
    const privatePath = r'C:\Users\private\health.db';
    final failure = SafeFailure.classify(
      FileSystemException('No such file', privatePath),
    );
    final strings = await AppLocalizations.delegate.load(const Locale('en'));

    try {
      await tester.pumpWidget(
        _testApp(
          SafeErrorView(
            title: strings.safeFailureLoadTitle,
            failure: failure,
            onRetry: () => retryCount += 1,
          ),
        ),
      );

      expect(find.text(strings.safeFailureLoadTitle), findsOneWidget);
      expect(find.text(strings.safeFailureNotFound), findsOneWidget);
      expect(find.textContaining(privatePath), findsNothing);
      expect(find.text(strings.commonRetry), findsOneWidget);

      final retry = find.bySemanticsLabel(strings.commonRetry);
      expect(retry, findsOneWidget);
      final node = tester.getSemantics(retry);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      await tester.tap(retry);
      expect(retryCount, 1);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('nonretryable failures do not offer a dead-end retry action', (
    tester,
  ) async {
    final strings = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      _testApp(
        SafeErrorView(
          title: strings.safeFailureSaveTitle,
          failure: const SafeFailure(
            kind: SafeFailureKind.invalidData,
            retryable: false,
          ),
          onRetry: () {},
        ),
      ),
    );

    expect(find.text(strings.safeFailureInvalidData), findsOneWidget);
    expect(find.text(strings.commonRetry), findsNothing);
  });

  testWidgets('action snackbars combine context with redacted guidance', (
    tester,
  ) async {
    const privatePath = r'C:\Users\private\health.db';
    final strings = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    safeFailureSnackBar(
                      context,
                      summary: strings.safeFailureSaveTitle,
                      error: FileSystemException(
                        'Permission denied',
                        privatePath,
                      ),
                    ),
                  );
                },
                child: const Text('Trigger'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Trigger'));
    await tester.pump();

    expect(find.textContaining(strings.safeFailureSaveTitle), findsOneWidget);
    expect(find.textContaining(strings.safeFailurePermission), findsOneWidget);
    expect(find.textContaining(privatePath), findsNothing);
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
