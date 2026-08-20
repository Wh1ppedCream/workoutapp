import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Privacy-safe categories that presentation code may use for recovery UI.
enum SafeFailureKind {
  validation,
  offline,
  permission,
  storage,
  invalidData,
  notFound,
  temporary,
  unknown,
}

/// A failure description that is safe to retain in UI state.
///
/// The original exception and its message are deliberately not retained so
/// paths, SQL, URLs, and user data cannot accidentally reach rendered copy.
class SafeFailure {
  const SafeFailure({required this.kind, required this.retryable});

  final SafeFailureKind kind;
  final bool retryable;

  static SafeFailure classify(Object error) {
    if (error is SafeFailure) return error;
    if (error is FormatException) {
      return const SafeFailure(
        kind: SafeFailureKind.invalidData,
        retryable: false,
      );
    }
    if (error is TimeoutException) {
      return const SafeFailure(
        kind: SafeFailureKind.temporary,
        retryable: true,
      );
    }
    if (error is SocketException) {
      return const SafeFailure(kind: SafeFailureKind.offline, retryable: true);
    }
    if (error is HttpException) {
      return const SafeFailure(
        kind: SafeFailureKind.temporary,
        retryable: true,
      );
    }
    if (error is FileSystemException) {
      return _classifySystemText(
        '${error.message} ${error.osError?.message ?? ''}',
        fallback: const SafeFailure(
          kind: SafeFailureKind.storage,
          retryable: true,
        ),
      );
    }
    if (error is PlatformException) {
      return _classifySystemText(
        '${error.code} ${error.message ?? ''}',
        fallback: const SafeFailure(
          kind: SafeFailureKind.temporary,
          retryable: true,
        ),
      );
    }
    if (error is ArgumentError || error is RangeError) {
      return const SafeFailure(
        kind: SafeFailureKind.validation,
        retryable: false,
      );
    }
    return const SafeFailure(kind: SafeFailureKind.unknown, retryable: true);
  }

  static SafeFailure _classifySystemText(
    String value, {
    required SafeFailure fallback,
  }) {
    final text = value.toLowerCase();
    if (text.contains('permission') ||
        text.contains('denied') ||
        text.contains('not_authorized')) {
      return const SafeFailure(
        kind: SafeFailureKind.permission,
        retryable: false,
      );
    }
    if (text.contains('no space') ||
        text.contains('disk full') ||
        text.contains('storage full')) {
      return const SafeFailure(kind: SafeFailureKind.storage, retryable: true);
    }
    if (text.contains('not found') ||
        text.contains('no such file') ||
        text.contains('404')) {
      return const SafeFailure(kind: SafeFailureKind.notFound, retryable: true);
    }
    if (text.contains('network') ||
        text.contains('offline') ||
        text.contains('connection')) {
      return const SafeFailure(kind: SafeFailureKind.offline, retryable: true);
    }
    return fallback;
  }
}
