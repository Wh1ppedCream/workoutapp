/// A benchmark may seed fixtures only in a fresh or previously marked test
/// installation. The normal preview installation must never be opted in.
void requireDisposableBenchmarkInstallation({
  required bool explicitlyDisposable,
  required bool markedDisposable,
  required Set<String> preferenceKeys,
}) {
  if (!explicitlyDisposable) {
    throw StateError(
      'Profile benchmarks require TONOS_DISPOSABLE_DEVICE=true '
      'on a dedicated test installation.',
    );
  }
  if (!markedDisposable && preferenceKeys.isNotEmpty) {
    throw StateError(
      'Refusing to seed an existing, unmarked installation. '
      'Use a fresh dedicated test device; preserve the review installation.',
    );
  }
}
