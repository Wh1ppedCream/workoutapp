import 'dart:async';
import 'dart:io';

import 'package:env_test/services/safe_failure.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SafeFailure', () {
    test('classifies failures into privacy-safe recovery categories', () {
      expect(
        SafeFailure.classify(FormatException('private payload')),
        isSafeFailure(SafeFailureKind.invalidData, retryable: false),
      );
      expect(
        SafeFailure.classify(TimeoutException('private operation')),
        isSafeFailure(SafeFailureKind.temporary, retryable: true),
      );
      expect(
        SafeFailure.classify(SocketException('private host')),
        isSafeFailure(SafeFailureKind.offline, retryable: true),
      );
      expect(
        SafeFailure.classify(HttpException('private URL')),
        isSafeFailure(SafeFailureKind.temporary, retryable: true),
      );
      expect(
        SafeFailure.classify(ArgumentError.value('private value')),
        isSafeFailure(SafeFailureKind.validation, retryable: false),
      );
      expect(
        SafeFailure.classify(StateError('private state')),
        isSafeFailure(SafeFailureKind.unknown, retryable: true),
      );
    });

    test('recognizes actionable system failures without retaining details', () {
      const secret = r'C:\Users\private\health.db';
      final permission = SafeFailure.classify(
        FileSystemException('Permission denied', secret),
      );
      final fullStorage = SafeFailure.classify(
        FileSystemException('No space left on device', secret),
      );
      final missing = SafeFailure.classify(
        FileSystemException('No such file', secret),
      );
      final platform = SafeFailure.classify(
        PlatformException(
          code: 'permission_denied',
          message: 'private platform details',
        ),
      );

      expect(
        permission,
        isSafeFailure(SafeFailureKind.permission, retryable: false),
      );
      expect(
        fullStorage,
        isSafeFailure(SafeFailureKind.storage, retryable: true),
      );
      expect(missing, isSafeFailure(SafeFailureKind.notFound, retryable: true));
      expect(
        platform,
        isSafeFailure(SafeFailureKind.permission, retryable: false),
      );
      expect(permission.toString(), isNot(contains(secret)));
    });

    test('does not reclassify an existing safe failure', () {
      const failure = SafeFailure(
        kind: SafeFailureKind.storage,
        retryable: false,
      );

      expect(SafeFailure.classify(failure), same(failure));
    });
  });
}

Matcher isSafeFailure(SafeFailureKind kind, {required bool retryable}) {
  return isA<SafeFailure>()
      .having((failure) => failure.kind, 'kind', kind)
      .having((failure) => failure.retryable, 'retryable', retryable);
}
