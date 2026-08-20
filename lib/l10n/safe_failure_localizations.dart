import '../services/safe_failure.dart';
import 'generated/app_localizations.dart';

String safeFailureMessage(AppLocalizations strings, Object error) {
  return safeFailureGuidance(strings, SafeFailure.classify(error));
}

String safeFailureGuidance(AppLocalizations strings, SafeFailure failure) {
  return switch (failure.kind) {
    SafeFailureKind.validation => strings.safeFailureValidation,
    SafeFailureKind.offline => strings.safeFailureOffline,
    SafeFailureKind.permission => strings.safeFailurePermission,
    SafeFailureKind.storage => strings.safeFailureStorage,
    SafeFailureKind.invalidData => strings.safeFailureInvalidData,
    SafeFailureKind.notFound => strings.safeFailureNotFound,
    SafeFailureKind.temporary => strings.safeFailureTemporary,
    SafeFailureKind.unknown => strings.safeFailureUnknown,
  };
}
